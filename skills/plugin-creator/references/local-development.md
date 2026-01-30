# Local Development & Testing

Guide for testing plugins during development using `--plugin-dir`.

## Quick Start

Load your plugin directly from source without installing:

```bash
claude --plugin-dir /path/to/my-plugin
```

When you modify files, restart Claude Code to pick up changes.

## Testing Workflow

1. **Make changes** to plugin files (skills, hooks, manifest, etc.)
2. **Restart Claude Code** - All changes require restart to take effect
3. **Test components:**

### Test Skills

Invoke with slash command or by describing relevant task:

```bash
/plugin-name:skill-name
```

Example:
```bash
/my-plugin:code-review
```

Or let Claude activate automatically based on skill description.

### Test Hooks

Hooks execute automatically on configured events. Test by:

1. **PreToolUse hooks** - Trigger by using Write/Edit tools
2. **PostToolUse hooks** - Check output after tool execution completes
3. **Async hooks** - Verify cleanup/logging happens in background

Example hook testing:
```bash
# Edit a file to trigger PreToolUse hook
# (should create backup if backup hook is configured)
```

### Test Agents

Check `/agents` to see available subagents:

```bash
/agents
```

Or describe a task and let Claude invoke subagents automatically.

### Test Multiple Plugins

Load multiple plugins simultaneously:

```bash
claude --plugin-dir ./plugin-one --plugin-dir ./plugin-two
```

## ⚠️ Critical: Hook File Location

**Most common hook mistake:** Placing `hooks.json` in wrong location.

✅ **CORRECT:** `hooks/hooks.json` at plugin root
```
my-plugin/
├── .claude-plugin/
│   └── plugin.json
├── hooks/
│   └── hooks.json      ← CORRECT location
└── skills/
```

❌ **WRONG:** `.claude-plugin/hooks.json`
- Only `plugin.json` belongs in `.claude-plugin/`
- Hooks must be in `hooks/hooks.json`

If hooks aren't firing, verify file location first.

## Debugging

### Skill Not Appearing

**Problem:** Skill command not recognized or doesn't activate automatically

**Checklist:**
- [ ] File exists: `skills/skill-name/SKILL.md`
- [ ] Frontmatter present: `name` and `description` fields
- [ ] `description` includes trigger phrases Claude recognizes
- [ ] Restarted Claude Code
- [ ] Plugin loads: `claude --plugin-dir /path` shows no errors

**Test:**
```bash
/plugin-name:skill-name
```

### Hook Not Firing

**Problem:** Hook doesn't execute on expected events

**Checklist:**
- [ ] File location correct: `hooks/hooks.json` (not `.claude-plugin/hooks.json`)
- [ ] JSON syntax valid: `cat hooks/hooks.json | jq .`
- [ ] Event name correct (case-sensitive): `PreToolUse`, `PostToolUse`, `SessionEnd`, etc.
- [ ] Matcher pattern valid regex: `^(Write|Edit)$` for precise matching
- [ ] Script path uses `${CLAUDE_PLUGIN_ROOT}` variable
- [ ] Restarted Claude Code

**Test script manually:**
```bash
chmod +x scripts/my-script.sh
./scripts/my-script.sh
```

### Script Execution Error

**Problem:** Hook script runs but fails or produces unexpected output

**Checklist:**
- [ ] Script is executable: `chmod +x scripts/my-script.sh`
- [ ] Shebang line present: `#!/bin/bash`
- [ ] Uses correct variable: `${CLAUDE_PLUGIN_ROOT}` (not hardcoded paths)
- [ ] Exit codes correct:
  - `0` = success
  - `1` = non-blocking error
  - `2` = blocking error (shown to Claude)
- [ ] Script validated with shellcheck: `shellcheck scripts/my-script.sh`

**Test manually:**
```bash
export CLAUDE_PLUGIN_ROOT=/path/to/plugin
./scripts/my-script.sh /path/to/test/file.md
```

### Manifest Validation Error

**Problem:** `plugin.json` has syntax or schema errors

**Checklist:**
- [ ] JSON syntax valid: `cat .claude-plugin/plugin.json | jq .`
- [ ] Required fields present: `name`, `version`, `description`
- [ ] All paths are relative: `./skills/`, `./hooks/hooks.json`
- [ ] Version follows semantic versioning: `1.0.0`

**Validate:**
```bash
cat .claude-plugin/plugin.json | jq .
```

## Performance Considerations

**PreToolUse hooks** (execute before every tool):
- Keep fast: <100ms target
- Use for validation/blocking only
- Avoid expensive operations

**PostToolUse hooks** (execute after every tool):
- Runs very frequently - optimize if needed
- Good for formatting, linting
- Async recommended for slow operations

**Async hooks** (`async: true`):
- Run in background - don't block Claude
- Use for cleanup, logging, notifications
- Won't block plugin execution

**Matcher patterns**:
- Be specific: `^(Write|Edit)$` not `.*`
- Overly broad matchers = performance impact
- Test regex against expected inputs

## Common Plugin Structures

### Minimal Plugin (Just Skills)

```
my-plugin/
├── .claude-plugin/
│   └── plugin.json
└── skills/
    └── my-skill/
        └── SKILL.md
```

### Complete Plugin (Skills + Hooks + Agents)

```
my-plugin/
├── .claude-plugin/
│   └── plugin.json
├── skills/
│   └── code-review/
│       ├── SKILL.md
│       ├── references/
│       └── scripts/
├── agents/
│   └── security-reviewer.md
├── hooks/
│   └── hooks.json
└── scripts/
    └── validate.sh
```

### Plugin with MCP/LSP Servers

```
my-plugin/
├── .claude-plugin/
│   └── plugin.json
├── .mcp.json
├── .lsp.json
└── skills/
    └── my-skill/
        └── SKILL.md
```

## Testing Checklist

Before distributing your plugin:

- [ ] Skills activate correctly (auto-activation + slash command)
- [ ] Hooks fire on expected events
- [ ] Scripts execute without errors
- [ ] No hardcoded paths (all use `${CLAUDE_PLUGIN_ROOT}`)
- [ ] plugin.json validates: `jq . .claude-plugin/plugin.json`
- [ ] All referenced files exist
- [ ] hooks.json in correct location (`hooks/hooks.json`)
- [ ] Tested with `claude --plugin-dir`
- [ ] Tested multiple times after restarts
- [ ] No external dependencies (all files self-contained)

## Next Steps

- Use `skill-creator` skill to validate individual Agent Skills
- Use `hook-creator` skill to validate hooks
- Use `subagent-creator` skill to validate subagents
- Read [Plugin CLI Commands](cli-commands.md) for installation/distribution commands
- See [Best Practices](best-practices.md) for production deployment
