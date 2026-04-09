# Claude Managed Agents — Deep Research for gOS Integration

**Date:** 2026-04-09
**Status:** Research complete. Promote to `specs/` when integration decisions are finalized.
**Confidence:** HIGH — sourced directly from official Anthropic docs + launch blog + pricing pages

---

## 1. What It Is

Claude Managed Agents (launched April 8, 2026, public beta) is Anthropic's cloud-hosted agent infrastructure. It sits one layer above the Messages API: instead of building your own agent loop, tool execution, and runtime, you get a fully managed environment where Claude autonomously reads files, runs commands, browses the web, and executes code inside a secure container.

The positioning statement: **"From prototype to launch in days rather than months."**

Early adopters: Notion, Rakuten, Asana, Vibecode, Sentry.

---

## 2. Core Architecture: Four Concepts

| Concept | What It Is |
|---------|------------|
| **Agent** | Versioned configuration: model + system prompt + tools + MCP servers + skills. Created once, referenced by ID across sessions. |
| **Environment** | Cloud container template: packages (Python, Node, Go, etc.), network access rules, mounted files. |
| **Session** | A running agent instance within an environment. Performs a specific task. Has its own event stream. |
| **Events** | The communication protocol: user turns, tool results, status updates. Persisted server-side. Streamable via SSE. |

**How it works:**
1. Create an Agent (reusable definition)
2. Create an Environment (container config)
3. Start a Session (Agent + Environment + task)
4. Send events → stream responses via SSE
5. Steer or interrupt mid-execution

Sessions are **stateful**: persistent filesystem + conversation history across interactions within a session.

---

## 3. Programming Model

### CLI (new `ant` tool)
```bash
brew install anthropics/tap/ant
ant beta:agents create --name "..." --model ... --system "..."
ant beta:sessions create --agent "$AGENT_ID" --environment "$ENV_ID"
ant beta:sessions:events send --session-id "$SESSION_ID" --event "..."
```

### Python SDK
```python
from anthropic import Anthropic
client = Anthropic()

agent = client.beta.agents.create(
    name="Spec Enforcer",
    model="claude-sonnet-4-6",
    system="...",
    tools=[{"type": "agent_toolset_20260401"}],
)

session = client.beta.sessions.create(
    agent=agent.id,
    environment_id=environment.id,
)

with client.beta.sessions.events.stream(session.id) as stream:
    client.beta.sessions.events.send(session.id, events=[{
        "type": "user.message",
        "content": [{"type": "text", "text": "Run spec drift check..."}]
    }])
    for event in stream:
        ...
```

### All supported SDKs
Python, TypeScript, Java, Go, C#, Ruby, PHP. Beta header required: `managed-agents-2026-04-01`.

### REST API
All endpoints at `https://api.anthropic.com/v1/` — `agents`, `environments`, `sessions`, `memory_stores`.

---

## 4. Session Event Log Model

Sessions communicate via **Server-Sent Events (SSE)**. Event types:

| Event | Meaning |
|-------|---------|
| `agent.message` | Claude's text response |
| `agent.tool_use` | Claude invoked a tool |
| `user.message` | You sent a message |
| `user.tool_confirmation` | You approved/denied a tool call |
| `user.custom_tool_result` | You returned a custom tool result |
| `session.status_idle` | Agent finished, waiting |
| `session.thread_created` | (Multi-agent) coordinator spawned a subagent |
| `session.thread_idle` | (Multi-agent) a subagent thread finished |
| `agent.thread_message_sent` | (Multi-agent) agent-to-agent message |
| `agent.thread_message_received` | (Multi-agent) agent received delegation |

**Key property:** Event history is **persisted server-side** and can be fetched at any time. Sessions are auditable.

---

## 5. Built-In Tools

All enabled by default via `{"type": "agent_toolset_20260401"}`. Can be selectively disabled.

| Tool | Name | What it does |
|------|------|-------------|
| Bash | `bash` | Execute shell commands in the container |
| Read | `read` | Read files from the container filesystem |
| Write | `write` | Write files to the container filesystem |
| Edit | `edit` | String replacement in files |
| Glob | `glob` | File pattern matching |
| Grep | `grep` | Regex text search across files |
| Web Fetch | `web_fetch` | Fetch and parse URL content |
| Web Search | `web_search` | Search the web |

Custom tools also supported — you define the schema, your code executes them, you send results back via events. The agent never executes custom tools itself.

---

## 6. Multi-Agent Coordination (Research Preview)

**Status:** Research preview — must request access.

**Architecture:** All agents in a multi-agent session share the same **container and filesystem**, but each runs in its own **session thread** with isolated context/conversation history.

