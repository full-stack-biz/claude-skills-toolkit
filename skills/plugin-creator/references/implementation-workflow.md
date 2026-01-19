# Plugin Implementation Workflows

Step-by-step procedures for creating, converting, and validating Claude Code plugins.

## Table of Contents

- [Workflow 1: Creating a New Plugin from Scratch](#workflow-1-creating-a-new-plugin-from-scratch)
- [Workflow 2: Converting Existing Projects to Plugins](#workflow-2-converting-existing-projects-to-plugins)
- [Workflow 3: Validating or Improving Existing Plugins](#workflow-3-validating-or-improving-existing-plugins)
- [Quick Validation Flowchart](#quick-validation-flowchart)
- [Common Mistakes to Avoid](#common-mistakes-to-avoid)
- [Reference Links](#reference-links)

## Workflow 1: Creating a New Plugin from Scratch

Use this workflow when building a plugin from scratch.

### Step 1: Interview Requirements

Gather these details using questions or conversation:

- **Plugin purpose** - What does it do? What problem does it solve?
- **Plugin name** - Lowercase-hyphen format (becomes `/plugin-name:command`)
- **Components needed** - Which will you include?
  - Slash commands (user-invoked via `/plugin-name:command`)
  - Custom agents (complex workflows with planning)
  - Agent Skills (auto-invoked capabilities)
  - Hooks (event handlers like on-save, on-commit)
  - MCP servers (external service integration)
  - LSP servers (language-specific intelligence)
- **Distribution scope** - Personal, team, or marketplace?

### Step 2: Create Directory Structure

```bash
mkdir -p my-plugin/.claude-plugin
mkdir -p my-plugin/commands
mkdir -p my-plugin/agents
mkdir -p my-plugin/skills
mkdir -p my-plugin/references
```

### Step 3: Create plugin.json Manifest

Create `.claude-plugin/plugin.json`:

```json
{
  "name": "my-plugin",
  "description": "[Action]. Use when [trigger contexts]. [Components/scope].",
  "version": "1.0.0",
  "author": {
    "name": "Your Name"
  }
}
```

**Validation:**
- `name`: lowercase-hyphen, 1-64 chars, no spaces or special chars
- `description`: 1-1024 chars, includes specific trigger phrases Claude will recognize
- See `references/plugin-json-schema.md` for optional fields (homepage, repository, license)

### Step 4: Add Components in Order

**4a. Slash Commands** (if needed)

Create `.md` files in `commands/` directory:

```markdown
---
name: command-name
description: >-
  What this command does.
arguments:
  input:
    description: Input parameter
    required: true
---

# Command Name

Your instructions here.

## Quick Start

1. Read input
2. Process
3. Return result
```

See `references/slash-command-format.md` for complete format.

**4b. Custom Agents** (if needed)

Create `agents/agent-name.md` (flat file in agents/ directory):

````markdown
---
description: What this agent specializes in
capabilities: ["task1", "task2", "task3"]
---

# Agent Name

Detailed description of agent role, expertise, and when Claude should invoke it.

## Capabilities
- Specific task the agent excels at
- Another specialized capability

## Context and examples
Examples of when this agent should be used.
````

See `references/how-plugins-work.md` for agent patterns.

**4c. Agent Skills** (if needed)

Create `skills/skill-name/SKILL.md` following skill format:

```yaml
---
name: skill-name
description: Use when [trigger context]
allowed-tools: Read,Write
---

# Skill Name

Instructions here...
```

See `references/agent-skills.md` for skill packaging in plugins.

**4d. Hooks** (if needed)

Create `hooks.json`:

```json
{
  "on-save": [
    {"name": "validate", "args": {}}
  ],
  "on-commit": [
    {"name": "format", "args": {}}
  ]
}
```

See `references/hooks.md` for available events and patterns.

**4e. MCP Servers** (if needed)

Create `.mcp.json`:

```json
{
  "mcpServers": {
    "database": {
      "command": "python",
      "args": ["-m", "mcp_database_server"]
    }
  }
}
```

See `references/mcp-servers.md` for configuration examples.

**4f. LSP Servers** (if needed)

Create `.lsp.json`:

```json
{
  "go": {
    "command": "gopls",
    "args": ["serve"],
    "extensionToLanguage": {".go": "go"}
  }
}
```

See `references/lsp-servers.md` for language examples.

### Step 5: Validate with `claude plugin validate`

Run the validation command to automatically check for structural and manifest errors:

```bash
claude plugin validate /path/to/my-plugin
```

This checks:
- Valid JSON in `.claude-plugin/plugin.json`
- Required fields present (name, description)
- Component paths exist and are accessible
- No structural errors that would block installation

### Step 6: Manual Structure Review

If validation passes, manually verify:

- [ ] `.claude-plugin/plugin.json` exists and is valid JSON
- [ ] `name` and `description` fields present in manifest
- [ ] Plugin name follows lowercase-hyphen convention
- [ ] Description includes specific trigger phrases
- [ ] Slash command files (if present) have required metadata (name, description)
- [ ] All component directories match Claude Code conventions
- [ ] No deeply nested structures (keep one level deep)

See `references/validation-checklist.md` for comprehensive validation checklist.

### Step 7: Test Locally

```bash
# Test plugin without installing
claude --plugin-dir /path/to/my-plugin /my-plugin:command-name

# This loads the plugin from the specified directory
# Verify components load and work as expected
```

### Step 8: Deploy

**For personal/local use:**
```bash
mkdir -p ~/.claude/skills
cp -r my-plugin ~/.claude/skills/
```

**For project-specific use:**
```bash
mkdir -p .claude/skills
cp -r my-plugin .claude/skills/
```

**For team/marketplace distribution:**
See `references/team-marketplaces.md` for setup and publishing.

---

## Workflow 2: Converting Existing Projects to Plugins

Use this workflow when transforming an existing project into a plugin.

### Step 1: Identify Existing Components

Audit the existing project for:

**Slash commands/scripts:**
- What commands exist?
- What do they do?
- What arguments do they take?
- → Will become files in `commands/` directory

**Complex workflows/agents:**
- What multi-step processes exist?
- What requires planning and state management?
- → Will become custom agents in `agents/` directory

**Reusable capabilities/Skills:**
- What tasks does Claude do repeatedly?
- What could other projects benefit from?
- → Will become Agent Skills in `skills/` directory

**Event handlers:**
- What automation exists (on-save, on-commit, on-test)?
- → Will become `hooks.json`

**External services:**
- What APIs or databases does it use?
- → Will become `.mcp.json` or `.lsp.json`

### Step 2: Create Plugin Structure

Create the plugin directory:

```bash
mkdir -p my-plugin/.claude-plugin
mkdir -p my-plugin/commands
mkdir -p my-plugin/agents
mkdir -p my-plugin/skills
mkdir -p my-plugin/references
```

### Step 3: Write plugin.json Manifest

Create `.claude-plugin/plugin.json` with:
- **name**: derived from project name (lowercase-hyphen)
- **description**: what the plugin does + trigger phrases + components list
- **version**: current project version or 1.0.0
- **author**: project author info

```json
{
  "name": "my-plugin",
  "description": "What the project does. Use when [contexts where this would be used]. Includes [components list].",
  "version": "1.0.0",
  "author": {
    "name": "Author Name"
  }
}
```

### Step 4: Migrate Components

**Migrate slash commands:**
1. Find command scripts in project
2. Move to `commands/` directory as `.md` files
3. Add YAML frontmatter:
   ```yaml
   ---
   name: command-name
   description: What it does
   arguments:
     param1:
       description: Parameter description
       required: true
   ---
   ```
4. Keep implementation instructions in body

**Migrate agents/complex workflows:**
1. Identify multi-step processes
2. Create `agents/agent-name.md` (flat file in agents/)
3. Add frontmatter with description and capabilities array
4. Move workflow instructions to body

**Migrate Skills:**
1. Identify reusable capabilities
2. Create `skills/skill-name/SKILL.md`
3. Add skill frontmatter (name, description, allowed-tools)
4. Move implementation to body

**Migrate event handlers:**
1. Extract automation rules from project config
2. Create `hooks.json` with events and associated commands
3. Map original events to Claude Code events (on-save, on-commit, etc.)

**Migrate external services:**
1. Extract API integrations from project config
2. Create `.mcp.json` with server configurations
3. Verify server definitions are compatible with Claude Code

### Step 5: Update Component Metadata

Ensure all migrated components have:

**For slash commands:**
- [ ] YAML frontmatter with name, description
- [ ] Argument definitions if applicable
- [ ] Clear instructions in body

**For agents:**
- [ ] YAML frontmatter with name, description
- [ ] Clear workflow instructions
- [ ] Error handling guidance

**For Skills:**
- [ ] YAML frontmatter with name, description, allowed-tools
- [ ] Quick Start section (80% of tasks)
- [ ] Key notes and constraints

### Step 6: Validate with `claude plugin validate`

Run the validation command to automatically check for structural and manifest errors:

```bash
claude plugin validate /path/to/my-plugin
```

This checks:
- Valid JSON in `.claude-plugin/plugin.json`
- Required fields present (name, description)
- Component paths exist and are accessible
- No structural errors that would block installation

### Step 7: Test Locally

```bash
# Test the converted plugin
claude --plugin-dir /path/to/my-plugin /my-plugin:command-name

# Verify:
# - All commands load and execute
# - Arguments are parsed correctly
# - Agents handle complex workflows
# - Skills are auto-invoked when relevant
# - Hooks fire at expected events
```

### Step 8: Validate Against Plugin Standards

Use the comprehensive checklist in `references/validation-checklist.md`:

- [ ] Manifest is valid JSON
- [ ] Structure matches Claude Code conventions
- [ ] All components have proper metadata
- [ ] Descriptions include activation signals (trigger phrases)
- [ ] No nested directory chains
- [ ] All referenced paths are correct

### Step 9: Deploy

Move converted plugin to plugin directories:

```bash
# For team/shared use
cp -r my-plugin ~/.claude/skills/

# For project-specific use
cp -r my-plugin .claude/skills/
```

---

## Workflow 3: Validating or Improving Existing Plugins

Use this workflow when checking or refining existing plugins.

### Step 1: Run `claude plugin validate`

Start with the automated validation command:

```bash
claude plugin validate /path/to/plugin
```

This identifies critical issues automatically:
- Invalid JSON in manifest
- Missing required fields
- Broken component paths
- Structural errors

Review the output carefully. Address any errors before proceeding to manual checks.

### Step 2: Manifest Validation

Check `.claude-plugin/plugin.json`:

- [ ] File exists and contains valid JSON (test with `jq .`)
- [ ] `name` field present: lowercase-hyphen, 1-64 chars
- [ ] `description` field present: 1-1024 chars
- [ ] Description includes specific trigger phrases Claude will recognize
- [ ] Optional fields valid (if present): version, author, homepage, repository

**Common issues:**
- Description too vague: "A plugin for processing" → Vague activation
- Missing trigger phrases: Won't activate when user mentions relevant context
- Invalid JSON syntax: Use `jq .` to validate

### Step 3: Directory Structure Validation

Check plugin layout:

- [ ] `.claude-plugin/plugin.json` exists
- [ ] `commands/` directory exists if plugin has slash commands
- [ ] `agents/` directory exists if plugin has custom agents
- [ ] `skills/` directory exists if plugin has Agent Skills
- [ ] `hooks.json` exists if plugin has event handlers
- [ ] `.mcp.json` exists if plugin has MCP servers
- [ ] `.lsp.json` exists if plugin has LSP servers
- [ ] No deeply nested directories (keep one level deep)

**Common issues:**
- `plugin.json` in wrong location (should be `.claude-plugin/plugin.json`)
- Component directories with different names than Claude Code conventions
- Nested chains: `commands/v1/latest/validate.md` instead of `commands/validate.md`

### Step 4: Component Metadata Validation

For each component, check metadata:

**Slash commands (`commands/*.md`):**
- [ ] YAML frontmatter with `name` field
- [ ] YAML frontmatter with `description` field
- [ ] Arguments defined if applicable
- [ ] Clear instructions in body

**Custom agents (`agents/*.md`):**
- [ ] YAML frontmatter with `description` field
- [ ] YAML frontmatter with `capabilities` array
- [ ] Description tells Claude when to use agent
- [ ] Workflow instructions clear and procedural

**Agent Skills (`skills/*/SKILL.md`):**
- [ ] YAML frontmatter with `name` field
- [ ] YAML frontmatter with `description` field
- [ ] Description includes trigger contexts
- [ ] Body <500 lines (progressive disclosure)

**Hooks (`hooks.json`):**
- [ ] Valid JSON format
- [ ] Events match Claude Code event names
- [ ] Command references point to actual command files

### Step 5: Activation Signal Review

Check if Claude will recognize when to use the plugin:

**Plugin description must include:**
- ✅ Specific action verbs: "Review code", "Process PDFs", "Generate reports"
- ✅ Concrete trigger contexts: "when validating pull requests", "before committing code", "when analyzing documents"
- ✅ Component list or scope: "Includes validate, report, and export commands"

**Example good description:**
"Review code for best practices and potential issues. Use when validating pull requests, reviewing before commit, or analyzing code quality. Includes validate, report, and export commands."

**Example poor description:**
"A plugin for code operations."

### Step 6: Clarity Review

For each component, verify Claude understands its purpose:

**Good clarity:**
- Descriptions are concrete and specific
- Instructions use imperative language (what Claude should do)
- Examples show expected inputs and outputs
- Constraints are explicit (what Claude shouldn't do)

**Poor clarity:**
- Vague descriptions: "does processing"
- Passive language: "processing may occur"
- No examples or constraints

### Step 7: Improvement Action Plan

Based on validation, prioritize improvements:

1. **Critical (blocks usage):**
   - Invalid manifest JSON
   - Missing plugin name or description
   - Wrong directory structure

2. **High (affects activation):**
   - Vague descriptions without trigger phrases
   - Component metadata missing or unclear
   - Wrong event names in hooks.json

3. **Medium (affects execution):**
   - Instructions unclear or incomplete
   - Missing error handling guidance
   - Inconsistent naming conventions

4. **Low (nice-to-have):**
   - Code examples could be clearer
   - Documentation could be more comprehensive
   - Token efficiency improvements

### Step 8: Implement Improvements

Apply fixes in priority order:

1. Fix manifest and structure issues first
2. Update descriptions with trigger phrases
3. Clarify component instructions
4. Add examples and constraints
5. Optimize for token efficiency

### Step 9: Test Improvements

```bash
# Test the improved plugin locally
claude --plugin-dir /path/to/plugin /plugin-name:command

# Verify improvements actually help Claude execute better
```

### Step 10: Re-validate with `claude plugin validate`

After implementing improvements, run the validation command again to confirm all issues are resolved:

```bash
claude plugin validate /path/to/plugin
```

Ensure the command runs without errors before marking the plugin as complete.

### Step 11: Final Review

Run through validation checklist again to confirm all issues addressed.

---

## Quick Validation Flowchart

```
Plugin exists?
├─ No → Start with Workflow 1 (Create new plugin)
└─ Yes
   └─ Is it already a plugin?
      ├─ No → Start with Workflow 2 (Convert to plugin)
      └─ Yes
         └─ Start with Workflow 3 (Validate/improve)
            ├─ Check manifest
            ├─ Check structure
            ├─ Check metadata
            ├─ Check activation signals
            ├─ Check clarity
            └─ Improve and re-test
```

---

## Common Mistakes to Avoid

**Plugin Creation:**
- ❌ Deeply nested directories (`commands/v1/latest/validate.md`)
- ❌ Vague descriptions without trigger phrases
- ❌ Missing component metadata (name, description in YAML)
- ✅ One-level directory structure
- ✅ Specific trigger phrases in description
- ✅ All components have clear metadata

**Plugin Conversion:**
- ❌ Forgetting to add YAML frontmatter to migrated commands
- ❌ Keeping project structure instead of flattening to plugin structure
- ❌ Not updating descriptions for plugin activation
- ✅ Systematically audit and migrate components
- ✅ Add/update metadata during migration
- ✅ Test locally before deploying

**Plugin Validation:**
- ❌ Assuming JSON is valid without checking
- ❌ Skipping metadata review
- ❌ Not testing activation with actual requests
- ✅ Validate JSON with `jq .`
- ✅ Check all metadata systematically
- ✅ Test locally to confirm activation works

---

## Reference Links

- `references/validation-checklist.md` — Comprehensive validation phases
- `references/plugin-json-schema.md` — Manifest field definitions
- `references/slash-command-format.md` — Command metadata format
- `references/plugin-templates.md` — Copy-paste starting points
- `references/best-practices.md` — Naming conventions, descriptions, organization
- `references/how-plugins-work.md` — Plugin architecture and activation
