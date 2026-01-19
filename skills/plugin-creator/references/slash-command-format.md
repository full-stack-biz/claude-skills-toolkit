# Slash Command Format Reference

Complete guide to creating slash commands in Claude Code plugins (`commands/` directory).

## Table of Contents

- [Command File Structure](#command-file-structure)
- [Required Frontmatter](#required-frontmatter)
- [Command Body (Instructions)](#command-body-instructions)
- [Complete Command Example](#complete-command-example)
- [Argument Validation](#argument-validation)
- [File Organization Best Practices](#file-organization-best-practices)
- [Common Patterns](#common-patterns)
- [Metadata Guidelines](#metadata-guidelines)
- [Formatting Tips](#formatting-tips)
- [Integration with Plugin](#integration-with-plugin)

## Command File Structure

Each slash command is a Markdown file with YAML frontmatter (metadata) + instructions (body).

**File location and naming:**
```
my-plugin/
└── commands/
    ├── validate.md
    ├── report.md
    └── export.md
```

**File name becomes command identifier:**
- `validate.md` → `/my-plugin:validate`
- `report.md` → `/my-plugin:report`
- `export.md` → `/my-plugin:export`

**File format:**
```markdown
---
name: command-name
description: What Claude does when user runs this command
arguments:
  param-name:
    description: What this parameter is
    required: true
---

# Command Documentation

Your instructions here. Tell Claude exactly what to do.

Include examples Claude can reference and adapt.
```

## Required Frontmatter

### `name` (string)
- **Length**: 1-64 characters
- **Format**: lowercase, hyphens, no spaces
- **Purpose**: Command identifier
- **Appears in**: `/plugin-name:validate`

**Example:**
```yaml
name: validate
```

### `description` (string)
- **Length**: 1-512 characters
- **Purpose**: Explains what Claude does when command runs
- **Usage**: Claude reads this to understand the command's purpose

**Example:**
```yaml
description: Validate code against best practices and return detailed feedback with specific issues and recommendations.
```

### `arguments` (object)
- **Purpose**: Define input parameters the command accepts
- **Format**: Key-value pairs where key is parameter name
- **Optional**: Can be empty if command takes no parameters

**Structure:**
```yaml
arguments:
  param-name:
    description: What this parameter is for
    required: true
  optional-param:
    description: Optional parameter description
    required: false
```

**Example:**
```yaml
arguments:
  code:
    description: Source code to validate
    required: true
  language:
    description: Programming language (js, py, go, rust)
    required: false
  strict-mode:
    description: Enable strict validation rules
    required: false
```

**Field descriptions:**

| Field | Purpose |
|-------|---------|
| `description` | Explains what the parameter is (Claude reads this) |
| `required` | Boolean; true = parameter must be provided, false = optional |

## Command Body (Instructions)

Everything after the frontmatter is instructions Claude executes.

**Structure:**
```markdown
# Command Name

Brief description of what this command does.

## Quick Start

Step-by-step instructions for the most common use case.

## Examples

Concrete examples Claude can reference and adapt.

## Key Notes

Important constraints, edge cases, error handling.

## Full Reference

Detailed documentation (optional for complex commands).
```

**Guidelines:**
- Be procedural: tell Claude exactly what to do
- Be concrete: include examples, code patterns, test cases
- Be concise: focus on execution, not explanation
- Progressive disclosure: essentials first, advanced topics last

**Example command body:**

```markdown
# Validate Command

Validate source code against best practices and return detailed feedback.

## Quick Start

1. Read the input code from the `code` argument
2. Analyze for common issues (undefined variables, unused imports, type mismatches)
3. Check against best practices for the language specified in `language` argument
4. Return formatted report with:
   - Issue type (error, warning, style)
   - Line number
   - Specific issue description
   - Recommended fix
   - Priority (high, medium, low)

## Examples

**Example 1: Validate JavaScript with strict mode**
```
Input:
  code: "const x = 1; const y = 2;"
  language: "js"
  strict-mode: true

Output:
  - Line 1, col 7: Unused variable 'x' (high priority)
  - Line 1, col 22: Unused variable 'y' (high priority)
```

**Example 2: Validate Python**
```
Input:
  code: "import os\ndef hello():\n  print('test')"
  language: "py"

Output:
  - Line 1: Unused import 'os' (medium priority)
  - No syntax errors detected
```

## Key Notes

- If `language` not specified, attempt to auto-detect
- Always include line/column numbers in output
- Return empty report if no issues found
- Handle errors gracefully (return error message, not crash)
- Respect `strict-mode` flag if provided

## Language-Specific Rules

### JavaScript/TypeScript
- Check for undefined variables, unused imports
- Validate syntax
- Flag common mistakes (== vs ===, missing semicolons if strict-mode)

### Python
- Check for indentation errors
- Flag unused imports
- Validate syntax

### Go
- Check for unused variables and packages
- Validate syntax
- Format issues

### Rust
- Check for borrowing/ownership issues
- Validate syntax
- Flag common Rust patterns
```

## Complete Command Example

**File: `commands/validate.md`**

```markdown
---
name: validate
description: Validate source code against best practices, syntax, and style rules. Returns detailed feedback with issue location, severity, and recommended fixes.
arguments:
  code:
    description: Source code to validate
    required: true
  language:
    description: Programming language (js, ts, py, go, rust, java, c)
    required: false
  rules:
    description: Comma-separated list of rules to check (all, syntax, style, best-practices)
    required: false
  strict:
    description: Enable strict validation (flag: true/false)
    required: false
---

# Validate Command

Analyzes source code for syntax errors, style violations, and best practice violations.

## Quick Start

1. Parse the `code` argument
2. Detect language (use `language` parameter or auto-detect)
3. Run validation checks:
   - Syntax validation (parse errors, invalid constructs)
   - Style validation (formatting, naming conventions, organization)
   - Best practice checks (unused variables, imports, common mistakes)
4. Return sorted report (high priority first)

Each issue includes:
- Line and column number
- Issue type and message
- Severity (error, warning, style)
- Recommended fix (when applicable)

## Examples

**JavaScript validation:**
```
Input: code: "const x = 1;"
       language: "js"
       strict: true

Output:
✗ Line 1: Unused variable 'x' (error)
  Recommendation: Remove unused variable or assign to _x if intentional

✓ No syntax errors detected
✓ Code is valid JavaScript
```

**Python validation:**
```
Input: code: "import os\nprint('hello')"
       language: "py"

Output:
⚠ Line 1: Unused import 'os' (warning)
  Recommendation: Remove import or use os in code

✓ No syntax errors detected
✓ Code follows Python conventions
```

## Key Notes

- Auto-detect language if not specified (by file extension or syntax)
- Return errors first (highest priority), then warnings, then style issues
- Always include line/column numbers
- Handle parse errors gracefully
- If `rules` specified, check only those rules
- If `strict` true, apply stricter style rules
- Return empty result if no issues found

## Error Handling

- Invalid language: auto-detect and return warning
- Malformed code: return syntax error details
- Unknown rules: apply default rules and note skipped ones
```

## Argument Validation

Claude validates command arguments before execution:

| Field | Validation | Required |
|-------|-----------|----------|
| `description` | Human-readable string | Yes |
| `required` | Boolean (true/false) | Yes |

**Example with multiple arguments:**

```yaml
arguments:
  input-file:
    description: Path to file to process
    required: true
  output-format:
    description: Output format (json, csv, xml)
    required: false
  verbose:
    description: Enable verbose output (flag)
    required: false
```

## File Organization Best Practices

**Single-purpose commands:**
```
commands/
└── validate.md    # Just validation
```

**Multi-step workflow (separate commands):**
```
commands/
├── validate.md     # Step 1: validate
├── report.md       # Step 2: generate report
└── export.md       # Step 3: export results
```

**Related commands (organized by function):**
```
commands/
├── analyze.md       # Analysis commands
├── format.md        # Formatting commands
└── validate.md      # Validation commands
```

## Common Patterns

### Pattern 1: Simple Input → Output Command

```yaml
name: analyze
description: Analyze input and return results
arguments:
  input:
    description: Content to analyze
    required: true
```

### Pattern 2: File-Based Command

```yaml
name: process
description: Process a file and generate output
arguments:
  filepath:
    description: Path to file to process
    required: true
  options:
    description: Processing options
    required: false
```

### Pattern 3: Configuration Command

```yaml
name: setup
description: Configure plugin settings
arguments:
  config-file:
    description: Path to configuration file
    required: true
  validate-only:
    description: Validate config without applying (flag)
    required: false
```

## Metadata Guidelines

**Good descriptions:**
- "Validate code syntax and style rules, returning detailed feedback"
- "Generate test reports in multiple formats with coverage analysis"
- "Extract text from PDF documents using OCR"

**Poor descriptions:**
- "Process things" (vague)
- "Do stuff" (unclear)
- "Command" (no information)

## Formatting Tips

**Use markdown for clarity:**
```markdown
---
name: command-name
description: >-
  Multi-line description if needed. Use >- for line folding
  so it stays readable in YAML.
arguments:
  param:
    description: |
      Multi-line argument description.
      Can span multiple lines.
    required: true
---
```

## Integration with Plugin

Commands are discovered automatically if:
1. Located in `commands/` directory
2. Have `.md` file extension
3. Contain valid YAML frontmatter with `name` field
4. Plugin manifest (plugin.json) is valid

**Command activation:**
- Slash command format: `/plugin-name:command-name`
- Example: `/code-reviewer:validate`
- Claude reads command description to decide when to suggest it
