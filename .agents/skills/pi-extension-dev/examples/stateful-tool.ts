/**
 * Stateful Tool Example
 * 
 * A counter tool that maintains state across turns using tool result details.
 * Demonstrates: state persistence, session event reconstruction, custom rendering
 */

import { Type } from "@sinclair/typebox";
import { StringEnum } from "@mariozechner/pi-ai";
import type { ExtensionAPI, ExtensionContext } from "@mariozechner/pi-coding-agent";
import { Text } from "@mariozechner/pi-tui";

interface CounterState {
  count: number;
  history: Array<{ action: string; timestamp: number }>;
}

export default function (pi: ExtensionAPI) {
  // In-memory state (reconstructed from session on load)
  let state: CounterState = { count: 0, history: [] };

  // Reconstruct state from session entries
  const reconstructState = (ctx: ExtensionContext) => {
    state = { count: 0, history: [] };
    
    for (const entry of ctx.sessionManager.getBranch()) {
      if (entry.type !== "message") continue;
      const msg = entry.message;
      if (msg.role !== "toolResult" || msg.toolName !== "counter") continue;
      
      const details = msg.details as CounterState | undefined;
      if (details) {
        state = details;
      }
    }
  };

  // Reconstruct on session events
  pi.on("session_start", async (_event, ctx) => reconstructState(ctx));
  pi.on("session_switch", async (_event, ctx) => reconstructState(ctx));
  pi.on("session_fork", async (_event, ctx) => reconstructState(ctx));

  // Register the counter tool
  pi.registerTool({
    name: "counter",
    label: "Counter",
    description: "Manage a counter: increment, decrement, get, reset",
    promptSnippet: "Use the counter tool to track numeric values",
    
    parameters: Type.Object({
      action: StringEnum(["increment", "decrement", "get", "reset"] as const),
      by: Type.Optional(Type.Number({ description: "Amount to increment/decrement", default: 1 })),
    }),
    
    async execute(_toolCallId, params, _signal, _onUpdate, _ctx) {
      const by = params.by ?? 1;
      const timestamp = Date.now();
      
      switch (params.action) {
        case "increment":
          state.count += by;
          state.history.push({ action: `+${by}`, timestamp });
          break;
        case "decrement":
          state.count -= by;
          state.history.push({ action: `-${by}`, timestamp });
          break;
        case "reset":
          state.count = 0;
          state.history = [];
          state.history.push({ action: "reset", timestamp });
          break;
        case "get":
          // Just return current state
          break;
      }

      return {
        content: [{
          type: "text",
          text: `Counter: ${state.count} (last action: ${params.action}${params.by ? ` by ${by}` : ""})`,
        }],
        details: { ...state },  // Persist full state
      };
    },

    renderCall(args, theme, _context) {
      const text = theme.fg("toolTitle", theme.bold("counter ")) + 
                   theme.fg("muted", args.action) +
                   (args.by ? theme.fg("dim", ` by ${args.by}`) : "");
      return new Text(text, 0, 0);
    },

    renderResult(result, { expanded }, theme, _context) {
      const details = result.details as CounterState;
      
      let text = theme.fg("accent", `Count: ${theme.bold(details.count.toString())}`);
      
      if (expanded && details.history.length > 0) {
        text += "\n" + theme.fg("dim", "History:");
        const recent = details.history.slice(-5);
        for (const h of recent) {
          const time = new Date(h.timestamp).toLocaleTimeString();
          text += `\n  ${theme.fg("muted", time)} ${h.action}`;
        }
      }
      
      return new Text(text, 0, 0);
    },
  });

  // Command to view counter
  pi.registerCommand("counter", {
    description: "Show current counter value",
    handler: async (_args, ctx) => {
      ctx.ui.notify(`Counter: ${state.count}`, "info");
    },
  });
}
