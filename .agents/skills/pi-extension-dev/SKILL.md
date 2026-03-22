---
name: pi-extension-dev
description: |
  Create extensions for the pi coding agent using the Agent SDK. Use this skill when the user wants to:
  - Create a new pi agent extension
  - Extend pi with custom tools, commands, UI components, or event handlers
  - Build sub-agents, permission gates, custom providers, or integrations
  - Modify pi's behavior via lifecycle hooks
  - Package and share extensions via npm or git
  
  This skill covers the full extension development lifecycle: from simple tools to complex multi-file extensions with dependencies, custom TUI components, and provider integrations.
---

# Pi Extension Development

Create powerful extensions for the pi coding agent to customize its behavior, add new capabilities, and integrate with external systems.

## What Are Extensions?

Extensions are TypeScript modules that extend pi with:
- **Custom tools** - New capabilities the LLM can invoke
- **Event handlers** - React to session lifecycle, tool calls, and agent state
- **Commands** - User-triggered actions via `/command`
- **UI components** - Custom TUI interfaces and overlays
- **Custom providers** - Connect to new AI model providers

## Quick Start

### Minimal Extension

Create `~/.pi/agent/extensions/my-extension.ts`:

```typescript
import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";
import { Type } from "@sinclair/typebox";

export default function (pi: ExtensionAPI) {
  // React to events
  pi.on("tool_call", async (event, ctx) => {
    if (event.toolName === "bash" && event.input.command?.includes("rm -rf")) {
      const ok = await ctx.ui.confirm("Dangerous!", "Allow rm -rf?");
      if (!ok) return { block: true, reason: "Blocked by user" };
    }
  });

  // Register a custom tool
  pi.registerTool({
    name: "greet",
    label: "Greet",
    description: "Greet someone by name",
    parameters: Type.Object({
      name: Type.String({ description: "Name to greet" }),
    }),
    async execute(toolCallId, params, signal, onUpdate, ctx) {
      return {
        content: [{ type: "text", text: `Hello, ${params.name}!` }],
        details: {},
      };
    },
  });

  // Register a command
  pi.registerCommand("hello", {
    description: "Say hello",
    handler: async (args, ctx) => {
      ctx.ui.notify(`Hello ${args || "world"}!`, "info");
    },
  });
}
```

Test with:
```bash
pi -e ./my-extension.ts
```

## Extension Structure

### Single File
```
~/.pi/agent/extensions/
└── my-extension.ts
```

### Directory with Index
```
~/.pi/agent/extensions/
└── my-extension/
    ├── index.ts        # Entry point
    ├── tools.ts        # Helper modules
    └── utils.ts
```

### With Dependencies
```
~/.pi/agent/extensions/
└── my-extension/
    ├── package.json    # npm dependencies
    ├── package-lock.json
    ├── node_modules/
    └── src/
        └── index.ts
```

## Extension API Overview

### Core Interface

```typescript
import type { ExtensionAPI, ExtensionContext } from "@mariozechner/pi-coding-agent";

export default function (pi: ExtensionAPI) {
  // All handlers receive ctx: ExtensionContext
  pi.on("event_name", async (event, ctx) => {
    // ctx.ui - User interaction methods
    // ctx.sessionManager - Read session state
    // ctx.modelRegistry - Access models
    // ctx.cwd - Current working directory
  });
}
```

### Context Properties

| Property | Description |
|----------|-------------|
| `ctx.ui` | Dialogs, notifications, widgets, custom components |
| `ctx.hasUI` | Boolean - false in print/JSON mode |
| `ctx.sessionManager` | Read session entries, tree, labels |
| `ctx.modelRegistry` | Access available models |
| `ctx.cwd` | Current working directory |
| `ctx.isIdle()` | Check if agent is idle |
| `ctx.abort()` | Abort current operation |
| `ctx.shutdown()` | Graceful shutdown |
| `ctx.getContextUsage()` | Current token usage |
| `ctx.compact()` | Trigger compaction |
| `ctx.getSystemPrompt()` | Current effective system prompt |

## Lifecycle Events

### Session Events

