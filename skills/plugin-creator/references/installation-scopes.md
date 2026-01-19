# Plugin Installation Scopes

Plugins install to different scopes based on availability and intended use.

## Scope Types

### `user` (Default, Global)

**Location:** `~/.claude/skills/my-plugin/`

**Availability:** All projects, all sessions

**Use case:** Plugins you use across all projects (personal tools, universal utilities)

**Installation:**
```bash
claude plugin install my-plugin@marketplace --scope user
# or default (no --scope needed)
claude plugin install my-plugin@marketplace
```

**Characteristics:**
- Persistent across projects and sessions
- Available to all Claude Code instances on the machine
- Personal preference (not shared via git)
- User controls installation/updates

### `project` (Project-Local, Shared)

**Location:** `.claude/skills/my-plugin/`

**Availability:** This project only (shared via git)

**Use case:** Plugins specific to team/project (custom linters, domain-specific tools, team workflows)

**Installation:**
```bash
claude plugin install my-plugin@marketplace --scope project
```

**Characteristics:**
- Checked into git (`.claude/skills/` directory tracked)
- All team members get the same plugin via clone/pull
- Project-specific functionality
- Version controlled alongside code
- Team can customize and evolve together

### `local` (Project-Local, Personal)

**Location:** `.claude/skills/my-plugin/`

**Availability:** This project only (NOT shared)

**Use case:** Personal experiments, experimental plugins, local customizations

**Installation:**
```bash
claude plugin install my-plugin@marketplace --scope local
```

**Characteristics:**
- `.claude/skills/` directory is gitignored (not committed)
- Personal use only (not shared with team)
- Good for testing before team adoption
- Can diverge from team plugins without conflict

### `managed` (Read-Only, Marketplace)

**Location:** System cache (not directly accessible)

**Availability:** All projects

**Characteristics:**
- Installed from plugin marketplace
- Read-only (can't edit locally)
- Auto-updated by Claude Code
- Cannot be modified (use `--scope user` if you need to customize)

## Scope Comparison Table

| Aspect | `user` | `project` | `local` | `managed` |
|--------|--------|-----------|---------|-----------|
| **Location** | `~/.claude/skills/` | `.claude/skills/` | `.claude/skills/` | System cache |
| **Git tracked** | No | Yes | No (gitignored) | N/A |
| **Shared with team** | No | Yes | No | N/A |
| **Editable** | Yes | Yes | Yes | No |
| **Default scope** | Yes | No | No | N/A |
| **Multi-project** | Yes | No | No | Yes |
| **Use case** | Personal tools | Team plugins | Experiments | Marketplace |

## Choosing a Scope

**Use `user` scope when:**
- Plugin is universally useful (not project-specific)
- You want it available across all projects
- It's a personal productivity tool
- Example: Code formatter, file utilities, personal linters

**Use `project` scope when:**
- Plugin is specific to this project/team
- Team should use consistent version
- Plugin is part of project standards
- Example: Custom company linter, domain-specific analyzer, team-specific tools

**Use `local` scope when:**
- Testing a plugin before team adoption
- Experimenting with custom versions
- Personal workflow that shouldn't be shared
- Example: Experimental feature, personal customization

**Use marketplace (`managed`) when:**
- Installing published plugins
- Don't need to customize the plugin
- Want automatic updates

## Scope Installation Examples

**Install globally for all projects:**
```bash
cd ~/any-project
claude plugin install code-reviewer@marketplace --scope user
# Now available in all projects
```

**Install for current project only (shared):**
```bash
cd ~/my-team-project
claude plugin install code-reviewer@marketplace --scope project
# Committed to git, team members get it via git
```

**Install for current project (personal experiment):**
```bash
cd ~/my-team-project
claude plugin install code-reviewer@marketplace --scope local
# NOT committed to git, personal use only
```

## Changing Scopes

If you install a plugin at the wrong scope:

1. **Uninstall** from current scope:
   ```bash
   claude plugin uninstall code-reviewer --scope user
   ```

2. **Reinstall** at correct scope:
   ```bash
   claude plugin install code-reviewer@marketplace --scope project
   ```

## Best Practices

**For teams:**
- Install shared plugins at `project` scope
- Commit `.claude/skills/` to git
- Document required plugins in README or CONTRIBUTING.md
- Review plugins before adding to `project` scope (security)

**For individuals:**
- Use `user` scope for personal productivity tools
- Use `project` scope for team collaboration
- Use `local` scope for experimentation
- Keep `~/.claude/skills/` organized

**For plugin development:**
- Test with `--plugin-dir` flag first (no installation)
- Use `local` scope for beta testing
- Move to `project` scope once stable
- Publish to marketplace when ready for broader use

## Scope Verification

Check what plugins are installed in each scope:

```bash
# List all installed plugins (all scopes)
claude plugin list

# Check specific directories
ls ~/.claude/skills/            # user scope
ls .claude/skills/              # project scope
```

## Scope Conflicts

If a plugin exists in multiple scopes:
1. `local` scope takes precedence over `project`
2. `project` scope takes precedence over `user`
3. `managed` is lowest priority

Example: If `code-reviewer` is installed in both `user` and `project` scopes, the `project` version is used.
