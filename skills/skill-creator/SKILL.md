---
name: skill-creator
description: >-
  Create, validate, and refine Claude Code skills. Use when: building new skills,
  validating skills against best practices, or improving skill clarity and execution.
  Handles skill structure, frontmatter, activation, references, tool scoping, and
  production readiness. Can also migrate slash commands to skills for better context
  management and subagent support.
version: 1.7.0
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
2. **Important:** If user wants to refine the skill after validation, you will follow `references/refinement-preservation-policy.md` (not just validation workflow)
3. Follow the systematic workflow in `references/validation-workflow.md` (Phase 1-7)
4. Use `references/checklist.md` to identify gaps during Phase 3-6
5. Check `references/allowed-tools.md` if tool scoping is involved
6. Complete workflow + checklist before considering the skill validated

### For Improvements (Refining)

**CRITICAL: Follow `references/refinement-preservation-policy.md` strictly when refining—this skill models the policy it teaches.**

1. **LOCATE the skill first (MANDATORY):** Follow "Locate the Target Skill" workflow above
   - Search current project: `skills/X/`, `.claude/skills/X/`
   - If not in project → check `~/.claude/skills/X/` (warn and confirm if found)
   - If not found anywhere → ask user for source path
   - Cache path? → REFUSE and ask for source
2. Ask user which aspects need improvement (structure, length, triggering, etc.)
3. **GATE 1 - Content Audit:** List ALL existing guidelines, patterns, workflows, examples. Classify each as core (80%+ use) or supplementary (<20% use).
4. **GATE 2 - Capability Assessment:** Will removing/moving content impair execution? If YES, content cannot be deleted—only migrate. If UNCERTAIN, defer to operator.
5. **GATE 3 - Migration Verification (NO GAPS ALLOWED):** See `references/refinement-preservation-policy.md` Gate 3 for mandatory verification checklist. Before moving ANY content:
   - Identify exact text being removed (copy/paste section)
   - Read destination file completely (don't just search)
   - Compare: Is the destination complete? If NOT FOUND in destination, add it NOW before deleting from source
   - Verify links exist and accessibility is preserved
   - Re-read both files after move to ensure no broken references
6. **GATE 4 - Operator Confirmation:** Any content deletion (not migration)? Get explicit operator approval. Rewording/relocation is auto-approved; deletion requires "Should I remove this?" confirmation.
7. **Follow validation workflow** (`references/validation-workflow.md`) to identify all issues systematically
8. **Improve systematically:** frontmatter clarity (activation) → instruction clarity → examples → separate detailed content
9. **Test activation:** Will Claude recognize this description in real requests?
10. **Re-validate** using validation workflow before sign-off
11. **Document reasoning:** Explain which gate applied to each content decision (core procedural vs supplementary)

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

**Base Directory context:** When skill-creator loads, the system shows a "Base directory" path. This points to THIS skill's installed location—use it ONLY for loading skill-creator's own references (`references/templates.md`, etc.). Never use it to locate target skills you're asked to work on. Target skills must be discovered via the "Locate the Target Skill" workflow.
