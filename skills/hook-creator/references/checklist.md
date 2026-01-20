# Hook Creation & Validation Checklist

Comprehensive checklist for creating and validating hooks for production use.

## Table of Contents

- [New Hook Creation Checklist](#new-hook-creation-checklist)
- [Existing Hook Validation Checklist](#existing-hook-validation-checklist)
- [Command Hook Specific Checklist](#command-hook-specific-checklist)
- [Prompt Hook Specific Checklist](#prompt-hook-specific-checklist)
- [Agent Hook Specific Checklist](#agent-hook-specific-checklist)
- [Production & Team Hooks Checklist](#production--team-hooks-checklist)
- [Troubleshooting Checklist](#troubleshooting-checklist)
- [Sign-Off Checklist](#sign-off-checklist)

---

## New Hook Creation Checklist

Use this checklist when creating a new hook from scratch.

### Foundation
- [ ] **Hook purpose is clear** - Can describe in 1 sentence what the hook does
- [ ] **Problem it solves** - Why is this hook needed? What problem does it address?
- [ ] **Event selected** - Right event for the hook's purpose (Pre vs Post, which event?)
- [ ] **Matcher criteria defined** - When should hook execute within that event?
- [ ] **Hook type chosen** - Command, prompt, or agent? Why?

### Configuration
- [ ] **Event syntax correct** - Event name matches Claude Code event names
- [ ] **Matcher syntax valid** - Regex is correct, special chars escaped
- [ ] **Matcher tested** - Tested with 3+ scenarios (matches when should, doesn't when shouldn't)
- [ ] **Hook type valid** - "command", "prompt", or "agent"
- [ ] **Action is specified** - Command path, prompt text, or agent reference

### Command Hooks Specific
- [ ] **Script exists** - File path is correct and file exists
- [ ] **Script executable** - Has execute permissions on Unix/Linux
- [ ] **Uses ${CLAUDE_PLUGIN_ROOT}** - Relative path, not hardcoded
- [ ] **Timeout specified** - Has reasonable timeout (e.g., 2000ms)
- [ ] **No shell injection** - Arguments properly quoted/escaped
- [ ] **No network dependencies** - Or documented timeout for network calls
- [ ] **Error output captured** - Script has clear error messages

### Error Handling
- [ ] **onError defined** - Behavior when hook fails (warn, fail, continue)
- [ ] **Validation before execution** - Checks input/state before running
- [ ] **Graceful failure** - Fails without crashing plugin
- [ ] **Error message useful** - User can debug what went wrong
- [ ] **Recovery possible** - Plugin can continue if hook fails

### Integration Safety
- [ ] **No race conditions** - Safe if multiple hooks trigger simultaneously
- [ ] **Idempotent** - Safe to run multiple times without side effects
- [ ] **No file conflicts** - Doesn't collide with other operations
- [ ] **Plugin state assumptions** - Only assumes state that exists
- [ ] **Atomic operations** - File writes are atomic (temp + move)

### Documentation
- [ ] **Comments explain matcher** - Why this specific regex/pattern?
- [ ] **Comments explain action** - What does the command/script do?
- [ ] **Comments explain failure mode** - What happens if hook fails?
- [ ] **Examples provided** - Show when hook triggers and when it doesn't
- [ ] **Version tracked** - Version field added if team/production

### Testing
- [ ] **Real scenario testing** - Tested with actual plugin workflow
- [ ] **Success path tested** - Hook executes correctly when should trigger
- [ ] **Negative path tested** - Hook doesn't execute when shouldn't trigger
- [ ] **Failure path tested** - Hook handles errors gracefully
- [ ] **Performance tested** - Executes in acceptable time (<1s for sync)

---

## Existing Hook Validation Checklist

Use this when validating existing hooks against best practices.

### Phase 1: Event Correctness
- [ ] **Event matches hook purpose** - Right event for what hook does?
- [ ] **Event timing correct** - Pre vs Post makes sense?
- [ ] **Event has needed data** - Required fields available on that event?
- [ ] **No timing assumptions** - Doesn't assume state that doesn't exist?

### Phase 2: Matcher Quality
- [ ] **Matcher syntax valid** - No regex errors or typos
- [ ] **Matcher tested** - Verified with multiple test cases
- [ ] **Not too broad** - Doesn't match unintended cases
- [ ] **Not too narrow** - Matches all intended cases
- [ ] **Performance acceptable** - No expensive regex patterns
- [ ] **Documented** - Comments explain what matcher does

### Phase 3: Hook Type & Action
- [ ] **Hook type appropriate** - Command/prompt/agent fits the action
- [ ] **Action is safe** - No shell injection, data loss, or security risks
- [ ] **Paths are portable** - Uses ${CLAUDE_PLUGIN_ROOT}, not hardcoded
- [ ] **Resources exist** - Referenced scripts/files/agents exist
- [ ] **Permissions correct** - Executable files have execute perms

### Phase 4: Error Handling
- [ ] **Timeout exists** - Prevents hangs (command hooks especially)
- [ ] **onError behavior defined** - Hook knows what to do if it fails
- [ ] **Validation exists** - Checks inputs/state before executing
- [ ] **Error messages clear** - User can understand what went wrong
- [ ] **Plugin survives failure** - Doesn't crash if hook fails
- [ ] **Failure is visible** - User/logs show hook failed

### Phase 5: Performance
- [ ] **Execution time acceptable** - <1s for sync hooks
- [ ] **Trigger frequency reasonable** - Doesn't trigger on every event
- [ ] **Matcher optimized** - No expensive regex patterns
- [ ] **No blocking I/O** - Network calls have timeout
- [ ] **No busy loops** - Doesn't spin waiting for conditions

### Phase 6: Integration
- [ ] **Idempotent** - Safe to run multiple times
- [ ] **Atomic operations** - File operations don't leave partial state
- [ ] **No race conditions** - Safe with concurrent hooks
- [ ] **Plugin state safe** - Only depends on state that exists
- [ ] **File conflicts avoided** - Doesn't collide with other operations
- [ ] **Version tracked** - Version field present if team/production

### Phase 7: Testing
- [ ] **Success case tested** - Verified hook works when should trigger
- [ ] **Negative case tested** - Verified hook doesn't trigger when shouldn't
- [ ] **Error case tested** - Verified graceful failure
- [ ] **Performance tested** - Execution time measured
- [ ] **Integration tested** - Works with other plugin components
- [ ] **Documented in tests** - Test scenarios documented

---

## Command Hook Specific Checklist

Use when creating or validating command hooks.

### Safety
- [ ] **Script exists and is accessible** - File path correct, readable
- [ ] **Script is executable** - Has execute permissions
- [ ] **No hardcoded paths** - Uses ${CLAUDE_PLUGIN_ROOT} for plugin files
- [ ] **No shell injection** - Arguments properly quoted
- [ ] **Inputs validated** - Checks args/env vars before using
- [ ] **No `eval` or `exec`** - Especially with user input
- [ ] **No credentials** - Doesn't hardcode secrets
- [ ] **Timeout enforced** - Won't hang indefinitely

### Reliability
- [ ] **Exit codes correct** - Script uses exit codes properly (0=success)
- [ ] **Error messages to stderr** - Errors written to stderr
- [ ] **Stdout used for output** - Only output goes to stdout
- [ ] **Handles missing deps** - Graceful error if dependencies missing
- [ ] **Idempotent** - Multiple runs don't cause issues
- [ ] **Atomic file ops** - Writes temp file, then moves

### Performance
- [ ] **Script is fast** - <1s for sync operations
- [ ] **No unnecessary overhead** - Startup/teardown is quick
- [ ] **Timeout reasonable** - Not too short (script can't complete), not too long (hangs)
- [ ] **Batch operations** - Doesn't run once per file if can run on all

### Debugging
- [ ] **Verbose logging available** - Can enable debug output
- [ ] **Error messages clear** - User can understand failure
- [ ] **Logs written to file** - For debugging after execution
- [ ] **Script testable standalone** - Can run script directly to test

---

## Prompt Hook Specific Checklist

Use when creating or validating prompt hooks.

### Prompt Quality
- [ ] **Prompt is clear** - Claude understands what to evaluate
- [ ] **Context included** - Prompt has $ARGUMENTS for context
- [ ] **Specific instructions** - What should Claude decide?
- [ ] **Output format defined** - How should Claude respond?
- [ ] **Examples provided** - Helps Claude understand task
- [ ] **Not over-scoped** - Single decision, not multiple

### Reliability
- [ ] **Consistent responses** - Prompt design leads to predictable outputs
- [ ] **Error handling** - What if LLM returns unexpected format?
- [ ] **Fallback behavior** - What if prompt evaluation fails?
- [ ] **Token cost reasonable** - Prompt is concise enough

### Integration
- [ ] **$ARGUMENTS placeholder used** - Context passed to prompt
- [ ] **Output parsing safe** - Can handle various response formats
- [ ] **Blocking tolerated** - LLM call can add latency
- [ ] **Async if long-running** - Doesn't block if evaluation slow

---

## Agent Hook Specific Checklist

Use when creating or validating agent hooks.

### Agent Setup
- [ ] **Agent exists** - Referenced agent is defined in plugin
- [ ] **Agent has tools** - Has necessary tools for verification
- [ ] **Tool scoping appropriate** - Only needed tools available
- [ ] **No dangerous tools** - Doesn't have Bash, network access unnecessarily

### Reliability
- [ ] **Agent trained on task** - Instructions clear for verification
- [ ] **Fallback defined** - What if agent can't decide?
- [ ] **Timeout specified** - Prevents runaway verification
- [ ] **Error handling** - What if agent crashes?

### Performance
- [ ] **Verification is fast** - <5s typical for verification
- [ ] **Async if needed** - Can block if verification takes time
- [ ] **Tool limits set** - Agent has iteration limits

### Integration
- [ ] **Result interpretation** - Clear how agent response affects hook behavior
- [ ] **Safe to fail** - Plugin continues if agent fails
- [ ] **Audit trail** - Can see why verification passed/failed

---

## Production & Team Hooks Checklist

Use when creating hooks for production or team use.

### Code Quality
- [ ] **Version tracked** - Version field in hook metadata
- [ ] **Changelog maintained** - Document changes between versions
- [ ] **Code reviewed** - Peer review before deployment
- [ ] **Security reviewed** - Checked for injection, privilege issues
- [ ] **Well commented** - Clear for other team members

### Testing & Validation
- [ ] **Unit tested** - Script/agent tested independently
- [ ] **Integration tested** - Works with other plugin hooks
- [ ] **Stress tested** - Works with high frequency triggers
- [ ] **Failure cases tested** - All error paths verified
- [ ] **Real scenario tested** - Validated with actual plugin workflow
- [ ] **Regression tested** - New hooks don't break existing functionality

### Documentation
- [ ] **README updated** - Documented for team
- [ ] **Hook purpose clear** - Why does this hook exist?
- [ ] **Event explained** - Why this event?
- [ ] **Configuration documented** - How to configure hook
- [ ] **Troubleshooting guide** - Common issues and fixes
- [ ] **Version history** - Changes tracked across versions

### Monitoring & Maintenance
- [ ] **Logging implemented** - Hook execution logged
- [ ] **Metrics tracked** - Success/failure rates monitored
- [ ] **Alerts configured** - Team notified of failures
- [ ] **Update procedure** - How to deploy new hook versions
- [ ] **Rollback procedure** - How to disable broken hooks

---

## Troubleshooting Checklist

If a hook isn't working, use this checklist to diagnose:

### Hook Doesn't Trigger
- [ ] Event correct? - Check against event reference
- [ ] Matcher syntax valid? - Test regex separately
- [ ] Matcher too specific? - Overly narrow pattern?
- [ ] Hook enabled? - Check plugin.json has hook enabled
- [ ] Event has data? - Check event fires at all

### Hook Triggers Too Often
- [ ] Matcher too broad? - Does `.*` match everything?
- [ ] Correct event? - Running on too many events?
- [ ] Conditional logic needed? - Should trigger only sometimes?

### Hook Fails Silently
- [ ] Error logging missing? - No way to see failures
- [ ] onError behavior? - Set to continue instead of fail?
- [ ] Timeout too short? - Does script need more time?
- [ ] Missing dependencies? - Script depends on things not available?

### Hook Slows Plugin Down
- [ ] Timeout too long? - Set longer timeout than needed?
- [ ] Sync vs async? - Blocking operation when async better?
- [ ] Expensive matcher? - Complex regex on every event?
- [ ] Command itself slow? - Optimize script performance

### Hook Causes Plugin Crash
- [ ] Unhandled error? - Doesn't have error handling
- [ ] State corruption? - Modifying plugin state unsafely
- [ ] Permission issue? - Trying to write where can't
- [ ] Race condition? - Colliding with other hooks

---

## Sign-Off Checklist

Before deploying hook to production:

- [ ] All 7 validation phases passed
- [ ] All relevant checklists reviewed
- [ ] Peer review completed
- [ ] Security review completed
- [ ] Testing complete (success, negative, error cases)
- [ ] Documentation complete
- [ ] Monitoring/logging set up
- [ ] Rollback procedure documented
- [ ] Team notified of deployment