```typescript
// CLI startup - configure session directory
pi.on("session_directory", async (event) => {
  return { sessionDir: "/custom/path" };
});

// Session started
pi.on("session_start", async (_event, ctx) => {
  ctx.ui.notify("Extension loaded!", "info");
});

// Before/after session switch
pi.on("session_before_switch", async (event, ctx) => {
  // event.reason - "new" or "resume"
  // event.targetSessionFile - for "resume"
  return { cancel: true }; // Cancel the switch
});

// Before/after fork
pi.on("session_before_fork", async (event, ctx) => {
  // event.entryId - entry being forked from
  return { skipConversationRestore: true };
});

// Compaction hooks
pi.on("session_before_compact", async (event, ctx) => {
  // Return custom summary or cancel
  return {
    compaction: {
      summary: "Custom summary...",
      firstKeptEntryId: event.preparation.firstKeptEntryId,
      tokensBefore: event.preparation.tokensBefore,
    }
  };
});

// Tree navigation
pi.on("session_before_tree", async (event, ctx) => {
  return { cancel: true };
  // OR: return { summary: { summary: "...", details: {} } };
});

// Shutdown
pi.on("session_shutdown", async (_event, ctx) => {
  // Cleanup, save state
});
```

### Agent Events

```typescript
// Before agent starts processing
pi.on("before_agent_start", async (event, ctx) => {
  // event.prompt - user input
  // event.images - attached images
  // event.systemPrompt - current system prompt
  return {
    message: { customType: "my-ext", content: "Context", display: true },
    systemPrompt: event.systemPrompt + "\n\nAdditional instructions...",
  };
});

// Agent start/end
pi.on("agent_start", async (_event, ctx) => {});
pi.on("agent_end", async (event, ctx) => {
  // event.messages - messages from this prompt
});

// Turn lifecycle (one LLM call + tool executions)
pi.on("turn_start", async (event, ctx) => {
  // event.turnIndex, event.timestamp
});
pi.on("turn_end", async (event, ctx) => {
  // event.turnIndex, event.message, event.toolResults
});

// Message lifecycle
pi.on("message_start", async (event, ctx) => {});
pi.on("message_update", async (event, ctx) => {
  // Streaming updates from assistant
});
pi.on("message_end", async (event, ctx) => {});
```

### Tool Events

```typescript
import { isToolCallEventType, isBashToolResult } from "@mariozechner/pi-coding-agent";

// Intercept tool calls - can block
pi.on("tool_call", async (event, ctx) => {
  // event.toolName, event.toolCallId, event.input
  
  if (isToolCallEventType("bash", event)) {
    // event.input is typed as { command: string; timeout?: number }
    if (event.input.command.includes("rm -rf")) {
      return { block: true, reason: "Dangerous command" };
    }
  }
});

// Modify tool results
pi.on("tool_result", async (event, ctx) => {
  // event.toolName, event.content, event.details, event.isError
  
  if (isBashToolResult(event)) {
    // event.details is typed as BashToolDetails
  }
  
  // Modify result (partial update)
  return { content: [...], details: {...}, isError: false };
});

// Tool execution lifecycle
pi.on("tool_execution_start", async (event, ctx) => {});
pi.on("tool_execution_update", async (event, ctx) => {});
pi.on("tool_execution_end", async (event, ctx) => {});
```

### Input Events

```typescript
pi.on("input", async (event, ctx) => {
  // event.text - raw input (before skill/template expansion)
  // event.images - attached images
  // event.source - "interactive" | "rpc" | "extension"
  
  // Transform input
  if (event.text.startsWith("?quick ")) {
    return { action: "transform", text: `Respond briefly: ${event.text.slice(7)}` };
  }
  
  // Handle completely (skip agent)
  if (event.text === "ping") {
    ctx.ui.notify("pong", "info");
    return { action: "handled" };
  }
  
  return { action: "continue" };
});
```

## Custom Tools

### Basic Tool

```typescript
import { Type } from "@sinclair/typebox";
import { StringEnum } from "@mariozechner/pi-ai";

pi.registerTool({
  name: "my_tool",
  label: "My Tool",
  description: "What this tool does",
  promptSnippet: "One-line summary for system prompt",
  promptGuidelines: ["Use this tool when..."],
  
  parameters: Type.Object({
    action: StringEnum(["list", "add"] as const),  // Use StringEnum for Google compatibility
    text: Type.Optional(Type.String()),
  }),
  
  async execute(toolCallId, params, signal, onUpdate, ctx) {
    // Stream progress
    onUpdate?.({ content: [{ type: "text", text: "Working..." }] });
    
    // Check cancellation
    if (signal?.aborted) {
      return { content: [{ type: "text", text: "Cancelled" }] };
    }
    
    // Return result
    return {
      content: [{ type: "text", text: "Done" }],
      details: { data: "..." },  // For rendering & state
    };
  },
});
```

