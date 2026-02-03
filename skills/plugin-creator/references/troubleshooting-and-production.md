# Troubleshooting, Debugging & Production Best Practices

This guide covers debugging plugin issues, resolving common problems, and applying best practices for production-quality plugins.

---

## Part 1: Debugging and Troubleshooting

### Debugging Tools

#### claude --debug

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

#### Validation Command

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

### Common Issues and Solutions

#### Issue 1: Plugin Not Loading

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

#### Issue 2: Invalid JSON Syntax

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

**Validation tool:**
```bash
# Validate JSON syntax
jq . .claude-plugin/plugin.json

# Pretty-print with syntax check
python -m json.tool .claude-plugin/plugin.json
```

#### Issue 3: Commands Not Appearing

**Symptoms:**
- `/plugin-name:command` not recognized
- Command not listed in completion
- Plugin loads but commands missing

**Common causes:**

| Cause | Fix |
|-------|-----|
| Commands in `.claude-plugin/` | Move to `plugin-root/commands/` |
| Command files not `.md` | Rename: `command.txt` → `command.md` |
| Missing YAML frontmatter | Add: `---\nname: cmd\ndescription: ...\n---` |
| Invalid command name in frontmatter | Use lowercase-hyphen: `my-command` |

#### Issue 4: Hooks Not Executing

**Symptoms:**
- Hook script not running on expected events
- No output from hook scripts
- Debug shows hook configured but not firing

**Common causes:**

| Cause | Fix |
|-------|-----|
| Event name misspelled/wrong case | Use exact names: `PostToolUse`, `PreToolUse`, `UserPromptSubmit` |
| Script not executable | `chmod +x ./scripts/script.sh` |
| Missing shebang | Add `#!/bin/bash` as first line |
| Path to script incorrect | Use `${CLAUDE_PLUGIN_ROOT}/scripts/script.sh` |
| Matcher doesn't match tools | Use correct tool names in matcher: `"Write\|Edit"` |

**Hook Event Names Reference:**

| Event | When it fires |
|-------|---------------|
| `PreToolUse` | Before Claude uses any tool |
| `PostToolUse` | After successful tool use |
| `PostToolUseFailure` | After tool use fails |
| `PermissionRequest` | When permission dialog shown |
| `UserPromptSubmit` | When user submits prompt |
| `SubagentStart` | When subagent starts |
| `SubagentStop` | When subagent stops |
| `SessionStart` | At session beginning |
| `SessionEnd` | At session end |

#### Issue 5: MCP Server Not Starting

**Symptoms:**
- MCP server tools don't appear in Claude's toolkit
- Error: "MCP server failed to start"
- Debug shows connection timeout

**Common causes:**

| Cause | Fix |
|-------|-----|
| Command not in PATH | Install first: `npm install -g package` or verify path |
| Missing `${CLAUDE_PLUGIN_ROOT}` variable | Use variable for absolute paths in args |
| Path to server script wrong | Verify file exists: `ls ${path}` |
| Server not compatible with MCP | Verify server implements MCP protocol |

#### Issue 6: Plugin Works with --plugin-dir but Fails After Install

**Symptoms:**
- Plugin works during development: `claude --plugin-dir /path/to/plugin`
- Plugin fails after: `claude plugin install /path/to/plugin`
- Paths broken after installation

**Common causes:**

| Cause | Fix |
|-------|-----|
| References to parent directory | Copy files into plugin or use symlinks |
| Relative paths without `./` | Add `./` to all relative paths |
| Hard-coded absolute paths | Use `${CLAUDE_PLUGIN_ROOT}` instead |
| External symlinks not followed | Create symlinks inside plugin before install |

### Error Message Reference

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

### Troubleshooting Workflow

1. **Enable debug:**
   ```bash
   claude --debug 2>&1 | tee debug.log
   ```

2. **Identify error from debug output**

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

---

## Part 2: Production Best Practices

### Naming Conventions

**Plugin Name:**
- Format: lowercase, hyphens, 1-64 characters
- Pattern: `[action]-[domain]` or `[domain]-[type]`
- Examples: `code-reviewer`, `pdf-processor`, `test-runner`

