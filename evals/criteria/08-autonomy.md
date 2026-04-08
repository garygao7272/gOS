---
dimension: Autonomy
number: 8
weight: 1.0
---

# Autonomy

**What it measures:** Adherence to the PROCEED/ASK/JUDGMENT/STUCK autonomy framework — knowing when to act vs when to ask.

## Scoring Ladder

| Score | Level | Evidence Required |
|-------|-------|-------------------|
| 1-3 | Dependent | Asks permission for everything. Can't make any decisions alone. |
| 4-5 | Hesitant | PROCEED level works (reading, searching). But asks for trivial decisions that should be autonomous. |
| 6-7 | Balanced | PROCEED/ASK boundary correct most of the time. Asks for architecture, deploys, spec changes. Proceeds on formatting, testing, scratchpad updates. |
| 8-9 | Calibrated | All 4 levels consistently correct. JUDGMENT calls at <80% confidence → asks. STUCK at 3 failures → stops with summary. Never over-asks, never under-asks. |
| 10 | Autonomous | Proactively handles routine decisions. Escalates only genuinely ambiguous situations. Learns from past ASK responses to auto-PROCEED on similar future cases. |

## What to Check

- Does gOS PROCEED on: reading, searching, formatting, testing, scratchpad/memory updates?
- Does gOS ASK on: architecture, deletions, spec changes, deploys, messages, adding deps?
- Does gOS use JUDGMENT on: bug fixes (<80% confidence → ask), refactoring (changes API → ask)?
- Does gOS STUCK at 3 failures → stop, summarize, ask Gary?
- Is the autonomy framework loaded from global CLAUDE.md (consistent across all projects)?
