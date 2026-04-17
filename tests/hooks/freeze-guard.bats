#!/usr/bin/env bats
# Tests for freeze-guard.sh — blocks edits outside the frozen scope dir.
# Freeze is activated by writing a path to /tmp/claude-freeze-scope.

HOOK="$BATS_TEST_DIRNAME/../../.claude/hooks/freeze-guard.sh"
FREEZE_FILE="/tmp/claude-freeze-scope"

setup() {
  TMPDIR=$(mktemp -d)
  export FAKE_PROJECT="$TMPDIR"
  mkdir -p "$FAKE_PROJECT/in-scope" "$FAKE_PROJECT/out-of-scope"
  touch "$FAKE_PROJECT/in-scope/a.txt" "$FAKE_PROJECT/out-of-scope/b.txt"
  # Stash any existing freeze file so we don't clobber real state
  if [ -f "$FREEZE_FILE" ]; then
    mv "$FREEZE_FILE" "$FREEZE_FILE.bats-backup"
  fi
}

teardown() {
  rm -f "$FREEZE_FILE"
  if [ -f "$FREEZE_FILE.bats-backup" ]; then
    mv "$FREEZE_FILE.bats-backup" "$FREEZE_FILE"
  fi
  rm -rf "$TMPDIR"
}

make_input() {
  local path="$1"
  printf '{"tool_name":"Edit","tool_input":{"file_path":"%s"}}' "$path"
}

@test "no-op when no freeze file exists" {
  rm -f "$FREEZE_FILE"
  run bash -c "echo '$(make_input "$FAKE_PROJECT/out-of-scope/b.txt")' | bash '$HOOK'"
  [ "$status" -eq 0 ]
  [ -z "$output" ]
}

@test "no-op when freeze file is empty" {
  : > "$FREEZE_FILE"
  run bash -c "echo '$(make_input "$FAKE_PROJECT/in-scope/a.txt")' | bash '$HOOK'"
  [ "$status" -eq 0 ]
  [ -z "$output" ]
}

@test "allows edit inside frozen scope (exit 0, no warning)" {
  echo "$FAKE_PROJECT/in-scope" > "$FREEZE_FILE"
  run bash -c "echo '$(make_input "$FAKE_PROJECT/in-scope/a.txt")' | bash '$HOOK'"
  [ "$status" -eq 0 ]
  [ -z "$output" ]
}

@test "warns on edit outside frozen scope" {
  echo "$FAKE_PROJECT/in-scope" > "$FREEZE_FILE"
  run bash -c "echo '$(make_input "$FAKE_PROJECT/out-of-scope/b.txt")' | bash '$HOOK'"
  [ "$status" -eq 0 ]
  [[ "$output" == *"FROZEN"* ]]
  [[ "$output" == *"/gos freeze off"* ]]
}

@test "no-op when file_path is empty" {
  echo "$FAKE_PROJECT/in-scope" > "$FREEZE_FILE"
  run bash -c "echo '{\"tool_name\":\"Edit\",\"tool_input\":{}}' | bash '$HOOK'"
  [ "$status" -eq 0 ]
  [ -z "$output" ]
}
