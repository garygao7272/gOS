# God System — Complete Manifest

> Last synced: 2026-04-07
> Auto-synced every 3 days via scheduled task `sync-bootstrap`

This is the authoritative registry of every component in the God/Writ system. If it's not here, it doesn't exist. Updated automatically by `sync.sh`.

---

## 1. The Writ — 10 Commands

God's command set. These live in `<project>/.claude/commands/` and are the entry points for all work.

| #   | Command       | File            | Decree      | Sub-commands                                                                                                                                                               | Output                 |
| --- | ------------- | --------------- | ----------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------------------- |
| 1   | `/god`        | `god.md`        | Summon      | status, last, ship, pulse, diff, save                                                                                                                                      | Briefing + routing     |
| 2   | `/think`      | `think.md`      | Reason      | discover, design, research, decide, spec                                                                                                                                   | `specs/`               |
| 3   | `/build`      | `build.md`      | Create      | prototype, feature, component, test, deploy                                                                                                                                | `apps/`                |
| 4   | `/judge`      | `judge.md`      | Evaluate    | s2-jake, s7-sarah, s1-alex, s3-marcus, trader-ux, crypto-sec, risk-analyst, signal-analyst, hl-protocol, mobile-perf, compliance, second-opinion, contrarian, full-council | `specs/` + `apps/`     |
| 5   | `/schedule`   | `schedule.md`   | Automate    | list, add, pause, resume, remove, run                                                                                                                                      | Recurring agents       |
| 6   | `/coordinate` | `coordinate.md` | Orchestrate | status, claim, handoff, merge, close                                                                                                                                       | `sessions/active.md`   |
| 7   | `/evolve`     | `evolve.md`     | Improve     | audit, upgrade, learn, reflect, prompt, diff                                                                                                                               | Writ upgrades + memory |
| 8   | `/prototype`  | `prototype.md`  | Sketch      | —                                                                                                                                                                          | `apps/web-prototype/`  |
| 9   | `/verify-app` | `verify-app.md` | Prove       | —                                                                                                                                                                          | Test results           |
| 10  | `/intel`      | `intel.md`      | Brief       | war-room, signal-scan, both, status                                                                                                                                        | `outputs/briefings/`   |

**Execution patterns:**

- Think → Swarm (3-5 parallel agents)
- Build → Sequential (one commit at a time)
- Judge → Swarm for full-council, sequential for single persona

---

## 2. Soul File

| File     | Location                   | Purpose                                                                                                            |
| -------- | -------------------------- | ------------------------------------------------------------------------------------------------------------------ |
| `GOD.md` | `<project>/.claude/GOD.md` | God's identity, directive (UNDERSTAND→CHALLENGE→COMPLETE→ALIGN), thinking modes, 9 principles, voice, the standard |

---

## 3. Plugins (26 enabled)

### Official Plugins (`@claude-plugins-official`)

| Plugin                 | Purpose                              |
| ---------------------- | ------------------------------------ |
| `claude-md-management` | CLAUDE.md file management            |
| `commit-commands`      | Git commit workflow                  |
| `context7`             | Library documentation lookup         |
| `feature-dev`          | Feature development workflow         |
| `figma`                | Design context, components, styles   |
| `firebase`             | Backend services                     |
| `firecrawl`            | Web scraping and crawling            |
| `frontend-design`      | Frontend design patterns             |
| `linear`               | Issue tracking, cycles, projects     |
| `ralph-loop`           | Autonomous agent loop                |
| `skill-creator`        | Create new skills                    |
| `superpowers`          | Enhanced agent capabilities          |
| `vercel`               | Deployment, preview URLs, build logs |

### LSP Plugins (`@claude-plugins-official`)

| Plugin           | Purpose                    |
| ---------------- | -------------------------- |
| `typescript-lsp` | TypeScript language server |
| `pyright-lsp`    | Python language server     |
| `swift-lsp`      | Swift language server      |
| `kotlin-lsp`     | Kotlin language server     |

### Financial Services (`@financial-services-plugins`)

| Plugin               | Purpose                                |
| -------------------- | -------------------------------------- |
| `equity-research`    | Earnings, initiations, sector analysis |
| `financial-analysis` | DCF, comps, LBO, 3-statement models    |
| `investment-banking` | CIM, teasers, process letters          |
| `private-equity`     | IC memos, deal screening, DD           |
| `wealth-management`  | Client reports, financial plans        |

### Third-Party / Custom

