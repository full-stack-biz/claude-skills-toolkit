# Plugin Architecture & Templates

Understanding plugin architecture helps you create effective plugins. This guide covers how plugins work mechanically, then provides copy-paste templates for common patterns.

## Table of Contents

- [Plugin Discovery & Activation](#plugin-discovery--activation)
- [Token Loading Hierarchy](#token-loading-hierarchy)
- [Plugin Components Overview](#plugin-components-overview)
- [Plugin vs Standalone Configuration](#plugin-vs-standalone-configuration)
- [Performance Considerations](#performance-considerations)
- [Security Model](#security-model)
- [Plugin Templates](#plugin-templates)
- [Customization Checklist](#customization-checklist)
- [Quick Template Selection](#quick-template-selection)

---

## Plugin Discovery & Activation

### Discovery Mechanism

Claude Code discovers plugins by:

1. **Scanning plugin directories:**
   - Global: `~/.claude/skills/` (if installed there)
   - Project-local: `.claude/skills/` (project-specific)

2. **Reading plugin manifest:**
   - Loads `.claude-plugin/plugin.json` from each plugin directory
   - Extracts `name` (for namespace) and `description` (for activation)

3. **Indexing components:**
   - Agent Skills in `skills/` directory (both auto-invoked and user-invoked via `/`)
   - Custom agents in `agents/` directory
   - Hooks in `hooks.json`
   - MCP servers in `.mcp.json`

### Activation Signals

Claude decides when to use a plugin based on:

**Primary signal:** Plugin manifest description
- Contains specific trigger phrases matching user request
- Example user message: "review this code for best practices"
- Matches plugin with description: "Review code for best practices...Use when validating pull requests"
- Result: Plugin recommended/activated

**Component metadata:**
- Skill descriptions and frontmatter (automatically activated by Claude when relevant, or user-invoked via `/`)
- Agent descriptions (if complex workflow needed)

**Specificity matters:**
- Vague descriptions ("A plugin for processing") = rarely activated
- Specific descriptions ("Process PDF files with OCR. Use when extracting text or analyzing documents") = reliably activated

---

## Token Loading Hierarchy

Plugins load in three levels (minimizing unnecessary token usage):

### Level 1: Discovery Metadata (~150 tokens)

Always loaded when Claude Code starts or scans plugins:
- `name` from plugin.json
- `description` from plugin.json
- Plugin is indexed for future discovery

**Why it's always loaded:** Claude needs to know what plugins exist and when they're relevant.

### Level 2: Component Metadata (~50-200 tokens per component)

Loaded when plugin is recommended or explicitly requested:
- Full manifest content (plugin.json)
- Skill frontmatter (name, description, version, allowed-tools)
- Agent descriptions

**Why on-demand:** Claude only needs component details when actually using the plugin.

### Level 3: Full Content (unlimited)

Loaded only when Claude executes a component:
- Skill body (SKILL.md instructions)
- Agent body (detailed instructions)
- Reference files (only if Claude determines they're needed)

**Why on-demand:** Full instructions only needed during execution.

**Token efficiency principle:** Minimize content at levels 1-2, keep detailed instructions in level 3 (full content).

---

## Plugin Components Overview

| Component | Use Case | Location |
|-----------|----------|----------|
| **Agent Skills** | Capabilities Claude uses automatically or via `/skill-name` | `skills/` |
| **Subagents** | Isolated execution with custom tools/permissions | `agents/` |
| **Hooks** | Event handlers that trigger automatically | `hooks.json` |
| **MCP Servers** | External service integration (APIs, databases) | `.mcp.json` |
| **LSP Servers** | Language-specific code intelligence | `.lsp.json` |
| **Commands** | User-invoked slash commands (DEPRECATED: use Skills) | `commands/` |

---

## Plugin vs Standalone Configuration

### When to Use Plugins
- **Sharing across teams/projects:** Plugins are discoverable and shareable
- **Distribution:** Can be published to marketplaces
- **Versioning:** Version tracking for releases and updates
- **Namespacing:** `/plugin-name:command` prevents conflicts

### When to Use Standalone
- **Personal projects:** Single-project customization
- **Quick experiments:** Fast setup without plugin structure
- **Simple workflows:** One or two commands, no complex organization
- **Short names:** `/hello` vs `/my-plugin:hello`

**Key difference:** Plugins use namespacing (`/plugin-name:command`) to prevent conflicts across teams.

---

## Performance Considerations

### Token Usage Optimization

**Good practices:**
1. **Minimal manifest metadata:** 150-200 tokens for discovery
2. **Concise descriptions:** Use specific phrases, not comprehensive docs
3. **Quick Start focus:** 80% of commands should work from Quick Start alone
4. **References for detail:** Detailed content in separate files
5. **One-level directories:** Avoid nested chains

**Example good structure:**
```
plugin/
├── commands/
│   └── validate.md          # ~50 lines, Quick Start + examples
└── references/
    └── comprehensive-guide.md    # ~500 lines, detailed docs
```

Claude loads quick start on every command execution, detailed guide only if referenced.

### Latency Optimization

**Minimize discovery time:**
- Keep plugin.json small (~500 bytes)
- Use concise descriptions (~100 chars)
- Index plugins efficiently

**Minimize execution time:**
- Pre-compute commonly-needed data
- Cache results when possible
- Use parallel operations in agents

---

## Security Model

### Isolation

Plugins are isolated by:
- **Namespace:** `/plugin-name:command` prevents conflicts
- **Permissions:** Tool access controlled via `allowed-tools`
- **Scope:** Each plugin has its own directory

### Permissions Model

```yaml
allowed-tools: Read,Write,Bash(git:*)
```

Claude respects tool scoping:
- `Read`: Can read files
- `Write`: Can write/create files
- `Bash(git:*)`: Only git commands (not all bash)

**Principle:** Least privilege (only necessary tools).

---

## Plugin Templates

Copy-paste starting points for common plugin patterns. Customize for your specific use case.

### Template 1: Simple Single-Command Plugin

For plugins with one slash command.

**Directory structure:**
```
my-plugin/
├── .claude-plugin/
│   └── plugin.json
└── commands/
    └── hello.md
```

**`.claude-plugin/plugin.json`:**
```json
{
  "name": "my-plugin",
  "description": "What the plugin does. Use when [context].",
  "version": "1.0.0",
  "author": {
    "name": "Your Name"
  }
}
```

**`commands/hello.md`:**
```markdown
---
name: hello
description: >-
  Brief description of what this command does.
arguments:
  input:
    description: Input parameter
    required: true
---

# Hello Command

Your command instructions here.

## Quick Start

1. Read input from `input` argument
2. Process it
3. Return result

## Example

Input: "test"
Output: "result"

## Key Notes

- Note any important constraints
- Specify error handling behavior
```

### Template 2: Multi-Command Plugin

For plugins with multiple related slash commands.

**Directory structure:**
```
my-plugin/
├── .claude-plugin/
│   └── plugin.json
├── commands/
│   ├── validate.md
│   ├── format.md
│   └── report.md
└── README.md
```

**`.claude-plugin/plugin.json`:**
```json
{
  "name": "code-processor",
  "description": "Process code with validate, format, and reporting. Use when checking code quality, formatting, or generating reports.",
  "version": "1.0.0",
  "author": {
    "name": "Your Name"
  },
  "repository": "https://github.com/user/code-processor"
}
```

### Template 3: Plugin with Agent Skills

For plugins with reusable Agent Skills.

**Directory structure:**
```
my-plugin/
├── .claude-plugin/
│   └── plugin.json
├── commands/
│   └── analyze.md
└── skills/
    ├── code-analysis/
    │   └── SKILL.md
    └── reporting/
        └── SKILL.md
```

**`.claude-plugin/plugin.json`:**
```json
{
  "name": "analyzer-plugin",
  "description": "Analyze code and generate reports. Use when evaluating code quality, finding issues, or generating analysis. Includes analyze command and reusable analysis Skills.",
  "version": "1.0.0"
}
```

**`skills/code-analysis/SKILL.md`:**
```markdown
---
name: code-analysis
description: Analyze code for issues, patterns, and quality metrics. Use when examining code structure, finding issues, or generating quality metrics.
allowed-tools: Read,Write
---

# Code Analysis Skill

Analyze source code and identify issues.

## Quick Start

1. Parse code
2. Check for issues (syntax, style, best practices)
3. Collect metrics (lines of code, complexity, etc.)
4. Return structured analysis

## Key Notes

- Independent skill (Claude uses automatically)
- Reusable across multiple commands
- Include specific issues found
```

### Template 4: Complex Plugin with Custom Agent

For plugins with complex workflows requiring a custom agent.

**Directory structure:**
```
my-plugin/
├── .claude-plugin/
│   └── plugin.json
├── commands/
│   └── orchestrate.md
├── agents/
│   └── workflow-engine.md
└── skills/
    ├── task-a/
    │   └── SKILL.md
    └── task-b/
        └── SKILL.md
```

**`.claude-plugin/plugin.json`:**
```json
{
  "name": "workflow-plugin",
  "description": "Execute multi-step workflows with custom orchestration. Use when running complex workflows that need planning, state management, and multiple steps. Includes workflow execution engine.",
  "version": "1.0.0"
}
```

**`agents/workflow-engine.md`:**
```markdown
---
description: Plan and execute complex multi-step workflows with state management and error recovery.
---

# Workflow Engine Agent

Custom agent for complex workflow orchestration.

## Capabilities

- Plan workflow execution
- Execute steps in order
- Manage state between steps
- Handle errors and recovery
- Track progress

## Context and examples

**When to use this agent:**
- Complex multi-step workflows needing coordination
- Tasks requiring state management between steps
- Workflows with error handling and recovery needs

**Not for:** Simple single-step operations (don't need agents)
```

### Template 5: Plugin with Hooks

For plugins that respond to events.

**Directory structure:**
```
my-plugin/
├── .claude-plugin/
│   └── plugin.json
├── commands/
│   ├── validate.md
│   └── format.md
├── hooks.json
└── README.md
```

**`.claude-plugin/plugin.json`:**
```json
{
  "name": "code-quality",
  "description": "Automatic code quality checks on save and pre-commit. Use when setting up quality gates.",
  "version": "1.0.0"
}
```

**`hooks.json`:**
```json
{
  "on-save": [
    {
      "name": "format",
      "args": {}
    }
  ],
  "on-commit": [
    {
      "name": "validate",
      "args": {}
    }
  ]
}
```

### Template 6: Project Conversion

For converting existing projects to plugins.

**Conversion steps:**

1. Create `.claude-plugin/` directory and `plugin.json`
2. Move slash commands to `commands/` directory
3. Move agents to `agents/` directory
4. Move Skills to `skills/` directory
5. Configure `hooks.json` if event handlers exist
6. Update component metadata (add YAML frontmatter)

**Before (project structure):**
```
my-project/
├── src/
│   └── commands/
│       └── validate.sh
├── agents/
│   └── analyzer.py
└── skills/
    └── reporting.md
```

**After (plugin structure):**
```
my-project/
├── .claude-plugin/
│   └── plugin.json
├── commands/
│   └── validate.md          # Converted from validate.sh
├── agents/
│   └── analyzer.md          # Converted from analyzer.py
└── skills/
    └── reporting/
        └── SKILL.md         # Already in correct format
```

---

## Customization Checklist

When using any template:

- [ ] Replace `my-plugin` with your plugin name (lowercase, hyphens)
- [ ] Update `description` with specific trigger phrases
- [ ] Update `author.name` with your name
- [ ] Replace placeholder command/agent/skill names
- [ ] Write actual instructions (replace placeholder text)
- [ ] Update `version` to start with "1.0.0"
- [ ] Test locally with `claude --plugin-dir /path/to/plugin`
- [ ] Validate plugin.json with `jq .`

---

## Quick Template Selection

| Use Case | Template |
|----------|----------|
| Single command | Template 1 |
| Multiple commands | Template 2 |
| Commands + reusable Skills | Template 3 |
| Complex workflows | Template 4 |
| Event-driven | Template 5 |
| Convert project | Template 6 |

---

## Summary

Good plugins:

1. **Clear architecture** - Directory structure follows conventions
2. **Discoverable** - Plugin name and description enable Claude to find them
3. **Token-efficient** - Minimal metadata, full content on-demand
4. **Focused components** - Each command/agent/skill has single responsibility
5. **Well-documented** - Inline instructions, examples, error handling
6. **Secure** - Tool scoping applies principle of least privilege
7. **Testable** - Works with real examples, multiple models
8. **Versioned** - Semantic versioning for team coordination
