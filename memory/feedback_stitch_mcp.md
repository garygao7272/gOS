---
name: Stitch MCP Fix
description: Custom proxy replaces buggy @_davideast/stitch-mcp — root cause and working solution documented
type: feedback
---

`@_davideast/stitch-mcp` v0.5.1 proxy has two bugs that prevent it from working in Claude Code:

1. The bundled MCP SDK connects to Google Stitch but never relays `initialize` responses to stdout
2. Even if it did, the ~6s Stitch connection delay would cause Claude Code to timeout before getting the `initialize` response

**Fix:** Custom zero-dependency proxy at `tools/stitch-proxy.mjs`:

- Responds to `initialize` instantly (<100ms) before connecting to Stitch
- Connects to Stitch in background, queues `tools/list` until ready
- Uses raw `fetch` to `https://stitch.googleapis.com/mcp` with `X-Goog-Api-Key` header
- `.mcp.json` config: `{"command": "node", "args": ["tools/stitch-proxy.mjs"], "env": {"STITCH_API_KEY": "${STITCH_API_KEY}"}}`

**Why:** David East's package IS the official Google package, but the proxy subcommand is broken. The `stitch-mcp tool` command (non-proxy) works fine — the bug is specifically in the stdio proxy mode.

**How to apply:** If stitch breaks again, check `tools/stitch-proxy.mjs` first. Don't go back to the npm package proxy. If Stitch API changes, update the fetch calls in the proxy.
