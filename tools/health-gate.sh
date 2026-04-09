#!/usr/bin/env bash
# gOS Health Gate — automated lean & performance checks
# Runs before every gOS commit. Exit 1 = warn, exit 2 = block.
set -euo pipefail

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
WARNINGS=0
ERRORS=0

echo "=== gOS Health Gate ==="

# --- 1. Command file size (warn if >400 lines) ---
echo ""
echo "Command sizes:"
for f in "$PROJECT_DIR"/commands/*.md; do
  [ -f "$f" ] || continue
  lines=$(wc -l < "$f" | tr -d ' ')
  name=$(basename "$f")
  if [ "$lines" -gt 400 ]; then
    echo "  WARN: $name ($lines lines > 400 max)"
    WARNINGS=$((WARNINGS + 1))
  else
    echo "  OK: $name ($lines lines)"
  fi
done

# --- 2. L1 size (warn if >60 lines / ~800 tokens) ---
echo ""
L1="$PROJECT_DIR/memory/L1_essential.md"
if [ -f "$L1" ]; then
  l1_lines=$(wc -l < "$L1" | tr -d ' ')
  if [ "$l1_lines" -gt 60 ]; then
    echo "L1: WARN — $l1_lines lines (target ≤60 / ~800 tokens)"
    WARNINGS=$((WARNINGS + 1))
  else
    echo "L1: OK — $l1_lines lines"
  fi
fi

# --- 3. Test suite ---
echo ""
if command -v bats &>/dev/null && [ -d "$PROJECT_DIR/tests/hooks" ]; then
  TEST_OUTPUT=$(cd "$PROJECT_DIR" && bats tests/hooks/ --tap 2>&1)
  TOTAL=$(echo "$TEST_OUTPUT" | grep -c '^ok ' 2>/dev/null || true)
  FAILED=$(echo "$TEST_OUTPUT" | grep -c '^not ok ' 2>/dev/null || true)
  TOTAL=${TOTAL:-0}; FAILED=${FAILED:-0}
  if [ "$FAILED" -gt 0 ]; then
    echo "Tests: FAIL — $FAILED failures out of $((TOTAL + FAILED))"
    ERRORS=$((ERRORS + 1))
  else
    echo "Tests: PASS — $TOTAL/$TOTAL"
  fi
else
  echo "Tests: SKIP — bats not installed or no tests found"
fi

# --- 4. Coverage matrix ---
echo ""
MATRIX="$PROJECT_DIR/tools/coverage-matrix.sh"
if [ -x "$MATRIX" ]; then
  bash "$MATRIX"
fi

# --- 5. Global sync check (commands + hooks vs ~/.claude/) ---
echo ""
SYNC_DRIFT=0
for f in "$PROJECT_DIR"/commands/*.md; do
  name=$(basename "$f")
  [ -f "$HOME/.claude/commands/$name" ] || { SYNC_DRIFT=$((SYNC_DRIFT + 1)); continue; }
  diff -q "$f" "$HOME/.claude/commands/$name" >/dev/null 2>&1 || SYNC_DRIFT=$((SYNC_DRIFT + 1))
done
for f in "$PROJECT_DIR"/.claude/hooks/*.sh; do
  name=$(basename "$f")
  [ -f "$HOME/.claude/hooks/$name" ] || { SYNC_DRIFT=$((SYNC_DRIFT + 1)); continue; }
  diff -q "$f" "$HOME/.claude/hooks/$name" >/dev/null 2>&1 || SYNC_DRIFT=$((SYNC_DRIFT + 1))
done
if [ "$SYNC_DRIFT" -gt 0 ]; then
  echo "Global sync: WARN — $SYNC_DRIFT files differ from ~/.claude/"
  echo "  Fix: cp commands/*.md ~/.claude/commands/ && cp .claude/hooks/*.sh ~/.claude/hooks/"
  WARNINGS=$((WARNINGS + 1))
else
  echo "Global sync: OK — all commands + hooks match ~/.claude/"
fi

# --- 6. New untracked files (warn if >5) ---
echo ""
UNTRACKED=$(cd "$PROJECT_DIR" && git status --porcelain 2>/dev/null | grep '^?' | wc -l | tr -d ' ')
if [ "$UNTRACKED" -gt 5 ]; then
  echo "Untracked: WARN — $UNTRACKED files (review before committing)"
  WARNINGS=$((WARNINGS + 1))
else
  echo "Untracked: OK — $UNTRACKED files"
fi

# --- Summary ---
echo ""
echo "=== Gate Result: ${ERRORS} errors, ${WARNINGS} warnings ==="
if [ "$ERRORS" -gt 0 ]; then
  echo "BLOCKED — fix errors before committing"
  exit 2
elif [ "$WARNINGS" -gt 0 ]; then
  echo "WARN — review warnings, proceed with caution"
  exit 0
else
  echo "CLEAN — all checks pass"
  exit 0
fi
