# How Hooks Work in Claude Code

Complete architectural understanding of the hook system for creating reliable hooks.

## Table of Contents

- [Hook Lifecycle](#hook-lifecycle)
- [Event System](#event-system)
  - [Available Events](#available-events)
  - [Event Timing Diagram](#event-timing-diagram)
- [Matcher System](#matcher-system)
  - [How Matchers Work](#how-matchers-work)
  - [Matcher Types](#matcher-types)
  - [Matcher Evaluation](#matcher-evaluation)
  - [Common Matcher Mistakes](#common-matcher-mistakes)
- [Hook Types & Actions](#hook-types--actions)
  - [Command Hooks](#command-hooks)
  - [Prompt Hooks](#prompt-hooks)
  - [Agent Hooks](#agent-hooks)
- [Hook Execution Model](#hook-execution-model)
  - [Synchronous (Blocking)](#synchronous-blocking)
  - [Asynchronous (Non-blocking)](#asynchronous-non-blocking)
- [Hook Result & onError](#hook-result--onerror)
  - [onError Behaviors](#onerror-behaviors)
  - [Result Flow](#result-flow)
- [Hook Ordering](#hook-ordering)
- [Hook Context & $ARGUMENTS](#hook-context--arguments)
  - [Placeholder: ${ARGUMENTS}](#placeholder-arguments)
- [Hook Safety & Security](#hook-safety--security)
  - [What hooks CAN'T do](#what-hooks-cant-do)
  - [What hooks CAN do](#what-hooks-can-do)
  - [Security Best Practices](#security-best-practices)
- [Performance Considerations](#performance-considerations)
  - [Typical Hook Latencies](#typical-hook-latencies)
  - [Impact on Claude](#impact-on-claude)
  - [Optimization Strategies](#optimization-strategies)
- [Debugging Hooks](#debugging-hooks)

---

## Hook Lifecycle

```
┌─────────────────────────────────────────────────────────────┐
│ Claude Code Event Occurs (e.g., User Submits Prompt)       │
└──────────────────────────┬──────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────┐
│ Claude Code Checks Registered Hooks for Event               │
│ (e.g., UserPromptSubmit hooks registered?)                 │
└──────────────────────────┬──────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────┐
│ For Each Hook, Evaluate Matcher Against Event Data          │
│ (Does pattern match? Is tool in list? Is text present?)    │
└──────────────────┬──────────────────────────────────────────┘
                   │
        ┌──────────┴──────────┐
        │                     │
        ▼                     ▼
   Matcher Match         No Match
   (Continue)            (Skip Hook)
        │
        ▼
┌─────────────────────────────────────────────────────────────┐
│ Execute Hook Action (Command/Prompt/Agent)                  │
│ (Run script, call LLM, verify with agent)                  │
└──────────────────┬──────────────────────────────────────────┘
                   │
        ┌──────────┴──────────┐
        │                     │
        ▼                     ▼
   Action Success        Action Failed
   (Proceed)             (Check onError)
        │                     │
        ▼                     ▼
   Normal Flow         ┌──────────────┐
                       │ onError:     │
                       │ - warn       │
                       │ - fail       │
                       │ - continue   │
                       └──────────────┘
```

## Event System

### Available Events

**Tool-related:**
- **PreToolUse** - Before any tool executes
  - Data: tool name, arguments
  - Use: Block dangerous operations, validate inputs
  - Blocking: Can prevent tool from running

- **PostToolUse** - After tool succeeds
  - Data: tool name, result, execution time
  - Use: Post-processing (format files, log activity)
  - Blocking: No (tool already executed)

- **PostToolUseFailure** - After tool fails
  - Data: tool name, error, execution time
  - Use: Error recovery, logging
  - Blocking: No (result already failed)

**Prompt-related:**
- **UserPromptSubmit** - After user submits prompt
  - Data: prompt text, context
  - Use: Validation, parsing, filtering
  - Blocking: Can prevent Claude from processing

**Session-related:**
- **SessionStart** - Session begins
  - Data: session metadata
  - Use: Initialization, setup
  - Blocking: No

- **SessionEnd** - Session ends
  - Data: session summary
  - Use: Cleanup, archiving, logging
  - Blocking: No

- **PreCompact** - Before history is compacted
  - Data: history data
  - Use: Backup, archiving
  - Blocking: Can prevent compaction

**Permission-related:**
- **PermissionRequest** - Permission dialog shown
  - Data: permission being requested
  - Use: Approval workflow, audit
  - Blocking: Can approve/deny

**Other:**
- **Notification** - Claude sends notification
  - Data: notification message
  - Use: Routing, filtering, logging
  - Blocking: No

- **Stop** - Claude attempts to stop
  - Data: reason for stop
  - Use: Cleanup, logging
  - Blocking: Can prevent stop

- **SubagentStart** - Subagent starts
  - Data: subagent info
  - Use: Monitoring, logging
  - Blocking: Can prevent start

- **SubagentStop** - Subagent stops
  - Data: subagent info
  - Use: Cleanup, logging
  - Blocking: Can prevent stop

### Event Timing Diagram

```
Session Timeline:
┌──────────────────────────────────────────────────────────┐
│ SessionStart
│ (Now accepting hooks)
├──────────────────────────────────────────────────────────┤
│ User Submits Prompt
│ ├─ UserPromptSubmit hooks (validate input)
│ ├─ Claude processes prompt
│ │
│ ├─ Claude uses tools:
│ │  ├─ PreToolUse hooks (validate/block)
│ │  ├─ Tool executes
│ │  ├─ PostToolUse hooks (format/log) OR
│ │     PostToolUseFailure hooks (if error)
│ │
│ ├─ More tools... (repeat above)
│ │
│ └─ Response complete
├──────────────────────────────────────────────────────────┤
│ More user prompts...
├──────────────────────────────────────────────────────────┤
│ Session compaction needed
│ ├─ PreCompact hooks (backup/archive)
│ ├─ History compacted
├──────────────────────────────────────────────────────────┤
│ SessionEnd
│ ├─ Final hooks (cleanup)
└──────────────────────────────────────────────────────────┘
```

## Matcher System

### How Matchers Work

Matchers are conditions that determine if a hook should execute when an event occurs.

```
Event fires with data:
{
  "tool": "Write",
  "file": "src/index.js",
  "content": "..."
}

Matcher: "^(Write|Edit)$"
         ↓
Does pattern "^(Write|Edit)$" match tool "Write"?
         ↓
         YES → Execute hook
         ↓
Hook action runs
```

### Matcher Types

**Regex patterns** (most common):
```json
{
  "matcher": "^(Write|Edit)$"  // Regex: Write OR Edit
}
```

**Text patterns** (substring match):
```json
{
  "matcher": "commit"  // Matches any prompt containing "commit"
}
```

**Tool patterns** (specific to tool events):
```json
{
  "matcher": "Bash"  // PreToolUse/PostToolUse: matches Bash tool
}
```

### Matcher Evaluation

| Matcher | Event Data | Result | Reason |
|---------|-----------|--------|--------|
| `^Write$` | Tool: Write | ✓ Match | Exact match |
| `^Write$` | Tool: WriteFile | ✗ No match | `^...$` requires exact |
| `Write` | Tool: WriteFile | ✓ Match | Substring match |
| `^(Write\|Edit)$` | Tool: Read | ✗ No match | Not in list |
| `.*` | Any tool | ✓ Match | Matches everything (dangerous!) |
| `\.js$` | File: test.js | ✓ Match | File ends in .js |
| `\.js$` | File: test.ts | ✗ No match | Wrong extension |
| `commit\|push` | Prompt: "git commit" | ✓ Match | Contains "commit" |

### Common Matcher Mistakes

❌ **Too broad:**
```json
{
  "matcher": ".*"  // Matches EVERYTHING
}
```
Every event triggers the hook. Performance killer.

❌ **Wrong anchors:**
```json
{
  "matcher": "Write"  // Also matches "DeviceWrite", "NetworkWrite"
}
```
Use `^Write$` to match exactly.

❌ **Typos:**
```json
{
  "matcher": "Writ"  // Doesn't match "Write"
}
```
Test your regex.

✓ **Correct:**
```json
{
  "matcher": "^(Write|Edit)$"  // Exact: Write OR Edit only
}
```

## Hook Types & Actions

### Command Hooks

**What it does:** Runs shell commands/scripts

```json
{
  "type": "command",
  "command": "${CLAUDE_PLUGIN_ROOT}/scripts/format.sh",
  "timeout": 2000,
  "env": {
    "DEBUG": "true"
  }
}
```

**Execution model:**
1. Command spawned as subprocess
2. Script runs with environment variables
3. Stdout/stderr captured
4. Exit code checked (0 = success, non-zero = error)
5. Returns within timeout or killed

**Use cases:**
- Format code (prettier, black)
- Validate files (linters)
- Git operations (commit, push)
- Build/test commands

**Performance implications:**
- Spawning process = ~50-100ms overhead
- Script execution = depends on script
- Total typical: <1s for fast operations
- Timeout prevents hangs (critical)

### Prompt Hooks

**What it does:** Sends context to LLM and gets decision

```json
{
  "type": "prompt",
  "prompt": "Is this code safe to deploy? Answer YES or NO. Context: ${ARGUMENTS}",
  "timeout": 10000
}
```

**Execution model:**
1. Prompt constructed with context (${ARGUMENTS})
2. LLM called via Claude API
3. Response parsed
4. Hook outcome determined from response
5. Returns within timeout or times out

**Use cases:**
- Code review decisions
- Security checks
- Quality gates
- Custom validation logic

**Performance implications:**
- LLM API call = ~2-10 seconds typically
- Context tokens cost (every input token)
- Response parsing = negligible
- Async recommended (can be slow)

### Agent Hooks

**What it does:** Runs verification agent with tools

```json
{
  "type": "agent",
  "agent": "security-verifier",
  "timeout": 15000
}
```

**Execution model:**
1. Agent initialized with available tools
2. Agent runs verification workflow
3. Agent can use tools to check conditions
4. Agent returns decision
5. Hook outcome determined from decision
6. Returns within timeout or times out

**Use cases:**
- Complex verification workflows
- Multi-step validation
- Conditional logic (if X then check Y)
- Sophisticated decision-making

**Performance implications:**
- Agent setup = ~100-200ms
- Tool use = depends on tools (could be slow)
- Multiple iterations possible
- Async recommended (potentially slow)

## Hook Execution Model

### Synchronous (Blocking)

Hook executes, Claude waits for result before proceeding.

```
User submits prompt
    ↓
UserPromptSubmit event
    ↓
Hook matcher evaluates
    ↓
Hook action executes (command/prompt/agent)
    ↓ (Claude waits here)
Action completes or times out
    ↓
Claude continues or fails based on onError
```

**Good for:** Fast operations (<1s), validation that must complete before proceeding

**Bad for:** Slow operations (network calls), can slow Claude significantly

### Asynchronous (Non-blocking)

Hook executes in background, Claude continues immediately. Enable with `async: true` in hook config.

```
User submits prompt
    ↓
UserPromptSubmit event
    ↓
Hook matcher evaluates
    ↓
Hook action starts in background
    ↓
Claude continues immediately
    ↓ (meanwhile, hook completes in background)
Hook result processed (logged, etc.)
```

**Configuration:**
```json
{
  "type": "command",
  "command": "...",
  "async": true,      // Enable background execution
  "onError": "warn"   // Recommended for async (doesn't affect execution)
}
```

**Good for:**
- Slow operations (network, file I/O, complex verification)
- Logging/auditing (doesn't need to block execution)
- Notifications (Slack, email, webhooks)
- Telemetry/metrics collection
- Cleanup tasks (don't need result before proceeding)

**Bad for:** Critical validation that must pass/fail (use sync for that)

**Important:** Async hooks don't return decision data; use only for side-effects, not for validation/blocking.

## Hook Result & onError

### onError Behaviors

**"warn"** (default for non-blocking):
```json
{
  "type": "command",
  "command": "...",
  "onError": "warn"
}
```
- Hook fails → Error logged as warning
- Claude continues
- Plugin not affected
- Use when failure is acceptable

**"fail"** (for critical validation):
```json
{
  "type": "command",
  "command": "...",
  "onError": "fail"
}
```
- Hook fails → Error raised
- Claude stops (for blocking hooks)
- Hook failure becomes Claude failure
- Use for validation that must pass

**"continue"** (silent failure):
```json
{
  "type": "command",
  "command": "...",
  "onError": "continue"
}
```
- Hook fails → Silently ignored
- Claude continues as if nothing happened
- Use only when error is expected/handled

### Result Flow

```
Hook Execution
    ↓
┌───┴────┐
│        │
Success  Failure
│        │
└───┬────┘
    ↓
Check onError
    ↓
┌───┬───┬────────┐
│   │   │        │
warn fail continue
│   │   │
└─┬─┴─┬─┴────────┐
  │   │         │
  ▼   ▼         ▼
 Log Fail    Silent
 Continue Block Continue
```

## Hook Ordering

When multiple hooks match the same event:

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "^(Write|Edit)$",
        "hooks": [
          {"type": "command", "command": "format.sh"},   // Runs first
          {"type": "command", "command": "lint.sh"},     // Runs second
          {"type": "command", "command": "test.sh"}      // Runs third
        ]
      }
    ]
  }
}
```

**Execution order:** Top to bottom, sequential

**Important:** Each hook failure can cascade. Use `onError: "warn"` to prevent cascade.

## Hook Context & $ARGUMENTS

### Placeholder: ${ARGUMENTS}

In prompt and agent hooks, `${ARGUMENTS}` gets replaced with event context:

```json
{
  "type": "prompt",
  "prompt": "Review this code: ${ARGUMENTS}"
}
```

**For UserPromptSubmit:**
```
${ARGUMENTS} = The user's prompt text
```

**For PostToolUse:**
```
${ARGUMENTS} = Tool name, result, execution time
```

**For PreCompact:**
```
${ARGUMENTS} = History summary
```

See event reference for what context is available for each event.

## Hook Safety & Security

### What hooks CAN'T do

- ❌ Access Claude's internal state (readonly)
- ❌ Modify Claude Code settings without permission
- ❌ Start/stop Claude Code externally
- ❌ Access user's other data without permission

### What hooks CAN do

- ✓ Run shell commands (use carefully!)
- ✓ Read/write plugin files
- ✓ Call external APIs
- ✓ Modify event data (immutable in some cases)

### Security Best Practices

1. **Validate inputs:**
   ```bash
   if [[ ! "$FILE" =~ ^[a-z0-9._-]+$ ]]; then
     echo "Invalid filename" >&2
     exit 1
   fi
   ```

2. **No shell injection:**
   ```bash
   # Bad
   command = "script.sh $user_input"

   # Good
   command = "script.sh"
   args = [user_input]  # Passed safely
   ```

3. **Limit tool access:**
   - Agent hooks should have minimal tool access
   - Don't give agents Bash if not needed

4. **Timeouts everywhere:**
   ```json
   {
     "command": "...",
     "timeout": 5000  // Always set
   }
   ```

## Performance Considerations

### Typical Hook Latencies

| Hook Type | Typical Time | Max Recommended | Use Case |
|-----------|-------------|-----------------|----------|
| Command (format) | 0.2-1s | 2s | Format code |
| Command (lint) | 0.5-2s | 3s | Validate |
| Command (test) | 2-10s | 15s | Run tests |
| Prompt (simple) | 2-8s | 10s | Decision |
| Prompt (complex) | 5-15s | 20s | Analysis |
| Agent (simple) | 3-10s | 15s | Verification |
| Agent (complex) | 10-30s | 45s | Complex workflow |

### Impact on Claude

```
PostToolUse hook with 2s timeout:
- User writes file
- Hook runs 2 seconds
- Claude waits 2 seconds
- Claude continues

Frequency impact:
- If writes files 10 times: +20 seconds total
- If writes files 100 times: +200 seconds (significant!)

Solution: Be specific with matchers to reduce trigger frequency
```

### Optimization Strategies

1. **Reduce matcher breadth:**
   ```json
   {
     "matcher": "^(Write|Edit)$"  // Specific
   }
   vs
   {
     "matcher": ".*"  // Slow: matches everything
   }
   ```

2. **Use async when possible:**
   - Formatting: can be async (result doesn't matter immediately)
   - Validation: should be sync (result needed)

3. **Cache results:**
   - Script: cache previous results if file unchanged
   - Prompt: cache if input same

4. **Optimize scripts:**
   - Make scripts as fast as possible
   - Use timeouts to kill slow operations
   - Avoid network calls without timeouts

## Debugging Hooks

### Hook not triggering?

1. Check event occurs (add logging to script)
2. Check matcher is correct (test regex separately)
3. Check hook is enabled (verify plugin.json)
4. Check event data matches (might not have expected field)

### Hook triggers too often?

1. Matcher too broad (check for `.*`)
2. Wrong event (maybe other event triggers more?)
3. Add conditional logic to script

### Hook slow?

1. Measure: run script directly vs in hook
2. Reduce trigger frequency (more specific matcher)
3. Optimize script (remove unnecessary work)
4. Use timeout to kill slow operations

### Hook fails silently?

1. Check logs (where is output going?)
2. Add logging to script
3. Change onError to "warn" to see errors
4. Test script standalone

### Multiple hooks colliding?

1. Check execution order (top to bottom)
2. Use temp files, atomic writes
3. Add delays/locks if needed
4. Test with concurrent execution
