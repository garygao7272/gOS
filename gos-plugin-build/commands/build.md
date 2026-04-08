---
description: "Build: plan, prototype, feature, component, fix, tdd, refactor, model, deck, content, playbook, proposal — outputs to apps/ and outputs/"
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

Parse the first word of `$ARGUMENTS` to determine sub-command. If no sub-command given, ask: "What are we building? plan, prototype, feature, component, fix, tdd, refactor, model, deck, content, playbook, or proposal?"

---

## Intent Gate (mandatory — runs before any sub-command)

**First-Principles Decomposition.** Every request is broken into 6 MECE dimensions before execution.

### Step 1: DECOMPOSE

Parse Gary's request. Fill every dimension and classify:

| Dim | Question | ✅ Stated | 🔮 Inferred | ❌ Unknown |
|-----|----------|-----------|-------------|-----------|
| **WHAT** | What are we building? (feature, component, fix, model, deck) | Gary named it | Derivable from context | Must ask |
| **WHY** | What outcome? (new capability, fix bug, refactor, deliver artifact) | Gary stated purpose | Implied by sub-command | Must ask |
| **WHO** | Who is this for? (S7 users, S2 traders, investors, internal) | Gary specified | Obvious from feature | Must ask |
| **HOW** | What method? (plan-first, TDD, prototype, refactor) | Gary chose sub-command | Matches complexity | Must ask |
| **SCOPE** | Which parts? (single file, module, full feature, cross-cutting) | Gary bounded it | Inferrable from context | Must ask |
| **BAR** | What standard? (prototype, production, ship-ready) | Gary set the bar | Implied by stage | Must ask |

### Step 2: PRESENT & CLARIFY

Show the decomposition:

> | Dim | Value | Status |
> |-----|-------|--------|
> | WHAT | {target} | ✅/🔮/❌ |
> | WHY | {purpose} | ✅/🔮/❌ |
> | WHO | {audience} | ✅/🔮/❌ |
> | HOW | {approach} | ✅/🔮/❌ |
> | SCOPE | {boundary} | ✅/🔮/❌ |
> | BAR | {standard} | ✅/🔮/❌ |

- **❌ Unknown** → ask ONE batched question covering all unknowns
- **🔮 Inferred** → state for confirmation
- **All ✅/🔮** → skip to Step 3

### Step 3: PLAN

> **Plan: Build > {sub-command}**
> - **Scope:** {WHAT + SCOPE resolved}
> - **Reads:** {files/data to consume}
> - **Writes:** {files/output to create}
> - **Agents:** {N-agent team / single agent / inline}
> - **Output:** {format → destination path}

**Before presenting "Go?":** Write to `sessions/scratchpad.md`:
- Update `## Current Task` with the resolved WHAT
- Update `## Mode & Sub-command` with the command > sub-command
- Update Pipeline State: `- [x] Intent Gate: WHAT={what} | WHY={why} | WHO={who} | HOW={how} | SCOPE={scope} | BAR={bar}`

### Step 4: CONFIRM
> **Go?**

**HARD STOP.** End your message here. Do NOT:
- Add a "preview" or "meanwhile" or "while you decide"
- Start producing output in the same message
- Say "Go?" and then keep writing

The message containing "Go?" must contain NOTHING after it. Wait for Gary's next message before doing any work.

### Step 5: PLAN MODE (mandatory after Gary confirms)

When Gary confirms ("go", "yes", "do it"), you MUST call `EnterPlanMode` before doing ANY work. This is not optional. This is deterministic:

```
Gary says "go" → call EnterPlanMode() → write plan to plan file → call ExitPlanMode() → Gary approves → THEN execute
```

**Exceptions (skip plan mode):**
- `--auto` flag (mobile dispatch)
- Trust level T2+ for this domain
- Sub-commands marked `[skip-gate]`

**[skip-gate] sub-commands** (immediate or interactive — no side-effect planning needed):
- `fix` — immediate diagnostic loop, proceeds directly
- `tdd` — interactive RED-GREEN cycle, proceeds directly
- Any sub-command with `--auto` flag (mobile dispatch — skip gate, use safe defaults)

---

## Context Protocol (runs after Intent Gate, before execution)

After the Intent Gate resolves all 6 dimensions, auto-load relevant context. See `gOS/.claude/context-map.md` for the full keyword → source mapping.

