# Packaging Hooks in Plugins

Hooks enable plugins to respond to Claude Code events automatically with custom handlers. This guide covers packaging and organizing hooks within plugins.

**For creating and validating hooks:** Use the `hook-creator` skill instead. This guide covers plugin integration only.

## When to Include Hooks in Your Plugin

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

## Plugin Structure with Hooks

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

## Hook Configuration in Plugins

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

## Hook Types in Plugins

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

## Best Practices

- **Event selection:** Choose event that provides needed data (Pre vs Post, which event)
- **Matcher precision:** Specific enough to avoid false triggers, broad enough to catch cases
- **Error handling:** Set `onError` behavior (warn/fail/continue) appropriately
- **Performance:** Keep sync hooks <1s. Use async for longer operations
- **Naming:** Describe hook by action + event: `format-on-write`, `validate-before-deploy`
- **Documentation:** Comment matcher logic and expected behavior in hooks.json
- **Testing:** Test hooks with real plugin workflows before deployment

## Workflow: Adding Hooks to Your Plugin

1. **Determine need** — What event should trigger? What should happen?
2. **Create hook scripts** — Write validation/formatting/coordination scripts in `scripts/`
3. **Use hook-creator skill** — Build and validate hook configuration
4. **Add to plugin** — Place `hooks.json` in plugin root (or inline in `.claude-plugin/plugin.json`)
5. **Test locally** — `claude --plugin-dir /path/to/plugin` and verify hooks trigger
6. **Validate** — Run `claude plugin validate .` to check structure

For detailed hook creation and validation workflows, use the `hook-creator` skill.
