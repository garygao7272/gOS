---
effort: high
description: "Evolve — self-improve: audit health, upgrade commands, learn lessons"
---

# Evolve — Self-Improvement Engine

**Purpose:** gOS reviews its own performance and upgrades itself. This is the reinforcement loop — not just logging what happened, but actively improving commands, prompts, and patterns based on evidence.

Parse the first word of `$ARGUMENTS` to determine sub-command. If none given, run `audit`.

**Plan mode by default.** For `audit` and `upgrade`: present scope (what signals/commands to examine, what changes to propose) and wait for approval. Skip for `learn` (single-pass, low risk).

**Output discipline (two-phase pattern):** For audit, upgrade, and reflect sub-commands, use the analysis/output separation pattern. Do your reasoning and evidence gathering inside `<analysis>` tags (private working space — not shown to Gary). Then produce the concise, actionable result inside `<output>` tags. This keeps Gary's view clean while preserving thorough analysis.

---

## Signal System

Six signal types: `accept` (used as-is), `rework` (changes requested), `reject` (discarded), `love` (praised), `repeat` (re-explained), `skip` (skipped prescribed step). Logged to `sessions/evolve_signals.md` as `| Date | Time | Command | Signal | Context |`. Batch-log during `/gos save`.

---

## audit

**Purpose:** Comprehensive health check of gOS performance. Absorbs the old `retro` analytics.

**Triggers:**
- Manual: `/evolve audit` or `/evolve` (default)
- Scheduled: weekly
- After 20+ signals accumulated without an audit

### Execution — PEV (see `specs/pev-protocol.md`)

1. Spawn `pev-planner` with: task = health audit, task_class = verification, pool hint:
   - `signal-tallier` — read `sessions/evolve_signals.md` since last `--- AUDITED ---` marker, compute health per command: `(accepts + 2*loves) / total * 100`
   - `feedback-miner` — read all `memory/feedback_*.md`, group correction patterns by command, surface repeats (3+)
   - `activity-summarizer` — `git log --oneline -30`, map commits to commands exercised, shipping cadence
   - Optional `episode-recaller` — pull prior audit (`memory/evolve_audit_*.md`) for trend comparison
2. Planner writes `roster.json`. Present. Approve.
3. Execute in parallel. Each agent writes to `artifacts/{agent}.md`.
4. `pev-validator` cross-checks: do signal counts reconcile with git activity? Do feedback patterns map to reworks in signals? Inconsistency → ITERATE.
5. **CONVERGED** → `adjudicator` produces the health table, shipping stats, trend comparison, diagnosis, and prioritized recommendations (see steps 2-8 below).

**Audit outputs:**

1. **Score each gOS command:**

   For each command, tally signals and compute a health score:

   ```
   Health = (accepts + 2 * loves) / total_invocations * 100
   ```

   Where `total_invocations = accepts + loves + reworks + rejects + repeats`

   Flag any command below 70% health.

2. **Produce the health table:**

   ```
   # gOS Health Audit — {date}

   ## Command Health

   | Command | Uses | Accept | Rework | Reject | Love | Health |
   |---------|------|--------|--------|--------|------|--------|
   | /think  | 15   | 12     | 2      | 0      | 1    | 93%    |
   | /build  | 23   | 18     | 4      | 1      | 0    | 78%    |
   | /ship   | 8    | 7      | 1      | 0      | 0    | 88%    |
   | /judge  | 5    | 3      | 1      | 1      | 0    | 60%    |
   ...
   ```

3. **Shipping analytics** (formerly retro):

   ```
   ## Shipping Stats
   - Commits this week: {count from git log --since='1 week ago'}
   - Test coverage: {from last test run, if available}
   - Review pass rate: {reviews cleared / reviews run}
   - Lines changed: {from git diff --stat}
   ```

4. **Trends:** For each command, compare current health to previous audit:
   - Improving (health went up)
   - Stable (within 5%)
   - Degrading (health went down)

5. **Diagnose issues:**

   | Pattern | What It Means | Fix |
   |---------|--------------|-----|
   | High rework rate | Output format or content mismatches expectations | Sharpen prompt constraints |
   | High skip rate | Prescribed steps add friction, not value | Make steps optional or remove |
   | Repeat signals | gOS isn't retaining corrections | Add to memory + command file |
   | Never used | Command isn't useful or isn't discoverable | Merge, rename, or document better |
   | High love rate | This command nails it | Protect — don't change what works |

6. **Generate recommendations:**
   - Rank issues by impact (most reworks + rejects first)
   - Propose specific fixes (file + section + change)
   - Flag commands to add/remove/merge

7. **Present to Gary:**
   ```
   ## Recommendations
   1. {specific fix} — impact: {high/medium}
   2. {specific fix} — impact: {high/medium}
   3. {specific fix} — impact: {medium/low}

   Want me to apply them?
   ```

8. **After audit:** Log audit results to `memory/evolve_audit_{date}.md`. Mark signal log with `--- AUDITED {date} ---` separator. **Then, for every recommendation that produces a rule, correction, or known-gap, write a `memory/feedback_{slug}.md` entry inline in this same pass.** Capture is always inline — step 7's "Want me to apply them?" refers only to command-file edits, not feedback capture. Rationale: 2026-04-08 audit generated 2 concrete recommendations, 0 ended up in memory; deferred capture doesn't survive the session.

