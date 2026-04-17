#!/bin/bash
# ═══════════════════════════════════════════════════════════
# Hook 11: Secret Scanner
# Event: PreToolUse (Bash — git commit)
# Scans staged files for hardcoded secrets before commit
# ═══════════════════════════════════════════════════════════

set -euo pipefail

INPUT=$(cat)

TOOL_NAME=$(echo "$INPUT" | python3 -c "
import sys, json
data = json.load(sys.stdin)
print(data.get('tool_name', ''))
" 2>/dev/null)

# Only check on Bash commands
if [ "$TOOL_NAME" != "Bash" ]; then
    exit 0
fi

CMD=$(echo "$INPUT" | python3 -c "
import sys, json
data = json.load(sys.stdin)
print(data.get('tool_input', {}).get('command', ''))
" 2>/dev/null)

# Only check on git commit commands
if ! echo "$CMD" | grep -qE 'git\s+commit'; then
    exit 0
fi

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"
cd "$PROJECT_DIR"

# Get staged files
STAGED=$(git diff --cached --name-only 2>/dev/null || true)

if [ -z "$STAGED" ]; then
    exit 0
fi

# Secret patterns to scan for
PATTERNS=(
    'API_KEY\s*=\s*["\x27][A-Za-z0-9]'
    'SECRET\s*=\s*["\x27][A-Za-z0-9]'
    'TOKEN\s*=\s*["\x27][A-Za-z0-9]'
    'PASSWORD\s*=\s*["\x27][A-Za-z0-9]'
    'PRIVATE_KEY\s*=\s*["\x27][A-Za-z0-9]'
    'sk-[A-Za-z0-9]{20,}'
    'ghp_[A-Za-z0-9]{36}'
    'xoxb-[0-9]'
)

FOUND=""
for file in $STAGED; do
    [ -f "$file" ] || continue
    # Skip binary files, lock files, and env examples
    case "$file" in
        *.lock|*.png|*.jpg|*.gif|*.ico|*.woff*|*.ttf|*.eot) continue ;;
        *.example|*.template|env.example|bootstrap/env.example) continue ;;
    esac

    for pattern in "${PATTERNS[@]}"; do
        MATCH=$(grep -nE "$pattern" "$file" 2>/dev/null || true)
        if [ -n "$MATCH" ]; then
            FOUND="$FOUND\n  $file: $MATCH"
        fi
    done
done

if [ -n "$FOUND" ]; then
    echo "BLOCKED: Potential secrets detected in staged files:$FOUND" >&2
    echo "" >&2
    echo "If these are false positives, use environment variables instead of hardcoded values." >&2
    exit 2
fi

exit 0
