# Refinement Preservation Policy

## Core Principle

**Refinement is refactoring, not reduction.** Content must migrate between SKILL.md and references/ while preserving skill functionality. Existing guidelines, patterns, and workflows cannot be deleted wholesale—they must be intentionally relocated or operator-approved for removal.

---

## Problem: Function-Crippling Refinement

**What happens when content is deleted instead of migrated:**

Example (release-process skill):
- Original: 4 pattern examples (patch, feature, breaking, scope-creep) in SKILL.md
- "Refinement": Moved all 4 to references/ to reduce line count
- **Result:** Claude now loads external files for 80%+ of releases (defeats token optimization)
- **Impact:** Skill appears lean but executes poorly

**Root cause:** Conflation of two operations:
- ✅ Optimization (preserve function, improve clarity)
- ❌ Reduction (delete content regardless of impact)

---

## The Preservation Mandate

### Rule 1: Functional Capacity Invariant

```
∀ refinement: skill_execution_quality(before) ≥ skill_execution_quality(after)
```

All existing behaviors Claude performs must remain equally accessible. If content is essential to execution, it cannot disappear—only relocate.

### Rule 2: Migration vs. Deletion

| Action | Allowed | Requirement |
|--------|---------|-------------|
| Move core procedural content SKILL.md → references/ | ❌ NO | Violates 80% rule; blocks externally-needed content |
| Move supplementary content SKILL.md → references/ | ✅ YES | Apply 80% rule; content is <20% case |
| Move content references/ → SKILL.md | ✅ YES | Consolidate for clarity |
| **DELETE content entirely** | ❌ NO | **Requires explicit operator authorization** |

---

## The 80% Rule Applied to Refinement

**Question:** "Will Claude execute this in 80%+ of skill activations?"

| Answer | Decision | Action |
|--------|----------|--------|
| YES | Core procedural | Must stay accessible in SKILL.md body |
| NO | Supplementary | Can move to references/ (zero-penalty loading) |
| UNCERTAIN | Unclear impact | Defer to operator; default keep in SKILL.md |

### Examples

**Release-process skill:**
- 4 pattern examples (patch, feature, breaking, scope-creep): YES, 80%+ → STAYS in SKILL.md
- Monorepo multi-component coordination: NO, <20% → Moves to references/

**PDF processor skill:**
- Basic extraction workflow: YES, 80%+ → STAYS in SKILL.md
- OCR configuration for specific document types: NO, <20% → Moves to references/

**Test runner skill:**
- Standard execution (Jest, PHPUnit): YES, 80%+ → STAYS in SKILL.md
- Complex parallel configuration: NO, <10% → Moves to references/

---

## Content Classification Framework

### Core Procedural (STAYS in SKILL.md)

✅ Step-by-step workflows for 80%+ cases
✅ Pattern examples Claude directly applies
✅ Decision trees for common branching logic
✅ Concrete input/output samples
✅ Essential command syntax or copyable code blocks
✅ Activation clarification (how/when to invoke)

### Supplementary (MOVES to references/)

📚 Edge cases beyond standard workflow
📚 Alternative approaches for power users
📚 Deep context on adjacent topics
📚 Expanded explanations of already-covered concepts
📚 Troubleshooting uncommon failure modes
📚 Historical or architectural context
📚 Advanced configuration options

---

## Pre-Refinement Validation Gates

### Gate 1: Content Audit
- [ ] List ALL existing guidelines, patterns, workflows, examples
- [ ] Classify each as core procedural (80%+ case) OR supplementary (edge case)
- [ ] Flag any planned deletions immediately

### Gate 2: Capability Assessment
- [ ] Will removed content impair Claude's execution in common cases?
- [ ] If YES: Content cannot be deleted (must stay or migrate)
- [ ] If UNCERTAIN: Defer to operator

### Gate 3: Migration Verification (NO GAPS ALLOWED)

**⚠️ CRITICAL: Do NOT move content without explicit verification. Incomplete migrations cripple skill execution.**

**Before moving ANY content:**

1. **Identify content to move** - Exact text you're removing from source file (copy/paste the section)

2. **Locate destination** - If moving SKILL.md → references/:
   - [ ] Reference file exists AND is readable
   - [ ] Reference file path matches what SKILL.md will link to
   - **Read the destination file completely** (use Read tool, not search)

