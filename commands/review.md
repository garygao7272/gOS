---
effort: max
description: "Review: code, design, gate, council, eval — or any persona name directly"
---

# Review — Quality Assurance → specs/ + apps/

**Review inspects, judges, and proves. Replaces the former /judge command and absorbs: code-review, grill-me, quality-gate, prove-it, e2e, test-coverage, eval, verify, verify-app.**

**Scratchpad checkpoints.** Update `sessions/scratchpad.md`:

- **On entry:** Write review type, target, and mode (`Review > {sub-command}`) to `Current Task`
- **After each review pass:** Log findings count and severity to `Working State`
- **After verdict:** Write verdict (APPROVE/WARNING/BLOCK) and top finding to `Key Decisions Made This Session`
- **On code/spec fixes applied:** Log files changed to `Files Actively Editing`
- **After compaction:** Re-read `sessions/scratchpad.md` to restore state

Parse the first word of `$ARGUMENTS` to determine sub-command. If it matches a persona name (s2-jake, s7-sarah, s1-alex, s3-marcus, trader-ux, crypto-sec, risk-analyst, signal-analyst, hl-protocol, mobile-perf, compliance, design-variant, second-opinion, contrarian), run a single-persona review. If no sub-command given, ask: "What kind of review? code, design, gate, council, or eval?"

> **Simplified (v2):** `test`/`prove`/`e2e`/`coverage` all folded into `gate` (pre-ship quality gate runs everything). `dashboard` folded into `/gos status`. `eval` absorbed from the former `/evaluate` command.

**Output discipline (two-phase pattern):** For council synthesis and multi-pass reviews, do reasoning inside `<analysis>` tags (private — not shown to Gary). Produce the clean verdict, table, and recommendations inside `<output>` tags. Individual persona verdicts are already structured; this applies to the lead's synthesis and cross-examination resolution.

---

## code

**Purpose:** 2-pass PR review with Fix-First pattern. Use code-reviewer agent. If security findings, also invoke security-reviewer agent.

**Process:**

1. **Read the diff:**
   - `git diff HEAD~1` for last commit, or `git diff main...HEAD` for full branch
   - Identify all changed files, added lines, removed lines
2. **Pass 1 — Critical (security + correctness):**
   - SQL injection (string concatenation in queries)
   - Race conditions (shared mutable state, async without locks)
   - Data loss (destructive operations without confirmation)
   - Auth bypass (missing permission checks, exposed endpoints)
   - XSS (unsanitized user input rendered as HTML)
   - Secrets exposure (API keys, tokens, passwords in code)
   - Null/undefined access (missing null checks on nullable values)
   - Off-by-one errors (loop bounds, array indexing)
3. **Pass 2 — Informational (quality):**
   - Naming (unclear variable/function names)
   - Style (inconsistent formatting, missing types)
   - Dead code (unused imports, unreachable branches)
   - Missing docs (public APIs without JSDoc)
   - Complexity (functions >50 lines, nesting >4 levels)
   - Duplication (copy-pasted logic that should be extracted)

**Fix-First classification:**

- **AUTO-FIX (apply immediately, no asking):**
  - Import ordering and unused imports
  - Formatting issues (trailing whitespace, missing semicolons)
  - Typos in comments and strings
  - Missing type annotations where inferable
  - Console.log statements left from debugging

- **ASK (batch into ONE question with multiple sub-items):**
  - Logic changes (different algorithm, different data structure)
  - API changes (new parameters, changed return types)
  - Architectural decisions (new patterns, restructured modules)
  - Dependency additions or removals

**Confidence filter:** Only report findings with >80% confidence. Suppress speculative concerns.

**Output format:**

```markdown
## Review: {branch or commit}

### Critical Findings

| #   | Severity | File:Line     | Issue         | Fix            |
| --- | -------- | ------------- | ------------- | -------------- |
| 1   | CRITICAL | {path}:{line} | {description} | {specific fix} |
| 2   | HIGH     | {path}:{line} | {description} | {specific fix} |

### Auto-Fixed

- {file}: removed unused import `{name}`
- {file}: fixed formatting on line {N}
- {file}: removed debug console.log

### Questions for Gary

**I have {N} items that need your input (batched):**

1. {question about logic/arch change} — my recommendation: {X}
2. {question about dependency} — my recommendation: {Y}
3. {question about scope} — my recommendation: {Z}

### Verdict: {APPROVE / WARNING / BLOCK}

{one-line summary of why}
```

---

## test

**Purpose:** Combined testing — runs QA + proves it works.

