---
description: "Review: fresh, ultra, code, gate, council, dashboard — or any persona name directly. TRIGGER when user asks to review, audit, or quality-check existing work — phrases like 'review this', 'audit X', 'is this good', 'is this safe', 'check this before I ship', 'red team this', 'second opinion on X', 'council review', or names a specific persona (s1-s8, trader-ux, crypto-sec, contrarian, etc.). SKIP for the initial creation of something — use /think or /design for that. For convergence-loop iteration use /refine; eval measurement is dropped."
---

# Review — Quality Assurance → specs/ + apps/

**Review inspects, judges, and proves.**

**Scratchpad checkpoints.** Update `sessions/scratchpad.md`:

- **On entry:** Write review type, target, mode (`Review > {sub-command}`)
- **After each review pass:** Log findings count and severity
- **After verdict:** Write verdict and top finding to `Key Decisions`
- **After compaction:** Re-read `sessions/scratchpad.md`

Parse the first word of `$ARGUMENTS` to determine sub-command. If it matches a persona name, run a single-persona review. Recognized personas:
- **Arx Independent Council archetypes:** `s2-scalper`, `s2-swing`, `s2-systematic`, `s7-yield-chaser`, `s7-conviction-copier`, `s7-diversifier` (spawn the matching `arx-s2-*` / `arx-s7-*` agent in fresh context)
- **Legacy composite personas:** `s2-jake`, `s7-sarah`, `s1-alex`, `s3-marcus` (single-persona, deprecated in favor of archetype councils for S2/S7)
- **Specialists:** `trader-ux`, `crypto-sec`, `risk-analyst`, `mobile-perf`, `contrarian`, `design-auditor`

If no sub-command given, ask: "What kind of review? fresh, ultra, code, gate, council, dashboard, or a persona?"

**Routing for `ultra` vs `council`:** if input is file paths, a diff, or a staged changeset → **ultra** (delegate to native `/ultrareview`). If input is a topic, spec, design, or strategy question → **council** (gOS persona swarm).

**Intent confirmation** — see [rules/common/intent-confirmation.md](../rules/common/intent-confirmation.md). Template: "I'll review [target] as [sub-command], covering [files/scope]. Proceed?"

**Plan mode enforced.** Before executing any review, state: what's being reviewed, which sub-command, what files/specs are in scope. Wait for confirmation unless Gary said "just do it."

**Output discipline:** Do reasoning inside `<analysis>` tags (private). Produce clean verdict, table, and recommendations inside `<output>` tags.

