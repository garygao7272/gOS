#!/usr/bin/env bash
# gOS Hook: Loop Detect (PreToolUse, matcher: .*)
# Reads error-tracker's log. If 3+ consecutive errors on the same tool,
# emits a warning to stdout so Claude sees it and can break the loop.
set -euo pipefail

INPUT=$(cat)

SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // "default"')
ERROR_LOG="/tmp/gos-loop-detect-${SESSION_ID}.log"

[ -f "$ERROR_LOG" ] || exit 0

# Read last 3 entries
LAST3=$(tail -3 "$ERROR_LOG" 2>/dev/null)
COUNT=$(echo "$LAST3" | wc -l | tr -d ' ')
[ "$COUNT" -ge 3 ] || exit 0

# Extract tool names from last 3 entries (format: timestamp|toolname:error)
TOOLS=$(echo "$LAST3" | cut -d'|' -f2 | cut -d':' -f1 | sort -u)
UNIQUE_COUNT=$(echo "$TOOLS" | wc -l | tr -d ' ')

if [ "$UNIQUE_COUNT" -eq 1 ]; then
  TOOL_NAME=$(echo "$TOOLS" | head -1)
  ERRORS=$(echo "$LAST3" | cut -d':' -f2- | tail -1 | head -c 100)
  echo "LOOP DETECTED: ${TOOL_NAME} has failed 3 consecutive times. Last error: ${ERRORS}. STOP and try a different approach."
fi

exit 0
