---
name: hook-creator
description: >-
  Create, validate, and refine Claude Code plugin hooks for automating workflows.
  Use when building new hooks from scratch, validating existing hooks against best practices,
  or improving hook quality. Supports command hooks (shell scripts), prompt hooks (LLM decisions),
  event matching, decision schemas, and production safety validation. Claude auto-activates when
  you ask to build a hook, check hook reliability, improve hook configurations, or validate hooks for production.
version: 2.2.1
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

## Quick Start

**What to do:** Tell hook-creator whether you want to **create**, **validate**, or **improve** a hook.

Then hook-creator will:
1. Ask clarifying questions about your goal (hook purpose, events, scope)
2. Detect your project type (Claude plugin or regular project)
3. Ensure hooks go to the right location (`.claude/hooks.json` or `hooks.json`)
4. Guide you through the workflow with templates and validation checklists

**What this skill does:** Ensures hooks trigger reliably, execute safely, and follow production best practices. Wrong events cause missed triggers. Loose matchers waste resources. Poor error handling breaks plugins. This skill prevents all of that.

**NOT for:** Debugging specific hook failures in running plugins, or writing hook scripts directly.

## Hook System Essentials (Quick Reference)

**Hook flow:** Event fires → Matcher evaluated → If matched: action executes → Decision returned → Claude Code acts

**Hook types:**
- **command** - Shell scripts (formatting, validation, deterministic logic)
- **prompt** - LLM decisions (Stop, SubagentStop, UserPromptSubmit, PermissionRequest, PreToolUse only)

**Execution modes:**
- **Synchronous (default)** - Blocks Claude Code; use for validation/blocking
- **Asynchronous (async: true)** - Background execution; use for logging, notifications, cleanup

**Matchers (case-sensitive regex):**
- Precise: `^(Write|Edit)$` matches exactly Write or Edit
- File extension: `\.js$` matches .js files
- Avoid: `.*` (matches everything, performance killer)
- Some events don't need matchers: Stop, SessionEnd, UserPromptSubmit, SessionStart (omit field)
- MCP tools: `mcp__<server>__<tool>` (e.g., `mcp__memory__create_entities`)

**Error handling:**
- Command exit code 0 = success
- Exit code 2 = blocking error (stderr shown to Claude)
- Other exit codes = non-blocking (stderr in verbose mode only)
- Always set `onError` behavior (warn/fail/continue)

**Critical constraints:**
- Matchers must be precise (overly broad = performance impact)
- Commands must be fast (<1s synchronous, up to 10s asynchronous)
- All hooks need timeout + onError handling

**For detailed execution model, event timing, and decision schemas:** See `references/how-hooks-work.md`, `references/event-reference.md`, and `references/decision-schemas.md`.

## Workflow by Action

**Step 1: Ask what you want to do (create / validate / improve)**

**Step 2: Scope detection (automatic)**
- Check for `.claude-plugin/plugin.json` — If exists, you're in a plugin project; if not, regular project
- If plugin project: Ask whether hook should be plugin-level (`hooks.json`) or project-level (`.claude/hooks.json`)
- If regular project: Hooks always go to `.claude/hooks.json` (no choice needed)
- **Refuse installed paths:** If user points to `~/.claude/plugins/cache/` or `~/.claude/`, refuse—only work with project-scoped hooks

**Step 3: Route to appropriate workflow below**

### Create New Hooks
1. Interview user (hook purpose, event type, matcher, action type, error handling)
2. Load `references/templates.md` — pick appropriate template (command vs prompt)
3. Build hook: event → matcher → action → error handling → timeout + onError
4. Validate against `references/checklist.md` (syntax, event correctness, matcher precision)
5. Complete and deploy

