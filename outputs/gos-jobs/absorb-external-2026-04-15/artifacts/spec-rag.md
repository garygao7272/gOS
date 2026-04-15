---
job: absorb-external-2026-04-15
agent: spec-rag
date: 2026-04-15
sources:
  - https://github.com/forrestchang/andrej-karpathy-skills
  - https://github.com/NousResearch/hermes-agent
---

# Overlap Audit

## Karpathy Feature Map

| Karpathy Principle | gOS Status | gOS Source | Gap Description |
|---|---|---|---|
| Think Before Coding — state assumptions, surface tradeoffs, ask before implementing | FULL | `~/.claude/CLAUDE.md:Plan Gate`; `commands/build.md:Intent confirmation`; `invariants.md:INV-G01` | Plan Gate + intent confirmation + first-principles invariant fully cover this. Enforced on every command. |
| Simplicity First — minimum code, no speculative features, no premature abstraction | FULL | `~/.claude/CLAUDE.md:Practitioner Rules §2`; `invariants.md:INV-G13`; `rules/common/coding-style.md` | Anti-over-engineering bias check explicitly named in CLAUDE.md. INV-G13 enforces fix scope. |
| Surgical Changes — touch only what you must, don't clean up adjacent code | PARTIAL | `invariants.md:INV-G13`; `rules/common/coding-style.md` | INV-G13 restricts `/build fix` scope only. No explicit surgical-changes contract for `/build feature`. Gap: adjacent refactor creep not formally gated in feature builds. |
| Goal-Driven Execution — define verifiable success criteria, loop until met | FULL | `commands/build.md:The Build loop`; `invariants.md:INV-G06`; `specs/pev-protocol.md:CONVERGED gate` | Build loop, compliance.md artifact, and PEV convergence gate all enforce this. Health scoring closes the outer loop. |

**Karpathy summary:** 3 of 4 FULL, 1 PARTIAL (surgical changes not enforced in feature builds).

---

## Hermes Feature Map

| Hermes Feature | gOS Status | gOS Source | Gap Description |
|---|---|---|---|
| Autonomous skill creation — agent creates skills from experience post-task | MISSING | — | gOS skills are manually authored. `/evolve upgrade` proposes changes but Gary gates every write. No post-task auto-creation. |
| Self-improving skills — skills update themselves during/after use | MISSING | — | Skills are static markdown. No self-update loop. Closest: `sessions/evolve_signals.md` feed → `/evolve upgrade` — but human-gated. |
| Honcho dialectic user modeling — persistent probabilistic user model updated each session | PARTIAL | `memory/user_gary_soul.md`; `memory/self-model.md`; `~/.claude/CLAUDE.md:Signal Capture` | gOS has Gary soul doc + self-model + signal capture, but no dialectic hypothesis loop. User model is manually curated, not autonomously updated from interaction evidence. |
| Multi-platform gateway — same agent reachable via Telegram, Discord, Slack, Signal, WhatsApp | MISSING | — | gOS is Claude Code CLI only. No gateway process or messaging adapters. Out of scope by architecture (Claude Code harness). |
| FTS5 session search — SQLite full-text search across all past sessions | PARTIAL | `sessions/last-session.md`; `memory/episodes.md` | File-based session history exists but no indexed search. Cross-session recall via L2 reads + Grep only. No structured query. |
| Subagent parallelization — spawn isolated child agents with restricted toolsets, parent sees only summary | FULL | `specs/pev-protocol.md:EXECUTE step`; `agents/REGISTRY.yaml`; `commands/evolve.md:PEV §3` | PEV protocol is exactly this pattern. Parallel executor agents with contracts, each writing to `artifacts/`. Validator synthesizes. Claude Code Task-based (not Python threads) but functionally equivalent. |
| Scheduled cron automation — natural language cron jobs delivered to any platform | PARTIAL | `gOS/claws/` (market-regime, source-monitor, spec-drift); `~/.claude/skills/schedule` | 3 named claws + `schedule` skill exist, but not an always-on daemon. Output goes to files, not Telegram/Discord. Narrower scope. |
| Agentskills.io standard — open interoperability standard for skills across agents | MISSING | — | gOS skills use custom SKILL.md frontmatter. Not agentskills.io-compatible. No declared intent to be. |
| Batch trajectory generation — parallel multi-process batch runs for RL training data | MISSING | — | No equivalent. Hermes `batch_runner.py` is for training data generation. gOS has no RL pipeline. Intentionally out of scope. |
| Serverless persistence — agent environment hibernates when idle, wakes on demand (Modal/Daytona) | MISSING | — | gOS runs locally via Claude Code. No serverless deployment target. Out of scope by design. |

---

## Absorption Candidates (what's actually NEW to gOS)

Ranked by value-add and fit:

1. **Autonomous skill creation** — NEW mechanism. After `/build feature` completes, agent proposes a new or updated skill file based on patterns learned. Gary gates approval (fits INV-G04). Fills the "gOS learns from real work" gap. High value, low blast radius.

2. **Surgical Changes on `/build feature`** — PARTIAL-fill. Extend `invariants.md` or `commands/build.md` with explicit surgical-scope contract for feature builds: every changed line must trace to user request. Currently only enforced on fix (INV-G13).

3. **Dialectic user modeling loop** — PARTIAL-fill. Add lightweight hypothesis-update step to `/evolve audit`: does `memory/user_gary_soul.md` need revision based on this session's signals? Format: hypothesis → evidence → confirm/revise. No Honcho dependency needed.

4. **FTS5-style session search** — PARTIAL-fill. Add a shell script (run on `/gos save`) that indexes `sessions/` + `memory/episodes.md` into a SQLite FTS5 db. Enables `grep`-level recall → structured query. Low effort, high value for multi-month projects.

5. **Agentskills.io frontmatter compatibility** — NEW standard. Add `agentskills.io`-compatible fields to gOS SKILL.md schema. Zero-effort: gOS skills already have name/description/license. Makes skills portable and community-shareable.

---

## Already-Covered (don't re-absorb)

- **Think Before Coding** — `~/.claude/CLAUDE.md:Plan Gate` + `invariants.md:INV-G01`
- **Goal-Driven Execution** — `commands/build.md:Build loop` + `invariants.md:INV-G06`
- **Simplicity First** — `~/.claude/CLAUDE.md:Practitioner Rules` + bias check in every Plan Gate
- **Subagent parallelization** — `specs/pev-protocol.md:EXECUTE` + `agents/REGISTRY.yaml`
- **Scheduled cron (core)** — `gOS/claws/` + `skills/schedule`; extend, don't re-implement
- **Multi-platform gateway** — out of scope (Claude Code CLI architecture; intentional)
- **Batch trajectory / RL training** — out of scope (no RL training target in gOS)
- **Serverless persistence** — out of scope (local-first by design)
