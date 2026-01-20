---
name: hook-creator
description: >-
  Create, validate, and refine Claude Code plugin hooks for automating workflows.
  Use when building new hooks from scratch, validating existing hooks against best
  practices, or improving hook quality for production. Handles command hooks (shell scripts),
  prompt hooks (LLM-based decisions), event matching, JSON decision schemas, and safety validation.
version: 2.0.3
allowed-tools: Read,Write,Edit,Glob,Grep,AskUserQuestion
---

# Hook Creator

**Dual purpose:** Create hooks right the first time OR elevate existing hooks to best practices.

## Quick Routing

Use AskUserQuestion to gather requirements, then proceed to the appropriate section below:

1. Ask what the user wants to do (create/validate/refine)
2. Ask for the hook name or description based on the action
3. Route to the appropriate workflow section

---

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

**Hook lifecycle:**
1. Event fires (tool use, prompt submit, session end, etc.)
2. Matcher (regex/text) evaluated against event data
3. If matched, hook action executes (command or prompt)
4. Action returns decision (allow/deny/block) or data (context/error)
5. Claude Code acts on decision (proceed/block/continue)

**Hook types and when to use:**
- **command** - Execute shell scripts for deterministic logic, validation, formatting
- **prompt** - Send event context to LLM for intelligent decisions (only for Stop, SubagentStop, UserPromptSubmit, PermissionRequest, PreToolUse)

**Event data and matchers:**
- Events fire with context data (tool name, arguments, results, timestamps)
- Matchers are case-sensitive regex patterns: `^(Write|Edit)$` matches exactly, `\.js$` matches files, `.*` matches all
- Some events (Stop, SessionEnd, UserPromptSubmit) don't require matchers (omit field entirely)
- MCP tools use special names: `mcp__<server>__<tool>` (e.g., `mcp__memory__create_entities`)

**Decision schemas:**
Each event supports specific decision fields for returning control:
- PreToolUse: `permissionDecision` (allow/deny/ask), `updatedInput`, `additionalContext`
- PermissionRequest: `behavior` (allow/deny), `updatedInput`, `message`, `interrupt`
- PostToolUse/PostToolUseFailure: `decision` (block), `additionalContext`
- Stop/SubagentStop: `decision` (block), `reason`
- UserPromptSubmit: `decision` (block), `additionalContext`
- SessionStart: `additionalContext`

**Exit codes (for command hooks):**
- 0 = Success; stdout shown in verbose mode (UserPromptSubmit/SessionStart add to context)
- 2 = Blocking error; stderr blocks action and shown to Claude
- Other = Non-blocking error; stderr shown in verbose mode only

**Critical constraints:**
- Matchers must be precise (broad matchers = performance impact, missed triggers = silent failures)
- Commands must be fast (<1s); blocking slows Claude proportionally by frequency
- Prompt hooks make API calls (~2-10s); use for Stop/SubagentStop where speed less critical
- Error handling mandatory; failed hooks can break plugin if onError not set

See `references/how-hooks-work.md` for execution model, `references/event-reference.md` for event timing, `references/decision-schemas.md` for JSON outputs, `references/exit-code-behavior.md` for command exit behaviors.

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

**START HERE:** Always begin by asking the user to clarify their intent using AskUserQuestion:

```
Question 1: What would you like to do?
- Create a new hook (Recommended) - Build from scratch
- Validate an existing hook - Check against best practices
- Refine hook quality - Improve existing hook

Question 2: What is the hook about?
- If creating: Describe what you want to automate (e.g., `format-on-write`, `pre-commit-check`, `post-tool-use`)
- If validating/refining: Provide the hook name or describe the hook event
```

Based on their answers, route to the appropriate workflow below:

### Create New Hooks
1. Interview user: hook purpose, event type, matcher conditions, action type, error handling needs (use AskUserQuestion)
2. Use `references/templates.md` to start from appropriate template
3. Configure event → matcher → action → error handling
4. Validate using `references/checklist.md` before completion

