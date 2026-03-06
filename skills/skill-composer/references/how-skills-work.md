# How Skills Work: Foundations & Architecture

## Table of Contents
- [What Skills Are (Mental Model)](#what-skills-are-mental-model)
- [Architecture (How Skills Work Internally)](#architecture-how-skills-work-internally)
- [Token Loading Hierarchy](#token-loading-hierarchy)
- [Selection Mechanism](#selection-mechanism)
- [Execution Model](#execution-model)

## What Skills Are (Mental Model)

Skills are **onboarding guides for specialized tasks**—modular instruction packages Claude loads dynamically when relevant. They transform Claude from general-purpose to domain-expert with procedural knowledge no model inherently possesses.

| Aspect | CLAUDE.md | Skills |
|--------|-----------|--------|
| Loading | Always (startup) | On-demand (triggered) |
| Scope | Project-wide rules | Task-specific workflows |
| Context cost | Every conversation | Only when needed |
| Structure | Single file | Directory with resources |

**Use CLAUDE.md for**: Unchanging conventions, coding standards, always-on project rules.
**Use Skills for**: Complex workflows, scripts, templates, domain expertise activated contextually.

---

## Architecture (How Skills Work Internally)

### Token Loading Hierarchy

```
Level 1: Metadata only (always loaded)     ~100 tokens
         name + description in system prompt
                    ↓
Level 2: SKILL.md body (on trigger)        ~1,500-5,000 tokens
         Full instructions load after skill selected
                    ↓
Level 3: Bundled resources (as-needed)     Unlimited
         scripts/ references/ assets/
         Only read when Claude determines necessary
```

**Key insight:** Only SKILL.md body loads when triggered. Reference files load on-demand. This three-level architecture enables rich, complex skills without token bloat.

### Selection Mechanism

**Pure LLM reasoning—no algorithmic matching.** Claude evaluates all skill descriptions via natural language understanding, not embeddings/classifiers/keyword-matching.

This means:
- **Description quality is critical** for triggering
- Vague descriptions → skill never triggers
- Specific trigger phrases → reliable activation
- Synonyms in descriptions help with discovery

**How Claude selects skills:**
1. Claude reads description field from all available skills
2. Claude uses semantic understanding to match user query to skill purpose
3. If description matches query intent, Claude triggers the skill
4. Full SKILL.md body loads and execution begins

### Execution Model

Skills use a **dual-message injection pattern**:
1. **Metadata message** (`isMeta: false`) — visible to user as status
2. **Skill prompt message** (`isMeta: true`) — hidden from UI, sent to API

This provides transparency without dumping instruction walls into chat. Users see "Skill activated: skill-name" while the full skill content is injected into the system prompt.

---

## Token Cost Implications

Understanding the three-level architecture helps optimize skill design:

- **Level 1 (Metadata)** is always loaded, so descriptions must be concise and specific
- **Level 2 (SKILL.md)** loads when triggered, so keep it <500 lines and actionable
- **Level 3 (References)** loads only when needed, so comprehensive content is free once the skill triggers

This architecture means:
- ✅ Long reference files are fine (only loaded on-demand)
- ✅ Detailed documentation can be comprehensive without penalty
- ✅ Quick Start sections are critical (should solve 80% of use cases)
- ❌ Lengthy prose in SKILL.md body wastes tokens

---

## Why This Matters for Skill Design

The execution model explains why certain design principles are critical:

1. **Description must be specific** — Claude uses LLM reasoning, not keyword matching. Vague descriptions fail.
2. **Quick Start is essential** — Most tasks solved in SKILL.md without loading references saves token overhead.
3. **Refactoring into references is valuable** — Moving content out of SKILL.md reduces on-trigger token cost with no downside.
4. **Progressive disclosure works** — Actionable quick content upfront, detailed content available when needed.
