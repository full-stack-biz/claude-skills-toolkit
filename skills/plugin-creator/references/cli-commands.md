# Plugin CLI Commands Reference

Claude Code provides command-line commands for plugin management, useful for scripting, automation, and non-interactive workflows.

## Table of Contents

- [Overview](#overview)
- [plugin install](#plugin-install)
- [plugin uninstall](#plugin-uninstall)
- [plugin enable](#plugin-enable)
- [plugin disable](#plugin-disable)
- [plugin update](#plugin-update)
- [Plugin Lifecycle](#plugin-lifecycle)
- [Scope Management Examples](#scope-management-examples)
  - [Installing Same Plugin to Multiple Scopes](#installing-same-plugin-to-multiple-scopes)
  - [Managing Project vs. User Plugins](#managing-project-vs-user-plugins)
  - [Updating Specific Versions](#updating-specific-versions)
- [Integration with Scripts](#integration-with-scripts)
- [Error Handling](#error-handling)
- [Plugin List Command](#plugin-list-command)
- [Validation Command](#validation-command)
- [Help Command](#help-command)
- [Automation Examples](#automation-examples)
  - [Bulk Install](#bulk-install)
  - [Disable All User Plugins](#disable-all-user-plugins)
  - [Check Plugin Status](#check-plugin-status)
- [See Also](#see-also)

## Overview

All plugin commands follow the pattern:
```bash
claude plugin <command> <plugin> [options]
```

## plugin install

Install a plugin from available marketplaces.

**Usage:**
```bash
claude plugin install <plugin> [options]
```

**Arguments:**
- `<plugin>`: Plugin name or `plugin-name@marketplace-name` for specific marketplace

**Options:**
```
-s, --scope <scope>    Installation scope: user, project, or local (default: user)
-h, --help             Display help for command
```

**Examples:**

Install to user scope (global, default):
```bash
claude plugin install code-reviewer
claude plugin install code-reviewer@my-marketplace
```

Install to project scope (shared via git):
```bash
claude plugin install code-reviewer --scope project
```

Install to local scope (personal, gitignored):
```bash
claude plugin install code-reviewer --scope local
```

**Behavior:**
- Copies plugin files to appropriate scope directory
- Creates/updates settings file in scope location
- Plugin becomes available immediately
- Enables plugin automatically (unless already disabled)

**Scope directories:**
- `user`: `~/.claude/skills/plugin-name/`
- `project`: `.claude/skills/plugin-name/`
- `local`: `.claude/skills/plugin-name/` (gitignored)

## plugin uninstall

Remove an installed plugin completely.

**Usage:**
```bash
claude plugin uninstall <plugin> [options]
```

**Aliases:** `remove`, `rm`

**Arguments:**
- `<plugin>`: Plugin name or `plugin-name@marketplace-name`

**Options:**
```
-s, --scope <scope>    Scope to uninstall from: user, project, or local (default: user)
-h, --help             Display help for command
```

**Examples:**

Uninstall from user scope:
```bash
claude plugin uninstall code-reviewer
```

Uninstall from project scope:
```bash
claude plugin uninstall code-reviewer --scope project
```

Uninstall using alias:
```bash
claude plugin remove code-reviewer --scope local
claude plugin rm code-reviewer --scope project
```

**Behavior:**
- Removes plugin directory completely
- Updates settings file to remove plugin reference
- Removes all plugin files and configurations
- Cannot be undone (data loss); reinstall to restore

**Warning:** This is permanent and cannot be undone. Reinstalling will get a fresh copy from the marketplace.

## plugin enable

Enable a disabled plugin (plugin still installed, but not active).

**Usage:**
```bash
claude plugin enable <plugin> [options]
```

**Arguments:**
- `<plugin>`: Plugin name or `plugin-name@marketplace-name`

**Options:**
```
-s, --scope <scope>    Scope to enable: user, project, or local (default: user)
-h, --help             Display help for command
```

**Examples:**

Enable plugin in user scope:
```bash
claude plugin enable code-reviewer
```

Enable plugin in project scope:
```bash
claude plugin enable code-reviewer --scope project
```

**Behavior:**
- Re-activates a disabled plugin
- Updates plugin settings to enabled state
- Plugin commands, hooks, MCP servers, etc. become active again
- Useful after running `plugin disable` to test without uninstalling

## plugin disable

Disable a plugin without uninstalling it (keeps plugin files, but deactivates).

**Usage:**
```bash
claude plugin disable <plugin> [options]
```

**Arguments:**
- `<plugin>`: Plugin name or `plugin-name@marketplace-name`

**Options:**
```
-s, --scope <scope>    Scope to disable: user, project, or local (default: user)
-h, --help             Display help for command
```

**Examples:**

Disable plugin temporarily:
```bash
claude plugin disable code-reviewer
```

Disable plugin in project scope:
```bash
claude plugin disable code-reviewer --scope project
```

**Behavior:**
- Marks plugin as disabled in settings
- Plugin files remain installed (not deleted)
- Commands, hooks, skills, agents, MCP servers not active
- Can be re-enabled with `plugin enable` without reinstalling
- Useful for testing or temporarily disabling problematic plugins

## plugin update

Update an installed plugin to the latest version.

**Usage:**
```bash
claude plugin update <plugin> [options]
```

**Arguments:**
- `<plugin>`: Plugin name or `plugin-name@marketplace-name`

**Options:**
```
-s, --scope <scope>    Scope to update: user, project, local, or managed (default: user)
-h, --help             Display help for command
```

**Examples:**

Update plugin in user scope:
```bash
claude plugin update code-reviewer
```

Update plugin in project scope:
```bash
claude plugin update code-reviewer --scope project
```

Update managed plugins (marketplace):
```bash
claude plugin update code-reviewer --scope managed
```

**Behavior:**
- Fetches latest version from marketplace
- Compares with installed version
- Upgrades if newer version available
- Preserves plugin configuration and settings
- Updates all components (commands, hooks, MCP servers, etc.)

**Scope behavior:**
- `user`, `project`, `local`: Updates from marketplace
- `managed`: Updates read-only marketplace-managed plugins

## Plugin Lifecycle

Typical plugin workflow:

```bash
# 1. Install a plugin
claude plugin install code-reviewer --scope user

# 2. Try it out, test hooks and commands
# ... use the plugin ...

# 3. Temporarily disable if issues
claude plugin disable code-reviewer

# 4. Re-enable once fixed
claude plugin enable code-reviewer

# 5. Check for updates
claude plugin update code-reviewer

# 6. Uninstall if no longer needed
claude plugin uninstall code-reviewer
```

## Scope Management Examples

### Installing Same Plugin to Multiple Scopes

You can install the same plugin at different scopes for different purposes:

```bash
# Install globally for personal use
claude plugin install code-reviewer --scope user

# Install to project for team standardization
claude plugin install code-reviewer --scope project

# Project version takes precedence over user version
```

### Managing Project vs. User Plugins

```bash
# Team plugins (committed to git)
claude plugin install team-linter --scope project
claude plugin install deploy-tools --scope project

# Personal plugins (not shared)
claude plugin install my-utils --scope local
claude plugin install experimental-feature --scope user
```

### Updating Specific Versions

```bash
# Update all plugins in user scope
for plugin in $(claude plugin list | grep user); do
  claude plugin update "$plugin" --scope user
done
```

## Integration with Scripts

Plugin commands are useful in scripts and CI/CD pipelines:

```bash
#!/bin/bash
# Auto-setup plugin environment

PLUGINS=("code-reviewer" "test-runner" "deploy-tools")

for plugin in "${PLUGINS[@]}"; do
  claude plugin install "$plugin" --scope project || {
    echo "Failed to install $plugin"
    exit 1
  }
done

echo "All plugins installed successfully"
```

## Error Handling

Common errors and their meanings:

| Error | Cause | Solution |
|-------|-------|----------|
| `Plugin not found: code-reviewer` | Plugin doesn't exist in marketplace | Check plugin name, ensure marketplace is available |
| `Plugin already installed` | Plugin is already at this scope | Use `plugin update` to upgrade or `plugin uninstall` first |
| `Scope not found` | Invalid scope or scope not initialized | Use valid scopes: `user`, `project`, `local`, `managed` |
| `Permission denied` | Cannot write to scope directory | Check file permissions on `~/.claude/` or `.claude/` |
| `Marketplace unavailable` | Cannot reach marketplace server | Check network connection, verify marketplace URL |

## Plugin List Command

List all installed plugins:

```bash
claude plugin list
```

Output shows:
- Plugin name
- Installed scope
- Current version
- Status (enabled/disabled)

## Validation Command

Validate a plugin manifest before installation:

```bash
claude plugin validate /path/to/plugin
```

Checks:
- Valid JSON in `plugin.json`
- Required fields present
- Component paths exist
- No structural errors

## Help Command

Get help for any plugin command:

```bash
claude plugin --help
claude plugin install --help
claude plugin uninstall --help
```

## Automation Examples

### Bulk Install

```bash
# Install multiple plugins from a list
cat plugins.txt | while read plugin; do
  claude plugin install "$plugin" --scope project
done
```

### Disable All User Plugins

```bash
# Temporarily disable all user-scope plugins
claude plugin list | grep user | awk '{print $1}' | while read plugin; do
  claude plugin disable "$plugin" --scope user
done
```

### Check Plugin Status

```bash
# Show status of all plugins
claude plugin list --verbose
```

## See Also

- [Installation scopes](installation-scopes.md) — Scope details and use cases
- [Plugin manifest](plugin-json-schema.md) — Configuration options
- [Debugging and troubleshooting](debugging-troubleshooting.md) — Troubleshoot plugin issues
