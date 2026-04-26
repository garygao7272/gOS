#!/usr/bin/env bats
# Tests for rules/common/output-discipline.md §6 Artifact Discipline.
# These are smoke tests — they check fixtures, not live /refine runs.
# Fixtures live under tests/fixtures/artifact-discipline/.

FIXTURES="$BATS_TEST_DIRNAME/../fixtures/artifact-discipline"

setup() {
  mkdir -p "$FIXTURES"
}

# ─── Helpers ──────────────────────────────────────────────────────────────

# Check §6.1 — first content after H1 is positioning + outline (not changelog).
# Enforces positive presence: must HAVE a positioning sentence, not just LACK a changelog.
_check_opens_with_positioning() {
  local file="$1"
  local post_h1
  post_h1=$(awk '/^# /{found=1; next} found{print; if (NR > 20) exit}' "$file" | head -20)
  # Negative: must not start with changelog header
  if echo "$post_h1" | grep -qiE '^## (what changed|changelog|version history|deprecated)'; then
    return 1
  fi
  # Positive: first non-blank, non-frontmatter line after H1 must be either
  #   (a) italic positioning sentence (*...*, ≥20 chars), or
  #   (b) a ≥40-char prose line containing a positioning keyword
  local first_content
  first_content=$(echo "$post_h1" | awk 'NF{print; exit}')
  [[ -z "$first_content" ]] && return 1  # empty after H1 — fail
  # (a) italic line
  if echo "$first_content" | grep -qE '^\*[^*]{20,}'; then
    return 0
  fi
  # (b) prose line ≥40 chars with positioning keyword
  local len=${#first_content}
  if [[ "$len" -ge 40 ]] && echo "$first_content" | grep -qiE '\b(spec|memo|record|produces|outputs|decision|runtime|framework|guide|contract|rule|pipeline|protocol)\b'; then
    return 0
  fi
  return 1
}

# Auto-infer doc-type from file path when frontmatter is missing.
# Path heuristics reflect the standard output locations declared in each command's
# doc-type contract (commands/think.md, commands/simulate.md, commands/review.md).
_infer_doc_type_from_path() {
  local file="$1"
  case "$file" in
    */outputs/think/research/*)        echo "research-memo" ;;
    */outputs/think/decide/*)          echo "decision-record" ;;
    */outputs/think/discover/*)        echo "discovery" ;;
    */outputs/think/design/*)          echo "design-spec" ;;
    */outputs/briefings/market-sim-*)  echo "research-memo" ;;
    */outputs/refine/*/synthesis*)     echo "research-memo" ;;
    */outputs/review/ultra/*)          echo "research-memo" ;;
    */outputs/gos-jobs/*/synthesis*)   echo "decision-record" ;;
    */specs/*_3-*)                     echo "discovery" ;;
    */specs/*_4-1*)                    echo "build-card" ;;
    */specs/*_4-2*)                    echo "design-spec" ;;
    */specs/*_9-*)                     echo "decision-record" ;;
    */specs/*)                         echo "product-spec" ;;
    *)                                 echo "" ;;
  esac
}

# Check §6.8 — doc-type frontmatter present on artifacts ≥100 lines,
# and first three H2s match expected ordering for that type. When frontmatter
# is missing, fall back to path-based doc-type inference so default outputs
# get gated even when the author forgot the frontmatter block.
_check_doc_type_ordering() {
  local file="$1"
  local total
  total=$(wc -l < "$file" | tr -d ' ')
  [[ "$total" -lt 100 ]] && return 0  # short files exempt (threshold tightened from 300 to 100)

  # Extract doc-type from frontmatter (between first two --- lines)
  local doc_type
  doc_type=$(awk 'NR==1 && /^---$/{fm=1; next} fm && /^---$/{exit} fm && /^doc-type:/{sub(/^doc-type:[[:space:]]*/,""); print; exit}' "$file" || true)

  # If frontmatter absent, try to infer from the file path
  if [[ -z "$doc_type" ]]; then
    doc_type=$(_infer_doc_type_from_path "$file")
    [[ -z "$doc_type" ]] && return 1  # ≥100 lines, no frontmatter, no inferable path = fail
  fi

  # Extract first three H2 headings
  local h2s
  h2s=$(grep -m3 '^## ' "$file" | tr '\n' '|')

  # Map doc-type → expected keywords in order (case-insensitive)
  # Research memo: What (findings/result) → Why → How
  # Discovery: Why (problem) → What → How
  # Product-spec: What (scope/boundaries) → Why → How
  # Design-spec: What (surface) → How (interaction) → Why
  # Decision-record: Why → What → How → Consequences
  # Build-card: What → How → Why
  # Strategy: Why (now) → What → How
  case "$doc_type" in
    research-memo|research_memo)
      echo "$h2s" | grep -qiE '(finding|result|verdict|tldr|summary)' || return 1
      ;;
    discovery)
      echo "$h2s" | grep -qiE '(problem|why|pain|gap|opportunity)' || return 1
      ;;
    product-spec|product_spec)
      echo "$h2s" | grep -qiE '(scope|boundar|what|atoms|primitive)' || return 1
      ;;
    design-spec|design_spec)
      echo "$h2s" | grep -qiE '(surface|screen|interaction|what|state)' || return 1
      ;;
    decision-record|decision_record)
      echo "$h2s" | grep -qiE '(context|why|problem|decision|rationale)' || return 1
      ;;
    build-card|build_card)
      echo "$h2s" | grep -qiE '(change|what|scope|done|acceptance)' || return 1
      ;;
    strategy)
      echo "$h2s" | grep -qiE '(why|now|game|moment|context)' || return 1
      ;;
    *)
      return 1  # unknown doc-type
      ;;
  esac
  return 0
}

# Check §6.4 — no main-body version markers like "(NEW in vX.Y)" or "(was vX.Y Step N)"
_check_no_main_body_version_markers() {
  local file="$1"
  # Extract body (everything before appendix)
  local body
  body=$(awk 'tolower($0) ~ /^## appendix/ || tolower($0) ~ /^# appendix/ { exit } { print }' "$file")
  if echo "$body" | grep -qE '\((NEW|new) (in )?v[0-9]|\(was v[0-9]'; then
    return 1
  fi
  return 0
}

# Check §6.5 — version metadata consistent (filename version matches H1 version)
_check_metadata_consistent() {
  local file="$1"
  local filename_ver h1_ver
  filename_ver=$(basename "$file" | grep -oE 'v[0-9]+[-.][0-9]+' | head -1 | tr '-' '.')
  h1_ver=$(grep -m1 '^# ' "$file" | grep -oE 'v[0-9]+\.[0-9]+' | head -1)
  [[ -z "$filename_ver" ]] && return 0  # No version in filename — skip check
  [[ -z "$h1_ver" ]] && return 1  # Filename has version but H1 doesn't
  [[ "$filename_ver" = "$h1_ver" ]]
}

