---
name: gOS rename from god/writ
description: Renamed the command system from "god/writ" (38 commands) to "gOS" (8 verbs + 1 utility) on 2026-03-21, inspired by gstack and GSD
type: project
---

On 2026-03-21, restructured the entire command system:

**Old system:** "The Writ" with 38 flat commands, soul file GOD.md, entry command /god
**New system:** "gOS" (Gary's OS) with 8 verbs + 1 utility, soul file gOS.md, entry command /gos

**Why:** 38 commands had heavy overlap (5 review commands, 7 testing commands). Inspired by garrytan/gstack (role-based skills, Fix-First pattern, safety hooks) and gsd-build/get-shit-done (plans-as-prompts, fresh context executors, 4-level verification).

**How to apply:** Always use gOS verb names. Never reference /god, /judge, /intel, /coordinate, /prototype, /verify-app — these are archived.

The 8 verbs: /gos, /think, /design, /simulate, /build, /review, /ship, /evolve, /refine
Utility: /aside

Key new capabilities added:

- /design promoted to top-level (was under /think)
- /simulate created (absorbs /intel, connects to Dux + MiroFish)
- /ship created (commit, PR, deploy, docs, release)
- /review replaces /judge (adds Fix-First auto-fix, 4-level verification, review dashboard)
- Safety hooks: /gos careful, /gos freeze
