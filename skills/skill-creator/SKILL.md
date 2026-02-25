---
name: skill-creator
description: >-
  Create NEW Claude Code skills from scratch following best practices. Use when building new
  skills, interviewing for requirements, applying templates, organizing frontmatter and body
  content, or converting slash commands to skills. Guides skill structure, naming, descriptions,
  progressive disclosure, reference organization, and tool scoping.
version: 2.4.0
allowed-tools: Read,Write,Edit,Glob,Grep,AskUserQuestion
---

# Skill Creator

**Purpose:** Create new Claude Code skills from scratch following best practices.

## Quick Start

Use AskUserQuestion with **predefined options**:

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

Then route to the appropriate section below based on their selection.

---

## Core Use Cases

**Create new skills** - Build from scratch with correct structure, naming, frontmatter, and validation guidance.
**Convert slash commands** - Migrate existing `~/.claude/commands/` slash commands to project-scoped skills (better context management, subagent support).
**Team/production skills** - Ensure robustness with error handling, tool scoping, and version tracking.

## Mindset

**CRITICAL:** Skills are instructions FOR CLAUDE, not documentation FOR PEOPLE. Always ask: "Will this help Claude execute the task?" not "Will people find this readable?"

## Core Principles

These principles apply to all skill creation and validation work—the foundational mental model Claude must follow.

**Self-Containment** — Skills must be self-contained. Claude needs everything within the skill directory (references, scripts, examples). Avoid external references or network dependencies unless core to the skill's purpose. When deciding about external dependencies, see `references/self-containment-principle.md` for architectural background.

**Progressive Disclosure** — Essential execution instructions first (Quick Start), detailed guidance second (references/), advanced topics last. Quick reference patterns solve 80% of task variants without loading auxiliary files.

**Token Efficiency** — Every token Claude loads must justify its cost for execution. Keep SKILL.md body <500 lines (non-negotiable). Use code examples before prose, tables instead of lists.

**The 80% Rule:** Core procedural content (used in 80%+ of skill activations) stays in SKILL.md. Example: release-process skill keeps standard workflows (patch/feature/breaking) in SKILL.md since every release uses them. Supplementary content (<20% of cases) moves to references/. Example: advanced monorepo coordination moves to references/ since most releases are single-component. Never delete content to reduce line count if it impairs execution. See `references/skill-workflow.md` for decision rules and preservation gates.

**Token Loading** — Metadata (~100 tokens) always loads. SKILL.md body (~1-5k tokens) loads on trigger. References load on-demand only (zero penalty until needed). For token loading mechanics and activation internals: `references/how-skills-work.md`.

**Activation** — Skills trigger via description text alone. Vague descriptions never activate. Include specific trigger phrases Claude will recognize in user requests (e.g., "create skill", "validate skill", "improve", "refine skill").

## Implementation Approach

**▶️ START HERE - Quick Workflow**

1. Ask: What do you want to do? (create / convert slash command)
2. For create: Gather requirements interview, then route to "New Skills" section
3. For slash command conversion: Offer conversion support following conversion workflow

**BEFORE ANY OPERATION - Locate the Target Skill:**

When user mentions a skill by name (e.g., "refine plugin-creator"):

1. **Search CURRENT PROJECT first (preferred):**
   ```
   skills/skill-name/SKILL.md
   .claude/skills/skill-name/SKILL.md
   packages/*/skills/skill-name/SKILL.md
   ```

2. **If found in project** → Use that path (source confirmed)

3. **If NOT found in project** → Search user-space:
   ```
   ~/.claude/skills/skill-name/SKILL.md
   ```

4. **If found in user-space** → Warn and confirm:
   > "I found `skill-name` in `~/.claude/skills/` (user-space, affects all projects).
   > It's not in this project. Do you want to:
   > - Edit the user-space copy directly?
   > - Copy it to this project first, then edit?"

5. **If NOT found anywhere** → Ask user:
   > "I couldn't find `skill-name` in this project or user-space. Where is the source?"

6. **NEVER search or use:**
   - `~/.claude/plugins/cache/*` (installed copies - read-only)
   - Skill's own base directory (that's for THIS skill's references only)

**Note:** The "Base directory" shown when this skill loads points to THIS skill's location for accessing its own references. Never use it to locate target skills.

---

**Scope Rules: Source Code Only (NO CACHE EDITS)**

✅ **PREFERRED - Project paths (search first):**
- `skills/skill-name/` in plugin projects
- `.claude/skills/skill-name/` in any project
- `packages/*/skills/skill-name/` (monorepo patterns)

⚠️ **CONDITIONAL - User-space (only if not in project):**
- `~/.claude/skills/skill-name/` - Warn: "Affects all projects"
- Requires explicit user confirmation before editing
- Offer to copy to project instead

