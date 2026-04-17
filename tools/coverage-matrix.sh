#!/usr/bin/env bash
# gOS Coverage Matrix — shows spec/test/code coverage for all components
# Usage: ./tools/coverage-matrix.sh [--json]
# Called by /gos status to show pipeline coverage
set -euo pipefail

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
JSON_MODE="${1:-}"

commands_dir="$PROJECT_DIR/commands"
hooks_dir="$PROJECT_DIR/.claude/hooks"
rubrics_dir="$PROJECT_DIR/evals/rubrics"
tests_dir="$PROJECT_DIR/tests/hooks"
handoffs_dir="$PROJECT_DIR/sessions/handoffs"

# --- Commands coverage ---
cmd_total=0; cmd_with_rubric=0; cmd_missing_rubric=()
for cmd_file in "$commands_dir"/*.md; do
  [ -f "$cmd_file" ] || continue
  cmd_name=$(basename "$cmd_file" .md)
  # Skip alias files — their rubric coverage is shared with the command they alias
  if grep -qE '^alias:\s*true' "$cmd_file" 2>/dev/null; then continue; fi
  cmd_total=$((cmd_total + 1))
  if [ -f "$rubrics_dir/${cmd_name}.md" ]; then
    cmd_with_rubric=$((cmd_with_rubric + 1))
  else
    cmd_missing_rubric+=("$cmd_name")
  fi
done

# --- Hooks coverage ---
hook_total=0; hook_with_test=0; hook_missing_test=()
for hook_file in "$hooks_dir"/*.sh; do
  [ -f "$hook_file" ] || continue
  hook_name=$(basename "$hook_file" .sh)
  # Skip library files (sourced by hooks, not hooks themselves)
  case "$hook_name" in
    hook-utils) continue ;;
  esac
  hook_total=$((hook_total + 1))
  if [ -f "$tests_dir/${hook_name}.bats" ]; then
    hook_with_test=$((hook_with_test + 1))
  else
    hook_missing_test+=("$hook_name")
  fi
done

# --- Pipeline phase ---
think_done=false; design_done=false; build_done=false
[ -f "$handoffs_dir/think.json" ] && think_done=true
[ -f "$handoffs_dir/design.json" ] && design_done=true
[ -f "$handoffs_dir/build.json" ] && build_done=true

# --- Output ---
if [ "$JSON_MODE" = "--json" ]; then
  cat << EOF
{
  "commands": {"total": $cmd_total, "with_rubric": $cmd_with_rubric, "missing": [$(printf '"%s",' "${cmd_missing_rubric[@]}" | sed 's/,$//' )]},
  "hooks": {"total": $hook_total, "with_test": $hook_with_test, "missing": [$(printf '"%s",' "${hook_missing_test[@]}" | sed 's/,$//' )]},
  "pipeline": {"think": $think_done, "design": $design_done, "build": $build_done}
}
EOF
else
  echo "=== gOS Coverage Matrix ==="
  echo ""

  # Pipeline
  t="pending"; d="pending"; b="pending"
  $think_done && t="done"
  $design_done && d="done"
  $build_done && b="done"
  echo "Pipeline: /think [$t] → /design [$d] → /build [$b]"
  if $think_done && [ -f "$handoffs_dir/think.json" ]; then
    summary=$(jq -r '.summary // "—"' "$handoffs_dir/think.json" 2>/dev/null || echo "—")
    echo "  think: $summary"
  fi
  if $design_done && [ -f "$handoffs_dir/design.json" ]; then
    summary=$(jq -r '.summary // "—"' "$handoffs_dir/design.json" 2>/dev/null || echo "—")
    echo "  design: $summary"
  fi
  echo ""

  # Commands
  cmd_pct=$((cmd_with_rubric * 100 / (cmd_total > 0 ? cmd_total : 1)))
  echo "Commands: ${cmd_with_rubric}/${cmd_total} have rubrics (${cmd_pct}%)"
  if [ ${#cmd_missing_rubric[@]} -gt 0 ]; then
    echo "  Missing: ${cmd_missing_rubric[*]}"
  fi
  echo ""

  # Hooks
  hook_pct=$((hook_with_test * 100 / (hook_total > 0 ? hook_total : 1)))
  echo "Hooks: ${hook_with_test}/${hook_total} have tests (${hook_pct}%)"
  if [ ${#hook_missing_test[@]} -gt 0 ]; then
    echo "  Untested: ${hook_missing_test[*]}"
  fi
fi
