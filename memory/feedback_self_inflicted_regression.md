---
name: Self-Inflicted Regression Prevention
description: Rules to prevent gOS /evolve changes from breaking session startup — learned from Phase 1 hooks blocking launch
type: feedback
valid_from: 2026-04-08
valid_to: open
---

Never ship hooks or MCP config changes that haven't been smoke-tested in a fresh session.

**Why:** Phase 1 of the agent audit added a UserPromptSubmit hook (auto signal capture) and enabled MCP servers without required tokens. Both blocked session startup — Gary couldn't launch gOS at all. A self-improvement cycle made the system worse.

**How to apply:**

1. **MCP servers** — always set `"disabled": true` unless the required env vars are confirmed present. Never commit an enabled MCP without testing `claude mcp list` first.
2. **Hooks** — UserPromptSubmit hooks fire on EVERY message. Keep them extremely lightweight or don't use them. If a hook writes to disk on every message, it will degrade performance.
3. **Evolve smoke test** — after any `/evolve upgrade` that touches settings.json or .mcp.json, verify the session still starts by checking: can gOS load? Do MCPs connect? Do hooks fire without error?
4. **Rollback plan** — before committing evolve changes, note the pre-change state so it can be reverted if startup breaks.
