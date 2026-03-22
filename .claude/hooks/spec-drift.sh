#!/bin/bash
# ═══════════════════════════════════════════════════════════
# Hook 9: Spec Drift Detector
# Event: PostToolUse (Edit|Write)
# After editing apps/, flags if corresponding spec needs updating
# ═══════════════════════════════════════════════════════════

set -euo pipefail

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"
INPUT=$(cat)

FILE_PATH=$(echo "$INPUT" | python3 -c "
import sys, json
data = json.load(sys.stdin)
ti = data.get('tool_input', {})
print(ti.get('file_path', '') or ti.get('filePath', ''))
" 2>/dev/null)

if [ -z "$FILE_PATH" ]; then
    exit 0
fi

# Only check files under apps/
REL_PATH="${FILE_PATH#"$PROJECT_DIR"/}"
if ! echo "$REL_PATH" | grep -q "^apps/"; then
    exit 0
fi

# Map apps/ paths to spec files
SPEC_HINT=""
if echo "$REL_PATH" | grep -q "apps/web-prototype/"; then
    SPEC_HINT="specs/Arx_4-1-1-* (mobile screen specs)"
elif echo "$REL_PATH" | grep -q "apps/mobile/"; then
    SPEC_HINT="specs/Arx_5-* (engineering specs)"
fi

if [ -n "$SPEC_HINT" ]; then
    echo "SPEC SYNC REMINDER: You edited $REL_PATH. Check if $SPEC_HINT needs updating."
fi

exit 0
