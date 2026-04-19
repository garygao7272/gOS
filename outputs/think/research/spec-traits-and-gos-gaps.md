# Spec Traits and gOS Gaps — 2026-04-19

*What high-quality research, product, design, and engineering specifications share in structure and voice — and where gOS is still missing pieces that would produce them.*

## Outline

| Phase | What it covers |
|---|---|
| 1 | Traits that high-quality specs share across traditions |
| 2 | The format rubric — what goes first, middle, last |
| 3 | The AI smell, named — twelve specific anti-patterns |
| 4 | gOS today, scored against the traits and rubric |
| 5 | Top gaps, ranked by leverage |
| 6 | Three concrete next actions |
| Action | How to use this document |

---

## Phase 1 — Traits that high-quality specs share

The best specs across research, product, design, and engineering traditions look different on the surface — an Amazon six-pager reads nothing like a Rust RFC, which reads nothing like an Architecture Decision Record — but they share a small set of structural moves. What follows is the intersection, drawn from Amazon's narrative memo format, Basecamp's Shape Up pitches, Michael Nygard's Architecture Decision Records, the Internet Engineering Task Force's Request-for-Comments tradition, Rust's community RFC template, Google's internal design-doc culture, Stripe's engineering writing, Shreyas Doshi's product writing, Marty Cagan's product specs, George Orwell's *Politics and the English Language*, and John Sweller's cognitive-load theory.

### The nine shared traits

| # | Trait | What it looks like | Why it matters |
|---|---|---|---|
| 1 | **Single point of view** | One author, one voice, one position | Committee specs read like committees — hedged, defensive, compromise-shaped |
| 2 | **Problem before solution** | Open with the pain, not the fix | A solution that precedes its problem reads as a solution looking for a problem |
| 3 | **Decision stated upfront** | TL;DR carries the load if reader stops reading | The bottom-of-document reveal is a consumer-media trick; specs are reference material |
| 4 | **Non-goals as first-class** | What this is NOT has equal weight to what it IS | Unstated non-goals are where scope creep hides |
| 5 | **Alternatives considered honestly** | Strongest opposing view presented fairly | The spec has to survive contact with "why not X?" — better to face it upfront than in review |
| 6 | **Open questions visible** | Unknowns explicitly named, not hidden | A confident spec with no open questions is usually a spec that hasn't been stress-tested |
| 7 | **Consequences explicit** | "If we do this, then…" spelled out downstream | A decision without named consequences is a wish |
| 8 | **Density calibrated to reader** | Assumes the reader is smart, impatient, and reads diagonally first | Over-explaining insults the reader; under-explaining loses them |
| 9 | **Narrative, not outline** | Prose carries transitions; tables carry structure; bullets serve parallel items only | Bullets let missing logic hide between the points; prose forces every transition to be earned |

Three of these deserve longer treatment because they're the hardest to fake.

**Problem before solution (trait 2).** The Amazon six-pager opens with the customer's situation, not the feature. Shape Up opens with the "raw idea" and its appetite, not the pitch. A research memo opens with the question and why it matters now. Specifications that reverse this order — fix first, problem sketched afterward — almost always turn out to be a solution hunting for justification. The test: delete the first paragraph of the spec. If the rest of the document still makes sense, the first paragraph was problem framing (good); if the rest of the document now reads as a non-sequitur, it was solution pitch (bad).

**Consequences explicit (trait 7).** Most specs stop at "we will do X." Good specs continue: "and because we did X, now Y becomes true, Z becomes harder, and W is foreclosed until we revisit." Nygard's ADR template bakes this in as a required section called *Consequences*. Shape Up requires a "circuit breaker" — an explicit point at which you abandon the work if it's not converging. Without consequences on the page, the reader has to do the derivation themselves, and most readers won't.

**Narrative, not outline (trait 9).** This is the one most commonly violated by AI-authored specs. Bullets are seductive because they *look* structured. But a bulleted list is parallel by claim, not by content — it asserts that all items are the same kind of thing, without proving it. Prose forces you to show the relationship between items. The heuristic from Amazon's six-pager culture: if your bullets could be rearranged in any order without changing meaning, they should have been prose. If the order matters, numbered steps are better. If the items differ in kind, a table with named columns is best.

### What these traits are not

