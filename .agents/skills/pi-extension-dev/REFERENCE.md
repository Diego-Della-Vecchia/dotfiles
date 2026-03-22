# Pi Extension API Reference

Quick reference for common extension APIs and types.

## ExtensionAPI

```typescript
interface ExtensionAPI {
  // Event subscription
  on<K extends keyof ExtensionEvents>(
    event: K,
    handler: ExtensionEventHandler<K>
  ): void;

  // Tool registration
  registerTool(definition: ToolDefinition): void;

  // Command registration
  registerCommand(name: string, options: CommandOptions): void;

  // Shortcut registration
  registerShortcut(shortcut: string, options: ShortcutOptions): void;

  // Flag registration
  registerFlag(name: string, options: FlagOptions): void;

  // Message handling
  sendMessage(message: CustomMessage, options?: MessageOptions): void;
  sendUserMessage(content: string | ContentPart[], options?: UserMessageOptions): void;
  appendEntry(customType: string, data?: unknown): void;

  // Session metadata
  setSessionName(name: string): void;
  getSessionName(): string | undefined;
  setLabel(entryId: string, label: string | undefined): void;

  // Tool management
  getActiveTools(): string[];
  getAllTools(): ToolInfo[];
  setActiveTools(names: string[]): void;

  // Model control
  setModel(model: Model): Promise<boolean>;
  getThinkingLevel(): ThinkingLevel;
  setThinkingLevel(level: ThinkingLevel): void;

  // Provider registration
  registerProvider(name: string, config: ProviderConfig): void;
  unregisterProvider(name: string): void;

  // Message rendering
  registerMessageRenderer(customType: string, renderer: MessageRenderer): void;

  // Utility
  exec(command: string, args: string[], options?: ExecOptions): Promise<ExecResult>;
  getCommands(): CommandInfo[];
  
  // Inter-extension communication
  events: EventBus;
}
```

## ExtensionContext

```typescript
interface ExtensionContext {
  // UI methods
  ui: UIContext;
  hasUI: boolean;

  // Session access (read-only)
  sessionManager: SessionManager;

  // Model access
  modelRegistry: ModelRegistry;
  model: Model | undefined;

  // Working directory
  cwd: string;

  // Control flow
  isIdle(): boolean;
  abort(): void;
  hasPendingMessages(): boolean;
  shutdown(): void;

  // Context
  getContextUsage(): ContextUsage | undefined;
  getSystemPrompt(): string;
  compact(options?: CompactOptions): void;
}
```

## ExtensionCommandContext

Extends `ExtensionContext` with session control:

```typescript
interface ExtensionCommandContext extends ExtensionContext {
  waitForIdle(): Promise<void>;
  newSession(options?: NewSessionOptions): Promise<{ cancelled: boolean }>;
  fork(entryId: string): Promise<{ cancelled: boolean }>;
  navigateTree(targetId: string, options?: NavigateOptions): Promise<NavigateResult>;
  reload(): Promise<void>;
}
```

## UI Context

```typescript
interface UIContext {
  // Dialogs
  select<T>(title: string, choices: string[], options?: DialogOptions): Promise<T | undefined>;
  confirm(title: string, message: string, options?: DialogOptions): Promise<boolean>;
  input(title: string, placeholder?: string, options?: InputOptions): Promise<string | undefined>;
  editor(title: string, text?: string, options?: EditorOptions): Promise<string | undefined>;

  // Custom components
  custom<T>(
    factory: ComponentFactory<T>,
    options?: CustomUIOptions
  ): Promise<T>;

  // Notifications
  notify(message: string, type: "info" | "warning" | "error"): void;

  // Status and widgets
  setStatus(id: string, text: string | undefined): void;
  setWorkingMessage(text?: string): void;
  setWidget(id: string, content: WidgetContent | undefined, options?: WidgetOptions): void;
  setFooter(factory: FooterFactory | undefined): void;
  setHeader(factory: HeaderFactory | undefined): void;

  // Editor
  setEditorText(text: string): void;
  getEditorText(): string;
  pasteToEditor(text: string): void;
  setEditorComponent(factory: EditorFactory | undefined): void;

  // Tools display
  getToolsExpanded(): boolean;
  setToolsExpanded(expanded: boolean): void;

  // Theme
  getAllThemes(): ThemeInfo[];
  getTheme(name: string): Theme | undefined;
  setTheme(theme: string | Theme): { success: boolean; error?: string };
  theme: Theme;

  // Terminal
  setTitle(title: string): void;
}
```

