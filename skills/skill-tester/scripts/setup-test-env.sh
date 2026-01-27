#!/bin/bash
# setup-test-env.sh - Create isolated test environment for skill testing
# Usage: bash setup-test-env.sh SKILL_NAME [--source-dir PATH]

set -e

SKILL_NAME=$1
SOURCE_DIR=$(cd "${2:-.}" && pwd)  # Convert to absolute path
TEST_BASE="/tmp/skill-test"
TEST_DIR="$TEST_BASE/$SKILL_NAME"

if [ -z "$SKILL_NAME" ]; then
    echo "Error: Usage: bash setup-test-env.sh SKILL_NAME [--source-dir PATH]"
    exit 1
fi

# Locate skill source (search project first, then user-space)
find_skill() {
    local name=$1

    # Search project paths
    if [ -d "$SOURCE_DIR/skills/$name" ]; then
        echo "$SOURCE_DIR/skills/$name"
        return 0
    fi

    if [ -d "$SOURCE_DIR/.claude/skills/$name" ]; then
        echo "$SOURCE_DIR/.claude/skills/$name"
        return 0
    fi

    # Search user-space
    if [ -d "$HOME/.claude/skills/$name" ]; then
        echo "$HOME/.claude/skills/$name"
        return 0
    fi

    echo "Error: Skill not found: $name (searched: $SOURCE_DIR/skills/$name, $SOURCE_DIR/.claude/skills/$name)" >&2
    return 1
}

SKILL_PATH=$(find_skill "$SKILL_NAME") || exit 1

echo "Setting up test environment for: $SKILL_NAME"
echo "Source: $SKILL_PATH"

# Create test directory
mkdir -p "$TEST_DIR"
rm -rf "$TEST_DIR" 2>/dev/null || true
mkdir -p "$TEST_DIR"

# Copy skill to test directory as isolated copy (read-only isolation)
cp -r "$SKILL_PATH" "$TEST_DIR/skill"

# Store original path for comparison
echo "$SKILL_PATH" > "$TEST_DIR/original_path.txt"

echo "✓ Test environment created at: $TEST_DIR"
echo "✓ Skill copied to: $TEST_DIR/skill"
echo "✓ Original at: $SKILL_PATH"

# Output skill path for use by other scripts
echo "$TEST_DIR/skill"
