#!/bin/bash
# Headless /evolve audit runner, invoked by launchd.
# Usage: evolve-claw.sh [sources|specs]     (no arg = base audit)
#
# Launchd jobs:
#   com.gos.evolve-audit   — every 4h at :13 (base audit)
#   com.gos.evolve-sources — daily 8:47      (sources audit)
#   com.gos.evolve-specs   — Mondays 9:13    (spec-drift audit)
#
# Writes stdout/stderr to ~/.claude/logs/evolve-<type>-<date>.log

set -euo pipefail

AUDIT_TYPE="${1:-}"
# Derive GOS_DIR from this script's own location so launchd + any fresh clone work.
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
GOS_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
# Resolve claude binary via PATH; fall back to the known local install.
CLAUDE_BIN="$(command -v claude || echo "$HOME/.local/bin/claude")"
LOG_DIR="$HOME/.claude/logs"

mkdir -p "$LOG_DIR"

STAMP=$(date +%Y-%m-%d_%H%M)
LOG_NAME="${AUDIT_TYPE:-base}"
LOG_FILE="$LOG_DIR/evolve-${LOG_NAME}-${STAMP}.log"

PROMPT="/evolve audit"
[ -n "$AUDIT_TYPE" ] && PROMPT="/evolve audit $AUDIT_TYPE"

cd "$GOS_DIR" || { echo "FATAL: cannot cd to gOS dir" >&2; exit 1; }

{
  echo "=== evolve-claw start: $(date) ==="
  echo "Prompt: $PROMPT"
  echo "CWD:    $PWD"
  echo ""
  "$CLAUDE_BIN" -p "$PROMPT" 2>&1
  echo ""
  echo "=== evolve-claw end: $(date) (exit=$?) ==="
} >> "$LOG_FILE" 2>&1
