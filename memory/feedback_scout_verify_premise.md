# Scout agents must verify premise before recommending

**Captured:** 2026-04-19 (from 2026-04-15 META signal, deferred 4 days)
**Signal weight:** decisive — 3/4 false-positive rate on scout-type agent recommendations

## Rule

Any scout-type agent (survey, audit, recon, recommendation-generating) must verify the premise with a direct file read or command run **before** recommending an action. Recommendations without premise verification are treated as noise until confirmed.

## Why

On 2026-04-15, scout agent recommended 4 P1 fixes:

- **vocab sweep** — premise "stale vocab" disproved: `build-squad` was consistent with sibling team-identifier pattern (swarm/panel/pipeline/squad)
- **.gitignore toolkit (24M saved)** — premise false: `node_modules/` was already untracked, local-disk state confused scout
- **plugin dupe delete** — premise false: `gos-plugin-build/FROZEN.md` explicitly forbids modification
- **one genuine fix** (install.sh P0+P1) — worked

False-positive rate: 3/4 = 75%. Pattern: scout reports surface signals (file exists, lines match, size large) without verifying the premise the signal implies (is it actually stale? is it actually untracked? is it actually safe to delete?).

## How to apply

When invoking scout-type agents, inject this into the contract:

> **BEFORE recommending any action, verify the premise:**
> 1. State the premise explicitly (e.g., "file X is stale," "dir Y is untracked," "doc Z contradicts code")
> 2. Verify with a direct check: file read, grep, `git ls-files`, or equivalent command
> 3. If the premise fails, SKIP the recommendation — do not recommend anyway with a hedge
> 4. If the premise holds, include the verification command in the recommendation so the caller can re-run

Apply to any agent whose contract includes words like: *scan, audit, survey, recon, sweep, find-and-recommend, scout*.

## Related

- `feedback_existing_tools_awareness.md` — same root cause (recommend before checking what's installed)
- INV-G01 (first-principles): trace to mechanism, not surface signal
