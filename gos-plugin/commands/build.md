---
effort: high
description: "Build: plan, prototype, feature, component, fix, tdd, refactor — outputs to apps/"
---

# Build — Engineering → apps/

**Build produces working software. Absorbs the former /plan, /prototype, /tdd, /build-fix, /refactor-clean, and /simplify commands.**

**Sequential execution only.** Build mode does NOT use the swarm pattern. Each step depends on the previous one. One agent, one task, one commit at a time. Parallel agents on shared files cause merge conflicts, inconsistent architecture, and regressions harder to debug than the time saved.

**The Build loop:** Spec → Code → Test → Verify → Commit → Next step. Never skip a step. Never batch steps.

**Scratchpad checkpoints.** Update `sessions/scratchpad.md`:

- **On entry:** Write current task, mode (`Build > {sub-command}`), and target
- **Before each build step:** Update `Working State` with what you're about to do
- **After each commit:** Log the commit message and files changed
- **On test failure:** Write failure details and attempted fix to `Dead Ends (don't retry)` if abandoned
- **After compaction:** Re-read `sessions/scratchpad.md` to restore state

Parse the first word of `$ARGUMENTS` to determine sub-command. If no sub-command given, ask: "What are we building? plan, prototype, feature, component, fix, tdd, or refactor?"

---

## plan <task>

**Purpose:** Implementation planning. Restate requirements, assess risks, create step-by-step plan. Wait for user CONFIRM before touching code.

**Process:**

1. Parse task from remaining `$ARGUMENTS`
2. Update scratchpad: `Build > plan`, task description
3. Use **planner** agent to analyze the task
4. **Research phase (parallel):**
   - Search codebase for related code, existing patterns, potential conflicts
   - Read relevant specs from `specs/`
   - Check if similar features exist that can be extended
5. **Generate plan in the following format:**

```markdown
# Implementation Plan: {task}

## Requirements (restated)
{restate what was asked in your own words — this is the comprehension check}

## Architecture Changes
{what files/modules are affected, new files needed, dependency changes}

## Steps
### Phase 1: {name}
- [ ] Step 1.1: {description} — files: {paths}
- [ ] Step 1.2: {description} — files: {paths}

### Phase 2: {name}
- [ ] Step 2.1: {description} — files: {paths}
- [ ] Step 2.2: {description} — files: {paths}

{add more phases as needed}

## Testing Strategy
{what tests to write, what coverage target, what edge cases}

## Risks & Mitigations
| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
| {risk} | {H/M/L} | {H/M/L} | {what to do} |

## Success Criteria
- [ ] {measurable outcome}
- [ ] {measurable outcome}
- [ ] {measurable outcome}
```

6. **Present plan and wait for CONFIRM**
7. After approval, offer: "Ready to execute? I'll use fresh-context executors per phase for large tasks."

**Output to:** `sessions/scratchpad.md` (inline) or `outputs/think/decide/{task-slug}-plan.md` for complex plans

---

## prototype <description>

**Purpose:** Single-file HTML prototype in `apps/web-prototype/`.

**Before building:**

1. `cd apps/web-prototype/` and read its `CLAUDE.md` (contains version bumping rules, single-file constraint)
2. Read `SOUL.md` for design philosophy
3. Read `COMPONENTS.md` for reusable patterns
4. Read the relevant spec from `specs/Arx_4-1-*` if applicable
5. Read `specs/Arx_4-2_Design_System.md` for design tokens

**Rules:**

- **One file only.** No external dependencies beyond CDNs. Single-file constraint is absolute.
- **Anti-slop:** No purple gradients. No 3-column grids. No generic hero sections. No AI-generic aesthetics. If it looks like every other AI-generated landing page, start over.
- **Mobile-first:** 390x844 viewport (iPhone 14 Pro). Design for this size first, scale up never.
- **CSS variables only:** Use design tokens from the design system. Never hardcode colors, fonts, or spacing.
- **Blast radius rule:** NEVER modify existing prototypes unless explicitly asked. If making a new prototype variant, create a new file in `drafts/{feature-name}-v1.html`.

**Anti-Pattern Rules (prevent bugs at write time):**

