# Skill Unit Testing

Testing skill changes before deployment using isolated Claude instances.

## Overview

Skills can be tested by:
1. Creating an isolated copy in `/tmp`
2. Invoking an external Claude instance with `--plugin-dir` and `--print`
3. Verifying behavior without modifying original files
4. Comparing test copy with original using `diff`

## Test Environment Setup

```bash
# Create isolated test directory
mkdir -p /tmp/skill-test

# Copy skill being tested (the tool)
cp -r skills/skill-creator /tmp/skill-test/

# Copy target skill (the subject)
cp -r skills/plugin-creator /tmp/skill-test/
```

## Running Tests

### Read-Only Test (--print flag)

The `--print` flag makes Claude output results without executing file changes:

```bash
cd /tmp/skill-test && claude --plugin-dir ./skill-creator --print "PROMPT HERE"
```

### Test Cases

**Gate 1: Content Audit**
```bash
claude --plugin-dir ./skill-creator --print \
  "Using skill-creator, refine plugin-creator. Follow references/skill-workflow.md. \
   Run Gate 1 (Content Audit) on plugin-creator/SKILL.md and classify each section \
   as core (80%+) or supplementary (<20%). Output the classification table."
```

Expected output:
- Classification table with all sections
- Each section marked as Core or Supplementary
- Line numbers referenced
- Rationale for each classification

**Gate 2: Capability Assessment**
```bash
claude --plugin-dir ./skill-creator --print \
  "Using skill-creator, run Gate 2 (Capability Assessment) on plugin-creator. \
   For each supplementary item from Gate 1, assess if moving it would impair execution."
```

Expected output:
- List of items being assessed
- Decision for each: keep/move/needs-approval
- Explanation of capability impact

**Gate 3: Migration Verification**
```bash
claude --plugin-dir ./skill-creator --print \
  "Using skill-creator, run Gate 3 (Migration Verification) for plugin-creator. \
   For any content proposed to move, verify the destination reference file exists \
   and contains equivalent content."
```

Expected output:
- Source content identified
- Destination file checked
- Gap analysis (content present or missing)
- Accessibility verification

**Full Validation Workflow**
```bash
claude --plugin-dir ./skill-creator --print \
  "Using skill-creator, validate plugin-creator following references/skill-workflow.md \
   Part 3 (Validation Workflow). Run all 7 phases and report findings."
```

Expected output:
- Phase 1-7 results
- Checklist items marked
- Issues identified
- Red flags noted

## Verifying No Changes

After any test, confirm the target skill is unchanged:

```bash
# Should produce no output if identical
diff /tmp/skill-test/plugin-creator/SKILL.md skills/plugin-creator/SKILL.md

# Check all files
diff -r /tmp/skill-test/plugin-creator skills/plugin-creator
```

## Test Assertions

### Workflow Compliance

| Test | Pass Criteria |
|------|---------------|
| Loads unified workflow | Output mentions `skill-workflow.md` |
| Runs Gate 1 first | Content audit appears before any changes |
| Applies 80% rule | Classifications use "core"/"supplementary" language |
| Respects Gate 4 | No deletions without "operator approval" mention |
| Follows validation phases | Phase 1-7 executed in order |

### Content Preservation

| Test | Pass Criteria |
|------|---------------|
| No unauthorized deletions | `diff` shows no removed sections |
| Core content preserved | 80%+ content remains in SKILL.md |
| Links intact | All `references/` links still valid |
| Line count stable | SKILL.md ≤ original line count (unless adding) |

## Example Test Session

```bash
# Setup
mkdir -p /tmp/skill-test
cp -r skills/skill-creator /tmp/skill-test/
cp -r skills/plugin-creator /tmp/skill-test/

# Test Gate 1
cd /tmp/skill-test
claude --plugin-dir ./skill-creator --print \
  "Refine plugin-creator. Run Gate 1 Content Audit." 2>&1 | tee gate1.log

# Verify no changes
diff plugin-creator/SKILL.md ../original/plugin-creator/SKILL.md

# Check log for compliance
grep -E "(Core|Supplementary|80%|skill-workflow)" gate1.log

# Cleanup
rm -rf /tmp/skill-test
```

## Interactive Testing (Without --print)

For testing actual refinement (destructive):

```bash
# Use isolated copy - changes will be made
cd /tmp/skill-test
claude --plugin-dir ./skill-creator

# Then manually verify changes
diff -u ../original/plugin-creator/SKILL.md plugin-creator/SKILL.md
```

## CI Integration

```bash
#!/bin/bash
# test-skill-changes.sh

set -e

# Setup
TEST_DIR=$(mktemp -d)
cp -r skills/skill-creator "$TEST_DIR/"
cp -r skills/plugin-creator "$TEST_DIR/"

# Run test
cd "$TEST_DIR"
OUTPUT=$(claude --plugin-dir ./skill-creator --print \
  "Run Gate 1 Content Audit on plugin-creator" 2>&1)

# Assertions
echo "$OUTPUT" | grep -q "skill-workflow.md" || { echo "FAIL: Workflow not loaded"; exit 1; }
echo "$OUTPUT" | grep -q "Core" || { echo "FAIL: No classifications"; exit 1; }
diff -q plugin-creator/SKILL.md "$OLDPWD/skills/plugin-creator/SKILL.md" || { echo "FAIL: Files modified"; exit 1; }

echo "PASS: All assertions passed"

# Cleanup
rm -rf "$TEST_DIR"
```

## Limitations

- `--print` only shows what Claude would output, not full execution trace
- Complex multi-turn refinements need interactive testing
- File change assertions require comparing before/after states
- Network-dependent skills may behave differently in isolation