## Events

### Session Events

| Event | Event Type | Return Type |
|-------|------------|-------------|
| `session_directory` | `{ cwd: string }` | `{ sessionDir?: string }` |
| `session_start` | `{}` | `void` |
| `session_before_switch` | `{ reason: "new" \| "resume"; targetSessionFile?: string }` | `{ cancel?: boolean }` |
| `session_switch` | `{ reason: "new" \| "resume"; previousSessionFile?: string }` | `void` |
| `session_before_fork` | `{ entryId: string }` | `{ cancel?: boolean; skipConversationRestore?: boolean }` |
| `session_fork` | `{ previousSessionFile?: string }` | `void` |
| `session_before_compact` | `{ preparation: CompactPreparation; branchEntries: Entry[]; customInstructions?: string }` | `{ cancel?: boolean; compaction?: CompactionResult }` |
| `session_compact` | `{ compactionEntry: Entry; fromExtension: boolean }` | `void` |
| `session_before_tree` | `{ preparation: TreePreparation }` | `{ cancel?: boolean; summary?: Summary }` |
| `session_tree` | `{ newLeafId: string; oldLeafId: string; summaryEntry?: Entry; fromExtension: boolean }` | `void` |
| `session_shutdown` | `{}` | `void` |

### Agent Events

| Event | Event Type | Return Type |
|-------|------------|-------------|
| `before_agent_start` | `{ prompt: string; images?: Image[]; systemPrompt: string }` | `{ message?: CustomMessage; systemPrompt?: string }` |
| `agent_start` | `{}` | `void` |
| `agent_end` | `{ messages: AgentMessage[] }` | `void` |
| `turn_start` | `{ turnIndex: number; timestamp: number }` | `void` |
| `turn_end` | `{ turnIndex: number; message: AssistantMessage; toolResults: ToolResult[] }` | `void` |
| `message_start` | `{ message: AgentMessage }` | `void` |
| `message_update` | `{ message: AgentMessage; assistantMessageEvent: AssistantMessageEvent }` | `void` |
| `message_end` | `{ message: AgentMessage }` | `void` |
| `tool_execution_start` | `{ toolCallId: string; toolName: string; args: unknown }` | `void` |
| `tool_execution_update` | `{ toolCallId: string; toolName: string; args: unknown; partialResult: ToolResult }` | `void` |
| `tool_execution_end` | `{ toolCallId: string; toolName: string; result: ToolResult; isError: boolean }` | `void` |
| `context` | `{ messages: AgentMessage[] }` | `{ messages?: AgentMessage[] }` |
| `before_provider_request` | `{ payload: unknown }` | `{ payload?: unknown }` |
| `model_select` | `{ model: Model; previousModel?: Model; source: "set" \| "cycle" \| "restore" }` | `void` |

### Tool Events

| Event | Event Type | Return Type |
|-------|------------|-------------|
| `tool_call` | `{ toolName: string; toolCallId: string; input: unknown }` | `{ block?: boolean; reason?: string }` |
| `tool_result` | `{ toolName: string; toolCallId: string; input: unknown; content: ContentPart[]; details: unknown; isError: boolean }` | `{ content?: ContentPart[]; details?: unknown; isError?: boolean }` |
| `user_bash` | `{ command: string; excludeFromContext: boolean; cwd: string }` | `{ operations?: BashOperations; result?: BashResult }` |

### Input Event

| Event | Event Type | Return Type |
|-------|------------|-------------|
| `input` | `{ text: string; images?: Image[]; source: "interactive" \| "rpc" \| "extension" }` | `{ action?: "continue" \| "transform" \| "handled"; text?: string; images?: Image[] }` |

## Tool Definition

```typescript
interface ToolDefinition {
  name: string;
  label: string;
  description: string;
  promptSnippet?: string;
  promptGuidelines?: string[];
  parameters: TSchema;
  
  execute(
    toolCallId: string,
    params: Static<typeof parameters>,
    signal: AbortSignal | undefined,
    onUpdate: ((result: Partial<ToolResult>) => void) | undefined,
    ctx: ExtensionContext
  ): Promise<ToolResult>;
  
  renderCall?(
    args: Static<typeof parameters>,
    theme: Theme,
    context: RenderContext
  ): Component;
  
  renderResult?(
    result: ToolResult,
    options: { expanded: boolean; isPartial: boolean },
    theme: Theme,
    context: RenderContext
  ): Component;
}
```

