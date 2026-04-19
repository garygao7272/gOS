---
description: "Think mode: discover, research, decide, spec — outputs to outputs/think/, promotes to specs/. TRIGGER when user asks to research something, decide between options, explore a question deeply, or spec a new concept — phrases like 'research X', 'what do we know about X', 'should we X or Y', 'help me think through X', 'decide on X', 'spec out X', 'dig into X'. SKIP for quick factual questions, or when user explicitly asks for just a one-line answer."
---

# Think Mode — Product + Strategy -> outputs/think/ -> specs/

**Think outputs go to `outputs/think/` first (staging), then promote to `specs/` if worthy.**

The separation matters: `outputs/think/` is the workshop. `specs/` is the showroom. Only conclusions worth building on get promoted.

**Output routing:**

| Sub-command | Output To | Then |
|-------------|-----------|------|
| `discover` | `outputs/think/discover/{topic}.md` | "Promote to `specs/Arx_3-X`?" |
| `research` | `outputs/think/research/{topic}.md` | "Promote to `specs/Arx_2-X`?" |
| `decide` | `outputs/think/decide/{topic}.md` | "Append to `specs/Arx_9-1_Decision_Log.md`?" |
| `spec` | **Direct to `specs/`** | No staging |

**Intent confirmation** — see [rules/common/intent-confirmation.md](../rules/common/intent-confirmation.md). Template: "I'll [sub-command] [topic], covering [scope]. Proceed?"

**Output discipline.** Every prose artifact this command produces (files under `outputs/think/` and `specs/`) must comply with [rules/common/output-discipline.md](../rules/common/output-discipline.md) §6 Artifact Discipline (positioning opener + outline, meta-content ≤5%, no main-body version markers, metadata consistent, prose-table weave, action anchor) and §7 Voice and AI smell (twelve anti-patterns, quantitative warn caps on em-dash density and padding-phrase frequency). `/think spec` has additional quality-gate dimensions 1–5 plus the 8-primitive skeleton; `discover`, `research`, and `decide` still follow §6 and §7 universally.

**Plan mode by default.** Present approach and wait for approval before executing.

**Swarm execution by default.** Once approved, spawn 3-5 parallel Agent workers with sub-command-specific roles. Each produces an independent artifact with zero file conflicts. Cross-examine contradictions before synthesizing.

**Scratchpad checkpoints:** On entry, after plan approval, after each agent completes, after synthesis, on dead end, after compaction.

**Handoff (mandatory on approval):** When Gary approves the /think output, write `sessions/handoffs/think.json`:
```json
{"phase":"think","sub":"<sub-command>","output":"<path-to-artifact>","summary":"<one-line>","approved":true,"approved_at":"<ISO-8601>"}
```
This unlocks `/design` via the phase gate. See `specs/handoff-schemas.md`.

Parse the first word of `$ARGUMENTS`. If none given, ask: "What kind of thinking? discover, research, decide, or spec?" (For URL absorption or source-watchlist management, use `/intake` directly.)

---

## discover <seed idea>

**Purpose:** Take a raw seed idea and produce a validated product concept.

**Input:** 1-2 sentence seed idea

### Design protocol (4-question lens — FP-OS §3.3)

`discover` lives at the Atoms + Degrees-of-freedom layers. Invariants (platform, regulation, business model, trust thresholds) are inputs. Every discover output must answer:

1. **User atom** — not the demographic. The irreducible unit: specific person, specific moment, specific job-to-be-done. Everything composes from this.
2. **Fixed invariants** — platform constraints, regulatory limits, trust thresholds, business-model requirements. Name every one — unnamed invariants cage the design silently.
3. **Real degrees of freedom** — of everything "up to you," which are actually free vs phantom (labelled-as-choice but fixed by an upstream constraint)?
4. **Minimum sufficient composition** — simplest recombination of atoms, respecting all invariants, that delivers the outcome. Add complexity only when the minimum fails.

Skill: `anthropic-skills:design-discovery` (run inside this lens). Failure mode: designing at the *feature* layer instead of the *atom* layer — produces a great checkout flow inside a product no one needs.

