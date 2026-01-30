# Packaging Components in Plugins

Plugins can bundle Agent Skills, Subagents, and Hooks as reusable components. This guide covers packaging, organizing, and using each component type within plugins.

**For component creation:**
- **Creating Skills:** Use the `skill-creator` skill
- **Creating Subagents:** Use the `subagent-creator` skill
- **Creating Hooks:** Use the `hook-creator` skill

This guide covers integration into plugins only.

---

## Agent Skills in Plugins

### When to Include Skills

Add Skills to your plugin when:

- Your plugin provides capabilities Claude should use automatically (not just explicit commands)
- You have domain-specific knowledge Claude should apply (code review patterns, security analysis, optimization strategies)
- You want optional enhancements Claude uses when relevant (testing strategies, documentation generation)

Examples:
- Code review plugin includes code-review Skill
- Security plugin includes vulnerability-detection Skill
- Testing plugin includes test-strategy Skill

### Plugin Structure with Skills

```
my-plugin/
├── .claude-plugin/
│   └── plugin.json
├── commands/
│   ├── analyze.md
│   └── generate.md
├── skills/
│   ├── skill-one/
│   │   ├── SKILL.md
│   │   └── references/
│   │       └── detailed-guide.md
│   └── skill-two/
│       └── SKILL.md
└── README.md
```

**Key points:**
- Skills go in `skills/` directory
- Each skill is a subdirectory with `SKILL.md`
- Optional `references/` for detailed content (one level deep)
- Skill names match directory names (lowercase with hyphens)

### Skill Packaging Requirements

#### Frontmatter Metadata

Required fields in each `SKILL.md`:

```yaml
---
name: skill-name
description: >-
  What the skill does. Use when [trigger context].
  [Specific domain/scope].
allowed-tools: Read,Grep
---
```

- `name` - Matches directory name (lowercase, hyphens)
- `description` - Tells Claude when to use the skill (must include trigger phrases)
- `allowed-tools` - Principle of least privilege (only necessary tools)

#### SKILL.md Body Structure

Keep body <500 lines (loaded when skill triggers):

```markdown
# Skill Name

## Quick Start

[Essentials only - what Claude needs to execute immediately]

## Workflow

[Step-by-step how Claude executes the task]

## Output Format

[What user gets as result]

## References

See `references/` for detailed content
```

#### References Organization

Move detailed content to `references/`:

```
skills/code-review/
├── SKILL.md                    # ~200 lines (quick start + workflow)
└── references/
    ├── checklist.md            # Detailed review checklist
    └── patterns.md             # Code pattern examples
```

References are one level deep (no nested subdirectories).

### Organizing Multiple Skills

If plugin includes several skills:

```
skills/
├── code-analysis/
│   ├── SKILL.md
│   └── references/
│       └── analysis-patterns.md
├── security-review/
│   ├── SKILL.md
│   └── references/
│       └── vulnerability-checklist.md
└── performance-tuning/
    └── SKILL.md
```

**Guidelines:**
- Keep skills focused (each does one thing well)
- Use clear, distinct names
- No overlap in activation triggers
- Each skill <500 lines

### Skill Activation

Claude discovers skills via:

1. **Plugin manifest** - Loads `plugin.json` name and description
2. **Skill metadata** - Reads SKILL.md frontmatter (name, description)
3. **Trigger phrases** - Activates based on description keywords

**Example activation:**

User: "Review this code for security issues"
↓
Claude matches against skill descriptions
↓
Finds security-review skill with description mentioning "security"
↓
Skill activates automatically

### Testing and Publishing Skills

**Test locally:**
```bash
claude --plugin-dir /path/to/my-plugin
```

**Test workflow:**
1. Trigger skill naturally - Use Claude in a way that activates the skill
2. Verify activation - Check that Claude uses the skill (output format, methodology)
3. Test edge cases - Empty/invalid input, different contexts, large inputs

**Document in README:**
```markdown
## Included Skills

This plugin includes Agent Skills that Claude uses automatically:

### Code Review Skill
Claude automatically reviews code for bugs and best practices when you share code or discuss pull requests.
**Activation:** Share code, discuss PR reviews, analyze code quality

### Security Analysis Skill
Claude analyzes code for security vulnerabilities when you discuss sensitive operations.
**Activation:** Code involving authentication, database access, external APIs
```

**Before Publishing:**
- [ ] Skill description clearly indicates when to use
- [ ] Skill body <500 lines
- [ ] References are organized and linked from SKILL.md
- [ ] Tool scoping is appropriate (only necessary tools)
- [ ] Skill tested with `--plugin-dir`
- [ ] Skill works with both Haiku and Opus models
- [ ] No overlap with other plugin skills

---

## Subagents in Plugins

### When to Include Subagents

Add subagents to your plugin when:

- Your plugin needs isolated execution with custom tool restrictions (e.g., read-only database analyzer)
- You want deterministic tool access control (specific tools, not inherit-all)
- You need conditional permission modes (auto-accept, auto-deny, plan-only)
- You want specialized prompts for specific tasks without affecting Claude's main behavior

