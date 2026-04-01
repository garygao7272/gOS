# Project Name — Project Instructions

## What Is This Project

<!-- Describe what this project is in 2-3 sentences -->

## Project Structure

```
project/
├── specs/              ← Product specs
├── outputs/            ← Generated outputs
├── apps/               ← Application code
├── sessions/           ← Session tracking
└── .claude/            ← Claude Code config
    ├── gOS.md          ← Soul file
    └── commands/       ← Project-specific commands (if any)
```

## gOS Commands

Soul file: `.claude/gOS.md`. All 8 verbs are globally installed.

| Command     | Purpose                                                      |
| ----------- | ------------------------------------------------------------ |
| `/gos`      | Session entry, safety, save/resume                           |
| `/think`    | discover, research, decide, spec, intake                     |
| `/design`   | quick, variants, flow, full, system, sync                    |
| `/simulate` | market, scenario, backtest, dux                              |
| `/build`    | plan, prototype, feature, component, fix, tdd, refactor      |
| `/review`   | code, test, design, gate, prove, council, dashboard          |
| `/ship`     | commit, pr, deploy, docs, release                            |
| `/evolve`   | audit, upgrade, learn, reflect                               |
| `/refine`   | prebuild convergence loop (think/design/simulate/review x N) |

## Key Context

<!-- Add project-specific context here:
- Primary tech stack
- Key APIs/services
- Design system references
- Audience/personas
-->
