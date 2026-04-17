---
name: review-ultra
command: /review ultra
effort: low
---

# Eval Rubric: /review ultra

## Dimensions

| Dimension | Weight | 1-3 (Poor) | 4-6 (Adequate) | 7-8 (Good) | 9-10 (Exceptional) |
|-----------|--------|-----------|----------------|-----------|-------------------|
| Routing correctness (30%) | 30 | Routed topic/strategy question to ultra, or routed code diff to council | Right call on obvious inputs only | Consistent routing by input type (paths/diff → ultra; topic → council) | Also surfaces edge cases (e.g., "paths + strategy question" → suggests both) |
| Delegation fidelity (25%) | 25 | Reimplemented review instead of delegating; or silently fell through | Invoked `/ultrareview` but didn't capture output | Delegated + stored output under `outputs/review/ultra/{ts}.md` | Also annotated findings with CRITICAL/HIGH/MED and linked to `/review gate` |
| Confidence filter (15%) | 15 | Reported every finding, no filter | Filtered but no threshold stated | Dropped <80% confidence findings | Also surfaced filtered count so user can audit |
| Fallback handling (15%) | 15 | Silently failed or crashed if `/ultrareview` unavailable | Errored but unclear why | Clean error + suggested `/review code` fallback | Also detected plan tier and pre-emptively routed |
| Output persistence (15%) | 15 | No artifact saved | Saved but wrong path | `outputs/review/ultra/{timestamp}.md` with findings + input manifest | Also appended to review index for cross-session lookup |

## Anti-Pattern Flags (auto-fail to ≤4)

- Silent fallthrough when native `/ultrareview` is missing → fail
- Reimplemented parallel review instead of delegating → fail (defeats the whole sub-command)
- Returned native output verbatim without confidence filter or storage → fail

## Test Input Requirements

The test input MUST contain:
- A small staged diff (2-3 files) for happy-path
- A non-code topic (e.g., "copy trading trust model") to verify routing rejects it toward council
- A simulated "ultrareview unavailable" mock to verify fallback
