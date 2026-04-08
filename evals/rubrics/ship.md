---
name: ship
command: /ship
effort: medium
---

# /ship Rubric

## Scoring (0-10)

### Pre-flight Check (0-2)
- 0: Shipped without checking tests, lint, or build
- 1: Checked one of tests/lint/build
- 2: Full pre-flight: tests pass, lint clean, build succeeds, no uncommitted changes

### Commit Quality (0-2)
- 0: Empty or generic commit message
- 1: Descriptive but missing type prefix or body
- 2: Conventional commit format, body explains why, references issue/spec

### PR Quality (0-2)
- 0: No PR or empty description
- 1: PR with summary but missing test plan
- 2: PR with summary, test plan, breaking changes noted, reviewers suggested

### Deploy Safety (0-2)
- 0: Deployed without verification
- 1: Deployed with basic smoke test
- 2: Deployed with rollback plan, canary if applicable, monitoring confirmed

### Documentation (0-2)
- 0: No docs updated
- 1: Code comments added but no user-facing docs
- 2: CHANGELOG updated, README if needed, spec sync if applicable
