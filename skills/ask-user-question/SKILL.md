---
name: ask-user-question
description: >-
  Implement skills using AskUserQuestion tool for interactive user input and decisions. Use when authoring skills that need to gather options, handle free-text answers, process multi-select, or build multi-step workflows. Covers tool mechanics, constraints, wiring into skills, response handling, and dynamic question patterns.
version: 1.0.0
allowed-tools: Read, Write, AskUserQuestion
---

# Implementing Skills with AskUserQuestion

How to author skills that use the AskUserQuestion tool for interactive user input, decisions, and guided workflows.

## Official Tool Purpose

From Claude Code system prompt:

**Use AskUserQuestion to:**
1. **Gather user preferences or requirements** - Understand what user wants
2. **Clarify ambiguous instructions** - Ask when instructions are unclear
3. **Get decisions on implementation choices** - Multiple valid approaches exist
4. **Offer choices about what direction to take** - User picks path forward

**Key Capabilities:**
- Users always see "Other" option for custom text input
- `multiSelect: true` allows selecting multiple answers
- Put recommended option first, labeled with "(Recommended)"

**Important:** Don't use to ask "Is my plan ready?" or similar meta-questions. Use in-band questions only for actual decisions.

## How It Works in Skills

**Response Format:**
```json
{
  "questions": [...original questions...],
  "answers": {
    "Question text": "selected option OR custom text",
    "Another question": "answer"
  }
}
```

**Critical Rule:** Custom text appears in answers directly, not as "Other"
```
answers["Framework?"] = "angular"    ✅ (user typed)
answers["Framework?"] = "Other"      ❌ (never this)
```

## Hard Constraints

**Tool Limits (Claude Code enforced):**
- Max 1-4 questions per call
- Min 2, Max 4 options per question
- "Other" is automatic (never include in options list)
- Max header: 12 characters
- Max option label: varies but aim for 1-5 words
- Max description: 1-2 sentences recommended

**"Other" Behavior:**
- Always present automatically
- Users can type any custom text
- Custom text returned as answer value (not "Other")

Example:
```
answers["Framework?"] = "angular"     ✅ (user typed "angular")
answers["Framework?"] = "Other"       ❌ (never this)
```

## How to Wire AskUserQuestion Into a Skill

### Pattern 1: Prose Question (Typical)

Ask in natural language, users respond freely:

```markdown
## Step 1: Ask User for Input

**What are we building?**

Describe the feature or change you want to make.

(I'll ask follow-up questions if I need clarification)

[User responds with description]

## Step 2: Follow-Up If Needed

Based on their response, ask 1-2 clarifying questions:
- "Is this a new feature or updating existing?"
- "What's the expected outcome?"

[User responds]

## Step 3: Process Answers

Use their responses to inform next steps...
```

### Pattern 2: Structured Options (When Choices Matter)

Use tool when user must select from specific options:

```markdown
## Step 1: Ask for Configuration Choice

Use AskUserQuestion tool:

**Question 1:**
- Text: "Which option?"
- Header: "Choice"
- Options:
  - Label: "Option A"
    Description: "What this does, trade-offs"
  - Label: "Option B"
    Description: "Alternative approach"

[User selects or types "Other" for custom]

## Step 2: Process Answer

The response provides:
- answers["Which option?"] = user's selection

Based on answer:
- If "Option A": Do X
- If "Option B": Do Y
- If custom text: Do Z

## Step 3: Continue

Proceed with workflow...
```

### Progressive Disclosure Pattern

CRITICAL: Ask ONE question, wait for response, THEN ask next.

```markdown
## Question 1: Gather Type

Ask: "What type of project?"
Options: Web, Mobile, CLI

[User answers]

## Question 2: Framework (Conditional)

Based on answer to Q1:
- If Web: Ask "Frontend framework?"
- If Mobile: Ask "Platform?"
- If CLI: Ask "Language?"

[User answers]

## Question 3: Confirmation

Show summary and ask: "Proceed?"
Options: Yes, No, Edit

[Continue based on answer]
```

## Defining Questions in Skills

### Pattern 1: Prose with Guidance (Recommended)

