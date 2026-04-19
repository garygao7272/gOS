# Output Discipline — Voice and AI smell (companion)

> Extracted from [output-discipline.md](./output-discipline.md) to keep the main rule file lean. The main rule file summarizes; this file holds the full anti-pattern catalog and enforcement detail. Load this file when auditing voice drift or wiring a new voice-related lint.

**Covers:** twelve anti-patterns · underlying pattern · quantitative caps · what doesn't count · exemptions.

## Twelve named anti-patterns

Writing produced or heavily edited by large language models tends to carry a specific set of tells. They aren't always wrong in isolation, but at density they mark the text as machine-generated and trigger the reader's lowered-trust reflex. This table codifies the tells as a lint surface so that gOS prose — both response and artifact — stays on the human side of the line.

| # | Pattern | Why it reads as machine |
|---|---|---|
| 1 | **Em-dash sandwich** — phrases offset by em-dashes at high density | Models reach for em-dashes because they're grammatically flexible; humans vary punctuation more |
| 2 | **Padding openers** — "It's worth noting that…", "Importantly…", "Let's dive into…" | Announce the next sentence rather than writing it |
| 3 | **Bulleted lists where prose would flow** | Bullets look structured; they hide missing logic |
| 4 | **Symmetric triples** — "X, Y, and Z" at every abstraction level | Training data is heavy on three-member lists; humans vary list length more |
| 5 | **"Not X but Y" rhetorical crutch** | Once per document is insight; four times is tic |
| 6 | **Summary-announcement openers** — "In essence,", "Ultimately,", "At its core," | Announce a summary instead of summarizing |
| 7 | **Over-qualification** — "This might be considered a form of X" instead of "This is X" | Models hedge to reduce embarrassment; humans commit |
| 8 | **Pivot cluster** — "However, on the other hand, that said…" | Hedging without commitment; often signals no chosen side |
| 9 | **Self-congratulatory close** — "To recap what we've accomplished…" | Readers trust themselves to have read the document |
| 10 | **Meta-about-meta** — "This document sets out to document…" | Starts a level above the substance |
| 11 | **Faux-specific vagueness** — "several key insights" with no number | Specificity requires commitment; hedging stays safe |
| 12 | **Symmetric section intros and outros** — "In this section we examine…" paired with "Having established…" | Feels structured; reads as filler |

## The underlying pattern

Every tell above is padding that masquerades as structure. The model is uncertain about the shape of the next sentence, so it reaches for a phrase that signals "structure is coming." Real human writing compresses — when the structure is clear, it doesn't need announcing.

**Test:** read the sentence without the announcing phrase. If it still makes sense, the phrase was smell.

## Quantitative caps (warn-level)

Voice is harder to mechanize than structure, so these caps warn rather than block. They flag drift; human judgment decides whether the instance is smell or craft.

| Metric | Warn threshold | Rationale |
|---|---|---|
| Em-dash density | > 1 per 25 words across the whole document | Calibrated against the lean First Principles OS reference (1 per 44 words — intentional stylistic compression). Genuine em-dash sandwich abuse runs at 1 per 15 words or worse. Threshold set to 25 so reference-style prose passes and abuse fails clearly |
| Padding-opener frequency | Any single phrase from the padding-opener or summary-announcement rows above appearing ≥ 3 times outside quoted lists | Once is voice; three times is tic |
| Consecutive bulleted sections | ≥ 3 consecutive sections that are bullet-only, no prose | Prose-table weave requires narrative between structure |

## What doesn't count as smell

Long sentences aren't AI smell. Technical vocabulary isn't AI smell. Tables aren't AI smell. Repetition for emphasis, carefully chosen, isn't AI smell. Em-dashes used deliberately for parenthetical asides aren't smell — the density cap above fires only at density that indicates reach-for-convenience use.

The twelve anti-patterns above are specifically moves that *substitute for* the harder work of thinking through a sentence's shape.

## Exemption: when naming the pattern is the point

A document that *lists* the anti-patterns (like this section, or a spec-writing guide) will mention the phrases to avoid. Linter implementations must exclude lines inside quoted lists, tables of anti-patterns, or code blocks from the padding-frequency count.

## How to use this file

Open it when auditing voice drift on a finished artifact, when wiring a new voice-related lint into `tests/hooks/artifact-discipline.bats`, or when training a fresh critic agent to evaluate prose for AI smell. For ordinary authorship, the summary in the main output-discipline rule is sufficient.
