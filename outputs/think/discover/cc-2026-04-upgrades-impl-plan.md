# Implementation Plan — Claude Code Apr 2026 Upgrades for gOS

**Status:** Draft (workshop)
**Date:** 2026-04-17
**Source:** /think output mapping CC v2.1.111+ features → gOS
**Scope:** 3 High + 1 Medium items. Each = atomic ticket with regression tests.

---

## Item 1 — PreCompact hard-block hook (HIGH)

### Problem
Current `.claude/settings.json` PreCompact hook is `prompt`-type — asks Claude to save signals but cannot enforce. CC v2.1.111+ supports **command-type** PreCompact hooks that block compaction via exit code 2 / `{decision:"block"}`. Today, `evolve_signals.md` regularly drops mid-session.

### Implementation

**Files to change:**
- `tools/save-signals.sh` (NEW) — extract & flush signals + scratchpad checkpoint
- `.claude/hooks/precompact-save.sh` (NEW) — wrapper, exits 2 on failure
- `.claude/settings.json` — replace prompt hook with command hook (keep prompt as fallback warning)
- `tests/hooks/precompact-save.bats` (NEW)

**`tools/save-signals.sh` contract:**
```bash
#!/usr/bin/env bash
# Inputs: stdin = transcript JSON from CC PreCompact event
# Outputs: appends to sessions/evolve_signals.md, updates sessions/scratchpad.md
# Exit: 0 on success, 2 on validation failure (blocks compaction)
set -euo pipefail
TRANSCRIPT="${1:-/dev/stdin}"
LOG="sessions/evolve_signals.md"
SCRATCH="sessions/scratchpad.md"
# 1. Append timestamped checkpoint marker
# 2. Update scratchpad Context field -> POST-COMPACTION
# 3. Verify both files writable; exit 2 if not
```

**settings.json delta:**
```json
"PreCompact": [{
  "hooks": [
    {"type": "command", "command": ".claude/hooks/precompact-save.sh", "timeout": 10},
    {"type": "prompt", "prompt": "Verify scratchpad reflects current task state.", "once": true}
  ]
}]
```

### Regression tests (`tests/hooks/precompact-save.bats`)

| # | Test | Expected |
|---|---|---|
| 1 | Hook runs against fixture transcript with 3 signals | Exit 0; 3 lines appended to evolve_signals.md |
| 2 | Hook with read-only sessions/ dir | Exit 2; stderr contains "cannot write" |
| 3 | Hook with malformed transcript JSON | Exit 2; no partial writes |
| 4 | Idempotency: run twice, same input | No duplicate signal entries |
| 5 | Scratchpad Context field updated to `POST-COMPACTION` | grep matches |
| 6 | settings.json schema valid (`jq`) | Exit 0 |

**Effort:** 45 min. **Risk:** low.

---

## Item 2 — `/review ultra` delegation (HIGH)

### Problem
gOS `/review council` reimplements parallel multi-agent review (~200 lines of orchestration). CC v2.1.111 ships native `/ultrareview` doing this for code.

### Implementation

**Files to change:**
- `commands/review.md` — add `ultra` sub-command that delegates to native `/ultrareview` for code-only paths
- Keep `/review council` for strategy/spec/persona reviews (unique to gOS)
- `evals/rubrics/review-ultra.md` (NEW)
- `tests/commands/review-ultra.bats` (NEW)

**Routing logic:**

| Sub-command | Delegate to | When |
|---|---|---|
| `ultra <files>` | native `/ultrareview` | code-only review of staged/diff'd files |
| `council <topic>` | gOS persona swarm | strategy, spec, UX |

**Decision rule:** input is file paths or `git diff` -> ultra. Topic/question -> council.

### Regression tests

| # | Test | Expected |
|---|---|---|
| 1 | `/review ultra src/foo.ts` invokes native `/ultrareview` | stdout shows native preamble |
| 2 | `/review council copy-trading-trust` stays in gOS council flow | spawns >=2 personas |
| 3 | `/review ultra` with no files errors clearly | "specify files or diff" |
| 4 | Eval rubric exists and scores >=8 on golden input | rubric runs clean |
| 5 | review.md command-frontmatter test passes | existing bats green |

**Effort:** 30 min. **Risk:** low (additive).

---

## Item 3 — `xhigh` effort for `/refine` adjudicator (HIGH)

### Problem
`/refine` Phase N adjudicator currently uses opus at default effort. New `xhigh` tier (between high and max) gives better convergence verdicts at lower cost than max.

### Implementation

**Files to change:**
- `commands/refine.md` — adjudicator spawn line: add effort hint
- `agents/pev-validator.md` — note effort default
- `tests/commands/refine.bats` (NEW or extend)

**Delta:** in the adjudicator Agent() call, set effort metadata. Document in the depth ladder table that adjudicator runs at `xhigh`.

### Regression tests

| # | Test | Expected |
|---|---|---|
| 1 | Refine loop on golden topic converges in <=3 cycles | exit reason = CONVERGED |
| 2 | Adjudicator output cites effort=xhigh in metadata | grep matches |
| 3 | Cost-per-cycle within 80% of opus-high baseline | numeric assertion |
| 4 | Fallback if xhigh unavailable: degrade to high (not max) | mock-test |

**Effort:** 20 min. **Risk:** very low.

---

## Item 4 — Plan auto-naming convergence (MEDIUM)

### Problem
CC v2.1.111 auto-names plan files (`fix-auth-race-snug-otter.md`). gOS `sessions/handoffs/*.json` uses different scheme. `/gos resume` could read native plans if conventions align.

### Implementation

**Files to change:**
- `tools/handoff-name.sh` (NEW) — generate slug matching CC's pattern: `{verb}-{slug}-{adj}-{noun}.json`
- `commands/gos.md` — `resume` reads both `sessions/handoffs/*.json` AND `~/.claude/plans/*.md`
- `specs/handoff-schemas.md` — document naming convention
- `tests/tools/handoff-name.bats` (NEW)

**Slug generator contract:** input = task description, output = `kebab-case-snug-otter` slug deterministic given input + date.

### Regression tests

| # | Test | Expected |
|---|---|---|
| 1 | Same input twice -> same slug | deterministic |
| 2 | Slug matches `^[a-z0-9-]+-[a-z]+-[a-z]+$` | regex pass |
| 3 | `/gos resume` finds both handoff JSON and CC plan files | listing combines both |
| 4 | Handoff schema doc updated, INDEX.md links resolve | spec-freshness clean |

**Effort:** 60 min. **Risk:** medium (touches resume flow).

---

## Cross-cutting regression: full hook + command suite

After all 4 items land, run as gate:

```bash
bash tools/health-gate.sh
bats tests/hooks/
bats tests/commands/
bash tools/coverage-matrix.sh
bash tools/spec-freshness.sh
```

**Acceptance:** zero new failures vs. pre-change baseline. New tests added to CI.

---

## Sequencing recommendation

1. **Item 3** (20 min) — lowest risk, immediate cost win
2. **Item 1** (45 min) — highest user-pain reduction
3. **Item 2** (30 min) — code-quality lift
4. **Item 4** (60 min) — convergence polish, can defer

Total: ~2.5 hours of focused build + test time.

---

## Open questions (verify before Item 1)

1. Does CC PreCompact command hook receive transcript via stdin or as `$1` path?
2. Is `/ultrareview` available outside Max plans? (gate ultra sub-command if not)
3. Is `xhigh` accessible via Agent() spawns or only top-level effort?

5-min docs read should resolve these before starting Item 1.
