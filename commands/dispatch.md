---
description: "Dispatch — multi-session orchestration: spawn workers, monitor progress, synthesize results"
---

# Dispatch — Multi-Session Orchestration

Dispatch splits a plan into independent phases, spawns worker agents per phase, monitors progress, and synthesizes results. The lead session (you) stays thin — orchestrating, not executing.

Parse the first word of `$ARGUMENTS` to route:

| Argument | Action |
|----------|--------|
| `<plan-file>` | Start a new dispatch job from a plan file |
| `status` | List all active dispatch jobs |
| `status <job-id>` | Detailed view of a specific job |
| `cancel <job-id>` | Cancel a running job |
| `retry <job-id> <worker-id>` | Retry a failed worker |
| `synthesize <job-id>` | Manually trigger synthesis |

---

## Starting a Job: `/dispatch <plan-file>`

### Step 1: Parse the Plan

Read the plan file. Plans use this format:

```markdown
# Plan: {title}

## Shared Context
{context that all workers need — spec references, design decisions, constraints}

## Phase 1: {name} [no-deps]
- repo: {optional, defaults to current project directory}
- files: {file paths this phase touches}
- instructions: {what to do — be specific, each worker gets fresh context}

## Phase 2: {name} [depends: Phase 1]
- repo: {optional}
- files: {file paths}
- instructions: {what to do}

## Phase 3: {name} [depends: Phase 1, Phase 2]
- repo: {optional}
- files: {file paths}
- instructions: {what to do}
```

### Step 2: Generate Job

1. Generate job ID: kebab-case from plan title + 4-char hash (e.g., `copy-trading-a1b2`)
2. Create directory structure:

```
~/.claude/dispatch/{job-id}/
├── plan.md              ← copy of input plan
├── config.json          ← job metadata
├── shared/
│   └── context.md       ← extracted from plan's "Shared Context" section
├── workers/
│   ├── worker-1/
│   │   ├── input.md     ← phase instructions + shared context
│   │   ├── output.md    ← worker writes results here
│   │   └── status.json  ← pending/running/done/failed
│   └── worker-2/
│       ├── input.md
│       ├── output.md
│       └── status.json
└── synthesis.md         ← lead writes after all workers complete
```

3. `config.json` format:

```json
{
  "id": "copy-trading-a1b2",
  "title": "Add copy trading",
  "status": "pending",
  "started_at": null,
  "completed_at": null,
  "worker_count": 3,
  "current_batch": 0,
  "batches": [
    { "batch": 1, "phases": ["Phase 1", "Phase 2"], "status": "pending" },
    { "batch": 2, "phases": ["Phase 3"], "status": "pending" }
  ]
}
```

### Step 3: Build Dependency Graph

Parse `[depends: ...]` tags from each phase header.

- `[no-deps]` → can run immediately
- `[depends: Phase 1]` → waits for Phase 1 to complete
- `[depends: Phase 1, Phase 2]` → waits for both

Group into batches:
- **Batch 1:** All phases with `[no-deps]` or no dependency tag (run in parallel)
- **Batch 2:** Phases whose dependencies are all in Batch 1
- **Batch 3:** Phases whose dependencies include Batch 2 items
- Continue until all phases are batched

### Step 4: Present for Approval

```
Dispatch job: {job-id}
Plan: {title}
Workers: {N total}

Dependency graph:
  Phase 1 (API endpoint) [no-deps]
  Phase 2 (UI screen) [no-deps]
  Phase 3 (Tests) [depends: Phase 1, Phase 2]

Execution order:
  Batch 1 (parallel): Phase 1, Phase 2
  Batch 2 (sequential after batch 1): Phase 3

Estimated: {N} agent spawns, {M} batches

Start? (yes/no)
```

Wait for explicit approval.

### Step 5: Execute Batches

For each batch:

1. Update `config.json`: `current_batch = N`, `status = "running"`
2. For each phase in the batch:
   a. Update `workers/worker-{N}/status.json`: `status = "running"`, `started_at = now`
   b. Spawn agent:
   ```
   Agent(
     prompt = "You are a dispatch worker. Read your input file and execute the task.
               Write your results to output.md when done.
               Input: {input.md contents}
               Shared context: {context.md contents}

               When complete, write output.md with:
               - What you did (summary)
               - Files changed (list)
               - Tests run and results
               - Any issues or blockers encountered

               RULES:
               - Do NOT push to remote. Local commits only.
               - Do NOT modify files outside your listed file paths.
               - If blocked, write the blocker to output.md and stop.",
     subagent_type = "general-purpose",
     isolation = "worktree",  # if phase touches code
     run_in_background = true,
     name = "dispatch-worker-{N}"
   )
   ```
3. Monitor: check worker status files periodically
4. When all workers in batch complete:
   a. Read each worker's output.md
   b. Check for failures — if any worker failed, offer: retry / skip / abort
   c. Update batch status in config.json
   d. If more batches remain, pass relevant outputs as shared context to next batch
   e. Spawn next batch

### Step 6: Synthesize (automatic after all batches complete, or manual via `/dispatch synthesize`)

