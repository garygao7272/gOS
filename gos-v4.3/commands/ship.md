---
description: "Ship — deliver: commit, pr, deploy, docs, release, publish, pitch — or full ship sequence"
---

# Ship — Delivery Pipeline

**Purpose:** Ship whatever changed — specs, code, docs. Ship doesn't filter by file type. It packages work into commits, PRs, deployments, and documentation updates.

Parse the first word of `$ARGUMENTS` to determine sub-command. If none given, run the full ship sequence.

---

## Intent Gate (mandatory — runs before any sub-command)

**First-Principles Decomposition.** Every request is broken into 6 MECE dimensions before execution.

### Step 1: DECOMPOSE

Parse Gary's request. Fill every dimension and classify:

| Dim | Question | ✅ Stated | 🔮 Inferred | ❌ Unknown |
|-----|----------|-----------|-------------|-----------|
| **WHAT** | What are we shipping? (commit, PR, deploy, release, publication) | Gary named it | Derivable from context | Must ask |
| **WHY** | What outcome? (merge to main, deploy to prod, publish externally) | Gary stated purpose | Implied by sub-command | Must ask |
| **WHO** | Who is the audience? (team, users, investors, public) | Gary specified | Obvious from destination | Must ask |
| **HOW** | What method? (direct commit, PR review, staged deploy, multi-platform) | Gary chose sub-command | Matches risk level | Must ask |
| **SCOPE** | Which parts? (all changes, specific files, specific branch) | Gary bounded it | Inferrable from diff | Must ask |
| **BAR** | What standard? (reviewed, gate-passed, fully tested) | Gary set the bar | Implied by destination | Must ask |

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

> **Plan: Ship > {sub-command}**
> - **Scope:** {WHAT + SCOPE resolved}
> - **Files:** {which files will be staged/committed}
> - **Destination:** {branch, remote, PR target, platform}
> - **Agents:** {N-agent team / single agent / inline}
> - **Output:** {commit hash, PR URL, deploy URL, etc.}

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

**[skip-gate] sub-commands** (read-only or auto-mode):
- `diff` — read-only display of changes
- `pulse` — read-only one-line status
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

1. Infer domain from resolved WHAT (e.g., "ship deploy" → `deployment`)
2. Read `sessions/trust.json` → get trust level for this domain
3. Adjust gate depth accordingly (T0=full, T1=lighter confirm, T2=execute-first, T3=silent)
4. Note: `deployment` has floor=T1 — never auto-promote above T1
5. Show trust context: "Trust: `{domain}` at T{N} ({history summary})"
6. **Write scratchpad marker:** Update Pipeline State: `- [x] Trust Level: T{N} for {domain}`

---

## Pipe Resolution (runs after Context Protocol, before execution)

Check for upstream artifacts that match the current task. See `gOS/.claude/artifact-schema.md` for the full schema and algorithm.

1. Parse WHAT from resolved intent
2. Search `outputs/` for files with matching topic in YAML frontmatter
3. Filter by types relevant to `/ship`: verdict (MUST be APPROVE status)
4. **Blocking rule:** `/ship deploy` and `/ship pr` REQUIRE a passing verdict. If none found: "Deploy blocked — no passing `/review gate` verdict. Run `/review gate` first."
5. If found: present list and auto-load as context ("📎 Upstream artifacts found...")
6. Update `outputs/ARTIFACT_INDEX.md` after writing output
7. **Write scratchpad marker:** Update Pipeline State: `- [x] Pipe Resolved: {N} upstream artifacts loaded` or `- [x] Pipe Resolved: none found`

---

## (no args) — Full Ship Sequence

The complete delivery pipeline. Run when work is done and ready to go out.

1. **Review gate:** Check if `/review` (code-reviewer agent) has been run on this work.
   - If review dashboard exists and is NOT CLEARED (has unresolved CRITICAL or HIGH issues): warn Gary and ask "Review has unresolved issues. Proceed anyway?"
   - If no review was run: warn "No review on record. Want to run /review first or ship anyway?"
   - If review is CLEARED: proceed silently.

