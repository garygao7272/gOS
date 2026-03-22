# Decision: gOS Conductor Mode (Jarvis Orchestration Layer)

**Date:** 2026-03-22
**Prompted by:** Gap analysis — gOS commands are isolated, no persistent orchestration layer
**Influenced by:** NanoClaw (24.8K stars, Karpathy-endorsed), OpenClaw ecosystem research

## Decision

Upgrade `/gos` to serve as the orchestration layer (Jarvis model). When `/gos` receives a freeform goal instead of a known sub-command, it enters **conductor mode**:

1. **Context Loading** — load specs, prototype, or other context as requested
2. **Intent Clarification** — adaptive reverse elicitation (light for simple goals, full for complex)
3. **Decomposition** — generate task graph from concrete intent, show plan, get approval
4. **Execution** — run task graph using existing gOS verbs as internal arms
5. **Reporting** — consolidated findings in `outputs/gos-jobs/{job-id}/report.md`

## Options Considered

| Option                                        | Verdict                                                                                     |
| --------------------------------------------- | ------------------------------------------------------------------------------------------- |
| Fork NanoClaw as gOS runtime                  | Rejected — wrong abstraction (messaging channels), Docker dependency, skills model mismatch |
| New `/orchestrate` command                    | Rejected — Gary's insight: `/gos` IS the conductor, like Jarvis. No new command.            |
| `/gos` as conductor with adaptive elicitation | **Chosen** — native to CLI stack, no new deps, 7 verbs become Jarvis's arms                 |

## Key Design Choices

- **Adaptive elicitation** over fixed depth (Gary confirmed)
- **Verbs remain directly accessible** — `/review code` still works without conductor overhead
- **Job state on filesystem** (`outputs/gos-jobs/`) — markdown files, no SQLite, auditable
- **Scheduled tasks for persistence** — jobs survive session boundaries via `mcp__scheduled-tasks`

## Confidence: HIGH

This is a natural evolution of gOS's architecture. The primitives (verbs, skills, agents, MCP tools) are already strong. The missing piece was the conductor that composes them.

## Review Date: 2026-04-22 (one month)
