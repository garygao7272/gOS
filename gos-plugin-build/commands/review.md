---
description: "Review: fresh, code, gate, council, eval, refine — or any persona name directly. TRIGGER when user asks to review, audit, or quality-check existing work — phrases like 'review this', 'audit X', 'is this good', 'is this safe', 'check this before I ship', 'red team this', 'second opinion on X', 'council review', or names a specific persona (s1-s8, trader-ux, crypto-sec, contrarian, etc.). SKIP for the initial creation of something — use /think or /design for that."
---

# Review — Quality Assurance → specs/ + apps/

**Review inspects, judges, and proves.**

**Scratchpad checkpoints.** Update `sessions/scratchpad.md`:

- **On entry:** Write review type, target, mode (`Review > {sub-command}`)
- **After each review pass:** Log findings count and severity
- **After verdict:** Write verdict and top finding to `Key Decisions`
- **After compaction:** Re-read `sessions/scratchpad.md`

Parse the first word of `$ARGUMENTS` to determine sub-command. If it matches a persona name (s2-jake, s7-sarah, s1-alex, s3-marcus, trader-ux, crypto-sec, risk-analyst, mobile-perf, contrarian), run a single-persona review. If no sub-command given, ask: "What kind of review? fresh, code, gate, council, eval, refine, ultra, or a persona?"

**Routing for `ultra` vs `council`:** if input is file paths, a diff, or a staged changeset → **ultra** (delegate to native `/ultrareview`). If input is a topic, spec, design, or strategy question → **council** (gOS persona swarm).

**Intent confirmation (always).** Before executing, restate scope in one line: "I'll review [target] as [sub-command], covering [files/scope]. Proceed?" Skip only if Gary said "just do it."

**Plan mode enforced.** Before executing any review, state: what's being reviewed, which sub-command, what files/specs are in scope. Wait for confirmation unless Gary said "just do it."

**Output discipline:** Do reasoning inside `<analysis>` tags (private). Produce clean verdict, table, and recommendations inside `<output>` tags.

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

**Output:** Findings table (severity, file:line, issue, fix) → Auto-fixed items → Batched questions → Verdict (APPROVE/WARNING/BLOCK)

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

**Purpose:** Pre-ship quality gate. Binary PASS/FAIL. Any failure blocks `/ship`.

**Checklist:**

| # | Check | Command |
|---|-------|---------|
| 1 | Tests pass | `npm test` |
| 2 | Coverage >= 80% | `npm test -- --coverage` |
| 3 | No lint errors | `npx eslint . --ext .ts,.tsx` |
| 4 | No type errors | `npx tsc --noEmit --pretty` |
| 5 | No security warnings | `npm audit --production` |
| 6 | Docs updated | Check changed files vs docs |
| 7 | Review dashboard CLEARED | All reviews fresh |

**Output:** Check results table → Verdict (PASS/FAIL) → What must be fixed if FAIL

---

## council

**Purpose:** Full multi-persona review with weighted adjudication. Runs via PEV (see `specs/pev-protocol.md`).

> **Scope note:** The `s1-s8` personas below are Arx-specific (trader/investor segments). In non-Arx projects, Gary swaps them for that project's user segments — the PEV flow + vote-weight structure stays the same.

**Roster** (planner selects; Gary approves):

| Persona | Type | Weight | Lens |
|---------|------|:---:|------|
| s2-jake | User | 2× | Daily use + saves time |
| s7-sarah | User | 2× | Safe setup + trust |
| s1-alex | User | 2× | Engagement vs blow-up |
| s3-marcus | User | 2× | Execution quality + privacy |
| crypto-sec | Specialist | 1× **(VETO)** | Keys, signing, MEV, input validation |
| trader-ux | Specialist | 1× | Order entry, price display, position mgmt |
| risk-analyst | Specialist | 1× | Margin, liquidation, leverage guards |
| mobile-perf | Specialist | 1× | Bundle size, render, network |
| contrarian | Strategic | 1× | Pre-mortem, kill shot, wargame |
| design-auditor | Specialist | 1× | Added only if target is UI/prototype |

Planner may drop a user persona if the target clearly doesn't touch their lens.

**Flow:** roster → Gary approval → parallel execution (each returns APPROVE/CONCERN/BLOCK + kill-shot + steel-man) → `pev-validator` scores. `crypto-sec` BLOCK = absolute veto (STUCK). Any wave-1 user BLOCK = STUCK. Otherwise compute weighted consensus. On CONVERGED, `adjudicator` synthesizes. On ITERATE, re-run blocking subset only (max 2 cycles). On STUCK, wait for Gary's fix list.

**Output:** Verdict table → weighted synthesis → top 3 findings + actions → `outputs/gos-jobs/{job-id}/synthesis.md`.

---

## refine <topic> [max-iterations]

**Purpose:** Prebuild convergence loop. Iteratively tighten specs, designs, and simulations before `/build`. Each cycle runs think → design → simulate → review; review feeds gaps back into the next cycle. Exits at convergence, stuck, good-enough, or max iterations.

