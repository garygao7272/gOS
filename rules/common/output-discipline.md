# Output Discipline

> **What this is.** Single source of truth for prose output rules across gOS — response shape, artifact structure, voice, and enforcement.
>
> **Audience.** Agents loading the rule into context; Gary reviewing and evolving it.
>
> **Reader output.** A compliant response, a compliant artifact, or the call to fix one.
>
> **Why now.** Response and artifact drift surfaced repeatedly in `/evolve audit`. This file is what every gOS invocation measures against.
>
> Extends [coding-style.md](./coding-style.md). Derived from FP-OS K3, K5, K6, K8. The style file [`output-styles/direct-response.md`](../../output-styles/direct-response.md) is a projection — it points here.

**Covers:** situation index (§0) · response prose (§1–§6) · artifact prose (§7) · voice and AI smell (§8) · enforcement.

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

**Sections 1 through 6 govern *response prose* (agent replies).** **Section 7 governs *artifact prose* (files gOS produces).** Apply where they bite.

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

## 6. Multi-option advisory close (ranked picks + decision ask)

When a response presents ≥ 3 ranked options AND asks Gary to decide, close with three H2s in this order:

```
## The deliverable — <N> ranked <picks/options/improvements>
| # | Pick | What it changes | Leverage | Effort | (optional: Source) |

## Why I suggested <the subset I did>   (only if recommending a subset rather than all)
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

## 7. Artifact discipline (files gOS produces)

Every artifact — spec, build card, refine output, synthesis doc — must follow the rules in this section. Reference target: [first_principles_operating_system_lean.md](../../../../first_principles_operating_system_lean.md) — table-first, narrative-stitched, plain-English, outline on top, action-anchor at the bottom.

**Declare the document's type before applying any other rule.** The type determines ordering, frontmatter, and which downstream rules bind hardest. That's why §7.1 leads this section.

### 7.1 Order substance by document type (declare type first)

Every prose artifact names why, what, and how. All three are always present; the **order** serves the reader's first question, which differs by document type.

**Every artifact >300 lines declares its type in frontmatter.** Missing `doc-type:` fails the quality gate — it forces the author to choose before writing, and it lets mechanical linters check the ordering.

```yaml
---
doc-type: research-memo | discovery | product-spec | design-spec | execution-spec | decision-record | build-card | strategy
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
| `execution-spec` | How do I code this? | **Rationale (≤6 lines)** → Contract → Edge cases → Numeric targets → State transitions → Open questions → Cut for v1 |
| `decision-record` | Why this call, and what are we committing to? | **Why** → What → How → Consequences |
| `build-card` | What changes, and how? | **What** → How → Why |
| `strategy` | Why now, and what's the move? | **Why** → What → How |

**`execution-spec` is the implementer's contract** — distinct from `product-spec` (what + scope) and `design-spec` (look + behaviour). The reader is a competent engineer with no context; the spec passes when they could code it correctly with ≤2 unanswered questions. Three weighted rubric dims bite hardest on this type: **execution density** (≥70% operationally-actionable lines), **rationale cap** (≤6 lines at top), **implementer-test** (fresh-context engineer leaves with ≤2 questions). All "why" compresses into the opening rationale; everything else is "what" and "how." See [evals/rubrics/think.md](../../evals/rubrics/think.md) for the dim weights.

**How to apply.** The positioning sentence at the top still leads — it names what the document is regardless of type. The *drill-down ordering below* the summary follows the table. A decision record that puts Consequences before Rationale buries the lede; a product spec that opens with mechanism before scope loses the reader.

**When the type is ambiguous**, pick the document's *primary reader need* and commit. A hybrid strategy-plus-spec document declares whichever type is load-bearing for the next action; the other concerns are cross-referenced, not merged.

**Mechanical check:** `tests/hooks/artifact-discipline.bats` reads `doc-type:` from frontmatter and verifies the first three H2s match the expected order keywords for that type. Files ≤ 300 lines are exempt from the frontmatter requirement.

### 7.2 Open with positioning and outline

First content after the H1 is (a) one sentence naming **what this document is, what the reader produces from it, and why it exists now**, and (b) a table of contents, stack, or layer map. No changelog, no "what changed from vX.Y," no deprecated-term mapping before the definition.

