# Changelog

All notable changes to the skills-toolkit plugin are documented here.

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