### Validate Existing Hooks
1. Verify hook path is project-scoped (`.claude/hooks.json` or `hooks.json` relative to project root). Refuse installed paths (`~/.claude/plugins/cache/` or `~/.claude/`).
2. Load `references/validation-workflow.md` — follow 7-phase validation (event → matcher → type → error handling → performance → integration → testing)
3. Use `references/checklist.md` to verify completeness at each phase
4. Report issues and sign off

### Improve Hooks
1. Verify hook path is project-scoped. Refuse installed paths.
2. Ask which aspect needs improvement (event, matcher, error handling, performance)
3. Load relevant reference (`references/checklist.md` for best practices; `references/validation-workflow.md` for systematic review)
4. Make targeted fixes (don't rewrite everything)
5. Re-validate using checklist before signing off

## Outcome Metrics

Measure success by whether the hook will execute reliably and safely:

✅ **Correct event** - Hook triggers on the right event; understands event timing
✅ **Precise matcher** - Matcher correctly identifies when hook should execute (not too broad, not too narrow)
✅ **Safe action** - Hook action is safe, fast, and doesn't block critical paths
✅ **Error handling** - Hook fails gracefully; includes validation and error messages
✅ **Configuration** - Valid JSON/YAML syntax; correct hook.json structure
✅ **Testing** - Validated with real plugin scenarios; tested both success and failure cases
✅ **Documentation** - Clear comments explaining matcher logic and failure modes


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

## Key Reference Points

**Hook JSON structure:**
```json
{
  "hooks": {
    "EventName": [{
      "matcher": "regex-pattern",  // Optional for some events
      "hooks": [{
        "type": "command",
        "command": "${CLAUDE_PLUGIN_ROOT}/scripts/script.sh",
        "timeout": 5000,
        "onError": "warn"
      }]
    }]
  }
}
```

**Event selection decision tree:**
- **Before execution?** → PreToolUse
- **After success?** → PostToolUse (or PostToolUseFailure for errors)
- **User input validation?** → UserPromptSubmit
- **Session/state lifecycle?** → SessionStart/SessionEnd/PreCompact
- **Permission request?** → PermissionRequest
- **Stopping Claude?** → Stop/SubagentStop

**Command vs Prompt decision:**
- **Deterministic logic** (linting, formatting, validation checks) → command (shell scripts)
- **Intelligent decision-making** (needs context, reasoning) → prompt (LLM, but only for Stop, SubagentStop, UserPromptSubmit, PermissionRequest, PreToolUse)
- **Complex conditions** (multiple branches, state checks) → command (simpler error handling, faster execution)

**Async vs Synchronous execution:**
- **Use `async: false` (default) when:**
  - Hook must make a blocking decision (allow/deny, validation pass/fail)
  - Hook runs on PreToolUse, PermissionRequest (validation gates)
  - Hook result affects Claude Code flow (blocking action, updating input)
  - Hook is critical to workflow and must fail fast

- **Use `async: true` when:**
  - Hook is for logging/auditing (doesn't affect execution flow)
  - Hook is for notifications (Slack, email, webhooks)
  - Hook is for telemetry/metrics (background tracking)
  - Hook is for cleanup (temp files, state reset after SessionEnd)
  - Hook may be slow but shouldn't slow Claude Code

**Naming convention:** action-on-event (e.g., `format-on-write`, `validate-on-prompt-submit`, `backup-on-compact`)

**For detailed reference:** See `references/templates.md` (copy-paste examples), `references/validation-workflow.md` (systematic validation), `references/checklist.md` (best practices)

**Production hooks checklist (summary):**
- ✅ Timeout set (<2s for command, <10s for prompt)
- ✅ onError behavior specified (warn/fail/continue)
- ✅ Matcher tested with real scenarios
- ✅ Decisions use proper JSON schemas
- ✅ Exit codes/JSON output correct
- ✅ Async mode chosen correctly
- ✅ Error handling in place (failures don't break plugin)

**For detailed production patterns:** See `references/advanced-patterns.md` (conditional execution, fallbacks, rate limiting, monitoring, testing).