1. Parse resolved WHAT and SCOPE for keywords
2. Match against context map → candidate sources
3. Check file existence (skip missing silently)
4. Estimate token cost (lines / 4)
5. If total < 30% of remaining context → load silently
6. If total > 30% → present list and ask Gary to trim
7. Log loaded context to `sessions/scratchpad.md` under `Working State`
8. **Write scratchpad marker:** Update `sessions/scratchpad.md` Pipeline State: `- [x] Context Loaded: {list of files loaded or "none needed"}`

---

## Memory Recall (runs after Context Protocol, before Trust Check)

Query persistent memory for relevant past experience before executing. This is how gOS learns across sessions.

1. **Search claude-mem** for the current command + domain:
   - `mcp__plugin_claude-mem_mcp-search__search({ query: "{WHAT} {sub-command}", type: "observation", limit: 5 })`
   - Also search: `mcp__plugin_claude-mem_mcp-search__search({ query: "{domain} {sub-command} signal", limit: 3 })`
2. **Check self-model** for domain competence:
   - Read the row for `{domain}` in `.claude/self-model.md`
   - If accept rate < 70% or weaknesses listed → flag: "Note: my `{domain}` has {weakness}. Adjusting approach."
3. **Surface relevant findings:**
   - If past sessions had reworks/rejects in this domain → mention what went wrong and how you'll avoid it
   - If past sessions had accepts/loves → mention what worked and reuse the approach
   - If no relevant history → say "No prior experience in this domain — running full pipeline."
4. **Write scratchpad marker:** Update Pipeline State: `- [x] Memory Recalled: {N} observations, self-model: {domain} T{N} {accept_rate}`

**Keep it brief.** One line of insight, not a paragraph. The goal is to inform execution, not to recite history.

---

## Trust Check (runs after Context Protocol, before Pipe Resolution)

Check trust level for the current domain. See `gOS/.claude/trust-ladder.md` for rules.

1. Infer domain from resolved WHAT (e.g., "build copy trading feature" → `architecture`)
2. Read `sessions/trust.json` → get trust level for this domain
3. Adjust gate depth accordingly (T0=full, T1=lighter confirm, T2=execute-first, T3=silent)
4. Show trust context: "Trust: `{domain}` at T{N} ({history summary})"
5. **Write scratchpad marker:** Update Pipeline State: `- [x] Trust Level: T{N} for {domain}`

---

## Pipe Resolution (runs after Context Protocol, before execution)

Check for upstream artifacts that match the current task. See `gOS/.claude/artifact-schema.md` for the full schema and algorithm.

1. Parse WHAT from resolved intent
2. Search `outputs/` for files with matching topic in YAML frontmatter
3. Filter by types relevant to `/build`: research-brief, design-spec, decision, build-plan
4. If found: present list and auto-load as context ("📎 Upstream artifacts found...")
5. If not found: proceed without — build can work from specs alone
6. Update `outputs/ARTIFACT_INDEX.md` after writing output
7. **Write scratchpad marker:** Update Pipeline State: `- [x] Pipe Resolved: {N} upstream artifacts loaded` or `- [x] Pipe Resolved: none found`

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

1. **No inline styles for toggle states.** Visual states MUST be driven by CSS classes (`.selected`, `.active`), NEVER by inline `style=""` attributes. Use `style.removeProperty()` to clear inherited inline styles before relying on class-based styling.
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

If any check fails, fix before proceeding. Do NOT bump with known issues.

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
   - **RISKY:** Functions used via string references, dynamic imports, reflection → do NOT remove without deep analysis
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

---

## model <type>

**Purpose:** Build financial models — spreadsheets, projections, and quantitative analyses. Uses financial-analysis skills.

**Input:** Model type (e.g., "3-statement", "dcf", "lbo", "unit-economics", "revenue-forecast", "budget", "cap-table")

**Routing table:**

| Model Type | Skill to Invoke | Output Format |
|-----------|----------------|---------------|
| `3-statement` | `financial-analysis:3-statement-model` | Excel (.xlsx) |
| `dcf` | `financial-analysis:dcf` or `financial-analysis:dcf-model` | Excel (.xlsx) |
| `lbo` | `financial-analysis:lbo` or `financial-analysis:lbo-model` | Excel (.xlsx) |
| `comps` | `financial-analysis:comps` or `financial-analysis:comps-analysis` | Excel (.xlsx) |
| `unit-economics` | `private-equity:unit-economics` | Markdown + spreadsheet |
| `revenue-forecast` | Build from scratch with assumptions | Excel (.xlsx) |
| `budget` | Build from scratch with line items | Excel (.xlsx) |
| `cap-table` | Build from scratch with rounds | Excel (.xlsx) |
| `merger` | `investment-banking:merger-model` | Excel (.xlsx) |

