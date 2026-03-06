---
name: plugin-creator
description: >-
  Create, convert, validate, and publish Claude Code plugins with Agent Skills, hooks, agents, and servers. Use when building plugins from scratch, converting projects to plugins, improving plugin structure, or publishing to marketplace. Includes automated scanning, manifest generation, marketplace.json creation, and validation guidance. Component-specific work delegates to hook-creator, subagent-creator, and skill-creator skills.
version: 1.7.0
allowed-tools: Read,Write,Edit,AskUserQuestion,Glob,Bash(find:*,grep:*,head:*,jq:*,du:*,xargs:*)
---

# Plugin Creator

**Dual purpose:** Create plugins from scratch OR transform existing projects into well-structured plugins.

## Quick Routing

Use AskUserQuestion with **predefined options** to gather requirements:

```
questions: [
  {
    question: "What would you like to do?",
    header: "Action",
    options: [
      {
        label: "Create a new plugin",
        description: "Build a plugin from scratch with proper manifest, structure, and components"
      },
      {
        label: "Convert a project to plugin",
        description: "Transform existing project into plugin with manifest and proper directory layout"
      },
      {
        label: "Validate a plugin",
        description: "Check plugin structure against Claude Code standards"
      },
      {
        label: "Publish to marketplace",
        description: "Prepare plugin for distribution and marketplace publication"
      }
    ],
    multiSelect: false
  }
]
```

Then proceed to the appropriate workflow section based on their selection.

---

## When to Use This Skill

Invoke plugin-creator in these scenarios:

**Creating new plugins:** Building a plugin from scratch with proper manifest, commands, agents, Skills, hooks, and/or MCP servers organized correctly.

**Converting projects to plugins:** Take an existing project and transform it into a Claude Code plugin with `.claude-plugin/plugin.json` manifest and proper directory structure.

**Validating plugin structure:** Check existing plugins against Claude Code plugin standards (manifest schema, directory layout, naming conventions).

**Multi-component plugins:** Creating plugins that bundle multiple elements (Skills, hooks, agents, MCP servers, etc.).

**Team/production plugins:** Building plugins for distribution across teams or deployment to plugin marketplaces.

**NOT for:** General Claude questions, debugging plugin behavior at runtime, writing plugin code directly (focus on structure/organization only).

## ⚠️ Important: Slash Commands Deprecated

**Slash commands** (via `commands/` directory) are deprecated in favor of **Agent Skills**.

When creating new plugins, use Agent Skills (`skills/` directory) instead. Slash commands still work for backward compatibility but are being phased out. Use `skill-creator` to build Agent Skills instead.

---

## Foundation: How Plugins Work

Plugins extend Claude Code with custom functionality shared across projects and teams.

**Plugin activation:** Pure LLM reasoning on manifest metadata. Claude discovers plugins via:
- **name**: Unique identifier (plugin namespace)
- **description**: Tells Claude when to suggest or use the plugin

**Plugin structure (at project root):**
```
.
├── .claude-plugin/
│   └── plugin.json                    # Required: metadata manifest
├── skills/                            # Optional: Agent Skills (recommended)
│   └── code-review/
│       ├── SKILL.md
│       └── references/
├── agents/                            # Optional: subagents
│   ├── code-reviewer.md
│   └── security-auditor.md
├── hooks.json                         # Optional: event handlers
├── .mcp.json                          # Optional: MCP servers
├── .lsp.json                          # Optional: LSP servers
└── commands/                          # DEPRECATED: Use skills instead
    ├── hello.md
    └── review.md
```

**Token loading hierarchy:**
1. **Plugin manifest** (150 tokens): name + description in plugin.json (always loaded for discovery)
2. **Component metadata** (50-200 tokens each): Command files, agent descriptions, skill descriptions
3. **Full content** (unlimited): Loaded only when Claude uses the component

**Why this matters for your plugin:**
- **plugin.json description** is your activation signal (vague = plugin never recommended when needed)
- **Naming conventions** are critical (plugin name becomes skill namespace in plugins)
- **Directory structure** must be exact (Claude Code uses path conventions to discover components)
- **Component metadata** must be clear (descriptions tell Claude what each command/agent/skill does)

---

## Quick Start: Create a Plugin in an Empty Project

Copy-paste templates for creating a plugin structure from scratch: manifest, skills, agents, and testing. See `references/quick-start-guide.md` for complete bash commands and examples.

## Choose Your Workflow

**START HERE:** Always begin by asking the user to clarify their intent and collect all required manifest data using AskUserQuestion (one question at a time, progressive disclosure):

### Interview Flow for New Plugin Creation

