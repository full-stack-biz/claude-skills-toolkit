# Test Suite Format Guide

Complete reference for authoring YAML test suites for skill-tester.

## Suite Structure

Every test suite is a YAML file with metadata, detection rules, and test definitions.

```yaml
---
name: suite-name
description: Human-readable description of what this suite validates
detection:
  markers:
    - pattern: "marker1"
    - pattern: "marker2"
  logic: and  # and, or, or always

tests:
  - id: test-id
    name: "Test name"
    description: "Optional: detailed description"
    assertion:
      type: grep  # grep, diff, or custom
      # ... assertion-specific fields
    enabled: true
```

## Metadata Fields

### name
**Type:** string (lowercase, hyphens only, ≤64 chars)
**Required:** yes
**Example:** `preservation-gates`, `workflow-compliance`

The suite name used in CLI and for file naming.

### description
**Type:** string (≤1024 chars)
**Required:** yes
**Example:** `Validate preservation gates implementation`

Human-readable description of what the suite tests.

## Detection

Auto-detection determines if a suite should run on a skill.

### detection.markers
**Type:** array of pattern objects
**Required:** if logic is `and` or `or`

Each marker is a regex pattern matched against the skill's SKILL.md:

```yaml
detection:
  markers:
    - pattern: "GATE 2B"
    - pattern: "NON-DELETABLE"
```

### detection.logic
**Type:** string (and, or, always)
**Required:** yes
**Default:** always

- **and** - All markers must match (conjunction)
- **or** - Any marker must match (disjunction)
- **always** - No detection, suite always runs

**Examples:**

```yaml
# Run only if BOTH markers present
detection:
  markers:
    - pattern: "GATE 2B"
    - pattern: "NON-DELETABLE"
  logic: and

# Run if EITHER marker present
detection:
  markers:
    - pattern: "skill-workflow.md"
    - pattern: "workflow"
  logic: or

# Always run (no detection)
detection:
  markers: []
  logic: always
```

## Tests

An array of individual test definitions.

```yaml
tests:
  - id: test-id
    name: "Test name"
    description: "Optional description"
    assertion:
      type: grep
      pattern: "pattern"
      target: "$SKILL_MD"
    enabled: true
```

### Test Fields

#### id
**Type:** string (lowercase, hyphens, ≤64 chars)
**Required:** yes

Unique identifier for the test within the suite (for CLI output).

#### name
**Type:** string (≤256 chars)
**Required:** yes

Human-readable test name (displayed in test output).

#### description
**Type:** string
**Required:** no

Optional detailed description of what the test validates.

#### assertion
**Type:** object
**Required:** yes

The actual assertion to execute. See "Assertion Types" below.

#### enabled
**Type:** boolean
**Required:** no
**Default:** true

If false, test is skipped (useful for temporarily disabling tests).

## Assertion Types

### Grep Assertions

Search for a regex pattern in a file.

```yaml
assertion:
  type: grep
  pattern: "regex pattern"
  target: "$SKILL_MD"
```

**Fields:**

- **type:** `grep` (required)
- **pattern:** Regex pattern to search for (required, extended regex syntax)
- **target:** File path (required, supports variable expansion)

**Variables:**
- `$SKILL_MD` - Path to skill's SKILL.md file
- `$SKILL_PATH` - Path to tested skill directory
- `$ORIGINAL_PATH` - Path to original skill (before testing)

**Examples:**

```yaml
# Simple substring
assertion:
  type: grep
  pattern: "GATE 2B"
  target: "$SKILL_MD"

# Regex with alternation (extended regex)
assertion:
  type: grep
  pattern: "GATE 2B.*NON-DELETABLE|NON-DELETABLE.*GATE 2B"
  target: "$SKILL_MD"

# Multiline patterns
assertion:
  type: grep
  pattern: "^##.*Workflow"
  target: "$SKILL_MD"
```

**Pass Criteria:** Pattern found in file (exit code 0).

### Diff Assertions

Compare two files for equality.

```yaml
assertion:
  type: diff
  files:
    - "$SKILL_PATH/SKILL.md"
    - "$ORIGINAL_PATH/SKILL.md"
```

**Fields:**

- **type:** `diff` (required)
- **files:** Array of exactly 2 file paths (required)

**Variables:** Same as grep assertions.

**Examples:**

