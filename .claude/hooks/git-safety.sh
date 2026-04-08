#!/usr/bin/env bash
# gOS Hook: Git Safety (PreToolUse, matcher: Bash)
# Blocks git rebase/pull --rebase when untracked files exist in critical dirs.
# This is the specific combination that caused the 2026-04-08 file deletion incident.
set -euo pipefail

INPUT=$(cat)
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // ""')
[ "$TOOL_NAME" = "Bash" ] || exit 0

CMD=$(echo "$INPUT" | jq -r '.tool_input.command // ""')
[ -n "$CMD" ] || exit 0

# Only trigger on rebase operations — match the FIRST command, not body text.
# Extract just the first line / command portion (before any heredoc or message body).
FIRST_LINE=$(echo "$CMD" | head -1)

IS_REBASE=false
case "$FIRST_LINE" in
  "git pull --rebase"*|"git pull -r"*|"git rebase"*)
    IS_REBASE=true ;;
esac
[ "$IS_REBASE" = "true" ] || exit 0

# Count untracked files in critical directories
UNTRACKED=0
for dir in specs outputs memory; do
  if [ -d "$dir" ]; then
    COUNT=$(git ls-files --others --exclude-standard "$dir" 2>/dev/null | wc -l | tr -d ' ')
    UNTRACKED=$((UNTRACKED + COUNT))
  fi
done

if [ "$UNTRACKED" -gt 0 ]; then
  echo "BLOCKED: git rebase with ${UNTRACKED} untracked files in specs/outputs/memory/. These files are NOT protected by git and will be lost during rebase. Commit or stash them first: git stash --include-untracked"
  exit 2
fi

exit 0
