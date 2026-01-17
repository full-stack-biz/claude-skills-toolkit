# Versioning and Distribution Reference

Guide to version management, changelog maintenance, and distributing plugins across teams and marketplaces.

## Table of Contents

- [Semantic Versioning](#semantic-versioning)
- [Version in plugin.json](#version-in-pluginjson)
- [Updating Versions](#updating-versions)
- [CHANGELOG.md Format](#changelogmd-format)
- [Distribution Lifecycle](#distribution-lifecycle)
- [Version Bumping Workflow](#version-bumping-workflow)
- [Version Management in Teams](#version-management-in-teams)
- [Marketplace Distribution](#marketplace-distribution)
- [Dependency Management](#dependency-management)
- [Version Compatibility](#version-compatibility)
- [Handling Version Deprecation](#handling-version-deprecation)
- [Release Checklist](#release-checklist)
- [Version History Examples](#version-history-examples)
- [See Also](#see-also)

## Semantic Versioning

Claude Code plugins follow semantic versioning (semver): `MAJOR.MINOR.PATCH`

**Format:** `X.Y.Z`

### Version Components

**MAJOR (X)** — Breaking Changes
- Increment when making incompatible changes to plugin API or behavior
- Users must review and update configurations when updating
- Example: Changing command argument structure, removing commands, restructuring output

**MINOR (Y)** — New Features
- Increment when adding new functionality in backward-compatible way
- Users can safely update; old features still work
- Example: Adding new commands, new hooks, new agent capabilities

**PATCH (Z)** — Bug Fixes
- Increment when fixing bugs without changing behavior for users
- Safe updates that don't affect API or configuration
- Example: Fixing script errors, correcting documentation, performance improvements

### Versioning Examples

```
1.0.0     Initial stable release
1.0.1     Bug fix (patch)
1.1.0     New feature (minor)
2.0.0     Breaking change (major)
2.0.1     Bug fix (patch)
2.1.0     New feature (minor)
2.1.1     Another bug fix (patch)
3.0.0     Major breaking change (major)
```

### Pre-Release Versions

Use pre-release tags for testing before stable release:

**Format:** `X.Y.Z-IDENTIFIER`

Examples:
```
2.0.0-alpha.1      First alpha (early testing)
2.0.0-alpha.2      Second alpha
2.0.0-beta.1       Beta version (more stable than alpha)
2.0.0-beta.2       Another beta
2.0.0-rc.1         Release candidate (almost final)
2.0.0              Final stable release
```

**Use case:** Before releasing major version with breaking changes, distribute pre-release versions to gather feedback:

```
1.5.0              Current stable
2.0.0-alpha.1      Major refactor (pre-release)
2.0.0-beta.1       Refined (pre-release)
2.0.0              Final (stable)
```

## Version in plugin.json

Specify version in plugin manifest:

```json
{
  "name": "my-plugin",
  "version": "2.1.0"
}
```

**Validation rules:**
- Must follow `X.Y.Z` format (all three parts required)
- Each part is a number (0-9, can be any length)
- Optional: pre-release suffix after hyphen
- Use semantic meaning (not arbitrary numbers)

## Updating Versions

### When to Update

**Patch (Z):**
- Bug fixes in scripts
- Documentation corrections
- Performance improvements
- No API changes

**Minor (Y):**
- New commands added
- New hooks added
- New Skills added
- New MCP server integration
- Backward-compatible changes

**Major (X):**
- Command removed or renamed
- Command argument changed
- Output format changed
- Plugin behavior significantly changed
- Incompatible with previous versions

### How to Update

1. **Edit plugin.json:**
```json
{
  "version": "2.1.0"   ← Update version number
}
```

2. **Update CHANGELOG.md** (see below)

3. **Commit changes:**
```bash
git add plugin.json CHANGELOG.md
git commit -m "Release version 2.1.0"
git tag v2.1.0
```

4. **Publish to marketplace** (if distributing)

## CHANGELOG.md Format

Maintain a changelog documenting all changes. Recommended format uses "Keep a Changelog" style.

**Structure:**

```markdown
# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com),
and this project adheres to [Semantic Versioning](https://semver.org).

## [Unreleased]
### Added
- New feature coming in next release

## [2.1.0] - 2024-01-15
### Added
- New `security-audit` command
- Support for custom security rule files
- Integration with external vulnerability database

### Changed
- Improved performance of code analysis (3x faster)
- Reorganized report output format

### Fixed
- Bug: Security check failing on large files
- Bug: Timeout issues with complex code structures

## [2.0.0] - 2024-01-01
### Added
- Major refactor of command structure
- New agent: `deployment-manager`

### Changed
- **BREAKING**: `validate` command renamed to `verify`
- **BREAKING**: Changed output format from JSON to custom format

### Removed
- Deprecated `old-command` (use `new-command` instead)

## [1.5.0] - 2023-12-01
### Added
- New `report` command for generating summaries

### Fixed
- Memory leak in hook processing
- Command timeout issues

## [1.0.0] - 2023-11-01
### Added
- Initial stable release
```

### Changelog Sections

**Added** — New features, new commands, new functionality
- Use this for new commands, agents, hooks, or capabilities
- Users might want to know about new features

**Changed** — Changes to existing functionality (backward-compatible)
- Use for performance improvements, behavior changes that don't break API
- Users should be aware of changed behavior

**Deprecated** — Features marked for removal in future version
- Use when you plan to remove something in next major version
- Warn users to migrate to replacement

**Removed** — Features removed in this version
- Use when removing deprecated features
- Users must migrate or stay on old version

**Fixed** — Bug fixes
- Use for all bug fixes regardless of size
- Users should update to get bug fixes

**Security** — Security fixes and vulnerability patches
- Use for security-related changes
- Important for users to update quickly

### CHANGELOG.md Best Practices

1. **Keep current section updated** — Document changes as you make them in "Unreleased" section
2. **Date releases** — Include ISO date (YYYY-MM-DD) for each release
3. **Link to releases** — Add links to version tags or release pages
4. **Highlight breaking changes** — Mark with **BREAKING** prefix
5. **Be specific** — "Improved performance" is vague; "Reduced response time from 500ms to 100ms" is specific
6. **Use verb forms** — Start with verbs: "Add", "Fix", "Change", not "Added", "Fixed"
7. **Group by impact** — Organize sections by importance to users

## Distribution Lifecycle

### Development Phase

```
1.0.0-alpha.1 → Develop locally with --plugin-dir
1.0.0-alpha.2 → Share with team for feedback
1.0.0-beta.1  → Internal testing
1.0.0-beta.2  → Final testing
1.0.0         → Release to marketplace
```

### Maintenance Phase

```
1.0.0          Current stable version
1.0.1          Bug fix
1.0.2          Another bug fix
1.1.0          New feature
1.1.1          Bug fix for 1.1.0
2.0.0-alpha.1  Major refactor (pre-release)
2.0.0          Major release
```

## Version Bumping Workflow

### For Patch Release (1.0.0 → 1.0.1)

```bash
# 1. Update version in plugin.json
# 2. Update CHANGELOG.md
git add plugin.json CHANGELOG.md

# 3. Commit
git commit -m "Bump version to 1.0.1

- Fix: Correct hook script error
- Fix: Improve error handling in command
"

# 4. Tag
git tag v1.0.1

# 5. Push (if using git remote)
git push origin v1.0.1
```

### For Minor Release (1.0.0 → 1.1.0)

```bash
# 1. Update version
# 2. Update CHANGELOG.md with new features

git add plugin.json CHANGELOG.md

# 3. Commit
git commit -m "Release version 1.1.0

New features:
- Add 'analyze' command for code analysis
- Add security-audit agent
- Support custom rule files
"

# 4. Tag
git tag v1.1.0

# 5. Push
git push origin v1.1.0
```

### For Major Release (1.0.0 → 2.0.0)

For major releases with breaking changes, consider gradual migration:

```bash
# Before releasing 2.0.0:
1. Release 1.last-version (stable)
2. Release 2.0.0-alpha.1 (major refactor)
3. Publish 2.0.0-beta versions (feedback)
4. Release 2.0.0 (stable with migration guide)

# In CHANGELOG.md, clearly document:
- What changed (breaking changes must be explicit)
- How to migrate from 1.x to 2.x
- Deprecation path from previous version
```

## Version Management in Teams

### Shared Project Plugin

When distributing plugin via `.claude/skills/` (project scope):

```bash
# 1. Team agrees on version before release
# 2. Someone publishes new version
# 3. Everyone pulls changes
# 4. Version updates automatically for all

cat .claude/skills/my-plugin/.claude-plugin/plugin.json
# Shows: "version": "2.1.0"
```

**Best practice:** Pin version in `plugin.json` so all team members have consistent version.

### Global Plugin Across Teams

For user-scope plugins shared across multiple teams:

```bash
# Each user can have different version
# Recommend updating when available:
claude plugin update my-plugin --scope user
```

## Marketplace Distribution

When publishing to Claude Code marketplace:

1. **Version must be semantic:** `X.Y.Z` format
2. **Keep CHANGELOG.md updated** — Marketplace may display this
3. **Document breaking changes** — Critical for marketplace visibility
4. **Include version in plugin.json**
5. **Use consistent versioning** across all marketplace entries
6. **Tag releases in git** — Makes tracking easier

**Marketplace entry example:**
```json
{
  "name": "my-plugin",
  "version": "2.1.0",
  "description": "Plugin description",
  "source": "./plugins/my-plugin",
  "homepage": "https://github.com/user/my-plugin",
  "repository": "https://github.com/user/my-plugin"
}
```

## Dependency Management

If your plugin depends on specific versions of tools:

**Document in README.md:**
```markdown
## Requirements

- Node.js 18+ (for JavaScript utilities)
- Python 3.9+ (for Python scripts)
- Go 1.20+ (for MCP server)

## Installation

1. Install requirements
2. Run: `claude plugin install my-plugin`
3. Configure: (instructions)
```

**Or in plugin.json:**
```json
{
  "name": "my-plugin",
  "version": "2.1.0",
  "peerDependencies": {
    "node": ">=18.0.0",
    "python": ">=3.9"
  }
}
```

## Version Compatibility

Specify which versions of Claude Code your plugin supports:

**In plugin.json:**
```json
{
  "name": "my-plugin",
  "version": "2.1.0",
  "engines": {
    "claude-code": ">=1.0.0"
  }
}
```

**In README.md:**
```markdown
## Compatibility

- Claude Code: 1.0.0 and later
- Tested with: 1.5.0, 2.0.0
```

## Handling Version Deprecation

When deprecating plugin or feature:

**Option 1: Deprecation notice in CHANGELOG.md**
```markdown
## [1.5.0] - 2024-01-15
### Deprecated
- `old-command` — Use `new-command` instead. Will be removed in 2.0.0.
```

**Option 2: Deprecation warning in command output**
```markdown
---
name: old-command
description: >-
  **DEPRECATED**. Use 'new-command' instead.
  This command will be removed in v2.0.0.
---
```

**Option 3: Plugin deprecation message**
```json
{
  "name": "deprecated-plugin",
  "version": "1.0.0",
  "deprecated": true,
  "deprecatedMessage": "This plugin is no longer maintained. Use 'new-plugin' instead.",
  "deprecationDate": "2024-01-01"
}
```

## Release Checklist

Before releasing new version:

- [ ] All changes documented in CHANGELOG.md
- [ ] Version number updated in plugin.json
- [ ] Breaking changes clearly marked in CHANGELOG
- [ ] Tests pass (if applicable)
- [ ] README.md updated with new features
- [ ] Commit message follows conventions
- [ ] Git tag created with version number (v2.1.0)
- [ ] Marketplace entry updated (if publishing)
- [ ] Notification sent to users (if major release)

## Version History Examples

### Simple Plugin Growth

```
1.0.0 (Nov 2023) — Initial release with 2 commands
1.0.1 (Nov 2023) — Bug fix
1.1.0 (Dec 2023) — Added new command
1.1.1 (Dec 2023) — Bug fix
1.2.0 (Jan 2024) — Added MCP integration
2.0.0 (Feb 2024) — Major refactor with breaking changes
```

### Complex Plugin with Pre-releases

```
1.0.0          (Oct 2023) — Stable
1.1.0          (Nov 2023) — New feature
2.0.0-alpha.1  (Dec 2023) — Start major refactor
2.0.0-alpha.2  (Dec 2023) — More work
2.0.0-beta.1   (Jan 2024) — Team testing
2.0.0-beta.2   (Jan 2024) — Polish
2.0.0          (Feb 2024) — Stable major release
```

## See Also

- [Plugin manifest](plugin-json-schema.md) — Version field specification
- [CLI commands](cli-commands.md) — Installing and updating plugins
- [Plugin templates](plugin-templates.md) — Complete examples with versions
