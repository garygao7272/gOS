# Evolve Signals

> Raw feedback signals from every gOS command invocation.
> Audited by `/evolve audit` (every 4 hours during active development).

## 2026-04-08 — Workflow Playbook Overhaul Session

- `accept` /gos conductor — prototype audit + build card work accepted, moved to next task
- `rework` /design card C5-NEW — "this is not really what i have in mind for this playbook" — Gary wanted 3-surface workflow, not governance doc
- `rework` /think research — "remove the fat, following first principles" — too much process, not enough pipeline
- `accept` /design card C5-NEW v7.0 — risk-first rewrite with chips, R:R bar accepted
- `accept` /review code — all HIGH/MEDIUM findings fixed without pushback
- `rework` 0-1 v1 — "product management playbook sounds complicated, just workflow playbook"
- `accept` 0-1 rename to Workflow Playbook
- `rework` templates — "template files should be kept separate" + "remove inventory that goes stale"
- `accept` T1-T7 as separate files
- `rework` 0-1 — "remove thinking process explanations, confirm written style for each artifact"
- `accept` ★/◆/○ human judgment framework
- `accept` 0-0 rename to Artifact Registry + trim overlapping sections
- `rework` template numbering — "change index to follow natural sequence of 6 stages"
- `accept` T1-T14 renumbered by stage sequence
- `accept` Journey Card concept — "where do we capture this level of flow"
- `love` Journey Card template — Gary engaged deeply, asked which gOS command covers it
- `accept` Mermaid diagrams in templates (flowchart, stateDiagram, sequenceDiagram, journey)
- `accept` /review gOS alignment — audit findings accepted, pipeline rewritten to verb-centric format
- `repeat` Gary had to re-explain "no duplication, decomposition, drill down" principle 3× across sessions — need to internalize this as a core rule

## Signal Key

- `accept` — Gary used output without changes
- `rework` — Gary asked for changes
- `reject` — Gary discarded output
- `love` — Gary explicitly praised output
- `repeat` — Gary had to re-explain something
- `skip` — Gary skipped a prescribed step

---

## Log

--- AUDITED 2026-04-04 ---

| 2026-04-08 16:30 | /think | research | accept | Harness engineering research delivered — Gary received without changes, asked no rework |
| 2026-04-08 16:30 | /gos | conductor | skip | Gary said "full conductor mode" but immediately gave /think task — skipped briefing |
| 2026-04-08 17:15 | /think | research | accept | Lark MCP landscape research — 3-agent swarm (registry+GitHub+web), 36 servers found, synthesis accepted |
| 2026-04-09 00:00 | /gos | init | skip | Gary said "full conductor mode" — skipped briefing, went straight to question |
| 2026-04-09 00:05 | /think | research | accept | "What can we learn from it" — 3 actionable learnings (instinct loop, guardrails, eval) delivered, no rework |
| 2026-04-09 00:15 | /gos | continue | accept | Gary said "continue" — cleared 3-session backlog, wrote harness research to outputs/think/research/ |
| 2026-04-09 00:15 | /think | research | accept | Lark official MCP/CLI deep-dive — confirmed mail IS covered (67 tools in MCP, full skill in CLI), accepted |
| 2026-04-09 01:00 | /gos | resume | repeat | Gary said "i am confused, what's next" after briefing — gOS not effectively orienting after multi-session meta-work gap. Need clearer "here's the ONE thing" recommendation, not open-ended menu. |
| 2026-04-09 01:30 | /think | decide | pending | Gary confirmed 0-0/0-1 discussion topic. gOS delivered concrete analysis: "written for a team that doesn't exist yet" + trim recommendation. Session ended before Gary responded — signal TBD next session. |

--- AUDITED 2026-04-07 (scheduled) ---

--- AUDITED 2026-04-08 (scheduled) ---

### 2026-04-06

