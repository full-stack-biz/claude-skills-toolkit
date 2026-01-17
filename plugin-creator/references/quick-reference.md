# Plugin Creator Quick Reference

Fast lookup for common plugin creation tasks.

## Directory Structure Template

```
my-plugin/
├── .claude-plugin/
│   └── plugin.json                    # Required: metadata manifest
├── commands/                          # Optional: slash commands
│   ├── command1.md
│   └── command2.md
├── agents/                            # Optional: custom agents
│   ├── agent-name.md
│   └── another-agent.md
├── skills/                            # Optional: agent skills
│   └── skill-name/
│       ├── SKILL.md
│       └── references/
│           └── guide.md
├── hooks.json                         # Optional: event handlers
├── .mcp.json                          # Optional: MCP servers
└── README.md                          # Recommended: documentation
```

## plugin.json Template

```json
{
  "name": "my-plugin",
  "description": "What it does. Use when [trigger contexts]. [Components].",
  "version": "1.0.0",
  "author": {
    "name": "Your Name"
  }
}
```

**Fields:**
- `name` (required): lowercase-hyphen, 1-64 chars, no spaces
- `description` (highly recommended): 1-1024 chars, include trigger phrases for activation
- `version` (optional): semantic versioning (e.g., "1.0.0")
- `author` (optional): {name, email, url}
- `homepage`, `repository`, `license` (optional): URLs and identifiers

## Slash Command Template

File: `commands/command-name.md`

```markdown
---
name: command-name
description: What Claude does when user runs this command
arguments:
  param-name:
    description: What this parameter is
    required: true
---

# Command Name

Your command instructions here.

## Quick Start

Step-by-step instructions.

## Examples

Concrete examples Claude can reference.

## Key Notes

Important constraints and edge cases.
```

## Naming Conventions Quick Check

| Item | Format | Example | Bad Example |
|------|--------|---------|-------------|
| Plugin name | lowercase-hyphen | `code-reviewer` | `CodeReviewer`, `code reviewer` |
| Command name | lowercase-hyphen | `validate` | `Validate`, `VALIDATE` |
| Directory | lowercase-hyphen | `agent-name/` | `AgentName/`, `agent_name/` |
| Skill name | lowercase-hyphen | `code-analysis` | `Code Analysis` |

## Plugin Description Formula

```
[Action/capability]. Use when [trigger contexts]. [Components/scope].
```

**Components to mention:**
- `validate`, `format`, `analyze` commands
- Custom agent workflows
- Reusable skills
- Hook integration
- File support/formats

## Quick Checklist Before Deployment

- [ ] plugin.json exists in `.claude-plugin/` directory
- [ ] plugin.json is valid JSON (`jq . plugin.json` passes)
- [ ] `name` field: lowercase, hyphens, no spaces, 1-64 chars
- [ ] `description` field: includes trigger phrases
- [ ] Commands in `commands/` directory as `.md` files
- [ ] Each command has YAML frontmatter with `name`, `description`, `arguments`
- [ ] Command instructions are clear and include examples
- [ ] Agents (if present) are `.md` files in `agents/` directory
- [ ] Skills (if present) have `SKILL.md` with proper frontmatter
- [ ] Tested locally: `claude --plugin-dir /path/to/plugin /plugin-name:command`
- [ ] No Bash tool in allowed-tools (unless explicitly needed)

## Common Plugin Patterns

| Pattern | Use Case | Files |
|---------|----------|-------|
| Single command | Simple one-function plugin | `plugin.json` + `commands/cmd.md` |
| Multi-command | Related commands grouped | `plugin.json` + `commands/*.md` |
| Commands + Skills | Reusable capabilities | Above + `skills/*/SKILL.md` |
| Complex workflow | Multi-step coordination | Above + `agents/*.md` |
| Event-driven | Automatic on events | Above + `hooks.json` |

## Activation Signals for Claude

