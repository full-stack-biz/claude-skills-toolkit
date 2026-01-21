---
name: plugin-creator
description: >-
  Create, validate, and refine Claude Code plugins with Agent Skills, hooks, agents, and servers. Use when: building plugins from scratch, converting projects to plugins, or improving plugin structure. Includes automated scanning, manifest generation, component organization, and validation guidance (use hook-creator and subagent-creator skills for those components).
version: 1.1.0
allowed-tools: Read,Write,Edit,AskUserQuestion,Glob,Bash(find,grep,head,jq,du,xargs,bash,claude,rm,chmod)
---

# Plugin Creator

**Dual purpose:** Create plugins from scratch OR transform existing projects into well-structured plugins.

## Quick Routing

Use AskUserQuestion to gather requirements, then proceed to the appropriate section below:

1. Ask what the user wants to do (create/convert/validate)
2. Ask for the plugin name or path based on the action
3. Route to the appropriate workflow section

---

## When to Use This Skill

Invoke plugin-creator in these scenarios:

**Creating new plugins:** Building a plugin from scratch with proper manifest, commands, agents, Skills, hooks, and/or MCP servers organized correctly.

**Converting projects to plugins:** Take an existing project and transform it into a Claude Code plugin with `.claude-plugin/plugin.json` manifest and proper directory structure.

**Validating plugin structure:** Check existing plugins against Claude Code plugin standards (manifest schema, directory layout, naming conventions).

**Multi-component plugins:** Creating plugins that bundle multiple elements (Skills, hooks, agents, MCP servers, etc.).

**Team/production plugins:** Building plugins for distribution across teams or deployment to plugin marketplaces.

**NOT for:** General Claude questions, debugging plugin behavior at runtime, writing plugin code directly (focus on structure/organization only).

## ⚠️ Important: Slash Commands Deprecated

**Slash commands** (via `commands/` directory) are deprecated in favor of **Agent Skills**.

When creating new plugins, use Agent Skills (`skills/` directory) instead. Slash commands still work for backward compatibility but are being phased out. Use `skill-creator` to build Agent Skills instead.

---

## Foundation: How Plugins Work

Plugins extend Claude Code with custom functionality shared across projects and teams.

**Plugin activation:** Pure LLM reasoning on manifest metadata. Claude discovers plugins via:
- **name**: Unique identifier (plugin namespace)
- **description**: Tells Claude when to suggest or use the plugin

**Plugin structure:**
```
my-plugin/
├── .claude-plugin/
│   └── plugin.json                    # Required: metadata manifest
├── skills/                            # Optional: Agent Skills (recommended)
│   └── code-review/
│       └── SKILL.md
├── agents/                            # Optional: subagents
│   ├── code-reviewer.md               # Subagent (use subagent-creator skill)
│   └── security-auditor.md
├── hooks.json                         # Optional: event handlers
├── .mcp.json                          # Optional: MCP servers
├── .lsp.json                          # Optional: LSP servers
└── commands/                          # DEPRECATED: Use skills instead
    ├── hello.md
    └── review.md
```

**Token loading hierarchy:**
1. **Plugin manifest** (150 tokens): name + description in plugin.json (always loaded for discovery)
2. **Component metadata** (50-200 tokens each): Command files, agent descriptions, skill descriptions
3. **Full content** (unlimited): Loaded only when Claude uses the component

**Why this matters for your plugin:**
- **plugin.json description** is your activation signal (vague = plugin never recommended when needed)
- **Naming conventions** are critical (plugin name becomes skill namespace in plugins)
- **Directory structure** must be exact (Claude Code uses path conventions to discover components)
- **Component metadata** must be clear (descriptions tell Claude what each command/agent/skill does)

## Choose Your Workflow

**START HERE:** Always begin by asking the user to clarify their intent using AskUserQuestion:

```
Question 1: What would you like to do?
- Create a new plugin (Recommended) - Build from scratch
- Convert a project - Transform existing project into a plugin
- Validate a plugin - Check against Claude Code standards

Question 2: What is the plugin name or path?
- If creating/validating: Provide the plugin name (e.g., `code-reviewer`, `api-tools`)
- If converting: Provide the path to the existing project
```

