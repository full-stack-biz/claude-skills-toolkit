---
name: skill-refiner
description: >-
  Improve and validate existing Claude Code skills for clarity, efficiency, and production readiness.
  Use when: refining skills, improving skill structure, validating against best practices, reducing
  token usage, consolidating references, checking production readiness, or applying the 80% rule.
  Takes imperfect existing skills and elevates them to quality standards.
version: 1.4.1
allowed-tools: Read,Edit,Write,Glob,Task(*),AskUserQuestion
---

# Skill Refiner

Systematically improve and validate Claude Code skills while preserving functionality and following established patterns.

## Quick Start

**Step 0: Detect Predating Context (Escape Hatch)**

Check conversation history:
- User already provided the skill file or shared code?
- User already described the problem/issue?
- User is actively discussing a skill's problems?

**IF PREDATING CONTEXT EXISTS** → Offer escape hatch immediately:

```
questions: [
  {
    question: "I've reviewed the skill and context you provided. How would you like to proceed?",
    header: "Interview Style",
    options: [
      {
        label: "Infer from context",
        description: "I'll infer refinement needs from what you shared. Skip detailed interview (faster)"
      },
      {
        label: "Define explicitly",
        description: "I'll ask you to explicitly define improvement areas and goals (full interview)"
      }
    ],
    multiSelect: false
  }
]
```

Then route:
- **"Infer from context"** → Skip to BATCH 2 with context-tailored prompts
- **"Define explicitly"** → Full BATCH 1 + BATCH 2

**IF NO PREDATING CONTEXT** → Continue to Step 1

**Step 1:** Use AskUserQuestion to ask: **"What skill do you want to work on?"** (open-form text input)

**Step 2:** Use AskUserQuestion with **predefined options** to ask:

```
questions: [
  {
    question: "What would you like to do with this skill?",
    header: "Action",
    options: [
      {
        label: "Refine",
        description: "Improve clarity, structure, efficiency, token usage, or organization"
      },
      {
        label: "Validate",
        description: "Check if it's production-ready (tool scoping, completeness, error handling, trigger phrases)"
      }
    ],
    multiSelect: false
  }
]
```

**Step 3:** Route based on their selection:

