# Exit Code Behavior for Command Hooks

How Claude Code interprets exit codes and handles command hook output.

## Table of Contents

- [Exit Code Reference](#exit-code-reference)
  - [Exit Code 0: Success](#exit-code-0-success)
  - [Exit Code 2: Blocking Error](#exit-code-2-blocking-error)
  - [Exit Code 1, 3-255: Non-blocking Error](#exit-code-1-3-255-non-blocking-error)
- [Combining Exit Codes with onError](#combining-exit-codes-with-onerror)
- [JSON vs Plain Text Output](#json-vs-plain-text-output)
  - [JSON Output (Structured)](#json-output-structured)
  - [Plain Text Output (Simple)](#plain-text-output-simple)
- [Timeout Handling](#timeout-handling)
- [Error Message Best Practices](#error-message-best-practices)
  - [Clear, Actionable Messages (Exit 2)](#clear-actionable-messages-exit-2)
  - [Include Context](#include-context)
  - [Don't Include Stack Traces](#dont-include-stack-traces)
- [Practical Examples](#practical-examples)
- [Debugging Exit Codes](#debugging-exit-codes)

---

## Exit Code Reference

### Exit Code 0: Success

**Default behavior:** Hook succeeded, no errors.

**stdout handling:**
- Parsed as JSON if valid JSON present
- If JSON: Used for decision control (see decision-schemas.md)
- If plain text:
  - **UserPromptSubmit/SessionStart:** Added as context to Claude
  - **Other events:** Shown in verbose mode (ctrl+o) only

**stderr handling:** Shown in verbose mode only (not to Claude)

**Action:** Proceeds normally

**Example (plain text context):**
```bash
#!/bin/bash
echo "Dependencies installed successfully"
echo "Node version: $(node --version)"
exit 0
```

**Example (JSON output):**
```bash
#!/bin/bash
cat <<'EOF'
{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "allow"
  }
}
EOF
exit 0
```

---

### Exit Code 2: Blocking Error

**Severity:** Critical - blocks the action.

**stdout handling:** Ignored (JSON not parsed)

**stderr handling:** Used as error message and shown to Claude

**Action:** Blocks the operation

**Event-specific behavior:**

| Event | Behavior |
|-------|----------|
| PreToolUse | Blocks tool execution, shows stderr to Claude |
| PermissionRequest | Denies permission, shows stderr to Claude |
| PostToolUse | Tool already executed, shows stderr to Claude (informational) |
| UserPromptSubmit | Blocks prompt processing, erases prompt, shows stderr to user only |
| Stop | Blocks stoppage, shows stderr to Claude |
| SubagentStop | Blocks subagent stop, shows stderr to subagent |
| SessionStart | Hook fails, shows stderr to user only (doesn't block session) |

**Format:** `[command]: {stderr}` or just stderr

**Example (blocking validation):**
```bash
#!/bin/bash
if [[ ! -f ".gitignore" ]]; then
  echo "Missing .gitignore file" >&2
  exit 2
fi
exit 0
```

Result: If .gitignore missing, tool blocked with message "Missing .gitignore file"

---

### Exit Code 1, 3-255: Non-blocking Error

**Severity:** Warning - logs error but continues.

**stdout handling:** Ignored

**stderr handling:** Shown in verbose mode only (not to Claude, not in normal output)

**Action:** Proceeds, error logged

**When to use:** Expected errors, optional validations, or failures that shouldn't stop execution

**Example (optional validation):**
```bash
#!/bin/bash
# Check for common issues but don't block
if [[ -f "node_modules/.bin/eslint" ]]; then
  if ! npm run lint --silent 2>/dev/null; then
    echo "Lint warnings found (non-critical)" >&2
    exit 1  # Non-blocking exit
  fi
fi
exit 0
```

Result: Linting runs, warnings shown in verbose only, execution continues

---

## Combining Exit Codes with onError

The hook's `onError` setting modifies how errors are handled:

```json
{
  "type": "command",
  "command": "script.sh",
  "timeout": 5000,
  "onError": "warn|fail|continue"
}
```

**Interaction matrix:**

| Exit Code | onError | Behavior |
|-----------|---------|----------|
| 0 | any | Success, no error |
| 2 | warn | Error logged as warning, continues |
| 2 | fail | Error raised, hook fails |
| 2 | continue | Error silently ignored |
| 1 | warn | Warning logged (default) |
| 1 | fail | Treated as failure |
| 1 | continue | Silently ignored |

**Note:** Exit code 2 is always "blocking" intent. `onError` determines how strictly it's enforced.

---

## JSON vs Plain Text Output

### JSON Output (Structured)

**Advantages:**
- Specific decision control (allow/deny/ask)
- Can modify tool inputs
- Add context with metadata
- Works with all hook events

**When to use:**
- Need granular control over permission/decision
- Modifying inputs
- Adding context with explanation

**Format:**
```bash
cat <<'EOF'
{
  "hookSpecificOutput": {
    "hookEventName": "EventName",
    "decision": "value",
    ...
  }
}
EOF
exit 0
```

### Plain Text Output (Simple)

**Advantages:**
- Simple scripts, no JSON parsing
- Faster to write
- Works for adding context (UserPromptSubmit/SessionStart)

**When to use:**
- Just adding context
- Simple logging
- Non-decision hooks

**Format:**
```bash
echo "Some context to add to Claude"
exit 0
```

**Result:** Text added as context to Claude (UserPromptSubmit/SessionStart only)

---

## Timeout Handling

If hook doesn't complete before timeout:

```json
{
  "command": "long-running.sh",
  "timeout": 5000  // 5 seconds
}
```

**On timeout:**
- Process killed
- Treated as exit code 2 (blocking error) if PreToolUse
- Treated as non-blocking error otherwise
- stderr: "Hook timed out after Xms"

---

## Error Message Best Practices

### Clear, Actionable Messages (Exit 2)

```bash
#!/bin/bash
if [[ "$FILE_SIZE" -gt 1000000 ]]; then
  echo "File too large (1MB+). Split into smaller files or increase timeout." >&2
  exit 2
fi
```

Shows: "File too large (1MB+). Split into smaller files or increase timeout."

### Include Context

```bash
#!/bin/bash
if ! npm run build; then
  echo "Build failed. Run 'npm run build' locally to debug." >&2
  exit 2
fi
```

### Don't Include Stack Traces

```bash
# Bad
set -e
npm run build  # Shows full npm error output
exit 0

# Good
if ! npm run build > /tmp/build.log 2>&1; then
  echo "Build failed. Check build logs." >&2
  exit 2
fi
```

---

## Practical Examples

### Example 1: Conditional Validation (Mixed Exit Codes)

```bash
#!/bin/bash

# Critical validation (exit 2)
if [[ ! -f "package.json" ]]; then
  echo "package.json missing - cannot proceed" >&2
  exit 2
fi

# Warnings (exit 1 - non-blocking)
if [[ ! -f "README.md" ]]; then
  echo "README.md missing (optional)" >&2
fi

# Success
exit 0
```

### Example 2: Decision with JSON Output

```bash
#!/bin/bash

read -r input
command=$(echo "$input" | jq -r '.tool_input.command // ""')

# If safe, auto-approve
if [[ "$command" =~ ^npm\ run ]]; then
  cat <<'EOF'
{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "allow",
    "permissionDecisionReason": "npm run commands auto-approved"
  }
}
EOF
  exit 0
fi

# Default: ask user
exit 0  # No output = normal permission flow
```

### Example 3: Context on Session Start

```bash
#!/bin/bash

# Add useful context
cat <<'EOF'
Session initialized with:
- Python: $(python3 --version)
- Node: $(node --version)
- Current directory: $(pwd)
EOF

exit 0
```

Result: Context lines added to Claude's initial instructions

---

## Debugging Exit Codes

Use `echo` to stdout/stderr strategically:

```bash
#!/bin/bash
set -x  # Debug mode

if [[ condition ]]; then
  echo "Condition met" >&2  # Visible in verbose
  exit 0
else
  echo "Condition failed" >&2
  exit 1  # Non-blocking
fi
```

Run with `claude --debug` to see full hook execution and exit codes.
