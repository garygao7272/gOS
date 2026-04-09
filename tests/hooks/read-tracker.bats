#!/usr/bin/env bats
# Tests for read-tracker.sh — logs when governed specs (rubrics, test files) are read
# Event: PreToolUse (Read)

HOOK="$BATS_TEST_DIRNAME/../../.claude/hooks/read-tracker.sh"

setup() {
  READS_LOG="/tmp/gos-spec-reads-$(date +%Y%m%d)"
  [ -f "$READS_LOG" ] && cp "$READS_LOG" "$READS_LOG.bak"
  rm -f "$READS_LOG"
}

teardown() {
  READS_LOG="/tmp/gos-spec-reads-$(date +%Y%m%d)"
  rm -f "$READS_LOG"
  [ -f "$READS_LOG.bak" ] && mv "$READS_LOG.bak" "$READS_LOG"
}

make_read_input() {
  local path="$1"
  echo "{\"tool_name\":\"Read\",\"tool_input\":{\"file_path\":\"$path\"}}"
}

# --- SHOULD TRACK ---

@test "tracks rubric reads" {
  READS_LOG="/tmp/gos-spec-reads-$(date +%Y%m%d)"
  run bash -c "echo '{\"tool_name\":\"Read\",\"tool_input\":{\"file_path\":\"/some/path/evals/rubrics/build.md\"}}' | bash '$HOOK'"
  [ "$status" -eq 0 ]
  [ -f "$READS_LOG" ]
  grep -q "build.md" "$READS_LOG"
}

@test "tracks test file reads" {
  READS_LOG="/tmp/gos-spec-reads-$(date +%Y%m%d)"
  run bash -c "echo '{\"tool_name\":\"Read\",\"tool_input\":{\"file_path\":\"/some/path/tests/hooks/delete-guard.bats\"}}' | bash '$HOOK'"
  [ "$status" -eq 0 ]
  [ -f "$READS_LOG" ]
  grep -q "delete-guard.bats" "$READS_LOG"
}

@test "accumulates multiple reads" {
  READS_LOG="/tmp/gos-spec-reads-$(date +%Y%m%d)"
  echo '{"tool_name":"Read","tool_input":{"file_path":"/a/evals/rubrics/build.md"}}' | bash "$HOOK"
  echo '{"tool_name":"Read","tool_input":{"file_path":"/a/evals/rubrics/think.md"}}' | bash "$HOOK"
  [ "$(wc -l < "$READS_LOG")" -ge 2 ]
  grep -q "build.md" "$READS_LOG"
  grep -q "think.md" "$READS_LOG"
}

# --- SHOULD NOT TRACK ---

@test "does not track non-rubric reads" {
  READS_LOG="/tmp/gos-spec-reads-$(date +%Y%m%d)"
  run bash -c "echo '{\"tool_name\":\"Read\",\"tool_input\":{\"file_path\":\"/some/random/file.md\"}}' | bash '$HOOK'"
  [ "$status" -eq 0 ]
  ! [ -f "$READS_LOG" ] || ! grep -q "file.md" "$READS_LOG"
}

# --- EDGE CASES ---

@test "ignores non-Read tools" {
  run bash -c "echo '{\"tool_name\":\"Edit\",\"tool_input\":{\"file_path\":\"/a/evals/rubrics/build.md\"}}' | bash '$HOOK'"
  [ "$status" -eq 0 ]
  READS_LOG="/tmp/gos-spec-reads-$(date +%Y%m%d)"
  ! [ -f "$READS_LOG" ] || ! grep -q "build.md" "$READS_LOG"
}

@test "handles empty file_path gracefully" {
  run bash -c "echo '{\"tool_name\":\"Read\",\"tool_input\":{\"file_path\":\"\"}}' | bash '$HOOK'"
  [ "$status" -eq 0 ]
}
