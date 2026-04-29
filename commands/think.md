---
description: "Think mode: discover, research, decide, spec — outputs to outputs/think/, promotes to specs/. TRIGGER when user asks to research something, decide between options, explore a question deeply, or spec a new concept — phrases like 'research X', 'what do we know about X', 'should we X or Y', 'help me think through X', 'decide on X', 'spec out X', 'dig into X'. SKIP for quick factual questions, or when user explicitly asks for just a one-line answer."
---

# Think Mode — Product + Strategy -> outputs/think/ -> specs/

**Think outputs go to `outputs/think/` first (staging), then promote to `specs/` if worthy.**

The separation matters: `outputs/think/` is the workshop. `specs/` is the showroom. Only conclusions worth building on get promoted.

**Output routing:**

| Sub-command | Output To | Doc-type | First three H2s (doc-type ordering) | Then |
|-------------|-----------|----------|------------------------------|------|
| `advise` | **Chat only — no file** | n/a | Mechanism · ranked options · decision call | One follow-up: "save as decide?" if Gary commits |
| `brainstorm` | `outputs/think/brainstorm/{pain_slug}.md` | `discovery` | Pain → Primitives → Frames → Idea pool → Pain↔Idea matrix | "Top idea → /think decide?" |
| `discover` | `outputs/think/discover/{topic}.md` | `discovery` | Problem → Concept → Composition (Why → What → How) | "Promote to `specs/Arx_3-X`?" |
| `research` | `outputs/think/research/{topic}.md` | `research-memo` | Findings/Verdict → Why it matters → How we found it (What → Why → How) | "Promote to `specs/Arx_2-X`?" |
| `decide` | `outputs/think/decide/{topic}.md` | `decision-record` | Context → Decision → Rationale → Consequences (Why → What → How → Consequences) | "Append to `specs/Arx_9-1_Decision_Log.md`?" |
| `spec` | **Direct to `specs/`** | `product-spec` (or `design-spec` / `strategy` per altitude) | Boundaries → Atoms → Relations (8-primitive skeleton below) | No staging |

**Chat-default override** — see [output-discipline.md §7.9.6](../rules/common/output-discipline.md). If the output would be < 50 lines AND < 200 words AND has no future-session retrieval need, return inline; do not write the file. Applies to `discover`, `research`, `decide` outputs that come back short. `advise` is always chat. `spec` always writes.

**Brevity flags (apply to any sub-command):**

- `--inline` / `--brief` — chat-only output for this invocation; no file write. Equivalent to the chat-default override fired by hand.
- `--lean` — applies to `spec` only. Uses the 4-section lean template (Boundaries · Atoms · Rule · Consequences) instead of the full 8-primitive skeleton. For specs whose target length is < 300 lines.

**Length budgets — see [output-discipline.md §7.9.5](../rules/common/output-discipline.md).** Warn-level caps per doc-type: decision-record 200 · research-memo 350 · discovery 300 · product-spec 500 · design-spec 600 · execution-spec 400 · strategy 400 · build-card 300.

**Output routing** — see [rules/common/output-routing.md](../rules/common/output-routing.md). Default: per sub-command (`research` short can be inline; `decide`/`discover`/`spec` always file). Override: `--inline` / `--file` / `--file=<path>`. Print one-line routing decision before execution.

**Frontmatter contract (every sub-command, every output).** The adjudicator writes `synthesis.md` with YAML frontmatter that declares:

```yaml
---
doc-type: <from table above>
audience: <primary reader — one phrase>
reader-output: <what the reader produces after reading — one phrase>
generated: <ISO date>
---
```

The first three H2s after the positioning sentence must match the doc-type orderinging keywords for that doc-type. The linter at [tests/hooks/artifact-discipline.bats](../tests/hooks/artifact-discipline.bats) verifies this on every output ≥100 lines.

**Intent confirmation** — see [rules/common/intent-confirmation.md](../rules/common/intent-confirmation.md). Template: "I'll [sub-command] [topic], covering [scope]. Proceed?"