**Artifact discipline.** Every prose artifact this command writes to disk (findings tables, council synthesis, dashboard reports, under `outputs/review/` or `outputs/gos-jobs/*/synthesis.md`) must comply with [rules/common/output-discipline.md](../rules/common/output-discipline.md) §6 Artifact Discipline and §7 Voice and AI smell. In-chat verdict tables are exempt from §6 (they aren't persisted files); they still follow §7 voice rules.

**Doc-type contract (§6.8).** Persisted review artifacts declare frontmatter:

| Output | Doc-type | First three H2s (§6.8 order) |
|--------|----------|------------------------------|
| `outputs/gos-jobs/*/synthesis.md` (council) | `decision-record` | Context (Why the review ran) → Verdict (What we decided: PASS/KILL/DEFER) → Rationale + Disagreements (How we got here) → Consequences (downstream effects of the verdict) |
| `outputs/review/ultra/*.md` | `research-memo` | Findings (What) → Why it matters (severity reasoning) → How to fix (ordered remediations) |
| `outputs/review/*/dashboard.md` | `research-memo` | Review Status (What) → Why gaps exist (Why) → How to clear (ordered actions) |

Frontmatter block (mandatory on persisted artifacts ≥100 lines):

```yaml
---
doc-type: <decision-record | research-memo>
audience: Gary Gao (reviewer)
reader-output: <verdict + next action / ranked fix list / clearance list>
generated: <ISO date>
---
```

The linter at [tests/hooks/artifact-discipline.bats](../tests/hooks/artifact-discipline.bats) verifies frontmatter + ordering.

---

## Diagnosis protocol (3-question pattern — FP-OS §3.2)

When reviewing something **broken** (activation dropped, performance regressed, spec-vs-code diverged, test flaking, feature underperforming), run this *before* categorising findings by severity. Applies inside `code`, `gate`, `fresh`, and any ad-hoc diagnostic review.

1. **Symptom precisely** — measurable deviation from expected, not a vague concern. ("Activation 42% → 31% over 3w"; not "retention feels off".)
2. **Mechanism chain** — from symptom backward: for this symptom to appear, what *must* be true? Each step is a hypothesis. Walk back until you reach atomic — a broken dependency, a wrong assumption, a violated invariant.
3. **Which link is broken?** — per hypothesis, what decisive signal would confirm or falsify it? Gather those first. Don't fix until the broken link is localised.

Skill: `engineering:debug`. **Failure mode:** treating a correlated symptom as the root ("retention down → add features") — chain was never drawn, fix targets a symptom two layers from the cause, cause keeps producing new symptoms. Always draw the chain.

---

## Terminal verdict (mandatory for every review sub-command)

Every review MUST close with exactly one of three outcomes — no ambiguous "looks good" / "mostly fine" allowed. Derived from FP-OS K6 (defer is real).

| Verdict | When | Format |
|---|---|---|
| **PASS** | All invariants satisfied AND variants score ≥ threshold | `VERDICT: PASS — <one-line rationale>` |
| **KILL** | Any invariant violated OR critical falsifier present | `VERDICT: KILL — <violated invariant or falsifier>` |
| **DEFER** | Signal insufficient to call; specify what would resolve | `VERDICT: DEFER — needs: <decisive signal / evidence / experiment>` |

**Rule:** sub-commands may map their legacy verdicts (APPROVE → PASS, BLOCK → KILL, CONCERN → DEFER-if-signal-insufficient else KILL, PROMOTE → PASS, REFINE → DEFER, REWORK → KILL) but the terminal line must use **PASS / KILL / DEFER**. Legacy labels remain as internal severity tags; the terminal verdict is canonical.

**Why DEFER matters:** Most "concerns" are signal-insufficient, not failures. Naming defer explicitly — with the specific resolver — turns stuck reviews into open-but-legible ones, and prevents rationalising past a real falsifier as a "concern."

---

## fresh

**Purpose:** Clean-context spec-vs-code verification (INV-G06). Spawns a fresh sonnet agent with **zero implementation context** — only the build contract + diff. Catches drift the implementing session is blind to.

**When to run:** Automatically invoked by `/ship` for any `/build feature` output. Manual invocation for ad-hoc audits.

**Input:**
- `outputs/build/{slug}/contract.md` — declared IN/OUT/NEVER + DoD
- `git diff {base}...HEAD` — what actually shipped
- `outputs/build/{slug}/compliance.md` — claimed mapping (if present)

**Process:**

```
Agent(
  prompt = "You are a fresh spec-vs-code verifier. You have NO knowledge of
            how this code was written. Below is the BUILD CONTRACT and the
            DIFF. For each Definition-of-Done item in the contract:
              1. Is it correctly implemented? Cite file:line.
              2. Is it incorrectly implemented? Explain the deviation.
              3. Is it missing? Flag it.
            For each OUT OF SCOPE item: did any code violate it?
            For each NEVER item: did any code violate it?
            For code NOT in the contract: list it under 'Undeclared behavior'.
            First-principles check (INV-G01): does the implementation reflect
              causal decomposition, or analogical pattern-matching? Flag any
              'like X' reasoning without a named mechanism.
            Verdict: PASS / PARTIAL / FAIL.

            CONTRACT:
            {contract.md content}

            DIFF:
            {git diff output}",
  subagent_type = "general-purpose",
  model = "sonnet",
  run_in_background = false
)
```

**Output:** `outputs/build/{slug}/verify.md` — verdict table + gap list. `/ship` reads this and blocks on FAIL.

**Anti-patterns:**
- Never feed this agent the implementation session's conversation history
- Never let this agent write code — read-only verifier
- Never shortcut — even if the implementing session "already reviewed its own work", run fresh

---

## ultra <files | diff>

**Purpose:** Delegate to native `/ultrareview` (CC v2.1.111+) for parallel multi-agent code review. Use for large diffs (≥10 files) or cross-cutting sweeps. Use `code` instead for small targeted PRs needing Fix-First or gOS invariant (INV-Gxx) checks.

**Process:** validate input (non-empty files/diff; else error "specify files or `--diff`"). Invoke native `/ultrareview`. Store output under `outputs/review/ultra/{timestamp}.md`. Drop findings <80% confidence. If any CRITICAL, escalate to `/review gate`.

**Fallback:** if native `/ultrareview` unavailable (older CC / non-Max), error cleanly and suggest `/review code` — do NOT silently fall through.

---

## code

**Purpose:** 2-pass PR review with Fix-First pattern. Use code-reviewer agent. If security findings, also invoke security-reviewer agent.

**Process:**

1. **Read the diff:** `git diff HEAD~1` or `git diff main...HEAD`
2. **Pass 1 — Critical (security + correctness):** SQL injection, race conditions, data loss, auth bypass, XSS, secrets exposure, null access, off-by-one
3. **Pass 2 — Informational (quality):** Naming, style, dead code, missing docs, complexity, duplication

**Fix-First classification:**

- **AUTO-FIX:** Import ordering, formatting, typos, inferable types, debug console.logs
- **ASK (batch into ONE question):** Logic changes, API changes, architectural decisions, dependency changes

**Confidence filter:** Only report findings >80% confidence.

**Convergence loop:** After auto-fixes, re-run Pass 1. If new issues introduced by fixes, fix those too. Max 3 fix-verify cycles.

**Output:** Findings table → Auto-fixed items → Batched questions → Verdict (APPROVE/WARNING/BLOCK).

**Findings table schema (mandatory columns):**

| Severity | File:Line | Issue | Signal Class | Mechanism chain | Fix |
|----------|-----------|-------|--------------|-----------------|-----|

**Signal Class** tags each finding per FP-OS §4 and the output-discipline rule's signal-calibration section:
- **decisive** — this finding alone flips the verdict (falsifier). One decisive signal = BLOCK regardless of count.
- **suggestive** — accumulates; no single finding flips the call, but N suggestive findings compose into CONCERN.

**Mechanism chain** traces the finding from symptom back to root cause per the FP-OS Diagnosis protocol (§3.2). Format: `symptom ← intermediate ← root-cause-atom`. Examples:
- `null deref in user.ts:42 ← unchecked return from getProfile() ← API contract drift not caught by types`
- `test flake in auth.spec ← race condition in session init ← mock clock not reset between suites`

Findings at CRITICAL/HIGH severity MUST have a mechanism chain reaching an atomic root cause (broken dependency / violated invariant / wrong assumption). MEDIUM/LOW severity MAY use a two-link chain; single-link findings are demoted to suggestive unless the symptom *is* the atom (e.g., a typo).

**Why both tags matter.** Without Signal Class, every finding reads equal-weight and reviews accumulate CONCERN without localising the single falsifier. Without Mechanism chain, fixes target symptoms two layers from the cause — the cause keeps producing new symptoms. Together they turn a flat findings list into a localised kill-shot with a named fix target.

---

## test — folded into `gate`

Test-suite execution + 4-level verification + evidence capture now run as part of `/review gate`. The gate checklist already includes "tests pass" and "coverage ≥ 80%"; the 4-level verification (EXISTS → SUBSTANTIVE → WIRED → DATA-FLOW) is now the verification body of `/review gate`. Use `/review gate` when you need both pass/fail + evidence. Convergence cap: 5 fix-rerun cycles; flag STUCK if the same test fails 3 times with different fixes.

---

## design — folded into `/design audit`

Visual/UX audits of the app or prototype now live next to the authoring commands. Use `/design audit` for state matrix, typography, spacing, color temperature, responsive, anti-slop, and 3-cycle audit-fix convergence. See `commands/design.md`.

---

## spec — folded into `/think spec`

Spec quality scoring runs inline inside `/think spec` before promoting to `specs/`. The rubric stays the same (5 dimensions × 0-2 → /10, with 8-10 = PROMOTE, 5-7 = REFINE, 0-4 = REWORK). See `commands/think.md`.

---

## gate

**Purpose:** Pre-ship quality gate. Binary PASS/FAIL. Any failure blocks `/ship`. Checklist is split into **INVARIANTS** (AND-aggregated — every one must pass) and **VARIANTS** (scored — partial acceptable with explicit justification) per FP-OS §3.1 and `rules/common/output-discipline.md` §2. Mixing the two in one flat list lets a weighted-sum rationalise past a deal-breaker — the split prevents that.

**Invariants (AND-aggregated — failing any single row BLOCKS ship):**

| # | Invariant | Command | Falsifier |
|---|-------|---------|-----------|
| 1 | Tests pass | `npm test` | Any failing test |
| 2 | Coverage ≥ 80% | `npm test -- --coverage` | Any file or overall < 80% |
| 3 | No lint errors | `npx eslint . --ext .ts,.tsx` | Any error-level rule violation |
| 4 | No type errors | `npx tsc --noEmit --pretty` | Any type error |
| 5 | No CRITICAL security findings | `npm audit --production` | Any critical or high finding |
| 6 | Review dashboard CLEARED | `/review dashboard` | Any STALE review or unresolved CRITICAL |

**Variants (scored — may pass with a named justification):**

| # | Variant | Signal | Score |
|---|-------|---------|-------|
| 7 | Docs updated | Changed code vs changed docs ratio | 0 / 1 / 2 (0 = no docs for new public API; 2 = full) |
| 8 | Bundle size delta | Production bundle vs baseline | 0 / 1 / 2 (0 = >10% regression without cause; 2 = no change or improvement) |

**Verdict rule:** PASS requires all 6 invariants green AND variant total ≥ 2 out of 4. FAIL lists every red invariant first, variants second, so the fix order is unambiguous.

**Output:** Invariant-pass table (6 rows binary) → Variant-score table (2 rows) → Verdict (PASS / FAIL) → If FAIL: ordered fix list, invariants before variants.

---

## council

**Purpose:** Full multi-persona review with weighted adjudication. Runs via PEV (see `specs/pev-protocol.md`).

> **Arx default:** The Arx council uses the **Independent Review Council** protocol — 6 archetype agents (3 S2 + 3 S7) running in fresh isolated context, reconciled by a synthesizer. See `specs/8-governance/Arx_8-6_Independent_Review_Council.md`. For non-Arx projects, the roster swaps but the PEV flow stays the same.

### Arx Independent Review Council (default for Arx)

**When:** Major hypothesis validation, Journey/Ship Card review, design-system changes with behavior impact, copy-trading mechanisms, trust/execution/leaderboard/signal-display features.

**7 parallel lanes** (fresh-context, no cross-talk):

| Lane | Agent | Archetype / Focus | Lens |
|---|---|---|---|
| 1 | `arx-s2-scalper` | S2 Scalper (sec–min, orderflow) | Latency, bracket orders, funding visibility, session discipline |
| 2 | `arx-s2-swing` | S2 Swing (days–weeks, narrative+momentum) | RS ranking, MA trails, thesis-invalidation, funding cost |
| 3 | `arx-s2-systematic` | S2 Systematic (rules-based, API-driven) | API completeness, Sharpe vs expected, override EV, regime awareness |
| 4 | `arx-s7-yield-chaser` | S7 Yield-Chaser (APY-framed, delegation) | Default sorts, survivorship, follower-return vs leader-return |
| 5 | `arx-s7-conviction-copier` | S7 Conviction-Copier (thesis via proxy) | Open-positions-now, on-chain verification, expectancy-of-overrides |
| 6 | `arx-s7-diversifier` | S7 Diversifier (portfolio, monthly cadence) | DD profile, correlation heatmap, regulatory standing, monthly cadence |
| 7 | `/ultrareview` | Code-quality (native CC parallel multi-agent) | Correctness, security, performance, bugs — N/A if prose-only target |

Plus: `arx-council-synthesizer` — reconciles all 7 lanes, surfaces disagreements, writes synthesis. Has no standing opinion.

**Flow:**
1. Extract self-contained target brief (must not require Arx-internal context to read). **Brief MUST include a Boundaries section** with IN / OUT / NEVER so each lane scores against the same scope — without it, lanes diverge on what the target actually is and the synthesizer sees scope-disagreement masquerading as lens-disagreement:
   ```
   ## Boundaries
   **IN:** <what the target does / claims / covers>
   **OUT:** <adjacent concerns handled elsewhere — name where>
   **NEVER:** <what the target explicitly refuses to do, and why>
   ```
2. Gary approves brief.
3. Spawn 7 lanes in parallel.
   - Lanes 1–6: archetype profile section (`Arx_2-1-S2_*` or `Arx_2-1-S7_*`) + target brief (boundaries included) + verdict template. NO other context.
   - Lane 7: `/ultrareview` on target code/diff. If prose-only, ultra returns `N/A — prose target`; synthesizer treats as non-signal.
4. Collect outputs → `outputs/gos-jobs/{job-id}/council/{archetype}.md` + `ultra.md`.
5. Spawn `arx-council-synthesizer` with all 7 outputs. Produces `outputs/gos-jobs/{job-id}/synthesis.md`.
6. Gary sees: synthesis + raw per-archetype verdicts + ultra findings + disagreement map.

**Verdict escalation rules — the Aggregation Rule (FP-OS §I rule-form, mandatory `## Aggregation Rule` H2 in synthesis):**

The synthesizer MUST state the aggregation rule explicitly in the synthesis, in §I form **"overall verdict = <verdict> iff <condition>"**. Default rules (may be overridden per target with a named justification):

- **BLOCK (decisive falsifiers, any one fires):**
  - Any S2 agent BLOCK on a mechanical issue (latency, API, order primitives) → overall BLOCK.
  - Any S7 agent BLOCK on a behavioral-trap issue (default 7d ROI sort, follower-count ranking) → overall BLOCK.
  - Any ultra CRITICAL finding on code (security, correctness, data loss) → overall BLOCK.
- **CONCERN (suggestive accumulation):**
  - ≥4 of 7 lanes raise the same concern → elevate to overall CONCERN minimum.
- **PASS (all invariants satisfied, variants accumulate):**
  - No decisive falsifier fires AND ≤3 lanes raise matching concern AND all lane verdicts computable (no lane returned insufficient evidence).

**Max one re-run per cycle.** If Gary rejects the synthesis, fix the `Arx_2-1-S*` profiles, don't re-run the council with the same profiles.

**Output:** Context H2 → Verdict table → Aggregation Rule H2 (the rule-form statement) → Disagreement map → top 3 kill-shots → code-quality section → Consequences H2 → recommendation → `outputs/gos-jobs/{job-id}/synthesis.md`.

### Legacy multi-specialist council (non-Arx projects, or Arx infrastructure-only reviews)

Roster (planner selects; Gary approves):

| Persona | Type | Weight | Lens |
|---------|------|:---:|------|
| crypto-sec | Specialist | 1× **(VETO)** | Keys, signing, MEV, input validation |
| trader-ux | Specialist | 1× | Order entry, price display, position mgmt |
| risk-analyst | Specialist | 1× | Margin, liquidation, leverage guards |
| mobile-perf | Specialist | 1× | Bundle size, render, network |
| contrarian | Strategic | 1× | Pre-mortem, kill shot, wargame |
| design-auditor | Specialist | 1× | Added only if target is UI/prototype |

Planner may add S2/S7 archetype agents from the Independent Review Council roster on top.

**Flow:** roster → Gary approval → parallel execution → `pev-validator` scores. `crypto-sec` BLOCK = absolute veto (STUCK). `adjudicator` synthesizes on CONVERGED. Max 2 cycles on ITERATE.

---

## dashboard

**Purpose:** Review readiness state per branch.

1. Get current branch and HEAD commit
2. Check review history — evidence of code, test, design, gate reviews
3. Staleness check — compare commit hash at review time vs current HEAD. STALE if HEAD advanced.

**Output:** Review status table (review, status, last run, commit, fresh?) → Verdict (CLEARED/NOT CLEARED) → Ordered list of reviews to run

---

## Single Persona Reviews

Any persona name can be invoked directly: `/review s2-jake`, `/review trader-ux`, `/review contrarian`, etc.

**5-step protocol:**

1. **Load Persona** — adopt the specialist's expertise, vocabulary, and focus from the council table above
2. **Research** — launch a background research agent for current best practices relevant to the persona's lens
3. **Evaluate** — review through persona's lens. Each finding: severity (CRITICAL/HIGH/MEDIUM/LOW), evidence, location (file:line or spec:section), **signal class** (decisive / suggestive — per FP-OS §4), **mechanism chain** (symptom ← intermediate ← root-cause-atom — per FP-OS §3.2), fix. CRITICAL/HIGH severity MUST reach an atomic root cause in the chain; single-link findings demote to suggestive.
4. **Verdict** — APPROVE / CONCERN / BLOCK. Always include: Steel Man ("strongest argument FOR"), Kill Shot ("single biggest risk"), Recommendation
5. **Output** — code fixes → `apps/`, spec corrections → `specs/`, decisions → `specs/Arx_9-1_Decision_Log.md`

---

## Strategic Personas

- **second-opinion** — Cross-model review. Run internal review → package artifact + findings → Gary pastes into GPT-5/Gemini → synthesize: agreements (high confidence), blind spots (external-only), noise (internal-only) → unified verdict.
- **contrarian** — Devil's advocate assuming the feature will FAIL. Steps: (1) Pre-Mortem — 3 failure scenarios with causal chains; (2) Kill Shot — weakest assumption; (3) Wargame — how a competitor exploits each weakness; (4) Steel Man — the narrow path to success; (5) Research — failed implementations, competitor advantages, user complaints. Output: Pre-Mortem → Kill Shot → Wargame → Steel Man → Verdict.
