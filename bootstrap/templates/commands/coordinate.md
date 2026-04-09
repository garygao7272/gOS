---
description: "Session management: status, claim, handoff, merge, close"
---

# Coordinate Mode — Session Management → sessions/

**Manages parallel work sessions, prevents conflicts, enables handoffs.**

**Agent Teams (native).** If `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1` is set, prefer native Agent Teams for multi-agent coordination. Native teams provide real inter-agent messaging, automatic worktree isolation, shared task lists, and lead/teammate hierarchy. Fall back to manual session tracking via `sessions/active.md` when Agent Teams is unavailable.

To use native teams:

- `TeamCreate` tool to spawn teammates with specific roles
- Teammates work in isolated worktrees automatically
- `SendMessage` for inter-agent communication
- Lead coordinates, teammates execute independently

**Scratchpad checkpoints.** Update `sessions/scratchpad.md` at these moments:

- **On handoff:** Dump all scratchpad contents into the handoff document (ensures the next session inherits working context)
- **On close:** Save any valuable scratchpad content to persistent memory before clearing
- **On status:** Re-read `sessions/scratchpad.md` to include current working state in status output
- **After compaction (if you notice lost context):** Re-read `sessions/scratchpad.md` to restore state

Parse the first word of `$ARGUMENTS` to determine action. If no action given, show current status.

---

## status

**Purpose:** Show all active sessions and their ownership.

**Process:**

1. Read `sessions/active.md`
2. For each active session, check if its worktree still exists
3. Display formatted table with: Session ID, Mode, Worktree, Files Owned, Duration, Notes
4. Highlight any file ownership conflicts
5. Show recent session history (completed sessions from git log)

**Output:** Formatted status display to the user.

---

## claim <file patterns> [--worktree]

**Purpose:** Register file ownership for the current session to prevent conflicts.

**Input:** File patterns or directory paths (e.g., "apps/mobile/src/components/trade/_" or "specs/Arx_4-1-1-3_")

**Flags:**

- `--worktree` — Create an isolated git worktree for this work. The worktree branch is auto-named from the claim description (e.g., `claim "auth system" --worktree` → branch `worktree/auth-system`). This prevents merge conflicts when multiple agents work in parallel.

**Process:**

1. Read `sessions/active.md`
2. Check if any other active session owns overlapping files
3. If conflict: warn the user and ask for confirmation
4. If no conflict: add the file patterns to the current session's "Files Owned" column
5. If `--worktree` flag:
   a. Create a new branch: `git branch worktree/<slugified-description>`
   b. Create worktree: `git worktree add .claude/worktrees/<slug> worktree/<slug>`
   c. Record worktree path in `sessions/active.md`
   d. Agent works in the worktree directory
6. Update `sessions/active.md`

**Output:** Updated `sessions/active.md` with ownership claim (and worktree path if `--worktree`).

---

## handoff <notes>

**Purpose:** Create a handoff document for another session to continue the work.

**Input:** Context notes for the next session (what was done, what remains, any gotchas)

**Process:**

1. Summarize the current session's work:
   - Files changed (from git diff)
   - Decisions made (from recent memory)
   - Tests passed/failed
   - Open questions or blockers
2. Write handoff notes to `sessions/handoff-<session-id>.md`
3. Save session memory via claude-mem for cross-session persistence
4. Update `sessions/active.md` to mark session as "handing off"

**Handoff document format:**

```markdown
# Handoff from Session <id>

## What was done

- [list of completed work]

## What remains

- [list of remaining tasks]

## Key decisions made

- [decisions with rationale]

## Gotchas

- [anything the next session needs to know]

## Files touched

- [list of modified files]

## Relevant specs

- [spec files that were read or updated]
```

**Output:** Handoff file in `sessions/`. Updated memory. Updated session state.

---

## merge

**Purpose:** Merge the current worktree's work back to main and clean up.

**Process:**

1. Run all tests in the worktree
2. If tests fail: warn user, do not proceed unless explicitly approved
3. Check for merge conflicts with main
4. If conflicts: show them and help resolve
5. Merge worktree to main (rebase preferred, merge if rebase would be messy)
6. Clean up worktree
7. Update `sessions/active.md` to mark session as completed
8. Remove file ownership claims

**Safety checks:**

- Never force push
- Never delete uncommitted work
- Always show diff before merging
- Ask for confirmation before destructive operations

**Output:** Merged branch, cleaned worktree, updated session state.

---

## close

**Purpose:** End the current session without merging (work stays in worktree).

**Process:**

1. Commit any uncommitted changes with descriptive message
2. Update `sessions/active.md` to mark session as "paused"
3. Save session memory via claude-mem
4. Release file ownership claims
5. Show summary of what was done

**Output:** Committed work, updated session state, released claims.
