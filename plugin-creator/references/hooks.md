# Hooks in Plugins

Hooks allow your plugin to respond to Claude Code events automatically with custom handlers.

## When to Add Hooks to Your Plugin

Add hooks when your plugin should:

- React to Claude Code events (tool use, prompts, agent lifecycle, sessions)
- Perform automatic validation or formatting before tool execution
- Audit or verify Claude's actions
- Manage plugin state or notifications

Examples:
- Verify code before Write/Edit operations
- Run linting after file modifications
- Track tool usage for analytics
- Suppress sensitive information in notifications

## Plugin Structure with Hooks

Hooks can be defined in `hooks.json` or inline in `plugin.json`:

```
my-plugin/
├── .claude-plugin/
│   └── plugin.json
├── hooks.json                    # Event handlers (or inline in plugin.json)
└── scripts/
    ├── verify-code.sh
    └── sanitize-output.sh
```

## Hook Configuration Format

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Write|Edit",
        "hooks": [
          {
            "type": "command",
            "command": "${CLAUDE_PLUGIN_ROOT}/scripts/format.sh"
          }
        ]
      }
    ]
  }
}
```

## Available Events

| Event | Timing | Use Case |
|-------|--------|----------|
| `PreToolUse` | Before any tool execution | Validate inputs, pre-checks |
| `PostToolUse` | After successful tool execution | Auto-format, verification, logging |
| `PostToolUseFailure` | After tool execution fails | Error handling, cleanup, recovery |
| `PermissionRequest` | When permission dialog shown | Audit, policy enforcement |
| `UserPromptSubmit` | When user submits prompt | Input validation, preprocessing |
| `Notification` | When Claude Code sends notification | Message filtering, redirection |
| `Stop` | When Claude attempts to stop | Cleanup operations |
| `SubagentStart` | Subagent starts | Agent lifecycle tracking |
| `SubagentStop` | Subagent stops | Resource cleanup |
| `SessionStart` | Session begins | Initialization, setup |
| `SessionEnd` | Session ends | Cleanup, state persistence |
| `PreCompact` | Before history compaction | Archive operations |

## Hook Types

### Command Hook
Execute shell scripts or commands:
```json
{
  "type": "command",
  "command": "${CLAUDE_PLUGIN_ROOT}/scripts/verify.sh"
}
```

### Prompt Hook
Evaluate logic with LLM:
```json
{
  "type": "prompt",
  "prompt": "Is this code change safe? Respond with yes or no."
}
```

### Agent Hook
Run agentic verifier with tools for complex verification:
```json
{
  "type": "agent",
  "capabilities": ["file-analysis", "code-review"]
}
```

## Matcher Patterns

Use `matcher` to filter which tools trigger the hook. Matchers use regex pipe syntax for OR logic:

### Common Patterns

```json
"matcher": "Write|Edit"          // File operations: Write or Edit
"matcher": "Bash"                // Only Bash shell commands
"matcher": "Read"                // Only Read file operations
"matcher": "Glob"                // Only file globbing operations
"matcher": "*"                   // All tools (any tool use)
```

### Complete Tool Names

Claude Code tools that can be matched:

**File Operations:**
- `Read` — Read files
- `Write` — Write new files
- `Edit` — Edit existing files
- `Glob` — Find files by pattern
- `Bash` — Execute shell commands

**Development Tools:**
- `NotebookEdit` — Edit Jupyter notebooks
- `WebFetch` — Fetch web content
- `WebSearch` — Search the web

**Plugin/Custom:**
- `Task` — Launch specialized agents
- `Skill` — Invoke user-defined skills

### Advanced Matcher Examples

```json
// File operations (read, write, edit)
"matcher": "Read|Write|Edit"

// File discovery and operations
"matcher": "Glob|Read|Bash"

// Shell and web operations
"matcher": "Bash|WebFetch"

// Only specific risky tools
"matcher": "Bash|Write"

// Any tool (safety check for all)
"matcher": ".*"

// All file operations (precise)
"matcher": "^(Read|Write|Edit)$"
```

### Matching Logic

- **Pipe (|) means OR:** `"Write|Edit"` matches Write OR Edit
- **Regex syntax:** Matcher is regex pattern matched against tool name
- **Case-sensitive:** Match exact tool name case
- **Default to all:** If no matcher specified, hook runs for all tools

### Escaping Special Characters

For regex special characters in tool names (rare), escape with backslash:

```json
"matcher": "Tool\\(Special\\)"    // Literal parentheses
```

## Common Patterns

### Multiple Hooks on Single Event

Run multiple handlers for same event:

````json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Write|Edit",
        "hooks": [
          {
            "type": "command",
            "command": "${CLAUDE_PLUGIN_ROOT}/scripts/format.sh"
          },
          {
            "type": "command",
            "command": "${CLAUDE_PLUGIN_ROOT}/scripts/lint.sh"
          }
        ]
      }
    ]
  }
}
````

Hooks execute in order; failure doesn't prevent subsequent hooks.

### Tool-Specific Hooks

Filter hooks by tool type:

````json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Write",
        "hooks": [{"type": "command", "command": "./verify-write.sh"}]
      },
      {
        "matcher": "Edit",
        "hooks": [{"type": "command", "command": "./verify-edit.sh"}]
      }
    ]
  }
}
````

### Verification with LLM

Use prompt hooks to evaluate Claude's actions:

````json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "prompt",
            "prompt": "Is this bash command safe? Respond with yes or no."
          }
        ]
      }
    ]
  }
}
````

## Hook Configuration Rules

- **Scripts must be executable:** `chmod +x ./scripts/verify.sh`
- **Use `${CLAUDE_PLUGIN_ROOT}` for paths:** Ensures correct resolution after installation
- **Paths relative to plugin root:** All paths start with `./`
- **Inline or separate file:** Define `hooks` object directly in `plugin.json` or in separate `hooks.json`

## Testing Hooks

Test locally with `--plugin-dir`:

```bash
claude --plugin-dir /path/to/my-plugin --debug
```

Debug output shows which hooks are registered and when they trigger.

**Test by triggering events:**
```bash
# Test PostToolUse by writing a file
# Test PreToolUse by running any command
# Test SessionStart by starting new session
```

## Publishing Plugin with Hooks

Document hook behavior in plugin README:

```markdown
## Automatic Hooks

This plugin includes hooks that run automatically:

- **PostToolUse (Write|Edit):** Auto-formats code after modifications
- **PostToolUse (Bash):** Verifies shell commands for safety
- **SessionStart:** Initializes plugin state

Hooks can be disabled by removing them from `hooks.json` in your installation.
```

## Troubleshooting

| Issue | Cause | Solution |
|-------|-------|----------|
| Hook not triggering | Event name typo (case-sensitive) | Verify: `PostToolUse`, not `postToolUse` |
| Script not executing | Not executable | Run: `chmod +x ./scripts/script.sh` |
| Script fails silently | Wrong shebang | Add: `#!/usr/bin/env bash` as first line |
| `${CLAUDE_PLUGIN_ROOT}` not found | Absolute paths used | Use only `${CLAUDE_PLUGIN_ROOT}/path` |
| Matcher not working | Tool name incorrect | Check tool matches: `Write`, `Edit`, `Bash` |
