#!/bin/bash
# ═══════════════════════════════════════════════════════════
# Test-Fix Loop (Ralph Loop Pattern)
# Event: PostToolUse | Matcher: Bash
# Detects test failures and instructs auto-fix (up to 3 attempts)
# ═══════════════════════════════════════════════════════════

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/hook-utils.sh"
_parse_hook_input

[ "$HOOK_TOOL_NAME" = "Bash" ] || exit 0

# Only trigger on test runner commands
case "$HOOK_COMMAND" in
    *"npm test"*|*"npm run test"*|*"npx jest"*|*"npx vitest"*|*"npx playwright"*) ;;
    *"pytest"*|*"python -m pytest"*|*"python3 -m pytest"*) ;;
    *"go test"*|*"cargo test"*|*"swift test"*|*"xcodebuild test"*) ;;
    *) exit 0 ;;
esac

# Detect failure in tool result
if ! echo "$HOOK_TOOL_RESULT" | grep -qiE "(FAIL|FAILED|ERROR|failures?:|errors?:|AssertionError|assert.*failed|panic:|BROKEN|exit code [1-9]|exit status [1-9]|Tests:.*failed)"; then
    exit 0
fi
# False positive check
if echo "$HOOK_TOOL_RESULT" | grep -qiE "(0 failures|0 errors|all tests passed|Tests:.*0 failed)"; then
    exit 0
fi

RETRY_FILE="/tmp/claude-test-fix-loop-${HOOK_SESSION_ID}"
RETRY_COUNT=0
[ -f "$RETRY_FILE" ] && RETRY_COUNT=$(cat "$RETRY_FILE" 2>/dev/null || echo 0)

if [ "$RETRY_COUNT" -ge 3 ]; then
    echo "TEST-FIX LOOP: 3 retry attempts exhausted. Stop auto-fixing. Reset: rm $RETRY_FILE"
    exit 0
fi

RETRY_COUNT=$((RETRY_COUNT + 1))
echo "$RETRY_COUNT" > "$RETRY_FILE"

echo "TEST FAILURE (attempt ${RETRY_COUNT}/3). Read the error, fix the implementation (NOT the test unless wrong), re-run."
exit 0
