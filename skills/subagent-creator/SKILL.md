---
name: subagent-creator
description: >-
  Create, validate, and refine Claude Code subagents for reliable delegation.
  Use when building new subagents, validating existing ones, improving quality,
  scoping tool access, configuring permission modes, or setting up hook
  validation. For personal, team, or production environments.
version: 1.1.0
allowed-tools: Read,Write,Edit,Glob,Grep,AskUserQuestion
---

# Subagent Creator

**Dual purpose:** Create subagents right the first time OR elevate existing subagents to best practices.

## Quick Routing

Use AskUserQuestion to gather requirements, then proceed to the appropriate section below:

1. Ask what the user wants to do (create/validate/refine)
2. Ask for the subagent name or path based on the action
3. Route to the appropriate workflow section

---

## When to Use This Skill

- **Creating subagents** — Need structured guidance on scope, model, tool access, permission modes for new subagents
- **Validating subagents** — Ensure correct configuration, delegation clarity, tool scoping, permission modes
- **Improving subagents** — Enhance robustness (tool restrictions, permissions, delegation signals, error handling, hooks)
- **Team/production** — Building for multiple Claude instances; need stability and error handling

### Quick Reference: Three Workflows

| Workflow | Purpose | Steps | Reference |
|----------|---------|-------|-----------|
| **Create** | Build subagent from scratch | 1. Interview → 2. Design → 3. Implement → 4. Validate | `templates.md` + `validation-workflow.md` |
| **Validate** | Check existing subagent | 1. Configuration → 2. Delegation → 3. Prompt → 4. Tools → 5. Permissions → 6. Hooks → 7. Test | `validation-workflow.md` + `checklist.md` |
| **Refine** | Improve existing subagent | 1. Identify issues → 2. Target improvements → 3. Update → 4. Re-validate | `checklist.md` + topic-specific refs |

## Why This Exists

**Mindset:** Subagents are execution FOR CLAUDE, not documentation FOR PEOPLE. Question: "Will Claude reliably delegate & execute?" not "Does this read well?"

Subagents isolate task execution with custom prompts, tool access, permissions. Without structured guidance, they become misconfigured and unreliable. This skill ensures every subagent is optimized for reliable delegation and execution from creation.

## Foundation: Subagent Architecture

Subagents are isolated execution environments with independent configuration (prompt, tools, permissions). Claude delegates to subagents based on request context using natural language matching against descriptions. For complete architectural details including delegation mechanisms, configuration options, and integration patterns, see `references/how-subagents-work.md`.

## THE EXACT PROMPT

When creating or improving a subagent, use this exact request:

```
Use subagent-creator to [create/validate/improve] my [subagent-name] subagent.
Focus on: [specific area - e.g., "delegation triggering", "tool scoping", "permission modes"]
```

Examples:
- "Use subagent-creator to create my db-analyzer subagent"
- "Use subagent-creator to validate my code-reviewer subagent against best practices"
- "Use subagent-creator to improve my test-runner subagent, focus on permission modes"

## Implementation Approach

**⚠️ CRITICAL: Scope Detection & Clarification**

Always detect project type first, then clarify scope only when needed:

**Allowed scopes:**
- **Claude plugin projects** (has `.claude-plugin/plugin.json`): Subagents in `agents/` (plugin) or `.claude/agents/` (project-level)
- **Regular projects**: Subagents in `.claude/agents/` only
- **NEVER** edit subagents from installed locations: `~/.claude/plugins/cache/`, `~/.claude/agents/`, or global installations
- If user provides a path to an installed subagent, refuse and explain the difference

**START HERE - Scope Detection & Clarification Flow:**

1. **Ask Question 1: Action type**
   - Create a new subagent (Recommended)
   - Validate an existing subagent
   - Refine a subagent

2. **AUTO-DETECT: Check for `.claude-plugin/plugin.json`**
   - If it exists (project is a Claude plugin): Go to step 3a
   - If it doesn't exist (regular project): Go to step 3b

3a. **IF PROJECT IS A CLAUDE PLUGIN - Ask Question 2: Scope choice**
   ```
   Should this subagent be part of the plugin or project-level?
   - Part of the plugin - Add to `agents/` directory (bundled with plugin)
   - Project-level - Add to `.claude/agents/` directory (local, not bundled)
   ```
   Then ask: "What do you want to call it?" (e.g., `db-analyzer`, `code-reviewer`, `compliance-auditor`)

