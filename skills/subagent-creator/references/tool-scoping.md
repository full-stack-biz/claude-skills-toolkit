# Tool Scoping: Apply Principle of Least Privilege

Tool scoping controls which tools a subagent can access. This reference explains tool access patterns, how to apply the principle of least privilege, and when to use hook-based validation for conditional access.

## Table of Contents

- [Principle of Least Privilege](#principle-of-least-privilege)
- [Tool Access Methods](#tool-access-methods)
- [Tool Categories & Common Patterns](#tool-categories--common-patterns)
- [Common Tool Scope Patterns](#common-tool-scope-patterns)
- [Tool-Specific Security Concerns](#tool-specific-security-concerns)
- [Hook-Based Validation](#hook-based-validation)
- [Advanced Patterns](#advanced-patterns)
- [Configuration Checklist](#configuration-checklist)
- [Troubleshooting Tool Access](#troubleshooting-tool-access)
- [Next Steps](#next-steps)

## Principle of Least Privilege

**Core principle:** Grant only the minimum tools needed for the subagent's task.

**Benefits:**
- Security: Fewer tools = less damage if subagent behaves unexpectedly
- Focus: Subagent can't be distracted by unavailable tools
- Cost: Fewer tool calls available
- Clarity: Explicit about what subagent is supposed to do

**Rules:**
1. Start with the smallest tool set possible
2. Add tools only if the task requires them
3. Use hook-based validation for conditional access (e.g., read-only SQL)
4. Never grant tools "just in case"

## Tool Access Methods

### Allowlist (Specify Which Tools to Allow)

**Method:** Use the `tools` field to list permitted tools.

```yaml
tools: Read, Grep, Glob
```

Subagent can ONLY use Read, Grep, Glob. All other tools denied.

**When to use:**
- Know exactly which tools are needed
- Want explicit allowlist (recommended)
- Most restrictive (most secure)

**Example (code analyzer):**
```yaml
---
name: code-analyzer
description: Analyze code for patterns
tools: Read, Grep, Glob          # Only analysis tools
---
```

### Denylist (Specify Which Tools to Block)

**Method:** Use `disallowedTools` to block specific tools.

```yaml
disallowedTools: Write, Edit, Bash
```

Subagent inherits all tools except Write, Edit, Bash.

**When to use:**
- Want most tools but must block specific dangerous ones
- Less secure than allowlist
- Good for "safe by default" scenarios

**Example (safe researcher):**
```yaml
---
name: safe-researcher
description: Research without modifying anything
disallowedTools: Write, Edit, Bash    # Deny modifications
---
```

### No Specification (Inherit All)

**Method:** Omit both `tools` and `disallowedTools`.

```yaml
# No tools field = inherit all tools
```

Subagent inherits all tools from parent conversation.

**When to use:**
- Subagent needs all available tools
- Risk of being too permissive (not recommended)

**Example (rare case):**
```yaml
---
name: full-power-agent
description: Do anything needed
# Inherits all tools
---
```

## Tool Categories & Common Patterns

### Read-Only Analysis Tools

**Available tools:**
- `Read` - Read file contents
- `Grep` - Search file contents
- `Glob` - Find files by pattern
- `Bash` - Execute commands (read-only operations)

**Useful for:**
- Code analysis
- Data research
- File exploration
- Pattern finding

**Example configuration:**
```yaml
---
name: code-analyzer
description: Analyze code structure and patterns
tools: Read, Grep, Glob
permissionMode: plan
---
```

### File Modification Tools

**Available tools:**
- `Read` - Read files (prerequisite)
- `Write` - Create new files
- `Edit` - Modify existing files
- `Bash` - Execute commands (may modify)

**Useful for:**
- Code fixing
- File generation
- Refactoring
- Content creation

**Example configuration:**
```yaml
---
name: code-fixer
description: Fix bugs and refactor code
tools: Read, Write, Edit, Bash
permissionMode: acceptEdits
---
```

### Execution & System Tools

**Available tools:**
- `Bash` - Execute shell commands
- `Read` - Read output/results
- `Grep`/`Glob` - Find relevant files

**Useful for:**
- Running tests
- Executing scripts
- Database queries
- Build operations

**Example configuration:**
```yaml
---
name: test-runner
description: Run tests and report results
tools: Bash, Read, Grep, Glob
permissionMode: dontAsk
---
```

### Research & Exploration

**Available tools:**
- `Read` - Read documentation/code
- `Grep` - Search for specific patterns
- `Glob` - Find files
- `Bash` - Run queries/scripts
- `Task` - Delegate to other subagents

**Useful for:**
- Codebase exploration
- Architecture analysis
- Documentation research
- Dependency analysis

**Example configuration:**
```yaml
---
name: architecture-researcher
description: Analyze architecture and dependencies
tools: Read, Grep, Glob, Bash, Task
permissionMode: plan
---
```

## Common Tool Scope Patterns

### Pattern 1: Read-Only Analyzer

**Purpose:** Analyze code/data without modification

```yaml
---
name: analyzer
description: Analyze code and generate reports
tools: Read, Grep, Glob
permissionMode: plan
---
```

**Can do:**
- Read any file
- Search across files
- Find patterns
- Generate analysis reports

**Cannot do:**
- Modify files
- Execute commands
- Create files

### Pattern 2: Safe Editor (Foreground)

**Purpose:** Edit files with user approval

```yaml
---
name: editor
description: Edit and refactor code
tools: Read, Write, Edit, Bash
permissionMode: default
---
```

**Can do:**
- Read files (required for editing)
- Modify files (with user approval)
- Create new files (with user approval)
- Run verification commands (with user approval)

**Cannot do:**
- Any dangerous operation without approval

### Pattern 3: Trusted Editor (Background)

**Purpose:** Edit files automatically in background

```yaml
---
name: trusted-editor
description: Auto-fix issues and refactor code
tools: Read, Write, Edit, Bash
permissionMode: acceptEdits
---
```

**Can do:**
- Read files
- Modify files (auto-approved)
- Create files (auto-approved)
- Run verification (denied in background)

**Cannot do:**
- Run arbitrary Bash (denied in background)

### Pattern 4: Database Analyst

**Purpose:** Query database safely (read-only)

```yaml
---
name: db-analyst
description: Analyze data with read-only queries
tools: Bash, Read
hooks:
  PreToolUse:
    - matcher: "Bash"
      hooks:
        - type: command
          command: "./scripts/validate-readonly-query.sh"
---
```

**Can do:**
- Run Bash commands (validated by hook)
- Read files (documentation, saved queries)
- Execute SELECT queries (hook allows)

**Cannot do:**
- Run INSERT/UPDATE/DELETE (hook blocks)
- Modify database schema

### Pattern 5: Research Assistant

**Purpose:** Explore codebase in background

```yaml
---
name: researcher
description: Research codebase architecture and patterns
tools: Read, Grep, Glob
permissionMode: dontAsk
model: haiku
---
```

**Can do:**
- Read any file
- Search patterns
- Find specific code
- Explore architecture

**Cannot do:**
- Any interactive prompts (auto-denied)
- Modify anything
- Execute arbitrary commands

## Tool-Specific Security Concerns

### `Bash` Tool

**Risk:** Can execute arbitrary commands

**Mitigation strategies:**
1. **Don't include** if not needed
2. **Validate with hooks** if needed (see "Hook-Based Validation" section)
3. **Use `permissionMode: plan`** to restrict to read-only Bash
4. **Document why** Bash access is needed

**Risky use:**
```yaml
# ❌ Allows any Bash command
tools: Bash
permissionMode: bypassPermissions
```

**Safer use:**
```yaml
# ✅ Validates Bash commands with hook
tools: Bash
hooks:
  PreToolUse:
    - matcher: "Bash"
      hooks:
        - type: command
          command: "./validate.sh"
```

### `Write`/`Edit` Tools

**Risk:** Can create or modify any file

**Mitigation strategies:**
1. **Use `permissionMode: acceptEdits`** for automatic approval
2. **Use `permissionMode: default`** for user approval
3. **Document file modification scope** in prompt
4. **Use hooks** to validate file paths (advanced)

**Example (safe file editing):**
```yaml
---
name: code-fixer
description: Fix bugs in code
tools: Read, Write, Edit, Bash
permissionMode: acceptEdits    # Trust file edits
---
```

### `Task` Tool

**Risk:** Can launch other subagents

**Mitigation strategies:**
1. **Include only if delegation needed**
2. **Document which subagents** can be launched
3. **Ensure launched subagents are trusted**

**Example (controlled delegation):**
```yaml
---
name: coordinator
description: Coordinate analysis across modules
tools: Read, Grep, Glob, Task  # Can delegate research
---
```

## Hook-Based Validation

### What Are Hooks?

Hooks enable conditional validation of tool use. A hook script runs BEFORE or AFTER tool execution and can block operations based on custom logic.

**Example use case:** Allow Bash tool, but only for SELECT queries (not writes).

### PreToolUse Hooks (Validate Before Execution)

**When:** Runs BEFORE tool executes
**Use case:** Block dangerous operations before they happen

**Example: Validate read-only SQL queries**

```yaml
tools: Bash
hooks:
  PreToolUse:
    - matcher: "Bash"
      hooks:
        - type: command
          command: "./scripts/validate-readonly-query.sh"
```

**Validation script** (`./scripts/validate-readonly-query.sh`):
```bash
#!/bin/bash

# Read hook input from stdin
INPUT=$(cat)

# Extract the Bash command from input
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

# Block SQL write operations (case-insensitive)
if echo "$COMMAND" | grep -iE '\b(INSERT|UPDATE|DELETE|DROP|CREATE|ALTER|TRUNCATE)\b' > /dev/null; then
  echo "Error: Only SELECT queries are allowed" >&2
  exit 2  # Exit code 2 = block operation
fi

# Allow the operation
exit 0
```

**Exit codes:**
- `0` - Allow operation (proceed)
- `2` - Block operation (deny)
- Other - Error (fail tool execution)

### PostToolUse Hooks (Validate After Execution)

**When:** Runs AFTER tool executes
**Use case:** Run linters, formatters, verification after edits

**Example: Run linter after file edits**

```yaml
tools: Read, Write, Edit
hooks:
  PostToolUse:
    - matcher: "Edit"
      hooks:
        - type: command
          command: "./scripts/run-linter.sh"
```

**Linter script** (`./scripts/run-linter.sh`):
```bash
#!/bin/bash

# Run linter on modified files
eslint --fix src/**/*.js

if [ $? -ne 0 ]; then
  echo "Linting failed" >&2
  exit 1
fi

exit 0
```

### Stop Hooks (Cleanup on Completion)

**When:** Runs when subagent finishes
**Use case:** Cleanup resources, close connections

**Example: Close database connection**

```yaml
hooks:
  Stop:
    - type: command
      command: "./scripts/cleanup-db.sh"
```

## Advanced Patterns

### Pattern: Validate Specific Operations Only

**Scenario:** Allow most Bash commands, but block specific dangerous operations

```yaml
---
name: safe-executor
description: Execute safe operations
tools: Bash, Read
hooks:
  PreToolUse:
    - matcher: "Bash"
      hooks:
        - type: command
          command: "./scripts/block-dangerous.sh"
---
```

**Validation script:**
```bash
#!/bin/bash

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

# Block dangerous patterns
DANGEROUS_PATTERNS=(
  "rm -rf"           # Recursive delete
  "chmod 777"        # World-readable permissions
  "> /dev/null"      # Silent output (suspicious)
  "sudo "            # Privilege escalation
)

for pattern in "${DANGEROUS_PATTERNS[@]}"; do
  if [[ "$COMMAND" =~ $pattern ]]; then
    echo "Error: Blocked command pattern: $pattern" >&2
    exit 2
  fi
done

exit 0
```

### Pattern: Log All Operations

**Scenario:** Audit all tool use for compliance

```yaml
hooks:
  PreToolUse:
    - matcher: "Bash|Edit|Write"
      hooks:
        - type: command
          command: "./scripts/audit-log.sh"
```

**Audit script:**
```bash
#!/bin/bash

INPUT=$(cat)
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
TOOL=$(echo "$INPUT" | jq -r '.tool // unknown')
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // .tool_input.content // "unknown"' | head -c 100)

echo "$TIMESTAMP | $TOOL | $COMMAND" >> /var/log/subagent-audit.log

exit 0
```

## Configuration Checklist

When configuring tool scoping:

- [ ] Identified all tools the subagent actually needs
- [ ] Starting point is most restrictive (allowlist > denylist > inherit)
- [ ] Documented why each tool is included
- [ ] Verified `tools` list uses exact tool names (case-sensitive)
- [ ] If using Bash, considered hook validation
- [ ] If using Edit/Write, set appropriate `permissionMode`
- [ ] Tested that subagent can perform required tasks
- [ ] Tested that subagent cannot perform forbidden tasks

## Troubleshooting Tool Access

### "Tool not found" error

**Cause:** Tool name is misspelled or case-wrong

**Fix:** Use exact tool names:
- Read (not read, READ)
- Write (not write, WRITE)
- Edit (not edit, EDIT)
- Bash (not bash, BASH)
- Grep (not grep, GREP)
- Glob (not glob, GLOB)
- Task (not task, TASK)
- Skill (not skill, SKILL)
- AskUserQuestion (exact case)

### Tool access denied but tool is in list

**Causes:**
1. Tool name case is wrong
2. `disallowedTools` blocks it
3. `permissionMode` restricts it
4. Hook validation blocked it

**Debug steps:**
1. Check tool name case matches exactly
2. Verify `disallowedTools` doesn't include it
3. Check if operation requires permission (permission mode may deny)
4. If using hooks, check hook script logic

### Hook validation blocking expected operations

**Cause:** Hook script logic is too strict

**Fix:**
1. Review hook script pattern matching
2. Test script with actual command
3. Adjust patterns to be more specific
4. Add logging to debug

```bash
# Add logging to hook script
echo "DEBUG: Validating command: $COMMAND" >&2

# Test output
./validate.sh <<< '{"tool": "Bash", "tool_input": {"command": "SELECT * FROM users"}}'
```

## Next Steps

- **Permission modes:** See `permission-modes.md`
- **Advanced hooks:** See `advanced-patterns.md`
- **Complete configuration:** See `configuration-reference.md`
- **Real examples:** See `templates.md`
