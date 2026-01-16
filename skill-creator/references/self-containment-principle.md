# Self-Containment Principle for Skills

## Core Principle

**Skills must be self-contained.** A skill should not depend on external references, network fetches, or information that must be downloaded from outside the skill directory. Everything needed to use the skill must be bundled with it.

**Why this matters:**
- **Reliability**: No network latency, no external service outages affecting skill performance
- **Reproducibility**: Same skill works identically across environments and time
- **Portability**: Skills deploy anywhere without configuration or external dependencies
- **User experience**: Instant access without waiting for remote resources
- **Security**: No uncontrolled network access or third-party dependencies

---

## What Self-Containment Means

### ✅ Allowed: Bundled Within Skill

Everything the skill needs should be included in the skill directory:

```
skill-name/
├── SKILL.md              # Instructions + metadata
├── scripts/              # Executable code
│   ├── process.py
│   └── validate.sh
├── references/           # Documentation, schemas, data
│   ├── api-guide.md
│   ├── schema.json
│   └── config-examples.md
└── assets/               # Output templates, files
    └── template.docx
```

**Examples of self-contained content:**
- ✅ JSON schemas bundled in `references/`
- ✅ Example data or test files in `references/`
- ✅ Configuration examples in `references/`
- ✅ Complete API documentation in `references/`
- ✅ Helper scripts in `scripts/`
- ✅ Output templates in `assets/`

### ❌ Forbidden: External References (Exceptions Below)

Skills should NOT depend on:
- 🚫 Downloading files from remote URLs
- 🚫 Fetching documentation from websites
- 🚫 Making API calls to external services for skill operation
- 🚫 Requiring internet connection to function
- 🚫 Storing state in external databases
- 🚫 Referencing credentials stored outside the skill

**Examples to avoid:**
- ❌ "See the API docs at https://api.example.com/docs"
- ❌ "Fetch config from cloud storage"
- ❌ "Download the latest schema from the registry"
- ❌ "Call this endpoint to get the list of valid options"

---

## When External Access is Acceptable

### Network Access (Rare, Justified Cases)

Network calls are acceptable **only when**:
1. **It's the core purpose of the skill** — The skill's job is to fetch/query external data
2. **It's user-controlled** — User explicitly requests the network call
3. **It's non-critical to operation** — Network failure doesn't break the skill
4. **It's from trusted sources** — Only internal APIs or well-established services
5. **It's scoped in allowed-tools** — Declared in skill frontmatter with `Bash(curl:*)`

**Examples where network is acceptable:**
- ✅ A "weather checker" skill that fetches current weather
- ✅ A "GitHub helper" skill that queries GitHub's public API on request
- ✅ A "log analyzer" skill that fetches logs from a company's log service (user-initiated)

**But even then:** Cache results, document dependencies, provide offline fallbacks if possible.

### Building on Other Skills

A skill can depend on another skill if:
1. **It's optional** — Skill works without it, but has enhanced features with it
2. **It's documented** — Clear in description and documentation which skill(s) it builds on
3. **It's internal to the system** — Both skills are deployed together

**Example:**
```yaml
# ✅ GOOD - skill-creator extends from skill ecosystem
description: >-
  Create and refine Claude Code skills following best practices.
  Use when building new skills, validating existing skills, or improving skill quality.
  Integrates with skill validation ecosystem.
```

---

## Implementation Guidelines

### 1. Use references/ for All Documentation

Instead of linking to external docs, include content in `references/`:

```markdown
# BAD
For database schema details, see https://company.wiki/schemas

# GOOD
For database schema details, see references/database-schema.md
```

If content is large (>10KB), create a separate reference file:
```
references/
├── quick-reference.md
├── database-schema.md
├── api-operations.md
└── troubleshooting.md
```

### 2. Include Example Data in references/

Provide sample files or data:

```
references/
├── example-config.json
├── sample-data.csv
└── test-cases.md
```

This lets Claude work with realistic examples without fetching external data.

### 3. Document Required External Tools

If the skill must call external services (rare), document clearly:

```yaml
---
name: github-helper
allowed-tools: Bash(curl:*)
description: >-
  Interact with GitHub repositories. Use when querying GitHub for
  repository info, creating issues, or pulling pull request data.
  Requires GitHub API access and curl.
---
```

In SKILL.md, document:
```markdown
## Prerequisites
- GitHub API token (set GITHUB_TOKEN env var)
- curl for API calls

## Network Dependencies
This skill makes HTTPS calls to api.github.com:
- GET /repos/{owner}/{repo} — Fetch repository details
- GET /repos/{owner}/{repo}/pulls — List pull requests

All calls use GitHub's public API.
```

### 4. Validate Self-Containment During Creation

Before deploying a skill:

- [ ] All referenced files exist in the skill directory
- [ ] No external URLs in SKILL.md (except in notes/sources)
- [ ] No required network calls (except where documented as core feature)
- [ ] All example data is bundled
- [ ] No external configuration required (except env vars for credentials)
- [ ] No mandatory tools beyond what's in `allowed-tools`

### 5. Anti-Patterns: Beware of These

❌ **Don't reference external wikis/docs:**
```markdown
For details, see https://internal.wiki/database
```
Instead, include the docs in `references/`

❌ **Don't require downloading external files:**
```python
# BAD - requires internet and setup
urllib.request.urlretrieve("https://...", "config.json")
```
Instead, bundle files in the skill or have user provide them

❌ **Don't make non-user-initiated network calls:**
```python
# BAD - auto-fetches without asking
schema = requests.get("https://api.example.com/schema").json()
```
Instead, bundle schema or ask user to provide it

❌ **Don't rely on environment-specific external services:**
```python
# BAD - breaks if service is down or unreachable
check_status = requests.get("https://status.example.com")
```
Instead, fail gracefully with clear error messages

---

## Self-Containment Checklist

When validating a skill, verify:

- [ ] **SKILL.md has no external URL references** (except in Sources/Acknowledgments)
- [ ] **All documentation is in references/** — no "see external doc" links
- [ ] **Example data is bundled** — sample files in references/ if needed
- [ ] **Scripts don't require external downloads** — all dependencies listed
- [ ] **No network calls unless documented** — and only user-initiated
- [ ] **No external configuration required** — skill works after deployment
- [ ] **All required files exist in skill directory** — no missing dependencies
- [ ] **Credentials/secrets are user-provided** — not stored externally

---

## Why This Principle Protects Future Skills

Without the self-containment principle, skills become fragile:
- External docs get moved/deleted → skill breaks
- Network access fails → skill unusable
- External services change → skill needs updates
- Skills scattered across wikis/repos → hard to maintain
- Setup complexity increases → adoption drops

With the self-containment principle:
- Skills are portable and reliable
- Deploy once, works everywhere
- No external maintenance burden
- Clear scope and dependencies
- Easier to share and collaborate on

