#!/bin/bash
# gOS status line — surfaces invisible session state:
#   - current working dir (short)
#   - git branch + uncommitted file count
#   - gOS trust score (top domain)
#   - scratchpad age (minutes since last checkpoint)
#   - active job-id (if any)
#
# Claude Code pipes session context as JSON on stdin: {cwd, model, workspace}.
# Must be fast (<100ms) — called per-frame.

set -euo pipefail

# ── Read session context ────────────────────────────────────────────────
INPUT="$(cat)"
CWD="$(printf '%s' "$INPUT" | jq -r '.cwd // empty' 2>/dev/null || echo "")"
[ -z "$CWD" ] && CWD="$(pwd)"

# ── ANSI colors (dim, so the status line recedes) ───────────────────────
DIM='\033[2m'; CYAN='\033[36m'; VIOLET='\033[35m'; YELLOW='\033[33m'
GREEN='\033[32m'; RED='\033[31m'; RESET='\033[0m'

# ── Short CWD (last two path components) ────────────────────────────────
SHORT_CWD="$(basename "$(dirname "$CWD")")/$(basename "$CWD")"

# ── Git branch + dirty count ────────────────────────────────────────────
GIT_PART=""
if git -C "$CWD" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  BRANCH="$(git -C "$CWD" rev-parse --abbrev-ref HEAD 2>/dev/null || echo '?')"
  DIRTY="$(git -C "$CWD" status --porcelain 2>/dev/null | wc -l | tr -d ' ')"
  if [ "$DIRTY" != "0" ]; then
    GIT_PART=" ${CYAN}${BRANCH}${RESET}${YELLOW}*${DIRTY}${RESET}"
  else
    GIT_PART=" ${CYAN}${BRANCH}${RESET}"
  fi
fi

# ── gOS trust score (top domain) ────────────────────────────────────────
TRUST_PART=""
TRUST_FILE="$CWD/sessions/trust.json"
if [ -f "$TRUST_FILE" ]; then
  TOP_DOMAIN="$(jq -r '
    .domains
    | to_entries
    | map({domain: .key, score: (.value.score // 0.5)})
    | sort_by(.score)
    | reverse
    | .[0] // empty
    | "\(.domain)=\(.score)"' "$TRUST_FILE" 2>/dev/null || echo "")"
  [ -n "$TOP_DOMAIN" ] && TRUST_PART=" ${VIOLET}trust:${TOP_DOMAIN}${RESET}"
fi

# ── Scratchpad age (minutes since last touch) ───────────────────────────
SP_PART=""
SP_FILE="$CWD/sessions/scratchpad.md"
if [ -f "$SP_FILE" ]; then
  NOW=$(date +%s)
  MTIME=$(stat -f %m "$SP_FILE" 2>/dev/null || stat -c %Y "$SP_FILE" 2>/dev/null || echo "$NOW")
  AGE_MIN=$(( (NOW - MTIME) / 60 ))
  if [ "$AGE_MIN" -gt 30 ]; then
    SP_PART=" ${RED}sp:${AGE_MIN}m${RESET}"
  elif [ "$AGE_MIN" -gt 10 ]; then
    SP_PART=" ${YELLOW}sp:${AGE_MIN}m${RESET}"
  else
    SP_PART=" ${DIM}sp:${AGE_MIN}m${RESET}"
  fi
fi

# ── Active job-id (from state.json, if present) ─────────────────────────
JOB_PART=""
STATE_FILE="$CWD/sessions/state.json"
if [ -f "$STATE_FILE" ]; then
  JOB_ID="$(jq -r '.active_job.id // empty' "$STATE_FILE" 2>/dev/null || echo "")"
  PHASE="$(jq -r '.active_job.phase // empty' "$STATE_FILE" 2>/dev/null || echo "")"
  if [ -n "$JOB_ID" ]; then
    SHORT_JOB="${JOB_ID:0:8}"
    JOB_PART=" ${GREEN}job:${SHORT_JOB}${RESET}"
    [ -n "$PHASE" ] && JOB_PART="${JOB_PART}${DIM}/${PHASE}${RESET}"
  fi
fi

# ── Emit (use %b so ANSI escapes inside vars are interpreted) ───────────
printf '%b%s%b%b%b%b%b\n' "$DIM" "$SHORT_CWD" "$RESET" "$GIT_PART" "$TRUST_PART" "$SP_PART" "$JOB_PART"
