#!/bin/bash
# ═══════════════════════════════════════════════════════════
# Test-Fix Loop (Ralph Loop Pattern)
# Event: PostToolUse | Matcher: Bash
# Detects test failures in Bash output and instructs Claude
# to automatically fix and retry (up to 3 attempts)
# ═══════════════════════════════════════════════════════════

set -euo pipefail

INPUT=$(cat)

# Extract tool name and command
TOOL_NAME=$(echo "$INPUT" | python3 -c "import sys,json; print(json.load(sys.stdin).get('tool_name',''))" 2>/dev/null || echo "")

# Only trigger on Bash tool
if [ "$TOOL_NAME" != "Bash" ]; then
    exit 0
fi

# Extract the command that was run
COMMAND=$(echo "$INPUT" | python3 -c "import sys,json; print(json.load(sys.stdin).get('tool_input',{}).get('command',''))" 2>/dev/null || echo "")

# Only trigger on test runner commands
IS_TEST_CMD=false
case "$COMMAND" in
    *"npm test"*|*"npm run test"*|*"npx jest"*|*"npx vitest"*|*"npx playwright"*)
        IS_TEST_CMD=true ;;
    *"pytest"*|*"python -m pytest"*|*"python3 -m pytest"*)
        IS_TEST_CMD=true ;;
    *"go test"*)
        IS_TEST_CMD=true ;;
    *"cargo test"*)
        IS_TEST_CMD=true ;;
    *"swift test"*|*"xcodebuild test"*)
        IS_TEST_CMD=true ;;
esac

if [ "$IS_TEST_CMD" != "true" ]; then
    exit 0
fi

# Check if the tool result indicates failure
TOOL_RESULT=$(echo "$INPUT" | python3 -c "
import sys, json
data = json.load(sys.stdin)
result = data.get('tool_result', '')
if isinstance(result, dict):
    result = json.dumps(result)
elif isinstance(result, list):
    result = json.dumps(result)
print(str(result)[:5000])
" 2>/dev/null || echo "")

# Detect test failure patterns
HAS_FAILURE=false
if echo "$TOOL_RESULT" | grep -qiE "(FAIL|FAILED|ERROR|failures?:|errors?:|AssertionError|assert.*failed|panic:|BROKEN|exit code [1-9]|exit status [1-9]|Tests:.*failed)"; then
    # But not if ALL tests passed (some runners show "0 failures")
    if ! echo "$TOOL_RESULT" | grep -qiE "(0 failures|0 errors|all tests passed|Tests:.*0 failed)"; then
        HAS_FAILURE=true
    fi
fi

if [ "$HAS_FAILURE" != "true" ]; then
    exit 0
fi

# Track retry count per session
SESSION_ID=$(echo "$INPUT" | python3 -c "import sys,json; print(json.load(sys.stdin).get('session_id','default'))" 2>/dev/null || echo "default")
RETRY_FILE="/tmp/claude-test-fix-loop-${SESSION_ID}"

RETRY_COUNT=0
if [ -f "$RETRY_FILE" ]; then
    RETRY_COUNT=$(cat "$RETRY_FILE" 2>/dev/null || echo 0)
fi

if [ "$RETRY_COUNT" -ge 3 ]; then
    echo "⛔ TEST-FIX LOOP: 3 retry attempts exhausted. Stop auto-fixing — the issue needs manual investigation. Reset with: rm $RETRY_FILE"
    exit 0
fi

RETRY_COUNT=$((RETRY_COUNT + 1))
echo "$RETRY_COUNT" > "$RETRY_FILE"

echo "🔄 TEST FAILURE DETECTED (attempt ${RETRY_COUNT}/3). Read the error output above carefully. Identify the root cause, fix the implementation (NOT the test unless the test is wrong), then re-run the same test command. If you cannot fix it after this attempt, stop and explain the issue to the user."

exit 0