### Tool with Custom Rendering

```typescript
import { Text } from "@mariozechner/pi-tui";

pi.registerTool({
  name: "my_tool",
  // ... other properties
  
  renderCall(args, theme, context) {
    let text = theme.fg("toolTitle", theme.bold("my_tool "));
    text += theme.fg("muted", args.action);
    return new Text(text, 0, 0);
  },
  
  renderResult(result, { expanded, isPartial }, theme, context) {
    if (isPartial) {
      return new Text(theme.fg("warning", "Processing..."), 0, 0);
    }
    
    let text = theme.fg("success", "✓ Done");
    if (expanded && result.details?.items) {
      for (const item of result.details.items) {
        text += "\n  " + theme.fg("dim", item);
      }
    }
    return new Text(text, 0, 0);
  },
});
```

### Overriding Built-in Tools

Register a tool with the same name as a built-in to override it:

```typescript
pi.registerTool({
  name: "read",  // Overrides built-in read
  label: "Read",
  description: "Read files with logging",
  parameters: ReadParams,
  async execute(toolCallId, params, signal, onUpdate, ctx) {
    console.log(`Reading: ${params.path}`);
    // Call original or implement custom logic
    return originalRead.execute(toolCallId, params, signal, onUpdate, ctx);
  },
});
```

### Truncation Utilities

```typescript
import {
  truncateHead,
  truncateTail,
  formatSize,
  DEFAULT_MAX_BYTES,
  DEFAULT_MAX_LINES,
} from "@mariozechner/pi-coding-agent";

async execute(toolCallId, params, signal, onUpdate, ctx) {
  const output = await runCommand();
  
  const truncation = truncateHead(output, {
    maxLines: DEFAULT_MAX_LINES,
    maxBytes: DEFAULT_MAX_BYTES,
  });
  
  let result = truncation.content;
  if (truncation.truncated) {
    const tempFile = writeTempFile(output);
    result += `\n\n[Output truncated. Full output: ${tempFile}]`;
  }
  
  return { content: [{ type: "text", text: result }] };
}
```

## UI Components

### Dialogs

```typescript
// Select from options
const choice = await ctx.ui.select("Pick one:", ["A", "B", "C"]);

// Confirm dialog
const ok = await ctx.ui.confirm("Delete?", "This cannot be undone");

// Text input
const name = await ctx.ui.input("Name:", "placeholder");

// Multi-line editor
const text = await ctx.ui.editor("Edit:", "prefilled text");

// Notification (non-blocking)
ctx.ui.notify("Done!", "info");  // "info" | "warning" | "error"

// Timed dialog with countdown
const confirmed = await ctx.ui.confirm(
  "Timed Confirmation",
  "Auto-cancel in 5 seconds",
  { timeout: 5000 }
);
```

### Custom Components

```typescript
import { Text, Component } from "@mariozechner/pi-tui";

const result = await ctx.ui.custom<boolean>((tui, theme, keybindings, done) => {
  const text = new Text("Press Enter to confirm, Escape to cancel", 1, 1);
  
  text.handleInput = (data: string) => {
    if (data === "return") done(true);
    if (data === "escape") done(false);
    return true;
  };
  
  return text;
});
```

### Widgets and Status

```typescript
// Status in footer
ctx.ui.setStatus("my-ext", "Processing...");
ctx.ui.setStatus("my-ext", undefined);  // Clear

// Working message during streaming
ctx.ui.setWorkingMessage("Thinking deeply...");

// Widget above/below editor
ctx.ui.setWidget("my-widget", ["Line 1", "Line 2"]);
ctx.ui.setWidget("my-widget", ["Line 1", "Line 2"], { placement: "belowEditor" });
ctx.ui.setWidget("my-widget", undefined);  // Clear

// Custom footer
ctx.ui.setFooter((tui, theme) => ({
  render(width) { return [theme.fg("dim", "Custom footer")]; },
  invalidate() {},
}));

// Terminal title
ctx.ui.setTitle("pi - my-project");

// Editor text
ctx.ui.setEditorText("Prefill text");
const current = ctx.ui.getEditorText();
```

