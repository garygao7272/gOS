# PEV Protocol — Planner-Executor-Validator Loop

> Universal execution primitive for every gOS command. Replaces hardcoded agent rosters.

## The loop

```
Task received
  ↓
[1] PLAN — pev-planner reads REGISTRY.yaml, picks roster, writes contracts → roster.json
  ↓
[2] GATE — Gary reviews roster summary (1 line per agent), approves or edits
  ↓
[3] EXECUTE — roster spawns in parallel, each writes artifact + blackboard append
  ↓
[4] VALIDATE — pev-validator reads all artifacts (fresh context), scores convergence
  ↓
[5] DECIDE
   ├─ CONVERGED → synthesizer (adjudicator) writes final output → present to Gary
   ├─ ITERATE  → planner revises roster/contracts, spawn round N+1
   └─ STUCK   → escalate to Gary with what was tried
```

## Artifacts per job

```
outputs/gos-jobs/{job-id}/
├── roster.json              # Current round's roster + contracts
├── blackboard.md            # Append-only, read by all agents
├── artifacts/
│   ├── {agent-id}.md        # Each executor's output
│   └── ...
├── round-1/
│   ├── roster.json          # Snapshot of round 1 roster
│   └── verdict.md           # Validator's verdict
├── round-2/
│   └── ...
├── synthesis.md             # Final synthesized output (when CONVERGED)
└── report.md                # Summary to Gary (rounds completed, cost, verdict)
```

## roster.json schema

```json
{
  "job_id": "think-discover-copy-leaderboard-2026-04-15",
  "command": "/think discover",
  "task": "Should Arx surface a top-copier leaderboard?",
  "task_class": "exploration",
  "risk_level": "medium",
  "round": 1,
  "max_rounds": 3,
  "roster": [
    {
      "agent": "first-principles",
      "model": "opus",
      "contract": {
        "lens": "Decompose to atomic assumptions. Challenge each.",
        "task": "What assumptions does 'leaderboard surfaces top copiers' make? Challenge them.",
        "reads": ["memory/L0_identity.md"],
        "writes": "outputs/gos-jobs/{job-id}/artifacts/first-principles.md",
        "exit_criteria": ["≥5 assumptions listed", "each challenged with mechanism"],
        "forbidden": ["proposing design", "recommending build"]
      }
    },
    {
      "agent": "copier",
      "model": "sonnet",
      "contract": {
        "lens": "I copy others. I fear losing money. I need trust.",
        "task": "Would I trust a leaderboard? What would make me suspicious? What would earn my copy?",
        "reads": ["specs/Arx_2-1_Personas.md"],
        "writes": "outputs/gos-jobs/{job-id}/artifacts/copier.md",
        "exit_criteria": ["3 trust signals named", "3 red flags named"],
        "forbidden": ["speaking for pro traders"]
      }
    }
  ],
  "synthesis_agent": "adjudicator",
  "validator_agent": "pev-validator",
  "convergence_criteria": {
    "max_rounds": 3,
    "new_info_threshold": 0.2,
    "agreement_threshold": 0.8,
    "veto_halts": true
  }
}
```

## verdict.md schema

See `agents/pev-validator.md` Step 6 for full format. Key fields:
- `Verdict`: CONVERGED | ITERATE | STUCK
- `Agreement`: 0.0–1.0
- `New-info delta`: 0.0–1.0
- `Veto status`: cleared | BLOCKED by {agent}
- `Remaining gaps`: ranked CRITICAL → LOW
- `Next action`: roster adjustment (ITERATE) | escalation (STUCK) | synthesis plan (CONVERGED)

## Blackboard protocol

`outputs/gos-jobs/{job-id}/blackboard.md`

- **Append-only.** Once written, lines are never edited or deleted.
- **Each append timestamped + signed** with agent id: `[2026-04-15T10:23:00 — crypto-sec] ...`
- **Sections owned by agent** — each agent has a named section; don't write in others' sections.
- **Purpose:** cross-agent coordination without prompt round-trip. Agents read blackboard at start of their turn.

Example:

```markdown
# Blackboard — job think-discover-copy-leaderboard

## crypto-sec (veto)
[2026-04-15T10:23:00 — crypto-sec] Flagging: leaderboard exposes trader addresses → doxing risk. Escalating to MEDIUM unless PII stripped.

## copier
[2026-04-15T10:24:12 — copier] Agree with crypto-sec on doxing — I would not want my copies public either.

## pro-trader
[2026-04-15T10:24:30 — pro-trader] Disagree. Public verification is what makes alpha real. Pseudo-anonymous (ENS) is enough.

## first-principles
[2026-04-15T10:25:00 — first-principles] The disagreement is about WHO the leaderboard serves. Unpack: is this for discovery (pro-trader-optimal) or copy-decision (copier-optimal)?
```

## Convergence heuristics

Validator scores:

| Metric | Formula | Threshold |
|---|---|---|
| Agreement | # agents aligned on core claim / total agents | ≥ 0.8 = converged |
| New-info delta | new findings this round / total findings | < 0.2 = converged |
| Gap severity | Max(CRITICAL=4, HIGH=3, MEDIUM=2, LOW=1) over remaining | 0 new CRITICAL ≥ converged |
| First-principles depth | fraction of claims with named mechanism | ≥ 0.7 = pass INV-G01 |

Fail ANY threshold in a round < max_rounds → ITERATE.
Same gaps in N-1 and N, OR round = max_rounds with CRITICAL → STUCK.
Any veto agent BLOCK → STUCK immediately.

## Integration with existing commands

Each command adds this block (replacing hardcoded roster sections):

```markdown
## Execution — PEV

1. Spawn pev-planner with task + command pool hint → roster.json
2. Present roster to Gary, wait for approval
3. Spawn roster in parallel (each writes to artifacts/ + blackboard.md)
4. Spawn pev-validator (fresh context) → round-{N}/verdict.md
5. If CONVERGED → adjudicator synthesizes → present
   If ITERATE → planner revises → spawn round N+1 (max 3)
   If STUCK → escalate to Gary
```

Command-specific content shrinks to: purpose, default pool hint, output location.

## Invariants enforced

- INV-G01 (first-principles) — validator scores mechanism depth
- INV-G10 (synthesis boundary) — planner writes contracts with IN/OUT/NEVER
- INV-G06 (compliance matrix) — synthesizer produces one for `/build` jobs
- INV-G12 (confidence) — planner, validator, adjudicator all end with confidence

## Cost caps

- Planner: 1 opus call (~3K tokens)
- Executors: 3–7 parallel (sonnet-heavy, some opus for meta)
- Validator: 1 sonnet call (~5K tokens)
- Synthesizer: 1 opus call (~4K tokens)
- Max 3 rounds → ~100K tokens ceiling per job

If job exceeds 150K tokens without converging → STUCK (cost-circuit-break).
