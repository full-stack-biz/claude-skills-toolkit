---
name: skill-creator
description: >-
  Create, validate, and refine Claude Code skills. Use when: building a new skill,
  validating an existing skill against best practices, or improving a skill's
  clarity and execution. Handles skill structure, frontmatter, activation,
  references, tool scoping, and production readiness.
version: 1.2.0
allowed-tools: Read,Write,Edit,Glob,Grep,AskUserQuestion
---

# Skill Creator

**Dual purpose:** Create skills right the first time OR elevate existing skills to best practices.

## Quick Routing

Use AskUserQuestion to gather requirements, then proceed to the appropriate section below:

1. Ask what the user wants to do (create/validate/refine)
2. Ask for the skill name or path based on the action
3. Route to the appropriate workflow section

---

## Use Cases

**Create new skills** - Build from scratch with correct structure, naming, frontmatter, and validation guidance.
**Validate existing skills** - Check against best practices (structure, activation clarity, token efficiency, tool scoping).
**Improve skills** - Refine activation, clarity, organization, or efficiency of existing skills.
**Team/production skills** - Ensure robustness with error handling, tool scoping, and version tracking.

## Mindset

**CRITICAL:** Skills are instructions FOR CLAUDE, not documentation FOR PEOPLE. Always ask: "Will this help Claude execute the task?" not "Will people find this readable?"

## Foundation: Three Key Concepts

**Token loading:** Metadata (~100 tokens) always loads. SKILL.md body (~1-5k tokens) loads on trigger. References load on-demand only (zero penalty until needed).

**Activation:** Skills trigger via description text alone. Vague descriptions never activate. Specific trigger phrases ("create skill", "validate", "improve") = reliable activation.

**Efficiency:** Keep SKILL.md body <500 lines (non-negotiable). Quick Start ideally handles 80% of cases. Decide what stays vs. moves: ask "Will Claude execute this in 80%+ of cases?" Core procedural content (patterns, workflows, copyable examples) stays. Supplementary content (edge cases, alternatives, adjacent context) moves to references. See `references/content-distribution-guide.md` for the decision tree.

Full details: See `references/how-skills-work.md`.

## THE EXACT PROMPT

When creating or improving a skill, use this exact request:

```
Use skill-creator to [create/validate/improve] my [skill-name] skill.
Focus on: [specific area - e.g., "SKILL.md structure", "allowed-tools setup", "reference organization"]
```

Examples:
- "Use skill-creator to create my pdf-processor skill"
- "Use skill-creator to validate my test-runner skill against best practices"
- "Use skill-creator to improve my code-analyzer skill, focus on token efficiency"

## Implementation Approach

**⚠️ CRITICAL: Scope Detection & Clarification**

Only ask about scope when there's actual ambiguity. Detect where user is working first.

**Allowed scopes (what skill-creator will create/edit):**
- **Plugin skills**: `skills/` directory in Claude plugin projects (has `.claude-plugin/plugin.json`)
- **Project-level skills**: `.claude/skills/` at project root (discovered everywhere in project)
- **Nested skills**: `.claude/skills/` in any subdirectory (auto-discovered when editing files there, e.g., `packages/frontend/.claude/skills/`)

**Forbidden scopes (skill-creator will refuse):**
- **User-space skills**: `~/.claude/skills/` — REFUSE all creation/editing attempts. Risk: affecting user-space configuration, impacting all projects using these skills
- **Installed/cached skills**: `~/.claude/plugins/cache/`, plugin installation directories — REFUSE all editing attempts
- If user provides a path to user-space or installed location, refuse and explain: "This skill-creator only works with project-scoped skills (plugin or `.claude/skills/` directory). User-space skills in `~/.claude/skills/` should not be edited here—they affect all projects in your user space."

**START HERE - Scope Detection & Clarification Flow:**

1. **Ask Question 1: Action type**
   - Create a new skill (Recommended)
   - Validate an existing skill
   - Refine a skill

2. **AUTO-DETECT: Where is user working?**
   - Determine current working directory
   - Is user in project root? Or a nested directory (e.g., `packages/frontend/`, `services/api/`)?

3. **AUTO-DETECT: Is this a Claude plugin project?**
   - Check if `.claude-plugin/plugin.json` exists
   - If YES: Go to step 4a (ask plugin vs. project-level scope)
   - If NO: Go to step 4b (ask nested vs. project-level scope if nested, otherwise default)

4a. **IF CLAUDE PLUGIN PROJECT - Ask: Plugin or project-level?**
   ```
   Should this skill be part of the plugin or project-level?
   - Plugin - Add to `skills/` directory (bundled with plugin)
   - Project-level - Add to `.claude/skills/` at project root (available across project)
   ```

4b. **IF REGULAR PROJECT - Ask about nesting** (only if user is in nested directory)
   - If user is at project root:
     - Inform: "Creating project-level skill in `.claude/skills/`"
   - If user is in nested directory (e.g., `packages/frontend/`):
     ```
     Where should this skill live?
     - Nested - Add to `packages/frontend/.claude/skills/` (Recommended)
       Claude auto-discovers this when you edit files here.
     - Project-level - Add to `.claude/skills/` at project root
       Skill available everywhere in the project.
     ```

