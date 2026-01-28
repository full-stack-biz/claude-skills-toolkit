---
name: skill-tester
description: >-
  Generic unit testing framework for Claude Code skills. Loads test suites from YAML configuration, auto-detects skill type, executes assertions (grep, diff, custom shell scripts), and generates reports. Extensible: users can add custom test suites. Use when testing skill changes, validating preservation gates, verifying 80% rule compliance, or ensuring refactoring doesn't break functionality.
version: 2.0.0
allowed-tools: Read,Write,Edit,Bash(mkdir:*,cp:*,rm:*,diff:*,grep:*,wc:*,head:*,tail:*,ruby:*),Glob,Grep,AskUserQuestion
---

# Skill Tester

**Automated validation for Claude Code skills** — Test preservation gates, workflow compliance, content preservation, and functionality across skill refinements.

## Quick Start

Testing a skill takes 3 steps:

1. **Choose skill:** Which skill to test? (e.g., `skill-creator`, `plugin-creator`)
2. **Select test suite:** Gate validation? Workflow compliance? Content preservation? All of above?
3. **Run tests:** Automated test runner generates report with pass/fail assertions

## When to Use This Skill

**Testing any Claude Code skill:**
- skill-creator built skills (full test suite: gates + workflow + preservation)
- Generic skills (preservation tests only)
- plugin-creator and other tools (auto-detects applicable tests)

**Testing skill changes:**
- After refining a skill (check preservation gates enforced)
- Before deploying (verify 80% rule, core content preserved)
- When skill structure changes (validate workflow compliance)
- After CLI migrations (test backward compatibility)

**Validation scenarios:**
- Preserve Gates working? (GATE 1-4 executing in order) - if implemented
- Workflow compliant? (skill-workflow.md followed) - if applicable
- Content preserved? (no unauthorized deletions) - always checked
- Functionality intact? (expected behavior unchanged)
- Checklist enforced? (mandatory steps not skipped) - if applicable

**Auto-detection:** Tests intelligently skip if skill doesn't implement gates/workflow (e.g., generic skills get 4 preservation tests, not 13).

**NOT for:** Runtime debugging, skill behavior testing, user acceptance testing (focus on structure/preservation only).

---

## Testing Methodology

### Overview

Skills are tested by:
1. Creating isolated copy in `/tmp` (read-only if `--print` flag used)
2. Running assertion suite against skill structure
3. Comparing test copy with original (verify no mutations)
4. Generating automated test report with compliance details

### Workflow Compliance Tests

| Test | Checks | Pass Criteria |
|------|--------|---------------|
| **Loads unified workflow** | References `skill-workflow.md` | Output mentions `skill-workflow.md` |
| **Runs gates first** | Gates before editing (Step 1-3 before 4) | Gate content appears before edit instructions |
| **Applies 80% rule** | Uses "core"/"supplementary" classification | Output contains "80%" or "supplementary" |
| **Respects approvals** | Gate 4 requires "explicit approval" | "approval" mentioned for deletions |
| **Validates phases** | Phase 1-7 documented and ordered | All 7 validation phases present |

### Content Preservation Tests

| Test | Checks | Pass Criteria |
|------|--------|---------------|
| **No unauthorized deletions** | Target skill unchanged | `diff` produces no output |
| **Core content preserved** | 80%+ of original content remains | Line count stable or increased |
| **Links intact** | All reference links valid | `references/` paths still linked |
| **Structural integrity** | Sections/headings unchanged | File structure matches original |

### Preservation Gates Tests (if skill has them)

| Test | Checks | Pass Criteria |
|------|--------|---------------|
| **GATE 2B present** | Non-deletable list exists | "NON-DELETABLE" or "GATE 2B" found |
| **Refusal rules present** | Absolute refusal documented | "REFUSE IMMEDIATELY" mentioned |
| **Checkpoint enforcement** | "DO NOT PROCEED" blocking | "DO NOT PROCEED UNTIL" found |
| **Self-protection** | Gates cannot be deleted | GATE 2B in protected list |

