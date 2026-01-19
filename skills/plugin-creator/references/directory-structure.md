# Plugin Directory Structure Reference

This guide documents the standard plugin directory layout, file organization patterns, and structure requirements.

## Table of Contents

- [Standard Plugin Layout](#standard-plugin-layout)
- [Directory Organization Rules](#directory-organization-rules)
  - [Required: .claude-plugin/ Directory](#required-claude-plugin-directory)
  - [Optional: commands/ Directory](#optional-commands-directory)
  - [Optional: agents/ Directory](#optional-agents-directory)
  - [Optional: skills/ Directory](#optional-skills-directory)
  - [Optional: hooks/ Directory](#optional-hooks-directory)
  - [Optional: scripts/ Directory](#optional-scripts-directory)
  - [Optional: .mcp.json File](#optional-mcpjson-file)
  - [Optional: .lsp.json File](#optional-lspjson-file)
  - [Optional: styles/ Directory](#optional-styles-directory)
  - [Optional: assets/ Directory](#optional-assets-directory)
  - [Optional: README.md](#optional-readmemd)
  - [Optional: CHANGELOG.md](#optional-changelogmd)
  - [Optional: LICENSE](#optional-license)
- [File Locations Reference Table](#file-locations-reference-table)
- [Common Plugin Patterns](#common-plugin-patterns)
- [Structure Validation Checklist](#structure-validation-checklist)
- [Size and Performance Considerations](#size-and-performance-considerations)
- [Migration from Old Structure](#migration-from-old-structure)
- [See Also](#see-also)

## Standard Plugin Layout

A complete, production-ready plugin follows this structure:

```
my-plugin/
├── .claude-plugin/                 # Metadata directory (required)
│   └── plugin.json                # Plugin manifest (required)
├── commands/                        # Slash commands (optional)
│   ├── validate.md
│   ├── report.md
│   └── export.md
├── agents/                          # Custom agents (optional)
│   ├── security-reviewer.md
│   ├── performance-tester.md
│   └── compliance-checker.md
├── skills/                          # Agent Skills (optional)
│   ├── code-analyzer/
│   │   ├── SKILL.md
│   │   └── references/
│   │       └── guide.md
│   └── pdf-processor/
│       ├── SKILL.md
│       └── scripts/
│           └── process.py
├── hooks/                           # Hook configurations (optional)
│   └── hooks.json
├── .mcp.json                        # MCP server definitions (optional)
├── .lsp.json                        # LSP server configs (optional)
├── scripts/                         # Utility scripts (optional)
│   ├── security-scan.sh
│   ├── format.py
│   └── deploy.js
├── styles/                          # Output styles (optional)
│   ├── command-output.css
│   └── theme.css
├── assets/                          # Static assets (optional)
│   ├── icon.png
│   ├── logo.svg
│   └── templates/
│       └── report.html
├── LICENSE                          # License file (recommended)
├── CHANGELOG.md                     # Version history (recommended)
└── README.md                        # Plugin documentation (recommended)
```

## Directory Organization Rules

### Required: .claude-plugin/ Directory

**Purpose:** Contains plugin metadata

**Must contain:**
- `.claude-plugin/plugin.json` — Plugin manifest (only required file)

**Important:**
- Only `plugin.json` belongs in `.claude-plugin/`
- All other components (`commands/`, `agents/`, etc.) must be in plugin root
- Don't put commands or agents inside `.claude-plugin/`

✅ **Correct:**
```
my-plugin/
├── .claude-plugin/
│   └── plugin.json          ← Only manifest here
├── commands/                ← Components at root
└── agents/
```

❌ **Wrong:**
```
my-plugin/
├── .claude-plugin/
│   ├── plugin.json
│   ├── commands/            ← Don't put here
│   └── agents/              ← Don't put here
```

### Optional: commands/ Directory

**Purpose:** Slash commands that users invoke with `/plugin-name:command`

**Structure:**
```
commands/
├── validate.md              # /plugin-name:validate
├── report.md                # /plugin-name:report
└── export.md                # /plugin-name:export
```

**Rules:**
- Each command is a `.md` file
- Filename becomes command name (lowercase-hyphen)
- File must contain YAML frontmatter with `name` and `description`
- One command per file

**File format:**
```markdown
---
name: validate
description: Validate code against best practices
arguments:
  code:
    description: Source code to validate
    required: true
---

# Validate Command

Instructions for Claude to follow when running this command.
```

### Optional: agents/ Directory

**Purpose:** Custom agents that Claude invokes for specialized tasks

**Structure:**
```
agents/
├── security-reviewer.md     # Custom agent 1
├── performance-tester.md    # Custom agent 2
└── compliance-checker.md    # Custom agent 3
```

**Rules:**
- Each agent is a `.md` file
- Filename doesn't matter; use `name` field in frontmatter
- Must include `capabilities` array describing what agent can do
- Can include context, examples, and detailed expertise description

**File format:**
```markdown
---
description: What this agent specializes in
capabilities: ["code-review", "security-audit", "compliance-check"]
---

# Security Reviewer Agent

Detailed description of agent expertise, when to invoke it, and capabilities.

## Capabilities
- Security vulnerability detection
- Compliance verification
- Access control analysis

## Examples
Provide examples of tasks this agent excels at.
```

### Optional: skills/ Directory

**Purpose:** Agent Skills that Claude uses automatically for specialized tasks

**Structure:**
```
skills/
├── code-analyzer/
│   ├── SKILL.md             # Skill definition
│   ├── references/          # Supporting docs (optional)
│   │   └── patterns.md
│   └── scripts/             # Utility scripts (optional)
│       └── analyze.py
└── pdf-processor/
    ├── SKILL.md
    └── references/
        └── ocr-guide.md
```

**Rules:**
- Each skill is a directory with `SKILL.md` file
- Directory name is skill name
- Can include `references/` and `scripts/` subdirectories
- Keep SKILL.md body <500 lines (move detailed content to references/)

**SKILL.md format:**
```yaml
---
name: skill-name
description: >-
  What the skill does. Use when [trigger context].
version: 1.0.0
---

# Skill Name

Instructions for Claude to follow when invoking this skill.

## Quick Start
Essential execution steps.

## Key Notes
Important constraints and edge cases.
```

### Optional: hooks/ Directory

**Purpose:** Event handlers that respond to Claude Code events

**Structure:**
```
hooks/
└── hooks.json               # Hook configuration

# Or reference in plugin.json directly:
"hooks": "./hooks.json"
```

**File format (hooks.json):**
```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Write|Edit",
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

### Optional: scripts/ Directory

**Purpose:** Utility scripts used by hooks, MCP servers, or commands

**Structure:**
```
scripts/
├── format.sh                # Bash script for hooks
├── lint.sh
├── process.py               # Python script
├── deploy.js                # Node script
└── README.md                # Script documentation
```

**Rules:**
- Scripts must be executable: `chmod +x script.sh`
- Include shebang: `#!/bin/bash` or `#!/usr/bin/env bash`
- Reference with `${CLAUDE_PLUGIN_ROOT}` variable in hooks/MCP

### Optional: .mcp.json File

**Purpose:** Model Context Protocol server definitions

**Location:** Plugin root (not in subdirectory)

**File format:**
```json
{
  "database-server": {
    "command": "python",
    "args": ["${CLAUDE_PLUGIN_ROOT}/mcp/database.py"],
    "env": {
      "DB_PATH": "${CLAUDE_PLUGIN_ROOT}/data"
    }
  },
  "api-client": {
    "command": "node",
    "args": ["${CLAUDE_PLUGIN_ROOT}/mcp/api-client.js"]
  }
}
```

### Optional: .lsp.json File

**Purpose:** Language Server Protocol definitions for code intelligence

**Location:** Plugin root (not in subdirectory)

**File format:**
```json
{
  "go": {
    "command": "gopls",
    "args": ["serve"],
    "extensionToLanguage": {
      ".go": "go"
    }
  },
  "python": {
    "command": "pyright",
    "args": ["--stdio"],
    "extensionToLanguage": {
      ".py": "python"
    }
  }
}
```

### Optional: styles/ Directory

**Purpose:** Custom CSS for command output styling

**Structure:**
```
styles/
├── command-output.css       # Output styling
├── theme.css                # Theme customization
└── dark-mode.css
```

**Usage in plugin.json:**
```json
{
  "outputStyles": ["./styles/command-output.css", "./styles/theme.css"]
}
```

### Optional: assets/ Directory

**Purpose:** Static files like icons, images, templates

**Structure:**
```
assets/
├── icon.png                 # Plugin icon (128x128 recommended)
├── logo.svg
├── templates/
│   ├── report.html
│   └── email.txt
└── images/
    ├── screenshot1.png
    └── screenshot2.png
```

### Optional: README.md

**Purpose:** Plugin documentation for users and developers

**Suggested sections:**
- Overview (what the plugin does)
- Installation (how to install)
- Usage (how to use each command)
- Configuration (any setup needed)
- Troubleshooting
- Contributing guidelines
- License

### Optional: CHANGELOG.md

**Purpose:** Version history and release notes

**Format:**
```markdown
# Changelog

## [2.1.0] - 2024-01-15
### Added
- New security-audit command
- Support for custom rule files

### Fixed
- Performance issue with large files

## [2.0.0] - 2024-01-01
### Changed
- Breaking change: restructured command output
```

### Optional: LICENSE

**Purpose:** License terms for the plugin

**Examples:**
- `LICENSE` (MIT license text)
- `.license/` (multiple license files)
- License identifier in `plugin.json`: `"license": "MIT"`

## File Locations Reference Table

| Component | Default Location | Type | Required? | Purpose |
|-----------|------------------|------|-----------|---------|
| **Manifest** | `.claude-plugin/plugin.json` | File | ✅ Yes | Plugin configuration |
| **Commands** | `commands/` | Directory | ❌ No | Slash commands |
| **Agents** | `agents/` | Directory | ❌ No | Custom agents |
| **Skills** | `skills/` | Directory | ❌ No | Agent Skills |
| **Hooks** | `hooks/hooks.json` or inline | File/Config | ❌ No | Event handlers |
| **MCP servers** | `.mcp.json` or inline | File/Config | ❌ No | External service integration |
| **LSP servers** | `.lsp.json` or inline | File/Config | ❌ No | Code intelligence |
| **Scripts** | `scripts/` | Directory | ❌ No | Utility scripts |
| **Styles** | `styles/` | Directory | ❌ No | Output CSS styling |
| **Assets** | `assets/` | Directory | ❌ No | Static files, images |
| **Docs** | `README.md`, `CHANGELOG.md` | Files | ❌ No | User documentation |
| **License** | `LICENSE` | File | ❌ No | License terms |

## Common Plugin Patterns

### Simple Plugin (Single Command)

```
simple-plugin/
├── .claude-plugin/
│   └── plugin.json
├── commands/
│   └── format.md
└── README.md
```

### Multi-Command Plugin

```
code-tools-plugin/
├── .claude-plugin/
│   └── plugin.json
├── commands/
│   ├── validate.md
│   ├── format.md
│   ├── analyze.md
│   └── report.md
└── README.md
```

### Plugin with Skills

```
analyzer-plugin/
├── .claude-plugin/
│   └── plugin.json
├── commands/
│   └── analyze.md
├── skills/
│   ├── code-analyzer/
│   │   └── SKILL.md
│   └── pattern-detector/
│   │   └── SKILL.md
└── README.md
```

### Plugin with MCP Integration

```
database-plugin/
├── .claude-plugin/
│   └── plugin.json
├── commands/
│   ├── query.md
│   └── schema.md
├── .mcp.json
├── mcp/
│   └── database.py
└── README.md
```

### Complete Enterprise Plugin

```
enterprise-plugin/
├── .claude-plugin/
│   └── plugin.json
├── commands/
│   ├── deploy.md
│   ├── status.md
│   └── logs.md
├── agents/
│   ├── deployment-manager.md
│   └── security-auditor.md
├── skills/
│   ├── kubernetes-deployment/
│   │   ├── SKILL.md
│   │   └── references/
│   │       └── kubectl-guide.md
│   └── aws-integration/
│       ├── SKILL.md
│       └── scripts/
│           └── sync.py
├── hooks/
│   └── hooks.json
├── .mcp.json
├── .lsp.json
├── scripts/
│   ├── pre-deploy.sh
│   ├── post-deploy.sh
│   └── health-check.py
├── styles/
│   └── deployment.css
├── assets/
│   ├── icon.png
│   └── templates/
│       └── status-report.html
├── README.md
├── CHANGELOG.md
└── LICENSE
```

## Structure Validation Checklist

Before installing or distributing your plugin:

- [ ] `.claude-plugin/plugin.json` exists at correct location
- [ ] `plugin.json` is valid JSON (validate with `jq .`)
- [ ] Required fields in manifest: `name`, `description`
- [ ] Component directories at plugin root (not in `.claude-plugin/`)
- [ ] Command files are `.md` with YAML frontmatter
- [ ] Command names are lowercase-hyphen
- [ ] Agent files have required `description` and `capabilities`
- [ ] Skill directories contain `SKILL.md`
- [ ] All paths in `plugin.json` use `./` prefix
- [ ] Hook scripts are executable (`chmod +x`)
- [ ] Hook scripts have shebang line
- [ ] MCP/LSP paths use `${CLAUDE_PLUGIN_ROOT}` variable
- [ ] No components inside `.claude-plugin/` directory
- [ ] Directory depth appropriate (not overly nested)
- [ ] No circular references or dependencies

## Size and Performance Considerations

**Plugin size guidelines:**
- Keep total plugin <50MB for fast downloads
- Move large assets to separate directories
- Consider lazy-loading for optional components
- Document external dependencies

**Performance considerations:**
- Limit number of commands (10-20 is reasonable)
- Keep hooks lightweight (short scripts)
- Avoid spawning many subprocesses
- Cache expensive operations where possible

## Migration from Old Structure

If you have an older plugin structure:

**Old structure:**
```
plugin/
├── plugin.json              ← At root
├── commands/
└── agents/
```

**New structure:**
```
plugin/
├── .claude-plugin/
│   └── plugin.json          ← Moved here
├── commands/
└── agents/
```

**Migration steps:**
1. Create `.claude-plugin/` directory
2. Move `plugin.json` to `.claude-plugin/plugin.json`
3. Reinstall plugin: `claude plugin uninstall && claude plugin install`

## See Also

- [Plugin manifest schema](plugin-json-schema.md) — Configuration options
- [Plugin caching](plugin-caching.md) — How plugins are installed
- [Debugging and troubleshooting](debugging-troubleshooting.md) — Fix structural issues
- [Slash commands](slash-command-format.md) — Command file format
- [Hooks](hooks.md) — Hook configuration patterns