For users creating a new plugin, conduct this structured interview to gather all manifest.json fields **before** file creation. Use the predefined options format shown in Quick Routing above for Step 1.

1. **Action** - Use the predefined options from "Quick Routing" section above
   - Create a new plugin (→ proceed to 2-9)
   - Convert a project (→ skip to Converting Projects section)
   - Validate a plugin (→ skip to Validating Plugins section)
   - Publish to marketplace (→ skip to Publishing to Marketplace section)

2. **Plugin name** - "What's the plugin name?" (lowercase-hyphen, 1-64 chars)
   - Maps to: `plugin.json` → `name` field
   - Example: `code-reviewer`, `pdf-processor`

3. **Purpose/description** - "What does the plugin do? Describe its main purpose and capabilities."
   - Maps to: `plugin.json` → `description` field (1-1024 chars)
   - Example: "Review code for best practices and potential issues."

4. **Version** - "What version? (semantic format: MAJOR.MINOR.PATCH)"
   - Maps to: `plugin.json` → `version` field
   - Default if not specified: `1.0.0`

5. **Author information** - "Who is the author? (name, optional: email, URL)"
   - Maps to: `plugin.json` → `author` object with `name` field (REQUIRED)
   - Format: `{"name": "Your Name", "email": "optional@email.com", "url": "https://optional.url"}`
   - **CRITICAL:** author must be object, not string (common failure point)

6. **Optional metadata** - "Any additional metadata? (license, repository, homepage)"
   - Maps to: `plugin.json` → `license`, `repository`, `homepage` fields
   - Example: `"MIT"`, `"https://github.com/user/plugin"`, `"https://docs.example.com"`

7. **Components (BATCH 1)** - Use AskUserQuestion with **predefined options** (multiSelect: true):

```
questions: [
  {
    question: "Which core components will the plugin include?",
    header: "Core Components",
    options: [
      { label: "Skills", description: "Agent Skills (recommended)" },
      { label: "Agents", description: "Subagents for complex workflows" },
      { label: "Hooks", description: "Event handlers and automation" },
      { label: "MCP servers", description: "Model Context Protocol servers" }
    ],
    multiSelect: true
  }
]
```

8. **Components (BATCH 2)** - Then use AskUserQuestion for optional server support:

```
questions: [
  {
    question: "Include Language Server Protocol (LSP) support?",
    header: "LSP Servers",
    options: [
      { label: "Yes", description: "Add language-specific code intelligence" },
      { label: "No", description: "Skip LSP servers" }
    ],
    multiSelect: false
  }
]
```

⏸️ Wait for both batch responses before proceeding.

9. **Distribution scope** - Use AskUserQuestion with **predefined options**:

```
questions: [
  {
    question: "What's the distribution scope for this plugin?",
    header: "Distribution",
    options: [
      { label: "Personal", description: "Personal use only" },
      { label: "Team-shared", description: "Share with team members" },
      { label: "Marketplace", description: "Publish to plugin marketplace for community" }
    ],
    multiSelect: false
  }
]
```

### Manifest Field Mapping Reference

| Interview Question | Maps to | Type | Required | Notes |
|---|---|---|---|---|
| Action | (routing logic) | string | Yes | Determines workflow path |
| Plugin name | `plugin.json` → `name` | string | Yes | kebab-case, 1-64 chars, no spaces |
| Purpose/description | `plugin.json` → `description` | string | Yes | 1-1024 chars, clear and specific |
| Version | `plugin.json` → `version` | string | No | Semantic versioning (default: 1.0.0) |
| Author name | `plugin.json` → `author.name` | string | Yes | Must be object property, not string |
| Author email | `plugin.json` → `author.email` | string | No | Optional contact information |
| Author URL | `plugin.json` → `author.url` | string | No | Optional profile/website |
| License | `plugin.json` → `license` | string | No | e.g., "MIT", "Apache-2.0" |
| Repository | `plugin.json` → `repository` | string | No | GitHub/GitLab URL |
| Homepage | `plugin.json` → `homepage` | string | No | Documentation URL |
| Components (BATCH 1) | Directory structure | array | No | Skills, Agents, Hooks, MCP servers (max 4 options) |
| Components (BATCH 2) | Directory structure | boolean | No | Include LSP servers (yes/no) |
| Distribution scope | `marketplace.json` | string | No | "personal", "team", or "marketplace" |

### Common Manifest Generation Failures (Prevention)

**Failure: `author` is string instead of object**
- ❌ Wrong: `"author": "John Doe"`
- ✅ Correct: `"author": {"name": "John Doe"}`
- **Prevention:** Always structure author as object in template

**Failure: Missing required fields**
- Check: `name`, `description`, `author.name` are always present
- Validate before writing plugin.json

