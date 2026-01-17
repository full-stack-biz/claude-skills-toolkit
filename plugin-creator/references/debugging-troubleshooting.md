# Debugging and Troubleshooting Plugins

This guide helps you diagnose and fix plugin issues using Claude Code's debugging tools and error handling strategies.

## Table of Contents

- [Debugging Tools](#debugging-tools)
- [Common Issues and Solutions](#common-issues-and-solutions)
  - [Issue 1: Plugin Not Loading](#issue-1-plugin-not-loading)
  - [Issue 2: Invalid JSON Syntax](#issue-2-invalid-json-syntax)
  - [Issue 3: Commands Not Appearing](#issue-3-commands-not-appearing)
  - [Issue 4: Hooks Not Executing](#issue-4-hooks-not-executing)
  - [Issue 5: MCP Server Not Starting](#issue-5-mcp-server-not-starting)
  - [Issue 6: LSP Server Executable Not Found](#issue-6-lsp-server-executable-not-found)
  - [Issue 7: Plugin Works with --plugin-dir but Fails After Install](#issue-7-plugin-works-with---plugin-dir-but-fails-after-install)
- [Error Message Reference](#error-message-reference)
- [Troubleshooting Workflow](#troubleshooting-workflow)
- [Debugging Specific Components](#debugging-specific-components)
- [Getting Help](#getting-help)
- [See Also](#see-also)

## Debugging Tools

### claude --debug

Enable debug output to see detailed plugin loading information.

**Usage:**
```bash
claude --debug
```

**Output shows:**
- Which plugins are being loaded
- Plugin manifest parsing
- Component discovery (commands, agents, hooks, MCP servers)
- Error messages during initialization
- Plugin activation and invocation

**Example debug output:**
```
[DEBUG] Loading plugins from: ~/.claude/skills/
[DEBUG] Plugin: code-reviewer
  ✓ Manifest loaded: .claude-plugin/plugin.json
  ✓ Commands: 3 found (validate, report, export)
  ✓ Hooks: PostToolUse configured
  ✓ MCP servers: 0
  ✓ Skills: 1 found (code-analyzer)
[DEBUG] Plugin: test-runner
  ✓ Manifest loaded
  ✓ Commands: 2 found
  ⚠ Hook script not executable: ./scripts/test.sh
```

### Validation Command

Validate plugin manifest before installation:

```bash
claude plugin validate /path/to/plugin
```

Checks:
- Valid JSON syntax in `plugin.json`
- Required fields present (`name`, `description`)
- Field types correct (strings, objects, arrays)
- No obvious structural errors
- Path references exist

**Output:**
```
✓ Plugin "code-reviewer" is valid
✓ All required fields present
✓ No schema violations
```

## Common Issues and Solutions

### Issue 1: Plugin Not Loading

**Symptoms:**
- Plugin doesn't appear in `/agents` list
- Commands not available via `/plugin-name:command`
- No plugin listed in `claude plugin list`

**Diagnosis:**

Run debug to see if plugin is even discovered:
```bash
claude --debug | grep "your-plugin"
```

Look for:
- "Plugin not found at path..." → Plugin directory doesn't exist
- "No manifest found" → `.claude-plugin/plugin.json` missing
- "Invalid manifest" → JSON syntax error
- "Plugin loading failed" → Manifest validation error

**Common causes:**

| Cause | Fix |
|-------|-----|
| Plugin installed to wrong scope | Check all scopes: `ls ~/.claude/skills/ && ls .claude/skills/` |
| `.claude-plugin/` directory missing | Create: `mkdir -p plugin-root/.claude-plugin/` |
| `plugin.json` in wrong location | Must be at `.claude-plugin/plugin.json`, not in root |
| Invalid JSON in manifest | Validate: `jq . .claude-plugin/plugin.json` |
| Permission denied on directory | Check: `ls -ld ~/.claude/skills/your-plugin/` |
| Plugin name conflicts | Use unique name: `claude plugin list \| grep name` |

### Issue 2: Invalid JSON Syntax

**Symptoms:**
- Error: "Invalid JSON syntax: Unexpected token }"
- Plugin fails to load
- Debug shows "corrupt manifest"

**Examples of JSON errors:**

❌ **Missing comma:**
```json
{
  "name": "my-plugin",
  "description": "Description"  ← Missing comma
  "version": "1.0.0"
}
```

✅ **Fixed:**
```json
{
  "name": "my-plugin",
  "description": "Description",  ← Added comma
  "version": "1.0.0"
}
```

❌ **Extra comma:**
```json
{
  "name": "my-plugin",
  "version": "1.0.0",  ← Extra comma after last field
}
```

✅ **Fixed:**
```json
{
  "name": "my-plugin",
  "version": "1.0.0"   ← Removed trailing comma
}
```

❌ **Unquoted string:**
```json
{
  "name": my-plugin,     ← Not quoted
  "version": "1.0.0"
}
```

✅ **Fixed:**
```json
{
  "name": "my-plugin",   ← Quoted
  "version": "1.0.0"
}
```

**Validation tool:**
```bash
# Validate JSON syntax
jq . .claude-plugin/plugin.json

# Pretty-print with syntax check
python -m json.tool .claude-plugin/plugin.json

# Validate online or use IDE JSON validator
```

### Issue 3: Commands Not Appearing

**Symptoms:**
- `/plugin-name:command` not recognized
- Command not listed in completion
- Plugin loads but commands missing

**Diagnosis:**

1. Check commands directory exists:
```bash
ls -la plugin-root/commands/
```

2. Verify command files are Markdown:
```bash
ls plugin-root/commands/
# Should see: command1.md, command2.md, etc.
```

3. Check command frontmatter:
```bash
head -20 plugin-root/commands/my-command.md
# Should have: ---\nname: my-command\n...
```

4. Run debug and look for command loading:
```bash
claude --debug | grep -i command
```

**Common causes:**

| Cause | Fix |
|-------|-----|
| Commands in `.claude-plugin/` | Move to `plugin-root/commands/` |
| Command files not `.md` | Rename: `command.txt` → `command.md` |
| Missing YAML frontmatter | Add: `---\nname: cmd\ndescription: ...\n---` |
| Invalid command name in frontmatter | Use lowercase-hyphen: `my-command` |
| Commands path not in plugin.json | Add: `"commands": "./commands/"` |
| Directory structure nested too deep | Keep at root: `commands/` not `lib/src/commands/` |

### Issue 4: Hooks Not Executing

**Symptoms:**
- Hook script not running on expected events
- No output from hook scripts
- Debug shows hook configured but not firing

**Diagnosis:**

1. Verify hook configuration is valid JSON:
```bash
jq . plugin-root/hooks.json
```

2. Check event name is case-sensitive:
```bash
# Correct (capital P and T)
"PostToolUse"
"UserPromptSubmit"

# Wrong (will not work)
"postToolUse"
"userpromptsubmit"
```

3. Verify script is executable:
```bash
ls -l plugin-root/scripts/my-script.sh
# Should show: -rwxr-xr-x (x flags set)

# Make executable if needed:
chmod +x plugin-root/scripts/my-script.sh
```

4. Check script has proper shebang:
```bash
head -1 plugin-root/scripts/my-script.sh
# Should be: #!/bin/bash or #!/usr/bin/env bash
```

5. Test script manually:
```bash
./plugin-root/scripts/my-script.sh
# Should run without error
```

6. Run debug and look for hook loading:
```bash
claude --debug | grep -i hook
```

**Common causes:**

| Cause | Fix |
|-------|-----|
| Event name misspelled/wrong case | Use exact names: `PostToolUse`, `PreToolUse`, `UserPromptSubmit` |
| Script not executable | `chmod +x ./scripts/script.sh` |
| Missing shebang | Add `#!/bin/bash` as first line |
| Path to script incorrect | Use `${CLAUDE_PLUGIN_ROOT}/scripts/script.sh` |
| Matcher doesn't match tools | Use correct tool names in matcher: `"Write\|Edit"` |
| Hook path wrong in plugin.json | Should be: `"hooks": "./hooks.json"` |
| Invalid JSON in hooks.json | Validate with `jq .` |

**Hook Event Names Reference:**

| Event | When it fires |
|-------|---------------|
| `PreToolUse` | Before Claude uses any tool |
| `PostToolUse` | After successful tool use |
| `PostToolUseFailure` | After tool use fails |
| `PermissionRequest` | When permission dialog shown |
| `UserPromptSubmit` | When user submits prompt |
| `Notification` | When Claude sends notifications |
| `Stop` | When Claude attempts to stop |
| `SubagentStart` | When subagent starts |
| `SubagentStop` | When subagent stops |
| `SessionStart` | At session beginning |
| `SessionEnd` | At session end |
| `PreCompact` | Before conversation compaction |

### Issue 5: MCP Server Not Starting

**Symptoms:**
- MCP server tools don't appear in Claude's toolkit
- Error: "MCP server failed to start"
- Debug shows connection timeout

**Diagnosis:**

1. Verify MCP configuration is valid JSON:
```bash
jq . plugin-root/.mcp.json
```

2. Check command exists and is in PATH:
```bash
which python  # If using: "command": "python"
which node    # If using: "command": "node"
which gopls   # If using: "command": "gopls"

# If command not found, install it first
```

3. Check MCP server path uses `${CLAUDE_PLUGIN_ROOT}`:
```json
{
  "server-name": {
    "command": "python",
    "args": ["${CLAUDE_PLUGIN_ROOT}/mcp/server.py"]  ← Variable required
  }
}
```

4. Test server manually:
```bash
python /full/path/to/plugin/mcp/server.py
# Should start without error
```

5. Check server logs with debug:
```bash
claude --debug | grep -i "mcp\|server"
```

**Common causes:**

| Cause | Fix |
|-------|-----|
| Command not in PATH | Install first: `npm install -g package` or verify path |
| Missing `${CLAUDE_PLUGIN_ROOT}` variable | Use variable for absolute paths in args |
| Path to server script wrong | Verify file exists: `ls ${path}` |
| Server not compatible with MCP | Verify server implements MCP protocol |
| Startup timeout | Check if server hangs; increase `startupTimeout` |
| Wrong working directory | Use `cwd: "${CLAUDE_PLUGIN_ROOT}"` |
| Environment variables missing | Set in `env` field if server needs them |

### Issue 6: LSP Server Executable Not Found

**Symptoms:**
- Error: "Executable not found in $PATH"
- LSP features (go to definition, hover) not working
- Debug shows LSP initialization failed

**Diagnosis:**

1. Verify LSP server command is in PATH:
```bash
which gopls    # For Go
which pyright  # For Python
which rust-analyzer  # For Rust
```

2. If not installed, install it first:
```bash
# Go
brew install gopls  # or get from https://github.com/golang/tools

# Python
pip install pyright

# Rust
rustup component add rust-analyzer
```

3. Verify PATH includes location:
```bash
echo $PATH
# Should include directory where server was installed
```

4. Check plugin.json LSP configuration:
```json
{
  "lspServers": {
    "go": {
      "command": "gopls",        ← Must be in PATH
      "args": ["serve"]
    }
  }
}
```

5. Test server directly:
```bash
gopls -h  # or whatever command
# Should show help output
```

**Common causes:**

| Cause | Fix |
|-------|-----|
| Language server not installed | Install: `pip install pyright`, `npm install -g ...` |
| Server in wrong PATH location | Reinstall to standard location |
| Wrong server name | Verify executable name: `which gopls` |
| Shell doesn't have updated PATH | Restart terminal or Claude Code |
| Different Python/Node version | Use full path: `/usr/local/bin/python` |

### Issue 7: Plugin Works with --plugin-dir but Fails After Install

**Symptoms:**
- Plugin works during development: `claude --plugin-dir /path/to/plugin`
- Plugin fails after: `claude plugin install /path/to/plugin`
- Paths broken after installation

**Diagnosis:**

Compare behavior:
```bash
# Works:
claude --plugin-dir /path/to/my-plugin

# Fails:
claude plugin install /path/to/my-plugin --scope local
```

**This indicates:** Paths or file references that work during development don't work in cache.

**Common causes:**

| Cause | Fix |
|-------|-----|
| References to parent directory | Copy files into plugin or use symlinks |
| Relative paths without `./` | Add `./` to all relative paths |
| Hard-coded absolute paths | Use `${CLAUDE_PLUGIN_ROOT}` instead |
| External symlinks not followed | Create symlinks inside plugin before install |

**Solution workflow:**

1. Create symlinks for external files:
```bash
cd /path/to/my-plugin
ln -s /path/to/shared-code ./shared-code
```

2. Update plugin.json to use symlinked paths:
```json
{
  "skills": ["./skills/", "./shared-code/skills/"]
}
```

3. Reinstall and test:
```bash
claude plugin uninstall my-plugin --scope local
claude plugin install /path/to/my-plugin --scope local
```

See [Plugin caching](plugin-caching.md) for complete guide.

## Error Message Reference

### Manifest Errors

```
Error: Plugin has an invalid manifest file at .claude-plugin/plugin.json.
Validation errors: name: Required
```
**Fix:** Add `"name"` field to plugin.json

```
Error: Plugin has a corrupt manifest file at .claude-plugin/plugin.json.
JSON parse error: Unexpected token } in JSON at position 142
```
**Fix:** Check JSON syntax near position 142 (look for missing comma or quote)

```
Error: Plugin name contains reserved word: claude-utilities
```
**Fix:** Rename plugin to not contain "claude" or "anthropic"

### Component Errors

```
Warning: No commands found in plugin my-plugin custom directory: ./cmds.
Expected .md files or SKILL.md in subdirectories.
```
**Fix:** Check path exists or remove from plugin.json if not needed

```
Warning: Agent directory not found: ./custom-agents
Plugin will skip this component.
```
**Fix:** Create directory or correct path in plugin.json

### Execution Errors

```
Hook script failed with error: Permission denied
```
**Fix:** `chmod +x ./scripts/your-script.sh`

```
MCP server failed to connect after 5000ms
```
**Fix:** Check if server is running, increase timeout, verify logs

## Troubleshooting Workflow

1. **Enable debug:**
   ```bash
   claude --debug 2>&1 | tee debug.log
   ```

2. **Identify error from debug output:**
   - Look for `[ERROR]`, `[WARN]`, or `Failed` messages
   - Note component that failed (command, hook, MCP server, etc.)

3. **Apply relevant fix from table above**

4. **Validate manifest:**
   ```bash
   claude plugin validate /path/to/plugin
   ```

5. **Test in development mode:**
   ```bash
   claude --plugin-dir /path/to/plugin
   ```

6. **Test installed:**
   ```bash
   claude plugin install /path/to/plugin --scope local
   ```

7. **Reinstall if path-related:**
   ```bash
   claude plugin uninstall plugin-name --scope local
   claude plugin install /path/to/plugin --scope local
   ```

8. **Check file permissions:**
   ```bash
   ls -la plugin-root/scripts/
   chmod +x plugin-root/scripts/*.sh
   ```

## Debugging Specific Components

### Debugging Commands

1. Run debug and look for command loading
2. Verify `.md` files in `commands/` directory
3. Check frontmatter in each command file
4. Test command manually: `/plugin-name:command-name`

### Debugging Hooks

1. Verify `hooks.json` valid JSON
2. Check event name exact spelling and case
3. Make scripts executable: `chmod +x script.sh`
4. Test script manually before adding to hooks
5. Look for matcher patterns matching tool names

### Debugging MCP Servers

1. Verify command in PATH: `which command-name`
2. Test server manually: `command-name [args]`
3. Check stderr/stdout for errors
4. Use `--debug` to see startup messages
5. Verify all `${CLAUDE_PLUGIN_ROOT}` variables expand correctly

### Debugging Skills

1. Verify `SKILL.md` files in `skills/skill-name/`
2. Check skill frontmatter (name, description)
3. Ensure skill descriptions are specific (Claude activation)
4. Look for tokenefficiency: keep body <500 lines
5. Check if skill is actually being invoked (might be activation issue, not syntax)

## Getting Help

If you can't resolve the issue:

1. **Collect debug output:**
   ```bash
   claude --debug 2>&1 > debug.log
   ```

2. **List installed plugins:**
   ```bash
   claude plugin list
   ```

3. **Check plugin structure:**
   ```bash
   tree -L 2 ~/.claude/skills/your-plugin/
   ```

4. **Validate manifest:**
   ```bash
   claude plugin validate /path/to/plugin
   ```

5. **Share error messages and debug output** with support or team

## See Also

- [CLI commands](cli-commands.md) — Plugin installation and management
- [Plugin manifest](plugin-json-schema.md) — Configuration schema
- [Plugin caching](plugin-caching.md) — File path issues
- [Plugin paths and variables](plugin-paths-variables.md) — Path resolution
- [Hooks](hooks.md) — Hook configuration and patterns
