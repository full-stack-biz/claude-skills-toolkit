#!/bin/bash
# generate-test-report.sh - Generate markdown test report
# Usage: bash generate-test-report.sh TEST_DIR SKILL_NAME TEST_TYPE PASSED TOTAL SKIPPED

TEST_DIR=$1
SKILL_NAME=$2
TEST_TYPE=${3:-full}
PASSED=${4:-0}
TOTAL=${5:-0}
SKIPPED=${6:-0}

if [ -z "$TEST_DIR" ]; then
    echo "Error: Usage: bash generate-test-report.sh TEST_DIR SKILL_NAME TEST_TYPE PASSED TOTAL SKIPPED"
    exit 1
fi

SKILL_PATH="$TEST_DIR/skill"
SKILL_MD="$SKILL_PATH/SKILL.md"
REPORT="$TEST_DIR/TEST_REPORT.md"
ORIGINAL_PATH=$(cat "$TEST_DIR/original_path.txt" 2>/dev/null || echo "$SKILL_PATH")

# Calculate metrics
EFFECTIVE_TOTAL=$((TOTAL - SKIPPED))
FAILED=$((EFFECTIVE_TOTAL - PASSED))
if [ $EFFECTIVE_TOTAL -gt 0 ]; then
    PERCENTAGE=$((PASSED * 100 / EFFECTIVE_TOTAL))
else
    PERCENTAGE=0
fi

cat > "$REPORT" << EOF
# Test Report: $SKILL_NAME

**Test Date:** $(date -u +"%Y-%m-%d %H:%M:%S UTC")
**Test Type:** $TEST_TYPE
**Test Directory:** $TEST_DIR

## Test Environment

- **Skill:** $SKILL_NAME
- **Source:** $ORIGINAL_PATH
- **Test Copy:** $SKILL_PATH
- **Method:** Isolated structural verification (read-only)

## Summary

| Metric | Result |
|--------|--------|
| **Total Tests** | $TOTAL |
| **Applicable** | $EFFECTIVE_TOTAL $([ "$SKIPPED" -gt 0 ] && echo "(skipped $SKIPPED)" || echo "") |
| **Passed** | $PASSED |
| **Failed** | $FAILED |
| **Pass Rate** | $PERCENTAGE% |
| **Status** | $([ "$FAILED" -eq 0 ] && echo "✓ APPROVED FOR DEPLOYMENT" || echo "✗ NEEDS FIXES") |

EOF

# Add detailed test results and metrics using grouped redirects
{
    if [ -f "$TEST_DIR/test-log.txt" ]; then
        cat << 'EOF'

## Detailed Test Results

```
EOF
        cat "$TEST_DIR/test-log.txt"
        cat << 'EOF'
```

EOF
    fi

    cat << EOF

## Skill Metrics

| Metric | Value |
|--------|-------|
| **Line Count** | $(wc -l < "$SKILL_MD") |
| **Sections** | $(grep -c "^##" "$SKILL_MD" || echo "N/A") |
| **Code Blocks** | $(grep -c "^\`\`\`" "$SKILL_MD" || echo "N/A") |
| **References** | $(grep -c "references/" "$SKILL_MD" || echo "0") |
| **Checklists** | $(grep -c "^\- \[ \]" "$SKILL_MD" || echo "0") |

## Recommendations

EOF

    if [ "$FAILED" -eq 0 ]; then
        cat << 'EOF'
✓ All tests passed. Ready for deployment.

### Next Steps:
1. Review test report above
2. Deploy skill to production
3. Monitor for edge cases in real-world usage
4. Update team documentation if needed

EOF
    else
        cat << EOF

✗ $FAILED test(s) failed. Review findings below and address issues.

### Issues Found:
$(grep "✗" "$TEST_DIR/test-log.txt" 2>/dev/null | sed 's/^/- /')

### Recommended Actions:
1. Review failed test output above
2. Fix skill structure/content as indicated
3. Re-run tests to verify fixes
4. Approve for deployment once all tests pass

EOF
    fi
} >> "$REPORT"

# Add file comparison and footer using grouped redirects
{
    if ! diff -q "$SKILL_PATH/SKILL.md" "$ORIGINAL_PATH/SKILL.md" > /dev/null 2>&1; then
        cat << 'EOF'

## File Comparison

⚠️ Differences detected. Review changes below:

EOF
        diff -u "$ORIGINAL_PATH/SKILL.md" "$SKILL_PATH/SKILL.md" | head -50 || true
        cat << 'EOF'

(Showing first 50 lines of diff; full diff available in test directory)

EOF
    fi

    cat << EOF

---

**Report Generated:** $(date -u +"%Y-%m-%d %H:%M:%S UTC")
**Test Framework:** skill-tester v1.0.0
**Status:** $([ $FAILED -eq 0 ] && echo "APPROVED ✓" || echo "NEEDS REVIEW ✗")
EOF
} >> "$REPORT"

echo "✓ Test report generated: $REPORT"
echo ""
cat "$REPORT"
