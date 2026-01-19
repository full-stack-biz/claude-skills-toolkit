---
name: create-skill
description: Create or refine Claude Code skills following best practices. Use for building new skills, validating existing ones, or refining skill quality.
arguments:
  action:
    description: Action to perform (create, validate, refine)
    required: false
  skill-name:
    description: Name of skill to create or refine
    required: false
---

# Create Skill Command

Create, validate, or refine Claude Code skills using the skill-creator skill.

## Quick Start

When invoked, delegate to the `skill-creator` skill with the provided arguments.

**Default behavior (no arguments):**
- Start requirements interview for a new skill
- Ask about skill purpose, trigger phrases, scope, and tool needs

**With action specified:**
- `create` - Build a new skill from scratch
- `validate` - Check existing skill against best practices
- `refine` - Enhance skill quality (token efficiency, structure, activation)

## Examples

**Create a new skill:**
```
/skills-toolkit:create-skill action=create skill-name=pdf-processor
```

**Validate an existing skill:**
```
/skills-toolkit:create-skill action=validate skill-name=test-runner
```

**Refine skill quality:**
```
/skills-toolkit:create-skill action=refine skill-name=code-analyzer
```

## Key Notes

- Loads the full `skill-creator` skill from `skills/skill-creator/SKILL.md`
- Follow skill-creator's interview process for new skills
- Use skill-creator's validation workflow for existing skills
- Reference skill-creator's checklist for quality assurance
