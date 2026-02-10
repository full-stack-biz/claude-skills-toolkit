# Anti-Patterns in Skill Creation

Learn from common mistakes that prevent skills from activating, executing clearly, or integrating well. Each category shows ❌ BAD examples and ✅ GOOD alternatives.

## Table of Contents
- [Activation Anti-Patterns](#activation-anti-patterns)
- [Structure Anti-Patterns](#structure-anti-patterns)
- [Content Anti-Patterns](#content-anti-patterns)
- [Tool Scoping Anti-Patterns](#tool-scoping-anti-patterns)

---

## Activation Anti-Patterns

**Problem:** Skill never triggers when users need it because description lacks specificity.

### Anti-Pattern 1: Vague Description

❌ **BAD:**
```yaml
description: >-
  A helpful skill for working with documents.
```
**Why it fails:** Claude won't recognize when to activate. "Working with documents" matches everything and nothing.

✅ **GOOD:**
```yaml
description: >-
  Extract text from PDF files using OCR. Use when analyzing PDFs, reading scanned documents,
  or extracting structured data from forms. Supports encrypted PDFs.
```
**Why it works:** Specific trigger phrases ("extract text", "PDF", "OCR", "scanned documents") match real user requests.

### Anti-Pattern 2: Missing Trigger Phrases

❌ **BAD:**
```yaml
description: >-
  A utility for code validation.
```
**Problem:** No action verbs or domain context. Won't trigger on "validate my code" or "check for errors".

✅ **GOOD:**
```yaml
description: >-
  Validate PHP code syntax and detect errors. Use when checking code for syntax errors,
  before committing to git, or analyzing Laravel code quality.
```

### Anti-Pattern 3: Generic Category Instead of Action

❌ **BAD:**
```yaml
name: file-helper
description: >-
  Helps with file operations.
```

✅ **GOOD:**
```yaml
name: pdf-text-extractor
description: >-
  Extract text and structured data from PDF files. Use when analyzing PDFs,
  converting to markdown, or reading scanned documents.
```

---

## Structure Anti-Patterns

**Problem:** Skill has correct content but organized poorly, making it hard for Claude to find what's needed.

### Anti-Pattern 4: Nested Reference Chains

❌ **BAD:**
```
skill-name/
├── SKILL.md
└── references/
    ├── guide.md
    │   (links to)
    └── advanced-topics/
        └── patterns.md
            (links to)
            └── edge-cases.md
```
**Problem:** Claude may partially read files, missing context from nested chains.

✅ **GOOD:**
```
skill-name/
├── SKILL.md (links directly to both)
└── references/
    ├── guide.md
    ├── patterns.md
    └── edge-cases.md
```
**Why it works:** One level deep. Claude reads all files at same level together.

### Anti-Pattern 5: No Quick Start

❌ **BAD:**
```markdown
# Skill Name

## Overview
This skill processes files using advanced algorithms...

## Architecture
The system is built on several layers...

## Configuration
To configure the skill, you need to...
```
**Problem:** Claude must read extensive content before doing anything.

✅ **GOOD:**
```markdown
# Skill Name

## Quick Start

Process a file:
```bash
python scripts/process.py input.txt
```

## Core Workflow
[3-5 steps with examples]
```

### Anti-Pattern 6: Unclear Reference Links

❌ **BAD:**
```markdown
For more information, see `references/docs.md`.
```
**Problem:** "docs.md" tells Claude nothing about what's inside.

✅ **GOOD:**
```markdown
For error handling patterns specific to this skill, see `references/error-handling.md`.
For production deployment guidelines, see `references/team-production-patterns.md`.
```

---

## Content Anti-Patterns

**Problem:** SKILL.md includes content that violates the 80% rule or lacks clarity.

### Anti-Pattern 7: Theoretical Background Before Examples

❌ **BAD:**
```markdown
## PDF Processing

PDF files use a complex format with streams and objects. Understanding the
internal structure is key to effective extraction...

[3 paragraphs of theory]

### Example
```python
extract_text("file.pdf")
```
```

✅ **GOOD:**
```markdown
## Extract Text

Extract text from PDF:
```python
import pdfplumber
with pdfplumber.open("file.pdf") as pdf:
    text = pdf.pages[0].extract_text()
```

For theory and advanced patterns, see `references/pdf-architecture.md`.
```

### Anti-Pattern 8: Overly Detailed Troubleshooting

❌ **BAD:** SKILL.md includes full troubleshooting section with 20 error cases.

✅ **GOOD:** SKILL.md mentions "For troubleshooting, see `references/troubleshooting.md`" (supplementary, <20% cases).

### Anti-Pattern 9: Generic Placeholder Names

❌ **BAD:**
```markdown
## Example

Process your data:
```python
process_data(your_data)
```
```
**Problem:** Claude doesn't know what "data" means.

✅ **GOOD:**
```markdown
## Example

Extract contact names from a CSV:
```python
import csv
with open("contacts.csv") as f:
    reader = csv.DictReader(f)
    for row in reader:
        print(row["name"])
```
```

### Anti-Pattern 10: Exceeding 500 Lines

❌ **BAD:** SKILL.md body is 800 lines, with comprehensive guides inlined.

✅ **GOOD:** SKILL.md body is 280 lines; guides moved to `references/`.

---

---

## Tool Scoping Anti-Patterns

**Problem:** Skill requests too many permissions, violating principle of least privilege.

### Anti-Pattern 14: Overly Broad Bash Access

❌ **BAD:**
```yaml
allowed-tools: Read,Write,Bash(*)
```
**Problem:** Skill can execute ANY command (delete files, modify system, etc.).

✅ **GOOD:**
```yaml
allowed-tools: Read,Write,Bash(python:*,grep:*)
```
**Why it works:** Only Python and grep commands allowed.

### Anti-Pattern 15: Requesting Unnecessary Tools

❌ **BAD:**
```yaml
allowed-tools: Read,Write,Edit,Bash(*),Task(*)
```
**Problem:** Skill doesn't need all these. Principle of least privilege violated.

✅ **GOOD:**
```yaml
allowed-tools: Read,Write,Bash(git:*)
```
(Only what's actually used in the skill.)

### Anti-Pattern 16: No Tool Scoping at All

❌ **BAD:** Omit `allowed-tools` field entirely.

✅ **GOOD:** Always specify, even for simple skills:
```yaml
allowed-tools: Read
```

---

## Summary: Prevention Checklist

When creating or reviewing a skill, ask:

- ✅ Does description include specific trigger phrases (not just "processing", "helping", "utility")?
- ✅ Is reference structure one level deep (no chains)?
- ✅ Does Quick Start appear first (before theory)?
- ✅ Are examples concrete (real files, real data)?
- ✅ Is SKILL.md body <500 lines?
- ✅ Is 80% rule applied (supplementary content moved to references)?
- ✅ Are tool permissions minimal (only what's needed)?

If any answer is ❌, address before deployment.
