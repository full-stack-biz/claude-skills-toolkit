#!/bin/bash

# Backup skill before refinement (PreToolUse hook)
# Reads hook input from stdin as JSON
# Non-critical: failures should not block the write operation

# Read JSON hook input from stdin
INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

# Skip if FILE_PATH is empty or null
if [ -z "$FILE_PATH" ] || [ "$FILE_PATH" = "null" ]; then
  exit 0
fi

SKILL_DIR=$(dirname "$FILE_PATH")

# Only back up if this is an existing skill (SKILL.md exists)
# Skip for new skill creation
if [ ! -f "$SKILL_DIR/SKILL.md" ]; then
  # New skill being created - nothing to back up
  echo "" > /tmp/skill-backup-location.txt 2>/dev/null || true
  exit 0
fi

BACKUP_DIR="${SKILL_DIR}.backup"

# Back up existing skill (non-critical failure)
if ! cp -r "$SKILL_DIR" "$BACKUP_DIR" 2>/dev/null; then
  exit 1  # Non-blocking error
fi

# Store backup location for cleanup and validation
if ! echo "$BACKUP_DIR" > /tmp/skill-backup-location.txt 2>/dev/null; then
  exit 1  # Non-blocking error
fi

echo "✅ Skill backup created: $BACKUP_DIR"
exit 0