3. **Content Comparison (MANDATORY):**
   - [ ] Copy exact text being removed (section, examples, diagrams, all)
   - [ ] Search destination file for matching content (keyword search, pattern match)
   - [ ] IF NOT FOUND: You have a gap. Either:
     - Add missing content to destination file NOW (before removing from source), OR
     - Keep content in source file (don't move)
   - [ ] IF FOUND: Verify it's complete and identical in meaning/context

4. **Verify accessibility:**
   - [ ] SKILL.md links to destination file with full path (e.g., `references/filename.md`)
   - [ ] Link appears before or near where content was removed (so Claude finds it)
   - [ ] No broken references after move

5. **Re-read both files after move** (final audit):
   - [ ] Source file still makes sense without moved content
   - [ ] Destination file still makes sense with moved content added
   - [ ] No orphaned references or dangling links

**If ANY step fails:** Do NOT proceed. Ask operator for guidance.

### Gate 4: Operator Confirmation
- [ ] If ANY content marked for deletion (not migration): Get explicit operator approval
- [ ] Operator must confirm: "Yes, remove this" with reasoning
- [ ] Document deletion reason in commit message

---

## Approval Triggers

**Automatic approval (No operator decision needed):**
- Moving supplementary content SKILL.md → references/ (80% rule applied)
- Consolidating references/ → SKILL.md
- Rewording for clarity (no substance change)
- Adding examples or patterns
- Improving organization

**MANDATORY operator approval:**
- Removing ANY guideline, pattern, or example (deletion, not migration)
- Reducing coverage (e.g., 4 patterns → 2 patterns)
- Changing scope or capability boundaries
- Removing error handling or validation logic
- Any Gate 2 assessment flagged as uncertain

---

## Decision Tree: Content Relocation

```
Does content stay in SKILL.md?
├─ Will Claude execute this in 80%+ of activations?
│  ├─ YES → STAYS in SKILL.md (core procedural)
│  │   └─ Keep accessible on every trigger
│  └─ NO → Can move to references/ (supplementary)
│      ├─ Is there an existing reference file?
│      │  ├─ YES → Append to it
│      │  └─ NO → Create new reference file
│      └─ Verify SKILL.md still references this file
└─ Is content being DELETED (not relocated)?
   ├─ YES → Requires operator approval via Gate 4
   │   └─ Document reason before deletion
   └─ NO → Continue with migration
```

---

## Case Studies: Correct vs. Incorrect Refinement

### Case 1: Function-Preserving Refinement ✅

**Skill:** skill-creator (version 1.2.0 → 1.2.1)

**Before:** "Refining Existing Skills" section (5 lines) → needs expansion

**Plan:**
- Add "Refinement Preservation Rules" section with 4 gates + decision tree
- Move detailed policy rationale to `refinement-preservation-policy.md`

**Assessment:**
- Gate 1: Audit shows gates are core procedural (refinement uses them 80%+ of time)
- Gate 2: Adding gates improves execution; no capability loss
- Gate 3: New reference file created; SKILL.md links to it
- Gate 4: Not a deletion; auto-approved

**Result:** ✅ Function preserved, clarity improved, no external dependencies introduced

---

### Case 2: Function-Crippling Refinement ❌

**Skill:** release-process (hypothetical)

**Before:** 54 lines of 4 pattern examples in SKILL.md

**Plan:** "Move all patterns to references/ to reduce line count from 300 to 246 lines"

**Assessment:**
- Gate 1: 4 patterns classified as core procedural (used in 80%+ of releases)
- Gate 2: Moving patterns → Claude must load external file for 80% case → **IMPAIRS EXECUTION**
- Gate 3: Reference file created, but external loading defeats token optimization
- Gate 4: Would require operator approval; recommendation: REJECT

**Result:** ❌ Function degraded (unnecessary external file loads for core cases)

**Correct approach:** If line count is issue, split into "basic-releases" and "advanced-releases" skills instead of moving core patterns.

---

## Bounded Scope Alignment

Refinement must preserve **Bounded Scope Principle** from `self-containment-principle.md`:

- ✅ All content required for skill operation remains bundled within skill directory
- ✅ Progressive disclosure: Metadata → SKILL.md body → references/ (on-demand)
- ❌ Deleting content that makes skill incomplete violates bounded scope
- ❌ References must supplement SKILL.md core, never replace it

---

## Implementation Checklist

Before applying refinements:

- [ ] Pre-refinement audit complete (all content classified)
- [ ] 80% rule applied to each potential relocation
- [ ] No content marked for deletion without Gate 4 approval
- [ ] All references/ files are one-level-deep (no nesting)
- [ ] SKILL.md still <500 lines after changes
- [ ] No circular dependencies (references don't point back to SKILL.md for procedural content)
- [ ] Bounded scope maintained (all required content self-contained)
- [ ] Validation workflow re-run after refinements (references/validation-workflow.md)

---

## Success Criteria

Refinement enforcement succeeds when:

✅ No skill loses execution capacity during refinement
✅ Core procedural content (80% cases) always accessible in SKILL.md
✅ Supplementary content (edge cases) available in references/ with zero-penalty loading
✅ All deletions explicitly operator-approved
✅ Progressive disclosure hierarchy maintained
✅ Bounded scope principle preserved
✅ Token efficiency gains don't sacrifice execution quality

---

## References

- **Content Distribution Guide:** `content-distribution-guide.md` — When deciding what stays in SKILL.md vs. references/
- **Validation Workflow:** `validation-workflow.md` — Re-validate after refinements complete
- **Bounded Scope Principle:** `self-containment-principle.md` — Ensure skill remains self-contained