**Command Names:**
- Format: lowercase, hyphens
- Principle: Verb-based (what Claude does)
- Examples: `validate`, `generate-report`

**Directory Names:**
- Format: lowercase, hyphens
- Consistency across plugin

### Description Writing

**Plugin Description Formula:**

```
[Action/capability]. [Brief description of purpose]. [Components/scope].
```

**Examples:**

```
Review code for best practices and potential issues. Includes validate, report, and export commands.
```

```
Extract and analyze PDF documents with OCR. Supports encrypted PDFs and multiple formats.
```

**Good descriptions:**
- Clear and specific about what the plugin does
- Mentions key capabilities or supported features
- Includes component list or scope

**Poor descriptions:**
- "for processing" (too vague and generic)
- "for useful operations" (meaningless)
- "a general-purpose tool" (unclear purpose)

### Component Organization

**Good:** One level deep
```
plugin/
├── commands/
│   ├── validate.md
│   └── report.md
├── agents/
│   └── analyzer.md
└── skills/
    └── analysis/SKILL.md
```

**Poor:** Deeply nested
```
plugin/
├── src/
│   ├── commands/
│   │   └── validate/v1/latest.md    # Too many levels
```

### Documentation

**Inline Instructions:**

Clear, actionable instructions with examples.

**Skill Body Length:**

**Rule:** Keep SKILL.md body <500 lines

Why?
- Claude reads body on every skill invocation
- Longer = higher token cost
- Move detailed content to references/

**Structure:**
- Lines 1-100: Essential instructions (Quick Start)
- Lines 100-300: Examples and workflow patterns
- Lines 300-500: Key notes and edge cases
- 500+: Move to references/, link from body

**README for Distribution:**

For team/marketplace plugins, include README.md with:
- Description (what, who, problems solved)
- Installation instructions
- Usage examples
- Features list
- Requirements
- License
- Support info

### Error Handling

**Command Error Handling:**

```markdown
## Error Handling

- Invalid input: Return clear error message with expected format
- Missing required fields: Explain which fields are required
- File not found: Return "File not found: [path]"
- Parse errors: Return "Parse error: [details]"
- External service errors: Return "Service error: [message]"

Always return error message in same format as success output.
```

**Graceful Degradation:**

When partial results are possible:
- Continue processing remaining files even if one fails
- Return results for successful files
- Include error summary for failed files

### Testing Guidelines

**Local Testing:**

```bash
# Test plugin in isolation
claude --plugin-dir /path/to/plugin /plugin-name:command

# Test with arguments
claude --plugin-dir /path/to/plugin /plugin-name:command "argument value"

# Test with complex arguments (JSON if needed)
claude --plugin-dir /path/to/plugin /plugin-name:command '{"param": "value"}'
```

**Test Cases to Cover:**

1. **Basic case:** Normal usage with valid input
2. **Edge cases:** Empty input, single character, large input
3. **Error cases:** Invalid input, missing files, malformed data
4. **Different models:** Test with both Haiku and Opus

**Validation Script:**

```bash
#!/bin/bash
# validate-plugin.sh

PLUGIN_PATH=$1

# Check manifest
echo "Checking plugin.json..."
jq . "$PLUGIN_PATH/.claude-plugin/plugin.json" || exit 1

# Check directory structure
echo "Checking directory structure..."
[ -d "$PLUGIN_PATH/commands" ] && echo "✓ commands/" || echo "✗ no commands/"
[ -d "$PLUGIN_PATH/agents" ] && echo "✓ agents/" || echo "✗ no agents/"
[ -d "$PLUGIN_PATH/skills" ] && echo "✓ skills/" || echo "✗ no skills/"

# Check command files
echo "Checking commands..."
for cmd in "$PLUGIN_PATH/commands"/*.md; do
  [ -f "$cmd" ] && echo "✓ $(basename $cmd)" || echo "✗ $cmd"
done

echo "Plugin validation complete"
```

### Token Efficiency

**Minimize Level 1-2 Loading:**

What Claude loads for discovery:
- Plugin name: 1-5 tokens
- Plugin description: 10-30 tokens
- Component list in description: 5-10 tokens

