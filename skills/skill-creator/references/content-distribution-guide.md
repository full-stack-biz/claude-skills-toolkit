# Content Distribution: SKILL.md vs References

## The Problem

When refining skills, skill-creator sometimes moves core procedural content (patterns, examples, workflows) to references to reduce SKILL.md line count. This backfires: Claude must now load a separate reference file to execute the 80% case.

**Example (release-process skill):** All 4 pattern examples (54 lines) moved to `release-patterns.md`. Result: Claude executes most releases using those patterns, but now has to load external references instead of having them ready in the loaded SKILL.md body.

## Decision Tree: What Stays vs. Moves

Ask this question first: **"Will Claude execute this in 80%+ of cases?"**

### STAYS in SKILL.md (Core Procedural)

✅ Pattern examples Claude directly executes (e.g., "patch release", "breaking change")
✅ Step-by-step workflows for the common case
✅ Copyable code blocks or commands users run frequently
✅ Essential examples that illustrate the main task
✅ Concrete input/output samples
✅ Decision trees Claude follows to execute the task

**Examples:**
- Release-process skill: All 4 pattern examples (patch, feature, breaking, scope creep) stay in SKILL.md because Claude executes every release using one of these patterns
- PDF processor skill: Basic extraction workflow stays in SKILL.md; OCR configuration for specific document types moves to references
- Test runner skill: Standard test execution (80% case) stays; complex parallel configuration (edge case) moves to references

### MOVES to References (Supplementary)

📚 Edge cases beyond the common workflow
📚 Alternative approaches for power users (e.g., "if you need advanced configuration")
📚 Deep context on adjacent topics (history, architecture, related tools)
📚 Expanded explanations of concepts already covered in main body
📚 Troubleshooting guides for uncommon failure modes
📚 Advanced configuration options
📚 Related domain knowledge (not directly needed to execute the task)

**Examples:**
- Release-process skill: Monorepo multi-component coordination (beyond single-component pattern) → references
- PDF processor skill: Deep dive into OCR algorithms → references
- Test runner skill: History of testing frameworks → references

## The 80% Rule

**80% rule:** If Claude will execute the content in 80%+ of skill activations, it stays in SKILL.md. If it's an edge case or alternative, it moves to references.

This creates efficiency: SKILL.md body loads on every trigger; references load zero-penalty when needed.

## Avoid This Mistake

❌ **Don't:** Move detailed content just because it's long
- Reason: If that content is core procedural, Claude needs it immediately

❌ **Don't:** Assume "examples = reference material"
- Reason: Examples are how Claude understands the task; if they're patterns for common cases, they're core

❌ **Don't:** Optimize token count at the cost of having Claude load external files for core execution
- Reason: SKILL.md body loads anyway on trigger; moving core content doesn't save tokens, just adds a file load

✅ **Do:** Ask "Will Claude execute this in 80%+ of cases?"
- If yes: Keep it in SKILL.md
- If no: Move it to references

## Content Size

SKILL.md body must stay <500 lines (non-negotiable).

If your core procedural content for the 80% case exceeds 500 lines, that's the skill's true size. In rare cases, split into two skills (e.g., "basic-skill" for common cases, "advanced-skill" for complex workflows).

## References Structure

One level deep only:
```
skill-name/
├── SKILL.md              (core procedural, <500 lines)
├── references/
│   ├── edge-cases.md     (uncommon scenarios)
│   ├── configuration.md  (advanced options)
│   └── related-context.md (adjacent knowledge)
```

Files in `references/` load on-demand with zero token penalty until Claude needs them.
