---
name: skill-creator
description: >-
  Create NEW Claude Code skills from scratch following best practices. Use when building new
  skills, interviewing for requirements, applying templates, organizing frontmatter and body
  content, or converting slash commands to skills. Guides skill structure, naming, descriptions,
  progressive disclosure, reference organization, and tool scoping.
version: 2.6.0
allowed-tools: Read,Write,Edit,Glob,Grep,AskUserQuestion,Agent
---

# Skill Creator

**Purpose:** Create new Claude Code skills from scratch following best practices. Use when building skills from scratch or converting existing slash commands to project-scoped skills.

## Mindset

**CRITICAL:** Skills are instructions FOR CLAUDE, not documentation FOR PEOPLE. Always ask: "Will this help Claude execute the task?" not "Will people find this readable?"

## Quick Start

Start at Implementation Approach below.

## Core Use Cases

**Create new skills** - Build from scratch with correct structure, naming, frontmatter, and validation guidance.
**Convert slash commands** - Migrate existing `~/.claude/commands/` slash commands to project-scoped skills (better context management, subagent support).
**Complex skills** - Ensure robustness with error handling, tool scoping, and version tracking.

## Core Principles

These principles apply to all skill creation and validation work—the foundational mental model Claude must follow.

**Self-Containment** — Skills must be self-contained. Claude needs everything within the skill directory (references, scripts, examples). Avoid external references or network dependencies unless core to the skill's purpose. When deciding about external dependencies, see `references/self-containment-principle.md` for architectural background.

**Progressive Disclosure** — Essential execution instructions first (Quick Start), detailed guidance second (references/), advanced topics last. Quick reference patterns solve 80% of task variants without loading auxiliary files.

**Token Efficiency** — Every token Claude loads must justify its cost for execution. Keep SKILL.md body <500 lines (non-negotiable). Use code examples before prose, tables instead of lists.

**The 80% Rule:** Core procedural content (used in 80%+ of skill activations) stays in SKILL.md. Example: release-process skill keeps standard workflows (patch/feature/breaking) in SKILL.md since every release uses them. Supplementary content (<20% of cases) moves to references/. Example: advanced monorepo coordination moves to references/ since most releases are single-component. Never delete content to reduce line count if it impairs execution. See `references/skill-workflow.md` for decision rules and preservation gates.

**Token Loading** — Metadata (~100 tokens) always loads. SKILL.md body (~1-5k tokens) loads on trigger. References load on-demand only (zero penalty until needed). For token loading mechanics and activation internals: `references/how-skills-work.md`.

**Activation** — Skills trigger via description text alone. Vague descriptions never activate. Include specific trigger phrases Claude will recognize in user requests (e.g., "create skill", "validate skill", "improve", "refine skill").

## Implementation Approach

**▶️ START HERE - Establish Action & Scope**

**Interview 1: Ask - What do you want to do?**

Use AskUserQuestion with predefined options:

```
questions: [
  {
    question: "What do you want to do?",
    header: "Action",
    options: [
      {
        label: "Create a new skill",
        description: "Build a new Claude Code skill from scratch following best practices"
      },
      {
        label: "Convert a slash command",
        description: "Migrate existing ~/.claude/commands/ slash command to a project-scoped skill"
      }
    ],
    multiSelect: false
  }
]
```

⏸️ **Collect user input** — Wait for response to Interview 1 before proceeding.

**Interview 2: Ask - Where should the skill be created?**

