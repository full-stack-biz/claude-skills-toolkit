# Validation Checklist

Quick reference checklist for validating Claude Code skills. Use in conjunction with the seven validation phases.

## File Structure Checklist

- [ ] `SKILL.md` exists (required)
- [ ] `references/` directory exists (if references used)
- [ ] `scripts/` directory exists (if scripts used)
- [ ] `assets/` directory exists (if assets used)
- [ ] No nested subdirectories in `references/` (one level deep only)
- [ ] All referenced files exist and are accessible
- [ ] No orphaned files (all files are used or documented)

## Frontmatter Checklist

- [ ] YAML syntax valid (triple dashes `---`, correct indentation)
- [ ] `name` field present
  - [ ] Lowercase
  - [ ] Hyphen-separated (no spaces, underscores, or camelCase)
  - [ ] ≤64 characters
  - [ ] Doesn't contain "anthropic" or "claude"
- [ ] `description` field present
  - [ ] ≤1024 characters
  - [ ] Includes specific trigger phrases (e.g., "refine", "validate", "improve")
  - [ ] Clear use case context ("Use when...")
  - [ ] Mentions scope and constraints
- [ ] `version` field (optional but recommended)
  - [ ] Semantic versioning format (X.Y.Z)
  - [ ] Incremented appropriately from previous version
- [ ] `allowed-tools` field (optional but recommended for security)
  - [ ] Lists only tools actually used in skill procedures
  - [ ] Applies principle of least privilege
  - [ ] Wildcards used appropriately (`Task(Explore)`, specific agent types, etc.)

**Example of Good Frontmatter:**
```yaml
---
name: skill-refiner
description: >-
  Improve and validate Claude Code skills for clarity, efficiency,
  and production readiness. Use when refining existing skills,
  validating against best practices, or checking production readiness.
version: 1.0.0
allowed-tools: Read,Edit,Write,Glob,Task(*)
---
```

## SKILL.md Body Content Checklist

### Structure & Organization
- [ ] **Quick Start section** present and actionable (not theory)
- [ ] **Clear workflow sections** (e.g., "Core Workflow: Refinement", "Core Workflow: Validation")
- [ ] **Key Rules section** with essential constraints
- [ ] **References guide** explaining what documentation is available
- [ ] **Progressive disclosure** (essentials first, advanced later)
- [ ] **Logical flow** (can Claude follow from start to finish?)

### Content Quality
- [ ] **Line count** <500 lines (non-negotiable for token efficiency)
  - Count only body content (exclude frontmatter, not counted in 500-line limit)
- [ ] **80% rule applied** (essential content in body, supplementary in references)
  - [ ] Core procedural instructions in SKILL.md
  - [ ] Supplementary content (advanced patterns, edge cases) in references/
- [ ] **Code-first examples** (examples before abstract explanations)
- [ ] **Concrete procedures** (Claude knows exactly what to execute)
  - [ ] Not vague or generic
  - [ ] Not theoretical or explanatory without examples
- [ ] **Activation clarity** (trigger phrases are specific)
  - [ ] User requests containing trigger phrases will activate skill ✓
  - [ ] Vague descriptions that miss real requests ✗