Based on their answers, route to the appropriate workflow below:

---

## Automated Scanning Phase (For Validation)

**When the user wants to validate an existing plugin, always run this scanning phase FIRST before manual validation:**

The scanning phase is **read-only only**—it scans and reports, never modifies. User decisions are explicit and visible.

### Workflow

1. **Run the read-only scanner:**
   ```bash
   bash /path/to/plugin-creator/scripts/scan-plugin.sh /path/to/plugin /tmp/plugin-scan.json
   ```
   This generates a structured JSON report with three categories:
   - **errors**: Critical issues that prevent installation (must fix)
   - **warnings**: Best-practice violations (should fix)
   - **decisions_needed**: Items requiring user choice (files to delete, permissions to set, etc.)

2. **Read and interpret the JSON report:**
   Parse the JSON to identify what the scanner found. Output should show:
   - A summary count of errors, warnings, decisions
   - Errors printed first (must fix before validation)
   - Warnings categorized by type (security, naming, documentation, etc.)
   - Decisions with target file/directory for user approval

3. **Process errors first:**
   For each error, report it clearly and suggest the fix. Example:
   ```
   ❌ MANIFEST ERROR: Missing .claude-plugin/plugin.json
      Fix: Run mkdir -p .claude-plugin and create plugin.json
   ```

4. **Process warnings next:**
   Categorize by type and show user. Example:
   ```
   ⚠ SECURITY WARNING: Script contains hardcoded secrets
      File: scripts/deploy.sh
      Suggestion: Move secrets to environment variables

   ⚠ NAMING WARNING: Command name 'Check_Status' doesn't follow convention
      File: commands/Check_Status.md
      Suggestion: Rename to 'check-status'
   ```

5. **Present decisions via AskUserQuestion:**

   **For non-standard files in .claude-plugin/:**
   ```
   Question: "Found non-standard files in .claude-plugin/. What should we do?"
   Header: "File Cleanup"
   Options:
   - Delete all non-standard files (Recommended) - Removes MANIFEST.md, etc.
   - Review each file - Show what's in .claude-plugin/ and decide individually
   - Keep as-is - Leave everything
   ```

   **For orphaned directories:**
   ```
   Question: "Found non-standard directory '[name]'. Keep it or remove?"
   Header: "Directory Cleanup"
   Options:
   - Delete '[name]' - Remove the directory
   - Keep '[name]' - Custom structure is OK
   - Review all directories - List all and decide each one
   ```

   **For executable scripts:**
   ```
   Question: "Script '[filename]' is not executable. Fix permissions?"
   Header: "Permissions"
   Options:
   - Make executable (Recommended) - Run chmod +x
   - Leave as-is - Keep current permissions
   ```

   **For security warnings that need action:**
   ```
   Question: "Script '[filename]' contains potential secrets. Review and remove?"
   Header: "Security"
   Options:
   - Review now - Show file content so you can clean it
   - Already cleaned - Skip this check
   - Keep as-is - It's not actually a secret
   ```

6. **Execute decisions explicitly:**
   After user approves each decision category, run the specific commands:

   **User approved: Delete files**
   ```bash
   rm -rf /path/to/.claude-plugin/MANIFEST.md
   rm -rf /path/to/.claude-plugin/REFINEMENT_SUMMARY.md
   ```

   **User approved: Fix permissions**
   ```bash
   chmod +x /path/to/scripts/deploy.sh
   chmod +x /path/to/scripts/validate.sh
   ```

   Always show the exact command before executing. Give user a final chance to abort.

7. **Re-scan after changes:**
   After applying decisions, re-run the scanner to verify issues are resolved:
   ```bash
   bash /path/to/plugin-creator/scripts/scan-plugin.sh /path/to/plugin /tmp/plugin-scan-v2.json
   ```

8. **Proceed to manual validation:**
   Once scan passes with no errors/decisions:
   ```bash
   claude plugin validate /path/to/plugin
   ```
   Then check best practices from `references/validation-checklist.md`.

