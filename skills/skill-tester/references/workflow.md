# Skill-Tester Workflow Reference

Detailed step-by-step guidance for the full 7-phase evaluation pipeline. Use when implementing phases or making decisions about test design.

---

## Overview: Why Empirical Testing?

Skills are **instructions for Claude**. But do they actually help? The skill-tester pipeline answers that question with data:

- **Without data:** "This skill seems helpful" (intuition, no proof)
- **With data:** "This skill improved performance by 35%, at a token cost of 500" (empirical proof)

The pipeline tests a skill against **baseline Claude** (same task, no skill). Parallel execution (WITH skill + BASELINE simultaneously) eliminates confounding variables.

---

## Phase 1: Setup — Identify Skill & Prepare Workspace

### Decision Point 1.1: Which Skill?

**Question:** What skill should we test?

**Factors:**
- New skills (just created) → best time to test, iterate early
- Refactored skills → validate improvements didn't break anything
- Skills with low triggering rate → test if description/placement is the issue
- Production skills → periodic benchmarking to track quality over time

**Output:** Confirmed skill path + workspace directory created

### Decision Point 1.2: Workspace Location

**Question:** Where should evaluation data live?

**Recommendation:** Co-locate with skill being tested.

```
skills/my-skill/
├── SKILL.md
├── scripts/
├── references/
├── evals/              ← Evaluation data lives here
│   ├── evals.json
│   └── workspace/
│       ├── iteration-1/
│       ├── iteration-2/
│       └── iteration-3/
```

**Why co-locate?**
- Easy to find evaluation data when iterating
- Clear history: Iteration 1 → 2 → 3 shows improvement trajectory
- Each iteration directory is self-contained snapshot

---

## Phase 2: Create Evals — Design Test Cases

### Decision Point 2.1: How Many Test Cases?

**Question:** How many evals should we create?

**Guidance:**
- **Minimum:** 1 eval (covers core use case)
- **Typical:** 2–3 evals (covers core cases + edge cases)
- **Comprehensive:** 4–5 evals (core + edge cases + advanced scenarios)

**Example (skill-creator):**
- Eval 1: Create new skill from scratch
- Eval 2: Convert slash command to skill
- Eval 3: Create skill with complex references

Each eval tests a different scenario; pass rates show which scenarios the skill handles well vs. poorly.

### Decision Point 2.2: Assertion Design

**Question:** What makes a GOOD output? What should we verify?

**Assertion categories:**

| Category | Example | Check |
|----------|---------|-------|
| **Presence** | "SKILL.md frontmatter exists" | File/field/section present |
| **Quality** | "Description has trigger phrases" | Content meets criteria |
| **Structure** | "References have one-level nesting" | Directory layout correct |
| **Functionality** | "All reference links are valid" | Cross-references work |

**Assertion checklist:**
- [ ] Each assertion is **specific** (e.g., "description mentions 'skill'" not "description is good")
- [ ] Each assertion is **verifiable** (evidence can be extracted from output)
- [ ] Assertions cover **diverse dimensions** (not all presence, mix structure + quality)
- [ ] 3–5 assertions per eval (sweet spot: thorough without overwhelming)

**Example (skill-creator eval 1):**
- ✓ Presence: SKILL.md frontmatter with name, description, version exists
- ✓ Quality: Description includes specific trigger phrases ("create", "new skill", "best practices")
- ✓ Structure: Body <500 lines, includes Quick Start section
- ✓ Structure: References/ has one-level nesting (no nested subdirs)
- ✓ Functionality: All reference links in body have corresponding .md files

---

## Phase 3: Run Tests — Execute WITH skill + BASELINE Parallel

### Decision Point 3.1: Parallel Execution Pattern

**Question:** How should we run with_skill vs. baseline?

**Answer:** **Always in parallel.** Same message, 2 agents simultaneously.

**Why parallel?**
- Eliminates time-of-day effects (both run in same context window)
- Eliminates model variation (both use same model)
- Fair comparison: Same task, same model, different knowledge (skill present/absent)

