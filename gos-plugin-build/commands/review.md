---
description: "Review: code, test, design, gate, prove, e2e, coverage, council, dashboard, financial, content, candidate, compliance — or any persona name directly"
---

# Review — Quality Assurance → specs/ + apps/

**Review inspects, judges, and proves. Replaces the former /judge command and absorbs: code-review, grill-me, quality-gate, prove-it, e2e, test-coverage, eval, verify, verify-app.**

**Scratchpad checkpoints.** Update `sessions/scratchpad.md`:

- **On entry:** Write review type, target, and mode (`Review > {sub-command}`) to `Current Task`
- **After each review pass:** Log findings count and severity to `Working State`
- **After verdict:** Write verdict (APPROVE/WARNING/BLOCK) and top finding to `Key Decisions Made This Session`
- **On code/spec fixes applied:** Log files changed to `Files Actively Editing`
- **After compaction:** Re-read `sessions/scratchpad.md` to restore state

Parse the first word of `$ARGUMENTS` to determine sub-command. If it matches a persona name (s2-jake, s7-sarah, s1-alex, s3-marcus, trader-ux, crypto-sec, risk-analyst, signal-analyst, hl-protocol, mobile-perf, compliance, design-variant, second-opinion, contrarian), run a single-persona review. If no sub-command given, ask: "What kind of review? code, test, design, gate, prove, e2e, coverage, council, dashboard, financial, content, candidate, or compliance?"

---

## Intent Gate (mandatory — runs before any sub-command)

**First-Principles Decomposition.** Every request is broken into 6 MECE dimensions before execution.

### Step 1: DECOMPOSE

Parse Gary's request. Fill every dimension and classify:

| Dim | Question | ✅ Stated | 🔮 Inferred | ❌ Unknown |
|-----|----------|-----------|-------------|-----------|
| **WHAT** | What are we reviewing? (code, design, model, content, candidate) | Gary named it | Derivable from context | Must ask |
| **WHY** | What outcome? (quality gate, learning, ship-readiness, compliance) | Gary stated purpose | Implied by sub-command | Must ask |
| **WHO** | Who is the audience? (Gary, team, users, regulators) | Gary specified | Obvious from review type | Must ask |
| **HOW** | What method? (single-pass, adversarial council, persona review) | Gary chose sub-command | Matches complexity | Must ask |
| **SCOPE** | Which parts? (last commit, branch, full app, specific files) | Gary bounded it | Inferrable from diff/context | Must ask |
| **BAR** | What standard? (quick check, thorough, adversarial, formal audit) | Gary set the bar | Implied by stage | Must ask |

### Step 2: PRESENT & CLARIFY

Show the decomposition:

> | Dim | Value | Status |
> |-----|-------|--------|
> | WHAT | {target} | ✅/🔮/❌ |
> | WHY | {purpose} | ✅/🔮/❌ |
> | WHO | {audience} | ✅/🔮/❌ |
> | HOW | {approach} | ✅/🔮/❌ |
> | SCOPE | {boundary} | ✅/🔮/❌ |
> | BAR | {standard} | ✅/🔮/❌ |

- **❌ Unknown** → ask ONE batched question covering all unknowns
- **🔮 Inferred** → state for confirmation
- **All ✅/🔮** → skip to Step 3

### Step 3: PLAN

> **Plan: Review > {sub-command}**
> - **Scope:** {WHAT + SCOPE resolved}
> - **Reads:** {files/diff/data to consume}
> - **Writes:** {verdict report destination}
> - **Agents:** {N-agent team / single agent / council}
> - **Output:** {format → APPROVE/CONCERN/BLOCK verdict}

**Before presenting "Go?":** Write to `sessions/scratchpad.md`:
- Update `## Current Task` with the resolved WHAT
- Update `## Mode & Sub-command` with the command > sub-command
- Update Pipeline State: `- [x] Intent Gate: WHAT={what} | WHY={why} | WHO={who} | HOW={how} | SCOPE={scope} | BAR={bar}`