3b. **IF PROJECT IS REGULAR - No scope question needed**
   - Inform user: "Creating project-level subagent in `.claude/agents/`"
   - Ask: "What do you want to call it?" (e.g., `db-analyzer`, `code-reviewer`, `compliance-auditor`)

**For validating/refining:** Ask "Provide the subagent name or path relative to project root" (e.g., `agents/db-analyzer` for plugins or `.claude/agents/db-analyzer` for regular projects)

Based on answers, route to the appropriate workflow below.

### For New Subagents: Requirements Interview First

After routing to "create", **interview the user to gather requirements** using AskUserQuestion. This ensures the subagent will be reliably delegated to and execute correctly:

1. **Purpose & scope** - What specialized task should this subagent execute? What problem does isolation solve?
2. **Delegation trigger** - When should Claude delegate to this subagent? What request phrases trigger it?
3. **Tool access** - Which tools will Claude need? Apply principle of least privilege.
4. **Permission mode** - How should the subagent handle permission prompts? (default, acceptEdits, dontAsk, plan)
5. **Model choice** - Should it use fast Haiku, standard Sonnet, or powerful Opus? Or inherit from parent?
6. **Hooks & validation** - Does the subagent need conditional tool validation or lifecycle hooks?
7. **Team/production** - Will multiple Claude instances use this? Production data involved?

Then use `references/templates.md` to apply requirements to the appropriate subagent structure.

### For Existing Subagents (Validating)

1. **FIRST: Verify the subagent path is project-scoped** — Check if path contains `.claude/agents/` or `agents/` relative to project root. If path is from `~/.claude/plugins/cache/` or `~/.claude/`, REFUSE and explain project scope
2. **SECOND: Detect if subagent is plugin or project-level** — Infer from path prefix:
   - Path starts with `agents/` → Plugin-level subagent
   - Path starts with `.claude/agents/` → Project-level subagent
3. Follow the systematic workflow in `references/validation-workflow.md` (Phase 1-7)
4. Use `references/checklist.md` to identify gaps during validation
5. Check `references/delegation-signals.md` for description clarity
6. Validate: Complete workflow + checklist before considering the subagent complete

### For Improvements (Refining)

1. **FIRST: Verify the subagent path is project-scoped** — Check if path is in project directory, NOT in installed locations. Refuse if it's installed/cached
2. **SECOND: Detect scope from path** — Determine if subagent is plugin-level or project-level based on path prefix
3. Ask user which aspects need improvement (delegation, tools, permissions, etc.)
4. Reference relevant sections from `references/checklist.md` or `references/delegation-signals.md`
5. Make targeted improvements rather than rewriting everything

## Outcome Metrics

Measure success by whether Claude will reliably delegate to and execute the subagent:

✅ **Description clarity** - Includes specific trigger phrases Claude will recognize; delegates reliably when needed
✅ **Configuration** - Correct YAML frontmatter (name, description, tools, permissionMode, model, hooks)
✅ **Prompt quality** - System prompt is clear, procedural, and context-appropriate
✅ **Tool scoping** - Only necessary tools declared; principle of least privilege enforced
✅ **Permission mode** - Appropriate for use case (foreground vs background, interactive vs auto-deny)
✅ **Hooks** - Correctly configured for validation/lifecycle when needed
✅ **Integration** - Tested with real delegation scenarios; works with both foreground and background execution

## Quick Start: Creating a New Subagent

When helping the user create a subagent, follow these steps:

**Step 1: Prepare storage location**
Guide the user to create the directory:
- Global: `~/.claude/agents/`
- Project-local: `.claude/agents/`

**Step 2: Create the Markdown file**
Write the subagent configuration with YAML frontmatter + system prompt body. Example structure:

```yaml
---
name: db-analyzer
description: >-
  Execute read-only database queries to analyze data. Use when exploring
  databases, generating reports, or analyzing data patterns. Supports
  SELECT queries only; write operations blocked.
model: sonnet
tools: Bash, Read, Write
permissionMode: dontAsk
---

You are a database analyst with read-only access...
```

