---
description: "Evolve — self-improve: audit health, upgrade commands, learn lessons, reflect on principles"
---

# Evolve — Self-Improvement Engine

**Purpose:** gOS reviews its own performance and upgrades itself. This is the reinforcement loop — not just logging what happened, but actively improving commands, prompts, and patterns based on evidence.

Parse the first word of `$ARGUMENTS` to determine sub-command. If none given, run `audit`.

---

## Signal System — The Feedback Loop

Every gOS command generates **signals** — evidence of what worked and what didn't. Signals are the raw data that powers all of Evolve.

### Signal Types

| Signal | Meaning | How Detected |
|--------|---------|-------------|
| `accept` | Gary used the output without changes | No pushback, moved to next task |
| `rework` | Gary asked for changes to the output | "Change this", "not quite", "try again" |
| `reject` | Gary discarded the output entirely | "No", "scratch that", "wrong approach" |
| `love` | Gary explicitly praised the output | "Perfect", "great", "exactly", "hell yes" |
| `repeat` | Gary had to re-explain something | Same instruction given twice |
| `skip` | Gary skipped a step the command prescribed | Jumped past plan mode, skipped agent, etc. |

### Signal Storage

Signals accumulate in `sessions/evolve_signals.md` using this format:

```markdown
# Evolve Signals

## {date}

| Time | Command | Sub-cmd | Signal | Context |
|------|---------|---------|--------|---------|
| 14:30 | /think | design | rework | "Too many sections, simplify" |
| 14:45 | /think | design | accept | Simplified version approved |
| 15:10 | /build | prototype | love | "This is exactly right" |
```

### When to Record Signals

**During every session**, update `sessions/evolve_signals.md` at these moments:
- After Gary responds to any gOS command output (accept/rework/reject/love)
- When Gary repeats an instruction (repeat signal)
- When Gary skips a prescribed step (skip signal)
- During session save — review the session and batch-log any missed signals

This is lightweight. One line per signal. Takes 5 seconds to append. But over weeks, these signals reveal patterns no single session can show.

---

## audit

**Purpose:** Comprehensive health check of gOS performance. Absorbs the old `retro` analytics.

**Triggers:**
- Manual: `/evolve audit` or `/evolve` (default)
- Scheduled: weekly
- After 20+ signals accumulated without an audit

**Process:**

1. **Gather evidence** (parallel reads):
   - Read `sessions/evolve_signals.md` — all signals since last audit
   - Read all `memory/feedback_*.md` — what did Gary correct?
   - Read `memory/user_gary_soul.md` — are preferences current?
   - `git log --oneline -30` — what was built recently?
   - Read `sessions/scratchpad.md` — dead ends from current session

2. **Score each gOS command:**

   For each command, tally signals and compute a health score:

   ```
   Health = (accepts + 2 * loves) / total_invocations * 100
   ```

   Where `total_invocations = accepts + loves + reworks + rejects + repeats`

   Flag any command below 70% health.

3. **Produce the health table:**

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

4. **Shipping analytics** (formerly retro):

   ```
   ## Shipping Stats
   - Commits this week: {count from git log --since='1 week ago'}
   - Test coverage: {from last test run, if available}
   - Review pass rate: {reviews cleared / reviews run}
   - Lines changed: {from git diff --stat}
   ```

5. **Trends:** For each command, compare current health to previous audit:
   - Improving (health went up)
   - Stable (within 5%)
   - Degrading (health went down)

6. **Diagnose issues:**

   | Pattern | What It Means | Fix |
   |---------|--------------|-----|
   | High rework rate | Output format or content mismatches expectations | Sharpen prompt constraints |
   | High skip rate | Prescribed steps add friction, not value | Make steps optional or remove |
   | Repeat signals | gOS isn't retaining corrections | Add to memory + command file |
   | Never used | Command isn't useful or isn't discoverable | Merge, rename, or document better |
   | High love rate | This command nails it | Protect — don't change what works |

7. **Generate recommendations:**
   - Rank issues by impact (most reworks + rejects first)
   - Propose specific fixes (file + section + change)
   - Flag commands to add/remove/merge

8. **Present to Gary:**
   ```
   ## Recommendations
   1. {specific fix} — impact: {high/medium}
   2. {specific fix} — impact: {high/medium}
   3. {specific fix} — impact: {medium/low}

   Want me to apply them?
   ```

9. **After audit:** Log audit results to `memory/evolve_audit_{date}.md`. Mark signal log with `--- AUDITED {date} ---` separator.

### Auto-Optimization Mode (scheduled)

When audit runs on a schedule (weekly cron), it operates autonomously:

1. Run the full audit process above
2. **If any command is below 70% health:**
   - Auto-generate an upgrade proposal
   - Save to `~/.claude/evolve/proposals/{command}-{date}.md`
   - Format:
     ```markdown
     # Upgrade Proposal: /{command}
     Date: {date}
     Health: {score}% (threshold: 70%)

     ## Evidence
     {signal summary — what got reworked/rejected and why}

     ## Proposed Changes
     {specific before/after diffs}

     ## Expected Impact
     {what should improve}
     ```
3. **Do NOT apply changes automatically.** Proposals wait for human approval.
4. **Next `/gos` session briefing** surfaces pending proposals:
   ```
   Pending: 1 evolve proposal for /review (health 62%, 3 reworks in 5 uses).
   Run /evolve proposals to review.
   ```

### Proposals sub-command

`/evolve proposals` — List and act on pending upgrade proposals:
- Show all proposals in `~/.claude/evolve/proposals/`
- For each: show summary, evidence, proposed changes
- Actions: `accept` (apply + delete), `reject` (delete), `defer` (keep for next audit)

### Setup: Schedule the weekly auto-audit

```
/gos schedule add "evolve audit" --cron "0 9 * * 1"
```
This runs audit every Monday 9am. If commands are unhealthy, proposals are generated automatically.

---

## upgrade <command>

**Purpose:** Rewrite a specific command based on accumulated signals and feedback.

**Process:**

1. Read the current command file: `.claude/commands/{command}.md`
2. Read all signals related to that command from `sessions/evolve_signals.md`
3. Read feedback from memory files related to this command
4. Identify patterns — what gets reworked? what gets rejected? why?

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

### A/B Testing Mode: `upgrade --test <command>`

Instead of one-shot rewriting, fork the command and compare versions empirically:

1. **Fork:** Copy `commands/{command}.md` → `commands/{command}.v2.md`
2. **Generate variant:** Apply the proposed changes to v2 only. v1 stays unchanged.
3. **Announce:** "A/B test started for /{command}. Next {N} invocations (default: 5) will alternate between v1 and v2."
4. **Track:** Create `sessions/ab-test-{command}.md`:
   ```markdown
   # A/B Test: /{command}
   Started: {date}
   Target: {N} invocations

   | # | Version | Signal | Notes |
   |---|---------|--------|-------|
   | 1 | v1 | accept | |
   | 2 | v2 | rework | output format unclear |
   | 3 | v1 | accept | |
   | 4 | v2 | accept | |
   | 5 | v2 | love | better structure |
   ```
5. **On each invocation of the tested command:** Check if an A/B test is active. If so, select the version not yet used the least (balanced assignment). Log result.
6. **After N invocations:** Compare:
   - v1 health: `(accepts + 2*loves) / total * 100`
   - v2 health: same formula
   - Report: "v1: 75% health (3 accept, 0 love, 1 rework). v2: 90% health (3 accept, 1 love, 1 rework). v2 wins."
7. **Ask:** "Promote v2 to main? Run another round? Or discard v2?"
8. **If promoted:** Replace v1 with v2, delete v2 file, log in evolve_signals.md.

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

1. **Read everything:**
   - `.claude/gOS.md` (or `GOD.md`) — the soul and principles
   - All memory files — patterns across sessions
   - `sessions/evolve_signals.md` — signal history
   - Recent git history — what got built
   - `CLAUDE.md` — project state

2. **Grade against each principle:**

   For every principle in gOS.md, assign a letter grade with evidence:

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

## Signal Capture Integration

### Passive Signal Awareness

Every gOS command should be **signal-aware**. After producing output, notice Gary's response:
- If Gary says "perfect" / "great" / "exactly" / "yes!" → `love` signal
- If Gary says "change" / "not quite" / "try again" → `rework` signal
- If Gary says "no" / "scratch that" / "wrong" → `reject` signal
- If Gary re-explains the same thing → `repeat` signal
- If Gary skips a prescribed step → `skip` signal
- If Gary moves on without comment → `accept` signal

This is NOT a separate tool call. It's a mental note that gets batch-logged to `sessions/evolve_signals.md` during session wrap-up or when `/evolve` is invoked.

### Signal Log Format

When logging signals, append to `sessions/evolve_signals.md`:

```markdown
## {date}

| Time | Command | Sub-cmd | Signal | Context |
|------|---------|---------|--------|---------|
| {HH:MM} | /{command} | {sub} | {signal} | "{brief context}" |
```

Group by date. Most recent date at the top of the file.

## Safety (when hooks unavailable)
Before any destructive command (rm -rf, git push --force, git reset --hard, DROP TABLE, kubectl delete, docker system prune), ALWAYS ask for explicit confirmation. Never auto-approve destructive operations.
