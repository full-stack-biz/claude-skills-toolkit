---
name: skill-creator
description: >-
  Create, validate, and refine Claude Code skills. Use when: building new skills,
  validating skills against best practices, or improving skill clarity and execution.
  Handles skill structure, frontmatter, activation, references, tool scoping, and
  production readiness. Can also migrate slash commands to skills for better context
  management and subagent support.
version: 1.9.0
allowed-tools: Read,Write,Edit,Glob,Grep,AskUserQuestion
hooks:
  PreToolUse:
    - matcher: "^(Write|Edit)$"
      hooks:
        - type: command
          command: "${CLAUDE_PLUGIN_ROOT}/skills/skill-creator/scripts/backup-skill.sh"
          args:
            - "${FILE_PATH}"
          timeout: 3000
  PostToolUse:
    - matcher: "^(Write|Edit)$"
      hooks:
        - type: prompt
          prompt: |
            You are validating a skill refinement. Compare the original skill content with the refined version to detect if important content was completely dropped without being preserved elsewhere.

            ORIGINAL CONTENT:
            ```
            ${ORIGINAL_CONTENT}
            ```

            REFINED CONTENT:
            ```
            ${REFINED_CONTENT}
            ```

            Analyze:
            1. Was any content completely dropped (not moved to references/, not reorganized)?
            2. If duplication was removed: This is OK.
            3. If content moved to references/: This is OK.
            4. If sections reorganized: This is OK.
            5. If content is just gone with no preservation: This is NOT OK.

            Respond with JSON only (no additional text):
            {
              "dropped": true/false,
              "what": "description of what was dropped (or 'none' if ok)",
              "why_matters": "explanation of impact if dropped (or 'n/a' if ok)",
              "ok": true/false
            }
          timeout: 15000
        - type: command
          command: "${CLAUDE_PLUGIN_ROOT}/skills/skill-creator/scripts/cleanup-backup.sh"
          timeout: 2000
---

# Skill Creator

**Dual purpose:** Create skills right the first time OR elevate existing skills to best practices.

## Quick Start

Ask what the user wants: create, validate, refine, or convert slash commands. Then route to the section below.

---

## Core Use Cases

**Create new skills** - Build from scratch with correct structure, naming, frontmatter, and validation guidance.
**Validate existing skills** - Check against best practices (structure, activation clarity, token efficiency, tool scoping).
**Improve skills** - Refine activation, clarity, organization, or efficiency of existing skills.
**Convert slash commands** - Migrate existing `~/.claude/commands/` slash commands to project-scoped skills (bonus capability; better context management, subagent support).
**Team/production skills** - Ensure robustness with error handling, tool scoping, and version tracking.

## Mindset

**CRITICAL:** Skills are instructions FOR CLAUDE, not documentation FOR PEOPLE. Always ask: "Will this help Claude execute the task?" not "Will people find this readable?"

## Core Principles

These principles apply to all skill creation and validation work—the foundational mental model Claude must follow.

**Self-Containment** — Skills must be self-contained. Claude needs everything within the skill directory (references, scripts, examples). Avoid external references or network dependencies unless core to the skill's purpose. See `references/self-containment-principle.md` for complete guidance.

**Progressive Disclosure** — Essential execution instructions first (Quick Start), detailed guidance second (references/), advanced topics last. Quick reference patterns solve 80% of task variants without loading auxiliary files.

**Token Efficiency** — Every token Claude loads must justify its cost. Keep SKILL.md body <500 lines (non-negotiable). Use code examples over prose, tables over lists. Minimize only supplementary content (<20% cases); core procedural content (80%+ cases) must stay. Follow `references/skill-workflow.md` for content distribution and preservation rules; never delete content to reduce line count if it impairs execution.

**Token Loading** — Metadata (~100 tokens) always loads. SKILL.md body (~1-5k tokens) loads on trigger. References load on-demand only (zero penalty until needed). Full details: `references/how-skills-work.md`.

**Activation** — Skills trigger via description text alone. Vague descriptions never activate. Specific trigger phrases ("create skill", "validate", "improve") = reliable activation.

## Implementation Approach

**▶️ START HERE - Quick Workflow**