**Process:**

1. **Detect test framework:** Look for jest.config, vitest.config, pytest.ini, or package.json test scripts
2. **Run test suite:**

   ```bash
   # JavaScript/TypeScript
   npm test -- --coverage
   # or: npx vitest run --coverage

   # Python
   pytest --cov --cov-report=term-missing
   ```

3. **Check coverage:** Target 80%+. List files below threshold.
4. **Run E2E if critical flows changed:** Detect from diff which flows are affected. Run relevant Playwright tests.
5. **4-level verification (every changed module):**

   | Level       | Check                          | Method                                                                                | Fail Example                                |
   | ----------- | ------------------------------ | ------------------------------------------------------------------------------------- | ------------------------------------------- |
   | EXISTS      | File/function present          | `ls`, `grep` for exports                                                              | File created but empty                      |
   | SUBSTANTIVE | Not a stub                     | Check for `TODO`, `throw new Error('not implemented')`, empty function bodies, `pass` | Function exists but returns hardcoded value |
   | WIRED       | Imported, routed, rendered     | Trace import chain from entry point to the new code                                   | Component exists but never imported         |
   | DATA-FLOW   | Data actually flows end-to-end | Run the app, trigger the feature, verify output changes                               | API called but response never displayed     |

6. **Report results with evidence:**

```markdown
## Test Results: {target}

### Test Suite

- **Total:** {N} tests
- **Passed:** {N}
- **Failed:** {N}
- **Skipped:** {N}
- **Duration:** {time}

### Coverage

| File      | Statements | Branches | Functions | Lines   |
| --------- | ---------- | -------- | --------- | ------- |
| {file}    | {%}        | {%}      | {%}       | {%}     |
| **Total** | **{%}**    | **{%}**  | **{%}**   | **{%}** |

### 4-Level Verification

| Module   | EXISTS | SUBSTANTIVE | WIRED | DATA-FLOW |
| -------- | ------ | ----------- | ----- | --------- |
| {module} | PASS   | PASS        | PASS  | PASS      |

### Failures (if any)

{test name}: {error message}
{stack trace excerpt}

### Verdict: {PASS / FAIL}
```

---

## design

**Purpose:** Visual/UX audit of the app or prototype.

**Process:**

1. **Open the app/prototype** in Claude Preview or browser
2. **Check all states for every changed screen:**

   | State               | What to Look For                                 |
   | ------------------- | ------------------------------------------------ |
   | Default             | Layout, spacing, typography hierarchy, color     |
   | Loading             | Skeleton screens or spinners, not blank          |
   | Empty               | Helpful empty state message, not "No data"       |
   | Error               | User-friendly error message with recovery action |
   | Overflow            | Long text, many items, large numbers             |
   | Hover/Active        | Interactive feedback on all clickable elements   |
   | Selected/Unselected | Visual differentiation between states            |

3. **Typography audit:**
   - Numeric data in monospace (Geist Mono / JetBrains Mono)
   - Type scale: 11-24px range
   - No orphaned words in headings
   - Readable contrast ratios

4. **Spacing audit:**
   - 4px/8px grid alignment
   - Consistent padding within card types
   - No visual "rivers" of whitespace

5. **Color audit:**
   - Stone (violet) for structure/AI/actions, Water (cyan) for data/signals
   - Temperature distribution: T0 Ice (80%) / T1 Cool (15%) / T2 Warm (4%) / T3 Hot (1%)
   - No blended Stone/Water gradients

6. **Responsive check:**
   - 390x844 (iPhone 14 Pro) — primary
   - 375x812 (iPhone 13) — secondary
   - No horizontal scroll at any viewport

7. **Anti-slop check:**
   - No purple gradients
   - No generic 3-column grids
   - No AI-generic hero sections
   - Does it feel like Arx (amethyst citadel at night) or like a template?

8. **Atomic commits for each fix** — one visual fix per commit, not batched

**Output format:**

```markdown
## Design Review: {target}

### Visual Issues

| #   | Screen   | Issue         | Severity | Fix            |
| --- | -------- | ------------- | -------- | -------------- |
| 1   | {screen} | {description} | {H/M/L}  | {specific fix} |

### State Coverage

| Screen | Default | Loading | Empty | Error   | Overflow |
| ------ | ------- | ------- | ----- | ------- | -------- |
| {name} | OK      | MISSING | OK    | MISSING | OK       |

### Anti-Slop

{PASS or list of generic elements to replace}

### Verdict: {APPROVE / REFINE / REJECT}
```

