#!/usr/bin/env bash
# gOS Hook: Error Tracker (PostToolUseFailure, matcher: .*)
# Records tool failures for loop detection.
set -euo pipefail

INPUT=$(cat)

SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // "default"')
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // "unknown"')
ERROR=$(echo "$INPUT" | jq -r '.tool_response.error // .tool_response.stderr // "unknown error"' | head -c 200)

ERROR_LOG="/tmp/gos-loop-detect-${SESSION_ID}.log"
echo "$(date +%s)|${TOOL_NAME}:${ERROR}" >> "$ERROR_LOG"

# Keep only last 10 entries
tail -10 "$ERROR_LOG" > "${ERROR_LOG}.tmp" && mv "${ERROR_LOG}.tmp" "$ERROR_LOG"

exit 0
