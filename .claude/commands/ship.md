---
effort: medium
description: "Ship — deliver: commit, pr, deploy — or full ship sequence"
---

# Ship — Delivery Pipeline

**Purpose:** Ship whatever changed — specs, code, docs. Ship doesn't filter by file type. It packages work into commits, PRs, deployments, and documentation updates.

Parse the first word of `$ARGUMENTS` to determine sub-command. If none given, run the full ship sequence.

---

## Plan Gate (mandatory — runs before ANY sub-command)

**Proactive Memory Recall (execute before presenting the plan):**
1. Read `memory/L1_essential.md` — check for any blockers or pending reviews
2. Search L2 memory files for keywords matching this ship target (e.g., "deploy", "ship", "PR", "commit")
3. If L2 mentions past shipping issues, blocked deploys, or process corrections — surface it in the MEMORY field below
4. Only query L3 (claude-mem/spec-rag) if L2 doesn't have relevant context

Then present this to Gary and WAIT for confirmation:

> **PLAN:** [1-line restatement of what you'll ship — comprehension check]
> **SCOPE:** [which files/commits will be shipped]
> **STEPS:**
> 1. [action] — [why this first]
> 2. [action] — [depends on #1]
> 3. [action] — [why]
> **MEMORY:** [check L1_essential.md — "last ship: ...", "blocked by: ..."]
> **RISK:** [biggest risk — shipping is irreversible for pushes/deploys]
> **ROLLBACK:** [how to undo — "git revert", "Vercel rollback", etc.]
> **CONFIDENCE:** [high/medium/low] — [1-line reason]
>
> **Confirm?** [y / modify / abort]

After confirmation:
1. Write approved plan to `sessions/scratchpad.md` under `## Plan History`
2. Create TodoWrite items for each step
3. Begin execution step by step, updating TodoWrite as each completes

**Skip gate ONLY if:** Gary explicitly says "just do it" and scope is a single commit.

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

## Safety Rules

These are non-negotiable:

- **Never `git add -A` or `git add .`** — could include secrets (.env, tokens) or large files
- **Never force-push** without explicit approval from Gary
- **Never skip hooks** (`--no-verify`) — if a hook fails, fix the issue
- **Never `--amend`** after a hook failure — the failed commit didn't happen, so amend modifies the wrong commit. Create a NEW commit instead.
- **Ship everything that changed** — specs, code, docs, config. Don't filter by file type.
- **One commit per logical change** — don't bundle unrelated changes

---

## Signal Capture

After ship completes, log the outcome signal to `sessions/evolve_signals.md`:
- Command: `/ship`, sub-command used
- Signal: based on Gary's response (accept/rework/reject/love)
- Context: what was shipped, any issues encountered