1. Ask: What do you want to do? (create / validate / refine)
2. For create: Gather requirements, then route to "New Skills" section
3. For validate/refine: Search project first → user-space second → ask only if not found (see "Locate Target Skill" below)
4. For slash command migration: Mention as bonus capability, offer conversion support

**BEFORE ANY OPERATION - Locate the Target Skill:**

When user mentions a skill by name (e.g., "refine plugin-creator"):

1. **Search CURRENT PROJECT first (preferred):**
   ```
   skills/skill-name/SKILL.md
   .claude/skills/skill-name/SKILL.md
   packages/*/skills/skill-name/SKILL.md
   ```

2. **If found in project** → Use that path (source confirmed)

3. **If NOT found in project** → Search user-space:
   ```
   ~/.claude/skills/skill-name/SKILL.md
   ```

4. **If found in user-space** → Warn and confirm:
   > "I found `skill-name` in `~/.claude/skills/` (user-space, affects all projects).
   > It's not in this project. Do you want to:
   > - Edit the user-space copy directly?
   > - Copy it to this project first, then edit?"

5. **If NOT found anywhere** → Ask user:
   > "I couldn't find `skill-name` in this project or user-space. Where is the source?"

6. **NEVER search or use:**
   - `~/.claude/plugins/cache/*` (installed copies - read-only)
   - Skill's own base directory (that's for THIS skill's references only)

**Note:** The "Base directory" shown when this skill loads points to THIS skill's location for accessing its own references. Never use it to locate target skills.

---

**Scope Rules: Source Code Only (NO CACHE EDITS)**

✅ **PREFERRED - Project paths (search first):**
- `skills/skill-name/` in plugin projects
- `.claude/skills/skill-name/` in any project
- `packages/*/skills/skill-name/` (monorepo patterns)

⚠️ **CONDITIONAL - User-space (only if not in project):**
- `~/.claude/skills/skill-name/` - Warn: "Affects all projects"
- Requires explicit user confirmation before editing
- Offer to copy to project instead

❌ **FORBIDDEN - Never edit (REFUSE IMMEDIATELY):**
- `~/.claude/plugins/cache/*` (installed plugins - Claude-managed)
- Any path containing `/cache/` (always read-only)

**Search Priority:**
```
1. Current project     → Edit directly (preferred)
2. User-space          → Warn + confirm (conditional)
3. Cache               → REFUSE (never)
4. Not found           → Ask user for source path
```

**For NEW skills (scope detection):**
- Plugin project? → Default: `skills/skill-name/`
- Regular project? → Default: `.claude/skills/skill-name/`
- Ask only if ambiguous

### For New Skills: Requirements Interview First

After routing to "create", **interview the user to gather requirements** using AskUserQuestion. This ensures the skill will activate correctly and Claude will execute it effectively:

1. **Skill purpose** - What domain-specific task should Claude execute? What problem does this solve?
2. **Trigger phrases** - What phrases will Claude see in requests when this skill should activate?
3. **Scope & constraints** - What's IN scope for Claude to execute? What's OUT of scope?
4. **Tool needs** - Which tools will Claude need (file operations, Bash, network access)?
5. **Team/production** - Will multiple Claude instances use this? Production data involved?
6. **Complexity** - Will Claude need scripts to reference? Reference files? Multiple workflows?

Then use `references/templates.md` to apply requirements to the appropriate template structure.

### For Existing Skills (Validating)

1. **LOCATE the skill first (MANDATORY):** Follow "Locate the Target Skill" workflow above
   - Search current project: `skills/X/`, `.claude/skills/X/`
   - If not in project → check `~/.claude/skills/X/` (warn and confirm if found)
   - If not found anywhere → ask user for source path
   - Cache path? → REFUSE and ask for source
2. **Load `references/skill-workflow.md`** — Contains unified validation workflow (Part 3) and preservation gates
3. Follow the systematic workflow: Phase 1-7 (File Inventory → Read All → Frontmatter → Body → References → Tools → Testing)
4. Use `references/checklist.md` for additional quality assessment
5. Check `references/allowed-tools.md` if tool scoping is involved
6. Complete workflow before considering the skill validated

### For Improvements (Refining)

**CRITICAL: Load `references/skill-workflow.md` and follow it strictly when refining—this skill models the workflow it teaches.**

