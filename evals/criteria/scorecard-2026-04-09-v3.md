---
artifact_type: decision
created_by: independent evaluator (Opus 4.6)
topic: gOS 12-dimension self-eval v3 — evidence-based rescore
created_at: 2026-04-09
status: final
---

# gOS 12-Dimension Scorecard — 2026-04-09 v3

Independent evaluation. Scored on EVIDENCE of real value delivered, not files created.
Baseline: v2 scored 6.6 weighted.

## Methodology

Every claim was verified against actual repo state:
- Tests run: 32 BATS tests, all passing (5 of 29 hooks covered = 17% coverage)
- Wiki lint run: passes clean (0 issues)
- Eval scores checked: 1 score produced (aside 8/10) out of 11 rubrics
- Instincts checked: 3 YAML files exist, but only 1 provably drove a code change
- spec-compliance.sh: advisory only (exits 0 in all paths, never blocks)
- instinct index.md: NOT updated (still says "none yet" despite 3 instincts existing)
- think.md: NO evidence of audit-existing-tools applied (grep found 0 matches)
- build.md: NO evidence of context-limit-awareness applied (grep found 0 matches)

## Scorecard

| # | Dimension | Score | Weight | Weighted | Honest Assessment |
|---|-----------|-------|--------|----------|-------------------|
| 1 | Perception | 8 | 1.0 | 8.0 | Step 0 reads L1, state.json, scratchpad, wiki INDEX. Parallel context gathering documented. Tool discovery exists. Downgraded from 9: wiki query is INSTRUCTED but has zero sessions of proof that it actually runs. No evidence of proactive context loading by keyword matching in a real session. |
| 2 | Planning | 8 | 1.0 | 8.0 | Plan Gate structure solid (PLAN/STEPS/MEMORY/RISK/CONFIDENCE). Decomposition exists. Still advisory — no PreToolUse hook blocks execution without plan. Hold at 8. |
| 3 | Action | 7 | 1.0 | 7.0 | Agent orchestration documented. Model routing in commands. But: no evidence of parallel agent execution in git history. Progress tracking via status.md is prescribed but no status.md files exist in outputs/. Downgraded from 8: documentation vs demonstrated execution. |
| 4 | **Memory** | **7** | **1.5** | **10.5** | Step 0 now includes wiki INDEX (line 42 of gos.md). Staleness check added (line 45). Resume-project match guard added (line 50-51). But: wiki was built this session, zero sessions of query proof. claude-mem PATH fix still untested in live session. L1 updated but no automated mid-session writes. instinct index.md still says "none yet" despite 3 instincts existing — the system doesn't maintain its own index. Hold at 7. |
| 5 | **Learning** | **5.5** | **1.5** | **8.25** | Improved from 5.0. Evidence: 3 instincts extracted (was 0). 1 eval score produced (was 0). Signal log has 50+ entries. BUT: only 1 of 3 instincts ACTUALLY drove code changes (no-system-jargon applied to gos.md — verified by grep). audit-existing-tools claims applied_to think.md but think.md has NO matching content. context-limit-awareness claims applied_to build.md but build.md has NO matching content. The instinct YAMLs claim "status: applied" for changes that don't exist. That's the learning loop lying to itself. 11 rubrics exist but only 1 has inputs and scores. The loop ran once, partially. Bumped 0.5 for the one proven end-to-end case. |
| 6 | Reasoning | 8 | 1.0 | 8.0 | Council review structure exists. First principles in think.md. Bias checklist in Plan Gate. Solid — no change from v2. But no evidence of gOS pushing back on Gary with evidence in git history. Hold at 8. |
| 7 | Communication | 8 | 1.0 | 8.0 | Story+Table+Next Move format now in gos.md (verified at lines 100, 274). Confidence scoring prescribed. TodoWrite usage documented. Briefing adapts. The no-system-jargon instinct proved this works: Gary's rework signals led to real format changes. Hold at 8. |
| 8 | Autonomy | 7.5 | 1.0 | 7.5 | PROCEED/ASK/JUDGMENT/STUCK in global CLAUDE.md. Consistent across projects. But: the wrong-resume incident (loading cross-project session without flagging uncertainty) is a JUDGMENT failure that was documented in v2 and the resume-match guard was just added this session. Downgraded from 8 because the guard is untested — the same failure could recur despite the new code. |
| 9 | Reliability | 7.5 | 1.0 | 7.5 | 29 hooks exist and are wired. 5 of those hooks are now TESTED (32 tests, all passing). That's real progress from v2 (0 tested). But 24 hooks remain untested. Conservative rollout discipline documented. Checkpoint system exists. spec-compliance.sh is advisory only (can't prevent drift). Slight downgrade from 8 because we now know the exact coverage gap. |
| 10 | Metacognition | 7.5 | 1.0 | 7.5 | Staleness check added to Step 0 (line 44-45 of gos.md). Proactive uncertainty added (line 47-48). Resume-project match guard added (line 50-51). These are real improvements from v2 (7.0). But none have been tested in a live session yet. The "From memory (unverified):" prefix is instructed but has zero evidence of actually being used. Bumped 0.5 for the structural improvements. |
| 11 | **Craft** | **4.5** | **1.5** | **6.75** | spec-compliance.sh exists and is wired in settings.json (verified). But it's ADVISORY — exits 0 in all paths, never blocks an edit. It logs a warning; the edit proceeds regardless. That's weaker than enforcement. No evidence of comprehension checks in git history. No spec sync commits. build.md prescribes TDD but gOS itself has no application-level tests (only hook tests). Bumped 0.5 from 4.0 for the advisory hook existing — it's better than nothing, but not by much. |
| 12 | **Testing** | **5** | **1.5** | **7.5** | Major improvement from 3.0. REAL evidence: 32 BATS tests exist, all pass, run-tests.sh works. Tests cover 5 safety-critical hooks (delete-guard, git-safety, loop-detect, scope-guard, secret-scan). run-eval.sh framework exists and produced 1 real score. BUT: 5/29 hooks tested = 17% coverage. No tests for context-monitor, session-save, accumulate, plan-gate, protect-files, security-gate, or any other hook. No application-level tests (command behavior tests). No E2E tests. The test infrastructure is real but coverage is thin. |

