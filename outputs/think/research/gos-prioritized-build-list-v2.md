# gOS Prioritized Build List v2

**Date:** 2026-04-09
**Inputs:** 5 research agents across 2 rounds, 60+ source searches, actual project data (339 Arx specs, 130 active, ~1.1M tokens)
**Prior version:** `gos-spec-first-multi-agent-upgrade.md` (same session, pre-Karpathy/Managed-Agents research)

---

## Key Insights That Changed the Priority Stack

### 1. Karpathy's Knowledge Base > Vector RAG (April 3, 2026)

gOS specs already ARE a Karpathy-style compiled knowledge base. The `specs/INDEX.md` is his `index.md`. The individual specs are his wiki articles. The hierarchy (Groups 0→9) is his link graph. **The architecture is already right — the access layer is wrong.**

The current LanceDB spec-RAG has classic failure modes:
- 600-char snippets destroy cross-references and table context
- `all-MiniLM-L6-v2` is a general model, not tuned for structured markdown
- Top-5 results miss structural relationships between spec groups
- No staleness management

**Claude Code itself uses markdown index + lexical grep, not vector DB.** If LanceDB were the right answer, Anthropic would have used it.

**The fix:** Tiered access — index always loaded → full file load on demand → grep for discovery → vector search only as last resort for vocabulary mismatch.

### 2. Claude Managed Agents (Launched April 8, 2026)

Cloud-hosted persistent agents. $0.08/session-hour. 4-object model: Agent → Environment → Session → Events. Three research preview features (require access request):
- **Memory stores** — workspace-scoped, auto-read/write, versioned, 100KB each. Replaces manual `memory/*.md` + `state.json`.
- **Multi-agent** — coordinator with `callable_agents[]`, shared filesystem, isolated context. Single-level delegation.
- **Outcomes** — self-evaluation + iteration loops + scheduled execution.

**For gOS:** Migrate claws and long-running orchestration. Event-driven, not always-on (cost control).

### 3. Anthropic's Own Multi-Agent System (Internal Research)

90.2% quality improvement over single-agent at 15x token cost. Key lesson: decompose by independence of work, not type. Save plan to external memory before context fills. Prompt quality dominates architecture.

---

## The Regenerated Priority Stack

### P0: Fix What's Broken (this week)

| # | What | Effort | Impact | Status |
|---|------|--------|--------|--------|
| 1 | **Fix spec-compliance.sh naming bug** | 30 min | Unlocks hard spec-first enforcement | Broken |
| 2 | **Replace spec-RAG snippets with tiered access** | 2 hrs | Fix INDEX.md → full file load → grep → vector (last resort). Remove 600-char truncation. | Wrong architecture |
| 3 | **Install 6 missing agents globally** | 5 min | researcher, designer, engineer, reviewer, verifier, aidesigner-frontend | **DONE this session** |
| 4 | **Request Managed Agents preview access** | 5 min | Unlock memory stores + multi-agent + outcomes | Form at claude.com/form/claude-managed-agents |

### P1: Enforcement Gates (next 2 sessions)

| # | What | Effort | Impact |
|---|------|--------|--------|
| 5 | **Hard phase gates** (Kiro pattern) | 1 session | `/think` output approved before `/design`; `/design` before `/build`. Proven to reduce rework. |
| 6 | **Context budget monitor** (PreToolUse hook) | 1 session | Auto-dispatch to fresh agent before exhaustion. Prevents "approved but never executed." |
| 7 | **Handoff schemas** between commands | 1 session | Each verb outputs a typed artifact the next verb reads. No telepathy. |
| 8 | **Test scaffolder from spec acceptance criteria** | 1 session | Auto-generate RED tests from spec criteria. Makes TDD real. Testing 3→7. |

### P2: Visibility Layer (2-3 sessions)

