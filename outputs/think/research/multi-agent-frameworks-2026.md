# Multi-Agent AI Frameworks — Frontier Research
**Date:** April 2026  
**Question:** What is the state of multi-agent AI frameworks, and what patterns should gOS adopt to become a true spec-first multi-agent co-creator?

---

## Finding 1 — Claude Agent SDK (formerly Claude Code SDK)

**What it is:** Anthropic renamed "Claude Code SDK" to "Claude Agent SDK." It gives you the same tools, agent loop, and context management that power Claude Code, programmable in Python and TypeScript via `claude_agent_sdk` / `@anthropic-ai/claude-agent-sdk`.
Source: https://code.claude.com/docs/en/agent-sdk/overview

**Core orchestration patterns:**

| Pattern | How | Best for |
|---|---|---|
| **Subagents** | `agents={"name": AgentDefinition(...)}` + Agent tool | Parallel specialist work |
| **Sessions** | `resume=session_id` | Context continuity across multi-turn tasks |
| **Hooks** | PreToolUse, PostToolUse, Stop, SessionStart/End | Guardrails, audit, enforce workflows |
| **MCP** | `mcp_servers={...}` | External tool delegation |
| **Permissions** | `allowed_tools=[...]` | Sandbox enforcement |

**Key capability: Subagent definitions in code.** You define named agents with custom prompts, tool access, and model selection programmatically. The orchestrator spawns them via tool calls.

```python
options=ClaudeAgentOptions(
    allowed_tools=["Read", "Glob", "Grep", "Agent"],
    agents={
        "spec-writer": AgentDefinition(
            description="Writes PRDs and technical specs before code.",
            prompt="You write specs. Never write code. Output markdown.",
            tools=["Read", "WebSearch", "Write"],
        ),
        "code-reviewer": AgentDefinition(
            description="Reviews code against spec.",
            tools=["Read", "Glob", "Grep"],
        )
    }
)
```

**Memory tool:** Client-side filesystem (`/memories` directory). Claude creates/reads/updates files. Full control over storage. Not cross-agent by default — shared directory can make it cross-agent.
Source: https://platform.claude.com/docs/en/agents-and-tools/tool-use/memory-tool

**CLAUDE.md / Skills / Hooks integration:** Setting `setting_sources=["project"]` gives SDK agents access to all gOS filesystem-based configuration (CLAUDE.md, skills, slash commands, hooks).
Source: https://code.claude.com/docs/en/agent-sdk/overview

---

## Finding 2 — Claude Managed Agents (BRAND NEW — April 8-9, 2026)

**What it is:** Anthropic launched Claude Managed Agents in public beta this week. It decouples the "brain" (Claude + harness) from the "hands" (sandboxed execution environments), runs on Anthropic's infrastructure, and manages orchestration, checkpointing, credential management, and tracing.

**Pricing:** Standard token rates + $0.08/session-hour.
Source: https://claude.com/blog/claude-managed-agents
Source: https://siliconangle.com/2026/04/08/anthropic-launches-claude-managed-agents-speed-ai-agent-development/

**Architecture:** Three decoupled, durable components:
1. **Session (State)** — append-only event log stored externally; survives disconnections
2. **Harness (Logic)** — stateless, horizontally scalable; 60% reduction in time-to-first-token at p50
3. **Sandbox (Execution)** — containers, callable via `execute(name, input) → string`

**Multi-agent coordination:** Agents can spin up and direct other agents (research preview, requires access request). "Brains can pass hands to one another" — because harnesses are stateless, one agent's execution environment can be handed to another.
Source: https://www.anthropic.com/engineering/managed-agents

**Key design insight — external session log as memory:** The session log is the persistent context. `getEvents()` allows flexible retrieval — pick up where work stopped, rewind, or reread specific sequences. Context transformations happen in the harness before delivery to Claude.

---

## Finding 3 — Anthropic's Own Multi-Agent Research System

**Built with:** Orchestrator-worker pattern. Lead agent + 3-5 parallel subagents.

**Result:** 90.2% performance improvement on complex research tasks vs. single-agent. 15x more tokens consumed. ~90% research time reduction for complex queries.
Source: https://www.anthropic.com/engineering/multi-agent-research-system

**Critical lessons:**

