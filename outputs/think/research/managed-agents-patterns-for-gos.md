# Claude Managed Agents — Extractable Patterns for gOS

**Date:** 2026-04-09
**Type:** Pattern hunt — what to absorb locally without migrating to Managed Agents infrastructure
**Confidence:** HIGH — sourced from Anthropic engineering blog, official docs, launch blog
**Cross-reference:** Supersedes analysis in `claude-managed-agents-gos.md` sections 10-13 with specific file-level changes

---

## Convergence Check (pre-synthesis)

Three sources consistently confirm the same architecture. No contradictions found. One nuance:
- The engineering blog confirms TTFT gains come from NOT provisioning containers at session start, not from the decoupling per se. The insight for gOS is: lazy initialization, not structural separation.
- Memory auto-read/auto-write is triggered by the presence of a memory store in `resources[]`, not by any explicit prompt. This is fully replicable locally with a Stop hook pattern.

---

## Pattern 1: Brain / Hands / Session Decoupling

**Source:** [Anthropic Engineering Blog](https://www.anthropic.com/engineering/managed-agents)

**What it is:** The LLM reasoning loop (Brain), the execution sandbox (Hands), and the context store (Session) are fully independent components. Each can fail and restart without corrupting the others.

- Brain = stateless; reconstructed from the session log on each resume
- Hands = ephemeral Linux containers, provisioned only on first tool call (not at session start)
- Session = append-only event log living outside both

**Performance result:** By not provisioning containers until the first tool call:
- p50 TTFT dropped ~60%
- p95 TTFT dropped >90%

**The insight that transfers to gOS:** The costly thing is initializing execution context eagerly. In gOS, the analogy is loading full L2 memory + specs + scratchpad on session start even when the task is simple.

**Local implementability:** YES — full pattern replicable in Claude Code

**gOS implementation: lazy context loading**

The current gOS pattern loads L0+L1 every session regardless of task. Apply the brain/hands split by deferring heavy context (L2, project specs) until the command determines it needs them.

File changes:
- `/Users/garyg/.claude/commands/gos.md` — Add: "On `/gos` entry, load only L0+L1. Each verb command loads its own L2 context on first use. Do not pre-load spec files until the command explicitly calls for them."
- `/Users/garyg/.claude/commands/think.md` — Add context loading step as Step 0: "Before spawning agents, load relevant spec context for the sub-command's domain."

**What only works with Managed Agents cloud infrastructure:** The actual container lazy-provisioning performance gain (60% TTFT reduction) is an infrastructure-level optimization. gOS can apply the principle (defer loading) but not replicate the infrastructure gain.

---

## Pattern 2: Append-Only Event Log for Session Persistence

**Source:** [Anthropic Engineering Blog](https://www.anthropic.com/engineering/managed-agents); [Agent SDK Sessions Docs](https://platform.claude.com/docs/en/agent-sdk/sessions)

**What it is:** Every thought, tool invocation, and observation is written durably to an append-only event log external to the harness. Key interfaces:
- `getEvents()` — retrieve positional slices of the event stream; can rewind, skip forward, or read from a specific point
- `emitEvent(id, event)` — durable write during agent loops; idempotent by event ID
- `wake(sessionId)` — restart harness from session state after crash
- `getSession(id)` — recover event log after failures

**Why it beats mutable state files:**
1. No lost state on crash — harness can crash, brain restarts from last logged event
2. Rewindable — can replay events before a specific moment
3. Auditable — full history always available
4. Concurrent-safe — append-only means no write conflicts

**Current gOS state:** `sessions/scratchpad.md` is a mutable state file. On context compaction, this is re-read. But it's overwritten, not appended. `sessions/evolve_signals.md` is append-only by convention — this already follows the pattern correctly.

**Local implementability:** YES — fully replicable with a structured append-only log file

**gOS implementation: structured session event log**

Replace scratchpad.md with a structured append-only event log. Each entry is timestamped, typed, and never deleted.

```
# sessions/event_log.md

## 2026-04-09T10:23:14 | think.research | STARTED
Topic: Claude Managed Agents patterns
Agents spawned: deep-researcher, competitor-crawler, cross-referencer

## 2026-04-09T10:25:41 | think.research | AGENT_COMPLETE
Agent: deep-researcher
Key finding: Brain/hands decoupling achieves 60% TTFT reduction

## 2026-04-09T10:26:02 | think.research | AGENT_COMPLETE
Agent: competitor-crawler
...

## 2026-04-09T10:31:00 | think.research | SYNTHESIS_COMPLETE
Output: outputs/think/research/managed-agents-patterns-for-gos.md
Signal: [pending]
```

File changes:
- Create `sessions/event_log.md` with append-only structure
- `/Users/garyg/.claude/commands/gos.md` — Add to "Session Management" section: "On resuming after compaction, read `sessions/event_log.md` (last 20 entries) instead of scratchpad.md. The event log is the canonical session state."
- Retire `sessions/scratchpad.md` as primary bridge; use it only for narrative summaries
- `sessions/evolve_signals.md` stays as-is — it already correctly implements append-only for signal data

**What only works with Managed Agents cloud infrastructure:** Server-side persistence (log survives machine restart), concurrent multi-user access, the `getEvents()` positional slice API, and `wake()` restart semantics.

---

## Pattern 3: Memory Store Auto-Read / Auto-Write

**Source:** [Anthropic Docs — Using agent memory](https://platform.claude.com/docs/en/managed-agents/memory)

**What it is:** When a memory store is attached to a session via `resources[]`, the agent **automatically** reads it before starting any task and **automatically** writes learnings when done — no prompting or configuration needed. The agent gains memory tools: `memory_list`, `memory_search`, `memory_read`, `memory_write`, `memory_edit`, `memory_delete`.

Key design decisions:
- Memories are path-addressed files (e.g., `/preferences/formatting.md`) — not key-value pairs
- Each memory is capped at 100KB (~25K tokens)
- Many small focused files > few large ones
- Every mutation creates an immutable version (audit + rollback)
- Optimistic concurrency via `content_sha256` preconditions
- Up to 8 stores per session with different access levels (read-only vs read-write)

**Current gOS state:** gOS has L0/L1/L2 memory files in `memory/`. They are manually managed — Claude reads them when instructed, writes when instructed. There is no automatic trigger at session start/end.

**Local implementability:** YES — the trigger mechanism is replicable with hooks

**gOS implementation: auto-read/auto-write memory hooks**

The auto-read trigger maps to a PreToolUse hook (on session start). The auto-write trigger maps to a Stop hook.

The Stop hook already exists partially (signal scan + memory update). Strengthen it:

1. **Auto-read on session start** — Add to the gOS system prompt or `gos.md`: "On every session start, before any command: read `memory/L0_identity.md` and `memory/L1_essential.md`. Search `memory/` for files relevant to the current task using grep on the topic."

2. **Auto-write on session end** — Codify the Stop hook to always write learnings. The current `gos.md` mentions signal capture but it's described as "silently assess." Make it explicit:

```
## Auto-Write Protocol (every session exit)
1. Scan the session for: new decisions, corrections received, patterns observed
2. Write to appropriate memory file:
   - Corrections → memory/feedback_{topic}.md
   - Project state changes → memory/project_{name}.md
   - User preferences → memory/user_gary_soul.md
   - Domain knowledge → memory/wiki/{topic}.md
3. Append signal to sessions/evolve_signals.md
4. Update L1_essential.md if current focus or active feedback rules changed
```

3. **Many-small-files principle** — gOS `memory/wiki/` already follows path-addressed structure. Apply this to L2: break large memory files into focused sub-files. E.g., don't have one `project_gos.md` — have `/project/gos/current_sprint.md`, `/project/gos/decisions.md`, `/project/gos/known_gaps.md`.

File changes:
- `/Users/garyg/.claude/CLAUDE.md` — Add to "Memory Architecture" section: "Memory files follow path-addressed structure (many small focused files). Auto-read L0+L1 on session start. Auto-write to relevant memory files on session exit via Stop hook."
- `/Users/garyg/.claude/commands/gos.md` — Formalize the Stop hook protocol as above

**What only works with Managed Agents cloud infrastructure:** API-based memory store (versioned, concurrent-safe, server-persisted), optimistic concurrency control, audit trail and redaction, cross-machine access to memories.

---

## Pattern 4: Structured Rubric-Based Self-Evaluation (Outcomes)

**Source:** [Anthropic Docs — Define outcomes](https://platform.claude.com/docs/en/managed-agents/define-outcomes)

**What it is:** The `user.define_outcome` event triggers a separate "grader" with its own isolated context window to evaluate the agent's output against a markdown rubric. The grader returns per-criterion pass/fail with specific gaps. The agent iterates until satisfied or until `max_iterations` (default 3, max 20) is hit.

Key mechanics:
- Grader is in a **separate context window** — cannot be influenced by the agent's own implementation choices (prevents sycophancy)
- Rubric is explicit, gradeable criteria: "The CSV contains a price column with numeric values" not "The data looks good"
- Evaluation states: `satisfied`, `needs_revision`, `max_iterations_reached`, `failed`, `interrupted`
- Multiple outcomes can be chained in sequence (send new `user.define_outcome` after previous completes)

**The insight:** The grader's isolation from the agent's context is the key innovation. A self-evaluating agent that shares context with its own work tends toward confirmation bias.

**Current gOS state:** `/evolve audit` runs health checks. `/review` is a separate command but invoked manually. The `/think` convergence loop cross-examines agents but uses the same session context. The `evals/` directory has rubrics but they're evaluated by the same agent that produced the work.

**Local implementability:** YES — 80% replicable using a separate sub-agent for evaluation

**gOS implementation: isolated grader pattern**

The key mechanism to replicate is **context isolation for the evaluator**. In Claude Code, this means spawning a fresh sub-agent for grading, not having the producing agent evaluate itself.

Apply to `/review` and the convergence loops in `/think` and `/build`:

```
# In commands/review.md — add "Isolated Grader" pattern:

## Grader Protocol
When reviewing any artifact:
1. Read the rubric FIRST (from evals/rubrics/ or task-specific criteria)
2. Spawn a fresh sub-agent for evaluation:
   Agent(
     prompt = "You are an isolated grader. You have NOT seen the implementation process.
               Read ONLY: [artifact path] and [rubric path].
               For each criterion: PASS or FAIL with specific evidence.
               Do not read the producing agent's reasoning or the session history.",
     subagent_type = "general-purpose",
     model = "sonnet",
     run_in_background = false
   )
3. Return per-criterion breakdown to the producing agent
4. If any FAILs: producing agent revises and re-submits (max 3 rounds)
```

Apply to `/think` convergence loop — the current cross-examination uses the same session. Spawn a dedicated fact-checker sub-agent instead.

Apply to `/build` verification — after implementation, spawn a grader sub-agent that reads only the spec and the output, not the build session history.

**Rubric-first habit:** Before any `/build` command, write the rubric first. The rubric lives in `evals/rubrics/{task}.md` and is the single source of truth for "done."

File changes:
- `/Users/garyg/.claude/commands/review.md` — Add Isolated Grader Protocol as above
- `/Users/garyg/.claude/commands/build.md` — Add: "Before implementing, write a rubric to `evals/rubrics/{feature}.md`. After implementing, run Isolated Grader against rubric. Max 3 revision cycles."
- `/Users/garyg/.claude/commands/think.md` — In convergence loop: replace "route disputed claims between agents" with "spawn isolated fact-checker sub-agent that reads only primary sources, not the session"

**What only works with Managed Agents cloud infrastructure:** The automated outcome harness, chaining outcomes in sequence, the `span.outcome_evaluation_*` event stream, infrastructure-managed iteration state.

---

## Pattern 5: Credential Vault + Proxy (Secure Tool Isolation)

**Source:** [Anthropic Engineering Blog](https://www.anthropic.com/engineering/managed-agents)

**What it is:** Two patterns to prevent credentials from entering the execution sandbox:

1. **Bundled auth:** Repository tokens are used during container initialization (clone + configure git remote). Subsequent `git push`/`pull` work without the agent touching tokens directly.
2. **Vault + proxy:** OAuth tokens live in a secure vault outside the sandbox. Tool calls route through a dedicated proxy that fetches credentials from the vault and makes the external service call. The harness/agent never sees the credential.

**Quote from engineering blog:** "The harness is never made aware of any credentials."

**Current gOS state:** gOS has no explicit credential management pattern. MCP servers handle their own credentials (e.g., Linear MCP, Gmail MCP have their own auth). The risk is that credentials leak into Claude's context through error messages, tool results, or debug output.

**Local implementability:** PARTIAL — the principle is replicable; a true vault+proxy requires infrastructure

**gOS implementation: credential hygiene rules**

The vault+proxy infrastructure isn't replicable locally without significant tooling. But the credential hygiene principle is:

1. **Never request credentials in-session.** MCP servers handle auth externally. If an MCP fails auth, stop and ask Gary to re-authenticate the MCP, never to paste credentials into the session.

2. **Environment variable convention.** Any credential needed by a hook script should be in `~/.claude/settings.json` as an env var reference, not hardcoded. Current settings.json already does this for `ANTHROPIC_API_KEY`.

3. **Audit hook outputs.** PostToolUse hook scripts should strip any output that matches credential patterns (API keys, tokens, passwords) before logging.

File changes:
- `/Users/garyg/.claude/rules/common/security.md` — Add: "Never request credentials in-session. If an MCP fails auth, halt and ask for MCP re-authentication. Credentials must never appear in session context, tool results, or log files."
- This is a rule addition, not a structural change

**What only works with Managed Agents cloud infrastructure:** The actual vault service, the MCP proxy infrastructure, container-level credential isolation.

---

## Pattern 6: Immutable Memory Versions (Audit + Rollback)

**Source:** [Anthropic Docs — Using agent memory](https://platform.claude.com/docs/en/managed-agents/memory)

**What it is:** Every mutation to a memory creates an immutable `memver_...` record. Operations: `created`, `modified`, `deleted`. The audit trail tracks which session and API key made each change. Content can be redacted from history (for PII compliance) while preserving the trail (who, when, what operation).

**The deeper insight:** Memory is treated like code — versioned, diffable, rollbackable. This means agents can be audited and corrected without losing history.

**Current gOS state:** gOS memory files are edited in place. Git history is the only audit trail. There's no rollback mechanism for individual memory files without a git revert.

**Local implementability:** YES — git already provides this; the pattern is to be intentional about it

**gOS implementation: memory-as-code convention**

Memory files should be treated like code: small commits, descriptive messages, never force-push.

1. **Every memory write is a git commit.** The Stop hook (or `/gos save`) should commit any changed `memory/` files with a message like `memory: update L1 — {1-line description of what changed}`.

2. **Prefer append to overwrite.** When adding a new feedback or lesson, append to the relevant file rather than rewriting it. The file grows; git history shows each addition.

3. **Archive instead of delete.** When a memory is no longer active (e.g., a project is complete), move it to `memory/archive/` rather than deleting. This mirrors the "redact but preserve audit trail" pattern.

File changes:
- `/Users/garyg/.claude/CLAUDE.md` — "Version Control" section already says "Archive instead of delete." Add: "Every memory write during session exit is committed as a separate commit with message `memory: {what changed}`."
- `/Users/garyg/.claude/commands/gos.md` — `/gos save` sub-command: add `git add memory/ && git commit -m "memory: session $(date +%Y-%m-%d) — {summary}"` as the final step

---

## Pattern 7: Path-Addressed Memory Structure (Many Small Files)

**Source:** [Anthropic Docs — Using agent memory](https://platform.claude.com/docs/en/managed-agents/memory)

**What it is:** Memories in a store are path-addressed (like a filesystem): `/preferences/formatting.md`, `/project/arx/conventions.md`, `/domain/hyperliquid/precision.md`. Individual memories capped at 100KB. The design guideline: "Structure memory as many small focused files, not a few large ones."

**Why it matters:** Small focused files allow targeted reads (load only what's relevant), targeted writes (update only what changed), and prevent one large file from monopolizing context.

**Current gOS state:** gOS memory is partially path-addressed:
- `memory/wiki/` follows this pattern correctly
- `memory/L1_essential.md` is a single 800-token limit file — good
- `memory/feedback_*.md` files are small and focused — good
- `memory/user_gary_soul.md` could become large over time

**Local implementability:** YES — no infrastructure changes needed, just organizational discipline

**gOS implementation: memory file size discipline**

1. **Enforce 100-line soft limit per memory file.** If a memory file exceeds 100 lines, split it. E.g., if `user_gary_soul.md` grows to 200 lines, split into `user_gary_preferences.md` + `user_gary_context.md` + `user_gary_decisions.md`.

2. **Path-address L2 memory.** Current L2 is a flat directory. Introduce subdirectories:
   ```
   memory/
   ├── L0_identity.md          (≤100 tok, static)
   ├── L1_essential.md         (≤800 tok, session-updated)
   ├── user/
   │   ├── gary_soul.md        (identity, values, style)
   │   └── gary_preferences.md (output format, tone, preferences)
   ├── project/
   │   ├── gos_sprint.md       (current focus)
   │   ├── arx_state.md        (Arx current state)
   │   └── mirofish_state.md   (MiroFish state)
   ├── feedback/               (existing feedback_*.md → here)
   ├── procedure/              (existing procedure_*.md → here)
   └── wiki/                   (existing wiki/ → stays)
   ```

3. **Update MEMORY.md index** when restructuring.

File changes:
- This is a reorganization, not a code change. Execute with `/evolve upgrade memory` after approval.
- Update `memory/MEMORY.md` index to reflect new structure

---

## What Only Works With Managed Agents Cloud Infrastructure (Cannot Replicate Locally)

| Feature | Why It Can't Be Replicated |
|---------|--------------------------|
| p50 TTFT 60% reduction | Infrastructure-level container lazy-provisioning |
| Server-side session persistence (survives machine restart) | Requires Anthropic's session log servers |
| Memory store API (versioned, concurrent-safe, multi-user) | Requires hosted database with ACID guarantees |
| `wake(sessionId)` — resume crashed harness | Requires server-side session state |
| Automatic container provisioning per tool call | Requires cloud container orchestration |
| Always-on execution (Mac off → agents still run) | Requires cloud compute |
| Outcomes harness (automated grader + retry loop) | Requires server-side state machine |
| `span.outcome_evaluation_*` event stream | Requires harness infrastructure |
| MCP proxy + credential vault | Requires dedicated proxy infrastructure |
| Memory versions with redaction for PII compliance | Requires immutable append-only database |
| Cross-machine memory access | Requires cloud-hosted store |

---

## Priority Ranking for Immediate gOS Implementation

| Priority | Pattern | Effort | Impact |
|----------|---------|--------|--------|
| P1 | **Memory auto-read/auto-write hooks** (Pattern 3) | Low | High — every session benefits |
| P2 | **Isolated grader for /review and /build** (Pattern 4) | Medium | High — eliminates confirmation bias |
| P3 | **Append-only event log** (Pattern 2) | Low | Medium — better compaction recovery |
| P4 | **Memory-as-code commits** (Pattern 6) | Low | Medium — audit trail, rollback |
| P5 | **Path-addressed memory restructure** (Pattern 7) | Medium | Medium — future-proof scaling |
| P6 | **Lazy context loading in /gos** (Pattern 1) | Low | Low-Medium — current context load is fast |
| P7 | **Credential hygiene rules** (Pattern 5) | Low | Low (already partially done) |

---

## Early Adopter Signal (What They Actually Built)

| Company | What They Built | Extractable Pattern |
|---------|----------------|-------------------|
| **Notion** | Parallel coding/slides/spreadsheet tasks delegated to Claude within workspace | Parallel session dispatch; coordinator pattern |
| **Asana** | "AI Teammates" — agents that live inside projects, pick up tasks, draft deliverables | Session-per-task model; task as structured event |
| **Sentry** | Flagged bug → open pull request, fully autonomous | Event-triggered sessions; git-integrated output |
| **Rakuten** | Specialist agents across product/sales/marketing/finance/HR, each live in <1 week | One agent definition per domain; shared environment |

**gOS signal from Sentry pattern:** The bug→PR pipeline is achievable locally today with a `/build fix <issue>` command that runs the full TDD loop end-to-end. No Managed Agents needed for the core value.

---

## Sources

- [Scaling Managed Agents: Decoupling the brain from the hands — Anthropic Engineering](https://www.anthropic.com/engineering/managed-agents)
- [Claude Managed Agents Overview — Anthropic Docs](https://platform.claude.com/docs/en/managed-agents/overview)
- [Using agent memory — Anthropic Docs](https://platform.claude.com/docs/en/managed-agents/memory)
- [Define outcomes — Anthropic Docs](https://platform.claude.com/docs/en/managed-agents/define-outcomes)
- [Claude Managed Agents launch blog](https://claude.com/blog/claude-managed-agents)
- [Early adopter coverage — SiliconAngle](https://siliconangle.com/2026/04/08/anthropic-launches-claude-managed-agents-speed-ai-agent-development/)
- [Decoupling the Brain and Hands: Epsilla analysis](https://www.epsilla.com/blogs/anthropic-managed-agents-decoupling-brain-hands-enterprise-orchestration)
- [Complete guide 2026 — The AI Corner](https://www.the-ai-corner.com/p/claude-managed-agents-guide-2026)
