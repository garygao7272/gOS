---
dimension: Testing
number: 12
weight: 1.5
---

# Testing (TDD + Verification + Quality Gates)

**What it measures:** Whether gOS writes tests first, maintains coverage, runs quality gates, and uses verification loops to prove correctness — not just claim it.

This dimension exists because testing is the mechanism by which gOS proves its work is correct. Without it, "I built the feature" is an assertion, not evidence.

## Scoring Ladder

| Score | Level | Evidence Required |
|-------|-------|-------------------|
| 1-3 | Untested | No tests written. "It works" based on manual checking. No coverage data. |
| 4-5 | Afterthought | Tests exist but written after implementation. Coverage unknown. Tests are happy-path only. |
| 6-7 | Practiced | TDD attempted for new features. Coverage measured (>60%). tdd-guide agent invoked. Edge cases covered for critical paths. |
| 8-9 | Rigorous | TDD strict — RED→GREEN→REFACTOR with evidence (failing test screenshot/output before GREEN). 80%+ coverage. E2E tests for critical flows. Quality gates block merges. |
| 10 | Bulletproof | Tests are the specification. Coverage >90%. Mutation testing used. Every bug fix starts with a failing test. Test suite runs fast (<30s). Flaky tests quarantined immediately. |

## What to Check

### TDD Compliance
- Is tdd-guide agent invoked for new features?
- Are tests written BEFORE implementation? Evidence: git log showing test commit before implementation commit, or test failure output before GREEN.
- Does the RED phase actually produce failing tests? (not just empty test files)
- Does the REFACTOR phase happen without breaking tests?

### Coverage
- Is coverage measured after each feature?
- Is 80% the enforced minimum?
- Are coverage reports generated and checked?

### Quality Gates
- Does `/review gate` run before shipping?
- Does `/build prototype` run the post-build QA gate?
- Do e2e tests exist for critical user flows?
- Are quality gates blocking (prevent merge) or advisory (suggest but don't block)?

### Verification Loops
- Does every build include a verification step (one-liner to prove it works)?
- Are preview_* tools used to verify UI changes?
- Are screenshots captured as evidence?

### Test Quality
- Are tests testing behavior (what), not implementation (how)?
- Do tests cover edge cases and error paths?
- Are tests isolated (no shared mutable state between tests)?
- Are tests fast enough to run on every change?

## Weight: 1.5x

Testing is weighted higher because it's the primary mechanism for preventing regressions and proving correctness. Without testing, every other dimension degrades over time.