| Plugin                   | Source                                 | Purpose                                          |
| ------------------------ | -------------------------------------- | ------------------------------------------------ |
| `mobile-design-engine`   | `local-plugins` (`~/claude-plugins`)   | 6-phase mobile design pipeline                   |
| `ui-ux-pro-max`          | `nextlevelbuilder/ui-ux-pro-max-skill` | Design system generation, anti-pattern detection |
| `claude-mem`             | `thedotmack/claude-mem`                | Cross-session memory (observations, decisions)   |
| `everything-claude-code` | `affaan-m/everything-claude-code`      | 100+ skills for coding, review, testing          |

### Custom Marketplaces

| Name                         | Source                                           |
| ---------------------------- | ------------------------------------------------ |
| `local-plugins`              | `~/claude-plugins` (local directory)             |
| `financial-services-plugins` | `anthropics/financial-services-plugins` (GitHub) |
| `ui-ux-pro-max-skill`        | `nextlevelbuilder/ui-ux-pro-max-skill` (GitHub)  |
| `thedotmack`                 | `thedotmack/claude-mem` (GitHub)                 |
| `everything-claude-code`     | `affaan-m/everything-claude-code` (GitHub)       |

---

## 4. MCP Servers (9 configured)

Defined in `<project>/.mcp.json`:

| Server        | Type           | Auth                    | Purpose                                           | Tools |
| ------------- | -------------- | ----------------------- | ------------------------------------------------- | ----- |
| `slack`       | HTTP           | OAuth                   | Channel search, thread summary, messaging         | ~10   |
| `github`      | HTTP           | `$GITHUB_TOKEN`         | PRs, issues, code review, repo exploration        | ~20   |
| `sentry`      | HTTP           | OAuth                   | Error logs, release correlation, root-cause       | ~10   |
| `hyperliquid` | stdio (Node)   | None (public)           | Live market data, positions, order books, funding | 18    |
| `playwright`  | stdio (npx)    | None                    | UI testing, iPhone 14 Pro (390×844)               | ~15   |
| `discord`     | stdio (npx)    | `$DISCORD_TOKEN`        | Community monitoring, channel scraping            | ~10   |
| `telegram`    | stdio (npx)    | `$TELEGRAM_API_ID/HASH` | Trading group monitoring                          | ~5    |
| `notte`       | stdio (Python) | `$NOTTE_API_KEY`        | Anti-detection browser, CAPTCHA solving           | ~5    |
| `spec-rag`    | stdio (Python) | None                    | Semantic search over 65+ specs (LanceDB)          | 3     |

### Built-in MCP (via Claude Desktop)

| Server            | Purpose                    |
| ----------------- | -------------------------- |
| `scheduled-tasks` | Recurring agent automation |

### Plugin-Provided MCP (no .mcp.json needed)

| Server     | Via Plugin         | Purpose                        |
| ---------- | ------------------ | ------------------------------ |
| Vercel     | `vercel`           | Deployment, logs, preview URLs |
| Figma      | `figma`            | Design context, components     |
| Linear     | `linear`           | Issues, cycles, projects       |
| Context7   | `context7`         | Library docs lookup            |
| Firebase   | `firebase`         | Backend services               |
| Crypto.com | Claude.ai built-in | Market data                    |

---

## 5. Agents (12 defined)

User-level agents at `~/.claude/agents/`:

| Agent                  | File                      | Purpose                 | When to Use                   |
| ---------------------- | ------------------------- | ----------------------- | ----------------------------- |
| `planner`              | `planner.md`              | Implementation planning | Complex features, refactoring |
| `architect`            | `architect.md`            | System design           | Architectural decisions       |
| `tdd-guide`            | `tdd-guide.md`            | Test-driven development | New features, bug fixes       |
| `code-reviewer`        | `code-reviewer.md`        | Code review             | After writing code            |
| `security-reviewer`    | `security-reviewer.md`    | Security analysis       | Before commits                |
| `build-error-resolver` | `build-error-resolver.md` | Fix build errors        | When build fails              |
| `e2e-runner`           | `e2e-runner.md`           | E2E testing             | Critical user flows           |
| `refactor-cleaner`     | `refactor-cleaner.md`     | Dead code cleanup       | Code maintenance              |
| `doc-updater`          | `doc-updater.md`          | Documentation           | Updating docs                 |
| `python-reviewer`      | `python-reviewer.md`      | Python code review      | Python changes                |
| `harness-optimizer`    | `harness-optimizer.md`    | Agent harness config    | Reliability tuning            |
| `loop-operator`        | `loop-operator.md`        | Autonomous loops        | Monitor agent loops           |