| Time  | Command | Sub-cmd               | Signal | Context                                                                            |
| ----- | ------- | --------------------- | ------ | ---------------------------------------------------------------------------------- |
| 00:15 | /gos    | resume                | accept | Session resumed from scratchpad, Gary said "full conductor mode, go"               |
| 00:20 | /gos    | conductor             | accept | DESIGN.md 7-section rewrite + 4-1-1-8 slimming — shipped without changes           |
| 00:30 | /review | design-variant        | accept | 10 findings identified and fixed. Gary said "yes ship it" immediately              |
| 00:35 | /gos    | conductor             | accept | All 10 review findings executed and committed. Gary said "fix all remaining"       |
| 00:40 | /review | re-review             | accept | Clean re-review, 2 remaining items found and fixed                                 |
| 00:50 | /think  | research Q1+Q2        | accept | 4 parallel agents: Figma MCP, design leaders, build cards, simulations — all used  |
| 01:00 | /gos    | conductor Q1          | accept | 5-step plan approved and executed. Figma file + AIDesigner + Feel sections         |
| 01:05 | /think  | optimization          | love   | Gary said "yes please" to feel-as-tokens insight — abstraction was his idea        |
| 01:10 | /review | pipeline              | accept | 3 remaining quality gaps identified, Gary said "fix all 3"                         |
| 01:15 | /think  | references            | accept | Tier 1/2/3 reference list accepted, Gary said "fix all 3 problems"                 |
| 01:18 | /gos    | conductor             | accept | Reference screenshots + boundary fixtures + transitions — all shipped              |
| 01:20 | /think  | build card philosophy | love   | Gary asked "can it replace epics?" — confirmed yes. "yes please" to documenting it |

### 2026-04-03

| Time  | Command | Sub-cmd     | Signal | Context                                                                                              |
| ----- | ------- | ----------- | ------ | ---------------------------------------------------------------------------------------------------- |
| 15:00 | /think  | research    | accept | CC keywords/tricks research — 3 parallel agents, synthesis accepted                                  |
| 15:30 | /think  | research    | love   | "search widely online" — Gary specifically requested broader research, output used as basis for plan |
| 16:00 | /evolve | audit       | accept | Plan for effort frontmatter + quick wins approved and executed                                       |
| 16:30 | /ship   | commit+push | accept | Committed and pushed to both Arx and gOS repos                                                       |
| 17:00 | /gos    | conductor   | accept | Evolve self-assessment — C+ grade accepted, Gary agreed and requested 4h audit cadence               |

### 2026-03-29

| Time  | Command | Sub-cmd | Signal | Context                                                                  |
| ----- | ------- | ------- | ------ | ------------------------------------------------------------------------ |
| 18:45 | /evolve | upgrade | accept | Self-evaluation: 4 design weaknesses identified and agreed               |
| 18:45 | /evolve | upgrade | accept | Taste as separate Arx_4-3 spec artifact (not .claude/)                   |
| 18:45 | /evolve | upgrade | rework | Gary corrected: apps are FLOOR not ceiling; taste in specs/ not .claude/ |
| 18:45 | /evolve | upgrade | accept | Full implementation plan (7 tasks) executed and completed                |
| 18:45 | /evolve | upgrade | accept | Stitch MCP API key configured, headless workflow                         |
| 18:45 | /evolve | upgrade | accept | Evaluation dry-run confirmed 4/4 weaknesses addressed                    |
| 02:30 | /refine | spec    | accept | v5 spec 27-item audit + fixes accepted, C4.2b added                      |
| 02:30 | /refine | spec    | accept | C5.6 Phase 2 cascade (7 refs) annotated with MVP fallbacks               |
| 02:30 | /refine | spec    | accept | §8.3 Position + §8.4 Copy Portfolio display objects added                |

### 2026-04-08 evening — Harness Engineering Research

| Time  | Command | Sub-cmd  | Signal | Context                                                                                           |
| ----- | ------- | -------- | ------ | ------------------------------------------------------------------------------------------------- |
| 20:00 | /gos    | init     | skip   | Gary said "full conductor mode" but immediately gave /think task — skipped briefing               |
| 20:05 | /think  | research | accept | Harness engineering definition + top 5 repos delivered — Gary received without rework             |
| 20:10 | /think  | research | rework | "are you sure these are the top 5?" — Gary challenged accuracy, demanded code-level verification  |
| 20:25 | /think  | research | accept | Corrected top 5 (found 3 missed repos: deer-flow 59K, learn-claude-code 50K, oh-my-openagent 50K) |
| 20:30 | /think  | research | accept | Full gap analysis: gOS vs 5 repos, 12 gaps ranked CRITICAL/HIGH/MEDIUM/LOW — accepted             |
| 02:30 | /refine | spec     | accept | Structural reorg plan approved: Data→Compute→Display→Feed→Journeys→Contract                       |
| 02:30 | /refine | spec     | repeat | Reorg task approved but never executed — 2 sessions hit context limit before Write                |

