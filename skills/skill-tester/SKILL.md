---
name: skill-tester
description: >-
  Test and benchmark Claude Code skills empirically using evaluation-driven development.
  Use when validating a skill's effectiveness, comparing skill vs. baseline performance,
  running benchmarks with timing/token metrics, and iterating on skill improvements.
  Two modes: Quick Workflow (with_skill only, no baseline, fast pass/fail) or Full Pipeline (7-phase with baseline comparison, timing, aggregation).
version: 1.1.0
allowed-tools: Read,Write,Edit,Glob,Grep,Agent,Bash,AskUserQuestion
---

# Skill Tester

**Purpose:** Empirically validate Claude Code skills through evaluation-driven testing. Proves skills actually help Claude (with data) rather than guessing.

## Mindset

Skills must be **measured, not assumed**. This pipeline provides systematic evidence: Does the skill improve Claude's performance? By how much? What should we improve next?

## Core Use Cases

**Validate new skills** — Test a newly created skill against baseline Claude performance without it.
**Benchmark improvements** — Measure impact of skill refinements across multiple iterations.
**Comparative analysis** — Prove skill effectiveness with timing, token usage, and pass rates side-by-side.
**Iteration planning** — Data-driven decisions on what to improve next.

## Core Principles

**Empirical Evidence** — Intuition ≠ proof. Collect actual performance data: pass rates, tokens, timing.

**Parallel Testing** — For each eval, test WITH skill AND baseline SIMULTANEOUSLY (2 agents per eval, in parallel). Eliminates confounding variables from different test runs.

**Workspace Isolation** — Each iteration lives in `workspace/iteration-N/`. Keeps history clean. Easy to compare iteration 1 → 2 → 3 performance.

**Schema Consistency** — All JSON outputs follow strict schemas (evals.json, grading.json, benchmark.json, timing.json). Enables reliable aggregation and comparison.

## Quick Start: The 7-Phase Pipeline

```
Phase 1: Setup          → Identify skill + confirm what it does
Phase 2: Create Evals   → Interview user → write test cases + assertions
Phase 3: Run Tests      → Launch 2 agents per eval (with_skill + baseline) in parallel
Phase 4: Grade Results  → Evaluate outputs against assertions
Phase 5: Aggregate      → Run ruby script to compute benchmark.json
Phase 6: Review Summary → Show comparison table + improvement suggestions
Phase 7: Iterate        → Update skill + run next iteration (or stop if satisfied)
```

## Artifact Location (Standardized)

**All evaluation artifacts live in a centralized `./evals/` directory at project root:**

```
./evals/                          ← Project root, NOT inside skill directory
├── <skill-name-1>/
│   ├── evals.json
│   └── workspace/
│       ├── iteration-1/
│       │   ├── eval-1/, eval-2/, eval-3/  ← Per-eval directories
│       │   └── benchmark.json              ← Aggregated results
│       └── iteration-2/
│           └── ...
└── <skill-name-2>/
    └── ...
```

**Why centralized?**
- Easy to compare multiple skills' test results
- Keeps skill directories clean (no /evals/ subdirs)
- Natural location for project-wide evaluation data
- Simplifies path references in automation

---

## PHASE 1: Setup

**Goal:** Identify the skill being tested. Confirm what it does. Prepare workspace.

### Step 1.1: Ask User - Which Skill?

Use AskUserQuestion to ask which skill to test:

```
question: "Which skill do you want to test?"
header: "Skill Selection"
options: [
  {label: "skill-creator", description: "Testing skill-creator from skills/ directory"},
  {label: "skill-refiner", description: "Testing skill-refiner from skills/ directory"},
  {label: "Other skill", description: "Testing a skill not listed above"}
]
```

⏸️ **Collect user input.** Wait for response before proceeding.

### Step 1.2: Confirm Skill Path & Purpose

Read the skill's SKILL.md to understand:
- What does this skill do?
- What are its core use cases?
- What problem does it solve?

Show user a summary:
```
Skill: <name>
Location: <path>
Purpose: <one-line summary from description>
```

### Step 1.2b: Choose Workflow Mode

**Question:** Which testing mode do you want?

Use AskUserQuestion with 2 options:

```
questions: [
  {
    question: "Which testing mode would you like?",
    header: "Workflow Mode",
    options: [
      {
        label: "Quick Workflow",
        description: "Fast validation: only test WITH skill (no baseline), no timing metrics. Just pass/fail on assertions. Perfect for quick checks."
      },
      {
        label: "Full Pipeline",
        description: "Complete analysis: test WITH skill + baseline parallel, measure tokens/timing, aggregate & compare. For comprehensive benchmarking."
      }
    ],
    multiSelect: false
  }
]
```

