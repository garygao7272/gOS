# Eval Rubric: /resume

## Dimensions

| Dimension | Weight | 1-3 (Poor) | 4-6 (Adequate) | 7-8 (Good) | 9-10 (Exceptional) |
|-----------|--------|-----------|----------------|-----------|-------------------|
| State recovery (30%) | 30 | Didn't read state.json or L1 | Read one, missed the other | state.json + L1 + latest session file all loaded | Also loaded scratchpad, verified working-dir match, flagged staleness |
| Story clarity (20%) | 20 | Process narration, not outcome | Two sentences but jargon-heavy | Two sentences, outcome-first, busy-CEO readable | Surfaces the load-bearing context a reader needs without being asked |
| Action table (20%) | 20 | No table or > 6 rows | Table present, priorities wrong or missing | Max 6 rows, `Do first` / High / Medium / Low priorities correct | Rows reflect genuine next actions, not inventory; dead-end items pruned |
| Next move (15%) | 15 | No recommendation | Recommendation but weak reasoning | Highest-priority action with 1-line reasoning | Recommendation invites redirection, not compliance |
| Staleness guards (15%) | 15 | Ignored stale state | Noted staleness but still acted on it | Surfaced stale/pending items at top; claude-mem hits cited | Project-dir mismatch, pending_approval, and >24h-old sessions all handled explicitly |

## Scoring Rules

- **State recovery** auto-fails to ≤4 if `sessions/state.json.phase != completed` and resume didn't surface `pending_approval`.
- **Story clarity** — if the reader can't articulate "what's next" after reading the story alone, score ≤5.
- **Action table** — if the reader has to read the full session file to know what to do first, score ≤5.
- **Staleness guards** — resuming a session from a different project without a warning auto-fails this dimension.

## Overall Score

Weighted average: `(state * 30 + story * 20 + table * 20 + next * 15 + staleness * 15) / 100`

- 8-10 → cold resume, hot start
- 5-7 → usable, but Gary has to reconstruct context manually
- 0-4 → re-run with proper memory/state loading first
