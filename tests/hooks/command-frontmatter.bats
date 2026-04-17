#!/usr/bin/env bats
# Tests for command frontmatter validation in tools/health-gate.sh.
# Prevents regression of the recurring "/gos autocomplete disappears" bug.
# Root cause: deprecated/unknown frontmatter fields silently demote a slash
# command to a skill in Claude Code desktop — no autocomplete, no error.

GATE="$BATS_TEST_DIRNAME/../../tools/health-gate.sh"
PROJECT_DIR="$BATS_TEST_DIRNAME/../.."
COMMANDS_DIR="$PROJECT_DIR/commands"

# --- Static checks against the current repo state ---

@test "every commands/*.md has a description: field" {
  missing=0
  for f in "$COMMANDS_DIR"/*.md; do
    block=$(awk 'NR==1 && /^---$/{fm=1; next} fm && /^---$/{exit} fm' "$f")
    if ! printf '%s\n' "$block" | grep -qE '^description:'; then
      echo "MISSING description: $f"
      missing=$((missing + 1))
    fi
  done
  [ "$missing" -eq 0 ]
}

@test "no commands/*.md has the deprecated effort: field" {
  offenders=0
  for f in "$COMMANDS_DIR"/*.md; do
    block=$(awk 'NR==1 && /^---$/{fm=1; next} fm && /^---$/{exit} fm' "$f")
    if printf '%s\n' "$block" | grep -qE '^effort:'; then
      echo "HAS effort: $f"
      offenders=$((offenders + 1))
    fi
  done
  [ "$offenders" -eq 0 ]
}

@test "commands/gos.md exists and registers as a slash command" {
  [ -f "$COMMANDS_DIR/gos.md" ]
  block=$(awk 'NR==1 && /^---$/{fm=1; next} fm && /^---$/{exit} fm' "$COMMANDS_DIR/gos.md")
  printf '%s\n' "$block" | grep -qE '^description:'
  ! printf '%s\n' "$block" | grep -qE '^effort:'
}

# --- Dynamic checks: health-gate actually detects regressions ---

setup() {
  TMPDIR=$(mktemp -d)
  export FAKE_PROJECT="$TMPDIR"
  mkdir -p "$FAKE_PROJECT/commands" "$FAKE_PROJECT/memory" "$FAKE_PROJECT/.claude/hooks"
  # Minimal stubs so the rest of health-gate doesn't bail
  echo "# L1" > "$FAKE_PROJECT/memory/L1_essential.md"
}

teardown() {
  rm -rf "$TMPDIR"
}

@test "health-gate blocks when a command has effort: field" {
  cat > "$FAKE_PROJECT/commands/test.md" <<'EOF'
---
description: "test"
effort: high
---
# Test
EOF
  run env CLAUDE_PROJECT_DIR="$FAKE_PROJECT" bash "$GATE"
  [ "$status" -eq 2 ]
  echo "$output" | grep -q "deprecated 'effort:'"
}

@test "health-gate blocks when a command is missing description:" {
  cat > "$FAKE_PROJECT/commands/test.md" <<'EOF'
---
other: value
---
# Test
EOF
  run env CLAUDE_PROJECT_DIR="$FAKE_PROJECT" bash "$GATE"
  [ "$status" -eq 2 ]
  echo "$output" | grep -q "missing 'description:'"
}

@test "health-gate passes (no FM error) when command has only description:" {
  cat > "$FAKE_PROJECT/commands/test.md" <<'EOF'
---
description: "test command"
---
# Test
EOF
  run env CLAUDE_PROJECT_DIR="$FAKE_PROJECT" bash "$GATE"
  # Frontmatter stage must not block (status 0 or 1, not 2)
  [ "$status" -ne 2 ]
  echo "$output" | grep -q "OK: test.md"
}

@test "health-gate continues past frontmatter stage when all commands are clean" {
  # Regression guard for the set -e + grep-returns-1 silent abort.
  # If that bug returns, the script dies inside the frontmatter loop and
  # the "L1:" check line (next stage) never prints.
  cat > "$FAKE_PROJECT/commands/a.md" <<'EOF'
---
description: "a"
---
EOF
  cat > "$FAKE_PROJECT/commands/b.md" <<'EOF'
---
description: "b"
---
EOF
  run env CLAUDE_PROJECT_DIR="$FAKE_PROJECT" bash "$GATE"
  echo "$output" | grep -q "^L1:"
}
