#!/usr/bin/env bash
# precompact-save.sh — PreCompact event wrapper
#
# Thin wrapper that delegates to tools/save-signals.sh. Lives in .claude/hooks
# so it ships with the gOS plugin. On failure, exits 2 to BLOCK compaction
# (per CC PreCompact contract) so signals aren't lost silently.

set -euo pipefail

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"
WORKER="$PROJECT_DIR/tools/save-signals.sh"

if [ ! -x "$WORKER" ]; then
  # Worker missing or not executable — non-blocking warning (don't trap user)
  echo "precompact-save: worker not found at $WORKER (non-blocking)" >&2
  exit 0
fi

# Forward stdin payload to worker; preserve its exit code
exec "$WORKER"
