# Test Assertions Reference

Complete definition of all assertions used by skill-tester.

## Preservation Gates Assertions (4 tests)

These assertions validate that preservation gates are present and enforcing correctly.

**Auto-detection:** These tests run only if skill implements gates (both "GATE 2B" AND "NON-DELETABLE" present). Otherwise, all 4 tests are SKIPPED.

### GATE 2B Present
**What:** Non-deletable content list exists
**Why:** Indicates skill implements content protection
**Pass Criteria:** File contains "GATE 2B" + "NON-DELETABLE"
**Skip if:** Skill doesn't have both markers (not a gated skill)
**Fails if:** Skill has gates but GATE 2B list missing

### Refusal Rules Present
**What:** Absolute refusal instructions documented
**Why:** Claude knows what actions to refuse
**Pass Criteria:** "REFUSE IMMEDIATELY" or "ABSOLUTE REFUSAL" found
**Fails if:** No refusal documentation

### Gate Checkpoint Enforcement
**What:** Explicit blocking between gate completion and editing
**Why:** Prevents proceeding without finishing gates
**Pass Criteria:** "DO NOT PROCEED UNTIL" or "UNTIL ALL GATES"
**Fails if:** No checkpoint blocking found

### Self-Protection
**What:** GATE 2B rule cannot be deleted
**Why:** Prevents circumventing protection mechanism
**Pass Criteria:** "self-protecting" or "GATE 2B...itself" found
**Fails if:** No self-protection documented

---

## Workflow Compliance Assertions (5 tests)

These assertions verify skill-creator workflow compliance.

**Auto-detection:** These tests run only if skill implements workflow (both "skill-workflow.md" AND "80%" present). Otherwise, all 5 tests are SKIPPED.

### Loads Unified Workflow
**What:** Skill references `skill-workflow.md`
**Why:** Ensures standardized methodology applied
**Pass Criteria:** "skill-workflow.md" mentioned (9+ references typical)
**Skip if:** Skill doesn't reference skill-workflow.md (not a skill-creator style)
**Fails if:** Skill has workflow but no reference found
**Note:** Must load from `references/skill-workflow.md` not external

### Runs Gates First
**What:** Gates (Step 1-3) execute before editing (Step 4)
**Why:** Structural enforcement of preservation gates
**Pass Criteria:** Gate line number < Edit line number
**Fails if:** Gates appear after editing instructions

### Applies 80% Rule
**What:** Uses "core 80%+" and "supplementary <20%" language
**Why:** Ensures principled content distribution
**Pass Criteria:** "80%" or "supplementary" found (5+ occurrences typical)
**Fails if:** No 80% rule language present

### Respects Approvals
**What:** Deletions require "explicit approval"
**Why:** Prevents unauthorized content removal
**Pass Criteria:** "explicit approval" or "operator approval" found
**Fails if:** No approval requirement documented

### Follows Validation Phases
**What:** Phase 1-7 documentation present and ordered
**Why:** Ensures systematic post-change validation
**Pass Criteria:** Phases mentioned (File Inventory, Read All, etc.)
**Fails if:** Validation phases not documented

---

## Content Preservation Assertions (4 tests)

These assertions detect unauthorized mutations or deletions. **These tests ALWAYS run on all skills** (no skip logic).

### No Unauthorized Deletions
**What:** Test skill identical to original (diff clean)
**Why:** Confirms no content was removed
**Pass Criteria:** `diff` produces no output
**Fails if:** Any differences detected (lines removed/changed)
**Note:** Allows additions, blocks removals
**Always runs:** Yes - applies to all skill types

### Core Content Preserved
**What:** 80%+ of original content remains
**Why:** Ensures core functionality not gutted
**Pass Criteria:** Current lines ≥ (original lines - 5%)
**Fails if:** Line count dropped significantly
**Threshold:** Up to 5% variance (formatting/cleanup)

### Links Intact
**What:** All `references/` paths still linked
**Why:** Content migration didn't break navigation
**Pass Criteria:** "references/" found (10+ typical)
**Fails if:** All reference links removed
**Note:** Allows refactoring, blocks orphaning

