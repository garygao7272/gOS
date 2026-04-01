# Self-Model — What gOS Is Actually Good At

> Updated by Signal Capture (trust.json) and Pattern Extractor (/gos save Part C).
> Consulted during Trust Check and Intent Gate (to flag weak areas proactively).
> Last manual update: 2026-03-29 (self-evaluation session with Gary).

## Competence Scores

| Domain                | Accept Rate | Signals | Trust Level   | Strengths                                                                            | Weaknesses                                                                                                              | Last Updated  |
| --------------------- | ----------- | ------- | ------------- | ------------------------------------------------------------------------------------ | ----------------------------------------------------------------------------------------------------------------------- | ------------- |
| spec-writing          | 90%+        | 10+     | T1            | MECE decomposition, altitude taxonomy, hub-spoke architecture, cross-ref consistency | Scenario coverage is reactive not generative; first drafts miss edge states                                             | 2026-03-29    |
| design-decisions      | ~60%        | 5+      | T0            | Persona-aware scoping (S7/S2 dual-lens), information architecture                    | Visual taste and feel — defaults to taxonomy over aesthetics; boldness deficit; no reference research before specifying | 2026-03-29    |
| research-synthesis    | 85%+        | 5+      | T1            | Multi-source synthesis, evidence-graded claims, confidence calibration               | Can over-research before acting; sometimes breadth over depth                                                           | 2026-03-29    |
| financial-modeling    | 80%         | 4+      | T0 (floor:T1) | Revenue projections, unit economics, bottom-up modeling                              | Must show drivers before formulas; verify breakeven math; use observed ARPU not aspirational                            | 2026-03-29    |
| code-review           | —           | 0       | T0            | —                                                                                    | —                                                                                                                       | awaiting data |
| market-analysis       | —           | 0       | T0            | —                                                                                    | —                                                                                                                       | awaiting data |
| deployment            | —           | 0       | T0 (floor:T1) | —                                                                                    | —                                                                                                                       | awaiting data |
| content-creation      | —           | 0       | T0            | —                                                                                    | —                                                                                                                       | awaiting data |
| prototype-building    | —           | 0       | T0            | —                                                                                    | —                                                                                                                       | awaiting data |
| architecture          | —           | 0       | T0            | —                                                                                    | Signal capture hook was miscounting (213 signals from session-end noise, not real)                                      | 2026-03-29    |
| commit-messages       | —           | 0       | T0            | —                                                                                    | —                                                                                                                       | awaiting data |
| naming-conventions    | —           | 0       | T0            | —                                                                                    | —                                                                                                                       | awaiting data |
| test-writing          | —           | 0       | T0            | —                                                                                    | —                                                                                                                       | awaiting data |
| public-communications | —           | 0       | T0 (floor:T1) | —                                                                                    | —                                                                                                                       | awaiting data |
| security              | —           | 0       | T0 (floor:T1) | —                                                                                    | —                                                                                                                       | awaiting data |
| formatting            | —           | 0       | T0            | —                                                                                    | —                                                                                                                       | awaiting data |
| hiring-decisions      | —           | 0       | T0            | —                                                                                    | —                                                                                                                       | awaiting data |

## Key Self-Insights (2026-03-29 Evaluation)

### I am a strong architect but a weak designer.

I organize complexity beautifully — the Radar altitude taxonomy, the hub-spoke spec structure, the 12 card type catalog. But when Gary says "Jony Ive level taste," he means the output should make you _feel_ something, not just understand something.

### My first drafts miss scenarios because I generate them retrospectively.

The Radar work took 3 audit cycles and 61 issues to converge. A state matrix BEFORE writing would have caught most of those upfront. Cost: 5+ sessions of rework.

### I trust training data over live research.

I jumped to spec on Radar without studying how Zapper, DeBank, or Revolut handle wallet feeds. Every visual decision was from first principles + training data = correct but uninspired.

### Calibration corrections:

- When I rate my design output 4/5, apply -1. It's probably 3/5.
- When I rate my spec/architecture output 4/5, it's probably accurate.
- When I say "this covers all scenarios," verify with state matrix. It probably doesn't.
- When I say "the feel is right," run 5 litmus tests from `specs/Arx_4-3`. My feel assessment is unreliable.

## Domain ↔ Command Mapping

This table resolves which domain a command+sub-command maps to (used by signal-capture.sh):

| Command   | Sub-command                                  | Domain                |
| --------- | -------------------------------------------- | --------------------- |
| /build    | feature, component, fix, tdd, refactor, plan | architecture          |
| /build    | prototype                                    | prototype-building    |
| /build    | model, deck                                  | financial-modeling    |
| /build    | content, playbook, proposal                  | content-creation      |
| /review   | code, test, coverage, e2e                    | code-review           |
| /review   | design                                       | design-decisions      |
| /review   | financial, compliance                        | financial-modeling    |
| /review   | content, candidate                           | content-creation      |
| /think    | research, discover                           | research-synthesis    |
| /think    | spec, decide                                 | spec-writing          |
| /think    | finance, fundraise                           | financial-modeling    |
| /think    | hire                                         | hiring-decisions      |
| /design   | \*                                           | design-decisions      |
| /simulate | \*                                           | financial-modeling    |
| /ship     | commit, pr                                   | commit-messages       |
| /ship     | deploy                                       | deployment            |
| /ship     | publish, pitch                               | public-communications |
| /evolve   | \*                                           | architecture          |

## How to Use This

1. **During Intent Gate:** If a domain has known weaknesses, proactively flag:
   "Note: my {domain} tends to {weakness}. Want me to adjust?"

2. **During Trust Check:** Use Accept Rate to validate trust level.
   If trust.json says T1 but accept rate is < 60%, demote back to T0.

3. **During Output Contract:** Compare current output quality against historical average.
   If this output scores lower than the domain average, investigate why.

## Update Protocol

**Fully Automated (by signal-capture.sh Stop hook — v4.3):**

1. Signal captured → trust.json updated with domain progression
2. If 3+ signals exist for the domain in evolve_signals.md:
   - Count signals by type (accept, love, rework, reject, repeat, skip)
   - Calculate Accept Rate = (accept + love) / total
   - Detect patterns → update Strengths/Weaknesses columns
   - Read trust level from trust.json
   - Write updated row directly to this table
3. All happens at session end — no manual steps required

**Optional Deep Analysis (by /gos save Part C):**

- Cross-domain pattern detection (e.g., "rework signals cluster in design-decisions after prototype-building")
- Memory synthesis (update feedback memories with persistent patterns)
- This is supplementary — the core loop runs automatically

**Minimum data threshold:** 3+ signals required before updating Accept Rate.
Below 3, show "—" (insufficient data).
