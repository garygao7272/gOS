#!/usr/bin/env bats
# Tests for phase-gate.sh — hard gate: /design requires /think output, /build requires /design output
# Event: PreToolUse (Edit|Write)
# Phase chain: think → design → build (each requires prior phase's artifact)

HOOK="$BATS_TEST_DIRNAME/../../.claude/hooks/phase-gate.sh"
PROJECT_DIR="$BATS_TEST_DIRNAME/../.."

setup() {
  export CLAUDE_PROJECT_DIR="$PROJECT_DIR"
  SCRATCHPAD="$PROJECT_DIR/sessions/scratchpad.md"
  HANDOFFS_DIR="$PROJECT_DIR/sessions/handoffs"
  # Backup real scratchpad
  [ -f "$SCRATCHPAD" ] && cp "$SCRATCHPAD" "$SCRATCHPAD.bak" || true
  # Clean handoffs for isolation
  [ -d "$HANDOFFS_DIR" ] && cp -r "$HANDOFFS_DIR" "$HANDOFFS_DIR.bak" || true
  rm -rf "$HANDOFFS_DIR"
  mkdir -p "$HANDOFFS_DIR"
}

teardown() {
  SCRATCHPAD="$PROJECT_DIR/sessions/scratchpad.md"
  HANDOFFS_DIR="$PROJECT_DIR/sessions/handoffs"
  # Restore backups
  [ -f "$SCRATCHPAD.bak" ] && mv "$SCRATCHPAD.bak" "$SCRATCHPAD" || true
  rm -rf "$HANDOFFS_DIR"
  [ -d "$HANDOFFS_DIR.bak" ] && mv "$HANDOFFS_DIR.bak" "$HANDOFFS_DIR" || true
}

write_mode() {
  local mode="$1"
  cat > "$PROJECT_DIR/sessions/scratchpad.md" << EOF
# Session Scratchpad

## Mode & Sub-command
$mode
EOF
}

make_edit_input() {
  echo "{\"tool_name\":\"Edit\",\"tool_input\":{\"file_path\":\"/tmp/test.md\"}}"
}

# --- /design BLOCKED without /think handoff ---

@test "blocks /design when no think handoff exists" {
  write_mode "gOS > /design card"
  run bash -c "echo '{\"tool_name\":\"Edit\",\"tool_input\":{\"file_path\":\"/tmp/test.md\"}}' | bash '$HOOK'"
  [ "$status" -eq 2 ]
  [[ "$output" == *"PHASE GATE"* ]]
  [[ "$output" == *"think"* ]]
}

# --- /build BLOCKED without /design handoff ---

@test "blocks /build when no design handoff exists" {
  write_mode "gOS > /build feature"
  run bash -c "echo '{\"tool_name\":\"Edit\",\"tool_input\":{\"file_path\":\"/tmp/test.md\"}}' | bash '$HOOK'"
  [ "$status" -eq 2 ]
  [[ "$output" == *"PHASE GATE"* ]]
  [[ "$output" == *"design"* ]]
}

# --- /design ALLOWED with /think handoff ---

@test "allows /design when think handoff exists" {
  write_mode "gOS > /design card"
  echo '{"phase":"think","output":"specs/test.md","approved":true}' > "$HANDOFFS_DIR/think.json"
  run bash -c "echo '{\"tool_name\":\"Edit\",\"tool_input\":{\"file_path\":\"/tmp/test.md\"}}' | bash '$HOOK'"
  [ "$status" -eq 0 ]
}

# --- /build ALLOWED with /design handoff ---

@test "allows /build when design handoff exists" {
  write_mode "gOS > /build feature"
  echo '{"phase":"design","output":"outputs/design/card.md","approved":true}' > "$HANDOFFS_DIR/design.json"
  run bash -c "echo '{\"tool_name\":\"Edit\",\"tool_input\":{\"file_path\":\"/tmp/test.md\"}}' | bash '$HOOK'"
  [ "$status" -eq 0 ]
}

# --- /think ALWAYS allowed (first phase) ---

@test "allows /think without any prior handoff" {
  write_mode "gOS > /think research"
  run bash -c "echo '{\"tool_name\":\"Edit\",\"tool_input\":{\"file_path\":\"/tmp/test.md\"}}' | bash '$HOOK'"
  [ "$status" -eq 0 ]
}

# --- Non-gated modes pass through ---

@test "allows /ship without handoff check" {
  write_mode "gOS > /ship commit"
  run bash -c "echo '{\"tool_name\":\"Edit\",\"tool_input\":{\"file_path\":\"/tmp/test.md\"}}' | bash '$HOOK'"
  [ "$status" -eq 0 ]
}

@test "allows /review without handoff check" {
  write_mode "gOS > /review code"
  run bash -c "echo '{\"tool_name\":\"Edit\",\"tool_input\":{\"file_path\":\"/tmp/test.md\"}}' | bash '$HOOK'"
  [ "$status" -eq 0 ]
}

@test "allows /evolve without handoff check" {
  write_mode "gOS > /evolve audit"
  run bash -c "echo '{\"tool_name\":\"Edit\",\"tool_input\":{\"file_path\":\"/tmp/test.md\"}}' | bash '$HOOK'"
  [ "$status" -eq 0 ]
}

# --- Edge cases ---

@test "exits cleanly when no scratchpad exists" {
  rm -f "$PROJECT_DIR/sessions/scratchpad.md"
  run bash -c "echo '{\"tool_name\":\"Edit\",\"tool_input\":{\"file_path\":\"/tmp/test.md\"}}' | bash '$HOOK'"
  [ "$status" -eq 0 ]
}

@test "exits cleanly when mode is empty" {
  write_mode ""
  run bash -c "echo '{\"tool_name\":\"Edit\",\"tool_input\":{\"file_path\":\"/tmp/test.md\"}}' | bash '$HOOK'"
  [ "$status" -eq 0 ]
}

@test "ignores non-Edit/Write tools" {
  write_mode "gOS > /build feature"
  run bash -c "echo '{\"tool_name\":\"Read\",\"tool_input\":{\"file_path\":\"/tmp/test.md\"}}' | bash '$HOOK'"
  [ "$status" -eq 0 ]
}

# --- Bypass: explicit PHASE_GATE_SKIP ---

@test "allows bypass with PHASE_GATE_SKIP in scratchpad" {
  write_mode "gOS > /build feature"
  echo "PHASE_GATE_SKIP" >> "$PROJECT_DIR/sessions/scratchpad.md"
  run bash -c "echo '{\"tool_name\":\"Edit\",\"tool_input\":{\"file_path\":\"/tmp/test.md\"}}' | bash '$HOOK'"
  [ "$status" -eq 0 ]
}