**CRITICAL: Block user-space scope attempts**
   - If user asks for user-space scope or mentions `~/.claude/skills/`, REFUSE immediately
   - Explain: "User-space skills (`~/.claude/skills/`) affect all projects in your user space. This skill-creator only works with project-scoped skills to prevent unintended side effects across your projects. After creation or refinement, you can manually copy the skill directory to `~/.claude/skills/` if you want user-space availability."

5. **Ask: What do you want to call it?** (e.g., `code-analyzer`, `test-runner`)

**For validating/refining:** Ask "Provide the skill path relative to project root"
- Examples: `skills/pdf-processor`, `.claude/skills/pdf-processor`, `packages/frontend/.claude/skills/pdf-processor`, `api/.claude/skills/test-runner`
- Paths can be at any directory level where `.claude/skills/` exists

Based on answers, route to the appropriate workflow below.

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

1. **FIRST: Verify the skill path is project-scoped** — Check if path contains `skills/` or `.claude/skills/` relative to project root. If path is from `~/.claude/plugins/cache/` or `~/.claude/`, REFUSE and explain project scope
2. **SECOND: Detect scope from path** — Infer from path structure:
   - Path starts with `skills/` → Plugin-level skill
   - Path contains `.claude/skills/` anywhere → Project-level skill (can be root `.claude/skills/` or nested like `packages/frontend/.claude/skills/`)
3. Follow the systematic workflow in `references/validation-workflow.md` (Phase 1-7)
4. Use `references/checklist.md` to identify gaps during Phase 3-6
5. Check `references/allowed-tools.md` if tool scoping is involved
6. Validate: Complete workflow + checklist before considering the skill complete

### For Improvements (Refining)

1. **FIRST: Verify the skill path is project-scoped** — Check if path is in project directory, NOT in installed locations. Refuse if it's installed/cached
2. **SECOND: Detect scope from path** — Infer from path structure:
   - Path starts with `skills/` → Plugin-level skill
   - Path contains `.claude/skills/` anywhere (root or nested) → Project-level skill
3. Ask user which aspects need improvement (structure, length, triggering, etc.)
4. **CRITICAL for length/organization improvements:** Use `references/content-distribution-guide.md` to decide what stays in SKILL.md vs. moves to references. Ask: "Will Claude execute this in 80%+ of cases?" Core procedural content stays; supplementary content moves.
5. Reference relevant sections from `references/checklist.md` or `references/allowed-tools.md`
6. Make targeted improvements rather than rewriting everything

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

## Refining Existing Skills

1. **Follow the validation workflow** (references/validation-workflow.md) to identify all issues systematically
2. **Review against the checklist** (references/checklist.md) during validation phases 3-6
3. **Improve so Claude executes better:** frontmatter clarity (activation) → instruction clarity → examples Claude can adapt → separate detailed content
4. **Test activation:** Will Claude recognize this description in real requests? Will it activate when needed?
5. **Re-validate** using the workflow before considering refinements complete

## Reference Guide

**Load when understanding skill fundamentals:**
- `references/how-skills-work.md` — **Load if:** User asks why descriptions trigger activation, or you need to explain token loading hierarchy, selection mechanism, or skill architecture

**Load when creating a new skill:**
- `references/templates.md` — **Load if:** User describes requirements and you need copy-paste starting points (basic template vs. production template, workflow patterns)
- `references/content-guidelines.md` — **Load if:** Writing skill descriptions/frontmatter and need to verify trigger phrases work, or checking terminology consistency in existing skill

**Load when validating or improving skills:**
- `references/validation-workflow.md` — **Load if:** Systematically validating through phases (frontmatter clarity → body clarity → references organization → tool scoping → real-world testing)
- `references/content-distribution-guide.md` — **Load if:** Deciding what content stays in SKILL.md vs. moves to references, or refining skill organization/length (prevents moving core procedural content unnecessarily)
- `references/checklist.md` — **Load if:** Assessing skill quality across all dimensions (activation, clarity, token efficiency, error handling, production readiness)
- `references/advanced-patterns.md` — **Load if:** Skill is production/team-use and needs error handling, version history, risk assessment, security review, or advanced patterns

**Load when configuring permissions and structure:**
- `references/allowed-tools.md` — **Load if:** Determining which tools skill needs, or reviewing security/principle of least privilege
- `references/self-containment-principle.md` — **Load if:** Deciding whether skill has external dependencies, or troubleshooting self-containment violations

## Key Notes

**Required frontmatter (Claude reads this to discover and activate skills):**
- YAML syntax (use triple dashes: `---`)
- `name`: Required, lowercase-hyphen, ≤64 chars, no "anthropic"/"claude" (how Claude references the skill)
- `description`: Required, must include specific trigger phrases Claude recognizes, ≤1024 chars
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

**Team/Production considerations:** Error handling mandatory. Scripts tested. Tool scoping: least privilege. Version tracking recommended. See `references/advanced-patterns.md` and `references/checklist.md`.

**Content distribution rule:** Keep SKILL.md <500 lines. Add >50 lines? Create reference file instead. Reference files have zero token penalty until needed.

**Allowed creation/editing scopes:**
- **Plugin skills**: `skills/` directory in Claude plugin projects
- **Project-level skills**: `.claude/skills/` at project root
- **Nested skills**: `.claude/skills/` in any subdirectory

**Forbidden creation/editing scopes:**
- **User-space skills**: `~/.claude/skills/` — Risk of affecting all projects in your user space
- **Installed/cached skills**: `~/.claude/plugins/cache/` and other installation directories
