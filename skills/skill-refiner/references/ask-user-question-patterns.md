# AskUserQuestion Patterns & Best Practices

Use this guide when refining skills that interact with users. AskUserQuestion is the primary tool for gathering input; patterns here ensure good UX and compliance with framework constraints.

## Core Constraint: Maximum 4 Options Per Question

**Non-negotiable:** AskUserQuestion schema enforces `maxItems: 4` per question's options array.

```json
{
  "questions": [{
    "question": "...",
    "header": "...",
    "options": [
      // MAX 4 ITEMS
    ]
  }]
}
```

**Violation impact:**
- Tool validation error (schema rejection)
- User never sees the question
- Skill execution fails silently
- **Solution:** Split into multiple questions or reduce options

---

## Pattern 1: Single Question with Predefined Options

**Use when:** User must choose ONE thing from a fixed set (≤4 options)

**Structure:**
```json
{
  "questions": [{
    "question": "What would you like to do?",
    "header": "Action",
    "options": [
      { "label": "Option A", "description": "Use when..." },
      { "label": "Option B", "description": "Use when..." },
      { "label": "Option C", "description": "Use when..." }
    ],
    "multiSelect": false
  }]
}
```

**Examples from toolkit:**

✅ **skill-refiner** (lines 30-46):
```json
{
  "question": "What would you like to do with this skill?",
  "header": "Action",
  "options": [
    { "label": "Refine", "description": "Improve clarity, structure, efficiency..." },
    { "label": "Validate", "description": "Check if it's production-ready..." }
  ],
  "multiSelect": false
}
```

✅ **skill-creator** (lines 21-38):
```json
{
  "question": "What do you want to do?",
  "header": "Action",
  "options": [
    { "label": "Create a new skill", "description": "..." },
    { "label": "Convert a slash command", "description": "..." }
  ],
  "multiSelect": false
}
```

---

## Pattern 2: Multiple Selection (≤4 options)

**Use when:** User selects MULTIPLE things from a set (≤4 options total)

**Structure:**
```json
{
  "questions": [{
    "question": "Which of these apply?",
    "header": "Selection",
    "options": [
      { "label": "Option A", "description": "..." },
      { "label": "Option B", "description": "..." },
      { "label": "Option C", "description": "..." }
    ],
    "multiSelect": true
  }]
}
```

**Example from toolkit:**

✅ **plugin-creator (CORRECTED)** - BATCH 1 (lines 149-162):
```json
{
  "question": "Which core components will the plugin include?",
  "header": "Core Components",
  "options": [
    { "label": "Skills", "description": "..." },
    { "label": "Agents", "description": "..." },
    { "label": "Hooks", "description": "..." },
    { "label": "MCP servers", "description": "..." }
  ],
  "multiSelect": true
}
```

---

## Pattern 3: Progressive Disclosure (Wizard Pattern)

**Use when:** You need >4 options OR multiple related questions

**Key rule:** Ask ONE batch, wait for response, THEN ask next batch. Never combine into a single AskUserQuestion.

**Structure:**
```
Batch 1: Ask first set of questions (up to 4 options each)
         ↓
[WAIT for response]
         ↓
Batch 2: Ask follow-up questions (conditional or next step)
         ↓
[WAIT for response]
         ↓
Batch 3: Continue as needed
```

**Why this matters:**
- Avoids cognitive overload (users see one question at a time)
- Allows conditional routing (skip questions based on previous answers)
- Respects the 4-option maximum (split across multiple questions)
- Feels conversational (not a form)

**Example: Handling >4 options**

❌ **WRONG - Violates max 4 options:**
```json
{
  "question": "Which components?",
  "options": [
    { "label": "Skills" },
    { "label": "Agents" },
    { "label": "Hooks" },
    { "label": "MCP servers" },
    { "label": "LSP servers" },
    { "label": "Commands" }
  ]
}
```

✅ **RIGHT - Split into 2 batches:**

