# Plugin Caching and File Resolution

Understanding how Claude Code handles plugin caching and file paths is essential for plugins that reference external files or need reliable path resolution after installation.

## Table of Contents

- [Overview](#overview)
- [How Plugin Caching Works](#how-plugin-caching-works)
  - [Installation and Copying](#installation-and-copying)
  - [Cache Locations by Scope](#cache-locations-by-scope)
  - [Marketplace Source Copying](#marketplace-source-copying)
  - [Plugin Root Directory Copying](#plugin-root-directory-copying)
- [Path Traversal Limitations](#path-traversal-limitations)
  - [Critical Rule: No External File Access](#critical-rule-no-external-file-access)
  - [Example Path Traversal Problem](#example-path-traversal-problem)
- [Solutions: Working with External Files](#solutions-working-with-external-files)
  - [Solution 1: Copy Files into Plugin](#solution-1-copy-files-into-plugin)
  - [Solution 2: Use Symlinks (Recommended for Development)](#solution-2-use-symlinks-recommended-for-development)
  - [Solution 3: Restructure Marketplace Entry (For Marketplace Plugins)](#solution-3-restructure-marketplace-entry-for-marketplace-plugins)
- [Path Resolution at Runtime](#path-resolution-at-runtime)
  - [Absolute vs. Relative Paths](#absolute-vs-relative-paths)
  - [Variable Expansion](#variable-expansion)
- [File Resolution Order](#file-resolution-order)
- [Caching and Development Workflow](#caching-and-development-workflow)
  - [Development Mode (--plugin-dir)](#development-mode---plugin-dir)
  - [Testing Before Installation](#testing-before-installation)
  - [Debugging Path Issues](#debugging-path-issues)
- [Common Path Issues and Fixes](#common-path-issues-and-fixes)
- [Security Implications](#security-implications)
  - [What Plugins Can Access](#what-plugins-can-access)
- [Best Practices](#best-practices)
- [See Also](#see-also)

## Overview

When you install a plugin, Claude Code copies it to a cache directory rather than using it in-place. This provides security, verification, and isolation benefits but creates important implications for how plugins reference files.

## How Plugin Caching Works

### Installation and Copying

When you run `claude plugin install my-plugin`:

1. **Locate plugin source** - Claude Code finds the plugin from the marketplace or local source
2. **Copy to cache** - Entire plugin directory is recursively copied to a scope-specific location
3. **Register plugin** - Plugin is registered in scope-specific settings file
4. **Verify manifest** - `plugin.json` is validated
5. **Load components** - Commands, hooks, agents, skills, MCP servers are indexed

### Cache Locations by Scope

| Scope | Cache Location | Details |
|-------|----------------|---------|
| `user` | `~/.claude/skills/plugin-name/` | Global cache, persistent |
| `project` | `.claude/skills/plugin-name/` | Project-specific cache |
| `local` | `.claude/skills/plugin-name/` | Project-specific, gitignored |
| `managed` | System cache (OS-dependent) | Read-only, managed by Claude Code |

### Marketplace Source Copying

When installing from a marketplace with `source` field:

**marketplace.json example:**
```json
{
  "plugins": [
    {
      "name": "my-plugin",
      "source": "./plugins/my-plugin",
      "description": "..."
    }
  ]
}
```

The `source` path (`./plugins/my-plugin`) is copied recursively to the scope cache directory:
- Source: `./plugins/my-plugin/` → Cache: `~/.claude/skills/my-plugin/`
- All files in source directory are copied
- Directory structure is preserved
- Symlinks are honored (copied as symlinks, not dereferenced)

### Plugin Root Directory Copying

If no `source` field is specified, the plugin root (directory containing `.claude-plugin/plugin.json`) is copied:
- Everything in plugin root → Cache root
- All subdirectories included
- Manifest at `.claude-plugin/plugin.json` is preserved

## Path Traversal Limitations

### Critical Rule: No External File Access

Plugins **cannot reference files outside their copied directory structure**. This is a security boundary.

**❌ BROKEN - Won't work after installation:**
```json
{
  "agents": "../shared-agents/",
  "skills": "../../team-skills/"
}
```

Why:
- These paths reference directories outside the plugin root
- When plugin is copied to cache, parent directories are not included
- Paths become invalid after installation
- Plugin loads in development (`--plugin-dir`) but fails after `plugin install`

### Example Path Traversal Problem

**Plugin source structure:**
```
monorepo/
├── shared-utils/          ← External to plugin
│   └── helpers.js
├── plugins/
│   └── my-plugin/
│       ├── .claude-plugin/
│       │   └── plugin.json
│       ├── commands/
│       └── skills/
```

**❌ This plugin.json won't work:**
```json
{
  "name": "my-plugin",
  "hooks": "../shared-utils/hooks.json"
}
```

After installation to `~/.claude/skills/my-plugin/`:
- Path `../shared-utils/hooks.json` would look outside plugin cache
- File doesn't exist at that location
- Plugin fails to load

## Solutions: Working with External Files

### Solution 1: Copy Files into Plugin

Copy external dependencies into the plugin directory structure before distribution:

```bash
# Build script for plugin distribution
cp -r ../shared-utils ./shared-utils
cp -r ../../team-skills ./vendor/skills
```

**Resulting structure:**
```
my-plugin/
├── .claude-plugin/
│   └── plugin.json
├── commands/
├── skills/
├── shared-utils/         ← Copied in
└── vendor/
    └── skills/           ← Copied in
```

**plugin.json:**
```json
{
  "name": "my-plugin",
  "hooks": "./shared-utils/hooks.json",
  "skills": ["./skills/", "./vendor/skills/"]
}
```

After installation, all paths work because files are included in cache.

### Solution 2: Use Symlinks (Recommended for Development)

Create symbolic links to external files within the plugin directory:

```bash
# In plugin directory
ln -s /path/to/shared-utils ./shared-utils
ln -s /path/to/team-skills ./vendor/skills
```

**Advantages:**
- Single source of truth (actual files elsewhere)
- Symlinks are followed during copy process
- Symlinked content is copied into plugin cache
- Changes to shared files are reflected automatically (before copy)

**How symlink copying works:**
1. `claude plugin install` copies plugin directory
2. Symlinks are detected and followed
3. Target files are copied into plugin cache (not just the symlink)
4. After installation, symlinked content exists in cache
5. Plugin works with absolute `${CLAUDE_PLUGIN_ROOT}` paths

**Create symlinks:**
```bash
cd /path/to/my-plugin
ln -s /path/to/shared-utils ./shared-utils
ln -s /path/to/team-skills ./vendor/skills
```

**plugin.json (unchanged):**
```json
{
  "name": "my-plugin",
  "skills": ["./skills/", "./vendor/skills/"]
}
```

### Solution 3: Restructure Marketplace Entry (For Marketplace Plugins)

Set the marketplace `source` to a parent directory that contains all required files:

**marketplace.json:**
```json
{
  "plugins": [
    {
      "name": "my-plugin",
      "source": "./",
      "description": "My plugin with shared resources",
      "commands": ["./plugins/my-plugin/commands/"],
      "agents": ["./plugins/my-plugin/agents/"],
      "skills": ["./plugins/my-plugin/skills/", "./team-skills/"],
      "strict": false
    }
  ]
}
```

**Directory structure:**
```
marketplace-root/
├── shared-utils/
├── team-skills/
├── plugins/
│   └── my-plugin/
│       ├── commands/
│       ├── agents/
│       └── skills/
└── marketplace.json
```

When `source: "./"` is used:
- Entire marketplace root is copied to cache
- All subdirectories included (shared-utils, team-skills, plugins/)
- Plugin can reference all paths

**Settings:**
- `"strict": false` allows marketplace entry to augment `plugin.json`
- Both manifest file and marketplace entry component paths are loaded
- Parent directory structure is preserved in cache

## Path Resolution at Runtime

### Absolute vs. Relative Paths

**In plugin.json (use relative paths):**
```json
{
  "commands": "./commands/",
  "agents": "./agents/",
  "skills": "./skills/",
  "hooks": "./hooks.json"
}
```

All paths are relative to plugin root in cache.

**In hooks, scripts, MCP servers (use ${CLAUDE_PLUGIN_ROOT}):**
```json
{
  "type": "command",
  "command": "${CLAUDE_PLUGIN_ROOT}/scripts/format.sh"
}
```

The variable expands to the absolute cache path.

### Variable Expansion

`${CLAUDE_PLUGIN_ROOT}` is expanded at runtime to:
- `user` scope: `~/.claude/skills/plugin-name`
- `project` scope: `/absolute/path/to/project/.claude/skills/plugin-name`
- `local` scope: `/absolute/path/to/project/.claude/skills/plugin-name`
- `managed` scope: System cache path (varies by OS)

## File Resolution Order

When Claude Code loads a plugin:

1. **Locate plugin** in scope directories (user, project, local, managed)
2. **Read plugin.json** from `.claude-plugin/plugin.json`
3. **Resolve relative paths** relative to plugin cache root
4. **Expand variables** like `${CLAUDE_PLUGIN_ROOT}` to absolute paths
5. **Load components** from resolved paths
6. **Error if paths invalid** - plugin fails to load with clear error message

## Caching and Development Workflow

### Development Mode (--plugin-dir)

When developing locally with `--plugin-dir`:

```bash
claude --plugin-dir /path/to/my-plugin
```

**Behavior:**
- Plugin is NOT copied to cache
- Plugin loaded directly from `/path/to/my-plugin`
- Symlinks work as expected
- External paths (if in parent directory) can work
- Changes to plugin files are visible immediately

**Limitations:**
- Parent directory access only works during development
- Will fail after `plugin install` if you reference parent files
- Test with `plugin install --scope local` before release

### Testing Before Installation

```bash
# 1. Develop with --plugin-dir (symlinks work, external refs work)
claude --plugin-dir /path/to/my-plugin

# 2. Test installation to local scope (gitignored, test without sharing)
cd /my-project
claude plugin install /path/to/my-plugin --scope local

# 3. Verify paths resolve correctly in cache
ls .claude/skills/my-plugin/

# 4. If successful, commit and test project scope
claude plugin install /path/to/my-plugin --scope project
```

### Debugging Path Issues

Check what files are in plugin cache after installation:

```bash
# User scope
ls ~/.claude/skills/my-plugin/

# Project scope
ls .claude/skills/my-plugin/

# Check if symlinks were followed
ls -la ~/.claude/skills/my-plugin/
```

If symlinked content is missing:
1. Verify symlinks exist before installation
2. Reinstall plugin: `claude plugin uninstall && claude plugin install`
3. Check file permissions on symlink targets

## Common Path Issues and Fixes

| Problem | Symptom | Fix |
|---------|---------|-----|
| Parent directory reference | Plugin works with `--plugin-dir` but fails after install | Copy files into plugin or use symlinks |
| Absolute hard-coded paths | Plugin only works on developer's machine | Use `${CLAUDE_PLUGIN_ROOT}` variable |
| Missing ./ prefix | Claude Code doesn't recognize path | Add `./` to all relative paths in plugin.json |
| Broken symlink | Symlink in cache doesn't resolve | Target must exist when plugin is installed |
| Path not in cache | Referenced file not found after install | Ensure file is copied/symlinked into plugin root |

## Security Implications

Plugin caching provides security benefits:

1. **Isolation** - Plugins can't access files outside their directory
2. **Verification** - Claude Code can verify plugin manifest and structure
3. **Integrity** - Copies prevent modification of installed plugins
4. **Cleanup** - Uninstalling completely removes plugin files

### What Plugins Can Access

✅ **Allowed:**
- Files within plugin cache directory (`${CLAUDE_PLUGIN_ROOT}`)
- Subdirectories and nested files
- Symlinked content (copied into cache)

❌ **Not allowed:**
- Parent directories (`../`)
- Sibling directories outside plugin root
- Absolute paths to arbitrary system files
- Network file systems outside cache

## Best Practices

1. **Keep plugins self-contained** - All files should be within plugin root
2. **Use symlinks for shared code** - Link to external files during development
3. **Include dependencies** - Copy required files into plugin before distribution
4. **Use `${CLAUDE_PLUGIN_ROOT}`** - For absolute paths in hooks and scripts
5. **Test with local scope** - Install to `.claude/skills/` before team deployment
6. **Document external dependencies** - If plugin expects specific setup

## See Also

- [Plugin paths and variables](plugin-paths-variables.md) — Path types and variable usage
- [Plugin manifest](plugin-json-schema.md) — Configuration options
- [CLI commands](cli-commands.md) — Installation and management commands
- [Debugging and troubleshooting](debugging-troubleshooting.md) — Troubleshoot path issues
