#!/bin/bash
# Plan Gate — UserPromptSubmit edition
# Event: UserPromptSubmit
#
# Two jobs:
#   1. When the prompt starts with a plan-gated gOS verb, write a Plan Gate
#      section to sessions/scratchpad.md with STATE=pending. The PreToolUse
#      plan-gate.sh reads this and blocks Edit/Write until STATE flips.
#   2. When STATE=pending and the prompt contains an approval or bypass
#      token, flip STATE accordingly so Claude can proceed.
#
# Also inject the direct-response styling reminder for all gOS verbs.

set -uo pipefail

INPUT="$(cat)"
PROMPT="$(printf '%s' "$INPUT" | jq -r '.prompt // empty' 2>/dev/null || echo "")"
PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"
SCRATCHPAD="$PROJECT_DIR/sessions/scratchpad.md"

lowercase() { printf '%s' "$1" | tr '[:upper:]' '[:lower:]'; }

# Hard plan-gate list. Sub-command awareness:
#   /ship commit | /ship docs             → NO gate (atomic)
#   /ship <anything else>                 → gate
#   /evolve audit | learn | reflect       → NO gate
#   /evolve upgrade                       → gate
#   /review dashboard                     → NO gate
#   /review <anything else>               → gate
requires_plan_gate() {
    local cmd="$1" rest="$2"
    case "$cmd" in
        /build|/design|/think|/refine|/simulate) return 0 ;;
        /review)
            case "$(lowercase "$rest")" in
                dashboard*|"") return 1 ;;
                *) return 0 ;;
            esac ;;
        /ship)
            case "$(lowercase "$rest")" in
                commit*|docs*) return 1 ;;
                *) return 0 ;;
            esac ;;
        /evolve)
            case "$(lowercase "$rest")" in
                upgrade*) return 0 ;;
                *) return 1 ;;
            esac ;;
        *) return 1 ;;
    esac
}

is_gos_verb() {
    case "$1" in
        /gos|/think|/design|/build|/review|/ship|/simulate|/evolve|/refine|/save|/resume|/intake)
            return 0 ;;
        *) return 1 ;;
    esac
}

current_state() {
    [ -f "$SCRATCHPAD" ] || { echo ""; return; }
    awk '
        /^## Plan Gate/ { in_section = 1; next }
        /^## / && in_section { exit }
        in_section && /^STATE:/ { sub(/^STATE:[[:space:]]*/, ""); print; exit }
    ' "$SCRATCHPAD" 2>/dev/null
}

current_required() {
    [ -f "$SCRATCHPAD" ] || { echo ""; return; }
    awk '
        /^## Plan Gate/ { in_section = 1; next }
        /^## / && in_section { exit }
        in_section && /^REQUIRED:/ { sub(/^REQUIRED:[[:space:]]*/, ""); print; exit }
    ' "$SCRATCHPAD" 2>/dev/null
}

write_plan_gate() {
    local required="$1" state="$2"
    local ts
    ts="$(date +%s)"
    mkdir -p "$(dirname "$SCRATCHPAD")"
    touch "$SCRATCHPAD"
    local tmp
    tmp="$(mktemp)"
    awk '
        /^## Plan Gate/ { in_section = 1; next }
        /^## / && in_section { in_section = 0 }
        !in_section { print }
    ' "$SCRATCHPAD" > "$tmp"
    cat >> "$tmp" <<EOF

## Plan Gate
REQUIRED: $required
STATE: $state
SET_AT: $ts
EOF
    mv "$tmp" "$SCRATCHPAD"
}

# Approval: standalone short tokens OR explicit "plan approved" in longer text.
matches_approval() {
    local p
    p="$(lowercase "$1")"
    # Trim whitespace for short-reply check.
    local trimmed
    trimmed="$(printf '%s' "$p" | awk '{$1=$1; print}')"
    if [ "${#trimmed}" -le 20 ]; then
        case "$trimmed" in
            y|yes|go|ok|okay|proceed|approved|approve|confirm|confirmed|"ship it"|"do it")
                return 0 ;;
        esac
    fi
    case " $p " in
        *" plan approved "*|*"plan_approved"*)
            return 0 ;;
    esac
    return 1
}

