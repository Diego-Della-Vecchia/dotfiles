import type { ExtensionAPI, ExtensionContext } from "@mariozechner/pi-coding-agent";
import { Type } from "@sinclair/typebox";
import { spawn, ChildProcess } from "node:child_process";
import * as fs from "node:fs";
import * as path from "node:path";
import { pathToFileURL, fileURLToPath } from "node:url";

// LSP message types
interface LSPMessage {
  jsonrpc: "2.0";
  id?: number | string;
  method?: string;
  params?: any;
  result?: any;
  error?: any;
}

interface LSPDiagnostic {
  range: {
    start: { line: number; character: number };
    end: { line: number; character: number };
  };
  severity?: 1 | 2 | 3 | 4; // Error, Warning, Info, Hint
  code?: string | number;
  source?: string;
  message: string;
}

interface LSPConfig {
  command: string[];
  extensions: string[];
  env?: Record<string, string>;
  initialization?: Record<string, any>;
  disabled?: boolean;
}

interface LSPServerState {
  process: ChildProcess;
  rootPath: string;
  messageId: number;
  pendingRequests: Map<number, { resolve: (value: any) => void; reject: (reason?: any) => void }>;
  notificationHandlers: Map<string, ((params: any) => void)[]>;
  initialized: boolean;
  documents: Set<string>; // Track open documents
}

// Global state
let config: Record<string, LSPConfig> | false = {};
let servers: Map<string, LSPServerState> = new Map(); // key: rootPath+serverName
let messageBuffer = "";

/**
 * Load LSP configuration from settings files
 */
async function loadConfig(cwd: string): Promise<void> {
  // Try project settings first, then global
  const configPaths = [
    path.join(cwd, ".pi", "settings.json"),
    path.join(process.env.HOME || "", ".pi", "agent", "settings.json"),
  ];

  for (const configPath of configPaths) {
    if (fs.existsSync(configPath)) {
      try {
        const content = fs.readFileSync(configPath, "utf-8");
        const settings = JSON.parse(content);
        if (settings.lsp !== undefined) {
          config = settings.lsp;
          return;
        }
      } catch (e) {
        console.error(`Failed to load LSP config from ${configPath}:`, e);
      }
    }
  }

  // Default: empty config (no LSP servers)
  config = {};
}

/**
 * Find the project root for a file (where relevant config files exist)
 */
function findProjectRoot(filePath: string, serverName: string): string | null {
  const dir = path.dirname(filePath);
  const markers: Record<string, string[]> = {
    typescript: ["tsconfig.json", "package.json", ".git"],
    tsgo: ["tsconfig.json", "package.json", ".git"],
    rust: ["Cargo.toml", ".git"],
    python: ["pyproject.toml", "setup.py", "requirements.txt", ".git"],
    go: ["go.mod", ".git"],
    default: [".git"],
  };

  const checks = markers[serverName] || markers.default;
  let current = dir;

  while (current !== path.dirname(current)) {
    for (const marker of checks) {
      if (fs.existsSync(path.join(current, marker))) {
        return current;
      }
    }
    current = path.dirname(current);
  }

  // Fallback to file's directory
  return dir;
}

/**
 * Get file extension
 */
function getExtension(filePath: string): string {
  return path.extname(filePath).toLowerCase();
}

/**
 * Find applicable LSP servers for a file
 */
function findServersForFile(filePath: string): Array<{ name: string; config: LSPConfig }> {
  if (config === false) return [];

  const ext = getExtension(filePath);
  const results: Array<{ name: string; config: LSPConfig }> = [];

  for (const [name, serverConfig] of Object.entries(config)) {
    if (serverConfig.disabled) continue;
    if (serverConfig.extensions?.includes(ext)) {
      results.push({ name, config: serverConfig });
    }
  }

  return results;
}

/**
 * Spawn an LSP server
 */
