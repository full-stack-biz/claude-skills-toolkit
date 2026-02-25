# Building Robust Skills with AskUserQuestion

How to author skills that handle errors, validate input, and work reliably in production.

## Table of Contents

- [Error Handling Pattern](#error-handling-pattern)
- [Input Validation Patterns](#input-validation-patterns)
- [Compatibility Checking](#compatibility-checking)
- [Confirmation Pattern](#confirmation-pattern)
- [Logging Best Practices](#logging-best-practices)
- [Fallback Handling](#fallback-handling)
- [Recovery from Errors](#recovery-from-errors)
- [Version/Compatibility Checking](#versioncompatibility-checking)
- [Testing Validation](#testing-validation)
- [Testing Skills with AskUserQuestion](#testing-skills-with-askuserquestion)
- [Skill Security Patterns](#skill-security-patterns)
- [Rollback Support](#rollback-support)
- [Key Principles for Robustness](#key-principles-for-robustness)

## Error Handling Pattern

Basic structure for robust skills:

```markdown
## Step 1: Ask Question

Ask: "Your choice?"
Options: ...

## Step 2: Handle Response

If response is null or empty:
  Log error: "No response received"
  Offer: "Please try again or provide value manually"
  Exit

If response received:
  Continue to validation

## Step 3: Validate Answer

Validate format, range, compatibility
If invalid:
  Log error with details
  Ask: "Reconfigure?" (Yes/No)
  If Yes: Go back to Step 1
  If No: Exit or use default

If valid:
  Proceed with configuration
```

## Input Validation Patterns

### Numeric Input

```
If question asks for number:

Get answer: port = answers["Port?"]
Parse as integer: portNum = parseInt(port)

Validate:
- Is it a number? (isNaN check)
- Is it in valid range? (1-65535 for ports)
- Is it available? (if checking system)

If invalid:
  Log: "Invalid port: [value]"
  Show expected format: "1-65535"
  Ask to reconfigure

If valid:
  Use portNum
```

### Format Validation

```
If question asks for email:

Get answer: email = answers["Email?"]

Validate:
- Contains @?
- Has domain?
- Looks like email?

If invalid:
  Log: "Invalid email format"
  Ask to reconfigure

If valid:
  Use email
```

### Range Validation

```
If question asks for count:

Get answer: count = answers["How many?"]
Parse: num = parseInt(count)

Validate:
- Between min (2) and max (10)?

If invalid:
  Log: "Please enter 2-10"
  Ask to reconfigure

If valid:
  Use num for iteration
```

## Compatibility Checking

Check that multiple answers work together:

```markdown
## Step 1-2: Ask questions
[Get answers]

## Step 3: Check Compatibility

If answer1 = "PostgreSQL" AND answer2 = "NoSQL-mode":
  Log warning: "PostgreSQL doesn't support NoSQL queries"
  Ask: "Use standard PostgreSQL?" (Yes/No)
  If No: Ask to reconfigure

If answer1 = "Development" AND answer2 = "Prod-scale":
  Log warning: "Large scale in dev environment unusual"
  Ask: "Confirm?" (Yes/No)
  If No: Ask to reconfigure

If all compatible:
  Proceed
```

## Confirmation Pattern

Always confirm before applying:

```markdown
## Step 1-3: Gather and Validate
[Get answers, validate all]

## Step 4: Show Summary

Log exactly what will be configured:
"Configuration Summary:
- Database: PostgreSQL
- Port: 5432
- Environment: production
- Features: Logging, Monitoring"

## Step 5: Ask Confirmation

Ask: "Apply this configuration?"
Options: Yes, No, Edit

If Yes:
  Apply configuration
  Log: "✓ Configuration applied"

If No:
  Log: "Configuration cancelled"
  Exit

If Edit:
  Ask which setting to change
  Ask new value
  Go back to Step 4
```

## Logging Best Practices

### Log Important Events

```
Log when:
- Question is asked (what are options)
- User answer received (show what they chose)
- Validation happens (success or failure)
- Configuration is applied
- Errors occur
```

### Don't Log Sensitive Data

```
✅ DO:
  Log: "Database connection configured"
  Log: "Using provided connection string"

❌ DON'T:
  Log: "Using password: abc123"
  Log: "API key: secret-key-here"
```

### Use Clear Error Messages

```
❌ WRONG:
  Log: "Error"

✅ RIGHT:
  Log: "ERROR: Port must be 1-65535, you entered: 99999"
  Log: "Please choose a valid port and reconfigure"
```

## Fallback Handling

When custom input can't be validated:

```markdown
## When Custom Input Doesn't Match Format

If user types custom value that can't be validated:

Option 1: Use with warning
  Log: "⚠️  Using custom value: [value]"
  Log: "This may require additional manual setup"
  Proceed with custom value

Option 2: Ask for help
  Log: "Custom value entered: [value]"
  Log: "This requires: [specific format/details]"
  Ask: "Can you provide in required format?"
  [Ask clarifying question]

Option 3: Use sensible default
  Log: "Can't parse [value]"
  Log: "Using default: [default]"
  Proceed with default
```

## Recovery from Errors

When something goes wrong:

```markdown
## If Configuration Fails

If error applying configuration:

Step 1: Log the error
  Log: "ERROR: [specific error message]"
  Log: "Failed to [what was being done]"

Step 2: Inform user
  Log: "Configuration was not applied"
  Log: "Reason: [explanation]"

Step 3: Offer options
  Ask: "Retry?" (Yes/No)
  Ask: "Reconfigure?" (Yes/No)
  Ask: "Show log?" (Yes/No)

Step 4: Recovery
  If Retry: Try again
  If Reconfigure: Ask questions again
  If Show log: Display error details
```

## Version/Compatibility Checking

When applying configuration:

```markdown
## Check Compatibility

Before applying configuration:

Check: Is system in right state?
  - Required tools installed?
  - Permissions correct?
  - Enough disk space?
  - Compatible OS?

If incompatible:
  Log: "System check failed"
  Log: "Required: [list what's needed]"
  Log: "Your system: [what you have]"
  Exit without applying
```

## Testing Validation

When writing skill, test with:

1. Valid options
   - User selects provided option
   - Configuration applies correctly

2. Custom text
   - User types custom value
   - Custom text handled gracefully

3. Invalid input
   - User types wrong format
   - Error handling works
   - User can retry

4. Edge cases
   - Empty answers
   - Very long answers
   - Special characters
   - Boundary values (port 1, port 65535)

## Testing Skills with AskUserQuestion

### Simulate User Responses

When testing skill:
- Provide different option selections
- Test with custom text ("Other" selections)
- Test with multi-select combinations
- Test with empty/invalid inputs

### Common Test Cases

1. User selects first option
2. User selects last option
3. User types custom answer
4. User selects multiple (if multiSelect)
5. User provides invalid format (test validation)

## Skill Security Patterns

### Never Log Secrets

```
When handling passwords, API keys, tokens:

✅ DO:
  Log: "API key provided"
  Log: "Password configured"

❌ DON'T:
  Log: "API key: ak-12345"
  Log: "Password: super-secret"
```

### Validate User Input

```
When user provides paths, filenames, URLs:

Validate:
- Path traversal attempts (../)
- Special characters that could be exploits
- Suspicious patterns

If suspicious:
  Log: "WARNING: Suspicious input detected"
  Ask to reconfigure
```

### Use Environment Variables for Secrets

```
If skill needs secrets:

Do NOT ask user to type password
Instead:
  1. Check if env var exists
  2. If not: Provide clear instructions
  3. Ask user to set env var
  4. Read from environment

Example:
  Check: process.env.DB_PASSWORD
  If missing:
    Log: "Set environment variable: export DB_PASSWORD=..."
    Exit
```

## Rollback Support

For destructive operations:

```markdown
## Before Making Changes

Create backup:
  Save current configuration to backup file
  Log: "Backup created: [path]"

## If Something Goes Wrong

If error during configuration:
  Log: "ERROR detected, rolling back..."
  Restore from backup
  Log: "Configuration restored from backup"

If user cancels:
  Log: "Cancelled, no changes made"
  (No rollback needed if backup wasn't applied)
```

## Key Principles for Robustness

✅ **Always validate** before using user input

✅ **Always confirm** before applying changes

✅ **Always handle errors** gracefully

✅ **Always log** what you're doing

✅ **Never log** sensitive data

✅ **Offer recovery** options when things fail

✅ **Be explicit** about what went wrong and why

✅ **Support redo/reconfigure** patterns

✅ **Test** with invalid inputs

✅ **Document** custom input requirements