---

## 6. Rules (9 common + 7 language dirs)

User-level at `~/.claude/rules/`:

### Common Rules (all projects)

| File                      | Purpose                                           |
| ------------------------- | ------------------------------------------------- |
| `agents.md`               | Agent orchestration patterns                      |
| `coding-style.md`         | Immutability, file organization, error handling   |
| `development-workflow.md` | Research → Plan → TDD → Review → Commit           |
| `git-workflow.md`         | Commit format, PR process                         |
| `hooks.md`                | PreToolUse, PostToolUse, Stop hooks               |
| `patterns.md`             | Skeleton projects, repository pattern, API format |
| `performance.md`          | Model selection, context management               |
| `security.md`             | Secret management, OWASP checks                   |
| `testing.md`              | 80% coverage, TDD workflow                        |

### Language-Specific Rules

| Directory     | Languages/Frameworks                     |
| ------------- | ---------------------------------------- |
| `golang/`     | Go patterns, concurrency, error handling |
| `kotlin/`     | Kotlin/Android, coroutines, Compose      |
| `perl/`       | Perl patterns, testing                   |
| `php/`        | PHP patterns                             |
| `python/`     | Python/PEP 8, type hints, Django/FastAPI |
| `swift/`      | Swift/SwiftUI, concurrency, actors       |
| `typescript/` | TypeScript/React, Next.js, testing       |

---

## 7. Scheduled Tasks (5 active)

Managed via Claude Desktop's scheduled-tasks MCP:

| Task                       | Schedule  | Purpose                                      | Output                     |
| -------------------------- | --------- | -------------------------------------------- | -------------------------- |
| `reindex-specs`            | Mon 9am   | Rebuild spec-rag vector index                | `.lancedb/`                |
| `hyperliquid-market-pulse` | Mon 8am   | Top movers, funding rates, OI snapshot       | `outputs/`                 |
| `morning-briefing`         | Daily 8am | 5-section macro-to-micro briefing (PDF + MD) | `outputs/` + iCloud        |
| `weekly-highlight`         | Sun 9am   | Weekly distillation of daily briefings       | `outputs/` + iCloud        |
| `weekly-evolve-audit`      | Sun 10am  | Self-audit of Writ performance signals       | `memory/evolve_audit_*.md` |

---

## 8. Specs (68 files)

Product knowledge at `<project>/specs/`. Organized by altitude:

### Group 0 — Meta

| File                               | Purpose                                       |
| ---------------------------------- | --------------------------------------------- |
| `Arx_0-0_Artifact_Architecture.md` | Master blueprint, naming rules, cascade logic |
| `INDEX.md`                         | Quick lookup by screen, decision, flow        |

### Group 1 — Foundation (30,000 ft)

| File                                                     | Purpose                                    |
| -------------------------------------------------------- | ------------------------------------------ |
| `Arx_1-1_Vision_and_Mission.md`                          | Why Arx exists                             |
| `Arx_1-2_Strategy_Memo.md`                               | Strategic direction                        |
| `Arx_1-2-1_Strategy-Connectivity-Layer-Opportunities.md` | Connectivity layer strategy                |
| `Arx_1-2-2_Competitive_Strategy_Synthesis.md`            | Competitive strategy                       |
| `Arx_1-3_Business_Model.md`                              | Revenue (builder codes + Gold + copy fees) |
| `Arx_1-4_Agentic_AI_Strategy_Amendment.md`               | AI agent strategy                          |

### Group 2 — Market Intel (20,000 ft)

| File                                                 | Purpose                        |
| ---------------------------------------------------- | ------------------------------ |
| `Arx_2-1_Problem_Space_and_Audience.md`              | Who we serve, what hurts       |
| `Arx_2-2_User_Domain_Research.md`                    | User research                  |
| `Arx_2-2-1_User_Domain_Research_GenAI_In_Trading.md` | GenAI in trading research      |
| `Arx_2-2-2_Trading_Signal_Foundational_Research.md`  | Signal research                |
| `Arx_2-3_Competitive_Landscape.md`                   | Competitor overview            |
| `Arx_2-3-1` thru `2-3-7`                             | Individual competitor analyses |
| `Arx_2-4_Market_Structure_Data.md`                   | Market data                    |

### Group 3 — Product (10,000 ft)

