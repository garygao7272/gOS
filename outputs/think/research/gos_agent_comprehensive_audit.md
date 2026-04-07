# gOS Comprehensive Agent Audit — 10 Dimensions

> Output of `/think research` — 2026-04-08
> Challenge: Rate gOS against ALL dimensions of AI agent correctness, not just the basic 5.
> Then: comprehensive improvement plan with mempalace learnings.

---

## The 10 Dimensions

Most frameworks stop at 5 (Perception, Planning, Action, Memory, Learning). That's incomplete. A production agent also needs: Reasoning, Communication, Autonomy, Reliability, and Metacognition.

---

## Dimension Scorecard

| # | Dimension | Score | Evidence | Critical Gap |
|---|-----------|-------|----------|-------------|
| 1 | **Perception** | 9/10 | 6 MCP servers, spec-rag, Hyperliquid live data, sources feed, Gmail, Linear, Figma, Chrome, Vercel | Minor: no proactive context surfacing from claude-mem at session start. Doesn't "look around" before engaging. |
| 2 | **Planning** | 6/10 | Plan mode exists in `/build plan` and `/think`. Complexity gate in agent framework. Team templates. | **Major: Planning is optional, not enforced.** `/review`, `/design card`, `/ship`, `/simulate` all skip plan decomposition. Gary can say "build X" and code starts immediately. No mandatory decomposition of freeform goals. No dependency graph. No rollback plan. |
| 3 | **Action** | 8/10 | Full tool access, multi-agent dispatch, worktrees, 10 verbs / 33 sub-commands, Figma/Vercel/Chrome | `/build` and `/design` have zero health data. No action verification loop (did the action succeed?). No automatic rollback on failure. No action cost estimation. |
| 4 | **Memory** | 4/10 | 13 flat files in memory/. Palace Protocol documented but not enforced. claude-mem installed (349MB) but barely queried. No layering. No temporal validity. Manual-only capture. | **Worst dimension.** No L0/L1 pre-injection. No episodic memory (linking related sessions). No procedural memory (HOW to do things, only WHAT was decided). No memory decay/freshness. claude-mem is a 349MB asset sitting unused. |
| 5 | **Learning** | 4/10 | Evolve signals exist. Weekly audit cron. 3 audit reports. | **Tied worst.** 4 consecutive audits flag manual-only capture. 30+ sessions with 0 signals. Learning is reactive (only when `/evolve audit` runs). No pattern extraction after sessions. No A/B testing of approaches. No "this worked last time, do it again" reinforcement. |
| 6 | **Reasoning** | 8/10 | Extended thinking enabled. Council voting (12 personas). Adversarial cross-examination in `/think discover`. First-principles decomposition skill. | Good but inconsistent. Council only runs in `/review council`. Other commands do single-perspective reasoning. No devil's advocate pass on /build decisions. No causal chain validation ("if I change X, what breaks?"). |
| 7 | **Communication** | 7/10 | Output discipline (analysis/output tags). Briefing format. Scratchpad checkpoints. | No progress reporting mid-task. Gary sees nothing between "starting" and "done" on long tasks. No confidence calibration ("I'm 60% sure about this approach"). No proactive surfacing of risks before they bite. |
| 8 | **Autonomy** | 7/10 | Conductor pattern routes freeform goals. `/gos <goal>` decomposes. Complexity gate chooses agent count. | But autonomy is inconsistent. Some commands wait for approval (good), others charge ahead (risky). No clear "ask vs proceed" decision framework. No escalation protocol when stuck. |
| 9 | **Reliability** | 6/10 | Scratchpad survives compaction. PreCompact hook (advisory). Stop hook captures signals. | PreCompact is advisory, not blocking — context loss still happens. No checkpoint/rollback mechanism. No retry logic on failed actions. No graceful degradation (if MCP server is down, what's the fallback?). Session state in JSON is fragile. |
| 10 | **Metacognition** | 5/10 | Evolve audit scores commands. Signal types track feedback. | No real-time self-monitoring ("I'm at 60% context, should I compact?"). No confidence scoring on outputs. No "I don't know" detection. No tracking of which approaches work for which types of tasks. No awareness of own biases or blind spots. |

**Overall: 6.4/10** — Perception and Reasoning are strong. Planning, Memory, Learning, and Metacognition are holding the system back.

---

## Comprehensive Improvement Plan

### PLANNING (6/10 → 9/10)

**The core problem:** Planning is available but not enforced. Gary can invoke any command and it starts executing immediately. This leads to: wrong scope, missed dependencies, wasted context on approaches that should have been questioned first.

**Gary's mandate:** "I want decomposition using plan mode to be enforced for EVERY ask in general, and every single command in gOS."

#### P1. Mandatory Plan Gate on Every Command

**What:** Every gOS command (think, design, build, review, ship, simulate, refine, evolve) must present a 3-line plan before executing. Not full Plan Mode — a lightweight "here's what I'm about to do, confirm?" gate.

**Format:**
```
PLAN: [1-line goal restatement]
STEPS: [numbered list, 2-5 items]
RISK: [biggest risk or assumption]
CONFIRM? [y/modify/abort]
```

**Implementation:**
- Add a `## Plan Gate (mandatory)` section to EVERY command .md file
- The gate fires BEFORE any tool call, agent spawn, or file read beyond the initial context load
- For trivial tasks (<3 steps), the gate is 2 lines. For complex tasks, it expands.
- Gary can say "y" to proceed, modify the plan, or abort
- The approved plan gets written to scratchpad as the execution contract

**Files to modify:** All 9 command files + gos.md conductor section

#### P2. Freeform Goal Decomposition in Conductor

**What:** When Gary gives gOS a freeform goal (not a verb), the conductor must decompose it into a dependency-ordered task graph before executing anything.

**Format:**
```
GOAL: {restated goal}
DECOMPOSITION:
  1. [verb] [sub-command] [target] — {why this first}
  2. [verb] [sub-command] [target] — {depends on #1 because...}
  3. [verb] [sub-command] [target] — {depends on #2 because...}
PARALLEL: {which steps can run concurrently}
ESTIMATE: {context cost — light/medium/heavy}
```

**Implementation:**
- Update gos.md conductor flow: between "parse intent" and "execute", insert mandatory decomposition
- The decomposition uses the 8 verbs as primitives — every step maps to a verb
- Dependencies are explicit ("step 3 needs step 2's output")
- Parallel opportunities are identified upfront
- Context cost is estimated (will this fit in one session or need dispatch?)

#### P3. Pre-Action Dependency Check

**What:** Before every action (file edit, agent spawn, command execution), check: does this action have unmet dependencies? Is there context I should have loaded first?

**Implementation:**
- Add to the Plan Gate: a "prerequisites" field
- For /build: "Have I read the spec? Have I read existing code? Have I run tests?"
- For /design card: "Have I read DESIGN.md? Have I read the journey map? Have I checked reference apps?"
- For /review: "Have I read the full diff? Have I loaded the spec it implements?"
- Codify these as checklists per command

#### P4. Rollback Planning

**What:** Every plan includes a rollback strategy. What happens if this fails?

**Implementation:**
- Add `ROLLBACK:` field to the Plan Gate format
- For /build: "git stash, revert to last commit"
- For /design: "restore from specs/Archive/"
- For /ship: "git revert, unpublish"
- Not every task needs it, but the field forces the thought

#### P5. Plan Versioning

**What:** When Gary modifies a plan mid-execution, the modification is recorded. This creates an audit trail of scope changes.

**Implementation:**
- Scratchpad gets a `## Plan History` section
- Each modification: `v1 → v2: removed step 3, added step 4 (Gary: "skip the tests for now")`
- This feeds into Learning — we can detect patterns like "Gary always skips X"

---

### ACTION (8/10 → 9.5/10)

#### A1. Action Verification Loop

**What:** After every significant action (file write, commit, deploy, agent completion), verify the action succeeded. Don't assume.

**Implementation:**
- After Edit/Write: read the file back, confirm the change is what was intended
- After git commit: verify commit appears in log
- After agent spawn: check agent returned, parse result
- After MCP call: check response is valid, not error
- Add a `## Verification` section to each command that lists what to check after each action type

#### A2. Action Cost Estimation

**What:** Before spawning agents or reading large files, estimate the context cost. "This will use ~15% of context. Proceed?"

**Implementation:**
- Track approximate context usage in scratchpad (already have `Context: ~5%`)
- Before heavy operations: estimate cost and warn if >50% remaining
- Suggest dispatch to fresh-context agent when operation would exceed 70%

#### A3. Graceful Degradation

**What:** When an MCP server is down or a tool fails, have a fallback plan instead of stopping.

**Implementation:**
- Map each MCP to its fallback:
  - Figma MCP down → use get_design_context API directly
  - Hyperliquid MCP down → use WebFetch to API
  - spec-rag down → use Grep on specs/ directory
  - sources down → use WebSearch
- Add fallback routing to each command that depends on MCPs

#### A4. Action Registry

**What:** Log every significant action (not just signals) to enable replay and debugging.

**Implementation:**
- Lightweight action log in scratchpad: `[14:30] Edit specs/Arx_3-2.md:45 — added acceptance criteria`
- This is NOT the same as evolve signals (which track Gary's reaction). This tracks what gOS DID.
- Useful for: "what did you change?" questions, rollback, and session handoff

---

### MEMORY (4/10 → 8/10)

**The mempalace lesson:** Raw verbatim text with good search is better than summarized vectors. But it needs structure — layers, temporal validity, and proactive injection.

#### M1. 4-Layer Memory Stack

**What:** Restructure memory/ into layers with hard token budgets.

```
L0: Identity (≤100 tokens) — ALWAYS in system prompt
    → WHO is Gary, WHAT is Arx, HOW to behave
    → File: memory/L0_identity.md
    → Loaded via: CLAUDE.md reference or settings.json env injection

L1: Essential Story (≤800 tokens) — ALWAYS in context at session start
    → Active project state, current sprint, recent decisions, active feedback rules
    → File: memory/L1_essential.md
    → Updated: every /gos save, every session end
    → Loaded via: gOS briefing reads this first

L2: On-Demand (search-triggered) — Loaded when relevant
    → All current memory/ files (feedback, project, reference, evolve)
    → Loaded via: Palace Protocol (search before answering)
    → Budget: unlimited, but only load what's needed

L3: Deep Search (claude-mem + spec-rag) — Semantic search across all history
    → 349MB claude-mem database, spec embeddings
    → Loaded via: explicit search when L2 doesn't have the answer
    → Budget: unlimited
```

**Implementation:**
- Create `memory/L0_identity.md` — 100-token Gary + Arx identity
- Create `memory/L1_essential.md` — 800-token active state (auto-updated)
- Restructure MEMORY.md to annotate each file with its layer
- Update gOS briefing to load L1 before anything else
- Update all commands to query L2 before answering from recall

#### M2. Temporal Fact Validity

**What:** Every memory file gets `valid_from` and `valid_to` in frontmatter. Facts expire.

**Implementation:**
- Add to frontmatter: `valid_from: 2026-04-08`, `valid_to: (open)` or `valid_to: 2026-05-01`
- When loading a memory: check if `valid_to` has passed. If so, flag as stale.
- Scheduled task: weekly memory freshness scan — find files with expired `valid_to`
- Enable temporal queries: "what was true in March?" → filter by valid_from/valid_to

#### M3. Episodic Memory (Session Linking)

**What:** Link related sessions into episodes. "The financial modeling work" is an episode spanning 30+ sessions. Currently these sessions are disconnected — each starts fresh.

**Implementation:**
- Add `episode` field to session save files: `episode: financial-modeling-v12`
- When resuming or starting: query claude-mem for the episode to load prior decisions
- Episode index in memory/: `episodes.md` listing active episodes with session counts
- This is how gOS answers: "what have we tried before for this?" — by loading the episode

#### M4. Procedural Memory (HOW-TO)

**What:** Currently memory stores WHAT was decided, not HOW to do things. Procedural memory captures proven workflows.

**Implementation:**
- New memory type: `procedure`
- Example: "How to update the financial model: 1) Read current xlsx 2) Use OfficeCLI not openpyxl 3) Verify with soffice --headless 4) Cross-check breakeven"
- Extracted from: successful sessions where the workflow was validated
- Loaded: when gOS is about to do a task it's done before — check for procedure first

#### M5. Proactive Memory Recall

**What:** At session start and before every command, proactively search memory for relevant context. Don't wait for Gary to ask.

**Implementation:**
- gOS briefing: after loading L1, search L2+L3 for anything related to current task
- Before each command: quick search for "last time we did /design card" or "known issues with /build feature"
- Surface findings: "Note: last time you tried X, you hit Y. Want to adjust approach?"
- This is the Palace Protocol upgrade: from "search when asked" to "search always"

#### M6. Blocking PreCompact Hook

**What:** Upgrade the PreCompact hook from advisory (prompt) to blocking (decision: block).

**Implementation:**
- Change hook type from `prompt` to a script that:
  1. Saves all unsaved context to scratchpad
  2. Logs any unrecorded signals
  3. Updates L1_essential.md with current state
  4. Creates a claude-mem observation
  5. Only THEN allows compaction
- This prevents the "30+ sessions with 0 signals" problem — compaction forces a save

#### M7. Save-Interval Trigger

**What:** Auto-save every 15 human messages, not just at session end.

**Implementation:**
- Add a counter to the Stop hook or UserPromptSubmit hook
- Every 15 messages: trigger a mini-save (update scratchpad + L1 + signals)
- This catches long sessions where save never triggers

#### M8. Memory Garbage Collection

**What:** Periodically prune stale, duplicate, or contradicted memories.

**Implementation:**
- Weekly scheduled task: scan memory/ for:
  - Files with expired `valid_to`
  - Files that contradict current codebase state (Palace Protocol verification)
  - Duplicate content across files
- Propose deletions/updates for Gary's approval

---

### LEARNING (4/10 → 8/10)

#### L1. Auto-Signal Capture (PostToolUse Hook)

**What:** Wire a PostToolUse hook that detects signal-worthy moments and logs them automatically.

**Detection heuristics:**
- `accept`: Gary's next message after gOS output doesn't reference problems, moves to new topic
- `rework`: Gary's message contains "change", "not quite", "try again", "simplify", "more", "less"
- `reject`: Gary's message contains "no", "scratch that", "wrong", "stop"
- `love`: Gary's message contains "perfect", "great", "exactly", "hell yes", "love"
- `repeat`: Gary says something semantically similar to what they said 2-3 turns ago
- `skip`: Gary invokes next step without completing current prescribed step

**Implementation:**
- UserPromptSubmit hook that scans Gary's message for signal keywords
- If detected: append to evolve_signals.md with timestamp, command, context
- False positive rate is acceptable — better to over-capture than miss (current: 40% coverage → target: 80%)

#### L2. Pattern Extraction After Every Session

**What:** Don't wait for `/evolve audit`. Extract patterns after every session.

**What to extract:**
- Approaches that worked (→ procedural memory)
- Approaches that failed (→ dead ends, don't retry)
- New feedback rules (→ feedback memory)
- Preference signals (→ user memory)

**Implementation:**
- Enhance the Stop hook: after signal capture, run a 3-question self-debrief:
  1. "What approach worked that I should reuse?"
  2. "What approach failed that I should avoid?"
  3. "Did Gary correct me in a way that reveals a preference?"
- If any answers are non-trivial: write to memory/ and evolve_signals.md

#### L3. Reinforcement Loops (Do More of What Works)

**What:** When starting a task, check: "have I done something similar before? What worked?"

**Implementation:**
- Before each command: search claude-mem for similar past invocations
- If found: load the approach that got `accept` or `love` signals
- If the past approach got `rework` or `reject`: load the correction and apply it
- This is how gOS stops making the same mistake twice

#### L4. A/B Approach Tracking

**What:** When there are multiple valid approaches, track which one Gary prefers.

**Implementation:**
- When presenting alternatives: log which one Gary chose
- Over time: build a preference model (e.g., "Gary prefers terse over verbose", "Gary prefers code-first over spec-first for UI")
- This already partially exists in feedback memories — formalize it

#### L5. Drift Detection

**What:** Detect when gOS's behavior drifts from Gary's preferences.

**Detection signals:**
- Increasing `rework` rate on a command (was 10%, now 30%)
- `repeat` signals (Gary had to re-explain)
- Feedback memories that contradict current behavior

**Implementation:**
- Scheduled task: weekly drift check
- Compare recent signals against historical baseline
- If drift detected: generate a specific upgrade proposal

#### L6. Cross-Session Learning Transfer

**What:** Learnings from one project should inform other projects where applicable.

**Implementation:**
- claude-mem already supports cross-project queries
- Add to session debrief: "Is this learning Arx-specific or universal?"
- Universal learnings → global memory (user preferences, workflow patterns)
- Arx-specific → project memory

---

### REASONING (8/10 → 9/10)

#### R1. Devil's Advocate Pass on Every Plan

**What:** Before executing any plan, run a quick adversarial check: "What could go wrong? What am I assuming?"

**Implementation:**
- Add to Plan Gate: after Gary confirms, run a 30-second adversarial pass
- Check: "Am I assuming a file exists? Am I assuming an API works? Am I assuming Gary wants X when they said Y?"
- Surface any concerns before starting

#### R2. Causal Chain Validation

**What:** Before changing code or specs, trace the causal chain: "If I change X, what else changes?"

**Implementation:**
- For spec changes: check downstream specs (cascade rule in CLAUDE.md)
- For code changes: check imports, tests, and dependents
- Surface: "Changing this file will affect: [list]. Want me to update those too?"

---

### COMMUNICATION (7/10 → 9/10)

#### C1. Progress Reporting Mid-Task

**What:** For tasks >5 minutes, report progress every 2-3 actions. Gary sees nothing between "starting" and "done" currently.

**Implementation:**
- After every 3 tool calls or every agent completion: print a 1-line status
- Format: `[3/7] Read spec, loaded design system, now generating layout...`
- Use TodoWrite for this — it's already there but underused

#### C2. Confidence Calibration

**What:** When presenting plans, recommendations, or outputs, include a confidence level.

**Implementation:**
- Add to Plan Gate: `CONFIDENCE: high/medium/low — {reason}`
- Add to output: "I'm ~70% confident this approach is right because X, but Y could be wrong"
- This helps Gary calibrate how much to trust vs verify

#### C3. Proactive Risk Surfacing

**What:** Don't wait for Gary to discover risks. Surface them before they bite.

**Implementation:**
- Before each action: check if there's a known risk (from memory, from dead ends, from feedback)
- Surface: "Warning: last time we edited this file, we hit X. I'll avoid that by doing Y."

---

### AUTONOMY (7/10 → 8.5/10)

#### AU1. Ask vs Proceed Decision Framework

**What:** Formalize when gOS should ask Gary vs proceed autonomously.

```
PROCEED (no ask):
  - Reading files, searching, gathering context
  - Auto-fixing formatting, imports, typos
  - Running tests
  - Updating scratchpad/signals

ASK (always):
  - Architectural decisions
  - Deleting or moving files
  - Changing specs
  - Deploying
  - Sending messages (email, Slack, PR)
  - Spending money (API calls with cost)
  - Any irreversible action

JUDGMENT (use confidence):
  - Fixing a bug (ask if <80% confident in root cause)
  - Refactoring (ask if it changes public API)
  - Adding a dependency (ask always — Gary has opinions)
```

#### AU2. Stuck Escalation Protocol

**What:** When gOS is stuck (3 failed attempts at the same thing), escalate to Gary with context.

**Implementation:**
- Track retry count in scratchpad
- After 3 failures: stop, summarize what was tried, ask Gary for direction
- Don't silently try a 4th approach

---

### RELIABILITY (6/10 → 8.5/10)

#### RE1. Checkpoint/Rollback Mechanism

**What:** Before risky operations, create a checkpoint. If the operation fails, rollback.

**Implementation:**
- `git stash` before multi-file edits
- Record checkpoint in scratchpad: `CHECKPOINT: stash@{0} at 14:30`
- On failure: `git stash pop` to restore
- Already have /checkpoint skill — enforce its use

#### RE2. MCP Health Check at Session Start

**What:** At briefing time, ping all MCPs to verify they're responsive.

**Implementation:**
- During gOS briefing: call a lightweight operation on each MCP
- If any fails: note in briefing ("Figma MCP is down — /design ui will use fallback")
- This prevents mid-task failures

#### RE3. Idempotent Operations

**What:** Every gOS operation should be safe to retry. If it fails halfway, running it again should work.

**Implementation:**
- File writes: use Edit (diff-based) not Write (full replace) wherever possible
- Git operations: check state before acting (don't commit if nothing staged)
- Agent spawns: check if team already exists before creating

---

### METACOGNITION (5/10 → 8/10)

#### MC1. Context Budget Awareness

**What:** Track context usage and proactively manage it.

**Implementation:**
- Update scratchpad `Context: ~X%` after every major operation
- At 50%: suggest compacting or dispatching to fresh agent
- At 70%: mandatory compact warning
- At 80%: auto-compact (already set via CLAUDE_AUTOCOMPACT_PCT_OVERRIDE)

#### MC2. Confidence Scoring on Outputs

**What:** Every output gets an internal confidence score. Low confidence → flag for review.

**Implementation:**
- After generating any output: self-assess confidence
- <70% confidence: flag to Gary: "I'm not fully confident in this. Key uncertainty: {what}"
- This prevents the "gOS sounds confident but is wrong" failure mode

#### MC3. "I Don't Know" Detection

**What:** When gOS doesn't have enough information to answer, say so instead of guessing.

**Implementation:**
- Before answering any factual question: check Palace Protocol (search first)
- If search returns nothing: "I don't have this in my records. Want me to research it?"
- Never fabricate facts about: Gary's preferences, past decisions, project state, market data

#### MC4. Bias Awareness

**What:** Track known biases and compensate.

**Known gOS biases:**
- Over-engineering: tends to add more structure than needed
- Scope creep: tends to expand tasks beyond what was asked
- Recency bias: over-weights recent sessions, under-weights old decisions
- Confirmation bias: tends to support Gary's initial framing rather than challenging it

**Implementation:**
- Add bias checklist to Plan Gate: "Am I over-engineering? Am I expanding scope? Am I just confirming Gary's assumption?"
- The /review council contrarian persona already does this — extend it to all commands

---

## Implementation Priority Matrix

### Phase 1: Foundation (This Session)

| # | Item | Dimension | Impact | Files |
|---|------|-----------|--------|-------|
| 1 | M1: L0+L1 memory files | Memory | HIGH | memory/L0_identity.md, memory/L1_essential.md, MEMORY.md |
| 2 | P1: Plan Gate template | Planning | HIGH | All 9 command .md files |
| 3 | L1: Auto-signal capture hook | Learning | HIGH | .claude/settings.json |
| 4 | M6: Blocking PreCompact | Memory | HIGH | .claude/settings.json |
| 5 | C1: TodoWrite enforcement | Communication | MEDIUM | All command .md files |

### Phase 2: Intelligence (Next Session)

| # | Item | Dimension | Impact | Files |
|---|------|-----------|--------|-------|
| 6 | P2: Freeform goal decomposition | Planning | HIGH | gos.md conductor section |
| 7 | M2: Temporal validity frontmatter | Memory | MEDIUM | All memory/ files |
| 8 | M5: Proactive memory recall | Memory | HIGH | All command .md files |
| 9 | L2: Pattern extraction on Stop | Learning | HIGH | .claude/settings.json |
| 10 | MC1: Context budget awareness | Metacognition | MEDIUM | Scratchpad + commands |

### Phase 3: Robustness (Future)

| # | Item | Dimension | Impact | Files |
|---|------|-----------|--------|-------|
| 11 | A1: Action verification loop | Action | MEDIUM | All command .md files |
| 12 | A3: Graceful degradation | Action | MEDIUM | gos.md + MCP fallback map |
| 13 | RE1: Checkpoint/rollback | Reliability | MEDIUM | Build/ship commands |
| 14 | R1: Devil's advocate pass | Reasoning | MEDIUM | Plan Gate addition |
| 15 | L3: Reinforcement loops | Learning | HIGH | Command preambles |

### Phase 4: Excellence (Ongoing)

| # | Item | Dimension | Impact | Files |
|---|------|-----------|--------|-------|
| 16 | M3: Episodic memory | Memory | MEDIUM | Session save + claude-mem |
| 17 | M4: Procedural memory | Memory | MEDIUM | New memory type |
| 18 | L5: Drift detection | Learning | MEDIUM | Scheduled task |
| 19 | MC2: Confidence scoring | Metacognition | MEDIUM | Output format |
| 20 | AU1: Ask vs Proceed framework | Autonomy | MEDIUM | All commands |
| 21 | M7: Save-interval trigger | Memory | MEDIUM | .claude/settings.json |
| 22 | M8: Memory garbage collection | Memory | LOW | Scheduled task |
| 23 | RE2: MCP health check | Reliability | LOW | gOS briefing |
| 24 | C2: Confidence calibration | Communication | LOW | Output format |
| 25 | MC4: Bias awareness | Metacognition | LOW | Plan Gate checklist |
| 26 | P3: Pre-action dependency check | Planning | MEDIUM | Command checklists |
| 27 | P4: Rollback planning | Planning | LOW | Plan Gate field |
| 28 | P5: Plan versioning | Planning | LOW | Scratchpad format |
| 29 | L4: A/B approach tracking | Learning | LOW | Signal system |
| 30 | L6: Cross-session learning transfer | Learning | LOW | claude-mem config |
| 31 | R2: Causal chain validation | Reasoning | MEDIUM | Build/design commands |
| 32 | C3: Proactive risk surfacing | Communication | MEDIUM | Memory + Plan Gate |
| 33 | AU2: Stuck escalation protocol | Autonomy | LOW | All commands |
| 34 | RE3: Idempotent operations | Reliability | LOW | All commands |
| 35 | A4: Action registry | Action | LOW | Scratchpad format |
| 36 | MC3: "I don't know" detection | Metacognition | MEDIUM | Palace Protocol upgrade |
| 37 | A2: Action cost estimation | Action | LOW | Agent dispatch |

---

## Projected Scores After Full Implementation

| Dimension | Current | After Phase 1 | After Phase 2 | After All |
|-----------|---------|---------------|---------------|-----------|
| Perception | 9 | 9 | 9.5 | 9.5 |
| Planning | 6 | 8 | 9 | 9.5 |
| Action | 8 | 8.5 | 8.5 | 9.5 |
| Memory | 4 | 6.5 | 8 | 9 |
| Learning | 4 | 6 | 7.5 | 8.5 |
| Reasoning | 8 | 8 | 8.5 | 9 |
| Communication | 7 | 8 | 8.5 | 9 |
| Autonomy | 7 | 7 | 7.5 | 8.5 |
| Reliability | 6 | 7 | 7.5 | 8.5 |
| Metacognition | 5 | 5.5 | 7 | 8 |
| **Overall** | **6.4** | **7.3** | **8.1** | **8.9** |

---

## The Plan Gate Template (for all commands)

This is the universal template to inject into every command file:

```markdown
## Plan Gate (mandatory — runs before any action)

Before executing, present:

> **PLAN:** [1-line goal restatement in your own words — comprehension check]
> **STEPS:**
> 1. [action] — [why]
> 2. [action] — [depends on #1 because...]
> 3. [action] — [why]
> **RISK:** [biggest assumption or thing that could go wrong]
> **MEMORY:** [anything from L1/L2 relevant to this task — "last time: ...", "known issue: ..."]
> **CONFIDENCE:** [high/medium/low] — [1-line reason]
>
> **Confirm?** [y / modify / abort]

Wait for Gary's explicit confirmation before proceeding.

After confirmation:
1. Write approved plan to scratchpad
2. Create TodoWrite items for each step
3. Begin execution step by step
```

---

## Sources

- mempalace — 4-layer stack, Palace Protocol, temporal validity
- claude-mem — 349MB semantic DB, 5 lifecycle hooks, observation model
- shanraisshan/claude-code-best-practice — initialPrompt, drift detection
- ECC continuous-learning-v2 — instinct-based pattern extraction
- Anthropic agent design guidelines — ask vs proceed, escalation protocol
- 4 consecutive evolve audits — signal capture gap, data quality warnings
