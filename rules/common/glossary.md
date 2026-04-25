# gos glossary — one page, plain English

Every internal term used in gos rule files and command files, defined in one sentence. If a term you're reading isn't here, it should be — file an evolve signal.

The rule (per [output-discipline.md](./output-discipline.md), §7.9.6.5): the terms below are banned from body prose unless expanded inline on first use. They live here as the single reference. Industry-standard terms (Sharpe, P95, idempotent, etc.) are not jargon and don't appear in this file.

## Process and protocol

| Term | Plain-English meaning |
|---|---|
| **gos** | Gary's AI operating system — the rule files + command files + agents that govern how Claude works on Arx and other gOS-managed projects |
| **FP-OS** | First Principles Operating System — the upstream design / strategy / decision protocols (4-question design lens, 5-question strategy lens, 4-question decision gate) |
| **PEV** | Plan / Execute / Validate — the multi-agent pattern where one agent plans, several execute in parallel, and a fresh-context agent validates the result before synthesis |
| **plan gate** | A required checkpoint before destructive tool calls (Edit, Write, Bash-git): present plan, wait for "yes" / "go" / "approved" |
| **convergence loop** | The /refine cycle that scores against a rubric, identifies gaps, revises, re-scores, until the quality bar is met or a stop condition fires |
| **swarm** | Multiple Claude agents running in parallel on independent contracts (artifacts) for the same task; default in /think discover, /research, /decide |

## Spec and decision vocabulary

| Term | Plain-English meaning |
|---|---|
| **invariant** | A hard constraint — must hold, no exceptions, binary pass/fail. AND-aggregated: any one failing kills the option |
| **variant** | A weighted preference — accumulates toward a score, trade-offs allowed. Failing one is acceptable if others compensate |
| **decisive signal** | An observation that flips the verdict by itself. Once one fires, stop gathering — more signals are noise |
| **suggestive signal** | An observation that nudges probability but doesn't decide alone. Accumulates with others |
| **PASS / KILL / DEFER** | The three decision outcomes. DEFER must name what would resolve it (`DEFER — needs: <X>`); a defer without a named resolver is paralysis |
| **doc-type** | The category of a written artifact: `discovery`, `research-memo`, `decision-record`, `product-spec`, `design-spec`, `build-card`, `strategy`. Determines the order of opening sections |
| **positioning sentence** | The opening sentence of any artifact, naming what it is + what the reader produces from it + why it exists now |

## Spec template (PM-native — Problem / Users / Solution / Success / Risks)

| Section | Plain-English meaning |
|---|---|
| **Problem** | What hurts, who has the pain, what constraints can't be relaxed |
| **Users** | The specific person and moment (one named persona, one job-to-be-done — not a demographic) |
| **Solution** | The rule we're committing to — what we operate on, how we combine / select, why this beats alternatives |
| **Success criteria** | How we'll know it shipped right — observable signals tagged decisive vs suggestive, with numeric targets |
| **Risks** | What we're accepting, what becomes harder, what's hard to reverse if we ship this |

## Quality dimensions (rubric)

| Dim | Plain-English meaning |
|---|---|
| **Acceptance criteria** | The pass/fail test. Either the spec passes the test or it doesn't ship |
| **Cross-references** | Links to other specs / source files. Broken links = broken contract |
| **Freshness** | Refs and claims still valid. Stale = misleading the reader |
| **Structural compression** | Opens with positioning, has an outline, meta-content under 5%, ends with an action anchor |
| **Doc-type articulation** | Frontmatter declares what kind of doc this is; first three H2s match the type's expected order |
| **Voice discipline** | No padding openers, no AI-smell phrases, em-dashes under 1 per 25 words |
| **Edge cases** | Empty / overflow / error / concurrent / stale all handled |
| **Data model** | Schemas with types, constraints, defaults, nullability — not just field names |
| **Compression** | Within length budget for doc-type, no double tables, no trailing recap |
| **Numeric concreteness** *(new)* | Soft adjectives ("fast", "comfortable", "responsive") replaced with numbers, states, or contracts |
| **State machine completeness** *(new)* | Every state (loading / empty / partial / error / over-quota / offline / stale / forbidden) named, every transition, every edge case |
| **Performance budget** *(new)* | Numeric targets per surface or endpoint — cold paint < 800ms, P95 < 200ms, payload < 50KB |
| **Delete-first check** *(new)* | Spec opens with what we considered deleting and why we kept it; additive-only specs score 0 |

## Index codes (when allowed)

The file uses index codes (HT4, MR1, 4-3-1, INV-G01, §7.9.5) only inside cross-reference tables, footnotes, and frontmatter. They do not appear in body prose. The reason: a sentence with three index codes forces the reader to scroll back to a key before parsing — that's a comprehension tax.

## Adding a new term

If a gos doc starts using a new internal term, the term lands here in one sentence within the same change. If it's not worth one sentence in the glossary, it's not worth coining.