**Batch 1:**
```json
{
  "question": "Which core components will the plugin include?",
  "header": "Core Components",
  "options": [
    { "label": "Skills" },
    { "label": "Agents" },
    { "label": "Hooks" },
    { "label": "MCP servers" }
  ],
  "multiSelect": true
}
```

[WAIT for response]

**Batch 2:**
```json
{
  "question": "Include Language Server Protocol (LSP) support?",
  "header": "LSP Servers",
  "options": [
    { "label": "Yes" },
    { "label": "No" }
  ],
  "multiSelect": false
}
```

**Real toolkit example:**

✅ **plugin-creator** (lines 146-180):
- BATCH 1 (lines 149-162): "Which core components?" (4 options, multiSelect)
- BATCH 2 (lines 167-177): "Include LSP support?" (2 options, yes/no)

✅ **skill-refiner** (lines 69-132):
- BATCH 1 (lines 72-100): "What aspects need improvement?" (4 options: Clarity, Efficiency, Structure, User Interaction UX) + 3 open-form questions
- BATCH 2 (lines 107-132): "Should we consolidate references?" (yes/no) + "Validate for production?" (yes/no) + "Add testing patterns?" (yes/no)

---

## Pattern 4: Open-Form Questions (No Options)

**Use when:** User provides free-text input (not a choice)

**Structure:**
```json
{
  "questions": [{
    "question": "What is the skill's purpose?",
    "header": "Skill Purpose",
    "options": []  // ← Empty = open-form
  }]
}
```

**Examples from toolkit:**

✅ **skill-refiner - BATCH 1 (interview)** (lines 72-82):
```json
{
  "question": "What aspects need improvement?",
  "header": "Focus Areas",
  "options": [
    { "label": "Clarity", "description": "Make instructions clearer, remove jargon, improve examples" },
    { "label": "Efficiency", "description": "Reduce token usage, consolidate references, optimize content" },
    { "label": "Structure", "description": "Reorganize sections, improve flow, better grouping" },
    { "label": "User Interaction UX", "description": "Convert free-form interactions to AskUserQuestion patterns, improve workflows" }
  ],
  "multiSelect": true  // ← Multiple aspects can need work simultaneously
},
{
  "question": "What specific problems are you seeing?",
  "header": "Key Issues",
  "options": []  // Open-form; captures issues across all selected aspects
},
{
  "question": "What would success look like?",
  "header": "Success Metric",
  "options": []  // Open-form
},
{
  "question": "Any areas to exclude or preserve as-is?",
  "header": "Scope Limits",
  "options": []  // Open-form
}
```

✅ **skill-creator** (lines 147-169):
```json
{
  "question": "What domain-specific task should Claude execute?",
  "header": "Skill Purpose",
  "options": []  // Open-form
},
{
  "question": "What phrases will Claude see in user requests?",
  "header": "Trigger Phrases",
  "options": []  // Open-form
}
```

---

## Pattern 5: Conditional Questions (Based on Previous Answer)

**Use when:** Next question depends on previous answer

**Structure:**
```
Ask Question 1 (with predefined options)
  ↓
[WAIT for response]
  ↓
IF response == "Option A" → Ask follow-up for Option A
IF response == "Option B" → Ask follow-up for Option B
IF response == "Option C" → Skip to step X
```

**Example: skill-refiner routing**

```
Q1: "What would you like to do?"
  - Option A: "Refine" → Route to Refinement Interview
  - Option B: "Validate" → Skip to Validation Phase

Q2: [Depends on Q1 answer]
  IF "Refine": Ask "What aspect needs improvement?"
  IF "Validate": Ask "Ready for validation checklist?"
```

**Real toolkit example:**

✅ **skill-refiner** (lines 23-53):
```
1. Ask: "What would you like to do?" (Refine / Validate)
2. Wait for response
3. IF "Refine" → proceed to "Core Workflow: Refinement"
   IF "Validate" → proceed to "Core Workflow: Validation"
```

---

## Pattern 6: Multi-Question Batch (All Asked Together)

**Use when:** Multiple related questions, all can be answered together (NOT conditional)

**Key rule:** Each question in the batch must be independent. Combine only if they don't depend on each other's answers.