### Validate Existing Hooks
1. Follow 7-phase workflow in `references/validation-workflow.md`
2. Check each phase against `references/checklist.md` for gaps
3. Complete all 7 phases before signing off

### Improve Hooks
1. Ask which aspect needs improvement (event, matcher, performance, error handling) using AskUserQuestion
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
| `decision-schemas.md` | JSON output formats for each event (PreToolUse, PermissionRequest, Stop, etc.) |
| `exit-code-behavior.md` | Command hook exit codes (0, 2, other) and error handling |
| `validation-workflow.md` | 7-phase validation process (event, matcher, action, error handling, performance) |
| `checklist.md` | Best practices and validation checklists (creation, validation, troubleshooting) |
| `templates.md` | Copy-paste templates for command and prompt hooks, common patterns |
| `mcp-tools.md` | MCP tool naming patterns, matching MCP tools in hooks |
| `component-scoped-hooks.md` | Defining hooks in skill/agent frontmatter, once option, environment variables |
| `advanced-patterns.md` | Production patterns (conditional execution, fallbacks, monitoring, testing) |

## Core Principles

**Event Correctness** — Right event = right trigger time (Pre vs Post). Wrong event = missed or wrong-time triggers.

**Matcher Precision** — Specific enough to avoid false triggers, broad enough to catch intended cases. Overly broad = performance impact; overly narrow = missed triggers.

**Safe Execution** — Commands must be fast (<1s) and non-blocking. Failed hooks must not crash plugins.

**Error Handling** — All hooks need timeouts, onError behavior, validation. Production hooks need monitoring/logging.

## Key Notes

**Hook JSON structure** (in plugin.json, `.claude-plugin/hooks.json`, or skill/agent frontmatter):
```json
{
  "hooks": {
    "EventName": [{
      "matcher": "regex-pattern",  // Optional for some events; case-sensitive
      "hooks": [{
        "type": "command",
        "command": "${CLAUDE_PLUGIN_ROOT}/scripts/script.sh",
        "timeout": 5000,
        "onError": "warn"
      }, {
        "type": "prompt",
        "prompt": "Evaluate: ${ARGUMENTS}. Return YES or NO.",
        "timeout": 10000
      }]
    }]
  }
}
```

**Matcher requirements by event:**
- **Require matcher**: PreToolUse, PostToolUse, PostToolUseFailure, PermissionRequest, Notification
- **Matcher optional**: UserPromptSubmit, SessionStart, SessionEnd, PreCompact, Stop, SubagentStart, SubagentStop (if omitted, applies to all)

**Naming convention:** action-on-event (e.g., `format-on-write`, `validate-on-prompt-submit`, `backup-on-compact`)

**Event selection decision tree:**
- Before execution? → PreToolUse
- After success? → PostToolUse (or PostToolUseFailure for errors)
- User input validation? → UserPromptSubmit
- Session/state? → SessionStart/SessionEnd/PreCompact
- Permissions? → PermissionRequest
- Lifecycle? → Stop/SubagentStart/SubagentStop

**Command vs Prompt decision:**
- Deterministic validation (linting, formatting, checks)? → command
- Intelligent decision-making (needs context understanding)? → prompt (but only for appropriate events)
- Multiple conditions, complex logic? → command (simpler error handling)

**Production requirements:**
- Timeout set (<2s for command, <10s for prompt); prevents hanging
- onError behavior specified (warn/fail/continue); prevents cascade failures
- Matcher tested with real scenarios (broad matchers have silent performance impact)
- Decisions use proper JSON schemas (see decision-schemas.md)
- Exit codes/JSON output correct (see exit-code-behavior.md)

## Advanced Topics

For production hooks: understand event timing → test matchers with real scenarios → design graceful failure modes → ensure fast execution → implement monitoring/logging → track versions for coordination.

Common patterns in `references/templates.md` and `references/advanced-patterns.md`.
