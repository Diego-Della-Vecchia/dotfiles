# LSP Diagnostics Extension - Usage Guide

## For Users

### 1. Configure Your LSP Server

Edit `~/.pi/agent/settings.json` (global) or `.pi/settings.json` (project-local):

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

### 2. Install the Language Server

Make sure the LSP server binary is in your PATH:

```bash
npm install -g typescript-language-server typescript
```

### 3. Use in Pi

The LLM will automatically use the `lsp_diagnostics` tool when appropriate. You can also prompt it:

> "Check for TypeScript errors in src/index.ts"

> "Run LSP diagnostics on the files we just modified"

### 4. Check Status

Type `/lsp-status` to see which servers are configured and running.

## For the LLM (System Prompt Addition)

When this extension is active, the LLM sees:

```
Available tools:
  ...
  lsp_diagnostics - Get LSP diagnostics (errors, warnings) for a file

Guidelines:
  ...
  - Use lsp_diagnostics after editing files to check for type errors, lint warnings, or other issues
  - Use after write, edit, or bash commands that modify source files
  - Particularly useful before running tests or committing changes
```

## Example Tool Output

```
LSP Diagnostics for src/utils.ts:

ERROR [42:15] TS2345: Argument of type 'string' is not assignable to parameter of type 'number'.
WARNING [15:8] 'unusedVar' is declared but its value is never read.
INFO [3:1] File is a CommonJS module; it may be converted to an ES module.
```

## Typical Workflow

1. User: "Fix the type errors in the auth module"
2. LLM reads relevant files
3. LLM makes edits with the edit tool
4. LLM calls lsp_diagnostics to verify no new errors were introduced
5. If errors exist, LLM fixes them
6. Repeat until clean

## Project-Specific Configuration

For a TypeScript project using tsgo:

`.pi/settings.json`:
```json
{
  "lsp": {
    "tsgo": {
      "command": ["tsgo", "lsp"],
      "extensions": [".ts", ".tsx"]
    }
  }
}
```

This keeps the configuration with the project, so anyone using pi with this project gets the same LSP setup.

## Troubleshooting

**"No LSP servers configured"**
- Add LSP configuration to settings.json

**"LSP server process exited"**
- Check that the language server is installed and in PATH
- Verify the command array is correct

**Diagnostics not showing**
- Some servers don't support pull diagnostics
- The file may not have any diagnostics
- Check /lsp-status to verify server is running