**Output discipline.** Every prose artifact this command produces (files under `outputs/think/` and `specs/`) must comply with [rules/common/output-discipline.md](../rules/common/output-discipline.md) the artifact discipline rules (positioning opener + outline, meta-content ≤5%, no main-body version markers, metadata consistent, prose-table weave, action anchor) and the voice-and-AI-smell rules (twelve anti-patterns, quantitative warn caps on em-dash density and padding-phrase frequency). `/think spec` has additional quality-gate dimensions 1–5 plus the 8-primitive skeleton; `discover`, `research`, and `decide` still follow artifact and voice rules universally.

**Plan mode by default.** Present approach and wait for approval before executing.

**Swarm execution by default.** Once approved, spawn 3-5 parallel Agent workers with sub-command-specific roles. Each produces an independent artifact with zero file conflicts. Cross-examine contradictions before synthesizing.

**Scratchpad checkpoints:** On entry, after plan approval, after each agent completes, after synthesis, on dead end, after compaction.

**Handoff (mandatory on approval):** When Gary approves the /think output, **first validate doc-type articulation**:

```bash
bash tools/validate-doc-type.sh <path-to-artifact> <expected-doc-type>
# exit 0 → write handoff; exit 2 → refuse and surface the gap to Gary
```

Then write `sessions/handoffs/think.json` with the typed primitive payload (schema: [specs/handoff-schemas.md](../specs/handoff-schemas.md)):

```json
{
  "phase": "think",
  "sub": "<sub-command>",
  "output": "<path-to-artifact>",
  "doc_type": "<discovery|research-memo|decision-record|product-spec|design-spec|strategy>",
  "summary": "<one-line>",
  "primitives": {
    "invariants_declared": ["<extracted from artifact's Invariants section or AC table>"],
    "decisive_signals": ["<extracted from artifact's Signals table rows tagged 'decisive'>"],
    "rule_form": "<extracted from artifact's Selection Rule H2 or Rule primitive>",
    "boundary": {
      "in": "<extracted from Boundaries IN row>",
      "out": "<extracted from Boundaries OUT row>",
      "never": "<extracted from Boundaries NEVER row>"
    }
  },
  "approved": true,
  "approved_at": "<ISO-8601>"
}
```

`primitives` is required for `decide` and `spec`; set to `null` explicitly for `research` and `discover` where no decision is being committed. /design and /build read these typed primitives rather than re-parsing the prose — this prevents downstream drift where the implementation doesn't match what /think committed. If validate-doc-type.sh fails, the handoff is refused — fix the artifact's frontmatter or ordering before re-approving.

**When spawned from /refine** (a refine cycle dispatches an external /think call to close a gap), check for a `pending-think.json` at `outputs/refine/{slug}/cycle-N/`. If present:

1. Read the JSON — it specifies `gap_question`, `acceptance_signal`, `resolver_type`, `deposit_result_at`, `wake_signal_at`
2. Run /think with `gap_question` as the input (sub-command = `resolver_type`)
3. Write the artifact to `deposit_result_at` (NOT the usual `outputs/think/{sub}/` path — the result is job-scoped to the spawning refine cycle)
4. Touch `wake_signal_at` (`outputs/refine/{slug}/external/.ready`) so refine's state machine transitions `waiting-on-X` → `running`
5. Skip the "promote to specs/?" prompt — the result feeds back into /refine, not into the standalone outputs tree

This is the inverse direction of the standard handoff: /think normally feeds /design + /build downstream; here it feeds back upstream into the spawning /refine. Schema: [specs/handoff-schemas.md](../specs/handoff-schemas.md) → `refine.json`.

Parse the first word of `$ARGUMENTS`. If none given, ask: "What kind of thinking? advise (chat-only), brainstorm (non-obvious solutions to a pain), discover, research, decide, or spec?" (For URL absorption or source-watchlist management, use `/intake` directly.)

---

## advise <question>

**Purpose:** Chat-only thinking. Mechanism, ranked options, decision call — all inline. No file. No frontmatter. No PEV swarm.

**When to pick:** Quick advisory, meta-tooling questions, gOS-internal asks, "just talk it through" moments where the user wants the thinking, not the artifact. The litmus test: would the file get re-read in a future session? If no, this is `advise`.

**Output shape (chat only):**

1. **Mechanism** — one sentence naming the cause (per output-discipline §1).
2. **Outline** — `**Covers:** a · b · c` (per §1.1, when ≥ 8 lines).
3. **Body** — ranked options table OR direct prose, whichever fits.
4. **Decision close** — if asking the user to pick, use the multi-option three-H2 shape (§6); if recommending one path, close with a single suggestion.

