# Arx — Project Instructions

## What Is Arx

Arx is a mobile-first crypto trading terminal built on Hyperliquid. It unifies smart money intelligence, trade execution, copy trading, and risk management into a single AI-augmented interface for retail traders. Spelling: "Arx" — not "ARX", not "arx".

## Specs

All product knowledge lives in `specs/`. Read the relevant spec before making product, design, or engineering decisions.

```
Start here:  specs/INDEX.md                              ← Quick lookup
Full system: specs/Arx_0-0_Artifact_Architecture.md      ← Master blueprint
Screens:     specs/Arx_4-1-0_Experience_Design_Index.md   ← Screen inventory
```

| Altitude  | Group            | Question Answered            |
| --------- | ---------------- | ---------------------------- |
| 30,000 ft | 1 — Foundation   | Why does Arx exist?          |
| 20,000 ft | 2 — Market Intel | Who do we serve, what hurts? |
| 10,000 ft | 3 — Product      | What do we build?            |
| 5,000 ft  | 4 — Design       | How does it look and feel?   |
| 1,000 ft  | 5 — Engineering  | How is it built?             |
| 0 ft      | 6 — Execution    | How do we ship?              |

Naming: `Arx_{Group}-{Artifact}_{Slug}.md` — IDs are permanent, no version numbers in filenames.
Cascade: changes flow downward only. Lower-altitude changes inform upstream but don't override.

**Agent consumption tags:** Specs should include an `<!-- AGENT: -->` HTML comment at the top with key files, dependencies, and test paths. This lets `/build feature` load only what's needed instead of the full spec tree. Format:

```html
<!-- AGENT: This spec defines [feature].
     Key files: [implementation paths]
     Dependencies: [other spec refs]
     Test: [test directory path]
-->
```

## Project Structure

```
Arx/
├── specs/              ← Canonical product specs (promoted from outputs/think/)
├── outputs/
│   ├── think/          ← /think staging area (research, discover, design, decide)
│   │   ├── research/
│   │   ├── discover/
│   │   ├── design/
│   │   └── decide/
│   └── briefings/      ← /simulate output
├── apps/
│   ├── web-prototype/  ← Single-file HTML prototype (has its own CLAUDE.md — read it first)
│   └── mobile/         ← React Native / Next.js mobile app
├── sessions/           ← Session tracking (active.md, scratchpad.md)
├── tools/              ← Custom MCP servers (hyperliquid, spec-rag, sources)
├── bootstrap/          ← System disaster recovery templates
└── Archive/            ← Superseded files (date-prefixed)
```

## Common Mistakes

- **Naming**: "Arx" not "ARX" or "arx"
- **Prices/amounts**: Use Decimal or integer base units (wei), not floating point. Convert at display layer only.
- **Design tokens**: Use CSS variables from `specs/Arx_4-2_Design_System.md`, don't hardcode colors/fonts/spacing.
- **Features**: Trace back to a user pain in `specs/Arx_2-1`. No upstream pain = question the feature.
- **Duplication**: Link to specs, don't copy content between files.

## Audience & Personas

- **P1 Jake** (Strategic Learner, beachhead): Mid-capital ($10K-$100K), T3-T4 skill, wants signal clarity
- **S2** = Independent traders (Leaders, 5%) — trade their own ideas
- **S7** = Capital allocators (Followers, 95%) — copy or follow signals

## Version Control

Prefer the Edit tool over Write (Edit sends diffs, Write replaces files).
Commit after every meaningful change — small, frequent commits.
Move files to `Archive/` instead of deleting. Commit current state before overwriting.
Don't use `git reset --hard` or `git push --force` without explicit approval.

## Session Scratchpad

The scratchpad (`sessions/scratchpad.md`) bridges context compaction. Three memory layers:

| Layer             | Scope                | Purpose                                     |
| ----------------- | -------------------- | ------------------------------------------- |
| Context window    | Current conversation | Active reasoning (lossy on compaction)      |
| Scratchpad        | Current session      | Survives compaction, cleared at `/gos`      |
| Persistent memory | Cross-session        | Durable learnings in `memory/` + claude-mem |

On compaction: re-read `sessions/scratchpad.md` to restore lost context.

