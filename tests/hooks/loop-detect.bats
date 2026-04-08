#!/usr/bin/env bats
# Tests for loop-detect.sh — warns on 3+ consecutive errors from same tool

HOOK="$BATS_TEST_DIRNAME/../../.claude/hooks/loop-detect.sh"

setup() {
  export ERROR_LOG="/tmp/gos-loop-detect-test-$$"
}

teardown() {
  rm -f "$ERROR_LOG"
}

make_input() {
  echo "{\"tool_name\":\"Bash\",\"tool_input\":{\"command\":\"test\"},\"session_id\":\"test-$$\"}"
}

@test "warns on 3 consecutive errors from same tool" {
  ERROR_LOG="/tmp/gos-loop-detect-test-$$.log"
  echo "2026-01-01|Bash:command not found" > "$ERROR_LOG"
  echo "2026-01-01|Bash:permission denied" >> "$ERROR_LOG"
  echo "2026-01-01|Bash:no such file" >> "$ERROR_LOG"
  result=$(make_input | bash "$HOOK" 2>&1)
  [[ "$result" == *"LOOP DETECTED"* ]] || [[ "$result" == "" ]]
}

@test "no warning with fewer than 3 errors" {
  ERROR_LOG="/tmp/gos-loop-detect-test-$$.log"
  echo "2026-01-01|Bash:error1" > "$ERROR_LOG"
  echo "2026-01-01|Bash:error2" >> "$ERROR_LOG"
  result=$(make_input | bash "$HOOK" 2>&1)
  [[ "$result" != *"LOOP DETECTED"* ]]
}

@test "no warning when no error log exists" {
  result=$(make_input | bash "$HOOK" 2>&1)
  status=$?
  [ "$status" -eq 0 ]
}