| # | What | Effort | Impact |
|---|------|--------|--------|
| 9 | **Spec↔code coverage matrix** in `/gos status` | 1 session | "Which specs have no code? Which code has no spec? Which code has no tests?" |
| 10 | **Actor-aware evolve signals** | 30 min | Tag which agent/command produced each finding. Prevents inference masking. |
| 11 | **Spec freshness checker** | 1 session | Auto-scan for staleness, broken cross-refs, orphaned pages (Karpathy's "lint" operation). |

### P3: Multi-Agent Architecture (3-5 sessions, after preview access)

| # | What | Effort | Impact |
|---|------|--------|--------|
| 12 | **Migrate claws to Managed Agents** | 2 sessions | Persistent, cloud-hosted, memory stores. Event-driven design. |
| 13 | **Named SDK subagents per command** | 2 sessions | spec-writer (no code tools), researcher (WebSearch), reviewer (read-only), coder (edit). Tool restrictions at SDK level. |
| 14 | **Multi-project coordinator** | 1 session | One gOS agent with `callable_agents: [arx, advance_wealth]`. First cross-project view. |
| 15 | **Memory store migration** | 1 session | Replace manual `memory/*.md` with Managed Agent memory stores. Versioned, auto-read/write. |

### P4: Polish & Future-Proof

| # | What | Effort | Impact |
|---|------|--------|--------|
| 16 | **Add Exa MCP** | 30 min | Neural semantic search for external research. Biggest gap for `/think research`. |
| 17 | **AGENTS.md adoption** | 1 session | Industry-standard spec format. Compatible with Cursor, Codex, Gemini. |
| 18 | **Promptfoo eval pipeline** | 2 sessions | Automated command quality scoring. Testing dimension proof. |
| 19 | **End-to-end pipeline proof** | 1 session | One feature: spec→tests→code→verify→deploy. Proves the full loop works. |

---

## What Got Deprioritized (and Why)

| Previously High | Now | Why |
|-----------------|-----|-----|
| Knowledge Graph Memory MCP | **Deprioritized** | Managed Agent memory stores are the better path — versioned, cloud-hosted, auto-read/write. Don't build local infrastructure that Anthropic is building hosted. |
| Full LanceDB spec-RAG upgrade | **Replaced** | Karpathy's insight: tiered access (index→grep→full load) beats vector search for compiled knowledge bases. Fix the access pattern, don't upgrade the wrong architecture. |
| Agent Teams (local) | **Superseded** | Managed Agents multi-agent is the cloud-hosted version with persistence. Local Agent Teams useful as fallback but not the primary path. |
| cerebrus-pulse-mcp | **Deferred** | Nice-to-have for Arx simulation, not on the critical path for gOS framework improvement. |

---

## The Spec Access Architecture (Karpathy-Informed)

```
Tier 1: INDEX LOAD (always, every session)
  └── specs/INDEX.md (~2-5K tokens) — one-line summary + path per spec
  └── LLM navigates from here to specific specs

Tier 2: FULL FILE LOAD (on demand)
  └── Read the full spec file — never a chunk
  └── Spec is the atomic unit

Tier 3: LEXICAL GREP (discovery)
  └── ripgrep over specs/ directory
  └── Returns matching filenames → then load full file
  └── Zero infrastructure, zero staleness, transparent failures

Tier 4: SEMANTIC SEARCH (last resort)
  └── LanceDB/spec-RAG only for vocabulary mismatch
  └── Return filenames, not snippets → then load full file
  └── Most sessions should never reach this tier
```

**Quick wins (no MCP rewrite needed):**
1. Remove 600-char snippet truncation from `search_specs` — return full files
2. Add `grep_specs(keyword)` tool to spec-RAG MCP as alternative to vector search
3. Ensure `INDEX.md` is loaded in Step 0 of every `/gos` session

---

## Decision Points for Gary

1. **Request Managed Agents preview access now?** (Yes/No — I recommend Yes)
2. **Spec-RAG: fix incrementally or rewrite?** (I recommend incremental — remove snippet truncation + add grep)
3. **Hard phase gates: advisory warning or blocking?** (I recommend blocking, Kiro-style)
4. **Promote to spec?** This is substantial enough for `specs/gOS_evolution_roadmap.md`

---

**CONFIDENCE: High** — grounded in Karpathy's published gist (April 3, 2026), Anthropic's official Managed Agents docs (April 8, 2026), 60+ source searches, and actual project data (339 specs, 1.1M tokens measured).
