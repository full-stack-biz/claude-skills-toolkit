# Evaluation Schema Reference

Complete JSON schemas for all evaluation data files created during the skill-tester pipeline.

---

## evals.json — Test Case Definitions

**Location:** `<skill-location>/evals/evals.json`

**Purpose:** Central registry of all test cases for a skill. Defines what the skill is being tested on.

**Schema:**

```json
{
  "skill_name": "string (required) — name of skill being tested",
  "skill_path": "string (required) — path to SKILL.md file",
  "description": "string (required) — one-line purpose of skill",
  "evals": [
    {
      "id": "integer (required) — unique eval identifier (1, 2, 3, ...)",
      "name": "string (required) — short eval scenario name",
      "prompt": "string (required) — complete user prompt for this test case",
      "expected_output": "string (required) — description of good output",
      "files": [
        "string (optional) — file paths that should be created or modified"
      ]
    }
  ]
}
```

**Example:**

```json
{
  "skill_name": "skill-creator",
  "skill_path": "skills/skill-creator/SKILL.md",
  "description": "Test skill creation workflow and best practices guidance",
  "evals": [
    {
      "id": 1,
      "name": "Create new skill from scratch",
      "prompt": "Create a new Claude Code skill for converting CSV files to JSON. Include SKILL.md with frontmatter, body instructions, and references organized by workflow stage.",
      "expected_output": "Complete skill structure with SKILL.md (name, description, version), references/ for detailed guides, clear trigger phrases, <500 line body",
      "files": ["SKILL.md", "references/csv-parsing.md", "scripts/converter.py"]
    },
    {
      "id": 2,
      "name": "Convert slash command to skill",
      "prompt": "Convert the ~/.claude/commands/format-json slash command (existing formatter) into a project-scoped skill at myproject/.claude/skills/json-formatter/",
      "expected_output": "Skill structure: SKILL.md with frontmatter, body instructions, correct scope designation (project-scoped), preserved functionality",
      "files": ["SKILL.md"]
    }
  ]
}
```

---

## eval_metadata.json — Assertions Per Eval

**Location:** `<workspace>/iteration-N/eval-M/eval_metadata.json`

**Purpose:** Define what "success" means for a specific eval. Contains assertions Claude will check against outputs.

**Schema:**

```json
{
  "eval_id": "integer (required) — which eval this metadata applies to",
  "skill_path": "string (required) — path to SKILL.md being tested",
  "assertions": [
    {
      "text": "string (required) — assertion to verify (e.g., 'Output includes a clear skill name')",
      "type": "string (required) — assertion category: 'presence', 'quality', 'structure', 'functionality'",
      "target": "string (required) — where to look for this assertion (e.g., 'SKILL.md frontmatter', 'references/ directory', 'outputs/ directory')"
    }
  ]
}
```

**Assertion Types:**

- `presence` — File/section/field exists (or is absent)
- `quality` — Content meets quality criteria (clarity, specificity, completeness)
- `structure` — Directory layout, file organization, nesting levels match requirements
- `functionality` — Skill performs expected action, produces expected behavior

**Example:**

```json
{
  "eval_id": 1,
  "skill_path": "skills/skill-creator/SKILL.md",
  "assertions": [
    {
      "text": "SKILL.md has frontmatter with name, description, version",
      "type": "presence",
      "target": "SKILL.md frontmatter (first 10 lines)"
    },
    {
      "text": "Description includes specific trigger phrases (e.g., 'create', 'new skill', 'best practices')",
      "type": "quality",
      "target": "SKILL.md frontmatter description field"
    },
    {
      "text": "Body is <500 lines and includes 'Quick Start' section",
      "type": "structure",
      "target": "SKILL.md body"
    },
    {
      "text": "References/ directory has one-level nesting (no nested subdirectories)",
      "type": "structure",
      "target": "references/ directory tree"
    },
    {
      "text": "All reference links in SKILL.md body have corresponding .md files",
      "type": "functionality",
      "target": "SKILL.md body cross-references vs. references/ files"
    }
  ]
}
```

---

## grading.json — Assertion Results

**Location:** `<workspace>/iteration-N/eval-M/with_skill/grading.json` and `baseline/grading.json`

**Purpose:** Record whether each assertion passed or failed. Includes evidence quotes from outputs.

**Schema:**

```json
{
  "eval_id": "integer (required) — which eval this grades",
  "configuration": "string (required) — 'with_skill' or 'baseline'",
  "assertions_evaluated": [
    {
      "text": "string (required) — assertion text (from eval_metadata.json)",
      "passed": "boolean (required) — true if assertion passed",
      "evidence": "string (required) — quote or reference from output proving pass/fail"
    }
  ],
  "summary": {
    "assertions_total": "integer — total assertions evaluated",
    "assertions_passed": "integer — count of passed assertions",
    "pass_rate": "float (0.0–1.0) — assertions_passed / assertions_total"
  }
}
```