| File                                        | Purpose              |
| ------------------------------------------- | -------------------- |
| `Arx_3-1_Product_Roadmap.md`                | What to build, when  |
| `Arx_3-2_PRD.md`                            | Product requirements |
| `Arx_3-3_Customer_Journey_Maps.md`          | User flows           |
| `Arx_3-5_S2_S7_Pain_Alignment_Amendment.md` | Segment alignment    |
| `Arx_3-6_Agent_Product_Design.md`           | AI agent design      |

### Group 4 — Design (5,000 ft)

| File                                          | Purpose                                            |
| --------------------------------------------- | -------------------------------------------------- |
| `Arx_4-1-0_Experience_Design_Index.md`        | Screen inventory                                   |
| `Arx_4-1-1-0_Mobile_Master_Architecture.md`   | Mobile architecture                                |
| `Arx_4-1-1-1_Mobile_Onboarding_Funding.md`    | Onboarding screen                                  |
| `Arx_4-1-1-2_Mobile_Home_Markets.md`          | Home/Markets screen                                |
| `Arx_4-1-1-2a/b/c/d`                          | Markets sub-specs (ticker UX, animation, redesign) |
| `Arx_4-1-1-3_Mobile_Trade.md`                 | Trade screen                                       |
| `Arx_4-1-1-3-1_Trade_Tab_Design_Decisions.md` | Trade design decisions                             |
| `Arx_4-1-1-4_Mobile_Radar.md`                 | Radar (signals) screen                             |
| `Arx_4-1-1-5_Mobile_You_Systems.md`           | Profile/settings screen                            |
| `Arx_4-1-1-6_Mobile_Lucid.md`                 | Lucid (copy trading) screen                        |
| `Arx_4-1-1-7_Mobile_Data_Object_Model.md`     | Data model                                         |
| `Arx_4-1-1-8_Mobile_Mock_Data_Reference.md`   | Mock data                                          |
| `Arx_4-1-2-1` thru `4-1-2-4`                  | Desktop screen specs                               |
| `Arx_4-2_Design_System.md`                    | Design tokens, components                          |

### Group 5 — Engineering (1,000 ft)

| File                                      | Purpose                       |
| ----------------------------------------- | ----------------------------- |
| `Arx_5-1_Executable_Spec.md`              | Technical implementation spec |
| `Arx_5-2_Hyperliquid_Data_Dictionary.md`  | Hyperliquid API reference     |
| `Arx_5-3_Trader_Wallet_Label_Taxonomy.md` | Wallet classification         |

### Group 6 — Execution (Ground)

| File                                         | Purpose                    |
| -------------------------------------------- | -------------------------- |
| `Arx_6-1_Lucid_Interaction_Design_System.md` | Lucid interaction patterns |
| `Arx_6-2_MVP_Blueprint.md`                   | MVP plan                   |

### Group 7 — Operations

| File                                         | Purpose              |
| -------------------------------------------- | -------------------- |
| `Arx_7-1_Metrics_and_Measurement.md`         | KPIs and measurement |
| `Arx_7-1_S7_Forum_Alerts_UX_Architecture.md` | Forum alerts UX      |

### Group 9 — Governance

| File                                    | Purpose                      |
| --------------------------------------- | ---------------------------- |
| `Arx_9-1_Decision_Log.md`               | All decisions with rationale |
| `Arx_9-4-1_Onboarding_Debrief.md`       | Onboarding review            |
| `Arx_9-4-2_Legal_Compliance_Debrief.md` | Legal compliance             |
| `Arx_9-5_Hypothesis_Question_Log.md`    | Open questions               |

---

## 9. Apps (2 projects)

| App             | Location              | Stack                                                      | Purpose                                |
| --------------- | --------------------- | ---------------------------------------------------------- | -------------------------------------- |
| `web-prototype` | `apps/web-prototype/` | Single-file HTML, CSS variables, vanilla JS                | Interactive mobile prototype (390×844) |
| `mobile`        | `apps/mobile/`        | React Native / Next.js, Zustand, Tailwind 4, Framer Motion | Production mobile app                  |

---

## 10. Custom Tools (4 tools)

| Tool              | Location                 | Runtime     | Purpose                                                      |
| ----------------- | ------------------------ | ----------- | ------------------------------------------------------------ |
| `hyperliquid-mcp` | `tools/hyperliquid-mcp/` | Node.js     | 18-tool MCP wrapping Hyperliquid Info API                    |
| `spec-rag-mcp`    | `tools/spec-rag-mcp/`    | Python      | Semantic search over specs (LanceDB + sentence-transformers) |
| `spec-rag-env`    | `tools/spec-rag-env/`    | Python venv | Virtual environment for spec-rag                             |
| `notte-env`       | `tools/notte-env/`       | Python venv | Virtual environment for notte browser                        |

