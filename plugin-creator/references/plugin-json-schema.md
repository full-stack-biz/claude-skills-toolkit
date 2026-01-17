# Plugin Manifest Schema (plugin.json)

Complete reference for `.claude-plugin/plugin.json` fields and validation.

## Table of Contents

- [Required Fields](#required-fields)
- [Optional Fields](#optional-fields)
- [Component Path Configuration (Optional)](#component-path-configuration-optional)
- [Path Behavior Rules](#path-behavior-rules)
- [Example with Component Paths](#example-with-component-paths)
- [Complete Example](#complete-example)
- [Validation Rules](#validation-rules)
- [JSON Formatting Best Practices](#json-formatting-best-practices)
- [Common Errors](#common-errors)

## Required Fields

### `name` (string)
- **Length**: 1-64 characters
- **Format**: lowercase, hyphens, no spaces
- **Regex**: `^[a-z0-9]([a-z0-9-]{0,62}[a-z0-9])?$`
- **Reserved**: Cannot contain "anthropic" or "claude"
- **Uniqueness**: Must be unique across all installed plugins
- **Purpose**: Unique identifier, becomes slash command namespace

**Examples:**
```json
"name": "code-reviewer"
"name": "pdf-processor"
"name": "test-runner-v2"
```

**Wrong:**
```json
"name": "Code Reviewer"           // spaces not allowed
"name": "claude-plugin"           // reserved word
"name": "MyCodeReviewer"          // uppercase not allowed
```

## Optional Fields

### `description` (string) — **Highly Recommended**

> **Note:** While technically optional, `description` is critical for plugin activation. Without it, Claude won't know when to suggest your plugin. Always include a description.

- **Length**: 1-1024 characters
- **Format**: Human-readable text
- **Recommended elements**: Action verb, trigger phrases, scope/components
- **Purpose**: Tells Claude when to suggest or use the plugin

**Format:**
```
[Action]. Use when [trigger contexts/phrases]. [Components/scope].
```

**Examples:**
```json
"description": "Review code for best practices and potential issues. Use when validating pull requests, reviewing before commit, or analyzing code quality. Includes validate, report, and export commands."

"description": "Extract and analyze PDF documents with OCR. Use when processing PDFs, extracting text, or analyzing document content. Supports encrypted PDFs and multiple formats."

"description": "Run tests and generate reports. Use when validating code before commit or generating test coverage reports. Supports PHPUnit, Jest, and Go testing frameworks."
```

**Wrong:**
```json
"description": "A plugin for code stuff"              // vague, no trigger phrases
"description": "processor"                             // too short, unclear
"description": "Use this plugin to process things"    // no specific trigger context
```

### `version` (string)
- **Format**: Semantic versioning (MAJOR.MINOR.PATCH)
- **Pattern**: `^\d+\.\d+\.\d+$`
- **Default**: "1.0.0"
- **Purpose**: Track plugin releases for team coordination

**Examples:**
```json
"version": "1.0.0"
"version": "2.1.3"
```

### `author` (object)
- **Fields**:
  - `name` (string, required): Author's name
  - `email` (string, optional): Contact email
  - `url` (string, optional): Author's website/profile
- **Purpose**: Attribution and contact

**Example:**
```json
"author": {
  "name": "Jane Developer",
  "email": "jane@example.com",
  "url": "https://example.com"
}
```

### `homepage` (string)
- **Format**: Valid HTTPS URL
- **Purpose**: Link to plugin documentation or homepage

**Example:**
```json
"homepage": "https://github.com/user/code-reviewer"
```

### `repository` (string or object)
- **Formats**:
  - String: `"https://github.com/user/repo"`
  - Object: `{"type": "git", "url": "https://github.com/user/repo"}`
- **Purpose**: Link to source code repository

**Examples:**
```json
"repository": "https://github.com/user/plugin-name"

"repository": {
  "type": "git",
  "url": "https://github.com/user/plugin-name"
}
```

### `license` (string)
- **Format**: SPDX license identifier or path to license file
- **Examples**: "MIT", "Apache-2.0", "GPL-3.0", "LICENSE"
- **Purpose**: Specify license terms

**Examples:**
```json
"license": "MIT"
"license": "Apache-2.0"
"license": "./LICENSE"
```

### `keywords` (array of strings)
- **Length**: 1-10 keywords
- **Max length per keyword**: 64 characters
- **Purpose**: Help plugin discovery (for marketplaces)

**Example:**
```json
"keywords": ["code-review", "quality", "validation", "testing"]
```

### `icon` (string)
- **Format**: File path to icon image (PNG, SVG, JPEG)
- **Size**: 128x128 pixels recommended
- **Purpose**: Visual representation in plugin manager (marketplace only)

**Example:**
```json
"icon": "./assets/icon.png"
```

### `tags` (array of strings)
- **Purpose**: Categorization for plugin discovery

**Example:**
```json
"tags": ["code-quality", "testing", "development"]
```

## Component Path Configuration (Optional)

By default, Claude Code looks for components in standard directories (`commands/`, `agents/`, `skills/`, etc.). You can customize these paths:

### `commands` (string or array)
- **Format**: Relative paths starting with `./`
- **Purpose**: Specify custom command file/directory locations
- **Supplements default**: Both default `commands/` and custom paths are loaded

**Examples:**
```json
"commands": "./my-commands/"

"commands": ["./commands/", "./custom-commands/", "./scripts/commands.md"]
```

### `agents` (string or array)
- **Format**: Relative paths starting with `./`
- **Purpose**: Specify custom agent directories
- **Supplements default**: Both default `agents/` and custom paths are loaded

**Example:**
```json
"agents": "./lib/agents/"
```

### `skills` (string or array)
- **Format**: Relative paths starting with `./`
- **Purpose**: Specify custom skill directories
- **Supplements default**: Both default `skills/` and custom paths are loaded

**Example:**
```json
"skills": ["./skills/", "./reusable-skills/"]
```

### `hooks` (string or object)
- **Format**: Path to `hooks.json` file OR inline hook configuration
- **Purpose**: Event handlers for plugin events
- **See**: `references/hooks.md` for complete configuration examples

**Examples:**
```json
"hooks": "./hooks.json"

"hooks": {
  "PostToolUse": [
    {
      "hooks": [
        {"type": "command", "command": "./scripts/format.sh"}
      ]
    }
  ]
}
```

### `mcpServers` (string or object)
- **Format**: Path to `.mcp.json` file OR inline MCP configuration
- **Purpose**: Configure Model Context Protocol servers for external service integration
- **See**: `references/mcp-servers.md` for complete configuration examples

**Example:**
```json
"mcpServers": "./.mcp.json"
```

### `lspServers` (string or object)
- **Format**: Path to `.lsp.json` file OR inline LSP configuration
- **Purpose**: Configure Language Server Protocol for code intelligence
- **See**: `references/lsp-servers.md` for complete configuration examples

**Example:**
```json
"lspServers": "./.lsp.json"
```

### `outputStyles` (string or array)
- **Format**: Relative paths to CSS files or directories
- **Purpose**: Custom styling for command output and UI
- **See**: `references/output-styles.md` for examples

**Example:**
```json
"outputStyles": "./styles/custom.css"
```

## Path Behavior Rules

**Critical:** All paths are relative to plugin root and must start with `./`

**Examples of correct paths:**
```json
{
  "commands": "./commands/",
  "agents": "./lib/agents/",
  "skills": ["./skills/", "./vendor-skills/"],
  "hooks": "./config/hooks.json"
}
```

**Examples of WRONG paths:**
```json
{
  "commands": "commands/",           // Missing ./
  "agents": "/home/user/plugin/agents/",  // Absolute path won't work
  "skills": "skills"                 // Missing trailing slash
}
```

**Supplementation vs. Replacement:**
Custom paths SUPPLEMENT default directories, they don't replace them.

Example:
```json
{
  "commands": "./my-commands/"
}
```

Claude Code will load commands from BOTH:
- `./commands/` (default)
- `./my-commands/` (custom)

**Using Variables:**
In hooks, MCP servers, and scripts, use `${CLAUDE_PLUGIN_ROOT}` for absolute paths (see `references/plugin-paths-variables.md`):

```json
{
  "type": "command",
  "command": "${CLAUDE_PLUGIN_ROOT}/scripts/format.sh"
}
```

## Example with Component Paths

```json
{
  "name": "my-plugin",
  "description": "Multi-feature plugin with custom paths. Use when...",
  "version": "1.0.0",
  "author": {"name": "Developer"},
  "commands": ["./commands/", "./lib/slash-commands/"],
  "agents": "./workflows/agents/",
  "skills": ["./skills/", "./vendor/skills/"],
  "hooks": "./config/hooks.json",
  "mcpServers": "./.mcp.json"
}
```

## Complete Example

```json
{
  "name": "code-reviewer",
  "description": "Review code for best practices and potential issues. Use when validating pull requests, reviewing before commit, or analyzing code quality. Includes validate, report, and export commands.",
  "version": "1.0.0",
  "author": {
    "name": "Jane Developer",
    "email": "jane@example.com",
    "url": "https://example.com"
  },
  "homepage": "https://github.com/jane/code-reviewer",
  "repository": {
    "type": "git",
    "url": "https://github.com/jane/code-reviewer"
  },
  "license": "MIT",
  "keywords": ["code-review", "quality", "validation"],
  "icon": "./assets/icon.png"
}
```

## Validation Rules

**Name:**
- Unique across all plugins
- No uppercase letters
- No spaces or special characters except hyphens
- No reserved words (anthropic, claude)
- 1-64 characters

**Description:**
- Must be readable English
- Should include specific trigger phrases (Claude uses this for activation)
- Include component list if plugin has multiple commands/agents
- 1-1024 characters

**Version:**
- Must follow semantic versioning (MAJOR.MINOR.PATCH)
- Initial version typically "1.0.0"
- Increment for releases

**Author:**
- `name` required if author object present
- Email and URL optional but recommended

**URLs:**
- Must be valid HTTPS URLs (http deprecated)
- Should be accessible
- Repository should contain plugin source

## JSON Formatting Best Practices

```json
{
  "name": "plugin-name",
  "description": "Clear, specific description with trigger phrases.",
  "version": "1.0.0",
  "author": {
    "name": "Your Name"
  }
}
```

**Valid JSON check:**
```bash
jq . .claude-plugin/plugin.json  # Validates JSON syntax
```

## Common Errors

### Error 1: Invalid JSON
```json
{
  "name": "my-plugin",
  "description": "Description here"  // Missing comma on previous line
  "version": "1.0.0"
}
```

**Fix:** Add comma after each field except the last

### Error 2: Reserved word in name
```json
"name": "claude-utilities"  // "claude" is reserved
```

**Fix:** Use `"name": "utilities"` or `"name": "code-utilities"`

### Error 3: Vague description
```json
"description": "A useful plugin"
```

**Fix:** Include trigger phrases
```json
"description": "Utility functions for code analysis. Use when processing source files or analyzing code structure."
```

### Error 4: Invalid version
```json
"version": "1.0"         // Should be MAJOR.MINOR.PATCH
```

**Fix:**
```json
"version": "1.0.0"
```

### Error 5: HTTP instead of HTTPS
```json
"homepage": "http://example.com"
```

**Fix:**
```json
"homepage": "https://example.com"
```
