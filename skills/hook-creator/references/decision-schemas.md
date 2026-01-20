# Hook Decision Schemas

JSON output structure for each event type. Command hooks return JSON via stdout; prompt hooks use structured responses.

## Table of Contents

- [PreToolUse Decision Schema](#pretooluse-decision-schema)
- [PermissionRequest Decision Schema](#permissionrequest-decision-schema)
- [PostToolUse / PostToolUseFailure Decision Schema](#posttooluse--posttoolusefailure-decision-schema)
- [Stop / SubagentStop Decision Schema](#stop--subagentstop-decision-schema)
- [UserPromptSubmit Decision Schema](#userpromptsubmit-decision-schema)
- [SessionStart Decision Schema](#sessionstart-decision-schema)
- [Common JSON Output Wrapper](#common-json-output-wrapper)
- [Exit Code Behavior (Command Hooks)](#exit-code-behavior-command-hooks)
- [Practical Decision Examples](#practical-decision-examples)

---

## PreToolUse Decision Schema

**Use:** Control whether tool executes, modify inputs, add context.

**JSON format:**
```json
{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "allow|deny|ask",
    "permissionDecisionReason": "Explanation shown to user",
    "updatedInput": {
      "field_to_modify": "new_value"
    },
    "additionalContext": "Context added to Claude's instructions"
  }
}
```

**Field behavior:**
- `permissionDecision: "allow"` - Approves tool, runs immediately (reason shown to user only, not Claude)
- `permissionDecision: "deny"` - Blocks tool call (reason shown to Claude)
- `permissionDecision: "ask"` - Asks user to confirm (reason shown to user)
- `updatedInput` - Modifies tool parameters before execution (combine with allow/ask)
- `additionalContext` - Adds context to Claude before tool runs

**Example: Auto-approve file reads**
```json
{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "allow",
    "permissionDecisionReason": "Documentation file auto-approved"
  }
}
```

**Example: Modify command before execution**
```json
{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "allow",
    "updatedInput": {
      "command": "npm run lint -- --fix"
    },
    "permissionDecisionReason": "Auto-applying lint fix"
  }
}
```

---

## PermissionRequest Decision Schema

**Use:** Auto-approve/deny permission dialogs without user interaction.

**JSON format:**
```json
{
  "hookSpecificOutput": {
    "hookEventName": "PermissionRequest",
    "decision": {
      "behavior": "allow|deny",
      "updatedInput": { /* optional */ },
      "message": "Explanation (only for deny)",
      "interrupt": false
    }
  }
}
```

**Field behavior:**
- `behavior: "allow"` - Grants permission (updatedInput optional)
- `behavior: "deny"` - Denies permission (message required, explain why)
- `interrupt: true` (with deny) - Stops Claude from continuing
- `updatedInput` - Modifies input when allowing

**Example: Deny bash permission in production**
```json
{
  "hookSpecificOutput": {
    "hookEventName": "PermissionRequest",
    "decision": {
      "behavior": "deny",
      "message": "Bash not allowed in production environment",
      "interrupt": true
    }
  }
}
```

---

## PostToolUse / PostToolUseFailure Decision Schema

**Use:** Provide feedback after tool execution, block if critical issues found.

**JSON format:**
```json
{
  "decision": "block|undefined",
  "reason": "Explanation for decision",
  "hookSpecificOutput": {
    "hookEventName": "PostToolUse",
    "additionalContext": "Additional information for Claude"
  }
}
```

**Field behavior:**
- `decision: "block"` - Shows reason to Claude (tool already executed; doesn't prevent execution)
- `decision: undefined/omitted` - No feedback
- `additionalContext` - Adds context to Claude's understanding of result

**Example: Warn if file too large**
```json
{
  "decision": "block",
  "reason": "File size exceeds 1MB. Consider splitting into smaller files.",
  "hookSpecificOutput": {
    "hookEventName": "PostToolUse"
  }
}
```

---

## Stop / SubagentStop Decision Schema

**Use:** Control whether Claude/subagent can stop, provide reason if blocked.

**JSON format:**
```json
{
  "decision": "block|undefined",
  "reason": "Why Claude must continue (required if decision is block)"
}
```

**Field behavior:**
- `decision: "block"` - Prevents stop (must provide reason for Claude to continue)
- `decision: undefined/omitted` - Allows stop

**Example: Block stop if validation incomplete**
```json
{
  "decision": "block",
  "reason": "Validation not complete. Tests still running. Check results before stopping."
}
```

---

## UserPromptSubmit Decision Schema

**Use:** Validate/block user prompts, add context to conversation.

**JSON format:**
```json
{
  "decision": "block|undefined",
  "reason": "Explanation shown to user (only if blocked)",
  "hookSpecificOutput": {
    "hookEventName": "UserPromptSubmit",
    "additionalContext": "Context added to Claude's instructions"
  }
}
```

**Field behavior:**
- `decision: "block"` - Erases prompt from context (reason shown to user only, not Claude)
- `decision: undefined/omitted` - Processes prompt normally
- `additionalContext` - Added to Claude's context (loaded when prompt is processed)

**Fallback: Plain text stdout also adds context**
```bash
#!/bin/bash
# Non-JSON stdout also works for adding context
echo "Current time: $(date)"
echo "Environment: production"
exit 0
```

**Example: Block prompt with secrets**
```json
{
  "decision": "block",
  "reason": "Prompt contains potential secrets. Please remove before submitting."
}
```

---

## SessionStart Decision Schema

**Use:** Add context/environment setup at session start.

**JSON format:**
```json
{
  "hookSpecificOutput": {
    "hookEventName": "SessionStart",
    "additionalContext": "Context loaded into Claude's instructions"
  }
}
```

**Fallback: Plain text stdout**
```bash
#!/bin/bash
echo "Session initialized"
echo "Current branch: $(git branch --show-current)"
exit 0
```

**Multiple hooks concatenate context:**
If multiple SessionStart hooks run, all `additionalContext` values concatenated and added.

---

## Common JSON Output Wrapper

**All hooks can use these optional top-level fields:**
```json
{
  "continue": true,  // Whether to continue after hook (default: true)
  "stopReason": "Message shown to user if continue: false",
  "suppressOutput": false,  // Hide stdout from transcript (default: false)
  "systemMessage": "Warning shown to user"
}
```

---

## Exit Code Behavior (Command Hooks)

**Exit 0 (Success):**
- stdout: Parsed for JSON. If no JSON, added as context (UserPromptSubmit/SessionStart only)
- stderr: Shown in verbose mode only
- Action: Proceeds normally

**Exit 2 (Blocking Error):**
- stdout: Ignored (JSON not parsed)
- stderr: Blocks action and shown to Claude
- Action: Blocked, shown as reason to Claude

**Exit 1, 3, etc. (Non-blocking Error):**
- stdout: Ignored
- stderr: Shown in verbose mode only (not to Claude)
- Action: Proceeds, error logged

---

## Practical Decision Examples

### Example 1: Validate Bash Command (PreToolUse)

Check if command is safe:
```bash
#!/bin/bash
read -r input
command=$(echo "$input" | jq -r '.tool_input.command')

# Reject dangerous patterns
if [[ "$command" =~ rm\ -rf ]]; then
  cat >&2 <<'EOF'
{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "deny",
    "permissionDecisionReason": "Destructive rm -rf command blocked"
  }
}
EOF
  exit 2
fi

exit 0
```

### Example 2: Add Context on Session Start

Load recent changes:
```bash
#!/bin/bash
cat <<'EOF'
{
  "hookSpecificOutput": {
    "hookEventName": "SessionStart",
    "additionalContext": "Recent commits:\n$(git log --oneline -5)"
  }
}
EOF
exit 0
```

### Example 3: Block Unsafe Prompt (UserPromptSubmit)

```bash
#!/bin/bash
read -r input
prompt=$(echo "$input" | jq -r '.prompt')

if [[ "$prompt" =~ password|secret|key ]]; then
  cat <<'EOF'
{
  "decision": "block",
  "reason": "Prompt contains sensitive keywords. Please rephrase without passwords/secrets."
}
EOF
  exit 0
fi

exit 0
```

### Example 4: Prompt Hook Decision (Stop)

```json
{
  "type": "prompt",
  "prompt": "Evaluate if work is complete: ${ARGUMENTS}\n\nRespond with {\"ok\": true} to stop, or {\"ok\": false, \"reason\": \"why continue\"} to continue.",
  "timeout": 30
}
```

LLM response must return:
```json
{
  "ok": true,
  "reason": "All tasks completed"
}
```

Or:
```json
{
  "ok": false,
  "reason": "Tests still need to run"
}
```