They are not layout preferences. They are compressions of reasoning discipline. A spec that follows them reads well because the *thinking* that produced it was well-ordered; a spec that fakes them through mimicry reads like someone trying to sound like a spec.

---

## Phase 2 — The format rubric

The shared format across these traditions has a consistent grammar. Not every spec uses every element, but the ordering is stable.

### One-page grammar

| Position | Element | Length |
|---|---|---|
| Line 1 | Title with version and status | 1 line |
| Line 2 | One-sentence positioning — what this document is and what the reader produces after reading it | 1–2 lines |
| Lines 3–10 | Outline or table of contents with one-line descriptions | 5–10 lines |
| Middle (bulk) | Problem → Decision/Hypothesis → Mechanism/Design → Consequences → Alternatives → Open Questions | Flexible |
| Last section | Action anchor — how this gets used, by whom, what they produce from it | 10–20 lines |
| After action anchor | Appendix for version history, red-team log, process artifacts | Optional, clearly marked |

### Inside the middle

Two further moves are common and high-value:

**Structure-carrying tables, narrative-carrying prose.** Tables earn their place when rows compare across the same columns (options × criteria, primitives × properties, traits × scores). If every cell in a column is a label for the value in column 2, the table is "key: value" prose in disguise and reads worse than the prose would. Prose earns its place when it carries causation, contingency, or narrative — the stuff that doesn't fit in a grid.

**The "strongest objection" paragraph.** A spec that faces its hardest critique head-on (one paragraph, named, answered) is more trusted than one that pretends the critique doesn't exist. This is also the simplest way to make a spec survive fresh-context review.

### What to keep out of the main body

Changelog, version delta, red-team log, cycle-by-cycle refinement notes — useful for the author, corrosive for the reader. One appendix at the end, clearly marked as such. If the document's *subject* is history, the whole document is the appendix and this rule doesn't apply.

---

## Phase 3 — The AI smell, named

Writing produced or heavily edited by large language models tends to carry a specific set of tells. They aren't always wrong in isolation — an em-dash once per page is fine, "in essence" once per document is fine — but at density they mark the text as machine-generated and trigger the reader's lowered-trust reflex. The twelve most common:

### The tells

| # | Pattern | Why it reads as machine |
|---|---|---|
| 1 | **Em-dash sandwich** — phrases offset by em-dashes once or twice per paragraph | Models reach for em-dashes because they're grammatically flexible; humans vary punctuation more |
| 2 | **"It's worth noting that…" / "Importantly…" / "Let's dive into…"** | Padding that announces the next sentence rather than writing it |
| 3 | **Bulleted lists where prose would flow** | Bullets look structured; they hide missing logic |
| 4 | **Symmetric triples** — "X, Y, and Z" repeated at every abstraction level | Training data is heavy on three-member lists because they scan well; humans vary list length more |
| 5 | **"Not X but Y" as rhetorical crutch** | Once per document is insight; four times is tic |
| 6 | **"In essence," / "Ultimately," / "At its core," as paragraph openers** | Announce a summary is coming instead of just summarizing |
| 7 | **Over-qualification** — "This might be considered a form of X" instead of "This is X" | Models hedge to reduce embarrassment from being wrong; humans commit |
| 8 | **Pivot cluster** — "However, on the other hand, that said…" | Hedging without commitment; often signals the model doesn't know which side to back |
| 9 | **Self-congratulatory close** — "To recap what we've accomplished…" | Humans trust the reader to have read the document |
| 10 | **Meta-about-meta** — "This document sets out to document…" | Starts at the level above the substance; a human starts at the substance |
| 11 | **Faux-specific vagueness** — "We found several key insights" with no number | Specificity requires commitment; hedging stays safe |
| 12 | **Symmetric section intros and outros** — "In this section we examine…" paired with "Having established…" | Feels structured; reads as filler |

### The underlying pattern

Every tell above is a form of *padding that masquerades as structure*. The model is uncertain about the shape of the next sentence, so it reaches for a phrase that signals "structure is coming." Real human writing compresses — when the structure is clear, it doesn't need announcing.

The test: read the sentence without the announcing phrase. If it still makes sense, the phrase was smell.

### What doesn't count

