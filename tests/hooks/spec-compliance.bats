#!/usr/bin/env bats
# Tests for spec-compliance.sh — blocks edits to governed files unless spec was read first
# Event: PreToolUse (Edit|Write)

HOOK="$BATS_TEST_DIRNAME/../../.claude/hooks/spec-compliance.sh"
PROJECT_DIR="$BATS_TEST_DIRNAME/../.."

setup() {
  export CLAUDE_PROJECT_DIR="$PROJECT_DIR"
  READS_LOG="/tmp/gos-spec-reads-$(date +%Y%m%d)"
  # Clean read log for isolation
  [ -f "$READS_LOG" ] && cp "$READS_LOG" "$READS_LOG.bak"
  rm -f "$READS_LOG"
}

teardown() {
  READS_LOG="/tmp/gos-spec-reads-$(date +%Y%m%d)"
  rm -f "$READS_LOG"
  [ -f "$READS_LOG.bak" ] && mv "$READS_LOG.bak" "$READS_LOG"
}

make_edit_input() {
  local path="$1"
  echo "{\"tool_name\":\"Edit\",\"tool_input\":{\"file_path\":\"$path\"}}"
}

make_write_input() {
  local path="$1"
  echo "{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$path\",\"content\":\"test\"}}"
}

# --- SHOULD BLOCK: command edit without rubric read ---

@test "blocks editing commands/build.md without reading rubric" {
  run bash -c "echo '{\"tool_name\":\"Edit\",\"tool_input\":{\"file_path\":\"$PROJECT_DIR/commands/build.md\"}}' | bash '$HOOK'"
  [ "$status" -eq 2 ]
  [[ "$output" == *"BLOCKED"* ]]
  [[ "$output" == *"rubric"* || "$output" == *"Read"* ]]
}

@test "blocks editing commands/think.md without reading rubric" {
  run bash -c "echo '{\"tool_name\":\"Edit\",\"tool_input\":{\"file_path\":\"$PROJECT_DIR/commands/think.md\"}}' | bash '$HOOK'"
  [ "$status" -eq 2 ]
  [[ "$output" == *"BLOCKED"* ]]
}

@test "blocks Write to commands/review.md without reading rubric" {
  run bash -c "echo '{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$PROJECT_DIR/commands/review.md\"}}' | bash '$HOOK'"
  [ "$status" -eq 2 ]
}

# --- SHOULD BLOCK: hook edit without test read ---

@test "blocks editing hooks/delete-guard.sh without reading test" {
  run bash -c "echo '{\"tool_name\":\"Edit\",\"tool_input\":{\"file_path\":\"$PROJECT_DIR/.claude/hooks/delete-guard.sh\"}}' | bash '$HOOK'"
  [ "$status" -eq 2 ]
  [[ "$output" == *"BLOCKED"* ]]
  [[ "$output" == *"delete-guard.bats"* || "$output" == *"Read"* ]]
}

# --- SHOULD ALLOW: after reading spec ---

@test "allows editing commands/build.md after reading rubric" {
  READS_LOG="/tmp/gos-spec-reads-$(date +%Y%m%d)"
  echo "build.md" > "$READS_LOG"
  run bash -c "echo '{\"tool_name\":\"Edit\",\"tool_input\":{\"file_path\":\"$PROJECT_DIR/commands/build.md\"}}' | bash '$HOOK'"
  [ "$status" -eq 0 ]
}

@test "allows editing hooks/delete-guard.sh after reading test" {
  READS_LOG="/tmp/gos-spec-reads-$(date +%Y%m%d)"
  echo "delete-guard.bats" > "$READS_LOG"
  run bash -c "echo '{\"tool_name\":\"Edit\",\"tool_input\":{\"file_path\":\"$PROJECT_DIR/.claude/hooks/delete-guard.sh\"}}' | bash '$HOOK'"
  [ "$status" -eq 0 ]
}

# --- SHOULD ALLOW: ungoverned files ---

@test "allows editing files without governing spec" {
  run bash -c "echo '{\"tool_name\":\"Edit\",\"tool_input\":{\"file_path\":\"/tmp/random-file.md\"}}' | bash '$HOOK'"
  [ "$status" -eq 0 ]
}

@test "allows editing commands with no rubric" {
  # Assumes there's no rubric for a non-existent command
  run bash -c "echo '{\"tool_name\":\"Edit\",\"tool_input\":{\"file_path\":\"$PROJECT_DIR/commands/nonexistent-cmd.md\"}}' | bash '$HOOK'"
  [ "$status" -eq 0 ]
}

# --- EDGE CASES ---

@test "ignores non-Edit/Write tools" {
  run bash -c "echo '{\"tool_name\":\"Read\",\"tool_input\":{\"file_path\":\"$PROJECT_DIR/commands/build.md\"}}' | bash '$HOOK'"
  [ "$status" -eq 0 ]
}

@test "ignores empty file_path" {
  run bash -c "echo '{\"tool_name\":\"Edit\",\"tool_input\":{\"file_path\":\"\"}}' | bash '$HOOK'"
  [ "$status" -eq 0 ]
}