# Check §6.3 — meta-content ≤5% of lines (rough: count lines in changelog/history/redteam sections in body)
_check_meta_content_cap() {
  local file="$1"
  local total meta
  total=$(wc -l < "$file" | tr -d ' ')
  [[ "$total" -lt 50 ]] && return 0  # Short files exempt — noise threshold
  # Count lines in sections titled like changelog/version/red-team/what-changed, but NOT in Appendix
  meta=$(awk '
    tolower($0) ~ /^## appendix/ || tolower($0) ~ /^# appendix/ { in_appendix=1 }
    !in_appendix && tolower($0) ~ /^## (what changed|version delta|red-?team log|changelog|version history)/ { in_meta=1; next }
    !in_appendix && in_meta && /^## / { in_meta=0 }
    !in_appendix && in_meta { count++ }
    END { print count+0 }
  ' "$file")
  local pct=$(( meta * 100 / total ))
  [[ "$pct" -le 5 ]]
}

# ─── Fixture: clean artifact (should pass all) ────────────────────────────

@test "clean artifact passes all four checks" {
  cat > "$FIXTURES/clean.md" <<'EOF'
# Sample Spec v0.2

*A runtime for decisions. Five primitives, one loop, three protocols.*

## Outline

| Section | What |
|---|---|
| §1 Boundaries | Scope |
| §2 Atoms | Irreducible elements |

## §1 Boundaries

This spec covers the decision surface for trader X.

## §2 Atoms

Trader, order, position.

## How to use this

Walk the five steps; produce a pass/kill/defer verdict.

## Appendix — Version history

v0.1 → v0.2: added atoms section.
EOF
  _check_opens_with_positioning "$FIXTURES/clean.md"
  _check_no_main_body_version_markers "$FIXTURES/clean.md"
  _check_metadata_consistent "$FIXTURES/clean.md"
  _check_meta_content_cap "$FIXTURES/clean.md"
}

# ─── Fixture: changelog-first (fails §6.1) ────────────────────────────────

@test "FAILS §6.1 when opens with changelog before definition" {
  cat > "$FIXTURES/changelog-first.md" <<'EOF'
# Sample Spec v0.11

## What changed from v0.9

Eight refinements, lots of words, reader has no idea what this spec is.

## §1 Boundaries

Actual content starts here, too late.
EOF
  run _check_opens_with_positioning "$FIXTURES/changelog-first.md"
  [ "$status" -ne 0 ]
}

# ─── Fixture: empty opener (fails §6.1 positive check) ────────────────────

@test "FAILS §6.1 when H1 is followed by empty lines straight into H2" {
  cat > "$FIXTURES/empty-opener.md" <<'EOF'
# Sample Spec v0.11



## §1 Boundaries

Content starts without any positioning sentence.
EOF
  run _check_opens_with_positioning "$FIXTURES/empty-opener.md"
  [ "$status" -ne 0 ]
}

@test "FAILS §6.1 when opener is a short line lacking positioning keywords" {
  cat > "$FIXTURES/weak-opener.md" <<'EOF'
# Sample Spec v0.11

Hello world.

## §1 Content

Stuff.
EOF
  run _check_opens_with_positioning "$FIXTURES/weak-opener.md"
  [ "$status" -ne 0 ]
}

@test "PASSES §6.1 when opener is italic positioning sentence" {
  cat > "$FIXTURES/italic-opener.md" <<'EOF'
# Sample Spec v0.11

*A decision runtime for trader onboarding — five atoms, one loop, three protocols.*

## §1 Content

Stuff.
EOF
  _check_opens_with_positioning "$FIXTURES/italic-opener.md"
}

@test "PASSES §6.1 when opener is ≥40 chars and names a positioning keyword" {
  cat > "$FIXTURES/keyword-opener.md" <<'EOF'
# Sample Research Memo

Research memo on trader friction — produces a ranked list of improvements to ship.

## Findings

Stuff.
EOF
  _check_opens_with_positioning "$FIXTURES/keyword-opener.md"
}

# ─── Fixture: main-body version marker (fails §6.4) ───────────────────────

@test "FAILS §6.4 when main body carries (NEW in vX.Y) marker" {
  cat > "$FIXTURES/version-marker.md" <<'EOF'
# Sample Spec v0.10

*Decision runtime.*

## §2 TDC overview diagram (NEW in v0.10)

Diagram here.
EOF
  run _check_no_main_body_version_markers "$FIXTURES/version-marker.md"
  [ "$status" -ne 0 ]
}

@test "FAILS §6.4 when main body carries (was vX.Y Step N) marker" {
  cat > "$FIXTURES/was-marker.md" <<'EOF'
# Sample Spec v0.10

*Decision runtime.*

## STEP 2 REGIME (was v0.9 Step 1)

Content.
EOF
  run _check_no_main_body_version_markers "$FIXTURES/was-marker.md"
  [ "$status" -ne 0 ]
}

@test "PASSES §6.4 when version markers only appear in Appendix" {
  cat > "$FIXTURES/marker-in-appendix.md" <<'EOF'
# Sample Spec v0.10

*Decision runtime.*

## §1 Content

Clean body, no markers.

## Appendix — Version history

- v0.10 (NEW in v0.10): added markets step.
- v0.9: regime step was (was v0.8 Step 1).
EOF
  _check_no_main_body_version_markers "$FIXTURES/marker-in-appendix.md"
}

# ─── Fixture: metadata mismatch (fails §6.5) ──────────────────────────────

@test "FAILS §6.5 when filename version and H1 version disagree" {
  cat > "$FIXTURES/Spec_v0-11_Parent.md" <<'EOF'
# Sample Spec v0.10

*Version mismatch — filename says v0.11, H1 says v0.10.*
EOF
  run _check_metadata_consistent "$FIXTURES/Spec_v0-11_Parent.md"
  [ "$status" -ne 0 ]
}

@test "PASSES §6.5 when filename and H1 versions agree" {
  cat > "$FIXTURES/Spec_v0-11_Parent_ok.md" <<'EOF'
# Sample Spec v0.11

*Versions aligned.*
EOF
  _check_metadata_consistent "$FIXTURES/Spec_v0-11_Parent_ok.md"
}

# ─── Fixture: meta-content over cap (fails §6.3) ──────────────────────────

@test "FAILS §6.3 when meta-content in main body exceeds 5% of lines" {
  # 100-line file with 20 lines of changelog-in-body = 20% = FAIL
  {
    echo "# Sample Spec v0.10"
    echo
    echo "*Summary line.*"
    echo
    echo "## What changed from v0.9"
    for i in $(seq 1 19); do echo "- change $i"; done
    echo
    echo "## §1 Content"
    for i in $(seq 1 75); do echo "content line $i"; done
  } > "$FIXTURES/bloated-body.md"
  run _check_meta_content_cap "$FIXTURES/bloated-body.md"
  [ "$status" -ne 0 ]
}

@test "PASSES §6.3 when meta-content lives in Appendix, not main body" {
  {
    echo "# Sample Spec v0.10"
    echo
    echo "*Summary line.*"
    echo
    echo "## §1 Content"
    for i in $(seq 1 80); do echo "content line $i"; done
    echo
    echo "## Appendix — Version history"
    for i in $(seq 1 15); do echo "- change $i"; done
  } > "$FIXTURES/clean-appendix.md"
  _check_meta_content_cap "$FIXTURES/clean-appendix.md"
}

# ─── Lean FP-OS reference itself passes all checks ────────────────────────

@test "reference artifact (lean FP-OS) passes all four checks" {
  local ref="/Users/garyg/Documents/Documents - SG-LT674/Claude Working Folder/first_principles_operating_system_lean.md"
  if [ ! -f "$ref" ]; then
    skip "reference file not present on this machine"
  fi
  _check_opens_with_positioning "$ref"
  _check_no_main_body_version_markers "$ref"
  _check_metadata_consistent "$ref"
  _check_meta_content_cap "$ref"
}

# ─── §6.8 doc-type ordering ───────────────────────────────────────────────

@test "§6.8 exempts short files (<100 lines) from doc-type frontmatter" {
  cat > "$FIXTURES/short.md" <<'EOF'
# Short Doc

*A one-page explainer.*

## Point

Brief.
EOF
  _check_doc_type_ordering "$FIXTURES/short.md"
}

@test "§6.8 FAILS when long file lacks doc-type frontmatter AND path cannot infer" {
  {
    echo "# Long Doc"
    echo
    echo "*A ranked list of improvements to ship.*"
    echo
    for i in $(seq 1 120); do echo "line $i"; done
  } > "$FIXTURES/long-no-type.md"
  run _check_doc_type_ordering "$FIXTURES/long-no-type.md"
  [ "$status" -ne 0 ]
}

@test "§6.8 auto-infers research-memo from outputs/think/research/ path" {
  # Create a simulated outputs/think/research file without frontmatter; linter
  # should infer research-memo from the path and enforce finding-first H2.
  local inferred_dir="$FIXTURES/outputs/think/research"
  mkdir -p "$inferred_dir"
  {
    echo "# Inferred Research"
    echo
    echo "*A ranked picks memo produced by /think research.*"
    echo
    echo "## Verdict"
    echo "Finding first — auto-inferred type should require this H2 order."
    echo
    echo "## Why it matters"
    echo "Cause."
    echo
    for i in $(seq 1 110); do echo "line $i"; done
  } > "$inferred_dir/inferred-ok.md"
  _check_doc_type_ordering "$inferred_dir/inferred-ok.md"
}

@test "§6.8 auto-inferred research-memo FAILS when H2s open with background" {
  local inferred_dir="$FIXTURES/outputs/think/research"
  mkdir -p "$inferred_dir"
  {
    echo "# Inferred Research Bad"
    echo
    echo "*A memo that buries the finding.*"
    echo
    echo "## Background"
    echo "Setup before the payload — wrong for research-memo."
    echo
    echo "## Context"
    echo "More setup."
    echo
    echo "## Details"
    echo "Still no finding."
    echo
    for i in $(seq 1 110); do echo "line $i"; done
  } > "$inferred_dir/inferred-bad.md"
  run _check_doc_type_ordering "$inferred_dir/inferred-bad.md"
  [ "$status" -ne 0 ]
}

@test "§6.8 auto-infers decision-record from outputs/think/decide/ path" {
  local inferred_dir="$FIXTURES/outputs/think/decide"
  mkdir -p "$inferred_dir"
  {
    echo "# Inferred Decision"
    echo
    echo "*A pipeline design decision.*"
    echo
    echo "## Context"
    echo "Why this call now."
    echo
    echo "## Decision"
    echo "What we committed to."
    echo
    echo "## Consequences"
    echo "Downstream."
    echo
    for i in $(seq 1 110); do echo "line $i"; done
  } > "$inferred_dir/decision-inferred.md"
  _check_doc_type_ordering "$inferred_dir/decision-inferred.md"
}

@test "§6.8 100-line threshold: 150-line file with no frontmatter and generic path fails" {
  # Path is under $FIXTURES (no matching heuristic), so no inference. 150 lines
  # exceeds the new 100-line threshold — must fail.
  {
    echo "# Generic Doc"
    echo
    echo "*A doc in an unmapped location.*"
    echo
    for i in $(seq 1 150); do echo "line $i"; done
  } > "$FIXTURES/generic-150.md"
  run _check_doc_type_ordering "$FIXTURES/generic-150.md"
  [ "$status" -ne 0 ]
}

@test "§6.8 PASSES research-memo with finding-first H2" {
  {
    echo "---"
    echo "doc-type: research-memo"
    echo "audience: Gary"
    echo "reader-output: ranked picks"
    echo "---"
    echo
    echo "# Research Memo"
    echo
    echo "*Ranked picks for improvement.*"
    echo
    echo "## Verdict"
    echo "Finding first."
    echo
    echo "## Why it matters"
    echo "Cause."
    echo
    for i in $(seq 1 320); do echo "line $i"; done
  } > "$FIXTURES/research-ok.md"
  _check_doc_type_ordering "$FIXTURES/research-ok.md"
}

@test "§6.8 FAILS research-memo that opens with unrelated H2" {
  {
    echo "---"
    echo "doc-type: research-memo"
    echo "---"
    echo
    echo "# Research Memo"
    echo
    echo "*A memo.*"
    echo
    echo "## Overview"
    echo "Not a finding."
    echo
    echo "## Background"
    echo "Also not a finding."
    echo
    echo "## Details"
    echo "Still no finding."
    echo
    for i in $(seq 1 320); do echo "line $i"; done
  } > "$FIXTURES/research-bad.md"
  run _check_doc_type_ordering "$FIXTURES/research-bad.md"
  [ "$status" -ne 0 ]
}

@test "§6.8 PASSES decision-record with context/why first" {
  {
    echo "---"
    echo "doc-type: decision-record"
    echo "---"
    echo
    echo "# Decision Record"
    echo
    echo "*A commitment made explicit.*"
    echo
    echo "## Context"
    echo "Why this call now."
    echo
    echo "## Decision"
    echo "What we committed to."
    echo
    echo "## Consequences"
    echo "Downstream effects."
    echo
    for i in $(seq 1 320); do echo "line $i"; done
  } > "$FIXTURES/decision-ok.md"
  _check_doc_type_ordering "$FIXTURES/decision-ok.md"
}

# ─── §7 Voice and AI smell — warn-level checks ────────────────────────────
# These tests fire on warn-level violations. Voice is harder to mechanize
# than structure, so thresholds are lenient; bats failure here = strong
# signal of AI smell, not just imperfect prose.

# §7.3: em-dash density warn threshold.
# Calibration: Gary's lean FP-OS reference uses 1 em-dash per ~44 words
# (intentional stylistic compression, not smell). Genuine em-dash sandwich
# abuse runs 1 per <15 words. Threshold set to 25 words per em-dash:
# reference-style passes comfortably, real abuse fails clearly.
_check_em_dash_density() {
  local file="$1"
  local em words density_denom
  em=$(grep -o '—' "$file" | wc -l | tr -d ' ')
  words=$(wc -w < "$file" | tr -d ' ')
  [[ "$em" -eq 0 ]] && return 0  # no em-dashes is fine
  density_denom=$(( words / em ))
  # Warn threshold: < 25 words per em-dash = too dense (sandwich abuse)
  [[ "$density_denom" -ge 25 ]]
}

# §7.3: padding-phrase frequency (count in prose, exclude lines that are
# quoted anti-pattern lists — detected as table rows or heading-list
# contexts). Warn if any single phrase ≥ 3 times.
_check_padding_phrase_frequency() {
  local file="$1"
  # Single source of truth — phrases live in tests/fixtures/ai-smell-phrases/
  local phrase_file="$BATS_TEST_DIRNAME/../fixtures/ai-smell-phrases/padding-openers.txt"
  [[ -f "$phrase_file" ]] || return 1  # SoT missing is itself a failure
  local max_count=0
  while IFS= read -r phrase; do
    # Skip comments and blank lines
    [[ -z "$phrase" || "$phrase" =~ ^# ]] && continue
    # Exclude table rows and list items that quote the phrase
    local count
    count=$(grep -v '^|' "$file" | grep -v '^- \*\*"' | grep -cE "\b${phrase}" || true)
    [[ "$count" -gt "$max_count" ]] && max_count="$count"
  done < "$phrase_file"
  [[ "$max_count" -lt 3 ]]
}

@test "§7 em-dash density: reference artifact (lean FP-OS) passes" {
  local ref="/Users/garyg/Documents/Documents - SG-LT674/Claude Working Folder/first_principles_operating_system_lean.md"
  if [ ! -f "$ref" ]; then
    skip "reference file not present"
  fi
  _check_em_dash_density "$ref"
}

@test "§7 em-dash density: FAILS on fixture with em-dash sandwich at every sentence" {
  cat > "$FIXTURES/em-dash-sandwich.md" <<'EOF'
# Bad Artifact

*The answer — and this matters — is a system — designed for humans — but run by machines — that still — somehow — reads.*

The first step — and we'll get to this — is to name the problem — clearly — before — anything else.

The second step — which is equally important — involves — and this is crucial — thinking through — all of it — carefully.

The third step — which — let's be honest — is the hardest — is to write — without — these — patterns.
EOF
  run _check_em_dash_density "$FIXTURES/em-dash-sandwich.md"
  [ "$status" -ne 0 ]
}

@test "§7 padding phrases: clean artifact passes frequency check" {
  cat > "$FIXTURES/clean-voice.md" <<'EOF'
# Clean Spec

*A spec that commits.*

## Problem

Users hit friction at step three.

## Decision

Collapse step three into step two.

## Consequences

- Onboarding time drops twenty percent.
- Analytics event for step three breaks.
- Support tickets referencing step three need recategorizing.
EOF
  _check_padding_phrase_frequency "$FIXTURES/clean-voice.md"
}

@test "§7 padding phrases: FAILS on fixture with repeated padding openers" {
  cat > "$FIXTURES/padding-heavy.md" <<'EOF'
# Padded Spec

*A spec that hedges.*

## Section One

In essence, the core idea is simple.

## Section Two

Ultimately, we want to get to the root of it.

## Section Three

At its core, this is about clarity.

## Section Four

In essence, all three sections converge on the same point.

## Section Five

Ultimately, the point is that we must commit.

## Section Six

In essence, committing is what this document is about.
EOF
  run _check_padding_phrase_frequency "$FIXTURES/padding-heavy.md"
  [ "$status" -ne 0 ]
}

@test "§7 padding phrases: exemption — anti-pattern list doesn't count" {
  # A document that LISTS the anti-patterns (like this very rule) should pass.
  cat > "$FIXTURES/lists-antipatterns.md" <<'EOF'
# Anti-pattern Guide

*Names the tells.*

## The tells

Common padding openers to avoid:

- **"It's worth noting that"** — padding that announces.
- **"In essence,"** — summary-announce.
- **"Ultimately,"** — summary-announce.
- **"At its core,"** — summary-announce.

## Why they're bad

Each announces a summary instead of summarizing.
EOF
  _check_padding_phrase_frequency "$FIXTURES/lists-antipatterns.md"
}

# ─── §4 Signal calibration — decisive vs suggestive tagging ───────────────
# FP-OS §4 requires every cited signal tagged decisive or suggestive. This
# fires on decision-record artifacts (the doc-type whose reason to exist is
# taking a call on the basis of signals). Research memos, product specs, etc.
# are exempt — they surface findings, not decisions.
_check_signal_calibration() {
  local file="$1"
  local total
  total=$(wc -l < "$file" | tr -d ' ')
  [[ "$total" -lt 100 ]] && return 0  # short files exempt

  # Only fire on decision-records (declared or inferred)
  local doc_type
  doc_type=$(awk 'NR==1 && /^---$/{fm=1; next} fm && /^---$/{exit} fm && /^doc-type:/{sub(/^doc-type:[[:space:]]*/,""); print; exit}' "$file" || true)
  if [[ -z "$doc_type" ]]; then
    doc_type=$(_infer_doc_type_from_path "$file")
  fi
  case "$doc_type" in
    decision-record|decision_record) ;;
    *) return 0 ;;  # not a decision doc — not subject to §4 enforcement here
  esac

  # Require the keyword "decisive" OR "suggestive" at least once outside
  # frontmatter and outside code blocks. Checks that the author tagged signals,
  # not just that the words appear anywhere.
  local body
  body=$(awk 'NR==1 && /^---$/{fm=1; next} fm && /^---$/{fm=0; next} !fm{print}' "$file")
  if ! echo "$body" | grep -qiE '\b(decisive|suggestive)\b'; then
    return 1
  fi
  return 0
}

# ─── §I Rule-form — decision records must name their aggregation rule ──────
# FP-OS §I Layer 1 primitive 7: every well-formed decision output carries a
# rule-form "maximise X subject to Y" (or equivalent aggregation). This fires
# on decision-records: the H2 list must include a rule-shaped heading.
_check_rule_form() {
  local file="$1"
  local total
  total=$(wc -l < "$file" | tr -d ' ')
  [[ "$total" -lt 100 ]] && return 0  # short files exempt

  local doc_type
  doc_type=$(awk 'NR==1 && /^---$/{fm=1; next} fm && /^---$/{exit} fm && /^doc-type:/{sub(/^doc-type:[[:space:]]*/,""); print; exit}' "$file" || true)
  if [[ -z "$doc_type" ]]; then
    doc_type=$(_infer_doc_type_from_path "$file")
  fi
  case "$doc_type" in
    decision-record|decision_record) ;;
    *) return 0 ;;
  esac

  # Require an H2 with rule-form keyword (rule / selection / aggregation / objective)
  if ! grep -qiE '^## .*(rule|selection|aggregation|objective|criterion)' "$file"; then
    return 1
  fi
  return 0
}

