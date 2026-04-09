#!/usr/bin/env bats
# Tests for session-save.sh — saves session summary on Stop event
# Event: Stop

HOOK="$BATS_TEST_DIRNAME/../../.claude/hooks/session-save.sh"
PROJECT_DIR="$BATS_TEST_DIRNAME/../.."

setup() {
  export CLAUDE_PROJECT_DIR="$PROJECT_DIR"
  SESSIONS_DIR="$PROJECT_DIR/sessions"
  SCRATCHPAD="$SESSIONS_DIR/scratchpad.md"
  LAST_SESSION="$SESSIONS_DIR/last-session.md"

  # Backup real files
  [ -f "$SCRATCHPAD" ] && cp "$SCRATCHPAD" "$SCRATCHPAD.bak" || true
  [ -f "$LAST_SESSION" ] && cp "$LAST_SESSION" "$LAST_SESSION.bak" || true
}

teardown() {
  SESSIONS_DIR="$PROJECT_DIR/sessions"
  SCRATCHPAD="$SESSIONS_DIR/scratchpad.md"
  LAST_SESSION="$SESSIONS_DIR/last-session.md"

  # Restore backups
  if [ -f "$SCRATCHPAD.bak" ]; then
    mv "$SCRATCHPAD.bak" "$SCRATCHPAD"
  fi
  if [ -f "$LAST_SESSION.bak" ]; then
    mv "$LAST_SESSION.bak" "$LAST_SESSION"
  fi
  rm -f "$SESSIONS_DIR/.scratchpad_timestamp"
}

write_test_scratchpad() {
  cat > "$PROJECT_DIR/sessions/scratchpad.md" << 'EOF'
# Session Scratchpad

## Current Task
Building test scaffolder for Sprint 1

## Mode & Sub-command
gOS > /build feature

## Key Decisions
1. Test scaffolder as shell script, not Python
2. Lean approach: template + manual refinement

## Files Actively Editing
- tools/test-scaffold.sh
- tests/hooks/spec-compliance.bats

## Next Steps
1. Run all tests
2. Fix failures
EOF
}

# --- SHOULD SAVE ---

@test "creates last-session.md from scratchpad" {
  write_test_scratchpad
  rm -f "$PROJECT_DIR/sessions/last-session.md"
  run bash "$HOOK"
  [ "$status" -eq 0 ]
  [ -f "$PROJECT_DIR/sessions/last-session.md" ]
}

@test "captures task from scratchpad" {
  write_test_scratchpad
  bash "$HOOK"
  grep -q "test scaffolder\|Sprint 1" "$PROJECT_DIR/sessions/last-session.md"
}

@test "captures mode from scratchpad" {
  write_test_scratchpad
  bash "$HOOK"
  grep -q "build" "$PROJECT_DIR/sessions/last-session.md"
}

@test "captures files touched" {
  write_test_scratchpad
  bash "$HOOK"
  grep -q "test-scaffold.sh\|spec-compliance.bats" "$PROJECT_DIR/sessions/last-session.md"
}

@test "writes scratchpad timestamp" {
  write_test_scratchpad
  bash "$HOOK"
  [ -f "$PROJECT_DIR/sessions/.scratchpad_timestamp" ]
}

# --- SHOULD SKIP ---

@test "skips when no scratchpad exists" {
  rm -f "$PROJECT_DIR/sessions/scratchpad.md"
  rm -f "$PROJECT_DIR/sessions/last-session.md"
  run bash "$HOOK"
  [ "$status" -eq 0 ]
}

@test "skips when scratchpad is template-only" {
  cat > "$PROJECT_DIR/sessions/scratchpad.md" << 'EOF'
# Session Scratchpad
> Purpose: Survives context compaction.
---
## Current Task
## Mode & Sub-command
EOF
  rm -f "$PROJECT_DIR/sessions/last-session.md"
  run bash "$HOOK"
  [ "$status" -eq 0 ]
}

# --- EDGE CASES ---

@test "handles missing sections gracefully" {
  cat > "$PROJECT_DIR/sessions/scratchpad.md" << 'EOF'
# Session Scratchpad
Some content here that is real work.
More content to pass the line count check.
And another line of real work.
EOF
  run bash "$HOOK"
  [ "$status" -eq 0 ]
}
