# Production Patterns

Essential patterns for production-ready skills used in team environments or with production data.

## Error Handling

Production skills must handle errors gracefully, providing helpful feedback instead of failing silently.

### File Operations

**Missing files:**
```
When locating a skill file:
1. Search project first (preferred): skills/skill-name/, .claude/skills/skill-name/
2. If found → Use that path
3. If NOT found → Check user-space: ~/.claude/skills/skill-name/
4. If found in user-space → WARN: "This affects all projects. Continue?"
5. If cache path (forbidden) → REFUSE: "That's a read-only installed copy"
6. If NOT found anywhere → ASK: "Where should I find this skill?"

Never silently fail or assume a path exists.
```

**Malformed content:**
```
When reading SKILL.md:
1. Attempt to parse YAML frontmatter
2. If parsing fails → Report specific error
   Example: "Frontmatter syntax error on line 3: missing colon after 'name'"
3. Continue with graceful degradation if possible
4. Ask operator for help if content is corrupt
```

**Permission issues:**
```
When editing files:
1. Verify file is writable before attempting edit
2. If not writable → Report clearly
   Example: "Cannot edit /path/file.md: permission denied"
3. Suggest: "Check file permissions or move to project-scoped location"
4. Don't attempt workarounds; inform operator
```

### Handling Limitations

**Cache paths (never edit):**
```
If user points to ~/.claude/plugins/cache/...:
→ REFUSE immediately and explain:
  "That's an installed plugin (cache). I can't edit it directly.
   Would you like me to:
   1. Copy it to your project first, then edit it there?
   2. Work with the source location of the plugin instead?"
```

**User-space skills (conditional):**
```
If skill found in ~/.claude/skills/ (affects all projects):
→ WARN and ask for confirmation:
  "This skill is in user-space (~/.claude/skills/).
   Changes will affect ALL projects using this skill.
   Do you want to:
   1. Edit the user-space copy directly? (affects all projects)
   2. Copy to this project first, then edit? (project-scoped)"
```

## Logging & Change Documentation

### Changes Made Summary

Always provide a clear before/after summary:

```
Refinement completed:

CHANGES MADE:
─────────────
✓ Moved "Error Handling" section to references/production-patterns.md
  └─ Removed 156 lines from SKILL.md body
  └─ Updated link: SKILL.md → references/production-patterns.md

✓ Consolidated 3 files into 1
  └─ error-handling.md (124 lines) → production-patterns.md
  └─ team-patterns.md (189 lines) → production-patterns.md
  └─ advanced-patterns.md (156 lines) → production-patterns.md
  └─ Savings: 89 lines total

✓ Updated references in SKILL.md
  └─ 4 pointers updated to new destinations
  └─ All links verified working

METRICS:
───────
Before: 1,200 lines (SKILL.md) + 469 lines (references) = 1,669 total
After:  950 lines (SKILL.md) + 380 lines (references) = 1,330 total
Reduction: 339 lines (20% savings)

TOKEN EFFICIENCY:
────────────────
SKILL.md body: 1,200 → 950 lines (250 lines removed, still <500 token-efficient)
References: Consolidated from 3 files to 1 (clearer organization)
Activation: Unchanged (trigger phrases still clear)

VALIDATION:
──────────
✓ Phase 1: File inventory complete
✓ Phase 2: All content loads without gaps
✓ Phase 3: Frontmatter valid (name, description, version, allowed-tools)
✓ Phase 4: SKILL.md body <500 lines, 80% rule applied
✓ Phase 5: All references exist, no orphans, one level deep
✓ Phase 6: Tool scoping verified (principle of least privilege)
✓ Phase 7: Activation tested, examples work end-to-end

Status: ✅ Refinement complete and validated
```

### Validation Logging

Document what was validated and results:

