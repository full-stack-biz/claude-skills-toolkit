---
name: skill-creator
description: >-
  Create, validate, and refine Claude Code skills. Use when: building new skills,
  validating skills against best practices, or improving skill clarity and execution.
  Handles skill structure, frontmatter, activation, references, tool scoping, and
  production readiness. Can also migrate slash commands to skills for better context
  management and subagent support.
version: 1.4.0
allowed-tools: Read,Write,Edit,Glob,Grep,AskUserQuestion
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

**Token Efficiency** — Every token Claude loads must justify its cost. Keep SKILL.md body <500 lines (non-negotiable). Use code examples over prose, tables over lists. Minimize only supplementary content (<20% cases); core procedural content (80%+ cases) must stay. Always follow `references/refinement-preservation-policy.md`; never delete content to reduce line count if it impairs execution. See `references/content-distribution-guide.md` for decisions.

**Token Loading** — Metadata (~100 tokens) always loads. SKILL.md body (~1-5k tokens) loads on trigger. References load on-demand only (zero penalty until needed). Full details: `references/how-skills-work.md`.

**Activation** — Skills trigger via description text alone. Vague descriptions never activate. Specific trigger phrases ("create skill", "validate", "improve") = reliable activation.

## Implementation Approach

**▶️ START HERE - Quick Workflow**

1. Ask: What do you want to do? (create / validate / refine)
2. For create: Gather requirements, then route to "New Skills" section
3. For validate/refine: Ask for skill path, then route to appropriate section
4. For slash command migration: Mention as bonus capability, offer conversion support

**Scope Rules:**

✅ **Allowed scopes:** `skills/` (plugin) | `.claude/skills/` (project-level) | `.claude/skills/` (nested in any subdirectory)

❌ **Forbidden scopes:** `~/.claude/skills/` (user-space — refuse, explain risk) | `~/.claude/plugins/cache/` (installed — refuse immediately)

**For path validation:** If user provides user-space or cached path, refuse with: "This skill-creator only works with project-scoped skills (plugin or `.claude/skills/` directory). User-space skills affect all projects in your user space; edit them separately if needed."

**Scope Detection Flowchart:**

Auto-detect first; only ask when ambiguous:

1. **Auto-detect project type:**
   - Check for `.claude-plugin/plugin.json` (plugin project?)
   - Identify current working directory

2. **If plugin project:**
   - Default: `skills/` directory
   - Only ask if user is clearly working in `.claude/skills/` location

3. **If regular project (no plugin):**
   - At project root? Default: `.claude/skills/`
   - In nested directory? Ask only if scope is unclear

4. **Scope selection (ask only if ambiguous):**
   - Plugin projects: "Plugin (`skills/`) or project-level (`.claude/skills/`)?"
   - Nested directories: "Nested (`.claude/skills/` here) or project-level (`.claude/skills/` at root)?"

5. **Scope confirmation:**
   - Ask: "What do you want to call it?" (e.g., `code-analyzer`, `test-runner`)
   - For validate/refine: "Provide the skill path relative to project root" (e.g., `skills/pdf-processor`, `.claude/skills/pdf-processor`, `packages/frontend/.claude/skills/pdf-processor`)

**Block user-space attempts immediately:**
- If user mentions `~/.claude/skills/` or `~/.claude/plugins/cache/`, refuse with: "This skill-creator only works with project-scoped skills (plugin or `.claude/skills/` directory). User-space skills affect all projects in your user space; edit them separately if needed."

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

1. **Verify scope:** Use scope detection rules from "Allowed scopes" and "Forbidden scopes" subsections above. Refuse if path is from `~/.claude/plugins/cache/` or `~/.claude/`
2. Follow the systematic workflow in `references/validation-workflow.md` (Phase 1-7)
3. Use `references/checklist.md` to identify gaps during Phase 3-6
4. Check `references/allowed-tools.md` if tool scoping is involved
5. Validate: Complete workflow + checklist before considering the skill complete

### For Improvements (Refining)

1. **Verify scope:** Use scope detection rules from "Allowed scopes" and "Forbidden scopes" subsections above. Refuse if installed/cached
2. Ask user which aspects need improvement (structure, length, triggering, etc.)
3. **Follow validation workflow** (`references/validation-workflow.md`) to identify all issues systematically
4. **For length/organization:** Use `references/content-distribution-guide.md` to decide what stays in SKILL.md vs. moves to references. Core procedural content (80%+ cases) stays; supplementary content moves.
5. **Review against checklist** (`references/checklist.md`) during validation; check `references/allowed-tools.md` if tool scoping is involved
6. **Improve systematically:** frontmatter clarity (activation) → instruction clarity → examples → separate detailed content
7. **Test activation:** Will Claude recognize this description in real requests?
8. **Re-validate** using the workflow before considering refinements complete
9. Make targeted improvements rather than rewriting everything

### For Converting Slash Commands to Skills

**Context:** Slash commands (`~/.claude/commands/`) have been merged into Skills in Claude Code. While existing slash commands continue to work, migrating to skills provides:
- Better context management via dynamic file loading
- Access to subagents and context forking
- Progressive disclosure and references
- Project-scoped availability (vs. user-space affecting all projects)

