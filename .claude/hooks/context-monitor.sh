#!/bin/bash
# ═══════════════════════════════════════════════════════════
# Context Window Monitor
# Event: PostToolUse (all tools)
# Estimates cumulative token usage and alerts at thresholds
# ═══════════════════════════════════════════════════════════

set -euo pipefail

# --- Config ---
# Opus 4.6 = 1M context. ~200K for system prompt/instructions overhead.
EFFECTIVE_BUDGET=800000
WARN_PCT=50    # Suggest save
ALERT_PCT=70   # Recommend fresh session
STOP_PCT=85    # Auto-save handoff

WARN_THRESHOLD=$(( EFFECTIVE_BUDGET * WARN_PCT / 100 ))
ALERT_THRESHOLD=$(( EFFECTIVE_BUDGET * ALERT_PCT / 100 ))
STOP_THRESHOLD=$(( EFFECTIVE_BUDGET * STOP_PCT / 100 ))

# --- Session tracking ---
INPUT=$(cat)
SESSION_ID=$(echo "$INPUT" | python3 -c "import sys,json; print(json.load(sys.stdin).get('session_id','default'))" 2>/dev/null || echo "default")
TRACKER="/tmp/claude-context-monitor-${SESSION_ID}"

# Extract tool info for estimation
TOOL_NAME=$(echo "$INPUT" | python3 -c "import sys,json; print(json.load(sys.stdin).get('tool_name','unknown'))" 2>/dev/null || echo "unknown")
# Estimate result size from tool_result (chars / 4 ≈ tokens)
RESULT_TOKENS=$(echo "$INPUT" | python3 -c "
import sys, json
data = json.load(sys.stdin)
result = data.get('tool_result', '')
if isinstance(result, dict):
    result = json.dumps(result)
elif isinstance(result, list):
    result = json.dumps(result)
elif not isinstance(result, str):
    result = str(result)
print(max(len(result) // 4, 50))
" 2>/dev/null || echo "200")

# Per-tool overhead estimates (input tokens + conversation framing)
case "$TOOL_NAME" in
    Read)           OVERHEAD=300 ;;
    Edit|Write)     OVERHEAD=400 ;;
    Bash)           OVERHEAD=250 ;;
    Grep|Glob)      OVERHEAD=200 ;;
    Agent)          OVERHEAD=2000 ;;
    WebFetch|WebSearch) OVERHEAD=500 ;;
    *)              OVERHEAD=200 ;;
esac

# Each exchange also includes ~300 tokens of conversation framing
EXCHANGE_OVERHEAD=300
CALL_TOKENS=$(( RESULT_TOKENS + OVERHEAD + EXCHANGE_OVERHEAD ))

# --- Accumulate ---
PREV_TOKENS=0
PREV_CALLS=0
PREV_WARNED=""
if [ -f "$TRACKER" ]; then
    PREV_TOKENS=$(sed -n '1p' "$TRACKER" 2>/dev/null || echo 0)
    PREV_CALLS=$(sed -n '2p' "$TRACKER" 2>/dev/null || echo 0)
    PREV_WARNED=$(sed -n '3p' "$TRACKER" 2>/dev/null || echo "")
fi

TOTAL_TOKENS=$(( PREV_TOKENS + CALL_TOKENS ))
TOTAL_CALLS=$(( PREV_CALLS + 1 ))
PCT=$(( TOTAL_TOKENS * 100 / EFFECTIVE_BUDGET ))

# --- Determine if we need to warn ---
MSG=""
NEW_WARNED="$PREV_WARNED"

if [ "$TOTAL_TOKENS" -ge "$STOP_THRESHOLD" ] && [ "$PREV_WARNED" != "stop" ]; then
    MSG="⛔ CONTEXT AT ~${PCT}% (~${TOTAL_TOKENS} estimated tokens, ${TOTAL_CALLS} tool calls). STOP complex work. Write handoff to sessions/handoff-auto-$(date +%Y%m%d).md and tell user to start a fresh session with /gos resume."
    NEW_WARNED="stop"
elif [ "$TOTAL_TOKENS" -ge "$ALERT_THRESHOLD" ] && [ "$PREV_WARNED" != "alert" ] && [ "$PREV_WARNED" != "stop" ]; then
    MSG="⚠️ CONTEXT AT ~${PCT}% (~${TOTAL_TOKENS} estimated tokens, ${TOTAL_CALLS} tool calls). Recommend saving (/gos save) and starting a fresh session. Complex operations may degrade from here."
    NEW_WARNED="alert"
elif [ "$TOTAL_TOKENS" -ge "$WARN_THRESHOLD" ] && [ "$PREV_WARNED" = "" ]; then
    MSG="📊 CONTEXT AT ~${PCT}% (~${TOTAL_TOKENS} estimated tokens, ${TOTAL_CALLS} tool calls). Good stopping point? Consider /gos save if wrapping up."
    NEW_WARNED="warn"
fi

# --- Persist ---
printf '%s\n%s\n%s\n' "$TOTAL_TOKENS" "$TOTAL_CALLS" "$NEW_WARNED" > "$TRACKER"

# --- Output ---
if [ -n "$MSG" ]; then
    echo "$MSG"
fi

exit 0
