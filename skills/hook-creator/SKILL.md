---
name: hook-creator
description: >-
  Create, validate, and refine Claude Code plugin hooks for automating workflows.
  Use when building new hooks from scratch, validating existing hooks against best practices,
  or improving hook quality. Supports command hooks (shell scripts), prompt hooks (LLM decisions),
  event matching, decision schemas, and production safety validation. Claude auto-activates when
  you ask to build a hook, check hook reliability, improve hook configurations, or validate hooks for production.
version: 2.4.0
allowed-tools: Read,Write,Edit,Glob,Grep,AskUserQuestion
---

# Hook Creator

**Dual purpose:** Create hooks right the first time OR elevate existing hooks to best practices.

## Quick Routing

Use AskUserQuestion with **predefined options**:

```
questions: [
  {
    question: "What would you like to do?",
    header: "Action",
    options: [
      {
        label: "Create a new hook",
        description: "Build a hook from scratch with proper configuration and validation"
      },
      {
        label: "Validate existing hooks",
        description: "Check hooks against best practices and production standards"
      },
      {
        label: "Refine/improve hooks",
        description: "Enhance existing hooks for clarity, efficiency, or reliability"
      }
    ],
    multiSelect: false
  }
]
```

Then route to the appropriate workflow section based on their selection.

---

## Quick Start

**What to do:** Tell hook-creator whether you want to **create**, **validate**, or **improve** a hook.

Then hook-creator will:
1. Ask clarifying questions about your goal (hook purpose, events, scope)
2. Detect your project type (Claude plugin or regular project)
3. Ensure hooks go to the right location:
   - **Plugin project**: `hooks/hooks.json` (at plugin root)
   - **Regular project**: `.claude/hooks.json` (in .claude directory)
4. Guide you through the workflow with templates and validation checklists

**What this skill does:** Ensures hooks trigger reliably, execute safely, and follow production best practices. Wrong events cause missed triggers. Loose matchers waste resources. Poor error handling breaks plugins. This skill prevents all of that.

**NOT for:** Debugging specific hook failures in running plugins, or writing hook scripts directly.

---

## ⚠️ CRITICAL: Hook File Location

**Most common hook mistake:** Placing hooks in `.claude-plugin/hooks.json` (WRONG)

✅ **CORRECT locations:**
- **Plugin projects** (has `.claude-plugin/plugin.json`): Create `hooks/hooks.json` at plugin root
- **Regular projects** (no `.claude-plugin/`): Create `.claude/hooks.json` in .claude directory

❌ **WRONG location:** `.claude-plugin/hooks.json` (only plugin.json belongs in .claude-plugin/)

If your hooks aren't firing, check the file location first.

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

**Error handling (CRITICAL - this makes or breaks hooks):**
- `exit 0` = success (no error output)
- `exit 2` = blocking error (stderr shown DIRECTLY TO CLAUDE - he can fix it)
- `exit 1` = non-blocking error (stderr only in verbose mode, Claude never sees it)
- RULE: If hook needs to communicate errors to Claude, use `exit 2`. Otherwise use 0 or 1.
- Always set `onError` behavior (warn/fail/continue)

**HOW COMMAND HOOKS RECEIVE DATA (CRITICAL - most common mistake):**
- ❌ Environment variable substitution DOES NOT WORK: `"env": {"FILE_PATH": "${arguments.file_path}"}`
- ✓ Command hooks receive ALL event data via **stdin as JSON**, not environment variables
- ✓ Read from stdin: `INPUT=$(cat)` then parse: `jq '.tool_input.file_path'`
- See `references/command-hook-input-parsing.md` for correct patterns and examples
- This is the #1 reason command hooks appear to do nothing (scripts get no arguments)

**Critical constraints:**
- Matchers must be precise (overly broad = performance impact)
- Commands must be fast (<1s synchronous, up to 10s asynchronous)
- All hooks need timeout + onError handling
- **Command hook scripts must pass shellcheck** (run: `shellcheck script.sh`)

**For detailed execution model, event timing, and decision schemas:** See `references/how-hooks-work.md`, `references/event-reference.md`, and `references/decision-schemas.md`.

## Workflow by Action

**Step 1: Ask what you want to do (create / validate / improve)**

