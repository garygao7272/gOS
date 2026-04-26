# Eval Rubric: /refine

## Dimensions

| Dimension | Weight | 1-3 (Poor) | 4-6 (Adequate) | 7-8 (Good) | 9-10 (Exceptional) |
|-----------|--------|-----------|----------------|-----------|-------------------|
| Gap resolution (25%) | 25 | <30% of gaps resolved, or gap list grew unboundedly | 30-60% resolved, some CRITICAL remain | 60-90% resolved, no CRITICAL remain | >90% resolved, only polish items left |
| Cycle rigor (20%) | 20 | Skipped phases, think-only cycles | All 4 phases ran but shallow | Every cycle ran think+design+simulate+review with real output | Phases cross-referenced each other; review informed next think |
| Convergence discipline (20%) | 20 | Ran to max iterations with no clear exit reason, or stopped at cycle 1 | Exited but criteria fuzzy | Exited on CONVERGED/GOOD ENOUGH/STUCK with correct classification | Exited at the exact right cycle; explained why 1 more wouldn't help |
| Depth progression (15%) | 15 | All cycles at same depth (no ladder) | Some deepening but inconsistent | Clear ladder: surface → edge → adversarial | Each cycle uncovered a fundamentally different class of gap |
| Build-readiness (20%) | 20 | Output can't feed /build, no synthesis | Synthesis exists but vague | Clear remaining gaps, prioritized, /build handoff viable | Specs/designs/scenarios are concrete enough to hand off without rework |

## Test Input Requirements

The test input MUST contain:
- An existing spec with at least 3 known gaps (documented by test author)
- A mix of gap severities (at least 1 CRITICAL, 1 HIGH, 1 MEDIUM)
- A convergence target (specific max_iterations) so the harness can check discipline

## Scoring Rules

- Gap resolution: score = min(10, round((resolved / total_planted) * 10))
- Cycle rigor: each missing phase = -2 from 10
- Convergence: correct exit reason = 8, exit reason + justification = 10
- Depth: clear ladder applied = 8, each cycle novel class of gap = 10
- Build-readiness: `/build` can consume output without re-asking questions = 8

## Anti-Pattern Flags (auto-fail to ≤4)

- Refined while simultaneously building → fail
- Refined topic with no pre-existing spec → should have run `/think discover` first
- Max iterations > 7 used → diminishing returns ignored
- Same gap list repeated 3+ cycles unchanged → STUCK not flagged to Gary
- External `/think` call made for a gap that was rewrite-resolvable → wasted think-budget; resolver-type taxonomy mis-applied
- CRITICAL/HIGH gap left untagged with resolver type → cycle either over-rewrites or hits STUCK on a fixable gap
- Cycle stayed `running` while pending external — refine should have transitioned to `waiting-on-X` and waited
- INVALIDATED draft kept refining instead of routing back to `/think discover` → cycles wasted on a doomed draft

## Overall Score

Weighted average: `(gap_resolution * 25 + cycle_rigor * 20 + convergence * 20 + depth * 15 + build_ready * 20) / 100`

- 8-10 → ready for /build
- 5-7 → another refine pass or manual spec intervention
- 0-4 → reset: run /think discover first, or narrow topic

## Doc-type overlay: execution-spec

When the target file's frontmatter declares `doc-type: execution-spec`, swap convergence criterion to [execution-spec.md](execution-spec.md). Three weighted dims (execution density 25%, rationale cap 15%, implementer-test 20%) carry 60% combined weight. Stop the loop when **all four** hold: density ≥70%, rationale ≤6 lines, implementer-test ≤2 questions, zero anti-pattern flags. Spawn `agents/implementer-test.md` as critic during the cycle. Empirical convergence target: **2-3 cycles for first draft, 1-2 for revision** — replaces the 10-20-cycle historical loop driven by structural-completeness scoring against the wrong loss function.
