#!/usr/bin/env bats
# Tests for rules/common/output-discipline.md §1–§5 (response prose).
# These are smoke tests — they check fixture "response turn" blocks, not live transcripts.
# Fixtures live under tests/fixtures/response-discipline/.

FIXTURES="$BATS_TEST_DIRNAME/../fixtures/response-discipline"

setup() {
  mkdir -p "$FIXTURES"
}

# ─── Helpers ──────────────────────────────────────────────────────────────

# §1 Mechanism-first: first non-blank line must name a cause.
# Heuristic: reject common preambles and topic-first openers.
_check_mechanism_first() {
  local file="$1"
  local first_line
  first_line=$(awk 'NF{print; exit}' "$file")
  [[ -z "$first_line" ]] && return 1
  # Reject preamble patterns
  if echo "$first_line" | grep -qiE "^(I'll |Let me |Let's |Here's |Here is |Great question|Sure[,.]|Certainly|Of course|I will now|Now I'll|To answer)"; then
    return 1
  fi
  # Reject topic-first "Here's the X" / "X analysis:" style
  if echo "$first_line" | grep -qiE "^(The |A |An )?(analysis|summary|breakdown|overview|report)[:.]?[[:space:]]*$"; then
    return 1
  fi
  return 0
}

# §1.1 OUTLINE: responses ≥8 lines OR with ≥2 H2 sections must carry a
# `**Covers:**` line (or bulleted outline) near the top.
_check_outline_when_required() {
  local file="$1"
  local total h2_count
  total=$(wc -l < "$file" | tr -d ' ')
  h2_count=$(grep -c '^## ' "$file" 2>/dev/null) || h2_count=0
  h2_count=${h2_count:-0}
  # Exempt: short responses with <2 H2s
  if [[ "$total" -lt 8 && "$h2_count" -lt 2 ]]; then
    return 0
  fi
  # Must contain a Covers: line or bulleted outline within first 20 lines
  if head -20 "$file" | grep -qE '(\*\*Covers:\*\*|^- \*\*|^\*\*Outline\*\*)'; then
    return 0
  fi
  return 1
}

# §5 SUMMARY block: responses that report on actions (tool use, edits,
# commits) must include SUMMARY with DONE/TESTED/REMAINING/NEXT MOVE.
# Heuristic for fixture: if file contains an "action marker" (commit hash,
# "pushed", "edited", "shipped", "wrote"), require SUMMARY block.
_check_summary_on_action() {
  local file="$1"
  # Detect action markers
  if ! grep -qiE '\b(pushed|shipped|committed|edited|wrote|ran tests|deployed|merged)\b' "$file"; then
    return 0  # not an action response
  fi
  # Must contain SUMMARY block with all four labels
  grep -qE '^(SUMMARY|## SUMMARY|\*\*SUMMARY\*\*)' "$file" || return 1
  grep -qE '\bDONE:' "$file" || return 1
  grep -qE '\bTESTED:' "$file" || return 1
  grep -qE '\bREMAINING:' "$file" || return 1
  grep -qE '\bNEXT MOVE:' "$file" || return 1
  return 0
}

# §5 NEXT MOVE format: line after "NEXT MOVE:" must be ≤20 words AND
# contain a question mark (Proceed? / yes/no/modify prompt).
_check_next_move_format() {
  local file="$1"
  if ! grep -qE '\bNEXT MOVE:' "$file"; then
    return 0  # no NEXT MOVE = not applicable
  fi
  # Extract the NEXT MOVE value line
  local nm_line
  nm_line=$(grep -E '\bNEXT MOVE:' "$file" | head -1 | sed 's/.*NEXT MOVE:[[:space:]]*//')
  local words
  words=$(echo "$nm_line" | wc -w | tr -d ' ')
  [[ "$words" -gt 25 ]] && return 1  # too verbose (allowing 25 words incl modifiers)
  echo "$nm_line" | grep -qE '\?' || return 1  # missing question mark
  return 0
}

# §7.3 Em-dash density: < 25 words per em-dash = too dense (sandwich abuse).
_check_em_dash_density_response() {
  local file="$1"
  local em words
  em=$(grep -o '—' "$file" | wc -l | tr -d ' ')
  words=$(wc -w < "$file" | tr -d ' ')
  [[ "$em" -eq 0 ]] && return 0
  local density=$(( words / em ))
  [[ "$density" -ge 25 ]]
}

# ─── Fixtures: mechanism-first ────────────────────────────────────────────

@test "§1 PASSES response that leads with mechanism" {
  cat > "$FIXTURES/good-mechanism.md" <<'EOF'
Auth fails because the session token expires 2s before refresh completes.

Fix: bump refresh window to 10s in the config.
EOF
  _check_mechanism_first "$FIXTURES/good-mechanism.md"
}

@test "§1 FAILS response that opens with 'I'll now' preamble" {
  cat > "$FIXTURES/bad-preamble.md" <<'EOF'
I'll now analyze the auth failure.

Auth fails because the session token expires early.
EOF
  run _check_mechanism_first "$FIXTURES/bad-preamble.md"
  [ "$status" -ne 0 ]
}