⏸️ **Collect user input.**

**If Quick Workflow selected:**
- Skip to Phase 2 with note: "Quick mode: only with_skill, no baseline comparison"
- Jump to simplified Phase 3 (only 1 agent per eval)
- Skip Phase 5 (aggregation) and Phase 6 comparison tables
- Show simple pass/fail results

**If Full Pipeline selected:**
- Continue with standard 7-phase pipeline (proceed to Step 1.3)

### Step 1.3: Create Workspace

Create directory structure in project root (standardized):
```
./evals/<skill-name>/
./evals/<skill-name>/workspace/iteration-1/
```

Example for skill-creator:
```
./evals/skill-creator/
./evals/skill-creator/workspace/iteration-1/
```

Log workspace path. All subsequent phases write to this directory (NOT inside the skill's directory).

---

## PHASE 2: Create Evals

**Goal:** Build evaluation cases that measure skill effectiveness.

### Step 2.1: Interview User for Test Scenarios

Ask 3 questions (use AskUserQuestion with free-form "Other" option):

```
Question 1: "What are 2-3 core scenarios this skill should handle?"
Example: "skill-creator should handle: creating a new skill from scratch,
converting a slash command, improving an existing skill"

Question 2: "For each scenario, what makes a GOOD response?"
Example: "Good responses: skill has clear name, description with trigger phrases,
correct SKILL.md structure, efficient references/"

Question 3: "What should FAIL (baseline without skill)?"
Example: "Baseline will miss best practices, create vague descriptions,
skip necessary structure"
```

⏸️ **Collect responses.** Store in memory.

### Step 2.2: Generate evals.json

Create `evals.json` with structure:

```json
{
  "skill_name": "<name>",
  "skill_path": "<path/to/SKILL.md>",
  "description": "<purpose summary>",
  "evals": [
    {
      "id": 1,
      "name": "<scenario name>",
      "prompt": "<complete user prompt for this eval>",
      "expected_output": "<description of what good output looks like>",
      "files": []
    },
    {
      "id": 2,
      ...
    }
  ]
}
```

Write to `./evals/<skill-name>/evals.json` (project root, standardized location).

### Step 2.3: Generate eval_metadata.json Files

For each eval (one per directory), create `workspace/iteration-1/eval-N/eval_metadata.json`:

```json
{
  "eval_id": N,
  "skill_path": "<path/to/SKILL.md>",
  "assertions": [
    {
      "text": "Output includes a clear skill name",
      "type": "presence",
      "target": "SKILL.md frontmatter"
    },
    {
      "text": "Description has specific trigger phrases",
      "type": "quality",
      "target": "SKILL.md frontmatter description field"
    },
    {
      "text": "References are organized with one-level nesting",
      "type": "structure",
      "target": "references/ directory"
    }
  ]
}
```

Create directories: `workspace/iteration-1/eval-1/`, `eval-2/`, etc. (with_skill and baseline subdirs will be created in Phase 3).

---

## QUICK WORKFLOW (Alternative Path)

**If user chose "Quick Workflow" in Step 1.2b, follow this streamlined path instead of Phases 3-7.**

### Quick Phase 1: Run WITH_SKILL Only (No Baseline)

**Goal:** Test the skill itself. No baseline comparison, no timing metrics. Just: Does it work?

For EACH eval in evals.json, launch ONE agent (no parallel baseline):

```
Agent (WITH_SKILL_ONLY):
  Type: general-purpose
  Prompt: "
You are testing a Claude Code skill. Your job: HELP THE USER ACCOMPLISH THEIR TASK
using the skill provided below.

SKILL TO USE:
<read and include full SKILL.md content>

USER TASK:
<eval-N prompt from evals.json>

After completing the task, save all outputs to:
./evals/<skill-name>/workspace/iteration-1/eval-N/with_skill/outputs/

NO timing metrics needed for quick workflow. Just save your work."
```

⏸️ **Wait for agent completion before proceeding to next eval.**

### Quick Phase 2: Grade Results (Assertions Only)

For each eval, manually grade against assertions:
- Does with_skill output satisfy each assertion?
- Record pass/fail (no baseline comparison)
- Save to: `./evals/<skill-name>/workspace/iteration-1/eval-N/with_skill/grading.json`

```json
{
  "eval_id": N,
  "configuration": "with_skill",
  "assertions_evaluated": [
    {"text": "...", "passed": true/false, "evidence": "..."}
  ],
  "summary": {
    "assertions_total": X,
    "assertions_passed": Y,
    "pass_rate": Y/X
  }
}
```

### Quick Phase 3: Show Results

Display simple pass/fail summary (no benchmark.json):

```
QUICK VALIDATION RESULTS: <skill-name>
====================================

Eval 1: <Scenario>  ✓ PASS (5/5 assertions)
Eval 2: <Scenario>  ✓ PASS (4/5 assertions)
Eval 3: <Scenario>  ✗ FAIL (2/5 assertions)

Summary: 11/15 assertions passed (73%)
Status: Ready to refine or deploy
```

### Quick Phase 4: Next Steps

Ask user:

```
question: "What would you like to do?"
header: "Next Steps"
options: [
  {label: "Run full pipeline", description: "Move to complete benchmarking with baseline comparison"},
  {label: "Refine skill", description: "Update skill based on failed assertions"},
  {label: "Done", description: "Quick validation complete"}
]
```

---

## PHASE 3: Run Tests

**Goal:** Execute 2 agents per eval (WITH skill + BASELINE) in parallel. Capture outputs.

### Step 3.1: Spawn Agents (Parallel Execution)

For EACH eval, launch 2 agents SIMULTANEOUSLY in one Agent tool call:

**Agent 1 (WITH_SKILL):**
```
Agent type: general-purpose
Prompt: "
You are testing a Claude Code skill. Your job: HELP THE USER ACCOMPLISH THEIR TASK
using the skill provided below.

SKILL TO USE:
<read and include full SKILL.md content>

USER TASK:
<eval-N prompt from evals.json>

After completing the task, save all outputs (code, files, notes) to:
./evals/<skill-name>/workspace/iteration-1/eval-N/with_skill/outputs/

Then create a file ./evals/<skill-name>/workspace/iteration-1/eval-N/with_skill/timing.json with:
{
  \"total_tokens\": <count>,
  \"duration_ms\": <milliseconds>,
  \"model\": \"claude-opus-4-6\"
}
"
```

**Agent 2 (BASELINE):**
```
Agent type: general-purpose
Prompt: "
You are testing a Claude Code skill by providing a BASELINE. Your job: HELP THE USER
accomplish their task WITHOUT any special skill or methodology.

USER TASK:
<eval-N prompt from evals.json>

NO SKILLS AVAILABLE. Use standard Claude capabilities only.

After completing the task, save all outputs (code, files, notes) to:
./evals/<skill-name>/workspace/iteration-1/eval-N/baseline/outputs/

Then create a file ./evals/<skill-name>/workspace/iteration-1/eval-N/baseline/timing.json with:
{
  \"total_tokens\": <count>,
  \"duration_ms\": <milliseconds>,
  \"model\": \"claude-opus-4-6\"
}
"
```

⏸️ **Wait for both agents to complete before proceeding to Phase 4.**

---

## PHASE 4: Grade Results

**Goal:** Evaluate each agent's outputs against assertions in eval_metadata.json.

### Step 4.1: Review Outputs & Grade

For EACH eval:

1. Read `with_skill/outputs/` files
2. Read `baseline/outputs/` files
3. For EACH assertion in `eval-N/eval_metadata.json`:
   - Does with_skill output satisfy the assertion? (true/false)
   - Does baseline output satisfy the assertion? (true/false)
   - Collect brief evidence quotes from outputs

### Step 4.2: Write grading.json Files

Create `workspace/iteration-1/eval-N/with_skill/grading.json`:

```json
{
  "eval_id": N,
  "configuration": "with_skill",
  "assertions_evaluated": [
    {
      "text": "Output includes a clear skill name",
      "passed": true,
      "evidence": "SKILL.md line 2: name: skill-tester"
    },
    {
      "text": "Description has specific trigger phrases",
      "passed": true,
      "evidence": "Description mentions: 'validating', 'benchmarks', 'comparing performance'"
    }
  ],
  "summary": {
    "assertions_total": 3,
    "assertions_passed": 3,
    "pass_rate": 1.0
  }
}
```

Create identical file for `baseline/grading.json` with its results.

---

## PHASE 5: Aggregate

**Goal:** Compute benchmark.json with summary stats (pass rates, tokens, timing).

### Step 5.1: Run Ruby Script

Execute the aggregation script (see `references/eval-schema.md` for full script):

```bash
ruby skills/skill-tester/scripts/aggregate_benchmark.rb \
  ./evals/<skill-name>/workspace/iteration-1
```

Example:
```bash
ruby skills/skill-tester/scripts/aggregate_benchmark.rb \
  ./evals/skill-creator/workspace/iteration-1
```

This reads all grading.json and timing.json files from the standardized location, outputs `benchmark.json`:

```json
{
  "skill_name": "skill-tester",
  "iteration": 1,
  "timestamp": "2026-03-04T10:30:00Z",
  "evals": [
    {
      "eval_id": 1,
      "with_skill": {
        "pass_rate": 1.0,
        "assertions_passed": 3,
        "assertions_total": 3,
        "avg_tokens": 2500,
        "avg_duration_ms": 8000
      },
      "baseline": {
        "pass_rate": 0.67,
        "assertions_passed": 2,
        "assertions_total": 3,
        "avg_tokens": 1800,
        "avg_duration_ms": 5000
      },
      "delta": {
        "pass_rate": 0.33,
        "tokens": 700,
        "duration_ms": 3000
      }
    }
  ],
  "summary": {
    "with_skill_avg_pass_rate": 0.95,
    "baseline_avg_pass_rate": 0.70,
    "improvement": 0.25,
    "avg_tokens_with_skill": 2400,
    "avg_tokens_baseline": 1900,
    "token_cost": 500
  }
}
```

---

## PHASE 6: Review Summary

**Goal:** Show user a clear comparison table + next steps.

### Step 6.1: Render Comparison Table

Display results in human-readable format:

```
EVALUATION RESULTS: skill-tester iteration-1
==============================================

Eval 1: [Scenario Name]
  WITH SKILL:  3/3 (100%) | 2500 tokens | 8s
  BASELINE:    2/3 (67%)  | 1800 tokens | 5s
  DELTA:       +33% better | +700 tokens | +3s

Eval 2: [Scenario Name]
  WITH SKILL:  2/3 (67%)  | 2100 tokens | 7s
  BASELINE:    2/3 (67%)  | 1900 tokens | 4s
  DELTA:       Even      | +200 tokens | +3s

SUMMARY
-------
With Skill Avg:    96.5% pass rate | 2300 avg tokens
Baseline Avg:      67.0% pass rate | 1850 avg tokens
IMPROVEMENT:       +29.5 percentage points
```

### Step 6.2: Offer Next Steps

Ask user (AskUserQuestion):

```
question: "What would you like to do?"
header: "Next Steps"
options: [
  {
    label: "Iterate (update skill, run next iteration)",
    description: "Based on results, modify the skill and run workspace/iteration-2"
  },
  {
    label: "Stop (satisfied with results)",
    description: "Evaluation complete. Save benchmark data for reference"
  },
  {
    label: "Refine evals (change test cases, rerun)",
    description: "Update evals.json and run iteration again with same eval set"
  }
]
```

⏸️ **Collect user input.**

---

## PHASE 7: Iterate

**Goal:** If user chose "Iterate", update the skill and run next iteration.

### Step 7.1: Get Improvement Feedback

Ask user (AskUserQuestion, free-form):

```
question: "What would you like to improve about the skill?"
header: "Improvement"
```

⏸️ **Collect feedback.**

### Step 7.2: Update Skill

Use skill-refiner or direct edits to improve the skill based on feedback:
- Reword descriptions for clarity
- Add missing guidance to SKILL.md body
- Reorganize references
- Trim token usage

### Step 7.3: Run Next Iteration

Create `workspace/iteration-2/` directory. Repeat Phases 3–6 with updated skill.

### Step 7.4: Compare Iterations

Show delta between iteration-1 benchmark and iteration-2 benchmark:

```
ITERATION COMPARISON
====================
Iteration 1 pass rate: 67%  → Iteration 2: 95% (+28 points)
Iteration 1 tokens:   1900  → Iteration 2: 2100 (+200, acceptable)
```

Loop back to Phase 6 (Step 6.2) to ask: iterate again or stop?

---

## Token Accountability

- SKILL.md body: ~340 lines (target <500) ✓
- Frontmatter + Quick Start: ~20 lines (always loaded)
- 7 phases + subagent prompts: ~320 lines
- All detailed reference schemas and aggregate script → `references/` files

For full schemas, workflow details, and aggregate_benchmark.rb script code, see:
- `references/eval-schema.md` — JSON schemas for all eval files
- `references/workflow.md` — decision points and detailed workflow
- `scripts/aggregate_benchmark.rb` — Ruby aggregation script
