# Plugin Validation Checklist

**Start here:** Run `claude plugin validate` to automatically check for manifest and structural errors:

```bash
claude plugin validate /path/to/plugin
```

This catches critical issues immediately. After fixing any validation errors, use this checklist to manually review other aspects.

---

Use this checklist when validating new plugins or converting projects to plugins. Work through each section systematically.

## Phase 1: Plugin Manifest (plugin.json)

- [ ] **Automated validation**: Run `claude plugin validate /path/to/plugin` with no errors
- [ ] **File exists**: `.claude-plugin/plugin.json` is present
- [ ] **Valid JSON**: File parses without syntax errors
- [ ] **Required field present**:
  - [ ] `name` field exists
- [ ] **Highly recommended field** (critical for activation):
  - [ ] `description` field exists (without it, Claude won't suggest your plugin)
- [ ] **Name validation**:
  - [ ] Lowercase letters and numbers only
  - [ ] Hyphens allowed, no spaces or special characters
  - [ ] 1-64 characters
  - [ ] No "anthropic" or "claude" in name
  - [ ] Unique (not conflicting with other plugins)
- [ ] **Description validation**:
  - [ ] 1-1024 characters
  - [ ] Includes action verb (Review, Process, Analyze, Generate, etc.)
  - [ ] Includes trigger phrases Claude will recognize
  - [ ] Lists major components (commands, agents, Skills)
  - [ ] Specifies scope/limitations if relevant
- [ ] **Optional fields valid** (if present):
  - [ ] `version` follows semantic versioning (X.Y.Z)
  - [ ] `author.name` is present if author object exists
  - [ ] `homepage` and `repository` are valid HTTPS URLs
  - [ ] `license` is valid SPDX identifier or file path

**Example valid manifest:**
```json
{
  "name": "code-reviewer",
  "description": "Review code for best practices and issues. Use when validating pull requests or before commit. Includes validate, report, and export commands.",
  "version": "1.0.0"
}
```

## Phase 2: Directory Structure

- [ ] **Root directory structure**:
  - [ ] `.claude-plugin/` directory exists
  - [ ] `plugin.json` is in `.claude-plugin/` (not in root)
  - [ ] No conflicting hidden directories

- [ ] **Component directories** (as applicable):
  - [ ] `commands/` directory exists if plugin has slash commands
  - [ ] `agents/` directory exists if plugin has custom agents
  - [ ] `skills/` directory exists if plugin has Agent Skills
  - [ ] Other component directories follow naming conventions

- [ ] **File organization**:
  - [ ] No unnecessary nesting (directories one level deep)
  - [ ] Component files are in correct directories
  - [ ] No duplicate command/agent/skill names

## Phase 3: Slash Commands (`commands/` directory)

**For each command file:**

- [ ] **File structure**:
  - [ ] Located in `commands/` directory
  - [ ] Named `*.md` (Markdown format)
  - [ ] Filename is lowercase with hyphens (no spaces, no uppercase)
  - [ ] File name becomes command identifier

- [ ] **YAML frontmatter**:
  - [ ] Valid YAML syntax (triple dashes: `---`)
  - [ ] `name` field present (matches file name without .md)
  - [ ] `description` field present (1-512 characters)
  - [ ] `description` explains what Claude does (not meta-description)
  - [ ] `arguments` object present (can be empty `{}`)

- [ ] **Arguments validation**:
  - [ ] Each argument has `description` field
  - [ ] Each argument has `required` field (boolean)
  - [ ] Parameter names are lowercase with hyphens
  - [ ] Descriptions are clear and specific

- [ ] **Body (instructions)**:
  - [ ] Content after frontmatter is clear and procedural
  - [ ] Includes examples Claude can reference
  - [ ] Specifies error handling behavior
  - [ ] Notes any constraints or edge cases

**Example command structure:**
```markdown
---
name: validate
description: Validate code and return detailed feedback
arguments:
  code:
    description: Source code to validate
    required: true
  language:
    description: Programming language
    required: false
---

# Validate Command

Instructions Claude follows...
```

## Phase 4: Custom Agents (`agents/` directory)

**For each agent:**

- [ ] **File structure**:
  - [ ] Located in `agents/` directory
  - [ ] Named `*.md` (Markdown format)
  - [ ] Filename is lowercase with hyphens (no spaces, no uppercase)

- [ ] **Agent frontmatter**:
  - [ ] Valid YAML syntax (triple dashes: `---`)
  - [ ] `description` field present (describes agent's purpose)
  - [ ] `capabilities` array present (list of agent capabilities)

- [ ] **Content clarity**:
  - [ ] Agent purpose is clear
  - [ ] Capabilities section lists what agent excels at
  - [ ] Context and examples provided for complex workflows

**Example agent structure:**
````markdown
---
description: What this agent specializes in
capabilities: ["code-review", "security-audit", "compliance-check"]
---

# Agent Name

Detailed description of agent role and expertise.

## Capabilities
- Specific tasks the agent excels at
- When Claude should invoke this agent

## Context and examples
Examples of problems this agent solves.
````

## Phase 5: Agent Skills (`skills/` directory)

**For each Skill:**

- [ ] **Directory structure**:
  - [ ] Located in `skills/` directory
  - [ ] Skill name directory uses lowercase with hyphens
  - [ ] `SKILL.md` file exists

- [ ] **SKILL.md frontmatter**:
  - [ ] Valid YAML syntax
  - [ ] `name` field present (lowercase, hyphens)
  - [ ] `description` field present with trigger phrases
  - [ ] `allowed-tools` specified (principle of least privilege)

- [ ] **SKILL.md body**:
  - [ ] <500 lines (token efficiency)
  - [ ] Quick Start section present
  - [ ] Includes procedural instructions
  - [ ] Examples provided

- [ ] **References** (if applicable):
  - [ ] Located in `references/` subdirectory
  - [ ] One level deep (no nested chains)
  - [ ] Linked from SKILL.md body where needed

## Phase 6: Hooks and MCP Servers

**If plugin includes hooks:**

- [ ] **hooks.json structure**:
  - [ ] Valid JSON syntax
  - [ ] Event types are valid (on-save, on-commit, on-test, etc.)
  - [ ] Command references exist in `commands/` directory
  - [ ] Arguments match command definitions

**If plugin includes MCP servers:**

- [ ] **.mcp.json structure**:
  - [ ] Valid JSON syntax
  - [ ] Server definitions are complete
  - [ ] Commands/scripts are executable
  - [ ] Dependencies are documented

## Phase 7: Testing & Activation

- [ ] **Local testing**:
  - [ ] Tested with `claude --plugin-dir /path/to/plugin`
  - [ ] Plugin loads without errors
  - [ ] Slash commands are accessible (if applicable)
  - [ ] Arguments work as expected

- [ ] **Activation testing**:
  - [ ] Plugin manifest description is specific
  - [ ] Claude recognizes trigger phrases
  - [ ] Plugin activates when appropriate

- [ ] **Error handling**:
  - [ ] Commands handle invalid input gracefully
  - [ ] Error messages are clear
  - [ ] No crashes on edge cases

## Quick Validation Script

**Use `claude plugin validate` first** for automated checking:

```bash
claude plugin validate /path/to/plugin
```

Then, run manual checks if needed:

```bash
# Check JSON syntax
jq . .claude-plugin/plugin.json

# Validate required fields
jq '.name, .description' .claude-plugin/plugin.json

# Check directory structure
find . -type f -name "*.md" | grep -E "(commands|agents|skills)/"

# List commands
ls -1 commands/ 2>/dev/null || echo "No commands directory"

# List agents
ls -1 agents/ 2>/dev/null || echo "No agents directory"

# List skills
ls -1 skills/ 2>/dev/null || echo "No skills directory"
```

## Common Issues & Fixes

| Issue | Fix |
|-------|-----|
| `plugin.json` not found | Create `.claude-plugin/plugin.json` |
| Invalid JSON in plugin.json | Validate with `jq .` or online JSON validator |
| Name contains uppercase/spaces | Use lowercase with hyphens: `code-reviewer` |
| Vague description | Add trigger phrases: "Use when [context]" |
| Command missing description | Add `description:` field to frontmatter |
| Commands not discovered | Ensure files in `commands/` directory with `.md` extension |
| Plugin won't activate | Check description has specific trigger phrases |
| Arguments not working | Validate `arguments:` object and field names |

## Team/Production Checklist

**For team or marketplace plugins:**

- [ ] **Error handling**: Commands fail gracefully with clear messages
- [ ] **Validation**: Input validation on all command arguments
- [ ] **Documentation**: README with usage examples
- [ ] **Testing**: Tested with both Haiku and Opus models
- [ ] **Security**: No hardcoded secrets, environment variables used
- [ ] **Versioning**: Semantic versioning in plugin.json
- [ ] **Peer review**: Code reviewed before deployment
- [ ] **Changelog**: CHANGELOG.md documents version history

## Sign-Off Criteria

Plugin is ready for deployment when:

✅ All Phase 1-7 items checked
✅ Local testing passes
✅ Plugin activates with correct trigger phrases
✅ Error handling is robust
✅ Documentation is clear
✅ Team review completed (if applicable)

**Mark this checklist as complete only when all items pass.**