**Example:**

```json
{
  "eval_id": 1,
  "configuration": "with_skill",
  "assertions_evaluated": [
    {
      "text": "SKILL.md has frontmatter with name, description, version",
      "passed": true,
      "evidence": "Lines 1–9: ---\\nname: skill-csv-converter\\ndescription: Convert CSV...\\nversion: 1.0.0"
    },
    {
      "text": "Description includes specific trigger phrases",
      "passed": true,
      "evidence": "Description: 'Create NEW Claude Code skills...', 'building new skills', 'converting slash commands'"
    },
    {
      "text": "Body is <500 lines and includes 'Quick Start' section",
      "passed": true,
      "evidence": "SKILL.md body: 387 lines total, includes '## Quick Start' at line 23"
    },
    {
      "text": "References/ directory has one-level nesting",
      "passed": true,
      "evidence": "references/: csv-parsing.md, examples.md (no subdirectories)"
    },
    {
      "text": "All reference links in SKILL.md body have corresponding .md files",
      "passed": true,
      "evidence": "Body mentions: references/csv-parsing.md ✓, references/examples.md ✓"
    }
  ],
  "summary": {
    "assertions_total": 5,
    "assertions_passed": 5,
    "pass_rate": 1.0
  }
}
```

**Baseline example (lower pass rate):**

```json
{
  "eval_id": 1,
  "configuration": "baseline",
  "assertions_evaluated": [
    {
      "text": "SKILL.md has frontmatter with name, description, version",
      "passed": true,
      "evidence": "Includes name, description, version"
    },
    {
      "text": "Description includes specific trigger phrases",
      "passed": false,
      "evidence": "Description: 'This skill converts data' (vague, no specific trigger phrases)"
    },
    {
      "text": "Body is <500 lines and includes 'Quick Start' section",
      "passed": false,
      "evidence": "SKILL.md body: 847 lines (exceeds 500), no 'Quick Start' section"
    },
    {
      "text": "References/ directory has one-level nesting",
      "passed": true,
      "evidence": "references/: *.md files, no subdirs"
    },
    {
      "text": "All reference links in SKILL.md body have corresponding .md files",
      "passed": false,
      "evidence": "Body mentions: references/parser.md ✗ (doesn't exist)"
    }
  ],
  "summary": {
    "assertions_total": 5,
    "assertions_passed": 2,
    "pass_rate": 0.4
  }
}
```

---

## timing.json — Execution Metrics

**Location:** `<workspace>/iteration-N/eval-M/with_skill/timing.json` and `baseline/timing.json`

**Purpose:** Track resource usage (tokens, wall-clock time) for each eval run.

**Schema:**

```json
{
  "total_tokens": "integer (required) — total tokens consumed (input + output)",
  "duration_ms": "integer (required) — wall-clock execution time in milliseconds",
  "model": "string (required) — model used (e.g., 'claude-opus-4-6')",
  "timestamp": "string (optional) — ISO 8601 timestamp when eval ran"
}
```

**Example:**

```json
{
  "total_tokens": 2847,
  "duration_ms": 8234,
  "model": "claude-opus-4-6",
  "timestamp": "2026-03-04T10:35:22Z"
}
```

---

## benchmark.json — Aggregated Results

**Location:** `<workspace>/iteration-N/benchmark.json`

**Purpose:** Summary statistics across all evals for an iteration. Generated by `aggregate_benchmark.rb`.

**Schema:**

```json
{
  "skill_name": "string — name of skill being tested",
  "iteration": "integer — iteration number (1, 2, 3, ...)",
  "timestamp": "string — ISO 8601 timestamp when aggregation ran",
  "evals": [
    {
      "eval_id": "integer — eval identifier",
      "with_skill": {
        "pass_rate": "float (0.0–1.0) — assertions passed / total",
        "assertions_passed": "integer",
        "assertions_total": "integer",
        "avg_tokens": "integer — tokens for this eval",
        "avg_duration_ms": "integer — duration for this eval"
      },
      "baseline": {
        "pass_rate": "float (0.0–1.0)",
        "assertions_passed": "integer",
        "assertions_total": "integer",
        "avg_tokens": "integer",
        "avg_duration_ms": "integer"
      },
      "delta": {
        "pass_rate": "float — with_skill - baseline (positive = improvement)",
        "tokens": "integer — with_skill - baseline (positive = more tokens)",
        "duration_ms": "integer — with_skill - baseline (positive = slower)"
      }
    }
  ],
  "summary": {
    "with_skill_avg_pass_rate": "float — average pass rate across all evals with skill",
    "baseline_avg_pass_rate": "float — average pass rate across all evals without skill",
    "improvement": "float — with_skill - baseline (percentage points)",
    "avg_tokens_with_skill": "integer — average tokens with skill",
    "avg_tokens_baseline": "integer — average tokens without skill",
    "token_cost": "integer — with_skill - baseline (positive = more expensive)",
    "avg_duration_ms_with_skill": "integer",
    "avg_duration_ms_baseline": "integer",
    "duration_cost_ms": "integer"
  }
}
```

