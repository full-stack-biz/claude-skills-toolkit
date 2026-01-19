---
name: plugin-creator
description: >-
  Create, validate, and refine Claude Code plugins. Use when: building a new plugin from scratch ("help me create a plugin"), converting existing projects to plugins ("make this a plugin"), or validating/improving plugin structure. Includes manifest generation, component organization, and plugin testing.
version: 1.0.0
allowed-tools: Read,Write,Edit,AskUserQuestion,Glob,Bash(cp,mkdir,ls,find)
---

# Plugin Creator

**Dual purpose:** Create plugins from scratch OR transform existing projects into well-structured plugins.

## When to Use This Skill

Invoke plugin-creator in these scenarios:

**Creating new plugins:** Building a plugin from scratch with proper manifest, commands, agents, Skills, hooks, and/or MCP servers organized correctly.

**Converting projects to plugins:** Take an existing project and transform it into a Claude Code plugin with `.claude-plugin/plugin.json` manifest and proper directory structure.

**Validating plugin structure:** Check existing plugins against Claude Code plugin standards (manifest schema, directory layout, naming conventions).

**Multi-component plugins:** Creating plugins that bundle multiple elements (Skills + slash commands, hooks + agents, MCP servers + Skills, etc.).

**Team/production plugins:** Building plugins for distribution across teams or deployment to plugin marketplaces.

**NOT for:** General Claude questions, debugging plugin behavior at runtime, writing plugin code directly (focus on structure/organization only).

## Foundation: How Plugins Work

Plugins extend Claude Code with custom functionality shared across projects and teams.

**Plugin activation:** Pure LLM reasoning on manifest metadata. Claude discovers plugins via:
- **name**: Unique identifier (plugin namespace for slash commands: `/plugin-name:command`)
- **description**: Tells Claude when to suggest or use the plugin

**Plugin structure:**
```
my-plugin/
├── .claude-plugin/
│   └── plugin.json                    # Required: metadata manifest
├── commands/
│   ├── hello.md                       # Optional: slash commands
│   └── review.md
├── agents/                            # Optional: custom agents
│   ├── code-reviewer.md
│   └── security-auditor.md
├── skills/                            # Optional: Agent Skills
│   └── code-review/
│       └── SKILL.md
├── hooks.json                         # Optional: event handlers
├── .mcp.json                          # Optional: MCP servers
└── .lsp.json                          # Optional: LSP servers
```

**Token loading hierarchy:**
1. **Plugin manifest** (150 tokens): name + description in plugin.json (always loaded for discovery)
2. **Component metadata** (50-200 tokens each): Command files, agent descriptions, skill descriptions
3. **Full content** (unlimited): Loaded only when Claude uses the component

**Why this matters for your plugin:**
- **plugin.json description** is your activation signal (vague = plugin never recommended when needed)
- **Naming conventions** are critical (plugin name becomes slash command namespace: `/my-plugin:command`)
- **Directory structure** must be exact (Claude Code uses path conventions to discover components)
- **Component metadata** must be clear (descriptions tell Claude what each command/agent/skill does)

## Choose Your Workflow

See `references/implementation-workflow.md` for complete step-by-step procedures.

### 1. Creating a New Plugin from Scratch
Interview requirements → create structure → add components → test locally

### 2. Converting an Existing Project to a Plugin
Identify components → create plugin structure → migrate and update metadata → test locally