1. Read all `workers/*/output.md`
2. Identify file conflicts (same file path in multiple workers' "files changed")
3. If worktree isolation was used, list worktree branches for manual merge
4. Write `synthesis.md`:

```markdown
# Synthesis: {title}
Generated: {timestamp}

## Summary
{1-3 sentence overview of what was accomplished}

## Workers
| Worker | Phase | Status | Duration | Files Changed |
|--------|-------|--------|----------|---------------|
| worker-1 | API endpoint | done | 12 min | 3 files |
| worker-2 | UI screen | done | 18 min | 5 files |
| worker-3 | Tests | done | 8 min | 2 files |

## Combined Changes
{aggregate list of all files changed across all workers}

## Conflicts
{list any files modified by multiple workers, or "None"}

## Worktree Branches
{list branches to merge, or "N/A — no worktrees used"}

## Quality Gate
Run `/review gate` on the combined result before merging.

## Next Steps
- [ ] Review each worker's output.md for quality
- [ ] Resolve any conflicts listed above
- [ ] Merge worktree branches
- [ ] Run /review gate
- [ ] /ship if gate passes
```

5. Update `config.json`: `status = "completed"`, `completed_at = now`
6. Report to user with synthesis summary

---

## status

### `/dispatch status` — All Jobs

Read all `~/.claude/dispatch/*/config.json`. Display:

```
| Job ID | Title | Status | Workers | Progress | Started |
|--------|-------|--------|---------|----------|---------|
| copy-trading-a1b2 | Add copy trading | running | 3 | 2/3 done | 15 min ago |
| dark-mode-c3d4 | Add dark mode | completed | 2 | 2/2 done | 2 hours ago |
```

If no jobs exist: "No dispatch jobs. Start one with `/dispatch <plan-file>`."

### `/dispatch status <job-id>` — Specific Job

Read `config.json` and all worker status files. Display:

```
Job: copy-trading-a1b2
Title: Add copy trading
Status: running (batch 1 of 2)
Started: 15 min ago

Workers:
  worker-1 (API endpoint)     ✅ done (12 min, 3 files changed)
  worker-2 (UI screen)        🔄 running (spawned 8 min ago)
  worker-3 (Tests)            ⏳ blocked on worker-1, worker-2

Batch 1: [worker-1 ✅, worker-2 🔄]
Batch 2: [worker-3 ⏳]
```

---

## cancel <job-id>

1. Read `config.json` for the job
2. For each worker with status "running" or "pending":
   - Update `status.json`: `status = "cancelled"`
3. Update `config.json`: `status = "cancelled"`
4. Do NOT delete any files — keep all outputs for review
5. Report: "Job `{job-id}` cancelled. {N} workers stopped. Files preserved at `~/.claude/dispatch/{job-id}/`."

---

## retry <job-id> <worker-id>

1. Read the worker's `input.md`
2. Reset `status.json`: `status = "pending"`, `started_at = null`, `error = null`
3. Clear `output.md`
4. Re-spawn the worker agent with the same input
5. Report: "Worker `{worker-id}` retrying for job `{job-id}`."

---

## Safety Rules

1. **Workers CANNOT push to remote.** Local commits or worktree branches only. Lead reviews before any push.
2. **Workers CANNOT modify dispatch files.** They read their `input.md`, write their `output.md`. Nothing else in `~/.claude/dispatch/`.
3. **Lead ALWAYS reviews synthesis before merge.** No automatic merging of worker output into main branch.
4. **Maximum 5 parallel workers.** More than 5 causes API rate limits and context thrashing. If plan has >5 parallel phases, split into sub-batches of 5.
5. **Token budget warning.** If a worker's output suggests it used excessive context (>50k tokens estimated), flag in synthesis as "high-cost worker — review for efficiency."
6. **File ownership.** Workers should only modify files listed in their phase's `files:` field. If they need to modify other files, they should note it in output.md as a blocker rather than making unauthorized changes.

---

## Multi-Repo Support

Plans can specify different repos per phase:

```markdown
## Phase 1: API endpoint [no-deps]
- repo: ~/Projects/Arx-api
- files: routes/copy-trade.ts, services/copy-trade.ts
- instructions: Build the /copy-trade endpoint

## Phase 2: UI screen [depends: Phase 1]
- repo: ~/Projects/Arx
- files: apps/mobile/src/screens/CopyTrade.tsx
- instructions: Build the copy trade screen using types from Phase 1
```

When spawning workers with different repos:
- Each worker's agent prompt includes `cd {repo}` as the first instruction
- Shared context is passed via the dispatch directory (accessible from any repo)
- Cross-repo dependencies are passed via `shared/context.md` (updated between batches with relevant type definitions, API contracts, etc.)

---

## Example Plan File

```markdown
# Plan: Add Copy Trading Feature

## Shared Context
Spec: specs/Arx_4-1-1-3_Copy_Trading.md
Design: specs/Arx_4-1-1-3_Copy_Trading_Design.md
The copy trading feature allows users to follow top traders and automatically mirror their positions.
Key constraint: must use Hyperliquid's vault system for fund isolation.

## Phase 1: Data layer [no-deps]
- files: src/services/copy-trade.ts, src/types/copy-trade.ts, src/hooks/useCopyTrade.ts
- instructions: Build the data layer for copy trading. Define types for Leader, Follower, CopyPosition. Create a service that fetches leader data from Hyperliquid MCP. Create a React hook that exposes leader list, follow/unfollow actions, and position mirroring state.

## Phase 2: Leaderboard screen [no-deps]
- files: src/screens/CopyTradeLeaderboard.tsx, src/components/LeaderCard.tsx
- instructions: Build the leaderboard screen showing top traders. Use the LeaderCard component for each leader. Show: name, 30d PnL, win rate, followers, copy button. Mobile-first, dark theme. Use design tokens from specs/Arx_4-2.

## Phase 3: Copy management screen [depends: Phase 1]
- files: src/screens/CopyTradeManage.tsx, src/components/ActiveCopy.tsx
- instructions: Build the copy management screen. Show active copies with P&L, allocation, stop-loss settings. Allow adjusting allocation and stopping copies. Uses the data layer from Phase 1.

## Phase 4: Integration tests [depends: Phase 1, Phase 2, Phase 3]
- files: tests/copy-trade.test.ts, tests/e2e/copy-trade.spec.ts
- instructions: Write unit tests for the copy-trade service and integration tests for the screens. Use React Testing Library for component tests. Target 80%+ coverage.
```
