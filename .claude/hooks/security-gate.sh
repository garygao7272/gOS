#!/bin/bash
# ═══════════════════════════════════════════════════════════
# Security Gate (merged: protect-files + secret-scan)
# Event: PreToolUse (Edit|Write|Bash)
# Blocks: sensitive file edits, dangerous commands, secrets in commits
# ═══════════════════════════════════════════════════════════

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/hook-utils.sh"
_parse_hook_input

if [ "$HOOK_TOOL_NAME" = "Bash" ]; then
    # --- Cleanup-zone allowlist (bypasses rm -rf dangerous-command block) ---
    # Allow single-target rm of direct subdirs of ~/.claude/{plugins/cache,projects-archive,backups,cache}
    # See delete-guard.sh for the same pattern — they must stay in sync.
    _ZONES='(plugins/cache|projects-archive|backups|cache)'
    _NAME='[a-zA-Z0-9_.-]+'
    _BASE='(~|/Users/[a-zA-Z0-9_.-]+)/\.claude'
    if echo "$HOOK_COMMAND" | grep -qE "^[[:space:]]*rm[[:space:]]+-[rf]+[[:space:]]+${_BASE}/${_ZONES}/${_NAME}/?[[:space:]]*$" \
       || echo "$HOOK_COMMAND" | grep -qE "^[[:space:]]*cd[[:space:]]+${_BASE}/${_ZONES}[[:space:]]*&&[[:space:]]*rm[[:space:]]+-[rf]+[[:space:]]+${_NAME}/?[[:space:]]*$"; then
        exit 0  # allowlisted cleanup
    fi

    # --- Dangerous command blocklist ---
    if echo "$HOOK_COMMAND" | grep -qE '(rm\s+-rf\s+[/~]|git\s+push\s+--force|git\s+reset\s+--hard|git\s+clean\s+-fd)'; then
        echo "BLOCKED: Dangerous command: $HOOK_COMMAND" >&2; exit 2
    fi
    if echo "$HOOK_COMMAND" | grep -qE '(curl|wget|fetch)\s+.*\|\s*(sh|bash|zsh|python|node|ruby|perl)'; then
        echo "BLOCKED: Remote code execution pattern (pipe to shell)" >&2; exit 2
    fi
    if echo "$HOOK_COMMAND" | grep -qE '(>\s*|tee\s+)(\/etc\/|\/usr\/|\/var\/|\/tmp\/\.\.|\/root\/)'; then
        echo "BLOCKED: Write attempt outside project boundary" >&2; exit 2
    fi
    if echo "$HOOK_COMMAND" | grep -qE '(npm\s+install|pip\s+install|gem\s+install|cargo\s+install)\s+.*--force'; then
        echo "BLOCKED: Forced package install" >&2; exit 2
    fi

    # --- Secret scan on git commit ---
    if echo "$HOOK_COMMAND" | grep -qE 'git\s+commit'; then
        cd "$HOOK_PROJECT_DIR"
        STAGED=$(git diff --cached --name-only 2>/dev/null || true)
        if [ -n "$STAGED" ]; then
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
                case "$file" in
                    *.lock|*.png|*.jpg|*.gif|*.ico|*.woff*|*.ttf|*.eot) continue ;;
                    *.example|*.template|env.example) continue ;;
                esac
                for pattern in "${PATTERNS[@]}"; do
                    MATCH=$(grep -nE "$pattern" "$file" 2>/dev/null || true)
                    [ -n "$MATCH" ] && FOUND="$FOUND\n  $file: $MATCH"
                done
            done
            if [ -n "$FOUND" ]; then
                echo "BLOCKED: Potential secrets in staged files:$FOUND" >&2
                echo "Use environment variables instead of hardcoded values." >&2
                exit 2
            fi
        fi
    fi
else
    # --- Sensitive file protection (Edit|Write) ---
    if [ -n "$HOOK_FILE_PATH" ]; then
        case "$(basename "$HOOK_FILE_PATH")" in
            .env|.env.*|*.key|*.pem|*.p12|*.pfx|credentials.json|secrets.yaml|secrets.yml)
                echo "BLOCKED: Cannot edit sensitive file: $(basename "$HOOK_FILE_PATH")" >&2; exit 2 ;;
        esac
    fi
fi

exit 0