Examples:
- Database plugin includes `db-analyzer` subagent (read-only queries only)
- Security plugin includes `vulnerability-scanner` subagent (specific tools, strict permissions)
- Code review plugin includes `code-reviewer` subagent (focused prompt, review tools only)

### Plugin Structure with Subagents

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

### Subagent Frontmatter Requirements

For subagents included in plugins, the frontmatter must include:

**Required fields:**
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

**Optional configuration fields:**
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

### Example Subagent File

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

### Organizing Multiple Subagents

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

### Delegation from Commands

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

### Testing Subagents

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

---

## Hooks in Plugins

### When to Include Hooks

Add hooks to your plugin when:

- Your plugin should react to Claude Code events automatically (tool use, prompts, sessions)
- You want automatic validation or formatting before/after actions
- You need to audit or verify Claude's operations
- You want to manage plugin state or coordination between components

Examples:
- Format plugin hooks after Write/Edit to validate code style
- Validation plugin hooks before deployment commands to check requirements
- Analytics plugin hooks to track tool usage across session
- Automation plugin hooks to coordinate between multiple subagents

### Plugin Structure with Hooks

```
my-plugin/
├── .claude-plugin/
│   └── plugin.json
├── hooks.json                    # Optional: Event handlers (or inline in plugin.json)
├── scripts/
│   ├── validate.sh
│   └── format.sh
└── commands/
    └── deploy.md
```

**Key points:**
- Hooks defined in `hooks.json` (or inline in `.claude-plugin/plugin.json`)
- Hook scripts go in `scripts/` directory
- Use `${CLAUDE_PLUGIN_ROOT}` for relative paths to plugin files
- Claude Code auto-loads hook configuration on plugin startup

### Hook Configuration

Hooks can be defined in `hooks.json`:

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "^(Write|Edit)$",
        "hooks": [
          {
            "type": "command",
            "command": "${CLAUDE_PLUGIN_ROOT}/scripts/format.sh",
            "timeout": 3000,
            "onError": "warn"
          }
        ]
      }
    ],
    "UserPromptSubmit": [
      {
        "matcher": "deploy|release",
        "hooks": [
          {
            "type": "agent",
            "agent": "deployment-validator",
            "timeout": 5000,
            "onError": "fail"
          }
        ]
      }
    ]
  }
}
```

Or inline in `plugin.json`:

```json
{
  "name": "my-plugin",
  "description": "...",
  "hooks": {
    "PostToolUse": [...]
  }
}
```

### Hook Types

**Command hooks** — Run shell scripts
- Fastest option for validation, formatting, state management
- Use for non-blocking operations
- Example: Run formatter after file write

**Prompt hooks** — Ask LLM to make decisions
- For decisions requiring language understanding
- Adds latency (LLM call)
- Example: Review changes before deployment

**Agent hooks** — Delegate to specialized agent
- For complex verification requiring multiple tools
- Can run asynchronously
- Example: Security scanning before release

### Hook Best Practices

- **Event selection:** Choose event that provides needed data (Pre vs Post, which event)
- **Matcher precision:** Specific enough to avoid false triggers, broad enough to catch cases
- **Error handling:** Set `onError` behavior (warn/fail/continue) appropriately
- **Performance:** Keep sync hooks <1s. Use async for longer operations
- **Naming:** Describe hook by action + event: `format-on-write`, `validate-before-deploy`
- **Documentation:** Comment matcher logic and expected behavior in hooks.json
- **Testing:** Test hooks with real plugin workflows before deployment

### Workflow: Adding Hooks

1. **Determine need** — What event should trigger? What should happen?
2. **Create hook scripts** — Write validation/formatting/coordination scripts in `scripts/`
3. **Use hook-creator skill** — Build and validate hook configuration
4. **Add to plugin** — Place `hooks.json` in plugin root (or inline in `.claude-plugin/plugin.json`)
5. **Test locally** — `claude --plugin-dir /path/to/plugin` and verify hooks trigger
6. **Validate** — Run `claude plugin validate .` to check structure

For detailed hook creation and validation workflows, use the `hook-creator` skill.

---

## Component Comparison

| Use | Component | Why |
|-----|-----------|-----|
| Auto-invoked on context | Agent Skill | Claude decides when to use |
| Isolated execution with custom tools | Subagent | Custom tool restrictions and permissions |
| Automatic event reactions | Hook | Respond to Claude Code events |
| Explicit user invocation | Slash command | User controls activation |

---

## Version Management

Each component type tracks versions independently:
- **Skill version** (in SKILL.md frontmatter): Track skill changes
- **Subagent version** (in agents/*.md frontmatter): Track subagent changes
- **Hook version** (via git tags or plugin version): Track hook changes
- **Plugin version** (in plugin.json): Bump based on all bundled components

See your plugin's CLAUDE.md for versioning rules.

# Consolidation Note
This file consolidates agent-skills.md, subagents-in-plugins.md, and hooks-in-plugins.md from refinement pass 2.

---

## Advanced Reference

This consolidated guide combines:
- Agent Skills in Plugins (from agent-skills.md)
- Subagents in Plugins (from subagents-in-plugins.md)
- Hooks in Plugins (from hooks-in-plugins.md)

All three components are fully documented in their respective sections above.
