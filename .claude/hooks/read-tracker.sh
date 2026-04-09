#!/usr/bin/env bash
# gOS Hook: Read Tracker (PreToolUse, matcher: Read)
# Logs when governed specs (rubrics, test files) are read.
# This feeds spec-compliance.sh which blocks edits to governed files
# unless the governing spec has been read first.
set -euo pipefail

INPUT=$(cat)
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // ""')
[ "$TOOL_NAME" = "Read" ] || exit 0

FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // ""')
[ -n "$FILE_PATH" ] || exit 0

BASENAME=$(basename "$FILE_PATH")
READS_LOG="/tmp/gos-spec-reads-$(date +%Y%m%d)"

# Track reads of rubrics and test files
case "$FILE_PATH" in
  */evals/rubrics/*.md|*/tests/hooks/*.bats)
    echo "$BASENAME" >> "$READS_LOG"
    ;;
esac

exit 0