**Detection: When to recommend conversion**

Recommend conversion when user:
- Mentions "slash command" or asks about migrating commands
- Shows a slash command that would benefit from context isolation or subagent delegation
- Works in project needing project-scoped automation (not user-space-wide)
- Wants to use subagents with their command

Recommend user self-convert when they have:
- Simple slash commands (1-10 lines, no complex logic)
- Commands they understand well and can easily port

Offer to do conversion when:
- Complex command logic (control flow, multiple workflows)
- Unclear command purpose or structure
- User needs guidance on skill structure

**Migration workflow:** See `references/slash-command-conversion.md` for complete conversion process, including:
- Detecting command purpose and activation
- Mapping command → skill frontmatter
- Converting command logic to skill instructions
- Restructuring for references/subagents if needed
- Validation after conversion

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

**Refinement is refactoring, not reduction.** Preserve skill functionality while improving clarity. Apply these gates before relocating or deleting content.

**The 80% Rule (core procedural decision):**
- Will Claude execute this in 80%+ of refinement activations? → STAYS in SKILL.md
- Will Claude execute this in <20% of cases? → Can move to references/
- Uncertain? → Defer to operator; keep in SKILL.md by default

**Pre-Refinement Validation Gates:**

1. **Content Audit** — List all existing guidelines, patterns, examples. Classify each as core (80%+ case) or supplementary (edge case).

2. **Capability Assessment** — Will removing content impair execution? If yes, content cannot be deleted. Migrate instead.

3. **Migration Verification** — If moving SKILL.md → references/: verify the reference file exists and is linked from SKILL.md. Verify moved content remains accessible.

4. **Operator Confirmation** — Any deletion (not migration)? Get explicit approval. Ask: "Should I remove this?" Document reason.

**Approval Triggers:**
- **Auto-approved:** Moving supplementary content to references/ (80% rule applied). Consolidating references/ → SKILL.md. Rewording for clarity. Adding examples.
- **Requires approval:** Removing ANY guideline/pattern/example. Reducing coverage (e.g., 4 patterns → 2). Changing scope boundaries. Removing error handling.

**Quick Decision Tree:**
```
Does content relocate?
├─ 80%+ execution use → STAYS in SKILL.md (core procedural)
├─ <20% execution use → Move to references/ (supplementary)
└─ Being DELETED (not relocated)? → Requires operator approval
```

See `references/refinement-preservation-policy.md` for detailed rules, case studies, and examples.

## Reference Guide

**Load when understanding skill fundamentals:**
- `references/how-skills-work.md` — **MUST load:** When user asks why descriptions trigger activation, or you need to explain token loading hierarchy, selection mechanism, or skill architecture (enables user understanding)

**Load when creating a new skill:**
- `references/templates.md` — **MUST load:** After requirements interview, to apply requirements to template structure. Provides copy-paste starting points (basic vs. production, workflow patterns)
- `references/content-guidelines.md` — **MUST load:** When writing skill descriptions/frontmatter, to verify trigger phrases work and check terminology consistency

**Load when validating or improving skills:**
- `references/validation-workflow.md` — **MUST load:** To systematically validate through phases (frontmatter clarity → body clarity → references organization → tool scoping → real-world testing)
- `references/content-distribution-guide.md` — **MUST load:** When refining skill length/organization, to decide what stays in SKILL.md vs. moves to references (prevents incorrectly moving core procedural content)
- `references/refinement-preservation-policy.md` — **MUST load:** When refining existing skills, to enforce preservation gates and approval triggers. Ensures content migration vs. deletion decisions follow the 80% rule and operator approval requirements
- `references/checklist.md` — **MAY load:** To assess skill quality across all dimensions (activation, clarity, token efficiency, error handling, production readiness). Use when systematic quality review needed
- `references/advanced-patterns.md` — **MAY load:** When skill is production/team-use and needs error handling, version history, risk assessment, security review, or advanced patterns

**Load for team/production skill patterns:**
- `references/team-production-patterns.md` — **MAY load:** When creating skills for team environments or production systems. Covers error handling, tool scoping, validation scripts, security review, and documentation patterns for robust execution.

**Load when configuring permissions and structure:**
- `references/allowed-tools.md` — **MUST load:** When determining which tools skill needs or reviewing security/principle of least privilege
- `references/self-containment-principle.md` — **MAY load:** When deciding whether skill has external dependencies, or troubleshooting self-containment violations

**Load when converting slash commands to skills:**
- `references/slash-command-conversion.md` — **MUST load:** When user wants to migrate existing slash commands to skills. Provides detection, mapping, workflow, and validation for conversions

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

**Scope reference:** See "Implementation Approach" section for complete scope detection flowchart. In summary:
- ✅ **Allowed:** `skills/` (plugin), `.claude/skills/` (project root), `.claude/skills/` (nested directories)
- ❌ **Forbidden:** `~/.claude/skills/` (user-space), `~/.claude/plugins/cache/` (installed/cached)
