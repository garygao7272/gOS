# Claude Working Folder

This workspace contains Gary Gao's active projects. Each project has its own CLAUDE.md with project-specific instructions. The gOS framework and Gary's identity are configured globally at `~/.claude/CLAUDE.md` (loaded in every session automatically).

## Projects

| Project            | Path                | What                                   | Stage                 |
| ------------------ | ------------------- | -------------------------------------- | --------------------- |
| **Arx**            | `./Arx/`            | Crypto trading terminal on Hyperliquid | Deep specs, prototype |
| **Advance Wealth** | `./Advance Wealth/` | AI-native wealth management for SEA    | Specs, vendor eval    |
| **gOS**            | `./gOS/`            | gOS framework development              | Active                |
| **Dux**            | `./Dux/`            | Domain-agnostic simulation engine      | Backend complete      |
| **MiroFish**       | `./MiroFish/`       | Market simulation + regime detection   | Active                |

## Cross-Project Rules

- Each project's git remote should point to its **local** counterpart or its own GitHub repo — never to another project's repo.
- Shared infrastructure (gOS commands, skills, agents, rules) lives in `./gOS/` and is installed globally via `~/.claude/`.
- Don't copy content between projects — link or reference instead.
