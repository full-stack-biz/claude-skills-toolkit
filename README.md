# Skills Toolkit for Claude Code

A plugin for creating and managing Claude Code skills and plugins.

## What You Get

### `/skills-toolkit:create-skill`
Interactive guide for creating and validating skills:
- Name and describe your skill
- Structure SKILL.md (frontmatter + instructions)
- Set up reference documentation
- Configure tool permissions
- Validate structure and trigger phrases

### `/skills-toolkit:create-plugin`
Interactive guide for creating and managing plugins:
- Generate `.claude-plugin/plugin.json` manifest
- Organize skills, commands, hooks, MCP/LSP servers
- Convert existing projects to plugins
- Configure installation scope (user/project/managed)
- Validate plugin structure

## Installation

```bash
/plugin marketplace add full-stack-biz/claude-skills-toolkit
/plugin install skills-toolkit@skills-toolkit-marketplace
```

Or directly from GitHub:
```bash
claude plugin install https://github.com/full-stack-biz/claude-skills-toolkit --scope user
```

## Quick Start

Create a skill:
```bash
/skills-toolkit:create-skill
```

Create a plugin:
```bash
/skills-toolkit:create-plugin
```

## Usage Scenarios

### Scenario 1: Build a Domain-Specific Skill
You have specialized knowledge about API testing and want Claude to consistently follow your testing patterns.

```bash
/skills-toolkit:create-skill
```

The guide walks you through defining trigger phrases (so Claude activates it automatically when relevant), structuring your instructions clearly, and validating it works as expected.

Result: A reusable skill Claude activates whenever you mention API testing or validation.

### Scenario 2: Create a Team Plugin
Your team needs multiple tools: a code review skill, deployment automation, and custom hooks for validation.

```bash
/skills-toolkit:create-plugin
```

Organize all components into one installable plugin with a single manifest. Team members install once and get all capabilities.

Result: Shareable plugin your team can install and keep up to date.

### Scenario 3: Validate an Existing Skill
You have a skill that mostly works but want to ensure Claude understands it correctly and it's optimized.

```bash
/skills-toolkit:create-skill
```

Select validation mode. The guide checks your skill structure, trigger phrases, tool permissions, and efficiency.

Result: Confidence your skill works reliably and loads efficiently into Claude's context.

### Scenario 4: Convert a Project to a Plugin
You have an existing project with helper scripts, documentation, and utilities. You want to make it installable as a Claude plugin.

```bash
/skills-toolkit:create-plugin
```

The guide generates the proper manifest structure, organizes your files, and validates everything is set up correctly.

Result: Your project becomes an installable plugin others can discover and use.

### Scenario 5: Set Up Team Distribution
You've created several skills and want your organization to access them through a central marketplace.

```bash
/skills-toolkit:create-plugin
```

Create a marketplace plugin that bundles your skills. Push it to GitHub. Team members install once from your marketplace.

Result: Centralized distribution with version control and easy updates.

## What's Included

### Skill Creator
- Structured creation workflow
- 7-phase validation process
- Best practices checklist
- Token efficiency guidelines
- Tool scoping reference
- 8 supporting guides

### Plugin Creator
- Manifest generation
- Component organization
- Multi-component bundling
- Distribution guidance
- 21 supporting guides

## Directory Structure

```
.
├── .claude-plugin/
│   ├── plugin.json           # Plugin manifest
│   └── marketplace.json      # Marketplace definition
├── skills/
│   ├── skill-creator/
│   │   ├── SKILL.md
│   │   └── references/       # 8 guides
│   └── plugin-creator/
│       ├── SKILL.md
│       └── references/       # 21 guides
├── commands/
│   ├── create-skill.md       # /skills-toolkit:create-skill
│   └── create-plugin.md      # /skills-toolkit:create-plugin
└── README.md
```

## Reference Guides

### Skill Creator
- how-skills-work.md - Token loading and execution model
- validation-workflow.md - 7-phase validation
- checklist.md - Best practices
- templates.md - Skill templates
- content-guidelines.md - Writing for Claude
- allowed-tools.md - Tool scoping
- advanced-patterns.md - Advanced patterns
- self-containment-principle.md - Skill isolation

### Plugin Creator
- how-plugins-work.md - Plugin architecture
- implementation-workflow.md - Step-by-step creation
- validation-checklist.md - Quality checks
- directory-structure.md - File organization
- plugin-json-schema.md - Manifest schema
- installation-scopes.md - Installation options
- team-marketplaces.md - Team distribution
- And 14 more guides

## Inspiration & Resources

This project was built with guidance from the comprehensive best practices guide:
- [Best Practices for Writing and Using SKILL.md Files](https://github.com/Dicklesworthstone/meta_skill/blob/main/BEST_PRACTICES_FOR_WRITING_AND_USING_SKILLS_MD_FILES.md)

## License

MIT

## Author

[full-stack-biz](https://github.com/full-stack-biz)