async function spawnServer(
  serverName: string,
  serverConfig: LSPConfig,
  rootPath: string,
): Promise<LSPServerState | null> {
  const key = `${rootPath}:${serverName}`;

  if (servers.has(key)) {
    return servers.get(key)!;
  }

  if (!serverConfig.command || serverConfig.command.length === 0) {
    return null;
  }

  const [cmd, ...args] = serverConfig.command;

  return new Promise((resolve, reject) => {
    const child = spawn(cmd, args, {
      cwd: rootPath,
      env: { ...process.env, ...serverConfig.env },
      stdio: ["pipe", "pipe", "pipe"],
    });

    const serverState: LSPServerState = {
      process: child,
      rootPath,
      messageId: 0,
      pendingRequests: new Map(),
      notificationHandlers: new Map(),
      initialized: false,
      documents: new Set(),
    };

    // Handle stdout
    child.stdout!.on("data", (data: Buffer) => {
      messageBuffer += data.toString("utf-8");
      processMessageBuffer(serverState);
    });

    // Handle stderr (log but don't crash)
    child.stderr!.on("data", (data: Buffer) => {
      console.error(`[LSP ${serverName}]`, data.toString("utf-8").trim());
    });

    // Handle process exit
    child.on("exit", (code) => {
      console.error(`[LSP ${serverName}] Process exited with code ${code}`);
      servers.delete(key);
      // Reject pending requests
      for (const [, { reject }] of serverState.pendingRequests) {
        reject(new Error("LSP server process exited"));
      }
    });

    child.on("error", (err) => {
      console.error(`[LSP ${serverName}] Process error:`, err);
      servers.delete(key);
      reject(err);
    });

    // Wait a bit for process to start
    setTimeout(async () => {
      try {
        await initializeServer(serverState, serverName, rootPath, serverConfig);
        servers.set(key, serverState);
        resolve(serverState);
      } catch (e) {
        child.kill();
        reject(e);
      }
    }, 100);
  });
}

/**
 * Process accumulated message buffer
 */
function processMessageBuffer(serverState: LSPServerState): void {
  while (true) {
    // Look for Content-Length header
    const headerMatch = messageBuffer.match(/Content-Length: (\d+)\r?\n/);
    if (!headerMatch) break;

    const contentLength = parseInt(headerMatch[1], 10);
    const headerEnd = messageBuffer.indexOf("\r\n\r\n");
    if (headerEnd === -1) break;

    const messageStart = headerEnd + 4;
    if (messageBuffer.length < messageStart + contentLength) break;

    const content = messageBuffer.slice(messageStart, messageStart + contentLength);
    messageBuffer = messageBuffer.slice(messageStart + contentLength);

    try {
      const message: LSPMessage = JSON.parse(content);
      handleMessage(serverState, message);
    } catch (e) {
      console.error("[LSP] Failed to parse message:", e);
    }
  }
}

/**
 * Handle incoming LSP message
 */
function handleMessage(serverState: LSPServerState, message: LSPMessage): void {
  if (message.id !== undefined && serverState.pendingRequests.has(message.id)) {
    // Response to a request
    const { resolve, reject } = serverState.pendingRequests.get(message.id)!;
    serverState.pendingRequests.delete(message.id);

    if (message.error) {
      reject(new Error(message.error.message || "LSP error"));
    } else {
      resolve(message.result);
    }
  } else if (message.method) {
    // Notification from server
    const handlers = serverState.notificationHandlers.get(message.method) || [];
    for (const handler of handlers) {
      handler(message.params);
    }
  }
}

/**
 * Send a request to LSP server
 */
function sendRequest<T>(serverState: LSPServerState, method: string, params: any): Promise<T> {
  return new Promise((resolve, reject) => {
    const id = ++serverState.messageId;
    serverState.pendingRequests.set(id, { resolve, reject });

    const message: LSPMessage = {
      jsonrpc: "2.0",
      id,
      method,
      params,
    };

    sendMessage(serverState, message);

    // Timeout after 10 seconds
    setTimeout(() => {
      if (serverState.pendingRequests.has(id)) {
        serverState.pendingRequests.delete(id);
        reject(new Error(`LSP request timeout: ${method}`));
      }
    }, 10000);
  });
}

/**
 * Send a notification to LSP server
 */
function sendNotification(serverState: LSPServerState, method: string, params: any): void {
  const message: LSPMessage = {
    jsonrpc: "2.0",
    method,
    params,
  };
  sendMessage(serverState, message);
}

/**
 * Send raw message to LSP server
 */
function sendMessage(serverState: LSPServerState, message: LSPMessage): void {
  const content = JSON.stringify(message);
  const data = `Content-Length: ${Buffer.byteLength(content)}\r\n\r\n${content}`;
  serverState.process.stdin!.write(data);
}

/**
 * Initialize LSP server
 */