@test "§1 FAILS response that opens with 'Here's the X'" {
  cat > "$FIXTURES/bad-heres.md" <<'EOF'
Here's the auth analysis you asked for.

Auth fails because of token expiry.
EOF
  run _check_mechanism_first "$FIXTURES/bad-heres.md"
  [ "$status" -ne 0 ]
}

# ─── Fixtures: OUTLINE required ───────────────────────────────────────────

@test "§1.1 PASSES short response with no Covers line" {
  cat > "$FIXTURES/short-ok.md" <<'EOF'
Yes. Commit ab35dfb on main.
EOF
  _check_outline_when_required "$FIXTURES/short-ok.md"
}

@test "§1.1 FAILS long response that lacks a Covers line" {
  {
    echo "Auth fails because the session token expires early."
    echo
    for i in $(seq 1 15); do echo "detail line $i"; done
    echo
    echo "## Section A"
    echo "content"
    echo
    echo "## Section B"
    echo "content"
  } > "$FIXTURES/long-no-outline.md"
  run _check_outline_when_required "$FIXTURES/long-no-outline.md"
  [ "$status" -ne 0 ]
}

@test "§1.1 PASSES long response with Covers line near the top" {
  {
    echo "Auth fails because the session token expires early."
    echo
    echo "**Covers:** cause · fix · verification."
    echo
    for i in $(seq 1 10); do echo "detail line $i"; done
    echo
    echo "## Section A"
    echo "content"
    echo
    echo "## Section B"
    echo "content"
  } > "$FIXTURES/long-with-outline.md"
  _check_outline_when_required "$FIXTURES/long-with-outline.md"
}

# ─── Fixtures: SUMMARY required on action responses ───────────────────────

@test "§5 PASSES action response with full SUMMARY block" {
  cat > "$FIXTURES/action-good.md" <<'EOF'
Pushed ab35dfb to origin/main and synced to user install.

SUMMARY
  DONE: 1 commit pushed, 3 sync targets updated.
  TESTED: diff -q returned silent; bats 7/7 pass.
  REMAINING: none.
  NEXT MOVE: run /save to persist session. Proceed?
EOF
  _check_summary_on_action "$FIXTURES/action-good.md"
}

@test "§5 FAILS action response missing SUMMARY block" {
  cat > "$FIXTURES/action-no-summary.md" <<'EOF'
Pushed ab35dfb to origin/main and synced to user install.

All good.
EOF
  run _check_summary_on_action "$FIXTURES/action-no-summary.md"
  [ "$status" -ne 0 ]
}

@test "§5 FAILS action response missing NEXT MOVE" {
  cat > "$FIXTURES/action-no-next.md" <<'EOF'
Pushed ab35dfb to origin/main.

SUMMARY
  DONE: 1 commit.
  TESTED: pass.
  REMAINING: none.
EOF
  run _check_summary_on_action "$FIXTURES/action-no-next.md"
  [ "$status" -ne 0 ]
}

@test "§5 PASSES non-action response without SUMMARY" {
  cat > "$FIXTURES/qa-response.md" <<'EOF'
Auth fails because the session token expires 2s before refresh.

Fix: bump refresh window to 10s.
EOF
  _check_summary_on_action "$FIXTURES/qa-response.md"
}

# ─── Fixtures: NEXT MOVE format ───────────────────────────────────────────

@test "§5 NEXT MOVE PASSES imperative ≤20 words with ?" {
  cat > "$FIXTURES/next-good.md" <<'EOF'
SUMMARY
  NEXT MOVE: run /save to persist session. Proceed?
EOF
  _check_next_move_format "$FIXTURES/next-good.md"
}

@test "§5 NEXT MOVE FAILS when line exceeds 25 words" {
  cat > "$FIXTURES/next-verbose.md" <<'EOF'
SUMMARY
  NEXT MOVE: there are several things we could potentially consider doing next including running /save to persist the session or running /refine again or perhaps /evolve audit or we could also just move on?
EOF
  run _check_next_move_format "$FIXTURES/next-verbose.md"
  [ "$status" -ne 0 ]
}

@test "§5 NEXT MOVE FAILS when missing question mark" {
  cat > "$FIXTURES/next-no-q.md" <<'EOF'
SUMMARY
  NEXT MOVE: run /save to persist session.
EOF
  run _check_next_move_format "$FIXTURES/next-no-q.md"
  [ "$status" -ne 0 ]
}

# ─── Fixtures: em-dash density (§7.3) ─────────────────────────────────────

@test "§7.3 PASSES response with normal em-dash density" {
  cat > "$FIXTURES/em-ok.md" <<'EOF'
Auth fails because the session token expires — roughly 2s before the refresh handshake completes.

Fix: bump refresh window to 10s. This removes the race without changing the token lifetime.
EOF
  _check_em_dash_density_response "$FIXTURES/em-ok.md"
}

@test "§7.3 FAILS response with em-dash sandwich at every clause" {
  cat > "$FIXTURES/em-abuse.md" <<'EOF'
Auth fails — and this matters — because the token — which is session-scoped — expires — roughly — 2s — before — the refresh — handshake — completes.
EOF
  run _check_em_dash_density_response "$FIXTURES/em-abuse.md"
  [ "$status" -ne 0 ]
}
