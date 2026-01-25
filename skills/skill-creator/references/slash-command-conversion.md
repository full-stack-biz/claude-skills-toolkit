# Slash Command to Skill Conversion Guide

## Overview

Slash commands in `~/.claude/commands/` have been merged into Skills. While existing slash commands continue to work, migrating to skills provides better context management, subagent support, and project-scoped automation instead of user-space-wide effects.

## Why Convert?

| Aspect | Slash Command | Skill |
|--------|--------------|-------|
| **Scope** | User-space (`~/.claude/`) affects all projects | Project-scoped (`.claude/skills/` or `skills/`) affects only relevant projects |
| **Context** | Static frontmatter only | Dynamic file loading + references + subagent delegation |
| **Activation** | Fixed syntax `/command-name` | Automatic + user invocation + subagent delegation |
| **Flexibility** | Limited to command line | Full access to skill architecture (scripts, references, subagents) |

**When to recommend conversion:**
- User wants project-specific automation (not user-wide)
- Command would benefit from subagent delegation or context forking
- Complex logic needs organization beyond single file
- User wants Claude to auto-activate on relevant requests (not just explicit `/` invocation)

**When user should self-convert:**
- Simple commands (<15 lines)
- User understands command logic clearly
- No complex control flow or error handling

**When to offer conversion help:**
- Complex command logic (multiple workflows, loops, conditionals)
- Unclear command structure or purpose
- User uncertain about skill structure

---

## Part 1: Analyze the Slash Command

### Step 1a: Locate the Command

Slash commands live in `~/.claude/commands/`. Ask user for the command name or offer to help find it.

**Common patterns:**
- Simple wrapper: `deploy.sh`, `test.sh` (usually <20 lines)
- Complex logic: `audit.sh`, `release.sh` (50+ lines, multiple workflows)
- Integration: `slack-notify.sh`, `ci-trigger.sh` (external dependencies)

### Step 1b: Read and Understand

Read the slash command to understand:
1. **Purpose:** What problem does it solve? (e.g., "run tests and report", "deploy to staging")
2. **Invocation:** How/when is it used? (e.g., "before every commit", "on demand for releases")
3. **Inputs:** Does it take arguments? Environment variables? User prompts?
4. **Logic:** Is it linear (step A → B → C) or conditional (if X then A else B)?
5. **Output:** What does it produce? (logs, files, side effects)
6. **Tools:** What does it depend on? (Bash, git, external APIs)

### Step 1c: Identify Conversion Blockers

Some slash commands may not convert cleanly to skills:

❌ **Requires interactive CLI prompts** (expect keyboard input during execution)
- Workaround: Convert prompts to AskUserQuestion in skill frontmatter

❌ **Heavy reliance on environment variables**
- Workaround: Add to skill description or frontmatter documentation

❌ **Requires file system side effects outside project scope**
- Workaround: Refactor to document intent, verify scope is project-relevant

⚠️ **External service dependencies** (Slack, GitHub API, CI systems)
- Acceptable if tool scoping includes those tools

✅ **Most conversion candidates:**
- File operations (read/write/edit)
- Code analysis (Grep, Glob, Read)
- Task automation (test, lint, format)
- Documentation generation
- Local system operations

---

## Part 2: Map Command to Skill

### Mapping Template

Use this mapping to convert slash command elements → skill frontmatter:

```
Slash Command        →  Skill Element
─────────────────────────────────────
Command name         →  skill name (lowercase, hyphens)
Command description  →  frontmatter description (include trigger phrases)
Command syntax       →  skill activation (auto + user invocation)
Arguments/flags      →  AskUserQuestion (collect inputs before execution)
Environment setup    →  Frontmatter or reference documentation
Main logic           →  SKILL.md body or scripts/
Output/reports       →  Generated in project scope
Dependencies         →  allowed-tools in frontmatter
```

### Example 1: Simple Test Command

**Original slash command** (`~/.claude/commands/test.sh`):
```bash
#!/bin/bash
npm test
echo "Tests complete"
```

**Converted to skill frontmatter:**
```yaml
---
name: test-runner
description: >-
  Run tests and report results. Use when validating code before commit,
  ensuring test coverage, or running specific test suites.
allowed-tools: Bash(npm:*,test:*)
---
```

**SKILL.md body:**
```
## Quick Start

Run all tests:
\`\`\`bash
npm test
\`\`\`

Run specific test file:
\`\`\`bash
npm test -- path/to/test.js
\`\`\`

## Workflows

[Full test workflow instructions...]
```

### Example 2: Complex Release Command

**Original slash command** (`~/.claude/commands/release.sh`):
```bash
#!/bin/bash
set -e
VERSION=$1
if [ -z "$VERSION" ]; then
  echo "Usage: release VERSION"
  exit 1
fi
npm version $VERSION
npm run build
npm publish
git push --tags
```

**Converted to skill:**