async function initializeServer(
  serverState: LSPServerState,
  serverName: string,
  rootPath: string,
  serverConfig: LSPConfig,
): Promise<void> {
  const rootUri = pathToFileURL(rootPath).href;

  const initializeParams = {
    processId: process.pid,
    rootPath,
    rootUri,
    capabilities: {
      textDocument: {
        synchronization: { dynamicRegistration: false },
        completion: { dynamicRegistration: false },
        hover: { dynamicRegistration: false },
        definition: { dynamicRegistration: false },
        documentSymbol: { dynamicRegistration: false },
        codeAction: { dynamicRegistration: false },
        formatting: { dynamicRegistration: false },
        rename: { dynamicRegistration: false },
        publishDiagnostics: { relatedInformation: true },
      },
      workspace: {
        applyEdit: false,
        workspaceEdit: { documentChanges: false },
        didChangeConfiguration: { dynamicRegistration: false },
        didChangeWatchedFiles: { dynamicRegistration: false },
        workspaceFolders: false,
        configuration: false,
      },
    },
    workspaceFolders: null,
    initializationOptions: serverConfig.initialization || {},
  };

  await sendRequest(serverState, "initialize", initializeParams);
  serverState.initialized = true;

  // Send initialized notification
  sendNotification(serverState, "initialized", {});
}

/**
 * Open a document in LSP server
 */
async function openDocument(serverState: LSPServerState, filePath: string): Promise<void> {
  if (serverState.documents.has(filePath)) {
    return; // Already open
  }

  const content = fs.readFileSync(filePath, "utf-8");
  const uri = pathToFileURL(filePath).href;

  sendNotification(serverState, "textDocument/didOpen", {
    textDocument: {
      uri,
      languageId: getLanguageId(filePath),
      version: 1,
      text: content,
    },
  });

  serverState.documents.add(filePath);
}

/**
 * Get language ID from file path
 */
function getLanguageId(filePath: string): string {
  const ext = getExtension(filePath);
  const mapping: Record<string, string> = {
    ".ts": "typescript",
    ".tsx": "typescriptreact",
    ".js": "javascript",
    ".jsx": "javascriptreact",
    ".rs": "rust",
    ".py": "python",
    ".go": "go",
    ".java": "java",
    ".c": "c",
    ".cpp": "cpp",
    ".h": "c",
    ".hpp": "cpp",
    ".json": "json",
    ".md": "markdown",
    ".css": "css",
    ".html": "html",
    ".yaml": "yaml",
    ".yml": "yaml",
    ".toml": "toml",
  };
  return mapping[ext] || "plaintext";
}

/**
 * Get diagnostics for a file
 */
async function getDiagnostics(filePath: string): Promise<LSPDiagnostic[]> {
  if (config === false) return [];

  const serversForFile = findServersForFile(filePath);
  if (serversForFile.length === 0) {
    return [];
  }

  const allDiagnostics: LSPDiagnostic[] = [];

  for (const { name, config: serverConfig } of serversForFile) {
    const rootPath = findProjectRoot(filePath, name);
    if (!rootPath) continue;

    try {
      const serverState = await spawnServer(name, serverConfig, rootPath);
      if (!serverState) continue;

      // Open document
      await openDocument(serverState, filePath);

      // Wait a bit for diagnostics to be published
      await new Promise((resolve) => setTimeout(resolve, 500));

      // Request diagnostics via custom method or wait for notification
      // Since diagnostics are usually sent as notifications, we'll need to track them
      // For now, let's use a different approach: check if server supports pulling diagnostics
      try {
        const result = await sendRequest<any>(serverState, "textDocument/diagnostic", {
          textDocument: { uri: pathToFileURL(filePath).href },
        });
        if (result?.items) {
          allDiagnostics.push(...result.items);
        }
      } catch {
        // Server might not support pull diagnostics, that's ok
      }
    } catch (e) {
      console.error(`[LSP ${name}] Error getting diagnostics:`, e);
    }
  }

  return allDiagnostics;
}

/**
 * Format diagnostic for display
 */
function formatDiagnostic(d: LSPDiagnostic): string {
  const severity = ["ERROR", "ERROR", "WARNING", "INFO", "HINT"][d.severity || 1];
  const line = d.range.start.line + 1;
  const col = d.range.start.character + 1;
  const code = d.code ? ` [${d.code}]` : "";
  return `${severity} [${line}:${col}]${code}: ${d.message}`;
}

/**
 * Shutdown all LSP servers
 */
async function shutdownServers(): Promise<void> {
  for (const [key, serverState] of servers) {
    try {
      await sendRequest(serverState, "shutdown", {});
      sendNotification(serverState, "exit", {});
      serverState.process.kill();
    } catch (e) {
      console.error(`[LSP] Error shutting down server ${key}:`, e);
      serverState.process.kill();
    }
  }
  servers.clear();
}

/**
 * Extension main function
 */
