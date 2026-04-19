# Signal log hygiene — session-end auto-entries are noise, not signal

**Captured:** 2026-04-19 (from this audit — 54 session-end entries vs 27 real signals since last audit)

## Rule

`sessions/evolve_signals.md` contains **real signals only** (accept / rework / reject / love / repeat / skip on a specific command output). Session-boundary events (stop, start, compact) go to a separate `sessions/activity.log`, not the signal log.

## Why

Between 2026-04-08 and 2026-04-19, the signal log accumulated:

- **27 real signals** — actionable feedback on specific command outputs
- **54 session-end auto-entries** — all identical format: `| DATE | TIME | gOS | /<cmd> | session-end | Auto-captured at session stop |`

Ratio: 2:1 noise to signal. Every `/evolve audit` since the auto-capture hook shipped has had to filter out the noise before finding the real signals. Pattern from FP-OS K3: a signal that doesn't distinguish is no signal at all.

Signal capture only fires correctly on:
- `/gos save` (Gary's explicit persist)
- Stale-resume (>4h since last save)
- Manual signal-log append during real feedback moments

**Auto-capture on session stop is not a signal — it's an activity marker.**

## How to apply

1. **Stop writing session-end entries to `sessions/evolve_signals.md`.** Find the hook (likely `.claude/hooks/session-stop-gate.sh` or `precompact-save.sh`) and redirect its write path.
2. **New file: `sessions/activity.log`** — append-only log of session-boundary events. Format: `<ISO-8601> <event-type> <command> <project>`. Not read by `/evolve audit`.
3. **Retrofit:** next `/evolve audit` tallier should auto-skip any line matching `| session-end |` pattern.

## Related

- `feedback_stop_hook_compliance.md` — Gary's rule on when signals should fire (only on `/gos save` or >4h stale)
- `feedback_lean_smart.md` — no token/data bloat
