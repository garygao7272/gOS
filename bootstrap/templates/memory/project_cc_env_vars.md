---
name: CC Environment Variables
description: Claude Code env var findings from leaked source analysis — what's configurable vs runtime-only
type: project
---

CC env vars fall into two categories:

**User-configurable (via settings.json `env` block):**
- `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1` — enables native Agent Teams (TeamCreate, TaskCreate, SendMessage). Already set.
- `CLAUDE_CODE_ENABLE_TELEMETRY=1` — OTEL telemetry. Already set.
- `CLAUDE_CODE_ENABLE_SESSION_MEMORY=1` — enables SessionMemory background agent. Added 2026-04-03.
- `CLAUDE_CODE_COORDINATOR_MODE=1` — makes agent orchestration-only (no direct tool use). **Use only for dispatch lead agents**, not for interactive sessions. Do NOT set globally.

**Runtime-only (set by CC internally, not user-configurable):**
- `CLAUDE_CODE_ENTRYPOINT` — set by launcher (claude-desktop, cli, etc.)
- `CLAUDE_CODE_OAUTH_TOKEN` — auth token, managed by desktop app
- `CLAUDE_HEADLESS` — set when running headless workers via `-p` flag
- `CLAUDE_CODE_PROVIDER_MANAGED_BY_HOST` — desktop app integration flag

**Unverified (from leaked source, may need feature flags):**
- `CLAUDE_CODE_AUTO_COMPACT_WINDOW` — may control compaction trigger threshold (default ~90%)
- `CLAUDE_CODE_SM_AUTO_SAVE` — may enable session memory auto-save
- These are likely gated behind GrowthBook `tengu_*` feature flags and may not respond to env vars alone.

**Why:** Knowing which vars are configurable prevents wasted effort trying to set runtime-only vars.
**How to apply:** Only add user-configurable vars to `~/.claude/settings.json` env block. For dispatch workers, set `COORDINATOR_MODE` per-agent, not globally.
