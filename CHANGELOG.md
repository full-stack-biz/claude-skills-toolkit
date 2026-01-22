# Changelog

All notable changes to the skills-toolkit plugin are documented here.

## [1.6.2] - 2026-01-22

### Changed
- **plugin-creator:**
  - Improved marketplace.json documentation with clearer schema examples
  - Refactored automated scanning phase into separate reference file (`references/automated-scanning-workflow.md`) for better organization
  - Enhanced tool scoping with specific bash command restrictions (`Bash(find:*,grep:*,...)` instead of broad permissions)
  - Consolidated workflow documentation for clarity

- **hook-creator, subagent-creator:**
  - Removed redundant "THE EXACT PROMPT" sections (users can invoke skills directly with natural requests)
  - Improved scope terminology and user-space blocking guidance

## [1.6.1] - 2026-01-21

- **skill-creator 1.3.1:**

  ### Added
  - New reference file `references/team-production-patterns.md`
    - Error handling patterns for robust skill execution
    - Tool scoping and principle of least privilege guidance
    - Validation scripts and security review checklists
    - Documentation requirements for team environments

  ### Fixed
  - Consolidated Core Principles and Foundation sections for unified guidance
  - Fixed scope detection contradiction (auto-detect first, ask only when ambiguous)
  - Removed stale line number references; now reference by section names
  - Aligned frontmatter guidance with official Claude Code docs (name optional, description recommended)
  - Merged duplicate refining workflows into single authoritative workflow
  - Clarified 80% rule as unified concept across all principles

## [1.6.0] - 2026-01-21

### Added
- **skill-creator:** Refinement preservation rules with validation gates
  - New reference file `references/refinement-preservation-policy.md` with detailed preservation rules, the 80% rule, and operator approval triggers
  - "Refinement Preservation Rules" section in SKILL.md with 4 pre-refinement validation gates (Content Audit, Capability Assessment, Migration Verification, Operator Confirmation)
  - Quick decision tree for content relocation (SKILL.md vs. references/)
  - Prevents function-crippling refinements by enforcing preservation of core procedural content

### Changed
- **skill-creator:** Enhanced reference guide clarity
  - Updated all reference loading guidance from "Load if" to explicit "MUST load" / "MAY load" labels
  - Clarified activation requirements for each reference file based on task context
  - Improved scope reference in Key Notes section to direct users to implementation flowchart (lines 67-115)

## [1.5.0] - 2026-01-21

### Added
- **skill-creator:** Content distribution decision guide
  - New reference file `references/content-distribution-guide.md` with decision tree for organizing SKILL.md vs. reference files
  - Prevents moving core procedural content (patterns, workflows, examples) to references unnecessarily
  - Includes real-world examples from skill refinement scenarios

### Changed
- **skill-creator:** Enhanced refinement workflow with content organization guidance
  - Foundation section now includes decision tree question: "Will Claude execute this in 80%+ of cases?"
  - Refinement workflow step 4 marked CRITICAL for length/organization improvements, references content-distribution-guide.md
  - Reference guide section updated with activation criteria for new content-distribution-guide.md

## [1.4.0] - 2026-01-21

### Added
- **plugin-creator:** Automated scanning phase for plugin validation
  - Read-only scanner detects non-standard files, orphaned directories, security issues, and naming violations
  - User-approved cleanup workflows via AskUserQuestion (file deletion, permission fixes, structural decisions)
  - Deprecation warnings for legacy `commands/` directory, guiding migration to Agent Skills

### Changed
- **plugin-creator:** Migrated to Agent Skills architecture
  - Plugin structure examples now prioritize Agent Skills over deprecated commands
  - Enhanced reference documentation with table of contents for all 14 large files
  - Removed external URLs; improved self-containment

## [1.3.2] - 2026-01-21

### Changed
- **skill-creator:** Refined scope terminology and user-space blocking
  - Consistent terminology: plugin, project-level, nested, and user-space scopes
  - Enhanced refusal messages for user-space scope requests with clear explanation of side effects
  - Added guidance that users can manually copy skills to `~/.claude/skills/` after creation or refinement if desired