Claude activates plugins based on:

1. **Plugin description matches request:**
   - Plugin desc: "Review code for best practices. Use when validating PRs..."
   - User: "please review this code"
   - Result: ✓ Plugin activated

2. **Command description matches request:**
   - Command desc: "Validate code against rules"
   - User: "/my-plugin:validate"
   - Result: ✓ Command executed

3. **Trigger phrases in description:**
   - Generic: "Do code stuff" → ✗ Rarely activates
   - Specific: "Use when validating pull requests or analyzing code quality" → ✓ Reliably activates

## Common Errors & Fixes

| Error | Cause | Fix |
|-------|-------|-----|
| Plugin not found | plugin.json missing | Create `.claude-plugin/plugin.json` |
| Invalid JSON | Syntax error | Validate with `jq .` |
| Commands not working | Wrong directory or naming | Use `commands/` + lowercase + `.md` |
| Plugin won't activate | Vague description | Add specific trigger phrases |
| Argument errors | Missing metadata | Add `arguments:` with `description` + `required` |

## File Size Guidelines

| Component | Max Size | Goal |
|-----------|----------|------|
| plugin.json | <1KB | <500 bytes (minimal) |
| Command file | <200 lines | 50-100 lines (Quick Start + examples) |
| SKILL.md body | <500 lines | 200-300 lines (token efficiency) |
| Reference file | Unlimited | Keep separate from body |
| Plugin total | <10MB | Self-contained, no external deps |

## Deployment Paths

**Global (all projects):**
```bash
~/.claude/skills/my-plugin/
```

**Project-local (this project only):**
```bash
./.claude/skills/my-plugin/
```

**Both use same directory structure.**

## Testing Commands

```bash
# Test plugin directory structure
ls -R /path/to/plugin

# Validate plugin.json
jq . /path/to/plugin/.claude-plugin/plugin.json

# Test command locally
claude --plugin-dir /path/to/plugin /plugin-name:command

# List all plugin commands
ls /path/to/plugin/commands/

# Validate command metadata
grep -A 5 "^name:" /path/to/plugin/commands/*.md
```

## Reference Files to Use

- **Creating new plugin?** → See `plugin-templates.md`
- **Validating existing?** → Use `validation-checklist.md`
- **Confused about structure?** → Check `how-plugins-work.md`
- **plugin.json questions?** → Read `plugin-json-schema.md`
- **Command format help?** → See `slash-command-format.md`
- **Best practices?** → Review `best-practices.md`

## Key Rules

1. **Manifest name**: lowercase-hyphen, no "anthropic"/"claude"
2. **Description**: Must include specific trigger phrases
3. **Commands**: In `commands/` as `.md` files
4. **Quick Start**: 80% of tasks should work from Quick Start
5. **Directory depth**: One level deep (no nested chains)
6. **Tool scoping**: Only necessary tools (principle of least privilege)
7. **Testing**: Test locally before sharing
8. **Documentation**: Include examples and error handling

## Syntax Quick Tips

**YAML frontmatter (required):**
```yaml
---
name: lowercase-name
description: Description text
arguments:
  param:
    description: Param description
    required: true
---
```

**JSON (plugin.json):**
```json
{
  "name": "lowercase-name",
  "description": "Description text",
  "version": "1.0.0"
}
```

**Markdown (commands, agents, skills):**
```markdown
# Heading

Paragraph text.

## Subheading

More text with examples.
```

## When to Use Tools in Skill

| Task | Tool | Reason |
|------|------|--------|
| Create plugin files | `Write` | Generate plugin.json, command templates |
| Edit plugin files | `Edit` | Modify existing manifest or commands |
| Read plugin structure | `Read` | Understand plugin organization |
| Search files | `Glob` | Find plugin components |
| Ask user questions | `AskUserQuestion` | Gather requirements |

**NOT allowed:** `Bash` (git operations reserved for user)
