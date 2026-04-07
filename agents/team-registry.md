# Team Registry — Pre-built Team Templates

> Verbs load templates by name. The conductor spawns agents from the roster and wires them per template.

---

## think-swarm

**Use:** `/think discover`, `/think research`, `/think decide`
**Why team:** Adversarial cross-examination finds blind spots a single researcher misses.

### Composition

| Role | Agent | Model | Specialization (set in spawn prompt) |
|------|-------|-------|--------------------------------------|
| Lead | researcher | sonnet | Cross-examination moderator, synthesis |
| Member 1 | researcher | sonnet | Primary domain (varies by sub-command) |
| Member 2 | researcher | sonnet | Counter-perspective or adjacent domain |
| Member 3 | researcher | haiku | Fact-checker, data verification |

**Sub-command role mapping:**

| Sub-command | Member 1 | Member 2 | Member 3 |
|-------------|----------|----------|----------|
| `discover` | PM/JTBD analyst | First-principles decomposer | Market data verifier |
| `research` | Deep researcher | Competitor crawler | Cross-referencer with specs |
| `decide` | White+Yellow hat (upside) | Red+Black hat (risk) | Green hat (alternatives) |

For `decide`, the Lead acts as Blue hat (synthesis) on opus instead of sonnet.

### Task Flow

```
TaskCreate("research-primary", owner="member-1")
TaskCreate("research-counter", owner="member-2")
TaskCreate("fact-check", owner="member-3", blockedBy=["research-primary", "research-counter"])
TaskCreate("cross-examine", owner="lead", blockedBy=["fact-check"])
TaskCreate("synthesize", owner="lead", blockedBy=["cross-examine"])
```

### Handoff

- Members write findings to `outputs/gos-jobs/{job-id}/{role}-findings.md`
- Lead reads all findings, then initiates cross-examination via `SendMessage`
- Cross-examination: Lead sends contradictions to members, members defend or concede
- Lead synthesizes final output to `outputs/think/{sub-command}/{slug}.md`

### Shutdown Condition

Lead completes synthesis. Conductor verifies output exists, then shuts down team.

---

## build-squad

**Use:** `/build feature` (complexity gate 7+)
**Why team:** Backend/frontend/tests can advance in parallel when API contract is established early.

### Composition

| Role | Agent | Model | Isolation | Focus |
|------|-------|-------|-----------|-------|
| Architect | architect | opus | shared | API contract, data model, types |
| Backend | engineer | sonnet | worktree | API implementation, data layer |
| Frontend | engineer | sonnet | worktree | Screens, components, hooks |
| Verifier | verifier | haiku | shared | Tests, screenshots, e2e |

### Task Flow

```
TaskCreate("read-spec", owner="architect")
TaskCreate("api-contract", owner="architect", blockedBy=["read-spec"])
TaskCreate("backend-impl", owner="backend", blockedBy=["api-contract"])
TaskCreate("frontend-impl", owner="frontend", blockedBy=["api-contract"])
TaskCreate("verify-backend", owner="verifier", blockedBy=["backend-impl"])
TaskCreate("verify-frontend", owner="verifier", blockedBy=["frontend-impl"])
TaskCreate("integration-test", owner="verifier", blockedBy=["verify-backend", "verify-frontend"])
```

### Handoff

1. Architect reads spec, produces API contract + types → `SendMessage(to="backend", message="Contract: {types}")`
2. Same message to frontend: `SendMessage(to="frontend", message="Contract: {types}")`
3. Backend and Frontend work in parallel (worktree isolation)
4. On completion, each sends: `SendMessage(to="verifier", message="Ready for verification: {paths}")`
5. Verifier runs tests, reports results to conductor

### Conflict Resolution

- Type mismatch between backend and frontend → Architect arbitrates
- Test failure → Verifier reports to the agent whose code failed, that agent fixes

### Shutdown Condition

All verification tasks pass. Conductor merges worktrees, commits, then shuts down team.

---

## review-panel

**Use:** `/review council`, `/review gate`
**Why team:** Multiple uncorrelated context windows catch bugs a single reviewer misses (test-time compute).

### Composition — Batched Waves

**Wave 1 — User Personas (2x vote weight):**

