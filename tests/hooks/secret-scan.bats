#!/usr/bin/env bats
# Tests for secret-scan.sh — detects hardcoded secrets in staged files

HOOK="$BATS_TEST_DIRNAME/../../.claude/hooks/secret-scan.sh"

setup() {
  export TEST_DIR=$(mktemp -d)
  cd "$TEST_DIR"
  git init -q
  echo "init" > README.md
  git add README.md
  git commit -q -m "init"
}

teardown() {
  rm -rf "$TEST_DIR"
}

make_input() {
  echo '{"tool_name":"Bash","tool_input":{"command":"git commit -m \"test\""}}'
}

@test "blocks commit with API_KEY in staged file" {
  echo 'API_KEY = "sk-abc123456789"' > config.py
  git add config.py
  result=$(make_input | bash "$HOOK" 2>&1) || status=$?
  [ "$status" -eq 2 ]
  [[ "$result" == *"BLOCKED"* ]]
  [[ "$result" == *"secret"* ]]
}

@test "blocks commit with OpenAI key pattern" {
  echo 'key = "sk-abcdefghijklmnopqrstuvwxyz1234567890"' > .env
  git add .env
  result=$(make_input | bash "$HOOK" 2>&1) || status=$?
  [ "$status" -eq 2 ]
}

@test "blocks commit with GitHub token" {
  echo 'token = "ghp_abcdefghijklmnopqrstuvwxyz1234567890"' > auth.js
  git add auth.js
  result=$(make_input | bash "$HOOK" 2>&1) || status=$?
  [ "$status" -eq 2 ]
}

@test "allows commit with no secrets" {
  echo 'console.log("hello")' > app.js
  git add app.js
  result=$(make_input | bash "$HOOK" 2>&1)
  status=$?
  [ "$status" -eq 0 ]
}

@test "allows non-commit commands" {
  echo '{"tool_name":"Bash","tool_input":{"command":"git status"}}' | bash "$HOOK"
  status=$?
  [ "$status" -eq 0 ]
}

@test "skips binary files" {
  dd if=/dev/zero of=image.png bs=1 count=100 2>/dev/null
  git add image.png
  result=$(make_input | bash "$HOOK" 2>&1)
  status=$?
  [ "$status" -eq 0 ]
}