**Structure:**
```json
{
  "questions": [
    {
      "question": "Question 1?",
      "header": "Header 1",
      "options": [...]  // or []
    },
    {
      "question": "Question 2?",
      "header": "Header 2",
      "options": [...]  // or []
    },
    {
      "question": "Question 3?",
      "header": "Header 3",
      "options": [...]  // or []
    }
  ]
}
```

**When to use:**
- Questions are unrelated (no conditional logic needed)
- User can answer all of them in one go
- They're all required (no skip scenarios)

**When NOT to use:**
- ❌ If next question depends on previous answer (use conditional routing instead)
- ❌ If some questions should be skipped (use conditional routing)
- ❌ If you have >4 options per question (reduce or split)

**Example from toolkit:**

✅ **skill-refiner - BATCH 1** (lines 72-100):
```json
{
  "questions": [
    { "question": "What aspect needs improvement?", "options": [...] },  // 4 options
    { "question": "What specific problems are you seeing?", "options": [] },  // open-form
    { "question": "What would success look like?", "options": [] },  // open-form
    { "question": "Any areas to exclude?", "options": [] }  // open-form
  ]
}
```

All 4 questions are independent; user answers all together, then waits for BATCH 2.

---

## Decision Tree: Which Pattern to Use?

```
Does user select from a fixed set?
  ├─ YES, ≤4 options, single answer
  │  └─ Pattern 1: Single question with predefined options
  │
  ├─ YES, ≤4 options, multiple answers
  │  └─ Pattern 2: Multiple selection (multiSelect: true)
  │
  ├─ YES, >4 options
  │  └─ Pattern 3: Split into multiple AskUserQuestion batches
  │
  └─ NO, free-text input
     └─ Pattern 4: Open-form question (options: [])

Are next questions conditional on previous answers?
  ├─ YES
  │  └─ Pattern 5: Conditional routing between batches
  │
  └─ NO, all independent
     └─ Pattern 6: Multi-question batch
```

---

## Common Mistakes to Avoid

### ❌ Mistake 1: >4 Options in Single Question

```json
// WRONG - Will fail validation
{
  "question": "Pick one:",
  "options": [
    { "label": "A" },
    { "label": "B" },
    { "label": "C" },
    { "label": "D" },
    { "label": "E" },  // ← Exceeds maximum
    { "label": "F" }   // ← Will cause validation error
  ]
}
```

**Fix:** Split into 2+ AskUserQuestion calls OR reduce to ≤4 options

**Historical example:** plugin-creator had 6 component options initially (❌ Incorrect). After refinement: BATCH 1 with 4 options + BATCH 2 with 2 options (✅ Correct).

### ❌ Mistake 2: Asking All Questions as a Form

```json
// WRONG - Looks like a form, overwhelming
{
  "questions": [
    { question: "Name?", ... },
    { question: "Email?", ... },
    { question: "Phone?", ... },
    { question: "Company?", ... },
    { question: "Role?", ... }
  ]
}
```

**Fix:** Ask progressively: Name → wait → Email → wait → (conditional) Phone → etc.

### ❌ Mistake 3: Predefined Options When Free-Text Needed

```json
// WRONG - Tries to force choice when user should type freely
{
  "question": "What's the skill's purpose?",
  "options": [
    { "label": "A general skill" },
    { "label": "A specific skill" }
  ]
}
```

**Fix:** Use open-form (options: []) for free-text:
```json
{
  "question": "What's the skill's purpose?",
  "options": []  // User types response
}
```

### ❌ Mistake 4: Conditional Logic in Single AskUserQuestion

```json
// WRONG - Can't handle conditional logic
{
  "questions": [
    { "question": "Refine or validate?", "options": [...] },
    { "question": "[conditional follow-up]", "options": [...] }  // ← Doesn't work!
  ]
}
```

**Fix:** Use separate AskUserQuestion calls:
```
Call 1: "Refine or validate?" → wait
Call 2 (conditional): IF "Refine" → ask refinement questions
        (or IF "Validate" → ask validation questions)
```