1. **Decompose context-centrically, not problem-centrically.** "One agent writes features, another writes tests" creates constant coordination overhead. Instead: divide by independence of work, not type of work.

2. **External memory before context overflow.** Lead agent saves research plan to external memory before context window fills (200K token limit). Spawn fresh subagents with clean context + handoffs to maintain continuity.

3. **Tool design determines path quality.** Poor tool descriptions send agents "down completely wrong paths." Each tool needs distinct purpose, clear documentation. This applies directly to gOS commands.

4. **Extended thinking improves reasoning at every level.** Both orchestrators and subagents benefit from explicit thinking modes with interleaved thinking after tool results.

5. **Rainbow deployments for state management.** "Minor changes cascade into large behavioral changes." Production multi-agent systems need checkpoint systems and graceful rollout.

---

## Finding 4 — Framework Comparison (LangGraph / CrewAI / AutoGen / OpenAI Swarm)

Sources: 
- https://medium.com/data-science-collective/langgraph-vs-crewai-vs-autogen-which-agent-framework-should-you-actually-use-in-2026-b8b2c84f1229
- https://gurusup.com/blog/best-multi-agent-frameworks-2026
- https://o-mega.ai/articles/langgraph-vs-crewai-vs-autogen-top-10-agent-frameworks-2026

| Framework | Orchestration model | State/memory | Best for | Avoid when |
|---|---|---|---|---|
| **LangGraph** | Directed graph, conditional edges | Built-in checkpointing + time travel, thread-scoped | Deterministic, spec-driven, complex state workflows | Simple crews, quick prototypes |
| **CrewAI** | Role-based crews, sequential or parallel | Sequential task output passing | Fast setup, business workflow automation | Fine-grained state control needed |
| **AutoGen/AG2** | GroupChat, conversational | In-memory by default, external optional | Debate/consensus, dynamic interaction patterns | Deterministic workflows |
| **OpenAI Swarm → Agents SDK** | Handoffs + routines | Stateless, context in messages | Lightweight, transparent control flow | Complex state, long-running tasks |

**For gOS specifically:** LangGraph's explicit state management maps most cleanly to gOS's verb pipeline (think → design → build → review → ship). Each verb is a node with conditional edges. State flows downward. But gOS runs on Claude Code, not LangChain — so the patterns are relevant but don't require LangGraph itself.

**OpenAI Swarm pattern (now production Agents SDK):** The handoff primitive is elegant — `transfer_to_XXX(context)` — because it forces every handoff to be explicit and carry its own context. No hidden state. This is worth adopting as a gOS convention.

---

## Finding 5 — Windsurf, Cursor, Devin, Kiro — Coding Assistant Patterns

Sources:
- https://www.nxcode.io/resources/news/windsurf-vs-cursor-2026-ai-ide-comparison
- https://kiro.dev/blog/introducing-kiro/
- https://dev.to/alizgheib/kiro-from-steering-docs-to-specs-to-hooks-an-agentic-ide-walkthrough-3nbf

**Windsurf (acquired by Cognition/Devin, July 2025):**
- Pioneered "Cascade" — multi-step agentic flow across files with error recovery
- Wave 13 added: **Plan Mode** (separate planning from code generation), **Parallel Multi-Agent Sessions**, Arena Mode (blind model comparison)
- SWE-1.5 model: 13x faster than Sonnet 4.5, approaches Claude 4.5 coding benchmark performance

**Kiro (AWS, launched July 2025, GA November 2025) — most spec-first IDE:**
Five-pillar approach:
1. **Specs** — Requirements doc (acceptance criteria) + Design doc (architecture) + Task list (sequenced steps). AI generates all three from a vibe description. Human reviews before proceeding.
2. **Steering files** — Project-level context files encoding conventions, architecture decisions, preferred tools. Durable across all sessions.
3. **Hooks** — Event-driven automations: file save → run spec check, pre-task → validate against requirements, post-tool → linting. Created via natural language or config form.
4. **Autonomy Modes** — Fully supervised → autopilot spectrum.
5. **MCP** — Extensible tool ecosystem.
Source: https://kiro.dev/docs/hooks/
Source: https://repost.aws/articles/AROjWKtr5RTjy6T2HbFJD_Mw/

