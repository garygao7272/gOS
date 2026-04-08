# Arx — Project Instructions

## What Is Arx

Arx is a mobile-first crypto trading terminal built on Hyperliquid. It unifies smart money intelligence, trade execution, copy trading, and risk management into a single AI-augmented interface for retail traders. Spelling: "Arx" — not "ARX", not "arx".

## Specs

All product knowledge lives in `specs/`. Read the relevant spec before making product, design, or engineering decisions.

```
Start here:  specs/INDEX.md                              ← Quick lookup
Registry:    specs/Arx_0-0_Artifact_Registry.md           ← What exists, naming, cascade
Workflow:    specs/Arx_0-1_Workflow_Playbook.md            ← Pipeline, ownership, templates
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

| Section                    | Replaces                  | Purpose                                                                          |
| -------------------------- | ------------------------- | -------------------------------------------------------------------------------- |
| `## Reference Screenshots` | Mood boards, design brief | Tier 1-3 app references with adopt/surpass per screen                            |
| `## Why`                   | Epic description          | JTBD + pain trace to Arx_2-1 — no upstream pain = question the screen            |
| `## What the User Does`    | User stories              | Numbered steps with S7/S2 variants                                               |
| `## Feel`                  | Design brief              | Feel token reference (`feel:home`) from DESIGN.md §6.9 + overrides               |
| `## Layout`                | Screen spec / wireframe   | ASCII wireframe with auto-layout annotations (`column`, `fill-w`, `gap=12px`)    |
| `## Data`                  | Data requirements         | API source + computation for every visible element                               |
| `## States`                | QA spec                   | 8-state matrix: default, empty, loading, error, partial, overflow, stale, crisis |
| `## Navigate`              | Navigation spec           | From/to with transition types (`push-right`, `sheet-up`, `fade`)                 |
| `## Acceptance`            | Acceptance criteria       | EARS format (WHEN/SHALL) — testable, not vague                                   |
| `## Visual Spec`           | Design handoff            | Fixture pointer + icons/embellishments/interactions from DESIGN.md §3-5          |

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

## Plan Gate (enforced on every command)

Every gOS command presents a lightweight plan before executing. No exceptions.
Format: PLAN (1-line restatement) → STEPS (numbered) → MEMORY (relevant L1/L2) → RISK → CONFIDENCE → Confirm?
The MEMORY field MUST include: dead ends from prior sessions, known failures from feedback memories, and risks from evolve signals. Search `memory/` before populating — don't rely on recall.
Before editing specs or code, check what depends on it. For specs: check downstream per cascade rules. For code: check imports and tests. Surface affected files before starting.
After confirmation: write plan to scratchpad, create TodoWrite items, execute step by step.
Skip only if Gary says "just do it" or the task is trivially atomic.

**Confidence scoring** — every plan and output includes:
`CONFIDENCE: high/medium/low — [one-line reason]`
If confidence < 70% (medium-low), flag the key uncertainty to Gary before proceeding. Example: `CONFIDENCE: medium — unsure whether Hyperliquid API returns funding as annualized or per-interval`.

**Prerequisites by command:**

- `/build`: Read the spec? Read existing code? Run tests baseline?
- `/design card`: Read DESIGN.md? Read journey map? Check reference apps?
- `/review`: Read full diff? Load the spec it implements?
- `/ship`: Review gate PASSED? Tests green? Spec sync done?

**Bias check:** Am I over-engineering? Expanding scope beyond what was asked? Just confirming Gary's assumption without challenging it?

## Autonomy Framework

| Category                      | Rule                                                                                                                                                                                                                       |
| ----------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **PROCEED** (no ask)          | Reading files, searching, gathering context. Auto-fixing formatting/imports/typos. Running tests. Updating scratchpad/signals.                                                                                             |
| **ASK** (always)              | Architectural decisions. Deleting or moving files. Changing specs. Deploying. Sending messages (email, Slack, PR). Spending money (API calls with cost). Any irreversible action. Adding a dependency (Gary has opinions). |
| **JUDGMENT** (use confidence) | Fixing a bug — ask if <80% confident in root cause. Refactoring — ask if it changes public API.                                                                                                                            |
| **STUCK** (3 failures)        | Stop, summarize what was tried, ask Gary for direction. Don't silently try a 4th approach.                                                                                                                                 |

## Memory Architecture (4 layers)

```
L0: Identity (≤100 tok)  — ALWAYS loaded. memory/L0_identity.md
L1: Essential (≤800 tok) — ALWAYS loaded. memory/L1_essential.md — updated every save
L2: On-Demand (search)   — Loaded when relevant via Palace Protocol
L3: Deep Search           — claude-mem + spec-rag. Semantic query.
```

Loading order: L0 → L1 → task-relevant L2 → L3 only if L2 insufficient.