**Step 2: Scope detection (automatic)**
- Check for `.claude-plugin/plugin.json` — If exists, you're in a plugin project; if not, regular project
- If plugin project: Hooks go to `hooks/hooks.json` at plugin root (or inline in plugin.json)
- If regular project: Hooks go to `.claude/hooks.json` in project's .claude directory
- **Refuse installed paths:** If user points to `~/.claude/plugins/cache/` or `~/.claude/`, refuse—only work with project-scoped hooks

**Step 3: Route to appropriate workflow below**

### Create New Hooks
1. Interview user (hook purpose, event type, matcher, action type, error handling)
2. Load `references/templates.md` — pick appropriate template (command vs prompt)
3. Build hook: event → matcher → action → error handling → timeout + onError
4. Validate against `references/checklist.md` (syntax, event correctness, matcher precision)
5. Complete and deploy

### Validate Existing Hooks
1. Verify hook path is project-scoped:
   - **Plugin project**: `hooks/hooks.json` at plugin root
   - **Regular project**: `.claude/hooks.json` in .claude directory
   - **Refuse installed paths** (`~/.claude/plugins/cache/` or `~/.claude/`)
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

## Core Principles

**Event Correctness** — Right event = right trigger time (Pre vs Post). Wrong event = missed or wrong-time triggers.

**Matcher Precision** — Specific enough to avoid false triggers, broad enough to catch intended cases. Overly broad = performance impact; overly narrow = missed triggers.

**Safe Execution** — Commands must be fast (<1s) and non-blocking. Failed hooks must not crash plugins.

**Error Handling** — All hooks need timeouts, onError behavior, validation. Production hooks need monitoring/logging.

## Reference Guide

### Creating a New Hook

**Step 1: Understand hook architecture**
→ Hook flow: event fires → matcher evaluated → action executes → decision returned
→ Hook types: command (shell scripts) vs. prompt (LLM decisions)
→ Execution modes: synchronous (blocking) vs. asynchronous (background)
→ `references/how-hooks-work.md` for detailed execution model and timing

**Step 2: Choose the right template**
→ Copy-paste starting points for command hooks and prompt hooks
→ `references/templates.md`

**Step 3: Select event & matcher**
→ Event decision tree: PreToolUse, PostToolUse, UserPromptSubmit, PermissionRequest, Stop, SessionStart/End
→ Matcher patterns: precise regex for specific targeting (avoid `.*` performance killer)
→ `references/event-reference.md` for all available events

**Step 4: Configure command vs. prompt**
→ Command: deterministic logic (linting, validation) with proper exit codes
→ Prompt: intelligent decision-making with decision schemas
→ `references/decision-schemas.md` for schema format and validation

**Step 5: Handle errors & edge cases**
→ Critical: exit codes (0=success, 2=blocking error), onError behavior (warn/fail/continue)
→ Async vs. sync decision (blocking validators → sync; logging → async)
→ `references/command-hook-input-parsing.md` for stdin parsing (common mistake: missing input)

**Step 6: Validate before deployment**
→ 7-phase validation: event → matcher → type → error handling → performance → integration → testing
→ `references/validation-workflow.md` for systematic validation
→ `references/checklist.md` for production readiness checklist

### Validating Existing Hooks

→ Run 7-phase validation workflow systematically
→ `references/validation-workflow.md` for all phases
→ `references/checklist.md` for quality assessment

### Improving/Refining Hooks

→ Identify issues using validation workflow, make targeted improvements, re-validate
→ `references/checklist.md` for identifying gaps
→ Topic-specific references as needed

### Production & Advanced Patterns

→ Conditional execution, fallbacks, rate limiting, monitoring, testing patterns
→ `references/advanced-patterns.md` for production patterns

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

**For detailed reference:** Templates (`references/templates.md`), validation workflow (`references/validation-workflow.md`), best practices (`references/checklist.md`)

**Production hooks checklist (summary):**
- ✅ Timeout set (<2s for command, <10s for prompt)
- ✅ onError behavior specified (warn/fail/continue)
- ✅ Matcher tested with real scenarios
- ✅ Decisions use proper JSON schemas
- ✅ Exit codes/JSON output correct
- ✅ Async mode chosen correctly
- ✅ Error handling in place (failures don't break plugin)

**For detailed production patterns:** See `references/advanced-patterns.md` (conditional execution, fallbacks, rate limiting, monitoring, testing).
