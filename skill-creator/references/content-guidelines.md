# Content Guidelines for Skills

## Table of Contents
- [Writing Effective Descriptions](#writing-effective-descriptions)
- [MCP Tool References](#mcp-tool-references)
- [Consistent Terminology](#consistent-terminology)
- [Time-Sensitive Information](#time-sensitive-information)
- [Examples Over Explanations](#examples-over-explanations)

---

## Writing Effective Descriptions

The description is **the triggering mechanism**. Claude uses it to select from 100+ skills. It must be specific and include trigger phrases.

### Rules

1. **Third person always** — "Processes Excel files" not "I can help you" or "You can use this"
2. **Specific + trigger phrases** — Include what it does AND when to invoke
3. **Key terms for discovery** — Use synonyms user might say
4. **≤1024 characters** — Keep concise yet comprehensive

### Formula

```
[What it does - actions, capabilities].
Use when [trigger phrases, contexts, file types, user intents].
[Optional: key constraints or scope].
```

### Examples of Good Descriptions

✅ "Analyze Excel spreadsheets, create pivot tables, generate charts. Use when analyzing Excel files, spreadsheets, tabular data, or .xlsx files."

✅ "Generate descriptive commit messages by analyzing git diffs. Use when user asks for help writing commit messages or reviewing staged changes."

✅ "Create Claude Code skills following best practices. Use when building new skills, validating existing skills, or improving skill quality."

### Examples of Poor Descriptions

❌ "Helps with documents" — too vague, no triggers
❌ "Processes data" — generic, no action clarity
❌ "Does stuff with files" — no actionable content

### Testing Your Description

Before deploying, test your description mentally:

**Expected triggers (should activate):**
- List 3-5 queries your skill solves
- Would Claude match these to your description? ✓

**Unrelated queries (should NOT activate):**
- List 3-5 unrelated queries
- Would Claude wrongly match these? ✗

### "When to use this skill" Section

Beyond the frontmatter description, include an explicit **"When to use this skill"** section early in the SKILL.md body.

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

## MCP Tool References

When using MCP tools, **always use fully qualified names**:

```markdown
# GOOD
Use the BigQuery:bigquery_schema tool to retrieve schemas.

# BAD - may fail
Use the bigquery_schema tool...
```

**Format:** `ServerName:tool_name`

This ensures Claude references the correct tool from the correct MCP server, avoiding conflicts when multiple servers provide similar tools.

---

## Consistent Terminology

Pick one term, use it everywhere:

```
✓ Always "API endpoint" (not "URL", "route", "path")
✓ Always "field" (not "box", "element", "control")
✓ Always "extract" (not "pull", "get", "retrieve")
```

**Why this matters:** Inconsistent terminology confuses Claude. Using multiple words for the same concept makes instructions harder to follow.

**How to check:**
1. List all key concepts in your skill
2. Pick one term per concept
3. Search SKILL.md + references for variations
4. Replace all variations with chosen term

---

## Time-Sensitive Information

Avoid information that becomes wrong:

**BAD:**
```markdown
If before August 2025, use old API. After August 2025, use new API.
```

**GOOD:**
```markdown
## Current method
Use v2 API: `api.example.com/v2/messages`

<details>
<summary>Legacy v1 API (deprecated 2025-08)</summary>
The v1 API used: `api.example.com/v1/messages`
No longer supported.
</details>
```

**Why this works:**
- Current method is obvious upfront
- Legacy method is available but collapsed
- Deprecation date is explicit
- Content doesn't silently become wrong

---

## Examples Over Explanations

Examples are more efficient than prose explanations.

**BAD (~150 tokens):**
```markdown
## Commit message format

The commit message format follows conventional commits style with type(scope)
prefix. The type indicates the category of change (feat, fix, refactor, etc.).
The scope indicates the area affected. The description should be brief and in
imperative mood...
```

**GOOD (~50 tokens):**
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

**Key principles:**
- Concrete examples compress better than abstract rules
- Real names (not placeholders) are clearer
- Copy-paste ready code is more useful
- Examples + brief explanation beats lengthy explanation alone