### ❌ Mistake 5: Vague Option Descriptions

```json
// WRONG - User doesn't understand what each option does
{
  "options": [
    { "label": "Option A", "description": "Yes" },
    { "label": "Option B", "description": "No" }
  ]
}
```

**Fix:** Clear, actionable descriptions:
```json
{
  "options": [
    { "label": "Refine", "description": "Improve clarity, structure, efficiency, token usage, or organization" },
    { "label": "Validate", "description": "Check if it's production-ready (tool scoping, completeness, error handling)" }
  ]
}
```

---

## Best Practices Checklist

When refining skills that use AskUserQuestion, verify:

- ✅ **Max 4 options** per question (no exceptions)
- ✅ **Progressive disclosure** - Ask one batch, wait, ask next (no forms)
- ✅ **Clear descriptions** - User understands what each option does
- ✅ **Predefined vs open-form** - Use options: [] for free-text, [options] for choices
- ✅ **Conditional routing** - Next question logic is clear (if/then paths documented)
- ✅ **Batching** - Related questions grouped; unrelated questions separated
- ✅ **No violations** - Use fact-check or linting to verify compliance

---

## Verification Patterns (For Skill Refinement)

When refining skills that use AskUserQuestion, check:

```bash
# Count options per question
grep -A 15 "options: \[" SKILL.md | grep "{ label:" | wc -l

# Verify no single question has >4 options
# Expected: Each AskUserQuestion definition shows ≤4 options
```

**Rule:** If any question has >4 options, split it into multiple AskUserQuestion calls.

**Red flags to watch during refinement:**
- ⚠️ User wants to add "just one more option" → Suggests >4 total incoming
- ⚠️ Skills with conditional logic → Verify separate AskUserQuestion batches
- ⚠️ Large interview sections → Break into multiple progressive batches
- ⚠️ Mix of choices and free-text → Use separate questions for each type

---

## Examples from the Toolkit

All toolkit skills now follow these patterns:

| Skill | Pattern | Location |
|-------|---------|----------|
| **skill-creator** | Pattern 1 + Pattern 4 (routing + interviews) | Lines 21-38, 147-169, 176-196 |
| **skill-refiner** | Pattern 1 + Pattern 4 (action choice + interview batches) | Lines 30-46, 72-127 |
| **plugin-creator** | Pattern 1 + Pattern 3 (action choice + split components) | Lines 18-43, 149-177 |
| **hook-creator** | Pattern 1 (simple action choice) | Lines 22-43 |
| **subagent-creator** | Pattern 1 + Pattern 4 (action + scope + interviews) | Lines 18-42, 104-165 |

All comply with:
- ✅ Maximum 4 options per question
- ✅ Progressive disclosure (ask → wait → ask)
- ✅ Clear descriptions
- ✅ Appropriate use of open-form vs predefined

---

## How to Use This Reference During Refinement

When refining a skill that uses AskUserQuestion:

1. **Audit phase:** Count options per question (target: ≤4)
2. **Design phase:** If >4 found, plan split into multiple batches
3. **Implementation phase:** Apply appropriate pattern from above
4. **Validation phase:** Verify with verification patterns (bash script)
5. **Testing phase:** Try the skill; verify questions appear in correct order

**Example refinement workflow:**

```
FOUND: Question with 6 options
  ↓
DESIGN: Split into BATCH 1 (4 options) + BATCH 2 (2 options)
  ↓
IMPLEMENT: Update SKILL.md with 2 separate AskUserQuestion calls
  ↓
VALIDATE: Run verification patterns; confirm ≤4 per question
  ↓
TEST: Run skill; verify BATCH 1 → wait → BATCH 2 flow works
```

---

## Token Impact

Using AskUserQuestion efficiently:

- **Single question with 2-4 options:** ~150-300 tokens
- **Multi-batch question (3+ AskUserQuestion calls):** Spread across multiple interactions (efficient)
- **Large form (10+ questions at once):** ~500+ tokens, worse UX

**Recommendation:** Always prefer progressive disclosure. Better UX, better token efficiency, more responsive feel.
