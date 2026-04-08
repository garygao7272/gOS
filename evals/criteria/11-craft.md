---
dimension: Craft
number: 11
weight: 1.5
---

# Craft (Spec Compliance + Build Quality)

**What it measures:** Whether gOS actually builds to spec, follows TDD, syncs implementation back to specs, and maintains build quality through review gates.

This dimension exists because "building" and "building to spec" are different things. Action (dimension 3) measures execution mechanics. Craft measures whether the output matches what was specified.

## Scoring Ladder

| Score | Level | Evidence Required |
|-------|-------|-------------------|
| 1-3 | Cowboy | Builds without reading specs. No tests. No verification. "It works" = done. |
| 4-5 | Adequate | Reads specs sometimes. Tests written after implementation. Spec sync is manual and rare. |
| 6-7 | Disciplined | Reads spec before building (build.md Step 1). TDD attempted (tests first for new features). Post-build QA gate runs. Spec sync noted but not enforced. |
| 8-9 | Precise | Every build starts with spec read + comprehension check. TDD strict (RED→GREEN→REFACTOR verified). Post-build spec sync updates spec with implementation notes. Visual checkpoints matched. Review gates catch drift before commit. |
| 10 | Artisan | Spec and implementation are always in sync — drift is zero. TDD is reflexive, not prescribed. Build quality is consistent enough that Gary skips review for routine changes. The gap between "what was specified" and "what was built" approaches zero. |

## What to Check

### Spec Compliance
- Does `/build feature` actually read the spec before coding? (Step 1 in build.md)
- Does the comprehension check happen? ("Here's what I understand... correct?")
- After building, is the spec updated with `<!-- Synced from apps/... -->` notes?
- When spec and implementation diverge, which gets updated?

### TDD Compliance
- Are tests written BEFORE implementation? (RED phase — tests must fail first)
- Is there evidence of the RED→GREEN→REFACTOR cycle in git history?
- Is 80%+ coverage achieved and verified?
- Are tests in the same context window as implementation?

### Build Quality
- Does the post-build QA gate run (visual match, plan alignment, console clean, mobile fit)?
- Does the blast-radius rule apply (fix all instances, not just the one reported)?
- Is the verification step included (one-liner the user can run)?

### Evidence Trail
- Count of specs read before builds (from git log / session history)
- Count of tests written before implementation vs after
- Count of spec syncs after builds
- Count of post-build QA gates that caught issues

## Weight: 1.5x

Craft is weighted higher because it directly determines whether gOS's output matches Gary's intent. Without craft, gOS is just fast — not accurate.
