#!/usr/bin/env bash
# save-signals.sh — PreCompact persistence
#
# Reads the CC PreCompact JSON payload on stdin, ensures the signal log and
# scratchpad are written before compaction wipes context. Exits 2 if it
# cannot persist (which blocks compaction so Gary can intervene).
#
# stdin contract (CC docs):
#   { session_id, transcript_path, cwd, hook_event_name, compaction_trigger }
#
# Side effects (idempotent per session_id):
#   - Appends checkpoint line to $PROJECT/sessions/evolve_signals.md
#   - Updates Context line in $PROJECT/sessions/scratchpad.md to POST-COMPACTION
#
# Env overrides (used by tests):
#   GOS_PROJECT_DIR  — project root (defaults to cwd from payload, then $PWD)
#   GOS_NOW          — ISO-8601 timestamp (defaults to date -u)

set -euo pipefail

PAYLOAD=$(cat || true)

if [ -z "$PAYLOAD" ]; then
  echo "save-signals: empty stdin" >&2
  exit 2
fi

# Validate JSON; bail clean if malformed (block compaction so user notices)
if ! printf '%s' "$PAYLOAD" | jq -e . >/dev/null 2>&1; then
  echo "save-signals: malformed JSON payload" >&2
  exit 2
fi

SESSION_ID=$(printf '%s' "$PAYLOAD" | jq -r '.session_id // "unknown"')
TRIGGER=$(printf '%s' "$PAYLOAD" | jq -r '.compaction_trigger // "unknown"')
PAYLOAD_CWD=$(printf '%s' "$PAYLOAD" | jq -r '.cwd // ""')

PROJECT_DIR="${GOS_PROJECT_DIR:-${PAYLOAD_CWD:-$PWD}}"
NOW="${GOS_NOW:-$(date -u +%Y-%m-%dT%H:%M:%SZ)}"

LOG="$PROJECT_DIR/sessions/evolve_signals.md"
SCRATCH="$PROJECT_DIR/sessions/scratchpad.md"

mkdir -p "$PROJECT_DIR/sessions" 2>/dev/null || true

# Writability check up front — fail fast, block compaction
for f in "$LOG" "$SCRATCH"; do
  if [ -e "$f" ] && [ ! -w "$f" ]; then
    echo "save-signals: cannot write $f" >&2
    exit 2
  fi
done
if [ ! -w "$PROJECT_DIR/sessions" ]; then
  echo "save-signals: cannot write sessions/ dir" >&2
  exit 2
fi

# --- Append checkpoint to evolve_signals.md (idempotent) ---
CHECKPOINT_TAG="<!-- precompact:$SESSION_ID -->"
if [ -f "$LOG" ] && grep -qF "$CHECKPOINT_TAG" "$LOG" 2>/dev/null; then
  : # already logged for this session; skip
else
  {
    [ -f "$LOG" ] || printf '# Evolve Signals\n\n'
    printf '\n## Compaction Checkpoint — %s\n' "$NOW"
    printf '%s\n' "$CHECKPOINT_TAG"
    printf -- '- session_id: %s\n' "$SESSION_ID"
    printf -- '- trigger: %s\n' "$TRIGGER"
    printf -- '- note: PreCompact hard-block fired; review unlogged signals before next batch.\n'
  } >> "$LOG"
fi

# --- Update scratchpad Context line ---
if [ -f "$SCRATCH" ]; then
  CONTEXT_LINE="Context: POST-COMPACTION (~15%) — checkpoint $NOW (session $SESSION_ID)"
  if grep -qE '^Context:' "$SCRATCH" 2>/dev/null; then
    # Replace existing Context: line
    TMP=$(mktemp)
    awk -v line="$CONTEXT_LINE" '
      BEGIN { replaced = 0 }
      /^Context:/ && !replaced { print line; replaced = 1; next }
      { print }
      END { if (!replaced) print line }
    ' "$SCRATCH" > "$TMP"
    mv "$TMP" "$SCRATCH"
  else
    printf '\n%s\n' "$CONTEXT_LINE" >> "$SCRATCH"
  fi
fi

exit 0
