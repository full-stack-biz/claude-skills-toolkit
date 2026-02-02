# The 80% Rule: Content Distribution Decision Framework

The **80% Rule** is the core decision-making framework for determining what content stays in SKILL.md versus what moves to references/.

## The Core Question

Before moving, removing, or reorganizing ANY content, ask:

**"Will Claude execute this in 80%+ of skill activations?"**

| Answer | Classification | Action |
|--------|----------------|--------|
| YES | Core procedural | **STAYS in SKILL.md** |
| NO | Supplementary | Can move to references/ |
| UNCERTAIN | Unknown impact | Defer to operator; keep in SKILL.md |

## What STAYS in SKILL.md (Core Procedural)

Content Claude needs for the common case (80%+ of activations):

- Step-by-step workflows for standard execution
- Pattern examples Claude directly applies
- Decision trees for common branching logic
- Concrete input/output samples
- Essential command syntax or copyable code blocks
- Activation clarification (how/when to invoke)
- Quick Start sections
- Core procedures and patterns

**Examples:**
- Release-process skill: All 4 pattern examples (patch, feature, breaking, scope-creep) → STAYS (used in 80%+ of releases)
- PDF processor skill: Basic extraction workflow → STAYS
- Test runner skill: Standard test execution (Jest, PHPUnit) → STAYS
- Skill-refiner: Refinement workflow with preservation gates → STAYS

## What MOVES to references/ (Supplementary)

Content for edge cases, advanced users, or background context (<20% of activations):

- Edge cases beyond standard workflow
- Alternative approaches for power users
- Deep context on adjacent topics
- Expanded explanations of already-covered concepts
- Troubleshooting uncommon failure modes
- Historical or architectural context
- Advanced configuration options
- Production patterns (error handling, versioning, etc.)

**Examples:**
- Release-process skill: Monorepo multi-component coordination → MOVES (beyond single-component pattern)
- PDF processor skill: OCR configuration for specific document types → MOVES
- Test runner skill: Complex parallel configuration → MOVES
- Skill-refiner: Production patterns, advanced skill patterns → MOVES

## Content Distribution Decision Tree

```
Is this content used in 80%+ of skill activations?
│
├─ YES → STAYS in SKILL.md (core procedural)
│   └─ Keep accessible on every trigger
│
├─ NO → Can MOVE to references/ (supplementary)
│   ├─ Is there an existing reference file for this topic?
│   │   ├─ YES → Append to it
│   │   └─ NO → Create new reference file
│   └─ Ensure SKILL.md links to the reference file
│
└─ UNCERTAIN → Defer to operator
    └─ Default: keep in SKILL.md
```

## Common Mistakes to Avoid

❌ **Don't move content just because it's long**
- If that content is core procedural, Claude needs it immediately
- Moving core content doesn't save tokens; SKILL.md body loads anyway on trigger

❌ **Don't assume "examples = reference material"**
- Examples are how Claude understands the task
- If examples are patterns for common cases, they're core procedural

❌ **Don't optimize token count at the cost of execution quality**
- SKILL.md body loads on trigger regardless
- Moving core content doesn't save tokens, just adds a file load
- Moving supplementary content DOES save tokens (zero penalty until loaded)

✅ **Do ask "Will Claude execute this in 80%+ of cases?"**
- If yes: Keep in SKILL.md
- If no: Move to references/

## Size Constraints

- SKILL.md body must stay <500 lines (non-negotiable)
- If core procedural content exceeds 500 lines, that's the skill's true size
- In rare cases, split into two skills (e.g., "basic-skill" and "advanced-skill")
- References are one-level-deep only: `references/file.md`, never `references/subdir/file.md`

## Practical Refinement Example

**Scenario:** Skill-refiner has 5 reference files on related topics. Can we consolidate?

**Analysis using 80% rule:**
- **Consolidation opportunity:** "These 5 files cover refinement aspects. Would Claude need all of them in 80%+ of refinements?"
- **Assessment:** No. Most refinements need ONLY the workflow (refinement-workflow.md). Advanced patterns, preservation rules, and production patterns are supplementary (edge cases).
- **Decision:** Keep files separate. Claude loads refinement-workflow.md immediately on trigger; others load on-demand only.

**Better consolidation scenario:**
- Two reference files on "movement patterns" (part of refinement-guardrails.md and separate movement-pattern.md)
- **Assessment:** Both cover the same critical topic. Movement Pattern is core procedural (used in 80%+ of refinements).
- **Decision:** Consolidate both into one clear "movement-pattern.md". Reduces file count while keeping critical content accessible.

## When the 80% Rule Applies

✅ **Applies to:**
- Moving content SKILL.md → references/
- Moving content references/ → SKILL.md (consolidation)
- Deciding what examples to keep in SKILL.md
- Evaluating whether to split large skills
- Consolidating multiple reference files

❌ **Doesn't apply to:**
- Frontmatter (always loaded)
- Quick Start sections (always stays in SKILL.md)
- Deletion decisions (separate gates apply)
- Scope/capability changes (requires operator approval)