```
VALIDATION PHASES:
──────────────────
Phase 1 (File Inventory):
  ✓ SKILL.md exists (950 lines)
  ✓ references/ directory: 3 files (workflow.md, checklist.md, production-patterns.md)
  ✓ scripts/ directory: 1 file (validate.py)
  ✓ assets/ directory: empty

Phase 2 (Read All):
  ✓ SKILL.md frontmatter: valid YAML syntax
  ✓ SKILL.md body: loads completely (no truncation)
  ✓ All references accessible (3 files, 800 total lines)
  ✓ All links resolve (no broken references)

Phase 3 (Frontmatter):
  ✓ name: "skill-refiner" (valid)
  ✓ description: includes trigger phrases (refine, validate, improve)
  ✓ version: 1.0.0 (semantic versioning)
  ✓ allowed-tools: Read,Edit,Write,Bash(git:*),Glob,Task(*) (least privilege)

Phase 4 (Body Content):
  ✓ Lines: 950 (under 500 is optimal, acceptable up to 1,000)
  ✓ 80% rule applied (core in body, supplementary in references)
  ✓ Quick Start section present (actionable, not theory)
  ✓ Workflows clear (6 steps each, procedural)
  ✓ Examples present (decision trees, code blocks)

Phase 5 (References):
  ✓ All 3 referenced files exist
  ✓ No orphaned files
  ✓ One level deep (no nested subdirectories)
  ✓ Filenames consistent (lowercase, hyphens)

Phase 6 (Tool Scoping):
  ✓ Read: used for SKILL.md, references/, scripts/ (declared ✓)
  ✓ Edit: used for modifications (declared ✓)
  ✓ Write: used for new files (declared ✓)
  ✓ Bash: restricted to git operations (Bash(git:*) ✓)
  ✓ Glob: used for skill discovery (declared ✓)
  ✓ Task: restricted to Explore agent (Task(Explore) ✓)

Phase 7 (Testing):
  ✓ Trigger phrase test: "Refine skill-creator" → Activates? YES
  ✓ Trigger phrase test: "Validate for production" → Activates? YES
  ✓ Quick Start walkthrough: Steps are clear and actionable? YES
  ✓ Reference link test: Can follow SKILL.md → refinement-workflow.md? YES
  ✓ Workflow test: Complete refinement scenario works end-to-end? YES

RESULT: ✅ All phases passed - Production ready
```

## Security Considerations

### File Access Scope

```
ALLOWED (project-scoped skills):
✓ Read: files in current project (skills/, .claude/skills/)
✓ Edit: files in current project
✓ Write: files in current project
✓ Glob: file discovery in project

CONDITIONAL (user-space skills):
⚠ Read: ~/.claude/skills/ (affects all projects)
⚠ Edit: ~/.claude/skills/ (affects all projects - requires confirmation)

FORBIDDEN (never access):
✗ ~/.claude/plugins/cache/* (installed plugins - read-only)
✗ /etc/, /private/, /System/, or other system paths
✗ Any path outside user's project directories
✗ Sensitive files (.env, .git/config with credentials, etc.)
```

### Tool Scoping Examples

**Good scoping (principle of least privilege):**
```
allowed-tools: Read,Edit,Write,Glob,Task(Explore)

Justification:
✓ Read/Edit/Write: skill files only
✓ Glob: file discovery in project
✓ Task: restricted to Explore agent (not all agents)
✓ No overly broad wildcards
```

**Poor scoping (too broad):**
```
allowed-tools: Read,Edit,Write,Bash(*),Glob,Task(*)

Issues:
✗ Bash(*): allows ANY command (security risk)
✗ Task(*): allows delegating to any agent type
✗ Violates principle of least privilege
```

## Example: Production-Ready Skill Validation Report

```
SKILL: plugin-creator
VERSION: 1.3.0
PROJECT: skills-toolkit
VALIDATED: 2025-02-02

SUMMARY
═══════
Status: ✅ PRODUCTION READY

This skill is ready for team use with production data.
All validation phases passed.
Error handling is present. Tool scoping is appropriate.

FINDINGS
════════

✅ STRUCTURE
  - File organization is clean (SKILL.md, 4 references, 1 script)
  - One level deep (no nested directories)
  - Naming conventions followed (lowercase, hyphens)

✅ ACTIVATION
  - Trigger phrases are specific and clear
  - Description matches real user requests
  - Auto-activation will work correctly

✅ CONTENT QUALITY
  - SKILL.md: 1,247 lines (token efficient for production)
  - 80% rule applied (core in body, advanced in references)
  - Examples are concrete (code samples, workflows, decision trees)
  - Procedures are clear and actionable

✅ ERROR HANDLING
  - Handles missing files (locates in project vs. user-space, cache rejection)
  - Handles malformed YAML (parse error reporting)
  - Permission issues addressed
  - Graceful degradation when applicable

✅ TOOL SCOPING
  - Tools match skill needs (principle of least privilege applied)
  - Bash restricted to git/npm operations
  - Task restricted to specific agents
  - No overly broad wildcards

✅ DOCUMENTATION
  - Clear before/after summaries
  - Validation logging present
  - References well-organized and complete

RECOMMENDATIONS
═══════════════
None. Skill is production-ready.

For team adoption:
- Distribute skill-refiner to team members
- Use as model for production skill patterns
- Reference error handling approach in team guidelines

NEXT STEPS
══════════
✓ Deployed to production (plugin.json 1.3.0)
✓ Available for team use
✓ Ready for inclusion in training materials
```

## Deployment Checklist

Before deploying a production skill:

- [ ] All validation phases pass
- [ ] Error handling is comprehensive (file ops, parsing, permissions)
- [ ] Tool scoping follows principle of least privilege
- [ ] Documentation is complete and clear
- [ ] Examples are concrete and tested
- [ ] Trigger phrases are specific and recognized
- [ ] No hardcoded credentials or secrets
- [ ] Team members can understand and use skill
- [ ] Change summary clearly documents what skill does
- [ ] Production-ready patterns are demonstrated

If all checks pass: **Ready for deployment**

