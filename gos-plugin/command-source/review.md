---
effort: max
description: "Review: code, design, gate, council, eval — or any persona name directly"
---

# Review — Quality Assurance → specs/ + apps/

**Review inspects, judges, and proves.**

**Scratchpad checkpoints.** Update `sessions/scratchpad.md`:

- **On entry:** Write review type, target, mode (`Review > {sub-command}`)
- **After each review pass:** Log findings count and severity
- **After verdict:** Write verdict and top finding to `Key Decisions`
- **After compaction:** Re-read `sessions/scratchpad.md`

Parse the first word of `$ARGUMENTS` to determine sub-command. If it matches a persona name (s2-jake, s7-sarah, s1-alex, s3-marcus, trader-ux, crypto-sec, risk-analyst, mobile-perf, contrarian), run a single-persona review. If no sub-command given, ask: "What kind of review? code, design, gate, council, or eval?"

**Output discipline:** Do reasoning inside `<analysis>` tags (private). Produce clean verdict, table, and recommendations inside `<output>` tags.

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

**Output:** Visual issues table (screen, issue, severity, fix) → State coverage matrix → Anti-slop result → Verdict (APPROVE/REFINE/REJECT)

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

## e2e

**Purpose:** Generate and run Playwright E2E tests for critical user flows. Use e2e-runner agent.

**Process:**

1. **Identify critical flows** (trade execution, copy trading, portfolio, onboarding)
2. **Generate Playwright test files** — one per flow, 390x844 viewport, screenshots at each step
3. **Run locally 3-5 times** — confirm no flaky tests
4. **Quarantine flaky tests** to `__tests__/quarantine/`
5. **Capture artifacts:** screenshots, video, traces

**Output:** Flows table (flow, runs, pass, fail, flaky) → Quarantined list → Verdict (PASS/FAIL)

---

## coverage

**Purpose:** Test coverage analysis. Identify gaps and suggest tests.

**Process:**

1. **Run coverage tool** with text + json reporters
2. **Parse results:** 0% files, below-80% files, uncovered branches/functions
3. **Prioritize by risk:** HIGH (auth, payment, trade) 90%+, MEDIUM (UI) 80%, LOW (utilities) 60%
4. **Suggest specific tests** for each uncovered area

**Output:** Summary → Critical gaps table → Below-threshold table → Verdict (MET/NOT MET)

---

## council

**Purpose:** Full multi-persona review with live adjudication.

**Team Mode (always):** Council spawns reviewer agents in 3 waves with cross-examination.

- **Wave 1** (4 user personas, 2x vote weight): S2 Jake, S7 Sarah, S1 Alex, S3 Marcus
- **Wave 2** (4 specialists, 1x weight): crypto-sec, performance, UX, data. **Early termination:** if Wave 1 BLOCKs, skip Wave 2.
- **Wave 3** (1 contrarian, 1x weight): challenge consensus, find overlooked risks
- **Veto:** `crypto-sec` BLOCK is absolute. Any Wave 1 user BLOCK → overall BLOCK.
- **Adjudication:** Conductor routes conflicts via cross-examination between disagreeing agents.

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
2. **Research** — launch an agent to search for current best practices, known vulnerabilities, industry standards. Evidence-backed reviews, not LLM intuition.
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