- **If "Refine"** → Proceed to **Core Workflow: Refinement** (you'll be asked BATCH 1 + BATCH 2 interview questions during the workflow)
- **If "Validate"** → Skip interview, go directly to **Core Workflow: Validation**

## Core Workflow: Refinement

**When user requests refinement:**

1. **Locate the skill (MANDATORY first step)**
   - Search current project first: `skills/skill-name/`, `.claude/skills/skill-name/`
   - If not found in project → Check user-space: `~/.claude/skills/skill-name/`
   - If found in user-space → WARN: "This affects all projects. Continue?"
   - If in cache (`~/.claude/plugins/cache/`) → REFUSE: "That's an installed copy (read-only)"
   - If not found anywhere → ASK: "Where should I find this skill?"

### Requirements Interview (Progressive Disclosure - One Batch at a Time)

After locating the skill, **interview to gather what they want improved** using AskUserQuestion with proper options.

**🔴 BATCH 1: Refinement Focus** (Progressive AskUserQuestion - ask one at a time):

#### Question 1: What aspects need improvement?

```
questions: [
  {
    question: "What aspects need improvement?",
    header: "Focus Areas",
    options: [
      { label: "Clarity", description: "Make instructions clearer, remove jargon, improve examples" },
      { label: "Efficiency", description: "Reduce token usage, consolidate references, optimize content" },
      { label: "Structure", description: "Reorganize sections, improve flow, better grouping" },
      { label: "User Interaction UX", description: "Convert free-form interactions to AskUserQuestion patterns, improve workflows" }
    ],
    multiSelect: true
  }
]
```

#### Question 2: What specific problems are you seeing?

```
questions: [
  {
    question: "What specific problems are you seeing?",
    header: "Key Issues"
  }
]
```

(Examples: "Instructions are hard to follow", "References scattered and redundant", "Too many nested sections")

#### Question 3: What would success look like?

```
questions: [
  {
    question: "What would success look like?",
    header: "Success Metric"
  }
]
```

(Examples: "Clearer workflow", "Fewer token costs", "Production-ready with error handling")

#### Question 4: Any areas to exclude or preserve as-is?

```
questions: [
  {
    question: "Any areas to exclude or preserve as-is?",
    header: "Scope Limits"
  }
]
```

(Examples: "Keep the validation gates", "Don't change tool scoping")

After gathering ALL responses, document approved scope and proceed to BATCH 2.

**🟢 BATCH 2: Implementation Details** (Use AskUserQuestion with predefined options)

**ROUTING NOTE:**
- If user chose **"Infer from context"** in escape hatch → Skip BATCH 1, come straight here
- If user chose **"Define explicitly"** → Proceed after BATCH 1 responses
- **Context-Aware Prompts:** When inferring from context, tailor questions to specific issues mentioned (e.g., "I saw token usage issues in references. Consolidate them?" vs generic "Should we consolidate?")

```
questions: [
  {
    question: "Should we consolidate related reference files to reduce scattered content?",
    header: "References",
    options: [
      { label: "Yes", description: "Merge related files for clarity" },
      { label: "No", description: "Keep current structure" }
    ],
    multiSelect: false
  },
  {
    question: "Should we also validate against production standards?",
    header: "Production Validation",
    options: [
      { label: "Yes", description: "Check error handling, tool scoping, security" },
      { label: "No", description: "Skip production validation" }
    ],
    multiSelect: false
  },
  {
    question: "Should we add testing & validation patterns (evaluation framework, test patterns, quality gates)?",
    header: "Testing & Validation",
    options: [
      { label: "Yes", description: "Add evaluation framework and quality gates" },
      { label: "No", description: "Skip testing patterns" }
    ],
    multiSelect: false
  }
]
```

After gathering ALL responses, document approved scope and proceed.

---

2. **Load workflow reference**
   - Review `references/refinement-workflow.md` for the complete refinement workflow with all preservation gates and validation phases

3. **Identify consolidation opportunities (BEFORE changes)**
   - List all files in `references/` directory with line counts
   - Group by topic (what do they cover?)
   - Flag potential merges (2-4 files on same topic → 1 consolidated file)
   - ASK: "Should we consolidate these files? Saves N lines, improves clarity"
   - Only proceed if operator approves

4. **Apply preservation gates (CRITICAL - four gates, in order)**
   - **GATE 1**: Content Audit - list ALL existing content, classify as core (80%+) or supplementary (<20%)
   - **GATE 2**: Capability Assessment - will changes impair execution? If YES → cannot delete, only migrate
   - **GATE 3**: Migration Verification - before moving content, verify destination exists and is complete
   - **GATE 4**: Operator Confirmation - deletions require explicit approval, migrations auto-approved

5. **Make changes (following movement pattern)**
   - CREATE/UPDATE destination FIRST (new file, updated section)
   - LINK - update SKILL.md pointers to new destination
   - DELETE old source (only after links verified)
   - Never delete first; always: CREATE → LINK → DELETE

6. **Validate result (seven phases)**
   - Phase 1: File Inventory - list structure before/after
   - Phase 2: Read All - load complete content, verify no gaps
   - Phase 3: Frontmatter - check required metadata (name, description)
   - Phase 4: Body Content - verify <500 lines, 80% rule applied, clarity improved
   - Phase 5: References - confirm all linked files exist and are complete
   - Phase 6: Tools - review allowed-tools scoping against skill needs
   - Phase 7: Testing - verify activation with real-world trigger phrases

## Core Workflow: Validation

**When user requests validation:**

1. **Locate the skill** (same as refinement step 1)

2. **Run validation phases (seven phases, systematic)**
   - **Phase 1: File Inventory** - List all files: SKILL.md, references/, scripts/, assets/
   - **Phase 2: Read All** - Load complete skill content (frontmatter, body, all references)
   - **Phase 3: Frontmatter Check** - Verify required fields: `name`, `description`
   - **Phase 4: Body Content** - Check: <500 lines? 80% rule applied? Clear procedural instructions?
   - **Phase 5: References** - Verify: all linked files exist? No orphaned files? One level deep only?
   - **Phase 6: Tool Scoping** - Review `allowed-tools` against actual tool usage. Principle of least privilege applied?
   - **Phase 7: Testing** - Verify activation: does description include trigger phrases? Will Claude recognize real requests?

3. **Generate validation report**
   - Structure: Status (✅ Production Ready / ⚠️ Needs Review / ❌ Issues Found)
   - Detail: Findings from all seven phases
   - Recommendations: Specific improvements if issues found
   - Priority: Which issues are critical vs. advisory

## Key Rules (Non-Negotiable)

### The 80% Rule (Content Distribution)
- Will Claude execute this in 80%+ of skill activations? → **STAYS in SKILL.md**
- Will Claude execute this in <20% of cases? → **CAN MOVE to references/**
- Uncertain? → **DEFER to operator; keep in SKILL.md by default**

### Movement Pattern (for content changes)
```
SEQUENCE (never violate order):
1. CREATE/UPDATE destination file(s) with merged content
2. LINK - Update SKILL.md pointers to new destination(s)
3. DELETE old source (only after links verified and tested)

NEVER: DELETE → LINK → CREATE (creates broken links and lost content)
```

**Visual flow:**

```
    ❌ WRONG                              ✅ CORRECT

    DELETE old source                     CREATE destination
            │                                     │
            ▼                                     ▼
    LINK to new location                  LINK pointers
            │                                     │
            ▼                                     ▼
    CREATE destination                    DELETE old source
    (broken links!)                       (safe, links verified)
```

### Preservation Gates (Four Gates, In Order)
1. **Content Audit** - List ALL existing content. Classify using **the 80% rule**: core content (used in 80%+ of activations) vs. supplementary (<20%). Example: release-process uses standard workflow every time → core; monorepo coordination is rare → supplementary. See `references/80-percent-rule.md` for full decision framework.
2. **Capability Assessment** - Will changes impair execution? If YES → cannot delete, only migrate
3. **Migration Verification** - Before moving, verify destination complete. NO GAPS
4. **Operator Confirmation** - Deletions require explicit approval. Migrations auto-approved

### Scope Rules (Where to Work)
✅ **PREFERRED** - Project paths (search first):
- `skills/skill-name/` in plugin projects
- `.claude/skills/skill-name/` in any project

⚠️ **CONDITIONAL** - User-space (only if not in project):
- `~/.claude/skills/skill-name/` - WARN: "Affects all projects"
- Requires explicit user confirmation before editing
- Offer to copy to project instead

❌ **FORBIDDEN** - Never edit (REFUSE IMMEDIATELY):
- `~/.claude/plugins/cache/*` (installed plugins - read-only)
- Any path containing `/cache/` (always read-only)

## Reference Guide

### Refining for Clarity
Remove jargon, improve examples, restructure for flow
→ `references/ask-user-question-patterns.md` for interaction patterns
→ `references/content-guidelines.md` for description improvement
→ `references/anti-patterns.md` for what NOT to do

### Refining for Efficiency (Token Usage)
Apply 80% rule, consolidate references, optimize content
→ `references/80-percent-rule.md` for content distribution decisions
→ `references/skill-workflow.md` for detailed framework
→ `references/movement-pattern.md` for safe migration procedure

### Refining for Structure
Reorganize sections, improve grouping, better information flow
→ `references/refinement-workflow.md` for unified workflow with gates
→ `references/movement-pattern.md` for safe content relocation
→ `references/advanced-patterns.md` for archetype structures

### Preserving Functionality (Safety Gates)
Never break existing behavior, never delete without knowing where content goes
→ `references/preservation-rules.md` for what NEVER gets cut
→ `references/refinement-guardrails.md` for safe patterns
→ `references/movement-pattern.md` for CREATE → LINK → DELETE sequence

### Validating Quality
Check production readiness, tool scoping, completeness
→ `references/validation-checklist.md` for comprehensive assessment
→ `references/production-patterns.md` for error handling and team patterns
→ `references/allowed-tools.md` for tool scoping validation

### Understanding Refinement Fully
Complete workflow with all phases and preservation gates
→ `references/refinement-workflow.md`

## Pro Tips

**Finding skills efficiently:**
- Project-scoped skills in `skills/` or `.claude/skills/` (search project first)
- User-space skills in `~/.claude/skills/` (only if not in project)
- Use `Glob` pattern: `**/SKILL.md` to find all skills in project
- Never search cache paths; they're read-only copies

**Wizard pattern (progressive disclosure):**
- Ask one question, wait for response, then ask next
- Build context step-by-step (avoid form-like multi-questions)
- Document operator's choices; proceed only with approved scope

**Production patterns:**
- Detailed logging of changes made (helps with version tracking)
- Validation scripts provide confidence before deployment
- Error handling for edge cases (missing files, malformed YAML, etc.)

**Preservation principle:**
- Refinement improves existing functionality; it never reduces it
- When in doubt about deletion, ask operator first
- Movement is safer than deletion (can always link back)

## Common Scenarios

**Scenario 1: "Simplify this skill"**
→ Focus on clarity: restructure sections, improve examples, simplify language
→ Identify redundancy in references, suggest consolidation
→ Verify 80% rule for SKILL.md body content

**Scenario 2: "Reduce token usage"**
→ Apply **80% rule:** identify supplementary content used in <20% of cases (e.g., error handling for rare failure modes) that can move to references
→ Keep core content (80%+ usage) in SKILL.md (e.g., standard error handling patterns)
→ Consolidate related reference files
→ Verify activation doesn't suffer from moved content
→ See `references/80-percent-rule.md` for decision examples

**Scenario 3: "Improve user interaction UX"**
→ Audit all AskUserQuestion calls (max 4 options, progressive disclosure)
→ Convert free-form instructions to predefined AskUserQuestion options where applicable
→ Ensure questions follow wizard pattern (ask → wait → ask, not forms)
→ Verify descriptions are clear and help users make good choices
→ Check for >4 options violations (split into multiple AskUserQuestion batches)
→ See `references/ask-user-question-patterns.md` for patterns and decision trees

**Scenario 3.5: "Improve reference quality"**
→ Audit every reference link: does it provide context about what agents will find?
→ Pattern check: [Core knowledge] + `See `references/file.md` for [edge cases/depth]`
→ Flag orphaned links (bare links with no context): "This reference might not get loaded because agents don't know what's in it"
→ Offer: "Let's add context snippets so agents load references intentionally, not out of uncertainty"
→ Improves token efficiency: references only load when truly needed

**Scenario 4: "Check if this skill is production-ready"**
→ Run full validation phases (all 7 phases)
→ Check: error handling, tool scoping, clear trigger phrases, comprehensive testing
→ Flag missing production patterns (error handling, validation scripts, security review). See `references/production-patterns.md` for team patterns.
→ Generate detailed report with findings and recommendations

**Scenario 5: "Offer to help during skill work"**
→ Detect user is working with skills (reading SKILL.md, editing references, etc.)
→ Offer: "I can help refine this skill (clarity, efficiency) or validate it. Want me to?"
→ If yes, use appropriate workflow above

## Notes

**Token efficiency:** Skill-refiner itself should stay <500 lines (this body content). Reference files contain detailed workflows—loaded on-demand only.

**Auto-activation signals:** Watch for user requests containing: "refine", "improve", "make clearer", "reduce tokens", "validate", "check if ready", "is this production-ready", or when user is actively modifying skill files.

**Error handling:** If skill files can't be located, are malformed, or have structural issues, report specific problems and suggest solutions rather than failing silently.

**Version tracking:** Track changes made to skills during refinement (which files modified, what changed). Helps users understand impact of refinements.
