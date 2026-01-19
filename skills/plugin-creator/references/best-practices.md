# Plugin Best Practices

Guidelines for creating robust, maintainable, shareable Claude Code plugins.

## Table of Contents

- [Naming Conventions](#naming-conventions)
- [Description Writing](#description-writing)
- [Component Organization](#component-organization)
- [Documentation](#documentation)
- [Error Handling](#error-handling)
- [Testing Guidelines](#testing-guidelines)
- [Token Efficiency](#token-efficiency)
- [Versioning Strategy](#versioning-strategy)
- [Security Considerations](#security-considerations)
- [Team/Production Checklist](#teamproduction-checklist)
- [Common Anti-Patterns](#common-anti-patterns)
- [Summary](#summary)

## Naming Conventions

### Plugin Name
- **Format:** lowercase, hyphens, 1-64 characters
- **Pattern:** `[action]-[domain]` or `[domain]-[type]`
- **Examples:**
  - `code-reviewer` (good: action + domain)
  - `pdf-processor` (good: domain + type)
  - `test-runner` (good: action + domain)
  - `analyzer` (poor: too generic)
  - `MyAnalyzer` (poor: uppercase, no hyphens)

### Command Names
- **Format:** lowercase, hyphens
- **Principle:** Verb-based (what Claude does)
- **Examples:**
  - `validate` (good: clear action)
  - `generate-report` (good: multi-word action)
  - `analysis-results` (poor: noun-based, unclear)

### Directory Names
- **Format:** lowercase, hyphens
- **Consistency:** Match naming pattern across plugin
- **Examples:**
  - `commands/`, `agents/`, `skills/`, `references/`
  - `skill-name/` inside `skills/`
  - `agent-name/` inside `agents/`

## Description Writing

### Plugin Description Formula

```
[Action/capability]. Use when [trigger contexts]. [Components/scope].
```

**Examples:**

```
Review code for best practices and potential issues. Use when validating pull requests, reviewing before commit, or analyzing code quality. Includes validate, report, and export commands.
```

```
Extract and analyze PDF documents with OCR. Use when processing PDFs, extracting text, or analyzing document content. Supports encrypted PDFs and multiple formats.
```

```
Execute multi-step workflows with planning and state management. Use when running complex workflows that require orchestration. Includes workflow engine agent and step execution skills.
```

### Specific Trigger Phrases

Claude uses trigger phrases to decide when to activate plugins. Be specific:

**Good trigger phrases:**
- "when validating pull requests"
- "before committing code"
- "when analyzing code quality"
- "when extracting text from PDFs"
- "when generating test reports"

**Poor trigger phrases:**
- "for processing" (too vague)
- "for useful operations" (meaningless)
- "when needed" (everyone would match)
- "for code" (too broad)

## Component Organization

### Directory Depth

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

### Component Responsibilities

Keep components focused on single responsibilities:

**Good:**
- Command: Orchestrates a single user-facing operation
- Skill: Performs one specific task (reusable)
- Agent: Coordinates complex multi-step workflow

**Poor:**
- Command that does 10 unrelated things
- Skill that tries to handle multiple domains
- Agent without clear workflow

## Documentation

### Inline Instructions

Commands and agents should have clear instructions:

**Good:**
```markdown
# Validate Command

Validate code against best practices.

## Quick Start

1. Read `code` argument
2. Check for issues:
   - Undefined variables
   - Unused imports
   - Type mismatches
3. Return formatted report

## Examples

JavaScript example:
  Input: const x = 1;
  Output: Unused variable 'x'
```

**Poor:**
```markdown
# Validate

This validates things.

Just validate the code and return results.
```

### Skill Body Length

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

**Example:**
```
SKILL.md: 250 lines
  - Quick Start (50 lines)
  - Examples (100 lines)
  - Key Notes (100 lines)

references/detailed-guide.md: 500+ lines
  - Complete API reference
  - All patterns and workflows
  - Comprehensive examples

Link from body: "See references/detailed-guide.md for complete reference"
```

### README for Distribution

For team/marketplace plugins, include README.md:

```markdown
# My Plugin

## Description

What the plugin does, who it's for, what problems it solves.

## Installation

How to install globally or project-local.

## Usage

Examples of using the plugin commands.

## Features

What the plugin includes (commands, agents, skills, hooks).

## Requirements

Any prerequisites or dependencies.

## License

License information.

## Support

How to report issues or get help.
```

## Error Handling

### Command Error Handling

Commands should handle errors gracefully:

```markdown
## Error Handling

- Invalid input: Return clear error message with expected format
- Missing required fields: Explain which fields are required
- File not found: Return "File not found: [path]"
- Parse errors: Return "Parse error: [details]"
- External service errors: Return "Service error: [message]"

Always return error message in same format as success output.
```

### Graceful Degradation

When partial results are possible:

```markdown
## Partial Failures

If analyzing multiple files:
- Continue processing remaining files even if one fails
- Return results for successful files
- Include error summary for failed files
- Exit code: 1 if any failures, 0 if all succeed
```

## Testing Guidelines

### Local Testing

Always test locally before sharing:

```bash
# Test plugin in isolation
claude --plugin-dir /path/to/plugin /plugin-name:command

# Test with arguments
claude --plugin-dir /path/to/plugin /plugin-name:command "argument value"

# Test with complex arguments (JSON if needed)
claude --plugin-dir /path/to/plugin /plugin-name:command '{"param": "value"}'
```

### Test Cases to Cover

1. **Basic case:** Normal usage with valid input
2. **Edge cases:** Empty input, single character, large input
3. **Error cases:** Invalid input, missing files, malformed data
4. **Different models:** Test with both Haiku and Opus

### Validation Script

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

## Token Efficiency

### Minimize Level 1-2 Loading

What Claude loads for discovery:
- Plugin name: 1-5 tokens
- Plugin description: 10-30 tokens
- Component list in description: 5-10 tokens

**Keep under 50 tokens for discovery.**

### Optimize SKILL.md Body

**Good structure (50-200 lines typical):**
```
Quick Start (40 lines)
Examples (60 lines)
Key Notes (40 lines)
---
Total: 140 lines, ~500 tokens
```

**Poor structure (300+ lines):**
```
Introduction (50 lines)
Comprehensive guide (200 lines)
All possible examples (100+ lines)
---
Total: 350+ lines, ~1500+ tokens on every invocation
```

### Use References Strategically

Move to references/ if:
- >100 lines of content
- Not essential to core task
- Detailed reference material
- Comprehensive examples

**Token saved:** Content in references/ doesn't load until needed (~90% of the time not needed).

## Versioning Strategy

### Semantic Versioning

```
Version format: MAJOR.MINOR.PATCH

Examples:
  1.0.0 - Initial release
  1.0.1 - Bug fix
  1.1.0 - New feature
  1.2.0 - Another feature
  2.0.0 - Breaking change
```

### Changelog Format

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

## Security Considerations

### Allowed Tools Principle

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

### Input Validation

Commands should validate inputs:

```markdown
## Input Validation

- Code length: Reject if >100KB (prevents timeout)
- File path: Validate path doesn't escape plugin directory
- Language: Validate language parameter against whitelist
- Format: Validate JSON/YAML syntax before processing
```

### Secrets Management

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

## Team/Production Checklist

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

## Common Anti-Patterns

| Anti-Pattern | Why It's Bad | Fix |
|--------------|-------------|-----|
| Command does 10 things | Unfocused, hard to test, unclear activation | Split into multiple focused commands |
| Skill body 2000+ lines | High token cost on every invocation | Move detailed content to references/ |
| Vague description | Plugin never activates when needed | Include specific trigger phrases |
| No error handling | Plugin crashes on invalid input | Validate inputs, return clear errors |
| All tools requested | Unnecessary permissions | Only request needed tools |
| Deeply nested dirs | Hard to navigate, unclear structure | Keep one level deep |
| No examples | Claude doesn't understand usage | Include concrete examples |
| Undocumented behavior | Team doesn't know how to use | Add inline documentation |
| No versioning | Can't track changes or updates | Use semantic versioning |

## Summary

Good plugins:
1. **Clear names** - Plugin and component names describe purpose
2. **Specific descriptions** - Include trigger phrases Claude recognizes
3. **Focused components** - Each command/agent/skill has single responsibility
4. **Efficient token usage** - Keep level 1-2 small, move details to references/
5. **Good documentation** - Inline instructions, examples, error handling
6. **Security-conscious** - Validate inputs, principle of least privilege
7. **Well-tested** - Works with real examples, multiple models
8. **Properly versioned** - Semantic versioning for team coordination