**Length cap:** ≤ 200 lines of chat output. Over cap → escalate to `/think decide` or `/think research`.

**No file written.** No `outputs/think/advise/` directory. The thinking lives in the conversation. If Gary commits and wants persistence, follow up with `/think decide --save` to promote the chat thread into a decision record.

**Why this exists.** /think previously had no chat-only path — every invocation produced a file even when the question was "talk me through this." Verbosity-by-default was structural, not stylistic. `advise` restores the chat default for thinking-not-artifact.

---

## brainstorm <pain seed>

**Purpose:** Generate non-obvious solutions to a named customer pain. Pain-backwards, first-principles, anti-consensus, autonomous research. Where `discover` explores a topic, `brainstorm` attacks a pain.

**Input:** A pain statement (e.g., "copy-traders follow leaders who blow up after a hot streak"), a persona keyword (`copier`, `pro-trader`, or one of the s-series), or just a topic — the verb extracts pain itself if not given.

**When to pick:**
- Need non-consensus product moves, not incremental ones.
- Stuck — solution-space feels exhausted but pain persists.
- Pre-`/think discover` — when the topic is too vague and you need to surface the *real* pain before exploring concepts.

**When NOT to pick:** if you already know the pain and need to pick between named options → `/think decide`. If you need market evidence on existing solutions → `/think research`. If you want to validate a single concept → `/think discover`.

### Mechanism — five autonomous phases

Each phase runs without user re-entry. The verb consumes pain seed → produces ranked idea pool → hands off to `/think decide`.

| Phase | Engine | Output | Why |
|---|---|---|---|
| 1. **Pain extraction** | `arx-trading-intelligence:arx-audience-intelligence` simulates the 8 segments → top 3 unsolved pains per segment, with moment + constraint | Ranked pain list, no solutions | Solutions invented without a named persona-moment-constraint regress to consensus |
| 2. **First-principles decomposition** | `anthropic-skills:first-principles-decomposition` on top 3 pains → bedrock primitives (what's true, what's assumed) | Primitive map per pain | Strips inherited frame so Phase 4 can violate the right assumption |
| 3. **Frame-breaking research swarm** | 5 parallel agents, each given an adversarial framing — *(a) Renaissance Medallion · (b) a 12-yr-old · (c) a regulator · (d) a copy-trader who lost everything · (e) an LLM with no priors* — plus autonomous Exa / Context7 / GitHub access | 5 framings × research evidence | Diverse frames + autonomous fact-gathering breaks the consensus attractor |
| 4. **Anti-convergence ideation** | Generates ≥15 ideas, then **forces** tagging: 5 *consensus would say yes* · 5 *consensus would reject* · 5 *violates an assumption from Phase 2* | Tagged idea pool | Without forced anti-convergence, swarms collapse to the obvious 2–3 answers (FP-OS K3) |
| 5. **Synthesis: pain ↔ idea matrix** | Maps each idea → which pain it solves + which primitive it leverages + which assumption it breaks | Decision-ready matrix | Hands off to `/think decide` with the agency-tagged option set |

### Execution — PEV (`specs/pev-protocol.md`)

1. Spawn `pev-planner` with: task = pain seed, task_class = exploration, pool hint:
   - **Pain layer:** `audience-intelligence` (Phase 1 extraction)
   - **Decomposition:** `first-principles` (Phase 2)
   - **Frame swarm:** 5 contrarian agents with assigned framings (Phase 3) — each with autonomous research authority
   - **Anti-convergence:** `contrarian` + `consensus-mapper` (Phase 4 forced tagging)
   - **Synthesis:** `adjudicator` (Phase 5 matrix)
2. Planner writes `roster.json`. Present roster + pain extraction summary to Gary. Wait for approval — this is the only re-entry point.
3. Phases 2–4 execute fully autonomously. Each agent writes to `artifacts/{agent}.md`; research evidence cited inline.
4. `pev-validator` (fresh context) cross-examines the idea pool — every idea must trace to (a) a named pain, (b) a named primitive, (c) a named broken assumption (for the "violates assumption" tag) or a named research source (for the others). Ideas without traceability are cut.
5. **CONVERGED** → `adjudicator` writes synthesis with the pain↔idea matrix → present to Gary → offer `/think decide` handoff on top 3 ideas.
6. **STUCK** → escalate with what was tried + the assumption(s) the swarm couldn't break.

