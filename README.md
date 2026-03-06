# Skills Toolkit for Claude Code

A plugin for creating and managing Claude Code skills and plugins.

## About skill-composer vs Claude's skill-creator

This toolkit includes **skill-composer**, which differs significantly from Claude's built-in skill-creator:

| Aspect | skill-composer | Claude's skill-creator |
|--------|---|---|
| **Philosophy** | Convention enforcement upfront | Evaluation-driven iteration |
| **Approach** | Opinionated, enforced best practices from start | Learn via test feedback loops |
| **Interviews** | Multi-stage requirements gathering (purpose, scope, complexity, tools) | Minimal upfront requirements |
| **Best Practices** | Enforces from the start (frontmatter, 80% rule, references, token efficiency) | Discovered through empirical testing |
| **Workflow** | Design → Structure → Build → [Optional: Refine → Test] | Build → Test → Improve based on results |
| **Output** | Fully structured skill (SKILL.md, references/, scripts/ as needed) | Working skill you iterate on |
| **Use When** | Building skills with conventions you want enforced consistently | Building skills you'll test and improve empirically |
| **Ecosystem** | Part of full toolkit (refiner, tester, plugin-creator) | Standalone, integrates with evaluation |

**TL;DR:** skill-composer enforces **conventions upfront**. Claude's skill-creator improves **via evaluation loops**.

Use **skill-composer** if:
- You want conventions enforced from the ground up
- You're building consistent, production-ready skills
- You value structured SKILL.md, references, and tool scoping upfront
- You want to avoid common skill-building mistakes by design

Use **Claude's skill-creator** if:
- You want to build and improve skills through empirical testing
- You prefer iterative refinement based on evaluation results
- You're comfortable discovering best practices via feedback loops
- You want to measure skill effectiveness with benchmarks

## Table of Contents

