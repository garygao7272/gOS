# Output Discipline

> Single source of truth for prose output rules across gOS. Extends [coding-style.md](./coding-style.md). Derived from FP-OS K3, K5, K6, K8. The style file [`output-styles/direct-response.md`](../../output-styles/direct-response.md) is a projection — it points here.

**Covers:** situation-to-rule index · response prose (sections 1 through 5.5) · artifact prose (section 6) · voice and AI smell (section 7) · enforcement.

## 0. Situation → rule index (start here)

| Situation | Rule that fires |
|---|---|
| Writing a chat reply (yes/no, explanation, status) | Mechanism-first |
| Reply covers ≥ 2 topics or ≥ 8 lines | Mechanism-first + Outline after mechanism |
| Reply lists options or tradeoffs | Invariants before variants |
| Reply answers a decision question | DEFER is a valid close · Signal calibration |
| Reply reports on completed action (edits / commits / tool runs) | SUMMARY block |
| Reply presents ≥ 3 ranked picks + asks for a decision | Multi-option advisory close |
| Producing a file (spec / memo / decision / build card / strategy) | Artifact discipline (all subsections) |
| Checking drift, AI smell, voice | Voice and AI smell |
| Wiring a new rule into tests / hooks / CI | Enforcement |

Atomic replies (one-line yes/no / single fact / status check) skip Outline, SUMMARY, and Multi-option close. One-off scratch files skip Artifact discipline.

**Sections 1 through 5.5 govern *response prose* (agent replies).** **Section 6 governs *artifact prose* (files gOS produces).** Apply where they bite.

## 1. Mechanism-first

Lead with the *why*, not the *what*. First sentence names the cause.

- WRONG: "Here's the auth analysis..."
- RIGHT: "Auth fails because the session token expires 2s before the refresh handshake completes."

Test: if the first sentence is deletable without losing the answer, delete it. Gary reads top-down and stops when satisfied — a topic-first opener forces a second read.

### 1.1 Outline after mechanism (non-atomic responses)

For any response covering **≥2 distinct topics** OR running **≥8 lines**, the second line after the mechanism sentence names the shape of what follows. One line, scannable.

- **Form:** `**Covers:** <topic a> · <topic b> · <topic c>` — or a short bulleted outline when the sections are deeper.
- **Placement:** immediately after the mechanism sentence, before any table or drill-down.
- **Purpose:** Gary decides in one glance whether to read through or jump to a section. Mirrors the positioning-and-outline rule for artifacts.

**Exempt:** Atomic (yes/no / single fact / status check) and Q&A responses ≤ 7 lines — mechanism sentence is the whole answer, outline would inflate it.

**Action responses** also get this opener: TL;DR mechanism at top, SUMMARY (DONE/TESTED/REMAINING/NEXT MOVE) at bottom. The opener tells Gary *what* happened; the summary tells him *what was verified and what's next*.

- WRONG (Advisory, 20 lines, no outline): drills straight into section 1, Gary must read all 20 lines to know the shape.
- RIGHT (Advisory, 20 lines): mechanism sentence, then `**Covers:** cause · three fix options ranked by leverage · rollback plan`, then drill down.

## 2. Invariants surface before variants

Hard constraints first, weighted trade-offs second. Never mixed in one table.

Mixing invariants and variants is the most common decision failure in the FP-OS decision protocol: lets you rationalise past a deal-breaker, or kill a good option for missing a nice-to-have. Applies to `/review` findings, `/think decide` options, `/design card` acceptance criteria, `/build` DoD lists.

## 3. DEFER is a valid close

Every decision-shaped output has three outcomes, not two: **PASS / KILL / DEFER**.

Defer format: `DEFER — needs: <decisive signal / evidence / experiment>`. A defer without a named resolver is paralysis-dressed-as-deliberation. Most "concerns" are actually defer — name them as such.

## 4. Calibrate signal weight (K5)

Tag cited signals as **decisive** (flips the call alone) or **suggestive** (accumulates). Don't treat equally.

Once a decisive signal fires in either direction, stop gathering — more suggestive signals are noise. One suggestive signal is not a decision; don't dress it up as one.

## 5. Summary block schema (action-shaped responses)

When a response takes action (ran tools, edited files, shipped commits), close with exactly these four:

- **DONE** — what was actually done. Past tense, concrete. 1–2 sentences, not a list of every tool call.
- **TESTED** — how we verified. Evidence (test counts, byte-parity, diff=empty, HTTP 200, grep-count). "Looks good" is not evidence.
- **REMAINING** — honest delta between asked-for and shipped. "None" is valid. Future-want items belong under NEXT MOVE, not here.
- **NEXT MOVE** — single suggested next action with a clear, binary call to action (yes / no / modify).

**Why NEXT MOVE:** without it, every response ends with Gary deciding what to do next — silent re-entry cost. Naming the move converts summary into handoff. Keep it to one action; if three candidates exist, pick the highest-leverage and name the other two as alternates in parens.

**Supersedes** the prior DID / VERIFIED / REMAINING schema from the base output style. Legacy labels map: DID → DONE, VERIFIED → TESTED.

## 5.5 Multi-option advisory close (ranked picks + decision ask)

When a response presents ≥ 3 ranked options AND asks Gary to decide, close with three H2s in this order:

```
## The deliverable — <N> ranked <picks/options/improvements>
| # | Pick | What it changes | Leverage | Effort | (optional: Source) |

## Why I suggested <the subset I did>   ← only if recommending a subset rather than all
<sequencing, coverage, leverage-cliff reasoning — 2-4 sentences>

## The decision you need to make
- **A.** <option A — full or default>
- **B.** <option B — recommended subset>
- **C.** <free-form / custom>

Reply with `A`, `B`, or `C: <your list>`.
```

**Why this shape:** a research/advisory response fails when Gary has to re-read to separate *the output* from *my opinion* from *what I need from him*. Three H2s force the separation: deliverable is neutral, rationale is opinion, decision is explicit. The lettered options collapse decision latency to one keystroke.

**Rules:**

- Full ranked list is the neutral deliverable. Don't hide options by recommending only the top N in the table itself.
- If you recommend a subset, say so in its own H2 with explicit sequencing / coverage / leverage-cliff reasoning — not a parenthetical after the table.
- Decision options always include a "free form" C so Gary can override without inventing a new format.
- Atomic advisory (one recommendation, one decision) skips this shape — use standard SOLUTIONS instead.

**Triggers:** `/think research` synthesis, `/review` verdicts with ranked findings, `/refine` multi-cycle recommendations, any advisory response where the user needs to pick from a ranked set before work proceeds.

## 6. Artifact discipline (files gOS produces)

Every artifact — spec, build card, refine output, synthesis doc — must follow the rules in this section. Reference target: [first_principles_operating_system_lean.md](../../../../first_principles_operating_system_lean.md) — table-first, narrative-stitched, plain-English, outline on top, action-anchor at the bottom.

### 6.1 Open with positioning and outline

First content after the H1 is (a) one sentence naming **what this document is, what the reader produces from it, and why it exists now**, and (b) a table of contents, stack, or layer map. No changelog, no "what changed from vX.Y," no deprecated-term mapping before the definition.

The positioning sentence does three jobs in one line. *What it is* — the document's category (spec, research memo, decision record). *What the reader produces* — the concrete output a reader can take after reading (a verdict, a next action, a shared model). *Why it exists now* — the motivation that makes this document a present concern rather than a generic reference. A positioning sentence that does only the first two reads as catalog; adding "why now" grounds the reader in the problem before the structure lands.

**Why:** a first-time reader needs purpose, shape, and motivation in ten seconds. Version history is a concern for the author reviewing their iteration trail, not the reader.

### 6.2 Describe before you index

In prose, use descriptive names. Index codes belong in tables for cross-reference, not in sentences.

- WRONG: *"A7 composes with A8 and A9 through DM."*
- RIGHT: *"The instrument gate composes with the venue gate and the risk-unit gate through the Directional Momentum composite."*

Industry-standard trader terms — volatility, funding, basis, drawdown, leverage, stop, target — stay as-is. Internal index systems (P1–P13, A1–A14, T-parameters) are for engineering traceability, not reader comprehension.

