#!/bin/bash
# ═══════════════════════════════════════════════════════════
# Hook 3: Context Recovery
# Event: PostToolUse | Fires every ~20 tool uses
# Re-anchors Claude to scratchpad + active plan after compaction
# ═══════════════════════════════════════════════════════════

set -euo pipefail

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"

# Use session_id from stdin if available, else fallback to stable path
INPUT=$(cat)
SESSION_ID=$(echo "$INPUT" | python3 -c "import sys,json; print(json.load(sys.stdin).get('session_id','default'))" 2>/dev/null || echo "default")
COUNTER_FILE="/tmp/claude-hook-tool-counter-${SESSION_ID}"

# Read and increment counter
COUNT=0
if [ -f "$COUNTER_FILE" ]; then
    COUNT=$(cat "$COUNTER_FILE" 2>/dev/null || echo 0)
fi
COUNT=$((COUNT + 1))
echo "$COUNT" > "$COUNTER_FILE"

# Only fire every 20 tool uses
if [ $((COUNT % 20)) -ne 0 ]; then
    exit 0
fi

# Build context recovery message
MSG=""

SCRATCHPAD="$PROJECT_DIR/sessions/scratchpad.md"
if [ -f "$SCRATCHPAD" ]; then
    MSG="CONTEXT RECOVERY (tool use #${COUNT}): Re-read sessions/scratchpad.md to restore working state."
fi

# Check for active plan
PLAN_DIR="$HOME/.claude/plans"
if [ -d "$PLAN_DIR" ]; then
    ACTIVE_PLAN=$(ls -t "$PLAN_DIR"/*.md 2>/dev/null | head -1)
    if [ -n "$ACTIVE_PLAN" ]; then
        MSG="$MSG Also re-read the active plan at $ACTIVE_PLAN."
    fi
fi

if [ -n "$MSG" ]; then
    echo "$MSG"
fi

exit 0
