# Automated Scanning Workflow

**Use this guide when validating existing plugins.** The scanning workflow automates common validation issues before manual checking.

## Table of Contents
- [Workflow Overview](#workflow-overview)
- [Scanner Output](#scanner-output)
- [Processing Errors](#processing-errors)
- [Processing Warnings](#processing-warnings)
- [User Decisions](#user-decisions)
- [Executing Changes](#executing-changes)
- [Example Workflow](#example-workflow)
- [Safety Guarantees](#safety-guarantees)

---

## Workflow Overview

The scanning phase is **read-only only**—it scans and reports, never modifies. User decisions are explicit and visible.

### Steps

1. **Run the read-only scanner:**
   ```bash
   bash /path/to/plugin-creator/scripts/scan-plugin.sh /path/to/plugin /tmp/plugin-scan.json
   ```
   This generates a structured JSON report with three categories:
   - **errors**: Critical issues that prevent installation (must fix)
   - **warnings**: Best-practice violations (should fix)
   - **decisions_needed**: Items requiring user choice (files to delete, permissions to set, etc.)

---

## Scanner Output

### Read and Interpret the JSON Report

Parse the JSON to identify what the scanner found. Output should show:
- A summary count of errors, warnings, decisions
- Errors printed first (must fix before validation)
- Warnings categorized by type (security, naming, documentation, etc.)
- Decisions with target file/directory for user approval

---

## Processing Errors

**Process errors FIRST before any other action.**

For each error, report it clearly and suggest the fix. Example:

```
❌ MANIFEST ERROR: Missing .claude-plugin/plugin.json
   Fix: Run mkdir -p .claude-plugin and create plugin.json
```

Do not proceed to warnings or decisions until all errors are resolved.

---

## Processing Warnings

**Process warnings AFTER errors are fixed.**

Categorize by type and show user. Example:

```
⚠ SECURITY WARNING: Script contains hardcoded secrets
   File: scripts/deploy.sh
   Suggestion: Move secrets to environment variables

⚠ NAMING WARNING: Command name 'Check_Status' doesn't follow convention
   File: commands/Check_Status.md
   Suggestion: Rename to 'check-status'
```

---

## User Decisions

**Present decisions via AskUserQuestion.**

### Non-standard Files in .claude-plugin/

```
Question: "Found non-standard files in .claude-plugin/. What should we do?"
Header: "File Cleanup"
Options:
- Delete all non-standard files (Recommended) - Removes MANIFEST.md, etc.
- Review each file - Show what's in .claude-plugin/ and decide individually
- Keep as-is - Leave everything
```

### Orphaned Directories

```
Question: "Found non-standard directory '[name]'. Keep it or remove?"
Header: "Directory Cleanup"
Options:
- Delete '[name]' - Remove the directory
- Keep '[name]' - Custom structure is OK
- Review all directories - List all and decide each one
```

### Executable Scripts

```
Question: "Script '[filename]' is not executable. Fix permissions?"
Header: "Permissions"
Options:
- Make executable (Recommended) - Run chmod +x
- Leave as-is - Keep current permissions
```

### Security Warnings that Need Action

```
Question: "Script '[filename]' contains potential secrets. Review and remove?"
Header: "Security"
Options:
- Review now - Show file content so you can clean it
- Already cleaned - Skip this check
- Keep as-is - It's not actually a secret
```

---

## Executing Changes

After user approves each decision category, run the specific commands:

### User Approved: Delete Files

```bash
rm -rf /path/to/.claude-plugin/MANIFEST.md
rm -rf /path/to/.claude-plugin/REFINEMENT_SUMMARY.md
```

### User Approved: Fix Permissions

```bash
chmod +x /path/to/scripts/deploy.sh
chmod +x /path/to/scripts/validate.sh
```

**Always show the exact command before executing. Give user a final chance to abort.**

---

## Re-scan After Changes

After applying decisions, re-run the scanner to verify issues are resolved:

```bash
bash /path/to/plugin-creator/scripts/scan-plugin.sh /path/to/plugin /tmp/plugin-scan-v2.json
```

---

## Proceed to Manual Validation

Once scan passes with no errors/decisions:

```bash
claude plugin validate /path/to/plugin
```

Then check best practices from `references/validation-checklist.md`.

---

## Example Workflow

```
User: "validate my-plugin"
        ↓
1. Scanner runs (read-only) → finds 2 non-standard files, 1 permission issue
        ↓
2. Claude reports errors/warnings clearly
        ↓
3. Claude asks: "Delete .claude-plugin/MANIFEST.md and REFINEMENT_SUMMARY.md?"
        User: "Yes"
        ↓
4. Claude shows exact rm commands, waits for implicit approval (no confirmation needed, but visible)
        ↓
5. Claude asks: "Make scripts/scan-plugin.sh executable?"
        User: "Yes"
        ↓
6. Claude runs chmod +x
        ↓
7. Claude re-runs scanner → clean
        ↓
8. Claude runs claude plugin validate → passes
        ↓
9. Claude checks best practices from validation-checklist
        ↓
10. Final report: "✔ Plugin is ready"
```

---

## Safety Guarantees

- **Scanner never modifies files** — read-only only
- **No silent changes** — every action is explicitly approved by user
- **Visible execution** — user sees exact bash commands before they run
- **Reversible process** — user can choose "review individually" to be conservative