Long sentences aren't AI smell. Technical vocabulary isn't AI smell. Tables aren't AI smell. Repetition for emphasis, carefully chosen, isn't AI smell. The tells above are specifically moves that *substitute for* the harder work of thinking through a sentence's shape.

---

## Phase 4 — gOS today, scored

Against the nine traits and the format rubric, where does current gOS stand?

### Trait-level scoring

| Trait | Current gOS mechanism | Status |
|---|---|---|
| Single point of view | Commands are community-edited but each has a stable author-voice; rules files often read committee-built | Partial |
| Problem before solution | `/think spec` opens with Boundaries — a meta-answer, not a problem statement | Partial |
| Decision upfront | The §6 Artifact Discipline shipped today requires positioning at the top | Aligned (new) |
| Non-goals first-class | IN/OUT/NEVER covered by Boundaries primitive | Aligned |
| Alternatives considered | `/think decide` Decision protocol captures this | Aligned |
| Open questions visible | `/think spec` allows "UNKNOWN — resolver:" pattern | Aligned |
| Consequences explicit | Not enforced anywhere in gOS | **Missing** |
| Density calibrated | §6 dimension 6 now scores reader friction | Aligned (new) |
| Narrative over outline | §6.6 requires prose-table weave | Aligned (new) |

### Format-rubric scoring

| Rubric element | gOS state | Status |
|---|---|---|
| Positioning sentence at top | §6.1 requires it | Aligned (new) |
| Outline second | §6.1 requires it | Aligned (new) |
| Problem → decision → mechanism order | Not enforced; 7-primitive skeleton uses Atoms → Relations → Invariants → Degrees of freedom order | Partial |
| Structure-carrying tables, narrative-carrying prose | §6.6 requires it | Aligned (new) |
| Strongest-objection paragraph | Nowhere required | Missing |
| Action anchor at the end | §6.7 requires it | Aligned (new) |
| Meta-content ≤5% of main body | §6.3 requires it | Aligned (new) |
| No version markers in main body | §6.4 requires it | Aligned (new) |
| Appendix for history | §6.3 implies it | Aligned (new) |

### AI-smell scoring

None of the twelve anti-patterns are currently caught or lint-checked anywhere in gOS. The output-discipline rule addresses mechanism-first openers, invariant-before-variant tables, defer-as-valid-close, and signal weight — but it says nothing about em-dash density, padding phrases, symmetric triples, or self-congratulatory closes.

**Status: Missing.** This is the largest single gap in gOS's ability to produce non-AI-smell writing.

---

## Phase 5 — Top gaps, ranked by leverage

Applying first-principle Kernel rule K8 — first-order before second-order, eighty percent of attention on the factors driving eighty percent of the outcome — the gaps sort cleanly.

### First-order gaps

These shape the quality of every artifact gOS produces, not just specific ones.