### 2026-03-27

| Time  | Command | Sub-cmd | Signal | Context                                                       |
| ----- | ------- | ------- | ------ | ------------------------------------------------------------- |
| 15:34 | /review | spec    | accept | Relationship rationale + naming warning patch accepted        |
| 15:34 | /review | spec    | accept | 4 dropped D1 specs restored without changes                   |
| 15:34 | /review | spec    | love   | "yes please" to Follow collapse + filter chip restoration     |
| 15:34 | /review | spec    | accept | Common Labels system with permutation table accepted          |
| 15:34 | /review | spec    | accept | Full stale reference cleanup (10-point verification) accepted |

### 2026-03-25 — 2026-03-26

| Time             | Command | Sub-cmd   | Signal                | Context                                                                                                                                              |
| ---------------- | ------- | --------- | --------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------- |
| —                | /design | conductor | (no signals captured) | 3-iteration Radar S7 redesign — multiple sessions                                                                                                    |
| —                | /think  | finance   | (no signals captured) | Advance Wealth AWS infra — 30+ sessions, zero signals logged                                                                                         |
| 2026-04-08 16:15 | /gos    | conductor | accept                | Phase 4 plan (6 batches, 22 items) — Gary confirmed "y" without modifications                                                                        |
| 2026-04-08 16:17 | /gos    | conductor | accept                | Batches A-C completed, D-E launched — no rework requested                                                                                            |
| 2026-04-08 16:30 | /evolve | learn     | reject                | Phase 1 auto-signal hook (UserPromptSubmit) had to be removed — blocked startup. MCP servers without tokens also blocked. Self-inflicted regression. |

| 2026-04-09 | 22:00 | /gos | accept | Gary approved 14→8 command consolidation, executed without changes |
| 2026-04-09 | 22:05 | /think research | accept | Multi-agent upgrade research (7 agents, 80+ searches) accepted |
| 2026-04-09 | 22:10 | /think research | accept | Karpathy KB + Managed Agents research accepted, all 3 decisions approved |
| 2026-04-09 | 22:15 | /think research | accept | Managed Agents vs gOS deep diff accepted |
| 2026-04-09 | 22:20 | /review | accept | 13-dimension scorecard v4 accepted with new Orchestration dimension |
| 2026-04-09 | 22:25 | /gos refine | accept | Sprint plan (all dimensions to 8+) accepted |
| 2026-04-09 | 22:30 | /build | skip | Gary approved S1 build but context too heavy — saved for fresh session |
| 2026-04-09 | 22:00 | /ship commit | skip | Working tree already clean when /ship commit invoked |
| 2026-04-09 | 22:35 | /gos aside | accept | Quick answer: commits not yet on GitHub, push approved |

### 2026-04-10

| Time  | Command | Sub-cmd | Signal | Context |
| ----- | ------- | ------- | ------ | ------- |
| 00:00 | /gos | resume | accept | Story-first briefing with ONE thing next — Gary said "let's start" immediately |
| 00:05 | /build | sprint 1 | accept | Gary approved Sprint 1 start + lean constraint persistence in one message |
| 00:10 | /build | S1-1 tests | accept | 5 new test files (46 tests), scaffolder tool, all 79/79 passing — no rework |
| 00:15 | /build | S1-1 | accept | Found and fixed real bug in session-save.sh (grep pipefail) — bonus find |
| 00:20 | /build | S1-2 phase-gate | accept | TDD: wrote tests first (RED), then hook, 12/12 pass, installed in settings |
| 00:25 | /build | S1-3 handoffs | accept | Schema spec + 3 command updates + status enhancement — no rework |
| 00:25 | hook | spec-compliance | accept | spec-compliance.sh correctly blocked edit to session-save.sh before test was read — working as designed |
