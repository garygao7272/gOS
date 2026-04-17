---
owner: gos
last_updated: 2026-04-17
review_type: ultra (R2 delta — post-fix reassessment)
scope: [commands/, agents/, .claude/hooks/, tools/, settings/]
baseline: outputs/review/ultra/2026-04-17-gos-codebase.md
commits_since: [857553b, fb58a0d, 74e12ab]
confidence: high
status: APPROVE-WITH-RESIDUALS
---

# /review ultra R2 — delta reassessment — 2026-04-17

## Verdict: **APPROVE WITH 3 HIGH RESIDUALS**

R1 verdict was CONCERN. Today's 10 fixes closed **3 of 3 CRITICAL** and **5 of 6 broken enforcement mechanisms**. The gOS "harness-enforced" promise moved from ~50% true (R1) to ~90% true (R2). But this session's new code introduced **3 HIGH bugs** — most notably the mirror of the `evolve-claw.sh` portability bug in the brand-new `gos-drift-gate.sh`. Same class of error re-committed in the same session. Quick to fix; worth flagging as a pattern.

---

## Delta summary

| Category | R1 | R2 |
|---|---|---|
| CRITICAL fixed | — | 3 / 3 |
| HIGH fixed | — | 4 / 7 |
| Enforcement BROKEN → ENFORCING | — | 5 / 6 |
| New mechanisms validated | — | 1 (gos-drift-gate) |
| NEW HIGH bugs introduced | — | 3 |
| NEW MEDIUM bugs introduced | — | 2 |

---

## CLOSED (verified by R2)

| # | Prior finding | Evidence |
|---|---|---|
| 1 | UserPromptSubmit not wired | `~/.claude/settings.json:40-45` wired ✓ |
| 2 | `freeze-guard.sh` exit 0 on block | File deleted; not in directory listing ✓ |
| 3 | `simulate.md:92` hardcoded broken Dux path | `$HOME/Documents/Documents - SG-LT674/...` ✓ |
| 4 | `plan-gate.sh` missing `-e` | `set -euo pipefail` at line 19 ✓ |
| 5 | `health-gate.sh` bats silently optional | Missing bats → `ERRORS++` → exit 2 at line 158 ✓ |
| 6 | `evolve-claw.sh` hardcoded paths | `$(dirname "$0")` + `command -v claude` ✓ |
| 7 | `protect-files.sh` + `secret-scan.sh` double-scan | Both deleted; `security-gate.sh` is sole scanner ✓ |
| 8 | `middleware-chain.sh` + `claw-runner.sh` orphans | Deleted ✓ |
| 9 | 12 unwired hooks in deploy set | Moved to `.claude/hooks/_archive/` ✓ |
| 10 | `notify.sh` unwired | Wired to Notification event ✓ |
| 11 | Intent-confirmation duplication across 5 commands | Extracted to `rules/common/intent-confirmation.md` + references ✓ |
| 12 | Plan Gate (Edit\|Write) advisory | Now exits 2 on STATE=pending ✓ |

---

## STILL OPEN (known deferred)

| Severity | File:line | Issue | Fix |
|---|---|---|---|
| HIGH | `commands/gos.md:9` | Prose lists `status` as sub-command; routing table has no handler | Add `status` row or remove from prose |
| HIGH | `commands/design.md:62` | `/design system` dead reference (command was split into add/sync) | Reference `/design add` + `/design sync` |
| HIGH | `commands/evolve.md:70` | Phantom `/judge` row in sample health table | Replace with `/refine` |
| MEDIUM | `agents/reviewer.md` vs `agents/code-reviewer.md` | Description collision — ambiguous auto-select | Differentiate: reviewer=build-squad, code-reviewer=standalone |
| MEDIUM | `agents/REGISTRY.yaml` | Missing `signal-tallier` + `feedback-miner` (referenced by `evolve.md:35-36`) | Add entries or clarify inline |
| MEDIUM | ~10 hooks | Raw `echo "$INPUT" \| jq` bypasses `hook-utils.sh` fast path | Source hook-utils + call `_parse_hook_input` |
| LOW | 6 build-squad agents | `effort:` field not in REGISTRY schema, silently ignored | Remove or add to schema |

---

## NEW findings (introduced by this session's fixes)