@test "§4 signal calibration: decision-record WITHOUT decisive/suggestive tagging FAILS" {
  local d="$FIXTURES/outputs/think/decide"
  mkdir -p "$d"
  {
    echo "---"
    echo "doc-type: decision-record"
    echo "audience: Gary"
    echo "reader-output: picked option"
    echo "---"
    echo
    echo "# Untagged Decision"
    echo
    echo "*A commitment made without calibrated signals.*"
    echo
    echo "## Context"
    echo "Background."
    echo
    echo "## Decision"
    echo "Chose option B."
    echo
    echo "## Rationale"
    echo "Three signals pointed one way, two pointed the other."
    echo
    echo "## Selection Rule"
    echo "Picked by majority."
    echo
    for i in $(seq 1 110); do echo "line $i"; done
  } > "$d/untagged.md"
  run _check_signal_calibration "$d/untagged.md"
  [ "$status" -ne 0 ]
}

@test "§4 signal calibration: decision-record WITH decisive/suggestive tagging PASSES" {
  local d="$FIXTURES/outputs/think/decide"
  mkdir -p "$d"
  {
    echo "---"
    echo "doc-type: decision-record"
    echo "audience: Gary"
    echo "reader-output: picked option"
    echo "---"
    echo
    echo "# Tagged Decision"
    echo
    echo "*A commitment with calibrated signals.*"
    echo
    echo "## Context"
    echo "Background."
    echo
    echo "## Decision"
    echo "Chose option B."
    echo
    echo "## Rationale"
    echo "One decisive signal (regulatory block on option A) flipped the call; three suggestive signals accumulated for option B."
    echo
    echo "## Selection Rule"
    echo "Decisive signal fired → BLOCK option A; select remaining option with highest suggestive score."
    echo
    for i in $(seq 1 110); do echo "line $i"; done
  } > "$d/tagged.md"
  _check_signal_calibration "$d/tagged.md"
}

