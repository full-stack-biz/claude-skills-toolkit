# Plugin Templates

Copy-paste starting points for common plugin patterns. Customize for your specific use case.

## Table of Contents

- [Template 1: Simple Single-Command Plugin](#template-1-simple-single-command-plugin)
- [Template 2: Multi-Command Plugin](#template-2-multi-command-plugin)
- [Template 3: Plugin with Agent Skills](#template-3-plugin-with-agent-skills)
- [Template 4: Complex Plugin with Custom Agent](#template-4-complex-plugin-with-custom-agent)
- [Template 5: Plugin with Hooks](#template-5-plugin-with-hooks)
- [Template 6: Project Conversion](#template-6-project-conversion)
- [Customization Checklist](#customization-checklist)
- [Quick Template Selection](#quick-template-selection)

## Template 1: Simple Single-Command Plugin

For plugins with one slash command.

**Directory structure:**
```
my-plugin/
├── .claude-plugin/
│   └── plugin.json
└── commands/
    └── hello.md
```

**`.claude-plugin/plugin.json`:**
```json
{
  "name": "my-plugin",
  "description": "What the plugin does. Use when [context].",
  "version": "1.0.0",
  "author": {
    "name": "Your Name"
  }
}
```

**`commands/hello.md`:**
```markdown
---
name: hello
description: >-
  Brief description of what this command does.
arguments:
  input:
    description: Input parameter
    required: true
---

# Hello Command

Your command instructions here.

## Quick Start

1. Read input from `input` argument
2. Process it
3. Return result

## Example

Input: "test"
Output: "result"

## Key Notes

- Note any important constraints
- Specify error handling behavior
```

## Template 2: Multi-Command Plugin

For plugins with multiple related slash commands.

**Directory structure:**
```
my-plugin/
├── .claude-plugin/
│   └── plugin.json
├── commands/
│   ├── validate.md
│   ├── format.md
│   └── report.md
└── README.md
```

**`.claude-plugin/plugin.json`:**
```json
{
  "name": "code-processor",
  "description": "Process code with validate, format, and reporting. Use when checking code quality, formatting, or generating reports.",
  "version": "1.0.0",
  "author": {
    "name": "Your Name"
  },
  "repository": "https://github.com/user/code-processor"
}
```

**`commands/validate.md`:**
```markdown
---
name: validate
description: Validate code against rules and return issues found
arguments:
  code:
    description: Code to validate
    required: true
  rules:
    description: Rules to check (comma-separated)
    required: false
---

# Validate Command

Validates code and returns list of issues.

## Quick Start

1. Parse `code` argument
2. Apply rules from `rules` parameter (or use default rules)
3. Return issues found (sorted by severity)

## Examples

Example 1: JavaScript validation
```
Input: const x = 1; const y = 2;
Output: Unused variables: x, y
```

## Key Notes

- Always return sorted results (errors first, then warnings)
- Include line numbers in output
```

**`commands/format.md`:**
```markdown
---
name: format
description: Format code according to style rules
arguments:
  code:
    description: Code to format
    required: true
  style:
    description: Code style (default, compact, expanded)
    required: false
---

# Format Command

Format code according to specified style.

## Quick Start

1. Parse `code` argument
2. Apply formatting rules
3. Return formatted code

## Examples

Input: const x=1;const y=2;
Output: const x = 1; const y = 2;
```

**`commands/report.md`:**
```markdown
---
name: report
description: Generate report of code analysis
arguments:
  code:
    description: Code to analyze
    required: true
  format:
    description: Report format (text, json, html)
    required: false
---

# Report Command

Analyze code and generate detailed report.

## Quick Start

1. Analyze code
2. Generate report in specified format
3. Return formatted report
```

## Template 3: Plugin with Agent Skills

For plugins with reusable Agent Skills.

**Directory structure:**
```
my-plugin/
├── .claude-plugin/
│   └── plugin.json
├── commands/
│   └── analyze.md
└── skills/
    ├── code-analysis/
    │   └── SKILL.md
    └── reporting/
        └── SKILL.md
```

**`.claude-plugin/plugin.json`:**
```json
{
  "name": "analyzer-plugin",
  "description": "Analyze code and generate reports. Use when evaluating code quality, finding issues, or generating analysis. Includes analyze command and reusable analysis Skills.",
  "version": "1.0.0"
}
```

**`commands/analyze.md`:**
```markdown
---
name: analyze
description: Analyze code using available analysis Skills
arguments:
  code:
    description: Code to analyze
    required: true
  analysis-type:
    description: Type of analysis (quality, security, performance)
    required: false
---

# Analyze Command

Analyze code using appropriate Skills.

## Quick Start

1. Receive code from `code` argument
2. Use code-analysis Skill to analyze
3. Use reporting Skill to format results
4. Return analysis report
```

**`skills/code-analysis/SKILL.md`:**
```markdown
---
name: code-analysis
description: Analyze code for issues, patterns, and quality metrics. Use when examining code structure, finding issues, or generating quality metrics.
allowed-tools: Read,Write
---

# Code Analysis Skill

Analyze source code and identify issues.

## Quick Start

1. Parse code
2. Check for issues (syntax, style, best practices)
3. Collect metrics (lines of code, complexity, etc.)
4. Return structured analysis

## Key Notes

- Independent skill (Claude uses automatically)
- Reusable across multiple commands
- Include specific issues found
```

**`skills/reporting/SKILL.md`:**
```markdown
---
name: reporting
description: Generate formatted reports from analysis results. Use when creating analysis reports or formatting output for different audiences.
allowed-tools: Read,Write
---

# Reporting Skill

Generate formatted reports from analysis data.

## Quick Start

1. Receive analysis data
2. Format according to output format
3. Return formatted report

## Key Notes

- Works with code-analysis Skill output
- Supports multiple formats (text, JSON, HTML)
```

## Template 4: Complex Plugin with Custom Agent

For plugins with complex workflows requiring a custom agent.

**Directory structure:**
```
my-plugin/
├── .claude-plugin/
│   └── plugin.json
├── commands/
│   └── orchestrate.md
├── agents/
│   └── workflow-engine.md
└── skills/
    ├── task-a/
    │   └── SKILL.md
    └── task-b/
        └── SKILL.md
```

**`.claude-plugin/plugin.json`:**
```json
{
  "name": "workflow-plugin",
  "description": "Execute multi-step workflows with custom orchestration. Use when running complex workflows that need planning, state management, and multiple steps. Includes workflow execution engine.",
  "version": "1.0.0"
}
```

**`commands/orchestrate.md`:**
```markdown
---
name: orchestrate
description: Run complex workflow with state management and multiple steps
arguments:
  workflow:
    description: Workflow name or definition
    required: true
  params:
    description: Workflow parameters (JSON format)
    required: false
---

# Orchestrate Command

Run complex workflow using custom agent.

## Quick Start

1. Parse workflow definition
2. Delegate to workflow-engine agent
3. Return workflow results

## Key Notes

- Complex workflows use custom agent (workflow-engine)
- Agent handles planning and state management
```

**`agents/workflow-engine.md`:**
````markdown
---
description: Plan and execute complex multi-step workflows with state management and error recovery.
capabilities: ["workflow-planning", "state-management", "error-recovery", "step-execution"]
---

# Workflow Engine Agent

Custom agent for complex workflow orchestration.

## Capabilities

- Plan workflow execution
- Execute steps in order
- Manage state between steps
- Handle errors and recovery
- Track progress

## Context and examples

**When to use this agent:**
- Complex multi-step workflows needing coordination
- Tasks requiring state management between steps
- Workflows with error handling and recovery needs

**Not for:** Simple single-step operations (don't need agents)

## Key Notes

- Delegates to Skills for specific tasks
- Returns complete workflow results
````

**`skills/task-a/SKILL.md` and `skills/task-b/SKILL.md`:**

```markdown
---
name: task-a
description: Execute task A. Use when task A is needed in workflow.
allowed-tools: Read,Write
---

# Task A Skill

Execute specific task in workflow.

## Quick Start

1. Receive task input
2. Execute task
3. Return results

## Key Notes

- Used by workflow-engine agent
- Handles one specific task
```

## Template 5: Plugin with Hooks

For plugins that respond to events.

**Directory structure:**
```
my-plugin/
├── .claude-plugin/
│   └── plugin.json
├── commands/
│   ├── validate.md
│   └── format.md
├── hooks.json
└── README.md
```

**`.claude-plugin/plugin.json`:**
```json
{
  "name": "code-quality",
  "description": "Automatic code quality checks on save and pre-commit. Use when setting up quality gates.",
  "version": "1.0.0"
}
```

**`hooks.json`:**
```json
{
  "on-save": [
    {
      "name": "format",
      "args": {}
    }
  ],
  "on-commit": [
    {
      "name": "validate",
      "args": {}
    }
  ]
}
```

**`commands/validate.md` and `commands/format.md`:**
```markdown
---
name: validate
description: Validate code
arguments: {}
---

# Validate Command

Validate code before commit.

## Quick Start

Run validation checks.
```

## Template 6: Project Conversion

For converting existing projects to plugins.

**Conversion steps:**

1. Create `.claude-plugin/` directory and `plugin.json`
2. Move slash commands to `commands/` directory
3. Move agents to `agents/` directory
4. Move Skills to `skills/` directory
5. Configure `hooks.json` if event handlers exist
6. Update component metadata (add YAML frontmatter)

**Before (project structure):**
```
my-project/
├── src/
│   └── commands/
│       └── validate.sh
├── agents/
│   └── analyzer.py
└── skills/
    └── reporting.md
```

**After (plugin structure):**
```
my-project/
├── .claude-plugin/
│   └── plugin.json
├── commands/
│   └── validate.md          # Converted from validate.sh
├── agents/
│   └── analyzer.md          # Converted from analyzer.py
└── skills/
    └── reporting/
        └── SKILL.md         # Already in correct format
```

## Customization Checklist

When using any template:

- [ ] Replace `my-plugin` with your plugin name (lowercase, hyphens)
- [ ] Update `description` with specific trigger phrases
- [ ] Update `author.name` with your name
- [ ] Replace placeholder command/agent/skill names
- [ ] Write actual instructions (replace placeholder text)
- [ ] Update `version` to start with "1.0.0"
- [ ] Test locally with `claude --plugin-dir /path/to/plugin`
- [ ] Validate plugin.json with `jq .`

## Quick Template Selection

| Use Case | Template |
|----------|----------|
| Single command | Template 1 |
| Multiple commands | Template 2 |
| Commands + reusable Skills | Template 3 |
| Complex workflows | Template 4 |
| Event-driven | Template 5 |
| Convert project | Template 6 |
