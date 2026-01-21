# Team & Production Skill Patterns

When creating skills for team environments or production systems, ensure Claude will execute them robustly. This guide covers patterns for error handling, tool scoping, validation, security, and documentation that apply to ~25% of skill uses.

## Error Handling

Robust error handling ensures Claude doesn't silently fail or produce confusing output.

**Principles:**
- Use try/except blocks in scripts and explicitly communicate failures to Claude
- Provide clear error messages Claude can understand and act upon
- Don't hide errors; make them actionable (e.g., "Missing file: X. Create it with `mkdir -p Y`")
- Document expected error conditions and recovery steps

**Example:**
```python
try:
    result = execute_deployment()
except DeploymentError as e:
    print(f"ERROR: Deployment failed at {e.step}: {e.message}")
    print(f"Recovery: {e.recovery_instructions}")
    sys.exit(1)
```

## Tool Scoping

Minimal permissions protect both the codebase and user systems.

**Principles:**
- Apply principle of least privilege: declare only tools Claude actually needs
- Use tool restrictions like `Bash(git:*)` to limit which bash commands run
- Document why each tool is needed in frontmatter comments
- Avoid over-permissioning; add tools conservatively

**Example frontmatter:**
```yaml
---
name: git-release
allowed-tools: Read, Bash(git:*), Write
---
```

## Validation Scripts

Include example code Claude can reference and execute.

**Principles:**
- Provide copy-paste examples for common validation patterns
- Scripts should exit with clear success/failure status
- Output should be machine-readable when possible
- Document assumptions and dependencies

**Example:**
```bash
#!/bin/bash
# Validate skill structure
[[ -f SKILL.md ]] || { echo "ERROR: SKILL.md missing"; exit 1; }
[[ -d references ]] || { echo "ERROR: references/ missing"; exit 1; }
echo "✓ Skill structure valid"
```

## Security Review

Peer review catches edge cases and security assumptions.

**Principles:**
- Document security assumptions explicitly (e.g., "Assumes private repository")
- Flag potential injection points (user input, external data)
- Consider: What happens if Claude runs this with malicious input?
- Have team review before deploying to production

**Checklist:**
- [ ] Input validation: All user/external input sanitized?
- [ ] Command injection: Shell commands safe from argument injection?
- [ ] Data exposure: Sensitive data not logged or exposed?
- [ ] Permissions: Tool scoping appropriate?
- [ ] Failure modes: Graceful degradation on errors?

## Clear Documentation

Team members (and Claude in future sessions) need context to use skills effectively.

**What to document:**
- Integration points: Where does this skill fit in your workflow?
- Failure modes: What goes wrong? How to recover?
- Dependencies: What systems must be running? What must be configured?
- Assumptions: What does this skill assume about the environment?
- Limitations: What edge cases aren't handled?

**Example documentation section:**
```markdown
## Production Readiness Checklist

- Requires: Kubernetes cluster with kubectl access
- Assumes: Deployment configuration in `k8s/` directory
- Limitations:
  - Does not handle multi-region deployments
  - Requires manual verification for production-critical changes
- Recovery: See `troubleshooting-section` if deployment rolls back
```

## For Common Patterns

See `templates.md` → Workflow Pattern Examples and Optional Frontmatter Fields for team/production patterns in skill structure and execution.