---

## gate

**Purpose:** Pre-ship quality gate. Binary PASS/FAIL. All must pass to ship. Any failure blocks `/ship`.

**Checklist:**

| #   | Check                    | Command                       | Status                 |
| --- | ------------------------ | ----------------------------- | ---------------------- |
| 1   | Tests pass               | `npm test`                    | PASS/FAIL              |
| 2   | Coverage >= 80%          | `npm test -- --coverage`      | PASS/FAIL ({N}%)       |
| 3   | No lint errors           | `npx eslint . --ext .ts,.tsx` | PASS/FAIL ({N} errors) |
| 4   | No type errors           | `npx tsc --noEmit --pretty`   | PASS/FAIL ({N} errors) |
| 5   | No security warnings     | `npm audit --production`      | PASS/FAIL ({N} vulns)  |
| 6   | Docs updated             | Check changed files vs docs   | PASS/FAIL/N/A          |
| 7   | Review dashboard CLEARED | See `/review dashboard`       | PASS/FAIL              |

**Output:**

```markdown
## Quality Gate: {branch}

| Check    | Result          | Details                  |
| -------- | --------------- | ------------------------ |
| Tests    | {PASS/FAIL}     | {N} passed, {N} failed   |
| Coverage | {PASS/FAIL}     | {N}% (target: 80%)       |
| Lint     | {PASS/FAIL}     | {N} errors, {N} warnings |
| Types    | {PASS/FAIL}     | {N} errors               |
| Security | {PASS/FAIL}     | {N} vulnerabilities      |
| Docs     | {PASS/FAIL/N/A} | {details}                |
| Reviews  | {PASS/FAIL}     | {details}                |

## Verdict: {PASS / FAIL}

{if FAIL: list what must be fixed before shipping}
```

---

## prove

**Purpose:** Prove changes work with evidence, not assertions. Output evidence, not opinions.

**Process:**

1. **Read the diff** — understand what changed
2. **Run tests** — capture output with pass/fail counts
3. **Check build** — confirm it compiles without errors
4. **Verify edge cases:**
   - What happens with null input?
   - What happens with empty data?
   - What happens at boundaries?
   - What happens under load?
5. **Check for regressions:**
   - Did any existing tests break?
   - Do existing features still work?
   - Did bundle size change significantly?
6. **4-level verification** (same as in `test` sub-command):
   - EXISTS → SUBSTANTIVE → WIRED → DATA-FLOW
7. **Capture evidence:**
   - Test output (actual terminal output, not paraphrased)
   - Screenshots of working features
   - Console logs showing data flow
   - Network requests showing API calls

**Output format:**

```markdown
## Proof: {what was changed}

### Evidence

1. **Tests:** {N}/{N} passed — {actual test output}
2. **Build:** Clean — {build command output}
3. **Visual:** {screenshot reference showing it works}
4. **Data Flow:** {console/network log showing data moves correctly}
5. **Edge Cases:** {what was tested and results}

### Regressions

- Existing tests: {all pass / N failures}
- Bundle size: {before} → {after} ({delta})

### 4-Level Verification

| Module | EXISTS | SUBSTANTIVE | WIRED | DATA-FLOW | Evidence       |
| ------ | ------ | ----------- | ----- | --------- | -------------- |
| {name} | PASS   | PASS        | PASS  | PASS      | {how verified} |

### Verdict: {PROVEN / NOT PROVEN}

{if NOT PROVEN: what's missing}
```

---

## e2e

**Purpose:** Generate and run Playwright E2E tests for critical user flows. Use e2e-runner agent.

**Process:**

1. **Identify critical flows to test:**
   - Trade execution (place order → confirm → position appears)
   - Copy trading (select leader → configure → position mirrors)
   - Portfolio view (load → see positions → see P&L)
   - Onboarding (connect wallet → fund → first trade)
2. **Generate Playwright test files:**
   - One test file per flow
   - Use 390x844 viewport (iPhone 14 Pro)
   - Include setup/teardown for test data
   - Capture screenshots at each step
   - Capture network requests for API verification
3. **Run locally 3-5 times:**
   - Confirm no flaky tests
   - If a test fails intermittently, add retry logic or quarantine it
4. **Quarantine flaky tests:**
   - Move to `__tests__/quarantine/` with a note explaining the flakiness
   - Do not let flaky tests block the pipeline
5. **Capture artifacts:**
   - Screenshots at each test step
   - Video recording of each test run
   - Trace files for debugging failures

**Output:**

