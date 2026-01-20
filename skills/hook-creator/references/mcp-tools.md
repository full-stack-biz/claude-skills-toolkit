# MCP Tool Hooks

How to hook into Model Context Protocol (MCP) tools using special naming patterns.

## MCP Tool Naming Convention

MCP tools follow the pattern: `mcp__<server>__<tool>`

**Example MCP tool names:**
- `mcp__memory__create_entities` - Memory server's create entities tool
- `mcp__filesystem__read_file` - Filesystem server's read file tool
- `mcp__github__search_repositories` - GitHub server's search repositories tool
- `mcp__web__fetch_url` - Web server's fetch URL tool

## Matching MCP Tools in Hooks

MCP tools work with all hook events that support matchers (PreToolUse, PostToolUse, PermissionRequest, etc.).

### Match Specific MCP Tool

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "mcp__memory__create_entities",
        "hooks": [{
          "type": "command",
          "command": "${CLAUDE_PLUGIN_ROOT}/scripts/validate-mcp-memory.sh",
          "timeout": 2000
        }]
      }
    ]
  }
}
```

### Match All Tools from an MCP Server

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "mcp__filesystem__.*",
        "hooks": [{
          "type": "command",
          "command": "${CLAUDE_PLUGIN_ROOT}/scripts/log-filesystem-ops.sh",
          "timeout": 1000
        }]
      }
    ]
  }
}
```

Matches: `mcp__filesystem__read_file`, `mcp__filesystem__write_file`, etc.

### Match Write Operations Across MCP Servers

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "mcp__.*__write.*",
        "hooks": [{
          "type": "command",
          "command": "${CLAUDE_PLUGIN_ROOT}/scripts/validate-writes.sh",
          "timeout": 3000
        }]
      }
    ]
  }
}
```

Matches any write-like operation from any MCP server.

## Common Patterns

| Pattern | Matches |
|---------|---------|
| `mcp__memory__.*` | All memory server operations |
| `mcp__filesystem__.*` | All filesystem operations |
| `mcp__.*__read.*` | Read operations from any server |
| `mcp__.*__write.*` | Write operations from any server |
| `mcp__.*__delete.*` | Delete operations from any server |
| `^mcp__` | Any MCP tool (vs built-in tools) |

## Input Data for MCP Tools

When an MCP tool is hooked, the input includes:

```json
{
  "tool_name": "mcp__memory__create_entities",
  "tool_input": {
    "entities": [
      {"name": "entity1", "data": "value"}
    ]
  }
}
```

Extract in bash hooks:

```bash
#!/bin/bash
read -r input
tool=$(echo "$input" | jq -r '.tool_name')
tool_input=$(echo "$input" | jq -r '.tool_input')

if [[ "$tool" == "mcp__memory__"* ]]; then
  # Handle memory operations
fi
```

## Example: Audit MCP Memory Operations

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "^mcp__memory__",
        "hooks": [{
          "type": "command",
          "command": "${CLAUDE_PLUGIN_ROOT}/scripts/audit-memory.sh",
          "timeout": 1000,
          "onError": "warn"
        }]
      }
    ]
  }
}
```

Script (audit-memory.sh):
```bash
#!/bin/bash

read -r input
tool=$(echo "$input" | jq -r '.tool_name')
operation=$(echo "$tool" | sed 's/mcp__memory__//')

# Log all memory operations
echo "$(date): Memory operation: $operation" >> "$HOME/.claude/mcp-audit.log"

exit 0
```

## Example: Validate Filesystem Writes

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "mcp__filesystem__write.*",
        "hooks": [{
          "type": "command",
          "command": "${CLAUDE_PLUGIN_ROOT}/scripts/validate-fs-write.sh",
          "timeout": 2000
        }]
      }
    ]
  }
}
```

Script (validate-fs-write.sh):
```bash
#!/bin/bash

read -r input
file_path=$(echo "$input" | jq -r '.tool_input.path // ""')

# Reject writes to system directories
if [[ "$file_path" =~ ^/etc|^/sys|^/proc ]]; then
  cat >&2 <<'EOF'
{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "deny",
    "permissionDecisionReason": "System directories protected from writes"
  }
}
EOF
  exit 2
fi

exit 0
```

## Differentiating MCP from Built-in Tools

In a matcher that needs to distinguish:

```json
{
  "matcher": "^(?!mcp__)(Read|Write|Edit|Bash)$"
}
```

This matches only built-in Read/Write/Edit/Bash (excludes MCP versions).

Or explicitly:

```json
{
  "matcher": "^(Read|Write|Edit|Bash)$"
}
```

Matches only built-in tools (MCP tools always have `mcp__` prefix).

## Performance Notes

MCP tool hooks have similar latency to built-in tools:
- PreToolUse: <100ms (validation only)
- PostToolUse: Depends on script (typically 1-5s)
- Timeouts: Same recommendations as built-in tools

## Available MCP Servers

Check your Claude Code installation for available MCP servers. Common ones:

- **memory** - Persistent memory storage (`mcp__memory__*`)
- **filesystem** - File operations (`mcp__filesystem__*`)
- **github** - GitHub API (`mcp__github__*`)
- **web** - Web fetching (`mcp__web__*`)

Check documentation for each MCP server's available tools.
