---
name: create-plugin
description: Create or convert projects to Claude Code plugins. Use for building new plugins, converting existing projects, or validating plugin structure.
arguments:
  action:
    description: Action to perform (create, convert, validate)
    required: false
  plugin-name:
    description: Name of plugin to create or convert
    required: false
---

# Create Plugin Command

Create, convert, or validate Claude Code plugins using the plugin-creator skill.

## Quick Start

When invoked, delegate to the `plugin-creator` skill with the provided arguments.

**Default behavior (no arguments):**
- Start requirements interview for a new plugin
- Ask about plugin purpose, components needed, and distribution scope

**With action specified:**
- `create` - Build a new plugin from scratch
- `convert` - Transform existing project into a plugin
- `validate` - Check plugin structure against Claude Code standards

## Examples

**Create a new plugin:**
```
/skills-toolkit:create-plugin action=create plugin-name=code-reviewer
```

**Convert existing project:**
```
/skills-toolkit:create-plugin action=convert
```

**Validate plugin structure:**
```
/skills-toolkit:create-plugin action=validate plugin-name=my-plugin
```

## Key Notes

- Loads the full `plugin-creator` skill from `skills/plugin-creator/SKILL.md`
- Follow plugin-creator's interview process for new plugins
- Creates proper `.claude-plugin/plugin.json` manifest
- Organizes components into `commands/`, `skills/`, `agents/`, etc.
- Reference plugin-creator's validation checklist for quality assurance