1. **CSS classes for toggle states.** Visual states MUST be driven by CSS classes (`.selected`, `.active`). Use `style.removeProperty()` to clear inherited inline styles before relying on class-based styling.
2. **No template literals in static HTML.** `${expression}` only works inside JS template strings. Use placeholders populated via JS `textContent` at render time.
3. **CSS-first, JS-second.** CSS handles how things look. JS handles what class to add. JS should never set `el.style.borderColor` for states that have CSS rules. Exception: computed values like scroll-based positioning.
4. **Every option set needs "Other/All".** If presenting 3-5 choices, ALWAYS include an escape hatch.

**Build process:**

1. Make changes to `index.html` (or `drafts/{name}-v1.html` for new prototypes)
2. Test in 390x844 viewport
3. Run `./bump.sh patch` (or minor/major) after changes

**Post-Build QA Gate (mandatory before bump/deploy):**

| Check | Method | Pass Criteria |
|-------|--------|---------------|
| Plan alignment | Re-read plan/instruction | Every requirement has corresponding code change |
| Visual consistency | Screenshot all changed screens | Selected != unselected states; no clipped text; no overlap |
| Dark + light mode | Toggle theme, screenshot both | Both themes render without broken colors |
| Copy quality | Read all new user-facing text | No placeholders; labels <=3 words; active verb CTAs |
| Interaction pairs | Click every new element on AND off | Toggle, back, select, deselect all work |
| Console clean | `preview_console_logs(level='error')` | Zero JS errors |
| Mobile fit | Verify at 390x844 viewport | No horizontal scroll; all content within viewport |

If any check fails, fix before proceeding. All checks MUST pass before bumping.

**Blast-Radius Rule (fix all instances, not just the one reported):**

1. Identify the **pattern**, not just the instance
2. Grep the entire codebase for the same pattern
3. Fix ALL instances in one pass before committing
4. Add a CSS or JS guard that prevents recurrence
5. Never fix one instance and ship — the user should never report the same class of bug twice

**Auto-Deploy (mandatory after verification passes):**

