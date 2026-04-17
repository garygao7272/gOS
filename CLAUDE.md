# gOS — Framework Development

## What Is gOS

gOS (Gary's Operating System) is an AI builder companion framework built on Claude Code. It turns a solo founder into a full company by providing structured commands, memory, agents, and orchestration. This CLAUDE.md is for developing gOS itself — the framework, not the projects it powers.

## Commands (one home per command — no aliases, no duplicates)

| Command      | Question                   | Output                            |
| ------------ | -------------------------- | --------------------------------- |
| `/gos`       | What do you need? (Jarvis) | Briefing, aside, conductor mode   |
| `/think`     | What and why?              | Discover, research, decide, spec  |
| `/design`    | What are we building?      | Card, ui, add, audit, sync        |
| `/simulate`  | What could happen?         | Market, scenario, flow            |
| `/build`     | How do we code it?         | Feature, fix, refactor, model     |
| `/review`    | Is it good?                | Fresh, ultra, code, gate, council, dashboard, personas |
| `/refine`    | Converge before building?  | Think → design → simulate → review loop |
| `/ship`      | Is it out?                 | Commit, push, pr, gos, deploy, docs, fundraise |
| `/evolve`    | Are we getting better?     | Audit, upgrade, learn, reflect    |
| `/intake`    | What's the source say?     | Absorb URL, scan topic, watchlist |
| `/save`      | Persist now?               | Session file + signals + memory + state |
| `/resume`    | Where were we?             | Restore latest session → Story + Table + Next |

Every command has exactly one canonical home. Every command has a rubric in `evals/rubrics/`. Every command has built-in convergence loops where multi-step processing applies.

## Sub-command naming rule

**Sub-commands are noun-phrases naming the artifact produced or the target acted on.** Examples:
- Canonical: `/design ui`, `/design card`, `/build feature`, `/think spec`, `/ship pr`, `/review gate`
- Tolerated legacy (verb-form): `/think discover`, `/think research`, `/think decide`, `/review fresh`

When adding a new sub-command: prefer the noun-phrase form. A sub-command that reads like a verb (`/build make`, `/ship deliver`) is usually redundant with the parent verb and should be rejected in review. Atomicity rule: each sub-command must have one intent; pipelines are fine as long as the pipeline *is* the intent.

## Structure

```
gOS/
├── agents/            ← Agent definitions (architect, reviewer, etc.)
├── commands/          ← Verb definitions (think.md, build.md, etc.)
├── skills/            ← Skill files (tdd-workflow, intake, etc.)
├── rules/             ← Coding rules (common/, typescript/, python/)
├── hooks/             ← PreToolUse/PostToolUse shell scripts
├── claws/             ← Persistent scheduled agents
├── evals/             ← Command quality rubrics + test inputs
├── memory/            ← Shared memory files (L0, L1, L2)
├── gos-plugin/        ← Claude Code plugin source
├── gos-plugin-build/  ← Built plugin output
├── toolkit/           ← MCP server templates + utilities
├── settings/          ← settings.json templates
├── config/            ← Intake sources, etc.
└── project-template/  ← Template for new projects using gOS
```

## Development Rules

- Test command changes with `/evolve eval` before committing.
- Smoke-test settings.json changes in a fresh session before committing.
- Every command must have an eval rubric in `evals/rubrics/`.
- Signal data in `memory/evolve_audit_*.md` drives upgrades.
- Plugin builds go to `gos-plugin-build/`, not `gos-plugin/`.
- Changes to shared rules/agents/skills must be tested against at least one project (Arx).

## Installation

gOS installs globally via `install.sh`:

- Copies agents, commands, skills, rules, hooks to `~/.claude/`
- Sets up `settings.json` with env vars, hooks, permissions
- Does NOT touch project-level `.claude/` or `CLAUDE.md` files

## Versioning

No version numbers in filenames. Git history is the version log. Plugin versions tracked in `gos-plugin-build/settings.json`.
