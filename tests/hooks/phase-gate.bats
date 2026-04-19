#!/usr/bin/env bats
# Tests for phase-gate.sh — hard gate: /design requires /think output, /build requires /design output
# Event: PreToolUse (Edit|Write)
# Gate narrowed 2026-04-19: fires ONLY on target paths that match
#   specs/Arx_4-2* (design system) → needs /think handoff
#   specs/Arx_4-1* (build cards)   → needs /design handoff
#   apps/*                         → needs /design handoff
# Every other target path is ungated regardless of scratchpad Mode.
# (Root-cause fix for scratchpad-Mode drift firing false blocks on /evolve, /ship.)

HOOK="$BATS_TEST_DIRNAME/../../.claude/hooks/phase-gate.sh"
PROJECT_DIR="$BATS_TEST_DIRNAME/../.."

setup() {
  export CLAUDE_PROJECT_DIR="$PROJECT_DIR"
  SCRATCHPAD="$PROJECT_DIR/sessions/scratchpad.md"
  HANDOFFS_DIR="$PROJECT_DIR/sessions/handoffs"
  [ -f "$SCRATCHPAD" ] && cp "$SCRATCHPAD" "$SCRATCHPAD.bak" || true
  [ -d "$HANDOFFS_DIR" ] && cp -r "$HANDOFFS_DIR" "$HANDOFFS_DIR.bak" || true
  rm -rf "$HANDOFFS_DIR"
  mkdir -p "$HANDOFFS_DIR"
}

teardown() {
  SCRATCHPAD="$PROJECT_DIR/sessions/scratchpad.md"
  HANDOFFS_DIR="$PROJECT_DIR/sessions/handoffs"
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

# Run the hook with a given target file path, via bats `run`.
run_hook() {
  local target="$1"
  run bash -c "echo '{\"tool_name\":\"Edit\",\"tool_input\":{\"file_path\":\"$target\"}}' | bash \"$HOOK\""
}

# --- Gate FIRES on the narrow allowlist ---

@test "BLOCKS specs/Arx_4-1 build-card write when no /design handoff" {
  write_mode "gOS > /build feature"
  run_hook "/tmp/gOS/specs/Arx_4-1_Shipcard.md"
  [ "$status" -eq 2 ]
  [[ "$output" == *"PHASE GATE"* ]]
  [[ "$output" == *"design"* ]]
}

@test "BLOCKS specs/Arx_4-2 design-system write when no /think handoff" {
  write_mode "gOS > /design card"
  run_hook "/tmp/gOS/specs/Arx_4-2_Design_System.md"
  [ "$status" -eq 2 ]
  [[ "$output" == *"PHASE GATE"* ]]
  [[ "$output" == *"think"* ]]
}

@test "BLOCKS apps/ write when no /design handoff" {
  write_mode "gOS > /build feature"
  run_hook "/tmp/gOS/apps/web/page.tsx"
  [ "$status" -eq 2 ]
  [[ "$output" == *"PHASE GATE"* ]]
  [[ "$output" == *"design"* ]]
}

@test "ALLOWS specs/Arx_4-1 with /design handoff present" {
  write_mode "gOS > /build feature"
  echo '{"phase":"design","output":"outputs/design/card.md","approved":true}' > "$HANDOFFS_DIR/design.json"
  run_hook "/tmp/gOS/specs/Arx_4-1_Shipcard.md"
  [ "$status" -eq 0 ]
}

@test "ALLOWS specs/Arx_4-2 with /think handoff present" {
  write_mode "gOS > /design card"
  echo '{"phase":"think","output":"specs/test.md","approved":true}' > "$HANDOFFS_DIR/think.json"
  run_hook "/tmp/gOS/specs/Arx_4-2_Design_System.md"
  [ "$status" -eq 0 ]
}

# --- Gate DOES NOT FIRE on ungated targets regardless of Mode ---
# Regression tests for the 2026-04-15/19 scratchpad-Mode-drift bug.

@test "DOES NOT BLOCK memory/ write even if Mode says /build feature" {
  write_mode "gOS > /build feature"
  run_hook "/tmp/gOS/memory/evolve_audit.md"
  [ "$status" -eq 0 ]
}

@test "DOES NOT BLOCK outputs/think/ write even if Mode says /design card" {
  write_mode "gOS > /design card"
  run_hook "/tmp/gOS/outputs/think/research/foo.md"
  [ "$status" -eq 0 ]
}

@test "DOES NOT BLOCK rules/ write even with stale /build Mode" {
  write_mode "gOS > /build feature"
  run_hook "/tmp/gOS/rules/common/output-discipline.md"
  [ "$status" -eq 0 ]
}

@test "DOES NOT BLOCK tests/hooks/ write even with stale Mode" {
  write_mode "gOS > /build feature"
  run_hook "/tmp/gOS/tests/hooks/response-discipline.bats"
  [ "$status" -eq 0 ]
}

@test "DOES NOT BLOCK tools/ write even with stale Mode" {
  write_mode "gOS > /design card"
  run_hook "/tmp/gOS/tools/sync-gos.sh"
  [ "$status" -eq 0 ]
}

@test "DOES NOT BLOCK agents/ write even with stale Mode" {
  write_mode "gOS > /build feature"
  run_hook "/tmp/gOS/agents/researcher.md"
  [ "$status" -eq 0 ]
}

@test "DOES NOT BLOCK .claude/hooks/ write even with stale Mode" {
  write_mode "gOS > /build feature"
  run_hook "/tmp/gOS/.claude/hooks/phase-gate.sh"
  [ "$status" -eq 0 ]
}

@test "DOES NOT BLOCK sessions/ write" {
  write_mode "gOS > /build feature"
  run_hook "/tmp/gOS/sessions/evolve_signals.md"
  [ "$status" -eq 0 ]
}

@test "DOES NOT BLOCK /tmp/test.md (no path match)" {
  write_mode "gOS > /build feature"
  run_hook "/tmp/test.md"
  [ "$status" -eq 0 ]
}

# --- Edge cases ---

@test "exits cleanly when no scratchpad exists (and target is non-gated)" {
  rm -f "$PROJECT_DIR/sessions/scratchpad.md"
  run_hook "/tmp/test.md"
  [ "$status" -eq 0 ]
}

@test "ignores non-Edit/Write tools" {
  write_mode "gOS > /build feature"
  run bash -c "echo '{\"tool_name\":\"Read\",\"tool_input\":{\"file_path\":\"/tmp/gOS/specs/Arx_4-1.md\"}}' | bash \"$HOOK\""
  [ "$status" -eq 0 ]
}

# --- Bypass: explicit PHASE_GATE_SKIP ---

@test "allows bypass with PHASE_GATE_SKIP in scratchpad even on gated target" {
  write_mode "gOS > /build feature"
  echo "PHASE_GATE_SKIP" >> "$PROJECT_DIR/sessions/scratchpad.md"
  run_hook "/tmp/gOS/specs/Arx_4-1_Shipcard.md"
  [ "$status" -eq 0 ]
}