```markdown
## E2E Test Results

### Flows Tested

| Flow        | Runs | Pass | Fail | Flaky |
| ----------- | ---- | ---- | ---- | ----- |
| {flow name} | 5    | 5    | 0    | No    |

### Screenshots

{references to captured screenshots}

### Quarantined

{list of flaky tests moved to quarantine, if any}

### Verdict: {PASS / FAIL}
```

---

## coverage

**Purpose:** Test coverage analysis. Identify gaps and suggest tests to fill them.

**Process:**

1. **Run coverage tool:**
   ```bash
   npm test -- --coverage --coverageReporters=text --coverageReporters=json
   ```
2. **Parse results** — identify:
   - Files with 0% coverage (completely untested)
   - Files below 80% coverage
   - Uncovered branches (if/else paths never tested)
   - Uncovered functions (public API never called in tests)
3. **Prioritize by risk:**
   - HIGH: Auth, payment, trade execution — must be 90%+
   - MEDIUM: UI components, data display — target 80%
   - LOW: Utilities, helpers, config — 60% acceptable
4. **Suggest specific tests** for each uncovered area:
   - What test to write
   - What behavior it verifies
   - What edge cases it covers

**Output:**

```markdown
## Coverage Analysis

### Summary

- **Overall:** {N}% statements, {N}% branches, {N}% functions
- **Target:** 80% | **Status:** {MET / NOT MET}

### Critical Gaps (must fix)

| File   | Coverage | Uncovered Lines | Suggested Test     |
| ------ | -------- | --------------- | ------------------ |
| {path} | {N}%     | {lines}         | {test description} |

### Below Threshold

| File   | Coverage | Risk Level | Priority                             |
| ------ | -------- | ---------- | ------------------------------------ |
| {path} | {N}%     | {H/M/L}    | {fix now / next sprint / acceptable} |

### Fully Covered (>90%)

{list of well-tested files — these are good}
```

---

## council

**Purpose:** Full multi-persona review with live adjudication via native Agent Teams.

**Team Mode (always):** Council uses the `review-panel` template from `.claude/agents/team-registry.md`.

Load the template for full details: waves, agents, task flow, verdict protocol, and shutdown.

**Key points (summary from registry):**

- **Wave 1** (4 user personas, 2x vote weight): S2 Jake, S7 Sarah, S1 Alex, S3 Marcus — all spawned as `reviewer` agents with persona-specific prompts
- **Wave 2** (4 specialists, 1x weight): crypto-sec, performance, UX (`designer` agent), data — spawned after Wave 1 completes. **Early termination:** if Wave 1 issues a BLOCK, skip Wave 2.
- **Wave 3** (1 contrarian, 1x weight): challenge consensus, find overlooked risks
- **Veto:** `crypto-sec` BLOCK is absolute. Any Wave 1 user BLOCK → overall BLOCK.
- **Adjudication:** Conductor routes conflicts via `SendMessage` cross-examination between disagreeing agents.

**Persona definitions** (spawn prompts for each reviewer agent):

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

**Output format:**

```markdown
## Council Review: {target}

### Verdicts

| Persona | Type | Verdict | Kill Shot | Weight |
|---------|------|---------|-----------|--------|
| {name} | {type} | {APPROVE/CONCERN/BLOCK} | {one-line} | {1x/2x} |

### Weighted Synthesis

**Overall: {APPROVE / CONCERN / BLOCK}**

### Top 3 Findings + Recommended Actions
```

---

## dashboard

**Purpose:** Review readiness state per branch. Shows what reviews have been done and what's missing.

**Process:**

1. **Get current branch and HEAD commit:**
   ```bash
   git branch --show-current
   git rev-parse --short HEAD
   ```
2. **Check review history** — look for evidence of each review type:
   - `/review code` — was a code review done? Check git log for review commits, scratchpad for review notes
   - `/review test` — were tests run? Check for recent test output, coverage reports
   - `/review design` — was a design review done? Check scratchpad, output files
   - `/review gate` — was quality gate run? Check for gate output
3. **Staleness check:** Compare commit hash at review time vs current HEAD
   - If HEAD has advanced since the review, mark as STALE
   - STALE reviews need to be re-run before shipping
4. **Output:**