### Overlays

```typescript
const result = await ctx.ui.custom<string | null>(
  (tui, theme, keybindings, done) => new MyDialog({ onClose: done }),
  {
    overlay: true,
    overlayOptions: {
      anchor: "top-right",
      width: "50%",
      margin: 2,
    },
  }
);
```

### Custom Editor

```typescript
import { CustomEditor } from "@mariozechner/pi-coding-agent";
import { matchesKey } from "@mariozechner/pi-tui";

class VimEditor extends CustomEditor {
  private mode: "normal" | "insert" = "insert";
  
  handleInput(data: string): void {
    if (matchesKey(data, "escape") && this.mode === "insert") {
      this.mode = "normal";
      return;
    }
    if (this.mode === "normal" && data === "i") {
      this.mode = "insert";
      return;
    }
    super.handleInput(data);  // App keybindings + text editing
  }
}

pi.on("session_start", (_event, ctx) => {
  ctx.ui.setEditorComponent((_tui, theme, keybindings) =>
    new VimEditor(theme, keybindings)
  );
});
```

## Commands

```typescript
pi.registerCommand("stats", {
  description: "Show session statistics",
  handler: async (args, ctx) => {
    const count = ctx.sessionManager.getEntries().length;
    ctx.ui.notify(`${count} entries`, "info");
  },
});

// With argument completion
pi.registerCommand("deploy", {
  description: "Deploy to environment",
  getArgumentCompletions: (prefix: string) => {
    const envs = ["dev", "staging", "prod"];
    const items = envs.map((e) => ({ value: e, label: e }));
    return items.filter((i) => i.value.startsWith(prefix));
  },
  handler: async (args, ctx) => {
    ctx.ui.notify(`Deploying: ${args}`, "info");
  },
});
```

### Command Context Methods

Commands receive `ExtensionCommandContext` with session control:

```typescript
pi.registerCommand("my-cmd", {
  handler: async (args, ctx) => {
    await ctx.waitForIdle();  // Wait for agent to finish
    
    await ctx.newSession({    // Create new session
      parentSession: ctx.sessionManager.getSessionFile(),
      setup: async (sm) => { /* ... */ },
    });
    
    await ctx.fork(entryId);  // Fork from entry
    
    await ctx.navigateTree(targetId, {
      summarize: true,
      customInstructions: "Focus on...",
    });
    
    await ctx.reload();  // Reload extensions/resources
  },
});
```

## State Management

### Persisting State

Store state in tool result `details` for proper branching support:

```typescript
export default function (pi: ExtensionAPI) {
  let items: string[] = [];
  
  // Reconstruct from session on load
  pi.on("session_start", async (_event, ctx) => {
    items = [];
    for (const entry of ctx.sessionManager.getBranch()) {
      if (entry.type === "message" && entry.message.role === "toolResult") {
        if (entry.message.toolName === "my_tool") {
          items = entry.message.details?.items ?? [];
        }
      }
    }
  });
  
  pi.registerTool({
    name: "my_tool",
    // ...
    async execute(toolCallId, params, signal, onUpdate, ctx) {
      items.push("new item");
      return {
        content: [{ type: "text", text: "Added" }],
        details: { items: [...items] },  // Persist for reconstruction
      };
    },
  });
}
```

### Session Entries

Persist extension state (not sent to LLM):

```typescript
pi.appendEntry("my-state", { count: 42 });

// Restore on reload
pi.on("session_start", async (_event, ctx) => {
  for (const entry of ctx.sessionManager.getEntries()) {
    if (entry.type === "custom" && entry.customType === "my-state") {
      // Reconstruct from entry.data
    }
  }
});
```

## Custom Providers

