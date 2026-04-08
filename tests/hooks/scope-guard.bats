#!/usr/bin/env bats
# Tests for scope-guard.sh — enforces /gos freeze scope

HOOK="$BATS_TEST_DIRNAME/../../.claude/hooks/scope-guard.sh"
FREEZE_FILE="/tmp/claude-freeze-scope"

setup() {
  export TEST_DIR=$(mktemp -d)
  mkdir -p "$TEST_DIR/specs" "$TEST_DIR/src"
}

teardown() {
  rm -f "$FREEZE_FILE"
  rm -rf "$TEST_DIR"
}

@test "blocks edit outside frozen directory" {
  echo "$TEST_DIR/specs" > "$FREEZE_FILE"
  result=$(echo "{\"tool_name\":\"Edit\",\"tool_input\":{\"file_path\":\"$TEST_DIR/src/app.ts\"}}" | bash "$HOOK" 2>&1) || status=$?
  [ "$status" -eq 2 ]
  [[ "$result" == *"FROZEN"* ]]
}

@test "allows edit inside frozen directory" {
  echo "$TEST_DIR/specs" > "$FREEZE_FILE"
  result=$(echo "{\"tool_name\":\"Edit\",\"tool_input\":{\"file_path\":\"$TEST_DIR/specs/test.md\"}}" | bash "$HOOK" 2>&1)
  status=$?
  [ "$status" -eq 0 ]
}

@test "allows everything when no freeze active" {
  rm -f "$FREEZE_FILE"
  result=$(echo "{\"tool_name\":\"Edit\",\"tool_input\":{\"file_path\":\"/any/path.txt\"}}" | bash "$HOOK" 2>&1)
  status=$?
  [ "$status" -eq 0 ]
}

@test "works with Write tool too" {
  echo "$TEST_DIR/specs" > "$FREEZE_FILE"
  result=$(echo "{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$TEST_DIR/src/new.ts\"}}" | bash "$HOOK" 2>&1) || status=$?
  [ "$status" -eq 2 ]
}

@test "ignores non-Edit/Write tools" {
  echo "$TEST_DIR/specs" > "$FREEZE_FILE"
  result=$(echo "{\"tool_name\":\"Read\",\"tool_input\":{\"file_path\":\"$TEST_DIR/src/app.ts\"}}" | bash "$HOOK" 2>&1)
  status=$?
  [ "$status" -eq 0 ]
}
