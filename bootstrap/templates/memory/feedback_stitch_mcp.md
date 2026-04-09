---
name: Stitch MCP Debugging Dead Ends
description: What didn't work when trying to get @_davideast/stitch-mcp to load in Claude Code desktop app
type: feedback
---

Don't waste time retrying these — all confirmed ineffective:

- `~/.zprofile` export of env vars — macOS GUI apps don't source shell profiles
- `~/.claude/mcp-configs/mcp-servers.json` — Claude Code does NOT read this path for project servers
- `mcp_count=51` in `~/Library/Logs/Claude/main.log` — does NOT count project MCP servers, always 51
- Removing `${HOME}` substitution from .mcp.json env field — not the cause
- Thinking PATH was the issue — server starts fine manually with minimal env

**What IS confirmed:**

- `launchctl setenv STITCH_API_KEY "..."` works — env var confirmed present after
- `@_davideast/stitch-mcp` package works when run manually — connects to stitch.googleapis.com, finds 12 tools in <5s
- Full path `/usr/local/bin/npx` + `-y` flag + hardcoded API key + explicit PATH in .mcp.json = current config

**Why:** Despite all fixes, stitch still doesn't appear in Claude Code deferred tools list. Root cause unknown — possibly Claude Code startup timeout, or a spawning environment issue not solved by any of the above.

**How to apply:** Next attempt — try running `claude` CLI from terminal (inherits shell env correctly) instead of desktop app. Or accept stitch is broken for now and `/build prototype` without it.