---

## 11. Memory System

Cross-session memory at `~/.claude/projects/<project-path>/memory/`:

| File                             | Type     | Purpose                                     |
| -------------------------------- | -------- | ------------------------------------------- |
| `MEMORY.md`                      | Index    | Pointers to all memory files                |
| `user_gary_gao.md`               | User     | Builder identity, work style, preferences   |
| `project_unicorn_stack.md`       | Project  | The Writ system definition                  |
| `feedback_boris_workflow.md`     | Feedback | Spec-first, parallel sessions workflow      |
| `feedback_session_2026-03-17.md` | Feedback | Session learnings capture                   |
| `evolve_signals.md`              | Project  | RL signals (accept/rework/reject/love/skip) |

---

## 12. File Structure (Complete)

```
<project>/
├── CLAUDE.md                           ← Project instructions
├── .claude/
│   ├── GOD.md                          ← Soul file
│   ├── commands/                       ← 10 Writ commands
│   │   ├── god.md
│   │   ├── think.md
│   │   ├── build.md
│   │   ├── judge.md
│   │   ├── schedule.md
│   │   ├── coordinate.md
│   │   ├── evolve.md
│   │   ├── prototype.md
│   │   ├── verify-app.md
│   │   └── intel.md
│   ├── settings.local.json             ← Project permissions
│   └── launch.json                     ← Dev server configs
├── .mcp.json                           ← MCP server configuration
├── .gitignore
├── specs/                              ← 68 product specs (altitude-organized)
│   ├── INDEX.md
│   ├── Arx_0-0_*.md                   ← Meta
│   ├── Arx_1-*                        ← Foundation
│   ├── Arx_2-*                        ← Market intel
│   ├── Arx_3-*                        ← Product
│   ├── Arx_4-*                        ← Design
│   ├── Arx_5-*                        ← Engineering
│   ├── Arx_6-*                        ← Execution
│   ├── Arx_7-*                        ← Operations
│   ├── Arx_9-*                        ← Governance
│   └── Archive/                        ← Superseded docs
├── apps/
│   ├── web-prototype/                  ← HTML prototype (has own CLAUDE.md)
│   └── mobile/                         ← React Native / Next.js app
├── tools/
│   ├── hyperliquid-mcp/                ← Hyperliquid MCP server
│   ├── spec-rag-mcp/                   ← Spec search MCP server
│   ├── spec-rag-env/                   ← Python venv (gitignored)
│   └── notte-env/                      ← Python venv (gitignored)
├── sessions/
│   ├── active.md                       ← Session registry
│   └── scratchpad.md                   ← Working memory (gitignored)
├── outputs/                            ← Generated briefings, reports
├── bootstrap/                          ← THIS KIT
│   ├── README.md                       ← How to use
│   ├── SYSTEM_MANIFEST.md             ← YOU ARE HERE
│   ├── backup.sh                       ← Archive everything
│   ├── restore.sh                      ← Restore on fresh machine
│   ├── new-project.sh                  ← Bootstrap new project
│   ├── sync.sh                         ← Sync latest to templates
│   ├── env.example                     ← Required env vars
│   └── templates/                      ← Universal templates
│       ├── GOD.md
│       ├── CLAUDE.template.md
│       ├── .mcp.template.json
│       ├── .gitignore.template
│       ├── commands/                   ← All 9 Writ commands
│       └── memory/                     ← Memory templates
└── memory/                             ← Project-level evolve signals
    └── evolve_signals.md
```

### User-Level Structure (`~/.claude/`)

```
~/.claude/
├── GOD.md                              ← Soul file (if installed globally)
├── settings.json                       ← Plugins, env vars, experiments
├── rules/
│   ├── common/                         ← 9 language-agnostic rules
│   ├── golang/                         ← Go-specific overrides
│   ├── kotlin/                         ← Kotlin-specific
│   ├── perl/                           ← Perl-specific
│   ├── php/                            ← PHP-specific
│   ├── python/                         ← Python-specific
│   ├── swift/                          ← Swift-specific
│   └── typescript/                     ← TypeScript-specific
├── commands/                           ← 30 user-level commands
├── agents/                             ← 12 agent definitions
├── scheduled-tasks/                    ← 5 scheduled tasks
│   ├── morning-briefing/
│   ├── weekly-highlight/
│   ├── hyperliquid-market-pulse/
│   ├── reindex-specs/
│   └── weekly-evolve-audit/
├── plugins/                            ← Plugin marketplace cache
└── projects/
    └── <project-path>/
        └── memory/                     ← Cross-session memory
            ├── MEMORY.md
            ├── user_gary_gao.md
            ├── project_unicorn_stack.md
            ├── feedback_*.md
            └── evolve_signals.md
```