**Why:** a first-time reader needs purpose, shape, and motivation in ten seconds. Version history is a concern for the author reviewing their iteration trail, not the reader.

The positioning sentence does three jobs in one line. *What it is* — the document's category (spec, research memo, decision record). *What the reader produces* — the concrete output a reader can take after reading (a verdict, a next action, a shared model). *Why it exists now* — the motivation that makes this document a present concern rather than a generic reference. A positioning sentence that does only the first two reads as catalog; adding "why now" grounds the reader in the problem before the structure lands.

### 7.3 Describe before you index

In prose, use descriptive names. Index codes belong in tables for cross-reference, not in sentences.

- WRONG: *"A7 composes with A8 and A9 through DM."*
- RIGHT: *"The instrument gate composes with the venue gate and the risk-unit gate through the Directional Momentum composite."*

Industry-standard trader terms — volatility, funding, basis, drawdown, leverage, stop, target — stay as-is. Internal index systems (P1–P13, A1–A14, T-parameters) are for engineering traceability, not reader comprehension.

**Section-sigil ban.** Do not use the `§` section-sign in reader-facing artifacts under `specs/` or `outputs/think/`. It is legal/academic shorthand that reads as jargon to the retail audience and forces the reader to map a number to a heading. Use the heading name directly — the heading carries the reference. The mechanical linter rejects any `§\d` pattern in spec prose (see Enforcement).

### 7.4 Cap meta-content at five percent of lines

Changelog, version-delta, red-team log, cycle history, process artifact pointers — useful for traceability, corrosive in the main body. Consolidate into one appendix at the end. No parallel history sections.

The 5% cap applies to the main body. A document whose *subject* is version history (e.g., a dedicated changelog file) is itself the appendix — exempt.

### 7.5 Strip version markers from the main body

No "(NEW in vX.Y)" or "(was vX.Y Step N)" annotations inside substantive sections. These are notes for the author reviewing their diff, not for the reader.

Version context lives in the single appendix from the meta-content cap rule above. A main-body reader should not need to know what changed between versions to understand the current version.

### 7.6 Keep version metadata internally consistent

Filename, frontmatter version, H1 version, and status line must all agree on one version string. A mismatch is a bug, not a stylistic choice.

### 7.7 Weave prose with tables

Tables for structure (primitives, gates, rubric rows, trade-offs). Short prose for narrative stitching between them. All-prose reads as a wall; all-tables reads as inventory. Alternate rhythm: one to three sentences of context, then a table or diagram, then one to three sentences of implication.

### 7.8 End with an action anchor

Close with something the reader can operate on — a quick-reference card, a worked example, a "how to use this" section, or a next-steps list. Not a trailing version table. Not an appendix sprawl.

**Minimum acceptable close:** three to five lines naming how the document gets used, by whom, and what they produce after reading.

### 7.9.5 Length budget per doc-type (warn-level cap)

Verbosity is rewarded by additive rubrics — every rule says "ensure X is present"; no rule says "ensure absence of Y where Y is bloat." This budget closes the hole. Caps are warn-level (not block) — judgment can override, but the artifact must justify going over.

| Doc-type | Sweet-spot lines | Warn cap | Trigger |
|---|---|---|---|
| `decision-record` | 80–150 | 200 | One PASS/KILL call doesn't need 250 lines of prose |
| `research-memo` | 150–250 | 350 | Research compresses; 350+ usually means missing synthesis |
| `discovery` | 100–200 | 300 | Concept docs over 300 lines are usually two concepts |
| `product-spec` | 200–350 | 500 | Specs over 500 split into siblings |
| `design-spec` | 250–400 | 600 | Same — split or compress |
| `execution-spec` | 150–300 | 400 | Tight by design — implementer doesn't read past line 400 |
| `strategy` | 150–300 | 400 | Strategy is the bet, not the audit |
| `build-card` | 80–200 | 300 | Cards over 300 are micro-specs in disguise |

**Mechanical check (warn-only):** `_check_length_budget` reads `doc-type:` and warns if line count > cap. Author can document the override in a frontmatter `length-justification:` field. Three-strikes: if a doc-type's average length runs > cap across 3+ artifacts, the cap is wrong — revisit, don't paper over.

