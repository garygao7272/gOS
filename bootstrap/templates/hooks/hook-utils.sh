#!/bin/bash
# ═══════════════════════════════════════════════════════════
# Hook Utilities — shared helpers sourced by all gOS hooks
# ═══════════════════════════════════════════════════════════

# Parse JSON input from stdin into exported variables.
# Call once per hook; stdin is consumed.
#
# Exports: HOOK_TOOL_NAME, HOOK_FILE_PATH, HOOK_COMMAND,
#          HOOK_SESSION_ID, HOOK_TOOL_RESULT, HOOK_RAW
_parse_hook_input() {
    HOOK_RAW=$(cat)
    eval "$(echo "$HOOK_RAW" | python3 -c "
import sys, json, shlex
try:
    d = json.load(sys.stdin)
except:
    d = {}
ti = d.get('tool_input', {})
fp = ti.get('file_path', '') or ti.get('filePath', '')
cmd = ti.get('command', '')
sid = d.get('session_id', 'default')
tn = d.get('tool_name', '')
# tool_result can be dict/list/str
tr = d.get('tool_result', '')
if isinstance(tr, (dict, list)):
    tr = json.dumps(tr)
tr = str(tr)[:5000]
# Shell-safe export
print(f'HOOK_TOOL_NAME={shlex.quote(tn)}')
print(f'HOOK_FILE_PATH={shlex.quote(fp)}')
print(f'HOOK_COMMAND={shlex.quote(cmd)}')
print(f'HOOK_SESSION_ID={shlex.quote(sid)}')
print(f'HOOK_TOOL_RESULT={shlex.quote(tr)}')
" 2>/dev/null)" || {
        HOOK_TOOL_NAME=""
        HOOK_FILE_PATH=""
        HOOK_COMMAND=""
        HOOK_SESSION_ID="default"
        HOOK_TOOL_RESULT=""
    }
    export HOOK_TOOL_NAME HOOK_FILE_PATH HOOK_COMMAND HOOK_SESSION_ID HOOK_TOOL_RESULT HOOK_RAW
}

# Project directory (stable across hooks)
HOOK_PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"
export HOOK_PROJECT_DIR