1. **AI-smell lint is absent.** Output-discipline covers structure but not voice. Every response and every artifact inherits the gap. Addressing this lifts the quality floor on everything. **Leverage: very high.** **Effort: moderate.**
2. **Consequences discipline is absent.** Specs stop at the decision without naming what becomes true, harder, or foreclosed downstream. Readers either derive consequences themselves (most won't) or act without them (and get surprised). **Leverage: high.** **Effort: low — one section header and three sentences of rule.**
3. **Problem-before-solution ordering is not enforced.** The 7-primitive skeleton front-loads Boundaries, which answers "what are we discussing" but not "why does this exist." A reader who doesn't know the motivation reads the Boundaries section as arbitrary scoping. **Leverage: high.** **Effort: very low — wording tweak to §6.1 positioning rule.**

### Second-order gaps

These matter but are situational, not universal.

4. **Strongest-objection paragraph not required.** Helpful for strategic specs; unnecessary for routine ones. Worth adding as a conditional rule ("if this is a decision spec, include it") rather than a universal one.
5. **Single-author attribution not tracked.** Commands don't name an owner, so voice drifts over time. A simple `owner:` field in frontmatter would let an author write in voice.
6. **No gold-standard reference artifact in the rules.** The §6.1 rule points to the lean First Principles OS file by path, but that file lives outside the gOS repository. A canonical reference copy inside `rules/reference/` would make §6.1 self-contained.

---

## Phase 6 — Three concrete next actions

Each of the first-order gaps becomes a concrete edit. None is large; together they close the loop on voice quality that today's §6 Artifact Discipline left open.

### Action 1 — Add §7 "Voice and AI smell" to output-discipline

**What it does.** Codifies the twelve anti-patterns from Phase 3 as a rule. Adds a linted pair of heuristics: em-dash density capped at roughly one per hundred words of prose; zero tolerance for "it's worth noting," "in essence" paragraph-openers, "not X but Y" at higher than once-per-document frequency.

**Where it lives.** `rules/common/output-discipline.md` — new §7 immediately after §6.

**How it's enforced.** Extend `tests/hooks/artifact-discipline.bats` with a thirteenth and fourteenth test checking em-dash density and padding-phrase absence. The test can be conservative — warn rather than block — since voice is harder to mechanize than structure.

**Effort.** Forty minutes.

### Action 2 — Add Consequences as an eighth element to the 7-primitive skeleton

**What it does.** Every spec written via `/think spec` gets a Consequences section answering: *if we commit to this rule, what becomes true downstream, what becomes harder, what gets foreclosed until revisited?*

**Where it lives.** `commands/think.md` — extend the mandatory section table from seven rows to eight.

**Name for the primitive.** "Consequences" in plain English, not "Downstream Effects" or similar. Sits after Rule (§7 in current numbering).

**Effort.** Fifteen minutes for the edit and matching mirror sync.

### Action 3 — Promote "why this exists" into the §6.1 positioning rule

**What it does.** Tightens the §6.1 rule so the opening sentence answers *why this document exists*, not just *what it is*. Example upgrade:

- Current §6.1 requires: "One sentence naming what this document *is and does*."
- Upgraded: "One sentence naming (a) what this document is, (b) what it produces, and (c) why it exists now."

**Where it lives.** `rules/common/output-discipline.md` — wording patch inside §6.1.

**Effort.** Five minutes.

### Sequencing

Action 3 first — it's a five-minute wording tweak and lands immediately. Action 2 second — fifteen-minute structural change with obvious test coverage. Action 1 third — largest, requires a new bats test, but highest-leverage.

---

## Action

This document is an input to a future `/evolve upgrade` pass. It is not itself a spec for promotion to `specs/`. The six phases above produce:

- A concrete trait inventory to judge future specs against
- A format rubric that complements today's §6 Artifact Discipline
- A specific anti-pattern list the next AI-smell lint can reference
- Three ranked improvements ready to execute as a single `feat(gos)` commit

**Who reads this.** Any future session that runs `/evolve audit` or plans the next gOS self-improvement pass.

**What they produce.** The three edits in Phase 6, in the sequencing given. Estimated total effort: one hour including syncs, tests, and commit.

**When to revisit.** After the three Phase 6 actions ship, the second-order gaps (strongest-objection paragraph, single-author attribution, gold-standard reference in-repo) become candidates. Revisit this document's Phase 5 after that pass.

---

## Appendix — Source notes

Traits and format rubric synthesized from: Amazon six-pager and press-release-FAQ tradition (documented in Colin Bryar and Bill Carr, *Working Backwards*, 2021); Ryan Singer, *Shape Up* (Basecamp, 2019); Michael Nygard, "Documenting Architecture Decisions" (2011 blog post, template widely adopted); IETF RFC process (RFC 2026, "The Internet Standards Process," 1996); Rust RFC process (rust-lang/rfcs repository template); publicly-discussed Google design-doc culture; Stripe engineering blog; Shreyas Doshi's product-writing essays; Marty Cagan, *Inspired* (2008, revised 2017); George Orwell, "Politics and the English Language" (1946); William Strunk and E.B. White, *The Elements of Style* (1959); John Sweller, "Cognitive Load During Problem Solving" (*Cognitive Science*, 1988) and subsequent cognitive-load-theory literature.

AI-smell anti-patterns synthesized from observed output characteristics of large language models across 2023–2026, plus commentary from prompt-engineering practitioners on padding phrases, symmetric-triple preference, and hedging patterns.

gOS gap analysis grounded in today's (2026-04-19) state of `rules/common/output-discipline.md`, `commands/think.md`, `commands/refine.md`, and `tests/hooks/artifact-discipline.bats` — all at commit `acec3da`.
