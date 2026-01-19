# MCP Servers in Plugins

MCP (Model Context Protocol) servers let your plugin integrate external tools, databases, and services that Claude can use.

## When to Include MCP Servers in Your Plugin

Add MCP configuration to your plugin when:

- You need Claude to access external services (databases, APIs, file systems)
- You want to provide Claude custom tools for your domain
- You're integrating with specialized platforms (monitoring, deployment, content management)

Examples:
- Database plugin with MCP server for SQL queries
- Deployment plugin with MCP server for infrastructure access
- Document plugin with MCP server for content retrieval

**Don't add MCP if:**
- Task can be done with built-in tools (Read, Write, Bash, Grep)
- You just need slash commands or skills (use those instead)

## Plugin Structure with MCP

```
my-plugin/
├── .claude-plugin/
│   └── plugin.json
├── .mcp.json                     # MCP server configuration
├── commands/
│   └── query.md
└── README.md
```

The `.mcp.json` file is at plugin root (not in `.claude-plugin/`).

## .mcp.json Format

```json
{
  "mcpServers": {
    "server-name": {
      "command": "python",
      "args": ["-m", "mcp_server_module"]
    }
  }
}
```

**Structure:**
- `mcpServers` - Object containing server definitions
- `server-name` - Custom name (can be anything)
- `command` - Binary or script to run
- `args` - Command-line arguments (optional)

## Common MCP Patterns

### Python MCP Server

```json
{
  "mcpServers": {
    "my-db": {
      "command": "python",
      "args": ["-m", "mcp_database_server"]
    }
  }
}
```

**Requirements:**
- Python installed on system
- MCP module available (`pip install mcp-database-server`)

### Node.js MCP Server

```json
{
  "mcpServers": {
    "api-access": {
      "command": "node",
      "args": ["./server.js"]
    }
  }
}
```

**Requirements:**
- Node.js installed
- Server script at `./server.js` (relative to plugin root)

### Local Script

```json
{
  "mcpServers": {
    "custom": {
      "command": "./bin/my-server.sh"
    }
  }
}
```

**Requirements:**
- Script is executable
- Script implements MCP protocol

## Plugin Structure with MCP Server

If your plugin includes custom MCP server code:

```
my-plugin/
├── .claude-plugin/
│   └── plugin.json
├── .mcp.json
├── mcp-server/
│   ├── __init__.py
│   ├── server.py
│   └── requirements.txt
├── commands/
│   └── query.md
└── README.md
```

Store server code in `mcp-server/` or similar subdirectory.

## Testing MCP Locally

Test with `--plugin-dir`:

```bash
claude --plugin-dir /path/to/my-plugin
```

**Verify MCP is working:**

1. **Check server launches** - Look for startup messages
2. **Test MCP tools** - Claude should be able to use provided tools
3. **Check tool discovery** - `/tools` command shows available tools
4. **Test tool execution** - Use tools in conversation (Claude will invoke them)

If MCP server fails to start:
- Check command syntax in `.mcp.json`
- Verify binary/script exists and is executable
- Check dependencies are installed
- Test server directly: `python -m mcp_server_module`

## Publishing Plugin with MCP

### Document Dependencies

List all MCP server requirements in README:

```markdown
## Installation

This plugin requires external dependencies:

### Python Module
\`\`\`bash
pip install mcp-database-server
\`\`\`

### Node Module
\`\`\`bash
npm install -g my-mcp-server
\`\`\`

### Environment Variables
- `DATABASE_URL` - Database connection string
- `API_KEY` - Authentication token
```

### Security Considerations

For plugins with MCP servers:

- **No hardcoded secrets** - Use environment variables
- **Validate input** - MCP tools should validate Claude's requests
- **Document permissions** - What access does MCP server have?
- **Secure by default** - Restrictive access, not permissive

### Version Requirements

Document which Claude Code versions support your MCP:

```markdown
## Requirements

- Claude Code 1.0.33 or later
- Python 3.8+ (if using Python MCP server)
- Node 16+ (if using Node.js MCP server)
```

## Packaging Custom MCP Servers

If your plugin includes custom MCP server code:

### Directory Structure

```
my-plugin/
├── .claude-plugin/
│   └── plugin.json
├── .mcp.json
├── mcp-server/
│   ├── __init__.py
│   ├── server.py
│   ├── requirements.txt
│   └── tools/
│       └── database.py
└── README.md
```

### MCP Server Configuration

Point `.mcp.json` to your server:

```json
{
  "mcpServers": {
    "my-server": {
      "command": "python",
      "args": ["-m", "mcp_server"]
    }
  }
}
```

Make sure the module is importable (Python path includes plugin directory).

### Testing Custom MCP Server

```bash
# Test server directly
python -m mcp_server

# Or test in plugin
claude --plugin-dir /path/to/my-plugin
```

## Troubleshooting

| Problem | Cause | Fix |
|---------|-------|-----|
| MCP server won't start | Binary not found | Check command path in `.mcp.json` |
| MCP server crashes | Module not installed | Install dependencies: `pip install ...` |
| Tools not available | Server not launching | Check `.mcp.json` syntax, test server directly |
| Tools fail on use | Server error | Test tool with example input, check server logs |
| Permission denied | Script not executable | `chmod +x ./bin/server.sh` |

## When to Use MCP vs. Other Options

| Need | Use | Why |
|------|-----|-----|
| External service integration | MCP server | Proper protocol for tool access |
| Simple external commands | Slash command using Bash | Simpler, no protocol overhead |
| Claude's built-in capabilities | Skills/commands | No external dependencies |
| Database or API access | MCP server | Structured, secure tool interface |

## See Also

- [MCP Documentation](about:/docs/en/mcp) - Official MCP specs
- [Claude Code MCP Reference](about:/docs/en/plugins-reference#mcp-servers) - Plugin-specific MCP configuration
- [Model Context Protocol](https://modelcontextprotocol.io/) - MCP standard
