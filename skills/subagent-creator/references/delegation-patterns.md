# Subagent Delegation Patterns

Real-world patterns for reliably delegating tasks to subagents. Based on production implementations in the Claude Code skills toolkit.

---

## Pattern Overview

**Goal:** Write delegation prompts that produce consistent, reliable results from subagents.

**Key Principle:** Specificity breeds reliability. Vague prompts get vague results.

---

## Core Delegation Structure

```
Agent type: general-purpose
Prompt: "
[1. ROLE STATEMENT]
You are [what you are doing]. Your job: [primary responsibility].

[2. CONTEXT/CONSTRAINTS]
[Relevant context, files, constraints]

[3. PRIMARY TASK]
[Specific user task or problem to solve]

[4. EXPLICIT OUTPUTS]
After completing the task, [save/create/document]:
- File paths (absolute or relative, exact locations)
- JSON structures (with field definitions)
- Format requirements

[5. CONSTRAINTS/VARIATIONS]
[Special handling: "NO X AVAILABLE" or "USE Y ONLY"]
"
```

---

## Case Study: skill-tester Parallel Agents

Real example showing two parallel agents with variations on the same task.

### Pattern: WITH_SKILL Variant

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

**Key Elements:**
- ✓ Role: "You are testing..." (clear identity)
- ✓ Task: "Your job: HELP THE USER..." (primary responsibility)
- ✓ Context: Full SKILL.md provided inline
- ✓ Input: eval-N prompt from structured source (evals.json)
- ✓ Outputs: Exact file paths with directory structure
- ✓ Format: JSON structure specified with field names
- ✓ Constraint: "using the skill provided" (enables variations)

### Pattern: BASELINE Variant

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

**Key Variations:**
- ✓ Role variation: "...providing a BASELINE" (different identity)
- ✓ Task variation: "WITHOUT any special skill or methodology" (constraint)
- ✓ No skill provided: "NO SKILLS AVAILABLE" (explicit constraint)
- ✓ Same output structure: Makes results comparable
- ✓ Same file path structure: Parallel directories (with_skill vs baseline)

**Why This Works:**
- Both agents know their role (WITH vs BASELINE)
- Both get the same USER TASK (for fair comparison)
- Both output to parallel structures (enables aggregation)
- Constraint is explicit: "NO SKILLS AVAILABLE" vs "using the skill"
- Output format is identical (same timing.json structure)

---

## Pattern: Delegation with Dependencies

Use when subagent needs to reference previous work or outputs.

```
Agent type: general-purpose
Prompt: "
You are [role]. Your job: [responsibility].

PREVIOUS WORK:
[Summary of what just completed]
Location: [path to previous outputs]

CURRENT TASK:
[Build on previous work]

YOUR RESPONSIBILITY:
[Specific action]

OUTPUTS:
Save to: [exact path]
Format: [structure]
"
```

**Example from skill-tester (skill-refiner delegation):**

```
Agent type: general-purpose
Prompt: "
The user just finished creating a new skill at <skill_path>.
They want to refine it using skill-refiner.

Invoke skill-refiner to:
1. Analyze the skill (structure, clarity, efficiency)
2. Identify improvement opportunities
3. Apply refinements (wording, organization, token optimization)
4. Validate final quality

After refinement completes, tell the user: 'Skill refined. Ready for testing?'
Then stop and let the original skill-creator workflow offer testing."
```

**Key Elements:**
- ✓ Previous work: "user just finished creating..." (context)
- ✓ Dependency: References <skill_path> (location of previous output)
- ✓ Task chaining: "call skill-refiner" (delegates further)
- ✓ Success signal: "tell the user..." (how to signal completion)
- ✓ Return point: "let the original workflow offer..." (resumes parent)

---

## Pattern: Constraint Handling

Use when you need to restrict agent behavior or enforce specific approaches.

### Explicit Negations (What NOT to do)

```
NO BASELINE AGENTS. NO TIMING METRICS. NO AGGREGATION.
```

✓ Clear about what's excluded
✓ Prevents agent from trying extra features
✓ Useful for "fast mode" vs "full mode" variants

### Conditional Constraints

```
IF quick workflow: Only run with_skill, no timing collection
IF full pipeline: Run with_skill + baseline in parallel, collect timing
```

✓ Handles workflow variations
✓ Agent can check condition and branch
✓ Clearer than vague "do what makes sense"

### Tool Constraints

```
Use only: [tool 1], [tool 2]
Do NOT use: [tool 3], [tool 4]
```

✓ Prevents unnecessary tool calls
✓ Speeds up execution (fewer options to consider)
✓ Ensures consistency across parallel agents

---

## Pattern: Output Specification

**Always be explicit about outputs.** Vague = inconsistent results.

### Bad (Vague)
```
"Save your work somewhere and show results"
```

→ Agent guesses format, location, naming

