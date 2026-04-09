# Eval Rubric: /build feature

## Dimensions

| Dimension | Weight | 1-3 (Poor) | 4-6 (Adequate) | 7-8 (Good) | 9-10 (Exceptional) |
|-----------|--------|-----------|----------------|-----------|-------------------|
| Tests pass (25%) | 25 | Tests fail or don't exist | Some tests pass, some fail | All tests pass | All tests pass + edge cases covered |
| Coverage (15%) | 15 | <50% coverage | 50-79% coverage | 80-90% coverage | >90% coverage with meaningful tests |
| Spec compliance (25%) | 25 | Missing multiple requirements | Most requirements met | All requirements met | All requirements + handled edge cases spec didn't mention |
| Code quality (20%) | 20 | Lint/type errors, hacks | Clean but verbose | Clean, follows patterns | Elegant, would serve as example code |
| Readability (15%) | 15 | Can't follow without deep analysis | Understandable with effort | Clear at a glance | Self-documenting, intent obvious from names |

## Scoring Rules

- Tests pass: binary — if any test fails, max score is 5
- Coverage: measured by coverage tool, mapped to score range
- Spec compliance: checklist of requirements from the spec
- Code quality: no @ts-ignore, no any, no disabled lint rules
- Readability: could Gary explain this code in 60 seconds?

## Overall Score

Weighted average: `(tests * 25 + coverage * 15 + spec * 25 + quality * 20 + readability * 15) / 100`