@test "§4 signal calibration: research-memo is EXEMPT (no decision)" {
  local d="$FIXTURES/outputs/think/research"
  mkdir -p "$d"
  {
    echo "---"
    echo "doc-type: research-memo"
    echo "audience: Gary"
    echo "reader-output: ranked picks"
    echo "---"
    echo
    echo "# Research Memo"
    echo
    echo "*Ranked findings.*"
    echo
    echo "## Findings"
    echo "No signal tagging required."
    echo
    for i in $(seq 1 110); do echo "line $i"; done
  } > "$d/research-exempt.md"
  _check_signal_calibration "$d/research-exempt.md"
}

@test "§I rule-form: decision-record WITHOUT rule H2 FAILS" {
  local d="$FIXTURES/outputs/think/decide"
  mkdir -p "$d"
  {
    echo "---"
    echo "doc-type: decision-record"
    echo "audience: Gary"
    echo "reader-output: picked option"
    echo "---"
    echo
    echo "# No Rule Decision"
    echo
    echo "*A decision missing the rule-form.*"
    echo
    echo "## Context"
    echo "Background."
    echo
    echo "## Decision"
    echo "Chose B."
    echo
    echo "## Consequences"
    echo "Downstream."
    echo
    for i in $(seq 1 110); do echo "line $i"; done
  } > "$d/no-rule.md"
  run _check_rule_form "$d/no-rule.md"
  [ "$status" -ne 0 ]
}

