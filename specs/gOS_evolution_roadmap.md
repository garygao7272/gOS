# gOS Evolution Roadmap — Spec-First Multi-Agent Co-Creator

**Status:** Active
**Created:** 2026-04-09
**Research base:** 7 agents, 80+ source searches, actual project data

---

## Vision

gOS is an interactive co-pilot optimized for a human in the loop. It turns a solo founder into a company. The next evolution: multiple agents with sufficient tools working together on three surfaces (specs, design, code) — thinking deeply, enforcing spec-first, and self-improving.

**Structural insight:** gOS and Claude Managed Agents complement rather than compete. gOS's conductor + hooks + memory tiers stay for interactive work. Managed Agent sessions become the execution backend for autonomous work (claws, long-running tasks, always-on monitoring).

---

## Architecture Principles

### 1. Specs ARE the Knowledge Base (Karpathy, April 3 2026)

gOS's 339 Arx specs already form a compiled knowledge base. INDEX.md is the index. Specs are wiki articles. Groups 0-9 are the link graph. Don't build RAG infrastructure — fix the access layer.

**Tiered access (replaces vector-first approach):**
- **Tier 1 — INDEX** (always loaded): `specs/INDEX.md` (~2-5K tokens)
- **Tier 2 — Full file** (on demand): read whole spec, never chunks
- **Tier 3 — Grep** (discovery): ripgrep over `specs/`, returns filenames
- **Tier 4 — Semantic** (last resort): LanceDB for vocabulary mismatch only, return filenames not snippets

### 2. Hard Phase Gates (Kiro Pattern)

`/think` output approved → `/design` starts. `/design` output approved → `/build` starts. No soft conventions — structural enforcement. Proven to reduce rework.

### 3. Brain/Hands Split

Interactive sessions: gOS conductor runs locally with full filesystem + MCP access.
Autonomous work: Managed Agent sessions in the cloud, event-driven, container-isolated.

### 4. Handoff Schemas

Each verb outputs a typed artifact the next verb reads. Explicit context passing. No telepathy between commands.

---

## Managed Agents: What to Absorb vs Keep

### gOS is AHEAD on:
- Multi-agent orchestration (complexity gating, team templates, conflict resolution, weighted voting)
- Memory architecture (tiered L0-L3 for context efficiency)
- Behavioral guardrails (domain-specific hooks: delete-guard, spec-compliance)
- Cost awareness (built into decision framework)
- Trigger infrastructure (hook-based reactive triggers)

### Managed Agents LEAPFROGS gOS on:
- Cloud execution (device-independent — claws run even when Mac is off)
- Session persistence (server-side event logs, reconnection after crash)
- Auto-persist memory (no manual `/gos save` needed for autonomous agents)
- Container isolation (security for untrusted work)
- Agent-as-versioned-config (portable, testable claw definitions)

### Absorb into gOS locally (no Managed Agents needed):

| Pattern | Change | Priority |
|---------|--------|----------|
| **Memory auto-write on session exit** | Formalize Stop hook: auto-persist L1 + signals every session, not just when Gary runs `/gos save` | P1 |
| **Isolated grader** (Outcomes pattern) | Spawn fresh sub-agent for grading in `/review eval` — reads only artifact + rubric, not the build session. Eliminates sycophancy. | P2 |
| **Append-only event log** | Replace mutable `sessions/scratchpad.md` with append-only `sessions/event_log.md`. Typed entries. Better compaction recovery. | P3 |
| **Memory-as-code commits** | Every memory write during `/gos save` gets its own git commit | P4 |
| **Deferred context loading** | Don't load L2 specs at session start — wait until verb command actually needs them | P1 |

### Use Managed Agents cloud for:

| Use case | When | Why cloud |
|----------|------|-----------|
| **Claws** (spec-drift, market pulse, evolve audit) | After preview access | Device must be awake today; claws have zero runs |
| **Long-running orchestration** (multi-hour `/think` or `/build`) | After preview access | Survives context compaction, session persistence |
| **GitHub-triggered spec enforcement** | Immediately (no preview needed) | Webhook → create Managed Agent session → validate spec compliance on push |

### Do NOT absorb:

| What | Why |
|------|-----|
| Flat memory stores replacing L0-L3 tiers | gOS's tiered architecture is better for context-window economics |
| Managed Agents' delegation model | gOS conductor + complexity gate + team registry is strictly more sophisticated |
| Container isolation for interactive sessions | gOS's power comes from full filesystem + MCP access |
| $0.08/hr always-on pricing | Event-driven design only; minutes not hours |

---

## Prioritized Build List (Final, v3)

### P0: Fix What's Broken (this week, <1 session each)

| # | What | Effort | Impact |
|---|------|--------|--------|
| 1 | **Fix spec-compliance.sh naming bug** | 30 min | Unlocks hard spec-first enforcement |
| 2 | **Fix spec-RAG: remove 600-char truncation, add grep tool** | 2 hrs | Karpathy-informed tiered access |
| 3 | **Formalize memory auto-write Stop hook** | 30 min | Every session auto-persists L1 + signals (Managed Agents pattern) |
| 4 | **Request Managed Agents preview access** | 5 min | Unlock memory stores + multi-agent + outcomes |

