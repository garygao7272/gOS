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

# ─── Cleanup-zone allowlist ──────────────────────────────────────────────
# Allow `rm -rf` of DIRECT subdirectories of designated cleanup zones —
# these are directories whose purpose IS to be cleaned (regenerable caches,
# archived sessions, backups). Zones themselves and deeper paths stay blocked.
#
# Pattern matched: `rm -rf ~/.claude/<zone>/<name>` OR
#                  `cd ~/.claude/<zone> && rm -rf <name>`
# Zones: plugins/cache, projects-archive, backups, cache
# Name: [a-zA-Z0-9_.-]+  (single path segment, no nested slashes)
_ZONES='(plugins/cache|projects-archive|backups|cache)'
_NAME='[a-zA-Z0-9_.-]+'
_BASE='(~|/Users/[a-zA-Z0-9_.-]+)/\.claude'
if echo "$CMD" | grep -qE "^[[:space:]]*rm[[:space:]]+-[rf]+[[:space:]]+${_BASE}/${_ZONES}/${_NAME}/?[[:space:]]*$" \
   || echo "$CMD" | grep -qE "^[[:space:]]*cd[[:space:]]+${_BASE}/${_ZONES}[[:space:]]*&&[[:space:]]*rm[[:space:]]+-[rf]+[[:space:]]+${_NAME}/?[[:space:]]*$"; then
  # Allowlisted cleanup — single-target rm inside a designated cleanup zone
  exit 0
fi

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
