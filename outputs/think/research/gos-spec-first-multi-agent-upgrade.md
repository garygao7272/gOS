# Research: Upgrading gOS into a Frontier Spec-First Multi-Agent Co-Creator

**Date:** 2026-04-09
**Command:** `/think research`
**Question:** What should gOS improve to achieve its vision of multiple agents with sufficient tools working together, thinking deeply and building specs first across Arx, Advance Wealth, and future projects?

---

## Executive Finding

gOS's spec-first architecture is **structurally sound but operationally unenforced.** Arx proves the spec layer can reach extraordinary depth (339 files, 8 groups, clean MECE taxonomy). But the pipeline leaks at every transition: specs don't gate builds, builds don't trigger spec sync, tests don't exist, and context exhaustion silently kills multi-step operations. The 3-surface model's weakest surface is Design, but the more critical gap is the absence of a **verification surface** that closes the spec-to-code loop.

**One sentence:** The system writes beautifully but doesn't check its own work.

---

## Research Findings (3 Agents, 23 Sources)

### 1. Spec-Driven Development is Now an Industry Pattern

gOS is ahead of the curve — but the industry is catching up fast:

- **GitHub Spec Kit** (open source): Structured process for spec-driven development. Treats specs as executable contracts. Works with Claude Code, Copilot, Gemini CLI.
- **Kiro** (AWS): Agentic AI IDE that enforces spec→plan→code as a hard pipeline.
- **AGENTS.md** (Google + OpenAI + Cursor + Sourcegraph, late 2025): Vendor-neutral markdown format replacing fragmented tool-specific configs. Emerging cross-platform standard.
- **Thoughtworks SDD** (2025 Technology Radar): Identifies spec-driven development as one of 2025's key new AI-assisted engineering practices. The core pattern: intent → spec → plan → execution.
- **Addy Osmani's "How to Write a Good Spec"**: Practical guide for AI agent consumption — structured markdown, clear acceptance criteria, explicit scope boundaries.

**Implication for gOS:** The architecture is right. What's missing is enforcement (hard gates) and interoperability (AGENTS.md compatibility).

### 2. Claude Agent SDK is the Right Foundation

- **Agent SDK** (platform.claude.com): Same tools, agent loop, and context management that power Claude Code — programmable in Python and TypeScript. Built-in memory tool with file-based persistence.
- **Agent Teams** (experimental): Multiple Claude Code instances coordinating via SendMessage. One team lead, independent teammates, each in its own context window.
- **Sub-agents** vs **Agent Teams**: Sub-agents for discrete tasks within one session. Agent Teams for truly parallel work across sessions. gOS currently uses sub-agents only.
- **Claude Managed Agents** (platform.claude.com): Server-side persistent agents. Deploy once, invoke on demand or on schedule.

**Implication for gOS:** Currently limited to `Agent()` tool calls. The Agent SDK would unlock: persistent agents surviving context compaction, shared spec-RAG index, programmatic orchestration of the 8-command pipeline.

### 3. Multi-Agent Framework Landscape (April 2026)

| Framework | Orchestration | Best For | Relevance to gOS |
|-----------|--------------|----------|-------------------|
| Claude Agent SDK | Sub-agents + Teams | Claude-native workflows | **Direct fit** — same foundation |
| CrewAI | Role-based crews | Quick team assembly, 20 lines to start | Pattern inspiration (role DSL) |
| LangGraph | Directed graph, conditional edges | Complex stateful workflows | Overkill for gOS's needs |
| AutoGen/AG2 | Conversational GroupChat | Debate/decision scenarios | Pattern for `/think decide` |
| OpenAI Swarm | Lightweight agent handoff | Simple delegation chains | Too simple for gOS |

**Verdict:** Don't switch frameworks. Claude Agent SDK + Claude Code is the right stack. Adopt CrewAI's role DSL pattern and AutoGen's debate pattern selectively.

### 4. The 3-Surface Model — Gap Analysis

**Surface 1 (SPECS): Extraordinarily strong.**
- Arx: 339 spec files, 8 groups, MECE taxonomy, clean cascade model
- Advance Wealth: 24 spec files, well-structured but no code output yet
- Ship Card architecture (Journey Cards → Ship Cards at P0/P1/P2) is genuinely well-designed