**Step 3: Apply guidelines for Claude's delegation**
Ensure the subagent meets these requirements:
- **name**: lowercase-hyphen, ≤64 chars, unique within scope
- **description**: ≤1024 chars, must include specific trigger phrases (this is Claude's delegation signal)
- **tools**: Allowlist or omit to inherit all tools
- **model**: sonnet (default), opus, haiku, or inherit from parent
- **permissionMode**: default (ask), acceptEdits (auto-accept edits), dontAsk (auto-deny), bypassPermissions (skip checks), plan (read-only)

**Step 4: Write the system prompt**
The prompt body is what Claude executes when delegated. Structure: Purpose → Key behaviors → Constraints → Examples

**Step 5: Add hooks if needed**
For conditional tool validation (e.g., read-only database access), guide the user to configure PreToolUse hooks with validation scripts.

**Step 6: Guide user through validation**
Have the user review the checklist in `references/checklist.md` before deployment. Then guide them through real-world testing: try requests that should trigger delegation, and requests that should not.

## Refining Existing Subagents

1. **Follow the validation workflow** (`references/validation-workflow.md`) to identify issues systematically
2. **Review against the checklist** (`references/checklist.md`) during validation
3. **Improve so Claude delegates and executes reliably:** description clarity (delegation) → configuration correctness → prompt clarity → hooks/validation if needed
4. **Guide user to test delegation:** Ask them to make requests using the trigger phrases from the description. Check: Does Claude delegate to this subagent? If not, the description needs clearer trigger language.
5. **Guide user to test execution:** Once delegation works, verify the subagent can complete the task with its prompt and tools. Ask the user to test actual workflows.
6. **Re-validate** using the workflow before considering refinements complete

## Reference Files

For detailed guidance, see references/:

**Getting Started:**
- **`templates.md`** — Real-world examples and copy-paste starting points for common patterns

**Understanding & Validation:**
- **`how-subagents-work.md`** — Architecture: delegation mechanism, execution models, hooks, built-in subagents
- **`validation-workflow.md`** — 7-phase validation process (configuration → delegation → prompt → tools → permissions → hooks → testing)
- **`checklist.md`** — Best practices checklist (delegation signals, tool scoping, permission modes, team/production)

**Writing & Configuration:**
- **`delegation-signals.md`** — Writing descriptions that trigger Claude's delegation
- **`configuration-reference.md`** — Complete YAML frontmatter reference (fields, values, defaults, validation)
- **`permission-modes.md`** — Permission mode behavior with decision matrices and examples
- **`tool-scoping.md`** — Tool access patterns (principle of least privilege, hook-based validation, security)

**Advanced & Production:**
- **`advanced-patterns.md`** — Production patterns (hook validation, chaining, background execution, lifecycle management)

## Core Principles

1. **Clear Delegation Signals** — Descriptions trigger Claude's delegation. Include specific trigger phrases; vague descriptions = poor reliability.
2. **Principle of Least Privilege** — Grant only necessary tools. Use allowlist scoping and hooks for conditional validation (e.g., read-only queries).
3. **Appropriate Permission Mode** — Match mode to use case: foreground/interactive, background/concurrent, or plan/read-only.
4. **Configuration Clarity** — Validate YAML syntax, tool names, model values, and required fields before deploying.

## Key Notes

**Frontmatter essentials:**
- `name`: Required, lowercase-hyphen, ≤64 chars (Claude's reference label)
- `description`: Required, ≤1024 chars, must include trigger phrases Claude recognizes (PRIMARY delegation signal)
- Example formula: `[Action]. Use when [trigger contexts]. [Scope/constraints].`

**Common optional fields:**
- `model`: sonnet|opus|haiku|inherit (default: sonnet)
- `tools`: Allowlist tools (default: inherit all)
- `permissionMode`: default|acceptEdits|dontAsk|bypassPermissions|plan
- `hooks`: PreToolUse, PostToolUse, SubagentStart, SubagentStop for validation/lifecycle

**Scope storage:**
- Global: `~/.claude/agents/`
- Project-local: `.claude/agents/`
- Plugin: `agents/` in plugin directory

For complete configuration reference, defaults, field combinations, naming conventions, and permission mode decision matrices, see `configuration-reference.md` and `permission-modes.md`.

**Team/Production:**
- Error handling: prompts must handle failures gracefully
- Tool scoping: principle of least privilege (see `tool-scoping.md`)
- Hooks: validation scripts must be tested before deployment
- See `checklist.md` → "Team & Production Subagents" for full considerations and `advanced-patterns.md` for production patterns
