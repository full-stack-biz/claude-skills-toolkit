# Permission Modes: Control Subagent Permissions

Permission modes control how subagents handle permission prompts when performing actions that require user approval. This reference explains each mode, how they behave in foreground/background execution, and when to use each.

## Table of Contents

- [Permission Modes Overview](#permission-modes-overview)
- [Detailed Mode Behaviors](#detailed-mode-behaviors)
- [Foreground vs Background Execution](#foreground-vs-background-execution)
- [Decision Matrix: Choosing Permission Modes](#decision-matrix-choosing-permission-modes)
- [Real-World Examples](#real-world-examples)
- [Key Principles](#key-principles)
- [Troubleshooting Permission Issues](#troubleshooting-permission-issues)
- [Next Steps](#next-steps)

## Permission Modes Overview

| Mode | Interactive Prompts | File Edits | Other Actions | Foreground | Background |
|------|-------------------|-----------|---------------|-----------|-----------|
| `default` | ✅ Show to user | Ask user | Ask user | Interactive | Auto-deny |
| `acceptEdits` | ✅ (except edits) | Auto-accept | Ask user | Edits auto-approved | Auto-deny others |
| `dontAsk` | ❌ Auto-deny | Auto-deny | Works w/o prompts | Prompts skipped | Prompts skipped |
| `bypassPermissions` | ❌ Skipped | Auto-allow | All allowed | No permission checks | No checks |
| `plan` | ❌ Blocked | ❌ Blocked | Read-only works | Read-only | Read-only |

## Detailed Mode Behaviors

### `default` (Standard Permission Checking)

**Permission handling:**
- Permission prompts are shown to user for ALL operations
- User must explicitly approve each permission
- Subagent waits for user response

**Foreground behavior:**
- Interactive: User sees each permission prompt
- User can approve or deny
- Subagent responds to user's choice

**Background behavior:**
- Auto-denies all permission prompts (fails fast)
- Tool calls that require permissions fail
- Subagent continues (doesn't crash on failure)
- To run background tasks, use `dontAsk` or `acceptEdits` instead

**When to use:**
- Subagents that need user approval for actions
- Tasks where user should validate each step
- Development/testing (watch what subagent does)

**Example:**

Foreground:
```
User: Use db-analyzer to update this data
Subagent attempts: Bash (UPDATE query)
Prompt: "Allow Bash tool use?" → User approves
Subagent: Continues
```

Background (with `default`):
```
User: Use db-analyzer in background to update data
Subagent attempts: Bash (UPDATE query)
Result: Permission denied (auto-fail in background)
Subagent: Continues with other work
```

### `acceptEdits` (Auto-Accept File Edits)

**Permission handling:**
- File edits (Edit, Write tools) are auto-accepted
- Other permissions are shown to user
- Only shows prompts for non-edit operations

**Foreground behavior:**
- File edits auto-approved (no prompts)
- Other actions (Bash, etc.) show permission prompts
- Useful for code-fixing subagents

**Background behavior:**
- File edits auto-approved
- Other permissions auto-denied
- Subagent can edit files; can't run dangerous Bash commands

**When to use:**
- Code fixing/modification subagents
- Safe file editing (trusted subagent)
- Background code modifications

**Example (code-fixer subagent):**

Foreground:
```
User: Use code-fixer to fix the bug
Subagent: Edits file → Auto-approved (no prompt)
Subagent: Runs tests (Bash) → Permission prompt shown
User: Approves test run
Subagent: Continues
```

Background:
```
User: Use code-fixer in background to fix bugs
Subagent: Edits file → Auto-approved
Subagent: Runs tests (Bash) → Auto-denied
Subagent: Works around it, continues with editing
```

### `dontAsk` (Auto-Deny Interactive Prompts)

**Permission handling:**
- Interactive permission prompts are auto-denied
- Tool access is NOT denied (tool is still callable)
- Operations work if they don't require a prompt

**Key distinction:** Tool access ≠ permission prompt
- If tool is in `tools` list, it's accessible
- But if operation requires user permission prompt, it auto-denies that prompt
- Some operations work silently; others require permissions

**Foreground behavior:**
- No permission prompts shown
- Tool calls work if they don't require approval
- Certain operations fail silently (when permission was needed)

**Background behavior:**
- Perfect for background execution
- No user interaction needed
- Tool calls work, permission denials fail fast
- Subagent continues (doesn't crash)

**When to use:**
- Background research/analysis
- Trusted subagents (pre-approved for tool access)
- Foreground tasks that should never prompt
- Cost-sensitive operations (no waiting for user)

**Example (background researcher):**

```
User: Run db-analyzer in background to analyze sales data
[Background]
Subagent: Reads files → Works (no permission needed)
Subagent: Runs Bash query → Works (Bash in tools list)
Subagent: Tries to modify data → Auto-denied
Subagent: Completes analysis anyway
[Results returned to main conversation]
```

### `bypassPermissions` (Skip All Permission Checks)

**Permission handling:**
- All permission checks are bypassed
- All operations allowed (no prompts, no denials)
- Complete trust in subagent behavior

**Foreground behavior:**
- No prompts shown
- All operations allowed
- Subagent has full freedom

**Background behavior:**
- No prompts shown
- All operations allowed
- Subagent has full freedom

**Important:** Parent permission context takes precedence
- If parent uses `bypassPermissions`, child cannot override to more restrictive
- Child can only be more permissive
- Parent is the security boundary

**When to use:**
- Production subagents (fully tested, trusted)
- Automated systems (no user interaction possible)
- High-trust environments
- Subagents with full control over their domain

**⚠️ Security considerations:**
- Most permissive mode
- Use only for well-tested subagents
- Verify tool scoping is still restrictive (use `tools` allowlist)
- Document why bypass is needed

**Example:**

```yaml
---
name: deploy-automation
description: Deploy application to production
tools: Bash                          # Still restricted to Bash
permissionMode: bypassPermissions
---
```

Even with `bypassPermissions`, this subagent can ONLY use Bash (other tools blocked).

### `plan` (Read-Only Mode)

**Permission handling:**
- All write operations are blocked
- Read-only operations allowed
- Useful for research/analysis without modification

**Blocked operations:**
- Write files
- Edit files
- Bash commands that modify files
- Any destructive operation

**Allowed operations:**
- Read files
- Search files (Grep, Glob)
- Query databases (SELECT)
- Analyze data

**Foreground behavior:**
- Read operations work silently
- Write attempts show permission prompts (denying the operation)
- Subagent handles denials gracefully

**Background behavior:**
- Read operations work
- Write attempts auto-denied (fail fast)
- Subagent continues without interaction

**When to use:**
- Research and analysis
- Code review (no fixes, just analysis)
- Data analysis (no modifications)
- Safe exploration of codebase
- Read-only reports

**Example (code-reviewer):**

```yaml
---
name: code-reviewer
description: Review code for quality and security
tools: Read, Grep, Glob, Bash
permissionMode: plan
---
```

Reviewer can:
- Read files
- Search code
- Analyze patterns
- Generate reports

Reviewer cannot:
- Edit files
- Write new files
- Run destructive bash commands

## Foreground vs Background Execution

The same `permissionMode` behaves differently in foreground vs background:

### Foreground Execution (default/interactive)

**Characteristics:**
- Blocks main conversation
- User sees output in real-time
- Permission prompts go to user
- User can approve/deny each action

**Permission modes in foreground:**

| Mode | Behavior |
|------|----------|
| `default` | Shows permission prompts to user |
| `acceptEdits` | Auto-accepts edits; prompts for others |
| `dontAsk` | No prompts; operations work if allowed |
| `bypassPermissions` | No prompts; all operations allowed |
| `plan` | Read-only; write attempts shown as denied |

**Use foreground when:**
- Task needs user approval
- You want to watch subagent work
- Task needs interaction
- Debugging/testing

### Background Execution (concurrent)

**Characteristics:**
- Runs concurrent with main conversation
- User doesn't see prompts
- Pre-approved permissions work
- Denied permissions cause tool calls to fail (subagent continues)
- Output returns after completion

**How to run in background:**
- Ask Claude: "Run this in the background"
- Press Ctrl+B while subagent is running

**Permission modes in background:**

| Mode | Behavior |
|------|----------|
| `default` | ❌ Auto-denies all permissions (fails fast) |
| `acceptEdits` | ✅ File edits auto-approved; others denied |
| `dontAsk` | ✅ Works without prompts; denials fail fast |
| `bypassPermissions` | ✅ All operations allowed |
| `plan` | ✅ Read-only; writes denied |

**Important:** MCP tools are NOT available in background subagents.

**Use background when:**
- Task is self-contained (no user interaction needed)
- You want to continue main conversation
- Task produces verbose output (keep out of main context)
- Running parallel research

**Example:**

```
User: Analyze the API module in parallel using a subagent
[Subagent launches in background]
User: [Can continue main conversation while subagent works]
[Subagent completes and returns results]
```

## Decision Matrix: Choosing Permission Modes

### For Foreground Subagents

**Interactive user approval needed?**
```
YES → default (user sees prompts)
NO → dontAsk or acceptEdits or bypassPermissions
```

**File editing is primary task?**
```
YES → acceptEdits (auto-approve edits)
NO → other modes
```

**Read-only analysis only?**
```
YES → plan (blocks writes)
NO → other modes
```

### For Background Subagents

**Can this run without user interaction?**
```
NO → Use foreground instead
YES → Continue...
```

**File editing needed?**
```
YES → acceptEdits (auto-approve, others denied)
NO → dontAsk or plan (no interaction needed)
```

**Should modify any files?**
```
YES → acceptEdits
NO → plan or dontAsk
```

### Practical Selection Guide

| Scenario | Mode | Foreground | Background |
|----------|------|-----------|-----------|
| Code reviewer (read-only) | `plan` | ✅ | ✅ |
| Code fixer (edits files) | `acceptEdits` | ✅ | ✅ |
| Data analyzer (read-only) | `plan` or `dontAsk` | ✅ | ✅ |
| Interactive tool (needs approval) | `default` | ✅ | ❌ |
| Automated deployment | `bypassPermissions` | ✅ | ✅ |
| Safe background researcher | `dontAsk` | ✅ | ✅ |

## Real-World Examples

### Example 1: Code Reviewer (Read-Only)

**Requirement:** Review code without modifying anything

```yaml
---
name: code-reviewer
description: Review code for quality and security
tools: Read, Grep, Glob, Bash
permissionMode: plan
model: sonnet
---
```

**Behavior:**
- Foreground: User sees analysis, no prompts for writes (blocked)
- Background: Analyzes code silently, can't modify anything

### Example 2: Code Fixer (File Editing)

**Requirement:** Fix bugs and automatically approve edits

```yaml
---
name: code-fixer
description: Fix bugs and implement features
tools: Read, Edit, Write, Bash
permissionMode: acceptEdits
model: sonnet
---
```

**Behavior:**
- Foreground: File edits auto-approved; prompts for Bash commands
- Background: File edits auto-approved; Bash commands denied

### Example 3: Database Analyst (Background)

**Requirement:** Analyze data in background without interrupting main conversation

```yaml
---
name: db-analyzer
description: Execute read-only queries to analyze data
tools: Bash, Read
permissionMode: dontAsk
model: haiku
---
```

**Behavior:**
- Foreground: No prompts; reads and queries work
- Background: Perfect for parallel analysis (no interaction needed)

### Example 4: Automated Deployment (High Trust)

**Requirement:** Deploy application with full permissions

```yaml
---
name: deploy-automation
description: Deploy application to production
tools: Bash                        # Still restricted to Bash
permissionMode: bypassPermissions  # Trust this subagent completely
model: sonnet
---
```

**Behavior:**
- All Bash operations allowed without prompts
- Still only has access to Bash (other tools blocked)
- Use only with thoroughly tested subagents

## Key Principles

1. **Principle of Least Privilege**: Even with permissive permission modes, restrict tool access using the `tools` field
2. **Default is Restrictive**: If unsure, use `plan` or `dontAsk` (more restrictive)
3. **Background ≠ Interactive**: Use `acceptEdits` or `dontAsk` for background tasks, NOT `default`
4. **Read-Only First**: Start with `plan`, add write permissions only if needed
5. **Permission Mode ≠ Tool Access**: `permissionMode` controls prompts; `tools` field controls access

## Troubleshooting Permission Issues

### Foreground subagent keeps prompting

**Problem:** Too many permission prompts in foreground

**Solution:** If prompts are expected, that's correct. If not:
- Change `permissionMode` to `dontAsk` if user approval isn't needed
- Change `permissionMode` to `acceptEdits` if only edits should auto-approve
- Verify task doesn't need operations that require prompts

### Background subagent fails silently

**Problem:** Background subagent fails when it hits denied permission

**Solution:** Expected behavior with `default` permission mode

**Fix:**
- Use `permissionMode: acceptEdits` for file edits
- Use `permissionMode: dontAsk` for read-only tasks
- Use `permissionMode: plan` for analysis-only tasks

### Operations don't work even though tool is listed

**Problem:** Tool is in `tools` list but operations fail

**Possible causes:**
- Permission prompt was denied (in foreground with `default` mode)
- Tool is in `disallowedTools` (denylist overrides)
- Parent conversation denied permission
- Background subagent with `default` permission mode

**Solution:** Verify correct `permissionMode` for use case

## Next Steps

- **Tool access patterns:** See `tool-scoping.md`
- **Hook-based validation:** See `advanced-patterns.md`
- **Complete configuration reference:** See `configuration-reference.md`
- **Validation workflow:** See `validation-workflow.md`
