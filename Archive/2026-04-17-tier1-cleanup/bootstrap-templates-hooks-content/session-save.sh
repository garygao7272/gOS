#!/bin/bash
# ═══════════════════════════════════════════════════════════
# Hook: Session Auto-Save
# Event: Stop
# Saves session summary to sessions/ for next-session resumption
# ═══════════════════════════════════════════════════════════

set -euo pipefail

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"
SESSIONS_DIR="$PROJECT_DIR/sessions"
SCRATCHPAD="$SESSIONS_DIR/scratchpad.md"
LAST_SESSION="$SESSIONS_DIR/last-session.md"

# Only save if scratchpad has meaningful content
if [ ! -f "$SCRATCHPAD" ]; then
    exit 0
fi

# Check if scratchpad has content beyond the template
CONTENT_LINES=$(grep -v '^#\|^>\|^-\|^$\|^<!--' "$SCRATCHPAD" 2>/dev/null | wc -l | tr -d ' ')
if [ "$CONTENT_LINES" -lt 3 ]; then
    exit 0
fi

# Extract key sections from scratchpad
TASK=$(sed -n '/^## Current Task$/,/^## /{ /^## Current Task$/d; /^## /d; p; }' "$SCRATCHPAD" 2>/dev/null | head -3 | sed '/^$/d')
MODE=$(sed -n '/^## Mode & Sub-command$/,/^## /{ /^## Mode & Sub-command$/d; /^## /d; p; }' "$SCRATCHPAD" 2>/dev/null | head -3 | sed '/^$/d')
DECISIONS=$(sed -n '/^## Key Decisions$/,/^## /{ /^## Key Decisions$/d; /^## /d; p; }' "$SCRATCHPAD" 2>/dev/null | head -10 | sed '/^$/d')
FILES=$(sed -n '/^## Files Actively Editing$/,/^## /{ /^## Files Actively Editing$/d; /^## /d; p; }' "$SCRATCHPAD" 2>/dev/null | head -15 | sed '/^$/d')
NEXT=$(sed -n '/^## Next Steps$/,/^## /{ /^## Next Steps$/d; /^## /d; p; }' "$SCRATCHPAD" 2>/dev/null | head -5 | sed '/^$/d')

# Write last-session file
cat > "$LAST_SESSION" << EOF
# Last Session Summary
> Auto-saved at $(date '+%Y-%m-%d %H:%M')

## Task
${TASK:-"(not recorded)"}

## Mode
${MODE:-"(not recorded)"}

## Key Decisions
${DECISIONS:-"(none recorded)"}

## Files Touched
${FILES:-"(none recorded)"}
${NEXT:+"(none)"}

## Next Steps
${NEXT:-"(none recorded)"}
EOF

# --- Evolve Signal Persistence ---
# Append any EVOLVE_SIGNAL lines from scratchpad to evolve_signals.md
SIGNALS_FILE="$SESSIONS_DIR/evolve_signals.md"
if [ -f "$SIGNALS_FILE" ]; then
    DATE=$(date '+%Y-%m-%d')
    TIME=$(date '+%H:%M')
    CMD="${MODE:-unknown}"

    # Check scratchpad for any signal markers (written by Claude during session)
    SIGNALS=$(grep -oP 'EVOLVE_SIGNAL:\s*\K.*' "$SCRATCHPAD" 2>/dev/null || echo "")
    if [ -n "$SIGNALS" ]; then
        while IFS= read -r sig; do
            SIG_TYPE=$(echo "$sig" | cut -d'|' -f1 | xargs)
            SIG_CONTEXT=$(echo "$sig" | cut -d'|' -f2- | xargs)
            echo "| $DATE | $TIME | $CMD | $SIG_TYPE | $SIG_CONTEXT |" >> "$SIGNALS_FILE"
        done <<< "$SIGNALS"
    fi
fi

# Write scratchpad timestamp for staleness detection
echo "$(date +%s)" > "$SESSIONS_DIR/.scratchpad_timestamp"

exit 0
