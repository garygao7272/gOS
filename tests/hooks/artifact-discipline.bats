#!/usr/bin/env bats
# Tests for rules/common/output-discipline.md §6 Artifact Discipline.
# These are smoke tests — they check fixtures, not live /refine runs.
# Fixtures live under tests/fixtures/artifact-discipline/.

FIXTURES="$BATS_TEST_DIRNAME/../fixtures/artifact-discipline"

setup() {
  mkdir -p "$FIXTURES"
}

# ─── Helpers ──────────────────────────────────────────────────────────────

# Check §6.1 — first content after H1 is positioning + outline (not changelog)
_check_opens_with_positioning() {
  local file="$1"
  local post_h1
  post_h1=$(awk '/^# /{found=1; next} found{print; if (NR > 20) exit}' "$file" | head -20)
  # Must NOT start with a changelog header
  if echo "$post_h1" | grep -qiE '^## (what changed|changelog|version history|deprecated)'; then
    return 1
  fi
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
