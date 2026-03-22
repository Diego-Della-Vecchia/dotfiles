/**
 * Custom UI Dialog Example
 * 
 * Demonstrates creating custom TUI components with user interaction.
 * Shows a task picker dialog using ctx.ui.custom().
 */

import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";
import { Container, Text, matchesKey, type Component } from "@mariozechner/pi-tui";

interface Task {
  id: string;
  name: string;
  status: "pending" | "done";
}

class TaskPickerComponent implements Component {
  private tasks: Task[];
  private selectedIndex = 0;
  private onSelect: (task: Task | null) => void;
  private theme: any;

  constructor(tasks: Task[], theme: any, onSelect: (task: Task | null) => void) {
    this.tasks = tasks;
    this.onSelect = onSelect;
    this.theme = theme;
  }

  render(width: number): string[] {
    const lines: string[] = [];
    const th = this.theme;

    // Header
    lines.push("");
    lines.push(th.fg("accent", "Select a task:"));
    lines.push(th.fg("borderMuted", "─".repeat(Math.min(40, width))));
    lines.push("");

    // Tasks
    this.tasks.forEach((task, i) => {
      const prefix = i === this.selectedIndex ? th.fg("accent", "❯ ") : "  ";
      const status = task.status === "done" 
        ? th.fg("success", "✓ ") 
        : th.fg("dim", "○ ");
      const name = i === this.selectedIndex 
        ? th.bold(task.name) 
        : th.fg("text", task.name);
      lines.push(prefix + status + name);
    });

    // Footer
    lines.push("");
    lines.push(th.fg("dim", "↑↓ Navigate  Enter Select  Esc Cancel"));
    lines.push("");

    return lines;
  }

  handleInput(data: string): void {
    if (matchesKey(data, "up")) {
      this.selectedIndex = Math.max(0, this.selectedIndex - 1);
    } else if (matchesKey(data, "down")) {
      this.selectedIndex = Math.min(this.tasks.length - 1, this.selectedIndex + 1);
    } else if (matchesKey(data, "enter") || matchesKey(data, "return")) {
      this.onSelect(this.tasks[this.selectedIndex]);
    } else if (matchesKey(data, "escape") || matchesKey(data, "ctrl+c")) {
      this.onSelect(null);
    }
  }

  invalidate(): void {
    // Clear any cached render state
  }
}

export default function (pi: ExtensionAPI) {
  // Sample tasks - in a real extension, load from file or database
  const sampleTasks: Task[] = [
    { id: "1", name: "Review pull request", status: "pending" },
    { id: "2", name: "Update documentation", status: "done" },
    { id: "3", name: "Fix failing tests", status: "pending" },
    { id: "4", name: "Deploy to production", status: "pending" },
  ];

  pi.registerCommand("pick-task", {
    description: "Open task picker dialog",
    handler: async (_args, ctx) => {
      if (!ctx.hasUI) {
        ctx.ui.notify("Task picker requires interactive mode", "error");
        return;
      }

      const selectedTask = await ctx.ui.custom<Task | null>(
        (_tui, theme, _keybindings, done) => {
          return new TaskPickerComponent(sampleTasks, theme, (task) => {
            done(task);
          });
        }
      );

      if (selectedTask) {
        ctx.ui.notify(`Selected: ${selectedTask.name}`, "success");
        // Could set editor text, trigger tools, etc.
        ctx.ui.setEditorText(`Work on task: ${selectedTask.name}`);
      } else {
        ctx.ui.notify("No task selected", "warning");
      }
    },
  });

  // Also register as a tool the LLM can call
  pi.registerTool({
    name: "pick_task",
    label: "Pick Task",
    description: "Let the user pick a task from a list interactively",
    parameters: {
      type: "object",
      properties: {},
    },
    async execute(_toolCallId, _params, _signal, _onUpdate, ctx) {
      if (!ctx.hasUI) {
        return {
          content: [{ type: "text", text: "Cannot show picker in non-interactive mode" }],
          details: { error: "no_ui" },
        };
      }

      const selectedTask = await ctx.ui.custom<Task | null>(
        (_tui, theme, _keybindings, done) => {
          return new TaskPickerComponent(sampleTasks, theme, done);
        }
      );

      return {
        content: [{
          type: "text",
          text: selectedTask 
            ? `User selected: ${selectedTask.name} (${selectedTask.status})`
            : "User cancelled selection",
        }],
        details: { selectedTask },
      };
    },
  });
}
