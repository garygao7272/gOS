#!/bin/bash
# ═══════════════════════════════════════════════════════════
# God System — Sync to Bootstrap
# Copies current state of all God system files back to
# bootstrap/templates/ so they're always up to date.
# Run manually or via scheduled task every 3 days.
# ═══════════════════════════════════════════════════════════

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
CLAUDE_DIR="$HOME/.claude"
TEMPLATES="$SCRIPT_DIR/templates"
DATE=$(date +%Y-%m-%d)

echo "═══ God System Sync ═══"
echo "Date: ${DATE}"
echo ""

CHANGES=0

# ─── Helper: copy if different ────────────────────────────
sync_file() {
    local src="$1"
    local dst="$2"
    if [ ! -f "$src" ]; then
        return
    fi
    if [ ! -f "$dst" ] || ! diff -q "$src" "$dst" > /dev/null 2>&1; then
        mkdir -p "$(dirname -- "$dst")"
        cp "$src" "$dst"
        echo "  ✓ $(basename -- "$dst") (updated)"
        CHANGES=$((CHANGES + 1))
    fi
}

# ─── 1. Sync GOD.md ──────────────────────────────────────
echo "→ Soul file..."
sync_file "$PROJECT_DIR/.claude/GOD.md" "$TEMPLATES/GOD.md"

# ─── 2. Sync Writ Commands ───────────────────────────────
echo "→ Writ commands..."
for cmd in "$PROJECT_DIR/.claude/commands/"*.md; do
    [ -f "$cmd" ] || continue
    sync_file "$cmd" "$TEMPLATES/commands/$(basename -- "$cmd")"
done

# ─── 3. Sync MCP Config ──────────────────────────────────
echo "→ MCP config..."
sync_file "$PROJECT_DIR/.mcp.json" "$TEMPLATES/.mcp.template.json"

# ─── 4. Sync CLAUDE.md as reference ──────────────────────
echo "→ CLAUDE.md reference..."
sync_file "$PROJECT_DIR/CLAUDE.md" "$TEMPLATES/CLAUDE.reference.md"

# ─── 4b. Sync settings.local.json (hooks config) ────────
echo "→ Hooks config (settings.local.json)..."
sync_file "$PROJECT_DIR/.claude/settings.local.json" "$TEMPLATES/settings.local.json"

# ─── 4c. Sync launch.json ───────────────────────────────
echo "→ Launch config..."
sync_file "$PROJECT_DIR/.claude/launch.json" "$TEMPLATES/launch.json"

# ─── 5. Sync Memory Templates ────────────────────────────
echo "→ Memory files..."
MEMORY_DIR="$CLAUDE_DIR/projects/-Users-garyg-Documents-Claude-Working-Folder-Arx/memory"
if [ -d "$MEMORY_DIR" ]; then
    mkdir -p "$TEMPLATES/memory"
    for memfile in "$MEMORY_DIR/"*.md; do
        [ -f "$memfile" ] || continue
        sync_file "$memfile" "$TEMPLATES/memory/$(basename -- "$memfile")"
    done
fi

# ─── 6. Sync Settings ────────────────────────────────────
echo "→ Settings..."
sync_file "$CLAUDE_DIR/settings.json" "$TEMPLATES/settings.json"

# ─── 7. Sync Rules (common + all language dirs) ──────────
echo "→ Rules..."
if [ -d "$CLAUDE_DIR/rules" ]; then
    for ruledir in "$CLAUDE_DIR/rules/"*/; do
        [ -d "$ruledir" ] || continue
        dirname=$(basename -- "$ruledir")
        for rule in "$ruledir"*.md; do
            [ -f "$rule" ] || continue
            sync_file "$rule" "$TEMPLATES/rules/$dirname/$(basename -- "$rule")"
        done
    done
fi

# ─── 8. Sync Agent Definitions ───────────────────────────
echo "→ Agents..."
if [ -d "$CLAUDE_DIR/agents" ]; then
    mkdir -p "$TEMPLATES/agents"
    for agent in "$CLAUDE_DIR/agents/"*.md; do
        [ -f "$agent" ] || continue
        sync_file "$agent" "$TEMPLATES/agents/$(basename -- "$agent")"
    done
fi

# ─── 9. Sync Scheduled Task Definitions ──────────────────
echo "→ Scheduled tasks..."
if [ -d "$CLAUDE_DIR/scheduled-tasks" ]; then
    for task_dir in "$CLAUDE_DIR/scheduled-tasks/"*/; do
        [ -d "$task_dir" ] || continue
        task_name=$(basename -- "$task_dir")
        if [ -f "$task_dir/SKILL.md" ]; then
            mkdir -p "$TEMPLATES/scheduled-tasks/$task_name"
            sync_file "$task_dir/SKILL.md" "$TEMPLATES/scheduled-tasks/$task_name/SKILL.md"
        fi
    done
fi

