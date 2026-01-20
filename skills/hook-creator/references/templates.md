# Hook Templates

Copy-paste starting points for common hook patterns. Adapt these templates to your needs.

## Table of Contents

- [Basic Command Hook](#basic-command-hook)
- [Command Hook with Error Handling](#command-hook-with-error-handling)
- [Prompt Hook (UserPromptSubmit)](#prompt-hook-userpromptsubmit)
- [Prompt Hook (Stop/SubagentStop)](#prompt-hook-stopsubagentsop)
- [Prompt Hook (PreToolUse / PermissionRequest)](#prompt-hook-pretooluse--permissionrequest)
- [Multiple Hooks on Same Event](#multiple-hooks-on-same-event)
- [Multiple Matchers on Same Event](#multiple-matchers-on-same-event)
- [Format on Write Hook](#format-on-write-hook)
- [Validate Before Commit Hook](#validate-before-commit-hook)
- [Cleanup on Session End Hook](#cleanup-on-session-end-hook)
- [Hook File Organization](#hook-file-organization)
- [Common Matcher Patterns](#common-matcher-patterns)
- [Environment Variables in Hooks](#environment-variables-in-hooks)
- [Testing Hooks Locally](#testing-hooks-locally)
- [Migration: From Script-Based to Hook-Based](#migration-from-script-based-to-hook-based)
- [Production Deployment Checklist](#production-deployment-checklist-for-hooks)

---

## Basic Command Hook

**Use case:** Run a script after a tool executes. Example: format code after writing a file.

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "^(Write|Edit)$",
        "hooks": [
          {
            "type": "command",
            "command": "${CLAUDE_PLUGIN_ROOT}/scripts/my-script.sh",
            "timeout": 2000
          }
        ]
      }
    ]
  }
}
```

**Customization:**
- Replace `PostToolUse` with your event (PreToolUse, UserPromptSubmit, SessionEnd, etc.)
- Replace `^(Write|Edit)$` with tools/patterns to match
- Replace `my-script.sh` with your script path
- Adjust `timeout` based on how long your script takes

---

## Command Hook with Error Handling

**Use case:** Run script with explicit error handling and logging.

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "^(Write|Edit)$",
        "hooks": [
          {
            "type": "command",
            "command": "${CLAUDE_PLUGIN_ROOT}/scripts/validate.sh",
            "timeout": 3000,
            "onError": "warn",
            "env": {
              "PLUGIN_ROOT": "${CLAUDE_PLUGIN_ROOT}",
              "LOG_LEVEL": "debug"
            }
          }
        ]
      }
    ]
  }
}
```

**Features:**
- `onError: "warn"` - Log error but don't fail hook
- `env` - Pass environment variables to script
- `timeout` - Prevent hangs (3000ms = 3 seconds)

**Error behavior options:**
- `"warn"` - Log warning, continue (safe for most cases)
- `"fail"` - Fail hook but don't crash plugin
- `"continue"` - Silently continue (only if errors are expected)

---

## Prompt Hook (UserPromptSubmit)

**Use case:** LLM-based validation on user input. Example: block prompts with sensitive data patterns.

**Available for:** UserPromptSubmit only (on command hooks, use exit codes)

```json
{
  "hooks": {
    "UserPromptSubmit": [
      {
        "hooks": [
          {
            "type": "prompt",
            "prompt": "Does this prompt contain code or legitimate technical question? ${ARGUMENTS}\n\nRespond with: {\"ok\": true} or {\"ok\": false, \"reason\": \"why\"}",
            "timeout": 10000
          }
        ]
      }
    ]
  }
}
```

**LLM Response format:**
```json
{
  "ok": true,
  "reason": "Valid code question"
}
```

If LLM responds with `ok: false`, prompt is blocked with reason shown to user.

---

## Prompt Hook (Stop/SubagentStop)

**Use case:** Intelligent decision-making on stop. Example: prevent stop if work incomplete.

**Available for:** Stop, SubagentStop only

```json
{
  "hooks": {
    "Stop": [
      {
        "hooks": [
          {
            "type": "prompt",
            "prompt": "Evaluate if work can stop: ${ARGUMENTS}\n\nRespond with: {\"ok\": true, \"reason\": \"why stop\"} or {\"ok\": false, \"reason\": \"why continue\"}",
            "timeout": 30000
          }
        ]
      }
    ]
  }
}
```

**LLM Response format:**
```json
{
  "ok": true,
  "reason": "All tasks completed successfully"
}
```

Or:
```json
{
  "ok": false,
  "reason": "Tests still running, wait for completion"
}
```

If `ok: false`, stop is prevented and reason shown to Claude.

---

## Prompt Hook (PreToolUse / PermissionRequest)

**Use case:** Context-aware permission decisions. Example: allow risky commands only in safe contexts.

**Available for:** PreToolUse, PermissionRequest only

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "^Bash$",
        "hooks": [
          {
            "type": "prompt",
            "prompt": "Is this bash command safe? Command: ${ARGUMENTS}\n\nRespond: {\"ok\": true} or {\"ok\": false, \"reason\": \"why not\"}",
            "timeout": 15000
          }
        ]
      }
    ]
  }
}
```

**Note on prompt hooks:**
- Cost tokens (API calls ~2-10s each)
- Use for complex decisions needing context understanding
- Don't use for simple deterministic validation (use command hooks instead)
- Timeouts longer than command hooks (10-30s typical)

---

## Multiple Hooks on Same Event

**Use case:** Run multiple scripts/verifications after tool use. Example: format, lint, then test.

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
            "timeout": 2000,
            "onError": "warn"
          },
          {
            "type": "command",
            "command": "${CLAUDE_PLUGIN_ROOT}/scripts/lint.sh",
            "timeout": 3000,
            "onError": "warn"
          },
          {
            "type": "command",
            "command": "${CLAUDE_PLUGIN_ROOT}/scripts/test.sh",
            "timeout": 10000,
            "onError": "warn"
          }
        ]
      }
    ]
  }
}
```

**Execution order:** Top to bottom (format → lint → test)

**Important:** Each hook can fail independently. Set `onError: "warn"` so failures don't cascade.

---

## Multiple Matchers on Same Event

**Use case:** Run different hooks for different conditions. Example: different actions for different file types.

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "\\.js$",
        "hooks": [
          {
            "type": "command",
            "command": "${CLAUDE_PLUGIN_ROOT}/scripts/prettier.sh",
            "timeout": 2000
          }
        ]
      },
      {
        "matcher": "\\.py$",
        "hooks": [
          {
            "type": "command",
            "command": "${CLAUDE_PLUGIN_ROOT}/scripts/black.sh",
            "timeout": 2000
          }
        ]
      }
    ]
  }
}
```

**Logic:** If matcher 1 matches, execute hooks for matcher 1. If matcher 2 matches, execute hooks for matcher 2. Both can execute if both matchers match.

---

## Format on Write Hook

**Complete example:** Format code after file is written.

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "^(Write|Edit)$",
        "hooks": [
          {
            "type": "command",
            "command": "${CLAUDE_PLUGIN_ROOT}/scripts/format-code.sh",
            "timeout": 2000,
            "onError": "warn"
          }
        ]
      }
    ]
  }
}
```

**Script (format-code.sh):**
```bash
#!/bin/bash
set -e  # Exit on error

# Get the file path from stdin or argument
FILE_PATH="${1:-.}"

# Determine file type and format accordingly
if [[ "$FILE_PATH" == *.js ]] || [[ "$FILE_PATH" == *.jsx ]]; then
  prettier --write "$FILE_PATH" 2>/dev/null || echo "prettier failed for $FILE_PATH" >&2
elif [[ "$FILE_PATH" == *.py ]]; then
  black "$FILE_PATH" 2>/dev/null || echo "black failed for $FILE_PATH" >&2
fi

exit 0
```

---

## Validate Before Commit Hook

**Complete example:** Validation hook that prevents commits with issues.

```json
{
  "hooks": {
    "UserPromptSubmit": [
      {
        "matcher": "commit",
        "hooks": [
          {
            "type": "command",
            "command": "${CLAUDE_PLUGIN_ROOT}/scripts/pre-commit.sh",
            "timeout": 5000,
            "onError": "fail"
          }
        ]
      }
    ]
  }
}
```

**Script (pre-commit.sh):**
```bash
#!/bin/bash

# Run linting
if ! npm run lint --silent 2>/dev/null; then
  echo "Linting failed. Fix errors before committing." >&2
  exit 1
fi

# Run tests
if ! npm test --silent 2>/dev/null; then
  echo "Tests failed. Fix failures before committing." >&2
  exit 1
fi

exit 0
```

**Behavior:**
- If script exits with code 0 (success): commit proceeds
- If script exits with non-zero code (error): commit is blocked
- `onError: "fail"` means validation failure blocks the operation

---

## Cleanup on Session End Hook

**Complete example:** Run cleanup tasks when Claude Code session ends.

```json
{
  "hooks": {
    "SessionEnd": [
      {
        "matcher": ".*",
        "hooks": [
          {
            "type": "command",
            "command": "${CLAUDE_PLUGIN_ROOT}/scripts/cleanup.sh",
            "timeout": 3000,
            "onError": "warn"
          }
        ]
      }
    ]
  }
}
```

**Script (cleanup.sh):**
```bash
#!/bin/bash

# Remove temporary files
rm -f "${PLUGIN_ROOT}/temp/"*.tmp

# Archive logs
if [ -f "${PLUGIN_ROOT}/logs/session.log" ]; then
  gzip "${PLUGIN_ROOT}/logs/session.log"
fi

# Kill any background processes
pkill -f "plugin-worker" || true

exit 0
```

**Notes:**
- `SessionEnd` runs when session closes (safe for cleanup)
- `matcher: ".*"` matches all sessions
- `onError: "warn"` is appropriate for cleanup (shouldn't block session close)

---

## Hook File Organization

**Standard structure in plugin.json:**

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "pattern",
        "hooks": [...]
      }
    ],
    "PostToolUse": [
      {
        "matcher": "pattern",
        "hooks": [...]
      }
    ],
    "SessionEnd": [
      {
        "matcher": ".*",
        "hooks": [...]
      }
    ]
  }
}
```

**Alternative: Separate hooks.json file**

If hooks are complex, create `.claude-plugin/hooks.json`:

```json
{
  "hooks": {
    "PostToolUse": [...],
    "UserPromptSubmit": [...],
    "SessionEnd": [...]
  }
}
```

Then reference in `plugin.json`:
```json
{
  "name": "my-plugin",
  "version": "1.0.0",
  "hooks": "./.claude-plugin/hooks.json"
}
```

---

## Common Matcher Patterns

| Pattern | Matches | Use Case |
|---------|---------|----------|
| `^Write$` | Exactly "Write" tool | Format after write |
| `^(Write\|Edit)$` | Write OR Edit | Edit files |
| `^(Read\|Glob\|Grep)$` | Any file read | Audit reads |
| `\.js$` | Files ending in .js | JS-specific action |
| `\.py$` | Files ending in .py | Python-specific action |
| `commit\|push` | Text contains commit or push | Version control |
| `test\|spec` | Text contains test or spec | Test-related |
| `.*` | Matches everything | Run always |

**Examples:**

```json
{
  "matcher": "^(Write|Edit)$"  // Tool names: exact match
}
```

```json
{
  "matcher": "\\.js$"  // File pattern: .js files
}
```

```json
{
  "matcher": "commit|push"  // Text pattern: commit or push
}
```

```json
{
  "matcher": "test"  // Text pattern: contains "test"
}
```

---

## Environment Variables in Hooks

**Available to all hooks:**

```json
{
  "type": "command",
  "command": "${CLAUDE_PLUGIN_ROOT}/scripts/run.sh",
  "env": {
    "PLUGIN_ROOT": "${CLAUDE_PLUGIN_ROOT}",
    "DEBUG": "true",
    "CONFIG_PATH": "${CLAUDE_PLUGIN_ROOT}/config.json"
  }
}
```

**${CLAUDE_PLUGIN_ROOT}** - Automatically resolved to plugin root path

**Custom variables** - Add any env vars your script needs

---

## Testing Hooks Locally

**Before deploying, test locally:**

```bash
# 1. Create test hook config
cat > test-hook.json <<'EOF'
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "^Write$",
        "hooks": [{
          "type": "command",
          "command": "${CLAUDE_PLUGIN_ROOT}/scripts/format.sh",
          "timeout": 2000
        }]
      }
    ]
  }
}
EOF

