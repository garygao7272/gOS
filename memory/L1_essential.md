---
name: L1 Essential Story
description: Active project state, active feedback rules, live gaps. Updated every session. ≤800 tokens / ≤80 lines.
type: project
layer: L1
valid_from: 2026-04-17
valid_to: open
---

# Active State — gOS

## Current Focus

**Tier 1 cleanup + Claude Code Apr 2026 upgrades** (2026-04-17). PreCompact hard-block hook shipped (Item 1, 8/8 bats green). Now executing Tier 1: prompt cache TTL, MCP pruning, trash archive, L1 trim, python→jq in hook-utils, xhigh adjudicator.

## Active Feedback Rules

- **Lean & smart** — No token bloat, no over-engineering, shell > Python when sufficient.
- **Stop hook default-skip** — Silent exit. Full persist ONLY on /gos save or stale-session resume (>4h).
- **Conservative hook rollout** — one hook at a time, tested.
- **Resume: story-first** — ONE thing next, not an open menu.
- **Always sync after editing gOS** — cp commands + hooks to ~/.claude/ or health gate warns.
- **Archive, don't delete** when removing files with any reference.
- **Retry transient failures once** before diagnostic rabbit-holes.

## Known Live Gaps

- **Scratchpad Mode drift**: something resets `sessions/scratchpad.md` Mode line; workaround = append `PHASE_GATE_SKIP`. Root cause unknown.
- **Evolve T1 session-only**: 4h CronCreate audit dies on session exit. Fix = launchd plist (~30 min, deferred).
- **CronCreate `durable: true` bug**: accepted silently, not honored. Route around via launchd.
- **gos-plugin-build/** is the **distributed marketplace artifact** — keep tracked in git.

## Next Session Candidates

1. Continue Tier 2 (EnterWorktree path, /review ultra delegation, hook dedupe) — see outputs/think/discover/cc-2026-04-upgrades-impl-plan.md
2. Evolve launchd plist for true 4h audit persistence
3. Arx Radar Leaders S0-S4 redesign (first real test of phase gates + handoffs)