### Anti-consensus rule (the non-negotiable)

The synthesis MUST include ≥5 ideas tagged "consensus would reject" and ≥5 tagged "violates assumption." If the swarm produces fewer, the verdict is REWORK — it means the swarm regressed to consensus. The validator enforces this; the adjudicator cannot promote a synthesis that fails the anti-consensus floor.

### Output

`outputs/think/brainstorm/{pain_slug}.md` — promoted from `synthesis.md`. Doc-type `discovery`, first three H2s: **Pain → Primitives → Frames** (followed by Idea pool + matrix). Suggest:

- Top idea → `/think decide` (full decision protocol on the leading candidate)
- Cluster of 3 → `/think discover` (validate the most promising as a product concept)
- Promote pain itself → `specs/Arx_2-1_Audience_Pains.md` (if Phase 1 surfaced an unlogged pain)

### Length budget

`discovery` doc-type: 100–200 lines sweet, 300 warn cap. Brainstorm artifacts skew long because the matrix is structural; the cap holds.

### Brevity flags

`--inline` and `--brief` route the synthesis to chat (matrix collapsed to ranked-table form, no file written) per the chat-default override. Use when iterating quickly and the matrix won't be re-read in a future session. `--file` forces file output even if the synthesis would fit inline.

---

## discover <seed idea>

**Purpose:** Take a raw seed idea and produce a validated product concept.

**Input:** 1-2 sentence seed idea

### Design protocol (4-question lens — FP-OS design protocol)

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

### Strategy protocol (5-question lens — FP-OS strategy protocol)

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

### Decision protocol (4-question gate — FP-OS decision protocol)

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

**Output:** `outputs/think/decide/{question_slug}.md` (promoted from `synthesis.md`). Include: question, context, **Options table** (mandatory when ≥3 options — real/phantom tagged per FP-OS design protocol Q3; for 1–2 options, prose suffices), per-agent positions, **Signals table** (mandatory when ≥3 signals OR a decisive cut is named — decisive/suggestive tagged per the signal-calibration primitive; for sparse signals, prose suffices), decision + rationale, confidence, review date. Suggest appending to `specs/Arx_9-1_Decision_Log.md`.

**Tables relaxation rule (≤2 options).** A two-option decision can be prose: "Option A vs option B; here's why A wins. Decisive cut: X." The Options/Signals tables exist to prevent decision drift across many options — they're overhead when the call is binary. The decisive/suggestive *tagging* still applies in prose form (the linter checks for the keywords, not the table).

**Options table schema (mandatory for every `/think decide` artifact):**

| Option | Agency | Blocking constraint (if phantom) | Upstream resolver |
|--------|--------|----------------------------------|-------------------|

- **Agency = real** — this option is actually available; a decisive signal either way moves the call. List in the decision set.
- **Agency = phantom** — this option is labelled-as-choice but fixed by an upstream constraint (regulation, platform policy, contract, physics). Name the blocking constraint in column 3 and the upstream resolver (the command / decision / artifact that could relax it) in column 4. A phantom option is not in the decision set — it's a candidate for a separate upstream `/think decide` or strategy spec.

**Why the tag matters.** Presenting phantoms alongside real options lets the decision run against an illusory freedom. The verdict picks a "winner" that cannot execute ("works on paper, won't execute"). Phantom classification either removes the option from the decision set or escalates it to the upstream constraint. FP-OS design protocol Q3 is the source.

**Signals table schema (mandatory for every `/think decide` artifact):**

| Signal | Direction (for / against) | Class (decisive / suggestive) | Source / Evidence |
|--------|---------------------------|-------------------------------|-------------------|

- **Decisive signals** flip the verdict alone. Once one fires (in either direction), stop gathering — more suggestive signals are noise per FP-OS K5.
- **Suggestive signals** only accumulate. One suggestive signal is not a decision — don't dress it up as one.

