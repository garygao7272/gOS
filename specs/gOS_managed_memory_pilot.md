---
doc-type: product-spec
audience: gOS framework maintainer (Gary + future agents)
reader-output: a one-task pilot wiring Anthropic Managed Agents Memory into daily-evolve, with kill criteria
---

# Managed Agents Memory — daily-evolve pilot

This spec scopes a one-week pilot wiring Anthropic's Managed Agents Memory (public beta, header `managed-agents-2026-04-01`, announced 2026-04-23) into the `daily-evolve` scheduled task. It exists now because daily-evolve is the most session-isolated background workflow in gOS — every nightly run starts cold, re-reads `sessions/evolve_signals.md` from disk, and produces a report that the next session re-discovers via filesystem scan. Managed Memory replaces the disk round-trip with a server-managed file workspace that persists across runs.

**Covers:** scope · what changes · what stays the same · success criteria · kill criteria · rollout.

## Why daily-evolve first

| Property | Why it makes a good pilot |
|---|---|
| Runs in a fresh session every night | Maximum benefit from persistent memory |
| Read-mostly | Low blast radius if the beta misbehaves |
| Already produces a structured report | Easy to compare before/after quality |
| Single skill file | One integration point, no cross-cutting changes |

## Scope

| In | Out |
|---|---|
| `daily-evolve` skill at `~/.claude/scheduled-tasks/daily-evolve/SKILL.md` | All other scheduled tasks |
| Read + write to a Managed Memory workspace named `gos-evolve` | gOS interactive sessions (still use claude-mem) |
| Trend comparison across runs (today vs yesterday vs 7-day) | Cross-project memory sharing |

## What changes

1. Skill invocation adds `managed-agents-2026-04-01` beta header.
2. New step 0 (before current step 1): mount the `gos-evolve` memory workspace; read `state.json` + `last-7-days/` directory if present.
3. Current step 7 (write report) also writes a copy to the memory workspace under `reports/{date}.md` and updates `state.json` with the new health scores.
4. Trend comparison (current step 7 sub-bullet "Trends vs previous days") reads from memory rather than re-globbing `outputs/briefings/`.

## What stays the same

- Local report still goes to `outputs/briefings/evolve-{date}.md` (audit trail, no behaviour change).
- `sessions/evolve_signals.md` remains the source of truth for raw signals.
- Memory rules from `~/.claude/CLAUDE.md` — claude-mem stays the interactive-session memory layer.

## Success criteria (after one week)

- ≥ 5 of 7 nightly runs complete with no Managed Memory errors.
- Trend section in evolve briefing references prior runs without filesystem scan (verifiable by removing local prior briefings — pilot still produces trends).
- Memory-workspace size stays under 1 MB (no runaway growth).
- Zero loss of pre-existing audit trail (local file outputs unchanged).

## Kill criteria

- Beta header rejected → revert immediately.
- Memory writes time out > 2 nights in a row → revert and file feedback.
- Memory contents diverge from local outputs → revert; investigate divergence in next interactive session.

## Rollout

| Day | Action |
|---|---|
| 0 | Edit `SKILL.md`, add header + memory mount + write step. Snapshot pre-pilot evolve_signals + briefings. |
| 1–7 | Nightly runs. No human intervention unless kill criteria fire. |
| 8 | Review: success criteria met → keep + propose extension to one more task. Failed → revert + write findings to `outputs/think/research/managed-memory-pilot-postmortem.md`. |

## How to use this spec

Hand to a `/build feature` invocation when ready to execute the pilot. The build job edits one file (`SKILL.md`), creates the memory workspace, and updates the daily-evolve rubric to include the new memory-mount step. No code, no tests — the success criteria are operational.
