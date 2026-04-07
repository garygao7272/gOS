#!/bin/bash
# ═══════════════════════════════════════════════════════════
# Artifact Frontmatter Enforcer
# Event: PostToolUse (Write)
# After writing to outputs/, checks if YAML frontmatter
# exists. If missing, appends warning to scratchpad.
# PostToolUse cannot block, only flag.
# ═══════════════════════════════════════════════════════════

set -euo pipefail

INPUT=$(cat)
PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"
SCRATCHPAD="$PROJECT_DIR/sessions/scratchpad.md"

# Parse file path from tool input
FILE_PATH=$(echo "$INPUT" | python3 -c "
import sys, json
data = json.load(sys.stdin)
ti = data.get('tool_input', {})
print(ti.get('file_path', '') or ti.get('filePath', ''))
" 2>/dev/null)

# Only check files in outputs/
case "$FILE_PATH" in
    */outputs/*) ;;
    *) exit 0 ;;
esac

# Skip non-markdown files and index files
case "$FILE_PATH" in
    *ARTIFACT_INDEX*|*.json|*.html|*.css|*.js|*.ts) exit 0 ;;
esac

# Check if file starts with YAML frontmatter
if [ -f "$FILE_PATH" ]; then
    FIRST_LINE=$(head -1 "$FILE_PATH" 2>/dev/null)
    if [ "$FIRST_LINE" != "---" ]; then
        # No frontmatter — append warning to scratchpad
        if [ -f "$SCRATCHPAD" ]; then
            TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
            echo "" >> "$SCRATCHPAD"
            echo "⚠️ [$TIMESTAMP] Missing YAML frontmatter on: $FILE_PATH" >> "$SCRATCHPAD"
            echo "   Add artifact header per gOS/.claude/artifact-schema.md" >> "$SCRATCHPAD"
        fi
        echo "⚠️ ARTIFACT: Missing YAML frontmatter on $(basename "$FILE_PATH"). Add artifact header per artifact-schema.md."
    fi
fi

exit 0
