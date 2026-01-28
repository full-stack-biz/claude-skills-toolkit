#!/bin/bash
# Remove backup after validation completes
BACKUP_DIR=$(cat /tmp/skill-backup-location.txt 2>/dev/null)
[ -n "$BACKUP_DIR" ] && rm -rf "$BACKUP_DIR"
rm -f /tmp/skill-backup-location.txt /tmp/original-skill.txt
exit 0
