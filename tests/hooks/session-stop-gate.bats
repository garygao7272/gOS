#!/usr/bin/env bats
# Tests for session-stop-gate.sh — decides when to fire the persist pass.
# Regression guard for commit f75d4d6 (infinite Stop-loop caused by
# prompt-type hook re-prompting Claude). Must stay SILENT unless triggered.

HOOK="$BATS_TEST_DIRNAME/../../.claude/hooks/session-stop-gate.sh"

setup() {
  TMPDIR=$(mktemp -d)
  export FAKE_PROJECT="$TMPDIR"
  mkdir -p "$FAKE_PROJECT/sessions"
  export CLAUDE_PROJECT_DIR="$FAKE_PROJECT"
}

teardown() {
  rm -rf "$TMPDIR"
}

@test "silent exit when sessions/ dir does not exist" {
  rm -rf "$FAKE_PROJECT/sessions"
  run bash "$HOOK"
  [ "$status" -eq 0 ]
  [ -z "$output" ]
}

@test "silent exit when scratchpad has no Mode trigger and timestamp is fresh" {
  date +%s > "$FAKE_PROJECT/sessions/.scratchpad_timestamp"
  printf '## Mode\nnormal\n' > "$FAKE_PROJECT/sessions/scratchpad.md"
  run bash "$HOOK"
  [ "$status" -eq 0 ]
  [ -z "$output" ]
}

@test "emits persist directive when Mode line contains /gos save" {
  date +%s > "$FAKE_PROJECT/sessions/.scratchpad_timestamp"
  printf '## Mode\n/gos save\n' > "$FAKE_PROJECT/sessions/scratchpad.md"
  run bash "$HOOK"
  [ "$status" -eq 0 ]
  [[ "$output" == *"persist-trigger=gos-save"* ]]
  [[ "$output" == *"evolve_signals.md"* ]]
}

@test "emits persist directive when timestamp older than 4h (stale-resume)" {
  # 5h ago = 18000s; threshold is 14400s (4h)
  stale=$(( $(date +%s) - 18000 ))
  echo "$stale" > "$FAKE_PROJECT/sessions/.scratchpad_timestamp"
  printf '## Mode\nnormal\n' > "$FAKE_PROJECT/sessions/scratchpad.md"
  run bash "$HOOK"
  [ "$status" -eq 0 ]
  [[ "$output" == *"persist-trigger=stale-resume"* ]]
}

@test "silent exit when timestamp file is missing (treated as fresh)" {
  printf '## Mode\nnormal\n' > "$FAKE_PROJECT/sessions/scratchpad.md"
  run bash "$HOOK"
  [ "$status" -eq 0 ]
  [ -z "$output" ]
}

@test "silent exit when timestamp is non-numeric junk" {
  echo "not-a-number" > "$FAKE_PROJECT/sessions/.scratchpad_timestamp"
  printf '## Mode\nnormal\n' > "$FAKE_PROJECT/sessions/scratchpad.md"
  run bash "$HOOK"
  [ "$status" -eq 0 ]
  [ -z "$output" ]
}
