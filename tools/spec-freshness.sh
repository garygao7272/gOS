#!/usr/bin/env bash
# gOS Spec Freshness Checker — detects stale refs, broken cross-links, orphaned specs
# Usage: ./tools/spec-freshness.sh [specs-dir]
# Returns: list of issues found, exit 0 if clean, exit 1 if issues
set -euo pipefail

SPECS_DIR="${1:-${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}/specs}"
PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
ISSUES=()
WARNINGS=()

[ -d "$SPECS_DIR" ] || { echo "Specs directory not found: $SPECS_DIR" >&2; exit 1; }

# --- 1. Broken cross-references ---
# Find all internal references to other spec files (patterns: Arx_X-X, specs/X, see X.md)
for spec_file in "$SPECS_DIR"/*.md; do
  [ -f "$spec_file" ] || continue
  basename_file=$(basename "$spec_file")

  # Find references to other Arx_ specs
  while IFS= read -r ref; do
    # Extract the spec ID (e.g., Arx_4-1-1-0)
    spec_id=$(echo "$ref" | grep -oP 'Arx_[\d]+-[\d]+[-\d]*' | head -1) || continue
    [ -n "$spec_id" ] || continue

    # Check if a file matching this spec ID exists
    if ! ls "$SPECS_DIR"/${spec_id}*.md >/dev/null 2>&1; then
      # Also check common locations
      if ! find "$PROJECT_DIR" -name "${spec_id}*.md" -maxdepth 3 2>/dev/null | grep -q .; then
        ISSUES+=("BROKEN REF: $basename_file references $spec_id — file not found")
      fi
    fi
  done < <(grep -oP 'Arx_[\d]+-[\d]+[-\d]*[_\w]*' "$spec_file" 2>/dev/null | sort -u || true)
done

# --- 2. File path references that don't exist ---
for spec_file in "$SPECS_DIR"/*.md; do
  [ -f "$spec_file" ] || continue
  basename_file=$(basename "$spec_file")

  # Find backtick-quoted file paths
  while IFS= read -r path_ref; do
    # Skip common patterns that aren't real paths
    case "$path_ref" in
      http*|*.example.*|*.test.*|*\$*|*\{*|*.json|*.yaml|*.yml) continue ;;
    esac

    # Check if path exists relative to project root
    if [ -n "$path_ref" ] && [[ "$path_ref" == */* ]] && [ ! -e "$PROJECT_DIR/$path_ref" ]; then
      WARNINGS+=("STALE PATH: $basename_file references \`$path_ref\` — not found")
    fi
  done < <(grep -oP '`([a-zA-Z][\w\-./]+/[\w\-./]+\.\w+)`' "$spec_file" 2>/dev/null | tr -d '`' | sort -u || true)
done

# --- 3. Orphan detection (specs not referenced by any other spec or command) ---
for spec_file in "$SPECS_DIR"/*.md; do
  [ -f "$spec_file" ] || continue
  basename_file=$(basename "$spec_file")
  name_no_ext=$(basename "$spec_file" .md)

  # Skip meta files
  case "$basename_file" in
    INDEX.md|README.md|handoff-schemas.md|gOS_evolution_roadmap.md) continue ;;
  esac

  # Search for references in other specs and commands
  ref_count=$(grep -rl "$name_no_ext" "$SPECS_DIR" "$PROJECT_DIR/commands" 2>/dev/null | grep -v "$spec_file" | wc -l | tr -d ' ') || ref_count=0

  if [ "$ref_count" -eq 0 ]; then
    WARNINGS+=("ORPHAN: $basename_file is not referenced by any other spec or command")
  fi
done

# --- 4. Age check (specs not modified in 30+ days) ---
THIRTY_DAYS_AGO=$(date -v-30d +%s 2>/dev/null || date -d "30 days ago" +%s 2>/dev/null || echo 0)
if [ "$THIRTY_DAYS_AGO" -gt 0 ]; then
  for spec_file in "$SPECS_DIR"/*.md; do
    [ -f "$spec_file" ] || continue
    basename_file=$(basename "$spec_file")
    file_mtime=$(stat -f %m "$spec_file" 2>/dev/null || stat -c %Y "$spec_file" 2>/dev/null || echo 0)
    if [ "$file_mtime" -lt "$THIRTY_DAYS_AGO" ] && [ "$file_mtime" -gt 0 ]; then
      days_old=$(( ($(date +%s) - file_mtime) / 86400 ))
      WARNINGS+=("STALE: $basename_file last modified ${days_old} days ago")
    fi
  done
fi

# --- Output ---
echo "=== Spec Freshness Check ==="
echo "Scanned: $(ls "$SPECS_DIR"/*.md 2>/dev/null | wc -l | tr -d ' ') specs in $SPECS_DIR"
echo ""

if [ ${#ISSUES[@]} -eq 0 ] && [ ${#WARNINGS[@]} -eq 0 ]; then
  echo "All clean — no issues found."
  exit 0
fi

if [ ${#ISSUES[@]} -gt 0 ]; then
  echo "ISSUES (${#ISSUES[@]}):"
  for issue in "${ISSUES[@]}"; do
    echo "  - $issue"
  done
  echo ""
fi

if [ ${#WARNINGS[@]} -gt 0 ]; then
  echo "WARNINGS (${#WARNINGS[@]}):"
  for warning in "${WARNINGS[@]}"; do
    echo "  - $warning"
  done
  echo ""
fi

echo "Total: ${#ISSUES[@]} issues, ${#WARNINGS[@]} warnings"
[ ${#ISSUES[@]} -eq 0 ] || exit 1
