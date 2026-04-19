# Stop hook compliance — default-skip, persist only on save or stale

**Captured:** 2026-04-19 — **SUPERSEDES** prior 2026-04-15 "never skip Stop hook" version.

## Rule

Stop hook default-skips its full-persist checklist. It runs the full signal-scan + L1 check + state.json update **only** when:
- The current command is `/gos save` (explicit persist), OR
- The session is stale — more than 4 hours since the last persist

For every other turn (Q&A, briefing, planning, advisory), the Stop hook is a no-op.

## Why

On 2026-04-15 13:50, Gary reframed the Stop hook policy:

> "don't log signals every turn — default to Plan-Gate confidence + next-move. Formal signal scan only on /gos save or stale resume (>4h)."

Then at 13:51, the Stop hook fired on a **pure planning turn** (no changes landed, awaiting approval). Proved Gary's point live — the previous "never skip" rule was a noise generator. Signals captured on planning turns are meaningless (nothing happened yet), and the re-entry cost of the Stop hook wiped the planning-turn context before Gary's approval came back.

The prior version of this feedback file (2026-04-15) codified the wrong rule ("never skip"). Gary's later reframe invalidated it. This file is the replacement.

## How to apply

Stop hook logic:

```
if command == "/gos save" OR (now - last_persist_timestamp) > 4h:
    run_full_persist()  # signal scan, L1 check, state.json update, scratchpad write
else:
    skip()  # no-op; Plan-Gate confidence + next-move already captured in the turn
```

Per-turn feedback lives in the response itself (Plan Gate confidence + NEXT MOVE line). That's the lightweight signal. The Stop hook is for heavy persistence only.

## Supersedes

- Prior 2026-04-15 version of this file — was "Stop hook never skips." Rule was correct at time of capture but Gary reframed the same day; prior file was noted stale but never rewritten. This file replaces it.

## Related

- `feedback_lightweight_signaling.md` — Plan-Gate confidence + next-move is the per-turn signal
- `feedback_signal_log_hygiene.md` — session-end auto-entries ≠ signals
