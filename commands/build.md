---
effort: high
description: "Build: feature, fix, refactor — outputs to apps/"
---

# Build — Engineering → apps/

**Build produces working software.**

**Sequential execution only.** Each step depends on the previous one. One agent, one task, one commit at a time.

**The Build loop:** Spec → Code → Test → Verify → Commit → Next step. Never skip a step.

**Scratchpad checkpoints.** Update `sessions/scratchpad.md`:

- **On entry:** Write current task, mode (`Build > {sub-command}`), target
- **Before each step:** Update `Working State`
- **After each commit:** Log commit message and files changed
- **On test failure:** Write to `Dead Ends (don't retry)` if abandoned
- **After compaction:** Re-read `sessions/scratchpad.md`

Parse the first word of `$ARGUMENTS`. If none given, ask: "What are we building? feature, fix, or refactor?"

> **Folded sub-commands:** `plan` → use Plan Mode (native CC). `prototype` → use `/design ui`. `component` → use `feature`. `tdd` → always-on within `feature`.

---

## feature <spec or description>

**Purpose:** Full feature implementation with TDD. Strictly sequential.

**Team decision:**
- Complex features touching 3+ systems → spawn parallel Agent workers. Architect first, then engineers in parallel.
- Simple features → sequential execution (single session).

**Complex feature agent pattern:**

Step 1 — Architect designs the API contract (blocking):
```
Agent(
  prompt = "You are the architect for '{feature}'.
            Read {spec}. Design the API contract: types, interfaces,
            data flow, module boundaries. Output: contract.md with
            types, function signatures, file layout.",
  subagent_type = "architect", model = "opus"
)
```

Step 2 — Engineers implement in parallel (all in ONE message):
```
Agent(
  prompt = "You are engineer-1. Implement {module_1} per this contract:
            {contract from architect}. TDD: write tests first, then implement.
            Follow existing patterns in the codebase.",
  subagent_type = "general-purpose", model = "sonnet",
  isolation = "worktree", run_in_background = true
)

Agent(
  prompt = "You are engineer-2. Implement {module_2} per this contract:
            {contract from architect}. TDD: write tests first, then implement.",
  subagent_type = "general-purpose", model = "sonnet",
  isolation = "worktree", run_in_background = true
)
```

Step 3 — Verifier checks all outputs:
```
Agent(
  prompt = "Verify all engineer outputs against the architect contract.
            Check: types match, tests pass, no file conflicts, 80%+ coverage.",
  subagent_type = "code-reviewer", model = "haiku"
)
```

**Before building:**

1. Read the relevant spec from `specs/`
2. If a prototype exists, read `apps/web-prototype/index.html` for visual guidance
3. Read `apps/mobile/CLAUDE.md` if it exists
4. Check existing components in `apps/mobile/src/components/`

**Context limit guard:** Before any write >200 lines when context is above 50%, dispatch as a fresh agent with explicit file content, or save checkpoint and continue in new session. (Instinct: context-limit-awareness)

**Process (strictly sequential):**

1. **Read spec/plan** if available. If spec has `<!-- AGENT: -->` block, load ONLY referenced files — focused context protocol.
2. **Comprehension check:** "Here's what I understand... correct?"
3. **Write tests first (RED):** Tests MUST fail before proceeding.
4. **Implement to pass tests (GREEN):** Minimal code. Follow existing patterns.
5. **Refactor (IMPROVE):** Clean up while tests pass.
6. **Verify 80%+ coverage.**
7. **Commit:** Small commit, clear message.

**For large features:** Spawn executor agents with fresh context per phase. Orchestrator stays at 30-40% context. Each phase agent gets: plan for that phase only, relevant source files, clear entry/exit criteria.

**Deviation rules:**

- **Auto-fix:** Bugs, missing imports, wiring, type definitions — fix inline
- **ASK:** Architectural changes, new dependencies, scope expansion

**Verification step (mandatory):** After implementation, include a one-liner the user can run to verify. This 2-3x the quality of the final result.

**Spec Sync:** After building, check if implementation diverges from spec. Update spec with sync annotation.

---

## prototype <description>

**Purpose:** Single-file HTML prototype in `apps/web-prototype/`.

**Before building:**

1. `cd apps/web-prototype/` and read its `CLAUDE.md` (version bumping, single-file constraint)
2. Read `SOUL.md`, `COMPONENTS.md`, relevant spec, design system

**Rules:**

- **One file only.** No external deps beyond CDNs.
- **Anti-slop:** No purple gradients, 3-column grids, generic hero sections.
- **Mobile-first:** 390x844 viewport.
- **CSS variables only** from design system. Never hardcode.
- **Blast radius:** NEVER modify existing prototypes unless asked. New variants → `drafts/{name}-v1.html`.

**Anti-Pattern Rules:**
1. CSS classes for toggle states (not inline styles)
2. No template literals in static HTML
3. CSS-first, JS-second
4. Every option set needs "Other/All"

**Build process:**
1. Check Visual Checkpoints in scratchpad — implementation MUST match approved sketches
2. Make changes
3. Test at 390x844
4. Run Post-Build QA Gate (below)
5. `./bump.sh patch`

**Auto-Deploy:** Local preview → `npx vercel --prod --archive=tgz` → report both URLs.

---

## fix

**Purpose:** Fix build errors, type errors, lint failures. Never architectural changes.

**Process:**

1. Use **build-error-resolver** agent
2. Run diagnostics: `tsc --noEmit`, `npm run build`, `eslint`
3. Parse errors, group by type
4. Fix incrementally — one category at a time, smallest fix
5. Verify after each fix
6. **Never:** `@ts-ignore`, disable lint rules, change test expectations, make architectural changes

---

## refactor

**Purpose:** Dead code cleanup. Use refactor-cleaner agent.

**Rules:** Never during active feature dev. Never without tests. Never change behavior.

**Process:**

1. Run detection: `npx knip`, `npx depcheck`, `npx ts-prune`
2. Categorize: SAFE (unused imports, dead code) → CAREFUL (dynamic refs) → RISKY (string refs)
3. Remove SAFE first, commit after each batch
4. Run full test suite after each batch
5. Consolidate duplicates
6. Report: lines removed, files deleted, deps uninstalled, bundle change

---

## Post-Build QA Gate (mandatory before bump/commit)

| Check | Method | Pass Criteria |
|-------|--------|---------------|
| Plan alignment | Re-read plan | Every requirement has code |
| Visual consistency | Screenshot changed screens | No clipped text, no overlap |
| Dark + light mode | Toggle theme | Both work |
| Copy quality | Read user-facing text | No placeholders, active verb CTAs |
| Interaction pairs | Click every element on AND off | All toggles work |
| Console clean | `preview_console_logs(level='error')` | Zero JS errors |
| Mobile fit | 390x844 viewport | No horizontal scroll |

**Blast-Radius Rule:** Fix ALL instances of a pattern, not just the one reported. Grep the codebase, fix everything in one pass.

---

## Comprehension Check — Cognitive Debt Gate

Before marking any build complete:

1. **Explain it back:** Can Gary understand without re-reading?
2. **Flag black boxes:** Inline comment for non-obvious "why"
3. **Log unknowns:** If mechanism isn't understood, log in `specs/Arx_9-5_Hypothesis_Question_Log.md`
