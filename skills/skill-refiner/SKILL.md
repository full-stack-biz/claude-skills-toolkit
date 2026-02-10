---
name: skill-refiner
description: >-
  Improve and validate existing Claude Code skills for clarity, efficiency, and production readiness.
  Use when: refining skills, improving skill structure, validating against best practices, reducing
  token usage, consolidating references, checking production readiness, or applying the 80% rule.
  Takes imperfect existing skills and elevates them to quality standards.
version: 1.1.1
allowed-tools: Read,Edit,Write,Glob,Task(*)
hooks:
  PreToolUse:
    - matcher: "^(Write|Edit)$"
      hooks:
        - type: prompt
          prompt: "You are validating changes to a Claude Code skill during refinement. Enforce the Movement Pattern.\n\nFile being modified: $ARGUMENTS\n\n**MOVEMENT PATTERN (Enforce strictly for ANY content relocation):**\nWhen content is removed, it must appear in a destination (same file reorganized, or moved to another file).\nSequence: CREATE → LINK → DELETE (never DELETE → LINK → CREATE).\n\nWhen content is being REMOVED:\n- REJECT if: Deleted with no corresponding content appearing in destination\n- REJECT if: Destination unclear (where did it go?)\n- ACCEPT only if: Content clearly relocated to another location in same session\n\nRespond with JSON (no markdown, no extra text): {\"ok\": true, \"reason\": \"content is clearly relocated\"} if valid, or {\"ok\": false, \"reason\": \"specific reason why pattern violated\"} if invalid.\n\nDefault: false if content fate is unclear or movement pattern broken."
          timeout: 30
---

# Skill Refiner

Systematically improve and validate Claude Code skills while preserving functionality and following established patterns.

## Quick Start

**Option 1: Refine a skill** (improve clarity, efficiency, activation, or structure)
```
User: "Refine the skill-creator skill—make it clearer and more efficient"
→ Claude loads this skill → Locates skill-creator → Gathers approval (scope focus) →
→ Identifies improvements → Applies preservation gates → Makes changes → Validates result
```

**Option 2: Validate a skill** (check quality against standards)
```
User: "Validate the plugin-creator skill for production readiness"
→ Claude loads this skill → Locates plugin-creator → Runs validation phases (file inventory,
→ frontmatter, body content, references, tools, testing) → Reports findings
```

**Option 3: Auto-detection** (offer help during skill work)
```
User: (working with skills, no explicit request)
→ Claude detects skill context → Offers: "I can help refine or validate [skill]. Want me to?"
```

## Core Workflow: Refinement

**When user requests refinement:**

1. **Locate the skill (MANDATORY first step)**
   - Search current project first: `skills/skill-name/`, `.claude/skills/skill-name/`
   - If not found in project → Check user-space: `~/.claude/skills/skill-name/`
   - If found in user-space → WARN: "This affects all projects. Continue?"
   - If in cache (`~/.claude/plugins/cache/`) → REFUSE: "That's an installed copy (read-only)"
   - If not found anywhere → ASK: "Where should I find this skill?"

2. **Get approval (wizard approach - one question at a time)**
   - Ask: "What's the primary focus?" (structure/clarity OR content/efficiency OR both)
   - If NOT "both" → Ask: "Any additional areas to review?"
   - Document approved scope before proceeding

3. **Load workflow reference**
   - Read `references/refinement-workflow.md` (unified workflow with preservation gates)

4. **Identify consolidation opportunities (BEFORE changes)**
   - List all files in `references/` directory with line counts
   - Group by topic (what do they cover?)
   - Flag potential merges (2-4 files on same topic → 1 consolidated file)
   - ASK: "Should we consolidate these files? Saves N lines, improves clarity"
   - Only proceed if operator approves

5. **Apply preservation gates (CRITICAL - four gates, in order)**
   - **GATE 1**: Content Audit - list ALL existing content, classify as core (80%+) or supplementary (<20%)
   - **GATE 2**: Capability Assessment - will changes impair execution? If YES → cannot delete, only migrate
   - **GATE 3**: Migration Verification - before moving content, verify destination exists and is complete
   - **GATE 4**: Operator Confirmation - deletions require explicit approval, migrations auto-approved

6. **Make changes (following movement pattern)**
   - CREATE/UPDATE destination FIRST (new file, updated section)
   - LINK - update SKILL.md pointers to new destination
   - DELETE old source (only after links verified)
   - Never delete first; always: CREATE → LINK → DELETE

7. **Validate result (seven phases)**
   - Phase 1: File Inventory - list structure before/after
   - Phase 2: Read All - load complete content, verify no gaps
   - Phase 3: Frontmatter - check required metadata (name, description)
   - Phase 4: Body Content - verify <500 lines, 80% rule applied, clarity improved
   - Phase 5: References - confirm all linked files exist and are complete
   - Phase 6: Tools - review allowed-tools scoping against skill needs
   - Phase 7: Testing - verify activation with real-world trigger phrases

## Core Workflow: Validation

**When user requests validation:**

1. **Locate the skill** (same as refinement step 1)

2. **Run validation phases (seven phases, systematic)**
   - **Phase 1: File Inventory** - List all files: SKILL.md, references/, scripts/, assets/
   - **Phase 2: Read All** - Load complete skill content (frontmatter, body, all references)
   - **Phase 3: Frontmatter Check** - Verify required fields: `name`, `description`
   - **Phase 4: Body Content** - Check: <500 lines? 80% rule applied? Clear procedural instructions?
   - **Phase 5: References** - Verify: all linked files exist? No orphaned files? One level deep only?
   - **Phase 6: Tool Scoping** - Review `allowed-tools` against actual tool usage. Principle of least privilege applied?
   - **Phase 7: Testing** - Verify activation: does description include trigger phrases? Will Claude recognize real requests?

