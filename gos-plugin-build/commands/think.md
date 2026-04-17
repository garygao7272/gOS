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

**Intent confirmation (always).** Before planning, restate scope in one line: "I'll [sub-command] [topic], covering [scope]. Proceed?" Skip only if Gary's input is already precise (e.g., exact spec ID or file path).

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

**Purpose:** Write or update a strategy spec from upstream thinking.

**Input:** Topic or spec file (e.g., "update personas in Arx_2-1")

**Process:**

1. Read `specs/Arx_0-0_Artifact_Architecture.md` for naming/altitude rules
2. Read `specs/INDEX.md` for inventory
3. If updating: read existing spec. If creating: determine artifact ID + altitude.
4. Write following altitude convention. Cascade rule: changes flow downward only.
5. Single source of truth: link, don't duplicate.

**Quality gate (inline — no longer a separate `/review spec` command):** Before promoting to `specs/`, score the spec on 5 dimensions (each 0-2, total /10):

| # | Dimension | 0 | 1 | 2 |
|---|-----------|---|---|---|
| 1 | **Acceptance Criteria** | None | Vague or incomplete | MECE, testable, each has pass/fail condition |
| 2 | **Edge Cases** | None mentioned | Some listed | Exhaustive: empty, overflow, error, concurrent, stale |
| 3 | **Data Model** | No data defined | Fields listed but no types/constraints | Full schema: types, constraints, defaults, nullability |
| 4 | **Cross-References** | No links to other specs | Some references | All dependencies linked, no orphan references |
| 5 | **Freshness** | References stale/missing files | Minor staleness | All refs valid, recently updated |

**Before scoring:** run `bash tools/spec-freshness.sh` on the spec's directory to populate dimension 5 with evidence.

**Verdict:** 8-10 **PROMOTE** → write to `specs/` and update `specs/INDEX.md`. 5-7 **REFINE** → list gaps, fix, rescore (max 2 cycles). 0-4 **REWORK** → too incomplete, list required additions and return to `/think discover` or `/think research` first.

**Output:** New or updated spec in `specs/` once ≥ 8. Scoring table logged inline so the promotion decision is auditable.

---

## Think Convergence Loop (applies to discover, research, decide)

Multi-step think sub-commands run a convergence check before finalizing:

1. **After synthesis:** Cross-examine agent outputs for contradictions
2. **If contradictions found:** Route disputed claims between agents for resolution. Spawn a fact-checker if needed.
3. **If resolution changes the conclusion:** Re-synthesize with corrected facts.
4. **Max 3 cross-examination rounds** before presenting with flagged disagreements.

This ensures think outputs are internally consistent before Gary sees them.
