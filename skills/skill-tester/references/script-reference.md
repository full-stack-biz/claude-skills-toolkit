# Script Reference

Complete documentation of skill-tester scripts.

## Overview

Three main scripts work together:

1. **setup-test-env.sh** — Create isolated test environment
2. **run-test-suite.sh** — Execute assertions and generate results
3. **generate-test-report.sh** — Create markdown test report

All scripts are generalizable and work with any skill in the project.

---

## setup-test-env.sh

**Purpose:** Create isolated test directory with skill copy.

**Usage:**
```bash
bash setup-test-env.sh SKILL_NAME [--source-dir PATH]
```

**Parameters:**
- `SKILL_NAME` — Name of skill to test (required)
- `--source-dir PATH` — Project root (default: current directory)

**Returns:** Test directory path (e.g., `/tmp/skill-test/skill-creator`)

**Behavior:**
1. Searches for skill in project (preferred) or user-space
2. Creates `/tmp/skill-test/` isolation directory
3. Copies skill to `/tmp/skill-test/SKILL_NAME/`
4. Stores original path for comparison
5. Outputs test directory for use by other scripts

**Example:**
```bash
TEST_DIR=$(bash scripts/setup-test-env.sh plugin-creator)
# Output: /tmp/skill-test/plugin-creator
```

**Search Order:**
1. `./skills/SKILL_NAME/` (project-local, preferred)
2. `./.claude/skills/SKILL_NAME/`
3. `~/.claude/skills/SKILL_NAME/` (user-space)

**Error Handling:**
- Exits if skill not found
- Cleans up existing test directory
- Creates fresh copy each run

---

## run-test-suite.sh

**Purpose:** Execute assertion suite and validate skill.

**Usage:**
```bash
bash run-test-suite.sh SKILL_NAME [TEST_TYPE] [--report]
```

**Parameters:**
- `SKILL_NAME` — Skill to test (required)
- `TEST_TYPE` — gates-only | workflow-only | preservation-only | full (default: full)
- `--report` — Generate markdown report (optional)

**Test Types:**

| Type | Tests | Use Case |
|------|-------|----------|
| **gates-only** | GATE 2B, Refusal, Checkpoint, Self-protection (4 tests) | Validate gate enforcement |
| **workflow-only** | Loads workflow, Gates first, 80% rule, Approvals, Validation (5 tests) | Verify skill-creator compliance |
| **preservation-only** | No deletions, Core content, Links, Structure (4 tests) | Detect mutations after refinement |
| **full** | All 13 tests | Pre-deployment validation (recommended) |

**Output:**

Console output showing:
```
✓ GATE 2B (NON-DELETABLE list) present
✓ Refusal rules documented
✓ Gate checkpoint enforcement present
...

TEST SUMMARY
============
Total: 13
Passed: 13
Failed: 0

✓ ALL TESTS PASSED
```

**Example:**
```bash
# Test preservation gates only
bash scripts/run-test-suite.sh skill-creator --gates-only

# Full validation with report
bash scripts/run-test-suite.sh plugin-creator --full --report
```

**Test Execution:**
1. Sets up test environment via `setup-test-env.sh`
2. Reads skill SKILL.md
3. Runs assertions based on TEST_TYPE
4. Counts pass/fail
5. Optionally generates report via `generate-test-report.sh`

**Exit Codes:**
- `0` — All tests passed
- `1` — One or more tests failed

---

## generate-test-report.sh

**Purpose:** Create markdown test report for documentation.

**Usage:**
```bash
bash generate-test-report.sh TEST_DIR SKILL_NAME TEST_TYPE PASSED TOTAL
```

**Parameters:**
- `TEST_DIR` — Test directory from setup-test-env.sh
- `SKILL_NAME` — Name of tested skill
- `TEST_TYPE` — Test type used (gates-only, workflow-only, etc.)
- `PASSED` — Number of passed tests
- `TOTAL` — Total tests run

**Output:** Creates `TEST_DIR/TEST_REPORT.md`

**Report Sections:**

1. **Header** — Date, skill name, test type, source paths
2. **Summary** — Pass rate, status (APPROVED/NEEDS REVIEW)
3. **Skill Metrics** — Line count, sections, references, checklists
4. **Detailed Results** — Each test with pass/fail
5. **Recommendations** — Next steps based on results
6. **File Comparison** — Diff output if mutations detected
7. **Footer** — Timestamp, framework version

**Example Report Structure:**
```markdown
# Test Report: skill-creator

| Metric | Result |
|--------|--------|
| Total Tests | 13 |
| Passed | 13 |
| Failed | 0 |
| Pass Rate | 100% |
| Status | ✓ APPROVED FOR DEPLOYMENT |

## Detailed Test Results
[Test-by-test output]

## Recommendations
✓ All tests passed. Ready for deployment.
```

**Status Determination:**
- **APPROVED** — All tests pass (FAILED = 0)
- **NEEDS REVIEW** — Any test fails (FAILED > 0)

---

## Common Workflows

### Test Preservation Gates (skill-creator style)
```bash
bash scripts/run-test-suite.sh my-skill --gates-only --report
```

### Validate No Content Was Deleted
```bash
bash scripts/run-test-suite.sh my-skill --preservation-only --report
```

### Full Pre-Deployment Check
```bash
bash scripts/run-test-suite.sh my-skill --full --report
```

### Compare Skill Before/After Refinement
```bash
# Before changes
bash scripts/setup-test-env.sh my-skill

# After changes (manually edit skill)
bash scripts/run-test-suite.sh my-skill --full

# Inspect diff
diff /tmp/skill-test/my-skill/SKILL.md [original-path]
```

### Batch Test Multiple Skills
```bash
for skill in skill-creator plugin-creator my-skill; do
    bash scripts/run-test-suite.sh $skill --full --report
    echo "---"
done
```

---

## Script Generalization Features

All scripts work with any skill because:

1. **Dynamic skill location** — Searches project and user-space
2. **Path independence** — No hardcoded paths
3. **Generic assertions** — Check structural patterns, not skill-specific content
4. **Flexible test types** — Can run partial or full suites
5. **Automated reporting** — Generic report template fits any skill

### Adding Support for New Skill Locations

Edit `setup-test-env.sh` `find_skill()` function:
```bash
find_skill() {
    local name=$1
    # Add custom search path here
    if [ -d "$SOURCE_DIR/custom/path/$name" ]; then
        echo "$SOURCE_DIR/custom/path/$name"
        return 0
    fi
    # ... rest of search
}
```

---

## Error Handling

| Error | Cause | Fix |
|-------|-------|-----|
| "Skill not found" | Path doesn't match search pattern | Verify skill location, check spelling |
| "Test directory exists" | Previous test not cleaned up | Manual cleanup: `rm -rf /tmp/skill-test/SKILL_NAME` |
| "Diff not found" | Skill structure incompatible | Verify SKILL.md exists in skill directory |
| "Report failed" | Permissions issue | Check write access to `/tmp` |

---

## Performance Notes

- Setup: ~100ms (copy operation)
- Test execution: ~1-2s (grep/diff on SKILL.md files)
- Report generation: ~500ms (markdown file creation)
- Total typical run: 2-3 seconds

For large test suites (20+ skills), batch testing is efficient (~1s per skill after initial setup).

---

## Testing the Tester

To validate skill-tester itself:

```bash
bash scripts/run-test-suite.sh skill-tester --full --report
```

Expected: All tests pass (skill-tester implements preservation gates and workflow compliance).