### Example Workflow

```
User: "validate my-plugin"
        ↓
1. Scanner runs (read-only) → finds 2 non-standard files, 1 permission issue
        ↓
2. Claude reports errors/warnings clearly
        ↓
3. Claude asks: "Delete .claude-plugin/MANIFEST.md and REFINEMENT_SUMMARY.md?"
        User: "Yes"
        ↓
4. Claude shows exact rm commands, waits for implicit approval (no confirmation needed, but visible)
        ↓
5. Claude asks: "Make scripts/scan-plugin.sh executable?"
        User: "Yes"
        ↓
6. Claude runs chmod +x
        ↓
7. Claude re-runs scanner → clean
        ↓
8. Claude runs claude plugin validate → passes
        ↓
9. Claude checks best practices from validation-checklist
        ↓
10. Final report: "✔ Plugin is ready"
```

### Safety Guarantee

- **Scanner never modifies files** — read-only only
- **No silent changes** — every action is explicitly approved by user
- **Visible execution** — user sees exact bash commands before they run
- **Reversible process** — user can choose "review individually" to be conservative

---

### 1. Creating a New Plugin from Scratch
Interview requirements → create structure → add components → run `claude plugin validate` → test locally

See `references/implementation-workflow.md` for complete step-by-step procedures.

### 2. Converting an Existing Project to a Plugin
Identify components → create plugin structure → migrate and update metadata → run `claude plugin validate` → test locally

See `references/implementation-workflow.md` for complete step-by-step procedures.

### 3. Validating or Improving Existing Plugins
**FIRST:** Run `claude plugin validate /path/to/plugin` directly. Review output for errors. **THEN:** Do manual checks for best practices from `references/validation-checklist.md`.

## Quick Start: 5-Minute Setup

**Create plugin directory:**
```bash
mkdir -p my-plugin/.claude-plugin
mkdir -p my-plugin/commands my-plugin/agents my-plugin/skills
```

**Write plugin.json:**
```json
{
  "name": "my-plugin",
  "description": "[Action]. Use when [trigger contexts].",
  "version": "1.0.3"
}
```

**Add components:**
- Agent Skills: `.md` files in `skills/` (recommended approach)
- Other components: See "Component Overview" section below
- Test: `claude --plugin-dir /path/to/my-plugin`

## Complete Reference Documentation

**Implementation & Validation:**
- `references/implementation-workflow.md` — Step-by-step procedures for creating, converting, and validating plugins
- `references/validation-checklist.md` — Comprehensive validation phases and checklists

**Installation & Scopes:**
- `references/installation-scopes.md` — User/project/local/managed scopes and use cases
- `references/cli-commands.md` — Plugin install/uninstall/enable/disable/update commands

**Plugin Architecture:**
- `references/directory-structure.md` — Standard plugin layout, file organization, validation
- `references/plugin-json-schema.md` — Manifest format, required/optional fields, component paths
- `references/plugin-paths-variables.md` — Relative paths, ${CLAUDE_PLUGIN_ROOT} variable
- `references/plugin-caching.md` — Plugin caching, file resolution, symlinks, path traversal

**Components & Configuration:**
- `references/agent-skills.md` — Packaging Skills in plugins (recommended)
- `references/slash-command-format.md` — Command file format (DEPRECATED: for legacy support only)
- `references/subagents-in-plugins.md` — Packaging subagents in plugins with delegation
- `references/hooks-in-plugins.md` — Packaging hooks in plugins (use `hook-creator` skill for creation/validation)
- `references/hooks.md` — Hook event reference (events, formats, matchers, patterns)
- `references/mcp-servers.md` — External service integration
- `references/lsp-servers.md` — Language-specific code intelligence

**Deployment & Troubleshooting:**
- `references/versioning-and-distribution.md` — Semantic versioning, changelog, distribution
- `references/debugging-troubleshooting.md` — Debug mode, common issues, error messages
- `references/best-practices.md` — Production patterns, security, performance

## Component Overview

