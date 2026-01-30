# Skill Refinement Guardrails

Refinement is **refactoring + improving**, not cutting content for brevity.

## What NEVER Gets Cut

**Description field (frontmatter):**
- Scope qualifiers: "best practices", "clarity", "execution", "structure", "readiness"
- Use cases (e.g., "validate" is a primary action, don't reduce it)
- Important differentiation from similar skills

**Example of BAD refinement:**
```yaml
# BEFORE
description: >-
  Create, validate, and refine Claude Code skills. Use when: building new skills,
  validating skills against best practices, or improving skill clarity and execution.
  Handles skill structure, frontmatter, activation, references, tool scoping, and
  production readiness.

# AFTER (WRONG - lost critical scope)
description: >-
  Build and refine Claude Code skills. Use when: "create skill", "validate skill",
  "improve skill". Handles frontmatter, activation triggers, references organization,
  tool scoping, production safety.
```

**What was lost:**
- "Create, validate, and" → loses "validate" as equal action
- "Against best practices" → loses specificity about what validation means
- "Skill structure" → lost entirely
- "Production readiness" → changed to "safety" (different meaning)

## Safe Refinement Patterns

✅ **Reordering** - Rearrange sections, same content
✅ **Clarifying** - Reword confusing language, preserve meaning
✅ **Adding trigger phrases** - Make description more activation-friendly (add, don't remove)
✅ **Consolidating** - Merge redundant sections, don't erase

## The Movement Pattern (STRICTLY ENFORCED)

**For ANY content movement** (within file, between files, skill ↔ references):

1. **Create/update the destination FIRST** with complete content
2. **Verify destination exists and is complete**
3. **THEN remove from source**

This applies to:
- Moving SKILL.md → references/ files
- Moving references/ → SKILL.md (bringing context back)
- Moving between references/ files
- Reorganizing within SKILL.md or references/
- Consolidating duplicate content

❌ **WRONG (content disappears):**
```
1. Remove content from source
2. Intend to add to destination
3. Never actually add it
→ Content is lost
```

✅ **CORRECT (content preserved):**
```
1. Add/update content in destination
2. Verify destination has complete content
3. Remove from source
→ Content is relocated, not lost
```

**This is enforced as a gate:** If content is removed but no corresponding content appears in destination, the refinement is REJECTED.

## The Litmus Test

Before accepting ANY refinement, verify:

1. **Is the description still accurate?** Would someone understand all capabilities?
2. **Was anything important deleted?** Or just reorganized?
3. **Is scope preserved?** All major use cases still present?
4. **Is it still complete?** Or just shorter for brevity's sake?

If you cut something for brevity, it's not refinement—it's damage.

## When Refinement is Appropriate

- Simplifying overly complex language
- Moving examples/details to references (keeping originals)
- Adding missing trigger phrases
- Fixing typos or grammar
- Reorganizing for clarity
- Updating version numbers
- Adding/removing tools in scope

## When Refinement is NOT Appropriate

- Shortening descriptions to "save space"
- Removing qualifiers to "make it punchier"
- Deleting sections to "reduce complexity"
- Combining unrelated ideas into fewer words
- "Updating" scope (use case removal)

**Rule:** If you're cutting content, it's not refinement. It's deletion disguised as editing.
