# Eval Rubric: /intake

## Dimensions

| Dimension | Weight | 1-3 (Poor) | 4-6 (Adequate) | 7-8 (Good) | 9-10 (Exceptional) |
|-----------|--------|-----------|----------------|-----------|-------------------|
| Fidelity (30%) | 30 | Hallucinated content or dropped substance | Mostly accurate, some drift | Faithful to source, key claims preserved | Every claim traceable to source with timestamp/quote |
| Structure (20%) | 20 | Raw dump, no organization | Basic sectioning | MECE sections, clear hierarchy | MECE + cross-references + explicit assumption log |
| Filler removal (15%) | 15 | Includes ads, filler, repetition | Some cleanup | Clean — no filler, no marketing voice | Restructured into dense knowledge doc, ~30-50% of original length |
| Source discipline (20%) | 20 | No sources cited | Some sources | Every factual claim has inline source URL + date | Source + date + credibility note + access method |
| Actionability (15%) | 15 | No takeaways | Generic summary | Specific implications for Arx/gOS | Concrete next steps + open questions ranked by priority |

## Scoring Rules

- **Fidelity:** auto-fail to 3 or below if any hallucinated claim is found (no source or misattributed).
- **Source discipline:** `[Link unavailable]` is acceptable for dead/paywalled sources; zero sources = 0.
- **Filler removal:** if output length > 80% of source transcript, max score is 4 (failed to distill).
- **Applies to all three modes:** absorb, scan, sources. For `sources` (watchlist management), Fidelity = "watchlist entry matches intended source"; Actionability = "check command returned valid status per source".

## Overall Score

Weighted average: `(fidelity * 30 + structure * 20 + filler * 15 + sources * 20 + actionability * 15) / 100`

- 8-10 → ready to promote to `specs/` or feed into `/think research`
- 5-7 → usable as working notes, needs another pass
- 0-4 → re-run with stricter prompt or different source
