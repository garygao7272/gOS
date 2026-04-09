#!/usr/bin/env bash
# gOS Test Scaffolder — generates BATS skeleton from hook files
# Usage: ./tools/test-scaffold.sh <hook-name>
# Output: tests/hooks/<hook-name>.bats (skeleton with RED stubs)
set -euo pipefail

HOOK_NAME="${1:?Usage: test-scaffold.sh <hook-name>}"
PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
HOOK_FILE="$PROJECT_DIR/.claude/hooks/${HOOK_NAME}.sh"
TEST_FILE="$PROJECT_DIR/tests/hooks/${HOOK_NAME}.bats"

[ -f "$HOOK_FILE" ] || { echo "Hook not found: $HOOK_FILE" >&2; exit 1; }
[ ! -f "$TEST_FILE" ] || { echo "Test already exists: $TEST_FILE" >&2; exit 1; }

# Extract metadata from hook header
EVENT_TYPE=$(head -20 "$HOOK_FILE" | grep -i 'Event:' | head -1 | sed 's/.*Event:\s*//' | tr -d '#')
MATCHER=$(head -20 "$HOOK_FILE" | grep -i 'matcher\|Event:' | head -1 | grep -oP '\(.*?\)' | tr -d '()' || echo "")
PURPOSE=$(head -20 "$HOOK_FILE" | grep -iE '(blocks|checks|logs|tracks|saves|detects|runs|ensures)' | head -1 | sed 's/^#\s*//')

# Determine make_input pattern based on matcher
MAKE_INPUT_FN=""
case "$MATCHER" in
  *Bash*)
    MAKE_INPUT_FN='make_bash_input() {
  local cmd="$1"
  echo "{\"tool_name\":\"Bash\",\"tool_input\":{\"command\":\"$cmd\"}}"
}'
    ;;
  *Edit*|*Write*)
    MAKE_INPUT_FN='make_edit_input() {
  local path="$1"
  echo "{\"tool_name\":\"Edit\",\"tool_input\":{\"file_path\":\"$path\",\"old_string\":\"x\",\"new_string\":\"y\"}}"
}

make_write_input() {
  local path="$1"
  echo "{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$path\",\"content\":\"test\"}}"
}'
    ;;
  *Read*)
    MAKE_INPUT_FN='make_read_input() {
  local path="$1"
  echo "{\"tool_name\":\"Read\",\"tool_input\":{\"file_path\":\"$path\"}}"
}'
    ;;
  *)
    MAKE_INPUT_FN='make_input() {
  local tool="$1" path="$2"
  echo "{\"tool_name\":\"$tool\",\"tool_input\":{\"file_path\":\"$path\"}}"
}'
    ;;
esac

cat > "$TEST_FILE" << BATS
#!/usr/bin/env bats
# Tests for ${HOOK_NAME}.sh — ${PURPOSE:-"(add purpose)"}
# Event: ${EVENT_TYPE:-"(add event type)"}

HOOK="\$BATS_TEST_DIRNAME/../../.claude/hooks/${HOOK_NAME}.sh"

${MAKE_INPUT_FN}

# --- SHOULD BLOCK ---

@test "TODO: blocks expected dangerous input" {
  skip "Scaffold stub — implement this test"
}

# --- SHOULD ALLOW ---

@test "TODO: allows safe input" {
  skip "Scaffold stub — implement this test"
}

# --- EDGE CASES ---

@test "ignores irrelevant tool names" {
  result=\$(echo '{"tool_name":"Glob","tool_input":{}}' | bash "\$HOOK" 2>&1)
  status=\$?
  [ "\$status" -eq 0 ]
}
BATS

chmod +x "$TEST_FILE"
echo "Created: $TEST_FILE"
echo "  Event: ${EVENT_TYPE:-unknown}"
echo "  Matcher: ${MATCHER:-unknown}"
echo "  Stubs: 3 (2 TODO + 1 edge case)"
