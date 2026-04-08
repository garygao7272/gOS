#!/bin/bash
# ═══════════════════════════════════════════════════════════
# Hook 7: Prototype Version Guard
# Event: PreToolUse (Edit|Write)
# Warns if editing prototype without version bump
# ═══════════════════════════════════════════════════════════

set -euo pipefail

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

# Only guard the prototype index.html
if echo "$FILE_PATH" | grep -q "apps/web-prototype/index.html"; then
    echo "REMINDER: You are editing the prototype. Run ./apps/web-prototype/bump.sh after changes."
fi

exit 0
