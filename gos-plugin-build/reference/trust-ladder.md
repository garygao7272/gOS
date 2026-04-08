# Trust Ladder — Domain-Specific Autonomy

> Referenced by all gOS commands. Adjusts Intent Gate depth based on earned trust per domain.

## The 4 Trust Levels

| Level | Name | Behavior | Gary's Experience |
|-------|------|----------|-------------------|
| **T0** | Advisory | Present options, Gary decides everything | "Here are 3 approaches. Which one?" |
| **T1** | Collaborative | gOS recommends, Gary confirms | "I recommend X. Go?" |
| **T2** | Delegated | gOS acts, Gary reviews after | "Done. Here's what I did: [summary]" |
| **T3** | Autonomous | gOS acts, no review needed | (silent — logged to scratchpad) |

## Trust Domains

Trust is tracked per domain, not per command. Domains are granular capabilities:

| Domain | Default | Floor | Description |
|--------|---------|-------|-------------|
| `commit-messages` | T0 | none | Writing git commit messages |
| `code-review` | T0 | none | Reviewing code quality |
| `design-decisions` | T0 | none | Making visual/UX choices |
| `spec-writing` | T0 | none | Writing or updating specs |
| `research-synthesis` | T0 | none | Synthesizing research findings |
| `financial-modeling` | T0 | T1 | Financial models and projections |
| `hiring-decisions` | T0 | none | Hiring briefs and evaluations |
| `architecture` | T0 | none | Technical architecture decisions |
| `naming-conventions` | T0 | none | Naming files, variables, features |
| `test-writing` | T0 | none | Writing tests and test strategy |
| `deployment` | T0 | T1 | Deploying to production |
| `public-communications` | T0 | T1 | Social posts, blog posts, emails |
| `security` | T0 | T1 | Security-related decisions |
| `formatting` | T0 | none | Auto-fixing formatting, imports |

## Progression Rules

```
T0 → T1: 3+ consecutive accepts, 0 rejects in last 5 interactions
T1 → T2: 8+ consecutive accepts, 0 rejects in last 10 interactions
T2 → T3: ONLY by explicit Gary grant ("you can handle X autonomously")

Never auto-promote to T3. Gary must say it.
```

## Demotion Rules

```
Any reject signal    → drop 1 level immediately
2 reworks in 5       → drop 1 level
Gary says "ask me"   → reset to T0 for that domain
```

## Floor Rules

Some domains have a trust floor — they cannot go above a certain level without explicit Gary grant:

```
deployment              → never above T1 without explicit grant
security                → never above T1 without explicit grant
financial-modeling      → never above T1 without explicit grant
public-communications   → never above T1 without explicit grant
```

## How Trust Changes the Intent Gate

After the DECOMPOSE step, check trust level for the inferred domain:

```
T0: Full gate → DECOMPOSE → CLARIFY → PLAN → CONFIRM (hard stop) → Execute
T1: DECOMPOSE → PLAN (🔮 inferences auto-confirmed) → CONFIRM → Execute
T2: DECOMPOSE (shown as FYI, no confirm needed) → Execute → Present summary after
T3: Execute silently → Log to scratchpad only
```

## State File

Trust state persists at `sessions/trust.json`. Read on session start, write after each signal.

```json
{
  "domains": {
    "domain-name": {
      "level": 0,
      "history": [
        {"signal": "accept", "date": "2026-03-23", "context": "description"}
      ],
      "consecutive_accepts": 0,
      "last_reject": null,
      "floor": null
    }
  },
  "last_updated": "ISO timestamp"
}
```

## Signal Integration

After every command completes, the Signal Capture step:
1. Determines the domain from the command context
2. Records the signal (accept/rework/reject) to `trust.json`
3. Checks progression/demotion rules
4. If trust level changed: log to scratchpad and notify Gary
   "Trust update: `code-review` promoted from T0 → T1 (3 consecutive accepts)"