**Memory hygiene (weekly):** Scan `memory/` for: files with expired `valid_to`, facts that contradict current codebase state, duplicate content across files. Propose deletions/updates — don't auto-delete. Run during `/evolve audit` or when memory file count exceeds 25.

## Session Scratchpad

The scratchpad (`sessions/scratchpad.md`) bridges context compaction. Three memory layers:

| Layer             | Scope                | Purpose                                     |
| ----------------- | -------------------- | ------------------------------------------- |
| Context window    | Current conversation | Active reasoning (lossy on compaction)      |
| Scratchpad        | Current session      | Survives compaction, cleared at `/gos`      |
| Persistent memory | Cross-session        | Durable learnings in `memory/` + claude-mem |

On compaction: re-read `sessions/scratchpad.md` to restore lost context.

**Mini-checkpoint (every ~15 interactions):** After roughly 15 human messages, do a lightweight save — update scratchpad context estimate, write any unlogged evolve signals, and refresh L1 current focus. This prevents long sessions from losing context if compaction or exit happens unexpectedly.

## gOS — 8 Verbs + 1 Utility

Soul file: `.claude/gOS.md`. Sessions optionally start with `/gos`.

| Command       | Question                                 | Output                                                    |
| ------------- | ---------------------------------------- | --------------------------------------------------------- |
| `/gos`        | Am I set up?                             | Session state, safety hooks                               |
| `/gos <goal>` | What do you need? (Jarvis)               | Orchestrates all verbs autonomously → `outputs/gos-jobs/` |
| `/think`      | What and why?                            | `outputs/think/` → `specs/`                               |
| `/design`     | What are we building? (card, ui, system) | Build cards → `specs/`, visuals → Figma/prototypes        |
| `/simulate`   | What could happen?                       | `outputs/briefings/`                                      |
| `/build`      | How do we code it?                       | `apps/`                                                   |
| `/review`     | Is it good?                              | Verdicts, fixes, reports                                  |
| `/ship`       | Is it out?                               | Commits, PRs, deployments                                 |
| `/evolve`     | Are we getting better?                   | gOS upgrades                                              |
| `/refine`     | Is it tight enough?                      | Gap-hunt + deepen loop until convergence                  |

Plus utility: `/aside` (side question).

### Execution Patterns

- **Think mode** → Swarm (3-5 parallel agents) → `outputs/think/` (staging) → promote to `specs/`. Includes all research (market, competitor, user, UX).
- **Design mode** → `card` (author build card spec+visual), `ui` (Figma MCP/AIDesigner/Stitch → prototype), `system` (tokens+components).
- **Simulate mode** → `market` (MiroFish + backtest), `scenario` (what-if + Dux engine).
- **Build mode** → Sequential (feature, fix, refactor). TDD always-on. One agent, one task, one commit.
- **Review mode** → `code` (PR), `design` (visual audit), `gate` (pre-ship, absorbs test/e2e/coverage), `council` (multi-persona), `eval` (command quality).
- **Refine mode** → Convergence loop (think → design → simulate → review × N). Gap-hunt + depth ladder. Exits on convergence or max iterations.
- **Ship mode** → Pipeline (commit → PR → deploy). Blocks if review gate not PASSED.
- **Evolve mode** → Signal-driven. `audit` (health check + drift analysis: count signal types per command over last 5 sessions, flag rework rate >30% or repeat signals, generate upgrade proposal if drift detected), `upgrade` (rewrite commands), `learn` (manual teaching).

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
9. **Check blast radius.** Before editing specs, trace downstream per cascade. Before editing code, check imports and tests. Surface affected files in the plan.

## Palace Protocol — Memory Verification Rules

Before responding about any person, project, past event, or prior decision:

1. **Search first, never guess.** Query `memory/` files or `spec-rag` MCP before answering from recall. If unsure, say "let me check" and look it up.
2. **Verify before recommending.** If memory names a file path, check it exists. If it names a function or flag, grep for it. Memory says "X exists" is not the same as "X exists now."
3. **Invalidate stale facts.** If what you find contradicts what memory says, trust what you observe now — update or remove the stale memory.
4. **After each session.** Update memory with new decisions, corrections, and dead ends before stopping.
5. **Say "I don't know" when you don't.** If memory search returns nothing AND you can't verify from code/specs, you MUST say: "I don't have this in my records. Want me to research it?" Never fabricate facts about: Gary's preferences, past decisions, project state, market data, or competitor specifics. This applies to all outputs — plans, analyses, recommendations. Confidence < 70% on a factual claim = flag it explicitly rather than stating it as fact.

## Key Technical Context

- **Primary venue**: Hyperliquid (on-chain perpetuals DEX)
- **Signal taxonomy**: P1 Regime, P2 Instrument, P3 Participant, P4 Structural, P5 Pattern
- **Trust ladder**: Advisory → Collaborative → Delegated → Autonomous
- **Revenue**: Builder codes (2bps) + Gold subscription ($29/mo) + Copy fees
