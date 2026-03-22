/**
 * Minimal Tool Example
 * 
 * A simple greeting tool demonstrating the basic structure of a custom tool.
 */

import { Type } from "@sinclair/typebox";
import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";

export default function (pi: ExtensionAPI) {
  pi.registerTool({
    name: "greet",
    label: "Greet",
    description: "Greet someone by name",
    
    parameters: Type.Object({
      name: Type.String({ description: "Name to greet" }),
    }),
    
    async execute(_toolCallId, params, _signal, _onUpdate, _ctx) {
      return {
        content: [{ type: "text", text: `Hello, ${params.name}! 👋` }],
        details: { greeted: params.name },
      };
    },
  });
}
