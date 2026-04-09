---
description: "Dispatch — multi-session orchestration: spawn workers, monitor progress, synthesize results"
---

# Dispatch — Multi-Session Orchestration

Dispatch splits a plan into independent phases, spawns worker agents per phase, monitors progress, and synthesizes results. The lead session (you) stays thin — orchestrating, not executing.

Parse the first word of `$ARGUMENTS` to route:

| Argument | Action |
|----------|--------|
| `<plan-file>` | Start a new dispatch job from a plan file |
| `status [job-id]` | List all jobs or detail a specific one |
| `cancel <job-id>` | Cancel a running job |
| `retry <job-id> <worker-id>` | Retry a failed worker |
| `synthesize <job-id>` | Manually trigger synthesis |

---

## Starting a Job: `/dispatch <plan-file>`

### Plan Format

Plans use markdown with phase headers containing dependency tags:

```markdown
# Plan: {title}

## Shared Context
{context all workers need — specs, constraints}

## Phase 1: {name} [no-deps]
- files: {file paths this phase touches}
- instructions: {specific task}

## Phase 2: {name} [depends: Phase 1]
- files: {file paths}
- instructions: {specific task}
```

### Execution Flow

1. **Parse plan** → extract phases, dependencies, shared context
2. **Build dependency graph** → group into batches (no-deps first, then dependents)
3. **Generate job ID** → `{kebab-title}-{4char-hash}`
4. **Present for approval** → show batch order, worker count, estimated spawns. Wait for "yes."
5. **Execute batches** — for each batch, spawn all independent phases in parallel:

```
Agent(
  prompt = "You are dispatch worker-{N}. Task: {phase instructions}
            Shared context: {context}
            Write results to output when done: summary, files changed,
            tests run, blockers encountered.
            RULES: No push to remote. Only modify files in your file list.",
  subagent_type = "general-purpose",
  isolation = "worktree",
  run_in_background = true
)
```

6. **Monitor** — when all workers in batch complete, check for failures (offer retry/skip/abort), pass outputs as context to next batch
7. **Synthesize** — read all worker outputs, identify file conflicts, produce summary with combined changes, conflicts, quality gate recommendation

### Worker Configuration

| Worker Type | Model | Max Turns | Tools |
|-------------|-------|-----------|-------|
| Research | haiku | 10 | Read, Grep, Glob, WebSearch |
| Build | sonnet | 25 | Read, Edit, Write, Bash, Grep, Glob |
| Review | haiku | 15 | Read, Grep, Glob |

**Cache-friendly prompts:** Workers in the same batch share identical system prompt prefixes. Vary only the task-specific suffix.

---

## Safety Rules

1. **Workers cannot push to remote.** Local commits or worktree branches only.
2. **Workers only modify files in their `files:` list.** Note other needs as blockers.
3. **Lead always reviews synthesis before merge.** No automatic merging.
4. **Maximum 5 parallel workers.** More causes rate limits. Split into sub-batches.
5. **File ownership enforced.** Workers flag unauthorized changes as blockers.
