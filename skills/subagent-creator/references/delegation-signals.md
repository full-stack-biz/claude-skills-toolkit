# Delegation Signals: Writing Descriptions Claude Will Recognize

The subagent description is Claude's PRIMARY signal for when to delegate. This guide helps you write descriptions that trigger reliable delegation.

## Table of Contents

- [How Claude Evaluates Descriptions](#how-claude-evaluates-descriptions)
- [Description Formula](#description-formula)
- [Trigger Phrases: The Core of Delegation](#trigger-phrases-the-core-of-delegation)
- [Writing Descriptions: Step-by-Step](#writing-descriptions-step-by-step)
- [Common Delegation Mistakes & Fixes](#common-delegation-mistakes--fixes)
- [Trigger Phrase Library](#trigger-phrase-library)
- [Real-World Examples](#real-world-examples)
- [Testing Your Description](#testing-your-description)
- [Conclusion](#conclusion)

## How Claude Evaluates Descriptions

Claude uses natural language understanding (not keyword matching) to decide if a request matches a subagent description:

1. Claude reads the user's request
2. Claude evaluates each subagent description
3. Claude asks: "Does this description match what the user is asking for?"
4. If yes: Delegate to that subagent
5. If no or unclear: Don't delegate (or delegate to less-likely match)

**Key insight:** Specificity matters. Vague descriptions are ambiguous; specific descriptions are clear.

## Description Formula

```
[Action]. Use when [trigger contexts/scenarios]. [Scope/constraints].
```

**Components:**

1. **Action** (required)
   - What does this subagent DO?
   - Example: "Execute read-only database queries"
   - NOT: "Database subagent"

2. **Use when** (required)
   - What requests/contexts should trigger this?
   - Should include 3+ specific trigger phrases
   - Example: "when analyzing data, generating reports, or exploring structure"
   - NOT: "when needed" or "for database work"

3. **Scope/constraints** (required)
   - What's included? What's excluded?
   - Example: "SELECT only; write operations blocked"
   - NOT: absent or vague

## Trigger Phrases: The Core of Delegation

Trigger phrases are the words/concepts Claude sees in user requests that should activate your subagent.

### Identifying Good Trigger Phrases

Ask yourself: "When would a user want this subagent to run? What words would they use?"

**Example:** db-analyzer subagent

User requests that should trigger delegation:
- "Analyze the Q4 sales data"
- "Generate a report on user activity"
- "Explore the user_activity table structure"
- "What does the database look like?"

Trigger phrases to include in description:
- "analyzing data"
- "generating reports"
- "exploring structure"
- "answering questions"

**Bad trigger phrases:**
- "when needed" (too vague; will match many requests)
- "for database work" (too generic; unclear what you're doing)
- "if applicable" (doesn't help Claude decide)

### Finding Trigger Phrases: Brainstorming

1. **Think of use cases**: What problems does this subagent solve?
2. **Write example user requests**: "Analyze the database", "Generate a report", "Explore the schema"
3. **Extract key phrases**: "analyze", "generate report", "explore schema"
4. **Verify with real requests**: Would a user naturally say "analyze the database"? Yes → include "analyzing data"

Example brainstorm:

| Subagent | Use Cases | Trigger Phrases |
|-----------|-----------|-----------------|
| code-reviewer | Find bugs, check security, validate changes | "review code", "check security", "find bugs" |
| data-analyzer | Answer questions, explore data, generate reports | "analyze data", "answer questions about", "generate report" |
| test-runner | Validate before commit, check failing tests | "run tests", "check tests", "validate", "fix failing tests" |

### Specificity Levels

**❌ Too vague:**
```
"Database operations"
```
No trigger phrases; won't reliably trigger.

**⚠️ Generic:**
```
"Execute database queries. Use for database work."
```
"For database work" is too broad; includes things outside scope.

**✅ Specific:**
```
"Execute read-only SQL queries for data analysis. Use when analyzing data, generating reports, or exploring table structure. SELECT only."
```
Specific triggers (analyzing, generating reports, exploring); specific scope (SELECT only).

## Writing Descriptions: Step-by-Step

### Step 1: Define the Action

What does this subagent actually do?

```
Good:
- "Execute read-only database queries"
- "Review code for security and quality"
- "Generate test reports"

Bad:
- "Database subagent" (what does it do?)
- "Code subagent" (too generic)
- "Perform operations" (vague)
```

### Step 2: List 3+ Use Cases

When should Claude delegate to this subagent?

```
db-analyzer:
1. User asks to analyze data
2. User asks to generate a report
3. User asks to explore the database structure

code-reviewer:
1. User asks to review code
2. User asks to find security issues
3. User asks to check code quality
```

### Step 3: Extract Trigger Phrases

From the use cases, what words appear?

```
db-analyzer: analyze, generate report, explore structure
code-reviewer: review, find security issues, check quality
```

### Step 4: State Scope & Constraints

What's IN and OUT of scope?

```
db-analyzer:
- IN: SELECT queries, analysis, reporting
- OUT: Modifying data, creating tables

code-reviewer:
- IN: Finding issues, suggesting improvements
- OUT: Modifying code
```

### Step 5: Write Full Description

Combine all components:

```
Execute read-only database queries for data analysis. Use when analyzing
data, generating reports, or exploring table structure. SELECT only;
write operations blocked.
```

## Common Delegation Mistakes & Fixes

### Mistake 1: Vague Descriptions

**❌ Bad:**
```
"Analyze and execute operations"
```

**Why it fails:**
- "Analyze and execute operations" matches too many things
- Claude won't know when to use this specifically
- Will compete with other subagents

**✅ Fix:**
```
"Execute read-only SQL queries for data analysis. Use when analyzing
data patterns, generating reports, or exploring table structure.
SELECT only; writes blocked."
```

### Mistake 2: Missing Trigger Phrases

**❌ Bad:**
```
"Code review subagent. Use for code work."
```

**Why it fails:**
- "For code work" is vague (fixing code, writing code, reading code all count)
- No specific triggers (review, security, quality)
- Claude can't distinguish from code-writing subagent

**✅ Fix:**
```
"Review code for quality, security, and best practices. Use when analyzing
code changes, finding bugs, checking security, or validating against standards.
Analysis only; no modifications."
```

### Mistake 3: Conflicting Scope

**❌ Bad:**
```
"Execute database queries. Use when working with databases. All operations
supported."
```

**Why it fails:**
- "All operations supported" contradicts subagent capability (if it's read-only)
- Unclear scope confuses Claude
- Contradictions cause unreliable delegation

**✅ Fix:**
```
"Execute read-only database queries. Use when analyzing data, generating
reports, or exploring structure. SELECT only; write operations blocked."
```

### Mistake 4: Too Long

**❌ Bad:**
```
"This subagent can execute many different types of database queries including
SELECT queries for data analysis, INSERT and UPDATE queries for data modification,
and DELETE queries for data removal, and can also generate reports and explore
database structure in many different ways depending on the use case..."
```

**Why it fails:**
- Too long (>1024 chars)
- Too much detail (Claude doesn't need to know all possible operations)
- Unfocused (what's the PRIMARY purpose?)

**✅ Fix:**
```
"Execute read-only database queries for data analysis. Use when analyzing
data, generating reports, or exploring structure. SELECT only."
```

## Trigger Phrase Library

Use these phrases as inspiration when writing descriptions:

### Analysis & Reporting
- "analyzing data"
- "generating reports"
- "exploring structure"
- "answering questions about"
- "finding patterns"
- "summarizing findings"

### Code Review & Validation
- "reviewing code"
- "finding bugs"
- "checking security"
- "validating changes"
- "ensuring quality"
- "checking performance"

### Code Modification
- "fixing bugs"
- "implementing features"
- "refactoring code"
- "making changes"
- "updating code"
- "resolving issues"

### Testing
- "running tests"
- "checking test results"
- "validating functionality"
- "ensuring tests pass"
- "fixing failing tests"

### Research & Exploration
- "researching modules"
- "understanding architecture"
- "exploring codebase"
- "documenting patterns"
- "identifying dependencies"

### Background Processing
- "background processing"
- "parallel research"
- "concurrent work"
- "parallel analysis"

## Real-World Examples

### Example 1: Database Analyzer

**Brainstorm:**
- Use case 1: User wants to understand database structure
- Use case 2: User wants to answer questions about data
- Use case 3: User wants to generate a report

**Triggers identified:**
- explore structure / exploring database / understand tables
- answer questions / analyze data / query data
- generate report / reporting

**Description:**
```
Execute read-only database queries for data analysis. Use when exploring
table structure, answering questions about data, or generating reports.
SELECT only; write operations blocked.
```

**Test:** Does this match these user requests?
- "What's in the users table?" ✅ (explore structure, answer questions)
- "Generate a report on Q4 sales" ✅ (generating reports)
- "Create a new table" ❌ (write operation; correctly doesn't match)
- "Analyze the data" ✅ (data analysis)

### Example 2: Code Reviewer

**Brainstorm:**
- Use case 1: User made changes and wants review
- Use case 2: User concerned about security
- Use case 3: User wants quality check

**Triggers identified:**
- review code / reviewing changes / code review
- security / security issues / security vulnerabilities
- quality / code quality / best practices

**Description:**
```
Review code for quality, security, and best practices. Use when analyzing
code changes, finding bugs, checking security issues, or validating code
against standards. Analysis only; no modifications.
```

**Test:** Does this match these user requests?
- "Review my authentication changes for security" ✅ (review, security)
- "Check for bugs in this function" ✅ (finding bugs)
- "Fix this security vulnerability" ❌ (modifications; reviewer doesn't fix)
- "Ensure my code follows best practices" ✅ (validating against standards)

### Example 3: Code Fixer

**Brainstorm:**
- Use case 1: There's a bug to fix
- Use case 2: Need to implement a feature
- Use case 3: Code needs refactoring

**Triggers identified:**
- fix bug / fixing bugs / bug fix
- implement / implementing feature / add feature
- refactor / refactoring / clean up

**Description:**
```
Fix bugs, implement features, and refactor code. Use when fixing issues,
implementing new functionality, or refactoring sections. Modifies code directly.
```

**Test:** Does this match these user requests?
- "Fix the authentication bug" ✅ (fix bug)
- "Implement user login feature" ✅ (implement feature)
- "Refactor the database module" ✅ (refactor)
- "Review the authentication code" ❌ (review only; fixer modifies)

## Testing Your Description

Before deploying, test that your description triggers correctly:

### Manual Testing

Write 3-5 realistic user requests for this subagent:

```
Subagent: db-analyzer
Trigger phrases: "analyzing data", "generating reports", "exploring structure"

Test requests:
1. "Analyze the user_activity table and identify trends"
   → Should match? YES (analyzing data)

2. "Generate a report on Q4 metrics"
   → Should match? YES (generating reports)

3. "What columns are in the payments table?"
   → Should match? YES (exploring structure)

4. "Create a new table for tracking events"
   → Should match? NO (write operation; outside scope)

5. "Help me understand the database"
   → Should match? MAYBE (exploring structure? Yes)
```

If most tests match expected results → description is good.
If tests don't match expectations → rewrite description with clearer triggers.

### Description Checklist

Before finalizing:

- [ ] Description has clear action (what does it do?)
- [ ] Description has 3+ specific trigger phrases (concrete actions, not vague)
- [ ] Description states scope/constraints (what it can/can't do)
- [ ] No vague language ("when needed", "for work", "if applicable")
- [ ] Length is ≤1024 chars
- [ ] Would match realistic user requests
- [ ] Wouldn't match requests outside scope
- [ ] Uses concrete verbs (analyze, review, fix, generate, execute)
- [ ] No marketing language

## Conclusion

Reliable delegation comes from specific, clear descriptions. The description is Claude's ONLY signal for when to use your subagent. Invest time in getting it right—it directly impacts reliability.

**Remember:** Better descriptions = better delegation = better execution.
