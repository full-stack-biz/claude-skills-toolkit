# Advanced Skill Patterns

Complex scenarios and specialized workflows for skills using AskUserQuestion.

## Table of Contents

- [Dynamic Options from System](#dynamic-options-from-system)
- [Multi-Stage with Rollback](#multi-stage-with-rollback)
- [Conditional Branching with Nesting](#conditional-branching-with-nesting)
- [Conflict Detection and Resolution](#conflict-detection-and-resolution)
- [Weighted Recommendations](#weighted-recommendations)
- [Iterative Refinement](#iterative-refinement)
- [Dependency Mapping](#dependency-mapping)
- [Configuration Templating](#configuration-templating)
- [Progressive Disclosure by Expertise](#progressive-disclosure-by-expertise)
- [Approval Workflow for Teams](#approval-workflow-for-teams)
- [A/B Testing Different Approaches](#ab-testing-different-approaches)
- [State Machine Workflow](#state-machine-workflow)
- [Backward Compatibility](#backward-compatibility)
- [Incremental Configuration](#incremental-configuration)
- [Extensibility for Future Changes](#extensibility-for-future-changes)
- [Implementation Tips](#implementation-tips)
- [Workarounds for Common Limitations](#workarounds-for-common-limitations)

## Dynamic Options from System

Generate options based on actual system state:

```markdown
## Before Asking

Detect available options:
- Git branches: run git branch -q
- Installed tools: check PATH
- Existing databases: query system
- Available ports: scan for open ports

## Ask Question with Dynamic Options

Question: "Which branch?"
Options: [generate from git]
  - main (last update: 2h ago)
  - develop (last update: 30m ago)
  - feature/auth (last update: 1d ago)

User selects one

## Process

Configure for selected branch
```

## Multi-Stage with Rollback

Complex setup with ability to undo:

```markdown
## Stage 1: Core Configuration

Ask and apply: Database
Checkpoint 1: Save database config

Ask and apply: Environment
Checkpoint 2: Save environment config

## Stage 2: Advanced Options

Ask and apply: Features
Checkpoint 3: Save features config

## Stage 3: Review & Confirm

Show all selections
Ask: "Proceed with all changes?"

If Yes:
  Apply all at once

If No:
  Ask: "Rollback to?" (Stage 1 / Stage 2 / Cancel)
  If Stage 1: Restore checkpoint 1
  If Stage 2: Restore checkpoint 2
  If Cancel: Exit
```

## Conditional Branching with Nesting

Deep conditional logic:

```markdown
## Q1: Project Type?

Options: Web, Mobile, CLI

## Q2 & Q3: Based on Q1

If Web:
  Q2: Frontend Framework?
  Q3: Backend Framework?

  Q4 (conditional on Q2):
    If React: State management? (Redux/Context/Zustand)
    If Vue: State management? (Pinia/Vuex)

If Mobile:
  Q2: Native or Cross-platform?
  Q3: Framework?

If CLI:
  Q2: Language?
  Q3: Interactive or Batch?

## Proceed with full decision tree
```

## Conflict Detection and Resolution

When answers conflict:

```markdown
## Gather All Answers

[Ask questions, get answers]

## Detect Conflicts

If Database="NoSQL" AND Requires="ACID Transactions":
  Conflict detected

If Environment="Development" AND Scale="Enterprise":
  Conflict detected

If Framework="Legacy" AND Requires="Modern Features":
  Conflict detected

## Resolution Options

Ask: "Conflicts detected. How to resolve?"

For each conflict:
  Option 1: Use [first answer]
  Option 2: Use [second answer]
  Option 3: Reconfigure

Get user input and apply resolution
```

## Weighted Recommendations

Guide users toward best choices:

```markdown
## Ask Questions

Ask about: Project size, performance needs, team experience

## Calculate Recommendations

Based on answers, score each option:

PostgreSQL: score = 8.5 (good fit)
MongoDB: score = 6.0 (acceptable)
Redis: score = 9.2 (excellent fit)

## Show Recommendations

Display:
"Based on your answers, recommended databases:

1. Redis (9.2/10) - Excellent for your use case
   [explanation]

2. PostgreSQL (8.5/10) - Good option
   [explanation]

3. MongoDB (6.0/10) - Possible but less ideal
   [explanation]"

Ask: "Choose recommendation or select different?"
```

## Iterative Refinement

Ask, show preview, refine:

```markdown
## Round 1: Initial Configuration

Ask core questions
Get answers

## Round 2: Show Preview

"Your configuration will create:
- [Resource 1]
- [Resource 2]
- [Resource 3]

Estimated cost: $X/month"

Ask: "This looks good?" (Yes / Refine)

## Round 3 (if Refine): Ask Which To Change

"Which setting to change?"
Options:
  - Database (current: PostgreSQL)
  - Scale (current: Medium)
  - Features (current: Logging + Monitoring)

## Round 4: Update Specific Setting

Ask new value for selected setting

## Repeat Rounds 2-4 Until Happy
```

## Dependency Mapping

Questions depend on multiple prior answers:

```markdown
## Q1: Language?
Options: Python, JavaScript, Go

## Q2: Framework Type?
Options: Web, CLI, Data

## Q3: Testing? (depends on Q1 AND Q2)

If Python + Web:
  Options: pytest, Django test

If Python + Data:
  Options: pytest, unittest

If JavaScript + Web:
  Options: Jest, Mocha, Vitest

If JavaScript + CLI:
  Options: Jest, Mocha

If Go + CLI:
  Options: Go testing, testify

If Go + Web:
  Options: Go testing, testify, httptest
```

## Configuration Templating

Map answers to templates:

```markdown
## Ask Questions
[Get answers]

## Select Template

Based on answers, choose template:

If answers match "Startup Web App":
  Load: template/startup-web.yml
  Customize with answers
  Apply template

If answers match "Enterprise API":
  Load: template/enterprise-api.yml
  Customize with answers
  Apply template

If answers are custom/unique:
  Build from scratch using answers
```

## Progressive Disclosure by Expertise

Different workflows for different users:

```markdown
## Q1: Experience Level?

Options:
- Beginner (I'm new to this)
- Intermediate (I have some experience)
- Advanced (I know what I'm doing)

## Conditional Workflow

If Beginner:
  Simplified questions (3-4 total)
  Recommended defaults shown
  Step-by-step guidance provided

If Intermediate:
  Standard questions (6-8 total)
  Some customization options
  Brief explanations

If Advanced:
  Detailed questions (10+ total)
  All options available
  Technical documentation
  "Expert mode" features unlocked
```

## Approval Workflow for Teams

Multiple users approve configuration:

```markdown
## Configuration Phase

[Ask questions, get answers]

## Review Phase 1: Technical Lead

Show configuration to technical lead
Ask: "Technically sound?" (Approve / Reject / Revise)

If Approve:
  Continue to Phase 2
If Reject:
  Show issues
  Ask user to reconfigure
If Revise:
  Technical lead suggests changes
  Ask user to review changes

## Review Phase 2: Manager

Show configuration to manager
Ask: "Matches business needs?" (Approve / Reject / Revise)

If Approve:
  All good, proceed
If Reject/Revise:
  Handle accordingly
```

## A/B Testing Different Approaches

Let user choose between workflows:

```markdown
## Q1: Setup Approach?

Options:
- Guided (Step-by-step with explanations)
- Quick (Recommended defaults, minimal config)
- Custom (Full control, all options)

## If Guided:
  Ask many questions with context
  Explain each choice
  Show impact of selections

## If Quick:
  Use smart defaults
  Ask minimal questions
  Provide summary

## If Custom:
  Ask all possible questions
  No defaults assumed
  User has full control

Generate configuration from selected approach
```

## State Machine Workflow

Complex state transitions:

```markdown
## States

States: Initial, Configured, Validated, Applied, Complete

## Transitions

Initial:
  Ask configuration questions
  → Configured

Configured:
  Validate all answers
  If valid: → Validated
  If invalid: → Initial (ask again)

Validated:
  Show summary
  Ask: Apply?
  If Yes: → Applied
  If No: → Configured (ask again)

Applied:
  Apply configuration
  Check success
  If success: → Complete
  If failure: → Configured (retry)

Complete:
  Show results
  Log success
  Exit
```

## Backward Compatibility

Support old and new configuration formats:

```markdown
## Check Current Configuration

If old config exists:
  Ask: "Update old configuration?" (Yes/No)

  If Yes:
    Map old settings to new questions
    Ask user to confirm/update
    Apply migration

  If No:
    Offer manual update option

If new config doesn't exist:
  Normal flow: ask new questions
```

## Incremental Configuration

Build configuration piece by piece:

```markdown
## Round 1: Core

Ask: Basic questions
Apply: Core configuration
Show: "✓ Core configured"

## Round 2: Database

Ask: Database questions
Apply: Database configuration
Show: "✓ Database configured"

## Round 3: Services

Ask: Service questions
Apply: Service configuration
Show: "✓ Services configured"

## Round 4: Monitoring

Ask: Monitoring questions
Apply: Monitoring configuration
Show: "✓ Monitoring configured"

## Complete

"All configuration complete"
Show summary of all rounds
```

## Extensibility for Future Changes

Design for adding new options later:

```markdown
## Known Options

Database:
  - PostgreSQL
  - MongoDB
  - Redis

[Handles custom unknown options gracefully]

## When New Option Added (e.g., DynamoDB)

If user types: "dynamodb"
  Not in known list
  Treat as custom
  Apply generic handler
  Log: "Using custom database: dynamodb"

Later, when officially supported:
  Add "DynamoDB" to options
  Existing skills still work
  Automatically uses official handler
```

## Implementation Tips

1. **Test all branches** - Test every conditional path
2. **Handle unknowns** - Custom input should always work
3. **Provide feedback** - Show what was configured
4. **Allow undo** - Support reconfiguration
5. **Log thoroughly** - Help users understand what happened
6. **Validate early** - Check answers as soon as received
7. **Keep it simple** - Complex ≠ better
8. **Document clearly** - Users should understand options

## Workarounds for Common Limitations

### Limitation 1: Max 4 Questions Per Call

**Problem:** Need to ask 6 questions

**Solution:** Ask in stages
- Call 1: Questions 1-4
- Process answers
- Call 2: Questions 5-6

### Limitation 2: Max 4 Options Per Question

**Problem:** 8 possible databases to choose from

**Solution:** Categorize
- Call 1: "Category?" (Relational/Document/In-Memory)
- Call 2: "Specific?" (based on category)

### Limitation 3: Can't Pre-Populate Answers

**Problem:** Want to show previous selections

**Solution:** Use skill state or file system
- Read previous config from `.claude/config.json`
- Show in skill output: "Previous choice was X"
- Ask: "Use same or change?"

### Limitation 4: No Dependent Options

**Problem:** Option B should only appear if A is selected

**Solution:** Use conditional questions
- Ask Q1
- Based on answer, ask Q2 with filtered options
- Never combine into single call