Ask questions in natural language with examples. No options needed:

```markdown
## What are we building?

Please describe the feature or change.

(Be as specific as you like — I'll ask follow-ups if needed)
```

Or with guidance:

```markdown
## Do you have any visuals to reference?

- Mockups or wireframes
- Screenshots of similar features
- Examples from other apps

(Paste images, share file paths, or say "none")
```

This pattern:
- ✅ Feels natural to users
- ✅ Allows truly open input
- ✅ No constraint on number of options
- ✅ Users can respond with anything

### Pattern 2: Structured Options (When Choosing Matters)

Use tool options when user must select from specific choices:

```markdown
**Question: Database Selection**
- Text: "Which database for this project?"
- Header: "Database"  (max 12 chars)
- Options:
  - Label: "PostgreSQL"
    Description: "Relational, ACID compliant, best for complex queries"
  - Label: "MongoDB"
    Description: "Document-based, flexible schema, rapid iteration"
  - Label: "Redis"
    Description: "In-memory, very fast, ideal for caching"
```

Constraints for this pattern:
- Min 2, Max 4 options per question
- "Other" automatic for custom input
- Users can select one (or multiple if `multiSelect: true`)

Use when:
- Multiple mutually-exclusive choices exist
- Each option leads to different workflow
- You want to guide without forcing

### Pattern 3: Multi-Select Options

When users should enable/select multiple independent items:

```markdown
**Question: Which features to enable?**
- Header: "Features"
- multiSelect: true
- Options:
  - "Logging" (Operation logs for debugging)
  - "Metrics" (Performance monitoring)
  - "Alerts" (Error notifications)
  - "Backups" (Automatic data backups)
```

Response: `answers["Features?"] = "Logging, Metrics"` (joined with ", ")

## Processing Responses

### Basic Response Handling

```
The tool returns:

{
  "questions": [...],
  "answers": {
    "Which database?": "PostgreSQL"
  }
}

In skill body:

Based on the answer to "Which database?":
- If "PostgreSQL": Set up relational database
- If "MongoDB": Set up document database
- If "Redis": Set up in-memory cache
- If custom text: Configure for custom database name

Then proceed with configuration...
```

### Checking Multiple Answers

```
From response:
- answers["Database?"] = "PostgreSQL"
- answers["Environment?"] = "production"
- answers["Features?"] = "Logging, Metrics"

In skill:

Database: PostgreSQL (check: is this supported?)
Environment: production (check: validate settings for prod)
Features: Split by ", " and enable each

If any validation fails:
  Log error
  Ask user to reconfigure
  Return to questioning phase
```

### Handling Free-Text Answers

```
If user selected "Other" and typed "custom-framework":

answers["Framework?"] = "custom-framework"

In skill:

Check if "custom-framework" is in known frameworks:
  - If yes: use framework-specific setup
  - If no: use generic setup with warning

Log: "Using custom framework: custom-framework"
Proceed with generic configuration...
```

## When to Use Each Pattern

### Use Prose Questions When:
- Scope is open-ended (user describes feature, context, etc.)
- You need true free-form input
- Multiple follow-ups will be needed
- No specific options constrain the answer
- Examples: "What are we building?", "Describe the problem"

### Use Structured Options When:
- User must choose from specific alternatives
- Each option leads to different workflow/configuration
- You want to guide without forcing
- Examples: "Which database?", "Enable monitoring?" (Yes/No)

### Mixed Approach:
Start with prose for context/understanding, then use structured options for specific decisions:

```
Step 1: Ask "What are we building?" (prose)
Step 2: Ask "Which database?" (structured options)
Step 3: Ask "Which features?" (multi-select options)
```

## Question Design (For Structured Options)

When using predefined options:

### Be Specific

❌ "Database?"
✅ "Which database for this project?"

### Provide Context in Description

❌ "A good option"
✅ "Relational, ACID compliant, best for complex queries"

### Show Trade-Offs

❌ "Option A is best"
✅ "Fast for reads, slower for writes, good for analytics"

### Mutually Exclusive (Unless multiSelect)

