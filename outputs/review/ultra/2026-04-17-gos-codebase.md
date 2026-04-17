---
owner: gos
last_updated: 2026-04-17
review_type: ultra (multi-agent codebase sweep)
scope: [commands/, agents/, .claude/hooks/, tools/, settings/]
agents: [shell-audit, markdown-audit, enforcement-trace]
confidence: high
status: CONCERN
---

# /review ultra — gOS codebase sweep — 2026-04-17

## Verdict: **CONCERN**

Code is functional but **3 enforcement mechanisms are broken** (they warn instead of block), **~18 hook files are dead weight** (deployed but never invoked), and **4 command-markdown references are stale** (one guarantees silent failure). None of this prevents shipping — but it defeats the purpose of "harness-enforced" gOS principles if the harness isn't actually enforcing.

---

## Critical findings (ranked by blast radius)

| # | Severity | File:line | Issue | Fix |
|---|---|---|---|---|
| 1 | **CRITICAL** | `~/.claude/settings.json` | **UserPromptSubmit hook NOT WIRED.** `plan-gate-prompt.sh` exists, is executable, has a sophisticated two-phase state machine (upgraded by background hook earlier this session) — but no `UserPromptSubmit` entry in settings. Got un-wired somewhere after I added it. Plan Gate never fires on user prompts. | Re-add the `UserPromptSubmit` hook entry to `~/.claude/settings.json`. |
| 2 | **CRITICAL** | `.claude/hooks/freeze-guard.sh:28` | Blocking branch is `exit 0` instead of `exit 2`. Completely nullifies the freeze guard — every out-of-scope edit is silently allowed. | Change `exit 0` → `exit 2`. (Or delete file — it duplicates `scope-guard.sh`.) |
| 3 | **CRITICAL** | `commands/simulate.md:92` | Hardcoded path `/Users/garyg/Documents/Claude Working Folder/Dux` — actual path is `Documents - SG-LT674/...`. Every `/simulate dux` invocation silently fails. | Replace with relative or `${GOS_WORKSPACE}` reference. |
| 4 | **HIGH** | `.claude/hooks/plan-gate.sh:19` | `set -uo pipefail` missing `-e`. `jq` parse failures silently produce empty STATE → gate passes when it should block. Also, line 26 `exit 0` for no-approved-plan branch means the hook warns but doesn't block in the general case (only design-specific sub-gates exit 2). | Add `-e`; change line 26 to `exit 2` for think/build/design modes. |
| 5 | **HIGH** | `tools/health-gate.sh:85` | `bats` silently-optional — if not installed, frontmatter regression test is SKIPPED with `Tests: SKIP` and `ERRORS` not incremented. Commit passes even though the gate was supposed to block deprecated frontmatter. | Make bats a hard dependency: SKIP branch → `exit 2`, or inline the check without bats. |
| 6 | **HIGH** | `tools/sync-gos.sh:332` | `verify_sync` drift detected → `exit 1`, but exit 1 doesn't block Claude tool calls (only exit 2 in a hook does). Standalone script exit 1 is advisory. | Either wire `sync-gos.sh --verify-only` as a Bash PreToolUse hook on `git push`, or change the ship pipeline to treat exit 1 as blocking. |
| 7 | **HIGH** | `commands/gos.md:9` | Prose lists `status` as a known sub-command, but routing table (lines 19-29) only dispatches `aside` + freeform. `status` falls silently into conductor mode. | Add `## status` handler or remove from prose. |
| 8 | **HIGH** | `commands/design.md:62` | References `/design system` in the boundary block after the command explicitly split it into `add`/`sync`. Dead routing reference. | Point to `/design add` and `/design sync`. |
| 9 | **HIGH** | `commands/evolve.md:70` | Example health table includes phantom `/judge` command that doesn't exist. | Replace with real command (e.g., `/refine`). |
| 10 | **HIGH** | `tools/evolve-claw.sh:15-16` | Hardcoded absolute path + hardcoded `CLAUDE_BIN`. Breaks on any other machine; launchd cron fails silently. | Derive from `$(dirname "$0")/..`; use `command -v claude`. |

---

## Dead weight (~18 files to remove or wire)

### Delete outright — duplicates or obsolete
- **`.claude/hooks/protect-files.sh`** — explicitly superseded by `security-gate.sh` (file header says "merged"). Not in settings. Zero callers.
- **`.claude/hooks/secret-scan.sh`** — registered alongside `security-gate.sh` which runs identical patterns on the same event. Double-scans every commit.
- **`.claude/hooks/freeze-guard.sh`** — broken (exits 0 on block). `scope-guard.sh` is the live successor.

### Wire or remove (deployed but never invoked)
Synced to `~/.claude/hooks/` but zero settings.json registrations:
`auto-format.sh`, `context-recovery.sh`, `scratchpad-checkpoint.sh`, `observe.sh`, `state-tracker.sh`, `spec-drift.sh`, `file-changed-drift.sh`, `session-save.sh`, `notify.sh`, `prototype-guard.sh`, `spec-compliance.sh`, `phase-gate.sh`, `permission-denied-handler.sh`, `test-fix-loop.sh`, `middleware-chain.sh` — **15 hooks**.