| Role | Agent | Model | Persona |
|------|-------|-------|---------|
| User 1 | reviewer | sonnet | S2 Jake (Strategic Learner) |
| User 2 | reviewer | sonnet | S7 Copy Trader |
| User 3 | reviewer | sonnet | S2 Independent Trader |
| User 4 | reviewer | sonnet | Crypto-native power user |

**Wave 2 — Specialists (1x vote weight):**

| Role | Agent | Model | Focus |
|------|-------|-------|-------|
| Security | reviewer | sonnet | Crypto-sec, key handling, injection |
| Performance | reviewer | haiku | Bundle size, render cycles, latency |
| UX | designer | sonnet | Arx design system compliance |
| Data | researcher | haiku | Signal accuracy, data freshness |

**Wave 3 — Contrarian (1x weight):**

| Role | Agent | Model | Focus |
|------|-------|-------|-------|
| Contrarian | reviewer | sonnet | Challenge consensus, find overlooked risks |

### Task Flow

```
# Wave 1 — all parallel
TaskCreate("review-user-1", owner="user-1")
TaskCreate("review-user-2", owner="user-2")
TaskCreate("review-user-3", owner="user-3")
TaskCreate("review-user-4", owner="user-4")

# Early termination gate
# If ANY Wave 1 reviewer issues BLOCK → skip Wave 2, go to synthesis

# Wave 2 — all parallel, blocked on Wave 1
TaskCreate("review-security", owner="security", blockedBy=["review-user-1","review-user-2","review-user-3","review-user-4"])
TaskCreate("review-perf", owner="performance", blockedBy=[...wave1...])
TaskCreate("review-ux", owner="ux", blockedBy=[...wave1...])
TaskCreate("review-data", owner="data", blockedBy=[...wave1...])

# Wave 3 — blocked on Wave 2
TaskCreate("review-contrarian", owner="contrarian", blockedBy=[...wave2...])

# Synthesis
TaskCreate("synthesis", owner="conductor", blockedBy=["review-contrarian"])
```

### Verdict Protocol

```
Each reviewer outputs: APPROVE | CONCERN | BLOCK
  - APPROVE = no issues found
  - CONCERN = issues found but not blocking (informational)
  - BLOCK = must fix before proceeding

Weighting:
  - Wave 1 (users): 2x weight
  - Wave 2 (specialists): 1x weight
  - Wave 3 (contrarian): 1x weight

Veto power:
  - Security reviewer: BLOCK is absolute (cannot be overridden)
  - Any Wave 1 user BLOCK → overall BLOCK

Final verdict:
  - All APPROVE → PASSED
  - Any CONCERN, no BLOCK → PASSED WITH NOTES
  - Any BLOCK → BLOCKED (must address before retry)
```

### Shutdown Condition

Conductor synthesizes verdicts, produces report, then shuts down team.

---

## full-pipeline

**Use:** `/refine`, `/gos <complex multi-phase goal>`
**Why team:** Sequential handoff through specialist roles, each building on the previous output.

### Composition

| Phase | Agent | Model | Output |
|-------|-------|-------|--------|
| 1. Research | researcher | sonnet | Research brief |
| 2. Architect | architect | opus | Technical design |
| 3. Implement | engineer | sonnet | Working code |
| 4. Review | reviewer | sonnet | Review verdict |
| 5. Verify | verifier | haiku | Test results, screenshots |

### Task Flow

```
TaskCreate("research", owner="researcher")
TaskCreate("design", owner="architect", blockedBy=["research"])
TaskCreate("implement", owner="engineer", blockedBy=["design"])
TaskCreate("review", owner="reviewer", blockedBy=["implement"])
TaskCreate("verify", owner="verifier", blockedBy=["review"])
```

### Handoff

Strictly sequential via artifact handoff:
1. Researcher → `{job-id}/research-brief.md` → Architect reads
2. Architect → `{job-id}/technical-design.md` → Engineer reads
3. Engineer → commits code → Reviewer reads diff
4. Reviewer → `{job-id}/review-verdict.md` → if BLOCK, loop back to Engineer
5. Verifier → `{job-id}/verification-report.md` → Conductor reports

### Loop-Back

If Reviewer issues BLOCK:
- Engineer reads review findings
- Engineer fixes and re-commits
- Reviewer re-reviews (max 2 loop-backs, then escalate to conductor)

### Shutdown Condition

Verifier passes all checks, OR conductor decides to exit after max loop-backs.