### Skill Type Auto-Detection

Tests automatically detect which test suite to run:

**skill-creator style skills:**
- ✓ Preservation gates tests (4)
- ✓ Workflow compliance tests (5)
- ✓ Content preservation tests (4)
- Total: 13 tests

**Generic skills (no gates/workflow):**
- ⊘ Preservation gates tests (4 skipped)
- ⊘ Workflow compliance tests (5 skipped)
- ✓ Content preservation tests (4)
- Total: 4 applicable tests

**Plugin-creator style (workflow but no gates):**
- ⊘ Preservation gates tests (4 skipped)
- ✓ Workflow compliance tests (5)
- ✓ Content preservation tests (4)
- Total: 9 applicable tests

**Detection method:** Auto-detection scans SKILL.md for marker phrases:
- **Preservation gates:** Requires BOTH "GATE 2B" AND "NON-DELETABLE"
- **Workflow compliance:** Requires BOTH "skill-workflow.md" AND "80%"

Tests marked SKIP are not included in pass/fail totals, only in report for transparency.

---

## Test Workflow

### Step 1: Choose Target Skill

Ask: Which skill to test?
- Project-local: `skills/skill-name/` (preferred)
- User-space: `~/.claude/skills/skill-name/` (affects all projects)
- If test modifies: Use isolated copy in `/tmp`

**Locate the skill:**
```bash
find /Users/sergeymoiseev/full-stack.biz/claude-skills-toolkit -name "SKILL.md" -path "*/skills/*/SKILL.md" | grep skill-name
```

### Step 2: Select Test Suite

**Option 1: Preservation Gates Only**
- GATE 2B detection (non-deletable content)
- Refusal rules validation
- Self-protection checks
- Best for: Skills implementing preservation gates

**Option 2: Workflow Compliance Only**
- 80% rule applied?
- skill-workflow.md referenced?
- Validation phases documented?
- Best for: Validating skill-creator style

**Option 3: Content Preservation Only**
- No unauthorized deletions?
- Core content preserved (80%+)?
- Reference links intact?
- Line counts stable?
- Best for: Detecting mutations after refinement

**Option 4: Full Test Suite (Recommended)**
- All of above
- Comprehensive report
- Best for: Pre-deployment validation

### Step 3: Run Tests

**Setup (automated):**
```bash
ruby scripts/setup-test-env.rb SKILL_NAME
```

**Run test suite:**
```bash
ruby scripts/run-test-suite.rb SKILL_NAME TEST_SUITE_TYPE
```

**Generate report:**
```bash
ruby scripts/generate-test-report.rb TEST_RESULTS_JSON
```

---

## Reference Documentation

### Testing Assertions

See `references/test-assertions.md` for complete assertion definitions with:
- Workflow compliance assertions (5 tests)
- Content preservation assertions (4 tests)
- Preservation gates assertions (4 tests)
- Detailed pass/fail criteria

### Test Scripts

See `references/script-reference.md` for detailed documentation of:
- `setup-test-env.rb` — Create isolated test environment
- `run-test-suite.rb` — Execute assertion suite
- `generate-test-report.rb` — Generate markdown report

### Example Test Reports

See `references/example-reports.md` for real test reports from:
- skill-creator validation
- plugin-creator testing
- Preservation gates enforcement

---

## Quick Test Examples

**Test skill-creator preservation gates:**
```bash
ruby scripts/run-test-suite.rb skill-creator gates-only
```

**Test plugin-creator for content preservation:**
```bash
ruby scripts/run-test-suite.rb plugin-creator preservation-only
```

**Full validation before deployment:**
```bash
ruby scripts/run-test-suite.rb my-skill full --report
```

**Test specific skill in different project:**
```bash
ruby scripts/run-test-suite.rb my-skill full . /path/to/project
```

---

## Test Output

Each test generates:

1. **Console output:** Pass/fail for each assertion
2. **Test report (markdown):** Detailed results with metrics
3. **Assertion table:** Summary of all tests
4. **Diff output (if mutations detected):** Changed files