@test "§I rule-form: decision-record WITH ## Selection Rule H2 PASSES" {
  local d="$FIXTURES/outputs/think/decide"
  mkdir -p "$d"
  {
    echo "---"
    echo "doc-type: decision-record"
    echo "audience: Gary"
    echo "reader-output: picked option"
    echo "---"
    echo
    echo "# Rule-formed Decision"
    echo
    echo "*A decision with named selection rule.*"
    echo
    echo "## Context"
    echo "Background."
    echo
    echo "## Decision"
    echo "Chose B."
    echo
    echo "## Selection Rule"
    echo "Maximise expected return subject to regulatory-invariant hold AND drawdown < 20%."
    echo
    for i in $(seq 1 110); do echo "line $i"; done
  } > "$d/rule-form-ok.md"
  _check_rule_form "$d/rule-form-ok.md"
}

@test "§I rule-form: ## Aggregation Rule also satisfies the check" {
  local d="$FIXTURES/outputs/gos-jobs/job-42"
  mkdir -p "$d"
  {
    echo "---"
    echo "doc-type: decision-record"
    echo "audience: Gary"
    echo "reader-output: council verdict"
    echo "---"
    echo
    echo "# Council Synthesis"
    echo
    echo "*Multi-lane verdict synthesis.*"
    echo
    echo "## Context"
    echo "Review target."
    echo
    echo "## Verdict"
    echo "BLOCK."
    echo
    echo "## Aggregation Rule"
    echo "Overall = BLOCK iff any lane raises a decisive falsifier; CONCERN iff ≥4 lanes raise matching suggestive signal; else PASS."
    echo
    for i in $(seq 1 110); do echo "line $i"; done
  } > "$d/synthesis-rule.md"
  _check_rule_form "$d/synthesis-rule.md"
}

