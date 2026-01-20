# How Subagents Work

## Table of Contents

- [Architecture Overview](#architecture-overview)
- [Delegation Mechanism](#delegation-mechanism)
- [Configuration Scope](#configuration-scope)
- [Integration Patterns](#integration-patterns)
- [Token Loading Hierarchy](#token-loading-hierarchy)
- [Execution Model](#execution-model)
- [Common Patterns](#common-patterns)
- [Scope Storage & Priority](#scope-storage--priority)
- [Security Considerations](#security-considerations)
- [Delegation Reliability Factors](#delegation-reliability-factors)
- [Foreground vs Background Execution](#foreground-vs-background-execution)
- [Hooks: Lifecycle and Tool Validation](#hooks-lifecycle-and-tool-validation)
- [Subagent Resumption and Context Management](#subagent-resumption-and-context-management)
- [Built-In Subagents](#built-in-subagents)
- [Skills Field: Injecting Skill Context](#skills-field-injecting-skill-context)

## Architecture Overview

Subagents are isolated execution environments that Claude delegates to based on request context. Understanding the delegation and execution model is essential for creating reliable subagents.

## Delegation Mechanism

### How Claude Decides to Delegate

Claude evaluates incoming requests against subagent descriptions using natural language understanding:

1. **Request analysis**: Claude reads the user's request/task description
2. **Description matching**: Claude evaluates subagent descriptions against the request context
3. **Delegation decision**: If a subagent description matches the request, Claude delegates to that subagent
4. **Execution**: The subagent executes with its own configuration (prompt, tools, permissions)

**The description is the PRIMARY delegation signal.** Vague or generic descriptions don't trigger reliable delegation. Specific trigger phrases in the description dramatically improve delegation reliability.

### Description Formula

```
[Action]. Use when [trigger contexts/scenarios]. [Scope/constraints].
```

Example: "Execute read-only database queries. Use when analyzing data, generating reports, or exploring structure. SELECT only; write operations blocked."

This tells Claude:
- **When**: User asks to analyze data, generate reports, explore structure
- **What**: Execute database queries
- **Constraints**: Read-only (SELECT only)

### Avoiding Poor Delegation

❌ **Vague**: "Perform database operations"
- Too generic; Claude won't recognize when to use it

❌ **Missing context**: "Query database. Use when needed."
- "When needed" is too vague; no concrete trigger phrases

✅ **Specific**: "Execute read-only SQL queries to analyze data. Use when exploring database structure, generating reports, or analyzing data patterns. SELECT only."
- Includes concrete trigger phrases (explore structure, generate reports, analyze data)
- Includes constraints (SELECT only)
- Claude will recognize these phrases in requests

## Configuration Scope

### Subagent Configuration Fields

Subagents have independent configuration from the main conversation:

| Field | Purpose | Example |
|-------|---------|---------|
| `name` | Unique identifier | `db-analyzer` |
| `description` | Delegation trigger + scope | "Execute read-only queries. Use when analyzing data..." |
| `model` | AI model to use | `sonnet`, `opus`, `haiku`, `inherit` |
| `tools` | Tool access (allowlist) | `Bash, Read, Write` |
| `disallowedTools` | Tools to block (denylist) | `Edit, Bash` |
| `permissionMode` | Permission handling | `default`, `acceptEdits`, `dontAsk`, `plan` |
| `hooks` | Lifecycle validation | `PreToolUse`, `PostToolUse`, etc. |

### Model Selection

- **haiku**: Fast, cheap; good for isolated read-only tasks
- **sonnet**: Default; balanced capability/speed
- **opus**: Most capable; use for complex reasoning/analysis
- **inherit**: Use parent conversation's model (consistency)

Choose based on task complexity and latency requirements.

### Tool Access Control

**Allowlist** (specify which tools to allow):
```yaml
tools: Read, Grep, Glob
```
Subagent can ONLY use Read, Grep, Glob. All other tools denied.

**Denylist** (specify which tools to block):
```yaml
disallowedTools: Edit, Write, Bash
```
Subagent can use all tools EXCEPT Edit, Write, Bash.

**Inherit** (no specification):
```yaml
# No tools field = inherit all tools from parent
```

### Permission Modes

| Mode | Behavior | Use case |
|------|----------|----------|
| `default` | Standard permission checking; interactive prompts to user | User approval required |
| `acceptEdits` | Auto-accept file edits; prompt for other permissions | Trusted editing tasks |
| `dontAsk` | Auto-deny interactive prompts; explicit tool access still works | Background execution |
| `bypassPermissions` | Skip all permission checks | Trusted subagent with pre-approved access |
| `plan` | Read-only (blocks all write operations) | Research/analysis only |

## Integration Patterns

### Foreground vs Background Execution

**Foreground** (default):
- Blocks main conversation until subagent completes
- Permission prompts go to user
- User can see subagent output in real-time
- Use when: Task requires user interaction or validation

**Background** (user requests "run in background" or Ctrl+B):
- Runs concurrently with main conversation
- Auto-denies unpre-approved permissions (tool calls fail but subagent continues)
- Output returns to main conversation after completion
- Use when: Task is self-contained and won't need user input

### Context Flow

1. **User request** → Main conversation
2. **Delegation decision** → Claude evaluates against subagent descriptions
3. **Subagent created** → Fresh context with custom configuration
4. **Execution** → Subagent runs with its prompt, tools, and permissions
5. **Results** → Returned to main conversation (summary or full output)
6. **Continuation** → Main conversation can resume or ask for more work

### Resuming Subagents

Subagents retain full conversation history within their session:
- **Full context preserved**: All previous tool calls, results, and reasoning
- **Transcript storage**: Separate from main conversation (independent compaction)
- **Re-invocation**: Ask Claude to "continue that analysis" or "resume the subagent"

```
User: Use db-analyzer to query sales data
[Subagent completes initial analysis]

User: Continue that analysis and now look at geographic patterns
[Claude resumes subagent with full previous context]
```

## Token Loading Hierarchy

Subagents load configuration and prompts efficiently:

1. **Frontmatter only** (~100-200 tokens): Always loaded for delegation decisions
2. **System prompt** (~500-2000 tokens): Loaded when subagent is delegated to
3. **Scripts/references**: Loaded only if subagent needs them (on-demand)

This is efficient because descriptions (used for delegation) are small, while full prompts only load when needed.

## Execution Model

### Subagent Lifecycle

1. **Creation**: User request or Claude decides to delegate
2. **Configuration loading**: YAML frontmatter + system prompt loaded
3. **Tool setup**: Tool access configured based on `tools` and `permissionMode`
4. **Execution**: System prompt guides Claude's behavior within the subagent
5. **Completion**: Results returned to main conversation
6. **Cleanup**: Hooks with `Stop` event fire (if configured)

### Permission Handling

When a subagent attempts a tool call:

1. **Tool access check**: Is this tool in the allowlist/not in denylist?
   - ✅ If yes: Proceed
   - ❌ If no: Tool call fails

2. **Permission check** (if tool access OK):
   - `default`: Prompt user for permission
   - `acceptEdits`: Auto-approve (if Edit/Write); prompt for others
   - `dontAsk`: Auto-deny prompt, tool still callable
   - `bypassPermissions`: Skip check entirely
   - `plan`: Block write operations

3. **Hook validation** (if PreToolUse hook configured):
   - Hook script runs before tool execution
   - Can validate specific operations (e.g., SQL read-only)
   - Exit code 2 = block operation

## Common Patterns

### Read-Only Analysis Subagent
```yaml
tools: Read, Grep, Glob, Bash
permissionMode: plan
```
Claude can read and search; write operations blocked.

### Trusted Editor Subagent
```yaml
tools: Read, Edit, Write, Bash
permissionMode: acceptEdits
```
Claude can edit files; file edits auto-approved, other prompts shown to user.

### Background Research Subagent
```yaml
tools: Read, Grep, Glob
permissionMode: dontAsk
model: haiku
```
Fast, read-only, auto-denies prompts (good for background execution).

### Validated Query Subagent
```yaml
tools: Bash
hooks:
  PreToolUse:
    - matcher: "Bash"
      hooks:
        - type: command
          command: "./validate-query.sh"
```
Bash access allowed but validated by hook script (e.g., read-only SQL).

## Scope Storage & Priority

When multiple subagents have the same name, higher priority wins:

1. **Session** (`--agents` CLI flag): Current session only
2. **Project** (`.claude/agents/`): Current project
3. **User** (`~/.claude/agents/`): All projects on this machine
4. **Plugin** (`agents/` in plugin): Where plugin is installed

Choose scope based on sharing:
- **Project**: Subagent specific to this codebase (check into git)
- **User**: Personal subagent across all projects
- **Session**: Temporary or testing (not saved)

## Security Considerations

### Tool Scoping (Principle of Least Privilege)

Grant only necessary tools:
```yaml
# ✅ Good: Only what's needed
tools: Read, Grep

# ❌ Bad: Unnecessarily broad
tools: Read, Write, Edit, Bash, Glob, Grep
```

### Permission Modes

- **Production**: Use specific permission modes (dontAsk, acceptEdits)
- **Untrusted input**: Use plan mode or hook validation
- **High-risk operations**: Use PreToolUse hooks to validate

### Hook Validation

Hooks enable conditional validation:
```bash
# Block SQL write operations
if echo "$COMMAND" | grep -iE 'INSERT|UPDATE|DELETE|DROP'; then
  exit 2  # Block operation
fi
```

## Delegation Reliability Factors

### Factors that IMPROVE delegation:
- ✅ Specific trigger phrases in description
- ✅ Clear scope/constraints stated
- ✅ Concrete examples ("when analyzing data", "when generating reports")
- ✅ Short, focused descriptions

### Factors that HURT delegation:
- ❌ Vague descriptions ("perform operations")
- ❌ Missing context ("use when needed")
- ❌ Generic scope
- ❌ No trigger phrases

Example comparison:

**Poor** (vague):
> "Execute database commands. Use for database work."

**Good** (specific):
> "Execute read-only database queries to analyze data. Use when exploring tables, generating reports, or analyzing patterns. SELECT only; writes blocked."

The good version includes:
- Specific action (read-only queries)
- Concrete trigger phrases (exploring, generating reports, analyzing)
- Constraints (SELECT only)

## Foreground vs Background Execution

Subagents can run in the foreground (blocking) or background (concurrent). Understanding the differences is critical for choosing the right execution mode.

### Foreground Execution (Default/Interactive)

**Characteristics:**
- Blocks main conversation until subagent completes
- Full permission prompt interaction
- User sees output in real-time
- Subagent can ask user questions (AskUserQuestion tool)
- MCP tools available
- Latency: Waiting for subagent completion

**When to use:**
- Task requires user approval
- Subagent needs to interact with user
- You want to watch subagent work in real-time
- Task is high-priority and you're waiting anyway
- Subagent needs to ask clarifying questions

**Permission mode behavior in foreground:**
- `default`: Shows permission prompts to user
- `acceptEdits`: Auto-accepts edits; prompts for others
- `dontAsk`: No prompts; operations work if allowed
- `bypassPermissions`: No prompts; all allowed
- `plan`: Read-only; writes blocked

**Example:**
```
User: Use code-reviewer to check my changes
[Foreground - blocks main conversation]
Subagent: Analyzes code, may ask for clarification
[Output shown as it runs]
User: [Waits for completion]
[Results returned]
```

### Background Execution (Concurrent)

**Characteristics:**
- Runs concurrent with main conversation
- Auto-denies unpre-approved permission prompts
- No user interaction (questions fail)
- User can continue working while subagent runs
- MCP tools NOT available (can't require user interaction)
- Subagent continues even if tool calls are denied
- Results returned after completion

**How to trigger:**
- Ask Claude: "Run this in the background"
- Press Ctrl+B while subagent is running
- Claude may choose background automatically for suitable tasks

**When to use:**
- Task is self-contained (no user input needed)
- You want to continue main conversation
- Task produces verbose output (keep separate)
- Running parallel research
- Cost-sensitive (no waiting for user)

**Permission mode behavior in background:**
- `default`: ❌ Auto-denies all permissions (fails fast)
- `acceptEdits`: ✅ Approves edits; denies others
- `dontAsk`: ✅ Works without prompts; denials fail fast
- `bypassPermissions`: ✅ All allowed
- `plan`: ✅ Read-only; writes denied

**Example:**
```
User: Analyze the API module in the background
[Background - returns immediately]
User: [Can continue working]
[Subagent analyzes API in parallel]
User: [Later] Show me the API analysis results
[Results displayed]
```

### Permission Denial Behavior in Background

When a background subagent hits a denied permission:
- Tool call fails with a clear error message
- Subagent receives the failure
- Subagent CONTINUES (doesn't crash)
- Subagent handles denial gracefully

**Example:**
```
Background subagent tries to run Bash with default mode
→ Permission auto-denied (no prompt shown)
→ Tool call fails
→ Subagent receives failure notification
→ Subagent continues with other work
→ Subagent reports what it completed and what was blocked
```

### Choosing Between Foreground and Background

| Factor | Foreground | Background |
|--------|-----------|-----------|
| User interaction needed | ✅ Yes | ❌ No |
| Quick feedback needed | ✅ Yes | ❌ Time-delayed |
| Want to watch execution | ✅ Yes | ❌ No |
| Main conversation interrupted | ✅ Yes | ❌ No |
| MCP tools needed | ✅ Available | ❌ Not available |
| Verbose output OK in main context | ✅ Yes | ❌ No |
| Permission mode options | All | Restricted |

## Hooks: Lifecycle and Tool Validation

Hooks enable conditional validation and lifecycle management of subagents. Hooks run at specific events during subagent execution.

### Subagent-Level Hooks (in frontmatter)

These hooks run WITHIN the subagent's execution context. Only valid in subagent's frontmatter.

#### PreToolUse Hook

**When:** Runs BEFORE the subagent uses a tool
**Use case:** Validate or block specific operations

```yaml
hooks:
  PreToolUse:
    - matcher: "Bash"
      hooks:
        - type: command
          command: "./validate-sql-readonly.sh"
```

**Hook input (via stdin):**
```json
{
  "tool": "Bash",
  "tool_input": {
    "command": "SELECT * FROM users WHERE id > 100"
  }
}
```

**Hook exit codes:**
- `0` - Allow operation (proceed)
- `2` - Block operation (deny)
- Other - Error (fail tool execution)

**Example: Block SQL write operations**
```bash
#!/bin/bash

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

if echo "$COMMAND" | grep -iE '(INSERT|UPDATE|DELETE)'; then
  echo "Blocked: Read-only mode" >&2
  exit 2
fi

exit 0
```

#### PostToolUse Hook

**When:** Runs AFTER the subagent uses a tool
**Use case:** Run linters, formatters, or verification

```yaml
hooks:
  PostToolUse:
    - matcher: "Edit|Write"
      hooks:
        - type: command
          command: "./scripts/run-linter.sh"
```

**Use case: Lint after edits**
```bash
#!/bin/bash

# Run linter on modified files
eslint --fix src/**/*.js

if [ $? -ne 0 ]; then
  exit 1
fi

exit 0
```

#### Stop Hook

**When:** Runs when subagent finishes execution
**Use case:** Cleanup resources, close connections

```yaml
hooks:
  Stop:
    - type: command
      command: "./scripts/cleanup.sh"
```

### Project-Level Hooks (in settings.json)

These hooks run IN THE MAIN SESSION in response to subagent lifecycle events. Configure in `.claude/settings.json` or `~/.claude/settings.json`.

#### SubagentStart Hook

**When:** When a subagent starts execution
**Use case:** Setup resources, start monitoring

```json
{
  "hooks": {
    "SubagentStart": [
      {
        "matcher": "db-agent",
        "hooks": [
          { "type": "command", "command": "./setup-db-connection.sh" }
        ]
      }
    ]
  }
}
```

#### SubagentStop Hook

**When:** When a subagent completes
**Use case:** Cleanup resources, log results

```json
{
  "hooks": {
    "SubagentStop": [
      {
        "matcher": "db-agent",
        "hooks": [
          { "type": "command", "command": "./cleanup-db.sh" }
        ]
      }
    ]
  }
}
```

### Hook Matcher Syntax

**Single tool:**
```yaml
matcher: "Bash"
matcher: "Edit"
```

**Multiple tools:**
```yaml
matcher: "Edit|Write"
matcher: "Bash|Grep|Glob"
```

**Multiple matchers in one hook:**
```yaml
- matcher: "Edit"
  hooks: [...]
- matcher: "Write"
  hooks: [...]
```

## Subagent Resumption and Context Management

Subagents retain full conversation history and can be resumed to continue previous work.

### How Resumption Works

Each subagent invocation creates a separate execution context with:
- Independent token limit (~100k tokens by default)
- Separate transcript file (stored in `~/.claude/projects/{project}/{sessionId}/subagents/`)
- Full conversation history within that session

**Key property:** When you resume a subagent, it picks up exactly where it left off with full context.

```
User: Use db-analyzer to analyze sales data
[Subagent execution 1]
[Returns initial analysis]

User: Continue that analysis and look at regional patterns
[Subagent resumed with full previous context]
[Continues from previous state]
```

### How to Resume Subagents

**Explicit resumption:**
```
User: Use db-analyzer to analyze sales data
[Subagent ID: agent-abc123 completes]

User: Continue that analysis
[Claude resumes agent-abc123]
```

**With specific agent ID:**
```
User: Continue that analysis (agent-abc123)
[Claude resumes specific agent]
```

**Finding agent IDs:**
- Claude returns agent ID when subagent completes
- Stored in transcript files: `~/.claude/projects/{project}/{sessionId}/subagents/agent-{agentId}.jsonl`
- View in transcript summary

### Transcript Persistence

**Independent storage:**
- Main conversation compaction doesn't affect subagent transcripts
- Subagent transcripts stored separately from main conversation
- Persist within their session

**Automatic cleanup:**
- Transcripts cleaned up based on `cleanupPeriodDays` setting (default: 30 days)
- Can manually delete transcript files if needed

**Auto-compaction:**
- Subagents support automatic compaction (~95% capacity)
- Override with `CLAUDE_AUTOCOMPACT_PCT_OVERRIDE` environment variable
- Compaction events logged in transcript: `"type": "system", "subtype": "compact_boundary"`

## Built-In Subagents

Claude Code includes built-in subagents available by default. Understand when to use each vs creating custom subagents.

### Explore (Fast Read-Only Agent)

**Characteristics:**
- Model: Haiku (fast)
- Tools: Read, Grep, Glob (read-only)
- Purpose: Fast codebase exploration
- Throughness levels: quick, medium, very thorough

**When to use:**
- Need fast file discovery/search
- Don't need to make changes
- Want to keep exploration results separate from main context
- Searching large codebases

**When NOT to use:**
- Need to modify files
- Need real-time output visibility
- Task requires iterative refinement

### Plan (Research Agent)

**Characteristics:**
- Model: Inherits from main conversation
- Tools: Read-only (denied: Write, Edit)
- Purpose: Gather context during plan mode
- Used automatically in plan mode

**When to use:**
- Running in plan mode (design before implementation)
- Researching codebase without making changes
- Separating research from implementation

**When NOT to use:**
- Already have required context
- Need to make changes
- Task is implementation-focused

### General-Purpose (Full-Capability Agent)

**Characteristics:**
- Model: Inherits from main conversation
- Tools: All tools available
- Purpose: Complex multi-step tasks with exploration and action

**When to use:**
- Task requires both exploration and modification
- Complex reasoning needed
- Multi-step workflows

**When NOT to use:**
- Simple read-only analysis (use Explore)
- Need fast execution (Haiku models faster)
- Want to isolate research (use Plan)

### Custom vs Built-In

**Use built-in when:**
- Task matches their purpose exactly
- Don't need customization
- Default configuration works

**Create custom when:**
- Need specific tool restrictions
- Require custom system prompt
- Need special permission modes
- Want hook validation
- Need background-friendly setup

## Skills Field: Injecting Skill Context

The `skills` field loads skill content into the subagent's context at startup.

### Difference: skills field vs Task tool

**`skills` field** (in frontmatter):
- Skill content injected into subagent's context
- Available for direct reference in prompt
- Increases subagent context token usage
- No separate invocation needed

**`Task` tool** (in subagent):
- Launches a separate subagent
- Independent execution context
- Subagent can invoke other specialized agents
- Useful for complex multi-step workflows

### When to Use skills Field

**Use when:**
- Subagent needs specific reusable instructions
- Want instructions available without invoking
- Instructions should be in main prompt context

**Example:**
```yaml
---
name: code-fixer
description: Fix bugs in code
tools: Read, Write, Edit, Bash
skills: code-quality-standards, security-best-practices
---

You have access to code quality and security standards. Follow these
standards when fixing code.
```

**Result:**
- Skill content injected into subagent prompt
- Subagent can reference standards directly
- Standards available throughout execution

### Format

```yaml
skills: skill-name-1, skill-name-2, skill-name-3
```

**Important:**
- Subagents don't inherit skills from parent
- Must explicitly list all skills needed
- Full skill content is loaded (increases token usage)
- Spaces after commas are OK

### Example with Multiple Skills

```yaml
---
name: security-analyst
description: Analyze code for security vulnerabilities
tools: Read, Grep, Glob
permissionMode: plan
skills: security-checklist, owasp-top-10, secure-coding-standards
---

You are a security analyst with access to security standards and checklists.
Evaluate code against these standards...
```