## gOS — 7 Verbs + 1 Utility

Soul file: `.claude/gOS.md`. Sessions optionally start with `/gos`.

| Command       | Question                   | Output                                                    |
| ------------- | -------------------------- | --------------------------------------------------------- |
| `/gos`        | Am I set up?               | Session state, safety hooks                               |
| `/gos <goal>` | What do you need? (Jarvis) | Orchestrates all verbs autonomously → `outputs/gos-jobs/` |
| `/think`      | What and why?              | `outputs/think/` → `specs/`                               |
| `/design`     | What does it look like?    | `outputs/think/design/` → `specs/`                        |
| `/simulate`   | What could happen?         | `outputs/briefings/`                                      |
| `/build`      | How do we make it?         | `apps/`                                                   |
| `/review`     | Is it good?                | Verdicts, fixes, reports                                  |
| `/ship`       | Is it out?                 | Commits, PRs, deployments                                 |
| `/evolve`     | Are we getting better?     | gOS upgrades                                              |

Plus utility: `/aside` (side question).

### Execution Patterns

- **Think mode** → Swarm (3-5 parallel agents) → `outputs/think/` (staging) → promote to `specs/`
- **Design mode** → Phase pipeline (Stitch sketch → variants → full swarm → HTML bridge)
- **Simulate mode** → Engine execution (MiroFish for markets, Dux for general simulation)
- **Build mode** → Sequential (plan → code → test → verify → commit). Fresh context executors for large tasks.
- **Review mode** → Adversarial. Swarm for council, sequential for single persona. Fix-First auto-fixes.
- **Ship mode** → Pipeline (commit → PR → deploy → docs). Blocks if review dashboard not CLEARED.
- **Evolve mode** → Signal-driven. Accumulate accept/rework/reject signals, audit weekly.

### Spec Sync After Implementation

Specs describe what IS, not what was planned. After implementation changes:

| Code change           | Update                              |
| --------------------- | ----------------------------------- |
| Screen layout         | `specs/Arx_4-1-1-X`                 |
| Navigation flow       | `specs/Arx_4-1-1-0`                 |
| Data model/API        | `specs/Arx_4-1-1-7`                 |
| Feature added/removed | `specs/Arx_3-2` + `specs/Arx_4-1-0` |
| Design decision       | `specs/Arx_9-1`                     |

If implementation deviates from spec, document why in the spec. If it reveals upstream gaps, note in `specs/Arx_9-5`.

## MCP Servers

Config: `.mcp.json`. Follow Boris's rule: only tools outside normal coding.

| Server                | Purpose                                 |
| --------------------- | --------------------------------------- |
| Slack, GitHub, Sentry | Comms, code review, error tracking      |
| Hyperliquid           | Live market data (18 tools, public API) |
| Playwright            | UI testing at 390x844 (iPhone 14 Pro)   |
| Discord, Telegram     | Community monitoring                    |
| Notte                 | Anti-detection scraping                 |
| Spec-RAG              | Semantic search over specs              |

Plugins (no config needed): Vercel, Figma, Linear, Context7, Firebase, claude-mem.
Use `${ENV_VAR}` syntax for secrets in `.mcp.json`.

## Practitioner Rules

1. **Spec before agent.** Precise prompts need less review.
2. **Small chunks.** One function, one fix, one feature per prompt.
3. **Tests in same context window as implementation.**
4. **Build fast, refactor immediately.** Messy first pass is fine if you clean up right after.
5. **Context is precious.** Every irrelevant token degrades output. Keep this file lean.
6. **One landing at a time.** Swarm for research, merge implementation sequentially.
7. **Stay engaged.** Exit gates prevent disengagement regressions.
8. **CLI-accessible stack.** One-line CLI pointers beat verbose docs.

## Key Technical Context

- **Primary venue**: Hyperliquid (on-chain perpetuals DEX)
- **Signal taxonomy**: P1 Regime, P2 Instrument, P3 Participant, P4 Structural, P5 Pattern
- **Trust ladder**: Advisory → Collaborative → Delegated → Autonomous
- **Revenue**: Builder codes (2bps) + Gold subscription ($29/mo) + Copy fees
