#!/usr/bin/env bats
# Routing + documentation tests for /review ultra. These don't exercise the
# native /ultrareview (which requires a live CC runtime) — they verify the
# gOS-side surface: command.md documents the sub-command, includes routing
# logic, and the eval rubric exists.

REVIEW_MD="$BATS_TEST_DIRNAME/../../commands/review.md"
RUBRIC="$BATS_TEST_DIRNAME/../../evals/rubrics/review-ultra.md"

@test "review.md lists 'ultra' in the sub-command prompt" {
  run grep -E "code, test, design, spec, gate, council, ultra" "$REVIEW_MD"
  [ "$status" -eq 0 ]
}

@test "review.md has a dedicated ## ultra section" {
  run grep -E '^## ultra' "$REVIEW_MD"
  [ "$status" -eq 0 ]
}

@test "ultra section delegates to native /ultrareview" {
  run grep -E 'native.*`/ultrareview`' "$REVIEW_MD"
  [ "$status" -eq 0 ]
}

@test "ultra section has a routing rule distinguishing ultra vs council" {
  run grep -iE "ultra.*vs.*council|paths.*diff.*ultra|topic.*council" "$REVIEW_MD"
  [ "$status" -eq 0 ]
}

@test "ultra section has a fallback rule (not silent fallthrough)" {
  run grep -iE "fallback|unavailable.*error|do NOT silently" "$REVIEW_MD"
  [ "$status" -eq 0 ]
}

@test "eval rubric exists at evals/rubrics/review-ultra.md" {
  [ -f "$RUBRIC" ]
}

@test "rubric has required frontmatter fields" {
  run grep -E '^name: review-ultra' "$RUBRIC"
  [ "$status" -eq 0 ]
  run grep -E '^command: /review ultra' "$RUBRIC"
  [ "$status" -eq 0 ]
}

@test "rubric defines 5 scoring dimensions" {
  count=$(grep -cE '^\| [A-Z][a-z]+ [a-z]+' "$RUBRIC")
  [ "$count" -ge 5 ]
}
