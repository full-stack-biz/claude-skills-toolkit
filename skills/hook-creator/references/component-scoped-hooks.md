# Component-Scoped Hooks

Define hooks directly in skill and agent frontmatter for automatic execution when component is active.

## Table of Contents

- [Overview](#overview)
- [Skill Frontmatter Hooks](#skill-frontmatter-hooks)
  - [Example: Format on Write Skill](#example-format-on-write-skill)
- [Agent Frontmatter Hooks](#agent-frontmatter-hooks)
  - [Example: Validation Agent](#example-validation-agent)
- [The "once" Option](#the-once-option)
  - [Example: Initialize Once](#example-initialize-once)
- [Environment Variables Available](#environment-variables-available)
  - [CLAUDE_CODE_REMOTE Example](#claude_code_remote-example)
- [Execution Scoping](#execution-scoping)
- [Combining Component & Global Hooks](#combining-component--global-hooks)
- [Practical Examples](#practical-examples)
  - [Example 1: Format Skill with Once Initialization](#example-1-format-skill-with-once-initialization)
  - [Example 2: Testing Agent](#example-2-testing-agent)
  - [Example 3: Security Checker (Remote-Aware)](#example-3-security-checker-remote-aware)
- [Debugging Component Hooks](#debugging-component-hooks)
- [Limitations](#limitations)

---

## Overview

Instead of registering hooks globally in settings files or plugins, component-scoped hooks execute only when:
- A skill is triggered
- An agent is running
- The component finishes executing (cleanup)

## Skill Frontmatter Hooks

Hooks in a skill's SKILL.md frontmatter activate only when that skill is triggered.

```yaml
---
name: my-skill
description: My skill description
hooks:
  PreToolUse:
    - matcher: "^Bash$"
      hooks:
        - type: command
          command: "./scripts/validate.sh"
          timeout: 2000
  PostToolUse:
    - matcher: "^(Write|Edit)$"
      hooks:
        - type: command
          command: "./scripts/format.sh"
          timeout: 2000
---
```

**Supported events:** PreToolUse, PostToolUse, Stop

**Lifetime:** Hooks active only during skill execution; automatically cleaned up when skill finishes.

### Example: Format on Write Skill

```yaml
---
name: format-on-write
description: Format code after writing files
hooks:
  PostToolUse:
    - matcher: "^(Write|Edit)$"
      hooks:
        - type: command
          command: "${CLAUDE_PLUGIN_ROOT}/scripts/prettier.sh"
          timeout: 2000
          onError: "warn"
---

# Skill instructions follow...
When Claude writes files, automatically format them with Prettier.
```

**In practice:** When this skill is triggered, PostToolUse hooks are registered. Any Write/Edit tool automatically formats. When skill finishes, hooks are removed.

## Agent Frontmatter Hooks

Hooks in an agent's frontmatter activate during agent execution.

```yaml
---
name: code-reviewer
description: Review code changes
hooks:
  PostToolUse:
    - matcher: "^(Write|Edit)$"
      hooks:
        - type: command
          command: "./scripts/run-linter.sh"
          timeout: 3000
---
```

**Supported events:** PreToolUse, PostToolUse, Stop

**Lifetime:** Hooks active only while agent runs; cleaned up when agent finishes.

### Example: Validation Agent

```yaml
---
name: security-validator
description: Validate changes for security issues
hooks:
  PreToolUse:
    - matcher: "^(Write|Edit)$"
      hooks:
        - type: command
          command: "./scripts/security-check.sh"
          timeout: 2000
  PostToolUse:
    - matcher: "^Bash$"
      hooks:
        - type: command
          command: "./scripts/log-exec.sh"
          timeout: 1000
---
```

## The "once" Option

Run a hook only once per session, then remove it:

```yaml
---
name: my-skill
hooks:
  SessionStart:  # ERROR: This doesn't work in skill frontmatter
    - hooks:
        - type: command
          command: "init.sh"
          once: true
---
```

**Important:** `once` option is only supported for skills, not agents. Works with component-scoped hooks only.

**When to use:**
- One-time initialization within a skill
- Setup that shouldn't repeat if skill called multiple times
- Cleanup hooks that should run only once

### Example: Initialize Once

```yaml
---
name: database-tools
description: Tools for database operations
hooks:
  PreToolUse:
    - matcher: "^Bash$"
      hooks:
        - type: command
          command: "${CLAUDE_PLUGIN_ROOT}/scripts/init-db.sh"
          once: true
          timeout: 5000
---
```

First time any Bash tool is used in this skill, init-db.sh runs. On subsequent uses, hook is skipped.

## Environment Variables Available

**All component-scoped hooks have access to:**

```bash
${CLAUDE_PLUGIN_ROOT}     # Plugin root directory
${CLAUDE_PROJECT_DIR}     # Project root directory
${CLAUDE_CODE_REMOTE}     # "true" if running in web environment
```

### CLAUDE_CODE_REMOTE Example

Behave differently in remote (web) vs local (CLI):

```bash
#!/bin/bash

if [[ "$CLAUDE_CODE_REMOTE" == "true" ]]; then
  # Web environment (claude.ai/code)
  LOG_PATH="/tmp/hooks.log"
else
  # Local CLI environment
  LOG_PATH="$CLAUDE_PROJECT_DIR/.claude/hooks.log"
fi

echo "Hook running in $([ -n "$CLAUDE_CODE_REMOTE" ] && echo web || echo local)" >> "$LOG_PATH"
```

## Execution Scoping

Component-scoped hooks are cleaned up at lifecycle boundaries:

```
Session Start
├─ Skill A triggered
│  ├─ Skill A hooks registered
│  ├─ Claude works (hooks active)
│  └─ Skill A finishes → Hooks removed
├─ Agent B started
│  ├─ Agent B hooks registered
│  ├─ Agent runs (hooks active)
│  └─ Agent finishes → Hooks removed
└─ Session End
```

**Important:** No hook pollution. When a skill/agent finishes, its hooks are gone.

## Combining Component & Global Hooks

Both can coexist:

```
Global hooks (in settings/plugin): Always active
+ Component hooks (in skill/agent): Active only during component execution
= Combined behavior
```

If both match an event:
- All matching hooks run (global + component-scoped)
- Execution order: Global hooks first, then component hooks
- Each can return decisions independently

## Practical Examples

### Example 1: Format Skill with Once Initialization

```yaml
---
name: format-tool
description: Format code using Prettier and Black
version: 1.0.0
hooks:
  PreToolUse:
    - matcher: "^(Write|Edit)$"
      hooks:
        - type: command
          command: "${CLAUDE_PLUGIN_ROOT}/scripts/check-formatters.sh"
          once: true
          timeout: 2000
  PostToolUse:
    - matcher: "^(Write|Edit)$"
      hooks:
        - type: command
          command: "${CLAUDE_PLUGIN_ROOT}/scripts/format.sh"
          timeout: 3000
---

This skill automatically formats code. The check-formatters hook runs once to verify Prettier/Black are installed.
```

### Example 2: Testing Agent

```yaml
---
name: test-validator
description: Validate changes with tests
hooks:
  PostToolUse:
    - matcher: "^(Write|Edit)$"
      hooks:
        - type: command
          command: "${CLAUDE_PLUGIN_ROOT}/scripts/run-tests.sh"
          timeout: 15000
          onError: "warn"
  Stop:
    - hooks:
        - type: prompt
          prompt: "All tests passed? ${ARGUMENTS}\n\nRespond: {\"ok\": true} or {\"ok\": false, \"reason\": \"why\"}"
          timeout: 10000
---

This agent runs tests after file changes and intelligently decides if work can stop.
```

### Example 3: Security Checker (Remote-Aware)

```yaml
---
name: security-checker
description: Audit operations for security issues
hooks:
  PreToolUse:
    - matcher: "^Bash$"
      hooks:
        - type: command
          command: "${CLAUDE_PLUGIN_ROOT}/scripts/audit-bash.sh"
          timeout: 2000
---
```

Script (audit-bash.sh):
```bash
#!/bin/bash

if [[ "$CLAUDE_CODE_REMOTE" == "true" ]]; then
  # Web environment: stricter checks
  read -r input
  command=$(echo "$input" | jq -r '.tool_input.command')

  if [[ "$command" =~ rm\ -rf|sudo|chmod\ 777 ]]; then
    echo "Dangerous command blocked in web environment" >&2
    exit 2
  fi
else
  # Local: trust user
  exit 0
fi
```

## Debugging Component Hooks

Enable debug logging to see component hook execution:

```bash
claude --debug
```

Look for:
```
[DEBUG] Skill activated: my-skill
[DEBUG] Component hooks registered for skill: my-skill
[DEBUG] Executing component hook: PreToolUse
[DEBUG] Component hooks cleaned up: my-skill
```

## Limitations

**Component-scoped hooks cannot:**
- Use UserPromptSubmit (only available in settings/plugins)
- Use SessionStart/SessionEnd (session-level, not component-level)
- Persist across component boundaries (automatically cleaned up)

**Use global hooks (settings/plugins) for:**
- Session-level behavior
- User prompt validation
- Always-on monitoring
