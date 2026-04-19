---
doc-type: research-memo
audience: Gary Gao (gOS author)
reader-output: ranked decision on which spec-quality improvements to ship, defer, or reject
generated: 2026-04-19
sources: 3 independent fresh-context agent threads — Claude Code feature scan / Arx spec forensics / gOS architectural gap analysis
---

# gOS Spec Output Quality — Improvement Research Memo

*Research memo on how to raise gOS spec output quality, triangulated across latest Claude Code capabilities, observed Arx spec failures, and gOS pipeline architecture. Reader produces a ranked decision of which improvements to ship next cycle. Why now: the user's direct feedback that `/think`, `/refine`, `/review`, and `/simulate` outputs "aren't great product specs" — this memo names the structural causes and the concrete fixes.*

**Covers:** TL;DR verdict · convergence map across three threads · ranked picks with leverage/effort · per-pick detail · deferred · decision close · appendix.

---

## Verdict (TL;DR)

The gap is **not rule coverage — it's enforcement and pipeline shape.** Three independent threads converged on the same root cause: gOS has the right spec rules (§6.1 positioning, §6.8 doc-type, 8-primitive skeleton, invariants-vs-variants split) but `/think spec` runs them through the weakest scaffolding in the pipeline — a solo writer with a self-scored rubric and a linter that can't fire on missing frontmatter.

Three convergent, structural fixes would compound:

1. Make the spec skeleton a **mechanism not a prose reminder** (template bootstrap + bats checks that fire on what's absent).
2. Give `/think spec` a **PEV critic pool** matching what `decide` / `research` / `discover` already have.
3. Inject the spec contract into context via **`SessionStart` + `SubagentStart` hooks** so it survives compaction and reaches fresh-context critics.

Picks 4–7 are lower-leverage follow-ons. Picks 8+ are deferred until a `/refine` cycle surfaces them.

---

## Convergence map — where the three threads agree

| Finding | Arx forensics evidence | Architectural gap | Claude Code lever |
|---|---|---|---|
| **Spec skeleton is prose, not mechanism** | 0/7 specs carry `doc-type:` frontmatter — the bats gate is dead. 5/7 missing positioning sentence (§6.1) — the property-card metadata table replaced it. | 8-primitive skeleton is prose guidance only; no bats check for all 8 H2s; no AC invariants/variants split check. | `PreToolUse` Write/Edit hook with `if: "Write(specs/*)"` conditional; `SessionStart` hook injecting skeleton template. |
| **`/think spec` runs solo** | Quality failures that a fresh eye would catch (action anchor missing in 3/7, metadata malformed in Arx_5-1, invariants/variants mixed). | `/think spec` has no PEV pool; `decide` / `research` / `discover` all have one. Council mode in `/refine` exists but the roster is behavioral (S2/S7), not structural. | `Agent(effort: "xhigh")` on Opus 4.7 for spec agents unused. `isolation: "worktree"` + `EnterWorktree` reuse for refine cycles unused. |
| **Research→spec handoff is prose re-interpretation** | Atoms in research outputs aren't cleanly mapped to Atoms in specs — the Trader Decision Chain (656 lines) reads like prose, not like structured primitives. | `think.json` handoff carries only `output` path + one-line `summary`. No structured extraction of atoms/invariants/signals from the upstream synthesis. | `SubagentStart` hook could inject extracted primitives into any spawned critic. |

Three-lens convergence on items 1 and 2 is the strongest signal in this research. It's what makes the sequencing below tight.

---

## The deliverable — 7 ranked picks

| # | Pick | What changes | Leverage | Effort | Convergence |
|---|---|---|---|---|---|
| 1 | **`/think spec` template bootstrap** — auto-write frontmatter + 8-primitive skeleton + positioning sentence placeholder | Every new spec lands with `doc-type:` declared, all 8 H2s present, positioning sentence stubbed at top. Immediately activates the dead bats gates. | **HIGH** — closes Arx failure modes #1 (doc-type missing in 100%) and #2 (no positioning in 5/7) in one move | S (one template file + a line in `commands/think.md`) | 3/3 |
| 2 | **PEV pool for `/think spec`** — match the pattern from `decide` / `research` / `discover` | Spawn `pev-planner` → pool = `[first-principles, contrarian, architect, doc-type-auditor, upstream-synthesizer]` → fresh-context `pev-validator` → `adjudicator`. Spec — the highest-stakes artifact — gets the same scaffold as lower-stakes outputs already do. | **HIGH** — multi-lens critique on the highest-leverage reasoning task | M (mirror `decide`'s flow in `commands/think.md`, add 2 new agent definitions) | 3/3 |
| 3 | **Spec-structural council mode for `/refine`** | `/refine council --mode=spec-structural` with fixed roster (first-principles, contrarian, architect, doc-type-auditor, signal-calibrator, consequence-tracer). Reuses council machinery; swaps the Arx-behavioral pool. | **HIGH** — right lens for spec refinement; current council misses structural drift | S (new roster map + one flag in `commands/refine.md`) | 2/3 |
| 4 | **`SessionStart` hook injects spec contract** | On session init: load 8-primitive skeleton + 6-dim rubric + active project's decision log into Claude's context. Survives compaction and context loss. | **HIGH** — eliminates the "spec drift from context loss" failure mode that compounds across every other fix | M (new `hooks/session-start-spec-contract.sh` + `settings.json` entry) | 2/3 |
| 5 | **Extend `artifact-discipline.bats` with spec-specific checks** | (a) `_check_spec_primitives` verifies all 8 H2s present for product-spec/design-spec. (b) `_check_acceptance_criteria_split` requires distinct Invariants + Variants subsections when AC exists. (c) `_check_action_anchor` blocks specs whose last H2 is Glossary/Appendix/Changelog. | **MEDIUM-HIGH** — closes specific recurring gaps that the prose rules name but don't enforce | S (3 bats helpers, ~40 lines) | 2/3 |
| 6 | **Structured research→spec handoff** | Extend `think.json` schema with `extracted: { atoms, invariants, signals, open_questions }` populated by the upstream adjudicator. Spec writer consumes structured input, not prose. | **MEDIUM** — kills the "re-read and re-interpret" failure mode but requires adjudicator prompt rewrites | M (schema bump in `specs/handoff-schemas.md` + adjudicator prompt change) | 2/3 |
| 7 | **`effort: xhigh` on Opus 4.7 for spec agents + `SubagentStart` hook injects rubric** | Spawn spec PEV agents with `Agent(effort: "xhigh")`. `SubagentStart` hook injects the 6-dim rubric and doc-type ordering into every fresh-context critic so they evaluate against the actual bar, not their priors. | **MEDIUM** — compounds with pick 2; without pick 2, effort boost is wasted on a solo writer | S (one config flag + one hook script) | 2/3 |

---

## Why I suggested this subset

Picks 1–3 form the minimum viable spec-quality fix. Pick 1 activates the linter suite on day one — a day's work that immediately raises the floor across every new spec. Pick 2 adds the PEV scaffolding that exists everywhere else in `/think` except where it's needed most. Pick 3 gives `/refine` the right lens for spec iteration; today its council runs trader archetypes when the spec needs architects.

Picks 4–7 are compounding follow-ons. Pick 4 (SessionStart hook) amplifies 1–3 by making the contract survive compaction. Pick 5 (extended bats) catches specific gaps that pick 1 doesn't — not every AC failure is a missing section. Pick 6 (structured handoff) eliminates re-interpretation but depends on upstream adjudicator rewrites, so it's second-order. Pick 7 (effort + SubagentStart) only pays off after pick 2 lands — an effort boost on a solo writer is waste.

Sequencing: **pick 1 → pick 5 (bats) → pick 2 (PEV) → pick 3 (council mode) → pick 4 (SessionStart) → pick 6 (handoff) → pick 7 (effort)**. Pick 1 before pick 5 so the bats have frontmatter to check against. Pick 2 before 3 so council mode has a PEV pattern to match. Pick 4 before 6 because SessionStart is a prerequisite for most context-injection fixes.

---

## Deferred / rejected

- **Swarm-mode on every `/think spec`**: rejected — not every spec is high-stakes enough to warrant a 5-agent swarm. Invoke PEV when the spec affects commitments (product spec, design spec, decision record) and skip it for internal memos.
- **Full `diátaxis` taxonomy** (from prior output-discipline memo): still deferred — §6.8 doc-type already solves 80% with a lighter scheme.
- **Skill-based spec writing** (extract `/think spec` into a SKILL.md): deferred — SKILL.md frontmatter gives `model:` and `effort:` controls but doesn't change the pipeline shape; pick 2 (PEV) is the right intervention, not a skill refactor.
- **Conditional hooks (`if:` field) on every existing hook**: deferred — hygiene, not leverage. Revisit if hook-fatigue signals appear in `/evolve audit`.

---

## The decision you need to make

- **A.** Ship all 7 picks in sequence (1 → 5 → 2 → 3 → 4 → 6 → 7) as a `/refine` campaign. Full pipeline overhaul over several cycles.
- **B.** Ship picks 1–3 now as the minimum viable spec-quality fix. Defer 4–7 until a refine cycle shows residual drift. *(Recommended)*
- **C.** Free-form: pick any subset or sequence, or ask me to expand any specific pick into a build-card before you decide.

Reply with `A`, `B`, or `C: <your list or ask>`.

---

## Appendix — raw agent threads

Three independent fresh-context agents produced this memo:

- Claude Code feature scan (researcher, agent ID `a8e97dac30ff12679`) — mapped Claude Code capabilities late-2025 / Apr-2026 against current gOS `settings.json` and hooks. Source URLs in its output.
- Arx spec forensics (researcher, agent ID `a0d94ebdfb2c77e7a`) — sampled 7 Arx specs across groups 1 / 2 / 3 / 5, ranked §6 rule violations with file:line evidence.
- gOS architectural gap analysis (architect, agent ID `aa684837e5ea5f5a2`) — mapped the `/think` → `/refine` → `/review gate` pipeline, named 5 structural gaps with effort/leverage.

Re-open any thread via `SendMessage` if a specific pick needs deeper expansion.