export default function lspDiagnosticsExtension(pi: ExtensionAPI) {
  // Load configuration on session start
  pi.on("session_start", async (_event, ctx) => {
    await loadConfig(ctx.cwd);

    if (config === false) {
      console.log("[LSP] Diagnostics disabled by configuration");
    } else {
      const serverNames = Object.keys(config);
      if (serverNames.length > 0) {
        ctx.ui.notify(`LSP servers configured: ${serverNames.join(", ")}`, "info");
      }
    }
  });

  // Shutdown servers on session end
  pi.on("session_shutdown", async () => {
    await shutdownServers();
  });

  // Register the LSP diagnostics tool
  pi.registerTool({
    name: "lsp_diagnostics",
    label: "LSP Diagnostics",
    description:
      "Get language server protocol (LSP) diagnostics for a file. " +
      "Shows errors, warnings, and hints from configured LSP servers. " +
      "Configure servers in ~/.pi/agent/settings.json or .pi/settings.json under the 'lsp' key.",
    promptSnippet: "Get LSP diagnostics (errors, warnings) for a file",
    promptGuidelines: [
      "Use this tool after editing files to check for type errors, lint warnings, or other issues",
      "Use after write, edit, or bash commands that modify source files",
      "Particularly useful before running tests or committing changes",
    ],
    parameters: Type.Object({
      filePath: Type.String({
        description: "Absolute or relative path to the file to check",
      }),
      timeout: Type.Optional(
        Type.Number({
          description: "Timeout in milliseconds (default: 5000)",
          default: 5000,
        }),
      ),
    }),

    async execute(toolCallId, params, signal, onUpdate, ctx) {
      if (config === false) {
        return {
          content: [{ type: "text", text: "LSP diagnostics are disabled in configuration." }],
          details: { disabled: true },
        };
      }

      const absolutePath = path.isAbsolute(params.filePath)
        ? params.filePath
        : path.join(ctx.cwd, params.filePath);

      if (!fs.existsSync(absolutePath)) {
        throw new Error(`File not found: ${absolutePath}`);
      }

      onUpdate?.({
        content: [{ type: "text", text: `Getting LSP diagnostics for ${params.filePath}...` }],
      });

      try {
        const diagnostics = await getDiagnostics(absolutePath);

        if (diagnostics.length === 0) {
          return {
            content: [{ type: "text", text: `✓ No diagnostics for ${params.filePath}` }],
            details: { filePath: absolutePath, diagnostics: [] },
          };
        }

        const formatted = diagnostics.map(formatDiagnostic).join("\n");
        const summary = `Found ${diagnostics.length} diagnostic(s) for ${params.filePath}:`;

        return {
          content: [{ type: "text", text: `${summary}\n\n${formatted}` }],
          details: { filePath: absolutePath, diagnostics },
        };
      } catch (e) {
        const error = e instanceof Error ? e.message : String(e);
        throw new Error(`Failed to get LSP diagnostics: ${error}`);
      }
    },
  });

  // Register command to check LSP status
  pi.registerCommand("lsp-status", {
    description: "Show LSP server status and configuration",
    handler: async (_args, ctx) => {
      if (config === false) {
        ctx.ui.notify("LSP diagnostics are disabled", "info");
        return;
      }

      const serverNames = Object.keys(config);
      if (serverNames.length === 0) {
        ctx.ui.notify("No LSP servers configured", "warning");
        return;
      }

      const activeServers = Array.from(servers.entries()).map(([key, state]) => ({
        key,
        initialized: state.initialized,
        documents: state.documents.size,
      }));

      ctx.ui.notify(
        `LSP: ${serverNames.length} configured (${serverNames.join(", ")}), ${activeServers.length} active`,
        "info",
      );
    },
  });

  // Optional: Auto-run diagnostics after file modifications
  pi.on("tool_result", async (event, ctx) => {
    // Only interested in write and edit tool results
    if (event.toolName !== "write" && event.toolName !== "edit") {
      return;
    }

    if (config === false) return;

    // Get the file path from the tool input
    const filePath = event.input?.path as string | undefined;
    if (!filePath) return;

    // Check if this file type has LSP support
    const serversForFile = findServersForFile(filePath);
    if (serversForFile.length === 0) return;

    // Don't block - just notify about available diagnostics
    const relPath = path.relative(ctx.cwd, filePath);
    ctx.ui.setStatus("lsp", `LSP ready: ${relPath}`);

    // Clear status after a few seconds
    setTimeout(() => {
      ctx.ui.setStatus("lsp", undefined);
    }, 3000);
  });
}
