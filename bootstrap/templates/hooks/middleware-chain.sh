#!/bin/bash
# gOS Middleware Chain Hook
# Called by PreToolUse and PostToolUse hooks in settings.local.json
# Dispatches to the Python middleware runner with phase and tool context.
#
# Usage: middleware-chain.sh <pre|post> [tool_name] [file_path]

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
RUNNER="$PROJECT_DIR/.claude/middleware/runner.py"

PHASE="${1:-post}"
TOOL_NAME="${TOOL_NAME:-${2:-}}"
FILE_PATH="${FILE_PATH:-${3:-}}"

# Skip if runner doesn't exist
if [ ! -f "$RUNNER" ]; then
    exit 0
fi

# Skip if no state.json (not in a gOS session)
if [ ! -f "$PROJECT_DIR/sessions/state.json" ]; then
    exit 0
fi

# Run the middleware chain
# Exit code 2 from runner = blocking middleware denied (for PreToolUse)
python3 "$RUNNER" "$PHASE" --tool "$TOOL_NAME" --file "$FILE_PATH"
exit $?
