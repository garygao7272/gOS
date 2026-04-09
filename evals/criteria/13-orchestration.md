# 13. Orchestration (1.5x weight)

**What it measures:** Multi-agent spec-first coordination across the 3 surfaces (specs, design, code). This is the core objective — multiple agents working together, thinking deeply, enforcing spec-first.

## Scoring Levels

| Score | Level | Evidence Required |
|-------|-------|-------------------|
| 1-3 | **Broken** | Single-agent only. No spec-first enforcement. No handoff between surfaces. |
| 4-5 | **Manual** | Multiple agents spawn but don't coordinate. Spec-first prescribed but not enforced. Surfaces disconnected. |
| 6-7 | **Functional** | Conductor orchestrates agents. Spec-first enforced via hooks. Handoff schemas exist. Coverage matrix tracks all 3 surfaces. |
| 8-9 | **Automated** | Convergence loops run without intervention. Cross-examination produces better outputs. Agents share memory. Cloud claws monitor spec drift. |
| 10 | **Co-creator** | Agents propose spec changes proactively. Auto-detect gaps across surfaces. Self-improving orchestration. Gary trusts multi-agent output without review for routine tasks. |

## Sub-Dimensions

### 13a. Multi-Agent Coordination
- Do agents share context via typed handoff schemas?
- Does cross-examination produce better outputs than single-agent?
- Are there convergence loops that run until quality gates pass?
- Can agents be re-contacted with retained context?

### 13b. Spec-First Enforcement
- Does a hard gate block `/design` without approved `/think` output?
- Does a hard gate block `/build` without approved `/design` output?
- Does spec-compliance.sh actually BLOCK edits (exit 2), not just warn?
- Is there a spec↔code coverage matrix showing gaps?

### 13c. 3-Surface Coverage
- Are all 3 surfaces tracked: specs (339 Arx), design (prototypes), code (apps/)?
- Can `/gos status` answer: "what's not specced? not designed? not coded? not tested?"
- Is there automated drift detection between surfaces?
- Does spec freshness get monitored?

### 13d. Agent Tooling
- Are all roster agents installed globally (not just in gOS source)?
- Do agents have appropriate tool restrictions (spec-writer can't edit code, reviewer is read-only)?
- Is there a shared memory layer for cross-agent knowledge?
- Are claws/persistent agents actually running (non-zero execution count)?

## What Moves the Score

| From | To | What's Needed |
|------|-----|---------------|
| 4 → 6 | Fix spec-compliance hook (blocking), install missing agents, add coverage matrix |
| 6 → 8 | Hard phase gates, handoff schemas, convergence loops proven, context budget monitor |
| 8 → 10 | Cloud claws monitoring drift, agents propose spec changes, self-improving orchestration |
