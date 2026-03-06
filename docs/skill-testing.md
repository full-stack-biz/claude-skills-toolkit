# Skill Testing with skill-tester

Empirically validate and benchmark Claude Code skills using the **skill-tester** skill.

## Overview

skill-tester provides systematic, data-driven validation of skills through:
- **Quick Workflow**: Fast pass/fail validation (with_skill only, no baseline)
- **Full Pipeline**: Comprehensive benchmarking with baseline comparison, timing, and token metrics

All evaluation artifacts are centralized in `./evals/<skill-name>/` at your project root.

## Quick Start

### Option 1: Quick Validation (Fast)

Test a skill quickly to verify it works as intended:

```bash
/skills-toolkit:skill-tester
# Follow prompts:
# 1. Select the skill to test
# 2. Choose "Quick Workflow"
# 3. Create test cases
# 4. View pass/fail results
```

**Output:** Simple pass/fail on test assertions. No baseline, no timing metrics.

**Time:** ~2-5 minutes depending on test complexity.

### Option 2: Full Benchmarking (Comprehensive)

Measure skill effectiveness with before/after comparison:

```bash
/skills-toolkit:skill-tester
# Follow prompts:
# 1. Select the skill to test
# 2. Choose "Full Pipeline"
# 3. Create test cases with assertions
# 4. Review benchmarking results with pass rates, tokens, timing
```

**Output:** Side-by-side comparison: baseline vs. with_skill performance.

**Time:** ~5-15 minutes (depends on eval complexity and test case count).

## Workspace Structure

All test artifacts organize automatically:

```
./evals/
├── skill-name/
│   ├── evals.json                    ← Test case definitions
│   └── workspace/
│       ├── iteration-1/
│       │   ├── eval-1/
│       │   │   ├── with_skill/       ← With skill enabled
│       │   │   └── baseline/         ← Without skill (Full Pipeline only)
│       │   ├── eval-2/, eval-3/, ... ← Other test cases
│       │   └── benchmark.json        ← Aggregated results
│       ├── iteration-2/
│       │   └── ...
│       └── iteration-3/
│           └── ...
```

Each iteration captures improvement history. Compare iteration 1 → 2 → 3 to see skill refinement impact.

## The 7-Phase Pipeline (Full Workflow)

skill-tester automates this workflow:

1. **Setup** - Identify skill, confirm purpose, choose mode
2. **Create Evals** - Interview for test scenarios and assertions
3. **Run Tests** - Launch 2 agents per eval in parallel (with_skill + baseline)
4. **Grade Results** - Evaluate outputs against test assertions
5. **Aggregate** - Compute metrics: pass rates, token usage, timing deltas
6. **Review Summary** - Display comparison table and insights
7. **Iterate** - Refine skill and re-test (or complete)

## Creating Test Cases

When skill-tester asks for test scenarios, provide:

### Test Case Structure

```
Scenario: [What you're testing]
Input: [The user request or context]
Expected: [What should happen if skill works]
Assertion: [How to grade the output]
```

### Example: Testing skill-composer

**Scenario:** Create a simple skill from scratch

**Input:**
```
Create a skill for validating JSON files.
Use when users ask for JSON validation.
Simple complexity, needs Read and Bash tools.
```

**Expected:**
- Skill has proper frontmatter (name, description)
- SKILL.md body is under 500 lines
- Includes basic validation workflow

**Assertion:**
Check if SKILL.md contains all three elements above. Pass if all present.

### Example: Testing skill-refiner

**Scenario:** Improve clarity of an existing skill

**Input:** [Provide a skill with vague description]

**Expected:**
- Description clarified with specific trigger phrases
- Token count improved or maintained

**Assertion:**
Compare original vs. refined: does refined version include 2+ specific trigger phrases?

## Interpreting Results

### Quick Workflow Results

```
Test Case 1: [scenario name]
Status: PASS ✓
Status: FAIL ✗ (reason)
```

No timing or token data. Just validation that skill works.

### Full Pipeline Results

```json
{
  "skill": "skill-composer",
  "iteration": 1,
  "eval_count": 3,
  "baseline_pass_rate": "66.7%",
  "with_skill_pass_rate": "100%",
  "improvement": "+33.3%",
  "token_delta": "-15%",
  "timing_delta": "-8%"
}
```

**Key metrics:**
- **Pass Rate** - % of test cases that passed
- **Improvement** - Gain from skill vs. baseline
- **Token Delta** - Change in token usage (negative = better)
- **Timing Delta** - Change in execution time (negative = better)

## Workflow: Quick Iteration

### Test → Refine → Re-test

**Iteration 1:**
1. Run Quick Workflow on new skill
2. View results
3. Identify failures

**Iteration 2:**
1. Refine skill based on failures
2. Run Full Pipeline for comprehensive comparison
3. Review benchmark.json

**Iteration 3+:**
1. Continue refining
2. Re-run tests
3. Compare iteration-1 vs. iteration-2 vs. iteration-3 benchmarks

## Using skill-tester in Your Workflow

### For New Skills (After skill-composer)

```bash
# 1. Create skill with skill-composer
/skills-toolkit:skill-composer
# ... create skill ...

# 2. Test it with skill-tester
/skills-toolkit:skill-tester
# Choose: Quick Workflow (fast validation)
# Verify it works

# 3. Refine and re-test
/skills-toolkit:skill-refiner
# ... improve based on test results ...

/skills-toolkit:skill-tester
# Choose: Full Pipeline (comprehensive benchmarking)
```

### For Existing Skills (Before skill-refiner)

```bash
# 1. Benchmark current performance
/skills-toolkit:skill-tester
# Full Pipeline on existing skill
# Get baseline iteration-1 results

# 2. Refine the skill
/skills-toolkit:skill-refiner
# ... improve skill ...

# 3. Re-test to see improvement
/skills-toolkit:skill-tester
# Creates iteration-2
# Compare iteration-1 vs. iteration-2 in benchmark.json
```

## Advanced: Accessing Test Artifacts

All test outputs are in `./evals/<skill-name>/workspace/iteration-N/`:

- **eval-N/with_skill/outputs/** - Test results when skill is active
- **eval-N/baseline/outputs/** - Test results without skill (Full Pipeline only)
- **benchmark.json** - Aggregated stats for the iteration
- **evals.json** - Original test case definitions

Read these files to:
- Debug test failures
- Compare outputs manually
- Extract specific metrics for reporting

## Troubleshooting

**Test keeps failing:**
- Review the assertion: is it too strict?
- Run Quick Workflow first to see actual output
- Refine the skill based on what you see
- Re-run with updated test case

**Baseline performs unexpectedly well:**
- Skill may be redundant for this task
- Assertion may be too easy
- Consider different test scenarios

**Token/timing metrics look odd:**
- Baseline and with_skill should use similar prompts
- If vastly different, assertion may be measuring something unrelated
- Compare actual outputs in eval-N/outputs/

