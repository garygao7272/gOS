#!/bin/bash
# ═══════════════════════════════════════════════════════════
# Plan Gate
# Event: PreToolUse (Edit|Write)
# Blocks edits during /think, /build, /design until plan approved
# ═══════════════════════════════════════════════════════════

set -euo pipefail

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"
SCRATCHPAD="$PROJECT_DIR/sessions/scratchpad.md"

[ -f "$SCRATCHPAD" ] || exit 0

MODE=$(sed -n '/^## Mode/,/^##/{/^## Mode/d;/^##/d;p;}' "$SCRATCHPAD" 2>/dev/null | head -1 | xargs)
[ -n "$MODE" ] && [ "$MODE" != "(awaiting routing)" ] || exit 0

# Only gate think/build/design modes
case "$MODE" in
    *[Tt]hink*|*[Bb]uild*|*[Dd]esign*) ;;
    *) exit 0 ;;
esac

# Check for plan approval
grep -q "Plan: APPROVED\|PLAN_APPROVED\|plan approved" "$SCRATCHPAD" 2>/dev/null || {
    echo "PLAN GATE: Mode is '$MODE' but no plan approved yet. Use EnterPlanMode, get approval, then write 'Plan: APPROVED' to scratchpad."
    exit 0
}

# ═══════════════════════════════════════════════════════════
# Design-specific gates (only apply in Design mode)
# ═══════════════════════════════════════════════════════════
case "$MODE" in
    *[Dd]esign*)
        # Get the target file path from tool input (Edit/Write file_path)
        TARGET="${TOOL_INPUT_FILE_PATH:-${TOOL_INPUT_file_path:-}}"

        # Only gate writes to design output paths and screen specs
        case "$TARGET" in
            */think/design/*|*/specs/Arx_4-1-*|*/web-prototype/drafts/*)
                # Gate 0: State Matrix must exist in scratchpad before writing screen specs
                grep -q "## State Matrix\|STATE_MATRIX_DONE\|state matrix" "$SCRATCHPAD" 2>/dev/null || {
                    echo "DESIGN GATE 0: Writing to '$TARGET' but no state matrix found in scratchpad."
                    echo "Before writing any screen spec, generate the state matrix (all states × journey × data × edge cases)."
                    echo "Write '## State Matrix' section to scratchpad, then retry."
                    echo ""
                    echo "Template (from specs/Arx_4-3 §8):"
                    echo "| State | Journey | Data Available | What User Sees | Edge Case |"
                    echo "|-------|---------|----------------|----------------|-----------|"
                    echo "| Default | ... | ... | ... | ... |"
                    exit 2
                }

                # Gate -1: Reference Research must exist before writing screen specs
                grep -q "## Reference Research\|## Design References\|REFERENCE_RESEARCH_DONE\|reference research" "$SCRATCHPAD" 2>/dev/null || {
                    echo "DESIGN GATE -1: Writing to '$TARGET' but no reference research found in scratchpad."
                    echo "Before writing any screen spec, research 3+ reference apps that handle this pattern."
                    echo "Write '## Reference Research' section to scratchpad with findings, then retry."
                    exit 2
                }
                ;;
        esac
        ;;
esac

exit 0
