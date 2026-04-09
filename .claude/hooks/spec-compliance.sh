#!/usr/bin/env bash
# gOS Hook: Spec Compliance (PreToolUse, matcher: Edit|Write)
# BLOCKS edits to governed files unless the governing spec was read first.
# Governed files: commands/*.md (if rubric exists), hooks/*.sh (if .bats exists)
# Read tracking: read-tracker.sh logs spec reads to /tmp/gos-spec-reads-{date}
set -euo pipefail

INPUT=$(cat)
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // ""')

case "$TOOL_NAME" in
  Edit|Write) ;;
  *) exit 0 ;;
esac

FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // ""')
[ -n "$FILE_PATH" ] || exit 0

# Determine governing spec
SPEC=""
SPEC_BASE=""
case "$FILE_PATH" in
  */commands/*.md)
    CMD_NAME=$(basename "$FILE_PATH" .md)
    RUBRIC_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}/evals/rubrics"
    if [ -f "$RUBRIC_DIR/${CMD_NAME}.md" ]; then
      SPEC="evals/rubrics/${CMD_NAME}.md"
      SPEC_BASE="${CMD_NAME}.md"
    fi
    ;;
  */hooks/*.sh)
    HOOK_NAME=$(basename "$FILE_PATH" .sh)
    TEST_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}/tests/hooks"
    if [ -f "$TEST_DIR/${HOOK_NAME}.bats" ]; then
      SPEC="tests/hooks/${HOOK_NAME}.bats"
      SPEC_BASE="${HOOK_NAME}.bats"
    fi
    ;;
esac

# No governing spec → allow
[ -n "$SPEC" ] || exit 0

# Check if spec was read today (tracked by read-tracker.sh)
READS_LOG="/tmp/gos-spec-reads-$(date +%Y%m%d)"
if [ -f "$READS_LOG" ] && grep -q "$SPEC_BASE" "$READS_LOG" 2>/dev/null; then
  exit 0
fi

# BLOCK: spec not read
echo "BLOCKED: Read $SPEC first before editing $(basename "$FILE_PATH")"
exit 2