## Type Helpers

### Checking Tool Types

```typescript
import { isToolCallEventType, isBashToolResult } from "@mariozechner/pi-coding-agent";

pi.on("tool_call", async (event, ctx) => {
  if (isToolCallEventType("bash", event)) {
    // event.input is typed as { command: string; timeout?: number }
  }
});

pi.on("tool_result", async (event, ctx) => {
  if (isBashToolResult(event)) {
    // event.details is typed as BashToolDetails
  }
});
```

### String Enum (Google API Compatible)

```typescript
import { StringEnum } from "@mariozechner/pi-ai";
import { Type } from "@sinclair/typebox";

// Good - works with all providers including Google
Type.Object({
  action: StringEnum(["list", "add", "delete"] as const),
});

// Bad - doesn't work with Google
Type.Object({
  action: Type.Union([
    Type.Literal("list"),
    Type.Literal("add"),
    Type.Literal("delete"),
  ]),
});
```

## Truncation Utilities

```typescript
import {
  truncateHead,
  truncateTail,
  truncateLine,
  formatSize,
  DEFAULT_MAX_BYTES,
  DEFAULT_MAX_LINES,
} from "@mariozechner/pi-coding-agent";

// Keep first N lines/bytes (good for search results, file reads)
const result = truncateHead(content, { maxLines: 2000, maxBytes: 50000 });

// Keep last N lines/bytes (good for logs, command output)
const result = truncateTail(content, { maxLines: 2000, maxBytes: 50000 });

// Truncate single line
const line = truncateLine(longLine, 100);

// Format size for display
const size = formatSize(50000); // "50KB"
```

## File Operations

```typescript
import { withFileMutationQueue } from "@mariozechner/pi-coding-agent";

// Queue file mutations to prevent race conditions
async execute(_toolCallId, params, _signal, _onUpdate, ctx) {
  const absolutePath = resolve(ctx.cwd, params.path);
  
  return withFileMutationQueue(absolutePath, async () => {
    await mkdir(dirname(absolutePath), { recursive: true });
    const current = await readFile(absolutePath, "utf8");
    const next = current.replace(params.oldText, params.newText);
    await writeFile(absolutePath, next, "utf8");
    
    return {
      content: [{ type: "text", text: `Updated ${params.path}` }],
      details: {},
    };
  });
}
```

## Key Matching

```typescript
import { matchesKey, Key } from "@mariozechner/pi-tui";

// String format
if (matchesKey(data, "enter")) { }
if (matchesKey(data, "ctrl+c")) { }
if (matchesKey(data, "shift+tab")) { }

// Key enum
if (matchesKey(data, Key.enter)) { }
if (matchesKey(data, Key.ctrl("c"))) { }
if (matchesKey(data, Key.shift("tab"))) { }
```

## Theme Colors

```typescript
// Available color keys
theme.fg("toolTitle", text)   // Tool names
theme.fg("accent", text)      // Highlights, selections
theme.fg("success", text)     // Success states (green)
theme.fg("error", text)       // Errors (red)
theme.fg("warning", text)     // Warnings (yellow)
theme.fg("muted", text)       // Secondary text
theme.fg("dim", text)         // Tertiary text
theme.fg("text", text)        // Primary text
theme.fg("border", text)      // Borders
theme.fg("borderMuted", text) // Subtle borders

// Styles
theme.bold(text)
theme.italic(text)
theme.strikethrough(text)
theme.underline(text)
```

## SessionManager Methods

```typescript
ctx.sessionManager.getEntries()       // All entries
ctx.sessionManager.getBranch()        // Current branch (root to leaf)
ctx.sessionManager.getTree()          // Full tree structure
ctx.sessionManager.getPath()          // Path from root to current leaf
ctx.sessionManager.getLeafId()        // Current leaf entry ID
ctx.sessionManager.getLeafEntry()     // Current leaf entry
ctx.sessionManager.getEntry(id)       // Get entry by ID
ctx.sessionManager.getChildren(id)    // Direct children
ctx.sessionManager.getLabel(id)       // Get label for entry
ctx.sessionManager.getSessionFile()   // Current session file path
```
