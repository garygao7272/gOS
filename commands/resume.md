---
description: "Restore most recent saved session — read state.json + L1 + latest session file, output Story + Table + Next Move. TRIGGER when the user says 'resume', '/resume', 'where were we', 'pick up', 'continue from last time', 'what's the status', 'what was I doing'. SKIP for fresh-start sessions with no prior context."
---

# /resume — Restore Most Recent Saved Session

**Purpose:** Re-enter a session with the right context loaded. Canonical entry — there is no `/gos resume`.

## Process

1. Read `sessions/state.json` — check for incomplete work (`phase`, `pending_approval`, `recovery_instructions`).
2. Read `memory/L1_essential.md` — active state, feedback rules, known gaps.
3. Read most recent session file from `~/.claude/sessions/` (sort by mtime, take newest).
4. Load into `sessions/scratchpad.md`.
5. Verify resume→project match: working directory should match the saved session. If mismatch, warn before loading.

## Output — Story + Table + Next Move

Write for a busy CEO. No jargon, no process narration.

- **Story (2 sentences max):** Lead with outcome, not process. What happened last, what state we're in now.
- **Table (max 6 rows):** Only actionable items. Priority column uses **Do first** / High / Medium / Low.

  | What | State | Priority |
  |------|-------|----------|

- **Next move:** Recommend highest-priority action with 1-line reasoning. Invite redirection:

  > **Suggested:** [action with reasoning]
  > What do you need?

## Staleness guards

- If the loaded session is >24h old, prefix the story with "From a day-old session:".
- If `state.json` shows `phase != completed`, surface `pending_approval` at the top of the table.
- If claude-mem is available, search for keywords from the session's current task and surface 1-2 relevant hits as `From memory (verified):`.
