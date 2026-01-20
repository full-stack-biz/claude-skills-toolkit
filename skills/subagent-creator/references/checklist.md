# Subagent Quality Checklist

Use this checklist when creating or validating subagents to ensure they meet best practices for reliability, security, and execution quality.

## Table of Contents

- [Configuration & Syntax (Phase 1)](#configuration--syntax-phase-1)
- [Delegation & Activation (Phase 2)](#delegation--activation-phase-2)
- [Prompt Quality & Clarity (Phase 3)](#prompt-quality--clarity-phase-3)
- [Tool Scoping (Phase 4)](#tool-scoping-phase-4)
- [Permission Modes (Phase 5)](#permission-modes-phase-5)
- [Hook Configuration (Phase 6)](#hook-configuration-phase-6)
- [Real-World Testing (Phase 7)](#real-world-testing-phase-7)
- [Team & Production Subagents](#team--production-subagents)
- [Security Checklist (Production)](#security-checklist-production)
- [Naming & Organization](#naming--organization)
- [Final Sign-Off](#final-sign-off)

## Configuration & Syntax (Phase 1)

### Required Fields
- [ ] `name` is present and valid (lowercase-hyphen, ≤64 chars)
- [ ] `description` is present (≤1024 chars)
- [ ] YAML frontmatter syntax is valid (--- delimiters, proper indentation)

### Optional Fields
- [ ] `model` field (if present) is valid: sonnet, opus, haiku, or inherit
- [ ] `tools` field (if present) uses exact tool names
- [ ] `disallowedTools` field (if present) is configured sensibly
- [ ] `permissionMode` (if present) is valid: default, acceptEdits, dontAsk, bypassPermissions, or plan
- [ ] `hooks` (if present) are valid YAML

### File Organization
- [ ] Frontmatter separated by `---` markers
- [ ] Body (system prompt) follows frontmatter
- [ ] Proper indentation in YAML
- [ ] No trailing whitespace or formatting issues

## Delegation & Activation (Phase 2)

### Description Quality
- [ ] Description includes specific trigger phrases (not vague language)
- [ ] Trigger phrases match real user requests (concrete examples)
- [ ] Description states what the subagent does (action)
- [ ] Description states when to use it (trigger contexts)
- [ ] Description states constraints/scope (what's NOT included)
- [ ] Description follows pattern: [Action]. Use when [triggers]. [Constraints].
- [ ] Description is ≤1024 chars

### Examples of Good Descriptions
```
"Execute read-only database queries to analyze data. Use when exploring table structure, generating reports, or analyzing patterns. SELECT only; write operations blocked."
```

Includes:
- Action: Execute queries
- Triggers: exploring structure, generating reports, analyzing patterns
- Constraints: SELECT only; writes blocked

### Examples of Poor Descriptions
```
"Database query subagent"
```

Missing:
- Specific triggers
- Action details
- Constraints

### Delegation Testing
- [ ] Description would trigger on realistic user requests (test with examples)
- [ ] Description includes 3+ specific trigger phrases
- [ ] Trigger phrases are concrete (actions, not vague intent)

## Prompt Quality & Clarity (Phase 3)

### Structure
- [ ] Prompt has clear purpose statement
- [ ] Prompt includes step-by-step instructions (procedural)
- [ ] Prompt includes 2+ concrete examples Claude can adapt
- [ ] Prompt addresses error cases (what if operation fails?)
- [ ] Prompt states constraints clearly
- [ ] Prompt is ≤2000 chars (not overwhelming)

### Code Examples
- [ ] Examples are runnable/adaptable by Claude
- [ ] Examples show expected output format
- [ ] Examples cover common use cases

Example (good):
```
When querying:
1. Identify relevant tables
2. Write SELECT query with filters
3. Execute and format results

Example:
SELECT user_id, COUNT(*) FROM users
WHERE created_at > '2025-01-01'
GROUP BY user_id;
```

### Error Handling
- [ ] Prompt explains what to do if operation is blocked
- [ ] Prompt explains what to do if tool fails
- [ ] Prompt recovers gracefully from permission denials
- [ ] Prompt doesn't assume operations will always succeed

### Clarity & Language
- [ ] Language is technical and precise (no ambiguity)
- [ ] No marketing/promotional language
- [ ] No unnecessary verbosity
- [ ] Instructions are actionable (Claude knows what to do)

## Tool Scoping (Phase 4)

### Principle of Least Privilege

Subagent Purpose | Should Have | Should NOT Have
---|---|---
Read-only analysis | Read, Grep, Glob | Write, Edit
Code review | Read, Grep, Glob, Bash(git) | Write, Edit (optional Bash)
Code fixes | Read, Write, Edit, Bash | (none)
Database analysis | Bash (validated) | Write, Edit
Data pipeline | Write, Bash | (depends)

### Tool Access Validation
- [ ] Tools are necessary for subagent's purpose
- [ ] Tools that aren't needed are removed/denied
- [ ] Tool names are exact (capitalized correctly)
- [ ] Write access only granted if needed for purpose
- [ ] Bash access only granted if needed

### Security Checks
- [ ] Read-only subagents don't have Write/Edit
- [ ] Analysis subagents don't have unnecessary Bash
- [ ] No tool given "just in case"
- [ ] If permissionMode = plan, writes are blocked anyway (redundant check)

## Permission Modes (Phase 5)

### Foreground vs Background
- [ ] For foreground use: mode = default or acceptEdits
- [ ] For background use: mode = dontAsk
- [ ] For read-only: mode = plan
- [ ] Mode matches intended execution context

### Permission Mode Matching
- [ ] Interactive editing: acceptEdits (auto-approve edits, prompt for others)
- [ ] Autonomous background: dontAsk (auto-deny prompts, tool access works)
- [ ] Research-only: plan (reads allowed, writes blocked)
- [ ] General trusted: default (user confirms each operation)

### Production Checks
- [ ] Production subagents use specific permission modes (not default)
- [ ] Subagents touching sensitive data use restricted modes
- [ ] Permission mode prevents dangerous auto-operations

## Hook Configuration (Phase 6)

### If Hooks are Present
- [ ] Hook YAML syntax is valid
- [ ] Hook `matcher` specifies a tool name (e.g., "Bash")
- [ ] Hook script path exists and is relative
- [ ] Hook script is executable (chmod +x)
- [ ] PreToolUse hooks validate before execution
- [ ] Exit codes are correct (0 = allow, 2 = block)
- [ ] Error messages are clear (sent to stderr)

### Example Hook Validation
```yaml
hooks:
  PreToolUse:
    - matcher: "Bash"
      hooks:
        - type: command
          command: "./scripts/validate-query.sh"
```

Script must:
- Read JSON from stdin
- Extract command from `tool_input.command`
- Exit 0 (allow) or 2 (block)
- Return error message on stderr if blocking

### Hook Testing
- [ ] Hook script runs without errors
- [ ] Script correctly allows legitimate operations
- [ ] Script correctly blocks forbidden operations
- [ ] Error messages are user-friendly

## Real-World Testing (Phase 7)

### Delegation Testing
- [ ] Create request matching subagent's purpose
- [ ] Verify Claude delegates to this subagent (not other subagents)
- [ ] Test with multiple realistic request phrasings
- [ ] Verify false positives don't trigger (wrong subagent)

### Execution Testing
- [ ] Subagent completes its task successfully
- [ ] Output is useful and properly formatted
- [ ] Tools work as expected (accepts/denies as configured)
- [ ] Permission modes work (prompts or auto-deny as configured)

### Error Case Testing
- [ ] What happens when operation is blocked? (graceful failure)
- [ ] What happens when tool fails? (Claude recovers)
- [ ] What happens with invalid input? (handled)
- [ ] What happens on permission denial? (doesn't crash)

### Integration Testing
- [ ] Works when run in foreground
- [ ] Works when run in background (if applicable)
- [ ] Can be resumed (if used multiple times)
- [ ] Doesn't interfere with main conversation

## Team & Production Subagents

### Additional Requirements
- [ ] Error handling is robust (try/except, clear messages)
- [ ] Tool scoping is minimal (principle of least privilege)
- [ ] Validation scripts (hooks) are tested
- [ ] Version field present (if team sharing): `version: 1.0.0`
- [ ] Permissions are well-defined (not default/permissive)
- [ ] Security review completed (permission modes, tool access)
- [ ] Clear documentation of purpose and constraints
- [ ] Tested with multiple Claude instances (if applicable)

### Documentation for Team Subagents
- [ ] README or comment explaining purpose
- [ ] Hook scripts documented (what they validate, exit codes)
- [ ] Trigger phrases clearly stated
- [ ] Permission mode rationale explained
- [ ] Version history tracked (if changes made)

## Security Checklist (Production)

- [ ] Subagent doesn't have unnecessary write access
- [ ] Read-only subagents are truly read-only (plan mode or hooks verify)
- [ ] Validation hooks prevent dangerous operations (e.g., SQL writes)
- [ ] Permission modes prevent unintended auto-operations
- [ ] Tool scoping follows principle of least privilege
- [ ] No credentials or secrets in prompt body
- [ ] No hardcoded paths that expose structure

## Naming & Organization

- [ ] Subagent name is descriptive (action + domain, e.g., db-analyzer)
- [ ] Subagent name uses hyphens (db-analyzer not db_analyzer)
- [ ] Subagent name is lowercase
- [ ] Subagent name is ≤64 chars
- [ ] File organized in appropriate scope (project/.claude/agents, user/~/.claude/agents, etc.)
- [ ] Hooks/scripts are in subdirectories (./scripts/)

## Final Sign-Off

Before deploying, verify:

- ✅ All Phase 1 items (configuration)
- ✅ All Phase 2 items (delegation)
- ✅ All Phase 3 items (prompt quality)
- ✅ All Phase 4 items (tool scoping)
- ✅ All Phase 5 items (permission modes)
- ✅ All Phase 6 items (hooks if present)
- ✅ All Phase 7 items (real-world testing)
- ✅ All relevant team/production items (if applicable)

Subagent is ready for deployment.
