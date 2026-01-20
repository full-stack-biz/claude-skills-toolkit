# How Claude Code Plugins Work

Understanding plugin architecture helps you create effective plugins.

## Table of Contents

- [Plugin Discovery & Activation](#plugin-discovery--activation)
- [Token Loading Hierarchy](#token-loading-hierarchy)
- [Plugin vs Standalone Configuration](#plugin-vs-standalone-configuration)
- [Skills (User-Invoked)](#skills-user-invoked)
- [Custom Agents](#custom-agents)
- [Agent Skills](#agent-skills)
- [Hooks & Event Handlers](#hooks--event-handlers)
- [MCP Servers & External Services](#mcp-servers--external-services)
- [Performance Considerations](#performance-considerations)
- [Security Model](#security-model)
- [Deployment & Distribution](#deployment--distribution)
- [Debugging & Troubleshooting](#debugging--troubleshooting)
- [Summary](#summary)

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

## Skills (User-Invoked)

Skills handle both automatic activation AND user invocation via `/` slash commands. This unified approach replaces the old separate "commands" system.

### User Invocation Flow

1. **User types:** `/plugin-name:skill-name` or just `/skill-name`
2. **Claude Code loads:** Skill frontmatter and body
3. **Claude executes:** Follows instructions in SKILL.md body
4. **Return output:** Displays results to user

### Skill Invocation Control

Skills use frontmatter to control who can invoke them:

```yaml
---
name: my-skill
description: What this skill does. Use when [trigger context].
disable-model-invocation: false  # Claude can auto-invoke
user-invocable: true             # User can invoke with /
---
```

**Three invocation modes:**
- **Default** (both enabled) - Claude auto-activates + user can invoke with `/`
- `disable-model-invocation: true` - Only user can invoke (for side-effect operations)
- `user-invocable: false` - Only Claude can invoke (for background knowledge)

### User Invocation Examples

```
/plugin-name:skill-name
/my-validator
/code-reviewer:analyze
```

### Argument Passing

Use `$ARGUMENTS` in skill body to receive arguments:

```yaml
---
name: validate-code
description: Validate code for best practices
argument-hint: "[code]"
---

Validate the following code against best practices:

$ARGUMENTS
```

User can invoke:
```
/validate-code function foo() { ... }
```

## Custom Agents

### When Agents Are Used

Agents are invoked for:
- **Complex workflows** (multiple steps requiring planning)
- **State management** (maintaining context across steps)
- **Error recovery** (handling failures and retrying)
- **Decision making** (choosing between paths based on intermediate results)

### Agent Model

Agents follow this pattern:
1. **Plan:** Understand task and devise execution strategy
2. **Execute:** Perform steps in sequence
3. **Adapt:** Adjust based on intermediate results
4. **Report:** Return complete results

### Agent Lifecycle

```
User Request
    ↓
Agent Activated
    ↓
Agent Plans Execution
    ↓
Agent Executes Steps (may delegate to Skills)
    ↓
Agent Returns Results
```

Agents can invoke Skills to execute specific tasks while maintaining overall workflow state.

## Agent Skills

### Skill Activation

Skills are **model-invoked** (automatic), not **user-invoked** (manual).

**How it works:**
1. Claude evaluates task context
2. Reads skill descriptions in index
3. Determines which Skills are relevant
4. Automatically invokes appropriate Skills
5. Uses skill output in task completion

**Example:**
- Task: "Generate a report"
- Available Skills: `code-analysis`, `reporting`, `formatting`
- Claude: Recognizes report generation needs analysis + formatting
- Action: Invokes code-analysis Skill → reporting Skill
- Result: Complete report

### Skill Token Efficiency

Skills are optimized for token efficiency:

**Metadata (always loaded):**
```yaml
name: skill-name
description: Use when [trigger context]
```

**Body (loaded on invocation):** <500 lines
- Quick Start section
- Procedural instructions
- Key examples

**References (loaded on-demand):** Unlimited
- Detailed guides
- Comprehensive documentation
- Code examples Claude may need

## Hooks & Event Handlers

### Hook Model

Hooks respond to events and trigger commands:

```json
{
  "on-save": [
    {"name": "validate", "args": {}}
  ],
  "on-commit": [
    {"name": "format", "args": {}}
  ]
}
```

**Event flow:**
1. Event occurs (on-save, on-commit)
2. Claude Code checks hooks.json
3. Invokes associated commands
4. Returns results

### Common Events

- `on-save`: File saved
- `on-commit`: Before git commit
- `on-test`: Before running tests
- `on-deploy`: Before deployment
- Custom events as needed

## MCP Servers & External Services

### MCP Integration

MCP (Model Context Protocol) servers extend Claude's capabilities to external systems:

```json
{
  "mcpServers": {
    "database": {
      "command": "python",
      "args": ["-m", "mcp_database_server"]
    }
  }
}
```

**Use cases:**
- Database access
- API integration
- File system operations
- External service calls

### Architecture

```
Plugin
    ↓
Claude Code
    ↓
MCP Server (database, API, filesystem, etc.)
    ↓
External Service
```

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

## Deployment & Distribution

### Installation Locations

**Global (available everywhere):**
```
~/.claude/skills/my-plugin/
├── .claude-plugin/plugin.json
├── commands/...
└── ...
```

**Project-local (project-specific):**
```
my-project/.claude/skills/my-plugin/
├── .claude-plugin/plugin.json
├── commands/...
└── ...
```

### Plugin Marketplace

Published plugins:
- Listed in plugin manager with metadata
- Searchable by name, keywords, description
- Easy install via `claude plugin install`
- Version tracking for updates

### Version Tracking

Semantic versioning helps with updates:
- **1.0.0**: Initial release
- **1.0.1**: Bug fix (patch)
- **1.1.0**: New feature (minor)
- **2.0.0**: Breaking change (major)

## Debugging & Troubleshooting

### Common Issues

| Issue | Cause | Solution |
|-------|-------|----------|
| Plugin not discovered | plugin.json missing/invalid JSON | Validate with `jq .` |
| Commands not activated | Vague description, no trigger phrases | Update description with specific triggers |
| Plugin won't load | Directory structure error | Verify `.claude-plugin/plugin.json` exists |
| Commands fail | Incorrect metadata or body | Check command YAML syntax and instructions |
| Hooks not firing | hooks.json syntax error or wrong event | Validate hooks.json and event names |

### Testing Locally

```bash
# Test plugin without installing
claude --plugin-dir /path/to/plugin /plugin-name:command

# This loads plugin from specified directory for testing
```

## Summary

Plugins work by:

1. **Discovery:** Claude scans directories, reads manifest
2. **Activation:** Matches plugin description to user context
3. **Loading:** Loads component metadata on-demand
4. **Execution:** Runs component instructions
5. **Output:** Returns results to user

**Key principles:**
- Metadata always loaded (small, concise)
- Full content loaded on execution (detailed, comprehensive)
- References loaded on-demand (zero penalty until needed)
- Namespacing prevents conflicts
- Permissions limit tool access (least privilege)