See `references/quick-reference.md` for component templates, formats, and metadata requirements.

| Component | Use Case |
|-----------|----------|
| **Agent Skills** (`skills/`) | Capabilities Claude uses automatically or via `/skill-name` (recommended) |
| **Subagents** (`agents/`) | Isolated execution environments with custom prompts, tools, and permissions (use `subagent-creator` skill) |
| **Hooks** (`hooks.json`) | Event handlers (tool use, permissions, sessions) (use `hook-creator` skill) |
| **MCP Servers** (`.mcp.json`) | External service integration (APIs, databases) |
| **LSP Servers** (`.lsp.json`) | Language-specific code intelligence |
| **Commands** (`commands/`) | DEPRECATED: Use Agent Skills instead |

## Key Notes

**Plugin naming conventions:**
- Hyphen-separated lowercase: `code-reviewer`, `pdf-processor`, `test-runner`
- Include action/domain: prefer `test-runner` over `runner`
- Becomes plugin namespace: `/plugin-name` for skills, commands, hooks

**CLI commands:** `claude plugin install|uninstall|enable|disable|update <name>@<marketplace> [--scope user|project|local]`

**Important paths note:**
- Plugins are cached (copied, not used in-place) for security
- External paths won't work after installation; use `${CLAUDE_PLUGIN_ROOT}` variable in hooks/scripts
- See `references/plugin-paths-variables.md` for complete path behavior and variable usage

**Description formula (Claude's activation signal):**
```
[Action]. Use when [trigger contexts]. [Components/scope].
```

Example: "Review code for best practices. Use when validating pull requests or before commit. Includes validate, report, and export commands."

**Installation scopes:**
- **`user` scope (global)**: `~/.claude/skills/` (available in all projects)
- **`project` scope**: `.claude/skills/` (shared via git)
- **`local` scope**: `.claude/skills/` (personal, not shared)
- **`managed` scope**: System cache (marketplace plugins, read-only)

See `references/installation-scopes.md` for scope details and use cases.

## Validation Checklist

**Step 0 (AUTOMATED SCANNING):** For existing plugins, run the automated scanner first to catch common issues:
```bash
bash /path/to/plugin-creator/scripts/scan-plugin.sh /path/to/plugin /tmp/plugin-scan.json
```
Review the JSON output and use AskUserQuestion to handle any decisions (file cleanup, permissions, etc.). See "Automated Scanning Phase" section above for details.

**Step 1 (REQUIRED):** Run the validation command directly:
```bash
claude plugin validate /path/to/plugin
```
Do NOT create wrapper scripts. Run this command directly and review its output.

**Step 2:** If validation passes, check best practices from `references/validation-checklist.md`:
- Manifest description includes specific trigger phrases
- Component metadata is clear and complete
- Security: No hardcoded secrets, safe shell patterns, proper permissions
- Documentation: README.md, CHANGELOG.md present for distributed plugins
- Test locally with `claude --plugin-dir /path/to/plugin`

## Advanced Topics

**Publishing & Distribution:**
See `references/team-marketplaces.md` for marketplace setup, version management, and team distribution patterns.

**Language Servers (LSP):**
See `references/lsp-servers.md` for LSP configuration and language-specific integration examples.

**Hooks & Events:**
See `references/hooks.md` for event handler configuration and common automation patterns.

**Agent Skills in Plugins:**
See `references/agent-skills.md` for packaging Skills in plugins. (Note: To create new Skills, use the `skill-creator` skill.)

**Subagents in Plugins:**
See `references/subagents-in-plugins.md` for packaging subagents in plugins. (Note: To create new subagents, use the `subagent-creator` skill.)

**External Service Integration (MCP):**
See `references/mcp-servers.md` for MCP server configuration and testing.

**Team Plugins:**
- Use `.claude/skills/` (project-local) for team-shared plugins
- Use `~/.claude/skills/` (global) for organization-wide plugins
- Document dependencies in plugin description
- Version track releases in plugin.json
- Peer review before team deployment

See `references/team-marketplaces.md` for multi-plugin registries and marketplace setup.
