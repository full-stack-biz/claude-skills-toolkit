#!/bin/bash
set -e

# Parse file path from PreToolUse arguments
FILE_PATH="$1"
SKILL_DIR=$(dirname "$FILE_PATH")
BACKUP_DIR="${SKILL_DIR}.backup"

# Create backup using cp -r
cp -r "$SKILL_DIR" "$BACKUP_DIR"

# Capture content for prompt hook comparison
{
  cat "$SKILL_DIR/SKILL.md"
  [ -d "$SKILL_DIR/references" ] && find "$SKILL_DIR/references" -type f -exec cat {} \;
} > /tmp/original-skill.txt

# Store backup location for cleanup
echo "$BACKUP_DIR" > /tmp/skill-backup-location.txt

exit 0
