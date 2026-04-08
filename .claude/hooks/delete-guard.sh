#!/usr/bin/env bash
# gOS Hook: Delete Guard (PreToolUse, matcher: Bash)
# Blocks file deletion commands unless user confirms.
# Catches: rm, git clean, git reset --hard, git checkout -- .
set -euo pipefail

INPUT=$(cat)
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // ""')
[ "$TOOL_NAME" = "Bash" ] || exit 0

CMD=$(echo "$INPUT" | jq -r '.tool_input.command // ""')
[ -n "$CMD" ] || exit 0

# Patterns that delete files — require confirmation
BLOCKED=false
REASON=""

case "$CMD" in
  *"rm -rf"*|*"rm -r "*|*"rm -fr"*)
    BLOCKED=true; REASON="rm -rf / rm -r (recursive delete)" ;;
  *"git clean"*)
    BLOCKED=true; REASON="git clean (removes untracked files)" ;;
  *"git reset --hard"*)
    BLOCKED=true; REASON="git reset --hard (discards all uncommitted changes)" ;;
  *"git checkout -- ."*|*"git checkout -- '*'"*|*"git restore ."*)
    BLOCKED=true; REASON="git checkout/restore (discards working tree changes)" ;;
  *"git push --force"*|*"git push -f"*)
    BLOCKED=true; REASON="git push --force (overwrites remote history)" ;;
esac

# Also catch any rm that targets specs/, outputs/, memory/, or .claude/
if [ "$BLOCKED" = "false" ]; then
  if echo "$CMD" | grep -qE "rm\s+.*\b(specs/|outputs/|memory/|\.claude/)"; then
    BLOCKED=true; REASON="rm targeting protected directory (specs/outputs/memory/.claude/)"
  fi
fi

if [ "$BLOCKED" = "true" ]; then
  echo "BLOCKED: ${REASON}. This operation deletes files and requires Gary's explicit confirmation. Command: ${CMD}"
  exit 2
fi

exit 0