matches_bypass() {
    local p
    p="$(lowercase "$1")"
    case "$p" in
        *"just do it"*|*"skip plan"*|*"skip the plan"*|*"no plan"*|*"bypass plan"*)
            return 0 ;;
    esac
    return 1
}

FIRST_TOKEN_RAW="$(printf '%s' "$PROMPT" | awk '{print $1}')"
FIRST_TOKEN="$(lowercase "$FIRST_TOKEN_RAW")"
REST="$(printf '%s' "$PROMPT" | awk '{$1=""; print substr($0,2)}')"
STATE_NOW="$(current_state)"

# Case 1: prompt starts with a plan-gated verb → open a new gate.
if requires_plan_gate "$FIRST_TOKEN" "$REST"; then
    SUB="$(printf '%s' "$REST" | awk '{print $1}')"
    write_plan_gate "$FIRST_TOKEN $SUB" "pending"
    cat <<GATE
─── Plan Gate OPENED (harness-injected) ─────────────────────────────────────
Command: $FIRST_TOKEN_RAW — requires a plan before any Edit/Write/Bash(git).

Present before executing (skip only if Gary says "just do it"):
  PLAN       — 1-line restatement of the goal
  STEPS      — numbered, each dependency-aware
  MEMORY     — L1 + scratchpad + claude-mem relevant hits
  RISK       — biggest risk + mitigation
  CONFIDENCE — high / medium / low + 1-line reason
  CONFIRM?   — wait for Gary's explicit "yes" / "go" / "approved"

The PreToolUse hook will BLOCK Edit/Write/Bash(git) until STATE flips.
To bypass: Gary types "just do it" or "skip plan".
──────────────────────────────────────────────────────────────────────────────
GATE
    exit 0
fi

# Case 2: gate is pending — detect approval or bypass.
if [ "$STATE_NOW" = "pending" ]; then
    REQUIRED="$(current_required)"

    if matches_bypass "$PROMPT"; then
        write_plan_gate "$REQUIRED" "bypassed-$(date +%s)"
        cat <<GATE
─── Plan Gate BYPASSED ──────────────────────────────────────────────────────
Gary said "just do it" — Plan Gate for "$REQUIRED" is bypassed.
Edit/Write/Bash(git) unblocked.
──────────────────────────────────────────────────────────────────────────────
GATE
        exit 0
    fi

    if matches_approval "$PROMPT"; then
        write_plan_gate "$REQUIRED" "approved-$(date +%s)"
        cat <<GATE
─── Plan Gate APPROVED ──────────────────────────────────────────────────────
Plan for "$REQUIRED" approved. Edit/Write/Bash(git) unblocked. Proceed.
──────────────────────────────────────────────────────────────────────────────
GATE
        exit 0
    fi
fi

# Case 3: any gOS verb not in the hard list → styling reminder only.
if is_gos_verb "$FIRST_TOKEN"; then
    cat <<GATE
─── gOS styling reminder (harness-injected) ─────────────────────────────────
Direct-response structure (from ~/.claude/output-styles/direct-response.md):
  1. ANSWER  — root mechanism first
  2. DECOMPOSE — table/list
  3. SOLUTIONS — concrete actions, ordered
  4. WRAP — CONFIDENCE + WHY + NEXT

Output routing: inline by default. Write a file only when content must outlive
this session (cross-session retrieval, handoff, persistent contract, >300
words with reusable structure, audit tracking). When writing a file, also emit
a ≤100-word inline summary with the path.
──────────────────────────────────────────────────────────────────────────────
GATE
fi

exit 0