1. **LOCATE the skill first (MANDATORY):** Follow "Locate the Target Skill" workflow above
   - Search current project: `skills/X/`, `.claude/skills/X/`
   - If not in project → check `~/.claude/skills/X/` (warn and confirm if found)
   - If not found anywhere → ask user for source path
   - Cache path? → REFUSE and ask for source
2. Ask user which aspects need improvement (structure, length, triggering, etc.)
3. **Load `references/skill-workflow.md`** — Contains the unified workflow with preservation gates and validation phases
4. **Run Preservation Gates (Part 2 of skill-workflow.md) BEFORE making changes:**
   - **GATE 1 - Content Audit:** List ALL existing content. Classify as core (80%+) or supplementary (<20%).
   - **GATE 2 - Capability Assessment:** Will changes impair execution? If YES → cannot delete, only migrate.
   - **GATE 3 - Migration Verification:** Before moving content, verify destination exists and is complete. NO GAPS.
   - **GATE 4 - Operator Confirmation:** Deletions require explicit approval. Migrations are auto-approved.
5. Make changes following the 80% rule (Part 1 of skill-workflow.md)
6. **Run Validation Workflow (Part 3 of skill-workflow.md) AFTER changes:**
   - Phase 1-7: File Inventory → Read All → Frontmatter → Body → References → Tools → Testing
7. **Test activation:** Will Claude recognize this description in real requests?
8. **Document reasoning:** Explain which gate applied to each content decision

### For Converting Slash Commands to Skills

**Shorthand:** Recommend skill migration for complex commands or team/project-scoped automation. Self-convert simple commands (1-10 lines); offer help for complex logic or unclear structure.

**Full conversion workflow:** See `references/slash-command-conversion.md` for detection, mapping, conversion logic, and validation process.

## Outcome Metrics

Measure success by whether Claude will execute the skill effectively:

✅ **Structure** - Claude can execute 80% of cases from Quick Start alone (no references needed)
✅ **Activation** - Description includes trigger phrases Claude will recognize; skill activates when needed
✅ **Token efficiency** - SKILL.md body <500 lines; Claude doesn't waste tokens on unnecessary content
✅ **Clarity** - Instructions are concrete and procedural (Claude knows exactly what to execute)
✅ **Completeness** - All required frontmatter present (name, description for activation)
✅ **Tool scoping** - Only necessary tools declared (principle of least privilege for security)
✅ **Testing** - Validated with both Haiku and Opus; works with real-world example requests

## Quick Start: Creating a New Skill

**Step 1: Create directory structure**
```bash
mkdir -p skill-name/references
```

**Step 2: Write frontmatter**
Create `SKILL.md` with required metadata. Frontmatter is what Claude reads to discover and activate skills:
```yaml
---
name: skill-name
description: >-
  What the skill does. Use when [trigger context]. Constraints/scope.
---
```

Guidelines for Claude's activation:
- name: lowercase, hyphens, ≤64 chars, no "anthropic"/"claude" (Claude uses this to reference the skill)
- description: ≤1024 chars, must include trigger phrases Claude will recognize in requests

**Step 3: Write SKILL.md body**
Write instructions Claude will follow to execute the task. Structure: Quick Start → Workflows → Key Notes → Full Reference (optional)
- Keep <500 lines (Claude reads this body every time skill triggers; token efficiency is mandatory)
- Code-first: examples Claude can adapt before abstract explanations
- Progressive disclosure: essentials Claude needs immediately → advanced topics later

**Step 4: Add references (if needed)**
Create `references/` subdirectories for:
- **Comprehensive guides** (>100 lines): include table of contents
- **Templates or configuration**: structured reference material
- One level deep only (no nested chains)

**Step 5: Validate**
Use the checklist in `references/checklist.md` to verify quality before deployment.

## ⚠️ CRITICAL: Refinement Preservation Rules

**Refinement is refactoring, not reduction.** Preserve skill functionality while improving clarity. Load `references/skill-workflow.md` for the complete unified workflow.

**The 80% Rule (core procedural decision):**
- Will Claude execute this in 80%+ of skill activations? → STAYS in SKILL.md
- Will Claude execute this in <20% of cases? → Can move to references/
- Uncertain? → Defer to operator; keep in SKILL.md by default

