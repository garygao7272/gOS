#!/bin/bash
# ═══════════════════════════════════════════════════════════
# Freeze Guard
# Event: PreToolUse (Edit|Write)
# Blocks file edits outside the frozen scope directory
# Toggle: /gos freeze <dir> creates /tmp/claude-freeze-scope
#         /gos freeze off removes it
# ═══════════════════════════════════════════════════════════

set -euo pipefail

FREEZE_FILE="/tmp/claude-freeze-scope"

# No freeze active → allow everything
if [ ! -f "$FREEZE_FILE" ]; then
    exit 0
fi

FROZEN_DIR=$(cat "$FREEZE_FILE" 2>/dev/null | head -1 | xargs)

# Empty or invalid freeze file → allow
if [ -z "$FROZEN_DIR" ]; then
    exit 0
fi

# Extract target file path from tool input
INPUT=$(cat)
TARGET=$(echo "$INPUT" | python3 -c "
import sys, json
data = json.load(sys.stdin)
ti = data.get('tool_input', {})
print(ti.get('file_path', ''))
" 2>/dev/null || echo "")

# No file path (shouldn't happen for Edit/Write) → allow
if [ -z "$TARGET" ]; then
    exit 0
fi

# Resolve to absolute paths for comparison
FROZEN_ABS=$(cd "${FROZEN_DIR}" 2>/dev/null && pwd || echo "$FROZEN_DIR")
TARGET_DIR=$(dirname "$TARGET")
TARGET_ABS=$(cd "$TARGET_DIR" 2>/dev/null && echo "$(pwd)/$(basename "$TARGET")" || echo "$TARGET")

# Check if target is within frozen scope
case "$TARGET_ABS" in
    ${FROZEN_ABS}*)
        # Within scope → allow
        exit 0
        ;;
    *)
        # Outside scope → block
        echo "🧊 FROZEN: Edits scoped to $FROZEN_DIR. File $TARGET is outside scope. Use /gos freeze off to unlock."
        exit 0
        ;;
esac
