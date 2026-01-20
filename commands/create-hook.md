---
name: create-hook
description: Create, validate, and refine Claude Code plugin hooks for automating workflows. Use when building new hooks, validating existing hooks, or improving hook quality for production.
arguments:
  action:
    description: Action to perform (create, validate, refine)
    required: false
  hook-name:
    description: Name or description of hook to create or modify
    required: false
---

# Create Hook Command

Create, validate, or refine Claude Code plugin hooks using the hook-creator skill.

## Quick Start

When invoked, delegate to the `hook-creator` skill with the provided arguments.

**Default behavior (no arguments):**
- Start requirements interview for a new hook
- Ask about hook purpose, event type, matcher conditions, and error handling needs

**With action specified:**
- `create` - Build a new hook from scratch
- `validate` - Check existing hooks against best practices
- `refine` - Improve hook quality (event matching, error handling, performance)

## Examples

**Create a new hook:**
```
/skills-toolkit:create-hook action=create hook-name=format-on-write
```

**Validate an existing hook:**
```
/skills-toolkit:create-hook action=validate hook-name=pre-commit-check
```

**Refine hook quality:**
```
/skills-toolkit:create-hook action=refine hook-name=post-tool-use focus=performance
```

## Key Notes

- Loads the full `hook-creator` skill from `skills/hook-creator/SKILL.md`
- Follow hook-creator's interview process for new hooks
- Use hook-creator's validation workflow for existing hooks
- Reference hook-creator's checklist and templates for best practices
- Supports command, prompt, and agent hook types with comprehensive validation
