# Personal Skills Discovery Bug in Claude Code

**Status:** Open bug, unresolved
**Affects:** Claude Code v2.0.31 - v2.1.20+ (all versions since skills launch)
**GitHub Issue:** [#9716](https://github.com/anthropics/claude-code/issues/9716)
**Related Issue:** [#19212](https://github.com/anthropics/claude-code/issues/19212) (Skill tool recognition)

## Problem Summary

Personal skills stored in `~/.claude/skills/` are not discoverable by Claude Code, even though the documentation states they should auto-load. Project-level skills (`.claude/skills/`) work more reliably, but personal skills are completely ignored.

## Expected Behavior (Per Documentation)

From [code.claude.com/docs/en/skills](https://code.claude.com/docs/en/skills):

> Skills are automatically discovered from `~/.claude/skills/` and `.claude/skills/` directories.

| Location | Path | Applies to |
|----------|------|------------|
| Personal | `~/.claude/skills/<skill-name>/SKILL.md` | All your projects |
| Project | `.claude/skills/<skill-name>/SKILL.md` | This project only |

Personal skills should appear in `/context` output and be available via `/skill-name` invocation.

## Actual Behavior

1. **Personal skills don't appear in `/context`** - Only project and plugin skills are listed
2. **`<available_skills>` is empty** for personal skills
3. **Skills load at filesystem level but not into context** - Debug logs show skills loading, but Claude doesn't see them
4. **`/skill-name` fails** with "Unknown skill" for personal skills

### Evidence from Debug Logs

```
2026-01-19T08:05:28.062Z [DEBUG] Loaded 12 unique skills (managed: 0, user: 12, project: 0, legacy commands: 0)
2026-01-19T08:05:28.062Z [DEBUG] getSkills returning: 12 skill dir commands, 0 plugin skills, 0 bundled skills
```

Skills ARE loaded from the filesystem, but Claude cannot access them.

## Investigation Results

### Test Case

**Setup:**
- Personal skills in `~/.claude/skills/`:
  - `document-external-connections/SKILL.md` (8KB)
  - `fact-check/SKILL.md` (4.8KB)
- Project skills in `.claude/skills/` (5 skills, ~44KB total)
- Valid YAML frontmatter in all SKILL.md files

**Results from `/context`:**
```
Skills · /skills

Project
└ laravel-di-testing: 128 tokens
└ laravel-pennant: 114 tokens
└ migration-research: 72 tokens
└ phpstan: 59 tokens
└ test-runner: 59 tokens

Plugin
└ hook-creator: 126 tokens
└ plugin-creator: 107 tokens
[... plugin skills ...]
```

**Missing:** `document-external-connections` and `fact-check` (personal skills)

### Character Budget Theory (Disproven)

Initial hypothesis: Skills exceed the 15,000 character budget.

**Reality:** Total skills usage was only 1.3k tokens (0.6%), well under the budget. No warning about excluded skills appeared. The budget is not the issue.

## Root Cause

Unknown. The bug appears to be in how Claude Code injects personal skills into the `<available_skills>` context that the model sees. Skills are discovered at the filesystem level but not passed to the model.

## Confirmed Workarounds

### 1. Use Project-Level Skills Instead (Most Reliable)

Move personal skills to `.claude/skills/` in each project:

```bash
cp -r ~/.claude/skills/my-skill .claude/skills/
```

**Downside:** Must duplicate across all projects.

### 2. Add a Hook to Force Skill Evaluation

From @spences10 (84% success rate in testing):

```json
{
  "UserPromptSubmit": [
    {
      "hooks": [
        {
          "type": "command",
          "command": "echo '\\n\\nIF THERE IS A SKILL FOR THIS USE IT! PLEASE CHECK.'"
        }
      ]
    }
  ]
}
```

Or use the [claude-skills-cli](https://github.com/spences10/claude-skills-cli):

```bash
pnpx claude-skills-cli add-hook --type forced-eval
```

### 3. Symlink Personal Skills into Project

```bash
ln -s ~/.claude/skills/my-skill .claude/skills/my-skill
```

### 4. Reference Skills in CLAUDE.md

Add explicit instructions in `~/.claude/CLAUDE.md`:

```markdown
## Available Skills

When relevant, use these skills:
- `/document-external-connections` - For documenting API connections
- `/fact-check` - For verifying documentation accuracy
```

This doesn't fix discovery but increases the chance Claude will search for them.

### 5. Check YAML Formatting

Multiline descriptions can break skill loading. Use single-line:

```yaml
# GOOD
---
name: my-skill
description: Short description on one line
---

# BAD
---
name: my-skill
description:
  Long description
  on multiple lines
---
```

## Community Reports

### @JacksonBates:
> "global skill discovery does nothing for me, i.e. `~/.claude/skills/my-skill/SKILL.md` is not discoverable at all despite file naming, description content or valid yaml front-matter formatting"

### @spences10:
> "I found an inode INT overflow bug which may be related... Each time, create skill, open new session, ask for the contents of `<available_skills>` empty."

### @Nantris:
> "This issue severely limits the usefulness of Claude Code and has wasted a lot of my time jumping through hoops trying to get it working before I came across this issue to find that the feature simply does not work months after roll-out."

### @dellis23:
> "Even though my skills are in the available_skills section, here's what claude code has to say about them: 'The skills are documentation that I need to actively consult -- they don't run automatically'"

## Timeline

- **Skills feature launched:** ~October 2024
- **Issue #9716 opened:** Shortly after launch
- **Current status (Jan 2026):** Still open, no official fix
- **Anthropic response:** None on this issue

## Recommendations

1. **For immediate use:** Put skills at project level (`.claude/skills/`)
2. **For cross-project skills:** Use a plugin instead of personal skills
3. **Report the bug:** Add your experience to [#9716](https://github.com/anthropics/claude-code/issues/9716)
4. **Monitor for fixes:** Check the [Claude Code changelog](https://code.claude.com/docs/en/changelog.md)

## Related Resources

- [Skills Documentation](https://code.claude.com/docs/en/skills)
- [GitHub Issue #9716](https://github.com/anthropics/claude-code/issues/9716) - Main tracking issue
- [GitHub Issue #19212](https://github.com/anthropics/claude-code/issues/19212) - Skill tool recognition
- [GitHub Issue #9710](https://github.com/anthropics/claude-code/issues/9710) - Duplicate issue
- [Scott Spence's Blog Post](https://scottspence.com/posts/how-to-make-claude-code-skills-activate-reliably) - Hook workaround
- [Claude Skills CLI](https://github.com/spences10/claude-skills-cli) - Community tool for skill management

## Environment Variables

```bash
# Increase skill character budget (not the fix, but documented for reference)
export SLASH_COMMAND_TOOL_CHAR_BUDGET=60000
```

---

*Last updated: January 27, 2026*