# Check section-sigil ban — artifacts under specs/ or outputs/think/ must not
# contain §\d patterns. Forces descriptive cross-references over legal-style
# numbering. Internal rule files, commands, and tests are exempt (author-facing).
_check_no_section_sigils() {
  local file="$1"
  # Only enforce on reader-facing artifact paths
  case "$file" in
    */specs/*|*/outputs/think/*) ;;
    *) return 0 ;;
  esac
  # Fail if any §<digit> pattern appears in the file
  if grep -qE '§[0-9]' "$file"; then
    return 1
  fi
  return 0
}

@test "section-sigil ban: spec with section sigil cross-reference FAILS" {
  local d="$FIXTURES/sigil-fail/specs"
  rm -rf "$FIXTURES/sigil-fail" && mkdir -p "$d"
  {
    echo "# Test Spec"
    echo
    echo "*A product spec that produces an engineer handoff and exists because the upstream decision landed.*"
    echo
    echo "## Overview"
    echo "Per §6.1 the positioning sentence is required."
  } > "$d/test-spec.md"
  run _check_no_section_sigils "$d/test-spec.md"
  [ "$status" -eq 1 ]
}

@test "section-sigil ban: spec without section sigils PASSES" {
  local d="$FIXTURES/sigil-pass/specs"
  rm -rf "$FIXTURES/sigil-pass" && mkdir -p "$d"
  {
    echo "# Test Spec"
    echo
    echo "*A product spec that produces an engineer handoff and exists because the upstream decision landed.*"
    echo
    echo "## Overview"
    echo "The positioning sentence is required. See the positioning-and-outline rule."
  } > "$d/test-spec.md"
  run _check_no_section_sigils "$d/test-spec.md"
  [ "$status" -eq 0 ]
}

@test "section-sigil ban: rule files and commands are EXEMPT" {
  local d="$FIXTURES/sigil-exempt/rules/common"
  rm -rf "$FIXTURES/sigil-exempt" && mkdir -p "$d"
  {
    echo "# Output Discipline"
    echo
    echo "Authors reference §1 through §7 here — internal shorthand OK."
  } > "$d/output-discipline.md"
  run _check_no_section_sigils "$d/output-discipline.md"
  [ "$status" -eq 0 ]
}

@test "section-sigil ban: outputs/think/ research artifacts fail on section sigil" {
  local d="$FIXTURES/sigil-think-fail/outputs/think/research"
  rm -rf "$FIXTURES/sigil-think-fail" && mkdir -p "$d"
  {
    echo "# Research Memo"
    echo
    echo "*A research memo that produces a ranked decision and exists because of the recent Arx forensics.*"
    echo
    echo "## Findings"
    echo "Per §6.1, the opener must..."
  } > "$d/memo.md"
  run _check_no_section_sigils "$d/memo.md"
  [ "$status" -eq 1 ]
}

# Check AC invariants/variants split — any spec with an Acceptance Criteria
# section must split it into distinct Invariants and Variants subsections.
# Promotes the "invariants before variants" rule from LLM self-judgment to a
# mechanical gate. Applies to product-spec / design-spec / build-card / strategy.
_check_ac_invariants_variants_split() {
  local file="$1"
  # Only applies to specs and design outputs
  case "$file" in
    */specs/*|*/outputs/think/decide/*) ;;
    *) return 0 ;;
  esac
  # Detect Acceptance Criteria section (case-insensitive H2 or H3)
  if ! grep -qiE '^#{2,3}[[:space:]]+(acceptance criteria|acceptance|success criteria)' "$file"; then
    return 0  # no AC section, nothing to enforce
  fi
  # AC section exists — require both Invariants and Variants subsections (case-insensitive,
  # any heading depth, or bold emphasis as subsection anchor)
  local has_invariants=0
  local has_variants=0
  if grep -qiE '(^#{2,4}[[:space:]]+invariants?\b|^\*\*invariants?\*\*)' "$file"; then
    has_invariants=1
  fi
  if grep -qiE '(^#{2,4}[[:space:]]+variants?\b|^\*\*variants?\*\*)' "$file"; then
    has_variants=1
  fi
  if [[ "$has_invariants" -eq 1 && "$has_variants" -eq 1 ]]; then
    return 0
  fi
  return 1
}

@test "AC split: spec with AC but no invariants/variants split FAILS" {
  local d="$FIXTURES/ac-flat/specs"
  rm -rf "$FIXTURES/ac-flat" && mkdir -p "$d"
  {
    echo "# Test Spec"
    echo
    echo "*A product spec.*"
    echo
    echo "## Acceptance Criteria"
    echo "- User can log in"
    echo "- Page loads in under 2 seconds"
    echo "- Error messages are friendly"
  } > "$d/flat-ac.md"
  run _check_ac_invariants_variants_split "$d/flat-ac.md"
  [ "$status" -eq 1 ]
}

@test "AC split: spec with AC split into Invariants + Variants PASSES" {
  local d="$FIXTURES/ac-split/specs"
  rm -rf "$FIXTURES/ac-split" && mkdir -p "$d"
  {
    echo "# Test Spec"
    echo
    echo "*A product spec.*"
    echo
    echo "## Acceptance Criteria"
    echo
    echo "**Invariants** (binary pass/fail):"
    echo "- User can log in"
    echo "- No data loss on refresh"
    echo
    echo "**Variants** (weighted):"
    echo "- Page loads in under 2 seconds"
    echo "- Error messages are friendly"
  } > "$d/split-ac.md"
  run _check_ac_invariants_variants_split "$d/split-ac.md"
  [ "$status" -eq 0 ]
}

@test "AC split: spec with no AC section is EXEMPT" {
  local d="$FIXTURES/ac-none/specs"
  rm -rf "$FIXTURES/ac-none" && mkdir -p "$d"
  {
    echo "# Test Spec"
    echo
    echo "*A research memo with no acceptance criteria.*"
    echo
    echo "## Findings"
    echo "Three things matter."
  } > "$d/no-ac.md"
  run _check_ac_invariants_variants_split "$d/no-ac.md"
  [ "$status" -eq 0 ]
}

@test "AC split: AC section with H3 Invariants/Variants headings PASSES" {
  local d="$FIXTURES/ac-h3/specs"
  rm -rf "$FIXTURES/ac-h3" && mkdir -p "$d"
  {
    echo "# Test Spec"
    echo
    echo "*A design spec.*"
    echo
    echo "## Acceptance Criteria"
    echo
    echo "### Invariants"
    echo "- Deterministic output"
    echo
    echo "### Variants"
    echo "- Sub-50ms response time target"
  } > "$d/h3-ac.md"
  run _check_ac_invariants_variants_split "$d/h3-ac.md"
  [ "$status" -eq 0 ]
}

@test "AC split: files outside specs/ are EXEMPT" {
  local d="$FIXTURES/ac-outside"
  rm -rf "$d" && mkdir -p "$d"
  {
    echo "# Commands doc"
    echo
    echo "## Acceptance Criteria"
    echo "- Flat list — OK because not in specs/"
  } > "$d/commands.md"
  run _check_ac_invariants_variants_split "$d/commands.md"
  [ "$status" -eq 0 ]
}

# Meta-check — Enforcement table in output-discipline.md must match the
# _check_* helpers that actually exist in both bats files. A table row that
# cites a helper not present in bats, or a bats helper absent from the table,
# fails this meta-check. Keeps the rule file honest about what's enforced.
_check_enforcement_table_matches_bats() {
  local rule_file="$1"
  local bats1="$2"
  local bats2="$3"
  [[ -f "$rule_file" ]] || return 1
  [[ -f "$bats1" ]] || return 1
  [[ -f "$bats2" ]] || return 1

  # Extract helper names cited in the Enforcement table (lines with `_check_*`)
  local claimed
  claimed=$(grep -oE '_check_[a-z_]+' "$rule_file" | sort -u)

  # Extract helper definitions from both bats files
  local defined
  defined=$( { grep -oE '^_check_[a-z_]+' "$bats1"; grep -oE '^_check_[a-z_]+' "$bats2"; } | sort -u)

  # Helpers cited but not defined anywhere in bats → false positive
  local claimed_but_missing
  claimed_but_missing=$(comm -23 <(echo "$claimed") <(echo "$defined") | grep -v '^$' || true)
  if [[ -n "$claimed_but_missing" ]]; then
    echo "Enforcement table cites helpers that don't exist in bats:"
    echo "$claimed_but_missing"
    return 1
  fi

  # Helpers defined in bats but not cited in Enforcement table → false negative.
  # No exceptions — every helper must be explicitly cited. If a helper is an
  # internal implementation detail not worth citing, rename it without the
  # `_check_` prefix (e.g., `_strip_code_blocks`).
  local defined_but_missing
  defined_but_missing=$(comm -13 <(echo "$claimed") <(echo "$defined") || true)
  if [[ -n "$defined_but_missing" ]]; then
    echo "bats defines helpers not cited in Enforcement table:"
    echo "$defined_but_missing"
    return 1
  fi

  return 0
}

@test "meta-check: Enforcement table and bats helpers match" {
  _check_enforcement_table_matches_bats \
    "$BATS_TEST_DIRNAME/../../rules/common/output-discipline.md" \
    "$BATS_TEST_DIRNAME/artifact-discipline.bats" \
    "$BATS_TEST_DIRNAME/response-discipline.bats"
}

@test "meta-check: FAILS when Enforcement table claims a nonexistent helper" {
  # Synthetic rule file that claims a helper not present in bats
  local d="$FIXTURES/meta-bogus"
  rm -rf "$d" && mkdir -p "$d"
  {
    echo "# Rule"
    echo
    echo "## Enforcement"
    echo
    echo "| Rule | Gate |"
    echo "|---|---|"
    echo "| Fake rule | \`_check_totally_fake_helper\` |"
  } > "$d/rule.md"
  # Minimal bats files without the claimed helper
  echo "_check_real_one() { return 0; }" > "$d/a.bats"
  echo "_check_real_two() { return 0; }" > "$d/b.bats"
  run _check_enforcement_table_matches_bats "$d/rule.md" "$d/a.bats" "$d/b.bats"
  [ "$status" -ne 0 ]
}

# §8 Self-congratulatory close — artifact ends with a phrase that restates /
# summarizes / congratulates instead of handing off to the reader. Check the
# last 15 non-blank, non-code-block lines.
_check_self_congratulatory_close() {
  local file="$1"
  local phrase_file="$BATS_TEST_DIRNAME/../fixtures/ai-smell-phrases/self-congratulatory-close.txt"
  [[ -f "$phrase_file" ]] || return 1
  # Last 15 non-blank, non-code-block, non-table lines
  local tail_window
  tail_window=$(awk '/^```/{in_cb=!in_cb; next} !in_cb && !/^\|/ && NF{print}' "$file" | tail -15)
  local alt
  alt=$(grep -vE '^(#|[[:space:]]*$)' "$phrase_file" | tr '\n' '|' | sed 's/|$//')
  [[ -z "$alt" ]] && return 0
  if echo "$tail_window" | grep -qiE "(${alt})"; then
    return 1
  fi
  return 0
}

# §8 Meta-about-meta — artifact opens by describing its own purpose /
# structure rather than engaging the subject. Check the first 20 non-blank,
# non-frontmatter lines after the H1.
_check_meta_about_meta() {
  local file="$1"
  local phrase_file="$BATS_TEST_DIRNAME/../fixtures/ai-smell-phrases/meta-about-meta.txt"
  [[ -f "$phrase_file" ]] || return 1
  # Head window: skip frontmatter + H1, take first 20 content lines
  local head_window
  head_window=$(awk 'BEGIN{fm=0; past_h1=0} NR==1 && /^---$/{fm=1; next} fm && /^---$/{fm=0; next} fm{next} /^# /{past_h1=1; next} past_h1 && NF{print; n++; if (n>=20) exit}' "$file")
  local alt
  alt=$(grep -vE '^(#|[[:space:]]*$)' "$phrase_file" | tr '\n' '|' | sed 's/|$//')
  [[ -z "$alt" ]] && return 0
  if echo "$head_window" | grep -qiE "(${alt})"; then
    return 1
  fi
  return 0
}

# §8 Faux-specific vagueness — phrases like "several key" / "a number of"
# that hedge where a specific count would commit. Fires when the phrase is
# NOT followed by a digit on the same line (commitment would be "3 key" or
# "seven important").
_check_faux_vague() {
  local file="$1"
  local phrase_file="$BATS_TEST_DIRNAME/../fixtures/ai-smell-phrases/faux-vague.txt"
  [[ -f "$phrase_file" ]] || return 1
  # Strip code blocks
  local prose
  prose=$(awk '/^```/{in_cb=!in_cb; next} !in_cb{print}' "$file")
  local fail=0
  while IFS= read -r phrase; do
    [[ -z "$phrase" || "$phrase" =~ ^# ]] && continue
    # Find lines containing the phrase, but not followed by a digit within same line
    if echo "$prose" | grep -iE "${phrase}" | grep -ivE "${phrase}[[:space:]]*[0-9]" > /dev/null; then
      fail=1
      break
    fi
  done < "$phrase_file"
  [[ "$fail" -eq 0 ]]
}

@test "§8 self-congratulatory close: artifact ending with 'To recap what we've accomplished' FAILS" {
  local d="$FIXTURES/congrat-close"
  rm -rf "$d" && mkdir -p "$d"
  {
    echo "# Report"
    echo
    echo "*A research memo.*"
    echo
    echo "## Findings"
    echo "Three findings."
    echo
    echo "## Close"
    echo "To recap what we've accomplished today, we shipped the campaign."
  } > "$d/close.md"
  run _check_self_congratulatory_close "$d/close.md"
  [ "$status" -ne 0 ]
}

@test "§8 self-congratulatory close: artifact ending with action handoff PASSES" {
  local d="$FIXTURES/congrat-clean"
  rm -rf "$d" && mkdir -p "$d"
  {
    echo "# Report"
    echo
    echo "*A research memo.*"
    echo
    echo "## Findings"
    echo "Three findings."
    echo
    echo "## Next action"
    echo "Run the backtest on Q2 data before deciding."
  } > "$d/clean.md"
  run _check_self_congratulatory_close "$d/clean.md"
  [ "$status" -eq 0 ]
}

@test "§8 meta-about-meta: artifact opening with 'This document sets out to' FAILS" {
  local d="$FIXTURES/meta-open"
  rm -rf "$d" && mkdir -p "$d"
  {
    echo "# Report"
    echo
    echo "This document sets out to describe the system's architecture."
    echo
    echo "## Overview"
    echo "Three components."
  } > "$d/meta.md"
  run _check_meta_about_meta "$d/meta.md"
  [ "$status" -ne 0 ]
}

@test "§8 meta-about-meta: artifact opening with mechanism PASSES" {
  local d="$FIXTURES/meta-clean"
  rm -rf "$d" && mkdir -p "$d"
  {
    echo "# Report"
    echo
    echo "*A research memo produced to identify where the auth refresh flow races.*"
    echo
    echo "## Overview"
    echo "The race happens because..."
  } > "$d/clean.md"
  run _check_meta_about_meta "$d/clean.md"
  [ "$status" -eq 0 ]
}

@test "§8 faux-vague: artifact with 'several key insights' (no count) FAILS" {
  local d="$FIXTURES/faux-vague"
  rm -rf "$d" && mkdir -p "$d"
  {
    echo "# Report"
    echo
    echo "*A memo.*"
    echo
    echo "## Findings"
    echo "The research surfaced several key insights about the system."
  } > "$d/vague.md"
  run _check_faux_vague "$d/vague.md"
  [ "$status" -ne 0 ]
}

@test "§8 faux-vague: artifact with concrete count PASSES" {
  local d="$FIXTURES/faux-specific"
  rm -rf "$d" && mkdir -p "$d"
  {
    echo "# Report"
    echo
    echo "*A memo.*"
    echo
    echo "## Findings"
    echo "Three concrete findings came out of the research."
  } > "$d/specific.md"
  run _check_faux_vague "$d/specific.md"
  [ "$status" -eq 0 ]
}

@test "meta-check: FAILS when bats defines a helper missing from Enforcement" {
  local d="$FIXTURES/meta-missing"
  rm -rf "$d" && mkdir -p "$d"
  {
    echo "# Rule"
    echo
    echo "## Enforcement"
    echo
    echo "| Rule | Gate |"
    echo "|---|---|"
    echo "| Some rule | \`_check_known_one\` |"
  } > "$d/rule.md"
  {
    echo "_check_known_one() { return 0; }"
    echo "_check_orphan_helper() { return 0; }"
  } > "$d/a.bats"
  echo "_check_other() { return 0; }" > "$d/b.bats"
  run _check_enforcement_table_matches_bats "$d/rule.md" "$d/a.bats" "$d/b.bats"
  [ "$status" -ne 0 ]
}

# ─── execution-spec voice lints (§7.1, §7.9.7) ────────────────────────────

# Strip code blocks, frontmatter, and quoted anti-pattern lists from prose
# to avoid false positives when a rule file *names* the patterns it bans.
_strip_exec_spec_noise() {
  local file="$1"
  awk '
    NR==1 && /^---$/ { fm=1; next }
    fm && /^---$/    { fm=0; next }
    fm               { next }
    /^```/           { code = !code; next }
    code             { next }
    /^[[:space:]]*[-*][[:space:]]+\*\*/ { next }   # bullet starting with bold (anti-pattern lists)
    /^[[:space:]]*\|/ { next }                      # table rows (cite anti-patterns)
    /^[[:space:]]*>/ { next }                       # quoted blocks
    { print }
  ' "$file"
}

