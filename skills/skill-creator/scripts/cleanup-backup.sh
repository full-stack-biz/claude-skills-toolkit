#!/bin/bash
# Cleanup backup after skill refinement validation (PostToolUse hook)
# Non-critical: failures should not affect execution
# Runs async in background

BACKUP_DIR=$(cat /tmp/skill-backup-location.txt 2>/dev/null)

# Remove backup directory if it exists
if [ -n "$BACKUP_DIR" ]; then
  if ! rm -rf "$BACKUP_DIR" 2>/dev/null; then
    echo "⚠️  Warning: Could not remove skill backup directory" >&2
    # Continue cleanup anyway
  else
    echo "🧹 Backup cleaned up"
  fi
fi

# Remove temp files (best effort)
rm -f /tmp/skill-backup-location.txt 2>/dev/null || true
rm -f /tmp/original-skill.txt 2>/dev/null || true

exit 0