## Summary

| Metric | Value |
|--------|-------|
| **Raw average** | (8+8+7+7+5.5+8+8+7.5+7.5+7.5+4.5+5) / 12 = **6.96** |
| **Weighted score** | (8+8+7+10.5+8.25+8+8+7.5+7.5+7.5+6.75+7.5) / 14.0 = **6.75** |
| **Previous v2** | Raw 6.9, Weighted **6.6** |
| **Delta** | **+0.15 weighted** |

## Comparison to v2

| Dimension | v2 | v3 | Delta | Reason |
|-----------|----|----|-------|--------|
| Perception | 9 | 8 | -1 | Wiki query instructed but unproven. Downgraded to honest level. |
| Planning | 8 | 8 | 0 | No change. |
| Action | 8 | 7 | -1 | No evidence of parallel agent execution in practice. |
| Memory | 7 | 7 | 0 | Wiki added but untested. instinct index stale. |
| Learning | 5 | 5.5 | +0.5 | One proven instinct-to-code-change loop. But 2 of 3 instincts have false "applied" status. |
| Reasoning | 8 | 8 | 0 | No change. |
| Communication | 8 | 8 | 0 | No change. |
| Autonomy | 8 | 7.5 | -0.5 | Resume-match guard added but untested. |
| Reliability | 8 | 7.5 | -0.5 | Better accuracy: 5 hooks tested, 24 not. |
| Metacognition | 7 | 7.5 | +0.5 | Staleness + uncertainty + resume guard added to gos.md. |
| Craft | 4 | 4.5 | +0.5 | Advisory hook exists. Still not enforcement. |
| Testing | 3 | 5 | +2 | 32 real tests, framework working. Coverage still thin. |

Testing is the biggest real improvement (+2 points). But some v2 scores were inflated (Perception, Action, Autonomy, Reliability were scored generously in v2 — corrected here).

## Gap Analysis

### What moved the needle (real value)

1. **BATS tests**: 32 tests across 5 hooks, all passing. This is REAL infrastructure — it caught nothing yet (no bugs found in testing), but it prevents regressions on the most critical safety hooks. Worth the +2.
2. **no-system-jargon instinct**: Provably drove code changes in gos.md. The rework signals (3 reworks) led to Story+Table+Next Move format. This is the learning loop working end-to-end exactly once.
3. **Eval framework**: run-eval.sh produced one real score. The framework is sound. But 1/11 rubrics scored is 9% utilization.

### What's scaffolding (looks good but unproven)