The linter at [tests/hooks/artifact-discipline.bats](../tests/hooks/artifact-discipline.bats) verifies persisted decision-record artifacts contain the keyword `decisive` or `suggestive` at least once in a signals context.

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

**Spec skeleton — five sections, PM-native (Problem · Users · Solution · Success criteria · Risks).** Every spec opens with these five sections, in order. The five questions a CEO and product lead would ask of any commitment. Mental model carries from any company; no gos vocabulary required to read or write.

| # | Section | What goes here | Question it answers |
|---|---|---|---|
| 1 | **Problem** | What hurts. The constraints that can't be relaxed (regulatory, platform, business-model, trust thresholds). What we considered deleting and why we kept it. | What's broken, what's fixed about the world we operate in, and is this even worth doing? |
| 2 | **Users** | The specific person and moment. One named persona, one job-to-be-done. Not a demographic. Open with the worst user case (most confused, lowest context) so the design has to handle them | Who has the pain, in what moment, with what context? |
| 3 | **Solution** | The rule we're committing to. What we operate on, how we combine / select, why this beats alternatives. State machine completeness if UX/UI; type signatures and contracts if code | What are we shipping, and how does it work? |
| 4 | **Success criteria** | How we'll know it shipped right. Decisive signals (must fire) vs suggestive signals (accumulate). Numeric targets (P95 latency, payload size, error rate, cold-paint time, cognitive load). Acceptance test as a concrete user-flow pass/fail | What's the proof we built it, and how do we measure it in production? |
| 5 | **Risks** | What we're accepting, what becomes harder, what's hard to reverse. Reversibility tag on every consequential action. Named one-way doors. Failure modes upfront with recovery paths | What could break, what's the worst case, and what becomes impossible to undo? |

**The five sections fold every constraint of the prior 8-primitive system without requiring the reader to learn the system.** Hard constraints live in Problem. Atomic units, relations, and the rule live in Solution. Degrees of freedom are implicit in Solution (what we could have varied but chose not to). Decisive vs suggestive signals live in Success criteria. Consequences live in Risks. The mental checklist is preserved; the academic vocabulary is gone.

**Lean variant for short specs (`/think spec --lean`)** — for specs under ~150 lines, Solution and Success criteria can merge ("Solution + how we'll know it works"); Problem and Risks can compress. Five sections is the floor, not the ceiling — sub-headings are fine; section omission is not.

**Why every section is required.** Skip Problem → spec optimizes a part that shouldn't exist. Skip Users → solution looks elegant on paper, fails the actual user. Skip Success criteria → "shipped" becomes ambiguous. Skip Risks → we discover one-way doors after walking through them. Each section forces a question the writer would otherwise dodge.

**Criteria taxonomy (required for specs with acceptance criteria).** Split into:
- **Invariants** — binary pass/fail, AND-aggregated, no partial credit (hard constraints).
- **Variants** — continuous, weighted, trade-offs allowed (soft constraints).

Mixing the two is the single most common spec failure (per FP-OS decision protocol): treating an invariant as a variant lets you rationalise past a deal-breaker; treating a variant as an invariant kills good options for missing a nice-to-have.

**Purpose:** Write or update a strategy spec from upstream thinking.

**Input:** Topic or spec file (e.g., "update personas in Arx_2-1")

**Process:**

1. Read `specs/Arx_0-0_Artifact_Architecture.md` for naming/altitude rules
2. Read `specs/INDEX.md` for inventory
3. If updating: read existing spec. If creating: determine artifact ID + altitude, then **bootstrap the file from [`templates/spec-skeleton.md`](../templates/spec-skeleton.md)** — copy the template as the initial file so the `doc-type:` frontmatter, positioning sentence placeholder, and all 8 mandatory H2s are present before writing content. This activates the `artifact-discipline.bats` gates immediately and prevents the property-card-instead-of-positioning drift (Arx forensics, 2026-04-19).
4. Fill the skeleton section-by-section. Every placeholder `<...>` must be replaced; empty sections use "UNKNOWN — resolver: &lt;what would fill it&gt;" rather than deletion.
5. Write following altitude convention. Cascade rule: changes flow downward only.
6. Single source of truth: link, don't duplicate.

