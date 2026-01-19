# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Purpose

This repository is a **Claude Code plugin** that bundles reusable skills for creating skills and plugins. The plugin is named **skills-toolkit** and provides Agent Skills (auto-activated) and slash commands for managing Claude Code skills and plugins.

**CRITICAL MINDSET:** Skills are instructions FOR CLAUDE, not documentation FOR PEOPLE. When evaluating or improving a skill, the question is always: "Will this help Claude understand and execute the task?" not "Will people find this easy to read?"

**Plugin structure:** This project is organized as a Claude Code plugin with `.claude-plugin/plugin.json` manifest, `skills/` directory for Agent Skills, and `commands/` directory for slash commands.

## Skill Structure

Each skill is a directory containing:

```
skill-name/
├── SKILL.md                    # Required: metadata + instructions (frontmatter + body)
├── scripts/                    # Optional: executable code (Python, shell, etc.)
│   └── script.py
├── references/                 # Optional: documentation Claude loads into context
│   └── api.md
└── assets/                     # Optional: files used in output (images, templates)
    └── template.docx
```

### SKILL.md Format

SKILL.md is the complete instruction set Claude loads and follows when the skill is triggered.

**Frontmatter** (metadata Claude uses for skill discovery and activation):
```yaml
---
name: skill-name                    # lowercase, hyphens, ≤64 chars
description: >-                     # ≤1024 chars, specific trigger phrases
  What the skill does. Use when [trigger contexts/phrases].
version: 1.0.0                      # Optional: semantic version for tracking
allowed-tools: Read,Write,Bash(*)   # Optional: principle of least privilege
---
```

**Body** (instructions Claude executes):
- Clear, procedural guidance for the task
- Examples Claude can reference and adapt
- Important constraints and edge cases Claude must know
- Links to reference files for deeper context when needed
- Target <500 lines; offload detailed content to references/

**Key principle:** Every word in SKILL.md body is loaded when the skill triggers. Keep it focused on what Claude needs to execute the task correctly.

## Plugin Components

### Agent Skills (in `skills/`)
- **skill-creator** - Create and refine Claude Code skills following best practices. Invoked via `/skills-toolkit:create-skill` or auto-activated by Claude when skill-related tasks are detected.
- **plugin-creator** - Create, convert, and validate Claude Code plugins. Invoked via `/skills-toolkit:create-plugin` or auto-activated when plugin-related tasks are detected.

### Slash Commands (in `commands/`)
- `/skills-toolkit:create-skill` - Shortcut to invoke skill-creator skill
- `/skills-toolkit:create-plugin` - Shortcut to invoke plugin-creator skill

## Development Workflow

### Creating a New Skill

1. Create a directory: `skill-name/`
2. Create `SKILL.md` with frontmatter (name + description) and body (instructions)
3. Add `scripts/` if the skill includes reusable code
4. Add `references/` if instructions are lengthy (keep one level deep)
5. Add `assets/` only if outputting files users will interact with

### Best Practices Reference

Consult **building-skills.md** for comprehensive guidance on:
- Writing effective descriptions and trigger phrases
- Progressive disclosure of information
- Workflow patterns (checklists, feedback loops, templates)
- Security and permissions
- Testing and iteration
- Organization patterns by complexity

Key principle: **Context window = public good**. Every token must justify its cost through genuine value to Claude's task execution.

### Plugin Installation

This repository is a Claude Code plugin. Install it with:

```bash
claude plugin install . --scope project
# or
claude plugin install /Users/sergeymoiseev/full-stack.biz/claude-skills --scope project
```

**Testing locally before installation:**
```bash
claude --plugin-dir /Users/sergeymoiseev/full-stack.biz/claude-skills
```

**Plugin structure:**
- **Manifest**: `.claude-plugin/plugin.json` - metadata (name, description, version)
- **Skills**: `skills/` - Agent Skills bundled in plugin (auto-discoverable)
- **Commands**: `commands/` - slash commands that invoke skills
- **Standalone**: `rails-migrations/` - not part of plugin; deploy separately if needed

## Skill Anatomy (Quick Reference)

| Component | Claude's Use | Required? |
|-----------|--------------|-----------|
| `SKILL.md` frontmatter | Discovery (name for reference) + activation (description triggers skill) | Yes |
| `SKILL.md` body | Core instructions Claude follows to execute the task | Yes |
| `scripts/` | Reusable code Claude may reference or invoke | No |
| `references/` | Additional context Claude loads on-demand (zero token penalty until needed) | No |
| `assets/` | Output files Claude produces (not loaded into context during execution) | No |

**Token loading hierarchy** (critical for efficiency):
1. **Frontmatter only** (~100 tokens) - always loaded for skill discovery
2. **SKILL.md body** (~1,500-5,000 tokens) - loaded when skill triggers
3. **References/scripts** (unlimited) - loaded only if Claude determines they're needed

## Common Mistakes to Avoid

❌ **Thinking of skills as end-user documentation**
- Don't write for "readability by people"
- DO write for "Claude's task execution efficiency"
- Example: Don't spend tokens on friendly tone; spend them on clear procedures

❌ **Overloading SKILL.md body with comprehensive guides**
- Don't put 500+ lines of detailed reference in SKILL.md
- DO keep body <500 lines and link to reference files
- Example: Move detailed API docs → `references/api.md`

❌ **Vague or generic descriptions**
- Don't write: "Process files"
- DO write: "Process PDF files with OCR. Use when extracting text or analyzing documents. Supports encrypted PDFs."

❌ **Making design decisions based on how it "looks" or "reads"**
- Don't: "This reads better with an explanation"
- DO: "Will Claude understand this without the explanation?"

## Markdown Code Fence Escaping

When authoring skill examples that show code blocks within code blocks, use these techniques:

**One level of nesting** (code block containing code fence):
- Wrap with 4 backticks (`````) instead of 3
- Example: document JSON that contains a Markdown code block

**Two levels of nesting** (show code fence examples showing code fences):
- Alternate between backticks and tildes
- Outer: 4 backticks (````)
- Inner: 3 backticks (```)
- Wrap inner in tildes: `~~~`

**Arbitrary nesting** (3+ levels):
- Append invisible markers (Left-To-Right Mark, U+200E) to closing fences to differentiate them
- Or use increasing numbers of backticks/tildes

**Practical**: Most skill examples won't need deep nesting. Use 4 backticks for simple nested blocks and reference documentation in separate files for complex examples.

## Design Principles

1. **Conciseness** - Assume Claude's baseline intelligence; only document domain-specific knowledge
2. **Actionable first** - Lead with concrete examples and quick reference before theory
3. **Progressive disclosure** - Start with essentials, link to detailed sections
4. **Clear triggers** - Description determines if skill activates; be specific about when to use it
5. **Token accountability** - Every word in SKILL.md body must justify its presence for Claude's task execution

## Workflow: Adding a New Skill to the Plugin

1. Create skill in `skills/skill-name/`
2. Create `SKILL.md` with frontmatter + instructions
3. (Optional) Create `commands/skill-name.md` slash command if direct user invocation is useful
4. Test locally: `claude --plugin-dir . /skills-toolkit:command`
5. Install plugin: `claude plugin install .`

## Notes for Future Development

- Plugin architecture established; follow `.claude-plugin/` conventions
- Skills are organized within plugin; use `skills/` directory for new additions
- Commands auto-discovered from `commands/` directory
- No automated workflows (validation, etc.) implemented yet
