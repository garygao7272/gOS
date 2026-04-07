# Claude Code Best Practices Manual

> Synthesized from [shanraisshan/claude-code-best-practice](https://github.com/shanraisshan/claude-code-best-practice) (v2.1.92, Apr 2026), Boris Cherny tips, Thariq skills guide, and Arx gOS experience.

---

## 1. The Architecture: Command → Agent → Skill

The fundamental CC extension pattern has three layers:

| Layer | File Location | Role | Example |
|-------|--------------|------|---------|
| **Command** | `.claude/commands/*.md` | Entry point, user interaction, orchestration | `/weather-orchestrator` |
| **Agent** | `.claude/agents/*.md` | Fetches data, executes tasks with preloaded skills | `weather-agent` |
| **Skill** | `.claude/skills/*/SKILL.md` | Domain knowledge, output templates, verification logic | `weather-svg-creator` |

**Two skill patterns:**
- **Agent skills** — preloaded via `skills:` frontmatter field into agent context at startup
- **Independent skills** — invoked via `Skill` tool during execution

**gOS mapping:** Our verbs (`/think`, `/build`, `/review`) are commands. Research swarms are agents with preloaded domain skills. Output generators are independent skills.

---

## 2. Frontmatter Reference (Complete)

### Commands/Skills (13 fields)

| Field | Type | Description |
|-------|------|-------------|
| `name` | string | Display name and `/slash-command` identifier |
| `description` | string | What it does — used for auto-discovery |
| `argument-hint` | string | Autocomplete hint (e.g., `[issue-number]`) |
| `disable-model-invocation` | boolean | Prevent automatic invocation |
| `user-invocable` | boolean | `false` hides from `/` menu (background knowledge only) |
| `paths` | string/list | Glob patterns for auto-activation on matching files |
| `allowed-tools` | string | Tools allowed without permission prompts |
| `model` | string | Model override (`haiku`, `sonnet`, `opus`) |
| `effort` | string | Effort level (`low`, `medium`, `high`, `max`) |
| `context` | string | `fork` to run in isolated subagent context |
| `agent` | string | Subagent type when `context: fork` (default: `general-purpose`) |
| `shell` | string | `bash` (default) or `powershell` |
| `hooks` | object | Lifecycle hooks scoped to this command/skill |

### Agents (16 fields)

| Field | Type | Description |
|-------|------|-------------|
| `name` | string | Unique identifier (lowercase, hyphens) |
| `description` | string | When to invoke. Use `"PROACTIVELY"` for auto-invocation |
| `tools` | string/list | Allowlist of tools. Inherits all if omitted. Supports `Agent(agent_type)` |
| `disallowedTools` | string/list | Tools to deny |
| `model` | string | `haiku`, `sonnet`, `opus`, or `inherit` |
| `permissionMode` | string | `default`, `acceptEdits`, `auto`, `dontAsk`, `bypassPermissions`, `plan` |
| `maxTurns` | integer | Maximum agentic turns before stop |
| `skills` | list | Skill names preloaded at startup (full content injected) |
| `mcpServers` | list | MCP servers for this agent |
| `hooks` | object | Lifecycle hooks (PreToolUse, PostToolUse, Stop most common) |
| `memory` | string | Persistent scope: `user`, `project`, or `local` |
| `background` | boolean | Always run as background task |
| `effort` | string | `low`, `medium`, `high`, `max` |
| `isolation` | string | `"worktree"` for git worktree isolation |
| `initialPrompt` | string | Auto-submitted first turn when run as main agent |
| `color` | string | CLI output color for visual distinction |

---

## 3. Settings.json — Key Patterns

### Settings Hierarchy (highest → lowest priority)

1. **Managed** (`managed-settings.json`) — org-enforced, cannot override
2. **CLI arguments** — session overrides
3. **`.claude/settings.local.json`** — personal project (git-ignored)
4. **`.claude/settings.json`** — team-shared
5. **`~/.claude/settings.json`** — global personal defaults

### Essential Settings We Should Use

```json
{
  "env": {
    "CLAUDE_AUTOCOMPACT_PCT_OVERRIDE": "80"
  },
  "respectGitignore": true,
  "enableAllProjectMcpServers": true,
  "plansDirectory": "./reports",
  "attribution": {
    "commit": "",
    "pr": ""
  }
}
```

**`CLAUDE_AUTOCOMPACT_PCT_OVERRIDE: "80"`** — Compact at 80% context instead of default. Important for long sessions.

**`plansDirectory`** — Store plans in a custom location instead of `~/.claude/plans`.

**`attribution.commit: ""`** — Empty string disables the Co-Authored-By line.

### Permission Patterns

```json
{
  "permissions": {
    "allow": ["Edit(*)", "Write(*)", "Bash", "WebFetch(domain:*)"],
    "ask": [
      "Bash(rm *)", "Bash(docker *)", "Bash(kubectl *)",
      "Bash(npm *)", "Bash(pip *)", "Bash(kill *)"
    ]
  }
}
```

**Pattern:** Allow broad editing, ask on destructive/install commands.

### Worktree Optimization

```json
{
  "worktree": {
    "symlinkDirectories": ["node_modules", ".cache"],
    "sparsePaths": ["packages/my-app", "shared/utils"]
  }
}
```

Symlink heavy directories to save disk. Sparse checkout for monorepos.

---

## 4. Hooks — What to Hook and When

### All 27 Hook Events

| Category | Events |
|----------|--------|
| **Tool lifecycle** | PreToolUse, PostToolUse, PostToolUseFailure |
| **Permissions** | PermissionRequest, PermissionDenied |
| **Session** | SessionStart, SessionEnd, Setup |
| **Context** | PreCompact, PostCompact |
| **User** | UserPromptSubmit, Notification, Elicitation, ElicitationResult |
| **Agent** | SubagentStart, SubagentStop, TeammateIdle, StopFailure |
| **Task** | TaskCreated, TaskCompleted |
| **Files** | FileChanged, CwdChanged, InstructionsLoaded |
| **Config** | ConfigChange |
| **Worktree** | WorktreeCreate, WorktreeRemove |
| **Control** | Stop |

### Hook Configuration

```json
{
  "hooks": {
    "PreToolUse": [{
      "hooks": [{
        "type": "command",
        "command": "python3 ${CLAUDE_PROJECT_DIR}/.claude/hooks/scripts/hooks.py",
        "timeout": 5000,
        "async": true
      }]
    }]
  }
}
```

**Key options:**
- `async: true` — don't block the agent loop
- `once: true` — fire only once per session (good for SessionStart, PreCompact)
- `matcher` — filter by pattern (e.g., `.envrc|.env|.env.local` for FileChanged)

### High-Value Hook Patterns

1. **SessionStart** — Load dynamic context, set up environment
2. **Stop** — Poke Claude to keep going, or save session state
3. **PreToolUse** — Log bash commands, block destructive operations
4. **FileChanged with matcher** — Reload env vars when `.env` changes
5. **PreCompact (once: true)** — Save critical state before compaction

---

## 5. Agent Memory System

Agents can maintain persistent memory across sessions:

```yaml
---
name: code-reviewer
memory: project  # or user, local
---
```

| Scope | Location | Git? | Shared? |
|-------|----------|------|---------|
| `user` | `~/.claude/agent-memory/<name>/` | No | No |
| `project` | `.claude/agent-memory/<name>/` | Yes | Yes |
| `local` | `.claude/agent-memory-local/<name>/` | No | No |

**How it works:** First 200 lines of `MEMORY.md` injected into agent system prompt at startup. Agent can read/write its memory directory freely.

---

## 6. Boris Cherny's Top Tips (Curated)

### Productivity

1. **Spin up 3-5 worktrees in parallel** — biggest productivity unlock. Name them, use shell aliases (`2a`, `2b`, `2c`).
2. **Start every complex task in Plan Mode** — pour energy into the plan, Claude 1-shots the implementation. One person has Claude write the plan, then a second Claude review it as a staff engineer.
3. **After every correction, say "update your CLAUDE.md"** — Claude is eerily good at writing rules for itself.
4. **If something goes sideways, switch back to plan mode** — don't keep pushing.

### Automation

5. **`/loop` is incredibly powerful:**
   - `/loop 5m /babysit` — auto-address code review, auto-rebase, shepherd PRs
   - `/loop 30m /slack-feedback` — auto-PR for Slack feedback
   - `/loop 1h /pr-pruner` — close stale PRs
6. **If you do something more than once a day, make it a skill**
7. **`/schedule` for persistent cron-like tasks** — runs even when you close the terminal

### Quality

8. **Give Claude a way to verify its output** — #1 most important tip. Use Chrome extension, Playwright, or Claude Preview. Without verification, Claude is writing blind.
9. **Multiple uncorrelated context windows find bugs better** — one agent causes bugs, another reviews. This is test-time compute.
10. **Keep PRs small** — Boris does 141 PRs/day, median 118 lines, always squash-merged.

### Sessions

11. **`/branch` to fork a session** — explore "what if" without losing the main thread.
12. **`/teleport` and `/remote-control`** — move sessions between mobile/web/desktop and terminal.
13. **`/compact` at ~50% context** — manual compaction preserves more important context than auto-compaction.

---

## 7. Thariq's 9 Skill Categories

| Category | Description | Example |
|----------|-------------|---------|
| 1. Library/API Reference | How to use a library correctly | `billing-lib`, `frontend-design` |
| 2. Product Verification | Test/verify code output | `signup-flow-driver`, `checkout-verifier` |
| 3. Data Fetching | Connect to data/monitoring stacks | `funnel-query`, `grafana` |
| 4. Business Process | Automate repetitive workflows | `standup-post`, `weekly-recap` |
| 5. Code Scaffolding | Generate framework boilerplate | Templates with natural language requirements |
| 6. Style/Convention Guide | Enforce team coding standards | Linting rules, naming conventions |
| 7. Domain Knowledge | Inject specialist expertise | Industry-specific rules, compliance |
| 8. Tool Integration | Bridge external tools | MCP wrappers, API helpers |
| 9. Composite/Orchestrator | Chain multiple skills together | Multi-step workflows |

**Key insight:** Skills are folders, not just markdown files. Include scripts, data, examples, reference code.

---

## 8. RPI Workflow Pattern

**R**esearch → **P**lan → **I**mplement with validation gates.

```
/rpi:research → RESEARCH.md (GO/NO-GO verdict)
/rpi:plan     → pm.md + ux.md + eng.md + PLAN.md
/rpi:implement → Phase-by-phase execution with gates
```

Each feature gets its own folder: `rpi/{feature-slug}/`. This maps directly to our gOS pattern: `/think research` → `/think spec` → `/build feature`.

---

## 9. Built-in Commands Reference (65 total)

### Most Useful for Daily Work

| Command | What it does |
|---------|-------------|
| `/compact [focus]` | Compact with optional focus instructions |
| `/context` | Visualize context usage as colored grid |
| `/cost` | Token usage stats |
| `/diff` | Interactive diff viewer |
| `/branch` | Fork current conversation |
| `/rewind` | Rewind conversation/code to previous point |
| `/plan [desc]` | Enter plan mode with optional task |
| `/btw <q>` | Side question without adding to conversation |
| `/tasks` | List/manage background tasks |
| `/loop` | Run command on recurring interval (up to 3 days) |
| `/schedule` | Cloud scheduled tasks (cron) |
| `/resume` | Resume specific session |
| `/effort` | Set model effort level |
| `/fast` | Toggle fast mode |
| `/doctor` | Diagnose installation |
| `/powerup` | Interactive feature lessons |
| `/security-review` | Security scan of pending changes |
| `/remote-control` | Control local session from phone/web |
| `/teleport` | Pull cloud session to local terminal |
| `/copy [N]` | Copy Nth response to clipboard |
| `/export` | Export conversation as text |

### New/Underused

| Command | What it does |
|---------|-------------|
| `/ultraplan <prompt>` | Draft plan in browser, execute remotely |
| `/insights` | Analyze session patterns and friction |
| `/stats` | Usage visualization with streaks |
| `/passes` | Share free week of CC with friends |
| `/color` | Set prompt bar color per session |
| `/statusline` | Configure status line |
| `/stickers` | Order Claude Code stickers |
| `/rename` | Name the current session |

---

## 10. MCP Server Stack (Recommended)

| Server | Purpose |
|--------|---------|
| **Context7** | Up-to-date library docs (prevents hallucinated APIs) |
| **Playwright** | Browser automation for UI verification |
| **Claude in Chrome** | Real Chrome debugging (console, network, DOM) |
| **DeepWiki** | Structured wiki docs for any GitHub repo |
| **Excalidraw** | Architecture diagrams from prompts |

**Boris's rule:** "Went overboard with 15 MCP servers. Ended up using only 4 daily." Quality over quantity.

---

## 11. CLI Startup Flags (Most Useful)

| Flag | When to use |
|------|-------------|
| `--worktree` / `-w` | Isolated git worktree per session |
| `--agent <name>` | Start with specific agent |
| `--model <name>` | Override model |
| `--permission-mode plan` | Start in plan mode |
| `--continue` / `-c` | Resume most recent conversation |
| `--resume` / `-r` | Resume specific session |
| `--fork-session` | Fork when resuming |
| `--add-dir <path>` | Add extra working directory |
| `--mcp-config <path>` | Custom MCP config |
| `--max-turns <n>` | Limit agent turns (print mode) |
| `--max-budget-usd <n>` | Cost cap (print mode) |
| `--append-system-prompt` | Add to system prompt |
| `--chrome` | Enable Chrome integration |
| `--verbose` | Full turn-by-turn output |

---

## 12. CLAUDE.md Best Practices

1. **Keep under 200 lines per file** — beyond this, adherence drops
2. **Ancestor files load at startup** (walk UP from cwd to root)
3. **Descendant files load lazily** (only when Claude reads files in those dirs)
4. **Sibling directories never cross-load**
5. **Use `CLAUDE.local.md`** for personal preferences (git-ignored)
6. **After every correction, update CLAUDE.md** — Claude writes its own rules well
7. **Global `~/.claude/CLAUDE.md`** applies to ALL sessions

### What to Include

- Project overview and architecture
- Coding standards and conventions
- Critical patterns (what to do)
- Common mistakes (what NOT to do)
- Key file locations
- Testing requirements

### What NOT to Include

- Implementation details (put in skills)
- Verbose explanations (be terse)
- Things derivable from code (don't duplicate)
- Temporary state (use scratchpad)

---

## 13. Programmatic Tool Calling (Advanced)

For API/SDK users: Claude writes Python that orchestrates tools in a sandbox. Only `stdout` enters context. Reduces token usage ~37%.

Not directly applicable to CLI usage, but important for building agents with the Claude Agent SDK.

---

## 14. What Arx gOS Already Does Better

| Area | Repo Pattern | gOS Pattern | Advantage |
|------|-------------|-------------|-----------|
| Session management | Manual `/resume` | 3-layer memory (context → scratchpad → persistent) | More resilient to compaction |
| Orchestration | Single command → agent → skill | 8 verbs with parallel swarms | More parallel, domain-specific |
| Self-improvement | None | `/evolve` with signal capture | Continuous learning loop |
| Spec system | N/A | 60+ specs with hierarchy | Deep product knowledge |
| Design system | N/A | Figma integration + DESIGN.md | Design-code bridge |
