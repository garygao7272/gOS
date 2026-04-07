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
- **Excel/XLSX**: NEVER use openpyxl for writing. Use OfficeCLI (`/Users/garyg/Documents/Claude Working Folder/toolkit/officecli`) for edits + LibreOffice headless (`soffice --headless`) for full recalc verification. See `.claude/skills/financial-modeling/SKILL.md`.

## Build Cards — The Atomic Unit of Product Work

A build card (`specs/Arx_4-1-1-X_*.md`) replaces epics, user stories, screen specs, and design handoff docs. One file per screen, containing everything needed to understand, design, build, and test it.

| Section | Replaces | Purpose |
|---------|----------|---------|
| `## Reference Screenshots` | Mood boards, design brief | Tier 1-3 app references with adopt/surpass per screen |
| `## Why` | Epic description | JTBD + pain trace to Arx_2-1 — no upstream pain = question the screen |
| `## What the User Does` | User stories | Numbered steps with S7/S2 variants |
| `## Feel` | Design brief | Feel token reference (`feel:home`) from DESIGN.md §6.9 + overrides |
| `## Layout` | Screen spec / wireframe | ASCII wireframe with auto-layout annotations (`column`, `fill-w`, `gap=12px`) |
| `## Data` | Data requirements | API source + computation for every visible element |
| `## States` | QA spec | 8-state matrix: default, empty, loading, error, partial, overflow, stale, crisis |
| `## Navigate` | Navigation spec | From/to with transition types (`push-right`, `sheet-up`, `fade`) |
| `## Acceptance` | Acceptance criteria | EARS format (WHEN/SHALL) — testable, not vague |
| `## Visual Spec` | Design handoff | Fixture pointer + icons/embellishments/interactions from DESIGN.md §3-5 |

**Three-layer architecture:**

```
Journey Maps (Arx_3-3)           → WHY (emotional arc across screens)
Master Architecture (Arx_4-1-1-0) → HOW screens connect (navigation graph)
Build Cards (Arx_4-1-1-X)        → WHAT each screen is (everything else)
```

Build cards are consumed by humans (`/review`), AI design tools (`/design ui`), and code generators (`/build`). One format, three consumers.

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

## gOS — 8 Verbs + 1 Utility

Soul file: `.claude/gOS.md`. Sessions optionally start with `/gos`.

| Command       | Question                      | Output                                                    |
| ------------- | ----------------------------- | --------------------------------------------------------- |
| `/gos`        | Am I set up?                  | Session state, safety hooks                               |
| `/gos <goal>` | What do you need? (Jarvis)    | Orchestrates all verbs autonomously → `outputs/gos-jobs/` |
| `/think`      | What and why?                 | `outputs/think/` → `specs/`                               |
| `/design`     | What are we building? (card, ui, system) | Build cards → `specs/`, visuals → Figma/prototypes |
| `/simulate`   | What could happen?            | `outputs/briefings/`                                      |
| `/build`      | How do we code it?            | `apps/`                                                   |
| `/review`     | Is it good?                   | Verdicts, fixes, reports                                  |
| `/ship`       | Is it out?                    | Commits, PRs, deployments                                 |
| `/evolve`     | Are we getting better?        | gOS upgrades                                              |
| `/refine`     | Is it tight enough?           | Gap-hunt + deepen loop until convergence                  |

Plus utility: `/aside` (side question).

### Execution Patterns

- **Think mode** → Swarm (3-5 parallel agents) → `outputs/think/` (staging) → promote to `specs/`. Includes all research (market, competitor, user, UX).
- **Design mode** → `card` (author build card spec+visual), `ui` (Figma MCP/AIDesigner/Stitch → prototype), `system` (tokens+components).
- **Simulate mode** → `market` (MiroFish + backtest), `scenario` (what-if + Dux engine).
- **Build mode** → Sequential (feature, fix, refactor). TDD always-on. One agent, one task, one commit.
- **Review mode** → `code` (PR), `design` (visual audit), `gate` (pre-ship, absorbs test/e2e/coverage), `council` (multi-persona), `eval` (command quality).
- **Refine mode** → Convergence loop (think → design → simulate → review × N). Gap-hunt + depth ladder. Exits on convergence or max iterations.
- **Ship mode** → Pipeline (commit → PR → deploy). Blocks if review gate not PASSED.
- **Evolve mode** → Signal-driven. `audit` (health check), `upgrade` (rewrite commands), `learn` (manual teaching).

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

## Palace Protocol — Memory Verification Rules

Before responding about any person, project, past event, or prior decision:
1. **Search first, never guess.** Query `memory/` files or `spec-rag` MCP before answering from recall. If unsure, say "let me check" and look it up.
2. **Verify before recommending.** If memory names a file path, check it exists. If it names a function or flag, grep for it. Memory says "X exists" is not the same as "X exists now."
3. **Invalidate stale facts.** If what you find contradicts what memory says, trust what you observe now — update or remove the stale memory.
4. **After each session.** Update memory with new decisions, corrections, and dead ends before stopping.

## Key Technical Context

- **Primary venue**: Hyperliquid (on-chain perpetuals DEX)
- **Signal taxonomy**: P1 Regime, P2 Instrument, P3 Participant, P4 Structural, P5 Pattern
- **Trust ladder**: Advisory → Collaborative → Delegated → Autonomous
- **Revenue**: Builder codes (2bps) + Gold subscription ($29/mo) + Copy fees