2. **Final test run:** Run the project's test suite one last time.
   - `npm test` or equivalent for the active app
   - If tests fail: STOP. Report failures. Do not ship broken code.

3. **Stage files:** Run `git status` to see what changed. Stage relevant files individually.
   - NEVER use `git add -A` or `git add .`
   - Add specific files by name
   - Skip files that look like secrets (.env, credentials, tokens)
   - Skip large binary files unless intentional

4. **Create commit:** Follow conventional commit format.
   - Read recent `git log --oneline -10` for style consistency
   - Analyze the diff to determine type: feat, fix, refactor, docs, test, chore, perf, ci
   - Write concise message (1-2 sentences, focus on "why" not "what")
   - No Co-Authored-By line (attribution disabled globally)

5. **Push:** Push to remote.
   - Use `-u` flag if this is a new branch
   - Never force-push without explicit approval

6. **Create PR:** Via `gh pr create`.
   - Title: <70 chars
   - Body format:
     ```
     ## Summary
     <1-3 bullet points>

     ## Test plan
     - [ ] ...

     Generated with gOS
     ```
   - Return PR URL

7. **Auto-docs:** Trigger `/ship docs` automatically (see docs sub-command below).

8. **Report:**
   ```
   Shipped.
   Commit: {hash} — {message}
   PR: {url}
   Docs: {updated | no changes needed}
   ```

---

## commit

**Purpose:** Create a git commit only. No push, no PR.

**Process:**

1. Run `git status` to see all untracked and modified files
2. Run `git diff` (staged + unstaged) to see what changed
3. Read `git log --oneline -10` for recent commit message style
4. Analyze changes — determine type:
   - `feat`: new feature or capability
   - `fix`: bug fix
   - `refactor`: code restructuring, no behavior change
   - `docs`: documentation only
   - `test`: adding or updating tests
   - `chore`: maintenance, config, dependencies
   - `perf`: performance improvement
   - `ci`: CI/CD changes
5. Draft concise commit message (1-2 sentences, "why" not "what")
6. Stage specific files by name (never `git add -A` or `git add .`)
   - Skip .env, credentials, tokens, large binaries
7. Create commit
8. Run `git status` to verify clean state

No Co-Authored-By attribution line (disabled globally).

If pre-commit hook fails: fix the issue and create a NEW commit. Never `--amend` the previous commit (amending after hook failure modifies the wrong commit).

---

## pr

**Purpose:** Create a pull request only. Assumes commits already exist.

**Process:**

1. Check if current branch tracks a remote branch
   - If not tracking or behind: push with `-u` flag
2. Determine the base branch (main, master, or develop)
3. Run `git diff {base-branch}...HEAD` to see the full diff
4. Read ALL commits on the branch: `git log {base-branch}..HEAD --oneline`
   - Analyze every commit, not just the latest
5. Draft PR:
   - Title: <70 chars, summarizes the change
   - Body:
     ```
     ## Summary
     <1-3 bullet points covering ALL commits>

     ## Test plan
     - [ ] {specific test steps}

     Generated with gOS
     ```
6. Create PR via `gh pr create`
7. Return PR URL

---

## deploy

**Purpose:** Deploy to production or preview environment.

**Input:** Optionally specify target — `web` (default) or `mobile`.

**For web (Vercel):**

1. Pre-deploy checks:
   - Run build: `npm run build` (or equivalent)
   - Run lint: `npm run lint` (if configured)
   - Run tests: `npm test` (if configured)
   - If any check fails: STOP. Report the failure.
2. Deploy:
   - Use Vercel MCP `deploy_to_vercel` tool if available
   - Fallback: `npx vercel --prod --archive=tgz`
3. Monitor build logs via `get_deployment_build_logs` if build fails
4. Verify deployment URL loads correctly
5. Report deployment URL

**For mobile (Expo):**