---

## 13. Environment Variables

| Variable            | Required          | Purpose                |
| ------------------- | ----------------- | ---------------------- |
| `GITHUB_TOKEN`      | Yes               | GitHub MCP             |
| `DISCORD_TOKEN`     | If using Discord  | Discord MCP            |
| `TELEGRAM_API_ID`   | If using Telegram | Telegram MCP           |
| `TELEGRAM_API_HASH` | If using Telegram | Telegram MCP           |
| `NOTTE_API_KEY`     | If using Notte    | Anti-detection browser |
| `ANTHROPIC_API_KEY` | Optional          | Claude API calls       |

---

## 15. Hooks (10 configured)

Anti-drift automation. Ensures specs and plans are followed 100% through context compression.

### Priority: Anti-Drift

| #   | Hook                  | Event                       | Type    | Purpose                                       |
| --- | --------------------- | --------------------------- | ------- | --------------------------------------------- |
| 1   | Plan Compliance Gate  | `Stop`                      | agent   | Compares last action against approved plan    |
| 2   | Spec Compliance Gate  | `Stop`                      | agent   | Verifies implementation matches spec          |
| 3   | Context Recovery      | `PostToolUse`               | command | Re-reads scratchpad + plan every 20 tool uses |
| 4   | Scratchpad Checkpoint | `PostToolUse` (Edit\|Write) | command | Auto-appends edited file paths to scratchpad  |

### Safety & Quality

| #   | Hook                    | Event                            | Type    | Purpose                                                                |
| --- | ----------------------- | -------------------------------- | ------- | ---------------------------------------------------------------------- |
| 5   | File Protector          | `PreToolUse` (Edit\|Write\|Bash) | command | Blocks edits to `.env*`, `*.key`, `*.pem`; blocks `rm -rf`, force push |
| 6   | Auto-Formatter          | `PostToolUse` (Edit\|Write)      | command | Prettier for JS/TS/HTML/CSS, Black for Python                          |
| 7   | Prototype Version Guard | `PreToolUse` (Edit\|Write)       | command | Warns if editing prototype without bump.sh                             |
| 8   | Evolve Signal Capture   | `Stop`                           | prompt  | Detects accept/rework/reject/love/skip signals                         |
| 9   | Spec Drift Detector     | `PostToolUse` (Edit\|Write)      | command | Flags when apps/ edit may require spec update                          |
| 10  | Desktop Notification    | `Notification`                   | command | macOS notification when Claude needs input                             |

### Files

| File                                     | Purpose                     |
| ---------------------------------------- | --------------------------- |
| `.claude/settings.local.json`            | Hook configuration (all 10) |
| `.claude/hooks/context-recovery.sh`      | Hook 3 script               |
| `.claude/hooks/scratchpad-checkpoint.sh` | Hook 4 script               |
| `.claude/hooks/protect-files.sh`         | Hook 5 script               |
| `.claude/hooks/auto-format.sh`           | Hook 6 script               |
| `.claude/hooks/prototype-guard.sh`       | Hook 7 script               |
| `.claude/hooks/spec-drift.sh`            | Hook 9 script               |
| `.claude/hooks/notify.sh`                | Hook 10 script              |

Hooks 1, 2, 8 are inline (agent/prompt type) — no script file needed.

---

## 14. Key Design Decisions

| Decision          | Choice                                      | Why                                                           |
| ----------------- | ------------------------------------------- | ------------------------------------------------------------- |
| Session entry     | `/god` (single command)                     | Routes to all modes; Jarvis-like briefing                     |
| Execution model   | Swarm for thinking, sequential for building | Thinking produces independent docs; building has dependencies |
| Spec organization | Altitude-based (30K→Ground)                 | Natural zoom from strategy to implementation                  |
| Signal system     | RL feedback loop in `/evolve`               | God improves over time from Gary's reactions                  |
| File convention   | Edit tool over Write tool                   | Smaller diffs, safer, cleaner git history                     |
| Memory            | File-based + claude-mem                     | File-based survives tool changes; claude-mem adds search      |
| Bootstrap         | Git-tracked templates + backup script       | Disaster recovery without cloud dependency                    |
