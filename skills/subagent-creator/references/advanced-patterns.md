# Advanced Patterns: Production Subagents

Advanced patterns and techniques for production subagents, including hook validation, lifecycle management, subagent chaining, background execution, and error handling.

## Table of Contents

- [Hook Validation Patterns](#hook-validation-patterns)
- [Subagent Chaining](#subagent-chaining)
- [Background Execution Patterns](#background-execution-patterns)
- [Lifecycle Management Patterns](#lifecycle-management-patterns)
- [Error Handling Patterns](#error-handling-patterns)
- [Production Hardening Checklist](#production-hardening-checklist)

## Hook Validation Patterns

### Pattern 1: SQL Read-Only Validation

**Requirement:** Allow Bash for database queries, but block write operations

**Implementation:**

```yaml
---
name: db-analyzer
description: Analyze data with read-only SQL queries
tools: Bash, Read
hooks:
  PreToolUse:
    - matcher: "Bash"
      hooks:
        - type: command
          command: "./scripts/validate-sql-readonly.sh"
---

You are a database analyst. Execute SELECT queries only.
```

**Validation script** (`./scripts/validate-sql-readonly.sh`):

```bash
#!/bin/bash
set -e

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

# Extract just the SQL command (remove quotes, pipes, etc.)
SQL=$(echo "$COMMAND" | sed "s/^.*'\([^']*\)'.*$/\1/")

# Check for write operations (case-insensitive)
if echo "$SQL" | grep -iE '(INSERT|UPDATE|DELETE|DROP|CREATE|ALTER|TRUNCATE|GRANT|REVOKE)' > /dev/null; then
  echo "Security: Write operations not allowed. Use SELECT only." >&2
  exit 2
fi

# Check for dangerous PRAGMA statements
if echo "$SQL" | grep -iE 'PRAGMA' > /dev/null; then
  echo "Security: PRAGMA statements not allowed." >&2
  exit 2
fi

# Allow SELECT queries
exit 0
```

### Pattern 2: File Path Validation

**Requirement:** Allow file editing but only in specific directories

**Implementation:**

```yaml
---
name: code-fixer
description: Fix bugs in source code
tools: Read, Write, Edit, Bash
permissionMode: acceptEdits
hooks:
  PreToolUse:
    - matcher: "Edit|Write"
      hooks:
        - type: command
          command: "./scripts/validate-file-path.sh"
---
```

**Validation script** (`./scripts/validate-file-path.sh`):

```bash
#!/bin/bash

INPUT=$(cat)
FILE=$(echo "$INPUT" | jq -r '.tool_input.file_path // .tool_input.filename // empty')

# Only allow src/ and tests/ directories
ALLOWED_DIRS=("src/" "tests/" "lib/")
ALLOWED=0

for dir in "${ALLOWED_DIRS[@]}"; do
  if [[ "$FILE" =~ ^$dir ]]; then
    ALLOWED=1
    break
  fi
done

if [ $ALLOWED -eq 0 ]; then
  echo "Security: Can only modify files in src/, tests/, lib/" >&2
  exit 2
fi

exit 0
```

### Pattern 3: Command Rate Limiting

**Requirement:** Prevent runaway bash commands with rate limiting

**Implementation:**

```yaml
hooks:
  PreToolUse:
    - matcher: "Bash"
      hooks:
        - type: command
          command: "./scripts/rate-limit.sh"
```

**Rate limiting script** (`./scripts/rate-limit.sh`):

```bash
#!/bin/bash

RATE_LIMIT_FILE="/tmp/subagent-rate-limit-$RANDOM"
MAX_COMMANDS_PER_MIN=10
TIME_WINDOW=60

# Initialize or read count
if [ ! -f "$RATE_LIMIT_FILE" ]; then
  echo "1" > "$RATE_LIMIT_FILE"
  touch -t "$(date +%Y%m%d%H%M.%S)" "$RATE_LIMIT_FILE"
  exit 0
fi

# Check file age
FILE_TIME=$(stat -f%m "$RATE_LIMIT_FILE" 2>/dev/null || stat -c%Y "$RATE_LIMIT_FILE")
CURRENT_TIME=$(date +%s)
AGE=$((CURRENT_TIME - FILE_TIME))

if [ $AGE -gt $TIME_WINDOW ]; then
  # Reset counter after time window
  echo "1" > "$RATE_LIMIT_FILE"
  exit 0
fi

# Increment counter
COUNT=$(cat "$RATE_LIMIT_FILE")
COUNT=$((COUNT + 1))

if [ $COUNT -gt $MAX_COMMANDS_PER_MIN ]; then
  echo "Rate limit exceeded: $MAX_COMMANDS_PER_MIN commands per minute" >&2
  exit 2
fi

echo "$COUNT" > "$RATE_LIMIT_FILE"
exit 0
```

### Pattern 4: Multi-Stage Validation

**Requirement:** Validate database queries with multiple security checks

**Implementation:**

```bash
#!/bin/bash

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

# Stage 1: Check for dangerous keywords
if echo "$COMMAND" | grep -iE '(DROP DATABASE|TRUNCATE TABLE|DELETE FROM)' > /dev/null; then
  echo "Validation: Dangerous operations not allowed" >&2
  exit 2
fi

# Stage 2: Check for SQL injection patterns
if echo "$COMMAND" | grep -E "[-;][ ]*--" > /dev/null; then
  echo "Validation: SQL injection patterns detected" >&2
  exit 2
fi

# Stage 3: Check for system command execution
if echo "$COMMAND" | grep -iE "(xp_cmdshell|exec|system_execute)" > /dev/null; then
  echo "Validation: System execution not allowed" >&2
  exit 2
fi

# All checks passed
exit 0
```

## Subagent Chaining

**Pattern:** One subagent delegates to others for specialized tasks.

### Sequential Chain (One After Another)

**Scenario:** Code reviewer finds issues, then code fixer fixes them

```
User Request
    ↓
[1] code-reviewer (analyze code)
    ↓ (returns findings)
[2] code-fixer (fix issues found)
    ↓ (returns fixed code)
Done
```

**Prompt guidance for reviewer:**

```markdown
---
name: code-reviewer
description: Review code and identify issues
tools: Read, Grep, Glob
---

When you identify issues, report them clearly:
1. List specific issues found
2. For each issue, provide:
   - Location (file:line)
   - Issue description
   - Suggested fix

After review, the fixer subagent will use this analysis to make corrections.
```

**Prompt guidance for fixer:**

```markdown
---
name: code-fixer
description: Fix code issues identified by reviewer
tools: Read, Write, Edit, Bash
permissionMode: acceptEdits
---

When invoked with code review findings:
1. Read the identified issues
2. Implement fixes in order
3. Run tests to verify
4. Report what was fixed
```

### Parallel Chain (Multiple Subagents at Once)

**Scenario:** Analyze multiple modules in parallel

```
User Request
    ↓
┌─────────────┬──────────────┬─────────────┐
│  analyzer-1 │  analyzer-2  │ analyzer-3  │
│  (module A) │  (module B)  │ (module C)  │
└─────────────┴──────────────┴─────────────┘
    ↓              ↓               ↓
[Synthesize results]
    ↓
Done
```

**Prompt for parallel researchers:**

```markdown
You are part of a parallel analysis team. Each team member researches
one aspect independently, then the main conversation synthesizes findings.

Your specific focus: [specific module/aspect]

Complete your analysis and return findings. Do not coordinate with other
subagents—they work in parallel.
```

## Background Execution Patterns

### Pattern 1: Long-Running Analysis in Background

**Scenario:** Analyze large codebase while user continues working

```yaml
---
name: background-analyzer
description: Analyze codebase in background
tools: Read, Grep, Glob
permissionMode: dontAsk
model: haiku
---

You are a background analysis agent. Generate comprehensive analysis
without needing user interaction. Report findings clearly at the end.

Your task:
1. [Step 1]
2. [Step 2]
3. [Step 3]

Return: Summary of findings
```

**Usage:**
```
User: Analyze the architecture in the background
[Subagent launches in background]
User: [Can continue working]
[Subagent completes and returns findings]
```

### Pattern 2: Bulk Processing in Background

**Scenario:** Process many files automatically

```yaml
---
name: bulk-processor
description: Process files in bulk in background
tools: Read, Write, Bash
permissionMode: acceptEdits
model: haiku
---

Process files automatically without user interaction:

1. Find all files matching pattern
2. Process each file
3. Save results

When edits are blocked due to background restrictions, skip that file
and continue with others.
```

## Lifecycle Management Patterns

### Pattern 1: Setup and Cleanup

**Requirement:** Initialize database connection at start, cleanup at end

```yaml
---
name: db-worker
description: Execute database operations
tools: Bash, Read
hooks:
  PreToolUse:
    - matcher: "Bash"
      hooks:
        - type: command
          command: "./scripts/setup-db-connection.sh"
  Stop:
    - type: command
      command: "./scripts/cleanup-db.sh"
---

You have database access. Execute queries and return results.
```

**Setup script** (`./scripts/setup-db-connection.sh`):

```bash
#!/bin/bash

# Initialize connection (run once at start)
if [ -z "$DB_INITIALIZED" ]; then
  export DB_INITIALIZED=1

  # Load credentials
  source ~/.db-credentials

  # Test connection
  mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASS" -e "SELECT 1" > /dev/null

  if [ $? -ne 0 ]; then
    echo "Database connection failed" >&2
    exit 1
  fi
fi

exit 0
```

**Cleanup script** (`./scripts/cleanup-db.sh`):

```bash
#!/bin/bash

# Close any open connections
mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASS" -e "SELECT 1" 2>/dev/null

# Clear temporary files
rm -f /tmp/db-query-*.sql

# Log completion
echo "$(date): Database cleanup completed" >> logs/db-access.log

exit 0
```

### Pattern 2: Logging and Audit Trail

**Requirement:** Log all operations for compliance

```yaml
hooks:
  PreToolUse:
    - matcher: "Bash|Edit|Write"
      hooks:
        - type: command
          command: "./scripts/audit-log.sh"
```

**Audit script** (`./scripts/audit-log.sh`):

```bash
#!/bin/bash

INPUT=$(cat)
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
TOOL=$(echo "$INPUT" | jq -r '.tool')
OPERATION=$(echo "$INPUT" | jq -r '.tool_input.command // .tool_input.file_path // "unknown"' | head -c 200)
USER=${LOGNAME:-unknown}
SESSION_ID=${SUBAGENT_SESSION:-unknown}

# Format: timestamp | tool | operation | user | session
LOG_ENTRY="$TIMESTAMP | $TOOL | $OPERATION | $USER | $SESSION_ID"

# Append to audit log
echo "$LOG_ENTRY" >> /var/log/subagent-audit.log

# Also log critical operations
if [[ "$TOOL" == "Bash" ]]; then
  echo "$LOG_ENTRY" >> /var/log/subagent-bash-audit.log
fi

exit 0
```

## Error Handling Patterns

### Pattern 1: Graceful Degradation

**Scenario:** Try operation; if blocked, use alternative approach

```markdown
---
name: flexible-worker
description: Complete tasks with flexible approaches
tools: Read, Write, Edit, Bash
permissionMode: acceptEdits
---

You can edit files or run Bash commands. If either is blocked:
1. Try the other approach
2. If both blocked, use Read-only analysis
3. Always report what you completed and what was blocked

Example: If can't run tests (Bash blocked), verify changes by reading
the code and checking test files manually.
```

### Pattern 2: Permission-Aware Prompting

**Scenario:** Inform subagent about permission restrictions

```markdown
---
name: permission-aware-worker
description: Work within permission constraints
tools: Read, Write, Edit, Bash
permissionMode: dontAsk
---

You have permission-aware access. Some operations may be auto-denied
in background execution:

✅ What works:
- Read files
- Write new files
- Edit existing files
- Run Bash commands (in foreground)

❌ What may fail (and is OK):
- Bash in background (don't rely on it)
- Interactive prompts (won't show)

Strategy: Design your approach to work with read/write even if Bash fails.
```

## Production Hardening Checklist

When preparing subagents for production:

### Security

- [ ] Tool scoping: Only granted necessary tools
- [ ] Hook validation: All dangerous tools (Bash, Write, Edit) have PreToolUse validation
- [ ] Permission mode: Appropriate for use case (don't use `bypassPermissions` lightly)
- [ ] File paths: Validated with hooks if Write/Edit allowed
- [ ] Commands: Validated with hooks if Bash allowed
- [ ] Secrets: No credentials in prompts or default values

### Reliability

- [ ] Error handling: Prompt handles failures gracefully
- [ ] Permission awareness: Prompt acknowledges permission mode limits
- [ ] Timeout handling: Long operations won't timeout (documented in prompt)
- [ ] Retry logic: Prompt can retry failed operations
- [ ] Logging: All critical operations logged (see Pattern 2 above)

### Operability

- [ ] Description: Specific trigger phrases for reliable delegation
- [ ] Documentation: Clear prompt explaining capabilities and limitations
- [ ] Monitoring: Hooks log operations for audit trail
- [ ] Lifecycle: Setup and cleanup hooks if needed
- [ ] Version tracking: Version field in frontmatter updated with releases

### Testing

- [ ] Foreground execution: Tested in interactive mode
- [ ] Background execution: Tested in concurrent mode
- [ ] Permission modes: Tested with actual permission constraints
- [ ] Hook scripts: All hooks tested independently
- [ ] Edge cases: Tested with unusual inputs
- [ ] Failure modes: Tested when operations are blocked

### Example Production Subagent

```yaml
---
name: production-analyzer
description: >-
  Analyze code structure and performance. Use when understanding
  architecture, identifying bottlenecks, or profiling. Read-only analysis.
version: 1.0.0
model: sonnet
tools: Read, Grep, Glob, Bash
permissionMode: plan
hooks:
  PreToolUse:
    - matcher: "Bash"
      hooks:
        - type: command
          command: "./scripts/validate-readonly-bash.sh"
  PostToolUse:
    - matcher: "Bash"
      hooks:
        - type: command
          command: "./scripts/log-bash-operation.sh"
---

# Production Code Analyzer

You analyze code for architecture, performance, and structure.

## Capabilities

✅ Read any file
✅ Search for patterns
✅ Run read-only analysis commands (validated)
✅ Generate detailed reports

## Limitations

❌ Cannot modify files (read-only mode)
❌ Cannot run write operations
❌ Cannot execute dangerous commands (validated by hook)

## Workflow

When analyzing code:

1. **Map Structure**: Understand module organization
2. **Identify Patterns**: Find recurring patterns or issues
3. **Analyze Dependencies**: Trace module dependencies
4. **Profile Performance**: Identify bottlenecks (if data available)
5. **Report Findings**: Provide clear, actionable analysis

## Examples

When asked: "Analyze the authentication system"
- Read relevant source files
- Search for auth-related patterns
- Trace auth flow through codebase
- Report architecture, potential issues, suggested improvements

When asked: "Find performance bottlenecks"
- Run profiling commands (if available)
- Analyze algorithms and data structures
- Identify N+1 queries, inefficient patterns
- Report findings with specific examples

## Error Handling

If any operation is denied:
- Acknowledge the limitation
- Continue analysis with alternative approach
- Report what was and wasn't analyzed
```

## Common Pitfalls and Solutions

### Pitfall 1: Overly Permissive Configuration

**Problem:** Granting all tools to subagent that only needs a few

```yaml
# ❌ Bad: Too permissive
tools: Read, Write, Edit, Bash, Grep, Glob, Task
```

**Solution:** Apply principle of least privilege

```yaml
# ✅ Good: Only needed tools
tools: Read, Grep, Glob
```

### Pitfall 2: Insufficient Hook Validation

**Problem:** Allowing Bash without validation

```yaml
# ❌ Bad: Dangerous
tools: Bash
permissionMode: bypassPermissions
# No hook validation
```

**Solution:** Add validation hooks

```yaml
# ✅ Good: Validated access
tools: Bash
hooks:
  PreToolUse:
    - matcher: "Bash"
      hooks:
        - type: command
          command: "./validate.sh"
```

### Pitfall 3: Wrong Permission Mode for Background

**Problem:** Using `default` for background execution

```yaml
# ❌ Bad: Will auto-deny in background
permissionMode: default
```

**Solution:** Use appropriate mode for background

```yaml
# ✅ Good: Works in background
permissionMode: dontAsk    # or acceptEdits
```

### Pitfall 4: Vague Error Handling

**Problem:** Prompt doesn't explain permission constraints

```markdown
# ❌ Bad: No acknowledgment of constraints
Execute all queries as needed.
```

**Solution:** Document permission mode in prompt

```markdown
# ✅ Good: Clear constraints
This subagent can read and search files. Write operations are blocked
(read-only mode). If you need to modify files, use a different subagent.
```

## Next Steps

- **Configuration details:** See `configuration-reference.md`
- **Permission modes:** See `permission-modes.md`
- **Tool scoping:** See `tool-scoping.md`
- **Real examples:** See `templates.md`
- **Validation:** See `validation-workflow.md`