**Quality gate (inline — no longer a separate `/review spec` command):** Before promoting to `specs/`, score the spec on 8 dimensions (each 0–2, total /16) **split into invariants and variants per the FP-OS decision protocol**. Shared with `/refine` — any change lands in both places.

**Invariants (binary-like, floor ≥1, AND-aggregated).** Any invariant at 0 → REWORK regardless of total.

| # | Invariant dim | 0 (FAIL) | 1 | 2 |
|---|-----------|---|---|---|
| 1 | **Acceptance Criteria** | None | Vague or incomplete | MECE, testable, each has pass/fail condition |
| 4 | **Cross-References** | Broken / orphaned / missing | Some valid, some missing | All dependencies linked, no orphan references |
| 5 | **Freshness** | Stale refs or unsourced claims | Minor staleness | All refs valid, recently updated |
| 6 | **Structural compression** | Topic-first opener, no outline, meta-content crowds substance, version markers in main body, metadata inconsistent, no action anchor | Some friction; opening and outline present but meta-content ≥5% or main body carries version markers | Opens with positioning sentence + outline (`**Covers:** ...`); meta-content ≤5%; no main-body version markers; metadata consistent; closes with a named action anchor (not a glossary, not a changelog). Matches the artifact discipline rules in [output-discipline.md](../rules/common/output-discipline.md). |
| 7 | **Doc-type articulation** | No `doc-type:` frontmatter declared, OR declared but first three H2s don't match the doc-type ordering | `doc-type:` declared but drill-down reorders the why/what/how sequence for the declared type | `doc-type:` + `audience:` + `reader-output:` frontmatter present; first three H2s match the order keywords for the declared type; reader sees why/what/how in the correct sequence for the document's primary question |
| 8 | **Voice discipline** | Three or more AI-smell patterns present (em-dash sandwich, padding openers, summary-announcement openers, faux-specific vagueness, meta-about-meta, symmetric triples at every abstraction level); no section-sigil leakage. Also fails if `§\d` patterns appear in spec prose. | Some voice drift; one AI-smell pattern present but not habitual; section sigils absent | Prose reads as Gary's register: em-dash density ≤ 1 per 25 words; no padding openers repeated; no section sigils; compression over announcement. Matches the voice and AI-smell rules in [output-discipline-voice.md](../rules/common/output-discipline-voice.md). |

**Variants (continuous, weighted, trade-offs allowed).**

| # | Variant dim | 0 | 1 | 2 |
|---|-----------|---|---|---|
| 2 | **Edge Cases** | None mentioned | Some listed | Exhaustive: empty, overflow, error, concurrent, stale |
| 3 | **Data Model** | No data defined | Fields listed but no types/constraints | Full schema: types, constraints, defaults, nullability |
| 9 | **Compression** | Doc length > 1.5× the doc-type cap in [output-discipline.md §7.9.5](../rules/common/output-discipline.md); double tables, redundant recaps, citation density without value | Within cap but reads dense; borderline meta-content | At or below sweet-spot; no double tables; no trailing recap restating body; meta-content cleanly in appendix |
| 10 | **Numeric concreteness** | Soft adjectives throughout — "fast", "comfortable", "responsive", "good UX" — none replaced with numbers, states, or contracts | Some numeric targets present but mixed with soft adjectives; key surfaces still under-specified | Every soft adjective replaced with a number, named state, or named contract. UX/UI specs name pixel/dp values, frame rates, tap targets, animation durations. Code specs name P50/P95 latency, payload size, memory budget, idempotency, retry semantics |
| 11 | **State machine completeness** | Happy path only; loading / empty / error / over-quota / offline / stale / forbidden states are absent or hand-waved | Some states named (loading + error) but missing partial / over-quota / offline / stale / forbidden | Every state named with copy + visual or semantics; every transition listed; every edge case (concurrent edit, network partition, expired session, malformed input) has a named handler |
| 12 | **Performance budget** | No latency, payload, render-cost, or rate-limit numbers anywhere | Numbers present for some surfaces / endpoints but not all consequential ones | Every render surface has cold-paint and interaction-latency targets. Every endpoint has P50 / P95 / payload / RPS targets. Every batch job has time and resource budgets. Targets are realistic and measurable in production |
| 13 | **Delete-first check** | Spec is additive only — no acknowledgment of what was considered for deletion | Some deletions named but no scope-cut rationale | Spec opens with what we considered deleting and why we kept it. Includes the Musk test: "if shipping this in 18 months wouldn't embarrass me, I didn't cut enough." Every section has been pressure-tested for deletion before optimization |

