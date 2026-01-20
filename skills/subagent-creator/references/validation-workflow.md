# Subagent Validation Workflow

Follow this 7-phase workflow to validate subagents systematically. Use this for both new and existing subagents.

## Table of Contents

- [Phase 1: Configuration Validation](#phase-1-configuration-validation)
- [Phase 2: Delegation Signal Validation](#phase-2-delegation-signal-validation)
- [Phase 3: Prompt Quality Validation](#phase-3-prompt-quality-validation)
- [Phase 4: Tool Scoping Validation](#phase-4-tool-scoping-validation)
- [Phase 5: Permission Mode Validation](#phase-5-permission-mode-validation)
- [Phase 6: Hook Configuration Validation](#phase-6-hook-configuration-validation)
- [Phase 7: Real-World Testing](#phase-7-real-world-testing)
- [Validation Sign-Off](#validation-sign-off)
- [When to Re-Validate](#when-to-re-validate)

## Phase 1: Configuration Validation

Check that the subagent file is correctly formatted and has all required fields.

### Checklist

- [ ] File is Markdown with YAML frontmatter (`---` delimiters)
- [ ] `name` is present, lowercase-hyphen, ≤64 chars
- [ ] `description` is present, ≤1024 chars
- [ ] `model` field valid: `sonnet`, `opus`, `haiku`, or `inherit`
- [ ] `tools` field (if present) uses valid tool names
- [ ] `disallowedTools` field (if present) uses valid tool names
- [ ] `permissionMode` (if present): `default`, `acceptEdits`, `dontAsk`, `bypassPermissions`, or `plan`
- [ ] YAML syntax is valid (proper indentation, no typos)
- [ ] File location is correct (`.claude/agents/`, `~/.claude/agents/`, or plugin `agents/`)

### Common Configuration Errors

| Error | Fix |
|-------|-----|
| Tool name misspelled (e.g., "Write" vs "write") | Use exact tool names: Read, Write, Edit, Bash, Glob, Grep |
| Invalid permission mode | Use: default, acceptEdits, dontAsk, bypassPermissions, plan |
| Conflicting tools and disallowedTools | tools is allowlist; disallowedTools is denylist; don't use both unless intentional |
| Missing description | Description is required for delegation |
| Description too vague | Add specific trigger phrases |

### How to Fix

1. Open the subagent file
2. Correct any YAML syntax errors
3. Verify all field values are valid
4. Test with: `claude` (run CLI and verify subagent loads without errors)

## Phase 2: Delegation Signal Validation

Check that the description will reliably trigger delegation when Claude sees user requests.

### Description Clarity Checklist

- [ ] Description includes specific trigger phrases Claude will see in requests
- [ ] Trigger phrases are concrete ("analyzing data", "generating reports") not vague ("when needed")
- [ ] Scope/constraints are stated clearly
- [ ] Description follows formula: [Action]. Use when [triggers]. [Constraints].
- [ ] Description length ≤1024 chars (reasonable for evaluation)
- [ ] No marketing language; clear, technical language

### Real-World Testing

Test delegation with realistic requests:

```
User request: "Analyze the user_activity table and generate a report"
Subagent description: "Execute read-only database queries. Use when analyzing data, generating reports, or exploring structure. SELECT only."
Expected: ✅ Claude recognizes "analyzing data" and "generating reports" → delegates
```

```
User request: "Help me with the database"
Subagent description: "Execute database commands. Use for database work."
Expected: ❌ Claude sees vague trigger ("for database work") → may not delegate
```

### How to Fix Poor Delegation

1. Rewrite description with specific trigger phrases from your use cases
2. Include action + context + constraints
3. Ask: "What words would a user type when they want this subagent to run?"
4. Add those words to the description

Example:
```
# Before (vague)
Description: "Database operations subagent"

# After (specific)
Description: "Execute read-only SQL queries for data analysis. Use when exploring database structure, analyzing tables, or generating reports. SELECT only; write operations blocked."
```

## Phase 3: Prompt Quality Validation

Check that the system prompt (markdown body) is clear and will guide Claude effectively.

### Prompt Checklist

- [ ] Purpose is clear: What is this subagent supposed to do?
- [ ] Instructions are procedural (steps Claude will follow)
- [ ] Prompt includes examples Claude can adapt
- [ ] Error cases are handled (what if operation fails?)
- [ ] Constraints are clear (what operations are blocked?)
- [ ] Language is technical and precise (no ambiguity)
- [ ] Prompt length is reasonable (not overwhelming for Claude)

### Code Examples in Prompts

Good example (Claude can adapt):
```
When executing queries:
1. Identify the relevant tables
2. Write efficient SELECT queries with appropriate filters
3. Execute and present results clearly

Example query:
SELECT user_id, COUNT(*) as activity_count
FROM user_activity
WHERE date > '2025-01-01'
GROUP BY user_id
ORDER BY activity_count DESC;
```

Poor example (too vague):
```
"Execute database queries efficiently"
```

### How to Fix Weak Prompts

1. Add concrete examples Claude can follow
2. Break instructions into procedural steps
3. Include error handling guidance
4. Clarify constraints explicitly

## Phase 4: Tool Scoping Validation

Check that tool access matches the subagent's purpose (principle of least privilege).

### Tool Access Checklist

- [ ] Subagent has only tools it needs
- [ ] Write-heavy subagents: Have Write, Edit, Bash?
- [ ] Read-only subagents: Denied Write, Edit unless necessary?
- [ ] Foreground subagents: Tool set reasonable for interactive use?
- [ ] Background subagents: Tool set reasonable for autonomous work?
- [ ] Tool names are exact (Read not read, Bash not bash)

### Tool Matching Table

| Subagent Purpose | Required Tools | Should Deny |
|------------------|----------------|------------|
| Read-only analysis | Read, Grep, Glob | Write, Edit, Bash |
| Code review | Read, Grep, Glob, Bash (git) | Write, Edit |
| Code fixes | Read, Write, Edit, Bash | - |
| Database queries | Bash (only) | Write, Edit |

### How to Fix Over-Scoped Tools

1. Identify what the subagent actually needs
2. Remove unnecessary tools
3. Use disallowedTools if you want to inherit some but block others

Example:
```yaml
# Before: Too much access
tools: Read, Write, Edit, Bash, Glob, Grep

# After: Only what's needed for read-only analysis
tools: Read, Grep, Glob
```

## Phase 5: Permission Mode Validation

Check that the permission mode matches how the subagent will be used.

### Permission Mode Checklist

- [ ] Subagent will run in foreground: mode = default or acceptEdits?
- [ ] Subagent will run in background: mode = dontAsk (auto-deny prompts)?
- [ ] File editing subagent: mode = acceptEdits?
- [ ] Research-only subagent: mode = plan?
- [ ] Permission mode matches tool access

### Use Case Matching

| Use Case | Permission Mode | Why |
|----------|-----------------|-----|
| Interactive code review | default | User should approve each suggestion |
| Auto-fixing code | acceptEdits | File edits trusted; prompt for others |
| Background research | dontAsk | Auto-deny prompts; auto-approve tool access |
| Read-only analysis | plan | Block all writes; read-only operations |

### How to Fix Mismatched Permission Modes

1. Determine how the subagent will be used (foreground/background)
2. Determine what permissions are safe to auto-approve
3. Select appropriate mode

Example:
```yaml
# Before: Read-only task but default mode (will prompt user)
tools: Read, Glob
permissionMode: default

# After: Appropriate for read-only background work
tools: Read, Glob
permissionMode: plan
```

## Phase 6: Hook Configuration Validation

Check hooks (if present) for correct syntax and validation logic.

### Hook Checklist

- [ ] Hook syntax is valid YAML
- [ ] `matcher` field specifies tool name (e.g., "Bash")
- [ ] Hook script path is relative and exists
- [ ] Hook script is executable (chmod +x)
- [ ] PreToolUse hook logic is correct (validates before execution)
- [ ] Exit codes understood: 0 = allow, 2 = block

### Example Hook Validation

```yaml
# Hook configuration
hooks:
  PreToolUse:
    - matcher: "Bash"
      hooks:
        - type: command
          command: "./scripts/validate-readonly.sh"
```

Validation script (`./scripts/validate-readonly.sh`):
```bash
#!/bin/bash
INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

# Block write operations
if echo "$COMMAND" | grep -iE 'INSERT|UPDATE|DELETE|DROP|CREATE|ALTER'; then
  echo "Blocked: Only SELECT allowed" >&2
  exit 2
fi
exit 0
```

### How to Fix Hook Issues

1. Verify script path is correct
2. Test script independently: `echo '{"tool_input":{"command":"SELECT"}}' | ./script.sh`
3. Verify exit codes (0 = allow, 2 = block)
4. Check script is executable

## Phase 7: Real-World Testing

Test the subagent with realistic scenarios to verify it works end-to-end.

### Test Scenarios

Create test cases that match the subagent's purpose:

**For analysis subagents:**
```
Scenario: User asks "Analyze the Q4 sales data and identify trends"
Expected: Subagent delegates, executes analysis, returns results
Test: Does delegation happen? Does execution complete? Is output useful?
```

**For code review subagents:**
```
Scenario: User asks "Review my authentication changes for security issues"
Expected: Subagent delegates, reads code, provides feedback
Test: Does it delegate? Does it find real issues? Is feedback actionable?
```

**For background processing:**
```
Scenario: User runs subagent in background with "run in background"
Expected: Task completes concurrently; main conversation continues
Test: Does it run concurrently? Do permission denials fail gracefully? Does output return?
```

### Test Checklist

- [ ] Delegation: Does Claude recognize when to delegate to this subagent?
- [ ] Execution: Does the subagent complete its task successfully?
- [ ] Output: Is output useful and formatted appropriately?
- [ ] Error handling: Do failures fail gracefully (not crash)?
- [ ] Tools: Are tools working as expected (accepted/denied appropriately)?
- [ ] Permissions: Are permission modes working (prompts/auto-deny as configured)?

### How to Debug Failed Tests

1. **Delegation not happening**: Rewrite description with specific trigger phrases
2. **Execution failing**: Check system prompt clarity; verify tool access
3. **Permission denied**: Check tool access, permission mode, hook logic
4. **Output confusing**: Revise prompt to guide clearer output format

## Validation Sign-Off

A subagent is ready for deployment when:

✅ Phase 1: Configuration valid (YAML syntax, required fields)
✅ Phase 2: Delegation reliable (description has trigger phrases)
✅ Phase 3: Prompt clear (Claude can execute from instructions)
✅ Phase 4: Tool access minimal (principle of least privilege)
✅ Phase 5: Permission mode appropriate (matches use case)
✅ Phase 6: Hooks correct (if present; syntax and logic valid)
✅ Phase 7: Real-world testing passes (works with realistic requests)

## When to Re-Validate

Re-run this workflow if you:
- Change the description (impacts delegation)
- Add/remove tools (impacts security/execution)
- Change permission mode (impacts permissions)
- Add/modify hooks (impacts validation)
- Encounter bugs or unexpected behavior