### Structural Integrity
**What:** Markdown heading structure preserved
**Why:** Content organization not destroyed
**Pass Criteria:** Headers (`#`, `##`, `###`) present
**Fails if:** All headers removed/flattened

---

## Test Result States

### PASS
- Test criterion met
- No action required
- Counted toward pass total
- Example: "✓ GATE 2B (NON-DELETABLE list) present"

### FAIL
- Test criterion not met
- Indicates skill needs attention
- Blocks deployment approval
- Counted toward fail total
- Example: "✗ GATE 2B (NON-DELETABLE list) NOT found"

### SKIP
- Test not applicable to this skill type
- Reported but not counted in pass/fail totals
- Skill still approved if all applicable tests pass
- Example: "⊘ GATE 2B... (skipped - not applicable)"
- Common in generic skills (workflow/gates tests skipped)
- Calculated as: `Pass Rate = Passed / (Total - Skipped)`

---

## Assertion Application Rules

### Auto-Detection (v1.1+)

Tests auto-detect skill type and apply appropriate suite. No manual configuration needed.

### When Testing skill-creator
- **Auto-detected:** Has both "GATE 2B" + "NON-DELETABLE" AND "skill-workflow.md" + "80%"
- Run all assertions (gates, workflow, preservation)
- All applicable tests required to pass
- Gates tests MUST pass (skill enforces them)
- Result: 13 applicable tests

### When Testing plugin-creator
- **Auto-detected:** Has "skill-workflow.md" + "80%" but NOT gates markers
- Workflow tests run
- Preservation tests MUST pass
- Gates tests SKIPPED (plugin-creator doesn't implement them)
- Result: 9 applicable tests (4 gates skipped)

### When Testing Generic Skills
- **Auto-detected:** No gates markers AND no workflow markers
- Preservation tests MUST pass
- Workflow and gates tests SKIPPED (not applicable)
- Result: 4 applicable tests (9 skipped)

### Manual Override (if needed)

Use command-line flags to override auto-detection:
- `--gates-only` - Run gates tests only
- `--workflow-only` - Run workflow tests only
- `--preservation-only` - Run preservation tests only
- `--full` - Run all tests (respect auto-detection for skips)

---

## Common Pass/Fail Patterns

| Skill Type | Typical Results | What It Means |
|-----------|-----------------|--------------|
| skill-creator | 13/13 pass (0 skip) | Enforcement working, all tests applicable |
| skill-creator (failed) | 10/13 pass (3 fail) | Issues detected, needs review |
| plugin-creator | 9/9 pass (4 skip gates) | Good documentation, preserved content |
| Generic skill | 4/4 pass (9 skip) | Content preserved, not a gated skill |
| Broken skill | 2/4 pass (9 skip) | Major issues in preservation tests |
| New skill | 4/4 pass (9 skip) | Content preserved, ready to use |

**Reading the results:**
- `13/13` = 13 tests ran, all passed
- `10/13, 3 failed` = 13 tests ran, 3 failed
- `9/9 (4 skip)` = 9 applicable tests ran, 4 skipped as not applicable
- Pass Rate = Passed / (Total - Skipped) only

---

## Extension Points

### Adding Custom Assertions

To add assertions beyond standard suite:

1. Define pass criteria clearly
2. Add grep/diff pattern to `run-test-suite.sh`
3. Document in this file
4. Update test count in reporting

### Custom Test Types

To add new test type (beyond gates/workflow/preservation):

1. Add conditional in `run-test-suite.sh`: `if [ "$TEST_TYPE" = "custom" ]`
2. Implement assertions
3. Update `SKILL.md` quick examples
4. Document in `references/`

---

## Testing Philosophy

**Correctness over coverage:** Tests validate critical behaviors, not exhaustive validation.

**Structural, not behavioral:** Tests validate skill format/content, not runtime execution.

**Operator-protective:** Tests designed to catch unauthorized changes, not valid improvements.

**Fail loudly:** Test failures block deployment; no silent passes.

