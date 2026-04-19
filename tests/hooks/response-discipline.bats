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

# §3 DEFER format: when "DEFER" appears as a verdict word, must be followed
# by "needs:" with a named resolver. Bare DEFER is paralysis-dressed-as-
# deliberation per the rule. Heuristic: search for "DEFER" outside code blocks
# and markdown table cells; for each match, confirm "needs:" follows within
# the same line (or next non-blank line if continuation).
_check_defer_format() {
  local file="$1"
  # Strip code blocks (triple-backtick fenced) and table rows
  local prose
  prose=$(awk '/^```/{in_cb=!in_cb; next} !in_cb && !/^\|/ {print}' "$file")
  # Find DEFER verdicts — standalone word, not substring (e.g., "DEFERRED", "DEFERENCE" OK)
  # Match: VERDICT: DEFER, verdict: DEFER, * DEFER, DEFER —, DEFER:
  local defer_lines
  defer_lines=$(echo "$prose" | grep -nE '(^|[^A-Za-z])DEFER($|[^A-Za-z])' || true)
  [[ -z "$defer_lines" ]] && return 0  # no DEFER verdicts — pass

  # For each DEFER line, require "needs:" within same line
  local failed=0
  while IFS= read -r line; do
    # Extract content (after line-number prefix if grep -n)
    local content="${line#*:}"
    if ! echo "$content" | grep -qiE 'needs:[[:space:]]*[^[:space:]]'; then
      failed=1
      break
    fi
  done <<< "$defer_lines"
  [[ "$failed" -eq 0 ]]
}

# §6 Multi-option advisory close: if response carries ≥3 lettered options
# (A./B./C.) AND a decision directive ("Reply with", "reply A/B/C"), it must
# also present the three-H2 structure: a "deliverable" H2, an optional
# "why" subset-rationale H2, and a "decision you need to make" H2.
_check_multi_option_shape() {
  local file="$1"
  # Detect lettered-options pattern: three `- **X.**` or `**X.**` bullets
  local option_count
  option_count=$(grep -cE '^(- )?\*\*[A-Z]\.\*\*' "$file" || true)
  [[ "$option_count" -lt 3 ]] && return 0  # not multi-option shape

  # Detect decision directive
  if ! grep -qiE '(reply with|reply `[A-Z]`|reply [A-Z]/[A-Z]|decision you need)' "$file"; then
    return 0  # lettered bullets not in a decision context — pass
  fi

  # Must carry three signals: deliverable H2, decision H2, at least one
  # "ranked" / "picks" / "options" indicator in the deliverable context
  local has_deliverable_h2 has_decision_h2
  has_deliverable_h2=$(grep -ciE '^## (the deliverable|the ranked|ranked picks)' "$file" || true)
  has_decision_h2=$(grep -ciE '^## (the decision|decision you need|make the decision)' "$file" || true)

  [[ "$has_deliverable_h2" -ge 1 && "$has_decision_h2" -ge 1 ]]
}

# §8 Pivot cluster: flag when pivot/hedge words appear at high density.
# Phrase list lives in tests/fixtures/ai-smell-phrases/pivot-cluster.txt —
# single source of truth consumed by this helper AND cited by
# rules/common/output-discipline-voice.md (row 8). Exclude code blocks + tables.
# Short responses (<20 prose lines) are exempt — insufficient mass to judge
# cluster vs single-use. Threshold: >1 pivot per 5 prose lines on longer content.
_check_pivot_cluster() {
  local file="$1"
  local phrase_file="$BATS_TEST_DIRNAME/../fixtures/ai-smell-phrases/pivot-cluster.txt"
  [[ -f "$phrase_file" ]] || return 1
  local prose
  prose=$(awk '/^```/{in_cb=!in_cb; next} !in_cb && !/^\|/ {print}' "$file")
  local lines
  lines=$(echo "$prose" | grep -cvE '^[[:space:]]*$' || true)
  [[ "$lines" -lt 20 ]] && return 0
  # Build alternation from phrase file (skip comments and blanks)
  local alt
  alt=$(grep -vE '^(#|[[:space:]]*$)' "$phrase_file" | tr '\n' '|' | sed 's/|$//')
  [[ -z "$alt" ]] && return 0
  local pivots
  pivots=$(echo "$prose" | grep -ciE "\b(${alt})\b" || true)
  local threshold=$(( lines / 5 ))
  [[ "$pivots" -le "$threshold" ]]
}

@test "§3 DEFER format: response with bare DEFER verdict FAILS" {
  cat > "$FIXTURES/defer-bare.md" <<'EOF'
**Covers:** findings · decision.

VERDICT: DEFER

We don't have enough signal yet.
EOF
  run _check_defer_format "$FIXTURES/defer-bare.md"
  [ "$status" -ne 0 ]
}

