# gOS Self-Evolution + Financial Modeling Fix — Research Brief

> Output of `/think research` — 2026-04-07

## Research Question

How to make gOS better at self-evolving to Gary's goals and typical activities, and how to fix the financial modeling (Excel) capability gap?

---

## Part 1: Self-Evolution — What Others Do That We Adopted

### Problem

gOS had a signal system (accept/rework/reject/love/skip/repeat) but capture was 100% manual. Three consecutive audits flagged "signal capture still manual-only." The evolve loop was designed but not wired.

### Solutions Implemented

| Improvement | Source Inspiration | What We Built |
|------------|-------------------|---------------|
| **Stop hook continuation nudge** | Boris Cherny (Stop hook pattern) | `settings.json` Stop hook checks for incomplete TodoWrite tasks, prompts to continue |
| **PreCompact signal capture** | ECC continuous-learning skill | `settings.json` PreCompact hook scans conversation for unlogged signals before context is lost |
| **Aggressive /gos save signals** | Metaswarm self-reflect | Enhanced Part B of `/gos save` — now mandatory, counts signals, flags N=0 as missed |
| **Scheduled weekly audit** | Addy Osmani continuous feedback | `weekly-evolve-audit` scheduled task (Mondays 9:17am) |

### Patterns Researched But NOT Implemented (For Future)

| Pattern | Source | Why Deferred |
|---------|--------|-------------|
| **JSON knowledge base for signals** | Metaswarm | Our markdown signals work fine; JSON adds complexity without benefit at our scale |
| **Instinct confidence scoring** | ECC continuous-learning-v2 | Requires hook infrastructure we don't have; our health scores serve the same purpose |
| **Auto-propose skill improvements** | MLflow skill evaluation | Evolve audit already proposes fixes; auto-apply would need more trust calibration |
| **learnings.md shared team file** | MindStudio | We're solo; persistent memory serves the same function |

### Key Insight from Addy Osmani

> The 80% Problem: engineers thriving in 2026 reconceptualized their role from implementer to orchestrator. Self-improving agents need three tiers: in-process subagents, local orchestrators, cloud async agents.

gOS already operates at all three tiers. The missing piece was the feedback loop connecting them.

---

## Part 2: Financial Modeling — The Excel Fix

### Problem

openpyxl (Python's standard Excel library) is fundamentally broken for financial models:
- Can't evaluate formulas (only reads stale cached values)
- `delete_rows()` doesn't update formula references in the same sheet
- Silently strips macros, named ranges, complex conditional formatting
- GitHub issue: anthropics/claude-code#22044

Gary's v14 financial model session hit all of these: hardcoded Peak Burn, broken monthly breakeven detection, formula cascade failure after row deletion.

### Solution Implemented

**OfficeCLI v1.0.37** — installed at `~/bin/officecli` (macOS ARM64, 29MB single binary)

| Capability | openpyxl | OfficeCLI |
|-----------|----------|-----------|
| Read cells | Yes | Yes |
| Write cells | Corrupts complex files | Safe |
| Formula evaluation | No (cached only) | Yes (auto-evaluates) |
| Row insert/delete | Breaks formulas | Handles correctly |
| Macros/named ranges | Silently strips | Preserves |
| Batch operations | N/A | Yes (single save cycle) |
| Office installation needed | No | No |

**Verified:** Created test workbook with `=A1+A2` formula. OfficeCLI returned `cachedValue: 300` — formula evaluated correctly.

### New Skill: `.claude/skills/financial-modeling/SKILL.md`

- Auto-activates on `*.xlsx` files via `paths` frontmatter
- Documents all OfficeCLI commands (create, get, set, batch, import)
- Embeds Gary's 14 financial modeling rules from memory
- Enforces: "NEVER use openpyxl for writing. OfficeCLI for all writes."

### Alternatives Evaluated

| Tool | Verdict | Why |
|------|---------|-----|
| **OfficeCLI** | **Adopted** | Single binary, formula eval, no Office install, AI-native |
| Excel MCP (sbroenne) | Rejected | Windows + Excel required, not viable on Mac |
| Google Sheets API | Rejected | Requires cloud upload, latency, quotas |
| LibreOffice headless | Fallback | Can recalc but not installed; `brew install --cask libreoffice` if needed |
| WPS Office CLI | N/A | WPS installed but no CLI recalc capability |

---

## Summary of All Changes Made

### New Files

| File | Purpose |
|------|---------|
| `~/bin/officecli` | OfficeCLI binary (macOS ARM64 v1.0.37) |
| `.claude/skills/financial-modeling/SKILL.md` | Financial modeling skill with OfficeCLI workflow |

### Modified Files

| File | Change |
|------|--------|
| `.claude/settings.json` | Added Stop hook (continuation nudge) + PreCompact hook (signal capture) |
| `.claude/commands/gos.md` | Enhanced `/gos save` Part B — mandatory signal capture with count verification |
| `memory/feedback_financial_modeling_v2.md` | Added rules 11-14: openpyxl warning, OfficeCLI preference, fallback path |

### Scheduled Tasks

| Task | Schedule | Purpose |
|------|----------|---------|
| `weekly-evolve-audit` | Mondays 9:17am | Auto-run `/evolve audit`, flag degrading commands |

---

## Sources

- [OfficeCLI — AI-native Excel CLI](https://github.com/iOfficeAI/OfficeCLI)
- [Claude Code xlsx corruption bug #22044](https://github.com/anthropics/claude-code/issues/22044)
- [Metaswarm — self-improving framework](https://github.com/dsifry/metaswarm)
- [Addy Osmani — Self-Improving Coding Agents](https://addyosmani.com/blog/self-improving-agents/)
- [MindStudio — learnings loop](https://www.mindstudio.ai/blog/how-to-build-learnings-loop-claude-code-skills)
- [ECC continuous-learning skill](https://github.com/anthropics/claude-code)
- [Excel MCP Server (COM API)](https://github.com/sbroenne/mcp-server-excel)
