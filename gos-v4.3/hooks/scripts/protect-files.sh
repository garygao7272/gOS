#!/bin/bash
# ═══════════════════════════════════════════════════════════
# Hook 5: File Protector
# Event: PreToolUse (Edit|Write|Bash)
# Blocks edits to sensitive files and dangerous commands
# ═══════════════════════════════════════════════════════════

set -euo pipefail

INPUT=$(cat)

TOOL_NAME=$(echo "$INPUT" | python3 -c "
import sys, json
data = json.load(sys.stdin)
print(data.get('tool_name', ''))
" 2>/dev/null)

if [ "$TOOL_NAME" = "Bash" ]; then
    # Check for dangerous bash commands
    CMD=$(echo "$INPUT" | python3 -c "
import sys, json
data = json.load(sys.stdin)
print(data.get('tool_input', {}).get('command', ''))
" 2>/dev/null)

    # Blocklist patterns — destructive commands
    if echo "$CMD" | grep -qE '(rm\s+-rf\s+[/~]|git\s+push\s+--force|git\s+reset\s+--hard|git\s+clean\s+-fd)'; then
        echo "BLOCKED: Dangerous command detected: $CMD" >&2
        exit 2
    fi

    # Blocklist — network egress piped to execution (Trail of Bits pattern)
    if echo "$CMD" | grep -qE '(curl|wget|fetch)\s+.*\|\s*(sh|bash|zsh|python|node|ruby|perl)'; then
        echo "BLOCKED: Remote code execution pattern detected (pipe to shell): $CMD" >&2
        exit 2
    fi

    # Blocklist — filesystem boundary enforcement
    PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"
    if echo "$CMD" | grep -qE '(>\s*|tee\s+)(\/etc\/|\/usr\/|\/var\/|\/tmp\/\.\.|\/root\/)'; then
        echo "BLOCKED: Write attempt outside project boundary: $CMD" >&2
        exit 2
    fi

    # Blocklist — package install without review
    if echo "$CMD" | grep -qE '(npm\s+install|pip\s+install|gem\s+install|cargo\s+install)\s+.*--force'; then
        echo "BLOCKED: Forced package install detected: $CMD" >&2
        exit 2
    fi
else
    # Check for sensitive file paths (Edit or Write)
    FILE_PATH=$(echo "$INPUT" | python3 -c "
import sys, json
data = json.load(sys.stdin)
ti = data.get('tool_input', {})
print(ti.get('file_path', '') or ti.get('filePath', ''))
" 2>/dev/null)

    if [ -n "$FILE_PATH" ]; then
        BASENAME=$(basename "$FILE_PATH")

        # Block sensitive files
        case "$BASENAME" in
            .env|.env.*|*.key|*.pem|*.p12|*.pfx|credentials.json|secrets.yaml|secrets.yml)
                echo "BLOCKED: Cannot edit sensitive file: $BASENAME" >&2
                exit 2
                ;;
        esac
    fi
fi

exit 0