**Pre-Refinement Gates (summary — see skill-workflow.md Part 2 for full details):**

1. **Content Audit** — List all existing content. Classify as core (80%+) or supplementary (<20%).
2. **Capability Assessment** — Will changes impair execution? If yes → cannot delete, only migrate.
3. **Migration Verification** — Before moving, verify destination exists and content is complete. NO GAPS.
4. **Operator Confirmation** — Deletions require explicit approval. Migrations are auto-approved.

**Quick Decision Tree:**
```
Is content used in 80%+ of activations?
├─ YES → STAYS in SKILL.md (core procedural)
├─ NO → Can MOVE to references/ (supplementary)
└─ Being DELETED? → Requires operator approval
```

**See `references/skill-workflow.md`** for the complete unified workflow including content distribution rules, preservation gates, and validation phases.

## Reference Guide

**Primary workflow reference (load for ANY skill work):**
- `references/skill-workflow.md` — **MUST load:** Unified workflow for creating, validating, and refining skills. Contains content distribution (80% rule), preservation gates (4 gates), and validation phases (7 phases). This is the single authoritative workflow.

**Load when understanding skill fundamentals:**
- `references/how-skills-work.md` — When user asks about token loading, activation mechanism, or skill architecture

**Load when creating a new skill:**
- `references/templates.md` — **MUST load:** After requirements interview, provides copy-paste starting points
- `references/content-guidelines.md` — When writing descriptions/frontmatter, to verify trigger phrases

**Load when validating or improving skills:**
- `references/checklist.md` — Additional quality assessment across all dimensions
- `references/advanced-patterns.md` — When skill needs production patterns (error handling, version history, security)

**Load for team/production skill patterns:**
- `references/team-production-patterns.md` — Error handling, tool scoping, validation scripts for team environments

**Load when configuring permissions and structure:**
- `references/allowed-tools.md` — **MUST load:** When determining tool scoping or reviewing security
- `references/self-containment-principle.md` — When deciding about external dependencies (architectural background)

**Load when converting slash commands to skills:**
- `references/slash-command-conversion.md` — Detection, mapping, and conversion workflow

## Key Notes

**Frontmatter (Claude reads this to discover and activate skills):**
- YAML syntax (use triple dashes: `---`)
- `name`: Optional (uses directory name if omitted), lowercase-hyphen, ≤64 chars, no "anthropic"/"claude"
- `description`: Recommended, ≤1024 chars, must include specific trigger phrases Claude recognizes
- Description is Claude's activation signal (vague descriptions = skill never activates)

**Optional frontmatter (for team/production skills):**
- `version: 1.0.0` — Track skill evolution for team coordination
- `allowed-tools: Read,Write,Bash(git:*)` — Apply principle of least privilege (see `references/allowed-tools.md`)
- See `references/templates.md` for tool scoping examples

**Naming conventions:**
- Hyphen-separated lowercase: `skill-name`, `my-feature-validator`
- Prefer gerund form: `processing-pdfs`, `analyzing-spreadsheets`
- Include action/domain: `test-runner`, `skill-creator`, `code-reviewer`
- Avoid generic: prefer `log-analyzer` over `analyzer`

**Description formula (Claude uses this to decide whether to activate the skill):**
```
[Action]. Use when [trigger contexts]. [Scope/constraints].
```
Example: "Run tests and generate reports. Use when validating code before commit. Supports PHPUnit and Jest."

The description must contain phrases Claude will see in user requests. If the description is vague, Claude won't activate the skill when needed.

**Team/Production considerations:** For skills used in team environments or with production data, ensure robust error handling, tool scoping, validation scripts, security review, and clear documentation. See `references/team-production-patterns.md` for detailed guidance on these patterns, plus `references/advanced-patterns.md` and `references/checklist.md` for additional requirements.

**Content distribution rule:** Keep SKILL.md <500 lines. Add >50 lines? Create reference file instead. Reference files have zero token penalty until needed.

**Base Directory context:** When skill-creator loads, the system shows a "Base directory" path. This points to THIS skill's installed location—use it ONLY for loading skill-creator's own references (`references/templates.md`, etc.). Never use it to locate target skills you're asked to work on. Target skills must be discovered via the "Locate the Target Skill" workflow.
