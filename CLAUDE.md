# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Purpose

This repository is a **Claude Code plugin** that bundles reusable skills for creating skills and plugins. The plugin is named **skills-toolkit** and provides Agent Skills that can be auto-activated by Claude or invoked directly with `/skills-toolkit:skill-name` slash commands.

**CRITICAL MINDSET:** Skills are instructions FOR CLAUDE, not documentation FOR PEOPLE. When evaluating or improving a skill, the question is always: "Will this help Claude understand and execute the task?" not "Will people find this easy to read?"

**Plugin structure:** This project is organized as a Claude Code plugin with `.claude-plugin/plugin.json` manifest and `skills/` directory for Agent Skills. Skills control invocation behavior through frontmatter (see [Control who invokes a skill](#control-who-invokes-a-skill) below).

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
Skills are discoverable and invocable via both auto-activation and direct `/` commands:

- **skill-creator** - Create and refine Claude Code skills following best practices. Claude auto-activates when detecting skill-related tasks; users can invoke directly with `/skills-toolkit:create-skill`.
- **plugin-creator** - Create, convert, and validate Claude Code plugins. Claude auto-activates when detecting plugin-related tasks; users can invoke directly with `/skills-toolkit:create-plugin`.
- **subagent-creator** - Create, validate, and refine Claude Code subagents. Claude auto-activates for subagent delegation tasks; users can invoke with `/skills-toolkit:create-subagent`.
- **hook-creator** - Create, validate, and refine hooks for automating workflows. Claude auto-activates for hook-related work; users can invoke with `/skills-toolkit:create-hook`.

No separate command files are needed—skills use frontmatter to control invocation behavior.

## Known Limitation: Knowledge Duplication & Future Refactoring

### Current State

This toolkit has intentional **knowledge duplication** that respects Claude's official architecture:

- `plugin-creator` includes summaries of skill/subagent/hook knowledge in `references/`
- These overlap with the full guidance in `skill-creator/`, `subagent-creator/`, and `hook-creator/`
- This duplication follows the **Bounded Scope Principle** (see `skills/skill-creator/references/bounded-scope-principle.md`)

**Why?** Claude's official architecture does not support skill-to-skill delegation as a first-class feature. Each skill must be completely self-contained within its directory structure. This is documented in [Claude Code Skills documentation](https://code.claude.com/docs/en/skills).

### Future Improvement Path

When Claude implements full support for `context: fork` skill execution ([Feature request on GitHub](https://github.com/anthropics/claude-code/issues/17283)), we can refactor for Single Responsibility Principle:

```yaml
# Future: When context: fork fully works for skills
---
name: plugin-creator
description: Create and organize plugins with proper structure
context: fork  # ← Delegate complex tasks to subagents
agent: general-purpose
---

# plugin-creator focuses on: manifest, directory layout, CLI
# Delegates to: skill-creator, subagent-creator, hook-creator for component knowledge
```

This will enable:
- Reduced duplication in `plugin-creator/references/`
- True Single Responsibility Principle (SRP)
- Knowledge owned by one specialist (skill-creator owns skill knowledge)
- `plugin-creator` focuses solely on plugin structure

### What This Means

**For Users:**
- Current behavior unchanged: `/plugin-creator` works as-is
- Direct skill invocation works as-is
- No changes required to your usage

**For Contributors:**
- Don't try to eliminate duplication by sharing files (violates bounded scope)
- When updating skill knowledge, update both the specialist skill AND the summary in plugin-creator
- Watch for the Claude feature request resolution; we'll refactor when possible

**For Agents (You, Claude):**
- Bounded scope design is intentional, not a bug
- Duplication exists because the architecture demands it (for now)
- This will improve when Claude's skill delegation becomes stable

### References

- Official principle: [Bounded Scope Principle for Skills](skills/skill-creator/references/bounded-scope-principle.md)
- Claude docs: [Extend Claude with skills](https://code.claude.com/docs/en/skills)
- Tracking: [GitHub issue for context: fork support](https://github.com/anthropics/claude-code/issues/17283)

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
- **Skills**: `skills/` - Agent Skills bundled in plugin (auto-discoverable with `/` command support)

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
2. Create `SKILL.md` with frontmatter (including `name`, `description`, and invocation controls) + instructions
3. Use frontmatter fields to control invocation:
   - Default: Both Claude auto-activation and `/` command invocation enabled
   - `disable-model-invocation: true` - Only users can invoke (e.g., for `/deploy`, `/commit`)
   - `user-invocable: false` - Only Claude can invoke (e.g., for background context skills)
4. Test locally: `claude --plugin-dir . /skills-toolkit:skill-name`
5. Install plugin: `claude plugin install .`

## Version Release Process

For detailed release process guidance, use the `/dev-flow:release-process` skill.

### Key Principle: Skill Versions Are Independent

Each skill in this toolkit maintains its own independent semantic version (in `SKILL.md` frontmatter). Skill versions do NOT automatically sync with the plugin version—they evolve based on the skill's own changes:

- **Skill version bumps** happen when:
  - PATCH: Bug fixes, wording improvements, reference updates to that specific skill
  - MINOR: New capabilities or expanded tool access in that skill
  - MAJOR: Breaking changes to that skill's behavior or interface

- **Plugin version bumps** happen when:
  - PATCH: Any included skill gets a PATCH bump, or bug fixes to plugin manifest/structure
  - MINOR: Any included skill gets a MINOR bump, or skills are added/removed
  - MAJOR: Any included skill gets a MAJOR bump, or breaking changes to plugin structure

## Control who invokes a skill

Skills support frontmatter fields to control invocation behavior:

- **`disable-model-invocation: true`** - Only you can invoke via `/skill-name`. Use for workflows with side effects (e.g., `/deploy`, `/commit`, `/send-slack-message`). Prevents Claude from triggering these automatically.
- **`user-invocable: false`** - Only Claude can invoke. Use for background knowledge skills that shouldn't be directly actionable (e.g., a `legacy-system-context` skill that teaches Claude about old systems).
- **(default)** - Both you and Claude can invoke. Skill description always in context; Claude loads full skill when relevant.

## Notes for Future Development

- Plugin architecture established; follow `.claude-plugin/` conventions
- Skills are organized within plugin; use `skills/` directory for new additions
- Legacy `commands/` directory can be deprecated; use skill frontmatter instead
- No automated workflows (validation, etc.) implemented yet
