---
doc-type: decision-record
audience: gOS framework maintainer (Gary + future agents)
reader-output: a checklist of CC 2.1.119 follow-ups with adoption decisions and verification steps
---

# Claude Code 2.1.119 — gOS adoption decisions

This decision record exists because the upgrade from CC 2.1.111 → 2.1.119 (performed 2026-04-25) unlocked five primitives, three of which require explicit gOS adoption and two of which are already addressed. It exists now so that the next session — which will be the first to actually run the new binary — knows what to verify and what was deliberately deferred.

**Covers:** what was adopted in-session · what was deferred · post-restart verification checklist · consequences.

## Decisions

| Primitive | Adopted in-session | Decision | Rationale |
|---|---|---|---|
| `duration_ms` in PostToolUse hooks | Yes | Wired into `accumulate.sh` and `error-tracker.sh`. Log format gained a `\|duration_ms` column. | Decisive signal: zero-cost, unlocks evolve-loop tool-cost analysis. |
| `type: "mcp_tool"` in hooks | No | Deferred until a concrete need arises. | Suggestive only: no current gOS bash hook wraps an MCP call (all are policy gates: plan, delete, git, security, health, drift, scope, read, loop). The primitive is now available and should be reached for *first* the next time a new hook needs an MCP-side effect (e.g. posting to scheduled-tasks, reading a memory MCP). Pre-emptive conversion is busywork. |
| `claude plugin tag` for `gos-plugin-build/` | No | Defer to next plugin release | Suggestive: current plugin versioning is git-history-based and works. Adopt at the next material release — at that point the `claude plugin tag <semver>` command becomes the canonical version source and the plugin's `settings.json` `version` field gets cross-checked against it. Recipe for the next release: `claude plugin tag <semver>` from `gos-plugin-build/`, then commit the resulting tag artefact alongside the version bump. |
| Worktree reuse fix (2.1.119) | Pending verify | Verify on next `/refine` cycle | Decisive bug fix that affects the `/refine` executor spawn path. Needs a real cycle to confirm — see post-restart checklist below. |
| Opus 4.7 `/context` percentage fix (2.1.117) | Already in 2.1.119 | No action | Inherited automatically with the upgrade. Sessions on Opus 4.7 should now show correct context% against the 1M ceiling. |

## Post-restart verification checklist

Run on the first new session after restarting the CLI (the running session is still on 2.1.111 in memory).

- [ ] `claude --version` reports `2.1.119`.
- [ ] Run any `/refine` cycle that re-spawns an executor — confirm worktree is reused (look for `EnterWorktree { path: <existing> }` rather than a fresh clone).
- [ ] Trigger any Edit on a tracked file. Inspect `/tmp/gos-edits-<session>.log` — last column should be a non-zero `duration_ms`.
- [ ] Trigger any tool failure. Inspect `/tmp/gos-loop-detect-<session>.log` — last column should be a non-zero `duration_ms`.
- [ ] On an Opus 4.7 session, check `/context` reports correctly against the 1M ceiling, not 200k.

## Consequences

- **Hook telemetry shape changed.** Any downstream consumer of `/tmp/gos-edits-*.log` or `/tmp/gos-loop-detect-*.log` must tolerate the new third column. Today the only known consumer is the daily-evolve scan, which already field-splits — additional fields are ignored.
- **`/ship` review-gate prompt now mentions `/ultrareview`** for diffs ≥ 10 files / ≥ 500 LOC. Small-diff path (`/review code`) unchanged.
- **Arx council agents now run at `effort: medium`** (previously inheriting CC 2.1.117's bumped default of `high`). Council-review cost should drop noticeably; quality should be re-evaluated after the next `/review council` cycle. If quality regresses, lift to `high` — the synthesizer is already pinned at `high`.
- **One leftover npm install** at `/usr/local/bin/claude` is shadowed by the native install at `/Users/garyg/.local/bin/claude`. Cleanup is `npm -g uninstall @anthropic-ai/claude-code` — left to the next cleanup pass since destructive npm should not run unprompted.

## How to use this doc

The checklist is the action surface — work it on the next session start. Once all items pass, archive this doc to `outputs/think/research/`. If any item fails, capture the failure mode in `outputs/think/research/cc-2-1-119-followup-postmortem.md` and revert the corresponding adoption.