1. Pre-deploy checks: build, lint, tests (same as web)
2. Deploy: `eas build --platform all` or `expo publish`
3. Report build URL or QR code

---

## docs

**Purpose:** Update documentation to match code changes. Absorbs the old `update-docs` and `update-codemaps` commands.

**Process:**

1. Run `git diff HEAD~1` (or `git diff` if uncommitted changes) to see what changed
2. Identify all changed files — code, specs, config
3. Search for all `.md` files in the project that might reference changed code:
   - `specs/` — product specs
   - `docs/` — documentation
   - `docs/CODEMAPS/` — architecture maps
   - `CLAUDE.md` — project instructions
   - `README.md` — project readme
   - Any other `.md` files
4. For each doc file, check if it references any changed code:
   - File paths that moved or were renamed
   - Function/component names that changed
   - API endpoints that changed
   - Configuration that changed
5. Update stale documentation with accurate information
6. If architecture changed (new modules, moved files, changed data flow):
   - Update relevant codemaps in `docs/CODEMAPS/`
   - Update project structure in `CLAUDE.md` if applicable
7. Commit doc updates separately: `docs: update documentation for {feature/change}`
   - Stage only the doc files, not code
   - This keeps doc commits distinct from code commits

---

## release

**Purpose:** Full release process — version bump, changelog, tag, PR, deploy.

**Process:**

1. **Version bump:**
   - Read current version from `package.json` (or `VERSION` file)
   - Determine bump type from recent commits:
     - Breaking changes → major
     - New features → minor
     - Bug fixes → patch
   - Ask Gary to confirm the version: "Bumping to v{version}. Correct?"
   - Update version in `package.json` (and any other version files)

