# gOS Multi-Agent Framework

> The operating system for multi-agent coordination in gOS. Verbs reference this; agents follow it.

## Architecture

```
gOS Conductor (routes intent to verb)
        │
   Complexity Gate (score 0-10)
        │
   ┌────┼────┐
 Solo  Ad-hoc  Team
 0-3   4-6    7-10
```

**Solo** = conductor executes inline. **Ad-hoc** = fire-and-forget `Agent()` calls. **Team** = persistent roster agents with `TeamCreate`, `SendMessage`, `TaskList`.

---

## 1. Complexity Gate

Score the task before choosing execution method. Quick mental math, not a formal rubric.

| Factor | Weight | Low (0) | Mid (5) | High (10) |
|--------|--------|---------|---------|-----------|
| Files touched | 30% | 1-2 | 3-5 | 6+ |
| Systems involved | 25% | 1 | 2 | 3+ (backend+frontend+tests) |
| Dependency depth | 20% | None | A before B | Chain of 3+ |
| Adversarial value | 15% | Formatting | Logic | Security, money |
| Estimated turns | 10% | <10 | 10-30 | 30+ |

| Score | Method | Example |
|-------|--------|---------|
| **0-3** | Solo (inline) | Fix typo, update one spec, quick research |
| **4-6** | Ad-hoc agents | Research 3 topics, review 2 files, parallel reads |
| **7-10** | Team (from registry) | Build feature across systems, full pipeline, council |

---

## 2. Agent Roster

Six specialist agents in `.claude/agents/`. Each has persistent memory and a constrained role.

| Agent | Model | Effort | Memory | MaxTurns | Color | Primary Verbs |
|-------|-------|--------|--------|----------|-------|--------------|
| `researcher` | sonnet | high | project | 25 | cyan | think, simulate |
| `architect` | opus | max | project | 15 | magenta | build, refine |
| `engineer` | sonnet | high | project | 40 | green | build |
| `reviewer` | sonnet | max | project | 20 | yellow | review |
| `designer` | sonnet | high | project | 25 | pink | design |
| `verifier` | haiku | medium | local | 15 | blue | build, review, ship |

**Naming at spawn time:** Role-suffixed for clarity. `researcher` becomes `researcher-market` or `researcher-competitor` in the team. The base agent file is reused; the spawn prompt specializes it.

---

## 3. Coordination Protocol

### Lifecycle (10 steps)

```
 1. SCORE    — Complexity gate evaluates task
 2. SELECT   — Pick template from team-registry.md (or solo/ad-hoc)
 3. CREATE   — TeamCreate(team_name="gos-{verb}-{slug}")
 4. SPAWN    — Agent(name="{role}", team_name=..., subagent_type="{roster-agent}")
 5. ASSIGN   — TaskCreate() per work item, with blockedBy dependencies
 6. EXECUTE  — Agents work; SendMessage for handoffs and questions
 7. RESOLVE  — Conflict resolution if agents disagree (see §4)
 8. COLLECT  — Conductor reads task results + agent outputs
 9. SHUTDOWN — SendMessage(to="*", message={type:"shutdown_request"}) → TeamDelete
10. PERSIST  — Agents save learnings to their memory scope before exit
```

### Handoff Protocol

| Type | When | How |
|------|------|-----|
| **Message** | Small data (<500 tokens) | `SendMessage(to="engineer", message="API contract: {types}")` |
| **Artifact** | Large output (specs, code, reports) | Agent writes to `outputs/gos-jobs/{job-id}/{role}-output.md`; next agent reads |

### Handoff Triggers

- Architect → Engineer: API contract + data model ready
- Engineer → Verifier: Implementation committed, test paths identified
- Researcher → Architect: Research brief with constraints and evidence
- Reviewer → Engineer: Findings with severity (CRITICAL blocks, others inform)

---

## 4. Conflict Resolution

Three escalation levels. Always try the lowest level first.

```
Level 1: SELF-RESOLVE
  Agent re-reads spec, checks own assumptions, retries.
  Trigger: Agent detects inconsistency in its own output.

Level 2: PEER CROSS-EXAMINE
  SendMessage(to=conflicting_agent, "Your finding X contradicts my finding Y. Evidence: {evidence}")
  Conflicting agent responds with counter-evidence or concedes.
  Trigger: Two agents produce contradictory outputs on the same topic.

Level 3: CONDUCTOR ARBITRATES
  Both agents present evidence to conductor.
  Conductor decides based on spec authority and evidence weight.
  Trigger: Peer cross-examination fails to resolve after 2 rounds.
```

**Veto power:** `reviewer` can BLOCK any output that touches security or money handling. This is non-negotiable — conductor cannot override a security BLOCK.

---

## 5. Shutdown Sequence

1. Conductor sends: `SendMessage(to="*", message={type: "shutdown_request"})`
2. Each agent receives, saves any unsaved memory, responds: `{type: "shutdown_response", approve: true}`
3. Conductor collects final outputs from TaskList
4. Conductor calls `TeamDelete`
5. Conductor synthesizes results and reports to user

**Abnormal shutdown:** If an agent is stuck (no response after 60s), conductor force-terminates and notes the incomplete work in the job report.

---

## 6. Team Templates

See `team-registry.md` for pre-built team compositions:

| Template | Agents | Use Case |
|----------|--------|----------|
| `think-swarm` | 3-5 researchers + cross-exam lead | `/think discover`, `/think research`, `/think decide` |
| `build-squad` | architect + engineer(s) + verifier | `/build feature` (complex) |
| `review-panel` | batched waves with veto | `/review council`, `/review gate` |
| `full-pipeline` | sequential handoff through all roles | `/refine`, `/gos <complex goal>` |

---

## 7. Rules

1. **Agents cannot spawn agents.** Only the conductor (gOS) spawns. Agents use `SendMessage` to request help.
2. **One team per verb invocation.** Don't nest teams. If a think-swarm needs a review, the conductor spawns a separate review after the swarm completes.
3. **Memory is per-agent, not per-team.** Teams are ephemeral; agent memory persists. The `researcher` remembers findings across teams.
4. **Solo is the default.** Teams are the exception for complex work. Most tasks score 0-3.
5. **Specs are the source of truth.** When agents disagree, the spec wins. If the spec is ambiguous, escalate to conductor who escalates to user.