```yaml
---
name: release-coordinator
description: >-
  Coordinate releases with versioning, building, and publishing. Use when
  preparing releases, bumping versions, or publishing packages to npm.
allowed-tools: Bash(npm:*,git:*),Read,Write,Edit,Grep
version: 1.0.0
---
```

**SKILL.md body:**
```
## Release Workflow

This skill coordinates package releases with semantic versioning.

### Quick Start

1. Interview user for version bump (major/minor/patch)
2. Run npm version with selected version
3. Build package
4. Publish to npm
5. Push git tags

### Detailed Steps

[Full workflow with error handling, validation, rollback...]

### Use Cases

- **PATCH release:** Bug fixes, security updates, minor docs
- **MINOR release:** New features, non-breaking changes
- **MAJOR release:** Breaking changes, major refactors

[Complete instructions...]
```

---

## Part 3: Convert Logic to Skill Instructions

### Pattern 1: Linear Command → Sequential Instructions

**Command:**
```bash
npm run lint
npm run test
npm run build
```

**Skill instructions:**
```
1. Lint code with ESLint: `npm run lint`
2. Run test suite: `npm test`
3. Build package: `npm run build`
4. Report success or capture failures
```

### Pattern 2: Conditional Command → Workflows with Branches

**Command:**
```bash
if [ "$ENV" = "prod" ]; then
  npm run build:prod
else
  npm run build:dev
fi
```

**Skill instructions:**
```
## Workflows

### Production Build
1. Ask user: "Confirm production build?"
2. Set environment to production
3. Run build:prod

### Development Build
1. Run build:dev
2. Report to developer
```

### Pattern 3: Argument Processing → AskUserQuestion

**Command:**
```bash
SKIP_TESTS=$1
if [ "$SKIP_TESTS" = "--skip-tests" ]; then
  npm run build
else
  npm test && npm run build
fi
```

**Skill frontmatter:**
```yaml
---
name: build-package
description: >-
  Build package with optional test skipping. Use when preparing releases
  or building for deployment.
---
```

**SKILL.md body:**
```
Ask user:
1. "Run tests before build?" (Yes/No)

Then:
- If yes: npm test && npm run build
- If no: npm run build
```

---

## Part 4: Determine Skill Location

### Rule: Where should the converted skill live?

**Plugin projects** (has `.claude-plugin/plugin.json`):
- Plugin-specific skills: `skills/skill-name/` (bundled with plugin)
- Project-level skills: `.claude/skills/skill-name/` (available across project)

**Regular projects**:
- Project-level skills: `.claude/skills/skill-name/` (available project-wide)
- Nested skills: `packages/frontend/.claude/skills/skill-name/` (auto-discovered in subdirectory)

**User-space migration:**
- NOT recommended: Don't convert to `~/.claude/skills/`
- Reason: Original slash command was user-space-wide; better to make project-scoped to avoid affecting unrelated projects
- Exception: If user specifically needs user-space availability after conversion, they can copy the skill directory manually

---

## Part 5: Structure the Converted Skill

### Minimal Structure (Simple Command)

```
skill-name/
├── SKILL.md          # Frontmatter + instructions
└── (no other files)
```

### Standard Structure (Complex Command)

```
skill-name/
├── SKILL.md          # Frontmatter + Quick Start + key workflows
├── scripts/
│   ├── validate.sh   # Pre-execution validation
│   └── helpers.sh    # Reusable functions
└── references/
    ├── workflows.md  # Detailed workflow documentation
    └── configuration.md  # Setup and config guide
```

### Full Structure (Production Command)

```
skill-name/
├── SKILL.md          # Frontmatter + overview
├── scripts/
│   ├── main.sh       # Primary logic
│   ├── validate.sh   # Input validation
│   ├── error-handler.sh  # Error recovery
│   └── cleanup.sh    # Resource cleanup
├── references/
│   ├── workflows.md  # All workflow patterns
│   ├── error-handling.md  # Error scenarios
│   ├── faq.md        # Common questions
│   └── examples.md   # Real-world examples
└── assets/
    └── report-template.html  # Output template
```

**Key principle:** Keep SKILL.md <500 lines. Move detailed workflows/references to separate files.

---

## Part 6: Validation After Conversion

### Checklist

Use this checklist to validate the converted skill:

- [ ] **Frontmatter complete:** name, description with trigger phrases
- [ ] **Purpose clear:** Anyone reading description understands what skill does
- [ ] **Activation works:** Description includes phrases Claude will recognize
- [ ] **Instructions executable:** SKILL.md body is concrete and procedural
- [ ] **Tool scoping correct:** only necessary tools in allowed-tools
- [ ] **Structure clean:** SKILL.md <500 lines, references organized
- [ ] **Examples present:** Code examples users/Claude can adapt
- [ ] **Error handling:** Clear guidance for failure scenarios
- [ ] **Self-contained:** All necessary context in skill directory (no external refs)
- [ ] **Tested:** Works when invoked with `/skill-name` or via AskUserQuestion

### Testing Protocol