❌ "PostgreSQL" and "Also supports MongoDB"
✅ "PostgreSQL" (relational) or "MongoDB" (document) - pick one

### Consistent Formatting

All options same style:
- Same capitalization
- Same description length (~1-2 sentences)
- Same level of detail

## Dynamic Questions Pattern

How to ask different questions based on previous answers:

```
## Step 1: Initial Question

Ask: "Application type?"
Options: Web, Mobile, CLI

[Get answer]

## Step 2: Conditional Question

If answer == "Web":
  Ask: "Frontend framework?"
  Options: React, Vue, Svelte

If answer == "Mobile":
  Ask: "Platform?"
  Options: iOS, Android, Cross-platform

If answer == "CLI":
  Ask: "Language?"
  Options: Python, Go, Rust

[Get answer]

## Step 3: More Conditional Questions

Based on BOTH previous answers:
If Web + React:
  Ask: "State management?"
  Options: Redux, Context, Zustand

If Web + Vue:
  Ask: "State management?"
  Options: Pinia, Vuex

[Continue...]
```

## Error Handling in Skills

### Check if Response Received

```
If AskUserQuestion fails or no answers:

Log error: "Failed to gather responses"
Show: "Please try again or provide configuration manually"
Exit

(Or restart the questioning phase)
```

### Validate Answer Format

```
If question expects "port number":
  answers["Port?"] could be:
  - "8080" (valid)
  - "invalid" (needs validation)
  - "12345" (out of range)

Validate before using:
  Parse as number
  Check range (1-65535)
  If invalid: Ask user to reconfigure
```

### Handle Empty Answers

```
If answers["Required field?"] is empty or missing:

Log: "No answer provided for required field"
Ask user to reconfigure

Don't proceed with empty critical answers
```

## Common Limitations & Workarounds

See `references/advanced-patterns.md` for detailed workarounds for common constraint scenarios (max questions, max options, dependent options, pre-populating answers).

## Response Processing Workflow

Typical skill using AskUserQuestion:

```
1. Describe what you're asking
   "Let's configure your database"

2. Ask Question 1
   Call AskUserQuestion with 1 question

3. Get Response
   Extract answers from response object

4. Validate
   Check format, compatibility, ranges

5. Ask Question 2 (if conditional)
   Based on Q1 answer, ask Q2

6. Get Response & Validate

7. Process All Answers
   - Check compatibility across answers
   - Apply configuration
   - Generate outputs

8. Confirm
   Ask: "Does this look right?"
   If Yes: Proceed
   If No: Restart from Q1
```

## Writing About AskUserQuestion in Skills

See `references/skill-patterns.md` for guidance on documenting AskUserQuestion in skill descriptions, body content, and custom input support.

## Testing Skills with AskUserQuestion

See `references/robust-skills.md` for testing validation patterns and common test cases (valid options, custom text, invalid input, edge cases).

## Key Takeaways

✅ **Max constraints:** 1-4 questions, 2-4 options, 12-char header

✅ **Progressive disclosure:** One question → wait → next question

✅ **Custom input:** "Other" automatic, custom text goes in answers

✅ **Conditional:** Ask different Q2 based on Q1 answer

✅ **Validation:** Always check answers before using

✅ **Response format:** Extract from `answers` object

✅ **Error handling:** Check for missing/invalid answers

❌ **Don't:** Combine multiple questions, use >4 options, include "Other" in options

## Plan Mode: When & When NOT to Use

In plan mode, use AskUserQuestion to **clarify requirements before finalizing plan**.

❌ **DON'T use for meta-questions:**
- "Is my plan ready?"
- "Does the plan look good?"
- "Should I proceed with this plan?"

✅ **USE for actual decisions:**
- "Which database?" (real implementation choice)
- "How many environments?" (preference for setup)
- "Enable monitoring?" (actual configuration decision)

For plan approval, use proper plan approval tool instead.

---

**Based on:** Claude Code system prompt (tool-description-askuserquestion.md)
**Source:** https://github.com/Piebald-AI/claude-code-system-prompts
**Last updated:** 2026-02-25 | **Version:** 1.0.0