❌ **FORBIDDEN - Never edit (REFUSE IMMEDIATELY):**
- `~/.claude/plugins/cache/*` (installed plugins - Claude-managed)
- Any path containing `/cache/` (always read-only)

**Search Priority:**
```
1. Current project     → Edit directly (preferred)
2. User-space          → Warn + confirm (conditional)
3. Cache               → REFUSE (never)
4. Not found           → Ask user for source path
```

**For NEW skills (scope detection):**
- Plugin project? → Default: `skills/skill-name/`
- Regular project? → Default: `.claude/skills/skill-name/`
- Ask only if ambiguous

### For New Skills: Requirements Interview First

After routing to "create", **interview the user to gather requirements** using progressive disclosure (AskUserQuestion, one batch at a time). This ensures the skill will activate correctly and Claude will execute it effectively.

**🔴 BATCH 1: Core Definition** (Use AskUserQuestion with open-form responses):

```
questions: [
  {
    question: "What domain-specific task should Claude execute? What problem does this solve?",
    header: "Skill Purpose",
    options: [] // Open-form
  },
  {
    question: "What phrases will Claude see in user requests when this skill should activate?",
    header: "Trigger Phrases",
    options: [] // Open-form
  },
  {
    question: "What's IN scope? What's OUT of scope?",
    header: "Scope & Constraints",
    options: [] // Open-form
  },
  {
    question: "Which tools will Claude need (file operations, Bash, web access, etc.)?",
    header: "Tool Needs",
    options: [] // Open-form
  }
]
```

⏸️ Wait for all 4 responses.

**🟢 BATCH 2: Team & Complexity** (Then use AskUserQuestion with predefined options):

```
questions: [
  {
    question: "Will multiple Claude instances use this? Production data involved?",
    header: "Team & Production",
    options: [
      { label: "Personal use only", description: "Single user, no shared data" },
      { label: "Team or production", description: "Multiple users or production data involved" }
    ],
    multiSelect: false
  },
  {
    question: "Will Claude need scripts or reference files? Multiple workflows?",
    header: "Complexity",
    options: [
      { label: "Simple", description: "Single workflow, SKILL.md only" },
      { label: "Complex", description: "Multiple workflows, needs scripts or references" }
    ],
    multiSelect: false
  }
]
```

After gathering ALL responses, use `references/templates.md` to apply requirements to the appropriate skill template.

### For Converting Slash Commands to Skills

**Shorthand:** Recommend skill migration for complex commands or team/project-scoped automation. Self-convert simple commands (1-10 lines); offer help for complex logic or unclear structure.

**Full conversion workflow:** See `references/slash-command-conversion.md` for detection, mapping, conversion logic, and validation process.

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
Check structure, content, security, activation. See `references/checklist.md` for comprehensive validation across all dimensions before deployment.

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

### Building Team or Production Skills

**Error handling, security, tool scoping:**
→ Robust patterns: validation scripts, error recovery, security review, team documentation
→ `references/team-production-patterns.md`

**Preventing secret leaks:**
→ Never hardcode API keys, passwords, tokens. Use environment variables, validate at startup, provide clear error messages if missing. Never commit .env files to git.
→ `references/secrets-and-credentials.md` for detection, handling, git safety, and testing patterns

**Tool scoping (principle of least privilege):**
→ Declare only tools Claude needs. Restrict Bash to specific commands (e.g., `Bash(git:*)`).
→ `references/allowed-tools.md` for scoping validation and security patterns

**External dependencies & self-containment:**
→ Skills should contain everything they need (references, scripts, examples). Avoid external APIs unless core to skill purpose.
→ `references/self-containment-principle.md` for architectural guidance

**Production patterns & specialized skills:**
→ Common archetypes: validators, transformers, multi-workflow coordinators. Examples of quality production skills.
→ `references/advanced-patterns.md` for proven patterns and detailed examples

### Converting Slash Commands to Skills

**Migration workflow:**
→ Detect command type → identify entry point → extract logic → map to skill structure → validate
→ `references/slash-command-conversion.md` for full conversion process with examples

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

**Optional frontmatter (for team/production skills):**
- `version: 1.0.0` — Track skill evolution for team coordination
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

**Team/Production considerations:** For skills used in team environments or with production data, ensure robust error handling, tool scoping, validation scripts, security review, and clear documentation. See `references/team-production-patterns.md` for detailed guidance on these patterns, plus `references/advanced-patterns.md` and `references/checklist.md` for additional requirements.

**Secrets & credentials:** Skills must never contain hardcoded secrets (API keys, passwords, tokens). Use environment variables instead, validate they're set, and provide clear error messages. Never commit `.env` files or credentials to git. See `references/secrets-and-credentials.md` for complete guidance on detection, handling, git safety, and testing patterns.

**Content distribution rule:** Keep SKILL.md <500 lines. Add >50 lines? Create reference file instead. Reference files have zero token penalty until needed.

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
