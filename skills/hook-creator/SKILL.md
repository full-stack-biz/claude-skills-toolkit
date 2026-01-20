---
name: hook-creator
description: >-
  Create, validate, and refine Claude Code plugin hooks for automating workflows.
  Use when building new hooks from scratch, validating existing hooks against best
  practices, or improving hook quality for production. Handles command, prompt, and
  agent hook types with event matching, error handling, and safety validation.
version: 1.0.0
allowed-tools: Read,Write,Edit,Glob,Grep,AskUserQuestion
---

# Hook Creator

**Dual purpose:** Create hooks right the first time OR elevate existing hooks to best practices.

## When to Use This Skill

Invoke hook-creator in these scenarios (Claude will guide you through each):

**Creating new hooks:** Building a hook from scratch and need structured guidance so Claude will configure it correctly (hook type, event matching, validation, error handling).

**Validating existing hooks:** Have hooks in your plugin and want to ensure they work reliably (correct event binding, matcher syntax, proper error handling, security).

**Improving hook quality:** Hooks work but may have issues with reliability, performance, or maintainability (refine event matching, optimize command timing, add proper validation).

**Production hooks:** Creating hooks for team/production plugins and need robustness (security review, error handling, testing, monitoring).

**NOT for:** General Claude questions, debugging specific hook failures in running plugins, writing hook scripts directly (focus on configuration/guidance only).

## Why This Exists

**CRITICAL MINDSET:** Hooks are configuration FOR CLAUDE. The question is: "Will this hook trigger reliably and execute safely?" — not cosmetic concerns.

Hook configuration is error-prone: wrong events cause missed triggers, loose matchers cause excessive execution, missing validation causes unsafe execution. hook-creator ensures every hook is optimized for reliability and safety.

## Hook System Essentials

**How hooks execute:**
1. Event fires (tool use, prompt submit, session end, etc.)
2. Matcher evaluates conditions
3. If matched, hook action executes (command, prompt, or agent)
4. Result may block/modify behavior or continue

**Hook types:**
- **command** - Shell scripts (synchronous, fast)
- **prompt** - LLM evaluation using $ARGUMENTS
- **agent** - Verification agent with tool access

**Key constraints:**
- Matchers must be precise (wrong = missed/excessive triggers)
- Commands must be fast (<1s); blocking slows Claude
- Error handling is mandatory; failed hooks can break plugins
- Right event timing is critical (Pre vs Post distinction)

See `references/how-hooks-work.md` for architecture details and `references/event-reference.md` for complete event listing.

## THE EXACT PROMPT

When creating or improving a hook, use this exact request:

```
Use hook-creator to [create/validate/improve] my [hook-name] hook.
Focus on: [specific area - e.g., "event matching", "error handling", "performance"]
```

Examples:
- "Use hook-creator to create my format-on-write hook"
- "Use hook-creator to validate my pre-commit-check hook against best practices"
- "Use hook-creator to improve my post-tool-use hook, focus on performance"

## Workflow by Action

### Create New Hooks
1. Interview user: hook purpose, event type, matcher conditions, action type, error handling needs
2. Use `references/templates.md` to start from appropriate template
3. Configure event → matcher → action → error handling
4. Validate using `references/checklist.md` before completion

### Validate Existing Hooks
1. Follow 7-phase workflow in `references/validation-workflow.md`
2. Check each phase against `references/checklist.md` for gaps
3. Complete all 7 phases before signing off

### Improve Hooks
1. Ask which aspect needs improvement (event, matcher, performance, error handling)
2. Reference `references/checklist.md` for best practices in that area
3. Make targeted fixes rather than rewrites

## Outcome Metrics

Measure success by whether the hook will execute reliably and safely:

✅ **Correct event** - Hook triggers on the right event; understands event timing
✅ **Precise matcher** - Matcher correctly identifies when hook should execute (not too broad, not too narrow)
✅ **Safe action** - Hook action is safe, fast, and doesn't block critical paths
✅ **Error handling** - Hook fails gracefully; includes validation and error messages
✅ **Configuration** - Valid JSON/YAML syntax; correct hook.json structure
✅ **Testing** - Validated with real plugin scenarios; tested both success and failure cases
✅ **Documentation** - Clear comments explaining matcher logic and failure modes

## Quick Start

**Step 1: Pick event** → Choose from: PreToolUse, PostToolUse, UserPromptSubmit, SessionEnd, others (see `references/event-reference.md`)

**Step 2: Define matcher** → Create regex for when hook executes (e.g., `^(Write|Edit)$` for Write/Edit tools)

**Step 3: Choose type & action** → command (script), prompt (LLM), or agent. Set action path/prompt/agent name.

**Step 4: Add error handling** → Set timeout, onError behavior (warn/fail/continue)

**Step 5: Validate** → Run through `references/checklist.md` before deployment

## Refining Existing Hooks

1. Run 7-phase workflow (`references/validation-workflow.md`) to identify issues
2. Use checklist (`references/checklist.md`) to spot gaps
3. Fix in priority order: event → matcher → error handling → performance
4. Re-validate all 7 phases before sign-off

## Reference Files

| File | Purpose |
|------|---------|
| `how-hooks-work.md` | Hook lifecycle, event timing, matcher evaluation, execution model |
| `event-reference.md` | Event documentation (when events fire, available data, timing constraints) |
| `validation-workflow.md` | 7-phase validation process (event, matcher, action, error handling, performance) |
| `checklist.md` | Best practices and validation checklists (creation, validation, troubleshooting) |
| `templates.md` | Copy-paste templates for command, prompt, agent hooks and common patterns |
| `advanced-patterns.md` | Production patterns (conditional execution, fallbacks, monitoring, testing) |

## Core Principles

**Event Correctness** — Right event = right trigger time (Pre vs Post). Wrong event = missed or wrong-time triggers.

**Matcher Precision** — Specific enough to avoid false triggers, broad enough to catch intended cases. Overly broad = performance impact; overly narrow = missed triggers.

**Safe Execution** — Commands must be fast (<1s) and non-blocking. Failed hooks must not crash plugins.

**Error Handling** — All hooks need timeouts, onError behavior, validation. Production hooks need monitoring/logging.

## Key Notes

**Hook structure (plugin.json or .claude-plugin/hooks.json):**
```json
{
  "hooks": {
    "EventName": [{
      "matcher": "pattern",
      "hooks": [{
        "type": "command|prompt|agent",
        "command": "...",
        "timeout": 5000
      }]
    }]
  }
}
```

**Naming:** Describe action + event: `format-on-write`, `validate-before-commit`, `cleanup-on-session-end`

**Event selection:** What action triggers hook? (write, prompt submit, session end) → When should hook respond? (before/after) → Which event? (PreToolUse vs PostToolUse)

**Matcher formula:** "Fire on [EVENT], only when [CONDITIONS]" — e.g., "PostToolUse when Write or Edit tool"

**Production requirements:**
- Timeout mandatory (<5s for sync)
- Error handling with clear messages (onError: warn/fail/continue)
- Test matcher with real scenarios (false triggers are silent failures)
- Version tracking for team coordination

**Deployment:** Plugin-local (`.claude-plugin/hooks.json` or inline) or global (`~/.claude/hooks.json`)

## Advanced Topics

For production hooks: understand event timing → test matchers with real scenarios → design graceful failure modes → ensure fast execution → implement monitoring/logging → track versions for coordination.

Common patterns in `references/templates.md` and `references/advanced-patterns.md`.
