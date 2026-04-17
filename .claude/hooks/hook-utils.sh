#!/bin/bash
# ═══════════════════════════════════════════════════════════
# Hook Utilities — shared helpers sourced by all gOS hooks
# (jq-powered; python3 path kept as fallback)
# ═══════════════════════════════════════════════════════════

# Parse JSON input from stdin into exported variables.
# Call once per hook; stdin is consumed.
#
# Exports: HOOK_TOOL_NAME, HOOK_FILE_PATH, HOOK_COMMAND,
#          HOOK_SESSION_ID, HOOK_TOOL_RESULT, HOOK_RAW
_parse_hook_input() {
    HOOK_RAW=$(cat)

    if command -v jq >/dev/null 2>&1; then
        # Fast path: single jq invocation with shell-safe output
        local parsed
        parsed=$(printf '%s' "$HOOK_RAW" | jq -r '
            def q: @sh;
            [
              "HOOK_TOOL_NAME=" + (.tool_name // "" | q),
              "HOOK_FILE_PATH=" + ((.tool_input.file_path // .tool_input.filePath // "") | q),
              "HOOK_COMMAND="   + (.tool_input.command // "" | q),
              "HOOK_SESSION_ID="+ (.session_id // "default" | q),
              "HOOK_TOOL_RESULT="+ ((.tool_result // "" |
                  if type == "string" then .
                  else tojson end
                ) | .[0:5000] | q)
            ] | .[]
        ' 2>/dev/null)
        if [ -n "$parsed" ]; then
            eval "$parsed"
        else
            HOOK_TOOL_NAME=""; HOOK_FILE_PATH=""; HOOK_COMMAND=""
            HOOK_SESSION_ID="default"; HOOK_TOOL_RESULT=""
        fi
    else
        # Fallback: python3 (retained for environments without jq)
        eval "$(printf '%s' "$HOOK_RAW" | python3 -c "
import sys, json, shlex
try:
    d = json.load(sys.stdin)
except Exception:
    d = {}
ti = d.get('tool_input', {}) or {}
fp = ti.get('file_path', '') or ti.get('filePath', '')
cmd = ti.get('command', '')
sid = d.get('session_id', 'default')
tn = d.get('tool_name', '')
tr = d.get('tool_result', '')
if isinstance(tr, (dict, list)):
    tr = json.dumps(tr)
tr = str(tr)[:5000]
print(f'HOOK_TOOL_NAME={shlex.quote(tn)}')
print(f'HOOK_FILE_PATH={shlex.quote(fp)}')
print(f'HOOK_COMMAND={shlex.quote(cmd)}')
print(f'HOOK_SESSION_ID={shlex.quote(sid)}')
print(f'HOOK_TOOL_RESULT={shlex.quote(tr)}')
" 2>/dev/null)" || {
            HOOK_TOOL_NAME=""; HOOK_FILE_PATH=""; HOOK_COMMAND=""
            HOOK_SESSION_ID="default"; HOOK_TOOL_RESULT=""
        }
    fi

    export HOOK_TOOL_NAME HOOK_FILE_PATH HOOK_COMMAND HOOK_SESSION_ID HOOK_TOOL_RESULT HOOK_RAW
}

# Project directory (stable across hooks)
HOOK_PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"
export HOOK_PROJECT_DIR