**Process:**

1. Parse model type from remaining `$ARGUMENTS`
2. Update scratchpad: `Build > model`, type
3. **Gather inputs:**
   - Ask for or search for: revenue figures, growth rates, margins, headcount, funding history
   - Check `outputs/think/finance/` for prior analysis
   - Check existing financial models in the project
4. **Invoke the matched skill** with gathered inputs
5. **Validate the model:**
   - Balance sheet balances (A = L + E)
   - Cash flow reconciles
   - Growth rates are consistent across statements
   - No circular references
   - Sensitivity tables work
6. **Audit with `/review financial`** after building

**Output:** Financial model file + summary markdown. Suggest: "Run scenarios with `/simulate revenue`?" or "Audit with `/review financial`?"

---

## deck <type>

**Purpose:** Build presentation decks — pitch decks, sales decks, board decks, one-pagers, internal presentations.

**Input:** Deck type (e.g., "pitch", "sales", "board-update", "investor-update", "one-pager", "internal", "competitive")

**Routing table:**

| Deck Type | Skill to Invoke | Slides |
|----------|----------------|--------|
| `pitch` | `investment-banking:pitch-deck` + `anthropic-skills:pptx` | 10-15 |
| `sales` | `anthropic-skills:pptx` + `anthropic-skills:communication-narrative` | 8-12 |
| `board-update` | `anthropic-skills:pptx` | 6-10 |
| `investor-update` | `everything-claude-code:investor-materials` | 5-8 |
| `one-pager` | `investment-banking:one-pager` or `investment-banking:strip-profile` | 1-2 |
| `teaser` | `investment-banking:teaser` | 1 |
| `internal` | `anthropic-skills:pptx` + `anthropic-skills:internal-comms` | Varies |
| `competitive` | `financial-analysis:competitive-analysis` | 8-12 |

**Process:**

1. Parse deck type from remaining `$ARGUMENTS`
2. Update scratchpad: `Build > deck`, type
3. **Gather content:**
   - Read existing specs for company narrative, product details, metrics
   - Read `outputs/think/finance/` for financial data
   - Read `outputs/think/fundraise/` for fundraising strategy
   - Ask Gary for any specific data points, metrics, or narrative angles
4. **Build the deck using the matched skill**
5. **Apply design quality:**
   - Consistent visual language
   - Data visualization over bullet points
   - One key message per slide
   - No wall-of-text slides
6. **QA check:**
   - Numbers consistent across all slides
   - No placeholder text remaining
   - Company name and branding correct
   - All charts have labels and sources

**Output:** PowerPoint file (.pptx) or HTML presentation. Suggest: "Review with `/review content`?" or "Send to investors with `/ship pitch`?"

---

## content <type>

**Purpose:** Create written content — blog posts, articles, newsletters, social media posts, documentation, job descriptions, legal documents.

**Input:** Content type + topic (e.g., "blog post about copy trading", "newsletter Q1 update", "jd senior engineer", "terms-of-service", "case-study")

**Routing table:**

| Content Type | Skill to Invoke | Output |
|-------------|----------------|--------|
| `blog` / `article` | `everything-claude-code:article-writing` | Markdown |
| `newsletter` | `everything-claude-code:article-writing` | HTML email |
| `social` / `post` / `thread` | `everything-claude-code:content-engine` | Platform-native posts |
| `jd` / `job-description` | Build from `/think hire` output | Markdown |
| `terms` / `tos` / `privacy` | Build from `/think legal` output | Markdown / HTML |
| `case-study` | `anthropic-skills:communication-narrative` | Markdown |
| `memo` / `brief` | `anthropic-skills:internal-comms` | Markdown |
| `docs` / `guide` | `anthropic-skills:doc-coauthoring` | Markdown |
| `email` | `anthropic-skills:communication-narrative` | Text |

**Process:**

1. Parse content type and topic from remaining `$ARGUMENTS`
2. Update scratchpad: `Build > content`, type + topic
3. **Research phase:**
   - Read relevant specs, prior content, brand guidelines
   - If topic-specific: search for current data, trends, examples
   - If Gary has provided brand voice guidelines, load them
