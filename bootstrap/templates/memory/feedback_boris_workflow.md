---
name: Boris Cherny Workflow Adopted
description: User adopted the Boris Cherny Claude Code workflow — spec-first, parallel sessions, prototypes over PRDs, simplify+verify loops
type: feedback
---

User wants to follow the Boris Cherny (Claude Code creator) workflow for all projects:

1. **Spec first** — always start in Plan Mode, produce a spec, get approval before coding
2. **Parallel sessions** — use git worktrees for 3-5 simultaneous Claude sessions
3. **Prototypes over PRDs** — build working prototypes, not documents
4. **Simplify pass** — run `/simplify` after every implementation
5. **Prove it works** — run `/prove-it` to verify with evidence, not claims
6. **Grill before commit** — run `/grill-me` for ruthless review before committing
7. **CLAUDE.md as living memory** — add rules when Claude makes mistakes

**Why:** User wants maximum productivity and quality from Claude Code sessions, following the workflow of the tool's creator.

**How to apply:** At the start of any non-trivial task, suggest starting with `/spec`. After implementation, proactively suggest `/simplify` then `/prove-it`. Before commits, suggest `/grill-me`. For multi-feature work, suggest parallel worktrees.
