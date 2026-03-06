#!/bin/bash
# Hook: Load CLAUDE.md at session start
# Purpose: Ensure CLAUDE.md is loaded before any operations
# Event: SessionStart
# Type: Developer tool (not part of plugin)

set -euo pipefail

# Define CLAUDE.md path relative to repository root
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
CLAUDE_MD="$REPO_ROOT/CLAUDE.md"

# Validate CLAUDE.md exists
if [ ! -f "$CLAUDE_MD" ]; then
  echo "❌ CLAUDE.md not found at $CLAUDE_MD" >&2
  exit 2
fi

# Output entire CLAUDE.md (single source of truth, not hardcoded)
cat "$CLAUDE_MD"

exit 0
