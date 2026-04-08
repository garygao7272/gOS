---
dimension: Memory
number: 4
weight: 1.5
---

# Memory

**What it measures:** Cross-session recall, automated persistence, memory layering, and staleness prevention.

## Scoring Ladder

| Score | Level | Evidence Required |
|-------|-------|-------------------|
| 1-3 | Amnesiac | No memory system. Every session starts from scratch. |
| 4-5 | Manual | Memory files exist but only read when explicitly asked. No auto-writes. Stale content. |
| 6-7 | Semi-auto | L1 auto-loaded at session start. Memory searched before plans. /gos save writes memories. But no automated writes during session. |
| 8-9 | Wired | Auto-search before every plan (L1 + claude-mem). Stop hook writes feedback/project memories. PreCompact saves scratchpad. L1 updated every session. |
| 10 | Living | Real-time memory — learns mid-session, promotes instincts automatically, detects and invalidates stale memories, cross-references across projects. |

## What to Check

- Does Step 0 read L1_essential.md?
- Does Step 0 search claude-mem for relevant context?
- Does /gos save update L1, feedback memories, and claude-mem?
- Does the Stop hook prompt memory writes?
- Is L1 current (not stale from weeks ago)?
- Are dead ends saved to prevent repeat failures?
- Does /gos resume load state.json for checkpoint recovery?

## Weight: 1.5x

Memory is weighted higher because it's the foundation for learning, planning, and reliability. Poor memory cascades into poor everything.
