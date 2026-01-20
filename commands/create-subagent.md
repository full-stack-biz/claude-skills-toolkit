---
name: create-subagent
description: Create, validate, and refine Claude Code subagents for reliable delegation. Use when building new subagents, validating existing ones, improving quality, or configuring permissions and hooks.
arguments:
  action:
    description: Action to perform (create, validate, refine)
    required: false
  subagent-name:
    description: Name of subagent to create or modify
    required: false
---

# Create Subagent Command

Create, validate, or refine Claude Code subagents using the subagent-creator skill.

## Quick Start

When invoked, delegate to the `subagent-creator` skill with the provided arguments.

**Default behavior (no arguments):**
- Start requirements interview for a new subagent
- Ask about purpose, delegation triggers, tool access, and permission modes

**With action specified:**
- `create` - Build a new subagent from scratch
- `validate` - Check existing subagent against best practices
- `refine` - Improve subagent quality (delegation signals, permissions, hooks)

## Examples

**Create a new subagent:**
```
/skills-toolkit:create-subagent action=create subagent-name=db-analyzer
```

**Validate an existing subagent:**
```
/skills-toolkit:create-subagent action=validate subagent-name=code-reviewer
```

**Refine subagent quality:**
```
/skills-toolkit:create-subagent action=refine subagent-name=test-runner focus=permission-modes
```

## Key Notes

- Loads the full `subagent-creator` skill from `skills/subagent-creator/SKILL.md`
- Follow subagent-creator's interview process for new subagents
- Use subagent-creator's validation workflow for existing subagents
- Reference subagent-creator's checklist for quality assurance
- Includes comprehensive guides on delegation signals, tool scoping, and hooks
