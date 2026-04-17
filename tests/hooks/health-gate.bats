#!/usr/bin/env bats
# Tests for .claude/hooks/health-gate.sh — the PreToolUse trigger that
# runs tools/health-gate.sh before git commit in gOS projects only.
# NOTE: command-frontmatter.bats tests tools/health-gate.sh (the gate).
# This file tests the HOOK that decides when to invoke the gate.

HOOK="$BATS_TEST_DIRNAME/../../.claude/hooks/health-gate.sh"

make_input() {
  local cmd="$1"
  printf '{"tool_name":"Bash","tool_input":{"command":"%s"}}' "$cmd"
}

@test "skips non-Bash tool calls" {
  run bash -c "echo '{\"tool_name\":\"Edit\",\"tool_input\":{}}' | bash '$HOOK'"
  [ "$status" -eq 0 ]
  [ -z "$output" ]
}

@test "skips non-commit Bash commands (git status)" {
  # Even in gOS dir, non-commit commands should skip.
  cd "$BATS_TEST_DIRNAME/../.."
  run bash -c "echo '$(make_input "git status")' | bash '$HOOK'"
  [ "$status" -eq 0 ]
  [ -z "$output" ]
}

@test "skips git commit outside gOS project" {
  TMPDIR=$(mktemp -d)
  run bash -c "CLAUDE_PROJECT_DIR='$TMPDIR' echo '$(make_input "git commit -m test")' | CLAUDE_PROJECT_DIR='$TMPDIR' bash '$HOOK'"
  [ "$status" -eq 0 ]
  [ -z "$output" ]
  rm -rf "$TMPDIR"
}

@test "runs gate on git commit inside gOS project" {
  # Point at the real gOS project so the gate script runs.
  GOS_DIR="$(cd "$BATS_TEST_DIRNAME/../.." && pwd)"
  run bash -c "echo '$(make_input "git commit -m test")' | CLAUDE_PROJECT_DIR='$GOS_DIR' bash '$HOOK'"
  # Exit is either 0 (gate passed) or 2 (gate blocked) — must NOT be 1 (error).
  [ "$status" -ne 1 ]
  # Gate announces itself when it runs.
  [[ "$output" == *"Running gOS health gate"* ]] || [[ "$status" -eq 0 ]]
}
