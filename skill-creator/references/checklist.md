# Skill Validation Checklist

Use this checklist to validate new or improved skills against best practices.

## Table of Contents
- [Frontmatter Validation](#frontmatter-validation)
- [Structure Validation](#structure-validation)
- [Path and Code Validation](#path-and-code-validation)
- [Content Quality](#content-quality)
- [Design Principles](#design-principles)
- [Description Quality](#description-quality)
- [Testing Checklist](#testing-checklist)
- [Team & Production Skills](#team--production-skills)
- [Security & Permissions](#security--permissions)
- [Common Issues Checklist](#common-issues-checklist)
- [Final Sign-Off](#final-sign-off)

## Frontmatter Validation

### Required Fields
- [ ] `name`: Present and non-empty
- [ ] `description`: Present and non-empty
- [ ] Valid YAML syntax (triple dashes: `---`)

### Name Validation
- [ ] Lowercase only (no capitals)
- [ ] Hyphens only (no underscores, spaces, dots)
- [ ] ≤64 characters
- [ ] No reserved words ("anthropic", "claude")
- [ ] Action-oriented when possible (gerund form: `processing-pdfs`, `managing-databases`)

### Description Validation
- [ ] ≤1024 characters
- [ ] Third person voice ("Processes files", not "I can help you")
- [ ] Includes specific trigger phrases (what it does AND when to use)
- [ ] No XML/HTML tags
- [ ] No empty content

**Example template:**
```
[What it does]. Use when [trigger contexts]. [Optional scope/constraints].
```

## Structure Validation

### File Organization
- [ ] Required: `SKILL.md` with frontmatter and body
- [ ] Optional: `scripts/` directory with executable code
- [ ] Optional: `references/` directory with documentation
- [ ] Optional: `assets/` directory with output files
- [ ] No extraneous files: no README.md, CHANGELOG.md, INSTALLATION_GUIDE.md
- [ ] No deeply nested structures (references/ is one level deep only)

### SKILL.md Body
- [ ] <500 lines total
- [ ] Code-first: examples before theory
- [ ] Progressive disclosure: essentials → workflows → advanced
- [ ] Imperative style: "Do X", "Run Y", "Configure Z"
- [ ] Includes Quick Start or Quick Reference section
- [ ] Links to reference files with clear context

### Reference Files
- [ ] **One level deep only** (critical: no chains like SKILL.md → guide.md → details.md)
  - Why: Claude may partial-read nested files, missing critical context
- [ ] Files >100 lines include table of contents at top
- [ ] Clear filenames: semantic + specific (`checklist.md`, `api-reference.md`, `patterns.md`)
  - Avoid generic: `reference.md`, `guide.md`, `config.md` (unclear scope)
- [ ] No empty reference files
- [ ] Organized by task/priority/impact when multiple sections

## Path and Code Validation

### Paths
- [ ] Forward slashes only (no Windows paths like `scripts\helper.py`)
- [ ] Relative paths work across systems
- [ ] {baseDir} used for portability when needed

### Scripts (if included)

**Quality Requirements (Non-negotiable):**
- [ ] **Tested** — Script executes without errors on expected inputs
- [ ] **Explicit error handling** — Try/except blocks around risky operations
- [ ] **Clear error messages** — User-friendly output (not stack traces)
- [ ] **Non-zero exit codes** — Failures signal with exit code 1 or higher
- [ ] **No silent failures** — Every error case is caught and reported

**Code Example: Robust error handling**
```python
try:
    result = perform_operation()
except FileNotFoundError:
    print(f"Error: File not found", file=sys.stderr)
    exit(1)
except Exception as e:
    print(f"Error: {e}", file=sys.stderr)
    exit(1)
```

**Additional requirements:**
- [ ] Clear documentation on what the script does
- [ ] Input/output clearly documented
- [ ] No hardcoded paths (use command-line args)
- [ ] Executable permissions set (if shell script)

**For team/production skills:**
- [ ] Validation script included (bash script that tests the skill)
- [ ] Scripts tested on multiple environments (>1 OS if applicable)

### Code Examples
- [ ] Concrete (real examples, not placeholder names)
- [ ] Runnable (code can be executed as-is)
- [ ] No magic numbers (all values explained)
- [ ] Language-appropriate syntax highlighting

## Content Quality

### Language & Terminology
- [ ] Consistent terminology throughout (pick one term, use everywhere)
- [ ] No ambiguous pronouns or vague references
- [ ] Technical accuracy verified
- [ ] Examples concrete, not abstract

### Readability
- [ ] Headings are clear and hierarchical
- [ ] Sections are scannable (use bullet points, tables, code blocks)
- [ ] Key information highlighted or emphasized
- [ ] Tables use consistent formatting

### Information Accuracy
- [ ] No time-sensitive information (or marked as deprecated)
- [ ] No outdated API references
- [ ] Version-specific guidance clearly marked
- [ ] Links check out (if external references included)

### Token Efficiency

Context window is a shared resource—optimize ruthlessly.

**Metrics to target:**
- [ ] Metadata (Level 1): ~100 tokens
- [ ] SKILL.md body (Level 2): 1,500-5,000 tokens
- [ ] Quick Start section: <100 tokens (should solve 80% of tasks)

**Optimization checklist:**
- [ ] Code examples before prose (1 example ~50 tokens beats 3 paragraphs ~150 tokens)
- [ ] Tables used for structured data (compresses better than lists)
- [ ] Reference files used for detailed content (not duplicated in SKILL.md)
- [ ] No tutorials (assume Claude knows basics)
- [ ] No explanations of obvious things
- [ ] Advanced/edge cases deferred to references/
- [ ] Each line challenged: "Does Claude need this?"

**Example: Bloat vs Efficiency**
````markdown
# BLOATED (~150 tokens)
PDFs are documents with text and images. To extract text, you need a library.
Libraries available include pdfplumber, PyPDF2, and others. Each has
trade-offs in features and speed...

# EFFICIENT (~50 tokens)
Extract PDF text using pdfplumber:
```python
import pdfplumber
with pdfplumber.open("file.pdf") as pdf:
    text = pdf.pages[0].extract_text()
```
For form filling, see references/FORMS.md
````

## Design Principles

### Progressive Disclosure
- [ ] Quick Start or Quick Reference first (3-5 essential items with code)
- [ ] Common patterns next (3-4 concrete examples)
- [ ] Detailed sections after basics
- [ ] Advanced features/references at the end
- [ ] No critical information buried in later sections

### Actionable First
- [ ] Code examples before explanations
- [ ] Quick reference available without reading full docs
- [ ] Can solve 80% of tasks with Quick Start alone
- [ ] Reference files loaded only when needed

### Degrees of Freedom
- [ ] Specificity matches task fragility
  - Low freedom (fragile): Exact commands, no flags (DB migrations)
  - Medium freedom: Preferred pattern with some variation (templates)
  - High freedom: Multiple valid approaches (code review guidelines)
- [ ] Default approach provided when multiple options exist
- [ ] Escape hatches documented for edge cases

## Description Quality

### Discovery & Activation
- [ ] Description clearly states what the skill does (action/capability)
- [ ] Includes specific trigger phrases (not just generic words)
- [ ] Would trigger on expected user queries (test mentally)
- [ ] Would NOT trigger on unrelated requests
- [ ] Discoverable by synonyms users might use

### Examples of Good Descriptions
✅ "Analyze Excel spreadsheets, create pivot tables, generate charts. Use when analyzing Excel files, spreadsheets, tabular data, or .xlsx files."

✅ "Generate descriptive commit messages by analyzing git diffs. Use when user asks for help writing commit messages or reviewing staged changes."

✅ "Create Claude Code skills following best practices. Use when building new skills, validating existing skills, or improving skill quality."

### Examples of Poor Descriptions
❌ "Helps with documents" — too vague, no triggers
❌ "Processes data" — generic, no action clarity
❌ "Does stuff with files" — no actionable content

## Testing Checklist

### Functional Testing
- [ ] Description triggers on expected user phrases
- [ ] Description doesn't trigger on unrelated requests
- [ ] Skill works with minimal context (fresh conversation)
- [ ] Scripts execute without error (if applicable)
- [ ] Reference files load when expected
- [ ] Examples in SKILL.md can be followed step-by-step

### Real-World Usage Testing
- [ ] Tested with Haiku model (needs clear guidance?)
- [ ] Tested with Opus model (over-explained?)
- [ ] Works with actual user files/data types
- [ ] Handles edge cases mentioned in skill docs
- [ ] Error messages are clear if something fails

### Validation Loops
- [ ] Validation feedback is actionable
- [ ] Errors caught are actually important
- [ ] No false positives (validation passes legitimate use cases)
- [ ] No excessive validation (doesn't block valid operations)

## Team & Production Skills (Optional)

If creating skills for shared team use:

### Requirements for Team Skills
- [ ] **Error handling**: Robust try/except blocks, clear error messages
- [ ] **Testing**: All scripts tested before deployment
- [ ] **Documentation**: Complete (Overview, Prerequisites, Troubleshooting, Support)
- [ ] **Tool scoping**: Strict principle of least privilege
- [ ] **Version tracking**: Optional but recommended for coordination
- [ ] **Validation script**: Team can verify skill works
- [ ] **Security review**: Peer review before sharing
- [ ] **Peer testing**: Tested on >1 team member's machine

### Team Skill Checklist
- [ ] Prerequisites clearly listed
- [ ] Error messages are user-friendly (not stack traces)
- [ ] Troubleshooting section covers common issues
- [ ] Support contact/channel documented
- [ ] Scripts have no hardcoded paths or credentials
- [ ] Scripts work across different environments
- [ ] No external API calls to untrusted sources
- [ ] File operations safely scoped

---

## Security & Permissions

### Tool Scoping
- [ ] Only required tools are included (principle of least privilege)
- [ ] No overly broad permissions (`Bash(*)`)
- [ ] If `Bash` included: scope to specific commands (`Bash(git:*)`)
  - Example: `Read,Write,Bash(python:*)` for Python skill
  - Example: `Bash(git:*)` for git-only skill
- [ ] No hardcoded paths or credentials
- [ ] Safe defaults (read-only when possible)

### User Safety
- [ ] Destructive operations are warned/confirmed
- [ ] No silent modifications to user files
- [ ] Clear what the skill will do before executing
- [ ] Explicit steps for irreversible operations

## Self-Containment

### Core Principle
- [ ] **Skill is self-contained** — No external references, network dependencies, or resources that must be downloaded (see `self-containment-principle.md`)
- [ ] **All referenced files exist** — Every file mentioned in SKILL.md exists in the skill directory
- [ ] **No external URL references** — Except in acknowledgments/sources section
- [ ] **Example data is bundled** — Sample files or test data included in references/ if needed
- [ ] **Network access documented** — If network calls required, they're user-initiated and documented in allowed-tools
- [ ] **No mandatory external setup** — Skill works after deployment without external configuration

## Common Issues Checklist

### Anti-Patterns to Avoid
- [ ] No Windows-style paths (`scripts\helper.py`)
- [ ] No deeply nested reference structures
- [ ] No time-sensitive rules without escape hatches
- [ ] No excessive options without defaults
- [ ] No vague descriptions
- [ ] No inconsistent terminology
- [ ] No magic numbers without explanation
- [ ] No error handling punted to Claude
- [ ] No external API references without user initiation (see self-containment principle)

### Quality Checks
- [ ] No extraneous documentation (this is for AI, not humans)
- [ ] No README, setup guides, or installation procedures
- [ ] No auxiliary context about skill creation process
- [ ] No commented-out code
- [ ] No TODOs or FIXMEs

## Final Sign-Off

- [ ] Skill creator reviewed this entire checklist
- [ ] All applicable items marked complete
- [ ] Skill is ready for deployment to:
  - [ ] Global: `~/.claude/skills/`
  - [ ] Project-local: `.claude/skills/`

## Notes

For comprehensive best practices, see:
- **How skills work**: `how-skills-work.md` (architecture, token loading, selection mechanism)
- **Writing effective descriptions**: `content-guidelines.md` (description formula, trigger phrases, testing)
- **Workflow patterns**: `templates.md` (checklist, feedback loop, conditional, template patterns)
- **Testing & iteration**: `validation-workflow.md` Phase 7 and Testing Checklist
- **Security & permissions**: `allowed-tools.md` (tool scoping, principle of least privilege)
- **Advanced patterns**: `advanced-patterns.md` (production patterns, archetypes, risk tiering)