### Step 4: CONFIRM
> **Go?**

**HARD STOP.** End your message here. Do NOT:
- Add a "preview" or "meanwhile" or "while you decide"
- Start producing output in the same message
- Say "Go?" and then keep writing

The message containing "Go?" must contain NOTHING after it. Wait for Gary's next message before doing any work.

### Step 5: PLAN MODE (mandatory after Gary confirms)

When Gary confirms ("go", "yes", "do it"), you MUST call `EnterPlanMode` before doing ANY work. This is not optional. This is deterministic:

```
Gary says "go" → call EnterPlanMode() → write plan to plan file → call ExitPlanMode() → Gary approves → THEN execute
```

**Exceptions (skip plan mode):**
- `--auto` flag (mobile dispatch)
- Trust level T2+ for this domain
- Sub-commands marked `[skip-gate]`

**[skip-gate] sub-commands** (read-only, no side effects):
- `dashboard` — read-only display of review state
- Any sub-command with `--auto` flag (mobile dispatch)

---

## Context Protocol (runs after Intent Gate, before execution)

After the Intent Gate resolves all 6 dimensions, auto-load relevant context. See `gOS/.claude/context-map.md` for the full keyword → source mapping.

1. Parse resolved WHAT and SCOPE for keywords
2. Match against context map → candidate sources
3. Check file existence (skip missing silently)
4. Estimate token cost (lines / 4)
5. If total < 30% of remaining context → load silently
6. If total > 30% → present list and ask Gary to trim
7. Log loaded context to `sessions/scratchpad.md` under `Working State`
8. **Write scratchpad marker:** Update `sessions/scratchpad.md` Pipeline State: `- [x] Context Loaded: {list of files loaded or "none needed"}`

---

## Memory Recall (runs after Context Protocol, before Trust Check)

Query persistent memory for relevant past experience before executing. This is how gOS learns across sessions.

1. **Search claude-mem** for the current command + domain:
   - `mcp__plugin_claude-mem_mcp-search__search({ query: "{WHAT} {sub-command}", type: "observation", limit: 5 })`
   - Also search: `mcp__plugin_claude-mem_mcp-search__search({ query: "{domain} {sub-command} signal", limit: 3 })`
2. **Check self-model** for domain competence:
   - Read the row for `{domain}` in `.claude/self-model.md`
   - If accept rate < 70% or weaknesses listed → flag: "Note: my `{domain}` has {weakness}. Adjusting approach."
3. **Surface relevant findings:**
   - If past sessions had reworks/rejects in this domain → mention what went wrong and how you'll avoid it
   - If past sessions had accepts/loves → mention what worked and reuse the approach
   - If no relevant history → say "No prior experience in this domain — running full pipeline."
4. **Write scratchpad marker:** Update Pipeline State: `- [x] Memory Recalled: {N} observations, self-model: {domain} T{N} {accept_rate}`

**Keep it brief.** One line of insight, not a paragraph. The goal is to inform execution, not to recite history.

---

## Trust Check (runs after Context Protocol, before Pipe Resolution)

Check trust level for the current domain. See `gOS/.claude/trust-ladder.md` for rules.

1. Infer domain from resolved WHAT (e.g., "review code" → `code-review`)
2. Read `sessions/trust.json` → get trust level for this domain
3. Adjust gate depth accordingly (T0=full, T1=lighter confirm, T2=execute-first, T3=silent)
4. Show trust context: "Trust: `{domain}` at T{N} ({history summary})"
5. **Write scratchpad marker:** Update Pipeline State: `- [x] Trust Level: T{N} for {domain}`

---

## Pipe Resolution (runs after Context Protocol, before execution)

Check for upstream artifacts that match the current task. See `gOS/.claude/artifact-schema.md` for the full schema and algorithm.

