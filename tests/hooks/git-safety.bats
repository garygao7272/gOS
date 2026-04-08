#!/usr/bin/env bats
# Tests for git-safety.sh — blocks rebase with untracked files in critical dirs

HOOK="$BATS_TEST_DIRNAME/../../.claude/hooks/git-safety.sh"

setup() {
  # Create a temp git repo for testing
  export TEST_DIR=$(mktemp -d)
  cd "$TEST_DIR"
  git init -q
  echo "init" > README.md
  git add README.md
  git commit -q -m "init"
  mkdir -p specs outputs memory
}

teardown() {
  rm -rf "$TEST_DIR"
}

make_input() {
  local cmd="$1"
  echo "{\"tool_name\":\"Bash\",\"tool_input\":{\"command\":\"$cmd\"}}"
}

@test "blocks git rebase when untracked files in specs/" {
  echo "untracked" > specs/new-spec.md
  result=$(make_input "git rebase main" | bash "$HOOK" 2>&1) || status=$?
  [ "$status" -eq 2 ]
  [[ "$result" == *"BLOCKED"* ]]
  [[ "$result" == *"untracked"* ]]
}

@test "blocks git pull --rebase when untracked files in memory/" {
  echo "untracked" > memory/new.md
  result=$(make_input "git pull --rebase origin main" | bash "$HOOK" 2>&1) || status=$?
  [ "$status" -eq 2 ]
}

@test "allows git rebase when no untracked files" {
  result=$(make_input "git rebase main" | bash "$HOOK" 2>&1)
  status=$?
  [ "$status" -eq 0 ]
}

@test "allows non-rebase git commands" {
  echo "untracked" > specs/new.md
  result=$(make_input "git status" | bash "$HOOK" 2>&1)
  status=$?
  [ "$status" -eq 0 ]
}

@test "ignores non-Bash tools" {
  result=$(echo '{"tool_name":"Read","tool_input":{}}' | bash "$HOOK" 2>&1)
  status=$?
  [ "$status" -eq 0 ]
}