```typescript
pi.registerProvider("my-proxy", {
  baseUrl: "https://proxy.example.com",
  apiKey: "PROXY_API_KEY",  // env var name or literal
  api: "anthropic-messages",
  models: [
    {
      id: "claude-sonnet-4-20250514",
      name: "Claude 4 Sonnet (proxy)",
      reasoning: false,
      input: ["text", "image"],
      cost: { input: 0, output: 0, cacheRead: 0, cacheWrite: 0 },
      contextWindow: 200000,
      maxTokens: 16384,
    }
  ],
});

// With OAuth
pi.registerProvider("corporate-ai", {
  baseUrl: "https://ai.corp.com",
  api: "openai-responses",
  models: [...],
  oauth: {
    name: "Corporate AI (SSO)",
    async login(callbacks) {
      callbacks.onAuth({ url: "https://sso.corp.com/..." });
      const code = await callbacks.onPrompt({ message: "Enter code:" });
      return { refresh: code, access: code, expires: Date.now() + 3600000 };
    },
    async refreshToken(credentials) {
      return credentials;
    },
    getApiKey(credentials) {
      return credentials.access;
    }
  }
});
```

## Keyboard Shortcuts

```typescript
pi.registerShortcut("ctrl+shift+p", {
  description: "Toggle plan mode",
  handler: async (ctx) => {
    ctx.ui.notify("Toggled!", "info");
  },
});
```

## CLI Flags

```typescript
pi.registerFlag("plan", {
  description: "Start in plan mode",
  type: "boolean",
  default: false,
});

// Check value
if (pi.getFlag("--plan")) {
  // Plan mode enabled
}
```

## Tool Management

```typescript
// Get active/all tools
const active = pi.getActiveTools();  // ["read", "bash", "edit", "write"]
const all = pi.getAllTools();        // Full tool definitions

// Enable/disable tools
pi.setActiveTools(["read", "bash"]);  // Switch to read-only

// Dynamic tool registration (works after startup)
pi.registerTool({ name: "dynamic_tool", ... });
```

## Event Bus

Inter-extension communication:

```typescript
pi.events.on("my-ext:status", (data) => {
  console.log("Status:", data);
});

pi.events.emit("my-ext:status", { ready: true });
```

## Session Management

```typescript
// Set session name (shown in selector)
pi.setSessionName("Refactor auth module");
const name = pi.getSessionName();

// Label entries for /tree navigation
pi.setLabel(entryId, "checkpoint-before-refactor");
pi.setLabel(entryId, undefined);  // Clear label
```

## Packaging Extensions

### As Pi Package

Add to `package.json`:

```json
{
  "name": "my-pi-package",
  "keywords": ["pi-package"],
  "pi": {
    "extensions": ["./extensions"],
    "skills": ["./skills"],
    "prompts": ["./prompts"],
    "themes": ["./themes"]
  }
}
```

Install via:
```bash
pi install npm:@foo/my-pi-package
pi install git:github.com/user/repo
```

## Common Patterns

### Permission Gate

```typescript
pi.on("tool_call", async (event, ctx) => {
  if (event.toolName === "bash") {
    const command = event.input.command;
    if (/\brm\s+(-rf?|--recursive)/i.test(command)) {
      const ok = await ctx.ui.confirm("Dangerous!", command);
      if (!ok) return { block: true, reason: "Blocked by user" };
    }
  }
});
```

### Protected Paths

```typescript
pi.on("tool_call", async (event, ctx) => {
  const protectedPaths = [".env", ".git/", "node_modules/"];
  const path = event.input.path;
  
  if (protectedPaths.some(p => path?.includes(p))) {
    return { block: true, reason: `Protected path: ${path}` };
  }
});
```

### Git Checkpointing

```typescript
pi.on("turn_end", async (event, ctx) => {
  await pi.exec("git", ["stash", "push", "-m", `pi-turn-${event.turnIndex}`]);
});
```

## Available Imports

| Package | Purpose |
|---------|---------|
| `@mariozechner/pi-coding-agent` | Extension types, API, tool factories |
| `@sinclair/typebox` | Schema definitions for tool parameters |
| `@mariozechner/pi-ai` | AI utilities (`StringEnum`, `getModel`) |
| `@mariozechner/pi-tui` | TUI components (`Text`, `Box`, `Container`, etc.) |
| `@mariozechner/pi-agent-core` | Core agent types (for SDK use) |

## Resources

- Full extensions docs: `docs/extensions.md`
- TUI components: `docs/tui.md`
- SDK docs: `docs/sdk.md`
- Examples: `examples/extensions/`