## [1.3.1] - 2026-01-21

### Changed
- **skill-creator:** Enhanced scope detection to support nested directory skills
  - Auto-detects where user is working (project root vs nested directory)
  - For nested directories, asks whether skill should be local (auto-discovered in that directory) or global (project-wide)
  - Supports monorepo patterns with nested `.claude/skills/` directories at any level (e.g., `packages/frontend/.claude/skills/`)
  - Improved user guidance explaining auto-discovery behavior for local skills

## [1.3.0] - 2026-01-20

### Added
- **Scope detection for artifact creation** - Automatically determine correct placement for skills, hooks, and subagents
  - **skill-creator, hook-creator, subagent-creator:** Auto-detect if project is a Claude plugin
  - **For plugin projects:** Prompt users to choose between plugin-level (bundled) or project-level (local) placement
  - **For regular projects:** Automatically place artifacts in project-level location without prompts
  - Prevents accidental creation of artifacts in wrong locations (e.g., global `~/.claude/` vs project scope)

### Changed
- **skill-creator, hook-creator, subagent-creator:** Enhanced workflows with project scope detection
  - Added automatic `.claude-plugin/plugin.json` detection to determine project type
  - Improved validation to refuse editing installed/cached artifacts from global locations
  - Scope detection applies to create, validate, and refine workflows

## [1.2.6] - 2026-01-20

### Changed
- **skill-creator:** Improved activation and safeguards
  - Description now uses specific trigger phrases for reliable activation ("building a new skill", "validating against best practices", "improving clarity")
  - Added critical project-scope safeguards to prevent accidentally editing installed/cached skill versions
  - Enhanced Reference Guide with explicit "Load if" conditions so Claude knows exactly when to load each reference file
  - Improved token efficiency (20% reduction while preserving all essential guidance)

## [1.2.5] - 2026-01-20

### Changed
- **Architecture documentation:** Refined and clarified Claude Code skill design principles
  - Renamed "Self-Containment Principle" to "Bounded Scope Principle" for clearer alignment with Claude's official progressive disclosure architecture
  - Added comprehensive grounding section showing how bounded scope derives from Claude's three-layer loading model (metadata, instruction, resource)
  - Clarified distinction between "content dependencies" (forbidden) and "optional network access" (allowed via declared tools)
  - Enhanced validation checklist to map to Claude's three-layer architecture
- **Project-level documentation:** Added architectural context for users and developers
  - CLAUDE.md: New "Known Limitation: Knowledge Duplication & Future Refactoring" section explaining why skills contain overlapping knowledge and when SRP refactoring becomes possible
  - README.md: New "Design Notes: Architecture & DRY" section explaining the design rationale and tracking the Claude feature request for skill delegation
  - Both sections reference the GitHub issue tracking `context: fork` support for full SRP alignment

## [1.2.4] - 2026-01-20

### Changed
- **skill-creator, plugin-creator, subagent-creator, hook-creator:** Enhanced initial guidance with interactive questions
  - Replaced text-based routing prompts with structured AskUserQuestion for better UX
  - Consistent pattern across all creator skills for gathering requirements
  - Clearer workflow routing based on user intent (create/validate/refine)

## [1.2.3] - 2026-01-20

### Changed
- **Unified skills approach:** Migrated from separate commands/ directory to unified skills system
  - Skills now handle both auto-activation and user invocation via `/` commands
  - Replaces deprecated command-based architecture with skill-based invocation control
- **skill-creator, plugin-creator, subagent-creator, hook-creator:** Added "Quick Routing" sections
  - Interactive questions guide users through action selection (create/validate/refine)
  - Examples embedded in questions for better discoverability
  - Frontmatter invocation control (`disable-model-invocation`, `user-invocable`) documented