### P1: Enforcement Gates (2-3 sessions)

| # | What | Effort | Impact |
|---|------|--------|--------|
| 5 | **Hard phase gates** (Kiro pattern) | 1 session | `/think` → `/design` → `/build` requires approval between phases |
| 6 | **Context budget monitor** (PreToolUse hook) | 1 session | Auto-dispatch to fresh agent before exhaustion |
| 7 | **Handoff schemas** between commands | 1 session | Typed artifact output → next verb's input brief |
| 8 | **Test scaffolder from spec acceptance criteria** | 1 session | Auto-generate RED tests from specs. Testing 3→7 |
| 9 | **Deferred context loading** | 30 min | Load L2 specs when verb needs them, not at session start |

### P2: Verification & Visibility (2-3 sessions)

| # | What | Effort | Impact |
|---|------|--------|--------|
| 10 | **Spec↔code coverage matrix** in `/gos status` | 1 session | "What's not specced / designed / coded / tested?" |
| 11 | **Isolated grader** for `/review eval` | 1 session | Fresh agent scores artifact against rubric — eliminates self-grading bias |
| 12 | **Actor-aware evolve signals** | 30 min | Tag which agent produced each finding |
| 13 | **Spec freshness checker** (Karpathy's "lint") | 1 session | Auto-scan for staleness, broken cross-refs, orphaned pages |
| 14 | **Append-only event log** replacing mutable scratchpad | 1 session | Better compaction recovery, typed entries |

### P3: Cloud Architecture (3-5 sessions, after preview access)

| # | What | Effort | Impact |
|---|------|--------|--------|
| 15 | **Migrate claws to Managed Agent sessions** | 2 sessions | Cloud execution, auto-persist memory, event-driven triggers |
| 16 | **GitHub Actions → Managed Agent webhook** for spec-drift | 1 session | Validates spec compliance on every push, device-independent |
| 17 | **Named SDK subagents per command** | 2 sessions | spec-writer (no code tools), researcher (WebSearch), reviewer (read-only) |
| 18 | **Agent-as-versioned-config** for claws | 1 session | Portable, testable claw definitions with version manifest |

### P4: Polish & Future-Proof

| # | What | Effort | Impact |
|---|------|--------|--------|
| 19 | **Add Exa MCP** for neural research | 30 min | Biggest gap for `/think research` |
| 20 | **AGENTS.md adoption** | 1 session | Industry standard, compatible with Cursor/Codex/Gemini |
| 21 | **Promptfoo eval pipeline** | 2 sessions | Automated command quality scoring |
| 22 | **End-to-end pipeline proof** | 1 session | One feature: spec→tests→code→verify→deploy |
| 23 | **Memory directory restructure** (user/, project/, feedback/) | 30 min | Cleaner organization, matches Karpathy's wiki/ pattern |

---

## What Got Cut from v2 (and Why)

| Item | Why cut |
|------|---------|
| Knowledge Graph Memory MCP | Managed Agent memory stores are the better path for autonomous agents; L0-L3 stays for interactive |
| Full LanceDB upgrade | Wrong architecture per Karpathy. Fix access layer, don't upgrade vector search |
| Local Agent Teams migration | Managed Agents multi-agent is the cloud version with persistence |
| cerebrus-pulse-mcp | Not on critical path for gOS framework improvement |
| Replacing gOS hooks with Managed Agents tool confirmation | gOS's domain-specific hooks are strictly more powerful |

---

## Success Metrics

| Metric | Current | Target | How to Measure |
|--------|---------|--------|----------------|
| Testing score | 3/10 | 7/10 | Test files exist, TDD evidence, eval pipeline runs |
| Craft score | 4/10 | 7/10 | Spec compliance enforced (hard gate), zero drift |
| Learning score | 5/10 | 8/10 | Auto-persist every session, pattern→upgrade loop proven |
| Claw execution | 0 runs | Weekly cadence | Managed Agent sessions triggered on schedule |
| Spec→code coverage | Unknown | Tracked per module | Coverage matrix in `/gos status` |
| Context exhaustion incidents | 2+ per week | 0 | Budget monitor auto-dispatches before exhaustion |

---

## Decision Log

| Decision | Rationale | Date |
|----------|-----------|------|
| Tiered spec access over vector-first | Karpathy: specs are compiled KB, not retrieval targets. Claude Code itself uses grep not vectors. | 2026-04-09 |
| gOS conductor stays local, claws go cloud | Interactive work needs full filesystem + MCP. Autonomous work needs device independence. | 2026-04-09 |
| Don't replace L0-L3 with flat memory stores | Tiered loading is context-efficient. Flat stores would waste tokens on irrelevant memories. | 2026-04-09 |
| Absorb isolated grader pattern | Fresh agent for scoring eliminates sycophancy. Managed Agents "Outcomes" pattern. | 2026-04-09 |
| Kill 6 commands, consolidate to 8 | First-principles: 14 commands had 37/41 unused finance sub-commands, REPL-in-REPL, redundant orchestration | 2026-04-09 |