### Execution — PEV (see `specs/pev-protocol.md`)

1. Spawn `pev-planner` with: task = seed idea, task_class = exploration, pool hint:
   - **Meta (always):** `first-principles`, `contrarian`
   - **User council:** pick 2+ personas relevant to seed (default: `copier`, `pro-trader` if seed touches copy/trust/trading; else 2 from s-series)
   - **Market:** `market-analyst`
   - **Infra:** `episode-recaller` (prior discover jobs on similar seeds)
2. Planner writes `outputs/gos-jobs/{job-id}/roster.json`. Present roster summary to Gary. Wait for approval.
3. Spawn approved roster in parallel — each writes to `artifacts/{agent}.md` + append to `blackboard.md`.
4. Spawn `pev-validator` (fresh context) → `round-{N}/verdict.md`.
5. Decide:
   - **CONVERGED** → `adjudicator` synthesizes → `synthesis.md` → present to Gary.
   - **ITERATE** → planner revises roster (add fact-checker or refine contract) → round N+1 (max 3).
   - **STUCK** → escalate to Gary with what was tried + options.

**Exit Gate:** "What specific pain from `specs/Arx_2-1` does this solve? If new, add it."

**Output:** `outputs/think/discover/{seed_slug}.md` (promoted from `synthesis.md`). Suggest promotion to `specs/Arx_3-X`.

---

## research <question>

> **Includes UX research** (absorbed from former `/design research`). All research — market, competitor, user, AND UX — lives here.

**Purpose:** Deep research grounded in evidence.

### Strategy protocol (5-question lens — FP-OS §3.5)

If the question has adversaries, feedback loops, or game-reshaping potential (competitor dynamics, market structure, venue economics), research through this lens. Pure fact-finding skips this.

1. **What's the game?** — players, objectives, available moves. Tactics ≠ strategy.
2. **Structural invariants** — regulatory, physical, economic, network effects. What would change the *game itself*?
3. **Asymmetry** — what can we see / do / access that others can't? No asymmetry = execution-speed play only, not strategy.
4. **Game-changing move** — tactical plays compete within rules; strategic plays change the rules, players, or payoffs. Rank candidates.
5. **Board response** — for each move, likely counter? How do we stay ahead of the reaction?

Skill: `anthropic-skills:product-strategy` (run inside this lens). Failure mode: playing the current game too well — produces incremental gains where reshaping the game would produce step-function gains.

**Before researching solutions, audit what's already installed.** Check settings.json, SETUP.md, installed MCP servers. Frame recommendations as "build on top of X" not "replace with Y". (Instinct: audit-existing-tools)

### Execution — PEV (see `specs/pev-protocol.md`)

1. Spawn `pev-planner` with: task = research question, task_class = exploration, pool hint:
   - `market-analyst` — academic papers, industry reports, data + sources
   - `competitor-crawler` — 3-5 competitors' features/pricing/UX/reviews
   - `spec-rag` — cross-reference with `specs/Arx_2-3_Competitive_Landscape.md`, identify gaps
   - `first-principles` — decompose the research question into atomic sub-questions
   - `tool-scout` (if question touches tooling/MCP/infra) — audit existing stack first
2. Planner writes `roster.json`. Present. Approve.
3. Execute in parallel. Each agent sources every claim; WebSearch required for external facts.
4. `pev-validator` cross-examines disputed claims across artifacts. If fact conflict → ITERATE with `fact-checker` added.
5. **CONVERGED** → `adjudicator` writes: numbered findings with sources → data points → competitive table → Arx implications → open questions.

**Output:** `outputs/think/research/{question_slug}.md` (promoted from `synthesis.md`). Suggest promotion or spec update.

---

## decide <question>

**Purpose:** Multi-perspective decision analysis.

**Input:** Decision question (e.g., "should copy trading show full P&L transparency?")

### Decision protocol (4-question gate — FP-OS §3.1)

The output MUST answer these four, in order. The PEV pool exists to gather evidence for them — not to replace them.