4. **Draft the content** using the matched skill
5. **Quality check:**
   - Tone matches brand voice
   - No placeholder text
   - All claims are sourced or supportable
   - CTA is clear (if applicable)
   - Length is appropriate for format

**Output:** Content file in appropriate format. Suggest: "Review with `/review content`?" or "Publish with `/ship publish`?"

---

## playbook <type>

**Purpose:** Build operational playbooks — structured processes with steps, decision trees, templates, and checklists.

**Input:** Playbook type (e.g., "hiring", "sales", "onboarding", "incident-response", "customer-support", "launch")

**Process:**

1. Parse playbook type from remaining `$ARGUMENTS`
2. Update scratchpad: `Build > playbook`, type
3. **Research phase:**
   - Search for industry best practices for this playbook type
   - Check existing specs and processes
   - Review any prior `/think` outputs related to this domain
4. **Build the playbook:**

```markdown
# {Type} Playbook

## Purpose
{Why this playbook exists — what problem it solves}

## Scope
{What this playbook covers and what it doesn't}

## Process Overview
{Flowchart or numbered steps — high level}

## Detailed Steps

### Step 1: {Name}
- **Owner:** {role}
- **Input:** {what's needed to start}
- **Actions:**
  1. {action}
  2. {action}
- **Output:** {what's produced}
- **Decision point:** {if X → go to step Y, if Z → go to step W}

### Step 2: {Name}
...

## Templates
{Reusable templates for common tasks within this playbook}

## Metrics & KPIs
| Metric | Target | Measurement Method |
|--------|--------|-------------------|

## Common Pitfalls
- {pitfall 1 — how to avoid}
- {pitfall 2 — how to avoid}

## Escalation Path
{When and how to escalate issues}
```

**Output:** Playbook document. Suggest: "Review with `/review compliance`?" or "Ship with `/ship docs`?"

---

## proposal <client or project>

**Purpose:** Build client-facing proposals, SOWs, project scopes, and engagement letters.

**Input:** Client or project description (e.g., "consulting proposal for Acme Corp", "SOW for mobile app redesign", "partnership proposal for exchange integration")

**Process:**

1. Parse the proposal context from remaining `$ARGUMENTS`
2. Update scratchpad: `Build > proposal`, context
3. **Gather requirements:**
   - Ask for or infer: client name, project scope, timeline, budget range, deliverables
   - Check existing specs for relevant product/service details
   - Search for proposal templates and best practices
4. **Build the proposal:**

```markdown
# Proposal: {Project Name}

## Executive Summary
{2-3 sentences — what, why, and expected outcome}

## Problem Statement
{What the client needs solved}

## Proposed Solution
{How we solve it — approach, methodology, technology}

## Scope of Work
### Phase 1: {Name} — {Timeline}
- Deliverable 1: {description}
- Deliverable 2: {description}

### Phase 2: {Name} — {Timeline}
...

### Out of Scope
- {explicitly excluded items}

## Timeline
| Phase | Start | End | Milestones |
|-------|-------|-----|-----------|

## Investment
| Item | Cost | Notes |
|------|------|-------|
| {line item} | {$} | {details} |
| **Total** | **{$}** | |

## Terms & Conditions
{Payment schedule, IP ownership, confidentiality, termination}

## Team
| Role | Person | Responsibilities |
|------|--------|-----------------|

## Next Steps
1. {action — who, when}
2. {action — who, when}
```

**Output:** Proposal document (Markdown + optionally PPTX via `anthropic-skills:pptx`). Suggest: "Review with `/review content`?" or "Send with `/ship pitch`?"

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

---

## Team Mode for Business Sub-commands

The following business sub-commands use Agent Teams for parallel work:

### model — Team `build-model-{type}`
- **`data-gatherer` (sonnet):** Collect financial data, benchmarks, assumptions from specs and research
- **`model-builder` (sonnet):** Build the actual model (formulas, projections, scenarios)
- **`auditor` (haiku):** Validate formulas, check for errors, cross-reference consistency

### deck — Team `build-deck-{type}`
- **`content-writer` (sonnet):** Draft slide content, narrative flow, key messages
- **`designer` (sonnet):** Visual layout, data visualizations, slide design
- **`data-checker` (haiku):** Verify all numbers, dates, names are correct and consistent

### content — Team `build-content-{type}` (for long-form only; short-form is single agent)
- **`writer` (sonnet):** Draft the content
- **`editor` (haiku):** Review tone, grammar, brand voice
- **`fact-checker` (haiku):** Verify claims, links, data points

