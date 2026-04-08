#!/usr/bin/env bash
# gOS Wiki Lint — detects stale, orphaned, and contradictory knowledge
# Run weekly via /evolve audit or scheduled task
set -euo pipefail

WIKI_DIR="$(cd "$(dirname "$0")" && pwd)"
MEMORY_DIR="$(dirname "$WIKI_DIR")"
TODAY=$(date '+%Y-%m-%d')
ISSUES=0

echo "═══════════════════════════════════════"
echo "  gOS Wiki Lint — $TODAY"
echo "═══════════════════════════════════════"
echo ""

# 1. Check staleness (valid_until dates)
echo "── Staleness Check ──"
for f in "$WIKI_DIR"/decisions/*.md "$WIKI_DIR"/preferences/*.md "$MEMORY_DIR"/instincts/*.yaml; do
  [ -f "$f" ] || continue
  name=$(basename "$f")
  valid_until=$(sed -n 's/.*valid_until:\s*\([0-9-]*\).*/\1/p' "$f" 2>/dev/null | head -1)
  if [ -n "$valid_until" ] && [[ "$TODAY" > "$valid_until" ]]; then
    echo "  STALE: $name (expired $valid_until)"
    ISSUES=$((ISSUES + 1))
  fi
done
[ "$ISSUES" -eq 0 ] && echo "  All pages current."

# 2. Check orphans (pages not referenced in INDEX.md)
echo ""
echo "── Orphan Check ──"
ORPHANS=0
for f in "$WIKI_DIR"/decisions/*.md "$WIKI_DIR"/preferences/*.md; do
  [ -f "$f" ] || continue
  name=$(basename "$f" .md)
  if ! grep -q "$name" "$WIKI_DIR/INDEX.md" 2>/dev/null; then
    echo "  ORPHAN: $name (not in INDEX.md)"
    ORPHANS=$((ORPHANS + 1))
    ISSUES=$((ISSUES + 1))
  fi
done
[ "$ORPHANS" -eq 0 ] && echo "  No orphans found."

# 3. Check instinct confidence drift
echo ""
echo "── Instinct Health ──"
for f in "$MEMORY_DIR"/instincts/*.yaml; do
  [ -f "$f" ] || continue
  name=$(sed -n 's/^name:\s*//p' "$f" 2>/dev/null | head -1)
  [ -z "$name" ] && name=$(basename "$f" .yaml)
  confidence=$(sed -n 's/^confidence:\s*//p' "$f" 2>/dev/null | head -1)
  [ -z "$confidence" ] && confidence="0"
  status=$(sed -n 's/^status:\s*//p' "$f" 2>/dev/null | head -1)
  [ -z "$status" ] && status="unknown"
  echo "  $name: confidence=$confidence status=$status"
done

# 4. Summary
echo ""
echo "═══════════════════════════════════════"
if [ "$ISSUES" -eq 0 ]; then
  echo "  Clean: 0 issues found"
else
  echo "  Found $ISSUES issue(s) — review and fix"
fi
echo "═══════════════════════════════════════"

exit 0