1. **Invariants** — what must hold, no exceptions? (binary pass/fail, AND-aggregated)
2. **Variants** — what's weighted? (continuous, trade-offs allowed, ranked)
3. **Decisive signals** — what would pass this alone (validators) or kill it alone (falsifiers)?
4. **Suggestive signals** — what's accumulating for (tailwinds) or against (yellow flags)?

**Verdict: PASS / KILL / DEFER (needs: X).** A variant failing ≠ KILL. A variant excelling ≠ PASS. Only invariants + decisive signals move the call; suggestive signals only nudge probability. Skill: `anthropic-skills:decision-prioritization` (run inside this gate, not instead of it).

### Execution — PEV (see `specs/pev-protocol.md`)

1. Spawn `pev-planner` with: task = decision question, task_class = synthesis, pool hint:
   - **Meta:** `first-principles` (decompose the decision), `contrarian` (pre-mortem)
   - **User council:** ≥2 personas affected by the decision (planner picks from copier/pro-trader/s-series based on keywords)
   - **Specialists:** match domain — `crypto-sec` if money/keys, `risk-analyst` if leverage/margin, `trader-ux` if UX flow
   - **Evidence:** `market-analyst` for data-backed claims
   - **Memory:** `episode-recaller` to check `specs/Arx_9-1_Decision_Log.md` for prior decisions
2. Planner writes `roster.json`. Present to Gary. Wait for approval.
3. Execute roster in parallel. Each agent argues from their lens; `crypto-sec` can VETO.
4. `pev-validator` scores convergence → verdict.
5. Decide:
   - **CONVERGED** → `adjudicator` produces recommendation with confidence (HIGH/MEDIUM/LOW).
   - **ITERATE** → planner refines contracts for unresolved dimension → round N+1 (max 3).
   - **STUCK** → escalate with options for Gary.

**Output:** `outputs/think/decide/{question_slug}.md` (promoted from `synthesis.md`). Include: question, context, options, per-agent positions, decision + rationale, confidence, review date. Suggest appending to `specs/Arx_9-1_Decision_Log.md`.

---

## spec <topic>

> **Strategy specs only.** Build cards are authored via `/design card`.

**Synthesis boundary (INV-G10, INV-G01).** Spec writing is synthesis — boundary discipline applies.

Before writing:
```
IN SCOPE: [what this spec answers]
OUT OF SCOPE: [adjacent questions handled elsewhere — name the other spec]
NEVER: [what this spec refuses to cover — and why]
```

**First-principles self-check (INV-G01):** Before finalizing, verify every claim traces to a mechanism, not an analogy. If any section leans on "like X" without naming the underlying cause, rewrite from primitives.

**Seven FP-OS primitives plus one Consequences section — eight mandatory sections.** Every spec written via `/think spec` must contain these eight sections in order. Empty or unknown is allowed — write "UNKNOWN — resolver: <what would fill it>". Missing sections fail the quality gate. Sections 1–7 are the FP-OS Layer 1 primitives; section 8 is a documentation primitive specific to specs, drawn from the Architecture Decision Record and Shape Up traditions.

| # | Section | What goes here |
|---|---|---|
| 1 | **Boundaries** | IN / OUT / NEVER — scope contract (reuses synthesis boundary above) |
| 2 | **Atoms** | Irreducible units this spec operates on. Each atom traced to a cause, not precedent (INV-G01). |
| 3 | **Relations** | How atoms connect — mechanisms, causality, flows. "A causes B by mechanism X." |
| 4 | **Invariants** | Hard constraints (binary, AND-aggregated). Classify each: *physical* (immutable) or *conventional* (industry habit — candidate for relaxation under `--innovate`). |
| 5 | **Degrees of freedom** | What can actually vary. For each: is this real agency, or phantom (labelled-as-choice but fixed)? |
| 6 | **Signals** | Observables that reveal state. Tag each: **decisive** (flips the call alone) or **suggestive** (accumulates). Reference FP-OS decision protocol. |
| 7 | **Rule** | How we combine / select / optimise. Form: "maximise X subject to invariants Y." Must be reproducible by a reader given the primitives above. |
| 8 | **Consequences** | If we commit to this rule, what becomes true downstream, what becomes harder, and what is foreclosed until revisited? Three bullets minimum, each naming a concrete downstream effect. |