1. **Direct invocation:** `/skill-name` via CLI
2. **Context triggering:** Request that mentions description trigger phrases
3. **Error case:** What happens if prerequisites fail? (e.g., repo not initialized, file missing)
4. **Boundary conditions:** Edge cases (empty input, unusual project structure)

---

## Part 7: Migration Path Decision

After conversion, decide on the migration path:

### Option A: Replace Slash Command

1. Validate converted skill thoroughly
2. Delete original slash command from `~/.claude/commands/`
3. Update project documentation to reference skill name instead of `/` syntax
4. Users invoke with `/skill-name` (same syntax, different implementation)

### Option B: Keep Both (Transition Period)

1. Keep original slash command in `~/.claude/commands/` (still works)
2. Announce skill version to team
3. Migrate users gradually over 1-2 weeks
4. Delete original command after transition period

### Option C: Install as Plugin (Team Use)

1. If skill is team-shared:
   - Copy to plugin `skills/` directory
   - Update plugin manifest
   - Publish plugin
2. Teams install with `claude plugin install`
3. Skill available to all team members automatically

---

## Part 8: Documentation & Handoff

After conversion, document:

### For Users

```markdown
# Migrated: skill-name

This skill replaced the `/skill-name` slash command.

## What Changed
- Auto-activation on relevant requests (in addition to `/skill-name` invocation)
- Better error messaging and edge case handling
- [Any new features or improvements]

## Migration
- Old syntax still works: `/skill-name`
- New syntax available: `/skill-name` or auto-triggered
- Project-scoped (affects only this project, not user-space)
```

### For Documentation

Update CLAUDE.md or project README:
```markdown
## Automation Skills

This project includes the following skills:

- **skill-name** - [Description]. Invoke with `/skill-name` or auto-triggered on [trigger context].
  Location: `.claude/skills/skill-name/`
```

---

## Common Conversion Pitfalls

### ❌ Pitfall 1: Losing Command Semantics

**Wrong:** Converting `npm test` command to "Run all tests in the repository"
- Scope blurs (what counts as "all"?)
- Claude won't activate on edge cases

**Right:** "Run npm test suite with coverage reporting. Activates on test requests."
- Specific (npm test, not other tools)
- Clear activation signal (test requests)

### ❌ Pitfall 2: Overfitting to Original Command

**Wrong:** Recreating exact bash logic in skill instructions
- Skill instructions != bash scripts
- Instructions are for Claude, not for literal shell execution

**Right:** Translate bash logic into procedural steps
- "If repository has package.json, run npm test"
- "If repository has pyproject.toml, run pytest"

### ❌ Pitfall 3: Forgetting Progressive Disclosure

**Wrong:** Putting all command logic in SKILL.md (500+ lines)
- Claude loads entire thing every activation
- Token waste

**Right:** Quick Start in SKILL.md, detailed workflows in references/
- Core 80% in SKILL.md
- Advanced 20% in references/

### ❌ Pitfall 4: User-Space Bias

**Wrong:** Converting to `~/.claude/skills/` because "original was user-space"
- Perpetuates user-wide scope
- Affects unrelated projects

**Right:** Convert to `.claude/skills/` or `skills/` (project-scoped)
- Better isolation
- User can manually copy to user-space if needed

---

## Quick Reference: Conversion Checklist

| Step | Task | Done? |
|------|------|-------|
| 1 | Locate slash command in `~/.claude/commands/` | ☐ |
| 2 | Read command, understand purpose/logic | ☐ |
| 3 | Check for conversion blockers | ☐ |
| 4 | Create skill directory structure | ☐ |
| 5 | Write frontmatter (name, description) | ☐ |
| 6 | Convert command logic to skill instructions | ☐ |
| 7 | Organize references (if needed) | ☐ |
| 8 | Test skill invocation | ☐ |
| 9 | Validate activation with trigger phrases | ☐ |
| 10 | Document migration path | ☐ |

---

## Examples by Complexity

### Tiny: Deploy Script

**Original:** 5 lines, straight bash
**Conversion time:** 5 minutes
**Outcome:** Minimal skill, no references

### Small: Test Runner

**Original:** 15 lines, linear logic
**Conversion time:** 15 minutes
**Outcome:** SKILL.md + basic references/

### Medium: Release Coordinator

**Original:** 40 lines, conditional logic, error handling
**Conversion time:** 30-45 minutes
**Outcome:** SKILL.md + scripts/ + references/

### Large: CI/CD Pipeline

**Original:** 100+ lines, multiple workflows, integrations
**Conversion time:** 2+ hours
**Outcome:** Full structure + subagent delegation for complex steps

---

## Need Help?

If during conversion you:
- **Find unclear command logic** → Ask user to explain original purpose
- **Hit conversion blockers** → Refactor command or document workarounds
- **Struggle with activation phrases** → Load `references/content-guidelines.md`
- **Are unsure about tool scoping** → Load `references/allowed-tools.md`
- **Need structural guidance** → Load `references/templates.md`
