#!/bin/bash

# Backup skill before refinement (PreToolUse hook)
# Non-critical: failures should not block the write operation

FILE_PATH="$1"
SKILL_DIR=$(dirname "$FILE_PATH")

# Only back up if this is an existing skill (SKILL.md exists)
# Skip for new skill creation
if [ ! -f "$SKILL_DIR/SKILL.md" ]; then
  # New skill being created - nothing to back up
  echo "" > /tmp/skill-backup-location.txt 2>/dev/null || true
  echo "" > /tmp/original-skill.txt 2>/dev/null || true
  exit 0
fi

BACKUP_DIR="${SKILL_DIR}.backup"

# Back up existing skill (non-critical failure)
if ! cp -r "$SKILL_DIR" "$BACKUP_DIR" 2>/dev/null; then
  echo "Warning: Could not back up skill (continuing anyway)" >&2
  exit 1  # Non-blocking error
fi

# Capture content for prompt hook comparison
# Gracefully handle missing directories
if ! {
  cat "$SKILL_DIR/SKILL.md" 2>/dev/null
  [ -d "$SKILL_DIR/references" ] && find "$SKILL_DIR/references" -type f -exec cat {} \; 2>/dev/null || true
} > /tmp/original-skill.txt 2>/dev/null; then
  echo "Warning: Could not capture original skill content" >&2
  exit 1  # Non-blocking error
fi

# Store backup location for cleanup
if ! echo "$BACKUP_DIR" > /tmp/skill-backup-location.txt 2>/dev/null; then
  echo "Warning: Could not store backup location" >&2
  exit 1  # Non-blocking error
fi

exit 0
