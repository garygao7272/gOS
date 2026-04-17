# Eval Rubric: /save

## Dimensions

| Dimension | Weight | 1-3 (Poor) | 4-6 (Adequate) | 7-8 (Good) | 9-10 (Exceptional) |
|-----------|--------|-----------|----------------|-----------|-------------------|
| Signal capture (30%) | 30 | Missed signals; no scan of conversation | Some signals logged, wrong types | All visible signals logged with correct types and context | Catches subtle signals (quiet acceptances, implicit reworks) + cites conversation location |
| Memory writes (25%) | 25 | No memory updates | L1 or state.json updated but not both | L1, state.json, and relevant feedback/*.md files updated | Memory entries deduplicate against existing, cross-reference other memories |
| State.json (20%) | 20 | Not written or corrupt | Written but missing `recovery_instructions` | Phase, step, files_modified, last_checkpoint all current and consistent | Recovery instructions are executable (explicit commands, not hand-waves) |
| Session file (15%) | 15 | Missing or empty | Written but vague | Task, decisions, dead ends, next steps — all present | A stranger could resume the session cold from this file alone |
| Report line (10%) | 10 | No report | Report but missing counts | One-line report with file count + signal count + L1/state deltas | Report flags anything unusual (duplicate signal, memory conflict, stale state) |

## Scoring Rules

- **Signal capture** auto-fails to ≤4 if any obvious rework/reject was missed (check against the last 10 conversation turns).
- **Memory writes** require at least L1_essential.md touched OR explicit "no memory-worthy changes" statement.
- **State.json** must be valid JSON — invalid JSON auto-fails to 0.
- **Session file** must exist at `~/.claude/sessions/{date}-{slug}.md` with all required sections.

## Overall Score

Weighted average: `(signal * 30 + memory * 25 + state * 20 + session * 15 + report * 10) / 100`

- 8-10 → clean save, nothing lost between sessions
- 5-7 → usable but some drift likely
- 0-4 → re-run — state wasn't captured faithfully
