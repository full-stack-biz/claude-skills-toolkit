# Quick Start: Create a Plugin in an Empty Project

**Required: Create `.claude-plugin/` directory and manifest**
```bash
mkdir -p .claude-plugin
cat > .claude-plugin/plugin.json << 'EOF'
{
  "name": "my-plugin",
  "description": "What your plugin does. Use when [contexts].",
  "version": "1.0.0"
}
EOF
```

**Optional: Add skills (only if your plugin includes skills)**
```bash
mkdir -p skills/my-skill
cat > skills/my-skill/SKILL.md << 'EOF'
---
name: my-skill
description: What this skill does
---

# My Skill

Instructions here...
EOF
```

**Optional: Add agents, hooks, MCP/LSP servers as needed**
- `agents/agent-name.md` for custom agents
- `hooks.json` for event handlers
- `.mcp.json` for MCP servers
- `.lsp.json` for LSP servers

**Test locally:**
```bash
claude --plugin-dir .
```

**Moving an existing skill into a plugin?**
```bash
mkdir -p skills
cp -r ~/.claude/skills/old-skill skills/old-skill
```