```markdown
## Review Dashboard: {branch} @ {commit}

| Review   | Status              | Last Run | At Commit | Fresh?            |
| -------- | ------------------- | -------- | --------- | ----------------- |
| Code     | {PASS/FAIL/NOT RUN} | {date}   | {commit}  | {FRESH/STALE/N/A} |
| Test     | {PASS/FAIL/NOT RUN} | {date}   | {commit}  | {FRESH/STALE/N/A} |
| Design   | {PASS/FAIL/NOT RUN} | {date}   | {commit}  | {FRESH/STALE/N/A} |
| Gate     | {PASS/FAIL/NOT RUN} | {date}   | {commit}  | {FRESH/STALE/N/A} |
| E2E      | {PASS/FAIL/NOT RUN} | {date}   | {commit}  | {FRESH/STALE/N/A} |
| Security | {PASS/FAIL/NOT RUN} | {date}   | {commit}  | {FRESH/STALE/N/A} |

## Verdict: {CLEARED / NOT CLEARED}

{if NOT CLEARED: list what's missing or stale}

### To Clear

{ordered list of reviews to run}
```

---

## Single Persona Reviews

Any persona name can be invoked directly: `/review s2-jake`, `/review trader-ux`, `/review contrarian`, etc.

**Every single-persona review follows the same 5-step protocol:**

### Step 1: Load Persona

Read the persona definition from the council section above. Adopt the specialist's expertise, vocabulary, and review focus. You ARE this specialist for the duration of the review.

### Step 2: Research Phase

Before forming any opinion, RESEARCH. Launch an agent to search for current best practices, known vulnerabilities, industry standards, and expert opinions relevant to this review. Use WebSearch for web research. Use specs/ for internal context. The goal: evidence-backed reviews, not LLM intuition.

### Step 3: Evaluate

Review the target through the persona's lens. For each finding:

- **Severity:** CRITICAL (blocks ship) / HIGH (should fix) / MEDIUM (advisory) / LOW (nitpick)
- **Evidence:** Why this is an issue — cite research, specs, or standards
- **Fix:** Specific, actionable recommendation
- **Location:** Exact file:line or spec:section

### Step 4: Verdict

Issue one of:

- **APPROVE** — No CRITICAL or HIGH issues. Ship it.
- **CONCERN** — HIGH issues found. Should fix before shipping, but not blocking.
- **BLOCK** — CRITICAL issues found. Must fix. Do not ship.

Always include:

- **Steel Man:** "The strongest argument FOR the current approach is..."
- **Kill Shot:** "The single biggest risk is..."
- **Recommendation:** Specific next steps

### Step 5: Output

- Code fixes → apply directly to `apps/` files (with user approval)
- Spec corrections → update relevant `specs/` files
- Decision records → append to `specs/Arx_9-1_Decision_Log.md`

---

## Strategic Personas (invoke individually)

### second-opinion

Cross-model review to catch blind spots and groupthink.

1. **Internal Review:** Run a standard review through the most relevant specialist persona. Capture findings.
2. **Export Prompt:** Package artifact + findings into a structured prompt for an external model:

```
--- PASTE INTO GPT-5 / GEMINI / OTHER MODEL ---

Review this [code/spec] for: architectural issues, missed edge cases, security concerns, and UX problems. Be contrarian — assume the author is wrong about at least one major decision.

Context: This is part of Arx, a mobile-first crypto trading terminal on Hyperliquid for retail traders. Primary users are swing traders ($10K-$100K accounts) and copy-trade followers ($5K-$15K accounts, mobile-only, once-per-day check-in).

<ARTIFACT>
[artifact will be inserted here]
</ARTIFACT>

<INTERNAL_REVIEW>
[internal findings will be inserted here]
</INTERNAL_REVIEW>

Format each finding as:
CONCERN (CRITICAL/HIGH/MEDIUM/LOW) | REASONING | SUGGESTION

End with: "The single thing this team is most likely wrong about is: ___"

--- END PROMPT ---
```

3. **Instruct:** "Paste this into a different model. Paste the response back here."
4. **Synthesize:** Flag agreements (HIGH confidence), blind spot candidates (only external found), possible noise (only internal found). Unified verdict.

### contrarian

Devil's advocate who assumes the feature will FAIL.

1. **Pre-Mortem:** "It's 12 months from now. This has failed. What went wrong?" — 3 failure scenarios with causal chains
2. **Kill Shot:** The single weakest assumption that makes everything irrelevant if wrong
3. **Wargame:** For each failure scenario, what would a competitor do to exploit the weakness?
4. **Steel Man:** "The exact narrow path to make this succeed is..." — be specific about what MUST be true
5. **Research:** Search for failed implementations of similar features, competitor advantages, user complaints

Output: Pre-Mortem → Kill Shot → Wargame → Steel Man → Verdict