```yaml
# Verify no changes to SKILL.md
assertion:
  type: diff
  files:
    - "$SKILL_PATH/SKILL.md"
    - "$ORIGINAL_PATH/SKILL.md"

# Compare reference files
assertion:
  type: diff
  files:
    - "$SKILL_PATH/references/api.md"
    - "$ORIGINAL_PATH/references/api.md"
```

**Pass Criteria:** Files are identical (no differences).

### Custom Assertions

Execute arbitrary bash code for complex logic.

```yaml
assertion:
  type: custom
  script: |
    gate_line=$(grep -n "GATE 1" "$SKILL_MD" | head -1 | cut -d: -f1)
    edit_line=$(grep -n "Step 4" "$SKILL_MD" | head -1 | cut -d: -f1)
    [ -n "$gate_line" ] && [ -n "$edit_line" ] && [ "$gate_line" -lt "$edit_line" ]
```

**Fields:**

- **type:** `custom` (required)
- **script:** Bash code to execute (required, multiline)

**Variables:** Environment variables available in script:
- `$SKILL_MD`
- `$SKILL_PATH`
- `$ORIGINAL_PATH`

**Examples:**

```yaml
# Check line ordering
assertion:
  type: custom
  script: |
    gate=$(grep -n "gates" "$SKILL_MD" | head -1 | cut -d: -f1)
    edit=$(grep -n "editing" "$SKILL_MD" | head -1 | cut -d: -f1)
    [ "$gate" -lt "$edit" ]

# Check line count
assertion:
  type: custom
  script: |
    orig=$(wc -l < "$ORIGINAL_PATH/SKILL.md")
    test=$(wc -l < "$SKILL_PATH/SKILL.md")
    [ "$test" -ge "$((orig - 5))" ]

# Complex file checks
assertion:
  type: custom
  script: |
    [ -d "$SKILL_PATH/scripts" ] && \
    [ -f "$SKILL_PATH/scripts/test.py" ] && \
    grep -q "import" "$SKILL_PATH/scripts/test.py"
```

**Pass Criteria:** Script exits with code 0 (success).

## Complete Example

Here's a complete custom test suite:

```yaml
---
name: security-checks
description: >-
  Validate security-related aspects of skills. Tests for hardcoded secrets,
  dangerous patterns, and security best practices.
detection:
  markers:
    - pattern: "shell"
    - pattern: "bash"
  logic: or

tests:
  - id: no-hardcoded-secrets
    name: "No hardcoded secrets or API keys"
    description: "Ensure no hardcoded credentials in skill content"
    assertion:
      type: grep
      pattern: "api[_-]?key|secret|password|token"
      target: "$SKILL_MD"
    enabled: true

  - id: no-eval-patterns
    name: "No dangerous eval patterns"
    description: "Avoid eval() and similar dangerous patterns"
    assertion:
      type: grep
      pattern: "eval\\(|exec\\(|system\\("
      target: "$SKILL_MD"
    enabled: true

  - id: safe-command-syntax
    name: "Shell commands use proper quoting"
    description: "Validate shell examples use proper variable quoting"
    assertion:
      type: custom
      script: |
        # Count unquoted variables (simplified check)
        unquoted=$(grep -o '\$[A-Za-z_]' "$SKILL_MD" | wc -l)
        quoted=$(grep -o '\"\$[A-Za-z_]' "$SKILL_MD" | wc -l)
        [ "$quoted" -gt "$unquoted" ]
    enabled: true

  - id: documents-permissions
    name: "Permission model documented"
    description: "Skill should document required permissions"
    assertion:
      type: grep
      pattern: "allowed-tools|permissions|required"
      target: "$SKILL_MD"
    enabled: true
```

## Best Practices

1. **Meaningful IDs and names** - Use descriptive, lowercase IDs and human-readable names
2. **Clear detection** - Be explicit about which skills your suite targets
3. **One assertion per test** - Keep tests focused and independent
4. **Document complex assertions** - Use descriptions for custom scripts
5. **Test in isolation** - Suite should work on target skills, skip on others
6. **Reasonable patterns** - Avoid overly complex regex; use custom if needed
7. **Variable usage** - Always use `$SKILL_MD`, `$SKILL_PATH`, `$ORIGINAL_PATH` for portability

## Testing Your Suite

```bash
# Run your custom suite
ruby scripts/run-test-suite.rb skill-creator my-suite

# Run with report
ruby scripts/run-test-suite.rb skill-creator my-suite --report

# Test on different skill
ruby scripts/run-test-suite.rb plugin-creator my-suite
```

Check the output for:
- All tests running (not skipped)
- Clear pass/fail results
- Accurate detection logic
