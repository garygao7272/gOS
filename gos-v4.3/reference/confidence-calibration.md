# Confidence Calibration — Structural Uncertainty Scoring

> Referenced by all gOS commands. Applied inline to key claims in every output.

## The 6 Confidence Factors

Every claim or output section is scored on structural indicators, not vibes:

| Factor | Score | How to Assess |
|--------|-------|---------------|
| **Source count** | +1 per independent source (max +3) | How many distinct sources confirm this? |
| **Source quality** | +1 for primary data, +0.5 for secondary | Is this from the source or a summary of a summary? |
| **Domain history** | +1 if gOS has prior accepts in this domain | Check `sessions/trust.json` for domain trust level |
| **Recency** | +1 if data is <30 days old | Is this current or potentially stale? |
| **Contradiction** | -1 per contradicting source | Do sources disagree on this claim? |
| **Assumption flag** | -1 per unvalidated assumption | What did we assume without evidence? |

## Score Range → Labels

| Score | Label | Marker | Meaning |
|-------|-------|--------|---------|
| 4-5 | HIGH | 🟢 | Multiple sources agree, verified, current |
| 2.5-3.9 | MEDIUM | 🟡 | Reasonable but not fully verified |
| 1-2.4 | LOW | 🟠 | Limited sources, assumptions present |
| 0-0.9 | SPECULATIVE | 🔴 | Educated guess, no direct evidence |

## Inline Marking Protocol

Apply confidence markers to **key claims only** — not every sentence. A "key claim" is one that, if wrong, would change Gary's decision.

```markdown
The copy trading market is estimated at $2.3B daily volume 🟢HIGH
(3 sources: DeFiLlama, Hyperliquid dashboard, Dune analytics, all <7 days old)

Retail traders are willing to pay 2bps for copy trading 🟡MEDIUM
(1 source: competitor pricing, no direct user research)

We can capture 5% of this market in 6 months 🔴SPECULATIVE
(assumption based on competitor growth rates, no direct evidence)
```

## When NOT to Apply Markers

- Code output — correctness is binary (compiles or doesn't), not probabilistic
- Design output — boldness is subjective, not evidence-based
- Formatting/structural content — tables, headers, formatting don't need confidence
- Quoting Gary's own words back to him

## Aggregated Confidence in Output Header

Include in the Output Contract scorecard:

```
📊 Quality: {artifact-name}
   Completeness: 4/5 | Evidence: 4/5 | Actionability: 3/5 | Accuracy: 4/5 | Clarity: 5/5
   {Extension}: 4/5
   🟢 HIGH: 4 claims | 🟡 MEDIUM: 6 claims | 🟠 LOW: 2 claims | 🔴 SPEC: 1 claim
   ⚠️ Key uncertainty: {the single biggest assumption that could be wrong}
```

## Calibration Rules

- Don't default to MEDIUM. Force a real assessment.
- If you have zero sources → it's 🔴 SPECULATIVE, not 🟡 MEDIUM.
- If Gary previously accepted a similar claim → +1 to domain history, but this doesn't make unsourced claims HIGH.
- Confidence is about the CLAIM, not about gOS's effort. Working hard doesn't make a claim more confident.
