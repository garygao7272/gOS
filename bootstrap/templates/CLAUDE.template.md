# {{PROJECT_NAME}} — Project Instructions

## What Is {{PROJECT_NAME}}

<!-- Describe your project in 2-3 sentences. What does it do? Who is it for? -->

## Project Structure

```
{{PROJECT_NAME}}/
├── CLAUDE.md                    ← YOU ARE HERE
├── .claude/
│   ├── GOD.md                   ← God's soul file (identity, principles, voice)
│   └── commands/                ← The Writ (9 commands)
├── specs/                       ← Product specs (authoritative source for all product knowledge)
│   └── INDEX.md                 ← Quick lookup
├── apps/                        ← All buildable projects
├── tools/                       ← Custom MCP servers and dev tools
├── sessions/                    ← Session tracking
│   └── active.md               ← Current session registry
└── outputs/                     ← Generated outputs
```

## The Writ — God's Command Set

| Command | Decree | Domain |
|---------|--------|--------|
| `/god` | **Summon** — awaken, brief, route | Session entry |
| `/think` | **Reason** — discover, design, research, decide, spec | Product + strategy |
| `/build` | **Create** — prototype, feature, component, test, deploy | Implementation |
| `/judge` | **Evaluate** — personas, specialists, full-council | Quality + truth |
| `/schedule` | **Automate** — recurring agents on autopilot | Delegation |
| `/coordinate` | **Orchestrate** — parallel sessions, handoffs | Scale |
| `/evolve` | **Improve** — self-reflect, upgrade, learn | Growth |
| `/prototype` | **Sketch** — quick prototype shortcut | Speed |
| `/verify-app` | **Prove** — verify it works | Evidence |

### Execution Patterns

**Think mode → Swarm (parallel agents).** Launch 3-5 agents in parallel with the same input. Each produces independent documents. Then synthesize the best result.

**Build mode → Sequential (one agent, one task, one commit).** Never swarm on implementation. Each step depends on the previous.

**Judge mode → Swarm for full-council, sequential for single persona.**

### Mode → Output Mapping

```
/think   → specs/    (product specs, research, decisions)
/build   → apps/     (code, prototypes, tests)
/judge   → specs/ + apps/ (corrections, fixes)
/schedule → Recurring agents
```

## Specs System

<!-- Customize the altitude map for your project -->

| Altitude | Group | Question Answered |
|----------|-------|-------------------|
| 30,000 ft | 1 — Foundation | Why does this exist? |
| 20,000 ft | 2 — Market Intel | Who do we serve, what hurts? |
| 10,000 ft | 3 — Product | What do we build? |
| 5,000 ft | 4 — Design | How does it look and feel? |
| 1,000 ft | 5 — Engineering | How is it built? |
| 0 ft | 6 — Execution | How do we ship? |
| Ground | 7 — Operations | How do we measure? |
| Lateral | 9 — Governance | How do we decide and remember? |

### Cascade Rule

Changes flow **downward only**. A strategy change (Group 1) cascades to product (Group 3) to design (Group 4) to engineering (Group 5). Lower-altitude changes do NOT override upstream files.

## MCP Servers

<!-- List your project's MCP servers here -->

| Server | Purpose | Auth |
|--------|---------|------|
| **Playwright** | UI testing & automation | None (local) |

## Common Mistakes — Do NOT Repeat

<!-- Add project-specific gotchas here -->

- Never use floating point for currency/prices — use integer base units
- Never hardcode colors, fonts, or spacing — use design tokens
- Always trace features to a user pain — if no upstream pain exists, question the feature
- Link to spec files, don't copy content between files

## Version Control

- **NEVER delete a file** — move to `Archive/` or let git track
- **Use the Edit tool, not Write** — smaller diffs, cleaner history
- **Commit after every meaningful change** — small, frequent commits
- **Never `git reset --hard` or `git push --force`** without explicit approval

## Session Scratchpad

The scratchpad (`sessions/scratchpad.md`) is session-scoped working memory:
- **Cleared** at every `/god`
- **Written to** at natural checkpoints
- **Re-read** after compaction to restore lost context
- **Never committed** to git

## Practitioner Rules

1. **Spec before agent, always.**
2. **Small chunks, never monoliths.**
3. **Tests in the same context window as implementation.**
4. **Build fast, refactor immediately.**
5. **Context is precious.** Every irrelevant token degrades output.
6. **One landing at a time.** Many agents for research, sequential for implementation.
7. **Stay engaged.** Exit gates prevent regressions.
8. **Make the stack CLI-accessible.**