**Failure: Incorrect marketplace.json schema**
- **Critical requirements:**
  - `owner` MUST be object: `{"name": "username"}`
  - `plugins` MUST be array: `[{...}]`
  - `source` MUST start with `./`
- See "Publishing to Marketplace" section for full schema

Based on their answers, route to the appropriate workflow section below:

---

## Automated Scanning Phase (For Validation)

**When validating existing plugins, always run the automated scanning phase FIRST before manual validation.**

See `references/automated-scanning-workflow.md` for complete scanning workflow, decision handling, and example validation sequences. The scanner is read-only only—it scans and reports, never modifies. All user decisions are explicit and visible.

**Quick reference:** Run the scanner, process errors/warnings, use AskUserQuestion for decisions, execute approved changes, re-scan, then proceed to manual validation.

---

### 1. Creating a New Plugin from Scratch
Interview requirements → create structure → add components → run `claude plugin validate` → test locally

See `references/implementation-workflow.md` for complete step-by-step procedures.

### 2. Converting an Existing Project to a Plugin
Identify components → create plugin structure → migrate and update metadata → run `claude plugin validate` → test locally

See `references/implementation-workflow.md` for complete step-by-step procedures.

### 3. Validating or Improving Existing Plugins
**FIRST:** Run `claude plugin validate /path/to/plugin` directly. Review output for errors. **THEN:** Do manual checks for best practices from `references/validation-checklist.md`.

### 4. Publishing to Marketplace

Make your plugin installable via `claude plugin marketplace add owner/repo`.

**Step 1:** Ensure plugin.json exists at `.claude-plugin/plugin.json`

**Step 2:** Create `.claude-plugin/marketplace.json` with this structure:

```json
{
  "name": "your-plugin-name",
  "owner": {
    "name": "github-username-or-org"
  },
  "plugins": [
    {
      "name": "your-plugin-name",
      "source": "./",
      "description": "What the plugin does"
    }
  ]
}
```

**CRITICAL schema requirements:**
- `owner` MUST be an object with `name` field, NOT a string
- `plugins` MUST be an array (can be empty `[]`)
- `source` paths MUST start with `./`

**Step 3:** Validate with `claude plugin validate /path/to/plugin`

See `references/team-marketplaces.md` for complete marketplace schema and common errors.

## Manifest Generation Best Practices

**BEFORE generating manifests, verify you have all required data:**

1. ✅ Plugin name (kebab-case, 1-64 chars)
2. ✅ Description (clear, 1-1024 chars)
3. ✅ Author name (will be in object: `{"name": "..."}`)
4. ✅ Version (semantic format, default: 1.0.0)

**ALWAYS structure author as object:**
```json
{
  "name": "my-plugin",
  "description": "What it does.",
  "version": "1.0.0",
  "author": {
    "name": "Your Name"
  }
}
```

**NEVER generate with incomplete data** - Incomplete manifests cause validation failures. Run the interview flow first, collect all fields, then proceed with generation.

**For marketplace.json, use official schema:**
```json
{
  "name": "plugin-name",
  "owner": {
    "name": "github-username"
  },
  "plugins": [
    {
      "name": "plugin-name",
      "source": "./",
      "description": "What it does"
    }
  ]
}
```

---

## Quick Start: 5-Minute Setup

**Create plugin directory:**
```bash
mkdir -p my-plugin/.claude-plugin
mkdir -p my-plugin/commands my-plugin/agents my-plugin/skills
```

**Write plugin.json:**
```json
{
  "name": "my-plugin",
  "description": "[Action]. [Brief description of purpose and capabilities].",
  "version": "1.0.3"
}
```

**Add components:**
- Agent Skills: `.md` files in `skills/` (recommended approach)
- Other components: See "Component Overview" section below
- Test: `claude --plugin-dir /path/to/my-plugin`

## Reference Guide

### Creating a New Plugin

**Step 1: Understand plugin architecture**
→ How plugins load, token costs, standard directory layout, manifest format
→ `references/plugin-architecture.md` for architecture overview
→ `references/directory-structure.md` for standard layout
→ `references/plugin-json-schema.md` for plugin.json format

**Step 2: Set up plugin structure & manifest**
→ Create `.claude-plugin/plugin.json` with metadata (name, description, version)
→ Templates and common patterns for quick setup
→ `references/quick-reference.md` for templates and metadata requirements

**Step 3: Add Agent Skills, Hooks, or other components**
→ Agent Skills: recommended approach, `.md` files in `skills/`
→ Hooks: event handlers in `hooks.json`
→ Subagents: isolated execution in `agents/`
→ External services: MCP servers, LSP for code intelligence
→ `references/components-in-plugins.md` for packaging guidance
→ Use `skill-creator`, `subagent-creator`, or `hook-creator` skills to build components

