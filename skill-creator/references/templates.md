# Templates for Skill Creation

## Table of Contents
- [SKILL.md Template](#skillmd-template)
- [Reference File Template](#reference-file-template)
- [Description Formula & Examples](#description-formula--examples)
- [Workflow Pattern Examples](#workflow-pattern-examples)
- [Optional Frontmatter Fields](#optional-frontmatter-fields)
- [Structure Validation](#structure-validation)
- [Token Efficiency Tips](#token-efficiency-tips)

## SKILL.md Template

Use this template as your starting point. Customize the sections based on your skill's complexity.

### Basic Template (Minimal)

```yaml
---
name: skill-name
description: >-
  What the skill does. Use when [specific trigger contexts].
  [Optional: key constraints or scope].
---

# Skill Name

## Quick Start
[Minimal example showing immediate usage. Code-first, 5-10 lines.]

```bash
# Example command or workflow
command example here
```

## Core Workflow
[Main 3-5 step workflow. Imperative style: "Do X", "Run Y", "Configure Z"]

## Advanced Options
[Optional: specific variations, edge cases, configuration]

## Key Notes
- Important assumption or constraint
- Common gotcha or best practice
- Deployment location or integration point

## Full Reference
For detailed configuration, see `references/complete-guide.md`
```

### Production/Team Skills Template

For Skills used by teams or in production, add optional fields.

**Frontmatter:**

```yaml
---
name: team-skill-name
description: >-
  What the skill does. Use when [specific trigger contexts].
  Designed for team use with robust error handling.
version: 1.0.0
allowed-tools: Read,Write,Bash(python:*)
---
```

**Body:**

````markdown
# Skill Name

## Overview
[Brief description of what this skill does]

## Prerequisites
- [Required software/libraries]
- [Team membership/access requirements]

## Quick Start
[3-5 step usage with example]

## Common Workflows
- [Workflow 1]
- [Workflow 2]
- [Workflow 3]

## Validation
Run the validation script to test the skill:

```bash
bash validate-team-skill.sh
```

## Error Handling
[How the skill handles failures and what error messages mean]

## Troubleshooting
[Common issues and solutions]

## Support
Contact: [Team lead / owner]

## Version History
See [VERSION_HISTORY.md](../VERSION_HISTORY.md)
````

### SKILL.md Body Structure Examples

**Minimal skill (50-75 lines):**
- Quick Start
- Workflows (2-3 bullet points)
- Key Notes

**Standard skill (75-150 lines):**
- Quick Start
- Core Workflow (steps with code)
- Variations or Advanced Options
- Key Notes
- Links to references/

**Complex skill (150-300 lines):**
- Quick Start
- Core Workflow
- Multiple workflows (conditional, template-based, etc.)
- Configuration section
- Key Notes
- Links to references/
- Troubleshooting (brief)

## Reference File Template

For skills with detailed content, create `references/complete-guide.md` or task-specific files.

```markdown
# Complete Guide: [Skill Name]

## Table of Contents
- [Configuration](#configuration)
- [Operations](#operations)
- [Workflows](#workflows)
- [Troubleshooting](#troubleshooting)

## Configuration

### Environment Variables
| Variable | Required | Default | Purpose |
|----------|----------|---------|---------|
| VAR_NAME | Yes | — | Description |
| VAR_NAME | No | default_value | Description |

### File Structure
```
project/
├── config.yml
├── src/
└── tests/
```

## Operations

### Basic Operation
[Step-by-step instructions with code examples]

### Advanced Operation
[For users who understand the basics]

## Workflows

### Template: [Workflow Name]
[Checklist or step-by-step workflow]

## Troubleshooting

### Error: [Error Message]
**Cause:** Explanation
**Solution:** Fix steps
```

## Description Formula & Examples

**Formula:**
```
[Action/capability]. Use when [trigger contexts]. [Scope/constraints].
```

### Example Descriptions

✅ **Good: Specific + triggers + scope**
- "Run PHPUnit tests in Laravel via Docker. Use when validating code before commit. Generates JUnit reports and coverage."
- "Create Claude Code skills following best practices. Use when building new skills, validating existing skills, or improving quality."

❌ **Poor: Vague, no triggers, unclear scope**
- "Helper for testing"
- "Useful for code validation"
- "Makes things easier"

## Common Description Patterns

**Action-based:**
"[Verb] [object] using [tool/method]. Use when [context]."
- "Run tests in Docker containers. Use when validating code changes."
- "Generate API documentation from OpenAPI specs. Use when creating SDK references."

**Problem-solving:**
"[Solves/prevents] [problem]. Use when [context]."
- "Prevents syntax errors in YAML configs. Use when writing Kubernetes manifests."
- "Detects unused dependencies. Use when optimizing package.json."

**Pattern-based:**
"Implement [pattern/workflow]. Use when [need/context]."
- "Implement blue-green deployments. Use when deploying without downtime."
- "Implement retry logic for flaky API calls. Use when working with unreliable services."

## Workflow Pattern Examples

### Checklist Pattern
```markdown
## Deployment Checklist
- [ ] Run tests
- [ ] Build distribution
- [ ] Update documentation
- [ ] Create pull request
- [ ] Notify team
```

### Conditional Pattern
```markdown
## Workflow: Update Dependencies

1. **Check for updates:** `npm outdated`
2. **Choose update strategy:**
   - **Minor updates only:** `npm update`
   - **All updates (test first!):** `npm install@latest`
3. **Run test suite**
4. **Commit and push**
```

### Template Pattern
```markdown
## Template: New Feature Implementation

Starting prompt:
```
I'm building [feature].
Architecture: [pattern].
Tech stack: [tools].
```

We'll follow these steps:
1. Review existing patterns
2. Design the component
3. Implement core functionality
4. Add tests
5. Document and deploy
```

### Feedback Loop Pattern
```markdown
## Workflow: Code Review

1. **Request review** with context
2. **Receive feedback** and discuss trade-offs
3. **Revise** based on feedback
4. **Iterate** until approved
5. **Merge and monitor**
```

## Optional Frontmatter Fields

Use these optional fields to customize your skill's behavior:

### Tool Scoping Examples

Apply principle of least privilege: only grant tools your skill needs.

```yaml
# Example 1: File processing skill (read/write files, run Python)
---
name: pdf-processor
allowed-tools: Read,Write,Bash(python:*)
---

# Example 2: Git workflow skill (git commands only)
---
name: git-helper
allowed-tools: Bash(git:*)
---

# Example 3: Read-only analysis (inspect code, no execution)
---
name: code-analyzer
allowed-tools: Read,Bash(grep:*,ls:*)
---

# Example 4: Team skill (limited network, file ops only)
---
name: team-doc-generator
version: 1.0.0
allowed-tools: Read,Write,Bash(python:*,curl:*)
---
```

**Key patterns:**
- Specify exact commands: `Bash(git:*)` not `Bash(*)`
- For team skills: minimal permissions
- Never use `Bash(*)` unless absolutely necessary

### Version Field Example

Track your skill's evolution:

```yaml
---
name: my-skill
version: 1.0.0
---
```

Then include in SKILL.md:
```markdown
## Version History

**v1.0.0** (January 2026)
- Initial release with core features
- Comprehensive error handling

**v0.9.0** (December 2025)
- Beta: Community testing
```

## Structure Validation

### Reference File Organization
✅ One level deep:
```
skill-creator/
├── SKILL.md
└── references/
    ├── templates.md
    └── checklist.md
```

❌ Nested chains (avoid):
```
skill-creator/
└── references/
    └── templates/
        └── advanced/
            └── patterns.md
```

### Filename Conventions
- **Main guide:** `complete-guide.md`, `guide.md`, or `reference.md`
- **Task-specific:** `deployment-guide.md`, `troubleshooting.md`
- **Curated lists:** `checklist.md`, `templates.md`, `patterns.md`
- **Data:** `config.md`, `environment-variables.md`

## Token Efficiency Tips

### Do
- Code examples first, explanation second
- Concrete over abstract (use real project names, not "your project")
- Progressive disclosure (essentials → advanced → reference)
- Tables for structured data
- Reference other docs instead of repeating content

### Don't
- Lengthy theory before examples
- Generic placeholder names (use real examples)
- Extraneous sections (README, CHANGELOG, setup guides)
- Nested reference files (keep one level deep)
- Overly detailed troubleshooting (only high-impact issues)