**Keep under 50 tokens for discovery.**

**Optimize SKILL.md Body:**

Good structure (50-200 lines typical):
```
Quick Start (40 lines)
Examples (60 lines)
Key Notes (40 lines)
---
Total: 140 lines, ~500 tokens
```

**Use References Strategically:**

Move to references/ if:
- >100 lines of content
- Not essential to core task
- Detailed reference material
- Comprehensive examples

**Token saved:** Content in references/ doesn't load until needed (~90% of the time not needed).

### Versioning Strategy

**Semantic Versioning:**

```
Version format: MAJOR.MINOR.PATCH

Examples:
  1.0.0 - Initial release
  1.0.1 - Bug fix
  1.1.0 - New feature
  1.2.0 - Another feature
  2.0.0 - Breaking change
```

**Changelog Format:**

Create CHANGELOG.md for distributed plugins:

```markdown
# Changelog

## [1.1.0] - 2025-01-17
### Added
- New export command
- Support for JSON output format
- Batch processing capability

### Fixed
- Issue with large file handling
- Incorrect error messages

### Changed
- Improved validation performance

## [1.0.0] - 2025-01-10
### Added
- Initial release
- Validate command
- Report generation
```

### Security Considerations

**Allowed Tools Principle:**

Only request tools Claude actually needs:

**Good:**
```yaml
allowed-tools: Read,Write       # Only file operations
allowed-tools: Read,Write,Glob  # File operations + search
```

**Poor:**
```yaml
allowed-tools: Read,Write,Edit,Bash,Grep,Glob,WebFetch,WebSearch
# Why request all tools if only Read needed?
```

**Input Validation:**

Commands should validate inputs:

```markdown
## Input Validation

- Code length: Reject if >100KB (prevents timeout)
- File path: Validate path doesn't escape plugin directory
- Language: Validate language parameter against whitelist
- Format: Validate JSON/YAML syntax before processing
```

**Secrets Management:**

Never hardcode secrets:

**Bad:**
```markdown
API_KEY="sk-12345678"
```

**Good:**
```markdown
Use environment variable: $API_KEY
Validate: Warn if API_KEY not set
```

### Team/Production Checklist

For plugins shared across teams:

- [ ] Error handling implemented (all failure cases covered)
- [ ] Input validation present (prevents crashes)
- [ ] Documentation complete (README, inline comments)
- [ ] Versioning tracked (semantic versioning)
- [ ] Security reviewed (no hardcoded secrets, input validation)
- [ ] Tested with multiple models (Haiku and Opus)
- [ ] Tested with real-world examples
- [ ] Peer reviewed (another team member approved)
- [ ] Changelog documented (version history)
- [ ] Tool scoping applied (principle of least privilege)

### Common Anti-Patterns

| Anti-Pattern | Why It's Bad | Fix |
|--------------|-------------|-----|
| Command does 10 things | Unfocused, hard to test, unclear activation | Split into multiple focused commands |
| Skill body 2000+ lines | High token cost on every invocation | Move detailed content to references/ |
| Vague description | Plugin never activates when needed | Include specific trigger phrases |
| No error handling | Plugin crashes on invalid input | Validate inputs, return clear errors |
| All tools requested | Unnecessary permissions | Only request needed tools |
| Deeply nested dirs | Hard to navigate, unclear structure | Keep one level deep |
| No examples | Claude doesn't understand usage | Include concrete examples |
| No versioning | Can't track changes or updates | Use semantic versioning |

### Summary

Good plugins:
1. **Clear names** - Plugin and component names describe purpose
2. **Specific descriptions** - Include trigger phrases Claude recognizes
3. **Focused components** - Each command/agent/skill has single responsibility
4. **Efficient token usage** - Keep level 1-2 small, move details to references/
5. **Good documentation** - Inline instructions, examples, error handling
6. **Security-conscious** - Validate inputs, principle of least privilege
7. **Well-tested** - Works with real examples, multiple models
8. **Properly versioned** - Semantic versioning for team coordination

# Consolidation Note
This file consolidates debugging-troubleshooting.md and best-practices.md from refinement pass 2.