**Step 4: Validate & test locally**
→ Run `claude plugin validate /path` for errors
→ Run `claude --plugin-dir /path` for local testing
→ Check best practices from validation checklist
→ `references/validation-checklist.md` for comprehensive checks
→ `references/local-development.md` for debugging

### Converting Existing Project to Plugin

→ Complete step-by-step procedures for converting projects to plugins
→ `references/implementation-workflow.md` for full conversion workflow
→ `references/automated-scanning-workflow.md` for scanning & validation phase

### Publishing & Distribution

→ Semantic versioning, changelog, marketplace setup
→ `references/versioning-and-distribution.md` for versioning
→ `references/team-marketplaces.md` for marketplace.json schema and multi-plugin registries

### Advanced Topics

**Path handling & caching:**
→ Use `${CLAUDE_PLUGIN_ROOT}` variable in hooks/scripts. Plugins are cached for security.
→ `references/plugin-paths-variables.md` for path guidance
→ `references/plugin-caching.md` for caching behavior

**Installing & managing plugins:**
→ Installation scopes (global, project), CLI commands (install/uninstall/enable/disable/update)
→ `references/installation-and-cli.md` for scope and commands

**Troubleshooting & production:**
→ Debugging plugins, common issues, best practices, production checklist
→ `references/troubleshooting-and-production.md`

**Integration patterns:**
→ External service integration (MCP servers), language-specific intelligence (LSP)
→ `references/mcp-servers.md` for MCP configuration
→ `references/lsp-servers.md` for LSP integration

**Legacy support:**
→ Command file format (deprecated, for backward compatibility only)
→ `references/slash-command-format.md` for legacy command support

## Component Overview

See `references/quick-reference.md` for component templates, formats, and metadata requirements.

| Component | Use Case |
|-----------|----------|
| **Agent Skills** (`skills/`) | Capabilities Claude uses automatically or via `/skill-name` (recommended) |
| **Subagents** (`agents/`) | Isolated execution environments with custom prompts, tools, and permissions (use `subagent-creator` skill) |
| **Hooks** (`hooks.json`) | Event handlers (tool use, permissions, sessions) (use `hook-creator` skill) |
| **MCP Servers** (`.mcp.json`) | External service integration (APIs, databases) |
| **LSP Servers** (`.lsp.json`) | Language-specific code intelligence |
| **Commands** (`commands/`) | DEPRECATED: Use Agent Skills instead |

## Key Notes

**Plugin naming conventions:** Hyphen-separated lowercase (`code-reviewer`, `pdf-processor`, `test-runner`). Include action/domain; becomes plugin namespace `/plugin-name` for skills, commands, hooks.

**Description formula (Claude's activation signal):**
```
[Action]. [Brief description of purpose]. [Components/scope].
```
Example: "Review code for best practices and potential issues. Includes validate, report, and export commands."

**CLI commands:** `claude plugin install|uninstall|enable|disable|update <name>@<marketplace> [--scope user|project|local]`

**Important paths note:** Plugins are cached (not in-place) for security. Use `${CLAUDE_PLUGIN_ROOT}` variable in hooks/scripts for paths. See `references/plugin-paths-variables.md` for details.

**Installation scopes:**
- **`user` (global)**: `~/.claude/skills/` (all projects)
- **`project` (shared)**: `.claude/skills/` (via git)
- **`local` (personal)**: `.claude/skills/` (not shared)
- **`managed` (read-only)**: System cache (marketplace plugins)

See `references/installation-and-cli.md` for scope and CLI details.

## Validation Checklist

**Step 0 (AUTOMATED SCANNING):** For existing plugins, run the automated scanner first to catch common issues:
```bash
bash /path/to/plugin-creator/scripts/scan-plugin.sh /path/to/plugin /tmp/plugin-scan.json
```
Review the JSON output and use AskUserQuestion to handle any decisions (file cleanup, permissions, etc.). See "Automated Scanning Phase" section above for details.

**Step 1 (REQUIRED):** Run the validation command directly:
```bash
claude plugin validate /path/to/plugin
```
Do NOT create wrapper scripts. Run this command directly and review its output.

**Step 2:** If validation passes, check best practices from `references/validation-checklist.md`:
- Manifest description includes specific trigger phrases
- Component metadata is clear and complete
- Security: No hardcoded secrets, safe shell patterns, proper permissions
- Documentation: README.md, CHANGELOG.md present for distributed plugins
- Test locally with `claude --plugin-dir /path/to/plugin`