**Default:** 5 iterations max. Example: `/review refine copy-trading 3`.

**Rubric:** `evals/rubrics/refine.md` — 5 dimensions (gap resolution, cycle rigor, convergence, depth progression, build-readiness) weighted to /10.

**When to use:** Before any non-trivial `/build feature` that touches UI, flows, or specs. Skip for fixes, refactors, and single-file features.

**Execution:**

| Phase | Input | Focus | Agents | Output |
|-------|-------|-------|--------|--------|
| **THINK** | Prior gap list (or Cycle 0 scan) | Top 3-5 gaps by severity | 2-3 parallel researchers (sonnet) | Updated specs + refine log |
| **DESIGN** | Updated specs | Visual/interaction gaps | 1 design auditor (sonnet) | Design decisions in refine log |
| **SIMULATE** | Specs + designs | Stress scenarios (happy → edge → adversarial → scale) | Bull-case + bear-case (sonnet, parallel) | Scenario results |
| **REVIEW** | All outputs above | NEW gaps not in previous list | Review adjudicator (opus) | Numbered gap list with severity |

**Gap severity:** 🔴 CRITICAL (blocks build) · 🟠 HIGH (degrades UX) · 🟡 MEDIUM (polish) · 🟢 LOW (cosmetic).

**Convergence:** end of REVIEW counts NEW 🔴 + 🟠 gaps. If `new_critical == 0 AND new_high <= 2` → **CONVERGED**, exit. If same gaps recur 2+ cycles → **STUCK**, flag. If all remaining are MEDIUM/LOW → **GOOD ENOUGH**, exit with polish list. Otherwise continue (cap = max-iterations; hard ceiling 7, diminishing returns beyond).

**Output:** `outputs/think/refine/{topic}-refine-summary.md` — cycles run, exit reason, gaps resolved/remaining, then "Ready for /build?".

**Anti-patterns:** Don't refine and build simultaneously — refine is prebuild. Don't refine topics without pre-existing specs — run `/think discover` first. Don't set max iterations > 7.

> **Legacy entry:** `/refine <topic>` and `/gos refine <topic>` both route here. `/review refine` is canonical.

---

## eval <command-name> [--runs N]

**Purpose:** Measure gOS command quality against rubrics with synthetic inputs. Answers: "Is this command getting better or worse?"

Default N=1. Maximum N=5 (cost guard).

**Process:**

1. **Load test input** from `evals/test-inputs/{command-name}-input.md`. If not found, offer to create one.
2. **Load rubric** from `evals/rubrics/{command-name}.md`. Extract dimensions, weights, scoring criteria.
3. **Execute run:** Spawn executor agent (sonnet, fresh context) with test input + command context. Capture output.
4. **Score:** Spawn separate scoring agent (sonnet — no self-grading). Strict rubric scoring: 5=adequate, 7=good, 9=exceptional. Returns JSON with per-dimension scores.
5. **Compare to baseline** from `evals/baselines/{command-name}/latest.json` if it exists. Delta >+0.5 = IMPROVED, <-0.5 = REGRESSED, else STABLE.
6. **Report:** Dimension table with scores, baseline comparison, variance, cost estimate.

If any dimension REGRESSED: flag and suggest `/evolve upgrade {command}`.

**Sub-actions:**

| Argument | Action |
|----------|--------|
| `eval <cmd>` | Run and score |
| `eval create <cmd>` | Create new test input interactively |
| `eval baseline <cmd>` | Set current results as baseline |
| `eval report` | Show all commands' eval scores and trends |
| `eval compare <cmd>` | Dimension-by-dimension baseline comparison |

**Convergence loop for multi-run evals (N>1):** Run N times. If variance across runs >1.5 on any dimension, flag as unreliable and suggest refining the rubric or test input.

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
3. **Evaluate** — review through persona's lens. Each finding: severity (CRITICAL/HIGH/MEDIUM/LOW), evidence, fix, location (file:line or spec:section)
4. **Verdict** — APPROVE / CONCERN / BLOCK. Always include: Steel Man ("strongest argument FOR"), Kill Shot ("single biggest risk"), Recommendation
5. **Output** — code fixes → `apps/`, spec corrections → `specs/`, decisions → `specs/Arx_9-1_Decision_Log.md`

---

## Strategic Personas

- **second-opinion** — Cross-model review. Run internal review → package artifact + findings → Gary pastes into GPT-5/Gemini → synthesize: agreements (high confidence), blind spots (external-only), noise (internal-only) → unified verdict.
- **contrarian** — Devil's advocate assuming the feature will FAIL. Steps: (1) Pre-Mortem — 3 failure scenarios with causal chains; (2) Kill Shot — weakest assumption; (3) Wargame — how a competitor exploits each weakness; (4) Steel Man — the narrow path to success; (5) Research — failed implementations, competitor advantages, user complaints. Output: Pre-Mortem → Kill Shot → Wargame → Steel Man → Verdict.
