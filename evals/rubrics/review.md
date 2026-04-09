# Eval Rubric: /review code

## Dimensions

| Dimension | Weight | 1-3 (Poor) | 4-6 (Adequate) | 7-8 (Good) | 9-10 (Exceptional) |
|-----------|--------|-----------|----------------|-----------|-------------------|
| Detection rate (30%) | 30 | Found 0/N planted bugs | Found 1/N bugs | Found N-1/N bugs | Found N/N bugs + identified root cause pattern |
| False positive rate (20%) | 20 | >3 false positives | 2-3 false positives | 0-1 false positives | Zero false positives, all findings valid |
| Fix quality (25%) | 25 | Fixes introduce new bugs | Fixes work but are hacky | Fixes are clean and correct | Fixes address root cause, add prevention |
| Prioritization (25%) | 25 | No severity classification | Severity mentioned but wrong order | Critical before medium before low | Critical found first, clear reasoning for each level |

## Test Input Requirements

The test input MUST contain:
- Exactly N planted bugs (document the count)
- A mix of severities (at least 1 critical, 1 medium, 1 low)
- Some clean code that should NOT be flagged (to test false positive rate)

## Scoring Rules

- Detection: score = (bugs_found / bugs_planted) * 10
- False positives: 10 - (false_positive_count * 2), min 1
- Fix quality: manual assessment by scoring agent
- Prioritization: did critical bugs appear before style issues?

## Overall Score

Weighted average: `(detection * 30 + false_positives * 20 + fix_quality * 25 + prioritization * 25) / 100`

---

# Eval Rubric: /review spec

## Dimensions

| Dimension | Weight | 1-3 (Poor) | 4-6 (Adequate) | 7-8 (Good) | 9-10 (Exceptional) |
|-----------|--------|-----------|----------------|-----------|-------------------|
| Dimension coverage (30%) | 30 | Scored <3 of 5 dimensions | Scored 3-4 dimensions | All 5 dimensions scored with evidence | All 5 + suggested improvements per gap |
| Freshness check (20%) | 20 | Didn't run freshness tool | Ran but ignored warnings | Ran and reported all findings | Ran, reported, and fixed broken refs |
| Verdict accuracy (25%) | 25 | Verdict doesn't match scores | Verdict roughly matches | Verdict matches, clear threshold reasoning | Verdict + specific fix list for each gap |
| Convergence (25%) | 25 | No fix-rescore cycle | Offered fixes but didn't rescore | Fixed and rescored once | Fixed, rescored, reached PROMOTE |

## Scoring Rules

- Dimension coverage: all 5 scored = 8, with actionable suggestions = 10
- Freshness: tool output included in report = 8, fixes applied = 10
- Verdict: correct threshold (8-10=PROMOTE, 5-7=REFINE, 0-4=REWORK) = 8
- Convergence: at least one fix-rescore loop completed = 8
