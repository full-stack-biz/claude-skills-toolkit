# LSP Servers for Code Intelligence

LSP (Language Server Protocol) servers provide Claude with real-time code intelligence: symbol navigation, hover information, diagnostics, and language-specific context. This guide covers adding LSP support to your plugin.

## Table of Contents

- [When to Use LSP Servers](#when-to-use-lsp-servers)
- [LSP Architecture](#lsp-architecture)
- [Configuration Format](#configuration-format)
- [Common Language Servers](#common-language-servers)
- [Plugin Structure with LSP](#plugin-structure-with-lsp)
- [Advanced Configuration](#advanced-configuration)
- [Testing LSP Locally](#testing-lsp-locally)
- [Troubleshooting](#troubleshooting)
- [Publishing LSP Plugins](#publishing-lsp-plugins)
- [LSP vs. Skills](#lsp-vs-skills)
- [References](#references)

## When to Use LSP Servers

Add LSP to your plugin when:

- **Supporting a language** Claude Code doesn't have official LSP support for
- **Enhancing code understanding** for a specialized language or framework
- **Providing language-specific features** (linting, formatting, diagnostics)
- **Improving code context** for agents and Skills that work with specific languages

Examples:
- Rust plugin with rust-analyzer
- Go plugin with gopls
- Custom language support
- Domain-specific language (DSL) servers

## LSP Architecture

LSP servers communicate with Claude Code to provide language-specific capabilities:

```
Claude Code (client)
    ↕ (JSON-RPC over stdio)
LSP Server (external process)
    ↕ (file system / language tools)
Your codebase
```

Claude Code:
1. Launches the LSP server binary (specified in `.lsp.json`)
2. Sends file content and cursor position
3. Receives diagnostics, completions, hover information
4. Uses context to inform Code Understanding and Symbol Navigation

## Configuration Format

Create `.lsp.json` at your plugin root:

```json
{
  "language-id": {
    "command": "server-binary",
    "args": ["--arg1", "value1"],
    "extensionToLanguage": {
      ".ext": "language-id"
    },
    "initializationOptions": {}
  }
}
```

**Required fields:**
- `command` - LSP server binary name or path (must be in PATH)
- `extensionToLanguage` - Object mapping file extensions to language IDs (e.g., `{".go": "go"}`)

**Optional fields:**
- `args` - Array of command-line arguments (e.g., `["serve"]`)
- `env` - Object of environment variables to set when starting server
- `initializationOptions` - LSP initialization settings (language-specific)
- `settings` - Settings passed via `workspace/didChangeConfiguration`
- `transport` - Communication transport: `stdio` (default) or `socket`
- `workspaceFolder` - Workspace folder path for the server
- `startupTimeout` - Max time to wait for server startup (milliseconds)
- `shutdownTimeout` - Max time to wait for graceful shutdown (milliseconds)
- `restartOnCrash` - Whether to automatically restart if server crashes
- `maxRestarts` - Maximum number of restart attempts before giving up

## Common Language Servers

### Go

```json
{
  "go": {
    "command": "gopls",
    "args": ["serve"],
    "extensionToLanguage": {
      ".go": "go"
    },
    "initializationOptions": {
      "usePlaceholders": true
    }
  }
}
```

**Setup:**
```bash
go install github.com/golang/tools/gopls@latest
```

### Rust

```json
{
  "rust": {
    "command": "rust-analyzer",
    "extensionToLanguage": {
      ".rs": "rust"
    }
  }
}
```

**Setup:**
```bash
rustup component add rust-analyzer
```

### Python

```json
{
  "python": {
    "command": "pylsp",
    "extensionToLanguage": {
      ".py": "python"
    },
    "initializationOptions": {
      "pylsp": {
        "plugins": {
          "pycodestyle": {"enabled": true},
          "pyflakes": {"enabled": true}
        }
      }
    }
  }
}
```

**Setup:**
```bash
pip install python-lsp-server
```

### TypeScript / JavaScript

```json
{
  "typescript": {
    "command": "typescript-language-server",
    "args": ["--stdio"],
    "extensionToLanguage": {
      ".ts": "typescript",
      ".tsx": "typescript",
      ".js": "javascript",
      ".jsx": "javascript"
    }
  }
}
```

**Setup:**
```bash
npm install -g typescript-language-server typescript
```

### Ruby

```json
{
  "ruby": {
    "command": "ruby-lsp",
    "extensionToLanguage": {
      ".rb": "ruby"
    }
  }
}
```

**Setup:**
```bash
gem install ruby-lsp
```

## Plugin Structure with LSP

Include LSP in your plugin alongside other components:

```
my-lsp-plugin/
├── .claude-plugin/
│   └── plugin.json
├── .lsp.json
├── commands/
│   └── debug.md
├── skills/
│   └── language-analysis/
│       └── SKILL.md
└── README.md
```

## Advanced Configuration

### Server Restart and Timeout Options

Configure server lifecycle behavior:

```json
{
  "go": {
    "command": "gopls",
    "args": ["serve"],
    "extensionToLanguage": {".go": "go"},
    "startupTimeout": 5000,
    "shutdownTimeout": 3000,
    "restartOnCrash": true,
    "maxRestarts": 3
  }
}
```

### Environment Variables and Settings

Pass environment variables and workspace settings to server:

```json
{
  "python": {
    "command": "pylsp",
    "extensionToLanguage": {".py": "python"},
    "env": {
      "PYTHONPATH": "/custom/python/path"
    },
    "settings": {
      "pylsp": {
        "plugins": {
          "pycodestyle": {"enabled": true},
          "pyflakes": {"enabled": true}
        }
      }
    }
  }
}
```

### Multiple Language Servers

Configure multiple languages in a single `.lsp.json`:

```json
{
  "go": {
    "command": "gopls",
    "args": ["serve"],
    "extensionToLanguage": {
      ".go": "go"
    }
  },
  "rust": {
    "command": "rust-analyzer",
    "extensionToLanguage": {
      ".rs": "rust"
    }
  },
  "python": {
    "command": "pylsp",
    "extensionToLanguage": {
      ".py": "python"
    }
  }
}
```

### Initialization Options

Pass language-specific configuration to LSP servers:

```json
{
  "go": {
    "command": "gopls",
    "args": ["serve"],
    "extensionToLanguage": {
      ".go": "go"
    },
    "initializationOptions": {
      "analyses": {
        "unusedvariable": true,
        "unreachable": true
      },
      "staticcheck": true,
      "usePlaceholders": true
    }
  }
}
```

### Environment Variables

Some servers require environment configuration. Set via wrapper script:

```bash
#!/bin/bash
# lsp-wrapper.sh
export RUST_LOG=debug
exec rust-analyzer "$@"
```

Then in `.lsp.json`:

```json
{
  "rust": {
    "command": "./lsp-wrapper.sh",
    "extensionToLanguage": {
      ".rs": "rust"
    }
  }
}
```

## Testing LSP Locally

Test your LSP configuration using `--plugin-dir`:

```bash
claude --plugin-dir /path/to/my-plugin
```

Claude Code will:
1. Load `.lsp.json` configuration
2. Launch the configured LSP server(s)
3. Provide language-specific features for recognized file types

Verify LSP is working by:
- Opening a file with the configured language extension
- Checking hover information appears
- Verifying diagnostics are reported
- Testing symbol navigation (if supported)

## Troubleshooting

### LSP server not starting

**Problem:** "Server failed to start" or LSP features unavailable

**Solutions:**
- Verify LSP server binary is installed and in PATH
- Check binary name matches `command` field exactly
- Test LSP server manually: `gopls serve` (for Go example)
- Add `args: ["serve"]` if server requires explicit serve mode
- Check file extension matches `extensionToLanguage` mapping

### LSP server crashes on startup

**Problem:** LSP server exits immediately or hangs

**Solutions:**
- Check `initializationOptions` are valid for your server
- Verify server version compatibility with Claude Code
- Test with minimal config (no `initializationOptions`)
- Check server documentation for required arguments

### No diagnostics or features appearing

**Problem:** LSP is running but features aren't visible

**Solutions:**
- Verify file extension is mapped in `extensionToLanguage`
- Check that language ID matches file extension mapping
- Ensure server is actually running (check Claude Code logs)
- Test with a simple file in the target language

### Performance issues

**Problem:** Claude Code becomes slow after adding LSP server

**Solutions:**
- Disable expensive LSP features in `initializationOptions`
- Reduce frequency of LSP requests
- Check if LSP server has high CPU/memory usage
- Consider using lightweight server alternative

## Publishing LSP Plugins

### Include Required Setup Instructions

Document LSP server installation in your README:

```markdown
## Installation

This plugin requires the Go language server:

### macOS
\`\`\`bash
brew install gopls
\`\`\`

### Linux
\`\`\`bash
go install github.com/golang/tools/gopls@latest
\`\`\`

### Windows
\`\`\`bash
go install github.com/golang/tools/gopls@latest
\`\`\`
```

### Version Tracking

Document the LSP server version your plugin supports:

```markdown
## Compatibility

- **gopls**: 0.11.0 or later
- **Claude Code**: 1.0.33 or later
```

### Testing Before Distribution

Test your LSP plugin across:
- Different OS platforms (macOS, Linux, Windows)
- Different LSP server versions
- Different project structures (monorepo, simple project, etc.)
- Verify Performance (LSP shouldn't cause noticeable slowdowns)

## LSP vs. Skills

When building language support, choose the right approach:

| Need | Use | Reason |
|------|-----|--------|
| Real-time code intelligence | LSP server in `.lsp.json` | Claude Code integrates with LSP natively |
| Language-specific analysis | Agent Skill | Claude can invoke automatically |
| Diagnostics & linting | LSP server | Standard LSP interface |
| Custom commands | Slash command | User-invoked via `/plugin:command` |
| IDE features (hover, goto) | LSP server | Claude Code uses LSP protocol |

## References

- [LSP Specification](https://microsoft.github.io/language-server-protocol/)
- [LSP Server Implementations](https://microsoft.github.io/language-server-protocol/implementors/servers/)
- [Claude Code Plugins Reference](about:/docs/en/plugins-reference#lsp-servers)