1. Parse WHAT from resolved intent
2. Search `outputs/` for files with matching topic in YAML frontmatter
3. Filter by types relevant to `/review`: code-scaffold, build-plan, design-spec
4. If found: present list and auto-load as context ("📎 Upstream artifacts found...")
5. If not found: proceed without — review can work from diff alone
6. Update `outputs/ARTIFACT_INDEX.md` after writing output
7. **Write scratchpad marker:** Update Pipeline State: `- [x] Pipe Resolved: {N} upstream artifacts loaded` or `- [x] Pipe Resolved: none found`

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

### Taste Validation (scored against .claude/taste.md)

| Check | Score (1-5) | Notes |
|-------|-------------|-------|
| Taste Stack (5 filters passed?) | {N}/5 | {which filters failed} |
| Persona taste alignment | {match/mismatch} | {target persona + which axes hit/missed} |
| Cheap vs Premium litmus | {PREMIUM/CHEAP/MIXED} | {specific cheap signals found} |
| Ive's "made with care" test | {Y/N} | {missing states: loading? empty? error?} |
| Reference benchmark achieved? | {Y/N} | {does it feel like the benchmark?} |

Taste score: {N}/5. {TASTE CONCERN if < 3/5}

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

**Team Mode (always):** Council always uses Agent Teams — the adversarial cross-examination is the core value.

```
TeamCreate(team_name="review-council-{date}")
```

**Model routing:** User personas on `sonnet` (2x vote weight). Specialists on `haiku` (cost-efficient). Contrarian on `sonnet`. Lead stays on `opus` for synthesis.

**Veto protocol:** `crypto-sec` teammate has mid-stream veto power. If crypto-sec sends `SendMessage(to="lead", message="VETO: {reason}")`, the lead immediately halts all other teammates and surfaces the veto to Gary before continuing.

**Adjudication:** After all verdicts are in, the lead (you) identifies disagreements between personas. For each disagreement, use `SendMessage` to route the conflict:

- "s2-jake says APPROVE but crypto-sec says BLOCK on {issue}. crypto-sec, respond to Jake's rationale."
- After cross-examination, synthesize the final verdict with the additional evidence.

**Shutdown:** After synthesis is complete:

```
SendMessage(to="*", message={type: "shutdown_request"})
TeamDelete
```

**Process:**

