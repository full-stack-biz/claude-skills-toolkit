# Skills Toolkit for Claude Code

A plugin for creating and managing Claude Code skills and plugins.

## Table of Contents

- [Available Skills](#available-skills)
  - [create-skill](#create-skill)
  - [skill-refiner](#skill-refiner)
  - [create-plugin](#create-plugin)
  - [create-hook](#create-hook)
  - [create-subagent](#create-subagent)
  - [ask-user-question](#ask-user-question)
- [Quick Start: From Knowledge to Plugin](#quick-start-from-knowledge-to-plugin)
- [Installation](#installation)
- [Usage Scenarios](#usage-scenarios)
- [Design Notes: Architecture & DRY](#design-notes-architecture--dry)
- [Inspiration](#inspiration)
- [License](#license)
- [Author](#author)

### create-skill

**Command:** `/skills-toolkit:create-skill`

Interactive guide for creating new skills from scratch:
- Name and describe your skill
- Structure SKILL.md (frontmatter + instructions)
- Set up reference documentation
- Configure tool permissions
- Apply best practices during creation

### skill-refiner

**Command:** `/skills-toolkit:skill-refiner`

Interactive guide for improving and validating existing skills:
- Refine skill structure and clarity
- Validate against best practices
- Reduce token usage and improve efficiency
- Check production readiness
- Apply the 80% rule for optimization

### create-plugin

**Command:** `/skills-toolkit:create-plugin`

Interactive guide for creating and validating plugins:
- Generate `.claude-plugin/plugin.json` manifest
- Organize skills, commands, hooks, MCP/LSP servers
- Convert existing projects to plugins
- Configure installation scope (user/project/managed)
- Validate plugin structure

### create-hook

**Command:** `/skills-toolkit:create-hook`

Interactive guide for creating and validating hooks:
- Build plugin hooks from scratch (command, prompt, agent types)
- Validate existing hooks against best practices
- Refine hook quality (event matching, error handling, performance)
- Configure event matching, matchers, and error handling
- Test hooks with validation workflows

### create-subagent

**Command:** `/skills-toolkit:create-subagent`

Interactive guide for creating and validating subagents:
- Build subagents with clear delegation signals
- Configure tool access with permission modes
- Set up hooks for agent coordination
- Validate against best practices for reliability

### ask-user-question

**Command:** `/skills-toolkit:ask-user-question`

Reference guide for implementing interactive user input in skills:
- Master AskUserQuestion tool constraints and patterns
- Build conditional workflows and dynamic questions
- Handle validation, error recovery, and multi-select
- Production patterns for robustness and testing

## Quick Start: From Knowledge to Plugin

### The Problem

Teams struggle with processes that matter but don't get followed. You document a release process, testing workflow, or code review guide. It sits in a repo. People don't find it. They forget it. They ask the same questions.

### The Solution: Interactive Guidance

Instead of documentation sitting idle, turn it into a skill—interactive guidance Claude activates when relevant. Then package it as a plugin so your team can install it once and get the full workflow.

### How It Works

1. **Start with what you know** - You have documentation, a process guide, or expertise
2. **Turn it into a skill** - Use `/skills-toolkit:create-skill` to formalize it into instructions Claude follows
3. **Refine for quality** - Use `/skills-toolkit:skill-refiner` to optimize clarity, efficiency, and production readiness
4. **Package for your team** - Use `/skills-toolkit:create-plugin` to make it installable
5. **Share and evolve** - Team members install once, Claude guides the process every time

### Real Example: Release Process to Plugin

**User:** `@RELEASE_PROCESS.md` — I have this release management guide. Turn it into a skill.

Claude asked clarifying questions:
- Where should this skill live?
- Will this be used by your team or in production?

**User:** Plugin skill. Team and production.

Claude built it. Created the skill with a detailed workflow. Extracted supporting material into reference guides. Added proper frontmatter, scoped the tools, made it activatable.

**User:** Now package this into a plugin so I can share it.

Claude asked:
- What would you like to do?
- What should the plugin be named?

**User:** Convert this project. Call it dev-flow.

Claude created the plugin manifest, README, changelog, added the skill, made it installable.

**User:** Do a fresh review. Make sure everything is solid.

Claude asked (using skill-refiner):
- Which refinement areas matter most for your team?

**User:** Activation & trigger phrases, token efficiency, quick start strengthening, error prevention guardrails.

Claude re-read what was built. Found ambiguities. Refined the guidance. Tightened the wording. Caught its own mistakes.

### Why This Pattern Works

1. Knowledge in documentation gets ignored. Skills get loaded.
2. Skills activate automatically when relevant. Documentation doesn't.
3. Plugins make skills installable and shareable across teams.
4. Iteration catches gaps the first draft misses.

## Installation

Add the marketplace:
```bash
/plugin marketplace add full-stack-biz/claude-skills-toolkit
```

Then install the plugin:
```bash
/plugin install skills-toolkit@skills-toolkit-marketplace
```

Or directly from GitHub:
```bash
claude plugin install https://github.com/full-stack-biz/claude-skills-toolkit --scope user
```

## Usage Scenarios

### Scenario 1: Build a Domain-Specific Skill
You have specialized knowledge about API testing and want Claude to consistently follow your testing patterns.

```
I need to build a new skill for API testing.
```

The guide walks you through defining trigger phrases (so Claude activates it automatically when relevant), structuring your instructions clearly, and validating it works as expected.

Result: A reusable skill Claude activates whenever you mention API testing or validation.

### Scenario 2: Create a Team Plugin
Your team needs multiple tools: a code review skill, deployment automation, and custom hooks for validation.

```
I need to build a plugin from scratch for our team.
```

Organize all components into one installable plugin with a single manifest. Team members install once and get all capabilities.

Result: Shareable plugin your team can install and keep up to date.

### Scenario 3: Refine an Existing Skill
You have a skill that mostly works but want to ensure Claude understands it correctly and it's optimized.

```
I need to refine an existing skill against best practices.
```

Use skill-refiner to validate structure, trigger phrases, token efficiency, tool permissions, and production readiness.

Result: Confidence your skill works reliably, loads efficiently, and meets quality standards.

### Scenario 4: Convert a Project to a Plugin
You have an existing project with helper scripts, documentation, and utilities. You want to make it installable as a Claude plugin.

```
I need to convert my project to a Claude plugin.
```

The guide generates the proper manifest structure, organizes your files, and validates everything is set up correctly.

Result: Your project becomes an installable plugin others can discover and use.

### Scenario 5: Set Up Team Distribution
You've created several skills and want your organization to access them through a central marketplace.

```
I need to improve my plugin structure for team distribution.
```

Create a marketplace plugin that bundles your skills. Push it to GitHub. Team members install once from your marketplace.

Result: Centralized distribution with version control and easy updates.

## Design Notes: Architecture & DRY

This toolkit follows **Claude's Bounded Scope Principle** for skills, which creates some intentional knowledge duplication:

- **plugin-creator** includes summaries of skill/subagent/hook concepts for users getting started with plugins
- **skill-creator**, **skill-refiner**, **subagent-creator**, and **hook-creator** provide authoritative, detailed knowledge
- These overlap because Claude's skill architecture doesn't support skill-to-skill delegation yet

**Why this design?** Each skill must be completely self-contained within its directory—this ensures skills work reliably across any deployment context (local, project, user, marketplace). For details, see [Bounded Scope Principle](skills/skill-creator/references/self-containment-principle.md).

**When will this improve?** Claude is actively developing support for full skill delegation via `context: fork`. Once stable, we can reorganize for better Single Responsibility Principle separation.

**Does this affect you?** No. All skills work exactly as expected. The duplication is internal and intentional.

## Inspiration

The original inspiration for this project came from the comprehensive best practices guide:
- [Best Practices for Writing and Using SKILL.md Files](https://github.com/Dicklesworthstone/meta_skill/blob/main/BEST_PRACTICES_FOR_WRITING_AND_USING_SKILLS_MD_FILES.md)

## License

MIT

## Author

[full-stack-biz](https://github.com/full-stack-biz)