**Anti-pattern (DON'T DO THIS):**
```
Run with_skill → wait for completion → Run baseline
❌ Wrong: Different time-of-day, possibly different model state, environment drift
```

**Correct pattern (DO THIS):**
```
Run with_skill AND baseline simultaneously in same Agent call
✓ Right: Fair comparison, controlled variables
```

### Decision Point 3.2: Agent Configuration

**Question:** What model/config should agents use?

**Recommendation:**
- Model: `claude-opus-4-6` (latest, most capable)
- Temperature: default (consistency with normal Claude behavior)
- Max tokens: appropriate to task (typically 8000–16000 for skill creation evals)

**Why Opus?** Skill-creator is complex; Haiku might struggle. Opus best demonstrates skill effectiveness or weakness.

### Decision Point 3.3: Output Capture

**Question:** How should agents save outputs?

**Rule:** Agents save to `workspace/iteration-N/eval-M/{with_skill,baseline}/outputs/`

**What to save:**
- All files created (code, markdown, JSON, etc.)
- Generated SKILL.md, references, scripts
- Logs or notes if helpful for grading

**Example:**
```
eval-1/with_skill/outputs/
  ├── SKILL.md
  ├── references/
  │   ├── workflow.md
  │   └── examples.md
  └── scripts/
      └── validator.py
```

### Decision Point 3.4: Timing Data

**Question:** How should agents report timing?

**Rule:** Each agent writes `workspace/iteration-N/eval-M/{config}/timing.json`

**Required fields:**
```json
{
  "total_tokens": 2847,
  "duration_ms": 8234,
  "model": "claude-opus-4-6"
}
```

**How to calculate:**
- `total_tokens`: Sum of input + output tokens consumed by agent
- `duration_ms`: Wall-clock time from start to completion (in milliseconds)
- Agents can use `time` command + token counting from API responses

---

## Phase 4: Grade Results — Evaluate Against Assertions

### Decision Point 4.1: Grading Approach

**Question:** How should we grade outputs?

**Answer:** For each assertion:
1. Check if assertion passed (true/false)
2. Extract evidence (quote or reference from output)
3. Record in grading.json

**Grading rubric (0 = fail, 1 = pass):**
- Does output demonstrate the assertion? → 1
- Does output fail the assertion? → 0
- Marginal cases: Use judgment, document in evidence

### Decision Point 4.2: Evidence Collection

**Question:** What counts as valid evidence?

**Examples:**

| Assertion | Valid Evidence |
|-----------|---|
| "SKILL.md has frontmatter" | Quote frontmatter lines (lines 1–9) |
| "Description has trigger phrases" | Exact words from description field |
| "Body <500 lines" | Line count (wc -l output) |
| "References have one-level nesting" | Directory listing (no subdirs) |
| "All reference links valid" | List of files that exist + missing files |

**Document evidence clearly** so you can re-verify grading later.

### Decision Point 4.3: Pass Rate Calculation

**Question:** How should we calculate pass rates?

**Formula:**
```
pass_rate = assertions_passed / assertions_total
```

**Example:**
```
eval-1 with_skill: 5 assertions, 5 passed → 1.0 (100%)
eval-1 baseline:   5 assertions, 2 passed → 0.4 (40%)
```

---

## Phase 5: Aggregate — Compute Benchmark Stats

### Decision Point 5.1: Aggregation Trigger

**Question:** When should we run the Ruby aggregation script?

**Answer:** After ALL evals are graded (Phase 4 complete).

### Decision Point 5.2: Script Execution

**Question:** How do we invoke the script?

**Command:**
```bash
ruby skills/<skill-name>/scripts/aggregate_benchmark.rb workspace/iteration-1
```

**Inputs:** All `eval-N/{with_skill,baseline}/{grading,timing}.json` files in iteration directory

**Outputs:** `workspace/iteration-1/benchmark.json` with summary statistics

### Decision Point 5.3: Interpreting Results

**Question:** What do the benchmark results tell us?

**Key metrics:**

| Metric | Interpretation |
|--------|---|
| `with_skill_avg_pass_rate` | How well does skill help? (0–100%) |
| `baseline_avg_pass_rate` | How well does Claude do without skill? (0–100%) |
| `improvement` | By how many points does skill improve performance? |
| `token_cost` | How many extra tokens does skill consume? |
| `duration_cost_ms` | How much slower is skill? |

**Evaluation framework:**

| Improvement | Token Cost | Verdict |
|---|---|---|
| +30 points | +500 tokens | **Excellent** (big improvement, moderate cost) |
| +10 points | +100 tokens | **Good** (solid improvement, low cost) |
| +5 points | +1000 tokens | **Acceptable** (marginal gain, high cost — reconsider) |
| -10 points | -500 tokens | **Fail** (skill hurts performance) |

---

## Phase 6: Review Summary — Present Results & Ask Next Steps

### Decision Point 6.1: Result Presentation

**Question:** How should we show results to the user?

**Format:**

```
EVALUATION RESULTS: <skill-name> iteration-1
==============================================

Eval 1: <Scenario Name>
  WITH SKILL:  pass_rate% | tokens | duration
  BASELINE:    pass_rate% | tokens | duration
  DELTA:       ±X points | ±tokens | ±duration

SUMMARY
-------
With Skill Avg:  pass_rate%
Baseline Avg:    pass_rate%
IMPROVEMENT:     ±X percentage points
```

**Use comparison table** so user can see all evals at once + aggregate improvement.

### Decision Point 6.2: Decision Tree for User

**Question:** What should we ask user after reviewing results?

**Options:**
1. **"Iterate"** — Update skill + run workspace/iteration-2 with same evals
2. **"Stop"** — Satisfied with results; save benchmark data
3. **"Refine evals"** — Change test cases; rerun with same iteration

**Recommendation:** Default to iterate if improvement is possible (e.g., baseline has high pass rate but with_skill is low).

---

## Phase 7: Iterate — Update Skill & Run Next Iteration

### Decision Point 7.1: What to Improve?

**Question:** Based on results, what should we fix?

**Decision framework:**

| Result | Action |
|--------|--------|
| with_skill pass rate = 100%, baseline = 50% | **Excellent** — Stop or retest on harder scenarios |
| with_skill pass rate = 80%, baseline = 60% | **Improve** — Skill helps, but not perfectly. Refine guidance. |
| with_skill pass rate = 40%, baseline = 60% | **Overhaul** — Skill hurts performance. Rework descriptions/structure. |
| with_skill pass rate = baseline | **Ineffective** — Skill provides no value. Reconsider approach. |

### Decision Point 7.2: Improvement Types

**Common improvements:**

| Issue | Fix |
|-------|-----|
| Low with_skill pass rate, specific assertion fails | Add guidance to SKILL.md body covering that scenario |
| Vague trigger (skill not activating) | Rewrite description with specific trigger phrases |
| High token cost | Trim SKILL.md body; move details to references/ |
| Baseline matches with_skill on some evals | Assertions might be too broad; refine to measure actual skill impact |

### Decision Point 7.3: Iteration Versioning

**Question:** How should we version skill updates?

**Recommendation:**
- Version bump in SKILL.md frontmatter (PATCH or MINOR, depending on scope)
- Iteration N+1 uses updated skill
- Workspace structure keeps both iterations (can compare improvement)

**Example:**
```
iteration-1/ — skill-creator 2.4.0, pass rate 80%
iteration-2/ — skill-creator 2.4.1 (bug fix), pass rate 95%
iteration-3/ — skill-creator 2.5.0 (new features), pass rate 98%
```

### Decision Point 7.4: Stopping Criteria

**Question:** When should we stop iterating?

**Criteria (choose one):**
- ✓ with_skill pass rate ≥ 95% (excellent)
- ✓ improvement ≥ 30 percentage points (major win)
- ✓ token cost acceptable (skill worth the expense)
- ✓ baseline achieves high pass rate (skill less needed)
- ✓ diminishing returns (iteration N+1 improvement <5 points)

---

## Quick Checklist: Full Pipeline Execution

- [ ] **Phase 1:** Skill identified, workspace created
- [ ] **Phase 2:** evals.json written, eval_metadata.json files created for each eval
- [ ] **Phase 3:** Both agents ran in parallel for each eval, outputs in correct directories, timing.json written
- [ ] **Phase 4:** All assertions graded, grading.json written for with_skill and baseline
- [ ] **Phase 5:** Ruby script executed, benchmark.json created
- [ ] **Phase 6:** Results presented to user, next action decided
- [ ] **Phase 7 (if iterate):** Skill updated, new iteration created, process repeats

---

## Integration with skill-creator, skill-refiner

**skill-creator workflow:**
1. Create skill with skill-creator
2. Test immediately with skill-tester (Phase 1–6, no iteration needed for new skills)
3. Review results
4. If pass rate <80%, use skill-refiner to improve → skill-tester again

**skill-refiner workflow:**
1. Refine skill with skill-refiner
2. Validate with skill-tester (run benchmark)
3. Compare iteration-N vs. iteration-N-1 results
4. If improvement achieved, keep changes; else revert

**Example workflow (recommended):**

```
skill-creator → SKILL.md v1.0 → skill-tester iteration-1 (pass rate: 75%)
                                      ↓
                              skill-refiner (improve descriptions)
                                      ↓
skill-creator → SKILL.md v1.1 → skill-tester iteration-2 (pass rate: 92%)
                                      ↓
                                   ✓ Stop (goal reached)
```