2. **Changelog:**
   - Read `CHANGELOG.md` (create if it doesn't exist)
   - Gather all commits since last release tag
   - Group by type (Features, Fixes, Refactors, etc.)
   - Write user-facing changelog entry under `## v{version} — {date}`
   - Focus on what changed for users, not implementation details

3. **Release commit:**
   - Stage version file + CHANGELOG.md
   - Commit: `chore: release v{version}`

4. **Tag:**
   - Create git tag: `git tag v{version}`

5. **Push:**
   - Push commits and tags: `git push && git push --tags`
   - Use `-u` flag if new branch

6. **Create PR:**
   - Run the `pr` sub-command flow

7. **Auto-docs:**
   - Run the `docs` sub-command flow

8. **Deploy (if approved):**
   - Ask: "Deploy v{version} to production?"
   - If yes: run the `deploy` sub-command flow

9. **Report:**
   ```
   Released v{version}
   Commit: {hash}
   Tag: v{version}
   PR: {url}
   Deploy: {status}
   ```

---

## publish <platform or "all">

**Purpose:** Publish content to external platforms — blog, social media, newsletter, documentation sites.

**Input:** Platform target (e.g., "blog", "x", "linkedin", "newsletter", "all") + content file path or "latest"

**Process:**

1. Parse platform and content from remaining `$ARGUMENTS`
2. **Load the content:**
   - If file path given: read it
   - If "latest": find most recent file in `outputs/` matching content type
   - If no content found: suggest running `/build content` first
3. **Platform routing:**

| Platform | Skill | Method |
|----------|-------|--------|
| `x` / `twitter` | `everything-claude-code:content-engine` + `everything-claude-code:x-api` | X API posting |
| `linkedin` | `everything-claude-code:content-engine` | Manual post (copy to clipboard) |
| `blog` | `everything-claude-code:article-writing` | CMS API or markdown deploy |
| `newsletter` | `everything-claude-code:content-engine` | Email service API (Resend/Mailchimp) |
| `all` | `everything-claude-code:crosspost` | Multi-platform distribution |

4. **Pre-publish checklist:**
   - [ ] Content reviewed (check if `/review content` was run)
   - [ ] Platform-specific formatting applied (character limits, hashtags, mentions)
   - [ ] Links are correct and not broken
   - [ ] Images/media are attached and sized correctly
   - [ ] No sensitive information in public content
   - [ ] Scheduling confirmed (post now or schedule for later?)

5. **Publish or prepare for manual posting:**
   - If API access available: publish directly (with confirmation)
   - If no API: format for manual posting and provide copy-ready output

6. **Track:**
   - Log publication to `sessions/scratchpad.md`
   - Note platform, URL, and timestamp

**Output:**
```
Published to {platform}:
  URL: {link}
  Time: {timestamp}
  Content: {first 100 chars}...
```

---

## pitch <action>

**Purpose:** Investor outreach — send updates, cold emails, intro requests, and follow-ups.

**Input:** Action type (e.g., "update", "outreach", "followup", "intro-request") + optional target

**Process:**

1. Parse action from remaining `$ARGUMENTS`
2. **Route by action:**

### pitch update
Send a monthly/quarterly investor update to existing investors.

1. Check `outputs/think/fundraise/` for update templates
2. Use `everything-claude-code:investor-materials` to draft the update
3. Structure:
   - Highlights (3 bullets)
   - Key metrics (MRR, users, runway)
   - Product updates
   - Challenges & asks
   - Next month's goals
4. Format for email
5. **Ask Gary to confirm** recipients and send method
6. Draft the email (do not send without explicit approval)

### pitch outreach
Draft cold outreach emails for potential investors.

1. Use `everything-claude-code:investor-outreach` to draft emails
2. Personalize per investor (research their portfolio, recent investments, thesis)
3. Keep emails under 150 words
4. Include: one-line pitch, traction metrics, specific ask
5. Generate 3-5 variants for A/B testing

### pitch followup
Draft follow-up emails after meetings or introductions.

1. Reference the specific meeting/intro
2. Address any questions raised
3. Attach relevant materials (deck, one-pager)
4. Clear next step with specific date

### pitch intro-request
Draft warm intro requests for mutual connections to relay.

1. Write the forwardable blurb (the email the connector sends)
2. Include: who you are, what you're building, why this investor, specific ask
3. Make it easy to forward — self-contained, no jargon

**Output:** Draft email(s) ready for review. **Never send without explicit Gary approval.** Suggest: "Review these drafts and I'll help you send them?"

---

## Safety Rules

These are non-negotiable:

- **Never `git add -A` or `git add .`** — could include secrets (.env, tokens) or large files
- **Never force-push** without explicit approval from Gary
- **Never skip hooks** (`--no-verify`) — if a hook fails, fix the issue
- **Never `--amend`** after a hook failure — the failed commit didn't happen, so amend modifies the wrong commit. Create a NEW commit instead.
- **Ship everything that changed** — specs, code, docs, config. Don't filter by file type.
- **One commit per logical change** — don't bundle unrelated changes

---

## Output Contract (MANDATORY — runs after execution, before presenting)

**You MUST complete all steps before showing output to Gary.** See `gOS/.claude/output-contract.md` for the full rubric.

1. Score on 5 universal dimensions (1-5): Completeness, Evidence, Actionability, Accuracy, Clarity
2. Score on Ship extension: **Safety** (1-5) — skipped checks vs all gates passed
3. Identify weakest dimension
4. If any dimension ≤ 2 → flag and offer to improve before Gary reads
5. Skip Confidence Calibration for ship (pass/fail binary)
6. Present scorecard at top of output
7. **Write scratchpad markers:** Update Pipeline State:
   - `- [x] Output Scored: {avg}/5 (weakest: {dimension})`
   - `- [x] Frontmatter Written: {path}`
   - `- [x] Index Updated: {topic} added to ARTIFACT_INDEX`

---

## Red Team Check (runs after Output Contract, before presenting)

**Ship red team question:** "What's the worst thing that could happen if we ship this now?"

1. Run the red team question against the draft output
2. If a genuine issue is found (would change Gary's decision):
   a. Fix it if possible (add safety checks)
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