Either register them (decide event + matcher per hook) or strip from the deploy set in `install.sh`.

### Obsolete in content
- `effort:` field on 6 build-squad agents (`architect.md`, `reviewer.md`, `engineer.md`, `designer.md`, `researcher.md`, `verifier.md`) — not in `REGISTRY.yaml` schema; silently ignored. Remove or add to schema.

---

## Duplication (refactor candidates)

| # | Pattern | Locations | Target |
|---|---|---|---|
| D1 | `echo "$INPUT" \| jq …` JSON parse (bypasses `hook-utils.sh`) | 13 hooks including `secret-scan`, `protect-files`, `delete-guard`, `git-safety`, `health-gate`, `accumulate`, `observe`, `error-tracker`, `loop-detect`, `read-tracker`, `spec-compliance`, `phase-gate`, `scope-guard` | Source `hook-utils.sh`, call `_parse_hook_input` |
| D2 | `CLAUDE_PROJECT_DIR:-$(pwd)` fallback | 15+ hooks/tools | Use `$HOOK_PROJECT_DIR` from hook-utils.sh:69 |
| D3 | Identical 8-pattern secret array | `secret-scan.sh:45-53` + `security-gate.sh:34-43` | Move to `SECRET_PATTERNS` in hook-utils.sh |
| D4 | scratchpad `## Plan Gate` awk parser | `plan-gate.sh:43-53` + `plan-gate-prompt.sh:62-77` | Extract `scratchpad_section()` helper |
| D5 | Intent confirmation paragraph (~30 lines) | `build.md`, `design.md`, `think.md`, `simulate.md`, `review.md` | Shared rule + one-line reference |
| D6 | File-to-spec mapping (Arx mobile) | `file-changed-drift.sh` + `post-commit-detect.sh` | Consolidate into one lookup |

---

## Advisory-posing-as-enforcement

Three mechanisms where the docs say "block" but the code says "warn":

1. **`plan-gate.sh`** — header says "Blocks edits during /think, /build, /design until plan approved." Only design sub-gates actually block (exit 2). General mode exits 0.
2. **`sync-gos.sh`** — comment says "/ship gos blocks if drift detected." `verify_sync` returns non-zero → script exits 1 → no hook-level blocking.
3. **`health-gate.sh`** — warnings section summary text implies blocking, but only `$ERRORS -gt 0` exits 2. Drift warnings, test failures (when bats missing), and L1 size are `exit 0`.

---

## Ranked action list (top 10, highest leverage first)

| Rank | Fix | File | Effort | Impact |
|---|---|---|---|---|
| 1 | Re-wire `UserPromptSubmit` hook in `~/.claude/settings.json` | settings | 2 min | Restores entire Plan Gate enforcement chain |
| 2 | `freeze-guard.sh:28` exit 0 → 2 (or delete file) | 1 line | 1 min | Makes freeze block actually block |
| 3 | `simulate.md:92` fix Dux path | 1 line | 1 min | Makes `/simulate dux` work |
| 4 | `plan-gate.sh:19` add `-e`; line 26 `exit 0` → `exit 2` | 2 lines | 2 min | Makes general plan gate actually block |
| 5 | Delete `protect-files.sh` + `secret-scan.sh`, remove from settings | 2 files + 1 settings edit | 5 min | Removes ~160 lines dead code + stops double-scan |
| 6 | Wire-or-delete the 15 unused hooks | settings + install.sh | 20 min | Clarifies deployment contract; reduces noise |
| 7 | `health-gate.sh` make bats hard req (SKIP → exit 2) | 3 lines | 2 min | Frontmatter regression actually enforced |
| 8 | `sync-gos.sh` exit 1 → 2 on drift, wire as hook | 5 lines + settings | 10 min | Drift blocks ship |
| 9 | `evolve-claw.sh` derive GOS_DIR from script path | 5 lines | 3 min | Launchd portable |
| 10 | Extract intent-confirmation to shared rule | 5 command files + 1 rule | 15 min | Reduces per-command context ~150 tokens × 5 |

**Quick wins (1-5 min each):** #1, #2, #3, #4, #7, #9 — six fixes restore enforcement parity for total ~15 min of work.

---

## Confidence

**High (>90%)** on all findings. Each was verified by direct file reads and cross-checked against settings.json wiring. UserPromptSubmit un-wiring confirmed by live `python3` check of settings.json during synthesis. Exit-code semantics verified against Claude Code hooks contract (exit 0 = allow, exit 2 = block with stderr as reason).

---

## WRAP

**CONFIDENCE:** high.

**WHY:** three independent sonnet agents converged on overlapping findings (e.g., both agent A and agent C identified `plan-gate.sh` exit-0 issue). Overlap = evidence of real defects, not hallucination. File:line citations all checkable.

**NEXT:**
1. Fix the top 6 quick wins (~15 min): re-wire UserPromptSubmit, fix freeze-guard, fix Dux path, fix plan-gate exit codes, bats-hard-dep, evolve-claw paths.
2. Decide the 15 unwired hooks in bulk: register or delete — don't leave them in limbo.
3. Do not ship any "enforcement" claim until the top 6 are done — the framework's enforce-at-harness promise is currently ~50% true.
