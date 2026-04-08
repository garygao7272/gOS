---
name: Spec Editing Procedure
description: How to correctly edit specs — cascade rules, journey-based structure, archive old versions
type: procedure
valid_from: 2026-04-08
valid_to: open
---

## How to Edit Specs

1. **Read INDEX.md** — Check spec ID and dependencies
2. **Check cascade** — Changes flow downward only (Foundation -> Market -> Product -> Design -> Engineering)
3. **Archive first** — Move current version to `Archive/` with date prefix before major rewrites
4. **Journey structure** — Organize by user journeys with self-contained cards, not technical architecture
5. **Agent tags** — Include `<!-- AGENT: -->` comment at top with key files, dependencies, test paths
6. **Trace to pain** — Every feature must trace to a user pain in specs/Arx_2-1. No upstream pain = question it
7. **Update downstream** — After editing, check if downstream specs need updates (see Spec Sync table in CLAUDE.md)

## When to Use

Any task involving files in `specs/`.