# Process-narrative leakage — phrases that announce the document's own evolution.
# Banned in execution-spec body prose (§7.1 + §7.9.7). Phrase list:
# tests/fixtures/ai-smell-phrases/process-narrative.txt
_check_process_narrative_leakage() {
  local file="$1"
  local phrases_file="$BATS_TEST_DIRNAME/../fixtures/ai-smell-phrases/process-narrative.txt"
  [[ -f "$phrases_file" ]] || return 0

  # Only apply to execution-spec doc-type
  local doc_type
  doc_type=$(awk 'NR==1 && /^---$/{fm=1; next} fm && /^---$/{exit} fm && /^doc-type:/{sub(/^doc-type:[[:space:]]*/,""); print; exit}' "$file" || true)
  [[ "$doc_type" != "execution-spec" ]] && return 0

  local prose
  prose=$(_strip_exec_spec_noise "$file")

  # Match any phrase from the fixture (case-insensitive). One match = fail.
  local hit
  while IFS= read -r phrase; do
    [[ -z "$phrase" ]] && continue
    if echo "$prose" | grep -qiF "$phrase"; then
      hit="$phrase"
      break
    fi
  done < "$phrases_file"

  if [[ -n "$hit" ]]; then
    echo "process-narrative phrase leaked into execution-spec body: \"$hit\""
    return 1
  fi
  return 0
}