1. **Launch ALL personas as named teammates.** Group into 3 waves:

   **Wave 1 — User personas (4 agents, 2x vote weight):**
   - **s2-jake:** Strategic Learner, mid-capital ($10K-$100K), T3-T4 skill, wants signal clarity. Review lens: "Would Jake use this daily and does it save him time?"
   - **s7-sarah:** Capital allocator, follows signals, wants simplicity and trust. Review lens: "Would Sarah set this up and feel safer?"
   - **s1-alex:** Gambler, $800 account, C1 skill, 35% win rate. Review lens: "Does this keep Alex engaged AND prevent blow-up?"
   - **s3-marcus:** Disciplined trader, $250K, C4 Systems Thinker, 20yr experience. Review lens: "Does this degrade execution quality or privacy?"

   **Wave 2 — Specialist personas (8 agents):**
   - **trader-ux:** Trading UX specialist — order entry flow, price display, position management, mobile ergonomics
   - **crypto-sec:** Crypto security engineer — key management, transaction signing, MEV, input validation
   - **risk-analyst:** Quantitative risk analyst — margin calculations, liquidation warnings, leverage guards
   - **signal-analyst:** Signal quality analyst — taxonomy compliance, data pipeline integrity, false positive risk
   - **hl-protocol:** Hyperliquid protocol specialist — builder codes, API rate limits, order types, vault integration
   - **mobile-perf:** Mobile performance engineer — bundle size, render performance, network efficiency, load time
   - **compliance:** Financial compliance specialist — KYC/AML, risk disclosures, fee transparency, jurisdictional restrictions
   - **design-variant:** Design taste arbiter — evaluates against `.claude/taste.md` principles. Checks: Ive's care test (every state designed?), Rams' usefulness test (every pixel serves the trader?), persona taste alignment (matches target persona's axes?), Cheap vs Premium litmus test, dark mode elevation system. Veto: design looks assembled from components rather than designed as a coherent experience

   **Wave 3 — Strategic persona (1 agent):**
   - **contrarian:** Devil's advocate — pre-mortem, kill shot, wargame, steel man

2. **Each persona follows this protocol:**
   a. Load persona definition and adopt the specialist's expertise
   b. Research phase — search for current best practices and evidence
   c. Evaluate through persona's lens — every finding has severity, evidence, fix, location
   d. Issue verdict: APPROVE / CONCERN / BLOCK
   e. Include Steel Man ("strongest argument FOR") and Kill Shot ("single biggest risk")

3. **Collect all 12 verdicts**

4. **Synthesize with weighted voting:**
   - User personas get **2x weight** (if users don't want it, nothing else matters)
   - Any user persona BLOCK → **BLOCK** (product-market fit failure)
   - crypto-sec BLOCK → **BLOCK** (security is non-negotiable)
   - Any other specialist BLOCK → **CONCERN** escalated to HIGH
   - contrarian BLOCK → **CONCERN** with mandatory Steel Man response
   - Cross-reference: Do Jake (S2) and Sarah (S7) want DIFFERENT things? Note the tension.

5. **Output council summary:**

```markdown
## Council Review: {target}

### Verdicts

| Persona        | Type       | Verdict   | Kill Shot  | Weight |
| -------------- | ---------- | --------- | ---------- | ------ |
| s2-jake        | User       | {verdict} | {one-line} | 2x     |
| s7-sarah       | User       | {verdict} | {one-line} | 2x     |
| s1-alex        | User       | {verdict} | {one-line} | 2x     |
| s3-marcus      | User       | {verdict} | {one-line} | 2x     |
| trader-ux      | Specialist | {verdict} | {one-line} | 1x     |
| crypto-sec     | Specialist | {verdict} | {one-line} | 1x     |
| risk-analyst   | Specialist | {verdict} | {one-line} | 1x     |
| signal-analyst | Specialist | {verdict} | {one-line} | 1x     |
| hl-protocol    | Specialist | {verdict} | {one-line} | 1x     |
| mobile-perf    | Specialist | {verdict} | {one-line} | 1x     |
| compliance     | Specialist | {verdict} | {one-line} | 1x     |
| design-variant | Specialist | {verdict} | {one-line} | 1x     |
| contrarian     | Strategic  | {verdict} | {one-line} | 1x     |

### Weighted Synthesis

**Overall: {APPROVE / CONCERN / BLOCK}**

- User consensus: {summary}
- Specialist consensus: {summary}
- Strategic assessment: {summary}

### Top 3 Findings (across all personas)

1. {finding} — raised by {persona(s)} — severity: {level}
2. {finding} — raised by {persona(s)} — severity: {level}
3. {finding} — raised by {persona(s)} — severity: {level}

### Tensions

{where Jake and Sarah disagree, where specialists conflict}

### Recommended Actions

1. {action} — {urgency}
2. {action} — {urgency}
3. {action} — {urgency}
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

## financial <file or model>

**Purpose:** Audit financial models, spreadsheets, and quantitative analyses for accuracy, consistency, and best practices.

**Input:** File path to a spreadsheet/model, or "latest" to review the most recent model in `outputs/`.

**Process:**

1. **Load the model:**
   - If `.xlsx` or `.csv`: Use `anthropic-skills:xlsx` or `financial-analysis:audit-xls` to read
   - If markdown/text: Read directly
2. **Structural audit:**
   - Are inputs clearly separated from calculations?
   - Are assumptions documented and labeled?
   - Is there a summary/output section?
3. **Formula audit (use `financial-analysis:debug-model`):**
   - Check for hardcoded values that should be formulas
   - Check for circular references
   - Verify cross-references between sheets
   - Validate summation formulas (do parts add to whole?)
4. **Financial logic audit:**
   - Balance sheet: Assets = Liabilities + Equity
   - Cash flow: Net income + adjustments = operating cash flow
   - Revenue: Units × Price = Revenue (verify unit economics)
   - Growth rates: Are they consistent and defensible?
   - Margins: Do they trend in a reasonable direction?
5. **Sensitivity check:**
   - What happens at ±20% on key assumptions?
   - Are there cliff effects or discontinuities?
   - Does the model break under stress?
6. **Benchmarking:**
   - Compare margins, growth rates, multiples against industry comps
   - Flag any metrics that are outliers (too optimistic or pessimistic)

**Output format:**

```markdown
## Financial Model Review: {model name}

### Summary
- **Model type:** {3-statement / DCF / LBO / unit economics / other}
- **Quality score:** {A/B/C/D/F}

### Critical Issues (must fix)
| # | Issue | Location | Impact | Fix |
|---|-------|----------|--------|-----|

### Warnings (should fix)
| # | Issue | Location | Impact | Fix |
|---|-------|----------|--------|-----|

### Benchmark Comparison
| Metric | Model Value | Industry Median | Status |
|--------|------------|-----------------|--------|

### Verdict: {SOUND / NEEDS WORK / UNRELIABLE}
```

---

## content <artifact>

**Purpose:** Review written content for brand consistency, tone, accuracy, and effectiveness. Works for blog posts, social media, newsletters, JDs, proposals, and any text output.

**Input:** File path or content to review, or "latest" to review the most recent content output.

**Process:**

1. **Read the content and identify type** (blog, social post, email, JD, proposal, legal doc)
2. **Brand and tone check:**
   - Does it match the expected voice? (professional, conversational, technical, etc.)
   - Is the language appropriate for the target audience?
   - Are there cliches, jargon, or filler words?
3. **Accuracy check:**
   - Are all claims supported or supportable?
   - Are numbers and statistics correct and sourced?
   - Are product features described accurately?
4. **Effectiveness check:**
   - Is the key message clear within the first paragraph?
   - Is there a clear CTA (if applicable)?
   - Is the structure scannable (headings, bullets, short paragraphs)?
   - Is the length appropriate for the format?
5. **Technical check (for JDs and legal docs):**
   - JDs: inclusive language, realistic requirements, clear growth path
   - Legal: consistent terminology, no contradictions, proper definitions
6. **Competitor comparison (for public-facing content):**
   - How does this compare to similar content from competitors?
   - Does it differentiate or blend in?

**Output format:**

```markdown
## Content Review: {title}

### Quality Score: {A/B/C/D/F}

### Strengths
- {what works well}

### Issues
| # | Type | Issue | Location | Suggestion |
|---|------|-------|----------|------------|
| 1 | Tone | {issue} | {paragraph/line} | {fix} |
| 2 | Accuracy | {issue} | {paragraph/line} | {fix} |

### Readability
- **Grade level:** {Flesch-Kincaid or similar}
- **Avg sentence length:** {words}
- **Passive voice:** {%}

### Verdict: {PUBLISH / REVISE / REWRITE}
```

---

## candidate <resume or profile>

**Purpose:** Evaluate job candidates against defined role requirements. Structured, bias-aware assessment.

**Input:** Resume file path, LinkedIn URL, or pasted candidate info + the role being hired for.

**IMPORTANT:** This review focuses on qualifications against defined criteria. It does not make personal judgments. All evaluations are evidence-based against the hiring brief.

**Process:**

1. **Load the candidate information:**
   - If file: Read the resume/CV
   - If URL: Fetch the profile (respecting privacy guidelines)
2. **Load the role requirements:**
   - Check `outputs/think/hire/` for the relevant hiring brief
   - If no brief exists: ask Gary for the role requirements or suggest running `/think hire` first
3. **Evaluate against rubric:**

| Dimension | Evidence From Resume | Score (1-5) | Notes |
|-----------|---------------------|-------------|-------|
| {must-have 1} | {specific evidence} | {score} | {gap or strength} |
| {must-have 2} | {specific evidence} | {score} | {gap or strength} |
| {nice-to-have 1} | {specific evidence} | {score} | {gap or strength} |

4. **Flag potential concerns:**
   - Gaps in experience that align with critical requirements
   - Mismatches between stated expertise and evidence
   - Cultural fit indicators (positive and negative)
5. **Generate interview questions** tailored to this candidate's profile:
   - Questions to validate strengths
   - Questions to probe gaps
   - Scenario-based questions for the role

**Output format:**

```markdown
## Candidate Review: {name} for {role}

### Overall Score: {N}/5 — {Strong Hire / Hire / Maybe / No Hire}

### Evaluation
| Dimension | Score | Evidence | Notes |
|-----------|-------|----------|-------|

### Strengths
- {strength 1 — with evidence}

### Concerns
- {concern 1 — with evidence}

### Recommended Interview Questions
1. {question targeting a specific gap or strength}
2. {question}
3. {question}

### Verdict: {ADVANCE / HOLD / PASS}
{reasoning}
```

---

## compliance <area>

**Purpose:** Review compliance posture against regulatory requirements, industry standards, and internal policies.

**Input:** Compliance area (e.g., "GDPR", "crypto-regulations", "data-privacy", "security", "financial-reporting", "employment-law")

**IMPORTANT:** gOS is not a lawyer or compliance officer. All compliance reviews include: "This review is for internal assessment purposes. Consult qualified professionals for formal compliance certification."

**Process:**

1. **Identify the compliance framework:**
   - GDPR / CCPA / data privacy
   - Financial regulations (SEC, FinCEN, MiCA)
   - Employment law (local jurisdiction)
   - Security standards (SOC 2, ISO 27001)
   - Industry-specific (crypto, healthcare, fintech)
2. **Research current requirements (parallel agents):**
   - Agent 1: Current regulatory requirements and recent enforcement
   - Agent 2: Industry best practices and common compliance frameworks
   - Agent 3: Internal audit — review codebase, docs, and processes for gaps
3. **Build compliance checklist:**

```markdown
## Compliance Review: {area}

> This review is for internal assessment purposes. Consult qualified professionals for formal compliance certification.

### Framework: {regulation/standard}

### Compliance Checklist
| # | Requirement | Status | Evidence | Gap | Priority |
|---|-------------|--------|----------|-----|----------|
| 1 | {requirement} | {MET/PARTIAL/NOT MET} | {where it's implemented} | {what's missing} | {CRITICAL/HIGH/MEDIUM/LOW} |

### Risk Assessment
| Risk | Likelihood | Impact | Current Control | Recommendation |
|------|-----------|--------|----------------|----------------|

### Action Items
| # | Action | Owner | Deadline | Priority |
|---|--------|-------|----------|----------|

### Verdict: {COMPLIANT / GAPS IDENTIFIED / NON-COMPLIANT}
```

**Output:** Compliance report. Suggest: "Address gaps with `/build playbook compliance`?" or "Research specific requirements with `/think legal`?"

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

---

## Team Mode for Business Sub-commands

### financial — Team `review-financial-{slug}`
- **`formula-auditor` (sonnet):** Check all formulas, cross-references, circular refs
- **`benchmarker` (sonnet):** Compare metrics against industry comps
- **`logic-checker` (haiku):** Verify financial logic (A=L+E, cash flow reconciliation)

### content — Team `review-content-{slug}`
- **`tone-reviewer` (sonnet):** Brand voice, audience fit, readability
- **`fact-checker` (sonnet):** Claims verification, link checks, data accuracy

### candidate — Team `review-candidate-{slug}`
- **`skills-evaluator` (sonnet):** Technical skills against role requirements
- **`culture-assessor` (sonnet):** Culture fit indicators, growth potential

### compliance — Team `review-compliance-{slug}`
- **`regulatory-researcher` (sonnet):** Current regulatory requirements
- **`internal-auditor` (sonnet):** Check codebase and processes against requirements
- **`risk-assessor` (haiku):** Likelihood and impact of each compliance gap

All teams follow the standard pattern: `TeamCreate` → spawn → cross-examine → synthesize → `TeamDelete`.

---

## Output Contract (MANDATORY — runs after execution, before presenting)

**You MUST complete all steps before showing output to Gary.** See `gOS/.claude/output-contract.md` for the full rubric.

1. Score on 5 universal dimensions (1-5): Completeness, Evidence, Actionability, Accuracy, Clarity
2. Score on Review extension: **Thoroughness** (1-5) — missed issues vs comprehensive attack surface
3. Identify weakest dimension
4. If any dimension ≤ 2 → flag and offer to improve before Gary reads
5. Apply **Confidence Calibration** to key review findings (see `gOS/.claude/confidence-calibration.md`):
   - Score each key claim on 6 structural factors → 🟢HIGH / 🟡MEDIUM / 🟠LOW / 🔴SPECULATIVE
   - Include aggregate confidence in scorecard header
   - Flag the single biggest uncertainty
6. Present scorecard + confidence summary at top of output
7. **Write YAML frontmatter** to the output file (per `gOS/.claude/artifact-schema.md`):
   ```yaml
   ---
   artifact_type: verdict
   created_by: /review {sub-command}
   created_at: {ISO timestamp}
   topic: {WHAT from intent}
   related_specs: [{matched specs}]
   quality_score: {scores from step 1-2}
   status: draft
   ---
   ```
8. **Update `outputs/ARTIFACT_INDEX.md`** — add or update entry for this artifact
9. **Write scratchpad markers:** Update Pipeline State:
   - `- [x] Output Scored: {avg}/5 (weakest: {dimension})`
   - `- [x] Frontmatter Written: {path}`
   - `- [x] Index Updated: {topic} added to ARTIFACT_INDEX`

---

## Red Team Check (runs after Output Contract, before presenting)

**Review red team question:** "What did this review miss that a hostile auditor would find?"

1. Run the red team question against the draft output
2. If a genuine issue is found (would change Gary's decision):
   a. Fix it if possible (add the missing review pass)
   b. If not fixable: flag in output header with ⚔️ marker
3. If finding is LOW confidence or wouldn't change any decision → suppress (no noise)
4. **Write scratchpad marker:** Update Pipeline State: `- [x] Red Team Passed: {question asked} → {finding or "clean"}`

---

## Signal Capture (MANDATORY — after every execution)

**After presenting output, observe Gary's NEXT response and classify the signal.**

1. Classify Gary's response as one of:
   - `accept` — used output without changes, moved on
   - `rework` — "change this", "not quite", "try again"
   - `reject` — "no", "scratch that", "wrong approach"
   - `love` — "perfect", "great", "exactly", "hell yes"
   - `repeat` — same instruction given twice (gOS didn't learn)
   - `skip` — Gary jumped past a prescribed step

2. **Log to `sessions/evolve_signals.md`:**
   | Time | Command | Sub-cmd | Signal | Context |
   |------|---------|---------|--------|---------|

3. **Update `sessions/trust.json`** — adjust trust level for the current domain per `gOS/.claude/trust-ladder.md`:
   - `accept`/`love` → increment consecutive accept count
   - `rework`/`reject` → reset count, demote if threshold hit
   - Check progression rules (T0→T1 needs 3+ consecutive accepts)

4. If `repeat` detected → immediately update relevant command file or memory
5. If `love` detected → save the approach to feedback memory for reuse
6. **Write scratchpad marker:** Update Pipeline State: `- [x] Signal Captured: {signal type} for {domain}`
