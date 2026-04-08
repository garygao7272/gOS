# gOS — AI Operating System for Builders

**Version 4.3** | One person becomes a company.

gOS is a structured AI operating system that turns Claude Code into a CTO, chief of staff, and execution layer. 7 verbs cover the full product lifecycle from research to shipping. A trust system and learning loop make it smarter over time.

## What's Included

| Component | Count | Description |
|-----------|-------|-------------|
| **Commands** | 12 | 7 core verbs + 5 utilities (`/gos`, `/think`, `/design`, `/simulate`, `/build`, `/review`, `/ship`, `/evolve`, `/aside`, `/dispatch`, `/checkpoint`, `/eval`) |
| **Agents** | 12 | Specialized subagents (planner, architect, tdd-guide, code-reviewer, security-reviewer, build-error-resolver, e2e-runner, doc-updater, refactor-cleaner, python-reviewer, harness-optimizer, loop-operator) |
| **Skills** | 15 | Reusable knowledge modules (TDD workflow, coding standards, frontend/backend patterns, design sync, strategic compaction, etc.) |
| **Hooks** | 16 | Automated enforcement (intent gate, plan gate, signal capture, secret scan, context monitor, artifact validation, etc.) |
| **Reference** | 13 | Soul files (identity, trust ladder, output contract, confidence calibration, taste, creative friction, etc.) |
| **Claws** | 3 | Persistent autonomous agents (market-regime, source-monitor, spec-drift) |
| **Rules** | 9 | Common coding standards (immutability, TDD, security, git workflow, etc.) |

## The 7 Verbs

| Verb | Question | What It Produces |
|------|----------|-----------------|
| `/gos` | Am I set up? (Conductor) | Session state, orchestration, briefings |
| `/think` | What and why? | Research, specs, decisions |
| `/design` | What does it look like? | Screens, flows, design systems |
| `/simulate` | What could happen? | Scenarios, backtests, projections |
| `/build` | How do we make it? | Code, tests, prototypes |
| `/review` | Is it good? | Adversarial reviews, fixes |
| `/ship` | Is it out? | Commits, PRs, deployments |
| `/evolve` | Are we getting better? | Self-improvement, upgrades |

## Execution Pipeline (v4)

Every command follows a mandatory 10-step pipeline, enforced by hooks:

```
Intent Gate (MECE decomposition, HARD STOP) → Context Protocol → Memory Recall
→ Trust Check → Pipe Resolution → Execution → Output Contract
→ Confidence Calibration → Red Team Check → Signal Capture
```

## Trust System

4-level autonomy model that adjusts based on performance:

| Level | Name | Behavior |
|-------|------|----------|
| T0 | Advisory | Full review required |
| T1 | Collaborative | Present approach, get approval |
| T2 | Delegated | Execute, report results |
| T3 | Autonomous | Execute silently |

Trust progresses automatically: 3 consecutive accepts = T0→T1, 5 = T1→T2, 10 = T2→T3. Rejects demote.

## Learning Loop

Three memory types, all wired:

