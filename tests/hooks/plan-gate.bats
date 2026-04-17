#!/usr/bin/env bats
# Tests for plan-gate.sh + plan-gate-prompt.sh
# Hard-enforces plan mode for /build, /design, /think, /refine, /simulate,
# /review (non-dashboard), /ship (non-commit/docs), /evolve upgrade.

PREHOOK="$BATS_TEST_DIRNAME/../../.claude/hooks/plan-gate-prompt.sh"
GATE="$BATS_TEST_DIRNAME/../../.claude/hooks/plan-gate.sh"

setup() {
  TMPDIR=$(mktemp -d)
  export FAKE_PROJECT="$TMPDIR"
  export CLAUDE_PROJECT_DIR="$FAKE_PROJECT"
  mkdir -p "$FAKE_PROJECT/sessions"
}

teardown() {
  rm -rf "$TMPDIR"
}

prompt_input() {
  printf '{"prompt":"%s","session_id":"test"}' "$1"
}

edit_input() {
  printf '{"tool_name":"Edit","tool_input":{"file_path":"%s"}}' "$1"
}

bash_input() {
  printf '{"tool_name":"Bash","tool_input":{"command":"%s"}}' "$1"
}

# ─── UserPromptSubmit — opening the gate ────────────────────────────────────

@test "opens gate when prompt is /build feature" {
  run bash -c "echo '$(prompt_input "/build feature login-screen")' | bash '$PREHOOK'"
  [ "$status" -eq 0 ]
  [[ "$output" == *"Plan Gate OPENED"* ]]
  grep -q "STATE: pending" "$FAKE_PROJECT/sessions/scratchpad.md"
  grep -q "REQUIRED: /build feature" "$FAKE_PROJECT/sessions/scratchpad.md"
}

@test "opens gate when prompt is /design card" {
  run bash -c "echo '$(prompt_input "/design card trade-entry")' | bash '$PREHOOK'"
  [ "$status" -eq 0 ]
  grep -q "STATE: pending" "$FAKE_PROJECT/sessions/scratchpad.md"
}

@test "opens gate when prompt is /review council" {
  run bash -c "echo '$(prompt_input "/review council auth-flow")' | bash '$PREHOOK'"
  [ "$status" -eq 0 ]
  grep -q "STATE: pending" "$FAKE_PROJECT/sessions/scratchpad.md"
}

@test "does NOT open gate for /review dashboard" {
  run bash -c "echo '$(prompt_input "/review dashboard")' | bash '$PREHOOK'"
  [ "$status" -eq 0 ]
  if [ -f "$FAKE_PROJECT/sessions/scratchpad.md" ]; then
    ! grep -q "STATE: pending" "$FAKE_PROJECT/sessions/scratchpad.md"
  fi
}

@test "does NOT open gate for /ship commit" {
  run bash -c "echo '$(prompt_input "/ship commit")' | bash '$PREHOOK'"
  [ "$status" -eq 0 ]
  if [ -f "$FAKE_PROJECT/sessions/scratchpad.md" ]; then
    ! grep -q "STATE: pending" "$FAKE_PROJECT/sessions/scratchpad.md"
  fi
}

@test "does NOT open gate for /save" {
  run bash -c "echo '$(prompt_input "/save")' | bash '$PREHOOK'"
  [ "$status" -eq 0 ]
  if [ -f "$FAKE_PROJECT/sessions/scratchpad.md" ]; then
    ! grep -q "STATE: pending" "$FAKE_PROJECT/sessions/scratchpad.md"
  fi
}

@test "opens gate for /ship deploy" {
  run bash -c "echo '$(prompt_input "/ship deploy")' | bash '$PREHOOK'"
  [ "$status" -eq 0 ]
  grep -q "STATE: pending" "$FAKE_PROJECT/sessions/scratchpad.md"
}

@test "opens gate for /evolve upgrade but NOT /evolve audit" {
  bash -c "echo '$(prompt_input "/evolve upgrade think")' | bash '$PREHOOK'" >/dev/null
  grep -q "STATE: pending" "$FAKE_PROJECT/sessions/scratchpad.md"

  rm -f "$FAKE_PROJECT/sessions/scratchpad.md"
  run bash -c "echo '$(prompt_input "/evolve audit")' | bash '$PREHOOK'"
  [ "$status" -eq 0 ]
  if [ -f "$FAKE_PROJECT/sessions/scratchpad.md" ]; then
    ! grep -q "STATE: pending" "$FAKE_PROJECT/sessions/scratchpad.md"
  fi
}

# ─── UserPromptSubmit — approval + bypass flipping ──────────────────────────

