#!/usr/bin/env bash
# validate-doc-type.sh — enforces rules/common/output-discipline.md §6.8 at
# handoff time. Commands call this before writing their handoff JSON so that
# downstream verbs (/design, /build) never consume mis-shaped upstream output.
#
# Usage:
#   tools/validate-doc-type.sh <artifact-path> [expected-doc-type]
#
# Exit codes:
#   0  artifact has valid doc-type frontmatter and first three H2s match the
#      §6.8 ordering keywords for that type
#   2  artifact is missing frontmatter, has wrong doc-type, or H2s drift from
#      expected ordering — caller must refuse the handoff
#   3  usage error (missing argument, file not found)
#
# Shares ordering logic with tests/hooks/artifact-discipline.bats. When the bats
# ordering keywords change, change them here too — both files reference the
# same §6.8 keyword table.

set -euo pipefail

FILE="${1:-}"
EXPECTED="${2:-}"

if [ -z "$FILE" ]; then
  echo "usage: validate-doc-type.sh <artifact-path> [expected-doc-type]" >&2
  exit 3
fi

if [ ! -f "$FILE" ]; then
  echo "validate-doc-type: file not found: $FILE" >&2
  exit 3
fi

# Extract doc-type from frontmatter (between first two --- lines)
DECLARED=$(awk 'NR==1 && /^---$/{fm=1; next} fm && /^---$/{exit} fm && /^doc-type:/{sub(/^doc-type:[[:space:]]*/,""); print; exit}' "$FILE" || true)

if [ -z "$DECLARED" ]; then
  echo "validate-doc-type: FAIL — no doc-type: frontmatter in $FILE" >&2
  echo "  fix: add YAML frontmatter with doc-type, audience, reader-output" >&2
  exit 2
fi

# If caller supplied an expected doc-type, enforce match
if [ -n "$EXPECTED" ] && [ "$DECLARED" != "$EXPECTED" ]; then
  echo "validate-doc-type: FAIL — declared doc-type '$DECLARED' does not match expected '$EXPECTED' in $FILE" >&2
  exit 2
fi

# Require audience + reader-output fields for handoff validity
for field in audience reader-output; do
  if ! awk 'NR==1 && /^---$/{fm=1; next} fm && /^---$/{exit} fm{print}' "$FILE" | grep -qE "^${field}:"; then
    echo "validate-doc-type: FAIL — missing '${field}:' in frontmatter of $FILE" >&2
    exit 2
  fi
done

# Extract first three H2s
H2S=$(grep -m3 '^## ' "$FILE" | tr '\n' '|')

if [ -z "$H2S" ]; then
  echo "validate-doc-type: FAIL — no H2 headings found in $FILE" >&2
  exit 2
fi

# Check ordering keywords per §6.8 doc-type table (must match bats helper)
check_ordering() {
  local doc_type="$1"
  local h2s="$2"
  case "$doc_type" in
    research-memo|research_memo)
      echo "$h2s" | grep -qiE '(finding|result|verdict|tldr|summary)'
      ;;
    discovery)
      echo "$h2s" | grep -qiE '(problem|why|pain|gap|opportunity)'
      ;;
    product-spec|product_spec)
      echo "$h2s" | grep -qiE '(scope|boundar|what|atoms|primitive)'
      ;;
    design-spec|design_spec)
      echo "$h2s" | grep -qiE '(surface|screen|interaction|what|state)'
      ;;
    decision-record|decision_record)
      echo "$h2s" | grep -qiE '(context|why|problem|decision|rationale)'
      ;;
    build-card|build_card)
      echo "$h2s" | grep -qiE '(change|what|scope|done|acceptance)'
      ;;
    strategy)
      echo "$h2s" | grep -qiE '(why|now|game|moment|context)'
      ;;
    *)
      return 1
      ;;
  esac
}

if ! check_ordering "$DECLARED" "$H2S"; then
  echo "validate-doc-type: FAIL — first three H2s do not match §6.8 ordering for doc-type '$DECLARED' in $FILE" >&2
  echo "  first H2s found: ${H2S//|/ | }" >&2
  echo "  see rules/common/output-discipline.md §6.8 for expected keywords" >&2
  exit 2
fi

echo "validate-doc-type: OK — $FILE is $DECLARED with correct §6.8 ordering"
exit 0
