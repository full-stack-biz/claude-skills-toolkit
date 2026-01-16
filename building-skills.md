---
tags:
  - skills
  - best-practices
  - claude
  - llm
  - prompt-engineering
  - patterns
  - architecture
  - reference
  - documentation
---
# Skills: Best Practices for Writing and Using

> Compiled from [Official Anthropic Docs](https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices), [Claude Code Skills Documentation](https://code.claude.com/docs/en/skills), [anthropics/skills repository](https://github.com/anthropics/skills), and community analysis (2025-2026).

Source: https://github.com/Dicklesworthstone/meta_skill/blob/main/BEST_PRACTICES_FOR_WRITING_AND_USING_SKILLS_MD_FILES.md

---

## 1. What Skills Are (Mental Model)

Skills are **onboarding guides for specialized tasks**—modular instruction packages Claude loads dynamically when relevant. They transform Claude from general-purpose to domain-expert with procedural knowledge no model inherently possesses.

| Aspect | CLAUDE.md | Skills |
|--------|-----------|--------|
| Loading | Always (startup) | On-demand (triggered) |
| Scope | Project-wide rules | Task-specific workflows |
| Context cost | Every conversation | Only when needed |
| Structure | Single file | Directory with resources |

**Use CLAUDE.md for**: Unchanging conventions, coding standards, always-on project rules.
**Use Skills for**: Complex workflows, scripts, templates, domain expertise activated contextually.

---

## 2. Architecture (How Skills Work Internally)

### Token Loading Hierarchy

```
Level 1: Metadata only (always loaded)     ~100 tokens
         name + description in system prompt
                    ↓
Level 2: SKILL.md body (on trigger)        ~1,500-5,000 tokens
         Full instructions load after skill selected
                    ↓
Level 3: Bundled resources (as-needed)     Unlimited
         scripts/ references/ assets/
         Only read when Claude determines necessary
```

### Selection Mechanism

**Pure LLM reasoning—no algorithmic matching.** Claude evaluates all skill descriptions via natural language understanding, not embeddings/classifiers/keyword-matching.

This means:
- Description quality is **critical** for triggering
- Vague descriptions → skill never triggers
- Specific trigger phrases → reliable activation

### Execution Model

Skills use a **dual-message injection pattern**:
1. Metadata message (`isMeta: false`) — visible to user as status
2. Skill prompt message (`isMeta: true`) — hidden from UI, sent to API

This provides transparency without dumping instruction walls into chat.

---

## 3. Required Structure

```
skill-name/
├── SKILL.md                    # Required - instructions + frontmatter
├── scripts/                    # Optional - executable code
│   └── validate.py
├── references/                 # Optional - docs loaded into context
│   ├── api.md
│   └── schema.md
└── assets/                     # Optional - files used in output (not loaded)
    └── template.docx
```

### Frontmatter (YAML)

```yaml
---
name: processing-pdfs                    # Required: lowercase, hyphens only
description: >-                          # Required: what + when to use
  Extract text and tables from PDF files, fill forms, merge documents.
  Use when working with PDF files or when user mentions PDFs, forms,
  or document extraction.
---
```

**Validation rules:**
- `name`: ≤64 chars, `[a-z0-9-]` only, no "anthropic"/"claude"
- `description`: ≤1024 chars, non-empty, no XML tags

### Body (Markdown)

Instructions Claude follows after skill triggers. Target **<500 lines**. Split into reference files when exceeding.

---

## 4. Core Design Principles

### 4.1 Conciseness Is Survival

Context window = public good. Every token competes with conversation history, other skills, user requests.

**Default assumption: Claude is already intelligent.** Only add what Claude doesn't know.

````markdown
# BAD (~150 tokens) - explains obvious things
PDF (Portable Document Format) files are a common file format that contains
text, images, and other content. To extract text from a PDF, you'll need to
use a library. There are many libraries available...

# GOOD (~50 tokens) - assumes competence
## Extract PDF text
Use pdfplumber:
```python
import pdfplumber
with pdfplumber.open("file.pdf") as pdf:
    text = pdf.pages[0].extract_text()
```
````

**Challenge each line:** "Does Claude need this? Does this justify its token cost?"

### Token Efficiency Metrics

Use these benchmarks to optimize your Skills:

| Content | Target | Why |
|---------|--------|-----|
| **Metadata (Level 1)** | ~100 tokens | Always loaded; prefer concise descriptions |
| **SKILL.md body (Level 2)** | 1,500-5,000 tokens | Loaded when triggered; actionable content only |
| **Reference files (Level 3)** | Unlimited | Loaded on-demand; no token cost if unused |
| **Quick Start section** | <100 tokens | Should solve 80% of tasks without references |

**Token optimization strategies:**
1. **Code over prose** — One runnable example (~50 tokens) beats three paragraphs of explanation (~150 tokens)
2. **Tables over lists** — Structured data compresses better than prose
3. **Reference, don't repeat** — Link to reference file instead of duplicating content
4. **Remove tutorials** — Assume Claude knows basics; only add domain-specific knowledge
5. **Defer detail** — Put edge cases and advanced options in references/, not SKILL.md

**Real example:** PDF skill Quick Start
````markdown
# GOOD (~80 tokens) - actionable, code-first
Extract text from PDF using pdfplumber:
```python
import pdfplumber
with pdfplumber.open("file.pdf") as pdf:
    text = pdf.pages[0].extract_text()
```

For form filling and advanced operations, see references/FORMS.md
````
```

### 4.2 Progressive Disclosure

Never front-load everything. Structure for on-demand loading.

**Content ordering principle:** Start with essentials (Quick Reference + concrete examples), then expand into categorized details.

```markdown
# In SKILL.md - optimal ordering
## Quick reference
[3-5 critical rules with code examples]

## Common patterns
[3-4 concrete, copy-paste ready examples]

## Detailed categories
[Organized by topic/impact/priority]

## Advanced features
- **Feature A**: See [FORMS.md](FORMS.md)
- **Feature B**: See [B.md](references/B.md)
```

Claude loads reference files only when needed to solve the task.

**Critical rules:**
- **Start with actionable content** — Quick reference + examples before theory/details
- Keep references **one level deep** from SKILL.md
- No chains: SKILL.md → advanced.md → details.md (Claude may partial-read)
- Long files (>100 lines): include TOC at top

**Why this matters:** Actionable content upfront reduces context window usage. Quick reference patterns solve most tasks without loading auxiliary files. Detailed sections available when Claude needs them.

### 4.3 Degrees of Freedom

Match specificity to task fragility:

| Freedom | When | Example |
|---------|------|---------|
| **High** | Multiple valid approaches, context-dependent | Code review guidelines |
| **Medium** | Preferred pattern exists, some variation OK | Report templates with customizable sections |
| **Low** | Fragile/error-prone, consistency critical | DB migration scripts—exact command, no flags |

**Analogy:** Narrow bridge with cliffs = low freedom (exact guardrails). Open field = high freedom (general direction).

### 4.4 Reference Structure Best Practices

Reference files enable Skills to contain comprehensive content without token penalties. However, structure matters.

**Critical constraint: One level deep only**

✅ **Correct:** Flat structure
```
skill-name/
├── SKILL.md
└── references/
    ├── guide.md
    ├── api.md
    └── patterns.md
```

❌ **Wrong:** Nested chains
```
skill-name/
├── SKILL.md
└── references/
    └── guides/
        ├── advanced/
        │   └── patterns.md
        └── basic.md
```

**Why one level deep?** Claude may partial-read nested files. If Claude reads `references/guides/advanced.md` but misses critical context from `references/guides/basic.md`, the skill fails silently.

**Long reference files (>100 lines): Include TOC**

When a reference file exceeds 100 lines, start with a table of contents:

```markdown
# Complete API Reference

## Table of Contents
- [Authentication](#authentication)
- [Core Operations](#core-operations)
- [Error Handling](#error-handling)
- [Rate Limits](#rate-limits)

## Authentication
[content...]

## Core Operations
[content...]
```

This helps Claude navigate without loading entire file into context.

**Naming convention for references:**
- Semantic names: `complete-guide.md`, `api-reference.md`, `troubleshooting.md`
- Avoid generic: ❌ `reference.md`, `guide.md`, `config.md` (could match many skills)
- Be specific: ✅ `bigquery-api-reference.md`, `pdf-forms-guide.md`

---

## 5. Writing Effective Descriptions

The description is **the** triggering mechanism. Claude uses it to select from 100+ skills.

### Rules

1. **Third person always** — "Processes Excel files" not "I can help you" or "You can use this"
2. **Specific + trigger phrases** — Include what it does AND when to invoke
3. **Key terms for discovery** — Use synonyms user might say

### Examples

```yaml
# GOOD - specific, includes triggers
description: >-
  Analyze Excel spreadsheets, create pivot tables, generate charts.
  Use when analyzing Excel files, spreadsheets, tabular data, or .xlsx files.

# GOOD - action + context
description: >-
  Generate descriptive commit messages by analyzing git diffs.
  Use when user asks for help writing commit messages or reviewing staged changes.

# BAD - vague
description: Helps with documents
description: Processes data
description: Does stuff with files
```

### Recommended: "When to use this skill" Section

Beyond the frontmatter description, include an explicit **"When to use this skill"** section early in the SKILL.md body.

**Why this pattern works:**
- Description triggers the skill; this section clarifies its scope
- Helps Claude understand multiple use cases vs. edge cases
- Provides context before diving into detailed content
- Immediate clarity on applicability

**Example structure:**
```markdown
## When to use this skill

**Use this skill when:**
- [Primary use case 1]
- [Primary use case 2]
- [Specific scenario]

**Key areas covered:**
- **Category A** (CRITICAL): [What it does]
- **Category B** (HIGH): [What it does]
- **Category C** (MEDIUM): [What it does]

**Not recommended for:**
- [Edge case where skill doesn't apply]
- [Scenario where manual approach is better]
```

This section bridges the gap between the metadata description and the skill's detailed content, serving as a "second filter" for relevance.

---

## 6. Naming Conventions

**Prefer gerund form** (verb + -ing): clearly describes activity.

```
✓ processing-pdfs
✓ analyzing-spreadsheets
✓ testing-code
✓ managing-databases

✗ helper, utils, tools (vague)
✗ documents, data, files (generic)
✗ anthropic-helper, claude-tools (reserved)
```

Acceptable alternatives: noun phrases (`pdf-processing`), action-oriented (`process-pdfs`).

---

## 7. Bundled Resources

### scripts/ — Executable Code

**When:** Same code rewritten repeatedly, deterministic reliability needed.

```
scripts/
├── rotate_pdf.py
├── validate_form.py
└── extract_text.py
```

**Benefits:**
- Token efficient (executed without loading)
- Deterministic (no generation variance)
- Consistent across uses

**Quality requirements for scripts:**

Before including a script in your Skill:

1. **Tested** — Script must execute without errors on expected inputs
2. **Explicit error handling** — Script must catch and report errors clearly
   ```python
   # GOOD - explicit error handling
   try:
       with pdfplumber.open(input_file) as pdf:
           text = pdf.pages[0].extract_text()
   except FileNotFoundError:
       print(f"Error: File not found: {input_file}")
       exit(1)
   except Exception as e:
       print(f"Error extracting PDF: {e}")
       exit(1)
   ```
3. **Documented inputs/outputs** — Comments explaining what the script does
4. **Exit codes** — Use non-zero exit codes to signal failure (don't let errors silently pass)
5. **No side effects** — Script should not modify files outside its intended scope

**Anti-pattern: Don't punt errors to Claude**
```python
# BAD - Claude has to fix the error
with pdfplumber.open(input_file) as pdf:
    text = pdf.pages[0].extract_text()  # Dies silently if file missing
```

**In SKILL.md, distinguish intent:**
```markdown
# Execute (most common)
Run `python scripts/validate.py input.pdf`

# Read as reference (rare, for complex logic)
See `scripts/validate.py` for the validation algorithm
```

### references/ — Context-Loaded Documentation

**When:** Documentation Claude should reference while working.

```
references/
├── schema.md       # Database schemas
├── api.md          # API specifications
├── policies.md     # Company rules
└── patterns.md     # Domain patterns
```

**Design pattern for multi-domain:**
````markdown
# In SKILL.md
## Available datasets
- **Finance**: Revenue, ARR → See [references/finance.md](references/finance.md)
- **Sales**: Pipeline, accounts → See [references/sales.md](references/sales.md)

## Quick search
```bash
grep -i "revenue" references/finance.md
```
````

**Large files (>10k words):** Include grep patterns in SKILL.md for targeted access.

### assets/ — Output Files (Not Loaded)

**When:** Files used in output, not instruction context.

```
assets/
├── logo.png
├── template.pptx
├── font.ttf
└── boilerplate/
```

Claude references by path, copies/modifies—never loads into context.

---

## 8. Workflow Patterns

### Checklist Pattern (Complex Multi-Step)

```markdown
## Form filling workflow

Copy and track progress:
```
- [ ] Step 1: Analyze form (run analyze_form.py)
- [ ] Step 2: Create field mapping (edit fields.json)
- [ ] Step 3: Validate mapping (run validate_fields.py)
- [ ] Step 4: Fill form (run fill_form.py)
- [ ] Step 5: Verify output (run verify_output.py)
```

**Step 1: Analyze the form**
Run: `python scripts/analyze_form.py input.pdf`
```

### Feedback Loop Pattern (Quality-Critical)

```markdown
## Validation loop

1. Make edits to document
2. **Validate immediately**: `python scripts/validate.py output/`
3. If validation fails:
   - Review error message
   - Fix issues
   - Run validation again
4. **Only proceed when validation passes**
```

### Conditional Workflow Pattern

```markdown
## Document modification

1. Determine type:
   - **Creating new?** → Follow "Creation workflow"
   - **Editing existing?** → Follow "Editing workflow"

2. Creation workflow:
   - Use docx-js library
   - Build from scratch

3. Editing workflow:
   - Unpack existing document
   - Modify XML directly
```

### Template Pattern

````markdown
## Report structure

ALWAYS use this template:

```markdown
# [Analysis Title]

## Executive summary
[One-paragraph overview]

## Key findings
- Finding 1 with data
- Finding 2 with data

## Recommendations
1. Actionable recommendation
```
````

### Don't/Do Format Pattern (Simple Rules)

For quick, scannable guidance on what to avoid vs. what to do, use the **Don't/Do format** with emoji bullets. This is more readable than tables for simple binary decisions.

**When to use:**
- Listing 3-7 simple pairs of practices
- Rules that are straightforward (not nuanced)
- Skills where context-aware lookup is priority

**Example:**

```markdown
## Best practices summary

❌ **Don't:**
- Use barrel imports from large libraries
- Block parallel operations with sequential awaits
- Re-render entire trees when only part needs updating
- Load analytics in the critical path

✅ **Do:**
- Import directly from source files
- Use Promise.all() for independent operations
- Memoize expensive components
- Lazy-load non-critical code
```

**Key differences from Anti-Patterns tables:**

| Use Case | Format | When |
|----------|--------|------|
| **Simple binary rules** | Don't/Do bullets | 3-7 pairs, straightforward |
| **Complex patterns** | Anti-Pattern tables | 5+ items with "Why Bad" + "Fix" |
| **Nuanced guidance** | Detailed sections | Requires explanation/context |

**Recommendation:** Use Don't/Do format in "Quick Reference" or "Best Practices Summary" sections for maximum scannability. Use tables in "Anti-Patterns" sections for deeper analysis.

---

## 9. Anti-Patterns (Avoid)

### Don't Include
- README.md, CHANGELOG.md, INSTALLATION_GUIDE.md
- User-facing documentation
- Setup/testing procedures
- Auxiliary context about creation process

Skills are **for AI agents**, not humans.

### Don't Do

| Anti-Pattern | Why Bad | Fix |
|-------------|---------|-----|
| Windows paths (`scripts\helper.py`) | Breaks on Unix | Use forward slashes |
| Deeply nested references | Claude partial-reads | One level deep only |
| Time-sensitive info | Becomes wrong | Use "old patterns" section |
| Too many options | Confusing | Provide default + escape hatch |
| Vague descriptions | Never triggers | Specific + trigger phrases |
| Inconsistent terminology | Confuses Claude | Pick one term, use throughout |
| Magic numbers | Unverifiable | Document why each value |
| Error punt to Claude | Unreliable | Handle explicitly in scripts |

### Bad: Multiple Options Without Default
```markdown
# BAD
"You can use pypdf, or pdfplumber, or PyMuPDF, or pdf2image..."

# GOOD
"Use pdfplumber for text extraction:
[code]
For scanned PDFs requiring OCR, use pdf2image with pytesseract instead."
```

---

## 10. Security & Permissions

### Tool Scoping

```yaml
allowed-tools: Read,Write,Bash(git:*)
```

**Principle of least privilege:** Only include tools the skill actually needs. `Bash(pdftotext:*)` not `Bash(*)`.

### Path Portability

```markdown
# GOOD - portable
{baseDir}/scripts/validate.py

# BAD - hardcoded
/Users/alice/skills/pdf/scripts/validate.py
```

`{baseDir}` auto-resolves to skill installation directory.

---

## 11. Testing & Iteration

### Development Process

1. **Complete task without skill** — Note what context you repeatedly provide
2. **Identify reusable pattern** — What would help future similar tasks?
3. **Create minimal skill** — Just enough to address gaps
4. **Test with fresh Claude instance** — Does it find right info? Apply rules correctly?
5. **Iterate based on observation** — What did it miss? What confused it?

### Testing Checklist

```
□ Description triggers on expected phrases
□ Description doesn't trigger on unrelated requests
□ Works with Haiku (needs more guidance?)
□ Works with Opus (over-explained?)
□ Scripts execute without error
□ Reference files load when expected
□ Validation loops catch errors
□ Real-world usage scenarios pass
```

### Evaluation Structure

```json
{
  "skills": ["pdf-processing"],
  "query": "Extract all text from this PDF and save to output.txt",
  "files": ["test-files/document.pdf"],
  "expected_behavior": [
    "Reads PDF using appropriate library",
    "Extracts text from all pages",
    "Saves to output.txt in readable format"
  ]
}
```

---

## 12. Organization Patterns by Complexity

### Simple Skill (Single Task)

```
image-rotate/
├── SKILL.md
└── scripts/
    └── rotate.py
```

### Medium Skill (Multiple Features)

```
pdf-processing/
├── SKILL.md
├── scripts/
│   ├── extract_text.py
│   ├── fill_form.py
│   └── validate.py
└── references/
    ├── FORMS.md
    └── API.md
```

### Complex Skill (Multi-Domain)

```
bigquery-analysis/
├── SKILL.md                    # Overview + domain selection
├── scripts/
│   └── query_runner.py
└── references/
    ├── finance.md              # Revenue, ARR, billing
    ├── sales.md                # Pipeline, opportunities
    ├── product.md              # Usage, features
    └── marketing.md            # Campaigns, attribution
```

---

## 13. Frontmatter Optional Fields

Beyond required `name`/`description`:

| Field | Effect | Example |
|-------|--------|---------|
| `allowed-tools` | Scoped permissions (principle of least privilege) | `Read,Write,Bash(git:*)` |
| `model` | Override session model (`inherit` = use current) | `model: inherit` or `model: opus` |
| `user-invocable: false` | Hide from slash menu, allow programmatic only | `user-invocable: false` |
| `mode: true` | Categorize as "Mode Command" | `mode: true` |
| `version` | Track skill evolution (optional, for documentation) | `version: 1.0.0` |

### Tool Scoping Examples

Apply **principle of least privilege**: only grant tools the Skill actually needs.

```yaml
# Example 1: PDF processing skill (needs file operations)
---
name: pdf-processing
allowed-tools: Read,Write,Bash(python:*)
---

# Example 2: Git workflow skill (needs git commands only)
---
name: git-workflow-helper
allowed-tools: Bash(git:*)
---

# Example 3: Analysis skill (read-only access)
---
name: code-analyzer
allowed-tools: Read,Bash(grep:*,ls:*)
---

# Example 4: Web documentation generator (needs network + file ops)
---
name: doc-generator
allowed-tools: Read,Write,Bash(curl:*,python:*)
---
```

**Key patterns:**
- Specify exact commands: `Bash(git:*)` not `Bash(*)`
- Combine related tools: `Read,Write` for file operations
- Avoid broad permissions: never use `Bash(*)` unless truly needed
- For production/shared skills: err on side of fewer permissions

### allowed-tools Specification

The `allowed-tools` field restricts which tools Claude can use when your Skill is active. When tools are listed, Claude can use them without requesting permission.

**Supported Syntax Formats:**

Comma-separated (inline):
```yaml
allowed-tools: Read,Grep,Glob
```

YAML list (recommended for readability):
```yaml
allowed-tools:
  - Read
  - Grep
  - Glob
```

**Available Tools** (case-sensitive):
- `Read` — Read files
- `Write` — Write/create files
- `Edit` — Edit file content
- `Bash(pattern:*)` — Execute specific bash commands
- `Grep` — Search file contents
- `Glob` — Find files by pattern
- `Task` — Launch specialized agents
- `Skill` — Invoke other skills

**Implementation Details:**
- `allowed-tools` is **only supported in Claude Code CLI** (not SDK)
- If omitted, no tool restrictions apply (Claude uses standard permission model)
- When specified, Claude can use those tools without asking for permission
- Case-sensitive: `Read` not `read`
- Wildcard filtering: `Bash(git:*)` allows all git commands, `Bash(python:*)` allows python only

**Tool Filtering Examples:**

```yaml
# Git commands only
allowed-tools: Bash(git:*)

# Python execution + file operations
allowed-tools: Read,Write,Bash(python:*)

# Multiple bash commands (comma-separated inside parentheses)
allowed-tools: Bash(grep:*,ls:*,find:*)

# Combined: bash + built-in tools
allowed-tools: Read,Glob,Bash(curl:*,wget:*)
```

**Why allowed-tools Matters:**
- **Security**: Prevent unintended tool use in sensitive workflows
- **Clarity**: Document which tools your skill depends on
- **Best practice**: Signal principle of least privilege to teams

### Version Field (Optional)

Track skill evolution for team coordination:

```yaml
---
name: skill-creator
version: 1.0.0
---
```

Then document in a "Version history" section:
```markdown
## Version history

**v1.0.0** (January 2026)
- Initial release
- Create workflow implemented
- Comprehensive checklist

**v0.9.0** (December 2025)
- Beta release
```

Not required, but helpful for:
- Team communication ("which version are you using?")
- Deprecation notices ("v1.x is deprecated, use v2.x")
- Release notes

---

## 14. MCP Tool References

When using MCP tools, **always use fully qualified names**:

```markdown
# GOOD
Use the BigQuery:bigquery_schema tool to retrieve schemas.

# BAD - may fail
Use the bigquery_schema tool...
```

Format: `ServerName:tool_name`

---

## 15. Content Guidelines

### Consistent Terminology

Pick one term, use it everywhere:

```
✓ Always "API endpoint" (not "URL", "route", "path")
✓ Always "field" (not "box", "element", "control")
✓ Always "extract" (not "pull", "get", "retrieve")
```

### Time-Sensitive Information

```markdown
# BAD
If before August 2025, use old API. After August 2025, use new API.

# GOOD
## Current method
Use v2 API: `api.example.com/v2/messages`

<details>
<summary>Legacy v1 API (deprecated 2025-08)</summary>
The v1 API used: `api.example.com/v1/messages`
No longer supported.
</details>
```

### Examples Over Explanations

```markdown
## Commit message format

**Example 1:**
Input: Added user authentication with JWT
Output:
```
feat(auth): implement JWT-based authentication

Add login endpoint and token validation middleware
```

**Example 2:**
Input: Fixed date display bug in reports
Output:
```
fix(reports): correct date formatting in timezone conversion
```

Follow this style: type(scope): brief description, then details.
```

---

## 16. Quick Reference Card

```
SKILL CHECKLIST
═══════════════════════════════════════════════════════════════

□ name: lowercase, hyphens, ≤64 chars
□ description: third person, specific triggers, ≤1024 chars
□ SKILL.md body: <500 lines
□ References: one level deep from SKILL.md
□ Long refs: include TOC
□ Scripts: tested, explicit error handling
□ No magic numbers (all values justified)
□ Forward slashes only (no Windows paths)
□ No extraneous docs (README, CHANGELOG, etc.)
□ Consistent terminology throughout
□ Examples concrete, not abstract
□ Tested with real usage scenarios

DESCRIPTION TEMPLATE
═══════════════════════════════════════════════════════════════
description: >-
  [What it does - actions, capabilities].
  Use when [trigger phrases, contexts, file types, user intents].

PROGRESSIVE DISCLOSURE TEMPLATE
═══════════════════════════════════════════════════════════════
## Quick start
[Essential example - <50 lines]

## Features
- **Feature A**: See [A.md](references/A.md)
- **Feature B**: See [B.md](references/B.md)

## Quick search
```bash
grep -i "keyword" references/
```
```

---

## 17. Advanced Patterns from Production Skills

Learnings from real-world skill collections (Dicklesworthstone's Agent Flywheel stack):

### 17.1 "THE EXACT PROMPT" Pattern

Encode reproducible prompts in all-caps sections for agent-to-agent handoff:

````markdown
## THE EXACT PROMPT — Plan Review

```
Carefully review this entire plan for me and come up with your best
revisions in terms of better architecture, new features...
```
````

**Why it works:**
- Prompts are copy-paste ready
- Stream Deck / automation friendly
- No ambiguity about phrasing
- Enables cross-model workflows (GPT Pro → Claude Code)

### 17.2 "Why This Exists" Section

Front-load motivation before instructions:

```markdown
## Why This Exists

Managing multiple AI coding agents is painful:
- **Window chaos**: Each agent needs its own terminal
- **Context switching**: Jumping between windows breaks flow
- **No orchestration**: Same prompt to multiple agents = manual copy-paste

NTM solves all of this...
```

Helps Claude understand when to apply the skill contextually.

### 17.3 Integration Sections

Complex tools should document ecosystem connections:

```markdown
## Integration with Flywheel

| Tool | Integration |
|------|-------------|
| **Agent Mail** | Message routing, file reservations |
| **BV** | Work distribution, triage |
| **CASS** | Search past sessions |
| **DCG** | Safety system integration |
```

### 17.4 Risk Tiering Tables

For safety/security skills, use explicit tier classifications:

```markdown
| Tier | Approvals | Auto-approve | Examples |
|------|-----------|--------------|----------|
| **CRITICAL** | 2+ | Never | `rm -rf /`, `DROP DATABASE` |
| **DANGEROUS** | 1 | Never | `git reset --hard` |
| **CAUTION** | 0 | After 30s | `rm file.txt` |
| **SAFE** | 0 | Immediately | `rm *.log` |
```

### 17.5 Robot Mode / Machine-Readable Output

For orchestration tools, document JSON/NDJSON APIs:

````markdown
## Robot Mode (AI Automation)

```bash
ntm --robot-status              # Sessions, panes, agent states
ntm --robot-snapshot            # Unified state: sessions + beads + mail
```

Output format:
```json
{"type":"request_pending","request_id":"abc123","tier":"dangerous"}
```
````

### 17.6 Exit Code Standardization

```markdown
## Exit Codes

| Code | Meaning |
|------|---------|
| `0` | Success |
| `1` | Error |
| `2` | Invalid arguments / Unavailable |
| `3` | Not found |
| `4` | Permission denied |
| `5` | Timeout |
```

### 17.7 ASCII State Diagrams

Visualize complex flows:

```markdown
### Processing Pipeline

```
┌─────────────────┐
│   Claude Code   │  Agent executes command
└────────┬────────┘
         │
         ▼ PreToolUse hook (stdin: JSON)
┌─────────────────┐
│      dcg        │
│  ┌──────────┐   │
│  │  Parse   │──▶│ Normalize ──▶ Quick Reject
│  └──────────┘   │
└────────┬────────┘
         │
         ▼ stdout: JSON (deny) or empty (allow)
```
```

### 17.8 Hierarchical Configuration Documentation

```markdown
## Configuration

Configuration precedence (lowest to highest):
1. Built-in defaults
2. User config (`~/.config/tool/config.toml`)
3. Project config (`.tool/config.toml`)
4. Environment variables (`TOOL_*`)
5. Command-line flags
```

### 17.9 "Use ultrathink" Convention

For complex prompts, append thinking mode instructions:

```markdown
...hyper-optimize for both separately to play to the specifics of
each modality. Use ultrathink.
```

Signals to Claude to use extended thinking for thorough analysis.

### 17.10 Iteration Protocols

For refinement workflows, specify iteration counts:

```markdown
### Repeat Until Steady-State

- Start fresh conversations for each round
- After 4-5 rounds, suggestions become very incremental
```

---

## 18. Common Skill Archetypes

### 18.1 CLI Reference Skill (github, gcloud, vercel)

**Structure:**
```markdown
# Tool Name Skill

## Authentication
[auth commands]

## Core Operations
[main commands grouped by function]

## Common Workflows
[multi-step recipes]
```

**Token efficiency:** Pure reference, minimal prose. Claude already knows CLI semantics.

### 18.2 Methodology Skill (planning-workflow, de-slopify)

**Structure:**
```markdown
# Methodology Name

> **Core Philosophy:** [one-liner insight]

## Why This Matters
[brief motivation]

## THE EXACT PROMPT
[copy-paste ready prompt]

## Why This Prompt Works
[technical breakdown]

## Before/After Examples
[concrete demonstrations]
```

### 18.3 Safety Tool Skill (dcg, slb)

**Structure:**
```markdown
# Tool Name

## Why This Exists
[threat model]

## Critical Design Principles
[architecture decisions]

## What It Blocks / Allows
[tables of patterns]

## Modular System
[extensibility]

## Security Considerations
[limitations, threat model assumptions]
```

### 18.4 Orchestration Tool Skill (ntm, agent-mail)

**Structure:**
```markdown
# Tool Name

## Why This Exists
[pain points solved]

## Quick Start
[minimal viable usage]

## Core Commands
[organized by function]

## Robot Mode
[machine-readable APIs]

## Integration with Ecosystem
[connections to other tools]
```

---

## 19. Production Patterns from Real-World Skills

Learnings synthesized from analyzing production skills (React Best Practices, Vercel Engineering):

### 19.1 Impact/Priority Tiering (Optional)

Explicitly categorize content by impact level to guide Claude on prioritization:

```markdown
## Quick reference

### Critical priorities (CRITICAL)
Rules that block performance or cause failures. Always apply.
- Rule 1
- Rule 2

### High impact (HIGH)
Significant performance gains. Prioritize these.
- Rule 3
- Rule 4

### Medium impact (MEDIUM)
Good optimizations for specific scenarios.
- Rule 5

### Low impact (LOW)
Micro-optimizations for hot paths.
- Rule 6
```

**Why this works:**
- Helps Claude understand what matters most
- Allows flexible application based on context
- Makes trade-off decisions explicit
- Signals degrees of freedom per tier

**Recommendation:** Use for optimization, performance, and safety-critical skills. Pair with degrees of freedom principle (section 4.3).

### 19.2 Implementation Approach Pattern

For process-oriented and methodology skills, provide a numbered step-by-step approach showing **how to apply the skill itself**:

```markdown
## Implementation approach

When using this skill:

1. **Profile first** — Measure baselines before optimizing
2. **Focus on critical path** — Start with highest-impact items
3. **Measure impact** — Verify improvements with metrics
4. **Apply incrementally** — Don't over-optimize prematurely
5. **Test thoroughly** — Ensure optimizations maintain functionality
```

**Why this works:**
- Reduces ambiguity about how to use the skill
- Provides structure for practical application
- Helps Claude understand the workflow
- Makes the skill actionable, not just theoretical

**When to use:** Optimization skills, workflows, methodologies, processes.

### 19.3 Outcome Metrics Pattern

Connect abstract rules to concrete, measurable results:

```markdown
## Key metrics to track

- **Time to Interactive (TTI)**: Measure page interactivity
- **Largest Contentful Paint (LCP)**: When main content is visible
- **Bundle Size**: Initial JavaScript payload (target: <50KB)
- **Server Response Time**: TTFB for server-rendered content
```

**Why this works:**
- Shows why following the guidance matters
- Provides success criteria
- Enables before/after comparisons
- Makes abstract principles concrete

**When to use:** Especially valuable for optimization, performance, and technical skills.

### 19.4 Version History Guidance

Track skill evolution in a footer section:

```markdown
## Version history

**v1.0.0** (January 2026)
- Initial release: 40+ rules across 8 categories
- Comprehensive code examples

**v0.9.0** (December 2025)
- Beta: Community feedback incorporated
```

**Why this works:**
- Signals maintenance and evolution
- Helps understand recency of content
- Enables version-specific discussions
- Shows the skill is actively maintained

**When to use:** Optional for skills; recommended for complex, evolving skills.

**Optional frontmatter:**
```yaml
---
name: skill-name
version: 1.0.0
---
```

### 19.5 Quick Reference Ordering (Emphasis)

Always lead with actionable essentials before theory:

```markdown
# Skill Name

## Quick reference
[3-5 critical rules with code examples]

## Common patterns
[3-4 concrete, copy-paste ready examples]

## Detailed categories
[Organized by impact/priority/complexity]

## Advanced features
[Deep dives and edge cases]
```

**Why this matters:** Actionable content first reduces context window bloat. Quick reference patterns solve 80% of task variants without loading auxiliary files. Detailed sections and references available when Claude needs them for edge cases.

**Critical ordering rule:** Actionable content first, theory second.

---

## 20. Skills for Shared Teams & Production Environments

When creating Skills for shared teams (vs. personal use), additional rigor is required. These Skills may be used by team members with varying technical expertise, in critical workflows, and with production data.

### Escalated Requirements

**For team/production Skills:**

| Requirement | Personal Skills | Team Skills | Why |
|-------------|-----------------|-------------|-----|
| **Error handling** | Best effort | Required | Errors must be clear, not silent failures |
| **Testing** | Informal | Required | Team depends on reliability |
| **Documentation** | Minimal | Comprehensive | Team members unfamiliar with context |
| **Tool scoping** | Lenient | Strict | Minimize blast radius of malicious use |
| **Version tracking** | Optional | Recommended | Team coordination and rollbacks |
| **Validation script** | Optional | Recommended | Team can verify skill works before use |
| **Security review** | Self-review | Peer review | Catch edge cases and vulnerabilities |

### Error Handling (Critical)

Team Skills must handle failures gracefully and report them clearly.

**Script requirements:**
- Try/except blocks around all risky operations
- Clear error messages (not stack traces)
- Non-zero exit codes on failure
- Validation before execution

```python
# Example: Robust PDF text extraction

import pdfplumber
import sys

def extract_text(pdf_path):
    """Extract text from PDF file."""
    try:
        if not pdf_path.endswith('.pdf'):
            print(f"Error: Not a PDF file: {pdf_path}", file=sys.stderr)
            return 1

        with pdfplumber.open(pdf_path) as pdf:
            text = "\n---PAGE BREAK---\n".join(
                page.extract_text() for page in pdf.pages
            )

        print(text)
        return 0

    except FileNotFoundError:
        print(f"Error: PDF file not found: {pdf_path}", file=sys.stderr)
        return 1
    except Exception as e:
        print(f"Error extracting PDF: {e}", file=sys.stderr)
        return 1

if __name__ == "__main__":
    sys.exit(extract_text(sys.argv[1]))
```

### Tool Scoping (Security)

Apply principle of least privilege strictly.

```yaml
# Team skill: minimal permissions
---
name: team-pdf-processor
allowed-tools: Read,Write,Bash(python:*)
description: >-
  Process PDF files as a team. Limited to file I/O and Python execution only.
---
```

**Security checklist:**
- [ ] Only needed tools included
- [ ] No `Bash(*)` (too broad)
- [ ] No network access unless required (`curl`, `wget` only if necessary)
- [ ] Scripts validated for safe execution
- [ ] File operations scoped to specific paths/extensions

### Validation Script (Optional but Recommended)

Create a simple validation script team members can run:

```bash
#!/bin/bash
# validate-team-skill.sh

echo "Testing pdf-processor skill..."

# Test 1: Check PDF extraction works
python scripts/extract_text.py test-files/sample.pdf > /dev/null
if [ $? -eq 0 ]; then
    echo "✓ PDF extraction works"
else
    echo "✗ PDF extraction failed"
    exit 1
fi

# Test 2: Check error handling
python scripts/extract_text.py nonexistent.pdf 2>&1 | grep -q "not found"
if [ $? -eq 0 ]; then
    echo "✓ Error handling works"
else
    echo "✗ Error handling failed"
    exit 1
fi

echo "All tests passed!"
```

Then document in SKILL.md (example content):

````markdown
## Validate this skill

Run the validation script to verify the skill works in your environment:

```bash
bash validate-team-skill.sh
```

Should output all tests passed before using in production.
````

### Security Review Checklist for Team Skills

Before sharing with team:

- [ ] All scripts tested and validated
- [ ] Error handling covers failure cases
- [ ] Tool scoping is minimal (least privilege)
- [ ] No hardcoded paths or credentials
- [ ] No external API calls to untrusted sources
- [ ] File operations safely scoped
- [ ] Error messages are user-friendly (no stack traces)
- [ ] Documentation is complete for team members

### Documentation for Team Skills

Include sections that personal Skills don't need:

```markdown
# PDF Processor

## Overview
[What the skill does]

## Prerequisites
- Python 3.8+
- pdfplumber library (installed via script)

## Quick Start
[3-5 step usage example]

## Common Workflows
- Extract text from single PDF
- Batch process multiple PDFs
- Extract specific pages

## Troubleshooting

### Error: "PDF file not found"
**Cause:** Path to PDF is incorrect or file doesn't exist
**Solution:** Check file path and verify file exists

### Error: "pdfplumber not installed"
**Cause:** Dependencies not set up
**Solution:** Run `pip install pdfplumber`

## Support
Contact: @team-lead or create issue in team repo

## Changelog
See VERSION_HISTORY.md
```

### Testing for Team Skills

Use the Testing Checklist from section 11, with added rigor:

```
Testing for Team Skills:
□ Description triggers on expected phrases
□ Description doesn't trigger on unrelated requests
□ Works with Haiku (simpler model)
□ Works with Opus (complex model)
□ Scripts execute without error on test data
□ Error handling catches common failures
□ Reference files load when expected
□ Validation loops catch errors
□ Real-world usage scenarios pass
□ Scripts work on team member machines (test on >1 OS)
□ Error messages are clear and actionable
□ No security issues found in peer review
```

---

## Sources

- [Skill Authoring Best Practices - Anthropic Docs](https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices)
- [Agent Skills - Claude Code Docs](https://code.claude.com/docs/en/skills)
- [anthropics/skills Repository](https://github.com/anthropics/skills)
- [Claude Skills Deep Dive - Lee Han Chung](https://leehanchung.github.io/blogs/2025/10/26/claude-skills-deep-dive/)
- [Claude Code Customization Guide - alexop.dev](https://alexop.dev/posts/claude-code-customization-guide-claudemd-skills-subagents/)
- [Claude Skills & CLAUDE.md Guide - gend.co](https://www.gend.co/blog/claude-skills-claude-md-guide)
- Dicklesworthstone Agent Flywheel Skills Collection (real-world patterns)

---

## Core Philosophy

**"Context window = public good"** — Every token must justify its cost through genuine value to Claude's task execution. Skills should assume Claude's baseline intelligence and only provide domain-specific knowledge and procedural guidance.