### 3. Validating or Improving Existing Plugins
Check manifest → verify structure → review metadata → improve and re-test

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
  "description": "[Action]. Use when [trigger contexts].",
  "version": "1.0.0"
}
```

**Add components:**
- Slash commands: `.md` files in `commands/` (see `references/slash-command-format.md`)
- Other components: See "Component Overview" section below
- Test: `claude --plugin-dir /path/to/my-plugin`

## Complete Reference Documentation

**Implementation & Validation:**
- `references/implementation-workflow.md` — Step-by-step procedures for creating, converting, and validating plugins
- `references/validation-checklist.md` — Comprehensive validation phases and checklists

**Installation & Scopes:**
- `references/installation-scopes.md` — User/project/local/managed scopes and use cases
- `references/cli-commands.md` — Plugin install/uninstall/enable/disable/update commands

**Plugin Architecture:**
- `references/directory-structure.md` — Standard plugin layout, file organization, validation
- `references/plugin-json-schema.md` — Manifest format, required/optional fields, component paths
- `references/plugin-paths-variables.md` — Relative paths, ${CLAUDE_PLUGIN_ROOT} variable
- `references/plugin-caching.md` — Plugin caching, file resolution, symlinks, path traversal

**Components & Configuration:**
- `references/slash-command-format.md` — Command file format, metadata, arguments
- `references/agent-skills.md` — Packaging Skills in plugins
- `references/hooks.md` — Event handlers, hook configuration, patterns
- `references/mcp-servers.md` — External service integration
- `references/lsp-servers.md` — Language-specific code intelligence

**Deployment & Troubleshooting:**
- `references/versioning-and-distribution.md` — Semantic versioning, changelog, distribution
- `references/debugging-troubleshooting.md` — Debug mode, common issues, error messages
- `references/best-practices.md` — Production patterns, security, performance

## Component Overview

See `references/quick-reference.md` for component templates, formats, and metadata requirements.

| Component | Use Case |
|-----------|----------|
| **Slash Commands** (`commands/`) | User-facing commands via `/plugin-name:command` |
| **Custom Agents** (`agents/`) | Complex multi-step workflows with planning |
| **Agent Skills** (`skills/`) | Capabilities Claude uses automatically |
| **Hooks** (`hooks.json`) | Event handlers (tool use, permissions, sessions) |
| **MCP Servers** (`.mcp.json`) | External service integration (APIs, databases) |
| **LSP Servers** (`.lsp.json`) | Language-specific code intelligence |

## Key Notes

**Plugin naming conventions:**
- Hyphen-separated lowercase: `code-reviewer`, `pdf-processor`, `test-runner`
- Include action/domain: prefer `test-runner` over `runner`
- Becomes slash command namespace: `/code-reviewer:validate`

**CLI commands:** `claude plugin install|uninstall|enable|disable|update <name>@<marketplace> [--scope user|project|local]`

**Important paths note:**
- Plugins are cached (copied, not used in-place) for security
- External paths won't work after installation; use `${CLAUDE_PLUGIN_ROOT}` variable in hooks/scripts
- See `references/plugin-paths-variables.md` for complete path behavior and variable usage

**Description formula (Claude's activation signal):**
```
[Action]. Use when [trigger contexts]. [Components/scope].
```

Example: "Review code for best practices. Use when validating pull requests or before commit. Includes validate, report, and export commands."

**Installation scopes:**
- **`user` scope (global)**: `~/.claude/skills/` (available in all projects)
- **`project` scope**: `.claude/skills/` (shared via git)
- **`local` scope**: `.claude/skills/` (personal, not shared)
- **`managed` scope**: System cache (marketplace plugins, read-only)

See `references/installation-scopes.md` for scope details and use cases.

## Validation Checklist

See `references/validation-checklist.md` for comprehensive checklist.

**Quick priorities:**
1. Run `claude plugin validate /path/to/plugin` (catches structural errors immediately)
2. Review manifest description (most common activation signal issue)
3. Test locally with `claude --plugin-dir /path/to/plugin`

## Advanced Topics

**Publishing & Distribution:**
See `references/team-marketplaces.md` for marketplace setup, version management, and team distribution patterns.

**Language Servers (LSP):**
See `references/lsp-servers.md` for LSP configuration and language-specific integration examples.

**Hooks & Events:**
See `references/hooks.md` for event handler configuration and common automation patterns.

**Agent Skills in Plugins:**
See `references/agent-skills.md` for packaging Skills in plugins. (Note: To create new Skills, use the `skill-creator` skill.)

**External Service Integration (MCP):**
See `references/mcp-servers.md` for MCP server configuration and testing.

**Team Plugins:**
- Use `.claude/skills/` (project-local) for team-shared plugins
- Use `~/.claude/skills/` (global) for organization-wide plugins
- Document dependencies in plugin description
- Version track releases in plugin.json
- Peer review before team deployment

See `references/team-marketplaces.md` for multi-plugin registries and marketplace setup.
