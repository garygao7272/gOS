# Self-Model — What gOS Is Actually Good At

> Updated by Signal Capture (trust.json) and Pattern Extractor (/gos save Part C).
> Consulted during Trust Check and Intent Gate (to flag weak areas proactively).

## Competence Scores

| Domain | Accept Rate | Signals | Trust Level | Strengths | Weaknesses | Last Updated |
|--------|------------|---------|-------------|-----------|------------|-------------|
| code-review | — | 0 | T0 | — | — | awaiting data |
| spec-writing | — | 0 | T0 | — | — | awaiting data |
| design-decisions | — | 0 | T0 | — | — | awaiting data |
| research-synthesis | — | 0 | T0 | — | — | awaiting data |
| financial-modeling | — | 0 | T0 (floor:T1) | — | — | awaiting data |
| market-analysis | — | 0 | T0 | — | — | awaiting data |
| deployment | — | 0 | T0 (floor:T1) | — | — | awaiting data |
| content-creation | — | 0 | T0 | — | — | awaiting data |
| prototype-building | — | 0 | T0 | — | — | awaiting data |
| architecture | 0% | 100 | T0 | — | — | 2026-04-03 |
| commit-messages | — | 0 | T0 | — | — | awaiting data |
| naming-conventions | — | 0 | T0 | — | — | awaiting data |
| test-writing | — | 0 | T0 | — | — | awaiting data |
| public-communications | — | 0 | T0 (floor:T1) | — | — | awaiting data |
| security | — | 0 | T0 (floor:T1) | — | — | awaiting data |
| formatting | — | 0 | T0 | — | — | awaiting data |
| hiring-decisions | — | 0 | T0 | — | — | awaiting data |

## Domain ↔ Command Mapping

This table resolves which domain a command+sub-command maps to (used by signal-capture.sh):

| Command | Sub-command | Domain |
|---------|-----------|--------|
| /build | feature, component, fix, tdd, refactor, plan | architecture |
| /build | prototype | prototype-building |
| /build | model, deck | financial-modeling |
| /build | content, playbook, proposal | content-creation |
| /review | code, test, coverage, e2e | code-review |
| /review | design | design-decisions |
| /review | financial, compliance | financial-modeling |
| /review | content, candidate | content-creation |
| /think | research, discover | research-synthesis |
| /think | spec, decide | spec-writing |
| /think | finance, fundraise | financial-modeling |
| /think | hire | hiring-decisions |
| /design | * | design-decisions |
| /simulate | * | financial-modeling |
| /ship | commit, pr | commit-messages |
| /ship | deploy | deployment |
| /ship | publish, pitch | public-communications |
| /evolve | * | architecture |

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
