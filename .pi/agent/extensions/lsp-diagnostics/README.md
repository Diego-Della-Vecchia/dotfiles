# LSP Diagnostics Extension for Pi

Provides Language Server Protocol (LSP) integration to get real-time diagnostics (errors, warnings, hints) from configured language servers.

## Features

- **Configurable LSP servers** via `settings.json`
- **On-demand diagnostics** via the `lsp_diagnostics` tool
- **Auto-detection** of applicable servers based on file extensions
- **Multi-server support** - can run multiple LSP servers for different languages
- **Project root detection** - finds the appropriate project root for each server

## Installation

This extension is automatically loaded by pi if placed in:
- `~/.pi/agent/extensions/lsp-diagnostics.ts` (global)
- `.pi/extensions/lsp-diagnostics.ts` (project-local)

## Configuration

Add LSP configuration to your `~/.pi/agent/settings.json` (global) or `.pi/settings.json` (project):

### TypeScript with typescript-language-server

```json
{
  "lsp": {
    "typescript": {
      "command": ["typescript-language-server", "--stdio"],
      "extensions": [".ts", ".tsx", ".js", ".jsx"]
    }
  }
}
```

### TypeScript with tsgo

```json
{
  "lsp": {
    "tsgo": {
      "command": ["tsgo", "lsp"],
      "extensions": [".ts", ".tsx"],
      "env": {
        "NODE_ENV": "development"
      }
    }
  }
}
```

### Rust with rust-analyzer

```json
{
  "lsp": {
    "rust": {
      "command": ["rust-analyzer"],
      "extensions": [".rs"]
    }
  }
}
```

### Python with pylsp

```json
{
  "lsp": {
    "python": {
      "command": ["pylsp"],
      "extensions": [".py"]
    }
  }
}
```

### Go with gopls

```json
{
  "lsp": {
    "go": {
      "command": ["gopls"],
      "extensions": [".go"],
      "initialization": {
        "ui.diagnostic.annotations": {
          "bounds": true,
          "escape": true,
          "inline": true,
          "nil": true
        }
      }
    }
  }
}
```

### Multiple Servers

```json
{
  "lsp": {
    "typescript": {
      "command": ["typescript-language-server", "--stdio"],
      "extensions": [".ts", ".tsx"]
    },
    "eslint": {
      "command": ["vscode-eslint-language-server", "--stdio"],
      "extensions": [".ts", ".tsx", ".js", ".jsx"]
    },
    "tailwind": {
      "command": ["tailwindcss-language-server", "--stdio"],
      "extensions": [".html", ".tsx", ".jsx", ".vue"]
    }
  }
}
```

### Disable LSP

```json
{
  "lsp": false
}
```

### Disable Specific Server

```json
{
  "lsp": {
    "typescript": {
      "command": ["typescript-language-server", "--stdio"],
      "extensions": [".ts", ".tsx"],
      "disabled": true
    }
  }
}
```

## Configuration Options

| Option | Type | Required | Description |
|--------|------|----------|-------------|
| `command` | `string[]` | Yes | Command and arguments to spawn the LSP server |
| `extensions` | `string[]` | Yes | File extensions this server handles (e.g., `[".ts", ".tsx"]` |
| `env` | `Record<string,string>` | No | Environment variables to set when spawning the server |
| `initialization` | `object` | No | Initialization options passed to the LSP server |
| `disabled` | `boolean` | No | Set to `true` to disable this server |

## Usage

### Tool: `lsp_diagnostics`

The LLM can call this tool to get diagnostics for a specific file:

```
LSP Diagnostics for src/index.ts:
ERROR [42:15] TS2345: Argument of type 'string' is not assignable to parameter of type 'number'.
WARNING [15:8] 'unusedVar' is declared but its value is never read.
```

### Command: `/lsp-status`

Type `/lsp-status` in the editor to see which LSP servers are configured and active.

### Auto-status

After file modifications (via `write` or `edit` tools), a brief status appears in the footer indicating that LSP diagnostics are available for that file.

## Prerequisites

You must have the language servers installed and available in your PATH:

```bash
# TypeScript
npm install -g typescript-language-server typescript

# Or tsgo
cargo install tsgo

# Rust
rustup component add rust-analyzer

# Python
pip install python-lsp-server

# Go
go install golang.org/x/tools/gopls@latest
```

## How It Works

1. **Configuration Loading**: On session start, the extension reads `lsp` configuration from settings
2. **Server Spawning**: When diagnostics are requested for a file, the extension:
   - Determines which LSP servers apply based on file extension
   - Finds the project root (looking for markers like `tsconfig.json`, `.git`, etc.)
   - Spawns the LSP server process if not already running
   - Initializes the LSP connection
3. **Diagnostics**: Opens the file in the LSP server and requests diagnostics
4. **Cleanup**: Servers are shut down gracefully when the session ends

## Project Root Detection

The extension detects project roots by looking for common marker files:

| Language | Markers (checked in order) |
|----------|---------------------------|
| TypeScript/tsgo | `tsconfig.json`, `package.json`, `.git` |
| Rust | `Cargo.toml`, `.git` |
| Python | `pyproject.toml`, `setup.py`, `requirements.txt`, `.git` |
| Go | `go.mod`, `.git` |
| Default | `.git` |

The search starts from the file's directory and walks up until a marker is found.

## Troubleshooting

### "No LSP servers configured"

Add LSP configuration to your settings.json. See Configuration section above.

### "LSP server process exited"

- Ensure the language server is installed: `which typescript-language-server`
- Check that the command in your configuration is correct
- Look at pi's stderr output for server error messages

### Diagnostics not appearing

- Some LSP servers don't support pull diagnostics
- The extension waits 500ms after opening a file - some servers may need more time
- Check if the server is initialized: run `/lsp-status`

### File not found errors

- Use absolute paths or paths relative to the current working directory
- Ensure the file exists before requesting diagnostics

## Language ID Mapping

The extension maps file extensions to LSP language IDs:

| Extension | Language ID |
|-----------|-------------|
| .ts | typescript |
| .tsx | typescriptreact |
| .js | javascript |
| .jsx | javascriptreact |
| .rs | rust |
| .py | python |
| .go | go |
| .java | java |
| .c, .h | c |
| .cpp, .hpp | cpp |
| .json | json |
| .md | markdown |
| .css | css |
| .html | html |
| .yaml, .yml | yaml |
| .toml | toml |

## Limitations

- Only pull diagnostics are supported (servers must respond to `textDocument/diagnostic`)
- Diagnostic notifications from servers are not currently tracked
- Each file type should have unique extensions configured per server
- Servers are not restarted if they crash (restart pi to respawn)

## Contributing

This extension can be extended to support additional LSP features:
- Go to definition
- Find references
- Hover information
- Code actions
- Formatting

See the [LSP specification](https://microsoft.github.io/language-server-protocol/) for more methods that could be implemented.
