# Plugin Paths and Variables

Understanding plugin paths is critical for scripts, hooks, and external service integrations that need to reference plugin files.

## Table of Contents

- [Path Rules Overview](#path-rules-overview)
- [Relative Paths in plugin.json](#relative-paths-in-pluginjson)
- [${CLAUDE_PLUGIN_ROOT} Variable](#claude_plugin_root-variable)
- [Installation Path Behavior](#installation-path-behavior)
- [Common Path Issues](#common-path-issues)
- [Real-World Examples](#real-world-examples)
- [Testing Paths During Development](#testing-paths-during-development)
- [Path Resolution Summary](#path-resolution-summary)

## Path Rules Overview

**Critical rule:** All paths in `plugin.json` are relative to plugin root and must start with `./`

| Context | Path Type | Example | Notes |
|---------|-----------|---------|-------|
| **plugin.json fields** | Relative, with `./` | `"./commands/"` | Must start with `./` |
| **Hooks, scripts, services** | Variable + relative | `"${CLAUDE_PLUGIN_ROOT}/scripts/format.sh"` | Use variable for absolute paths |
| **User filesystem** | Installation scope path | `~/.claude/skills/my-plugin/` | Where plugin lives after install |

## Relative Paths in plugin.json

All paths in `plugin.json` are relative to the plugin root directory and MUST start with `./`

### Correct Path Format

```json
{
  "commands": "./commands/",
  "agents": "./agents/",
  "skills": ["./skills/", "./vendor/skills/"],
  "hooks": "./hooks.json",
  "mcpServers": "./.mcp.json",
  "lspServers": "./.lsp.json",
  "outputStyles": "./styles/"
}
```

### Plugin Directory Structure Example

```
my-plugin/
├── .claude-plugin/
│   └── plugin.json          # Paths are relative to my-plugin/
├── commands/
│   └── validate.md
├── agents/
│   └── analyzer.md
├── skills/
│   └── code-review/
│       └── SKILL.md
├── hooks.json
├── .mcp.json
├── scripts/
│   └── format.sh
└── styles/
    └── custom.css
```

**In plugin.json:**
- `"commands": "./commands/"` → points to `my-plugin/commands/`
- `"scripts": "./scripts/format.sh"` → points to `my-plugin/scripts/format.sh`
- `"styles": "./styles/"` → points to `my-plugin/styles/`

## ${CLAUDE_PLUGIN_ROOT} Variable

Use this variable in **hooks, scripts, and MCP server configurations** to get the absolute path to the plugin root.

### Why This Variable Exists

When a plugin is installed, Claude Code copies it to a cache location. The absolute path depends on:
- Installation scope (`~/.claude/skills/` for user, `.claude/skills/` for project)
- Plugin name
- System environment

**Without the variable:** Hard-coded paths would break after installation
**With the variable:** Claude Code expands it to the correct absolute path at runtime

### Where to Use ${CLAUDE_PLUGIN_ROOT}

**Use in these contexts:**
- Hook command paths
- MCP server startup commands
- LSP server commands
- Script references in hooks or inline configurations
- External processes that need absolute paths

**Don't use in:**
- Regular `plugin.json` fields (`commands`, `agents`, `skills`, etc.)
- Internal file references (use relative `./` paths instead)

### Examples with ${CLAUDE_PLUGIN_ROOT}

#### Hooks Example

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "${CLAUDE_PLUGIN_ROOT}/scripts/format.sh"
          }
        ]
      }
    ]
  }
}
```

When installed to `~/.claude/skills/my-plugin/`, the variable expands to:
```
${CLAUDE_PLUGIN_ROOT} = ~/.claude/skills/my-plugin
```

Full path becomes: `~/.claude/skills/my-plugin/scripts/format.sh`

#### MCP Server Example

```json
{
  "python-mcp": {
    "command": "python",
    "args": ["${CLAUDE_PLUGIN_ROOT}/mcp_servers/file_handler.py"],
    "env": {
      "PLUGIN_ROOT": "${CLAUDE_PLUGIN_ROOT}"
    }
  }
}
```

The server is launched with:
```bash
python ~/.claude/skills/my-plugin/mcp_servers/file_handler.py
```

#### LSP Server Example

```json
{
  "go": {
    "command": "${CLAUDE_PLUGIN_ROOT}/bin/gopls",
    "args": ["serve"]
  }
}
```

## Installation Path Behavior

After installation, plugins are copied to scope-specific locations. The `${CLAUDE_PLUGIN_ROOT}` variable expands to these paths:

### User Scope (`--scope user`)

**Installation path:** `~/.claude/skills/my-plugin/`

```bash
# Variable expands to:
${CLAUDE_PLUGIN_ROOT} = ~/.claude/skills/my-plugin
```

**Available in:** All projects, all sessions

### Project Scope (`--scope project`)

**Installation path:** `.claude/skills/my-plugin/`

```bash
# Variable expands to:
${CLAUDE_PLUGIN_ROOT} = /full/path/to/project/.claude/skills/my-plugin
```

**Available in:** This project only

### Local Scope (`--scope local`)

**Installation path:** `.claude/skills/my-plugin/`

```bash
# Variable expands to:
${CLAUDE_PLUGIN_ROOT} = /full/path/to/project/.claude/skills/my-plugin
```

**Available in:** This project only (not shared)

### Managed Scope (Marketplace)

**Installation path:** System cache (Claude Code manages this)

```bash
# Variable expands to:
${CLAUDE_PLUGIN_ROOT} = /system/managed/cache/my-plugin
```

**Available in:** All projects (read-only)

## Common Path Issues

### Issue 1: Hard-coded Absolute Paths

❌ **WRONG:**
```json
{
  "command": "/Users/jane/projects/my-plugin/scripts/format.sh"
}
```

Why this breaks:
- Path is specific to Jane's machine
- Path doesn't work for other users
- Path doesn't work after installation

✅ **CORRECT:**
```json
{
  "command": "${CLAUDE_PLUGIN_ROOT}/scripts/format.sh"
}
```

### Issue 2: Relative Paths Without ./

❌ **WRONG (in plugin.json):**
```json
{
  "commands": "commands/",
  "agents": "agents/"
}
```

Why this breaks:
- Claude Code expects paths to start with `./`
- Plugin won't be recognized

✅ **CORRECT:**
```json
{
  "commands": "./commands/",
  "agents": "./agents/"
}
```

### Issue 3: Using ${CLAUDE_PLUGIN_ROOT} in plugin.json

❌ **WRONG:**
```json
{
  "commands": "${CLAUDE_PLUGIN_ROOT}/commands/"
}
```

Why this breaks:
- plugin.json fields don't support variable expansion
- Claude Code handles these paths specially

✅ **CORRECT:**
```json
{
  "commands": "./commands/"
}
```

### Issue 4: Symlinks After Installation

❌ **WRONG:**
```json
{
  "command": "./scripts/../actual-scripts/format.sh"
}
```

Why this breaks:
- Symlinks may not work after plugin is cached/copied
- Plugin root changes on installation

✅ **CORRECT:**
```json
{
  "command": "${CLAUDE_PLUGIN_ROOT}/scripts/format.sh"
}
```

## Real-World Examples

### Example 1: Python MCP Server

Plugin structure:
```
my-plugin/
├── .claude-plugin/plugin.json
├── mcp_servers/
│   └── database.py
└── requirements.txt
```

Plugin.json MCP configuration:
```json
{
  "mcpServers": {
    "database": {
      "command": "python",
      "args": [
        "${CLAUDE_PLUGIN_ROOT}/mcp_servers/database.py"
      ]
    }
  }
}
```

When installed to `~/.claude/skills/my-plugin/`, expands to:
```bash
python ~/.claude/skills/my-plugin/mcp_servers/database.py
```

### Example 2: Bash Script in Hooks

Plugin structure:
```
my-plugin/
├── .claude-plugin/plugin.json
├── hooks.json
└── scripts/
    ├── format.sh
    └── lint.sh
```

Plugin.json hooks configuration:
```json
{
  "hooks": "./hooks.json"
}
```

hooks.json content:
```json
{
  "PostToolUse": [
    {
      "hooks": [
        {
          "type": "command",
          "command": "${CLAUDE_PLUGIN_ROOT}/scripts/format.sh"
        },
        {
          "type": "command",
          "command": "${CLAUDE_PLUGIN_ROOT}/scripts/lint.sh"
        }
      ]
    }
  ]
}
```

Hooks execute at:
- User scope: `~/.claude/skills/my-plugin/scripts/format.sh`
- Project scope: `.claude/skills/my-plugin/scripts/format.sh`

### Example 3: Multiple Path Types

```json
{
  "name": "code-tools",
  "description": "Multi-tool plugin...",

  // Regular plugin.json paths (relative, with ./)
  "commands": ["./commands/", "./lib/commands/"],
  "agents": "./agents/",
  "skills": "./skills/",
  "hooks": "./hooks.json",

  // MCP configuration with ${CLAUDE_PLUGIN_ROOT}
  "mcpServers": {
    "file-tools": {
      "command": "python",
      "args": ["${CLAUDE_PLUGIN_ROOT}/mcp/file_tools.py"]
    },
    "database": {
      "command": "node",
      "args": ["${CLAUDE_PLUGIN_ROOT}/mcp/database.js"]
    }
  },

  // LSP configuration with ${CLAUDE_PLUGIN_ROOT}
  "lspServers": {
    "go": {
      "command": "${CLAUDE_PLUGIN_ROOT}/bin/gopls",
      "args": ["serve"]
    }
  }
}
```

## Testing Paths During Development

Use `--plugin-dir` to test before installation:

```bash
# Test with relative paths (plugin-dir mode)
claude --plugin-dir /path/to/my-plugin

# Test with installed version
claude plugin install ./my-plugin --scope local
```

During development with `--plugin-dir`:
- `${CLAUDE_PLUGIN_ROOT}` expands to the directory you passed
- Relative paths work from plugin root
- Scripts/hooks execute with correct paths

## Path Resolution Summary

| Path Type | Where Used | Format | Expansion |
|-----------|-----------|--------|-----------|
| **component paths** | plugin.json | `./relative/path` | Plugin root + relative path |
| **script paths** | hooks, MCP | `${CLAUDE_PLUGIN_ROOT}/path` | Installation path + relative path |
| **variable** | runtime | `${CLAUDE_PLUGIN_ROOT}` | Absolute path to plugin (system-dependent) |
| **symlinks** | not recommended | — | Use `${CLAUDE_PLUGIN_ROOT}` instead |