(Unified step for BOTH paths — regardless of whether creating from scratch or converting a slash command, establish the skill's location first. This applies before branching to the specific workflow.)

Use AskUserQuestion with predefined options:

```
questions: [
  {
    question: "Where should this skill be created?",
    header: "Skill Scope",
    options: [
      {
        label: "Project-scoped (.claude/skills/)",
        description: "Only available in this project via .claude/skills/ directory"
      },
      {
        label: "User-space (~/.claude/skills/)",
        description: "Available globally across all projects in user's home directory"
      },
      {
        label: "Plugin-scoped (skills/ in plugin)",
        description: "Only if working in a Claude Code plugin project - skill bundled with plugin"
      }
    ],
    multiSelect: false
  }
]
```

**Critical guidance for Agent:**
- ❌ NEVER default to user-space without asking (affects all projects)
- ❌ NEVER create in plugin/skills/ unless explicitly in a plugin project
- ✅ Always confirm scope with user first
- ✅ Default recommendation: Project-scoped (.claude/skills/) for isolated work

⏸️ **Collect user input** — Wait for response to Interview 2 before proceeding.

**Step 3: Route based on action selection**

Use the **action choice** from Interview 1 to route to the appropriate workflow. The **location** from Interview 2 applies to both paths:

- Action: "Create a new skill" → Proceed to "Create New Skill Workflow" section (use location for new skill placement)
- Action: "Convert a slash command" → Proceed to "Convert Slash Command to Skill" section (use location for converted skill placement)

### For New Skills: Requirements Interview with Escape Hatch

After routing to "create", gather requirements using progressive disclosure (AskUserQuestion, one batch at a time). This ensures the skill will activate correctly and Claude will execute it effectively.

**Step 1: Detect Predating Context**

Check conversation history before the skill request:
- User provided URLs, documentation, or code snippets?
- User gave detailed explanation of what needs to be built?
- User asked to "create skill for this" or similar?

**Step 2: Route Based on Context**

**IF NO PREDATING CONTEXT** → Full interview (BATCH 1 + BATCH 2)

**IF PREDATING CONTEXT EXISTS** → Use AskUserQuestion to offer escape hatch:

```
questions: [
  {
    question: "I've reviewed the docs/code/context you provided. How would you like to proceed?",
    header: "Interview Style",
    options: [
      {
        label: "Infer from context",
        description: "I'll infer purpose, scope, and triggers from what you shared. Just ask about complexity and tools (faster)"
      },
      {
        label: "Define explicitly",
        description: "I'll ask you to explicitly define purpose, scope, and triggers (full guided interview)"
      }
    ],
    multiSelect: false
  }
]
```

Then route based on their choice:
- **"Infer from context"** → Skip BATCH 1, go straight to BATCH 2
- **"Define explicitly"** → Full interview (BATCH 1 + BATCH 2)

---

**🔴 BATCH 1: Core Definition** (Prose questions with guidance):

*Do this batch if: no predating context exists, OR user chose "Define explicitly" in the escape hatch. Skip only if user chose "Infer from context."*

### Question 1: Skill Purpose

**What domain-specific task should Claude execute? What problem does this skill solve?**

Describe the skill's purpose and what problem it solves.

(Be specific — "Process PDFs with OCR" is better than "Process files")

[User responds with description]

### Question 2: Trigger Phrases

**What phrases will Claude see in user requests that should trigger this skill?**

List the specific trigger phrases Claude will recognize:

Examples:
- "create skill" (for a skill-creator)
- "validate code" (for a linter)
- "convert to plugin" (for converter)

(Include 2-5 key phrases)

[User responds with trigger phrases]

### Question 3: Scope & Constraints

**What's IN scope for this skill versus OUT of scope?**

Define the boundaries:

Examples:
- IN: "Create new skills, guide best practices"
- OUT: "Refine existing skills (use skill-refiner instead)"

(Clarify what this skill handles and what it doesn't)

[User responds with scope definition]

⏸️ Wait for all 3 responses.

**🟢 BATCH 2: Complexity & Tools** (Structured + Prose):

### Question 1: Complexity (Structured choice)

Use AskUserQuestion with predefined options (different workflows apply):

```
questions: [
  {
    question: "What's the skill's complexity level?",
    header: "Complexity",
    options: [
      { label: "Simple", description: "Single workflow, SKILL.md only, minimal structure" },
      { label: "Complex", description: "Multiple workflows, needs reference files and/or scripts" }
    ],
    multiSelect: false
  }
]
```

[User selects Simple or Complex]

### Question 2: Tool Requirements (Prose guidance)

**Which tools will Claude need to execute this skill?**

List the tools from this set:

- Read, Write (file operations)
- Bash (shell commands)
- Glob, Grep (file searching)
- AskUserQuestion (user input)
- WebFetch, WebSearch (internet access)
- Other tools as needed

Examples:
- "Read, Write, Bash"
- "Read, Write, AskUserQuestion"
- "Glob, Grep, Bash"

[User lists tools needed]

⏸️ Wait for both responses.

## Step 3: Create Skill Structure

Execute the skill creation using your gathered requirements (BATCH 1-2 responses).

### Step 3.1: Create skill directory in chosen location

Use the location from Implementation Approach Interview 2:
- **Project-scoped:** `mkdir -p .claude/skills/skill-name`
- **User-space:** `mkdir -p ~/.claude/skills/skill-name`
- **Plugin-scoped:** `mkdir -p skills/skill-name`

### Step 3.2: Check if templates needed and use them

Refer to `references/templates.md` to apply the template matching your BATCH 1-2 responses (skill purpose, complexity, tools needed). Copy or use template as reference while building.

### Step 3.3: Write frontmatter

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

**For detailed frontmatter patterns, naming conventions, description formulas, and edge cases:** See the Frontmatter section in Key Notes below.

### Step 3.4: Write SKILL.md body

Write instructions Claude will follow to execute the task. Structure: Quick Start → Workflows → Key Notes → Full Reference (optional)
- Target <500 lines (Claude reads this body every time skill triggers; token efficiency is mandatory)
- Code-first: examples Claude can adapt before abstract explanations
- Progressive disclosure: essentials Claude needs immediately → advanced topics later

### Step 3.5: Content-Size Check

After writing the body, evaluate what you've created:
1. Count total lines of SKILL.md body + any planned reference content
2. Check size:
   - **< 500 lines total?** → Skip to Step 3.8 (Validate). No references/ directory needed.
   - **≥ 500 lines total?** → Proceed to Step 3.6 (Create references/). Split content across files.

**User Feedback (if complexity/content mismatch):**

If user selected "Complex" BUT total content < 500 lines:

```
You selected Complexity: Complex
Total content generated: [X lines]

Since the total content is [X lines] (under 500 line threshold),
I'm keeping everything in SKILL.md for now. No separate references needed yet.

As the skill grows beyond 500 lines, we'll split into references/ to maintain token efficiency.
```

### Step 3.6: Create references/ (conditional)

Only proceed if Step 3.5 indicated ≥500 lines total:

```bash
mkdir -p skill-name/references
```

### Step 3.7: Add references (conditional)

Only proceed if Step 3.6 created the references/ directory:

Move supplementary content (<20% of activations) into reference files. Create table of contents for comprehensive guides. Keep one level deep (no nested subdirectories).

### Step 3.8: Validate

Check structure, content, security, activation. See `references/checklist.md` for comprehensive validation across all dimensions before deployment.

### Step 3.9: Optional — Refine Your Skill

**Question:** Would you like to refine the skill before testing it?

Use AskUserQuestion:

```
questions: [
  {
    question: "Would you like to refine this skill before testing?",
    header: "Next Step",
    options: [
      {
        label: "Yes, refine with skill-refiner",
        description: "Improve skill clarity, efficiency, structure. Validate against best practices (optional iteration)"
      },
      {
        label: "No, skip refinement",
        description: "Proceed directly to testing or completion"
      }
    ],
    multiSelect: false
  }
]
```

⏸️ **Collect user input.**

**If user chose "Yes, refine now":**

Tell user: "Launching skill-refiner. This will validate and improve your skill's quality."

Then delegate to skill-refiner using Agent tool:

```
Agent type: general-purpose
Prompt: "
The user just finished creating a new skill at <skill_path>.
They want to refine it using skill-refiner.

Invoke skill-refiner to:
1. Analyze the skill (structure, clarity, efficiency)
2. Identify improvement opportunities
3. Apply refinements (wording, organization, token optimization)
4. Validate final quality

After refinement completes, tell the user: 'Skill refined. Ready for testing?'
Then stop and let the original skill-creator workflow offer testing."
```

**If user chose "No, skip refinement":**

Continue to Step 3.10 (testing step below).

### Step 3.10: Optional — Test Your Skill (Empirical Validation)

**Question:** Would you like to test this skill empirically?

Use AskUserQuestion:

```
questions: [
  {
    question: "Would you like to test this skill empirically?",
    header: "Testing",
    options: [
      {
        label: "Yes, test now with skill-tester",
        description: "Run quick validation: design test cases, test your new skill, show pass/fail results (fast feedback)"
      },
      {
        label: "No, done",
        description: "Skill is complete. You can test anytime with /skills-toolkit:skill-tester"
      }
    ],
    multiSelect: false
  }
]
```

⏸️ **Collect user input.**

**If user chose "Yes, test now":**

Tell user: "Launching skill-tester (Quick Workflow). This will create an evals/ workspace, run test cases with the new skill, and show pass/fail results. No baseline comparison—just a sanity check."

Then delegate to skill-tester using Agent tool:

```
Agent type: general-purpose
Prompt: "
The user just finished creating a new skill at <skill_path>.
They want to quickly test it using skill-tester's QUICK WORKFLOW mode (not full pipeline).

Invoke skill-tester to:
1. Confirm the skill (Phase 1: Setup)
2. Interview user for test scenarios (Phase 2: Create Evals)
3. RUN QUICK WORKFLOW (fast validation):
   - Test the new skill on the scenarios
   - Grade if it passes the test criteria
   - Show simple pass/fail results
   - Ask: Refine? Run full benchmarking? Done?

QUICK MODE: Just test the skill itself, no comparisons.

The evals/ workspace should live at ./evals/<skill-name>/

Tell the user: 'Quick test complete. Results show if the skill works as intended.'"
```

**If user chose "No, done":**

Confirm: "Skill created and (optionally refined). You can test it anytime with `/skills-toolkit:skill-tester`."

## Convert Slash Command to Skill

**Shorthand:** Recommend skill migration for complex commands or team/project-scoped automation. Self-convert simple commands (1-10 lines); offer help for complex logic or unclear structure.

**Full conversion workflow:** See `references/slash-command-conversion.md` for detection, mapping, conversion logic, and validation process.

## Key Notes

**Wizard Pattern (this skill models the pattern it teaches) - CRITICAL EXECUTION RULE:**
Progressive disclosure ALWAYS means: ask ONE question, wait for response, then ask next. Never combine questions into a single AskUserQuestion call.
- ❌ WRONG: Ask 2 questions in one AskUserQuestion (looks like a form)
- ✅ RIGHT: Ask question 1 → wait for response → then ask question 2 (if conditional)
When tool has constraints (maxItems: 4), this pattern is mandatory. Applied in "For Improvements (Refining)" section's approval workflow. Claude must follow this pattern when implementing guided user interactions in skills.

**Frontmatter (Claude reads this to discover and activate skills):**
- YAML syntax (use triple dashes: `---`)
- `name`: Optional (uses directory name if omitted), lowercase-hyphen, ≤64 chars, no "anthropic"/"claude"
- `description`: Recommended, ≤1024 chars, must include specific trigger phrases Claude recognizes
- Description is Claude's activation signal (vague descriptions = skill never activates)

**Optional frontmatter (for complex skills):**
- `version: 1.0.0` — Track skill evolution for coordination
- `allowed-tools: Read,Write,Bash(git:*)` — Declare only tools Claude needs. Restrict Bash to specific commands (e.g., `Bash(git:*)`). See `references/allowed-tools.md` for tool scoping validation.
- Copy tool patterns from `references/templates.md` for reference

**Naming conventions:**
- Hyphen-separated lowercase: `skill-name`, `my-feature-validator`
- Prefer gerund form: `processing-pdfs`, `analyzing-spreadsheets`
- Include action/domain: `test-runner`, `skill-creator`, `code-reviewer`
- Avoid generic: prefer `log-analyzer` over `analyzer`

**Description formula (Claude uses this to decide whether to activate):**
```
[Action]. Use when [trigger contexts]. [Scope/constraints].
```
**Example:** "Run tests and generate reports. Use when validating code before commit. Supports PHPUnit and Jest."

✅ **Good descriptions** include specific trigger phrases Claude will recognize in user requests (e.g., "create", "validate", "improve", "refine").

❌ **Vague descriptions** (e.g., "Process things") never activate the skill when users need it.

**Complex skill considerations:** For complex skills requiring robust structure, ensure error handling, tool scoping, validation scripts, security review, and clear documentation. See `references/complex-skills-patterns.md` for detailed guidance on these patterns, plus `references/advanced-patterns.md` and `references/checklist.md` for additional requirements.

**Secrets & credentials:** Skills must never contain hardcoded secrets (API keys, passwords, tokens). Use environment variables instead, validate they're set, and provide clear error messages. Never commit `.env` files or credentials to git. See `references/secrets-and-credentials.md` for complete guidance on detection, handling, git safety, and testing patterns.

**Content distribution rule:** Apply the 80% Rule principle: keep core procedural content in SKILL.md <500 lines total. Supplementary content (<20% of activations) moves to references/. Reference files have zero token penalty until needed. See the Content-Size Check section for sizing logic.

**Reference Linking Pattern (when your skill has references):**

Every reference link teaches agents what they're looking for, so they decide confidently whether to load it:

- ❌ WRONG: `See `references/advanced-patterns.md` for more info.` (Agent: "What's in there? Better load it to be safe.")
- ✅ RIGHT: `Pattern: [core idea]. See `references/advanced-patterns.md` for [edge cases/advanced scenarios].` (Agent: "I have the pattern. The reference has detailed cases I might need.")

**Template:**
```
[What agents need 80% of the time]. See `references/<filename.md>` for [what depth/edge cases are there].
```

**Example:**
```
**The 80% Rule:** Will Claude execute this 80%+ of activations? → STAYS in SKILL.md. <20% cases? → MOVES to references/. See `references/<80-percent-rule.md>` for decision trees and edge cases.
```

Why? Without context, agents load references out of uncertainty (wastes tokens). With context, they load references *intentionally* when needed. The reference becomes more valuable, not less.

**Base Directory context:** When skill-creator loads, the system shows a "Base directory" path. This points to THIS skill's installed location—use it ONLY for loading skill-creator's own references (`references/templates.md`, etc.). Never use it to locate target skills you're asked to work on. Target skills must be discovered via the "Locate the Target Skill" workflow.

## Reference Guide

### Structuring Your Skill

**Step 1: Choose the right template**
→ Decision: Simple (SKILL.md only, <300 lines) or Complex (multiple references/scripts)?
→ Each template shows: frontmatter + Quick Start + core sections + validation
→ `references/templates.md`

**Step 2: Write frontmatter & descriptions**
→ Pattern: [Action]. Use when [trigger contexts]. [Scope]. Include specific trigger phrases Claude recognizes.
→ Example: "Create skills. Use when building new Claude Code skills from scratch."
→ `references/content-guidelines.md` for phrase library and activation examples

**Step 3: Organize content using 80% rule**
→ Core procedural (80%+ of skill activations) → SKILL.md body (<500 lines)
→ Supplementary (edge cases, <20%) → references/ subdirectory
→ Progressive disclosure: Quick Start → Workflows → Advanced sections
→ `references/skill-workflow.md` for detailed content distribution framework

**Step 4: Design user interactions**
→ Rule: Max 4 AskUserQuestion options per question. Progressive disclosure: ask → wait → ask next (never combine into forms).
→ `references/ask-user-question-patterns.md` for interaction patterns and decision trees

**Step 5: Validate quality before release**
→ Checklist: (1) Frontmatter complete, (2) <500 lines, (3) 80% rule applied, (4) All references complete, (5) Tool scoping matches needs, (6) Tested with real trigger phrases
→ `references/checklist.md` for comprehensive validation across all dimensions

**Step 6: Avoid common mistakes**
→ 16 patterns: thinking of skills as documentation, orphaned references, vague descriptions, moving content just to reduce lines, etc.
→ Each mistake has BAD/GOOD example showing what to do instead
→ `references/anti-patterns.md`

### Understanding Skill Fundamentals (Optional Deep Dive)

**How skills are loaded and activated:**
→ Frontmatter (~100 tokens) always loads for discovery. SKILL.md body (~1-5k tokens) loads when skill triggers. References load on-demand (zero penalty until needed).
→ `references/how-skills-work.md` for token loading mechanics and activation internals

### Building Complex Skills

**Error handling, security, tool scoping:**
→ Robust patterns: validation scripts, error recovery, security review, documentation
→ `references/complex-skills-patterns.md`

**Preventing secret leaks:**
→ Never hardcode API keys, passwords, tokens. Use environment variables, validate at startup, provide clear error messages if missing. Never commit .env files to git.
→ `references/secrets-and-credentials.md` for detection, handling, git safety, and testing patterns

**Tool scoping (principle of least privilege):**
→ Declare only tools Claude needs. Restrict Bash to specific commands (e.g., `Bash(git:*)`).
→ `references/allowed-tools.md` for scoping validation and security patterns

**External dependencies & self-containment:**
→ Skills should contain everything they need (references, scripts, examples). Avoid external APIs unless core to skill purpose.
→ `references/self-containment-principle.md` for architectural guidance

**Complex skill patterns & specialized skills:**
→ Patterns for robustness: encoding reproducible prompts, front-loading motivation, documenting ecosystem integration, risk tiering for safety, exit code standardization, ASCII flow diagrams, configuration precedence documentation, extended thinking signals, iteration protocols, dynamic context injection (live data preprocessing), impact tiering, and outcome metrics.
→ Skill archetypes: CLI reference tools, methodology guides, safety/security tools, orchestration systems.
→ `references/advanced-patterns.md` for full pattern library and detailed examples