**Before scoring:** run `bash tools/spec-freshness.sh` on the spec's directory to populate the freshness dim with evidence.

**Verdict:** 18–26 AND every invariant (1, 4, 5, 6, 7, 8) ≥1 → **PROMOTE** → write to `specs/` and update `specs/INDEX.md`. 13–17 OR any invariant at 0 → **REFINE** → list gaps (any invariant-zero is a MUST-FIX), rescore (max 2 cycles). 0–12 → **REWORK** → too incomplete, list required additions and return to `/think discover` or `/think research` first. **Invariants are AND-aggregated** — a spec with one invariant at 0 cannot promote even if every variant scores 2.

**Why dim 8 (voice) is separate from dim 6 (structural).** Prior rubric lumped voice into "Reader friction / compression" — structural rules got most of the signal, voice drift stayed invisible in the score. Splitting them makes a spec that nails structure but reads like AI slop ineligible for PROMOTE. The split was triggered by the 2026-04-19 spec-quality research: structural rules had one scoring dim; voice rules had zero.

**Output:** New or updated spec in `specs/` once ≥13 AND all invariant dims ≥1. Scoring table logged inline so the promotion decision is auditable, with invariant/variant split visible.

### Execution — PEV (spec-structural pool)

Specs are the highest-leverage artifact in gOS — a single spec cascades into build-cards, code, and production. Until this section was added (2026-04-19), `/think spec` ran solo while `discover`, `research`, and `decide` all had multi-lens PEV. That was the biggest architectural gap surfaced by the three-thread spec-quality research (see [outputs/think/research/spec-quality-improvement.md](../outputs/think/research/spec-quality-improvement.md)). PEV is now the default for any spec that affects commitments.

**When to invoke PEV:** product-spec, design-spec, decision-record, and strategy doc-types — any spec that downstream work commits to. **Skip PEV** for internal research memos, scratch notes, and specs under 150 lines where the skeleton check alone catches the common drift.

1. Spawn `pev-planner` with: task = spec topic, task_class = synthesis, pool hint:
   - **Meta:** `first-principles` (verify every atom traces to a cause, not precedent — INV-G01), `contrarian` (stress-test the rule under adversarial conditions)
   - **Structural:** `architect` (check altitude, cascade direction, cross-references), `doc-type-auditor` (verify positioning opener rule, doc-type orderinging, 8-primitive skeleton integrity, invariants/variants split in AC)
   - **Upstream:** `upstream-synthesizer` (map research/decide outputs into Atoms + Invariants + Signals — kills the prose re-interpretation failure mode from the research memo)
   - **Memory:** `episode-recaller` (check `specs/INDEX.md` and prior spec commits for orphans, duplicates, conflicts)
2. Planner writes `roster.json`. Present to Gary. Wait for approval.
3. Execute roster in parallel. Each agent writes to `artifacts/{agent}.md` + appends to `blackboard.md`. `doc-type-auditor` can VETO — a spec that fails positioning opener or doc-type ordering / 8-primitive / AC-split cannot proceed to promotion regardless of other verdicts.
4. `pev-validator` (fresh context) scores convergence → `verdict.md`.
5. Decide:
   - **CONVERGED** → `adjudicator` synthesizes final spec (using the skeleton from step 3 of Process above) → run inline quality gate → PROMOTE if ≥11 AND all invariant dims ≥1.
   - **ITERATE** → planner refines contracts for the unresolved dimension → round N+1 (max 3).
   - **STUCK** → escalate with what was tried + options for Gary.

---

## Think Convergence Loop (applies to discover, research, decide)

Multi-step think sub-commands run a convergence check before finalizing:

1. **After synthesis:** Cross-examine agent outputs for contradictions
2. **If contradictions found:** Route disputed claims between agents for resolution. Spawn a fact-checker if needed.
3. **If resolution changes the conclusion:** Re-synthesize with corrected facts.
4. **Max 3 cross-examination rounds** before presenting with flagged disagreements.

This ensures think outputs are internally consistent before Gary sees them.
