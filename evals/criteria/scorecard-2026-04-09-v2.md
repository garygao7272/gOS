---
artifact_type: decision
created_by: /refine + /review
topic: gOS 12-dimension self-eval (honest review)
created_at: 2026-04-09
status: reviewed
---

# gOS 12-Dimension Scorecard — 2026-04-09 v2

Honest review against updated criteria + VISION.md north star.
12 dimensions (was 10). Dimensions 4, 5, 11, 12 weighted 1.5x.

## Scorecard

| # | Dimension | Score | Weight | Weighted | Honest Assessment |
|---|-----------|-------|--------|----------|-------------------|
| 1 | Perception | 9 | 1.0 | 9.0 | Strong. Parallel context gathering, tool discovery, fallback chains. No gap. |
| 2 | Planning | 8 | 1.0 | 8.0 | Plan Gate exists and runs. Still advisory not blocking. Good decomposition. |
| 3 | Action | 8 | 1.0 | 8.0 | Agent orchestration works. Model routing documented. Progress tracking exists. |
| 4 | **Memory** | **7** | 1.5 | **10.5** | **Downgraded from 8.** Step 0 auto-read is INSTRUCTED but not VERIFIED. claude-mem PATH fixed but untested in live session. L1 updated this session but was stale before. No mid-session auto-writes. No stale memory detection. |
| 5 | **Learning** | **5** | 1.5 | **7.5** | **Honest: 5.** Stop/PreCompact hooks exist but were JUST added — zero sessions of proof. 11 rubrics exist but ZERO rubric scores have been run. Evolve audits run but proposals aren't systematically implemented. Repeat signals happened 3x this session alone (Stop hook). No automated instinct extraction. |
| 6 | Reasoning | 8 | 1.0 | 8.0 | Council review, first principles, bias checklist. Solid. |
| 7 | Communication | 8 | 1.0 | 8.0 | Confidence scoring added. TodoWrite used. Briefing adapts. |
| 8 | Autonomy | 8 | 1.0 | 8.0 | PROCEED/ASK/JUDGMENT/STUCK in global CLAUDE.md. Consistent. |
| 9 | Reliability | 8 | 1.0 | 8.0 | 11 hooks wired. Loop detection. Error tracking. Checkpoint system. Conservative rollout. But hooks are UNTESTED — added this session, zero sessions of proof. |
| 10 | Metacognition | 7 | 1.0 | 7.0 | Context-monitor wired. Confidence surfacing documented. But "I don't know" was NOT proactively said this session — went ahead with wrong resume instead of flagging uncertainty. |
| 11 | **Craft** | **4** | 1.5 | **6.0** | **NEW, harsh score.** build.md prescribes spec-read + comprehension check + spec sync. In PRACTICE: zero evidence of comprehension checks in git history. Zero spec sync commits. Prototype builds happen but spec compliance is not verified. The instructions exist; the behavior doesn't. |
| 12 | **Testing** | **3** | 1.5 | **4.5** | **NEW, harsh score.** ZERO test files in gOS repo. ZERO test configs (jest, vitest, pytest). ZERO TDD evidence in git history. build.md has a full TDD section (RED→GREEN→REFACTOR) but it has NEVER been executed against gOS itself. Eval rubrics ≠ tests. The testing infrastructure is entirely aspirational. |

## Summary

| Metric | Value |
|--------|-------|
| **Raw average** | (9+8+8+7+5+8+8+8+8+7+4+3) / 12 = **6.9** |
| **Weighted score** | (9+8+8+10.5+7.5+8+8+8+8+7+6+4.5) / 14.0 = **6.6** |
| **Previous (10-dim)** | 8.0 (inflated — didn't measure craft or testing) |
| **Honest 12-dim** | **6.6** |

## The Uncomfortable Truth

The previous 8.0 score was inflated because it didn't measure the two things that matter most for a co-creator: **Does it build what was specified?** and **Does it prove its work is correct?**

Adding Craft (4/10) and Testing (3/10) at 1.5x weight pulls the score down hard. This is correct — a co-creator that doesn't follow specs and doesn't test is just a fast typist.

## Gap Analysis (Prioritized)

### Critical (blocks co-creator status)

| # | Gap | Current | Target | Concrete Fix |
|---|-----|---------|--------|-------------|
| 1 | **No tests exist** | 3/10 | 7/10 | Add test infrastructure to gOS: pytest for Python (toolkit MCPs), vitest for JS. Write tests for hook scripts. Create a test runner that validates hooks work. |
| 2 | **Spec compliance not enforced** | 4/10 | 7/10 | Add a PreToolUse hook on Edit that checks if the edited file has an upstream spec, and surfaces it. Post-build spec sync should be a gate, not a suggestion. |
| 3 | **Learning is aspirational** | 5/10 | 7/10 | Run at least ONE eval rubric to produce an actual score. Implement one instinct extraction cycle. Prove the loop works end-to-end, not just that the pieces exist. |

### High (degrades quality)

| # | Gap | Current | Target | Fix |
|---|-----|---------|--------|-----|
| 4 | Memory untested | 7/10 | 8/10 | Verify claude-mem works with PATH fix in next session. Add stale memory detection (check valid_from dates). |
| 5 | Hooks untested | 8/10 | 9/10 | Run a deliberate test: try `rm -rf` and verify delete-guard blocks it. Try a git rebase with untracked files and verify git-safety blocks it. |
| 6 | Metacognition reactive | 7/10 | 8/10 | The wrong-resume incident proves gOS doesn't flag uncertainty proactively. Add a concrete check: if resuming, verify session matches current project before presenting. |

### Medium (polish)

| # | Gap | Current | Target | Fix |
|---|-----|---------|--------|-----|
| 7 | Planning advisory only | 8/10 | 9/10 | Make plan gate a blocking PreToolUse hook for Agent/Skill calls (must have plan approved before spawning). |
| 8 | No mid-task progress enforcement | 8/10 | 9/10 | TodoWrite usage is good but not enforced — add a PostToolUse prompt that checks if TodoWrite is stale. |

## Historical Scores

| Date | Dimensions | Raw | Weighted | Key Event |
|------|-----------|-----|----------|-----------|
| 2026-04-08 (pre) | 10 | 6.4 | — | Before restructure |
| 2026-04-08 (post) | 10 | 7.3 | — | CLAUDE.md hierarchy, install.sh |
| 2026-04-09 v1 | 10 | 8.0 | — | P1-P5 upgrade (inflated — missing craft+testing) |
| **2026-04-09 v2** | **12** | **6.9** | **6.6** | Honest review with craft + testing dimensions |

## Next Session Priority

1. **Add test infrastructure** — even minimal (hook smoke tests) proves the concept
2. **Run one eval rubric end-to-end** — produce an actual score, not just a rubric file
3. **Test the hooks** — deliberately trigger each safety hook to verify it works
4. **Verify claude-mem** — confirm PATH fix enables auto-search
