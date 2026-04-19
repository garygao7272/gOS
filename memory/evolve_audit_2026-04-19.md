---
doc-type: research-memo
audience: Gary (gOS author)
reader-output: prioritized list of gOS upgrades to ship or defer
---

# gOS Health Audit — 2026-04-19

*Audit covering 2026-04-08 → 2026-04-19 (11 days, 87 shipped commits, 27 real signals + 54 session-end noise entries). Produces: ranked list of upgrades to ship, with feedback captured inline per §2026-04-08 deferred-capture lesson.*

**Covers:** verdict · command health · shipping stats · decisive signals · ranked recommendations · feedback captured · audit marker.

## Verdict

gOS is shipping hard (8× commit velocity vs. prior audit) and the output-discipline substrate just landed, but **the signal capture loop is self-polluting**: 2 session-end noise entries for every real signal. Three decisive signals fired but none made it into `memory/` until this audit. Auto mode says act — capture them now.

## Command health (real signals only, session-end noise excluded)

| Command / Surface | Uses | Accept | Rework | Reject | Love | Repeat | Health | Note |
|---|---|---|---|---|---|---|---|---|
| `/gos aside` | 2 | 2 | 0 | 0 | 1 | 0 | **125%** | Protect — `love` signal |
| `/gos briefing` | 1 | 1 | 0 | 0 | 0 | 0 | 100% | — |
| `/ship commit` / `push` | 3 | 3 | 0 | 0 | 0 | 0 | 100% | Working as spec'd |
| `install.sh` / reproducibility | 1 | 1 | 0 | 0 | 0 | 0 | 100% | — |
| `/think research` | 2 | 2 | 0 | 0 | 0 | 0 | 100% | Simplify-parity + today's 4-lens |
| Karpathy absorption edits | 1 | 1 | 0 | 0 | 0 | 0 | 100% | — |
| `/gos conductor` (evolve-jobs cadence) | 2 | 0 | 2 | 0 | 0 | 0 | **0%** | Over-cautious on a stated-preference |
| scout-type agent recommendations | 4 | 0 | 3 | 0 | 0 | 1 META | **0%** | 3/4 false positives — decisive |
| phase-gate hook (scratchpad drift) | 2 | 0 | 0 | 0 | 0 | 2 | **REPEAT** | Unresolved 4+ days — fired live in this audit |
| Stop hook (auto-persist enforcement) | 2 | 0 | 1 | 0 | 0 | 2 | **REPEAT + reframed** | Rule itself was overridden |
| `CronCreate --durable:true` | 1 | 0 | 0 | 1 | 0 | 0 | **REJECT** | Silently ignored |

Commands with <2 invocations since last audit are excluded from health% per spec.

## Shipping stats

- **Commits:** 87 since 2026-04-08 (vs ~10 in prior 7-day window — 8× velocity)
- **Dominant themes:** FP-OS substrate (today), Independent Review Council, refine taxonomy, hook cleanup-zone, artifact discipline, visual aids, output discipline
- **Today alone:** 13 framework commits, all output-discipline / response-discipline
- **Signal-to-commit ratio:** 27 real / 87 commits = 31% — only 1 in 3 shipped commits produced an explicit signal
- **Signal log density:** 27 real + 54 session-end = 67% noise

## Decisive signals (flip-the-call-alone)

1. **`reject` on `CronCreate --durable:true` silent-degradation** (2026-04-15 13:35) — flag was passed, tool returned success, but `scheduled_tasks.json` never written. Meta-signal: flags that don't take must error, not silently degrade. *Still unresolved — T1 evolve audit cron was running but not persisted across reboots.*

2. **3/4 false positives on scout-type agents** (2026-04-15 12:42–12:46) — vocab-sweep, 24M gitignore, plugin dupe all disproved on first-principles inspection. META signal logged at the time: "add 'verify premise before recommending' to scout-type agent contracts." *Never acted on — scout agent contracts unchanged.*

3. **`love` on `/gos aside`** (2026-04-15 13:32) — Gary opened "perfect" before pivoting. Pattern to protect: read-only, offer resume, surface real gaps with file:line diffs.

## Recurring issues (repeat signals — ≥2 same session)

1. **Phase-gate hook scratchpad reset** (2026-04-15 10:15, 12:15, *fired again live in this audit at 15:49 Apr 19*) — scratchpad mode keeps drifting to `/build feature` or `/design card` mid-session; required `PHASE_GATE_SKIP` append. Deferred 4 days ago with "investigate who resets scratchpad." Now escalated to HIGH — three separate audit/work sessions blocked by the same bug.

2. **Stop hook over-firing** (2026-04-15 13:47, 13:51) — caught Claude on a pure-planning turn with no changes. Gary reframed rule on Apr 15: signal capture only on `/gos save` or `>4h` stale. *Feedback file `feedback_stop_hook_compliance.md` was noted stale but not updated in memory.*

## Ranked recommendations

| # | Recommendation | Leverage | Effort | Action |
|---|---|---|---|---|
| 1 | **Strip session-end auto-entries from `sessions/evolve_signals.md`** — they pollute every future audit at 2:1 ratio | HIGH | S | Edit the hook that writes `session-end` signals; redirect to `sessions/activity.log` (append-only, not signal) or drop entirely |
| 2 | **Add "verify premise before recommending" to scout-type agent contracts** — 3/4 false-positive rate is decisive, META signal sat unactioned for 4 days | HIGH | S | Edit `agents/scout*.md` (or equivalents in pool) — inject `BEFORE recommending: verify premise with direct file read or command run` clause |
| 3 | **Fix phase-gate scratchpad drift** — fired *live during this audit*, now 3rd confirmed occurrence across sessions | HIGH | M | Grep `sessions/scratchpad.md` write-paths across hooks, find resetter |
| 4 | **Fix CronCreate durable silent-degradation OR switch to native launchd plist** | HIGH | M | Either bug-report the tool or ship `launchd/*.plist` for T1 evolve-audit (Gary flagged this pending at 13:36 Apr 15) |
| 5 | **Update / invalidate `feedback_stop_hook_compliance.md`** — rule was overridden on Apr 15, still present in memory as-is | MEDIUM | S | Rewrite file with new rule: "default-skip; full persist only on /gos save or >4h stale" |
| 6 | **No signals yet on today's response-discipline linter** — flag for next audit to measure whether it catches real drift | LOW | — | Defer to next `/evolve audit` cycle |

Picks 1–4 are decisive-signal-driven; act without waiting for accumulation (per command spec).

## Feedback captured (inline, not deferred)

Three new feedback files written in this pass per §2026-04-08 deferred-capture lesson:

- `memory/feedback_scout_verify_premise.md` — new rule from META signal
- `memory/feedback_signal_log_hygiene.md` — new rule on session-end noise
- `memory/feedback_stop_hook_compliance.md` — **rewritten**, supersedes 2026-04-15 version (rule was already overridden by Gary)

## Audit marker

Signal log marked `--- AUDITED 2026-04-19 ---` at line end. Next audit should read only below this line.

## One Thing

**Phase-gate scratchpad drift fired live during this audit write.** Rec #3 is not theoretical — it's blocking real work right now. Ship it before the next audit cycle, or every audit repeats the `PHASE_GATE_SKIP` bypass dance.
