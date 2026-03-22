/**
 * Input Transformer Example
 * 
 * Transforms user input before it reaches the agent.
 * Demonstrates: input event, text transformation
 */

import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";

export default function (pi: ExtensionAPI) {
  pi.on("input", async (event, ctx) => {
    const text = event.text;
    
    // Quick mode: "?" prefix for brief responses
    if (text.startsWith("? ")) {
      return {
        action: "transform",
        text: `[Respond briefly in 1-2 sentences] ${text.slice(2)}`,
      };
    }
    
    // Code review mode: "review:" prefix
    if (text.startsWith("review: ")) {
      return {
        action: "transform",
        text: `Please review this code for bugs, security issues, and performance problems. Focus on: ${text.slice(8)}`,
      };
    }
    
    // Explain mode: "explain:" prefix
    if (text.startsWith("explain: ")) {
      return {
        action: "transform",
        text: `Explain this like I'm a junior developer: ${text.slice(9)}`,
      };
    }
    
    // Ping command - handle without agent
    if (text === "ping") {
      ctx.ui.notify("pong! 🏓", "info");
      return { action: "handled" };
    }
    
    // Time command - handle without agent
    if (text === "time") {
      ctx.ui.notify(new Date().toLocaleString(), "info");
      return { action: "handled" };
    }
    
    // Continue processing
    return { action: "continue" };
  });
}