- [Available Skills](#available-skills)
  - [skill-composer](#skill-composer)
  - [skill-refiner](#skill-refiner)
  - [skill-tester](#skill-tester)
  - [plugin-creator](#plugin-creator)
  - [hook-creator](#hook-creator)
  - [subagent-creator](#subagent-creator)
  - [ask-user-question](#ask-user-question)
- [Quick Start: From Knowledge to Plugin](#quick-start-from-knowledge-to-plugin)
- [Installation](#installation)
- [Usage Scenarios](#usage-scenarios)
- [Design Notes: Architecture & DRY](#design-notes-architecture--dry)
- [Inspiration](#inspiration)
- [License](#license)
- [Author](#author)

### skill-composer

**Command:** `/skills-toolkit:skill-composer`

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

### skill-tester

**Command:** `/skills-toolkit:skill-tester`

Empirically test and benchmark Claude Code skills:
- Quick Workflow: Fast pass/fail validation of new skills
- Full Pipeline: Comprehensive benchmarking with baseline comparison
- Measure impact: Pass rates, token usage, timing metrics
- Iteration tracking: Compare skill performance across refinement cycles
- Data-driven improvements: Prove skills help with empirical evidence

### plugin-creator

**Command:** `/skills-toolkit:plugin-creator`

Interactive guide for creating and validating plugins:
- Generate `.claude-plugin/plugin.json` manifest
- Organize skills, commands, hooks, MCP/LSP servers
- Convert existing projects to plugins
- Configure installation scope (user/project/managed)
- Validate plugin structure

### hook-creator

**Command:** `/skills-toolkit:hook-creator`

Interactive guide for creating and validating hooks:
- Build plugin hooks from scratch (command, prompt, agent types)
- Validate existing hooks against best practices
- Refine hook quality (event matching, error handling, performance)
- Configure event matching, matchers, and error handling
- Test hooks with validation workflows

### subagent-creator

**Command:** `/skills-toolkit:subagent-creator`

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
2. **Turn it into a skill** - Use `/skills-toolkit:skill-composer` to formalize it into instructions Claude follows
3. **Test empirically** - Use `/skills-toolkit:skill-tester` to validate the skill works and measure its impact
4. **Refine for quality** - Use `/skills-toolkit:skill-refiner` to optimize clarity, efficiency, and production readiness
5. **Package for your team** - Use `/skills-toolkit:plugin-creator` to make it installable
6. **Share and evolve** - Team members install once, Claude guides the process every time

### Real Example: Release Process to Plugin

**User:** `@RELEASE_PROCESS.md` — I have this release management guide. Turn it into a skill.

Claude asked clarifying questions:
- Where should this skill live?
- Will this be used by your team or in production?

**User:** Plugin skill. Team and production.

Claude built it. Created the skill with a detailed workflow. Extracted supporting material into reference guides. Added proper frontmatter, scoped the tools, made it activatable.

**User:** Let's test this before packaging. Does it actually help?

Claude launched skill-tester with Full Pipeline:
- Created test scenarios: simple release, hotfix, major version bump
- Measured: with skill vs. without skill
- Results: 100% pass rate with skill, 60% without. Skill works.

**User:** Great. Now refine it, then package.

Claude used skill-refiner:
- Tightened descriptions for better activation
- Optimized token usage
- Validated against best practices

Then re-tested: Results improved to 100% with clearer instructions and less token usage.

**User:** Perfect. Now package this into a plugin so I can share it.

Claude created the plugin:
- Generated `.claude-plugin/plugin.json`
- Added the release-process skill
- Created README and changelog
- Made it installable

**User:** Install it for the team.

Team members installed once with: `claude plugin install dev-flow`

Now every time someone mentions "release process", Claude activates the skill and guides the workflow.

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

### Scenario 3: Test a Skill Empirically
You've created a new skill but want to prove it actually helps Claude before deploying it.

```
I need to validate my new skill with empirical testing.
```

Use skill-tester to:
- Create test cases that measure skill effectiveness
- Compare performance WITH skill vs. baseline (without skill)
- Get metrics: pass rates, token usage, timing
- Track improvements across refinement iterations

Result: Data-driven evidence that your skill works, with measurable impact metrics.

### Scenario 4: Refine and Re-test
You have a skill in production, but want to improve it and verify the improvement worked.

```
I need to refine an existing skill and measure the improvement.
```

Use skill-refiner to improve the skill, then use skill-tester to compare iteration-1 vs. iteration-2 performance. See exactly how much your refinements helped.

Result: Confidence your improvements work, backed by side-by-side test results.

### Scenario 5: Convert a Project to a Plugin
You have an existing project with helper scripts, documentation, and utilities. You want to make it installable as a Claude plugin.

```
I need to convert my project to a Claude plugin.
```

The guide generates the proper manifest structure, organizes your files, and validates everything is set up correctly.

Result: Your project becomes an installable plugin others can discover and use.

### Scenario 6: Set Up Team Distribution
You've created several skills and want your organization to access them through a central marketplace.

```
I need to improve my plugin structure for team distribution.
```

Create a marketplace plugin that bundles your skills. Push it to GitHub. Team members install once from your marketplace.

Result: Centralized distribution with version control and easy updates.

## Complete Workflows

### Workflow 1: Create → Test → Refine → Package (New Skill)

```
1. skill-composer    Create new skill from scratch
2. skill-tester      Quick test: Does it work?
3. skill-refiner     Optimize clarity & efficiency
4. skill-tester      Full benchmark: Measure improvement
5. plugin-creator    Package for team installation
```

**Time:** ~30 mins from idea to installable plugin

### Workflow 2: Improve Existing Skill with Evidence

```
1. skill-tester      Benchmark current (iteration-1)
2. skill-refiner     Improve the skill
3. skill-tester      Re-benchmark (iteration-2)
4. Compare results   See exact improvement metrics
```

**Time:** ~15 mins per iteration

### Workflow 3: Build a Complete Plugin

```
1. skill-composer    Create skill 1, 2, 3...
2. skill-tester      Test each skill
3. hook-creator      Add automation hooks
4. plugin-creator    Bundle all together
5. Publish           Share with team/marketplace
```

**Time:** Depends on component count

## Design Notes: Architecture & DRY

This toolkit follows **Claude's Bounded Scope Principle** for skills, which creates some intentional knowledge duplication:

- **plugin-creator** includes summaries of skill/subagent/hook concepts for users getting started with plugins
- **skill-composer**, **skill-refiner**, **subagent-creator**, and **hook-creator** provide authoritative, detailed knowledge
- These overlap because Claude's skill architecture doesn't support skill-to-skill delegation yet

**Why this design?** Each skill must be completely self-contained within its directory—this ensures skills work reliably across any deployment context (local, project, user, marketplace). For details, see [Bounded Scope Principle](skills/skill-composer/references/self-containment-principle.md).

**When will this improve?** Claude is actively developing support for full skill delegation via `context: fork`. Once stable, we can reorganize for better Single Responsibility Principle separation.

**Does this affect you?** No. All skills work exactly as expected. The duplication is internal and intentional.

## Inspiration

The original inspiration for this project came from the comprehensive best practices guide:
- [Best Practices for Writing and Using SKILL.md Files](https://github.com/Dicklesworthstone/meta_skill/blob/main/BEST_PRACTICES_FOR_WRITING_AND_USING_SKILLS_MD_FILES.md)

## License

MIT

## Author

[full-stack-biz](https://github.com/full-stack-biz)