- **plugin-creator references:** Comprehensive architecture documentation updates
  - `how-plugins-work.md`: Replaced "Slash Commands" section with "Skills (User-Invoked)" explaining unified approach
  - `directory-structure.md`: Updated all plugin examples to use skills-only structure
  - Updated token loading hierarchy and component metadata documentation

### Removed
- **commands/ directory:** Deleted (all functionality preserved in skills)
  - create-skill.md → migrated to skill-creator Quick Routing
  - create-plugin.md → migrated to plugin-creator Quick Routing
  - create-subagent.md → migrated to subagent-creator Quick Routing
  - create-hook.md → migrated to hook-creator Quick Routing

## [1.2.2] - 2026-01-20

### Changed
- **hook-creator:** Enhanced `Hook System Essentials` section with comprehensive documentation
  - Complete 5-step hook lifecycle explanation
  - Clarified hook types (command vs prompt) with specific use cases
  - Event data and matcher pattern examples (regex, text, tool patterns)
  - Decision schemas overview for each event type
  - Exit code behavior documentation (0, 2, other)
  - Critical constraints (matcher precision, timing, error handling)
- **hook-creator:** Improved skill description to highlight command/prompt hooks, JSON decision schemas, and validation capabilities
- **hook-creator:** Added navigation tables of contents to 9 reference files for easier browsing:
  - advanced-patterns.md, how-hooks-work.md, templates.md, event-reference.md, validation-workflow.md, decision-schemas.md, exit-code-behavior.md, component-scoped-hooks.md, checklist.md
- **hook-creator:** Expanded reference documentation table to include all 10 reference files with clear purpose descriptions
- **hook-creator:** Reorganized templates.md section structure for improved clarity

## [1.2.1] - 2026-01-20

### Changed
- **plugin-creator skill:** Improved description to explicitly mention hooks, agents, and server integration
- **Marketplace keywords:** Enhanced to include hooks, agents, subagents, and automation for better discoverability

## [1.2.0] - 2026-01-20

### Added
- **New command: /skills-toolkit:create-hook** - Create, validate, and refine Claude Code plugin hooks
  - Supports `create`, `validate`, and `refine` actions
  - Takes optional `hook-name` argument for targeted work

### Changed
- **Plugin scope expanded:** Now manages skills, plugins, subagents, AND hooks

## [1.1.1] - 2026-01-20

### Added
- **plugin-creator references:** New `subagents-in-plugins.md` guide covering:
  - When to include subagents in plugins
  - Frontmatter requirements (name, description, model, tools, permissionMode, hooks)
  - Example subagent structure and organization patterns
  - Testing subagents locally before distribution

### Technical
- Bumped plugin-creator to 1.0.4 for upcoming documentation improvements

## [1.1.0] - 2026-01-20

### Added
- **New skill: subagent-creator** - Create, validate, and refine Claude Code subagents
  - Three workflows: Create (with interview), Validate (7-phase), Refine (targeted improvements)
  - Comprehensive references covering delegation signals, tool scoping, permission modes, and hooks
  - 9 reference files with best practices, templates, and validation workflows
  - Principle of least privilege enforcement for tool access

- **New command: /skills-toolkit:create-subagent** - Shortcut to invoke subagent-creator skill
  - Supports `create`, `validate`, and `refine` actions
  - Takes optional `subagent-name` argument

### Changed
- **plugin.json:** Updated description to include subagent management
- **CLAUDE.md:** Added comprehensive Version Release Process section documenting:
  - Independent versioning for skills vs plugin
  - Plugin version bumps based on bundled component changes (PATCH/MINOR/MAJOR)
  - Marketplace manifest update requirements
  - Verification procedures

## [1.0.3] - 2026-01-16

### Added
- Initial plugin release with:
  - **skill-creator** skill - Create and refine Claude Code skills
  - **plugin-creator** skill - Create, validate, and refine Claude Code plugins
  - **Slash commands:** `/skills-toolkit:create-skill`, `/skills-toolkit:create-plugin`
  - Comprehensive reference documentation for both skills