### 7.9.6 Chat-default routing for short outputs

The base inline-default rule (§7) is overridden by command-level routing (every `/think` sub-command names a file path). This sub-rule restores the default for short content.

**Rule:** If the response would be < 50 lines AND < 200 words AND has no future-session retrieval need, default to chat. File write requires explicit "save this" / "promote" / "append to log" follow-up.

**When to override (write the file anyway):** persistent contract (decision record on architectural call) · handoff to another verb · audit trail required · reusable structure > 300 words. The override is the author's call, not the command's default.

**Why this is needed.** Command-level "Output: outputs/think/.../.md" overrides §7's "Default: inline" — the inline default is dead-on-arrival for /think today. The fix isn't to remove the file path (sometimes a file is right) but to gate it on output size. A 30-line advisory should not become a 30-line file; a 200-line decision record should.

### 7.9.6.5 No internal jargon in body prose

A spec or rule that uses internal jargon (PEV, FP-OS, INV-G01, K5, doc-type articulation, AND-aggregated, primitives, atoms-vs-invariants, AC split) without defining it forces the reader to learn the system before reading the content. The rule that bans index codes in artifact prose applies recursively to the gos rule files themselves.

**Banned in body prose** (body = anything that isn't a glossary, footnote, or named code-block):
- Acronyms without expansion on first use ("PEV" → expand to "plan/execute/validate" once, then reuse).
- Internal labels that mean nothing to a fresh reader (INV-G01, FP-OS K3/K5/K6/K8, dim 6 / dim 8).
- "Primitive" / "atom" / "invariant" used as gos-specific vocabulary without naming what they map to in plain English.

**Allowed:**
- Industry-standard terms (Sharpe, MaxDD, funding, basis, OI, leverage, idempotent, P95, state machine, rate limit) — these are the language, not the jargon.
- Internal terms used inside the **glossary** (one-page plain-English reference at [glossary.md](./glossary.md)).
- Internal terms used inside cross-reference tables, code blocks, and frontmatter.

**The test:** could a fresh contributor — someone who joined yesterday with no gos exposure — read this sentence and parse it? If no, the sentence is jargon. Either expand the term inline once, or move the sentence into the glossary as a reference.

**Why this rule applies to gos rule files themselves:** the rule that requires plain-English in artifacts loses credibility if the rule itself is written in jargon. The gos rule files are read by every new contributor and every Claude session loading the rules into context — they are the highest-traffic prose in the system.

### 7.9.7 No interim-process content in final outputs

A spec is a present-tense contract. It is not a diff log of how it got here. The reader needs to know what we're committing to now, not what we considered and rejected, not how this version differs from the last, not which sentence was rewritten in cycle 2.

**Banned in main body:**

- Cross-version delta tables ("what changed from v0.2"), refactor logs, "before / after" comparisons.
- "Why this section exists" meta-commentary, rationale-for-rationale recursion ("we added this section because the rubric demanded it").
- Process artifacts: "after cycle 1 we discovered…", "the prior verdict was X, but reframing reveals…", "I was wrong before about Y."
- "Reframe" or "correction" callouts that reference prior thinking.

**Where these go instead:**

- Cross-version diffs → git log, or a sibling changelog file (`{spec}.changelog.md`), or the audit trail in `outputs/refine/{slug}/synthesis.md`.
- Interim thinking → `outputs/think/decide/{question}.md` artifacts and the refine cycle scratch — those are workshop artifacts that don't promote.
- Process narrative → never persists; lives only in conversation context.

**The test:** if a sentence describes the document's own evolution rather than the topic the document is about, delete it. The spec is what it is now. The history is somewhere else.

**Exemption:** a single line under the title noting "(supersedes vX)" is acceptable navigational metadata; a 17-line table cataloging Δ from prior version is not.

### 7.9.8 Descriptive names, not index codes, in narrative prose

Index codes (`[HT4]`, `[2-44]`, `MR4`, `CS1`, `D10`) are scaffolding for cross-reference. They belong in tables, footnotes, and citation appendices. They do not belong in body prose where a reader has to mentally map a code to a heading before the sentence parses.

**Wrong (current pattern):**
> `[HT4]` Position Heatmap kept on Asset A2; `[HT2]` Cohort tab dropped; `[2-126]` rollup feeds the new M4.

**Right:**
> Hypertracker's per-instrument liquidation heatmap is kept on the Asset Detail surface. Hypertracker's cohort tab is dropped. The cross-asset cohort heatmap rollup feeds the new Markets cascade view.

**The rule:** in body prose, name the thing in plain English. Use the surface or primitive's descriptive name. If a citation is needed, put the index code in a table cell or footnote, not in the running sentence.

**Industry-standard terms stay** (Sharpe, MaxDD, funding, basis, OI, leverage, liquidation). These are not index codes — they're trader vocabulary. Internal index systems (HT1–HT13, 2-1 through 2-126, MR1–MR7, CS1/CS2/CS3, A1/A2/A3a/A3b, M1/M2/M3/M4, W1–W9, C0–C6) are scaffolding.

**Exception zones (index codes allowed):**
- Block Contract tables (the Block column).
- Citation tables and footnote appendices.
- The "Surfaces" or similar overview tables that establish naming.
- Code blocks, formulas, technical references where the code IS the identifier.

Everywhere else, write the descriptive name. The reader should not have to scroll back to a key to parse a sentence.

### 7.9 Visual and structural aids (summary)

Reading fatigue comes from dense prose carrying load that a visual aid would carry better. The available tools — tables, numbered lists, ASCII flow diagrams, Mermaid flowcharts / sequence / state / mindmap diagrams, two-by-two matrices, admonitions, code blocks, status markers, footnotes — each earn their place under specific conditions. gOS supports Mermaid in modern viewers; keep a one-line ASCII fallback for legacy renderers.

**Reach-for rule:** if a reader would grasp something faster from a visual than a paragraph, and the visual fits in ten ASCII lines, include the ASCII version. If the visual needs more than ten lines of structure, use Mermaid with a one-line ASCII summary alongside.

**Full catalog and anti-patterns** (tables, Mermaid preferences, anti-patterns like table-of-tables, emoji decoration, images-in-specs): [`output-discipline-visuals.md`](./output-discipline-visuals.md). Load the companion when planning the visual shape of a section.

---

## 8. Voice and AI smell (summary)

LLM-authored or LLM-edited prose carries specific tells that at density trigger the reader's lowered-trust reflex. Twelve named anti-patterns: em-dash sandwich, padding openers ("It's worth noting that…"), bulleted lists where prose would flow, symmetric triples, "not X but Y" crutch, summary-announcement openers ("In essence,"), over-qualification, pivot clusters, self-congratulatory close, meta-about-meta, faux-specific vagueness, symmetric section intros/outros.

**Underlying pattern:** every tell is padding that masquerades as structure. The test: read the sentence without the announcing phrase — if it still makes sense, the phrase was smell.

**Quantitative caps (warn-level):** em-dash density > 1 per 25 words; any padding-opener phrase appearing ≥ 3 times outside quoted lists; ≥ 3 consecutive bullet-only sections with no prose between.

**Full catalog, rationale per pattern, and linter exemptions** (lists of anti-patterns in spec-writing guides are exempt from the padding-frequency count): [`output-discipline-voice.md`](./output-discipline-voice.md). Load the companion when auditing voice drift or wiring a new voice-related lint.

---

## Enforcement

| Rule surface | Test / gate | What it checks |
|---|---|---|
| Mechanism-first · Outline · SUMMARY · NEXT MOVE (responses) | [`response-discipline.bats`](../../tests/hooks/response-discipline.bats) `_check_mechanism_first` · `_check_outline_when_required` · `_check_summary_on_action` · `_check_next_move_format` | Response prose gates |
| DEFER format (responses) | `response-discipline.bats` `_check_defer_format` | `DEFER — needs: <resolver>` required; bare `DEFER` rejected |
| Multi-option three-H2 shape (responses) | `response-discipline.bats` `_check_multi_option_shape` | Responses with ≥3 lettered options + decision directive must carry deliverable + decision H2s |
| Pivot cluster (hedge-density anti-pattern) | `response-discipline.bats` `_check_pivot_cluster` | `however / on the other hand / that said / nevertheless / nonetheless` density > 1 per 5 prose lines on long content |
| Em-dash density (responses) | `response-discipline.bats` `_check_em_dash_density_response` | Voice warn cap: density > 1 per 25 words fails |
| Positioning opener (artifacts) | [`artifact-discipline.bats`](../../tests/hooks/artifact-discipline.bats) `_check_opens_with_positioning` | Italic or ≥40-char prose opener with positioning keyword |
| Meta-content cap | `_check_meta_content_cap` | ≤ 5% main-body lines in meta sections |
| No version markers in main body | `_check_no_main_body_version_markers` | `(NEW in vX.Y)` / `(was vX.Y)` markers restricted to Appendix |
| Metadata consistent | `_check_metadata_consistent` | Filename version matches H1 version |
| Doc-type ordering | `_check_doc_type_ordering` | `doc-type:` frontmatter + first three H2s match type ordering |
| Section-sigil ban in specs | `_check_no_section_sigils` | `§\d` rejected under `specs/` and `outputs/think/` |
| AC invariants/variants split | `_check_ac_invariants_variants_split` | Acceptance Criteria must split into Invariants + Variants subsections |
| Signal calibration (decision records) | `_check_signal_calibration` | `decisive` / `suggestive` tags present on cited signals |
| Rule-form H2 (decision records) | `_check_rule_form` | `## Selection Rule` or `## Aggregation Rule` H2 present |
| Em-dash density · padding-phrase frequency (artifacts) | `_check_em_dash_density` · `_check_padding_phrase_frequency` | Voice warn caps |
| Self-congratulatory close (artifacts) | `_check_self_congratulatory_close` | Last 15 lines must not restate / congratulate / announce conclusion |
| Meta-about-meta opener (artifacts) | `_check_meta_about_meta` | First 20 lines after H1 must not describe the document's own purpose (starts substantive, not meta) |
| Faux-specific vagueness (artifacts) | `_check_faux_vague` | Phrases like "several key" / "a number of" flagged when not followed by a specific count |
| Process-narrative leakage (execution-spec) | `_check_process_narrative_leakage` | "we considered" / "originally" / "after reflection" etc. banned from execution-spec body prose; phrase list at `tests/fixtures/ai-smell-phrases/process-narrative.txt` |
| Soft adjective without numeric (execution-spec) | `_check_soft_adjective_without_numeric` | "fast" / "responsive" / "comfortable" without a number in operational sections (Contract / Edges / Targets / State / Open questions); phrase list at `tests/fixtures/ai-smell-phrases/soft-adjectives.txt` |
| Artifact discipline overall | `/refine` 8-dim rubric (dim 6 structural + dim 8 voice) | A cycle that regresses either dim fails convergence |
| Style drift (all) | `/evolve audit` | `rework` signal with `output-discipline` context |

**LLM self-judgment (by design — judgment over mechanization):**

- Non-AC invariants/variants mix (§2 in prose contexts beyond Acceptance Criteria) — the AC case is mechanical; other cases are judgment
- Describe-before-index prose rule (§7.3) — index-code-in-prose flagged by reviewer, not regex
- Prose-table weave (§7.7) — rhythm is judgment
- Action-anchor minimum lines (§7.8) — final-section operability is judgment
- Five of twelve voice anti-patterns (§8) — em-dash density, padding-opener frequency, pivot-cluster, self-congratulatory close, meta-about-meta, and faux-specific vagueness are mechanical (six patterns total with mechanical coverage); the remaining six patterns (symmetric triples, "not X but Y," over-qualification, symmetric section intros, bulleted-over-prose, and summary-announcement openers via padding-opener overlap) are judgment
- Visuals (§7.9) — reach-for rule and tool selection are 100% judgment by design

**Meta-check:** `tests/hooks/artifact-discipline.bats` includes `_check_enforcement_table_matches_bats` which diffs the Enforcement table above against the actual `_check_*` helpers in both bats files. A table that claims a gate not present in bats, or a bats helper missing from the table, fails the meta-check. This keeps the Enforcement table honest.
