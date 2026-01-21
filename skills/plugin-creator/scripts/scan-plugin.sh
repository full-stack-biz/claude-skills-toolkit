#!/bin/bash
# Plugin Scanner - Read-only automated validation for Claude Code plugins
# Outputs JSON with categorized issues for Claude to process
# IMPORTANT: This script only SCANS and REPORTS. It does NOT modify files.

set -e

PLUGIN_PATH="${1:-.}"
OUTPUT_FILE="${2:-/tmp/plugin-scan-results.json}"

# Helper functions
init_json() {
    cat > "$OUTPUT_FILE" <<'EOF'
{
  "errors": [],
  "warnings": [],
  "decisions_needed": []
}
EOF
}

add_error() {
    local category="$1"
    local message="$2"
    local suggestion="${3:-}"

    jq --arg cat "$category" --arg msg "$message" --arg sug "$suggestion" \
        '.errors += [{category: $cat, message: $msg, suggestion: $sug}]' \
        "$OUTPUT_FILE" > "$OUTPUT_FILE.tmp" && mv "$OUTPUT_FILE.tmp" "$OUTPUT_FILE"
}

add_warning() {
    local category="$1"
    local message="$2"
    local suggestion="${3:-}"

    jq --arg cat "$category" --arg msg "$message" --arg sug "$suggestion" \
        '.warnings += [{category: $cat, message: $msg, suggestion: $sug}]' \
        "$OUTPUT_FILE" > "$OUTPUT_FILE.tmp" && mv "$OUTPUT_FILE.tmp" "$OUTPUT_FILE"
}

add_decision() {
    local category="$1"
    local issue="$2"
    local target="${3:-}"

    jq --arg cat "$category" --arg issue "$issue" --arg target "$target" \
        '.decisions_needed += [{category: $cat, issue: $issue, target: $target}]' \
        "$OUTPUT_FILE" > "$OUTPUT_FILE.tmp" && mv "$OUTPUT_FILE.tmp" "$OUTPUT_FILE"
}

# Start scanning
init_json
cd "$PLUGIN_PATH"

# ============================================================================
# 1. CHECK MANIFEST EXISTS AND IS VALID
# ============================================================================
if [[ ! -f .claude-plugin/plugin.json ]]; then
    add_error "manifest" "Missing .claude-plugin/plugin.json" "Run 'mkdir -p .claude-plugin' and create plugin.json"
else
    if ! jq . .claude-plugin/plugin.json > /dev/null 2>&1; then
        add_error "manifest" "Invalid JSON in .claude-plugin/plugin.json" "Fix JSON syntax errors"
    fi
fi

# ============================================================================
# 2. SCAN FOR NON-STANDARD FILES IN .claude-plugin/
# ============================================================================
if [[ -d .claude-plugin ]]; then
    PLUGIN_DIR_FILES=$(find .claude-plugin -type f -not -name "plugin.json" 2>/dev/null | grep -v "^\.$" || true)
    if [[ -n "$PLUGIN_DIR_FILES" ]]; then
        while IFS= read -r file; do
            if [[ -n "$file" ]]; then
                add_decision "file-cleanup" "Remove non-standard file?" "$file"
            fi
        done <<< "$PLUGIN_DIR_FILES"
    fi
fi

# ============================================================================
# 3. SCAN FOR NON-STANDARD HIDDEN/SYSTEM FILES AT ROOT
# ============================================================================
UNWANTED_ROOT_FILES=(".env" ".env.local" ".env.example" ".DS_Store" ".vscode" ".idea" "node_modules" "dist" "__pycache__" ".pytest_cache")
for pattern in "${UNWANTED_ROOT_FILES[@]}"; do
    FOUND=$(find . -maxdepth 1 -name "$pattern" 2>/dev/null | head -1 || true)
    if [[ -n "$FOUND" && "$FOUND" != "." ]]; then
        add_warning "file-cleanup" "Found non-standard file/directory: $FOUND (consider removing for distribution)" "Remove with: rm -rf '$FOUND'"
    fi
done

