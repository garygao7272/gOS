#!/bin/bash
# ═══════════════════════════════════════════════════════════
# Scratchpad Auto-Checkpoint
# Event: PostToolUse (Edit|Write)
# Appends edited file path to scratchpad "Files Actively Editing"
# ═══════════════════════════════════════════════════════════

set -euo pipefail

# Inline single-field parse — fires on every PostToolUse Edit/Write.
# Sourcing hook-utils.sh adds ~6ms per fire for the other 4 fields we don't use.
HOOK_FILE_PATH=$(jq -r '.tool_input.file_path // .tool_input.filePath // ""' 2>/dev/null || echo "")
[ -n "$HOOK_FILE_PATH" ] || exit 0

HOOK_PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"
SCRATCHPAD="$HOOK_PROJECT_DIR/sessions/scratchpad.md"
REL_PATH="${HOOK_FILE_PATH#"$HOOK_PROJECT_DIR"/}"

# Create scratchpad with template if missing
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

# Append if not already listed
if ! grep -qF "$REL_PATH" "$SCRATCHPAD" 2>/dev/null; then
    TIMESTAMP=$(date +%H:%M)
    if grep -q "## Files Actively Editing" "$SCRATCHPAD"; then
        sed -i '' "/## Files Actively Editing/a\\
- \`$REL_PATH\` ($TIMESTAMP)" "$SCRATCHPAD"
    fi
fi

exit 0
