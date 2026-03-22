#!/bin/bash
# ═══════════════════════════════════════════════════════════
# Hook 6: Auto-Formatter
# Event: PostToolUse (Edit|Write)
# Runs appropriate formatter based on file extension
# ═══════════════════════════════════════════════════════════

set -euo pipefail

INPUT=$(cat)

FILE_PATH=$(echo "$INPUT" | python3 -c "
import sys, json
data = json.load(sys.stdin)
ti = data.get('tool_input', {})
print(ti.get('file_path', '') or ti.get('filePath', ''))
" 2>/dev/null)

if [ -z "$FILE_PATH" ] || [ ! -f "$FILE_PATH" ]; then
    exit 0
fi

EXT="${FILE_PATH##*.}"

case "$EXT" in
    js|jsx|ts|tsx|css|scss|html|json|md)
        if command -v npx &>/dev/null; then
            npx prettier --write "$FILE_PATH" 2>/dev/null || true
        fi
        ;;
    py)
        if command -v black &>/dev/null; then
            black --quiet "$FILE_PATH" 2>/dev/null || true
        elif command -v autopep8 &>/dev/null; then
            autopep8 --in-place "$FILE_PATH" 2>/dev/null || true
        fi
        ;;
esac

exit 0