---

## upgrade <command>

**Purpose:** Rewrite a specific command based on accumulated signals and feedback.

**Direct-to-command learning (no intermediate artifacts).** When a pattern is identified, edit the command file directly. Annotate inline with `(Instinct: {name})` so the origin is traceable. No YAML files, no index to maintain — the command IS the instinct.

**Repeat-rework auto-detector:** When scanning signals, if the same rework type appears 3+ times for one command, auto-propose a command edit and flag for approval.

**Process:**

1. Read the current command file: `.claude/commands/{command}.md`
2. Read all signals related to that command from `sessions/evolve_signals.md`
3. Read feedback from memory files related to this command
4. Identify patterns — what gets reworked? what gets rejected? why? **Flag any pattern with 3+ occurrences.**

   | Signal Pattern | Upgrade Action |
   |---------------|----------------|
   | Rework on output format | Add clearer output format spec |
   | Rework on content | Sharpen agent instructions, add constraints |
   | Skip on plan mode | Make plan mode conditional |
   | Skip on a sub-command | Remove or merge the sub-command |
   | Reject on agent output | Swap agent type or skill |
   | Repeat on same correction | Hardcode the correction into the command |
   | Love on specific pattern | Extract the pattern and apply to other commands |

5. Propose specific changes — show before/after for each section
6. **Wait for approval.** Do not rewrite without Gary's go-ahead.
7. If approved: rewrite the command file
8. Commit: `evolve: upgrade /{command} — {reason}`
9. Log the upgrade in `sessions/evolve_signals.md` with context

---

## learn <lesson>

**Purpose:** Manually teach gOS something. Faster than waiting for signals to accumulate.

**Process:**

1. Parse the lesson from `$ARGUMENTS` (everything after "learn")
2. Classify the learning type:

   | Type | Target File | Example |
   |------|------------|---------|
   | `feedback` | `memory/feedback_*.md` | "Don't use plan mode for quick fixes" |
   | `project` | `memory/project_*.md` | "We're dropping the insurance vertical" |
   | `user` | `memory/user_gary_soul.md` | "I prefer dark mode mockups" |
   | `command` | `.claude/commands/{cmd}.md` | "Think design should skip Phase 0" |
   | `domain` | `memory/domain_*.md` | "Hyperliquid uses 8 decimal precision" |

3. Write the learning to the appropriate file:
   - For existing files: append to the relevant section
   - For new categories: create a new memory file and update `memory/MEMORY.md` index
4. If it's a command correction, also log a `repeat` signal to `sessions/evolve_signals.md`
5. Confirm:
   ```
   Learned: {1-line summary}. Saved as {type} memory to {file}.
   ```

---

## reflect

**Purpose:** Principle-by-principle self-grading. Deeper than audit — audit counts signals, reflect questions assumptions.

**Process:**

1. **Read everything — launch 2 agents in a single message:**

   ```
   Agent(
     prompt = "Read ~/.claude/CLAUDE.md (identity + principles) and all memory/feedback_*.md.
               For each principle, find evidence of compliance or violation in the feedback files.
               Return: principle → evidence mapping.",
     subagent_type = "general-purpose", model = "haiku", run_in_background = true
   )

   Agent(
     prompt = "Read sessions/evolve_signals.md and git log --oneline -30.
               Cross-reference: which commands were most used? Most reworked?
               Return: command activity + health summary.",
     subagent_type = "general-purpose", model = "haiku", run_in_background = true
   )
   ```

2. **Grade against each principle:**

   For every principle in `~/.claude/CLAUDE.md`, assign a letter grade with evidence:

   ```
   # gOS Reflection — {date}

   ## Principle Grades

   | Principle | Grade | Evidence |
   |-----------|-------|----------|
   | Spec before agent | A | Read specs 14/15 times before acting |
   | Small chunks | B | 2 oversized prompts this week |
   | Tests in same context | A | 100% compliance |
   | Build fast, refactor immediately | C | 3 instances of shipping without refactor |
   | Context is precious | B | Some unnecessary context loaded |
   | One landing at a time | A | No parallel build conflicts |
   | Stay engaged | A | Exit gates run every time |
   | CLI-accessible stack | B | One verbose doc section |
   ```

3. **Compute Directive scorecard:**

   ```
   ## Directive Scorecard
   UNDERSTAND: {score}/10 — {evidence: Am I decoding intent, not just words?}
   CHALLENGE: {score}/10 — {evidence: Am I surfacing blind spots?}
   COMPLETE: {score}/10 — {evidence: Am I filling knowledge gaps?}
   ALIGN: {score}/10 — {evidence: Am I confirming the right problem?}
   ```

4. **Answer the hard questions:**
   - What does Gary need most right now that I'm not providing?
   - What would a 10x better version of gOS do differently?
   - What's the biggest gap between what Gary wants and what I deliver?
   - Am I being constructive enough, or just agreeable?

5. **Identify the weakest principle** and propose a concrete improvement plan:

   ```
   ## Focus Area
   {weakest principle}: {specific improvement plan with actionable steps}
   ```

6. **Save reflection** to `memory/reflection_{date}.md`

7. **Present the "One Thing"** — the single highest-impact improvement Gary should know about.

---

## Signal Capture

Signals are passively observed after every command output (see Signal System above). Batch-logged during `/gos save`. Not a separate tool call — just a mental note.
