#!/usr/bin/env bash
# gOS Hook: Spec Compliance (PreToolUse, matcher: Edit|Write)
# Checks if the upstream spec/rubric was Read this session before allowing edits
# to governed files (commands/, hooks/).
set -euo pipefail

INPUT=$(cat)
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // ""')

# Only check Edit and Write
case "$TOOL_NAME" in
  Edit|Write) ;;
  *) exit 0 ;;
esac

FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // ""')
[ -n "$FILE_PATH" ] || exit 0

# Determine if this file has a governing spec
SPEC=""
case "$FILE_PATH" in
  */commands/*.md)
    # Commands are governed by their eval rubric
    CMD_NAME=$(basename "$FILE_PATH" .md)
    RUBRIC_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}/evals/rubrics"
    if [ -f "$RUBRIC_DIR/${CMD_NAME}.md" ]; then
      SPEC="evals/rubrics/${CMD_NAME}.md"
    fi
    ;;
  */hooks/*.sh)
    # Hooks with corresponding BATS tests
    HOOK_NAME=$(basename "$FILE_PATH" .sh)
    TEST_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}/tests/hooks"
    if [ -f "$TEST_DIR/${HOOK_NAME}.bats" ]; then
      SPEC="tests/hooks/${HOOK_NAME}.bats"
    fi
    ;;
esac

# If no spec governs this file, allow the edit
[ -n "$SPEC" ] || exit 0

# Check if the spec was already read this session (tracked by accumulate.sh)
ACCUMULATE_LOG="/tmp/gos-accumulate-$(date +%Y%m%d).log"
if [ -f "$ACCUMULATE_LOG" ] && grep -q "$SPEC" "$ACCUMULATE_LOG" 2>/dev/null; then
  exit 0
fi

# Also check if the spec basename appears anywhere in the accumulate log
SPEC_BASE=$(basename "$SPEC")
if [ -f "$ACCUMULATE_LOG" ] && grep -q "$SPEC_BASE" "$ACCUMULATE_LOG" 2>/dev/null; then
  exit 0
fi

# Spec not read — warn but don't block (advisory for now)
echo "ADVISORY: $FILE_PATH is governed by $SPEC. Consider reading it first for spec compliance. (This is advisory — edit will proceed.)"
exit 0