@test "approval token 'yes' flips STATE to approved" {
  bash -c "echo '$(prompt_input "/build feature login")' | bash '$PREHOOK'" >/dev/null
  grep -q "STATE: pending" "$FAKE_PROJECT/sessions/scratchpad.md"

  run bash -c "echo '$(prompt_input "yes")' | bash '$PREHOOK'"
  [ "$status" -eq 0 ]
  [[ "$output" == *"Plan Gate APPROVED"* ]]
  grep -qE "STATE: approved-[0-9]+" "$FAKE_PROJECT/sessions/scratchpad.md"
}

@test "approval token 'go' flips STATE to approved" {
  bash -c "echo '$(prompt_input "/design card home")' | bash '$PREHOOK'" >/dev/null
  bash -c "echo '$(prompt_input "go")' | bash '$PREHOOK'" >/dev/null
  grep -qE "STATE: approved-[0-9]+" "$FAKE_PROJECT/sessions/scratchpad.md"
}

@test "bypass token 'just do it' flips STATE to bypassed" {
  bash -c "echo '$(prompt_input "/build feature foo")' | bash '$PREHOOK'" >/dev/null
  run bash -c "echo '$(prompt_input "just do it")' | bash '$PREHOOK'"
  [ "$status" -eq 0 ]
  [[ "$output" == *"Plan Gate BYPASSED"* ]]
  grep -qE "STATE: bypassed-[0-9]+" "$FAKE_PROJECT/sessions/scratchpad.md"
}

@test "longer reply without 'plan approved' does NOT flip state" {
  bash -c "echo '$(prompt_input "/build feature foo")' | bash '$PREHOOK'" >/dev/null
  bash -c "echo '$(prompt_input "yes but change the approach to use typescript")' | bash '$PREHOOK'" >/dev/null
  grep -q "STATE: pending" "$FAKE_PROJECT/sessions/scratchpad.md"
}

# ─── PreToolUse — blocking behavior ─────────────────────────────────────────

@test "plan-gate BLOCKS Edit when STATE=pending" {
  bash -c "echo '$(prompt_input "/build feature foo")' | bash '$PREHOOK'" >/dev/null
  run bash -c "echo '$(edit_input "/some/file.ts")' | bash '$GATE' 2>&1"
  [ "$status" -eq 2 ]
  [[ "$output" == *"PLAN GATE: blocked"* ]]
}

@test "plan-gate ALLOWS Edit when STATE=approved" {
  bash -c "echo '$(prompt_input "/build feature foo")' | bash '$PREHOOK'" >/dev/null
  bash -c "echo '$(prompt_input "yes")' | bash '$PREHOOK'" >/dev/null
  run bash -c "echo '$(edit_input "/some/file.ts")' | bash '$GATE' 2>&1"
  [ "$status" -eq 0 ]
}

@test "plan-gate ALLOWS Edit when STATE=bypassed" {
  bash -c "echo '$(prompt_input "/build feature foo")' | bash '$PREHOOK'" >/dev/null
  bash -c "echo '$(prompt_input "just do it")' | bash '$PREHOOK'" >/dev/null
  run bash -c "echo '$(edit_input "/some/file.ts")' | bash '$GATE' 2>&1"
  [ "$status" -eq 0 ]
}

@test "plan-gate ALLOWS Edit when no Plan Gate section present" {
  run bash -c "echo '$(edit_input "/some/file.ts")' | bash '$GATE' 2>&1"
  [ "$status" -eq 0 ]
}

@test "plan-gate BLOCKS Bash git commit when STATE=pending" {
  bash -c "echo '$(prompt_input "/ship deploy")' | bash '$PREHOOK'" >/dev/null
  run bash -c "echo '$(bash_input "git commit -m test")' | bash '$GATE' 2>&1"
  [ "$status" -eq 2 ]
}

@test "plan-gate IGNORES Bash non-git commands even when pending" {
  bash -c "echo '$(prompt_input "/build feature foo")' | bash '$PREHOOK'" >/dev/null
  run bash -c "echo '$(bash_input "ls -la")' | bash '$GATE' 2>&1"
  [ "$status" -eq 0 ]
}

@test "plan-gate IGNORES non-Edit, non-Write, non-Bash tools" {
  bash -c "echo '$(prompt_input "/build feature foo")' | bash '$PREHOOK'" >/dev/null
  run bash -c "echo '{\"tool_name\":\"Read\",\"tool_input\":{\"file_path\":\"/x\"}}' | bash '$GATE' 2>&1"
  [ "$status" -eq 0 ]
}
