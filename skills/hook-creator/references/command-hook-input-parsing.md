# Command Hook Input: Reading from stdin

## Critical Misunderstanding

Many developers assume command hooks can receive tool arguments via environment variables like:

```json
{
  "env": {
    "FILE_PATH": "${arguments.file_path}"
  }
}
```

❌ **This does NOT work.** Claude Code does not support this variable substitution syntax.

## How Command Hooks Actually Receive Data

Command hooks receive **all event data as JSON on stdin**, not through environment variables.

### Input Format

Claude Code passes structured JSON to your hook script on stdin:

```json
{
  "session_id": "abc123",
  "transcript_path": "/path/to/transcript.jsonl",
  "cwd": "/current/dir",
  "permission_mode": "default",
  "hook_event_name": "PreToolUse",
  "tool_name": "Write",
  "tool_input": {
    "file_path": "/path/to/file.txt",
    "content": "file content here"
  },
  "tool_use_id": "toolu_01ABC123..."
}
```

**Your script must:**
1. Read stdin with `INPUT=$(cat)`
2. Parse JSON with `jq` (or similar tool)
3. Extract fields from `tool_input` object

## Correct Pattern

### Bash Example

```bash
#!/bin/bash

# Read hook input from stdin
INPUT=$(cat)

# Extract file_path from tool_input
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

# Safely handle missing/null values
if [ -z "$FILE_PATH" ] || [ "$FILE_PATH" = "null" ]; then
  exit 0
fi

# Your logic here
echo "Processing: $FILE_PATH"
exit 0
```

### Python Example

```python
#!/usr/bin/env python3

import json
import sys

# Read hook input from stdin
hook_input = json.load(sys.stdin)

# Extract file_path safely
file_path = hook_input.get('tool_input', {}).get('file_path')

if not file_path:
    sys.exit(0)

print(f"Processing: {file_path}")
sys.exit(0)
```

## Available Tool Arguments by Event

### PreToolUse & PostToolUse

Both events provide the same `tool_input` structure. Common tools:

**Write tool:**
```json
{
  "tool_input": {
    "file_path": "/path/to/file.txt",
    "content": "file content"
  }
}
```

**Edit tool:**
```json
{
  "tool_input": {
    "file_path": "/path/to/file.txt",
    "old_string": "original text",
    "new_string": "replacement text",
    "replace_all": false
  }
}
```

**Read tool:**
```json
{
  "tool_input": {
    "file_path": "/path/to/file.txt",
    "offset": 10,
    "limit": 100
  }
}
```

**Bash tool:**
```json
{
  "tool_input": {
    "command": "npm test",
    "description": "Run tests",
    "timeout": 120000,
    "run_in_background": false
  }
}
```

### UserPromptSubmit

```json
{
  "prompt": "User's input text here"
}
```

### Notification

```json
{
  "message": "Notification message",
  "notification_type": "permission_prompt"
}
```

### Stop

```json
{
  "stop_hook_active": false
}
```

## Best Practices

### 1. Always Safely Handle Missing Data

```bash
# Use jq's // operator for defaults
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

if [ -z "$FILE_PATH" ]; then
  exit 0
fi
```

### 2. Validate Before Using

```bash
# Check if file exists before processing
if [ ! -f "$FILE_PATH" ]; then
  echo "File not found: $FILE_PATH" >&2
  exit 1
fi
```

### 3. Error Handling

Exit codes matter:
- `exit 0` - Success (no error output)
- `exit 1` - Non-blocking error (only shown in verbose mode)
- `exit 2` - Blocking error (stderr shown directly to Claude)

### 4. Keep Scripts Fast

Command hooks should execute in <1s for synchronous hooks:

```bash
# ❌ Avoid slow operations
sleep 10

# ✓ Do lightweight validation/processing only
jq -r '.tool_input.file_path' < /dev/stdin
```

### 5. Avoid Assumptions

Don't assume field existence or types:

```bash
# ❌ Bad: assumes content is always present
CONTENT=$(echo "$INPUT" | jq -r '.tool_input.content')

# ✓ Good: handles missing content
CONTENT=$(echo "$INPUT" | jq -r '.tool_input.content // empty')
```

## Debugging Hooks

### Test Your Hook Locally

```bash
# Create sample input
cat > test-input.json <<'EOF'
{
  "tool_name": "Write",
  "tool_input": {
    "file_path": "/tmp/test.txt",
    "content": "test content"
  }
}
EOF

# Test your script
./your-hook.sh < test-input.json
echo "Exit code: $?"
```

### Log Parsed Values

```bash
#!/bin/bash

INPUT=$(cat)

# Log for debugging
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')
echo "DEBUG: FILE_PATH=$FILE_PATH" >&2

# ... rest of script
```

### Check Hook Configuration

Verify your `hooks.json` has:
- ✓ Correct event name (PreToolUse, PostToolUse, etc.)
- ✓ Correct matcher pattern (if needed)
- ✓ Correct script path (use `${CLAUDE_PLUGIN_ROOT}` for plugins)
- ✓ Reasonable timeout (in milliseconds, default unlimited)
- ✓ `onError` behavior specified

Example:
```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "^(Write|Edit)$",
        "hooks": [
          {
            "type": "command",
            "command": "${CLAUDE_PLUGIN_ROOT}/scripts/my-hook.sh",
            "timeout": 2000,
            "onError": "warn"
          }
        ]
      }
    ]
  }
}
```

## Common Mistakes

### ❌ Environment Variable Substitution (Doesn't Work)

```json
{
  "env": {
    "FILE_PATH": "${arguments.file_path}"  // Won't work
  }
}
```

### ❌ Passing Arguments Directly

```bash
command = "script.sh --file ${tool_input.file_path}"  // Won't work
```

### ❌ Ignoring null/empty Values

```bash
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path')
# FILE_PATH might be null, causing errors downstream
```

### ✓ Correct: Read from stdin with Safe Parsing

```bash
#!/bin/bash
INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

if [ -z "$FILE_PATH" ]; then
  exit 0
fi
# Use FILE_PATH safely
```

## Reference

- **Official docs**: https://code.claude.com/docs/en/hooks#hook-input
- **Related**: `how-hooks-work.md`, `event-reference.md`, `templates.md`
