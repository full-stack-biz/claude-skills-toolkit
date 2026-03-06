# Handling Custom Input ("Other") in Skills

How to author skills that properly handle free-text answers when users select "Other".

## How Free-Text Works

Users always see an automatic "Other" option. When selected, they can type custom text.

**In skill:**
```
Options:
  - React
  - Vue
  - Svelte

[User sees automatically: Other]
```

**User behavior:**
- Selects "React" → answers["Framework?"] = "React"
- Types "angular" → answers["Framework?"] = "angular"
- Types "i prefer next.js" → answers["Framework?"] = "i prefer next.js"

**CRITICAL:** Custom text appears in answers directly, NOT as "Other"

## Detecting Custom vs Known Answers

In skill body:

```
The answer to "Which framework?" could be:
- Known: React, Vue, Svelte (from options)
- Custom: angular, next.js, custom-framework (user typed)

Check which:

If answer in [React, Vue, Svelte]:
  Treat as known framework
  Use framework-specific setup

Else:
  Treat as custom framework
  Use generic setup
```

## Pattern 1: Accept Custom with Generic Handling

When you want to allow any custom value:

```markdown
## Question: Database Selection

**Text:** "Which database?"
**Options:**
- PostgreSQL (Relational, complex queries)
- MongoDB (Document-based, flexible)
- Redis (In-memory, caching)

[User can also type custom: dynamodb, firestore, etc.]

## Processing

Check answer:
- "PostgreSQL" → Use PostgreSQL setup
- "MongoDB" → Use MongoDB setup
- "Redis" → Use Redis setup
- Custom (any text) → Use generic setup with custom name

Log: "Database: [answer]"
Configure with [answer] as database name
```

## Pattern 2: Validate Custom Input Format

When custom input must match a format:

```markdown
## Question: Connection String

**Text:** "Database connection string?"
**Options:**
- Local (localhost setup)
- Cloud (use cloud provider)

## Processing

Get answer:
If "Local":
  Use default local connection

If "Cloud":
  Ask for connection details

If custom text:
  Validate format

  If contains "://":
    Treat as valid connection string
  Else:
    Log error: "Invalid format. Expected: protocol://user:pass@host:port"
    Ask user to reconfigure
```

## Pattern 3: Multi-Select with Custom

For features where user can enable any combination:

```markdown
## Question: Features

**Text:** "Which features to enable?"
**multiSelect:** true
**Options:**
- Logging
- Metrics
- Alerts
- Backups

User can select: Logging, custom-tracking, Metrics

## Processing

Answer: "Logging, custom-tracking, Metrics"

Split by ", ":
- features = ["Logging", "custom-tracking", "Metrics"]

For each:
- If known (Logging, Metrics): Enable built-in
- If custom (custom-tracking): Log warning and enable generic

Configure all selected features
```

## Pattern 4: Normalize Custom Input

When custom text needs to be standardized:

```markdown
## Question: Environment

**Text:** "Which environment?"
**Options:**
- Dev
- Staging
- Production

User types: "development"

## Processing

Get answer: "development"

Normalize:
- development → dev
- staging → staging
- prod → production
- production → production
- custom text → use as-is

Use normalized value for configuration
```

## Pattern 5: Custom with Validation

When you need to validate custom input:

```markdown
## Question: Port Number

**Text:** "Port number?"
**Options:**
- 3000 (Development)
- 8080 (Standard)

User types: 9000

## Processing

Get answer: "9000"

Validate:
- Parse as integer
- Check range 1-65535
- If valid: Use port 9000
- If invalid: Log error, ask to reconfigure

Log: "Using port 9000"
Configure server with port
```

## Pattern 6: Custom with List Validation

When custom must be from a larger set:

```markdown
## Question: Programming Language

**Text:** "Language for this project?"
**Options:**
- Python
- JavaScript
- Go

(Many more are possible)

## Processing

Get answer:
supportedLanguages = [
  Python, JavaScript, Go, Rust, Java,
  C++, C#, PHP, Ruby, Kotlin
]

If answer in supportedLanguages:
  Setup for that language

If not:
  Log: "Language [answer] not officially supported"
  Log: "Proceeding with generic setup"
  Use generic configuration

(User can still select unsupported language)
```

## Pattern 7: Document Custom Input Support

Tell users what custom input is allowed:

```markdown
# Interactive Project Setup

## Custom Input

You can select from provided options OR type custom values:

**Database Selection:**
- Provided: PostgreSQL, MongoDB, Redis
- Custom examples: dynamodb, firestore, supabase

**Framework:**
- Provided: React, Vue, Svelte
- Custom examples: angular, next.js, nuxt

## How It Works

- Select from options → Exact match, built-in configuration
- Type custom → Generic configuration, custom name used
```

## Pattern 8: Warn on Custom Input

When custom selections need attention:

```markdown
## Processing

If answer not in known options:

Log: "⚠️  Using custom option: [answer]"
Log: "This option may require additional configuration"
Log: "You may need to set up [details] manually"

Proceed with caution
```

## Pattern 9: Offer Clarification for Custom

When custom input might be ambiguous:

```markdown
## Processing

If user types custom answer:

Log: "You selected: [answer]"
Log: "This will configure [system] with:"
Log: "- Name: [answer]"
Log: "- Type: [generic type]"
Log: "- Setup: [generic setup]"

Ask: "Is this correct?" (Yes/No)

If No:
  Ask user to reconfigure
```

## Pattern 10: Track Custom Selections

Log which custom values were used:

```markdown
## Configuration Summary

Known selections:
- Database: PostgreSQL ✓
- Environment: production ✓

Custom selections:
- Framework: next.js (user provided)
- CI/CD: custom-pipeline (user provided)

Note: Custom selections may require additional setup.

See documentation for manual configuration steps.
```

## Complete Example: Database Setup Skill

```markdown
# Database Setup

## Step 1: Choose Database

**Question:**
"Which database system?"

**Options:**
- PostgreSQL (Relational, ACID, complex queries)
- MongoDB (Document, flexible, rapid iteration)
- Redis (In-memory, caching layer)

[User can also type: dynamodb, firestore, etc.]

## Step 2: Process Answer

If answer = PostgreSQL:
  Ask: Port? (default 5432)
  Ask: Username?
  Setup PostgreSQL config

If answer = MongoDB:
  Ask: URI? (default localhost:27017)
  Ask: Database name?
  Setup MongoDB config

If answer = Redis:
  Ask: Port? (default 6379)
  Setup Redis config

If custom (e.g., "dynamodb"):
  Log: "Using custom database: dynamodb"
  Log: "Note: You may need to set AWS credentials"
  Ask: Connection details?
  Setup generic config with custom name

## Step 3: Confirm & Apply

Show summary:
"Database: [answer]
Port: [port]
Configuration: [details]"

Ask: "Proceed?" (Yes/No)

If Yes: Apply configuration
If No: Restart from Step 1
```

## Key Points for Custom Input

✅ **DO:**
- Accept any text user types
- Use custom text directly (not "Other")
- Check if known vs custom
- Provide generic handling for custom
- Document what custom values are allowed
- Validate if format matters
- Warn if custom needs manual setup

❌ **DON'T:**
- Reject custom input without explanation
- Use word "Other" as answer value
- Force user back to options
- Assume custom input has been validated
- Ignore custom selections in logging
- Leave custom users without guidance