| # | Severity | File:line | Issue | Fix |
|---|---|---|---|---|
| 1 | **HIGH** | `.claude/hooks/gos-drift-gate.sh:28` | **Hardcoded `GOS_DIR`** — exact same portability bug the review caught yesterday in `evolve-claw.sh`. On any fresh clone or renamed path, line 29 (`[ -d "$GOS_DIR" ] \|\| exit 0`) silently bypasses the gate. Every drift check defeats itself outside Gary's current machine layout. | Replace with `GOS_DIR="$(cd "$(dirname "$0")/../.." && pwd)"` (hook lives 2 dirs deep from repo root) |
| 2 | **HIGH** | `.claude/hooks/plan-gate.sh:27-29` | `set -euo pipefail` kills the hook with **exit 1** (not 2) if `jq` parse fails on malformed `HOOK_INPUT`. CC treats exit 1 as "hook errored" → advisory, not block. Malformed input bypasses Plan Gate entirely. | Wrap each jq call in `2>/dev/null \|\| echo ""`, or source `hook-utils.sh:_parse_hook_input` (which has the safety net) |
| 3 | **HIGH** | `.claude/hooks/gos-drift-gate.sh:30` + `hook-utils.sh:69` | Scope filter compares `HOOK_PROJECT_DIR` to `$GOS_DIR` via path prefix. But `HOOK_PROJECT_DIR` falls back to `pwd` if `CLAUDE_PROJECT_DIR` is unset. Hook invocation context sometimes has `pwd` as `/` or `$HOME`, meaning legitimate gOS pushes silently pass the scope filter and drift is unchecked. | Require `CLAUDE_PROJECT_DIR`, OR detect gOS by git remote URL instead of path prefix |
| 4 | MEDIUM | `rules/common/intent-confirmation.md:3` | Rule header lists `/ship` and `/refine` as covered verbs — but `commands/ship.md` and `commands/refine.md` have no reference link to this rule. Scope mismatch on day 1 of the rule. | Either add references to ship.md + refine.md, or remove those verbs from the header |
| 5 | MEDIUM | `rules/common/intent-confirmation.md:34` | "How commands reference this rule" example template is generic 2-field `"I'll [sub-command] [target]"` — conflicts with the per-verb table above it (build has 3 fields, simulate has parameters). A future author copying the example will produce undersized confirmations. | Label example as illustrative-only, or show a verb-specific instance |
| 6 | LOW | `.claude/hooks/plan-gate-prompt.sh:79-99` | `write_plan_gate` uses `awk` → `mktemp` → `mv`. Two concurrent sessions writing the same scratchpad can race + corrupt the section. Low probability, unguarded. | `flock` the scratchpad write |
| 7 | LOW | `tools/health-gate.sh:13` | Health gate only fires on `git commit`, not `git push`. A push without intercepted commit (e.g., amending outside Claude then pushing) skips the health gate entirely. | Add `git push` trigger, or accept that security-gate + drift-gate already cover push |

---

## Pattern observation

**Same class of bug re-committed in the same session.** Yesterday's review flagged `evolve-claw.sh` for hardcoded paths (finding #10, HIGH, fixed in `857553b`). Today's new `gos-drift-gate.sh` (in `fb58a0d`) repeats the same hardcoding — the fix pattern (`$(dirname "$0")`) was fresh in scope but wasn't applied to the new hook.

Signal for future: when writing a new hook or script in gOS, apply the portability-path pattern by default. Worth a `rules/common/shell-script-portability.md` entry if this repeats a third time.

---

## Top 3 residual fixes by leverage

| # | Fix | Effort | Impact |
|---|---|---|---|
| 1 | `gos-drift-gate.sh:28` — derive `GOS_DIR` from `$(dirname "$0")/../..` | 1 line | Makes the brand-new drift gate actually functional across environments. Highest blast radius. |
| 2 | `plan-gate.sh:27-29` — wrap jq in safety net OR use `_parse_hook_input` | 3 lines | Fixes Plan Gate bypass on malformed hook input. |
| 3 | `commands/gos.md:9` + `commands/evolve.md:70` + `commands/design.md:62` — fix the 3 known-stale references | 3 × 1 line | Clears the deferred HIGH docs queue in one doc-only commit. |

---

## WRAP

**CONFIDENCE: high.** Each finding has file:line + direct file-read evidence. Agent convergence on gos-drift-gate scope issue (both shell + enforcement agents flagged it from different angles) strengthens confidence.

**WHY:** The 10 R1 fixes landed correctly — enforcement-trace agent independently verified 5 mechanisms moved BROKEN → ENFORCING. The 3 NEW HIGH bugs are narrow: drift-gate hardcoded path (1 line fix), plan-gate jq safety (3 line fix), drift-gate scope semantics (requires small design choice).

**NEXT:**
1. **Fix the 3 NEW HIGH residuals** — all in one small commit. ~10 min total.
2. **Optional: fix the 3 still-open doc references** (gos.md status, design.md system, evolve.md judge) — doc-only commit, no enforcement risk.
3. **Pattern memo**: consider capturing the portability-path rule in `rules/common/` so the next new hook doesn't repeat this.

Want me to execute #1 + #2 as a single fix pass?
