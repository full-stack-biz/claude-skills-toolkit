# Team Marketplaces and Distribution

Share your plugins with your team or community through marketplaces. This guide covers setting up and distributing plugins for team use.

## Table of Contents

- [Distribution Methods](#distribution-methods)
- [Team Marketplace Setup](#team-marketplace-setup)
- [Versioning and Releases](#versioning-and-releases)
- [Team Workflow](#team-workflow)
- [Marketplace Best Practices](#marketplace-best-practices)
- [Troubleshooting](#troubleshooting)
- [Publishing to Public Marketplaces](#publishing-to-public-marketplaces)
- [References](#references)

## Distribution Methods

### Method 1: Direct Installation (Simple)

Share a plugin directly via repository URL for small teams:

```bash
claude plugin install https://github.com/your-org/my-plugin
```

**When to use:**
- Small teams (< 10 people)
- Internal tools
- Quick sharing without marketplace infrastructure
- Testing before wider distribution

### Method 2: Team Marketplace (Recommended)

Set up a marketplace repository for your organization to discover and install plugins:

```bash
claude plugin marketplace configure https://github.com/your-org/plugin-marketplace
```

**When to use:**
- Multiple plugins across teams
- Organization-wide distribution
- Versioned releases
- Team member self-service installation

### Method 3: Public Marketplace (Community)

Publish your plugin to a public marketplace for community discovery:

- Requires: Well-documented plugin, README, clear description
- Benefits: Wider adoption, community feedback, shared maintenance

## Team Marketplace Setup

### Step 1: Create Marketplace Repository

Create a repository to host your marketplace metadata:

```bash
mkdir plugin-marketplace
cd plugin-marketplace
git init
```

### Step 2: Marketplace Structure

Organize your marketplace:

```
plugin-marketplace/
├── README.md                    # Marketplace overview
├── plugins.json                 # Plugin registry (metadata)
├── plugins/                     # Actual plugin directories
│   ├── code-reviewer/
│   ├── pdf-processor/
│   └── test-runner/
└── CONTRIBUTING.md              # Contribution guidelines
```

### Step 3: Create plugins.json Registry

The registry file tells Claude Code where to find plugins:

```json
{
  "version": "1.0.0",
  "plugins": [
    {
      "name": "code-reviewer",
      "description": "Review code for best practices. Use when validating pull requests or before commit.",
      "version": "1.2.0",
      "author": "Your Team",
      "homepage": "https://github.com/your-org/plugin-marketplace/tree/main/plugins/code-reviewer",
      "repository": "https://github.com/your-org/plugin-marketplace",
      "installUrl": "https://github.com/your-org/plugin-marketplace/tree/main/plugins/code-reviewer"
    },
    {
      "name": "pdf-processor",
      "description": "Process PDF files with OCR and extraction. Use when working with PDF documents.",
      "version": "1.0.5",
      "author": "Your Team",
      "homepage": "https://github.com/your-org/plugin-marketplace/tree/main/plugins/pdf-processor",
      "repository": "https://github.com/your-org/plugin-marketplace",
      "installUrl": "https://github.com/your-org/plugin-marketplace/tree/main/plugins/pdf-processor"
    }
  ]
}
```

**Registry fields:**
- `name` - Plugin identifier (must match `.claude-plugin/plugin.json`)
- `description` - What the plugin does (shown in plugin manager)
- `version` - Current version (semantic versioning)
- `author` - Attribution
- `homepage` - Documentation link
- `repository` - Marketplace repository URL
- `installUrl` - Direct path to plugin directory

### Step 4: Add Plugins to Marketplace

Copy or organize plugins in the marketplace:

```
plugin-marketplace/
└── plugins/
    └── code-reviewer/
        ├── .claude-plugin/
        │   └── plugin.json
        ├── commands/
        │   ├── validate.md
        │   └── report.md
        ├── skills/
        │   └── code-analysis/
        │       └── SKILL.md
        └── README.md
```

Each plugin should have its own `plugin.json`:

```json
{
  "name": "code-reviewer",
  "description": "Review code for best practices. Use when validating pull requests or before commit.",
  "version": "1.2.0",
  "author": {
    "name": "Your Team",
    "email": "team@yourcompany.com"
  },
  "homepage": "https://github.com/your-org/plugin-marketplace/tree/main/plugins/code-reviewer",
  "repository": "https://github.com/your-org/plugin-marketplace",
  "license": "MIT"
}
```

### Step 5: Document in README

Create a marketplace README:

```markdown
# Plugin Marketplace

Central repository of plugins for [Your Organization].

## Available Plugins

### Code Reviewer
Review code for best practices. [View plugin](plugins/code-reviewer)

### PDF Processor
Process PDF files with OCR extraction. [View plugin](plugins/pdf-processor)

### Test Runner
Run tests and generate reports. [View plugin](plugins/test-runner)

## Installation

Configure your marketplace:

\`\`\`bash
claude plugin marketplace configure https://github.com/your-org/plugin-marketplace
\`\`\`

Then browse and install plugins:

\`\`\`bash
claude plugin discover
\`\`\`

## Contributing

Submit new plugins via pull request. See [CONTRIBUTING.md](CONTRIBUTING.md).
```

### Step 6: Configure Team Access

#### For GitHub

1. Create the marketplace repository in your GitHub organization
2. Grant team members access (Settings → Access → Collaborators)
3. Share marketplace URL with team:

```bash
claude plugin marketplace configure https://github.com/your-org/plugin-marketplace
```

#### For GitLab / Self-Hosted Git

Use the repository URL matching your git host:

```bash
claude plugin marketplace configure https://gitlab.company.com/teams/plugin-marketplace
```

## Versioning and Releases

### Semantic Versioning

Use semantic versioning for plugin releases:

```
MAJOR.MINOR.PATCH
  1 . 2 . 3
  ↓   ↓   ↓
Breaking changes, new features, bug fixes
```

Examples:
- `1.0.0` - Initial release
- `1.1.0` - Added new command (minor version bump)
- `1.1.1` - Bug fix (patch version bump)
- `2.0.0` - Breaking changes (major version bump)

### Release Checklist

Before releasing a new version:

- [ ] Update `version` in `.claude-plugin/plugin.json`
- [ ] Update `version` in marketplace `plugins.json`
- [ ] Test all plugin components locally
- [ ] Create CHANGELOG entry describing changes
- [ ] Tag release in git: `git tag v1.2.0`
- [ ] Push changes and tags: `git push origin --tags`
- [ ] Announce release to team

### CHANGELOG Format

Track version history for team reference:

```markdown
# Changelog

## [1.2.0] - 2025-01-15

### Added
- New `report` command for generating analysis reports
- Support for custom output formats

### Fixed
- Fixed false positives in code pattern detection
- Improved performance on large codebases

### Changed
- Updated description to clarify scope

## [1.1.0] - 2025-01-01

### Added
- Initial public release
- Core validation command
- Agent Skills for automated analysis
```

## Team Workflow

### For Team Members

**Discover available plugins:**
```bash
claude plugin discover
```

**Install a plugin:**
```bash
claude plugin install code-reviewer
```

**Update plugins:**
```bash
claude plugin update
```

### For Plugin Maintainers

**Publish updates:**

1. Make changes to plugin
2. Test locally with `--plugin-dir`
3. Update version in `plugin.json`
4. Commit and push to marketplace repository
5. Tag release: `git tag v1.2.0 && git push origin --tags`

**Announce to team:**

```markdown
## Plugin Update: Code Reviewer v1.2.0

New features:
- Added report generation command
- Improved analysis speed

Installation:
\`\`\`bash
claude plugin update code-reviewer
\`\`\`
```

## Marketplace Best Practices

### Plugin Maintenance

- **Keep plugins up-to-date**: Update to latest Claude Code APIs
- **Test regularly**: Verify plugins still work with Claude Code releases
- **Respond to issues**: Monitor team feedback and fix bugs promptly
- **Document changes**: Use CHANGELOG to track plugin evolution

### Community Management (Public Marketplaces)

- **Clear documentation**: Write READMEs that explain plugin purpose and usage
- **Examples**: Include example commands and workflows
- **Issue tracking**: Set up GitHub Issues for bug reports
- **Contributing guide**: Make it easy for community to contribute
- **License**: Choose appropriate open-source license

### Security

- **No hardcoded secrets**: Use environment variables for credentials
- **Validate input**: All commands should validate user input
- **Secure defaults**: Plugins should be safe to use without extra configuration
- **Audit dependencies**: Review external tools and dependencies
- **Security updates**: Prioritize security patches

### Performance

- **Test with large projects**: Ensure plugins scale to large codebases
- **Profile commands**: Monitor CPU/memory usage
- **Async operations**: Use async where appropriate (don't block)
- **Progressive loading**: Load content progressively (don't load everything at once)

## Troubleshooting

### Plugin not appearing in marketplace

**Problem:** Plugin added to marketplace repository but doesn't appear

**Solutions:**
- Verify plugin is listed in `plugins.json`
- Check `.claude-plugin/plugin.json` exists and is valid JSON
- Ensure marketplace is configured: `claude plugin marketplace configure [url]`
- Try refreshing: `claude plugin discover`

### Installation fails

**Problem:** `claude plugin install` returns an error

**Solutions:**
- Verify marketplace URL is correct and accessible
- Check network connectivity
- Ensure plugin directory structure is valid
- Try installing from direct URL: `claude plugin install https://github.com/your-org/plugin-marketplace/tree/main/plugins/my-plugin`

### Version conflicts

**Problem:** Different team members have different plugin versions

**Solutions:**
- Use fixed version constraints in team documentation
- Pin versions during onboarding: `claude plugin install code-reviewer@1.2.0`
- Communicate breaking changes before major version bumps
- Provide migration guides for breaking changes

## Publishing to Public Marketplaces

### When to Go Public

Consider publishing your plugin to a public marketplace when:
- Plugin is well-tested and documented
- Problem it solves is generally useful (not org-specific)
- You have capacity to maintain it
- You're comfortable with community contributions

### Public Marketplace Options

- **Claude Code Official Marketplace** - (When available)
- **GitHub** - Use GitHub releases and marketplace listings
- **Community-maintained registries** - Curated plugin lists

### Preparation for Public Release

- [ ] Write comprehensive README with examples
- [ ] Create CONTRIBUTING guide for maintainers
- [ ] Set up issue templates for bug reports
- [ ] Add license file (MIT, Apache 2.0, etc.)
- [ ] Create CHANGELOG documenting version history
- [ ] Test with multiple Claude Code versions
- [ ] Gather feedback from beta testers
- [ ] Document any external dependencies

## References

- [Claude Code Plugin Discovery](about:/docs/en/discover-plugins)
- [Claude Code Plugins Reference](about:/docs/en/plugins-reference)
- [Semantic Versioning](https://semver.org/)
- [Keep a Changelog](https://keepachangelog.com/)
