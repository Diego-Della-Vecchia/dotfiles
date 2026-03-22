/**
 * Dynamic Tools Example
 *
 * Registers tools at runtime based on configuration or user actions.
 * Demonstrates: dynamic tool registration, tool enablement/disablement
 */

import { Type } from "@sinclair/typebox";
import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";

interface WeatherConfig {
  apiKey: string;
  defaultLocation: string;
}

export default function (pi: ExtensionAPI) {
  let weatherConfig: WeatherConfig | null = null;

  // Command to configure and enable weather tool
  pi.registerCommand("enable-weather", {
    description: "Enable weather tool with API key",
    handler: async (args, ctx) => {
      if (!args) {
        ctx.ui.notify("Usage: /enable-weather <api-key> [default-location]", "warning");
        return;
      }

      const [apiKey, defaultLocation = "London"] = args.split(" ");

      weatherConfig = { apiKey, defaultLocation };

      // Register the weather tool dynamically
      pi.registerTool({
        name: "weather",
        label: "Weather",
        description: `Get weather information (default: ${defaultLocation})`,
        promptSnippet: "Get current weather for a location",

        parameters: Type.Object({
          location: Type.Optional(Type.String({ description: "City name or coordinates" })),
        }),

        async execute(_toolCallId, params, _signal, _onUpdate, _ctx) {
          const location = params.location || weatherConfig!.defaultLocation;

          // In a real implementation, call a weather API
          // For demo, return mock data
          return {
            content: [{
              type: "text",
              text: `Weather for ${location}:\n` +
                    `🌤️  Partly cloudy\n` +
                    `🌡️  72°F (22°C)\n` +
                    `💧 45% humidity\n` +
                    `💨 8 mph wind`,
            }],
            details: { location, temp: 72, condition: "partly_cloudy" },
          };
        },
      });

      ctx.ui.notify("Weather tool enabled!", "success");
    },
  });

  // Command to list and toggle available tools
  pi.registerCommand("tools", {
    description: "List and manage available tools",
    handler: async (_args, ctx) => {
      const allTools = pi.getAllTools();
      const activeTools = pi.getActiveTools();

      const choices = allTools.map(t => {
        const isActive = activeTools.includes(t.name);
        return `${isActive ? "✓" : "○"} ${t.name} - ${t.description?.slice(0, 50) || ""}`;
      });

      const choice = await ctx.ui.select("Tools (toggle to enable/disable):", [
        ...choices,
        "",
        "Done"
      ]);

      if (choice && choice !== "Done") {
        const toolName = choice.replace(/^[✓○]\s/, "").split(" ")[0];
        const isActive = activeTools.includes(toolName);

        if (isActive) {
          pi.setActiveTools(activeTools.filter(t => t !== toolName));
          ctx.ui.notify(`Disabled: ${toolName}`, "warning");
        } else {
          pi.setActiveTools([...activeTools, toolName]);
          ctx.ui.notify(`Enabled: ${toolName}`, "success");
        }
      }
    },
  });

  // Register a math tool immediately
  pi.registerTool({
    name: "calculate",
    label: "Calculate",
    description: "Perform mathematical calculations",
    parameters: Type.Object({
      expression: Type.String({ description: "Math expression to evaluate (e.g., 2 + 2 * 3)" }),
    }),
    async execute(_toolCallId, params, _signal, _onUpdate, _ctx) {
      try {
        // Simple eval for demo - in production use a proper math parser
        const result = Function(`"use strict"; return (${params.expression})`)();
        return {
          content: [{ type: "text", text: `${params.expression} = ${result}` }],
          details: { expression: params.expression, result },
        };
      } catch (e) {
        return {
          content: [{ type: "text", text: `Error: ${e}` }],
          details: { error: String(e) },
          isError: true,
        };
      }
    },
  });
}
