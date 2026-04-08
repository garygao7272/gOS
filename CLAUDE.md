# gOS — Framework Development

## What Is gOS

gOS (Gary's Operating System) is an AI builder companion framework built on Claude Code. It turns a solo founder into a full company by providing structured commands, memory, agents, and orchestration. This CLAUDE.md is for developing gOS itself — the framework, not the projects it powers.

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