3. **Generate validation report**
   - Structure: Status (✅ Production Ready / ⚠️ Needs Review / ❌ Issues Found)
   - Detail: Findings from all seven phases
   - Recommendations: Specific improvements if issues found
   - Priority: Which issues are critical vs. advisory

## Key Rules (Non-Negotiable)

### The 80% Rule (Content Distribution)
- Will Claude execute this in 80%+ of skill activations? → **STAYS in SKILL.md**
- Will Claude execute this in <20% of cases? → **CAN MOVE to references/**
- Uncertain? → **DEFER to operator; keep in SKILL.md by default**

### Movement Pattern (for content changes)
```
SEQUENCE (never violate order):
1. CREATE/UPDATE destination file(s) with merged content
2. LINK - Update SKILL.md pointers to new destination(s)
3. DELETE old source (only after links verified and tested)

NEVER: DELETE → LINK → CREATE (creates broken links and lost content)
```

### Preservation Gates (Four Gates, In Order)
1. **Content Audit** - List ALL existing content. Classify as core (80%+) or supplementary (<20%)
2. **Capability Assessment** - Will changes impair execution? If YES → cannot delete, only migrate
3. **Migration Verification** - Before moving, verify destination complete. NO GAPS
4. **Operator Confirmation** - Deletions require explicit approval. Migrations auto-approved

### Scope Rules (Where to Work)
✅ **PREFERRED** - Project paths (search first):
- `skills/skill-name/` in plugin projects
- `.claude/skills/skill-name/` in any project

⚠️ **CONDITIONAL** - User-space (only if not in project):
- `~/.claude/skills/skill-name/` - WARN: "Affects all projects"
- Requires explicit user confirmation before editing
- Offer to copy to project instead

❌ **FORBIDDEN** - Never edit (REFUSE IMMEDIATELY):
- `~/.claude/plugins/cache/*` (installed plugins - read-only)
- Any path containing `/cache/` (always read-only)

## Reference Files

Load these references as needed:

- **`references/refinement-workflow.md`** - Unified refinement workflow with preservation gates and validation phases
- **`references/refinement-guardrails.md`** - What NEVER gets cut during refinement, safe patterns, the Litmus Test
- **`references/validation-checklist.md`** - Quality assessment across all dimensions
- **`references/production-patterns.md`** - Error handling, logging, and team patterns
- **`references/preservation-rules.md`** - What NEVER gets cut during refinement
- **`references/80-percent-rule.md`** - Content distribution decision framework (when to move content to references/)
- **`references/movement-pattern.md`** - Safe content migration procedure (CREATE → LINK → DELETE sequence)
- **`references/advanced-patterns.md`** - Advanced skill patterns, archetype structures, and production quality examples
- **`references/allowed-tools.md`** - Tool scoping validation, principle of least privilege, and security
- **`references/content-guidelines.md`** - Description and trigger phrase improvement, MCP tool references, consistent terminology

## Pro Tips

**Finding skills efficiently:**
- Project-scoped skills in `skills/` or `.claude/skills/` (search project first)
- User-space skills in `~/.claude/skills/` (only if not in project)
- Use `Glob` pattern: `**/SKILL.md` to find all skills in project
- Never search cache paths; they're read-only copies

**Wizard pattern (progressive disclosure):**
- Ask one question, wait for response, then ask next
- Build context step-by-step (avoid form-like multi-questions)
- Document operator's choices; proceed only with approved scope

**Production patterns:**
- Detailed logging of changes made (helps with version tracking)
- Validation scripts provide confidence before deployment
- Error handling for edge cases (missing files, malformed YAML, etc.)

**Preservation principle:**
- Refinement improves existing functionality; it never reduces it
- When in doubt about deletion, ask operator first
- Movement is safer than deletion (can always link back)

## Common Scenarios

**Scenario 1: "Simplify this skill"**
→ Focus on clarity: restructure sections, improve examples, simplify language
→ Identify redundancy in references, suggest consolidation
→ Verify 80% rule for SKILL.md body content

**Scenario 2: "Reduce token usage"**
→ Identify supplementary content (<20% cases) that can move to references
→ Consolidate related reference files
→ Apply 80% rule systematically
→ Verify activation doesn't suffer from moved content

**Scenario 3: "Check if this skill is production-ready"**
→ Run full validation phases (all 7 phases)
→ Check: error handling, tool scoping, clear trigger phrases, comprehensive testing
→ Flag missing production patterns (see references/production-patterns.md)
→ Generate detailed report with findings and recommendations

**Scenario 4: "Offer to help during skill work"**
→ Detect user is working with skills (reading SKILL.md, editing references, etc.)
→ Offer: "I can help refine this skill (clarity, efficiency) or validate it. Want me to?"
→ If yes, use appropriate workflow above

## Notes

**Token efficiency:** Skill-refiner itself should stay <500 lines (this body content). Reference files contain detailed workflows—loaded on-demand only.

**Auto-activation signals:** Watch for user requests containing: "refine", "improve", "make clearer", "reduce tokens", "validate", "check if ready", "is this production-ready", or when user is actively modifying skill files.

**Error handling:** If skill files can't be located, are malformed, or have structural issues, report specific problems and suggest solutions rather than failing silently.

**Version tracking:** Track changes made to skills during refinement (which files modified, what changed). Helps users understand impact of refinements.
