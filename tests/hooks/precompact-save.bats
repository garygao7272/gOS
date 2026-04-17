#!/usr/bin/env bats
# Tests for precompact-save.sh + tools/save-signals.sh — PreCompact hard-block.
# Verifies: idempotency, write-failure → exit 2, JSON validation, scratchpad
# Context update, settings.json schema validity.

WORKER="$BATS_TEST_DIRNAME/../../tools/save-signals.sh"
WRAPPER="$BATS_TEST_DIRNAME/../../.claude/hooks/precompact-save.sh"
SETTINGS="$BATS_TEST_DIRNAME/../../.claude/settings.json"

setup() {
  TMPDIR=$(mktemp -d)
  export GOS_PROJECT_DIR="$TMPDIR"
  export GOS_NOW="2026-04-17T12:00:00Z"
  mkdir -p "$TMPDIR/sessions"
  cat > "$TMPDIR/sessions/scratchpad.md" <<'EOF'
# Scratchpad

## Mode
gOS > /build

Context: ACTIVE
EOF
}

teardown() {
  rm -rf "$TMPDIR"
}

make_payload() {
  local sid="${1:-sess-abc}"
  local trigger="${2:-auto}"
  printf '{"session_id":"%s","transcript_path":"/tmp/x.jsonl","cwd":"%s","hook_event_name":"PreCompact","compaction_trigger":"%s"}' \
    "$sid" "$TMPDIR" "$trigger"
}

@test "test 1: valid payload → exit 0, signal log gets checkpoint with 3 fields" {
  run bash -c "echo '$(make_payload sess-1 auto)' | bash '$WORKER'"
  [ "$status" -eq 0 ]
  [ -f "$TMPDIR/sessions/evolve_signals.md" ]
  grep -q "session_id: sess-1" "$TMPDIR/sessions/evolve_signals.md"
  grep -q "trigger: auto" "$TMPDIR/sessions/evolve_signals.md"
  grep -q "Compaction Checkpoint — 2026-04-17T12:00:00Z" "$TMPDIR/sessions/evolve_signals.md"
}

@test "test 2: read-only sessions/ dir → exit 2 with stderr message" {
  chmod 555 "$TMPDIR/sessions"
  run bash -c "echo '$(make_payload)' | bash '$WORKER'"
  chmod 755 "$TMPDIR/sessions"
  [ "$status" -eq 2 ]
  [[ "$output" == *"cannot write"* ]]
}

@test "test 3: malformed JSON → exit 2, no partial writes" {
  run bash -c "echo 'not json at all' | bash '$WORKER'"
  [ "$status" -eq 2 ]
  [ ! -f "$TMPDIR/sessions/evolve_signals.md" ]
}

@test "test 4: idempotent — second run with same session_id does not duplicate" {
  echo "$(make_payload sess-dup)" | bash "$WORKER"
  echo "$(make_payload sess-dup)" | bash "$WORKER"
  count=$(grep -c "<!-- precompact:sess-dup -->" "$TMPDIR/sessions/evolve_signals.md")
  [ "$count" -eq 1 ]
}

@test "test 5: scratchpad Context line replaced with POST-COMPACTION" {
  echo "$(make_payload sess-ctx)" | bash "$WORKER"
  grep -q "^Context: POST-COMPACTION" "$TMPDIR/sessions/scratchpad.md"
  ! grep -q "^Context: ACTIVE" "$TMPDIR/sessions/scratchpad.md"
}

@test "test 6: settings.json validates as JSON and PreCompact uses command hook" {
  run jq -e '.hooks.PreCompact[0].hooks[] | select(.type=="command")' "$SETTINGS"
  [ "$status" -eq 0 ]
  run jq -re '.hooks.PreCompact[0].hooks[] | select(.type=="command") | .command' "$SETTINGS"
  [ "$status" -eq 0 ]
  [[ "$output" == *"precompact-save.sh" ]]
}

@test "wrapper test: precompact-save.sh forwards stdin to worker" {
  export CLAUDE_PROJECT_DIR="$BATS_TEST_DIRNAME/../.."
  payload=$(make_payload sess-wrap)
  run bash -c "echo '$payload' | bash '$WRAPPER'"
  [ "$status" -eq 0 ]
  grep -q "session_id: sess-wrap" "$TMPDIR/sessions/evolve_signals.md"
}

@test "wrapper test: missing worker is non-blocking (exit 0)" {
  run bash -c "CLAUDE_PROJECT_DIR='/nonexistent' bash -c \"echo '$(make_payload)' | bash '$WRAPPER'\""
  [ "$status" -eq 0 ]
  [[ "$output" == *"non-blocking"* ]]
}