**Why Consequences is required.** A decision without named consequences is a wish. Readers who don't see consequences either derive them privately (most won't) or act without them (and get surprised). Nygard's Architecture Decision Record template and Basecamp's Shape Up pitch both require this section for the same reason — the link between decision and reality has to be on the page, not implicit.

**Criteria taxonomy (required for specs with acceptance criteria).** Split into:
- **Invariants** — binary pass/fail, AND-aggregated, no partial credit (hard constraints).
- **Variants** — continuous, weighted, trade-offs allowed (soft constraints).

Mixing the two is the single most common spec failure (per FP-OS decision protocol): treating an invariant as a variant lets you rationalise past a deal-breaker; treating a variant as an invariant kills good options for missing a nice-to-have.

**Purpose:** Write or update a strategy spec from upstream thinking.

**Input:** Topic or spec file (e.g., "update personas in Arx_2-1")

**Process:**

1. Read `specs/Arx_0-0_Artifact_Architecture.md` for naming/altitude rules
2. Read `specs/INDEX.md` for inventory
3. If updating: read existing spec. If creating: determine artifact ID + altitude.
4. Write following altitude convention. Cascade rule: changes flow downward only.
5. Single source of truth: link, don't duplicate.

**Quality gate (inline — no longer a separate `/review spec` command):** Before promoting to `specs/`, score the spec on 6 dimensions (each 0–2, total /12). Shared with `/refine` — any change lands in both places.

| # | Dimension | 0 | 1 | 2 |
|---|-----------|---|---|---|
| 1 | **Acceptance Criteria** | None | Vague or incomplete | MECE, testable, each has pass/fail condition |
| 2 | **Edge Cases** | None mentioned | Some listed | Exhaustive: empty, overflow, error, concurrent, stale |
| 3 | **Data Model** | No data defined | Fields listed but no types/constraints | Full schema: types, constraints, defaults, nullability |
| 4 | **Cross-References** | No links to other specs | Some references | All dependencies linked, no orphan references |
| 5 | **Freshness** | References stale/missing files | Minor staleness | All refs valid, recently updated |
| 6 | **Reader friction / compression** | Topic-first opener, no outline, meta-content crowds substance, version markers in main body, metadata inconsistent | Some friction; opening and outline present but concept density uneven or main body carries version markers | Fresh reader produces accurate summary in 30 seconds; opens with positioning + outline; meta-content ≤5%; no main-body version markers; metadata consistent; closes with action anchor. Matches `rules/common/output-discipline.md` §6. |

**Before scoring:** run `bash tools/spec-freshness.sh` on the spec's directory to populate dimension 5 with evidence.

**Verdict:** 10–12 **PROMOTE** → write to `specs/` and update `specs/INDEX.md`. 6–9 **REFINE** → list gaps, fix, rescore (max 2 cycles). 0–5 **REWORK** → too incomplete, list required additions and return to `/think discover` or `/think research` first. **Dimension 6 must be ≥1 for PROMOTE, regardless of total** — a spec that fails reader friction cannot promote, even if it scores high on coverage.

**Output:** New or updated spec in `specs/` once ≥10 AND dim 6 ≥1. Scoring table logged inline so the promotion decision is auditable.

---

## Think Convergence Loop (applies to discover, research, decide)

Multi-step think sub-commands run a convergence check before finalizing:

1. **After synthesis:** Cross-examine agent outputs for contradictions
2. **If contradictions found:** Route disputed claims between agents for resolution. Spawn a fact-checker if needed.
3. **If resolution changes the conclusion:** Re-synthesize with corrected facts.
4. **Max 3 cross-examination rounds** before presenting with flagged disagreements.

This ensures think outputs are internally consistent before Gary sees them.