1. **Local preview:** Ensure dev server running (`preview_start` with config `arx-prototype` on port 8080). Confirm via screenshot.
2. **Vercel sync:** Deploy with `npx vercel --prod --archive=tgz` (run in background).
3. **Report:** Show local URL (http://localhost:8080) and Vercel production URL.

**Output:** Updated `apps/web-prototype/index.html` with version bump. Live on local + Vercel.

---

## feature <spec or description>

**Purpose:** Full feature implementation with TDD. Strictly sequential.

**Team decision:**
- If feature touches 3+ systems (backend + frontend + tests): Create team `build-{feature-slug}` with named teammates
- Otherwise: Sequential execution (current behavior — single session)

**If team mode:**
```
TeamCreate(team_name="build-{feature-slug}")
```
- `backend` (sonnet, worktree) — API, data layer, types
- `frontend` (sonnet, worktree) — screens, components, hooks
- `tests` (haiku) — test files only
- TaskCreate per phase with `blockedBy` — frontend blocks on backend's API contract
- Backend sends API contract to frontend via `SendMessage(to="frontend", message="API types ready: {types}")`
- Shutdown all after tests pass: `SendMessage(to="*", message={type: "shutdown_request"})` then `TeamDelete`

**Subagent configuration (CC forked agent pattern):**
- **Tool allowlist:** Read, Edit, Write, Bash, Grep, Glob (no WebSearch, no MCP unless needed)
- **Turn budget:** 25 turns max per phase agent — prevents runaway loops
- **Model:** sonnet for implementation, haiku for test scaffolding
- **Cache-friendly prompt:** Use identical system prefix across phase agents (project context, CLAUDE.md) — vary only the phase-specific task suffix

**Before building:**

1. Read the relevant spec from `specs/`
2. If a prototype exists, read `apps/web-prototype/index.html` for visual guidance
3. Read `apps/mobile/CLAUDE.md` if it exists
4. Check existing components in `apps/mobile/src/components/`

**Process (strictly sequential — each step must complete before the next):**

1. **Read spec/plan** if available. If the spec contains an `<!-- AGENT: -->` block, extract it and load ONLY the referenced key files, dependencies, and test paths — not the full spec tree. This is the **focused context protocol** (from GSD's `<files_to_read>`).
   ```html
   <!-- AGENT: This spec defines [feature].
        Key files: [paths to implementation files]
        Key decisions: [spec refs for design decisions]
        Dependencies: [other specs this depends on]
        Test: [path to test directory]
   -->
   ```
2. **Comprehension check:** "Here's what I understand... correct?" — present restated requirements and wait for confirmation
3. **Write tests first (RED):** Use tdd-guide agent. Tests MUST fail before proceeding.
4. **Implement to pass tests (GREEN):** Write minimal code to make tests pass. Follow existing patterns in `apps/mobile/src/`.
5. **Refactor (IMPROVE):** Clean up while tests still pass. Messy first pass is fine if you clean up immediately.
6. **Verify 80%+ coverage:** Run coverage tools. If under 80%, write more tests.
7. **Commit:** Small commit, clear message.

**For large features:** Spawn executor subagents with fresh context per phase. Orchestrator stays thin (30-40% context usage). Each phase gets its own agent with:
- The plan for that phase only
- Relevant source files (not the whole codebase)
- Clear entry/exit criteria

**Deviation rules:**

- **Auto-fix:** Bugs encountered during implementation — fix inline, note in commit
- **Auto-add:** Missing critical imports, wiring, type definitions — add without asking
- **Auto-fix:** Blocking issues (type errors, missing deps) — resolve to unblock
- **ASK:** Architectural changes — "I need to restructure X, is that OK?"
- **ASK:** New dependencies — "I want to add library X for Y, approve?"
- **ASK:** Scope expansion — "This also needs Z which wasn't in the plan, should I include it?"

**Tools to use:**

- **tdd-guide agent** — enforces write-tests-first
- **shadcn MCP** — `get_component` and `get_block` for production-ready components
- **Figma MCP** — `get_design_context` for design tokens
- **Hyperliquid MCP** — for trading data integration

**Stack (already configured):** Zustand (state), Tailwind 4 (styling), Framer Motion (animations).

**Write tests in the same context window as implementation** — tests with full context catch more issues than tests written in isolation.

**Exit Gate:** Tests pass AND visual verification via screenshot/snapshot.

**Verification step (mandatory):** After implementation, include a one-liner the user can run to verify the change works. Examples: `npm test -- --grep auth`, `curl localhost:3000/api/health`, `open index.html`. If no automated verification exists, describe the exact manual check. This is the single highest-leverage quality improvement — it 2-3x the quality of the final result.

**Spec Sync:** After building, check if implementation diverges from spec. Update spec with `<!-- Synced from apps/mobile vX.X.X -->` and note deviations with rationale.

---

## component <name>

**Purpose:** Build a reusable component for the mobile app.

**Before building:**

1. Read `specs/Arx_4-2_Design_System.md` for design tokens
2. Check if shadcn has an equivalent: use shadcn MCP `get_component` and `get_component_demo`
3. Check if Figma has the component: use Figma MCP `get_design_context`
4. Check existing components in `apps/mobile/src/components/` to avoid duplication
5. Read arx-ui-stack skill if available for Arx-specific patterns

**Build process (strictly sequential):**

1. Write component test first (Vitest + Testing Library). Run it. Confirm it FAILS.
2. Implement component in `apps/mobile/src/components/<feature>/`
3. Use design tokens via CSS variables, never hardcode values
4. Handle all states: loading, empty, error, populated, disabled
5. Ensure accessibility (ARIA labels, keyboard navigation, focus management)
6. Run test. Confirm it PASSES.
7. Refactor if needed, re-run tests.
8. Add exports to index file.
9. Write brief JSDoc or inline documentation for props and usage.
10. Commit this component before starting the next one.

**Output:** Component file + test file + exports in `apps/mobile/src/components/`.

---

## fix

**Purpose:** Analyze and fix build errors, type errors, lint failures. Never make architectural changes — only fix errors.

**Process:**

1. Update scratchpad: `Build > fix`
2. Use **build-error-resolver** agent
3. **Run diagnostic commands:**
   ```bash
   npx tsc --noEmit --pretty
   npm run build
   npx eslint . --ext .ts,.tsx
   ```
4. **Parse errors** — group by type (type error, lint, build, runtime)
5. **Fix incrementally** — one error category at a time, smallest fix possible
6. **Verify after each fix** — re-run the failing command to confirm the fix works
7. **Never:**
   - Add `@ts-ignore` or `any` type to suppress errors (fix the actual type)
   - Disable lint rules to hide warnings (fix the code)
   - Make architectural changes (that's a `feature` or `refactor`)
   - Change test expectations to match broken code (fix the implementation)

**Output:** Fixed files. All diagnostic commands pass clean.

---

## tdd <feature or test>

**Purpose:** Enforce Red-Green-Refactor cycle. Use tdd-guide agent.

**Process:**

1. Parse target from remaining `$ARGUMENTS`
2. Update scratchpad: `Build > tdd`, target
3. **RED — Write test first:**
   - Write the test that describes the desired behavior
   - Run it — it MUST fail
   - If it passes, the test is wrong (testing existing behavior, not new behavior)
4. **GREEN — Write minimal implementation:**
   - Write the smallest amount of code to make the test pass
   - No premature optimization, no extra features
   - Run the test — it MUST pass
5. **REFACTOR — Clean up:**
   - Improve code quality while tests still pass
   - Extract functions, rename variables, remove duplication
   - Run tests after each refactor step — they must still pass
6. **Verify coverage (80%+):**
   - Run coverage tool
   - If under 80%, add tests for uncovered paths

**Edge cases required (every TDD cycle must cover):**

- Null/undefined input
- Empty arrays/strings
- Boundary values (0, -1, MAX_INT, empty string vs whitespace)
- Error paths (network failure, invalid data, timeout)
- Race conditions (concurrent operations, stale state)
- Large data (performance with 1000+ items)
- Special characters (unicode, emoji, SQL injection attempts, XSS payloads)

**Output:** Test files + implementation files. All tests green. Coverage 80%+.

---

## refactor

**Purpose:** Dead code cleanup and simplification. Use refactor-cleaner agent.

**Rules:**

- **Never refactor during active feature development.** Finish the feature first, then refactor.
- **Never refactor without tests.** If there are no tests for the code being refactored, write tests first.
- **Never change behavior during refactor.** Tests must pass before AND after, with no changes to test expectations.

**Process:**

1. Update scratchpad: `Build > refactor`
2. **Run detection tools:**
   ```bash
   npx knip          # unused exports, files, dependencies
   npx depcheck      # unused npm dependencies
   npx ts-prune      # unused TypeScript exports
   ```
3. **Categorize findings by risk:**
   - **SAFE:** Unused imports, dead utility functions, commented-out code, unused CSS → remove immediately
   - **CAREFUL:** Unused exports that might be used dynamically, functions only called in tests → verify before removing
   - **RISKY:** Functions used via string references, dynamic imports, reflection → require deep analysis before removal
4. **Remove SAFE items first** — commit after each batch
5. **Run full test suite after each batch** — any failure means revert the batch and investigate
6. **Consolidate duplicates:**
   - Find functions/components that do the same thing in different ways
   - Pick the better implementation, redirect callers, remove the worse one
   - Run tests after each consolidation
7. **Report what was removed:**
   - Lines of code removed
   - Files deleted
   - Dependencies uninstalled
   - Bundle size change (if measurable)

**Output:** Cleaner codebase. Fewer files, fewer dependencies, smaller bundle. All tests still pass.

---

## Comprehension Check — Cognitive Debt Gate

**Applies to all sub-commands.** Before marking any build session complete:

1. **Explain it back:** Can Gary explain what this code does without re-reading it? If not, simplify, add comments, or refactor until clear.
2. **Flag black boxes:** Any sections where logic isn't immediately obvious get a brief inline comment explaining the "why."
3. **Log unknowns:** If generated code works but the mechanism isn't fully understood, log it in `specs/Arx_9-5_Hypothesis_Question_Log.md` under "Comprehension Debt."

This gate exists because AI generates code at 140-200 lines/min but humans comprehend at 20-40 lines/min. Velocity without understanding creates fragile systems.

---

## Universal Post-Build QA Checklist

**Applies to ALL sub-commands (prototype, feature, component).** Run after every change, before commit:

| Check | Method | Pass Criteria |
|-------|--------|---------------|
| Plan alignment | Re-read plan/instruction | Every requirement has corresponding code change |
| Visual consistency | Screenshot all changed screens | Selected != unselected states; no clipped text |
| Dark + light mode | Toggle theme, screenshot both | Both themes work |
| Copy quality | Read all new user-facing text | No placeholders; labels <=3 words; active verb CTAs |
| Interaction pairs | Click every new element on AND off | Toggle, back, select, deselect all work |
| Console clean | `preview_console_logs(level='error')` | Zero JS errors |
| Mobile fit | Verify at 390x844 viewport | No horizontal scroll |

If any check fails, fix before commit. Never ship with known visual or interaction bugs.

## Safety (when hooks unavailable)
Before any destructive command (rm -rf, git push --force, git reset --hard, DROP TABLE, kubectl delete, docker system prune), ALWAYS ask for explicit confirmation. Never auto-approve destructive operations.
