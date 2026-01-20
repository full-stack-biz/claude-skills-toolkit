# Changelog

All notable changes to the skills-toolkit plugin are documented here.

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