- **Primary thread** = session-level event stream (coordinator's view)
- **Sub-threads** = each callable agent's isolated event stream

**Delegation model:**
- Coordinator declares `callable_agents` at agent-creation time (by agent ID + version)
- When coordinator decides to delegate, it spawns a thread for the called agent
- Sub-agent has its own model, system prompt, tools, MCP servers
- **Critical constraint:** Only one level of delegation — sub-agents cannot call other agents

**Thread persistence:** Coordinator can re-contact a sub-agent later; that sub-agent retains its prior context.

**Python example:**
```python
orchestrator = client.beta.agents.create(
    name="Engineering Lead",
    callable_agents=[
        {"type": "agent", "id": reviewer_agent.id, "version": reviewer_agent.version},
        {"type": "agent", "id": test_writer_agent.id, "version": test_writer_agent.version},
    ],
    ...
)
```

---

## 7. Memory / Persistence (Research Preview)

**Status:** Research preview — must request access.

### Memory Stores
A **memory store** is a workspace-scoped collection of text documents. When attached to a session, the agent automatically reads stores before starting a task and writes durable learnings when done — **no additional prompting needed**.

Key properties:
- Individual memories capped at **100KB / ~25K tokens**
- Design as many small focused files (not few large ones)
- Up to **8 memory stores per session**
- Access: `read_write` or `read_only`
- Full versioning: every mutation creates an immutable `memver_...` record
- Can be seeded with content before any agent runs

**Memory tools (auto-granted when store is attached):**

| Tool | Description |
|------|-------------|
| `memory_list` | List memories, optionally filtered by path prefix |
| `memory_search` | Full-text search across memory contents |
| `memory_read` | Read a memory's contents |
| `memory_write` | Create or overwrite a memory at a path |
| `memory_edit` | Modify an existing memory |
| `memory_delete` | Remove a memory |

**Optimistic concurrency:** Writes support `precondition` (type: `not_exists` or `content_sha256`) to prevent clobbers.

**Audit / rollback:** Memory versions support retrieval, inspection, and **redaction** (for compliance/PII removal). The audit trail (who changed what, when) is always preserved.

---

## 8. Pricing

| Component | Cost |
|-----------|------|
| **Runtime fee** | **$0.08 per session-hour** (active execution only — idle time does not count) |
| **Token costs** | Standard Claude API rates (identical to direct API usage) |
| **Web search** | $10 per 1,000 searches |

**Practical examples:**
- Agent processing tickets, ~20 min active per ticket: ~$0.027 runtime/ticket + $0.10–0.50 tokens
- Always-on 24/7 agent: ~$58/month in runtime alone (before tokens)

**Rate limits:**
- Create endpoints (agents, sessions, environments): 60 req/min per org
- Read endpoints (retrieve, list, stream): 600 req/min per org
- Organization spend limits and tier-based limits also apply

---

## 9. Comparison Table

| Dimension | Claude Managed Agents | Claude Agent SDK | Claude Code Subagents | Claude Code Scheduled Tasks | OpenAI Codex |
|-----------|----------------------|-----------------|----------------------|----------------------------|--------------|
| **Execution location** | Cloud (Anthropic-managed containers) | Local (your machine / your server) | Local (within Claude Code session) | Local (device must be awake) | Cloud (OpenAI-managed) |
| **Persistence** | Sessions persist server-side; memory stores survive across sessions (research preview) | Session state via resume ID; no native memory | In-session only; no cross-session state | Per-schedule; no memory | Cloud-native; context per PR task |
| **Agent loop** | Fully managed by Anthropic | Managed by SDK (same loop that powers Claude Code) | Managed by Claude Code | Claude Code process | Fully managed by OpenAI |
| **Tools** | Full toolset (bash, files, web) + MCP + custom | Same toolset + hooks + MCP + full OS access | Inherited from parent session + specialized prompt | Same as Claude Code | Bash, files, web — GitHub-integrated |
| **Multi-agent** | Yes, via `callable_agents` + session threads (research preview) | Yes, via `AgentDefinition` + Agent tool call | Yes, inline subagent delegation | No | Parallel tasks across containers |
| **Scheduling / triggers** | "Outcomes" (research preview, not yet documented publicly) | External cron → SDK call | External cron → CLI | Built-in `/schedule` or `/loop` skill | Not applicable (task-based) |
| **Memory across sessions** | Memory stores (research preview) | None native (you implement) | None | None | None |
| **Infrastructure burden** | Zero | You manage deployment | Zero (in-session) | You manage machine uptime | Zero |
| **Cost model** | Tokens + $0.08/hr runtime | Tokens only (you pay compute separately) | Tokens only | Tokens only | Value-based / subscription |
| **Model lock-in** | Claude only | Claude only (Bedrock/Vertex/Azure options) | Claude only | Claude only | OpenAI only |
| **Audit / tracing** | Full event log, memory versions, execution tracing | Partial (hooks, custom logging) | Limited | Limited | PR-level audit |
| **Best for** | Long-running cloud tasks, asynchronous work, production scale | Custom agent loops, CI/CD pipelines, fine-grained control | Focused subtasks within interactive sessions | Recurring reminders, scheduled context | Batch coding tasks, PR generation at scale |

---

## 10. gOS-Specific Evaluation

### 10.1 Persistent Claws (spec-drift, market-regime, source-monitor)

**Current state:** gOS claws are defined as `.md` files in `gOS/claws/`. They have no native execution infrastructure — they depend on Claude Code hooks (PostToolUse, cron via `/schedule` skill) or manual invocation. The device must be awake.

**What Managed Agents offers:**
- Cloud-hosted execution — claws run even when your Mac is off
- Memory stores (research preview) can replace `state.json` files with persistent, versioned, auditable memory
- Session threads could allow multiple claws to run in parallel under a coordinator

**Verdict for claws: HIGH FIT** — but memory stores are still in research preview (requires access request). In the interim, Managed Agents can run claws triggered externally (scheduled Lambda, GitHub Actions, or wait for "Outcomes" research preview).

**Migration path:**
1. Convert each claw's `claw.md` into a Managed Agent definition (system prompt from claw.md)
2. Convert `state.json` to a memory store (seeded with current state)
3. Trigger sessions via cron job (AWS EventBridge, GitHub Actions scheduled workflow, or wait for Outcomes)
4. Coordinator agent (gOS supervisor) can run all three claws in parallel as callable agents

### 10.2 Long-Running Orchestration (multi-hour research/build)

**Current problem:** Claude Code sessions hit context limits. `/gos` commands that span hours lose context at compaction. The scratchpad bridge is manual.

**What Managed Agents offers:**
- Sessions run for minutes or hours with multiple tool calls
- Built-in prompt caching + compaction handled by the harness (no manual scratchpad needed)
- SSE stream can be reconnected after disconnection — event history is server-side
- Memory stores allow learnings from one `/think` session to persist into the next `/build` session

**Verdict for long-running tasks: VERY HIGH FIT** — this is the primary use case Managed Agents was built for. The `/think`, `/build`, and `/simulate` commands are natural candidates for Managed Agent sessions where duration and context survival matter.

**Migration path:**
- `/think research` → Managed Agent session with web_search + web_fetch tools enabled, memory store for findings
- `/build` on complex features → Managed Agent session with full bash/file toolset, memory store for project conventions
- gOS conductor can spawn Managed Agent sessions and poll status asynchronously

### 10.3 Multi-Project Coordination (Arx AND Advance Wealth simultaneously)

**Current problem:** gOS has no mechanism to coordinate work across two project directories simultaneously. Each Claude Code session is bound to one working directory.

**What Managed Agents offers:**
- Multiple sessions can run simultaneously
- Each session gets its own container with its own filesystem
- A coordinator agent can spawn sub-agents for Arx work and Advance Wealth work in parallel
- Shared memory stores can hold cross-project context (e.g., Gary's preferences, global gOS conventions)

**Critical constraint:** Sub-agents cannot call other agents (only one level of delegation). So coordinator → Arx-agent + coordinator → AW-agent works, but Arx-agent cannot then delegate further.

**Verdict for multi-project coordination: HIGH FIT (research preview required)** — multi-agent is in research preview. Once available, a gOS coordinator agent could be the first gOS entity that has a genuine cross-project view.

**Architecture sketch:**
```
gOS Coordinator Agent
├── callable_agents: [arx_agent, advance_wealth_agent, dux_agent]
├── memory_stores: [gos_global_memory (read_only)]
└── session triggers: scheduled or event-driven

On trigger:
  → spawn arx_agent thread (reads Arx memory store, runs task)
  → spawn advance_wealth_agent thread (reads AW memory store, runs task)
  → aggregate results, write to coordinator memory store
```

### 10.4 Spec Enforcement (always-on code monitor)

**Current problem:** The spec-drift claw is event-triggered (PostToolUse on git commit), but only runs when Claude Code is active. There's no always-on cloud monitor.

**What Managed Agents offers:**
- An agent can be configured as a spec enforcer with read-only access to the container's code
- Memory store can hold the current spec state and known violations
- With Outcomes (research preview), you could define "spec compliance" as a success criterion and let the agent iterate
- Custom tool can call a webhook to notify when violations are found

**Verdict for spec enforcement: MEDIUM FIT NOW, HIGH FIT WITH OUTCOMES** — a spec-drift Managed Agent triggered on each push (via GitHub Actions webhook → Managed Agent session) is feasible today. The "always-on" aspect requires Outcomes (research preview) or external triggering infrastructure.

**Immediate implementation:**
```yaml
# GitHub Actions workflow
on: push
jobs:
  spec-drift:
    steps:
      - name: Trigger spec-drift Managed Agent
        run: |
          curl https://api.anthropic.com/v1/sessions \
            -H "anthropic-beta: managed-agents-2026-04-01" \
            -d '{"agent": "$SPEC_DRIFT_AGENT_ID", "environment_id": "$ENV_ID"}'
```

---

## 11. What's in Research Preview (Requires Access Request)

Three features require explicit access request at `https://claude.com/form/claude-managed-agents`:

1. **Outcomes** — self-evaluation and iteration loops; scheduled/triggered execution (not yet documented publicly)
2. **Multiagent** — coordinator + callable agents + session threads
3. **Memory** — memory stores with persistence across sessions

**Recommendation:** Request access immediately. The memory + multiagent combination is the most transformative for gOS.

---

## 12. What Does NOT Exist Yet

Based on research, these gaps exist as of April 2026:

- **No native cron/scheduling** in Managed Agents (Outcomes research preview may address this — docs not yet public)
- **No cross-session filesystem persistence** without memory stores (files in the container are ephemeral per session)
- **Single level of agent delegation only** — cannot build deep hierarchies
- **No Bedrock/Vertex support** for Managed Agents (Agent SDK supports these; Managed Agents is Anthropic-direct only)
- **Memory stores still in preview** — cannot rely on for production gOS patterns today

---

## 13. Recommended Migration Priority for gOS

| Pattern | Migrate Now? | Why |
|---------|-------------|-----|
| Long-running `/think research` + `/build` sessions | **Yes** | Core use case, fully available, major UX improvement |
| Claws with external trigger (GitHub Actions) | **Yes** | Eliminates device-awake dependency; state.json → memory store |
| Multi-project coordinator | **Request preview access, then yes** | Requires multiagent research preview |
| Memory-backed L2/L3 gOS memory | **Request preview access, then yes** | Replaces manual memory file management |
| Spec-drift claw on push | **Yes (external trigger)** | Feasible today with GitHub Actions webhook |
| Always-on persistent monitor | **Wait for Outcomes** | Research preview, not yet documented |

---

## 14. Key Risks

1. **Beta instability** — behaviors "may be refined between releases"; don't put blocking production workflows on unproven claws
2. **Cost at scale** — 24/7 always-on is $58+/month runtime before tokens; design for event-driven, not polling
3. **Research preview gating** — the most valuable features (memory, multiagent) require access approval; timeline unknown
4. **Claude-only lock-in** — cannot use Bedrock/Vertex with Managed Agents (unlike Agent SDK)
5. **One-level delegation limit** — gOS's hierarchical command structure (conductor → verbs → sub-agents) exceeds what multiagent supports today

---

## Sources

- [Managed Agents Overview — Anthropic Docs](https://platform.claude.com/docs/en/managed-agents/overview)
- [Managed Agents Quickstart — Anthropic Docs](https://platform.claude.com/docs/en/managed-agents/quickstart)
- [Multi-Agent Sessions — Anthropic Docs](https://platform.claude.com/docs/en/managed-agents/multi-agent)
- [Agent Memory — Anthropic Docs](https://platform.claude.com/docs/en/managed-agents/memory)
- [Tools Reference — Anthropic Docs](https://platform.claude.com/docs/en/managed-agents/tools)
- [Agent SDK Overview — Anthropic Code Docs](https://code.claude.com/docs/en/agent-sdk/overview)
- [Launch Blog Post — Claude](https://claude.com/blog/claude-managed-agents)
- [Pricing — FindSkill.ai](https://findskill.ai/blog/claude-managed-agents-explained/)
- [SiliconAngle Launch Coverage](https://siliconangle.com/2026/04/08/anthropic-launches-claude-managed-agents-speed-ai-agent-development/)
- [Codex vs Claude Code Comparison — Northflank](https://northflank.com/blog/claude-code-vs-openai-codex)
- [Agent SDK vs OpenAI Agents SDK — Composio](https://composio.dev/content/claude-agents-sdk-vs-openai-agents-sdk-vs-google-adk)
