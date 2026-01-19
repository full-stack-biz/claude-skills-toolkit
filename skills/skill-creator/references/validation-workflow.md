# Skill Validation Workflow

This workflow ensures complete, systematic validation of skills. Use this to avoid gaps (like skipping reference files or missing structure issues).

## Table of Contents
- [Phase 1: File Inventory](#phase-1-file-inventory)
- [Phase 2: Read All Files](#phase-2-read-all-files)
- [Phase 3: Frontmatter Validation](#phase-3-frontmatter-validation)
- [Phase 4: Body Structure & Content](#phase-4-body-structure--content)
- [Phase 5: Reference File Quality](#phase-5-reference-file-quality)
- [Phase 6: Tool Scoping](#phase-6-tool-scoping)
- [Phase 7: Testing & Triggering](#phase-7-testing--triggering)
- [Quick Checklist](#quick-checklist)

---

## Phase 1: File Inventory

**Goal:** Understand the skill structure before diving into content.

### Steps

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

### Common Mistake
❌ **Skipping reference files**: Assuming `checklist.md` is all you need to review without reading `templates.md`, `allowed-tools.md`, or other references.

✅ **Correct approach**: List ALL files first, then systematically read each one.

---

## Phase 2: Read All Files

**Goal:** Load complete skill context before validation begins.

### Execution Order

1. **Read SKILL.md** (frontmatter + body)
   - First 10 lines (frontmatter)
   - Full body content

2. **Read ALL reference files** (in any order)
   - `references/checklist.md`
   - `references/templates.md`
   - `references/allowed-tools.md`
   - Any other `references/*.md` files

3. **Read scripts (if present)**
   - `scripts/*.py`, `scripts/*.sh`
   - Note language, error handling approach

4. **Document findings**
   - Total line count for SKILL.md body
   - Number and purpose of reference files
   - Whether scripts are included

### Why This Matters
If you skip reading a reference file, you'll miss:
- Scope/boundary issues (checklist might reference something not in SKILL.md)
- Organizational problems (templates might reveal duplicated content)
- Security gaps (allowed-tools might list permissions not needed)

---

## Phase 3: Frontmatter Validation

**Goal:** Ensure metadata is correct and complete.

### Checklist

**Required Fields**
- [ ] `name`: Present, non-empty
- [ ] `description`: Present, non-empty
- [ ] YAML syntax valid (triple dashes)

**Name Quality**
- [ ] Lowercase only
- [ ] Hyphens only (no underscores, spaces, dots)
- [ ] ≤64 characters
- [ ] No reserved words ("anthropic", "claude")
- [ ] Action-oriented (gerund form preferred: `processing-pdfs`, `managing-databases`)

**Description Quality**
- [ ] ≤1024 characters
- [ ] Third person voice ("Processes files", not "I can help")
- [ ] Includes specific trigger phrases (action + context)
- [ ] No XML/HTML tags
- [ ] Formula: `[Action]. Use when [trigger contexts]. [Optional scope/constraints].`

**Optional Fields (for team/production skills)**
- [ ] `version: 1.0.0` if this is a team skill
- [ ] `allowed-tools` declared if this is a team skill

### Example Validation
```
name: skill-creator ✓
- lowercase, hyphenated, 13 chars, action-oriented

description: "Create and refine Claude Code skills following best practices..." ✓
- 230 chars, third person, specific triggers (building, validating, improving)
```

---

## Phase 4: Body Structure & Content

**Goal:** Ensure SKILL.md follows progressive disclosure and is efficient.

### Structure Check

- [ ] <500 lines total (SKILL.md body only, not including frontmatter)
- [ ] Follows progressive disclosure pattern:
  - Quick Start / Quick Reference first
  - Core workflows / implementation details second
  - Advanced topics / troubleshooting third
  - References to external files last

### Code Examples

- [ ] Examples are concrete (real names, not placeholders)
- [ ] Examples are runnable (can copy/paste and execute)
- [ ] Code appears **before** explanations
- [ ] Magic numbers are explained

### Token Efficiency

- [ ] Quick Start section: <100 tokens
- [ ] Quick Start alone solves 80% of use cases
- [ ] Detailed content deferred to `references/`
- [ ] No lengthy theory before examples
- [ ] No extraneous explanations

### Verify Links to References

- [ ] All mentioned reference files exist
- [ ] Links are correct (e.g., `references/checklist.md`)
- [ ] Context provided before sending reader to reference

---

## Phase 5: Reference File Quality

**Goal:** Validate that reference files are well-organized and don't create nesting chains.

### For Each Reference File

1. **File exists and is readable**
   - [ ] File path matches what SKILL.md references
   - [ ] File is not empty
   - [ ] File has clear, semantic name

2. **Organization**
   - [ ] File includes Table of Contents (if >100 lines)
   - [ ] Sections are clear and scannable
   - [ ] Uses code blocks, tables, bullet points appropriately

3. **One-Level-Deep Rule** (critical)
   - [ ] This file is in `references/`
   - [ ] No nested subdirectories like `references/advanced/details/`
   - [ ] No chains: SKILL.md → guide.md → details.md → patterns.md

4. **No Duplicate Content**
   - [ ] Key content not repeated between SKILL.md and references/
   - [ ] Reference files don't point to each other (one-way links only)

### Line Count by Purpose

- **Checklist/reference:** 50-200 lines OK
- **Guide/tutorial:** 100-300 lines OK
- **Comprehensive reference:** 300+ lines with TOC required

### Example: skill-creator

```
✓ checklist.md (314 lines) — has TOC, one level deep
✓ templates.md (367 lines) — has TOC, one level deep
✓ allowed-tools.md (124 lines) — clearly organized, one level deep
```

---

## Phase 6: Tool Scoping

**Goal:** Ensure `allowed-tools` is declared correctly and follows principle of least privilege.

### Checklist

- [ ] `allowed-tools` field is present (for team/production skills)
- [ ] Only necessary tools are listed
- [ ] No overly broad permissions (`Bash(*)` avoided)
- [ ] Bash commands are scoped: `Bash(git:*)` not `Bash(*)`
- [ ] Matches actual tools used in SKILL.md body

### Validation Process

1. **List all tools mentioned in SKILL.md**
   - Read through body and note: Read, Write, Bash, Glob, Grep, Task, etc.

2. **Compare to `allowed-tools` declaration**
   - Does it include everything used?
   - Does it include unnecessary tools?

3. **Security check**
   - No `Bash(*)` (too broad)
   - Each bash tool is specific: `Bash(python:*)`, `Bash(git:*)`
   - File operations scoped appropriately

### Example: skill-creator

```yaml
allowed-tools: Read,Write,Edit,Glob,Grep,AskUserQuestion
```

**Verification:**
- Read SKILL.md uses Read tool? ✓ (mentions "Read the current SKILL.md")
- Uses Write? ✓ (creating/modifying files)
- Uses Edit? ✓ (refining existing skills)
- Uses Glob/Grep? ✓ (searching codebases)
- Uses AskUserQuestion? ✓ (requirements interview)
- Any Bash? ✗ (not used, not declared) ✓

---

## Phase 7: Testing & Triggering

**Goal:** Verify the skill activates on intended queries and not on unrelated ones.

### Description Triggering

**Test expected queries:**
- [ ] "Create a new skill" → Should trigger
- [ ] "Validate my existing skill" → Should trigger
- [ ] "Improve skill quality" → Should trigger
- [ ] For your skill: list 3-5 expected trigger phrases and verify each

**Test unrelated queries:**
- [ ] "Help me debug my code" → Should NOT trigger
- [ ] "What's the weather?" → Should NOT trigger
- [ ] "Fix this bug" → Should NOT trigger
- [ ] For your skill: list 3-5 unrelated queries that should not match

### Real-World Testing

- [ ] Tested with minimal context (fresh conversation)
- [ ] Works with actual user workflows
- [ ] Examples in SKILL.md can be followed step-by-step
- [ ] Error messages (if any) are clear

---

## Quick Checklist

Use this as a fast reference during validation:

### Must-Have (Required)
- [ ] File inventory complete (all files listed and reviewed)
- [ ] SKILL.md <500 lines
- [ ] Frontmatter: name, description, YAML syntax correct
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
- [ ] Token efficiency optimized

### Red Flags (Blockers)
- [ ] SKILL.md >500 lines
- [ ] Nested reference chains (references/guide/advanced/details.md)
- [ ] Missing frontmatter fields
- [ ] Overly broad tool scoping (`Bash(*)`)
- [ ] Broken links to reference files
- [ ] Empty reference files

---

## Validation Process Summary

**When validating a skill, follow this order:**

1. **List all files**
   - `find skill-name -type f`
   - Verify expected structure

2. **Read SKILL.md**
   - Frontmatter + body only

3. **Read ALL reference files**
   - Don't skip any, even if they seem less important
   - Note: This is where the initial validation gap occurred

4. **Run through checklist**
   - Frontmatter validation
   - Body structure check
   - Reference quality check

5. **Verify tool scoping**
   - Compare `allowed-tools` to actual usage

6. **Test description triggering**
   - Expected phrases: should trigger
   - Unrelated phrases: should not trigger

---

## Why Systematic Validation Matters

When validating ad-hoc, it's easy to:
- Skip reading reference files (you just did this)
- Miss structure issues in one reference while checking another
- Overlook tool scoping inconsistencies
- Assume the description works without testing

Systematic validation with this workflow prevents gaps and catches issues before deployment.
