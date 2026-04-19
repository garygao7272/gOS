# Output Discipline

> Extends [coding-style.md](./coding-style.md) for prose output — command responses, verdicts, and the files gOS produces (specs, build cards, refine outputs, synthesis docs). Derived from FP-OS K3, K5, K6, K8.

**Sections 1–5 govern *response prose* (agent replies).** **Section 6 governs *artifact prose* (files gOS produces).** Apply where they bite; atomic yes/no answers skip 1–5; one-off scratch files skip 6.

## 1. Mechanism-first

Lead with the *why*, not the *what*. First sentence names the cause.

- WRONG: "Here's the auth analysis..."
- RIGHT: "Auth fails because the session token expires 2s before the refresh handshake completes."

Test: if the first sentence is deletable without losing the answer, delete it. Gary reads top-down and stops when satisfied — a topic-first opener forces a second read.

## 2. Invariants surface before variants

Hard constraints first, weighted trade-offs second. Never mixed in one table.

Mixing invariants and variants is FP-OS §3.1's most common decision failure: lets you rationalise past a deal-breaker, or kill a good option for missing a nice-to-have. Applies to `/review` findings, `/think decide` options, `/design card` acceptance criteria, `/build` DoD lists.

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

## 6. Artifact discipline (files gOS produces)

Every artifact — spec, build card, refine output, synthesis doc — must follow seven rules. Reference target: [first_principles_operating_system_lean.md](../../../../first_principles_operating_system_lean.md) — table-first, narrative-stitched, plain-English, outline on top, action-anchor at the bottom.

### 6.1 Open with positioning and outline

First content after the H1 is (a) one sentence naming what this document *is and does*, and (b) a table of contents, stack, or layer map. No changelog, no "what changed from vX.Y," no deprecated-term mapping before the definition.

**Why:** a first-time reader needs to know the document's purpose and shape in ten seconds. Version history is a concern for the author reviewing their iteration trail, not the reader.

### 6.2 Describe before you index

In prose, use descriptive names. Index codes belong in tables for cross-reference, not in sentences.

- WRONG: *"A7 composes with A8 and A9 through DM."*
- RIGHT: *"The instrument gate composes with the venue gate and the risk-unit gate through the Directional Momentum composite."*

Industry-standard trader terms — volatility, funding, basis, drawdown, leverage, stop, target — stay as-is. Internal index systems (P1–P13, A1–A14, T-parameters) are for engineering traceability, not reader comprehension.

### 6.3 Cap meta-content at five percent of lines

Changelog, version-delta, red-team log, cycle history, process artifact pointers — useful for traceability, corrosive in the main body. Consolidate into one appendix at the end. No parallel history sections.

The 5% cap applies to the main body. A document whose *subject* is version history (e.g., a dedicated changelog file) is itself the appendix — exempt.

### 6.4 Strip version markers from the main body

No "(NEW in vX.Y)" or "(was vX.Y Step N)" annotations inside substantive sections. These are notes for the author reviewing their diff, not for the reader.

Version context lives in the single appendix from §6.3. A main-body reader should not need to know what changed between versions to understand the current version.

### 6.5 Keep version metadata internally consistent

Filename, frontmatter version, H1 version, and status line must all agree on one version string. A mismatch is a bug, not a stylistic choice.

### 6.6 Weave prose with tables

Tables for structure (primitives, gates, rubric rows, trade-offs). Short prose for narrative stitching between them. All-prose reads as a wall; all-tables reads as inventory. Alternate rhythm: one to three sentences of context, then a table or diagram, then one to three sentences of implication.

### 6.7 End with an action anchor

Close with something the reader can operate on — a quick-reference card, a worked example, a "how to use this" section, or a next-steps list. Not a trailing version table. Not an appendix sprawl.

**Minimum acceptable close:** three to five lines naming how the document gets used, by whom, and what they produce after reading.

---

## Enforcement

- `/review` terminal verdicts checked against PASS/KILL/DEFER schema.
- `/think spec` outputs checked for 7-primitive skeleton + invariant/variant criteria split + §6 artifact discipline (dimension 6 of the quality gate).
- `/think decide` outputs checked for 4-question gate (invariants, variants, decisive, suggestive).
- `/refine` cycles score artifact discipline as dimension 6 of the 6-dim rubric. A cycle that regresses dimension 6 fails convergence.
- Style drift (topic-first openers, mixed invariant/variant tables, un-tagged signals, bloat in main body, version markers in substantive sections) = `/evolve audit` `rework` signal with `output-discipline` context.
- Artifact-discipline smoke test: `tests/hooks/artifact-discipline.bats` — checks positioning opener, metadata consistency, meta-content cap, version-marker absence.
