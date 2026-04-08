# Output Contract — Self-Assessment Rubric

> Referenced by all gOS commands. Runs after execution, before presenting output to Gary.

## Universal Rubric (5 Dimensions)

Every output is scored 1-5 on each dimension:

| Dimension | 1 (Fail) | 2 (Weak) | 3 (Adequate) | 4 (Good) | 5 (Excellent) |
|-----------|----------|----------|-------------|----------|--------------|
| **Completeness** | Major gaps, missing sections | Partial coverage, obvious omissions | Covers the basics | Thorough, minor gaps only | Exhaustive, no gaps |
| **Evidence** | Unsourced opinions | Mostly opinion, few sources | Some sources cited | Well-sourced, traceable | Every claim sourced, primary data |
| **Actionability** | Abstract observations only | Vague suggestions | Some next steps | Specific actions identified | Actions with owners, dates, metrics |
| **Accuracy** | Known factual errors | Unverified claims | Reasonable but unchecked | Cross-referenced, mostly verified | Cross-verified from multiple sources |
| **Clarity** | Confusing, no structure | Readable but disorganized | Logical structure | Well-structured, scannable | Precise, scannable, no ambiguity |

## Command-Specific Extensions

Each command adds 1 extra dimension:

| Command | Extra Dimension | 1 | 3 | 5 |
|---------|----------------|---|---|---|
| `/think` | **Novelty** | Restates obvious knowledge | Some non-obvious insights | Surfaces insights Gary wouldn't find alone |
| `/design` | **Boldness** (taste-informed) | Generic template, no persona awareness, fails Cheap vs Premium test | Mix of safe and bold, some taste-aware choices, passes most litmus checks | Distinctive, persona-aligned, passes Premium litmus, Ive's care test — resolves complexity into clarity |
| `/build` | **Correctness** | Doesn't compile/run | Runs but edge cases fail | Compiles, passes tests, handles edges |
| `/review` | **Thoroughness** | Missed critical issues | Caught obvious issues | Comprehensive attack surface coverage |
| `/simulate` | **Range** | Single scenario only | Bull/base/bear but narrow spread | Wide spread with tail scenarios |
| `/ship` | **Safety** | Skipped pre-ship checks | Some checks run | All gates passed, rollback plan ready |
| `/evolve` | **Impact** | Cosmetic change only | Addresses a real pattern | Will measurably change behavior |

## Self-Score Protocol

Before presenting ANY output:

```
1. Score each of the 5 universal dimensions (1-5)
2. Score the command-specific extension (1-5)
3. Identify the weakest dimension
4. If any dimension ≤ 2:
   a. Flag it explicitly in the header
   b. Offer to improve before Gary reads: "Actionability is weak (2/5). Want me to add specific next steps before you review?"
5. Present the scorecard in compact format at the top of the output
```

## Presentation Format

```
📊 Quality: {artifact-name}
   Completeness: {N}/5 | Evidence: {N}/5 | Actionability: {N}/5 | Accuracy: {N}/5 | Clarity: {N}/5
   {Extension}: {N}/5
   ⚠️ Weakest: {dimension} — {one-line explanation}
```

If all dimensions ≥ 4: use ✅ instead of ⚠️:
```
📊 Quality: {artifact-name}
   Completeness: 4/5 | Evidence: 5/5 | Actionability: 4/5 | Accuracy: 4/5 | Clarity: 5/5
   Novelty: 4/5
   ✅ Solid across all dimensions
```

## Score Calibration

- **Don't inflate.** A 5 means "Gary couldn't do better with unlimited time." Reserve it.
- **Don't deflate.** A 3 is adequate, not bad. Don't score 2 on everything out of false modesty.
- **Evidence anchoring:** Score Evidence based on actual source count, not feeling.
  - 0 sources = 1, 1 source = 2, 2 sources = 3, 3+ independent sources = 4, primary data = 5
