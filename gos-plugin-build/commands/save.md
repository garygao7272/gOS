---
description: "Save session state + learning loop: files changed, signals, memory, state.json. TRIGGER when the user says 'save', '/save', 'save session', 'wrap up', 'end of session', 'checkpoint', or wants to persist what just happened before moving on. SKIP for automatic in-session state writes that hooks already handle."
---

# /save — Persist Session State + Learning Loop

**Purpose:** End-of-block persistence. Captures what changed, scans for evolve signals, updates memory, writes state.json. Canonical entry — there is no `/gos save`.

Save session state to `~/.claude/sessions/{date}-{slug}.md`. Capture: task, decisions, dead ends, branch, files, next steps.

## Learning Loop (mandatory on save)

**A — Capture:** Files changed, decisions made, dead ends.

**B — Record signals** to `sessions/evolve_signals.md`. Scan the ENTIRE conversation:

| Signal | Look For |
|--------|----------|
| accept | Gary used output without changes |
| rework | "Change this", "not quite", "simplify" |
| reject | "No", "scratch that", "wrong approach" |
| love | "Perfect", "great", "exactly" |
| repeat | Same instruction given twice |
| skip | Gary jumped past a prescribed step |

Every verb invocation should generate at least one signal. Report count after logging.

**C — Save to memory:** Update feedback/user/project memory files if Gary corrected approach, preferences changed, or project state shifted materially.

**D — Update persistent state:** `memory/L1_essential.md`, claude-mem observation, `sessions/state.json`, `sessions/.scratchpad_timestamp`.

## Report format

> **Session captured.** [1-line summary]. [N] files changed, [S] signals recorded, L1 [updated|unchanged], state.json [updated|unchanged].

## When to invoke

- End of a logical work block
- Before a long break / context compaction
- After a significant decision or dead end — so future sessions can pick it up
- When the session-stop hook fires with a stale timestamp (>4h) or a `/save` Mode line