### Good (Explicit)
```
"Save all outputs (code, files, notes) to:
./evals/<skill-name>/workspace/iteration-1/eval-N/with_skill/outputs/

Then create a file ./evals/<skill-name>/workspace/iteration-1/eval-N/with_skill/timing.json with:
{
  \"total_tokens\": <count>,
  \"duration_ms\": <milliseconds>,
  \"model\": \"claude-opus-4-6\"
}
"
```

→ Agent knows exact location, JSON structure, field names

### Output Specification Checklist

- [ ] **Location:** Absolute or relative path (with variable substitution: <skill-name>, <workspace>, etc.)
- [ ] **Format:** JSON, Markdown, plain text (be specific)
- [ ] **Structure:** If JSON, show example with field names and types
- [ ] **Naming:** Exact filename (e.g., "timing.json", not "metrics" or "data.json")
- [ ] **Directories:** Create them if needed, or assume they exist? (be explicit)

---

## Pattern: Parallel Execution

Use when you need multiple agents running simultaneously on the same task (with variations).

```
// In skill implementation, send both Agent calls in ONE message:

Agent 1 (WITH_SKILL):
Prompt: "
[Role: testing WITH skill]
[Task: complete user request using skill]
[Outputs: save to with_skill/ directory]
"

Agent 2 (BASELINE):
Prompt: "
[Role: testing WITHOUT skill]
[Task: complete SAME user request, no skill]
[Outputs: save to baseline/ directory]
"

⏸️ Wait for BOTH to complete before proceeding
```

**Key Points:**
- ✓ Send both agents in same message (parallel execution)
- ✓ Give them the SAME USER TASK (fair comparison)
- ✓ Vary constraints: "using skill" vs "no skill available"
- ✓ Output to parallel directories: with_skill/ vs baseline/
- ✓ Use identical JSON structures (enables aggregation)

**Why:**
- Eliminates time-of-day effects
- Same model state for both
- Same environment (no drift)
- Comparable results

---

## Checklist: Writing Reliable Delegation Prompts

- [ ] **Role statement:** Agent knows what it is (e.g., "You are testing...")
- [ ] **Primary task:** Crystal clear responsibility
- [ ] **Context:** Provide all needed information (files, constraints, background)
- [ ] **Inputs:** Specify where task definition comes from (e.g., "USER TASK: <eval-N prompt>")
- [ ] **Outputs:** Exact file paths, JSON structures, naming conventions
- [ ] **Constraints:** Explicit "do this" / "don't do that" (no ambiguity)
- [ ] **Format:** JSON specs with field names, not just "save results"
- [ ] **Comparability:** If parallel agents, use same output structure
- [ ] **Success signal:** How does agent signal completion?
- [ ] **Return point:** If chaining subagents, where does execution return?

---

## Anti-Patterns (What NOT to Do)

### ❌ Vague Outputs
```
"Save your results"
```
→ Agent creates files with unpredictable names/locations

### ❌ Inconsistent Parallel Agents
```
Agent 1: "Save outputs to outputs/"
Agent 2: "Save outputs to results/"
```
→ Different structures, hard to compare

### ❌ Missing Constraints
```
"Test the skill"
```
→ Agent might include baseline or skip it (unpredictable)

### ❌ Implicit Dependencies
```
"Refine the skill"
```
→ Agent doesn't know where skill file is, creates one locally instead

### ❌ Ambiguous Success
```
"Let me know when you're done"
```
→ Agent might continue working, add extra features, get sidetracked

---

## Production Examples

### Example 1: skill-tester (With vs Baseline)

Real, working delegation used to evaluate Claude Code skills:
- File: `skills/skill-tester/SKILL.md` (Phase 3)
- Pattern: Parallel WITH_SKILL + BASELINE agents
- Reliability: Used in production for skill evaluation
- Result: Consistent, aggregatable data

### Example 2: skill-creator (Refiner Delegation)

Real, working delegation from skill creation workflow:
- File: `skills/skill-creator/SKILL.md` (Step 3.9)
- Pattern: Sequential delegation to skill-refiner
- Reliability: Chain returns to parent workflow
- Result: Refined skill, ready for testing

### Example 3: skill-creator (Tester Delegation)

Real, working delegation from skill creation workflow:
- File: `skills/skill-creator/SKILL.md` (Step 3.10)
- Pattern: Sequential delegation to skill-tester (Quick Workflow)
- Reliability: Quick feedback, clear outputs
- Result: Pass/fail validation results

---

## Conclusion

**Reliable subagent delegation requires:**
1. Clear role and responsibility
2. Complete context and constraints
3. Explicit output specifications (paths, JSON structures)
4. Unambiguous success signals
5. Consistent structure for comparable results (if parallel)

Use these patterns as templates. Copy-paste and adapt to your use case. The more specific you are, the more reliable your subagents will be.