# 2. Validate syntax
claude plugin validate .

# 3. Test script standalone
${CLAUDE_PLUGIN_ROOT}/scripts/format.sh test-file.js

# 4. Install plugin with test hooks
claude plugin install .
```

---

## Migration: From Script-Based to Hook-Based

If migrating from manual scripts to hooks:

**Before (manual):**
```bash
claude write myfile.js
# Then manually: prettier myfile.js
```

**After (hook-based):**
```bash
claude write myfile.js
# Hook automatically runs: prettier myfile.js
```

**Setup:**
1. Create hook config with matcher for Write tool
2. Point hook to formatting script
3. Install plugin with hook
4. No more manual formatting needed

---

## Production Deployment Checklist for Hooks

Before deploying to production:

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
            "timeout": 2000,
            "onError": "warn",
            "env": {
              "LOG_LEVEL": "info"
            }
            // ✓ Timeout set
            // ✓ Error handling defined (warn)
            // ✓ Matcher precise (not .*)
            // ✓ Script path uses ${CLAUDE_PLUGIN_ROOT}
            // ✓ Logging configured
          }
        ]
      }
    ]
  }
}
```

Verify:
- [ ] Timeout reasonable (<5s for sync operations)
- [ ] onError behavior appropriate (warn for safe ops, fail for critical)
- [ ] Matcher tested with real scenarios
- [ ] Script is tested and documented
- [ ] Logging/monitoring configured
- [ ] Rollback procedure documented
