# Packaging Subagents in Plugins

Subagents are isolated execution environments with custom prompts, tool access, and permissions. This guide covers packaging and organizing subagents within plugins.

**For creating subagents:** Use the `subagent-creator` skill instead. This guide covers plugin integration only.

## When to Include Subagents in Your Plugin

Add subagents to your plugin when:

- Your plugin needs isolated execution with custom tool restrictions (e.g., read-only database analyzer)
- You want deterministic tool access control (specific tools, not inherit-all)
- You need conditional permission modes (auto-accept, auto-deny, plan-only)
- You want specialized prompts for specific tasks without affecting Claude's main behavior

Examples:
- Database plugin includes `db-analyzer` subagent (read-only queries only)
- Security plugin includes `vulnerability-scanner` subagent (specific tools, strict permissions)
- Code review plugin includes `code-reviewer` subagent (focused prompt, review tools only)

## Plugin Structure with Subagents

```
my-plugin/
├── .claude-plugin/
│   └── plugin.json
├── commands/
│   ├── analyze.md
│   └── generate.md
├── agents/
│   ├── db-analyzer.md
│   └── security-scanner.md
└── README.md
```

**Key points:**
- Subagents go in `agents/` directory as `.md` files
- Each file contains YAML frontmatter (configuration) + system prompt (body)
- Naming: lowercase-hyphen, ≤64 chars (e.g., `db-analyzer.md`)
- Claude discovers subagents automatically from plugin's `agents/` directory

## Subagent Frontmatter Requirements

For subagents included in plugins, the frontmatter must include:

### Required Fields
- **`name`** — Unique identifier (lowercase-hyphen, ≤64 chars)
  ```yaml
  name: db-analyzer
  ```

- **`description`** — Claude's delegation signal (≤1024 chars, include trigger phrases)
  ```yaml
  description: >-
    Execute read-only database queries. Use when analyzing data, generating
    reports, or exploring structure. SELECT only; write operations blocked.
  ```

### Optional Configuration Fields
- **`model`** — Execution model (sonnet, opus, haiku, or inherit from parent)
  ```yaml
  model: sonnet
  ```

- **`tools`** — Allowlist of tools (default: inherit all from parent)
  ```yaml
  tools: Bash, Read, Write
  ```

- **`permissionMode`** — Permission handling (default, acceptEdits, dontAsk, bypassPermissions, plan)
  ```yaml
  permissionMode: dontAsk
  ```

- **`hooks`** — Validation/lifecycle handlers (PreToolUse, PostToolUse, SubagentStart, SubagentStop)
  ```yaml
  hooks:
    - type: PreToolUse
      script: validate-query.sh
  ```

## Example Subagent File

```yaml
---
name: db-analyzer
description: >-
  Execute read-only database queries to analyze data. Use when exploring
  databases, generating reports, or analyzing data patterns. Supports
  SELECT queries only; write operations blocked.
model: sonnet
tools: Bash, Read, Write
permissionMode: dontAsk
---

You are a database analyst with read-only access. Your role is to:

1. Execute SELECT queries only (no INSERT, UPDATE, DELETE, DROP)
2. Analyze database structure and data patterns
3. Generate reports based on data exploration
4. Suggest optimization opportunities without modifying data

When Claude delegates database analysis tasks to you, you become the
specialized execution environment with tool restrictions enforced.
```

## Organizing Multiple Subagents

For plugins with multiple subagents:

```
my-plugin/
├── agents/
│   ├── db-analyzer.md           # Read-only DB access
│   ├── code-reviewer.md         # Review tools only
│   ├── security-scanner.md      # Security-specific tools
│   └── report-generator.md      # Report generation
└── ...
```

**Best practices:**
- One subagent per file (no nesting)
- Clear, specific descriptions for each
- Non-overlapping tool scopes (avoid confusion about which to delegate to)
- Document purpose in plugin README

## Delegation from Commands

Slash commands can invoke subagents implicitly through Claude's description matching. Example:

Command file (`commands/analyze.md`):
```yaml
---
name: analyze
description: Analyze data using subagents
---

When user requests data analysis, Claude will:
1. Recognize the request matches `db-analyzer` subagent description
2. Automatically delegate to db-analyzer subagent
3. Execute analysis with read-only tool restrictions
```

The command doesn't explicitly invoke the subagent; Claude's description matching handles delegation.

## Version Management

Subagents in plugins follow independent versioning:
- **Subagent version** (in frontmatter): Track subagent changes only
- **Plugin version**: Bump PATCH/MINOR/MAJOR based on all bundled components

See your plugin's CLAUDE.md for versioning rules.

## Testing Subagents in Plugins

Before distributing, test locally:

```bash
# Install plugin locally
claude plugin install /path/to/my-plugin --scope local

# Test delegation - make requests that should trigger subagents
# Example: "Analyze the sales table to generate a monthly report"
# Should delegate to db-analyzer subagent with read-only restrictions
```

Check:
- Does Claude recognize the subagent's trigger phrases?
- Does it delegate correctly for matching requests?
- Can it complete tasks with the allowed tools?
- Do permission modes work as expected?

## Reference: Subagent Best Practices

For complete guidance on creating and validating subagents, see:
- `subagent-creator` skill in your toolkit
- Subagent validation workflow in subagent-creator documentation
- Tool scoping and permission mode patterns

Key principle: Subagents are execution FOR CLAUDE with custom isolation, not documentation FOR PEOPLE. Description clarity determines reliable delegation.
