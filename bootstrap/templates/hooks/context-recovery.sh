#!/bin/bash
# ═══════════════════════════════════════════════════════════
# Context Recovery
# Event: PostToolUse (all) | Fires every ~20 tool uses
# Re-anchors Claude to scratchpad + active plan after compaction
# ═══════════════════════════════════════════════════════════

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/hook-utils.sh"
_parse_hook_input

COUNTER_FILE="/tmp/claude-hook-tool-counter-${HOOK_SESSION_ID}"

COUNT=0
[ -f "$COUNTER_FILE" ] && COUNT=$(cat "$COUNTER_FILE" 2>/dev/null || echo 0)
COUNT=$((COUNT + 1))
echo "$COUNT" > "$COUNTER_FILE"

# Only fire every 20 tool uses
[ $((COUNT % 20)) -ne 0 ] && exit 0

MSG=""
SCRATCHPAD="$HOOK_PROJECT_DIR/sessions/scratchpad.md"
[ -f "$SCRATCHPAD" ] && MSG="CONTEXT RECOVERY (tool use #${COUNT}): Re-read sessions/scratchpad.md to restore working state."

PLAN_DIR="$HOME/.claude/plans"
if [ -d "$PLAN_DIR" ]; then
    ACTIVE_PLAN=$(ls -t "$PLAN_DIR"/*.md 2>/dev/null | head -1)
    [ -n "${ACTIVE_PLAN:-}" ] && MSG="$MSG Also re-read the active plan at $ACTIVE_PLAN."
fi

[ -n "$MSG" ] && echo "$MSG"
exit 0