**Key pattern from Kiro:** Specs are structured into three documents — Requirements, Design, Tasks — each with validation gates before proceeding to the next. This directly maps to gOS's `/think` → `/design` → `/build` sequence.

**Cursor / Claude Code comparison:** Claude Code leads on agentic completions for large codebases. Cursor leads on IDE UX. Both converging toward autonomous multi-agent sessions.
Source: https://www.nxcode.io/resources/news/cursor-vs-windsurf-vs-claude-code-2026

---

## Finding 6 — Spec-First Development: Evidence and Patterns

Sources:
- https://github.blog/ai-and-ml/generative-ai/spec-driven-development-with-ai-get-started-with-a-new-open-source-toolkit/
- https://www.thoughtworks.com/en-us/insights/blog/agile-engineering-practices/spec-driven-development-unpacking-2025-new-engineering-practices
- https://developers.redhat.com/articles/2025/10/22/how-spec-driven-development-improves-ai-coding-quality
- https://addyosmani.com/blog/good-spec/

**What is Spec-Driven Development (SDD)?**
Intent → Spec → Plan → Implementation. AI agents write and validate specifications before writing code. Human reviews and approves each phase before the next begins.

**GitHub Spec Kit four phases:**
1. **Specify** — User journeys + outcomes. AI fleshes out what and why.
2. **Plan** — Architectural constraints, tech stack. AI generates technical implementation plan.
3. **Tasks** — Small, reviewable work units AI validates independently.
4. **Implement** — AI tackles tasks, human verifies each output before proceeding.

**Evidence for spec-first producing better outcomes:**
- SonarQube analysis: vibe-coded AI output has 0.38–0.62 vulnerabilities per 1,000 lines, >70% BLOCKER severity. Spec-driven reduces this class by catching system-level defects before coding.
- Organizations report 50-80% implementation time reduction for well-specified features (source: Augment Code — vendor, directional not verified)
- Spec-first eliminates AI guesswork: "Language models excel at pattern completion but struggle with ambiguous instructions" — clear specs are "unambiguous instructions."

**AGENTS.md standard (cross-platform):** Google, OpenAI, Factory, Sourcegraph, Cursor jointly launched a vendor-neutral markdown file format in late 2025 for encoding agent instructions, conventions, and constraints. Designed to replace fragmented tool-specific formats.
Source: https://developer.microsoft.com/blog/spec-driven-development-spec-kit

**Kiro's enforcement mechanism:** Gates between spec phases. AI cannot proceed from Requirements to Design without human approval. Design cannot proceed to Tasks without review. This is the key enforcement pattern.

---

## Finding 7 — Agent Memory and Context Sharing

Sources:
- https://mem0.ai/blog/state-of-ai-agent-memory-2026
- https://arxiv.org/abs/2504.19413
- https://atlan.com/know/best-ai-agent-memory-frameworks-2026/
- https://arxiv.org/html/2603.10062v1

**The winner in 2026:** Selective memory (Mem0 architecture) outperforms full-context approaches.
- Mem0: 66.9% accuracy, 91% lower p95 latency (1.44s vs 17.12s), 90% fewer tokens vs full-context.
- Graph-enhanced (Mem0g): 68.4% accuracy at minimal latency cost.
- Production viability test: "A system that scores well on accuracy but requires 26,000 tokens per query is not production-viable."

**Memory tier model (Letta/MemGPT — now production):**
| Tier | Analogy | What |
|---|---|---|
| Core memory | RAM | Always in-context |
| Archival memory | Disk | External searchable vector store |
| Recall memory | Cache | Conversation history |

**Four-scope model for multi-agent memory (Mem0):**
- `user_id` — individual identity
- `agent_id` — which agent stored this
- `run_id` / `session_id` — per-session scope
- `app_id` / `org_id` — project/org-wide scope

**Actor-aware memory (June 2025):** Tags stored facts with their source agent. Prevents one agent's inference from being treated as ground truth by downstream agents. "A real failure mode in multi-agent architectures."

**LangGraph checkpointing:** Thread-scoped checkpoints for short-term state. Long-term memory saved in custom namespaces, survives restarts. Reducer logic for state merging across concurrent agents.
Source: https://docs.langchain.com/oss/python/langgraph/memory

