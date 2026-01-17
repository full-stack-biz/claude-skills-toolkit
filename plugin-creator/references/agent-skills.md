# Packaging Agent Skills in Plugins

Agent Skills are model-invoked capabilities Claude uses automatically. This guide covers packaging and organizing Skills within plugins.

**For creating Skills:** Use the `skill-creator` skill instead. This guide covers plugin integration only.

## When to Include Skills in Your Plugin

Add Skills to your plugin when:

- Your plugin provides capabilities Claude should use automatically (not just explicit commands)
- You have domain-specific knowledge Claude should apply (code review patterns, security analysis, optimization strategies)
- You want optional enhancements Claude uses when relevant (testing strategies, documentation generation)

Examples:
- Code review plugin includes code-review Skill
- Security plugin includes vulnerability-detection Skill
- Testing plugin includes test-strategy Skill

## Plugin Structure with Skills

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

## Skill Packaging Requirements

For Skills included in plugins:

### 1. Frontmatter Metadata

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

### 2. SKILL.md Body Structure

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

### 3. References Organization

Move detailed content to `references/`:

```
skills/code-review/
├── SKILL.md                    # ~200 lines (quick start + workflow)
└── references/
    ├── checklist.md            # Detailed review checklist
    └── patterns.md             # Code pattern examples
```

References are one level deep (no nested subdirectories).

## Organizing Multiple Skills

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

## Skill Activation in Plugins

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

## Testing Skills in Plugins

Test locally with `--plugin-dir`:

```bash
claude --plugin-dir /path/to/my-plugin
```

**Test workflow:**

1. **Trigger skill naturally** - Use Claude in a way that activates the skill
2. **Verify activation** - Check that Claude uses the skill (output format, methodology)
3. **Test edge cases:**
   - Empty/invalid input (how does skill handle?)
   - Different contexts (does skill activate when needed?)
   - Large inputs (is output coherent?)

## Publishing Plugin with Skills

### Document in README

```markdown
## Included Skills

This plugin includes Agent Skills that Claude uses automatically:

### Code Review Skill
Claude automatically reviews code for bugs and best practices when you share code
or discuss pull requests.

**Activation:** Share code, discuss PR reviews, analyze code quality

### Security Analysis Skill
Claude analyzes code for security vulnerabilities when you discuss sensitive operations.

**Activation:** Code involving authentication, database access, external APIs
```

### Version Tracking

Update `version` in `plugin.json` when adding/changing skills:

```json
{
  "name": "my-plugin",
  "version": "1.1.0"
}
```

- `1.0.0 → 1.1.0` - Added new skill
- `1.0.0 → 1.0.1` - Fixed skill behavior
- `1.0.0 → 2.0.0` - Removed/changed skill significantly

### Before Publishing

- [ ] Skill description clearly indicates when to use
- [ ] Skill body <500 lines
- [ ] References are organized and linked from SKILL.md
- [ ] Tool scoping is appropriate (only necessary tools)
- [ ] Skill tested with `--plugin-dir`
- [ ] Skill works with both Haiku and Opus models
- [ ] No overlap with other plugin skills

## Common Packaging Issues

| Problem | Cause | Fix |
|---------|-------|-----|
| Skill won't activate | Description too vague | Add specific trigger phrases |
| Skill activates too much | Description too broad | Narrow scope, be explicit |
| Skill not found | Wrong directory name | Ensure `skills/skill-name/SKILL.md` exists |
| Tool permission error | Tool not declared | Add to `allowed-tools` in frontmatter |
| Large initial load | References too big in body | Move to `references/` files |

## Skill vs. Command

| Use | Component | Why |
|-----|-----------|-----|
| Auto-invoked on context | Agent Skill | Claude decides when to use |
| Explicit user invocation | Slash command | User controls activation |
| Both optional | Include both | Skills auto-invoke, commands for explicit use |

## See Also

- [skill-creator](about:/claude/code/skill-creator) - Create and validate Agent Skills
- [Agent Skills Documentation](about:/docs/en/skills) - Official Skill specs
- [Slash Commands](about:/docs/en/slash-commands) - Create user-invoked commands
