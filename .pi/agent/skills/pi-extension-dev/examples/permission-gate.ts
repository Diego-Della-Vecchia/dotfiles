/**
 * Permission Gate Example
 * 
 * Intercepts dangerous bash commands and prompts for user confirmation.
 * Demonstrates: tool_call event, user interaction, blocking tools
 */

import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";

export default function (pi: ExtensionAPI) {
  const dangerousPatterns = [
    { pattern: /\brm\s+(-rf?|--recursive)/i, desc: "Recursive delete" },
    { pattern: /\bsudo\b/i, desc: "Elevated privileges" },
    { pattern: /\b(chmod|chown)\b.*777/i, desc: "Dangerous permissions" },
    { pattern: />\s*\/dev\/(null|zero|random)/i, desc: "Device overwrite" },
  ];

  pi.on("tool_call", async (event, ctx) => {
    // Only intercept bash tool calls
    if (event.toolName !== "bash") return undefined;

    const command = event.input.command as string;
    
    // Check for dangerous patterns
    const match = dangerousPatterns.find(p => p.pattern.test(command));
    
    if (match) {
      // In non-interactive mode, block by default
      if (!ctx.hasUI) {
        return { 
          block: true, 
          reason: `Blocked ${match.desc}: ${command}` 
        };
      }

      // Prompt user for confirmation
      const choice = await ctx.ui.select(
        `⚠️ ${match.desc}\n\n${command}\n\nAllow this command?`,
        ["Yes - Allow once", "Yes - Allow all this session", "No - Block"]
      );

      if (choice?.startsWith("No")) {
        return { block: true, reason: "Blocked by user" };
      }
      
      // Could implement "allow all" logic here with session storage
    }

    return undefined;
  });
}
