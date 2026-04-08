#!/bin/bash
# ═══════════════════════════════════════════════════════════
# Hook 4: Scratchpad Auto-Checkpoint
# Event: PostToolUse (Edit|Write)
# Appends edited file path to scratchpad "Files Actively Editing"
# ═══════════════════════════════════════════════════════════

set -euo pipefail

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"
SCRATCHPAD="$PROJECT_DIR/sessions/scratchpad.md"

# Read tool input from stdin
INPUT=$(cat)

# Extract file path from tool input
FILE_PATH=$(echo "$INPUT" | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    ti = data.get('tool_input', {})
    print(ti.get('file_path', '') or ti.get('filePath', ''))
except:
    print('')
" 2>/dev/null)

if [ -z "$FILE_PATH" ]; then
    exit 0
fi

# Make path relative to project
REL_PATH="${FILE_PATH#"$PROJECT_DIR"/}"

# Ensure scratchpad exists with the section
if [ ! -f "$SCRATCHPAD" ]; then
    mkdir -p "$(dirname "$SCRATCHPAD")"
    cat > "$SCRATCHPAD" << 'TEMPLATE'
# Session Scratchpad

## Current Task


## Mode & Sub-command


## Key Decisions Made This Session


## Dead Ends (don't retry)


## Working State


## Files Actively Editing


## Important Values


## Agents Launched


## Next Steps

TEMPLATE
fi

# Append file path if not already listed
if ! grep -qF "$REL_PATH" "$SCRATCHPAD" 2>/dev/null; then
    TIMESTAMP=$(date +%H:%M)
    # Append under "Files Actively Editing"
    if grep -q "## Files Actively Editing" "$SCRATCHPAD"; then
        sed -i '' "/## Files Actively Editing/a\\
- \`$REL_PATH\` ($TIMESTAMP)" "$SCRATCHPAD"
    fi
fi

exit 0
