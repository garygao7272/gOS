#!/usr/bin/env bash
# file-length-check.sh — warn when files exceed ergonomic caps
# Caps defined in ~/.claude/rules/common/file-structure.md
# Exit 1 if any warnings; exit 0 if clean. Never blocks.
set -euo pipefail

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
WARN=0

check_glob() {
  local dir="$1"
  local name_pattern="$2"
  local cap="$3"
  local label="$4"
  [ -d "$dir" ] || return 0
  while IFS= read -r -d '' f; do
    lines=$(wc -l < "$f" | tr -d ' ')
    if [ "$lines" -gt "$cap" ]; then
      rel="${f#$PROJECT_DIR/}"
      echo "  WARN: $rel ($lines > $cap for $label)"
      WARN=$((WARN + 1))
    fi
  done < <(find "$dir" -maxdepth 1 -name "$name_pattern" -type f -print0 2>/dev/null)
}

echo "=== File Length Check ==="
echo ""
echo "Commands (cap 300):"
check_glob "$PROJECT_DIR/commands" "*.md" 300 "command"

echo "Agents (cap 200):"
check_glob "$PROJECT_DIR/agents" "*.md" 200 "agent"

echo "Rules (cap 200):"
check_glob "$PROJECT_DIR/rules/common" "*.md" 200 "rule"

echo "Hooks (cap 150):"
check_glob "$PROJECT_DIR/.claude/hooks" "*.sh" 150 "hook"
check_glob "$PROJECT_DIR/hooks" "*.sh" 150 "hook"

echo "Memory (cap varies):"
check_glob "$PROJECT_DIR/memory" "L0_*.md" 150 "L0 kernel"
check_glob "$PROJECT_DIR/memory" "L1_*.md" 80 "L1 essential"
check_glob "$PROJECT_DIR/memory" "feedback_*.md" 80 "feedback memory"

echo ""
echo "Skills:"
if [ -d "$PROJECT_DIR/skills" ]; then
  while IFS= read -r -d '' f; do
    name=$(basename "$f")
    lines=$(wc -l < "$f" | tr -d ' ')
    cap=150
    [[ "$name" == "REFERENCE.md" ]] && cap=800
    if [ "$lines" -gt "$cap" ]; then
      rel="${f#$PROJECT_DIR/}"
      echo "  WARN: $rel ($lines > $cap)"
      WARN=$((WARN + 1))
    fi
  done < <(find "$PROJECT_DIR/skills" -maxdepth 3 -name "*.md" -type f -print0 2>/dev/null)
fi

echo ""
if [ "$WARN" -eq 0 ]; then
  echo "RESULT: clean (0 warnings)"
  exit 0
else
  echo "RESULT: $WARN warning(s) — see ~/.claude/rules/common/file-structure.md"
  exit 1
fi
