---
description: "Evolve — self-improve: audit health, upgrade commands, learn lessons, reflect on principles"
---

# Evolve — Self-Improvement Engine

**Purpose:** gOS reviews its own performance and upgrades itself. This is the reinforcement loop — not just logging what happened, but actively improving commands, prompts, and patterns based on evidence.

Parse the first word of `$ARGUMENTS` to determine sub-command. If none given, run `audit`.

---

## Intent Gate (mandatory — runs before any sub-command)

**First-Principles Decomposition.** Every request is broken into 6 MECE dimensions before execution.

### Step 1: DECOMPOSE

Parse Gary's request. Fill every dimension and classify:

| Dim | Question | ✅ Stated | 🔮 Inferred | ❌ Unknown |
|-----|----------|-----------|-------------|-----------|
| **WHAT** | What are we evolving? (commands, memory, patterns, architecture) | Gary named it | Derivable from context | Must ask |
| **WHY** | What outcome? (fix weakness, add capability, learn from session) | Gary stated purpose | Implied by sub-command | Must ask |
| **WHO** | Who benefits? (gOS itself, Gary's workflow, future sessions) | Gary specified | Usually gOS | Must ask |
| **HOW** | What method? (signal audit, command rewrite, memory update) | Gary chose sub-command | Matches scope | Must ask |
| **SCOPE** | Which parts? (single command, all commands, memory, architecture) | Gary bounded it | Inferrable from signals | Must ask |
| **BAR** | What standard? (incremental tweak, significant upgrade, architectural change) | Gary set the bar | Implied by scope | Must ask |

### Step 2: PRESENT & CLARIFY

Show the decomposition:

> | Dim | Value | Status |
> |-----|-------|--------|
> | WHAT | {target} | ✅/🔮/❌ |
> | WHY | {purpose} | ✅/🔮/❌ |
> | WHO | {audience} | ✅/🔮/❌ |
> | HOW | {approach} | ✅/🔮/❌ |
> | SCOPE | {boundary} | ✅/🔮/❌ |
> | BAR | {standard} | ✅/🔮/❌ |

- **❌ Unknown** → ask ONE batched question covering all unknowns
- **🔮 Inferred** → state for confirmation
- **All ✅/🔮** → skip to Step 3

### Step 3: PLAN

> **Plan: Evolve > {sub-command}**
> - **Scope:** {WHAT + SCOPE resolved}
> - **Reads:** {signals, command files, memories}
> - **Writes:** {proposals, memory updates, command file rewrites}
> - **Output:** {audit report / upgrade diff / memory entry}

**Before presenting "Go?":** Write to `sessions/scratchpad.md`:
- Update `## Current Task` with the resolved WHAT
- Update `## Mode & Sub-command` with the command > sub-command
- Update Pipeline State: `- [x] Intent Gate: WHAT={what} | WHY={why} | WHO={who} | HOW={how} | SCOPE={scope} | BAR={bar}`

### Step 4: CONFIRM
> **Go?**

**HARD STOP.** End your message here. Do NOT:
- Add a "preview" or "meanwhile" or "while you decide"
- Start producing output in the same message
- Say "Go?" and then keep writing

The message containing "Go?" must contain NOTHING after it. Wait for Gary's next message before doing any work.

### Step 5: PLAN MODE (mandatory after Gary confirms)

When Gary confirms ("go", "yes", "do it"), you MUST call `EnterPlanMode` before doing ANY work. This is not optional. This is deterministic:

```
Gary says "go" → call EnterPlanMode() → write plan to plan file → call ExitPlanMode() → Gary approves → THEN execute
```

**Exceptions (skip plan mode):**
- `--auto` flag (mobile/scheduled dispatch)
- Trust level T2+ for this domain
- Sub-commands marked `[skip-gate]`

**[skip-gate] sub-commands** (read-only analysis or self-contained approval flow):
- `audit` — read-only health scoring, proceeds directly
- `reflect` — read-only self-grading, proceeds directly
- `learn --auto` — pattern detection + proposal generation, has its own approval gate at step 6

---

## Context Protocol (runs after Intent Gate, before execution)

After the Intent Gate resolves all 6 dimensions, auto-load relevant context. See `gOS/.claude/context-map.md` for the full keyword → source mapping.

1. Parse resolved WHAT and SCOPE for keywords
2. Match against context map → candidate sources
3. Check file existence (skip missing silently)
4. Estimate token cost (lines / 4)
5. If total < 30% of remaining context → load silently
6. If total > 30% → present list and ask Gary to trim
7. Log loaded context to `sessions/scratchpad.md` under `Working State`
8. **Write scratchpad marker:** Update `sessions/scratchpad.md` Pipeline State: `- [x] Context Loaded: {list of files loaded or "none needed"}`

---

## Memory Recall (runs after Context Protocol, before Trust Check)

Query persistent memory for relevant past experience before executing. This is how gOS learns across sessions.

1. **Search claude-mem** for the current command + domain:
   - `mcp__plugin_claude-mem_mcp-search__search({ query: "{WHAT} {sub-command}", type: "observation", limit: 5 })`
   - Also search: `mcp__plugin_claude-mem_mcp-search__search({ query: "{domain} {sub-command} signal", limit: 3 })`
2. **Check self-model** for domain competence:
   - Read the row for `{domain}` in `.claude/self-model.md`
   - If accept rate < 70% or weaknesses listed → flag: "Note: my `{domain}` has {weakness}. Adjusting approach."
3. **Surface relevant findings:**
   - If past sessions had reworks/rejects in this domain → mention what went wrong and how you'll avoid it
   - If past sessions had accepts/loves → mention what worked and reuse the approach
   - If no relevant history → say "No prior experience in this domain — running full pipeline."
4. **Write scratchpad marker:** Update Pipeline State: `- [x] Memory Recalled: {N} observations, self-model: {domain} T{N} {accept_rate}`

**Keep it brief.** One line of insight, not a paragraph. The goal is to inform execution, not to recite history.

---

## Trust Check (runs after Context Protocol, before Pipe Resolution)

Check trust level for the current domain. See `gOS/.claude/trust-ladder.md` for rules.

1. Infer domain from resolved WHAT (e.g., "evolve upgrade" → `architecture`)
2. Read `sessions/trust.json` → get trust level for this domain
3. Adjust gate depth accordingly (T0=full, T1=lighter confirm, T2=execute-first, T3=silent)
4. Show trust context: "Trust: `{domain}` at T{N} ({history summary})"
5. **Write scratchpad marker:** Update Pipeline State: `- [x] Trust Level: T{N} for {domain}`

---

## Pipe Resolution (runs after Context Protocol, before execution)

Check for upstream artifacts that match the current task. See `gOS/.claude/artifact-schema.md` for the full schema and algorithm.

1. Parse WHAT from resolved intent
2. Search `outputs/` for files with matching topic in YAML frontmatter
3. Filter by types relevant to `/evolve`: verdict, decision (learn from review outcomes)
4. If found: present list and auto-load as context ("📎 Upstream artifacts found...")
5. If not found: proceed without — evolve can work from signals alone
6. Update `outputs/ARTIFACT_INDEX.md` after writing output
7. **Write scratchpad marker:** Update Pipeline State: `- [x] Pipe Resolved: {N} upstream artifacts loaded` or `- [x] Pipe Resolved: none found`

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

## learn <lesson | --auto>

**Purpose:** Two modes — manual teaching (Gary tells gOS) or automatic procedural memory (gOS detects patterns and proposes command modifications).

### Manual mode: `learn <lesson>`

Manually teach gOS something. Faster than waiting for signals to accumulate.

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

### Automatic mode: `learn --auto` (Procedural Memory)

**This is the self-modification engine.** gOS analyzes signal patterns and proposes concrete command file changes. Inspired by LangMem's procedural memory — the agent rewrites its own instructions from experience.

**[skip-gate]** — this is a read-analyze-propose flow, not a side-effect operation. Gate is the approval step at the end.

**Process:**

1. **Gather signal data:**
   - Read `sessions/evolve_signals.md` — all signals
   - Read `.claude/self-model.md` — current competence scores
   - Read `sessions/trust.json` — current trust levels

2. **Detect patterns** (minimum 3 signals per pattern):

   | Pattern | Detection Rule | Action Type |
   |---------|---------------|-------------|
   | **Rework cluster** | 3+ reworks in same command+sub-command | Tighten output constraints |
   | **Reject cluster** | 2+ rejects in same domain | Fundamentally change approach |
   | **Repeat cluster** | 2+ repeats on same correction | Hardcode the correction into command |
   | **Skip cluster** | 3+ skips of same pipeline step | Make step optional or remove it |
   | **Love cluster** | 3+ loves in same command | Extract pattern, apply to weaker commands |
   | **Domain weakness** | Accept rate < 60% with 5+ signals | Overhaul command's domain-specific behavior |

3. **For each detected pattern, generate a modification proposal:**

   ```markdown
   ## Proposal: {command} — {pattern type}

   **Evidence:** {N} {signal_type} signals in {command} > {sub-command}
   **Context samples:**
   - "{context from signal 1}"
   - "{context from signal 2}"
   - "{context from signal 3}"

   **Root cause:** {why this pattern is happening — analyze the contexts}

   **Proposed change:**
   - **File:** `.claude/commands/{command}.md`
   - **Section:** {specific section name}
   - **Before:** {current text, abbreviated}
   - **After:** {proposed text}
   - **Rationale:** {why this change should fix the pattern}

   **Expected impact:** {what should improve — fewer reworks, skips, etc.}
   ```

4. **For love clusters, generate a "spread the pattern" proposal:**

   ```markdown
   ## Proposal: Spread {command} pattern to {weaker_command}

   **Evidence:** {N} love signals in {command} > {sub-command}
   **What works:** {extracted pattern from loved outputs}

   **Proposed change:**
   - **File:** `.claude/commands/{weaker_command}.md`
   - **Section:** {target section}
   - **Addition:** {pattern to transplant}
   ```

5. **Rank proposals by impact:**
   - Reject/repeat clusters → HIGH (these actively frustrate Gary)
   - Rework clusters → MEDIUM (these slow Gary down)
   - Skip clusters → LOW (these are friction, not failure)
   - Love clusters → ENHANCEMENT (these are positive reinforcement)

6. **Present to Gary:**

   ```
   ## Procedural Memory — {N} proposals

   ### HIGH IMPACT
   1. **{command}:** {1-line summary} — {evidence count} signals
      [Show diff] [Apply] [Defer]

   ### MEDIUM IMPACT
   2. **{command}:** {1-line summary} — {evidence count} signals

   ### ENHANCEMENT
   3. **Spread pattern from {command} to {command}**

   Apply all HIGH? Or review individually?
   ```

7. **On approval:**
   - Apply the diff to the command file using Edit tool
   - Commit: `evolve: procedural memory — {summary of changes}`
   - Log to `sessions/evolve_signals.md`: `| {time} | /evolve | learn --auto | accept | Applied {N} procedural memory updates |`
   - Update `self-model.md` if domain competence expectations changed
   - Save to claude-mem: observation capturing what was learned and why

8. **On partial approval:**
   - Apply only approved proposals
   - Save deferred proposals to `~/.claude/evolve/proposals/{command}-{date}.md`
   - These surface in next `/gos` briefing

9. **On rejection:**
   - Log: `| {time} | /evolve | learn --auto | reject | Gary rejected procedural memory proposals |`
   - Do NOT re-propose the same patterns next time (save rejection to feedback memory)

### Automatic trigger (via `/gos save`)

When `/gos save` runs, Part C now includes:
1. Check if `evolve_signals.md` has 10+ unaudited signals
2. If yes, run the pattern detection from step 2 above (silently)
3. If any HIGH impact patterns detected, mention in save report:
   ```
   ⚡ Procedural memory: 2 high-impact patterns detected.
   Run `/evolve learn --auto` to review proposals.
   ```

### What makes this "procedural" not just "feedback"

Regular feedback memory (`memory/feedback_*.md`) records WHAT Gary said. Procedural memory changes HOW gOS behaves. The distinction:

| Type | Example | Storage | Effect |
|------|---------|---------|--------|
| **Feedback** | "Gary prefers dark mode mockups" | memory/feedback_dark_mode.md | Influences decisions |
| **Procedural** | "Design reviews must include mobile screenshot" | .claude/commands/review.md (line 47) | Changes the command itself |

Feedback is advice. Procedural is surgery on the instruction set.

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

## Output Contract (MANDATORY — runs after execution, before presenting)

**You MUST complete all steps before showing output to Gary.** See `gOS/.claude/output-contract.md` for the full rubric.

1. Score on 5 universal dimensions (1-5): Completeness, Evidence, Actionability, Accuracy, Clarity
2. Score on Evolve extension: **Impact** (1-5) — cosmetic change vs measurably changes behavior
3. Identify weakest dimension
4. If any dimension ≤ 2 → flag and offer to improve before Gary reads
5. Apply **Confidence Calibration** to upgrade impact claims (see `gOS/.claude/confidence-calibration.md`):
   - Score each key claim on 6 structural factors → 🟢HIGH / 🟡MEDIUM / 🟠LOW / 🔴SPECULATIVE
   - Include aggregate confidence in scorecard header
   - Flag the single biggest uncertainty
6. Present scorecard + confidence summary at top of output
7. **Write YAML frontmatter** to the output file (per `gOS/.claude/artifact-schema.md`):
   ```yaml
   ---
   artifact_type: decision
   created_by: /evolve {sub-command}
   created_at: {ISO timestamp}
   topic: {WHAT from intent}
   related_specs: [{matched specs}]
   quality_score: {scores from step 1-2}
   status: draft
   ---
   ```
8. **Update `outputs/ARTIFACT_INDEX.md`** — add or update entry for this artifact
9. **Write scratchpad markers:** Update Pipeline State:
   - `- [x] Output Scored: {avg}/5 (weakest: {dimension})`
   - `- [x] Frontmatter Written: {path}`
   - `- [x] Index Updated: {topic} added to ARTIFACT_INDEX`

---

## Red Team Check (runs after Output Contract, before presenting)

**Evolve red team question:** "Will this change actually alter behavior, or is it just documentation?"

1. Run the red team question against the draft output
2. If a genuine issue is found (would change Gary's decision):
   a. Fix it if possible (make the change more impactful)
   b. If not fixable: flag in output header with ⚔️ marker
3. If finding is LOW confidence or wouldn't change any decision → suppress (no noise)
4. **Write scratchpad marker:** Update Pipeline State: `- [x] Red Team Passed: {question asked} → {finding or "clean"}`

---

## Signal Capture Integration (MANDATORY — after every execution)

**After presenting output, observe Gary's NEXT response and classify the signal.**

1. Classify Gary's response as one of:
   - `accept` — used output without changes, moved on
   - `rework` — "change this", "not quite", "try again"
   - `reject` — "no", "scratch that", "wrong approach"
   - `love` — "perfect", "great", "exactly", "hell yes"
   - `repeat` — same instruction given twice (gOS didn't learn)
   - `skip` — Gary jumped past a prescribed step

2. **Log to `sessions/evolve_signals.md`:**
   | Time | Command | Sub-cmd | Signal | Context |
   |------|---------|---------|--------|---------|

3. **Update `sessions/trust.json`** — adjust trust level for the current domain per `gOS/.claude/trust-ladder.md`:
   - `accept`/`love` → increment consecutive accept count
   - `rework`/`reject` → reset count, demote if threshold hit
   - Check progression rules (T0→T1 needs 3+ consecutive accepts)

4. If `repeat` detected → immediately update relevant command file or memory
5. If `love` detected → save the approach to feedback memory for reuse
6. **Write scratchpad marker:** Update Pipeline State: `- [x] Signal Captured: {signal type} for {domain}`
