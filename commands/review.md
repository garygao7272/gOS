---
effort: max
description: "Review: code, test, design, gate, council, eval — or any persona name directly"
---

# Review — Quality Assurance → specs/ + apps/

**Review inspects, judges, and proves.**

**Scratchpad checkpoints.** Update `sessions/scratchpad.md`:

- **On entry:** Write review type, target, mode (`Review > {sub-command}`)
- **After each review pass:** Log findings count and severity
- **After verdict:** Write verdict and top finding to `Key Decisions`
- **After compaction:** Re-read `sessions/scratchpad.md`

Parse the first word of `$ARGUMENTS` to determine sub-command. If it matches a persona name (s2-jake, s7-sarah, s1-alex, s3-marcus, trader-ux, crypto-sec, risk-analyst, mobile-perf, contrarian), run a single-persona review. If no sub-command given, ask: "What kind of review? code, test, design, spec, gate, council, or eval?"

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

## test

**Purpose:** Combined testing — runs suite + proves changes work with evidence.

**Process:**

1. **Detect test framework** and run with coverage
2. **Check coverage** — target 80%+
3. **Run E2E if critical flows changed**
4. **4-level verification** (every changed module):

   | Level | Check | Method |
   |-------|-------|--------|
   | EXISTS | File/function present | `ls`, `grep` for exports |
   | SUBSTANTIVE | Not a stub | Check for TODO, empty bodies |
   | WIRED | Imported, routed, rendered | Trace import chain |
   | DATA-FLOW | Data flows end-to-end | Run app, trigger feature, verify |

5. **Capture evidence:** Test output, screenshots, console logs, network requests
6. **Check for regressions:** Existing tests, bundle size

**Convergence loop:** If tests fail, diagnose → fix → rerun. Max 5 fix-rerun cycles. If same test fails 3 times with different fixes, flag as STUCK and escalate.

**Output:** Test results (total/pass/fail) → Coverage table → 4-level verification → Evidence → Verdict (PASS/FAIL)

---

## design

**Purpose:** Visual/UX audit of the app or prototype.

**Process:**

1. **Open in Claude Preview or browser**
2. **Check all states:** Default, Loading, Empty, Error, Overflow, Hover/Active, Selected/Unselected
3. **Typography audit:** Monospace for numbers, 11-24px scale, contrast ratios
4. **Spacing audit:** 4px/8px grid, consistent padding, no whitespace rivers
5. **Color audit:** Stone for structure, Water for data, temperature distribution T0(80%)/T1(15%)/T2(4%)/T3(1%)
6. **Responsive check:** 390x844 primary, 375x812 secondary, no horizontal scroll
7. **Anti-slop check:** No purple gradients, no generic grids, no AI-template aesthetics
8. **Atomic commits for each fix**

**Convergence loop:** After fixes, re-screenshot and re-audit changed areas. Continue until no new CRITICAL/HIGH visual issues. Max 3 audit-fix cycles.

**Output:** Visual issues table (screen, issue, severity, fix) → State coverage matrix → Anti-slop result → Verdict (APPROVE/REFINE/REJECT)

---

## spec

**Purpose:** Spec quality gate. Scores a spec for completeness before promoting to `specs/`. Run this before `/think spec` promotes output or before any major spec edit.

**Scoring dimensions (each 0-2, total /10):**

| # | Dimension | 0 | 1 | 2 |
|---|-----------|---|---|---|
| 1 | **Acceptance Criteria** | None | Vague or incomplete | MECE, testable, each has pass/fail condition |
| 2 | **Edge Cases** | None mentioned | Some listed | Exhaustive: empty, overflow, error, concurrent, stale |
| 3 | **Data Model** | No data defined | Fields listed but no types/constraints | Full schema: types, constraints, defaults, nullability |
| 4 | **Cross-References** | No links to other specs | Some references | All dependencies linked, no orphan references |
| 5 | **Freshness** | References stale/missing files | Minor staleness | All refs valid, recently updated |

**Process:**

1. **Read the spec** — understand its purpose and scope
2. **Run freshness check** — `bash tools/spec-freshness.sh` on the spec's directory
3. **Score each dimension** 0-2 with evidence
4. **Verdict:**
   - 8-10: **PROMOTE** — ready for `specs/`
   - 5-7: **REFINE** — list what's missing, suggest fixes
   - 0-4: **REWORK** — too incomplete, list required additions

**Convergence loop:** If verdict is REFINE, present gaps → fix → rescore. Max 2 cycles.

**Output:** Score table (dimension, score, evidence) → Total /10 → Verdict → Gaps to fix (if any)

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

**Purpose:** Full multi-persona review with live adjudication.

**Team Mode (always):** Council spawns reviewer agents in 3 waves with cross-examination.

- **Wave 1** (4 user personas, 2x vote weight): S2 Jake, S7 Sarah, S1 Alex, S3 Marcus
- **Wave 2** (4 specialists, 1x weight): crypto-sec, performance, UX, data. **Early termination:** if Wave 1 BLOCKs, skip Wave 2.
- **Wave 3** (1 contrarian, 1x weight): challenge consensus, find overlooked risks
- **Veto:** `crypto-sec` BLOCK is absolute. Any Wave 1 user BLOCK → overall BLOCK.
- **Adjudication:** Conductor routes conflicts via cross-examination between disagreeing agents.

**Wave 1 — launch all 4 in a single message.** Each persona reviews through their lens with APPROVE/CONCERN/BLOCK verdict, kill shot + steel man.

**If Wave 1 has no BLOCKs, launch Wave 2** (crypto-sec, trader-ux, risk-analyst, mobile-perf) — all in a single message.

**Wave 3** — contrarian reviews all prior findings, challenges consensus.

**Convergence loop:** If council verdict is BLOCK, present findings → Gary decides fix list → apply fixes → re-run the blocking wave only. Max 2 council-fix cycles.

**Persona definitions:**

| Persona | Type | Review Lens |
|---------|------|-------------|
| s2-jake | User | "Would Jake use this daily and does it save him time?" |
| s7-sarah | User | "Would Sarah set this up and feel safer?" |
| s1-alex | User | "Does this keep Alex engaged AND prevent blow-up?" |
| s3-marcus | User | "Does this degrade execution quality or privacy?" |
| crypto-sec | Specialist | Key management, transaction signing, MEV, input validation |
| trader-ux | Specialist | Order entry flow, price display, position management |
| risk-analyst | Specialist | Margin calculations, liquidation warnings, leverage guards |
| mobile-perf | Specialist | Bundle size, render performance, network efficiency |
| contrarian | Strategic | Pre-mortem, kill shot, wargame, steel man |

**Output:** Verdicts table (persona, type, verdict, kill shot, weight) → Weighted synthesis → Top 3 findings + actions

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

### second-opinion

Cross-model review. Run internal review → package artifact + findings into a prompt for GPT-5/Gemini → instruct Gary to paste in another model → synthesize: agreements (high confidence), blind spots (only external found), noise (only internal found) → unified verdict.

### contrarian

Devil's advocate who assumes the feature will FAIL.

1. **Pre-Mortem:** 3 failure scenarios with causal chains
2. **Kill Shot:** Single weakest assumption
3. **Wargame:** How would a competitor exploit each weakness?
4. **Steel Man:** The exact narrow path to success
5. **Research:** Failed implementations, competitor advantages, user complaints

Output: Pre-Mortem → Kill Shot → Wargame → Steel Man → Verdict