Example report structure:
```
# Test Report: skill-name

## Test Results
### Preservation Gates Tests ✓
- GATE 2B present: PASS
- Refusal rules: PASS
- Self-protection: PASS

### Workflow Compliance Tests ✓
- Loads workflow: PASS
- Runs gates first: PASS

### Content Preservation Tests ✓
- No deletions: PASS
- Core content: PASS

## Summary
14/14 assertions passed (100%)
Status: APPROVED FOR DEPLOYMENT ✓
```

---

## Extension Mechanism: Custom Test Suites

**skill-tester is fully extensible.** Create custom test suites by adding YAML files to `suites/` directory.

### Built-in Suites

- **preservation-gates.yaml** - 4 tests for GATE 2B content protection
- **workflow-compliance.yaml** - 5 tests for skill-workflow.md compliance
- **content-preservation.yaml** - 4 tests for core content integrity (always runs)

### Creating Custom Suites

1. Create `suites/my-suite.yaml`:

```yaml
---
name: my-suite
description: Custom validation
detection:
  markers:
    - pattern: "my-marker"
  logic: and  # and, or, always

tests:
  - id: test-1
    name: "My test"
    assertion:
      type: grep
      pattern: "search pattern"
      target: "$SKILL_MD"
    enabled: true
```

2. Run it:
```bash
ruby scripts/run-test-suite.rb skill-name my-suite
```

### Assertion Types

**Grep** - Search for patterns in files:
```yaml
assertion:
  type: grep
  pattern: "pattern"
  target: "$SKILL_MD"
```

**Diff** - Compare files for equality:
```yaml
assertion:
  type: diff
  files:
    - "$SKILL_PATH/SKILL.md"
    - "$ORIGINAL_PATH/SKILL.md"
```

**Custom** - Run bash scripts (access to $SKILL_MD, $SKILL_PATH, $ORIGINAL_PATH):
```yaml
assertion:
  type: custom
  script: |
    [ -f "$SKILL_MD" ] && grep -q "pattern" "$SKILL_MD"
```

### Auto-Detection

Test suites run based on detection markers:
- `logic: always` - Always run
- `logic: and` - All markers must match
- `logic: or` - Any marker matches

---

## Key Notes

**Test isolation:** Tests run in `/tmp/skill-test` isolated copy, never modify originals.

**No execution side effects:** Tests only validate structure, not runtime behavior.

**Automated reporting:** Reports generated as markdown with metrics and recommendations.

**Assertion-based:** All tests use clear pass/fail criteria.

**Extensible:** Add custom test suites for project-specific validation.

---

## Troubleshooting

**"Skill not found"**
- Verify path: `skills/SKILL_NAME/SKILL.md` or `~/.claude/skills/SKILL_NAME/SKILL.md`
- Check spelling (case-sensitive)

**"Test not found"**
- Verify suite file exists: `suites/suite-name.yaml`
- Check YAML syntax is valid

**"Diff shows differences"**
- Expected if testing a refinement (compare with original)
- Review changes in test report

---

## Version History

**v2.0.0** (January 2026)
- **MAJOR REFACTORING: Generic unit testing framework**
- Complete rewrite in pure Ruby (no bash scripts)
- YAML-based test suite definitions (pluggable)
- Support for grep, diff, and custom shell assertions
- Declarative auto-detection logic in YAML
- Extension mechanism: users can add custom suites
- Enhanced report generation with skill metrics
- Fully backward compatible CLI interface
- Works on any Claude Code skill type

**v1.1.0** (January 2026)
- Added auto-detection for skill type (gates, workflow, preservation)
- Implemented skip logic for non-applicable tests
- Support for generic skills (any Claude Code skill)
- Tests intelligently adapt to skill characteristics
- Backward compatible with existing test modes
- Improved reporting with skip counts

**v1.0.0** (January 2026)
- Initial release
- Full test suite (gates, workflow, preservation)
- Automated report generation
- Assertion-based validation
