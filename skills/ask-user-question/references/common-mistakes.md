# Common Mistakes in Skill Authoring

Mistakes when writing skills that use AskUserQuestion and how to fix them.

## Mistake 1: Asking Multiple Questions in One Call

❌ **WRONG:** Try to ask 3 questions at once
```
questions: [
  { question: "Choice 1?", options: [...] },
  { question: "Choice 2?", options: [...] },
  { question: "Choice 3?", options: [...] }
]
```

✅ **RIGHT:** Ask one, wait, then ask next
```
Step 1:
  Ask: "Choice 1?"
  [Get answer]

Step 2:
  Ask: "Choice 2?"
  [Get answer]

Step 3:
  Ask: "Choice 3?"
  [Get answer]
```

**Why:** Multiple questions look like a form and overwhelm the user. Progressive disclosure is better.

## Mistake 2: Too Many Options

❌ **WRONG:** 8 options in one question
```
options: [
  "Option 1", "Option 2", "Option 3", "Option 4",
  "Option 5", "Option 6", "Option 7", "Option 8"
]
```

✅ **RIGHT:** 2-4 options or split into stages
```
Step 1: Category?
  Options: Relational, Document, In-Memory

Step 2: Specific?
  Options: [3-4 based on category]
```

**Why:** Too many options cause user paralysis. Categorization helps decision-making.

## Mistake 3: Vague Questions

❌ **WRONG:** Unclear what's being asked
```
Question: "Settings?"
Options: ["A", "B"]
```

✅ **RIGHT:** Specific and contextual
```
Question: "Which database for this project?"
Options:
  - "PostgreSQL" (Relational, ACID, complex queries)
  - "MongoDB" (Document, flexible schema)
```

**Why:** Users need context to make informed decisions.

## Mistake 4: Missing Descriptions

❌ **WRONG:** No explanation of options
```
- "Option A" (description: "Good choice")
- "Option B" (description: "Also good")
```

✅ **RIGHT:** Explain trade-offs
```
- "PostgreSQL" (Relational, ACID, slower for simple ops, better integrity)
- "MongoDB" (Fast reads, flexible, slower joins)
```

**Why:** Descriptions help users compare and choose appropriately.

## Mistake 5: Including "Other" in Options

❌ **WRONG:** Explicitly list "Other"
```
options: [
  "React",
  "Vue",
  "Other (specify custom)"    ← Don't do this
]
```

✅ **RIGHT:** Let it be automatic
```
options: [
  "React",
  "Vue",
  "Svelte"
]
# "Other" is automatically added by tool
```

**Why:** "Other" is automatic. Including it doubles it.

## Mistake 6: Using "Other" as Answer Value

❌ **WRONG:** Store "Other" as the answer
```
answers["Framework?"] = "Other"
```

✅ **RIGHT:** Use custom text directly
```
answers["Framework?"] = "angular"  // User typed this
```

**Why:** You need the actual framework name, not "Other".

## Mistake 7: Not Waiting for Responses

❌ **WRONG:** Ask and assume answer without waiting
```
Ask: "Database?"
Log: "Using answer: [immediately assume something]"
```

✅ **RIGHT:** Wait for actual response
```
Ask: "Database?"
[Wait for tool response]
Get answer from response object
Process actual answer
```

**Why:** You need to process what user actually selected.

## Mistake 8: Not Validating Answers

❌ **WRONG:** Use answer without checking
```
port = answers["Port?"]
startServer(port)  // What if it's "abc"?
```

✅ **RIGHT:** Validate before using
```
port = answers["Port?"]
if port not numeric or not in range 1-65535:
  Log error
  Ask to reconfigure
else:
  startServer(port)
```

**Why:** Custom input might be invalid. Validate before using.

## Mistake 9: Ignoring Conditional Logic

❌ **WRONG:** Ask all questions regardless of answers
```
Q1: "Use database?" (Yes/No)
Q2: "Database type?" (always asked, even if user said No)
Q3: "Port?" (always asked)
```

✅ **RIGHT:** Conditional questions
```
Q1: "Use database?" (Yes/No)

If Yes:
  Q2: "Database type?"
  Q3: "Port?"
If No:
  Skip Q2, Q3
```

**Why:** Users shouldn't answer irrelevant questions.

## Mistake 10: Not Documenting Custom Input

❌ **WRONG:** User doesn't know they can type custom
```
Question: "Framework?"
Options: React, Vue, Svelte

[User doesn't know they can type "angular"]
```

✅ **RIGHT:** Explain custom input option
```
## Question: Framework

Choose from: React, Vue, Svelte
Or type custom: angular, next.js, nuxt

You can select from options or type your own.
```

**Why:** Users need to know custom input is available.

## Mistake 11: Mixing Exclusive and Non-Exclusive Options

❌ **WRONG:** Use multiSelect: false but treat as non-exclusive
```
multiSelect: false
Question: "Which features?"
Options: Feature A, Feature B, Feature C

[Users can only pick one, but question implies multiple]
```

✅ **RIGHT:** Match multiSelect to semantics
```
If user can pick ONE:
  multiSelect: false
  Question: "Which database?" (only one applies)

If user can pick MULTIPLE:
  multiSelect: true
  Question: "Which features?" (select all you need)
```

**Why:** multiSelect should match the actual use case.

## Mistake 12: No Error Handling

❌ **WRONG:** Assume everything works
```
Get response
Use response directly
```

✅ **RIGHT:** Handle errors
```
If response is null/empty:
  Log error
  Show alternative
  Exit or ask again

If answer invalid:
  Log error
  Explain what went wrong
  Ask to reconfigure
```

**Why:** Things can fail. Handle gracefully.

## Mistake 13: Inconsistent Formatting

❌ **WRONG:** Options formatted differently
```
- "React JS" (with space, capitalized)
- "vue" (lowercase)
- "SVELTE" (uppercase)
```

✅ **RIGHT:** Consistent format
```
- "React" (consistent)
- "Vue" (consistent)
- "Svelte" (consistent)
```

**Why:** Consistency makes options clearer and professional.

## Mistake 14: Asking When No Decision Needed

❌ **WRONG:** Ask about obvious defaults
```
Question: "Use security best practices?"
Options: Yes, No

[Everyone chooses Yes, no real decision]
```

✅ **RIGHT:** Only ask about genuine choices
```
Question: "Authentication method?"
Options: OAuth, JWT, Session

[Real trade-offs, genuine choice needed]
```

**Why:** Don't waste user time on non-decisions.

## Mistake 15: No Confirmation Before Applying

❌ **WRONG:** Apply configuration immediately
```
Get answers
Apply configuration
[User has no chance to review]
```

✅ **RIGHT:** Show and confirm before applying
```
Get answers
Show summary: "Will configure [details]"
Ask: "Proceed?" (Yes/No)

If Yes:
  Apply
If No:
  Ask to reconfigure
```

**Why:** Users should verify before committing changes.

## Quick Checklist

✅ One question per call
✅ 2-4 options per question
✅ Clear, specific questions
✅ Explanatory descriptions
✅ Wait for responses
✅ Validate answers
✅ Handle custom input
✅ Conditional logic
✅ Error handling
✅ Confirmation before applying
✅ Document custom options
✅ Consistent formatting
✅ Progressive disclosure (simple → complex)
✅ Only ask real decisions
