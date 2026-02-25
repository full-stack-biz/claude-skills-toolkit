# Complete Skill Patterns

End-to-end skill workflow examples showing how to structure skills with AskUserQuestion.

## Table of Contents

- [Simple Decision Gate](#simple-decision-gate)
- [Configuration Selection](#configuration-selection)
- [Multi-Question Workflow](#multi-question-workflow)
- [Conditional Branching](#conditional-branching)
- [Iterative Collection](#iterative-collection)
- [Feature Selection](#feature-selection)
- [Validation Loop](#validation-loop)
- [Showing Progress](#showing-progress)
- [Adaptive Complexity](#adaptive-complexity)
- [Documentation Generation](#documentation-generation)
- [Writing About AskUserQuestion in Skills](#writing-about-askuserquestion-in-skills)
- [Key Principles for All Patterns](#key-principles-for-all-patterns)

## Simple Decision Gate

**Skill purpose:** Single yes/no decision

```markdown
---
name: deploy-confirm
description: Confirm deployment before proceeding
allowed-tools: AskUserQuestion
---

# Deploy Confirmation

## Ask for Confirmation

**Question:**
"Deploy to production?"

**Options:**
- Yes (Proceed with deployment)
- No (Cancel)

## Based on Answer

If Yes:
  Log: "Starting deployment..."
  [Execute deployment steps]
  Log: "✓ Deployment complete"

If No:
  Log: "Deployment cancelled"
  Exit
```

## Configuration Selection

**Skill purpose:** Choose one configuration from options

```markdown
---
name: setup-environment
description: Configure application environment
allowed-tools: AskUserQuestion, Write
---

# Environment Setup

## Step 1: Choose Environment

**Question:**
"Which environment?"

**Options:**
- Development (Local machine, relaxed constraints)
- Staging (Pre-production testing)
- Production (Live environment, strict safety)

## Step 2: Configure Based on Selection

If Development:
  Set: DEBUG=true
  Set: LOG_LEVEL=debug
  Set: CACHE=disabled

If Staging:
  Set: DEBUG=false
  Set: LOG_LEVEL=info
  Set: CACHE=enabled

If Production:
  Set: DEBUG=false
  Set: LOG_LEVEL=warning
  Set: CACHE=enabled
  Set: BACKUPS=enabled

## Step 3: Create Configuration

Write .env file with settings
Log: "✓ Configuration created for [environment]"
```

## Multi-Question Workflow

**Skill purpose:** Gather multiple related inputs

```markdown
---
name: init-project
description: Initialize new project with setup questions
allowed-tools: AskUserQuestion, Write
---

# Project Initialization

## Question 1: Project Name

Ask: "Project name?"
Options: (user types custom)

[Get answer: projectName]

## Question 2: Type

Ask: "Project type?"
Options:
- Web Application
- CLI Tool
- Library

[Get answer: projectType]

## Question 3: Language

Ask: "Programming language?"
Options:
- Python
- JavaScript
- Go

[Get answer: language]

## Question 4: Include Tests?

Ask: "Include test framework?"
Options:
- Yes (recommended)
- No

[Get answer: includeTests]

## Step 5: Generate Project

Create directory: [projectName]
Create: package.json / pyproject.toml / go.mod
  - Type: [projectType]
  - Language: [language]

If includeTests = Yes:
  Add test framework
  Create example test

Log: "✓ Project [projectName] created"
```

## Conditional Branching

**Skill purpose:** Different flows based on user choice

```markdown
---
name: deploy-setup
description: Setup deployment with conditional options
allowed-tools: AskUserQuestion, Write
---

# Deployment Setup

## Question 1: Deployment Platform

Ask: "Deployment platform?"
Options:
- AWS
- GCP
- Azure
- Local

[Get answer: platform]

## Conditional: Platform-Specific Questions

If AWS:
  Ask: "AWS Region?"
  Options: us-east-1, us-west-2, eu-west-1
  Ask: "EC2 or Lambda?"
  Options: EC2, Lambda, ECS
  [Get answers]

If GCP:
  Ask: "GCP Project?"
  Options: [List user's projects]
  Ask: "App Engine or Cloud Run?"
  Options: App Engine, Cloud Run, GKE
  [Get answers]

If Azure:
  Ask: "Azure Region?"
  Options: eastus, westus, westeurope
  Ask: "App Service or Container?"
  Options: App Service, ACI, AKS
  [Get answers]

If Local:
  Ask: "Container or Direct?"
  Options: Docker, Direct installation
  [Get answers]

## Step 3: Generate Configuration

Based on all answers:
Create deployment config for [platform]
  Set: Region = [region]
  Set: Service = [service]
  Set: [platform-specific settings]

Log: "✓ Deployment configured for [platform]"
```

## Iterative Collection

**Skill purpose:** Ask same question multiple times, build list

```markdown
---
name: add-team-members
description: Collect team member information iteratively
allowed-tools: AskUserQuestion, Write
---

# Add Team Members

## Question 1: How many members?

Ask: "Team size?"
Options:
- 2-3 people
- 4-5 people
- 6+ people

[Get answer: teamSize]

## Step 2: Collect Each Member

FOR i = 1 to teamSize:

  Ask: "Role for member [i]?"
  Options:
  - Frontend Developer
  - Backend Developer
  - DevOps Engineer
  - QA Engineer
  [Get answer]

  Ask: "Can review PRs?"
  Options: Yes, No
  [Get answer]

  Store: {role, canReview}

## Step 3: Create Team Configuration

Create team.json:
  members: [
    {role: "Frontend", canReview: true},
    {role: "Backend", canReview: true},
    {role: "DevOps", canReview: false}
  ]

Log: "✓ Team configuration created"
```

## Feature Selection

**Skill purpose:** Multi-select features to enable

```markdown
---
name: configure-features
description: Enable/disable application features
allowed-tools: AskUserQuestion, Write
---

# Feature Configuration

## Question: Select Features

Ask: "Which features to enable?"
multiSelect: true

Options:
- Logging (Application logging)
- Monitoring (Performance metrics)
- Analytics (User analytics)
- Backups (Automatic backups)
- CDN (Content delivery network)

[User can select any combination]

[Get answer: features (comma-separated)]

## Step 2: Enable Selected Features

Parse features from answer:
  featureList = split answer by ", "

For each feature in featureList:
  If Logging:
    Enable logging service
  If Monitoring:
    Enable monitoring service
  If Analytics:
    Enable analytics service
  If Backups:
    Enable backup service
  If CDN:
    Enable CDN configuration

## Step 3: Create Configuration

Create config.json:
  features: {
    logging: [true/false],
    monitoring: [true/false],
    ...
  }

Log selected features
```

## Validation Loop

**Skill purpose:** Ask questions, validate, allow corrections

```markdown
---
name: config-with-validation
description: Configure with validation and retry
allowed-tools: AskUserQuestion, Write
---

# Configuration with Validation

## Step 1: Ask Questions

Ask 1: "Database?"
Options: PostgreSQL, MongoDB

Ask 2: "Environment?"
Options: dev, staging, prod

[Get answers]

## Step 2: Validate

Validate compatibility:
- If PostgreSQL + prod:
    ✓ Valid (well-supported)
  If MongoDB + staging:
    ✓ Valid (well-supported)

If validation fails:
  Log error: "Configuration conflict: [details]"
  Log: "Incompatible choices detected"

  Ask: "Fix or proceed?"
  Options:
  - Fix (reconfigure)
  - Proceed (continue with warning)
  - Cancel (abort)

  If Fix:
    Go back to Step 1
  If Proceed:
    Log warning
    Continue
  If Cancel:
    Exit

## Step 3: Apply Configuration

Write configuration with validated answers
```

## Showing Progress

**Skill purpose:** Multi-phase setup with progress indication

```markdown
---
name: progressive-setup
description: Setup in phases with progress display
allowed-tools: AskUserQuestion, Write
---

# Progressive Project Setup

## Phase 1/5: Basic Info

Ask: "Project name?"
Ask: "Project type?"

[Get answers]

## Phase 2/5: Tech Stack

Ask: "Language?"
Ask: "Framework?"

[Get answers]

## Phase 3/5: Tooling

Ask: "Package manager?"
Ask: "Test framework?"

[Get answers]

## Phase 4/5: Deployment

Ask: "Deployment platform?"
Ask: "Environment strategy?"

[Get answers]

## Phase 5/5: Confirmation

Show summary:
"Project: [name]
Type: [type]
Language: [language]
..."

Ask: "Create project?" (Yes/No)

If Yes:
  Generate all files
  Log: "✓ Project created"

If No:
  Log: "Aborted"
  Exit
```

## Adaptive Complexity

**Skill purpose:** Simple vs advanced configuration

```markdown
---
name: config-adapter
description: Configure with user-chosen complexity
allowed-tools: AskUserQuestion, Write
---

# Adaptive Configuration

## Question 1: Complexity Level

Ask: "Configuration level?"
Options:
- Quick (Recommended defaults)
- Standard (Common customization)
- Advanced (Full control)

[Get answer: complexity]

## Conditional: Based on Complexity

If Quick:
  Use defaults
  Ask minimal questions
  (Database? Storage?)
  Done

If Standard:
  Ask moderate questions
  (Database, Storage, Caching, Monitoring)

If Advanced:
  Ask all questions
  (Database, Storage, Caching, Monitoring, Security,
   Performance tuning, Advanced options)

[Get all answers]

## Step 3: Generate Configuration

Apply defaults (Quick)
Apply standard overrides (Standard)
Apply advanced settings (Advanced)

Create final configuration
```

## Documentation Generation

**Skill purpose:** Ask questions, generate docs

```markdown
---
name: doc-generator
description: Generate documentation from configuration choices
allowed-tools: AskUserQuestion, Write
---

# Configuration to Documentation

## Step 1: Ask Configuration Questions

Ask: "Project name?"
Ask: "What does it do?"
Ask: "Technology stack?"
Ask: "Team members?"

[Get answers]

## Step 2: Generate README

Create README.md:

# [Project Name]

## Overview
[Description from answer]

## Tech Stack
[Technologies from answer]

## Team
[Team members from answer]

## Getting Started
[Generated based on tech stack]

## Testing
[Generated based on project type]

## Deployment
[Generated based on tech stack]

## Contributing
[Standard template]

Log: "✓ README.md created"
```

## Writing About AskUserQuestion in Skills

### In Skill Description

State that skill uses AskUserQuestion:

```
description: >-
  Configure project settings interactively.
  Use when [trigger]. Asks about [topics]
  through guided questions.
```

### In Skill Body

Explain what you're asking and why:

```
## Interactive Setup

This skill will ask you about:
- Project type (Web/Mobile/CLI)
- Framework preference
- Additional features

You can select from options or type custom values.

## Step 1: Project Type

[Ask question...]
```

### Document Custom Input Support

```
You can:
- Select from provided options
- Type custom values by selecting "Other"

Example:
- Provided: React, Vue, Svelte
- Custom: "next.js", "nuxt", "angular"
```

## Key Principles for All Patterns

1. **One question per call** - Ask → wait → ask next
2. **Conditional logic** - Different Q2 based on Q1
3. **Process all answers** - Use all gathered info
4. **Validate before applying** - Check compatibility
5. **Provide feedback** - Show what was configured
6. **Support custom input** - Handle "Other" selections
7. **Progressive disclosure** - Simple → complex as needed
