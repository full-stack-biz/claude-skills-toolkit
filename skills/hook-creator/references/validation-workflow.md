# Hook Validation Workflow

Systematic 7-phase process to validate hooks for correctness, reliability, and production-readiness.

## Table of Contents

- [Phase 1: Event Correctness](#phase-1-event-correctness)
- [Phase 2: Matcher Analysis](#phase-2-matcher-analysis)
- [Phase 3: Hook Type & Action](#phase-3-hook-type--action)
- [Phase 4: Error Handling](#phase-4-error-handling)
- [Phase 5: Performance Impact](#phase-5-performance-impact)
- [Phase 6: Integration & Side Effects](#phase-6-integration--side-effects)
- [Phase 7: Testing & Documentation](#phase-7-testing--documentation)
- [Validation Checklist](#validation-checklist)
- [Common Hook Patterns](#common-hook-patterns)
- [When a Hook Fails Validation](#when-a-hook-fails-validation)

---

## Phase 1: Event Correctness

**Question:** Is the hook attached to the right event?

| Event | When It Fires | Best For | Common Mistakes |
|-------|---------------|----------|-----------------|
| PreToolUse | Before any tool executes | Validation, blocking | Waiting for result (use PostToolUse) |
| PostToolUse | After tool succeeds | Formatting, logging | Trying to block (use PreToolUse) |
| PostToolUseFailure | After tool fails | Error recovery, logging | Modifying failed result (immutable) |
| UserPromptSubmit | After user submits prompt | Parsing, validation | Blocking Claude (async only) |
| SessionStart | Session begins | Initialization, setup | Assuming environment ready |
| SessionEnd | Session ends | Cleanup, teardown | Trying to modify session state |
| PreCompact | Before history compaction | Backup, archiving | Modifying compact operation |
| PermissionRequest | Permission dialog shown | Approval workflow | Blocking user interaction |
| Notification | Claude sends notification | Routing, filtering | Modifying notification |

**Validation steps:**
1. What is the hook's primary purpose? (What problem does it solve?)
2. When should it execute? (Before/after what action?)
3. Which event matches that timing?
4. Can this hook achieve its goal on that event?

**Pass criteria:** Event selection makes logical sense for hook's purpose. Timing (Pre vs Post) is correct.

---

## Phase 2: Matcher Analysis

**Question:** Will the hook trigger at the right times (not too often, not too rarely)?

**Validation steps:**
1. What conditions must be true for hook to execute? (e.g., "Write or Edit tool used")
2. Is the matcher syntactically correct? (Valid regex, correct operator syntax)
3. Does matcher use correct tool/field names? (Check against hook event data)
4. Is matcher too broad? (Will it trigger unwanted times?)
5. Is matcher too narrow? (Will it miss intended cases?)

**Common matcher mistakes:**
- `.*` - Matches everything (performance killer)
- `Write` (no anchors) - May match unexpected tools like "DeviceWrite"
- `^(Write|Edit)$` - Correct: matches exactly Write or Edit
- Tool names wrong - Check event reference for available fields
- Regex syntax errors - Invalid patterns fail silently

**Example validation:**
```json
{
  "matcher": "^(Write|Edit)$",  // ✓ Precise: Write or Edit exactly
  "hooks": [...]
}
```

**Pass criteria:** Matcher is syntactically valid, specific enough to avoid false triggers, and matches intended use cases. Tested with multiple scenarios.

---

## Phase 3: Hook Type & Action

**Question:** Is the hook type appropriate for the action?

| Hook Type | Use Cases | Safety Concerns | Common Issues |
|-----------|-----------|-----------------|---------------|
| command | Validation, formatting, cleanup | Command injection, timeouts, shell escaping | Missing timeout, unsanitized input |
| prompt | LLM-based decisions, logic | Token cost, latency, consistency | Vague prompts, missing context |
| agent | Complex workflows, verification | Token cost, tool access, error states | Over-scoped tools, missing fallback |

**Validation steps:**
1. Is hook type appropriate for action? (Why command vs prompt vs agent?)
2. Is the action safe to execute? (No shell injection, no data loss)
3. Are inputs sanitized? (Command hooks: escape shell args)
4. Is there a timeout? (Prevent hangs)
5. What happens if action fails?

**Command hook safety checklist:**
- Uses `${CLAUDE_PLUGIN_ROOT}` for paths (not hardcoded)
- Arguments are properly quoted
- Script exists and is executable
- No network dependencies (should fail fast)
- Timeout < 5 seconds for blocking operations

**Pass criteria:** Hook type matches action, action is safe, timeout is reasonable, failure mode is clear.

---

## Phase 4: Error Handling

**Question:** Will hook fail gracefully without breaking plugin?

**Validation steps:**
1. What can fail? (Command timeout, network error, script crash, invalid input)
2. Is there validation before action executes?
3. What happens if action fails? (Warn, block, continue?)
4. Is error message useful? (Can user debug?)
5. Can plugin recover?

**Error scenarios to consider:**
- Command timeout (script hangs)
- Command exits with error (non-zero exit code)
- Matcher fails to evaluate (invalid syntax)
- Hook configuration error (wrong JSON)
- Missing script/resource (path doesn't exist)
- Permission denied (script not executable)

**Example error handling:**
```json
{
  "type": "command",
  "command": "${CLAUDE_PLUGIN_ROOT}/scripts/format.sh",
  "timeout": 5000,
  "onError": "warn"
}
```

**Pass criteria:** Hook has timeout, onError behavior defined, and fails without crashing plugin. Error is logged/visible.

---

## Phase 5: Performance Impact

**Question:** Will hook slow down Claude Code noticeably?

**Validation steps:**
1. Is hook synchronous or async? (Sync = blocks Claude)
2. How long does hook action take? (<1s preferred for sync)
3. How often does hook trigger? (Every tool use = high frequency)
4. Is there conditional logic to skip unnecessary execution?
5. Is matcher optimized? (Avoid `.*` or expensive regex)

**Performance red flags:**
- Sync network calls (command hook hitting API)
- Expensive regex matchers (complex patterns on every event)
- Frequent triggers (e.g., PostToolUse on every single tool)
- No timeout (runaway processes)
- Blocking operations in tight loops

**Example: Too slow**
```json
{
  "event": "PostToolUse",
  "matcher": ".*",  // Triggers on EVERY tool use
  "hooks": [{
    "type": "command",
    "command": "curl https://api.example.com/..."  // Network call, no timeout
  }]
}
```

**Example: Better**
```json
{
  "event": "PostToolUse",
  "matcher": "^(Write|Edit)$",  // Specific to Write/Edit only
  "hooks": [{
    "type": "command",
    "command": "${CLAUDE_PLUGIN_ROOT}/scripts/format.sh",
    "timeout": 2000
  }]
}
```

**Pass criteria:** Hook executes quickly (<1s), doesn't trigger excessively, matcher is efficient. No noticeable slowdown.

---

## Phase 6: Integration & Side Effects

**Question:** Will hook interact safely with plugin and other hooks?

**Validation steps:**
1. Does hook assume plugin state? (Will state exist?)
2. Does hook modify file system? (Could collide with other operations?)
3. Could multiple hooks trigger simultaneously? (Race conditions?)
4. Does hook depend on other hooks? (Order dependency?)
5. Is hook idempotent? (Safe to run multiple times?)

**Common integration issues:**
- Hook modifies file, then another hook reads stale version
- Hook assumes directory exists (not created yet)
- Two hooks write same file concurrently (data loss)
- Hook expects specific plugin state (might not exist)

**Example: Safer integration**
```json
{
  "type": "command",
  "command": "${CLAUDE_PLUGIN_ROOT}/scripts/format.sh",
  "timeout": 2000
}
```
- Uses plugin root (relative, portable)
- Creates temp file, then moves (atomic)
- Idempotent (safe to run multiple times)
- Checks file existence before modifying

**Pass criteria:** Hook is idempotent, uses atomic operations, doesn't assume external state, safe with concurrent execution.

---

## Phase 7: Testing & Documentation

**Question:** Has hook been tested? Is it documented?

**Validation steps:**
1. Hook tested with real plugin scenarios? (Not just config validation)
2. Tested matcher with multiple cases? (True positives and negatives)
3. Tested failure case? (What if action fails?)
4. Tested performance? (Reasonable execution time?)
5. Is hook documented? (Comments explaining matcher, action, failure mode)

**Test scenarios for format-on-write hook:**
```
✓ Write to .js file → matcher matches → hook executes → formatting applied
✗ Read from .js file → matcher fails → hook doesn't execute
✗ Write to .txt file → matcher fails → hook doesn't execute
✓ Format fails → timeout or error → logged, Claude continues
```

**Documentation example:**
```json
{
  "matcher": "^(Write|Edit)$",  // Trigger on Write/Edit tools only
  "hooks": [{
    "type": "command",
    "command": "${CLAUDE_PLUGIN_ROOT}/scripts/format.sh",
    "timeout": 2000
    // Formats code after file write. Fails gracefully (onError: warn).
    // Matcher specific to Write/Edit to avoid excessive triggers.
  }]
}
```

**Pass criteria:** Hook tested with real scenarios, handles both success and failure cases, documented clearly.

---

## Validation Checklist

Use this checklist for each phase:

- [ ] Phase 1: Event correct for hook's purpose
- [ ] Phase 2: Matcher is precise and syntactically valid
- [ ] Phase 3: Hook type matches action, action is safe, timeout exists
- [ ] Phase 4: Error handling defined, hook fails gracefully
- [ ] Phase 5: Hook executes quickly, doesn't trigger excessively
- [ ] Phase 6: Hook is idempotent, safe with concurrent execution
- [ ] Phase 7: Hook tested with real scenarios, documented

---

## Common Hook Patterns

### Pattern: Format on Write
```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "^(Write|Edit)$",
        "hooks": [{
          "type": "command",
          "command": "${CLAUDE_PLUGIN_ROOT}/scripts/format.sh",
          "timeout": 2000
        }]
      }
    ]
  }
}
```

### Pattern: Validate Before Commit
```json
{
  "hooks": {
    "UserPromptSubmit": [
      {
        "matcher": "commit|push",  // Text match in prompt
        "hooks": [{
          "type": "command",
          "command": "${CLAUDE_PLUGIN_ROOT}/scripts/pre-commit-check.sh",
          "timeout": 5000
        }]
      }
    ]
  }
}
```

### Pattern: Cleanup on Session End
```json
{
  "hooks": {
    "SessionEnd": [
      {
        "matcher": ".*",  // Matches all sessions
        "hooks": [{
          "type": "command",
          "command": "${CLAUDE_PLUGIN_ROOT}/scripts/cleanup.sh",
          "timeout": 3000
        }]
      }
    ]
  }
}
```

---

## When a Hook Fails Validation

If a hook doesn't pass all 7 phases:

1. **Identify the phase** - Which phase failed?
2. **Understand the issue** - Why did it fail?
3. **Fix the root cause** - Adjust hook configuration or action
4. **Re-validate that phase** - Verify fix works
5. **Re-run full validation** - Other phases may be affected

Example: Hook times out during Phase 5 (performance)
- Root cause: Slow script or network dependency
- Fix: Optimize script or add faster timeout
- Re-validate: Does it still execute correctly? Is new timing acceptable?