**Section-sigil ban.** Do not use the `§` section-sign in reader-facing artifacts under `specs/` or `outputs/think/`. It is legal/academic shorthand that reads as jargon to the retail audience and forces the reader to map a number to a heading. Use the heading name directly — the heading carries the reference. The mechanical linter rejects any `§\d` pattern in spec prose (see Enforcement).

### 6.3 Cap meta-content at five percent of lines

Changelog, version-delta, red-team log, cycle history, process artifact pointers — useful for traceability, corrosive in the main body. Consolidate into one appendix at the end. No parallel history sections.

The 5% cap applies to the main body. A document whose *subject* is version history (e.g., a dedicated changelog file) is itself the appendix — exempt.

### 6.4 Strip version markers from the main body

No "(NEW in vX.Y)" or "(was vX.Y Step N)" annotations inside substantive sections. These are notes for the author reviewing their diff, not for the reader.

Version context lives in the single appendix from the meta-content cap rule above. A main-body reader should not need to know what changed between versions to understand the current version.

### 6.5 Keep version metadata internally consistent

Filename, frontmatter version, H1 version, and status line must all agree on one version string. A mismatch is a bug, not a stylistic choice.

### 6.6 Weave prose with tables

Tables for structure (primitives, gates, rubric rows, trade-offs). Short prose for narrative stitching between them. All-prose reads as a wall; all-tables reads as inventory. Alternate rhythm: one to three sentences of context, then a table or diagram, then one to three sentences of implication.

### 6.7 End with an action anchor

Close with something the reader can operate on — a quick-reference card, a worked example, a "how to use this" section, or a next-steps list. Not a trailing version table. Not an appendix sprawl.

**Minimum acceptable close:** three to five lines naming how the document gets used, by whom, and what they produce after reading.

### 6.8 Order substance by document type

Every prose artifact names why, what, and how. All three are always present; the **order** serves the reader's first question, which differs by document type.

**Every artifact >300 lines declares its type in frontmatter.** Missing `doc-type:` fails the quality gate — it forces the author to choose before writing, and it lets mechanical linters check the ordering.

```yaml
---
doc-type: research-memo | discovery | product-spec | design-spec | decision-record | build-card | strategy
audience: <primary reader — one phrase>
reader-output: <what the reader produces after reading — one phrase>
---
```

| `doc-type:` value | Reader's first question | Typical order |
|---|---|---|
| `research-memo` | What did we find? | **What** → Why → How |
| `discovery` | What problem matters? | **Why** → What → How (deferred to later) |
| `product-spec` | What are we building, and where does it stop? | **What** → Why → How |
| `design-spec` | What does it look like and how does it behave? | **What** → How → Why |
| `decision-record` | Why this call, and what are we committing to? | **Why** → What → How → Consequences |
| `build-card` | What changes, and how? | **What** → How → Why |
| `strategy` | Why now, and what's the move? | **Why** → What → How |

**How to apply.** The positioning sentence at the top still leads — it names what the document is regardless of type. The *drill-down ordering below* the summary follows the table. A decision record that puts Consequences before Rationale buries the lede; a product spec that opens with mechanism before scope loses the reader.

**When the type is ambiguous**, pick the document's *primary reader need* and commit. A hybrid strategy-plus-spec document declares whichever type is load-bearing for the next action; the other concerns are cross-referenced, not merged.

**Mechanical check:** `tests/hooks/artifact-discipline.bats` reads `doc-type:` from frontmatter and verifies the first three H2s match the expected order keywords for that type. Files ≤ 300 lines are exempt from the frontmatter requirement.

### 6.9 Visual and structural aids (summary)

Reading fatigue comes from dense prose carrying load that a visual aid would carry better. The available tools — tables, numbered lists, ASCII flow diagrams, Mermaid flowcharts / sequence / state / mindmap diagrams, two-by-two matrices, admonitions, code blocks, status markers, footnotes — each earn their place under specific conditions. gOS supports Mermaid in modern viewers; keep a one-line ASCII fallback for legacy renderers.

**Reach-for rule:** if a reader would grasp something faster from a visual than a paragraph, and the visual fits in ten ASCII lines, include the ASCII version. If the visual needs more than ten lines of structure, use Mermaid with a one-line ASCII summary alongside.

**Full catalog and anti-patterns** (tables, Mermaid preferences, anti-patterns like table-of-tables, emoji decoration, images-in-specs): [`output-discipline-visuals.md`](./output-discipline-visuals.md). Load the companion when planning the visual shape of a section.