1. **Wiki layer**: INDEX.md, 4 wiki pages, lint.sh. All created this session. Zero query proof. Will it actually be read in the next session? Unknown.
2. **audit-existing-tools instinct**: YAML says "applied_to: commands/think.md" but think.md has NO matching content. The instinct exists as a file but never actually changed behavior.
3. **context-limit-awareness instinct**: Same problem. YAML says "applied_to: commands/build.md" but build.md has NO matching content.
4. **spec-compliance.sh**: Wired but advisory. Never blocks. Never changed a build outcome.
5. **Metacognition additions**: "From memory (unverified):" prefix instructed but never observed in output.

### What would move the needle MOST (priority order)

| Priority | Gap | Current | Target | Expected Delta |
|----------|-----|---------|--------|----------------|
| 1 | **Actually apply instincts** | 1/3 applied | 3/3 applied | Learning 5.5 -> 6.5. The YAML files lie — fix think.md and build.md to match claims. |
| 2 | **More hook tests** | 5/29 tested | 15/29 tested | Testing 5 -> 7. Focus on context-monitor, session-save, plan-gate, protect-files, security-gate. |
| 3 | **Run eval rubrics** | 1/11 scored | 5/11 scored | Learning 5.5 -> 7. Produce actual scores for build, review, think, evolve, gos. Need test inputs first. |
| 4 | **Make spec-compliance blocking** | Advisory | Blocking (exit 2) | Craft 4.5 -> 6. Until it blocks, it's a suggestion that will be ignored. |
| 5 | **Prove wiki in next session** | 0 queries | 1+ query | Memory 7 -> 8. Just use /gos and see if Step 0 actually reads INDEX.md. |
| 6 | **Fix instinct index** | Stale ("none yet") | Reflects actual 3 instincts | Learning: minor but embarrassing — the index is wrong. |

## Reality Check: Are We Creating Real Value or Just Building Scaffolding?

**Honest answer: 70% scaffolding, 30% real value.**

The 30% that's real:
- 32 BATS tests that actually run and pass. This prevents safety hook regressions.
- Story+Table+Next Move format change. One complete signal-to-instinct-to-code-change loop.
- 1 eval score that proves the eval framework works.

The 70% that's scaffolding:
- Wiki layer with zero query proof
- 2 instinct files that claim "applied" but weren't applied
- Advisory hook that can't prevent anything
- Metacognition instructions that have never been observed in output
- 11 rubrics with only 1 ever scored
- instinct index that doesn't reflect actual state
- 24 untested hooks

**The core question**: Does gOS make Gary more productive TODAY, or is it infrastructure for a future that hasn't arrived?

Right now, gOS provides real value through: command routing (the verb system works), safety hooks (delete-guard etc. prevent mistakes), the Plan Gate (structures thinking), and signal capture (raw data for future learning). That's genuinely useful.

What was added this session is mostly POTENTIAL value. The wiki, instincts, eval framework, and metacognition additions are good architecture, but they haven't survived a real session yet. A week from now, if the wiki gets queried, instincts get applied, and eval scores accumulate — the score should rise to 7.5+. But today, based on evidence, the score is 6.75.

**The delta from v2 is +0.15, not the +1.0 the volume of work might suggest.** That's because v2 inflated some scores (Perception 9, Action 8, Autonomy 8, Reliability 8) that should have been lower, and the corrections offset the real Testing gain.

## Historical Scores

| Date | Dimensions | Raw | Weighted | Key Event |
|------|-----------|-----|----------|-----------|
| 2026-04-08 (pre) | 10 | 6.4 | -- | Before restructure |
| 2026-04-08 (post) | 10 | 7.3 | -- | CLAUDE.md hierarchy, install.sh |
| 2026-04-09 v1 | 10 | 8.0 | -- | P1-P5 upgrade (inflated) |
| 2026-04-09 v2 | 12 | 6.9 | 6.6 | Honest review with craft + testing |
| **2026-04-09 v3** | **12** | **6.96** | **6.75** | Evidence-based rescore after 6-phase build |

## Next Session Litmus Test

Run these 5 checks at the start of the next session to validate or invalidate the scaffolding:

1. Does `/gos` actually read `memory/wiki/INDEX.md`? (Proves wiki is wired)
2. Does `/gos` prefix uncertain claims with "From memory (unverified):"? (Proves metacognition)
3. Do think.md and build.md contain instinct-driven content? (If not, fix or correct YAML status)
4. Does spec-compliance.sh fire a warning when editing a governed file? (Proves it's wired)
5. Can you run `./evals/run-eval.sh build --list-inputs` and get results? (Proves eval pipeline)

If 4/5 pass, the scaffolding is real. If 2/5 pass, the score should drop back to 6.5.