### Tone & Clarity
- [ ] **Clear procedural instructions** (action-oriented, not explanatory)
- [ ] **Concrete examples** (specific commands, file paths, inputs/outputs)
- [ ] **Decision points** (step-by-step decision trees where needed)
- [ ] **Constraints** (clearly stated what's in/out of scope)
- [ ] **No unnecessary elaboration** (every sentence justifies its token cost)

## References/ Checklist

### File Inventory
- [ ] All files referenced in SKILL.md exist
- [ ] Filenames are lowercase and hyphen-separated
- [ ] No nested directories (one level deep only)
  - [ ] ✓ `references/filename.md`
  - [ ] ✗ `references/subdir/filename.md`
- [ ] No orphaned files (all files are linked from SKILL.md)
- [ ] File purposes are clear

### File Contents (if present)
- [ ] **Table of contents** for files >100 lines
- [ ] **Clear headings** that organize content logically
- [ ] **Related sections** are grouped together
- [ ] **Cross-references** between files are accurate
- [ ] **No duplication** across reference files
  - [ ] Or duplication is intentional and noted
- [ ] **Link targets** are specific (use `#section-heading` for direct links)

### Organization Quality
- [ ] Files are grouped by purpose (not scattered randomly)
- [ ] Similar topics are in same file or clearly linked
- [ ] Each file has a clear purpose documented
- [ ] File count is appropriate (not too many, not consolidated when it should be)

## Scripts/ Checklist (if present)

- [ ] Scripts are clearly documented in SKILL.md or references/
- [ ] Scripts are executable (`#!/usr/bin/env python`, `#!/bin/bash`, etc.)
- [ ] Scripts have clear usage instructions
- [ ] Error handling is present (non-zero exit codes for failures)
- [ ] Scripts validate inputs (don't crash on bad data)
- [ ] Claude's procedures reference scripts appropriately
  - [ ] "Run `scripts/validate.py`" (clear invocation)
  - [ ] Not "use the script somewhere" (vague reference)

## Assets/ Checklist (if present)

- [ ] Assets are referenced in SKILL.md or output documentation
- [ ] File formats are appropriate (not converting unnecessarily)
- [ ] Filenames match references in documentation
- [ ] Assets are user-facing outputs (not internal tools)
  - [ ] ✓ Templates, example outputs, images
  - [ ] ✗ Internal build artifacts

## Tool Scoping Checklist

- [ ] `allowed-tools` field accurately reflects actual tool usage
- [ ] No unused tools declared (principle of least privilege)
  - [ ] ✓ `Read,Edit,Write,Glob` (all declared tools used)
  - [ ] ✗ `Read,Edit,Write,Bash(*)` (Bash unused, should remove)
- [ ] Wildcards are specific, not overly broad
  - [ ] ✓ `Task(Explore)` (only Explore agent)
  - [ ] ✓ `Glob` (file discovery only)
  - [ ] ✗ `Task(*)` (any agent—too broad)
- [ ] Tools match security model
  - [ ] Read/Edit/Write for file operations ✓
  - [ ] Bash with scoped commands ✓
  - [ ] Task with specific agents ✓

## Activation & Recognition Checklist

- [ ] Skill description includes specific trigger phrases
  - [ ] Not vague: ✗ "Process things", ✓ "Create and refine skills"
  - [ ] Not generic: ✗ "Help with stuff", ✓ "Validate production readiness"
  - [ ] Trigger phrases Claude will recognize in real requests
- [ ] Test activation mentally:
  - [ ] User says: "Refine my skill" → Does description match? ✓
  - [ ] User says: "Validate this is production-ready" → Does description match? ✓
  - [ ] User says: "Make my skill clearer" → Does description match? ✓
- [ ] Scope constraints are clear
  - [ ] Operator knows what skill will/won't do ✓
  - [ ] Scope is realistic (not promising everything) ✓

## Production-Ready Checklist

For skills used in team environments or with production data:

### Error Handling
- [ ] Handles missing files gracefully
- [ ] Handles malformed input (YAML parsing, etc.)
- [ ] Provides helpful error messages (not cryptic)
- [ ] Doesn't fail silently (reports problems explicitly)

### Logging & Documentation
- [ ] Documents what it's doing (helpful for debugging)
- [ ] Provides change summaries (what was modified)
- [ ] Clear before/after state (helps verify correctness)

### Testing & Validation
- [ ] Validated with both Haiku and Opus models
- [ ] Tested with real-world example requests
- [ ] Works across different project structures
- [ ] Edge cases considered (missing files, unusual configurations)

### Security
- [ ] Tool scoping applied (principle of least privilege)
- [ ] No hardcoded credentials or secrets
- [ ] Safe file operations (respects user boundaries)

## Final Checklist: Ready to Deploy?

Run through this final checklist before considering skill validation complete:

- [ ] All file structure checks pass ✓
- [ ] All frontmatter checks pass ✓
- [ ] SKILL.md body quality is high ✓
- [ ] All references are present and complete ✓
- [ ] Tool scoping is appropriate ✓
- [ ] Activation will work (trigger phrases clear) ✓
- [ ] Production patterns present (if team/production skill) ✓
- [ ] Examples work end-to-end ✓
- [ ] Documentation is clear and complete ✓

**Status:** ✅ Ready to Deploy

If any check fails, identify specific issues and address them before deployment.

## Quick Reference: Common Issues & Fixes

| Issue | Symptom | Fix |
|-------|---------|-----|
| **Too long** | SKILL.md >500 lines | Move supplementary content to references/ |
| **Vague activation** | Description has no trigger phrases | Add specific phrases: "refine", "validate", "improve" |
| **Missing files** | SKILL.md links to non-existent reference | Create missing file or update link |
| **Overly broad tools** | `allowed-tools: Bash(*)` | Restrict: `Bash(git:*)`, `Bash(npm:*)`, etc. |
| **Inconsistent structure** | Sections organized randomly | Reorganize: Quick Start → Workflows → Key Rules → References |
| **Nested references** | `references/subdir/file.md` | Move to: `references/file.md` (flatten) |
| **Orphaned files** | Reference files not linked from SKILL.md | Link or delete unused files |
| **Unclear trigger phrases** | Skill doesn't activate when needed | Make description specific: "Use when refining", "when validating for production" |
| **No examples** | All abstract explanations, no concrete cases | Add code examples, walk-throughs, decision trees |
| **Error handling missing** | Skill crashes on unexpected input | Add checks: missing files, malformed YAML, permission errors |