# ============================================================================
# 4. CHECK FOR ORPHANED OR OBSOLETE DIRECTORIES
# ============================================================================
KNOWN_DIRS=(".claude-plugin" "commands" "agents" "skills" "scripts" "references" "assets" "docs" ".git")
for dir in */; do
    dir_name="${dir%/}"
    if [[ "$dir_name" != "."* ]]; then  # Skip hidden dirs
        found=0
        for known in "${KNOWN_DIRS[@]}"; do
            if [[ "$dir_name" == "$known" ]]; then
                found=1
                break
            fi
        done
        if [[ $found -eq 0 ]]; then
            add_decision "structure" "Non-standard directory found" "$dir_name"
        fi
    fi
done

# ============================================================================
# 5. VALIDATE MANIFEST FIELDS
# ============================================================================
if [[ -f .claude-plugin/plugin.json ]]; then
    # Check required fields
    for field in "name" "version" "description"; do
        if ! jq -e ".$field" .claude-plugin/plugin.json > /dev/null 2>&1; then
            add_error "manifest" "Missing required field: $field" "Add '$field' to plugin.json"
        fi
    done

    # Check author field format if present
    if jq -e ".author" .claude-plugin/plugin.json > /dev/null 2>&1; then
        AUTHOR_TYPE=$(jq -r ".author | type" .claude-plugin/plugin.json)
        if [[ "$AUTHOR_TYPE" != "object" ]]; then
            add_warning "manifest" "author should be an object {name: ..., email: ...}, found: $AUTHOR_TYPE" "Reformat author field to object"
        fi
    fi

    # Check repository format if present
    if jq -e ".repository" .claude-plugin/plugin.json > /dev/null 2>&1; then
        REPO_TYPE=$(jq -r ".repository | type" .claude-plugin/plugin.json)
        if [[ "$REPO_TYPE" != "string" ]]; then
            add_warning "manifest" "repository should be a string URL, found: $REPO_TYPE" "Change to string format (e.g., 'https://...')"
        fi
    fi

    # Check version format
    VERSION=$(jq -r ".version" .claude-plugin/plugin.json 2>/dev/null || echo "")
    if ! [[ "$VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        add_warning "manifest" "version '$VERSION' doesn't match semantic versioning (X.Y.Z)" "Use format: 1.0.0"
    fi
fi

# ============================================================================
# 6. CHECK COMPONENT DIRECTORIES FOR STRUCTURE ISSUES
# ============================================================================

# Check skills directory structure
if [[ -d skills ]]; then
    for skill_dir in skills/*/; do
        if [[ -d "$skill_dir" ]]; then
            skill_name=$(basename "$skill_dir")
            if [[ ! -f "$skill_dir/SKILL.md" ]]; then
                add_error "skills" "Missing SKILL.md in skills/$skill_name/" "Create skills/$skill_name/SKILL.md"
            else
                # Check frontmatter
                if ! head -10 "$skill_dir/SKILL.md" | grep -q "^---$"; then
                    add_error "skills" "skills/$skill_name/SKILL.md missing frontmatter" "Add YAML frontmatter with --- delimiters"
                fi
            fi
        fi
    done
fi

# Check commands directory structure
if [[ -d commands ]]; then
    add_warning "deprecation" "commands/ directory is deprecated in favor of Agent Skills (skills/)" "Migrate commands to Agent Skills using skill-creator"
    while IFS= read -r cmd_file; do
        if [[ -n "$cmd_file" ]]; then
            if ! head -10 "$cmd_file" | grep -q "^---$"; then
                add_error "commands" "$(basename "$cmd_file") missing frontmatter" "Add YAML frontmatter with name, description, arguments"
            fi
        fi
    done < <(find commands -maxdepth 1 -name "*.md" -print0 2>/dev/null | xargs -0 -r printf '%s\n')
fi

# ============================================================================
# 7. SCAN SCRIPTS FOR SECURITY ISSUES
# ============================================================================
if [[ -d scripts ]]; then
    while IFS= read -r script; do
        if [[ -n "$script" ]]; then
            # Check for hardcoded absolute paths
            if grep -q "^/" "$script" 2>/dev/null; then
                add_warning "security" "Script $script contains absolute paths (may break after installation)" "Use \${CLAUDE_PLUGIN_ROOT} variable or relative paths"
            fi

            # Check for environment variables/secrets
            if grep -qE "(API_KEY|PASSWORD|SECRET|TOKEN|CREDENTIALS)" "$script" 2>/dev/null; then
                add_warning "security" "Script $script may contain hardcoded secrets" "Move secrets to .env or use authentication"
            fi

            # Check shell scripts for missing shebangs
            if [[ "$script" == *.sh ]]; then
                if ! head -1 "$script" | grep -q "^#!"; then
                    add_warning "scripts" "Shell script $script missing shebang" "Add '#!/bin/bash' as first line"
                fi
            fi

            # Check if scripts are executable
            if [[ ! -x "$script" ]]; then
                add_decision "permissions" "Script not executable" "$script"
            fi
        fi
    done < <(find scripts -type f \( -name "*.sh" -o -name "*.py" -o -name "*.js" \) -print0 2>/dev/null | xargs -0 -r printf '%s\n')
fi

# ============================================================================
# 8. CHECK FOR COMPONENT NAMING CONSISTENCY
# ============================================================================
if [[ -d commands ]]; then
    while IFS= read -r cmd_file; do
        if [[ -n "$cmd_file" ]]; then
            cmd=$(basename "$cmd_file" .md)
            if [[ ! "$cmd" =~ ^[a-z0-9_-]+$ ]]; then
                add_warning "naming" "Command name '$cmd' doesn't follow lowercase-hyphen convention" "Rename to lowercase with hyphens"
            fi
        fi
    done < <(find commands -maxdepth 1 -name "*.md" -print0 2>/dev/null | xargs -0 -r printf '%s\n')
fi

if [[ -d skills ]]; then
    for skill_dir in skills/*/; do
        skill_name=$(basename "$skill_dir")
        if [[ ! "$skill_name" =~ ^[a-z0-9_-]+$ ]]; then
            add_warning "naming" "Skill directory '$skill_name' doesn't follow lowercase-hyphen convention" "Rename to lowercase with hyphens"
        fi
    done
fi

# ============================================================================
# 9. CHECK DOCUMENTATION PRESENCE
# ============================================================================
DOC_FILES=("README.md" "CHANGELOG.md")
for doc in "${DOC_FILES[@]}"; do
    if [[ ! -f "$doc" ]]; then
        add_warning "documentation" "Missing $doc (helpful for distributed plugins)" "Create $doc"
    fi
done

# ============================================================================
# 10. CHECK FOR LICENSE
# ============================================================================
LICENSE_FILES=("LICENSE" "LICENSE.md" "LICENSE.txt")
LICENSE_FOUND=0
for lic in "${LICENSE_FILES[@]}"; do
    if [[ -f "$lic" ]]; then
        LICENSE_FOUND=1
        break
    fi
done
if [[ $LICENSE_FOUND -eq 0 ]] && jq -e ".license" .claude-plugin/plugin.json > /dev/null 2>&1; then
    add_warning "documentation" "plugin.json specifies license but no LICENSE file found" "Create LICENSE file"
fi

# ============================================================================
# 11. PLUGIN SIZE CHECK
# ============================================================================
PLUGIN_SIZE=$(du -sh . 2>/dev/null | cut -f1 || echo "unknown")
TOTAL_BYTES=$(du -sb . 2>/dev/null | cut -f1 || echo "0")
if [[ $TOTAL_BYTES -gt 52428800 ]]; then  # 50MB
    add_warning "performance" "Plugin is large ($PLUGIN_SIZE) - may impact installation speed" "Consider removing unused files or making assets lazy-loaded"
fi

# Output summary
echo "✔ Scan complete. Results saved to: $OUTPUT_FILE"
echo ""
echo "Summary:"
ERRORS=$(jq '.errors | length' "$OUTPUT_FILE")
WARNINGS=$(jq '.warnings | length' "$OUTPUT_FILE")
DECISIONS=$(jq '.decisions_needed | length' "$OUTPUT_FILE")
echo "  Errors: $ERRORS"
echo "  Warnings: $WARNINGS"
echo "  Decisions needed: $DECISIONS"