@test "§3 DEFER format: response with DEFER — needs: <resolver> PASSES" {
  cat > "$FIXTURES/defer-named.md" <<'EOF'
**Covers:** findings · decision.

VERDICT: DEFER — needs: 7-day backtest on the new signal against Q1 regime.

Gather before deciding.
EOF
  run _check_defer_format "$FIXTURES/defer-named.md"
  [ "$status" -eq 0 ]
}

@test "§3 DEFER format: response with no DEFER verdict is EXEMPT" {
  cat > "$FIXTURES/no-defer.md" <<'EOF'
**Covers:** shipped.

VERDICT: PASS — all tests green.
EOF
  run _check_defer_format "$FIXTURES/no-defer.md"
  [ "$status" -eq 0 ]
}

@test "§6 multi-option shape: response with A/B/C options but no three-H2 FAILS" {
  cat > "$FIXTURES/options-flat.md" <<'EOF'
Three ways to go.

- **A.** Ship all picks.
- **B.** Ship the recommended subset.
- **C.** Free-form.

Reply with `A`, `B`, or `C`.
EOF
  run _check_multi_option_shape "$FIXTURES/options-flat.md"
  [ "$status" -ne 0 ]
}

@test "§6 multi-option shape: response with three-H2 structure PASSES" {
  cat > "$FIXTURES/options-full.md" <<'EOF'
Three ranked picks below.

## The deliverable — 3 ranked picks

| # | Pick | Leverage |
|---|---|---|
| 1 | Fix A | High |
| 2 | Fix B | Medium |
| 3 | Fix C | Low |

## The decision you need to make

- **A.** Ship all three.
- **B.** Ship pick 1 only.
- **C.** Free-form.

Reply with `A`, `B`, or `C`.
EOF
  run _check_multi_option_shape "$FIXTURES/options-full.md"
  [ "$status" -eq 0 ]
}

@test "§6 multi-option shape: response without lettered options is EXEMPT" {
  cat > "$FIXTURES/not-multi.md" <<'EOF'
Single recommendation: ship it.
EOF
  run _check_multi_option_shape "$FIXTURES/not-multi.md"
  [ "$status" -eq 0 ]
}

@test "§8 pivot cluster: long response with heavy hedging density FAILS" {
  cat > "$FIXTURES/pivot-heavy.md" <<'EOF'
The signal is strong.
However, the sample is small.
On the other hand, the backtest covers three regimes.
That said, there's regime-change risk.
However, the recent window is stable.
Nevertheless, we should wait.
However, we could also move now.
However, caution wins.
Nevertheless, the trend is up.
On the other hand, capital is limited.
That said, we have dry powder.
However, discipline matters more.
Nevertheless, opportunity is fleeting.
However, we'll wait one more day.
On the other hand, tomorrow may be worse.
That said, patience compounds.
However, hesitation costs.
Nevertheless, we hold.
On the other hand, this could be the bottom.
That said, we don't know.
However, the plan says wait.
Nevertheless, we wait.
EOF
  run _check_pivot_cluster "$FIXTURES/pivot-heavy.md"
  [ "$status" -ne 0 ]
}

@test "§8 pivot cluster: short response with occasional pivot is EXEMPT" {
  cat > "$FIXTURES/pivot-normal.md" <<'EOF'
The signal is strong in momentum regimes. However, it weakens during chop.
We prefer to run it during trending windows only, which the regime-detector
flags 60% of sessions.
EOF
  run _check_pivot_cluster "$FIXTURES/pivot-normal.md"
  [ "$status" -eq 0 ]
}

@test "§8 pivot cluster: long response with reasonable pivot density PASSES" {
  cat > "$FIXTURES/pivot-reasonable.md" <<'EOF'
We shipped the spec-quality campaign today. Seven picks landed across two
phases: first the content edits to the three rule files, then the bats
helpers for the claimed invariants.

The council converged on three fractures. However, only two were decisive:
self-consistency (rule files violated their own opener rule) and enforcement
honesty (the table misrepresented coverage). The third was polish.

We chose option A from the ranked picks. That locked in all seven fixes
as a /refine campaign, executed cycle by cycle. Each cycle is a separate
commit with bats green before moving to the next one.

The first cycle covered picks one through three — structural edits only,
no new helpers. The second cycle added the three helpers you see below.
The third cycle will add the meta-check that keeps the enforcement table
honest going forward.

Verification ran green at every checkpoint. The test count is now
forty-three artifact plus twenty-nine response, for seventy-two total.
Ship is pending, the commits are local, pushing after the campaign lands.
EOF
  run _check_pivot_cluster "$FIXTURES/pivot-reasonable.md"
  [ "$status" -eq 0 ]
}
