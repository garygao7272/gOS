#!/usr/bin/env bash
# gOS Hook: Health Gate (PreToolUse, matcher: Bash)
# Auto-runs health checks before git commit in gOS project.
# Only triggers on git commit commands in gOS project directory.

INPUT=$(cat)
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // ""' 2>/dev/null) || exit 0
[ "$TOOL_NAME" = "Bash" ] || exit 0

CMD=$(echo "$INPUT" | jq -r '.tool_input.command // ""' 2>/dev/null) || exit 0

# Only trigger on git commit (not git add, git push, etc.)
echo "$CMD" | grep -qE '^\s*git\s+commit' || exit 0

# Only trigger in gOS project
PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"
case "$PROJECT_DIR" in
  *gOS*|*gos*) ;;
  *) exit 0 ;;
esac

# Run health gate
GATE="$PROJECT_DIR/tools/health-gate.sh"
[ -x "$GATE" ] || exit 0

echo "Running gOS health gate..." >&2
bash "$GATE" >&2
EXIT=$?

if [ "$EXIT" -eq 2 ]; then
  echo "HEALTH GATE BLOCKED: Fix errors before committing" >&2
  exit 2
fi

exit 0