**Key remaining challenges:**
- Memory staleness at scale
- Cross-session identity resolution
- Application-specific evaluation beyond generic benchmarks
- Multi-agent memory consistency (the "most pressing open challenge")

---

## Patterns Worth Adopting for gOS

### 1. Structured handoff protocol between gOS verbs
Every gOS verb should produce an artifact with a defined handoff schema. `/think` outputs a spec artifact → `/design` reads that artifact as its brief → `/build` reads both. Explicit context passing, no hidden state. Inspired by OpenAI Swarm handoff pattern.

### 2. Phase gates with human approval (Kiro model)
Between `/think` → `/design`: present spec, require "promote to specs/" before proceeding.  
Between `/design` → `/build`: present build card, require "looks good" before coding.  
Currently gOS has convergence loops but no hard gates. Kiro proves gates meaningfully reduce rework.

### 3. Actor-aware memory in gOS evolve signals
When multiple agents contribute to a research output, tag each finding with `agent_id` (which agent found it). Prevents synthesized conclusions from being overwritten by later inference. Apply to `memory/evolve_audit_*.md`.

### 4. Context-centric task decomposition (Anthropic's lesson)
When spawning parallel agents in `/think research`, divide by independence of sources, not by type of analysis. Don't have "one agent does market, another does tech" if they'll need each other's outputs mid-run. Have each agent operate on fully independent inputs.

### 5. Steering files as a first-class gOS concept
Kiro's "steering files" = gOS's CLAUDE.md + skills. But Kiro makes them project-level AND explicitly versioned in spec artifacts. Each project should have a `steering.md` encoding its conventions, architecture decisions, and domain context. This is different from CLAUDE.md (which is identity/behavior) — steering is project-specific knowledge.

### 6. Pre-spec agent before every /build invocation
The Claude Agent SDK subagent pattern makes it trivial to enforce "spec-writer runs before code-writer." Define a named `spec-writer` agent in the SDK options for `/build` that must produce a task breakdown before any code tools are enabled. This enforces spec-first at the SDK level, not just via convention.

### 7. Selective memory over full-context
gOS's current scratchpad pattern (full-context bridging) is correct for single-agent sessions. For multi-agent swarms, switch to selective memory (Mem0 pattern): extract salient facts, store with scope tags, retrieve via query. The 91% latency reduction and 90% token savings are substantial.

### 8. Claude Managed Agents for production claws
The $0.08/session-hour managed agents platform is now live. gOS claws (persistent scheduled agents) are a natural fit. Instead of running claw scripts locally via `mcp__scheduled-tasks`, migrate to Managed Agents for production-grade checkpointing and error recovery.

---

## Competitive Landscape Summary

| Tool/Framework | Spec-first | Multi-agent | Memory | Best for gOS? |
|---|---|---|---|---|
| Claude Agent SDK | Via subagent definitions | Yes (subagents + teams) | Filesystem + tool | Core runtime — yes |
| Claude Managed Agents | Via session log | Research preview | Session event log | Claws/production — yes |
| Kiro IDE | Best-in-class | Via hooks/automation | Steering files | Pattern inspiration |
| LangGraph | Explicit state graphs | Yes, checkpointed | Thread + namespace | Pattern inspiration |
| CrewAI | Weak | Role crews | Sequential passing | No |
| AutoGen/AG2 | Weak | GroupChat | In-memory | No |
| OpenAI Swarm/Agents | Via routines | Via handoffs | Stateless | Handoff pattern only |
| Mem0 | N/A | Multi-scope tagging | Yes — best-in-class | Memory layer for claws |

---

## Open Questions

1. Claude Managed Agents multi-agent coordination is "research preview" — what is the waitlist status and timeline to GA?
2. Does gOS need an explicit steering.md protocol, or does the current CLAUDE.md + L0/L1/L2 memory serve the same function?
3. Should `/build` hard-gate on spec promotion from `/think`? Or keep as soft convention?
4. Is Mem0 worth adding as a dependency for claws memory, or is the filesystem `/memories` approach sufficient at current scale?

---

*Promote to specs? This research warrants promoting the "Patterns Worth Adopting" section to a new spec: `specs/gOS_multi-agent-evolution.md`*
