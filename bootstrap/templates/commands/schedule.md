---
description: "Autopilot: list, add, pause, resume, remove — recurring agents on cron"
---

# Schedule Mode — Autopilot → Recurring Agents

**Manages recurring automated tasks — market pulses, spec reindexing, sentiment checks, data pipelines.**

Schedule mode is the "set it and forget it" layer of the Unicorn Stack. While Think/Build/Judge are session-driven (you invoke them), Schedule runs tasks on autopilot between sessions.

Parse the first word of `$ARGUMENTS` to determine action. If no action given, run `list`.

---

## list

**Purpose:** Show all scheduled tasks with their status, schedule, and next run time.

**Process:**
1. Call `mcp__scheduled-tasks__list_scheduled_tasks`
2. Format as a table with columns: Task ID, Description, Schedule, Next Run, Last Run, Enabled
3. Group by frequency (daily, weekly, monthly, ad-hoc)
4. Highlight any tasks that failed on last run

**Output:** Formatted table to user. If no tasks exist, suggest starter tasks.

---

## add <natural language description>

**Purpose:** Create a new scheduled task from a plain English description.

**Input:** Natural language like "every Monday morning check Hyperliquid funding rates" or "daily at 9am reindex specs"

**Process:**
1. Parse the description to extract:
   - **What:** The task to perform (becomes the prompt)
   - **When:** The schedule (becomes cron expression or fireAt)
   - **Where:** Output location (default: `outputs/` for reports, inline for maintenance tasks)
2. Generate a kebab-case `taskId` from the description
3. Write a comprehensive prompt that includes:
   - Which MCP tools to use (Hyperliquid, spec-rag, Playwright, Discord, etc.)
   - Output format and location
   - Error handling (what to do if a tool fails)
4. Present the task config for approval before creating
5. Call `mcp__scheduled-tasks__create_scheduled_task`

**Cron quick reference (local timezone):**
- Daily 9am: `0 9 * * *`
- Weekdays 9am: `0 9 * * 1-5`
- Every Monday 8am: `0 8 * * 1`
- Every 6 hours: `0 */6 * * *`
- First of month: `0 9 1 * *`

**Starter tasks** (suggest if the user asks "what should I schedule?"):

| Task | Schedule | What it does |
|------|----------|--------------|
| `reindex-specs` | Weekly Mon 9am | Rebuild RAG vector index for semantic spec search |
| `hyperliquid-market-pulse` | Weekly Mon 8am | Top movers, funding rates, OI snapshot → `outputs/` |
| `competitor-check` | Weekly Fri 10am | Crawl competitor apps for changes via Firecrawl/Notte |
| `spec-drift-check` | Weekly Wed 9am | Compare prototype vs specs for divergence |
| `twitter-sentiment` | Daily 8am | Scrape Hyperliquid mentions via RapidAPI → `outputs/` |
| `discord-digest` | Daily 9am | Summarize key Discord channels for trading signals |

**Output:** Created task confirmation with schedule and next run time.

---

## pause <task-id>

**Purpose:** Temporarily disable a scheduled task without deleting it.

**Process:**
1. Call `mcp__scheduled-tasks__list_scheduled_tasks` to verify the task exists
2. Call `mcp__scheduled-tasks__update_scheduled_task` with `enabled: false`
3. Confirm to user that task is paused

**Output:** Confirmation with task ID and previous schedule (so they can resume later).

---

## resume <task-id>

**Purpose:** Re-enable a paused scheduled task.

**Process:**
1. Call `mcp__scheduled-tasks__list_scheduled_tasks` to verify the task exists and is paused
2. Call `mcp__scheduled-tasks__update_scheduled_task` with `enabled: true`
3. Show next scheduled run time

**Output:** Confirmation with next run time.

---

## remove <task-id>

**Purpose:** Permanently delete a scheduled task.

**Process:**
1. Call `mcp__scheduled-tasks__list_scheduled_tasks` to show the task details
2. Ask for confirmation: "Remove `{task-id}` ({description})? This cannot be undone."
3. On confirmation, call `mcp__scheduled-tasks__update_scheduled_task` to disable, then inform user the task is removed

**Output:** Confirmation of removal.

---

## run <task-id>

**Purpose:** Manually trigger a scheduled task right now, outside its normal schedule.

**Process:**
1. Call `mcp__scheduled-tasks__list_scheduled_tasks` to get the task's prompt
2. Execute the task's prompt directly in the current session
3. This does NOT affect the regular schedule — the task still runs at its next scheduled time

**Output:** Task results displayed inline.

---

## Escalation Path

Schedule mode uses Claude Desktop's built-in scheduler. For more advanced needs:

| Need | Solution |
|------|----------|
| Task must run while Mac sleeps | Use `launchd` plist (macOS native) |
| GUI management of schedules | Install `runCLAUDErun` app |
| Multi-step workflow automation | Use `n8n` with Claude API integration |
| Always-on cloud automation | Deploy as Claude Agent SDK pipeline |

To set up launchd for a task: ask "escalate {task-id} to launchd" and I'll generate the plist file.
