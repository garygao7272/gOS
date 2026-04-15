#!/bin/bash
# ═══════════════════════════════════════════════════════════
# Hook: Session Stop Gate (persist trigger)
# Event: Stop
#
# Decides whether to run the persist/signal pass by checking
# actual filesystem state. Exits SILENTLY when no trigger fires
# so the Stop event does not re-prompt Claude (which caused an
# infinite loop when this lived as a prompt-type hook).
#
# Triggers (any one fires):
#   - sessions/scratchpad.md Mode line contains '/gos save'
#   - sessions/.scratchpad_timestamp older than 4h (stale-resume)
#
# On trigger: emit a short persist directive to stdout so Claude
# picks up one pass. Claude's persist path must update the
# timestamp (and clear Mode if it was '/gos save'), otherwise
# the trigger stays hot and this hook will re-fire next turn.
# ═══════════════════════════════════════════════════════════

set -u

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"
SESSIONS_DIR="$PROJECT_DIR/sessions"
TS_FILE="$SESSIONS_DIR/.scratchpad_timestamp"
SCRATCHPAD="$SESSIONS_DIR/scratchpad.md"

# If the sessions dir doesn't exist, there's nothing to persist. Silent exit.
if [ ! -d "$SESSIONS_DIR" ]; then
    exit 0
fi

NOW=$(date +%s)
LAST=$(cat "$TS_FILE" 2>/dev/null || echo "$NOW")
# Guard: if LAST is non-numeric, treat as NOW
case "$LAST" in
    ''|*[!0-9]*) LAST="$NOW" ;;
esac
AGE=$((NOW - LAST))

MODE=""
if [ -f "$SCRATCHPAD" ]; then
    MODE=$(grep -A1 '^## Mode' "$SCRATCHPAD" 2>/dev/null | tail -1)
fi

TRIGGER=""
case "$MODE" in
    *"/gos save"*) TRIGGER="gos-save" ;;
esac
if [ -z "$TRIGGER" ] && [ "$AGE" -gt 14400 ]; then
    TRIGGER="stale-resume-${AGE}s"
fi

# No trigger: silent exit. This is the hot path every turn.
if [ -z "$TRIGGER" ]; then
    exit 0
fi

# Triggered: emit minimal persist directive to stdout.
# Claude must: (a) do the persist, (b) update $TS_FILE to NOW,
# (c) clear Mode line if TRIGGER=gos-save — otherwise this re-fires.
cat <<EOF
[persist-trigger=$TRIGGER] Run the persist + signal pass now:
1) Scan this conversation for unlogged signals (Gary's response to prior suggested action → accept/rework/reject/love/repeat/skip) → append to sessions/evolve_signals.md
2) Update memory/L1_essential.md if decisions/feedback/state changed
3) Update sessions/state.json with phase + recovery
4) Touch sessions/.scratchpad_timestamp to now (required to clear this trigger)
5) If trigger was gos-save: clear or update the ## Mode line in sessions/scratchpad.md (required to clear this trigger)
Report one line: '[N] signals logged, L1 [updated|unchanged], state.json [updated|unchanged]'.
EOF
exit 0
