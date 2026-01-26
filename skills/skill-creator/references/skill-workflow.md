# Unified Skill Workflow

This is the single authoritative workflow for creating, validating, and refining skills. **Load this file for any skill work.**

## Table of Contents

- [Part 1: Content Distribution (The 80% Rule)](#part-1-content-distribution-the-80-rule)
- [Part 2: Preservation Gates (Before ANY Change)](#part-2-preservation-gates-before-any-change)
- [Part 3: Validation Workflow (After Changes)](#part-3-validation-workflow-after-changes)
- [Part 4: Quick Reference Checklists](#part-4-quick-reference-checklists)

---

## Part 1: Content Distribution (The 80% Rule)

### The Core Question

Before moving, removing, or reorganizing ANY content, ask:

**"Will Claude execute this in 80%+ of skill activations?"**

| Answer | Classification | Action |
|--------|----------------|--------|
| YES | Core procedural | **STAYS in SKILL.md** |
| NO | Supplementary | Can move to references/ |
| UNCERTAIN | Unknown impact | Defer to operator; keep in SKILL.md |

### What STAYS in SKILL.md (Core Procedural)

Content Claude needs for the common case (80%+ of activations):

- Step-by-step workflows for standard execution
- Pattern examples Claude directly applies
- Decision trees for common branching logic
- Concrete input/output samples
- Essential command syntax or copyable code blocks
- Activation clarification (how/when to invoke)
- Quick Start sections

**Examples:**
- Release-process skill: All 4 pattern examples (patch, feature, breaking, scope-creep) → STAYS (used in 80%+ of releases)
- PDF processor skill: Basic extraction workflow → STAYS
- Test runner skill: Standard test execution (Jest, PHPUnit) → STAYS

### What MOVES to references/ (Supplementary)

Content for edge cases, advanced users, or background context (<20% of activations):

- Edge cases beyond standard workflow
- Alternative approaches for power users
- Deep context on adjacent topics
- Expanded explanations of already-covered concepts
- Troubleshooting uncommon failure modes
- Historical or architectural context
- Advanced configuration options

**Examples:**
- Release-process skill: Monorepo multi-component coordination → MOVES (beyond single-component pattern)
- PDF processor skill: OCR configuration for specific document types → MOVES
- Test runner skill: Complex parallel configuration → MOVES

### Content Distribution Decision Tree

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

### Common Mistakes to Avoid

❌ **Don't move content just because it's long**
- If that content is core procedural, Claude needs it immediately

❌ **Don't assume "examples = reference material"**
- Examples are how Claude understands the task; if they're patterns for common cases, they're core

❌ **Don't optimize token count at the cost of execution quality**
- SKILL.md body loads anyway on trigger; moving core content doesn't save tokens, just adds a file load

✅ **Do ask "Will Claude execute this in 80%+ of cases?"**
- If yes: Keep in SKILL.md
- If no: Move to references/

### Size Constraints

- SKILL.md body must stay <500 lines (non-negotiable)
- If core procedural content exceeds 500 lines, that's the skill's true size
- In rare cases, split into two skills (e.g., "basic-skill" and "advanced-skill")
- References are one-level-deep only: `references/file.md`, never `references/subdir/file.md`

---

## Part 2: Preservation Gates (Before ANY Change)

**Refinement is refactoring, not reduction.** Content must migrate while preserving skill functionality. Existing guidelines, patterns, and workflows cannot be deleted—they must be intentionally relocated or operator-approved for removal.

### The Functional Capacity Invariant

```
∀ refinement: skill_execution_quality(before) ≥ skill_execution_quality(after)
```

All existing behaviors Claude performs must remain equally accessible. If content is essential to execution, it cannot disappear—only relocate.

### Gate 1: Content Audit

Before making ANY changes:

- [ ] List ALL existing guidelines, patterns, workflows, examples
- [ ] Classify each as core procedural (80%+ case) OR supplementary (edge case)
- [ ] Flag any planned deletions immediately

**Output:** Complete inventory with classification for each item.

### Gate 2: Capability Assessment

For each item you plan to move or remove:

- [ ] Will removing/moving this content impair Claude's execution in common cases?
- [ ] If YES: Content cannot be deleted (must stay or migrate with full accessibility)
- [ ] If UNCERTAIN: Defer to operator; default is keep in place

**Output:** Clear decision for each item (keep/move/needs-approval).

### Gate 3: Migration Verification (NO GAPS ALLOWED)

**⚠️ CRITICAL: Do NOT move content without explicit verification. Incomplete migrations cripple skill execution.**

Before moving ANY content:

**Step 1: Identify content to move**
- [ ] Copy exact text you're removing from source file (full section, examples, diagrams)

**Step 2: Locate destination**
- [ ] Reference file exists AND is readable
- [ ] Reference file path matches what SKILL.md will link to
- [ ] **Read the destination file completely** (use Read tool, not search)

**Step 3: Content Comparison (MANDATORY)**
- [ ] Copy exact text being removed
- [ ] Search destination file for matching content
- [ ] IF NOT FOUND in destination:
  - Add missing content to destination file NOW (before removing from source), OR
  - Keep content in source file (don't move)
- [ ] IF FOUND: Verify it's complete and identical in meaning/context

**Step 4: Verify accessibility**
- [ ] SKILL.md links to destination file with full path (e.g., `references/filename.md`)
- [ ] Link appears before or near where content was removed
- [ ] No broken references after move

**Step 5: Re-read both files after move**
- [ ] Source file still makes sense without moved content
- [ ] Destination file still makes sense with moved content added
- [ ] No orphaned references or dangling links

**If ANY step fails:** Do NOT proceed. Ask operator for guidance.

### Gate 4: Operator Confirmation

For ANY content deletion (not migration):

- [ ] Get explicit operator approval
- [ ] Operator must confirm: "Yes, remove this" with reasoning
- [ ] Document deletion reason in commit message

### Approval Triggers

**Auto-approved (no operator decision needed):**
- Moving supplementary content SKILL.md → references/ (80% rule applied correctly)
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

### Migration vs. Deletion Reference

| Action | Allowed | Requirement |
|--------|---------|-------------|
| Move core procedural SKILL.md → references/ | ❌ NO | Violates 80% rule |
| Move supplementary SKILL.md → references/ | ✅ YES | Apply 80% rule |
| Move content references/ → SKILL.md | ✅ YES | Consolidate for clarity |
| **DELETE content entirely** | ❌ NO | **Requires explicit operator approval** |

### Case Study: Correct Refinement ✅

**Skill:** skill-creator (version 1.2.0 → 1.2.1)

**Plan:** Add "Refinement Preservation Rules" section with 4 gates

**Assessment:**
- Gate 1: Audit shows gates are core procedural (refinement uses them 80%+ of time)
- Gate 2: Adding gates improves execution; no capability loss
- Gate 3: New reference file created; SKILL.md links to it
- Gate 4: Not a deletion; auto-approved

**Result:** ✅ Function preserved, clarity improved

### Case Study: Incorrect Refinement ❌

**Skill:** release-process (hypothetical)

**Plan:** "Move all 4 pattern examples to references/ to reduce line count"

**Assessment:**
- Gate 1: 4 patterns classified as core procedural (used in 80%+ of releases)
- Gate 2: Moving patterns → Claude must load external file for 80% case → **IMPAIRS EXECUTION**
- Gate 3: Reference file would be created, but external loading defeats token optimization
- Gate 4: Would require operator approval; recommendation: REJECT

**Result:** ❌ Function degraded

**Correct approach:** If line count is issue, split into "basic-releases" and "advanced-releases" skills instead of moving core patterns.

---

## Part 3: Validation Workflow (After Changes)

Use this systematic workflow to validate skills. Follow phases in order.

### Phase 1: File Inventory

**Goal:** Understand skill structure before diving into content.

1. **List all files in the skill directory**
   ```bash
   find skill-name -type f -name "*.md" -o -name "*.py" -o -name "*.sh"
   ```

2. **Verify expected structure**
   - [ ] `SKILL.md` exists (required)
   - [ ] `references/` directory (if used, should be present)
   - [ ] `scripts/` directory (if skill includes executable code)
   - [ ] `assets/` directory (if skill produces output files)

3. **Note: No extraneous files**
   - [ ] No `README.md`, `CHANGELOG.md`, `INSTALLATION.md`, etc.
   - [ ] No `.gitignore`, `.env`, config files at skill root
   - [ ] Clean structure only

**Common Mistake:** Skipping reference files, assuming one file is enough. ✅ Correct: List ALL files first, then systematically read each one.

### Phase 2: Read All Files

**Goal:** Load complete skill context before validation begins.

1. **Read SKILL.md** (frontmatter + body)
2. **Read ALL reference files** (don't skip any)
3. **Read scripts (if present)**
4. **Document findings:**
   - Total line count for SKILL.md body
   - Number and purpose of reference files
   - Whether scripts are included

### Phase 3: Frontmatter Validation

**Required Fields:**
- [ ] `name`: Present, non-empty
- [ ] `description`: Present, non-empty
- [ ] YAML syntax valid (triple dashes)

**Name Quality:**
- [ ] Lowercase only
- [ ] Hyphens only (no underscores, spaces, dots)
- [ ] ≤64 characters
- [ ] No reserved words ("anthropic", "claude")
- [ ] Action-oriented (gerund form preferred)

**Description Quality:**
- [ ] ≤1024 characters
- [ ] Third person voice ("Processes files", not "I can help")
- [ ] Includes specific trigger phrases
- [ ] Formula: `[Action]. Use when [trigger contexts]. [Optional scope].`

**Optional Fields (for team/production):**
- [ ] `version: 1.0.0`
- [ ] `allowed-tools` declared

### Phase 4: Body Structure & Content

**Structure Check:**
- [ ] <500 lines total (SKILL.md body only)
- [ ] Progressive disclosure pattern:
  - Quick Start / Quick Reference first
  - Core workflows second
  - Advanced topics third
  - References last

**Code Examples:**
- [ ] Examples are concrete (real names, not placeholders)
- [ ] Examples are runnable (can copy/paste)
- [ ] Code appears before explanations

**Token Efficiency:**
- [ ] Quick Start section: <100 tokens
- [ ] Quick Start alone solves 80% of use cases
- [ ] Detailed content deferred to references/

**Verify Links:**
- [ ] All mentioned reference files exist
- [ ] Links are correct paths
- [ ] Context provided before sending to reference

### Phase 5: Reference File Quality

For each reference file:

**File Basics:**
- [ ] File exists and is readable
- [ ] File is not empty
- [ ] File has clear, semantic name

**Organization:**
- [ ] Includes Table of Contents (if >100 lines)
- [ ] Sections are clear and scannable
- [ ] Uses code blocks, tables, bullet points appropriately

**One-Level-Deep Rule (critical):**
- [ ] File is in `references/` (not `references/subdir/`)
- [ ] No nested subdirectories
- [ ] No chains: SKILL.md → guide.md → details.md → patterns.md

**No Duplicate Content:**
- [ ] Key content not repeated between SKILL.md and references/
- [ ] Reference files don't point to each other for procedural content

### Phase 6: Tool Scoping

**Checklist:**
- [ ] `allowed-tools` field present (for team/production skills)
- [ ] Only necessary tools listed
- [ ] No overly broad permissions (`Bash(*)` avoided)
- [ ] Bash commands scoped: `Bash(git:*)` not `Bash(*)`
- [ ] Matches actual tools used in SKILL.md body

**Validation Process:**
1. List all tools mentioned in SKILL.md
2. Compare to `allowed-tools` declaration
3. Security check: no `Bash(*)`, each tool is specific

### Phase 7: Testing & Triggering

**Description Triggering:**

Test expected queries (should trigger):
- [ ] List 3-5 expected trigger phrases
- [ ] Verify each activates the skill

Test unrelated queries (should NOT trigger):
- [ ] List 3-5 unrelated queries
- [ ] Verify none activate the skill

**Real-World Testing:**
- [ ] Tested with minimal context (fresh conversation)
- [ ] Works with actual user workflows
- [ ] Examples can be followed step-by-step

---

## Part 4: Quick Reference Checklists

### For Creating a New Skill

1. [ ] Create directory: `skill-name/`
2. [ ] Write SKILL.md with frontmatter (name, description)
3. [ ] Write body following progressive disclosure
4. [ ] Add references/ if needed (one-level-deep)
5. [ ] Validate using Phase 3-7 above
6. [ ] Test activation with real queries

### For Validating an Existing Skill

1. [ ] Phase 1: List all files
2. [ ] Phase 2: Read all files completely
3. [ ] Phase 3: Validate frontmatter
4. [ ] Phase 4: Check body structure
5. [ ] Phase 5: Check reference quality
6. [ ] Phase 6: Verify tool scoping
7. [ ] Phase 7: Test triggering

### For Refining an Existing Skill

1. [ ] **FIRST:** Run Preservation Gates (Part 2)
   - Gate 1: Content Audit
   - Gate 2: Capability Assessment
   - Gate 3: Migration Verification
   - Gate 4: Operator Confirmation (if deleting)
2. [ ] Make changes following 80% rule
3. [ ] **THEN:** Run Validation Workflow (Part 3)
4. [ ] Re-test activation
5. [ ] Document reasoning for each content decision

### Must-Have (Required)

- [ ] SKILL.md <500 lines
- [ ] Frontmatter: name, description, valid YAML
- [ ] Progressive disclosure structure
- [ ] All reference files exist and readable
- [ ] One-level-deep reference structure
- [ ] Description triggers on expected queries

### Should-Have (Best Practices)

- [ ] `version` field (for team skills)
- [ ] `allowed-tools` field (for team skills)
- [ ] Code examples are concrete and runnable
- [ ] Reference files include TOC (if >100 lines)
- [ ] Quick Start solves 80% of use cases

### Red Flags (Blockers)

- [ ] SKILL.md >500 lines
- [ ] Nested reference chains
- [ ] Missing frontmatter fields
- [ ] Overly broad tool scoping (`Bash(*)`)
- [ ] Broken links to reference files
- [ ] Core procedural content moved to references/

---

## Summary: The Unified Flow

```
Creating a Skill:
  Content Distribution (80% rule) → Write SKILL.md → Add references/ → Validate

Validating a Skill:
  File Inventory → Read All → Frontmatter → Body → References → Tools → Testing

Refining a Skill:
  Preservation Gates (1-4) → Make Changes → Validation Workflow → Re-test
```

**Key principle:** Refinement is refactoring, not reduction. Never delete content without operator approval. Never move core procedural content (80%+ case) to references.
