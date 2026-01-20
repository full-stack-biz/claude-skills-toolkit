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

### `/skills-toolkit:create-hook`
Interactive guide for creating and validating hooks:
- Build plugin hooks from scratch (command, prompt, agent types)
- Validate existing hooks against best practices
- Refine hook quality (event matching, error handling, performance)
- Configure event matching, matchers, and error handling
- Test hooks with validation workflows

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

Create a hook:
```bash
/skills-toolkit:create-hook
```

Create a subagent:
```bash
/skills-toolkit:create-subagent
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

## Features

### Skill Creator
Build custom Claude Code skills with structured guidance:
- Interactive creation workflow for new skills
- 7-phase validation process for quality assurance
- Best practices and token efficiency optimization
- Trigger phrase guidance for reliable skill activation

### Plugin Creator
Create shareable plugins that bundle multiple components:
- Generate proper `.claude-plugin/plugin.json` manifests
- Organize and validate component structure
- Support multi-component bundling (skills, commands, hooks, agents)
- Convert existing projects into installable plugins

### Hook Creator
Automate plugin workflows with event-driven hooks:
- Create hooks for plugin automation (command, prompt, or agent types)
- Validate event matching and error handling
- Test hooks against best practices
- Production-ready validation workflows

### Subagent Creator
Delegate complex tasks to specialized Claude agents:
- Build subagents with clear delegation signals
- Configure tool access with permission modes
- Set up hooks for agent coordination
- Validate against best practices for reliability

## Inspiration & Resources

This project was built with guidance from the comprehensive best practices guide:
- [Best Practices for Writing and Using SKILL.md Files](https://github.com/Dicklesworthstone/meta_skill/blob/main/BEST_PRACTICES_FOR_WRITING_AND_USING_SKILLS_MD_FILES.md)

## License

MIT

## Author

[full-stack-biz](https://github.com/full-stack-biz)
