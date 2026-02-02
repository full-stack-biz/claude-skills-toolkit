# Movement Pattern: Safe Content Migration

The **Movement Pattern** is the critical procedure for relocating content during refinement. It prevents broken links, lost content, and incomplete migrations.

## Why This Matters

Content often needs to move during refinement:
- SKILL.md → references/ (consolidation for clarity)
- references/ → SKILL.md (bringing context back)
- Between references/ files (reorganizing by topic)
- Within SKILL.md (reordering sections)

❌ **Wrong sequence causes failure:**
```
1. Remove content from source
2. Intend to add to destination
3. Never actually add it
→ Content is lost forever
```

✅ **Correct sequence preserves functionality:**
```
1. Add content to destination first
2. Verify destination has complete content
3. Remove from source last
→ Content is relocated, not lost
```

## The Movement Pattern (Strict Sequence)

**⚠️ CRITICAL: Never violate this order**

### Phase 1: CREATE/UPDATE Destination

**Step 1: Identify the destination**
- [ ] Reference file exists AND is readable
- [ ] Reference file path matches what SKILL.md will link to
- [ ] **Read the destination file completely** (use Read tool, not search)

**Step 2: Add content to destination**
- [ ] Copy exact text being removed from source file
- [ ] Search destination file for matching content
- [ ] If NOT found in destination:
  - Add missing content to destination file NOW (before removing from source), OR
  - Keep content in source file (don't move)
- [ ] If FOUND: Verify it's complete and identical in meaning/context

**Step 3: Verify completeness**
- [ ] Read destination file after update
- [ ] Verify no gaps in migrated content
- [ ] Verify context is preserved

### Phase 2: LINK in SKILL.md

**Step 1: Update references**
- [ ] Update SKILL.md pointers to new destination file
- [ ] Remove old source file references from SKILL.md
- [ ] Verify all links in SKILL.md now point to destination files

**Step 2: Verify accessibility**
- [ ] Link appears before or near where content was removed
- [ ] Link is clear and findable
- [ ] No broken or orphaned references

**Step 3: Test links**
- [ ] Search SKILL.md for all references to moved files
- [ ] Confirm no dangling links remain

### Phase 3: DELETE Old Source

**⚠️ Only after Phase 2 is complete**

**Step 1: Delete source files**
- [ ] Delete old source files ONLY after Phase 2 links verified
- [ ] Confirm file count reduction
- [ ] Verify deletion is intentional

**Step 2: Final verification**
- [ ] SKILL.md reads without errors
- [ ] All references still work
- [ ] No orphaned files remain

## Why This Sequence Matters

### ❌ WRONG: Create → Delete → Link

```
1. Create destination with new content
2. Delete old source files (too early!)
3. Try to update links
→ Links now point to deleted files (BROKEN!)
→ Content appears lost
```

**Result:** Broken skill, lost content, cascading failures.

### ✅ CORRECT: Create → Link → Delete

```
1. Create destination with merged content
2. Update SKILL.md links to destination
3. Delete old source files
→ Links work, old files gone
→ Content safely relocated
```

**Result:** Smooth refinement, no broken links, content preserved.

## Applications

### Content Relocation: SKILL.md → references/

**Example:** Moving edge-case patterns from SKILL.md to supplementary reference file

**Sequence:**
1. **CREATE:** New reference file `references/advanced-patterns.md` with edge case content
2. **LINK:** Update SKILL.md to reference new file: "See `references/advanced-patterns.md` for edge cases"
3. **DELETE:** Remove edge cases from SKILL.md body

**Verify:** SKILL.md still makes sense. Edge cases are now in reference file.

### Content Consolidation: Multiple files → One file

**Example:** Three related reference files on similar topics merge into one

**Sequence:**
1. **CREATE:** New consolidated file `references/consolidated-topic.md` with content from all 3 files
2. **LINK:** Update SKILL.md to point to consolidated file (remove links to old files)
3. **DELETE:** Delete 3 old reference files (only after links updated)

**Verify:** Consolidated file contains all content from sources. Links work. File count decreased.

### Content Reorganization: Reorder within SKILL.md

**Example:** Move "Quick Start" section to top, move "Advanced Topics" to bottom

**Sequence:**
1. **CREATE:** New organization (copy full content, reorganize sections)
2. **LINK:** (Not needed - same file)
3. **DELETE:** (Not needed - replacing in place)

**Verify:** All content present. Better order. Same line count.

## Testing Movement Pattern Compliance

Use this checklist to validate movement during refinement:

- [ ] **Phase 1 (CREATE):** Destination file has ALL migrated content
- [ ] **Phase 1 (CREATE):** Destination file read-verified for completeness
- [ ] **Phase 2 (LINK):** SKILL.md updated to new location
- [ ] **Phase 2 (LINK):** Old links removed from SKILL.md
- [ ] **Phase 2 (LINK):** No broken references remain
- [ ] **Phase 3 (DELETE):** Old source files deleted ONLY after Phase 2
- [ ] **Phase 3 (DELETE):** Final read-verify: SKILL.md works without errors

## Hook Validation (Automated)

The skill-refiner hook validates Movement Pattern automatically during write/edit operations:

**Hook checks:**
- Is content being removed?
- Does destination file exist and contain equivalent content?
- Are links in SKILL.md pointing to destination?
- Reject if: "Content deleted with no corresponding destination"
- Accept if: "Content clearly relocated to another location"

**Result:** Movement Pattern violations are caught before changes committed.

## Common Mistakes

❌ **"I'll move it later"** → Don't. Create destination FIRST.

❌ **"I'll delete and recreate"** → Don't. Violates movement pattern.

❌ **"The file doesn't exist yet"** → Create it first, THEN delete source.

❌ **"Just leave broken links for now"** → Don't. Fix before deleting source.

✅ **"Create destination, update links, then delete source"** → Correct order.

## Real-World Example

**Skill:** skill-creator (version 1.2.0 → 1.2.1)
**Plan:** Extract refinement content into separate references/ file

**Wrong approach (❌):**
1. Delete refinement sections from SKILL.md
2. Plan to create new reference file later
3. (Never create the file)
→ Content lost, skill broken

**Correct approach (✅):**
1. **CREATE:** `references/refinement-workflow.md` with all refinement content from SKILL.md
2. **LINK:** Update SKILL.md: "For refinement, see `references/refinement-workflow.md`"
3. **DELETE:** Remove refinement sections from SKILL.md (now safely in reference)
→ Content relocated, links work, skill improved

## References

- **Gate 3: Migration Verification** in `refinement-workflow.md` - Full detailed gates
- **Preservation Gates** in `preservation-rules.md` - How gates protect against content loss
- **The 80% Rule** in `80-percent-rule.md` - Deciding what content moves
