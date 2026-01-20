---
name: skill-creator
description: >-
  Create and refine Claude Code skills following best practices. Use when
  building new skills from scratch, validating existing skills against standards,
  or improving subpar skills to production quality. For personal, team, or
  production environments.
version: 1.0.1
allowed-tools: Read,Write,Edit,Glob,Grep,AskUserQuestion
---

# Skill Creator

**Dual purpose:** Create skills right the first time OR elevate existing skills to best practices.

## Quick Routing

Use this to understand what you're here to do:

**What would you like to do?**
- **Create a new skill** - Build a skill from scratch with structured guidance (frontmatter, body structure, references, validation)
- **Validate an existing skill** - Check your skill against best practices (structure, activation, token efficiency, tool scoping)
- **Refine a skill** - Improve an existing skill (length, clarity, activation triggers, organization)

**What is the skill name or path?**
- If validating/refining: Provide the skill directory name (e.g., `pdf-processor`) or full path
- If creating: Tell us what you want to call it (e.g., `code-analyzer`, `test-runner`)

Then proceed to the appropriate section below.

---

## When to Use This Skill

Invoke skill-creator in these scenarios (Claude will guide you through each):

**Creating new skills:** Building a skill from scratch and need structured guidance so Claude will execute it correctly (naming, frontmatter for activation, body structure for Claude's execution, references, validation).

**Validating existing skills:** Have a skill and want to ensure Claude will follow it effectively (correct structure, progressive disclosure, token efficiency, clear tool scoping).

**Improving skill quality:** Skill works but Claude might execute it inefficiently (too long, missing references, poor organization, inconsistent terminology, unclear instructions).

**Team/production skills:** Creating skills for multiple Claude instances and need to ensure they're robust (error handling, tool scoping, version tracking, clear documentation Claude can follow).

**NOT for:** General Claude questions, debugging existing skills in use, writing skill content directly (focus on structure/guidance only).

## Why This Exists

**CRITICAL MINDSET:** Skills are instructions FOR CLAUDE, not documentation FOR PEOPLE. When evaluating or improving a skill, the question is always: "Will this help Claude understand and execute the task?" not "Will people find this easy to read?"

Skills solve a critical problem: Claude's knowledge is general-purpose, but specific domains need specialized execution patterns. Without structured skill creation guidance, skills end up inconsistent and hard for Claude to follow effectively. skill-creator ensures every skill is optimized for Claude's task execution (progressive disclosure, token efficiency, tool scoping, clear procedures) from the start.

## Foundation: How Skills Trigger & Load

To create and validate skills effectively, you need to understand how skills work internally:

**Token loading hierarchy** — Skills load in three levels:
1. **Level 1 (Metadata)**: ~100 tokens, always loaded (name + description)
2. **Level 2 (SKILL.md body)**: ~1,500-5,000 tokens, loads when triggered
3. **Level 3 (References/scripts)**: Unlimited, loads on-demand

**Selection mechanism** — Pure LLM reasoning on descriptions. Claude evaluates skill descriptions using natural language understanding (not keyword matching). This means:
- Vague descriptions = skills never trigger when needed
- Specific trigger phrases = reliable activation for Claude
- Descriptions are Claude's primary activation signal

**Why this matters for your work:**
- Descriptions must be specific and include concrete trigger phrases Claude will recognize
- SKILL.md body should stay <500 lines (Claude loads this every trigger; token efficiency matters)
- Reference files have zero token penalty when not needed (Claude loads only on-demand)
- Quick Start sections are critical (Claude should execute 80% of tasks from Quick Start alone)

See `references/how-skills-work.md` for complete architectural details.

## THE EXACT PROMPT

When creating or improving a skill, use this exact request:

```
Use skill-creator to [create/validate/improve] my [skill-name] skill.
Focus on: [specific area - e.g., "SKILL.md structure", "allowed-tools setup", "reference organization"]
```

Examples:
- "Use skill-creator to create my pdf-processor skill"
- "Use skill-creator to validate my test-runner skill against best practices"
- "Use skill-creator to improve my code-analyzer skill, focus on token efficiency"

## Implementation Approach

### For New Skills: Requirements Interview First

Before creating skill structure, **interview the user to gather requirements** using AskUserQuestion. This ensures the skill will activate correctly and Claude will execute it effectively:

1. **Skill purpose** - What domain-specific task should Claude execute? What problem does this solve?
2. **Trigger phrases** - What phrases will Claude see in requests when this skill should activate?
3. **Scope & constraints** - What's IN scope for Claude to execute? What's OUT of scope?
4. **Tool needs** - Which tools will Claude need (file operations, Bash, network access)?
5. **Team/production** - Will multiple Claude instances use this? Production data involved?
6. **Complexity** - Will Claude need scripts to reference? Reference files? Multiple workflows?

Then use `references/templates.md` to apply requirements to the appropriate template structure.

### For Existing Skills

1. Follow the systematic workflow in `references/validation-workflow.md` (Phase 1-7)
2. Use `references/checklist.md` to identify gaps during Phase 3-6
3. Check `references/allowed-tools.md` if tool scoping is involved
4. Validate: Complete workflow + checklist before considering the skill complete

### For Improvements

1. Ask user which aspects need improvement (structure, length, triggering, etc.)
2. Reference relevant sections from `references/checklist.md` or `references/allowed-tools.md`
3. Make targeted improvements rather than rewriting everything

## Outcome Metrics

Measure success by whether Claude will execute the skill effectively:

✅ **Structure** - Claude can execute 80% of cases from Quick Start alone (no references needed)
✅ **Activation** - Description includes trigger phrases Claude will recognize; skill activates when needed
✅ **Token efficiency** - SKILL.md body <500 lines; Claude doesn't waste tokens on unnecessary content
✅ **Clarity** - Instructions are concrete and procedural (Claude knows exactly what to execute)
✅ **Completeness** - All required frontmatter present (name, description for activation)
✅ **Tool scoping** - Only necessary tools declared (principle of least privilege for security)
✅ **Testing** - Validated with both Haiku and Opus; works with real-world example requests

## Quick Start: Creating a New Skill

**Step 1: Create directory structure**
```bash
mkdir -p skill-name/references
```

**Step 2: Write frontmatter**
Create `SKILL.md` with required metadata. Frontmatter is what Claude reads to discover and activate skills:
```yaml
---
name: skill-name
description: >-
  What the skill does. Use when [trigger context]. Constraints/scope.
---
```

Guidelines for Claude's activation:
- name: lowercase, hyphens, ≤64 chars, no "anthropic"/"claude" (Claude uses this to reference the skill)
- description: ≤1024 chars, must include trigger phrases Claude will recognize in requests

**Step 3: Write SKILL.md body**
Write instructions Claude will follow to execute the task. Structure: Quick Start → Workflows → Key Notes → Full Reference (optional)
- Keep <500 lines (Claude reads this body every time skill triggers; token efficiency is mandatory)
- Code-first: examples Claude can adapt before abstract explanations
- Progressive disclosure: essentials Claude needs immediately → advanced topics later

**Step 4: Add references (if needed)**
Create `references/` subdirectories for:
- **Comprehensive guides** (>100 lines): include table of contents
- **Templates or configuration**: structured reference material
- One level deep only (no nested chains)

**Step 5: Validate**
Use the checklist in `references/checklist.md` to verify quality before deployment.

## Refining Existing Skills

1. **Follow the validation workflow** (references/validation-workflow.md) to identify all issues systematically
2. **Review against the checklist** (references/checklist.md) during validation phases 3-6
3. **Improve so Claude executes better:** frontmatter clarity (activation) → instruction clarity → examples Claude can adapt → separate detailed content
4. **Test activation:** Will Claude recognize this description in real requests? Will it activate when needed?
5. **Re-validate** using the workflow before considering refinements complete

## Key Patterns & Reference Files

For detailed guidance, see references/:

### Understanding Skills (how Claude uses skills)
- **`how-skills-work.md`** — How skills activate and execute (token loading hierarchy, selection mechanism, execution model, activation signals)

### Creating & Validating (ensuring Claude will execute well)
- **`validation-workflow.md`** — 7-phase validation process Claude will follow (frontmatter activation, body clarity, references organization, tool scoping, real-world testing)
- **`checklist.md`** — Best practices Claude needs (activation clarity, execution clarity, token efficiency, error handling for production)
- **`templates.md`** — Copy-paste starting points Claude can follow (basic template, production template, workflow patterns)

### Content Quality (writing so Claude executes correctly)
- **`content-guidelines.md`** — Writing descriptions Claude will recognize, terminology consistency, code examples Claude can adapt
- **`allowed-tools.md`** — Tool scoping (what tools Claude needs, principle of least privilege, security)

### Advanced Usage
- **`advanced-patterns.md`** — Production patterns (impact tiering, implementation approach, outcome metrics, version history, skill archetypes, risk tiering)

## Core Principles

**Self-Containment** — Skills must be self-contained. Claude needs everything within the skill directory (references, scripts, examples). Avoid external references or network dependencies unless core to the skill's purpose. See `references/self-containment-principle.md` for complete guidance.

**Progressive Disclosure** — Essential execution instructions first (Quick Start), detailed guidance second (references/), advanced topics last. Claude should execute 80% of tasks from Quick Start alone without loading references (token efficiency matters).

**Token Efficiency** — Every token Claude loads must justify its cost. Use code examples over prose, tables over lists, and move detailed content to references/. SKILL.md body is loaded every trigger, so minimize it ruthlessly.

## Key Notes

**Required frontmatter (Claude reads this to discover and activate skills):**
- YAML syntax (use triple dashes: `---`)
- `name`: Required, lowercase-hyphen, ≤64 chars, no "anthropic"/"claude" (how Claude references the skill)
- `description`: Required, must include specific trigger phrases Claude recognizes, ≤1024 chars
- Description is Claude's activation signal (vague descriptions = skill never activates)

**Optional frontmatter (for team/production skills):**
- `version: 1.0.0` — Track skill evolution for team coordination
- `allowed-tools: Read,Write,Bash(git:*)` — Apply principle of least privilege (see `references/allowed-tools.md`)
- See `references/templates.md` for tool scoping examples

**Naming conventions:**
- Hyphen-separated lowercase: `skill-name`, `my-feature-validator`
- Prefer gerund form: `processing-pdfs`, `analyzing-spreadsheets`
- Include action/domain: `test-runner`, `skill-creator`, `code-reviewer`
- Avoid generic: prefer `log-analyzer` over `analyzer`

**Description formula (Claude uses this to decide whether to activate the skill):**
```
[Action]. Use when [trigger contexts]. [Scope/constraints].
```
Example: "Run tests and generate reports. Use when validating code before commit. Supports PHPUnit and Jest."

The description must contain phrases Claude will see in user requests. If the description is vague, Claude won't activate the skill when needed.

**Team/Production considerations:**
- Error handling is mandatory (robust try/except, clear messages)
- Scripts must be tested before sharing
- Tool scoping: minimal permissions (principle of least privilege)
- Version tracking recommended for team coordination
- See `checklist.md` → "Team & Production Skills" section

**Content distribution rule (Claude loads SKILL.md body every trigger):**
- Keep SKILL.md <500 lines (enforced; Claude reads this every time, so minimize token load)
- If adding >50 lines of content: create a reference file instead
- Example: "Add allowed-tools docs" → create `references/allowed-tools.md`, link briefly in SKILL.md
- Reference files have zero token penalty until Claude needs them (much better token efficiency)

**Deployment:**
- Global: `~/.claude/skills/`
- Project-local: `.claude/skills/`

## Advanced Topics

For team/production skills, ensure Claude will execute robustly:
- **Error handling**: Robust try/except blocks, clear error messages Claude can understand
- **Tool scoping**: Minimal permissions (principle of least privilege for security)
- **Validation scripts**: Include example code Claude can reference and execute
- **Security review**: Peer review before deployment to catch edge cases Claude might miss
- **Clear documentation**: So Claude (and other team members) understand context and constraints

For common patterns, see `references/templates.md` → Workflow Pattern Examples and Optional Frontmatter Fields.