# Soft adjective without numeric — "fast", "responsive", etc. in operational
# sections (Contract / Edges / Targets / State / Open questions) without a
# digit within 30 chars. Lint-detectable per §7.1 execution-spec rubric.
# Phrase list: tests/fixtures/ai-smell-phrases/soft-adjectives.txt
_check_soft_adjective_without_numeric() {
  local file="$1"
  local phrases_file="$BATS_TEST_DIRNAME/../fixtures/ai-smell-phrases/soft-adjectives.txt"
  [[ -f "$phrases_file" ]] || return 0

  local doc_type
  doc_type=$(awk 'NR==1 && /^---$/{fm=1; next} fm && /^---$/{exit} fm && /^doc-type:/{sub(/^doc-type:[[:space:]]*/,""); print; exit}' "$file" || true)
  [[ "$doc_type" != "execution-spec" ]] && return 0

  # Extract operational sections only (between H2 matching keywords and next H2)
  local op_prose
  op_prose=$(awk '
    /^## .*[Cc]ontract/         { in_op=1; next }
    /^## .*[Ee]dge/             { in_op=1; next }
    /^## .*[Tt]arget/           { in_op=1; next }
    /^## .*[Ss]tate/            { in_op=1; next }
    /^## .*[Oo]pen [Qq]uestion/ { in_op=1; next }
    /^## /                      { in_op=0; next }
    /^```/                      { code = !code; next }
    code                        { next }
    in_op                       { print }
  ' "$file")

  [[ -z "$op_prose" ]] && return 0  # no operational sections — skip

  # Build regex of all soft adjectives (word-boundary matched)
  local adj_regex
  adj_regex=$(awk 'NF{print "\\b" $0 "\\b"}' "$phrases_file" | paste -sd'|' -)
  [[ -z "$adj_regex" ]] && return 0

  # Find lines with adjective AND no digit within the line
  local hit
  hit=$(echo "$op_prose" | grep -iE "$adj_regex" | grep -v '[0-9]' | head -1)

  if [[ -n "$hit" ]]; then
    echo "soft adjective without numeric in operational section: \"$hit\""
    return 1
  fi
  return 0
}

@test "§7.1 process-narrative: execution-spec with 'we considered' in body FAILS" {
  local d="$FIXTURES/exec-narr"
  rm -rf "$d" && mkdir -p "$d"
  {
    echo "---"
    echo "doc-type: execution-spec"
    echo "---"
    echo "# Auth handshake"
    echo
    echo "Token refresh contract for the session pipeline."
    echo
    echo "## Contract"
    echo "Originally we used JWT but switched to opaque tokens."
    echo "The endpoint accepts POST /refresh with a session cookie."
  } > "$d/spec.md"
  run _check_process_narrative_leakage "$d/spec.md"
  [ "$status" -ne 0 ]
}

@test "§7.1 process-narrative: clean execution-spec PASSES" {
  local d="$FIXTURES/exec-narr-ok"
  rm -rf "$d" && mkdir -p "$d"
  {
    echo "---"
    echo "doc-type: execution-spec"
    echo "---"
    echo "# Auth handshake"
    echo
    echo "Token refresh contract for the session pipeline."
    echo
    echo "## Contract"
    echo "POST /refresh accepts a session cookie. Returns a new opaque token."
    echo "Token TTL is 3600 seconds. Refresh window is the final 300 seconds."
  } > "$d/spec.md"
  run _check_process_narrative_leakage "$d/spec.md"
  [ "$status" -eq 0 ]
}

@test "§7.1 process-narrative: non-execution-spec doc-type is EXEMPT" {
  local d="$FIXTURES/exec-narr-exempt"
  rm -rf "$d" && mkdir -p "$d"
  {
    echo "---"
    echo "doc-type: decision-record"
    echo "---"
    echo "# Decision"
    echo
    echo "We considered three options before picking the second one."
  } > "$d/dec.md"
  run _check_process_narrative_leakage "$d/dec.md"
  [ "$status" -eq 0 ]
}

@test "§7.1 soft-adj: execution-spec with 'fast' (no number) in Contract FAILS" {
  local d="$FIXTURES/exec-soft"
  rm -rf "$d" && mkdir -p "$d"
  {
    echo "---"
    echo "doc-type: execution-spec"
    echo "---"
    echo "# API"
    echo
    echo "Endpoint contract."
    echo
    echo "## Contract"
    echo "The endpoint must be fast and responsive under load."
  } > "$d/spec.md"
  run _check_soft_adjective_without_numeric "$d/spec.md"
  [ "$status" -ne 0 ]
}

@test "§7.1 soft-adj: execution-spec with 'P95 < 200ms' (number present) PASSES" {
  local d="$FIXTURES/exec-soft-ok"
  rm -rf "$d" && mkdir -p "$d"
  {
    echo "---"
    echo "doc-type: execution-spec"
    echo "---"
    echo "# API"
    echo
    echo "Endpoint contract."
    echo
    echo "## Numeric targets"
    echo "P95 latency under 200ms; cold paint under 800ms."
    echo "Response payload under 50KB."
  } > "$d/spec.md"
  run _check_soft_adjective_without_numeric "$d/spec.md"
  [ "$status" -eq 0 ]
}

@test "§7.1 soft-adj: soft adjective in non-operational section is EXEMPT" {
  local d="$FIXTURES/exec-soft-exempt"
  rm -rf "$d" && mkdir -p "$d"
  {
    echo "---"
    echo "doc-type: execution-spec"
    echo "---"
    echo "# API"
    echo
    echo "Endpoint contract."
    echo
    echo "## Rationale"
    echo "We want this to feel fast and responsive to the user."
    echo
    echo "## Contract"
    echo "POST /api accepts JSON. P95 < 200ms. Payload < 50KB."
  } > "$d/spec.md"
  run _check_soft_adjective_without_numeric "$d/spec.md"
  [ "$status" -eq 0 ]
}

# ─── §7.9.5 length budget per doc-type ────────────────────────────────────

# Reads `doc-type:` from frontmatter and compares total line count against
# the per-type warn cap. Over-cap fails (returns 1) so /refine cycles see
# the violation. A `length-justification:` frontmatter field overrides the
# cap (returns 0 with a "warn-only override" message). Unknown or missing
# doc-type is exempt (returns 0).
_check_length_budget() {
  local file="$1"
  [[ -f "$file" ]] || return 1

  local doc_type
  doc_type=$(awk 'NR==1 && /^---$/{fm=1; next} fm && /^---$/{exit} fm && /^doc-type:/{sub(/^doc-type:[[:space:]]*/,""); print; exit}' "$file")
  [[ -z "$doc_type" ]] && return 0

  local cap
  case "$doc_type" in
    decision-record) cap=200 ;;
    research-memo)   cap=350 ;;
    discovery)       cap=300 ;;
    product-spec)    cap=500 ;;
    design-spec)     cap=600 ;;
    execution-spec)  cap=400 ;;
    strategy)        cap=400 ;;
    build-card)      cap=300 ;;
    *) return 0 ;;
  esac

  local line_count
  line_count=$(wc -l < "$file" | tr -d '[:space:]')

  if (( line_count <= cap )); then
    return 0
  fi

  local justification
  justification=$(awk 'NR==1 && /^---$/{fm=1; next} fm && /^---$/{exit} fm && /^length-justification:/{sub(/^length-justification:[[:space:]]*/,""); print; exit}' "$file")

  if [[ -n "$justification" ]]; then
    echo "warn-only override: doc-type=$doc_type cap=$cap lines=$line_count justification=\"$justification\""
    return 0
  fi

  echo "length budget exceeded: doc-type=$doc_type cap=$cap lines=$line_count"
  return 1
}

@test "§7.9.5 length budget: under-cap decision-record PASSES" {
  local d="$FIXTURES/length-under"
  rm -rf "$d" && mkdir -p "$d"
  {
    echo "---"
    echo "doc-type: decision-record"
    echo "---"
    echo "# Decision: pick X"
    echo
    echo "*A decision record committing to X over Y.*"
    echo
    echo "## Why"
    echo "X scales; Y does not. Decisive signal: throughput at 10x load."
    echo
    echo "## What"
    echo "Adopt X across the pipeline."
    echo
    echo "## Consequences"
    echo "Migration cost is one sprint."
  } > "$d/dec.md"
  run _check_length_budget "$d/dec.md"
  [ "$status" -eq 0 ]
}

@test "§7.9.5 length budget: over-cap decision-record FAILS" {
  local d="$FIXTURES/length-over"
  rm -rf "$d" && mkdir -p "$d"
  {
    echo "---"
    echo "doc-type: decision-record"
    echo "---"
    echo "# Decision"
    echo
    # 250 filler lines — well over the 200 cap for decision-record
    for i in $(seq 1 250); do echo "Line $i of decision rationale prose."; done
  } > "$d/dec.md"
  run _check_length_budget "$d/dec.md"
  [ "$status" -ne 0 ]
  [[ "$output" == *"length budget exceeded"* ]]
  [[ "$output" == *"decision-record"* ]]
}

@test "§7.9.5 length budget: over-cap with length-justification PASSES" {
  local d="$FIXTURES/length-justified"
  rm -rf "$d" && mkdir -p "$d"
  {
    echo "---"
    echo "doc-type: decision-record"
    echo "length-justification: bundles three subsidiary decisions; splitting would lose cross-references"
    echo "---"
    echo "# Decision bundle"
    echo
    for i in $(seq 1 250); do echo "Line $i of decision rationale prose."; done
  } > "$d/dec.md"
  run _check_length_budget "$d/dec.md"
  [ "$status" -eq 0 ]
  [[ "$output" == *"warn-only override"* ]]
}