---

## 7. Voice and AI smell (summary)

LLM-authored or LLM-edited prose carries specific tells that at density trigger the reader's lowered-trust reflex. Twelve named anti-patterns: em-dash sandwich, padding openers ("It's worth noting that…"), bulleted lists where prose would flow, symmetric triples, "not X but Y" crutch, summary-announcement openers ("In essence,"), over-qualification, pivot clusters, self-congratulatory close, meta-about-meta, faux-specific vagueness, symmetric section intros/outros.

**Underlying pattern:** every tell is padding that masquerades as structure. The test: read the sentence without the announcing phrase — if it still makes sense, the phrase was smell.

**Quantitative caps (warn-level):** em-dash density > 1 per 25 words; any padding-opener phrase appearing ≥ 3 times outside quoted lists; ≥ 3 consecutive bullet-only sections with no prose between.

**Full catalog, rationale per pattern, and linter exemptions** (lists of anti-patterns in spec-writing guides are exempt from the padding-frequency count): [`output-discipline-voice.md`](./output-discipline-voice.md). Load the companion when auditing voice drift or wiring a new voice-related lint.

---

## Enforcement

| Rule surface | Test / gate | What it checks |
|---|---|---|
| Mechanism-first, Outline-after-mechanism, SUMMARY, NEXT MOVE format, em-dash density (responses) | [`tests/hooks/response-discipline.bats`](../../tests/hooks/response-discipline.bats) | Greps fixture response turns for preamble openers, Covers line, full SUMMARY block (DONE/TESTED/REMAINING/NEXT MOVE), NEXT MOVE ≤25 words + `?`, em-dash density ≥ 1 per 25 words |
| Positioning opener (artifacts) | [`tests/hooks/artifact-discipline.bats`](../../tests/hooks/artifact-discipline.bats) `_check_opens_with_positioning` | Rejects changelog-first; requires either italic positioning sentence OR ≥40-char prose line with positioning keyword |
| Meta-content cap | `artifact-discipline.bats` `_check_meta_content_cap` | ≤ 5% of main-body lines in changelog/version/red-team sections |
| No version markers in main body | `artifact-discipline.bats` `_check_no_main_body_version_markers` | `(NEW in vX.Y)` and `(was vX.Y Step N)` markers must live only in Appendix |
| Metadata consistent | `artifact-discipline.bats` `_check_metadata_consistent` | Filename version == H1 version |
| Doc-type ordering | `artifact-discipline.bats` `_check_doc_type_ordering` | Artifacts >300 lines must declare `doc-type:` frontmatter; first three H2s must match expected keywords for that type |
| Section-sigil ban in specs | `artifact-discipline.bats` `_check_no_section_sigils` | Artifacts under `specs/` or `outputs/think/` must not contain `§\d` patterns. Forces descriptive cross-references over legal-style numbering. |
| AC invariants/variants split | `artifact-discipline.bats` `_check_ac_invariants_variants_split` | Specs with Acceptance Criteria must split it into distinct Invariants (binary) and Variants (weighted) subsections. Promotes the invariants-before-variants rule from LLM self-judgment to a mechanical gate. |
| Em-dash density, padding-phrase frequency (artifacts) | `artifact-discipline.bats` `_check_em_dash_density`, `_check_padding_phrase_frequency` | Warn caps on voice drift |
| DEFER valid, signal calibration, PASS/KILL/DEFER (non-AC decisions) | `/review` terminal verdicts, `/think decide` 4-question gate | LLM self-check against rule wording (no mechanical linter yet — see enforcement gaps) |
| Artifact discipline overall | `/refine` reader-friction dimension of the quality rubric | A cycle that regresses reader-friction fails convergence |
| Style drift (all) | `/evolve audit` | `rework` signal with `output-discipline` context |

**Enforcement gaps (tracked):** DEFER substitution for KILL, signal mis-tagging, index-code-in-prose, and prose-table weave are currently LLM self-judgment only. The AC invariants/variants mix was promoted to mechanical on 2026-04-19. Promote the remaining gaps to mechanical checks when an `/evolve audit` surfaces recurring drift in any of them.