# ─── 10. Sync User-Level Commands ────────────────────────
echo "→ User commands..."
if [ -d "$CLAUDE_DIR/commands" ]; then
    mkdir -p "$TEMPLATES/user-commands"
    for cmd in "$CLAUDE_DIR/commands/"*.md; do
        [ -f "$cmd" ] || continue
        sync_file "$cmd" "$TEMPLATES/user-commands/$(basename -- "$cmd")"
    done
fi

# ─── 10b. Sync Skills ────────────────────────────────────
echo "→ Skills..."
if [ -d "$CLAUDE_DIR/skills" ]; then
    for skilldir in "$CLAUDE_DIR/skills/"*/; do
        [ -d "$skilldir" ] || continue
        skillname=$(basename -- "$skilldir")
        for skillfile in "$skilldir"*.md; do
            [ -f "$skillfile" ] || continue
            sync_file "$skillfile" "$TEMPLATES/skills/$skillname/$(basename -- "$skillfile")"
        done
    done
fi

# ─── 11. Sync .gitignore ─────────────────────────────────
echo "→ .gitignore..."
sync_file "$PROJECT_DIR/.gitignore" "$TEMPLATES/.gitignore.template"

# ─── 11b. Sync CI/CD Workflows ───────────────────────────
echo "→ CI/CD workflows..."
if [ -d "$PROJECT_DIR/.github/workflows" ]; then
    mkdir -p "$TEMPLATES/workflows"
    for wf in "$PROJECT_DIR/.github/workflows/"*.yml; do
        [ -f "$wf" ] || continue
        sync_file "$wf" "$TEMPLATES/workflows/$(basename -- "$wf")"
    done
fi

# ─── 12. Sync Hooks ────────────────────────────────────────
echo "→ Hooks..."
if [ -d "$PROJECT_DIR/.claude/hooks" ]; then
    mkdir -p "$TEMPLATES/hooks"
    for hook in "$PROJECT_DIR/.claude/hooks/"*.sh; do
        [ -f "$hook" ] || continue
        sync_file "$hook" "$TEMPLATES/hooks/$(basename -- "$hook")"
    done
fi

# ─── 13. Update manifest timestamp ───────────────────────
if [ -f "$SCRIPT_DIR/SYSTEM_MANIFEST.md" ]; then
    # Update the "Last synced" line
    if grep -q "^> Last synced:" "$SCRIPT_DIR/SYSTEM_MANIFEST.md"; then
        sed -i '' "s/^> Last synced:.*/> Last synced: ${DATE}/" "$SCRIPT_DIR/SYSTEM_MANIFEST.md"
        echo "  ✓ SYSTEM_MANIFEST.md timestamp updated"
    fi
fi

# ─── 14. Generate component counts ───────────────────────
echo ""
echo "═══ Sync Complete ═══"
echo ""
echo "  Changes: ${CHANGES} files updated"
echo ""

# Quick inventory
SPEC_COUNT=$(ls "$PROJECT_DIR/specs/"*.md 2>/dev/null | wc -l | tr -d ' ')
CMD_COUNT=$(ls "$PROJECT_DIR/.claude/commands/"*.md 2>/dev/null | wc -l | tr -d ' ')
PLUGIN_COUNT=$(python3 -c "import json; d=json.load(open('$CLAUDE_DIR/settings.json')); print(sum(1 for v in d.get('enabledPlugins',{}).values() if v))" 2>/dev/null || echo "?")
AGENT_COUNT=$(ls "$CLAUDE_DIR/agents/"*.md 2>/dev/null | wc -l | tr -d ' ')
RULE_COUNT=$(ls "$CLAUDE_DIR/rules/common/"*.md 2>/dev/null | wc -l | tr -d ' ')
TASK_COUNT=$(ls -d "$CLAUDE_DIR/scheduled-tasks/"*/ 2>/dev/null | wc -l | tr -d ' ')
MCP_COUNT=$(python3 -c "import json; d=json.load(open('$PROJECT_DIR/.mcp.json')); print(len(d.get('mcpServers',{})))" 2>/dev/null || echo "?")
HOOK_COUNT=$(ls "$PROJECT_DIR/.claude/hooks/"*.sh 2>/dev/null | wc -l | tr -d ' ')

echo "  Component Inventory:"
echo "  ├── Writ commands:    ${CMD_COUNT}"
echo "  ├── Plugins:          ${PLUGIN_COUNT}"
echo "  ├── MCP servers:      ${MCP_COUNT}"
echo "  ├── Agents:           ${AGENT_COUNT}"
echo "  ├── Rules:            ${RULE_COUNT} common + 7 lang dirs"
echo "  ├── Scheduled tasks:  ${TASK_COUNT}"
echo "  ├── Hooks:            ${HOOK_COUNT} scripts + 3 inline"
echo "  └── Specs:            ${SPEC_COUNT}"
echo ""

if [ "$CHANGES" -gt 0 ]; then
    echo "  Run 'git add bootstrap/ && git commit -m \"chore: sync bootstrap templates\"' to persist."
fi