**Surface 2 (DESIGN): A wasteland.**
- Zero Figma files referenced from specs
- Web prototype is a 32,160-line single HTML file (v1.27.0) with 42 archived versions
- Gary's learned preference: "Code-first pipeline beats Figma-first" (L1 memory)
- AI design tools evaluated (AIDesigner, Stitch) but none settled
- **Redefine Surface 2** as "visual verification" not "Figma files"

**Surface 3 (CODE): Spec overproduction.**
- Arx: ~110 .tsx/.ts component files, 5 smoke tests (no TDD evidence)
- Advance Wealth: 0 code files (empty apps/ directory)
- Spec-to-code ratio: 3:1 in Arx, ∞ in Advance Wealth
- Test-to-code ratio: 0.05:1 (5 tests / 110 files)

**Missing Surface: VERIFICATION.**
- No spec↔code coverage matrix ("which specs have no code? which code has no spec?")
- No visual regression checking (Playwright exists but not wired)
- No deployment state tracking (what's deployed where)
- No test scaffolding from spec acceptance criteria

### 5. Where the Pipeline Breaks (Evidence from Signals)

| Break Point | Evidence | Root Cause |
|-------------|----------|------------|
| **Spec compliance not enforced** | spec-compliance.sh has naming mismatch bug | Hook infrastructure exists but is broken |
| **Context exhaustion kills multi-step work** | 2026-03-29: "Reorg task approved but never executed — 2 sessions hit context limit" | 339 specs generate enormous context; no budget monitoring |
| **Cross-project contamination** | 2026-04-09: "Resume loaded wrong session" | No memory fence between Arx and Advance Wealth |
| **TDD never actually happens** | Testing 3/10, zero TDD evidence, Test Strategy spec is "placeholder" | No test-before-commit gate |
| **Spec sync fails silently** | Specs approved but never physically updated when context runs out | No post-build spec-diff check |
| **`<!-- AGENT: -->` tags aspirational** | Referenced in CLAUDE.md but not found in actual spec files | Prescribed but never implemented |

### 6. Agent Memory is the Weakest Link

**Industry patterns:**
- **Mem0**: Structured memory with semantic retrieval, staleness detection
- **MemGPT/Letta**: Hierarchical memory tiers with automatic promotion/demotion
- **Claude Memory Tool**: File-based memory with agent-managed read/write

**gOS gap:** Memory exists (L0-L3 architecture) but is manually managed. No agent writes to memory automatically. The staleness checker was proposed but never built. Cross-session knowledge transfer depends on `/gos save` being run — which gets skipped when context is exhausted.

---

## Prioritized Upgrade Plan

### Tier 1: Fix What's Broken (1 session each)

| # | Upgrade | Impact | Current State |
|---|---------|--------|---------------|
| 1 | **Fix spec-compliance.sh hook** | Enforce spec-first as hard gate | Naming mismatch bug, blocks nothing |
| 2 | **Verify spec-RAG MCP works** | Enable semantic spec search for agents | Installed but untested |
| 3 | **Add context budget monitor** | Prevent "approved but never executed" | No monitoring exists |
| 4 | **Add cross-project memory fence** | Prevent session contamination | Signals show contamination occurred |

### Tier 2: Close the Verification Gap (2-3 sessions)

| # | Upgrade | Impact | What It Enables |
|---|---------|--------|-----------------|
| 5 | **Spec↔code coverage matrix** | Answer "what's not specced/coded/tested?" | Surface status dashboard in `/gos status` |
| 6 | **Test scaffolder agent** | Generate test stubs from spec acceptance criteria | Makes TDD real instead of aspirational |
| 7 | **Post-build spec-diff check** | Auto-verify implementation matches spec | Closes the enforcement loop |
| 8 | **Visual regression via Playwright** | Screenshot diff against spec wireframes | Automated design verification |

### Tier 3: Multi-Agent Architecture (3-5 sessions)

| # | Upgrade | Impact | What It Enables |
|---|---------|--------|-----------------|
| 9 | **Agent SDK orchestration layer** (Python) | Persistent agents, shared memory, programmatic orchestration | True multi-agent with cross-session coordination |
| 10 | **Spec freshness scheduled agent** | Auto-scan 339 specs for staleness, broken refs | Prevents spec rot at scale |
| 11 | **Deployment state tracker** | Know what's deployed where, when, which commit | Surface 3 operational awareness |
| 12 | **AGENTS.md adoption** | Standard spec format compatible with Cursor/Codex/Gemini | Not locked to Claude ecosystem |

### Tier 4: The Compound Effect

| # | Upgrade | Impact | What It Enables |
|---|---------|--------|-----------------|
| 13 | **End-to-end pipeline proof** | Spec→tests→code→verify→deploy for one feature | Proves the full loop works |
| 14 | **Promptfoo eval pipeline** | Automated command quality scoring | Testing dimension 3→7 |
| 15 | **Auto-memory for agents** | Agents write findings to memory automatically | Knowledge persists without manual saves |

---

## The Single Highest-Impact Insight

**The spec-code linker + test scaffolder combination** is the most leveraged upgrade. Together they close the loop:

```
Spec exists → Tests generated from acceptance criteria → Code passes tests → Spec marked as implemented
```

This is what makes spec-first *real* instead of aspirational. It converts gOS from a system that *writes* specs into a system that *enforces* them.

---

## Late-Breaking Findings (Frontier Agent)

### Claude Managed Agents — Launched April 8, 2026 (yesterday)

Anthropic's hosted infrastructure for production agents. $0.08/session-hour on top of token costs. Decouples "brain" (stateless, scales horizontally) from "hands" (sandboxed execution containers). Session is an append-only event log stored externally — the persistent memory layer. Multi-agent coordination is in "research preview."

**Implication for gOS:** Claws (persistent scheduled agents) should migrate to Managed Agents once multi-agent coordination exits preview. This eliminates the "session dies when context fills" problem.

### Kiro IDE — The Best Implemented Spec-First System

AWS's Kiro (GA November 2025) has three-document spec structure: **Requirements** (acceptance criteria) → **Design** (architecture, data models) → **Tasks** (sequenced steps). Hard gates between phases — AI cannot proceed without human approval of the previous document. Plus: **Steering files** (project-level context encoding) and **Hooks** (event-driven automations).

**Direct mapping to gOS:** `/think` = Requirements, `/design` = Design, `/build` = Tasks. The missing piece is the hard gate. Kiro proves hard gates reduce rework.

### Anthropic's Own Multi-Agent Research System — 90.2% Quality Improvement

Key lessons from Anthropic's internal system (orchestrator + 3-5 parallel subagents):
1. Decompose by **independence of work**, not type — "feature agent + test agent + review agent" creates blocking dependencies
2. Save research plan to external memory **before** context fills
3. Prompt quality and tool description quality dominate performance, not architecture
4. Extended thinking helps at every agent level

### Actor-Aware Memory (Mem0, 2026)

Tag every stored fact with which agent produced it. Prevents one agent's inference from being treated as ground truth by downstream agents. Mem0: 66.9% accuracy, 91% lower latency, 90% fewer tokens vs full-context.

**Implication for gOS:** evolve_signals.md should tag which agent produced each finding. Memory files should track provenance.

### Handoff Schema Pattern (OpenAI Swarm)

Every handoff between agents/phases is explicit and carries its own context. No "telepathy" between commands. Each verb output should have a defined artifact schema that the next verb reads as its input brief.

---

### Tools Agent — Critical Gaps Found

**6 core build-squad agents were NOT installed globally.** Researcher, designer, engineer, reviewer, verifier, aidesigner-frontend only existed in the gOS source repo. Every Arx/AW session spawning these silently fell back to generic agents. **FIXED:** All 6 now installed to `~/.claude/agents/` (18 total).

**MCP gaps (prioritized):**

| Gap | Severity | Fix |
|-----|----------|-----|
| No neural/semantic research (Exa) | HIGH | Add `exa-mcp-server` — neural search with date filtering, paper citations |
| GitHub MCP disabled in Arx | HIGH | OAuth broken; use `gh` CLI via Bash as workaround |
| No shared agent memory store | HIGH | Add `@modelcontextprotocol/server-memory` (Knowledge Graph) for cross-agent state |
| No gOS .mcp.json | MEDIUM | gOS project has no MCP config — agents can't do spec-rag in gOS context |
| cerebrus-pulse-mcp missing | MEDIUM | Technical analysis layer for Hyperliquid (RSI, EMAs, funding rates, sentiment) |
| Agent Teams not configured | MEDIUM | Claude Code v2.1.19+ supports peer-to-peer agent messaging; gOS uses older parent→child pattern |

**What's already strong:** Figma (17 tools), Vercel (12 tools), Linear (30 tools), Claude Preview, Playwright, custom spec-RAG, custom sources-MCP, custom Hyperliquid MCP, 5 financial plugins, 9 hook scripts. The toolkit breadth is impressive — the gap is in the glue between agents.

---

## Revised Upgrade Plan (incorporating frontier + tools findings)

### Immediate (fix what's broken + adopt proven patterns)

1. **Fix spec-compliance.sh** — broken hook, 30-min fix
2. **Add hard phase gates** (Kiro pattern) — `/think` output must be approved before `/design` starts, `/design` before `/build`
3. **Define handoff schemas** — each command's output artifact has a typed schema the next command reads
4. **Context budget monitor** — auto-dispatch to fresh agent before context exhaustion

### Near-term (close the verification gap)

5. **Spec↔code coverage matrix** — add to `/gos status`
6. **Test scaffolder from spec acceptance criteria** — auto-generate RED tests from specs
7. **Actor-aware evolve signals** — tag which agent/command produced each finding
8. **Steering.md per project** — separate from CLAUDE.md (identity) vs steering (project conventions)

### Medium-term (multi-agent architecture)

9. **Named SDK subagents per command** — spec-writer (no code tools), researcher (WebSearch), reviewer (read-only), coder (edit tools). Tool restrictions enforced at SDK level.
10. **Migrate claws to Managed Agents** — when multi-agent coordination exits preview
11. **Spec freshness scheduled agent** — auto-scan for staleness, broken cross-references

---

## Sources

- [GitHub Spec Kit](https://github.blog/ai-and-ml/generative-ai/spec-driven-development-with-ai-get-started-with-a-new-open-source-toolkit/)
- [Kiro — Agentic AI Development](https://kiro.dev/)
- [Thoughtworks: Spec-Driven Development](https://www.thoughtworks.com/en-us/insights/blog/agile-engineering-practices/spec-driven-development-unpacking-2025-new-engineering-practices)
- [Addy Osmani: How to Write a Good Spec for AI Agents](https://addyosmani.com/blog/good-spec/)
- [Claude Agent SDK Overview](https://platform.claude.com/docs/en/agent-sdk/overview)
- [Claude Agent Teams](https://code.claude.com/docs/en/agent-teams)
- [Claude Memory Tool](https://platform.claude.com/docs/en/agents-and-tools/tool-use/memory-tool)
- [Multi-Agent Frameworks Comparison 2026](https://gurusup.com/blog/best-multi-agent-frameworks-2026)
- [Augment Code: Spec-Driven Development Tools](https://www.augmentcode.com/tools/best-spec-driven-development-tools)
- [Claude Managed Agents Launch](https://claude.com/blog/claude-managed-agents)
- [Anthropic: Managed Agents Engineering](https://www.anthropic.com/engineering/managed-agents)
- [Anthropic: Multi-Agent Research System](https://www.anthropic.com/engineering/multi-agent-research-system)
- [Kiro IDE](https://kiro.dev/blog/introducing-kiro/)
- [Mem0: State of AI Agent Memory 2026](https://mem0.ai/blog/state-of-ai-agent-memory-2026)

---

**CONFIDENCE: High** — grounded in 38 source searches across 3 parallel research agents, actual project data (339 Arx specs, 110 code files, 5 tests, evolve signals), and gOS self-score (6.6/10).