| Type | What | Where | Updates |
|------|------|-------|---------|
| Semantic | Facts, preferences | memory/*.md + claude-mem | Manual + /gos save |
| Episodic | Past outcomes | evolve_signals.md + trust.json + self-model.md | Auto: signal-capture.sh |
| Procedural | Learned behaviors | command files themselves | /evolve learn --auto |

## Installation

### Cowork (Manual Upload)

1. Download `gos-v4.3.zip`
2. Go to your Cowork organization settings
3. Upload the ZIP as a plugin
4. Plugin will be available to all team members

### Claude Code (Local)

```bash
# Test locally
claude --plugin-dir ./gos-plugin-build

# Or install from marketplace
claude plugin install gos
```

### First Use

1. Start a session: `/gos`
2. The SessionStart hooks auto-create `sessions/`, `memory/`, `outputs/` directories
3. Start working: `/think research <topic>`, `/build feature <description>`, etc.

## File Structure

```
gos/
├── .claude-plugin/
│   └── plugin.json              ← Plugin manifest (name, version, metadata)
├── commands/                    ← 12 slash commands
│   ├── gos.md                   ← Conductor + session management
│   ├── think.md                 ← Research, discovery, specs
│   ├── design.md                ← Visual design, UX flows
│   ├── simulate.md              ← Scenarios, backtests
│   ├── build.md                 ← Implementation
│   ├── review.md                ← Adversarial review
│   ├── ship.md                  ← Commit, PR, deploy
│   ├── evolve.md                ← Self-improvement
│   ├── aside.md                 ← Side questions
│   ├── dispatch.md              ← Multi-agent coordination
│   ├── checkpoint.md            ← Session checkpoints
│   └── eval.md                  ← Quality evaluation
├── agents/                      ← 12 specialized subagents
├── skills/                      ← 15 knowledge modules
├── hooks/
│   ├── hooks.json               ← Hook registrations (SessionStart, PreToolUse, PostToolUse, Stop)
│   └── scripts/                 ← 18 hook scripts (16 enforcement + 2 session management)
├── reference/                   ← 13 soul/reference files (injected via SessionStart)
│   ├── gOS.md                   ← Core identity and principles
│   ├── trust-ladder.md          ← T0-T3 autonomy model
│   ├── shared-ontology.md       ← Shorthand resolution
│   ├── output-contract.md       ← Quality rubric
│   ├── artifact-schema.md       ← Output format spec
│   ├── confidence-calibration.md ← Claim-level scoring
│   ├── context-map.md           ← Keyword → context source
│   ├── self-model.md            ← Competence tracking template
│   ├── pattern-extractor.md     ← Active learning
│   ├── anticipation.md          ← Proactive suggestions
│   ├── taste.md                 ← Design taste reference
│   ├── creative-friction.md     ← "What if instead..." protocol
│   └── project-state.md         ← Lifecycle tracker
├── claws/                       ← 3 persistent autonomous agents
│   ├── market-regime/           ← Market condition monitoring
│   ├── source-monitor/          ← Source tracking
│   └── spec-drift/              ← Specification drift detection
├── rules/
│   └── common/                  ← 9 language-agnostic coding standards
├── settings.json                ← Environment config (agent teams enabled)
└── README.md                    ← This file
```

## Hook Architecture

| Hook | Event | Purpose | Blocking? |
|------|-------|---------|-----------|
| inject-soul.sh | SessionStart | Injects gOS identity into every session | No |
| init-session.sh | SessionStart | Creates session directories and templates | No |
| careful (inline) | PreToolUse:Bash | Warns on destructive commands | Ask |
| secret-scan.sh | PreToolUse:Bash | Blocks commits with hardcoded secrets | Deny |
| protect-files.sh | PreToolUse:Edit/Write | Blocks edits to .env, credentials | Deny |
| freeze (inline) | PreToolUse:Edit/Write | Blocks edits outside frozen scope | Deny |
| intent-gate-check.sh | PreToolUse:Edit/Write | Requires Intent Gate before outputs | Deny |
| plan-gate.sh | PreToolUse:Edit/Write | Requires plan approval before building | Deny |
| artifact-frontmatter-check.sh | PostToolUse:Write | Flags missing YAML frontmatter | Warning |
| state-tracker.sh | PostToolUse:Bash | Tracks phase transitions | Auto |
| post-commit-detect.sh | PostToolUse:Bash | Detects spec drift after commits | Auto |
| context-monitor.sh | PostToolUse:Read | Estimates token usage, alerts at thresholds | Auto |
| scratchpad-checkpoint.sh | Stop | Saves scratchpad on session end | Auto |
| signal-capture.sh | Stop | Captures signals, updates trust + self-model | Auto |

## Requirements

- Claude Code 1.0.33+
- Python 3 (for trust.json and self-model updates in signal-capture.sh)
- jq (for hook input parsing)

## License

MIT
