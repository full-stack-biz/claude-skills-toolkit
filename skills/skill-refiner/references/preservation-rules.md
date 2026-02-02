# Preservation Rules

Critical content that MUST be preserved during skill refinement. These rules prevent accidental deletion of essential functionality.

## Non-Negotiable Content

### SKILL.md Frontmatter

**NEVER modify or delete:**
- `name` field - Required for skill identification
- `description` field - Required for skill activation (Claude's discovery mechanism)

**NEVER weaken:**
- `allowed-tools` field - Principle of least privilege must be maintained or strengthened, never weakened

Example of correct vs. incorrect changes:

```
❌ WRONG: Removing description
Before: description: "Improve and validate skills. Use when refining or validating."
After: [deleted]
→ Problem: Skill won't activate anymore

✅ CORRECT: Improving description
Before: description: "Improve skills"
After: description: "Improve and validate skills for clarity, efficiency, and production readiness. Use when refining, validating, or checking production readiness."
→ Benefit: Clearer activation triggers, better discoverability

❌ WRONG: Weakening tool scoping
Before: allowed-tools: Read,Edit,Write,Glob,Glob
After: allowed-tools: Read,Edit,Write,Bash(*),Glob
→ Problem: Now allows ANY command (security violation)

✅ CORRECT: Maintaining least privilege
Before: allowed-tools: Read,Edit,Write,Glob,Glob
After: allowed-tools: Read,Edit,Glob,Glob
→ Benefit: Still secure, more efficient (write removed if unused)
```

### Quick Start Section

**NEVER delete:** Quick Start section must remain.

**WHY:** Quick Start is what Claude uses to execute 80% of skill activations. Without it:
- Skill loses its core value proposition
- Procedures become unclear
- Activation quality degrades

Acceptable changes to Quick Start:
- Clarify wording
- Reorganize steps for better flow
- Add concrete examples
- Remove redundancy

Unacceptable changes:
- Delete entire section
- Remove steps from workflows
- Abstract procedures into theory

### Core Workflow Steps

**NEVER delete:** Core workflows must be preserved in their entirety.

Example: If skill-refiner defines 7 validation phases, don't:
- Delete phases 4-7 "to simplify"
- Merge phases arbitrarily
- Skip phases in documentation

Acceptable changes:
- Clarify phase descriptions
- Add examples to phases
- Reorganize phases for better flow
- Split one complex phase into substeps

### Scope & Constraints

**NEVER delete:** Clear statements about scope (what's IN, what's OUT) must be preserved.

Example: If skill says "Forbidden: Never edit cache paths", don't delete that constraint:
```
❌ WRONG: Removing constraint to "simplify"
Before: "FORBIDDEN - Never edit (REFUSE IMMEDIATELY): ~/.claude/plugins/cache/*"
After: [deleted]
→ Problem: User might try to edit cache files; safety guardrail removed

✅ CORRECT: Keeping constraint
Before: "FORBIDDEN - Never edit (REFUSE IMMEDIATELY): ~/.claude/plugins/cache/*"
After: "FORBIDDEN - Never edit (REFUSE IMMEDIATELY): ~/.claude/plugins/cache/* (installed plugins - read-only)"
→ Benefit: Constraint preserved with clearer reasoning
```

### Trigger Phrases

**NEVER delete:** Specific trigger phrases that enable skill activation must be preserved.

These phrases are how Claude recognizes when to invoke the skill:
- "refine"
- "improve"
- "validate"
- "production-ready"
- "simplify"

Acceptable changes:
- Add MORE trigger phrases for better activation
- Clarify existing phrases
- Explain when each phrase should trigger

Unacceptable changes:
- Delete trigger phrases
- Make description vague (defeats activation)
- Remove context about when to use skill

## References That Must Stay

**NEVER delete references that implement core functionality:**

```
skill-refiner MUST keep:
✗ Do NOT delete: refinement-workflow.md (core workflow for refinement)
✗ Do NOT delete: validation-checklist.md (validation depends on this)
✗ Do NOT delete: preservation-rules.md (this file! protects itself)

skill-creator MUST keep:
✗ Do NOT delete: templates.md (used in CREATE workflow)
✗ Do NOT delete: skill-workflow.md (unified workflow)

General rule:
If SKILL.md says "See references/X.md", file X is REQUIRED.
Don't delete without updating SKILL.md AND verifying functionality preserved.
```

## Movement, Not Deletion

**Core principle: Move essential content, never delete it.**

If content is essential (80%++ rule), moving is safer than deletion:

```
Scenario: SKILL.md is 1,200 lines (too long)

❌ WRONG: Delete 250 lines "to simplify"
→ Risk: Lose essential content

✅ RIGHT: Move 250 supplementary lines to references
→ Create: references/advanced-patterns.md (new file)
→ Update: SKILL.md links to new location
→ Result: Content preserved, SKILL.md more efficient

Movement pattern: CREATE → LINK → DELETE (old source only)
```

## Functional Dependencies

**NEVER remove content that other content depends on:**

```
Example: Two workflows depend on "Locate the Target Skill" procedure

Core Workflow: Refinement
  ├─ Step 1: Locate the skill
  │  └─ Uses: "Locate the Target Skill" section
  └─ Step 2: Get approval

Core Workflow: Validation
  ├─ Step 1: Locate the skill
  │  └─ Uses: "Locate the Target Skill" section
  └─ Step 2: Run validation

If you delete "Locate the Target Skill" section:
✗ Both workflows break (can't find skills)
✗ User has no way to locate skill files
✗ Skill is non-functional

MUST preserve: "Locate the Target Skill" section
It's used by multiple workflows.
```

## Error Handling Requirements

**NEVER remove error handling for critical paths:**

Skill-refiner MUST handle:
- Missing skill files (search project, user-space, refuse cache)
- Malformed YAML (report parse errors)
- Cache path access (refuse immediately)
- Permission issues (report, don't workaround)

If any error handler is removed:
- Skill becomes fragile
- User gets cryptic failures instead of helpful errors
- Maintenance burden increases

## Testing Requirements

**NEVER remove testing verification after changes:**

Before deploying refinement:
- Phase 7 (Testing) MUST pass
- Real-world example requests MUST activate skill
- Workflows MUST execute end-to-end

If testing is skipped:
- Broken skills ship to users
- Silent failures become common
- Refinement goals are defeated

## Decision Tree: Is This Deletable?

```
Is content being proposed for deletion?
├─ YES, proceed:
│  ├─ Is it in the "Non-Negotiable Content" list above?
│  │  ├─ YES → REFUSE deletion (preserve it)
│  │  └─ NO → proceed to next check
│  ├─ Does other content depend on it?
│  │  ├─ YES (functional dependency) → REFUSE deletion (move instead)
│  │  └─ NO → proceed to next check
│  ├─ Is it essential to core workflow?
│  │  ├─ YES → REFUSE deletion (move instead)
│  │  └─ NO → SAFE to delete
│  └─ Get operator confirmation before deletion
└─ NO (moving or updating instead) → Proceed with movement pattern
```

## Refinement Goals vs. Preservation

**Remember the balance:**

| Goal | How to Achieve | Preserve |
|------|---|---|
| Reduce token usage | Move supplementary to references/ | Core content stays |
| Improve clarity | Rewrite confusing sections | All functionality preserved |
| Better organization | Consolidate related files | All content retained |
| Simplify SKILL.md | Move advanced topics to references/ | Essential procedures |
| Fix bugs | Update wrong instructions | Correct functionality |

**Key insight:** All goals are compatible with preservation. You don't need to delete to improve.

## Version Tracking

When content is preserved during refinement:

```
Before refinement (version 1.0.0):
- Total content: 1,669 lines
- Functionality: Complete

After refinement (version 1.1.0):
- Total content: 1,330 lines (reorganized)
- Functionality: Complete (unchanged)

Semantic versioning:
✓ PATCH (1.0.0 → 1.0.1): Bug fixes, minor clarifications
✓ MINOR (1.0.0 → 1.1.0): Reorganization, efficiency improvements, new reference files
✗ MAJOR (1.0.0 → 2.0.0): Only for breaking changes to procedures

Note: Refinement is reorganization (MINOR bump), not breaking change.
```

## Examples: Correct Preservation

### Example 1: Simplifying Without Losing Content

**Scenario:** User says "Make this clearer and more efficient"

```
BEFORE (1,200 lines):
[SKILL.md body with mixed content: procedures, examples, advanced patterns, theory]

DURING REFINEMENT:
✓ Move advanced patterns to references/advanced-patterns.md
✓ Consolidate related files
✓ Rewrite confusing sections for clarity
✗ DO NOT delete any procedures
✗ DO NOT remove examples
✗ DO NOT remove core constraints

AFTER (950 lines):
[SKILL.md body: procedures + essential examples only]
[references/: advanced patterns, extended examples, theory]

Result: ✓ Clearer (less clutter), ✓ Efficient (moved, not deleted), ✓ Functional (all features preserved)
```

### Example 2: Handling Obsolete Content

**Scenario:** Old section is outdated and needs replacement

```
BEFORE:
[Old section describing deprecated workflow]

APPROACH:
✓ Create new section with updated workflow
✓ Link SKILL.md to new section
✓ DELETE old section only after links verified
✓ If old workflow is still needed: PRESERVE it (move to references/deprecated-patterns.md)

AFTER:
[New section with current workflow]
[references/deprecated-patterns.md: old workflow for users who need legacy support]

Result: ✓ Updated, ✓ Preserved (not lost), ✓ Available for reference
```

### Example 3: Consolidating Without Loss

**Scenario:** 3 related reference files exist

```
BEFORE:
references/error-handling.md (124 lines)
references/team-patterns.md (189 lines)
references/advanced-patterns.md (156 lines)
Total: 469 lines

DURING CONSOLIDATION:
✓ Create references/production-patterns.md
✓ Merge all 3 files into new file (sections for each topic)
✓ Update SKILL.md links to point to consolidated file
✓ DELETE old files only after links verified

AFTER:
references/production-patterns.md (380 lines)
  ├─ Error Handling (from error-handling.md)
  ├─ Team Patterns (from team-patterns.md)
  └─ Advanced Patterns (from advanced-patterns.md)

Result: ✓ Consolidated (fewer files), ✓ Preserved (all content), ✓ Linked (SKILL.md updated)
```

## Summary

**Refinement Principle:** Improve without reducing. Move without losing. Preserve what works.

**When in doubt:** Move to references instead of deleting. Moving preserves functionality while still improving efficiency.

**Operator approval:** Always ask before deleting. Migrations and improvements don't need approval (content preserved anyway).

