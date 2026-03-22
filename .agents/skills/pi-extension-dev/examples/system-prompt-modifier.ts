//**
 * System Prompt Modifier Example
 * 
 * Dynamically modifies the system prompt based on context.
 * Demonstrates: before_agent_start event, system prompt modification
 */

import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";

export default function (pi: ExtensionAPI) {
  // Track if we're in "expert mode"
  let expertMode = false;
  
  // Toggle expert mode via command
  pi.registerCommand("expert", {
    description: "Toggle expert mode (technical, concise responses)",
    handler: async (_args, ctx) => {
      expertMode = !expertMode;
      ctx.ui.notify(`Expert mode: ${expertMode ? "ON" : "OFF"}`, expertMode ? "success" : "info");
    },
  });

  // Modify system prompt before each agent start
  pi.on("before_agent_start", async (event, ctx) => {
    let additionalInstructions = "";
    
    if (expertMode) {
      additionalInstructions += `

## Expert Mode Instructions
- Be concise and technical
- Skip explanations of basic concepts
- Use precise terminology
- Provide code examples without lengthy prose
- Assume the user is experienced`;
    }
    
    // Check if prompt mentions testing
    if (event.prompt.toLowerCase().includes("test")) {
      additionalInstructions += `

## Testing Guidelines
- Prefer unit tests over integration tests
- Use descriptive test names
- Follow AAA pattern (Arrange, Act, Assert)
- Mock external dependencies`;
    }
    
    // Check if prompt mentions security
    if (event.prompt.toLowerCase().includes("security") || 
        event.prompt.toLowerCase().includes("auth")) {
      additionalInstructions += `

## Security Guidelines
- Never commit secrets to code
- Validate all inputs
- Use parameterized queries
- Implement proper error handling without leaking sensitive info`;
    }
    
    if (additionalInstructions) {
      return {
        systemPrompt: event.systemPrompt + additionalInstructions,
      };
    }
    
    return undefined;
  });

  // Show current mode on session start
  pi.on("session_start", async (_event, ctx) => {
    if (expertMode) {
      ctx.ui.notify("Expert mode active", "info");
    }
  });
}
