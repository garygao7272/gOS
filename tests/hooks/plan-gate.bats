#!/usr/bin/env bats
# Tests for plan-gate.sh — blocks edits during /think, /build, /design until plan approved
# Event: PreToolUse (Edit|Write)

HOOK="$BATS_TEST_DIRNAME/../../.claude/hooks/plan-gate.sh"
PROJECT_DIR="$BATS_TEST_DIRNAME/../.."

setup() {
  export CLAUDE_PROJECT_DIR="$PROJECT_DIR"
  SCRATCHPAD="$PROJECT_DIR/sessions/scratchpad.md"
  # Backup real scratchpad
  [ -f "$SCRATCHPAD" ] && cp "$SCRATCHPAD" "$SCRATCHPAD.bak"
}

teardown() {
  SCRATCHPAD="$PROJECT_DIR/sessions/scratchpad.md"
  if [ -f "$SCRATCHPAD.bak" ]; then
    mv "$SCRATCHPAD.bak" "$SCRATCHPAD"
  fi
}

# Helper: write a scratchpad with given mode and optional plan approval
write_scratchpad() {
  local mode="$1"
  local approved="${2:-no}"
  local scratchpad="$PROJECT_DIR/sessions/scratchpad.md"

  cat > "$scratchpad" << EOF
# Session Scratchpad

## Current Task
Test task

## Mode & Sub-command
$mode

## Working State
Testing plan gate
EOF

  if [ "$approved" = "yes" ]; then
    echo "" >> "$scratchpad"
    echo "Plan: APPROVED" >> "$scratchpad"
  fi
}

# --- SHOULD GATE: mode active, no approval ---

@test "gates edits in /build mode without plan approval" {
  write_scratchpad "gOS > /build feature"
  run bash -c "echo '{\"tool_name\":\"Edit\",\"tool_input\":{\"file_path\":\"/tmp/test.md\"}}' | bash '$HOOK'"
  # plan-gate currently exits 0 with warning message (advisory)
  [[ "$output" == *"PLAN GATE"* || "$output" == *"plan"* ]]
}

@test "gates edits in /think mode without plan approval" {
  write_scratchpad "gOS > /think research"
  run bash -c "echo '{\"tool_name\":\"Edit\",\"tool_input\":{\"file_path\":\"/tmp/test.md\"}}' | bash '$HOOK'"
  [[ "$output" == *"PLAN GATE"* || "$output" == *"plan"* ]]
}

@test "gates edits in /design mode without plan approval" {
  write_scratchpad "gOS > /design card"
  run bash -c "echo '{\"tool_name\":\"Edit\",\"tool_input\":{\"file_path\":\"/tmp/test.md\"}}' | bash '$HOOK'"
  [[ "$output" == *"PLAN GATE"* || "$output" == *"plan"* ]]
}

# --- SHOULD ALLOW: plan approved ---

@test "allows edits after plan approval" {
  write_scratchpad "gOS > /build feature" "yes"
  run bash -c "echo '{\"tool_name\":\"Edit\",\"tool_input\":{\"file_path\":\"/tmp/test.md\"}}' | bash '$HOOK'"
  [ "$status" -eq 0 ]
  [[ "$output" != *"PLAN GATE"* ]]
}

# --- SHOULD ALLOW: non-gated modes ---

@test "allows edits in /ship mode (not gated)" {
  write_scratchpad "gOS > /ship commit"
  run bash -c "echo '{\"tool_name\":\"Edit\",\"tool_input\":{\"file_path\":\"/tmp/test.md\"}}' | bash '$HOOK'"
  [ "$status" -eq 0 ]
  [[ "$output" != *"PLAN GATE"* ]]
}

@test "allows edits when no scratchpad mode set" {
  write_scratchpad "(awaiting routing)"
  run bash -c "echo '{\"tool_name\":\"Edit\",\"tool_input\":{\"file_path\":\"/tmp/test.md\"}}' | bash '$HOOK'"
  [ "$status" -eq 0 ]
}

# --- DESIGN-SPECIFIC GATES ---

@test "design gate blocks without state matrix" {
  write_scratchpad "gOS > /design full" "yes"
  export TOOL_INPUT_FILE_PATH="$PROJECT_DIR/outputs/think/design/test-spec.md"
  run bash -c "echo '{\"tool_name\":\"Edit\",\"tool_input\":{\"file_path\":\"$PROJECT_DIR/outputs/think/design/test-spec.md\"}}' | TOOL_INPUT_FILE_PATH='$PROJECT_DIR/outputs/think/design/test-spec.md' bash '$HOOK'"
  [ "$status" -eq 2 ]
  [[ "$output" == *"DESIGN GATE"* || "$output" == *"state matrix"* ]]
}

@test "design gate allows with state matrix in scratchpad" {
  write_scratchpad "gOS > /design full" "yes"
  echo "" >> "$PROJECT_DIR/sessions/scratchpad.md"
  echo "## State Matrix" >> "$PROJECT_DIR/sessions/scratchpad.md"
  echo "## Reference Research" >> "$PROJECT_DIR/sessions/scratchpad.md"
  echo "| State | Journey |" >> "$PROJECT_DIR/sessions/scratchpad.md"
  run bash -c "echo '{\"tool_name\":\"Edit\",\"tool_input\":{\"file_path\":\"$PROJECT_DIR/outputs/think/design/test-spec.md\"}}' | TOOL_INPUT_FILE_PATH='$PROJECT_DIR/outputs/think/design/test-spec.md' bash '$HOOK'"
  [ "$status" -eq 0 ]
}

# --- EDGE CASES ---

@test "exits cleanly when no scratchpad exists" {
  rm -f "$PROJECT_DIR/sessions/scratchpad.md"
  run bash -c "echo '{\"tool_name\":\"Edit\",\"tool_input\":{\"file_path\":\"/tmp/test.md\"}}' | bash '$HOOK'"
  [ "$status" -eq 0 ]
}
