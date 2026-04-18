#!/usr/bin/env bats
# Tests for delete-guard.sh — blocks destructive file operations

HOOK="$BATS_TEST_DIRNAME/../../.claude/hooks/delete-guard.sh"

make_input() {
  local cmd="$1"
  echo "{\"tool_name\":\"Bash\",\"tool_input\":{\"command\":\"$cmd\"}}"
}

@test "blocks rm -rf" {
  result=$(make_input "rm -rf /tmp/testdir" | bash "$HOOK" 2>&1) || status=$?
  [ "$status" -eq 2 ]
  [[ "$result" == *"BLOCKED"* ]]
  [[ "$result" == *"rm -rf"* ]]
}

@test "blocks rm -r with space" {
  result=$(make_input "rm -r /tmp/testdir" | bash "$HOOK" 2>&1) || status=$?
  [ "$status" -eq 2 ]
  [[ "$result" == *"BLOCKED"* ]]
}

@test "blocks rm -fr" {
  result=$(make_input "rm -fr /tmp/testdir" | bash "$HOOK" 2>&1) || status=$?
  [ "$status" -eq 2 ]
}

@test "blocks git clean" {
  result=$(make_input "git clean -fd" | bash "$HOOK" 2>&1) || status=$?
  [ "$status" -eq 2 ]
  [[ "$result" == *"git clean"* ]]
}

@test "blocks git reset --hard" {
  result=$(make_input "git reset --hard HEAD~1" | bash "$HOOK" 2>&1) || status=$?
  [ "$status" -eq 2 ]
  [[ "$result" == *"git reset --hard"* ]]
}

@test "blocks git push --force" {
  result=$(make_input "git push --force origin main" | bash "$HOOK" 2>&1) || status=$?
  [ "$status" -eq 2 ]
  [[ "$result" == *"git push --force"* ]]
}

@test "blocks git push -f" {
  result=$(make_input "git push -f origin main" | bash "$HOOK" 2>&1) || status=$?
  [ "$status" -eq 2 ]
}

@test "blocks rm targeting specs/" {
  result=$(make_input "rm specs/important.md" | bash "$HOOK" 2>&1) || status=$?
  [ "$status" -eq 2 ]
  [[ "$result" == *"protected directory"* ]]
}

@test "blocks rm targeting memory/" {
  result=$(make_input "rm memory/L1_essential.md" | bash "$HOOK" 2>&1) || status=$?
  [ "$status" -eq 2 ]
}

@test "allows safe commands" {
  result=$(make_input "ls -la" | bash "$HOOK" 2>&1)
  status=$?
  [ "$status" -eq 0 ]
}

@test "allows git commit" {
  result=$(make_input "git commit -m 'test'" | bash "$HOOK" 2>&1)
  status=$?
  [ "$status" -eq 0 ]
}

@test "allows rm on non-protected paths" {
  result=$(make_input "rm /tmp/scratch.txt" | bash "$HOOK" 2>&1)
  status=$?
  [ "$status" -eq 0 ]
}

@test "ignores non-Bash tools" {
  result=$(echo '{"tool_name":"Edit","tool_input":{}}' | bash "$HOOK" 2>&1)
  status=$?
  [ "$status" -eq 0 ]
}

# --- Cleanup-zone allowlist ---

@test "allows rm -rf of plugin cache subdir (~/.claude/plugins/cache/<name>)" {
  result=$(make_input "rm -rf /Users/garyg/.claude/plugins/cache/thedotmack" | bash "$HOOK" 2>&1)
  status=$?
  [ "$status" -eq 0 ]
}

@test "allows rm -rf of projects-archive subdir" {
  result=$(make_input "rm -rf /Users/garyg/.claude/projects-archive/-Users-garyg-old-project" | bash "$HOOK" 2>&1)
  status=$?
  [ "$status" -eq 0 ]
}

@test "allows cd+rm pattern inside cleanup zone" {
  result=$(make_input "cd /Users/garyg/.claude/plugins/cache && rm -rf thedotmack" | bash "$HOOK" 2>&1)
  status=$?
  [ "$status" -eq 0 ]
}

@test "BLOCKS rm of cleanup zone itself (not a subdir)" {
  result=$(make_input "rm -rf /Users/garyg/.claude/plugins/cache" | bash "$HOOK" 2>&1) || status=$?
  [ "$status" -eq 2 ]
}

@test "BLOCKS rm of nested path inside cleanup zone (two levels deep)" {
  result=$(make_input "rm -rf /Users/garyg/.claude/plugins/cache/foo/bar" | bash "$HOOK" 2>&1) || status=$?
  [ "$status" -eq 2 ]
}

@test "BLOCKS rm of non-allowlisted .claude/ path" {
  result=$(make_input "rm -rf /Users/garyg/.claude/hooks/delete-guard.sh" | bash "$HOOK" 2>&1) || status=$?
  [ "$status" -eq 2 ]
}