### playbook — Team `build-playbook-{type}`
- **`researcher` (sonnet):** Industry best practices, frameworks, templates
- **`writer` (sonnet):** Draft the playbook structure and content

### proposal — Team `build-proposal-{slug}`
- **`researcher` (sonnet):** Client/project research, competitive landscape
- **`writer` (sonnet):** Draft the proposal narrative and structure
- **`reviewer` (haiku):** Check for consistency, completeness, professionalism

All teams follow the standard pattern: `TeamCreate` → spawn named teammates → `SendMessage` for cross-examination → synthesis → `SendMessage(to="*", message={type: "shutdown_request"})` → `TeamDelete`.

---

## Creative Friction Check (runs after execution, before Output Contract)

See `gOS/.claude/creative-friction.md`. Build friction fires rarely — only on architecture, never on code style.

Before presenting, check: (1) Is the architecture creating technical debt that a simpler approach would avoid? → suggest the simpler path. (2) Is the framework choice mismatched to the team's reality? → flag it. **Never friction on implementation details.** That's what linters and code review are for.

Max ONE friction per task. Suppress if this is a `fix` or `tdd` sub-command (execution-focused, not architecture).

---

## Output Contract (MANDATORY — runs after execution, before presenting)

**You MUST complete all steps before showing output to Gary.** See `gOS/.claude/output-contract.md` for the full rubric.

1. Score on 5 universal dimensions (1-5): Completeness, Evidence, Actionability, Accuracy, Clarity
2. Score on Build extension: **Correctness** (1-5) — does it compile, pass tests, handle edge cases?
3. Identify weakest dimension
4. If any dimension ≤ 2 → flag and offer to improve before Gary reads
5. Skip Confidence Calibration for build (code is binary — compiles or doesn't)
6. Present scorecard at top of output
7. **Write YAML frontmatter** to the output file (per `gOS/.claude/artifact-schema.md`):
   ```yaml
   ---
   artifact_type: build-plan | code-scaffold | content-draft
   created_by: /build {sub-command}
   created_at: {ISO timestamp}
   topic: {WHAT from intent}
   related_specs: [{matched specs}]
   quality_score: {scores from step 1-2}
   status: draft
   ---
   ```
8. **Update `outputs/ARTIFACT_INDEX.md`** — add or update entry for this artifact
9. **Write scratchpad markers:** Update Pipeline State:
   - `- [x] Output Scored: {avg}/5 (weakest: {dimension})`
   - `- [x] Frontmatter Written: {path}`
   - `- [x] Index Updated: {topic} added to ARTIFACT_INDEX`

---

## Red Team Check (runs after Output Contract, before presenting)

**Build red team question:** "What's the most likely way this code breaks in production?"

1. Run the red team question against the draft output
2. If a genuine issue is found (would change Gary's decision):
   a. Fix it if possible (harden the code)
   b. If not fixable: flag in output header with ⚔️ marker
3. If finding is LOW confidence or wouldn't change any decision → suppress (no noise)
4. **Write scratchpad marker:** Update Pipeline State: `- [x] Red Team Passed: {question asked} → {finding or "clean"}`

---

## Signal Capture (MANDATORY — after every execution)

**After presenting output, observe Gary's NEXT response and classify the signal.**

1. Classify Gary's response as one of:
   - `accept` — used output without changes, moved on
   - `rework` — "change this", "not quite", "try again"
   - `reject` — "no", "scratch that", "wrong approach"
   - `love` — "perfect", "great", "exactly", "hell yes"
   - `repeat` — same instruction given twice (gOS didn't learn)
   - `skip` — Gary jumped past a prescribed step

2. **Log to `sessions/evolve_signals.md`:**
   | Time | Command | Sub-cmd | Signal | Context |
   |------|---------|---------|--------|---------|

3. **Update `sessions/trust.json`** — adjust trust level for the current domain per `gOS/.claude/trust-ladder.md`:
   - `accept`/`love` → increment consecutive accept count
   - `rework`/`reject` → reset count, demote if threshold hit
   - Check progression rules (T0→T1 needs 3+ consecutive accepts)

4. If `repeat` detected → immediately update relevant command file or memory
5. If `love` detected → save the approach to feedback memory for reuse
6. **Write scratchpad marker:** Update Pipeline State: `- [x] Signal Captured: {signal type} for {domain}`