**Example:**

```json
{
  "skill_name": "skill-creator",
  "iteration": 1,
  "timestamp": "2026-03-04T11:02:15Z",
  "evals": [
    {
      "eval_id": 1,
      "with_skill": {
        "pass_rate": 1.0,
        "assertions_passed": 5,
        "assertions_total": 5,
        "avg_tokens": 2847,
        "avg_duration_ms": 8234
      },
      "baseline": {
        "pass_rate": 0.4,
        "assertions_passed": 2,
        "assertions_total": 5,
        "avg_tokens": 1923,
        "avg_duration_ms": 5123
      },
      "delta": {
        "pass_rate": 0.6,
        "tokens": 924,
        "duration_ms": 3111
      }
    },
    {
      "eval_id": 2,
      "with_skill": {
        "pass_rate": 0.8,
        "assertions_passed": 4,
        "assertions_total": 5,
        "avg_tokens": 2156,
        "avg_duration_ms": 6789
      },
      "baseline": {
        "pass_rate": 0.6,
        "assertions_passed": 3,
        "assertions_total": 5,
        "avg_tokens": 1876,
        "avg_duration_ms": 4567
      },
      "delta": {
        "pass_rate": 0.2,
        "tokens": 280,
        "duration_ms": 2222
      }
    }
  ],
  "summary": {
    "with_skill_avg_pass_rate": 0.9,
    "baseline_avg_pass_rate": 0.5,
    "improvement": 0.4,
    "avg_tokens_with_skill": 2502,
    "avg_tokens_baseline": 1900,
    "token_cost": 602,
    "avg_duration_ms_with_skill": 7512,
    "avg_duration_ms_baseline": 4845,
    "duration_cost_ms": 2667
  }
}
```

---

## Workspace Directory Structure (Standardized)

All evaluation artifacts live in a **centralized `./evals/` directory at project root**, not inside skill directories:

```
./evals/                                      ← Project root (standardized location)
├── skill-creator/
│   ├── evals.json                           ← Test case definitions
│   └── workspace/
│       ├── iteration-1/
│       │   ├── eval-1/
│       │   │   ├── eval_metadata.json        ← Assertions for eval-1
│       │   │   ├── with_skill/
│       │   │   │   ├── outputs/              ← Files created by agent
│       │   │   │   ├── grading.json          ← Pass/fail results
│       │   │   │   └── timing.json           ← Execution metrics
│       │   │   └── baseline/
│       │   │       ├── outputs/
│       │   │       ├── grading.json
│       │   │       └── timing.json
│       │   ├── eval-2/
│       │   │   └── (same structure)
│       │   └── benchmark.json                ← Aggregated results (Ruby output)
│       ├── iteration-2/
│       │   └── (same structure, updated skill)
│       └── iteration-3/
│           └── (same structure)
│
├── skill-refiner/
│   └── (same structure for other skills)
│
└── other-skills/
    └── ...
```

**Advantages:**
- Easy to compare multiple skills' test results in one place
- Keeps skill directories clean (no `/evals/` subdirs inside skills/)
- Natural location for project-wide evaluation data
- Simplifies path references in automation and scripts

---

## aggregate_benchmark.rb — The Aggregation Script

The Ruby script reads all `grading.json` and `timing.json` files from an iteration directory and produces `benchmark.json`.

**Invocation:**

```bash
ruby skills/skill-tester/scripts/aggregate_benchmark.rb ./evals/<skill-name>/workspace/iteration-N
```

**Example:**

```bash
ruby skills/skill-tester/scripts/aggregate_benchmark.rb ./evals/skill-creator/workspace/iteration-1
```

**Output:**

```
✓ Benchmark aggregated: workspace/iteration-1/benchmark.json

Summary:
  Evals processed: 2
  With Skill pass rate: 90.0%
  Baseline pass rate: 50.0%
  Improvement: +40.0 percentage points
  Token cost: +602
  Duration cost: +2667ms
```

**Logic:**

1. Discover all `eval-N/` directories
2. For each eval:
   - Read `with_skill/grading.json` → extract pass_rate
   - Read `baseline/grading.json` → extract pass_rate
   - Read `with_skill/timing.json` → extract total_tokens, duration_ms
   - Read `baseline/timing.json` → extract total_tokens, duration_ms
   - Calculate delta (with_skill - baseline)
3. Compute summary statistics:
   - Average pass rates across all evals
   - Average tokens and duration across all evals
   - Calculate improvement (with_skill - baseline)
4. Write `benchmark.json` with all results

See skill-tester `SKILL.md` Phase 5 for integration instructions.
