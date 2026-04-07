#!/bin/bash
# ═══════════════════════════════════════════════════════════
# God System Backup
# Archives everything needed to restore the Writ on a new machine.
# Output: god-backup-YYYY-MM-DD.tar.gz
# ═══════════════════════════════════════════════════════════

set -euo pipefail

DATE=$(date +%Y-%m-%d)
BACKUP_NAME="god-backup-${DATE}"
BACKUP_DIR="/tmp/${BACKUP_NAME}"
CLAUDE_DIR="$HOME/.claude"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

echo "═══ God System Backup ═══"
echo "Date: ${DATE}"
echo ""

# Clean previous temp
rm -rf "$BACKUP_DIR"
mkdir -p "$BACKUP_DIR"/{user-level,project-level,memory,plugins}

# ─── 1. User-Level Files ─────────────────────────────────
echo "→ Backing up user-level files..."

# GOD.md (soul file — may be in project or user level)
if [ -f "$CLAUDE_DIR/GOD.md" ]; then
    cp "$CLAUDE_DIR/GOD.md" "$BACKUP_DIR/user-level/"
fi
if [ -f "$PROJECT_DIR/.claude/GOD.md" ]; then
    cp "$PROJECT_DIR/.claude/GOD.md" "$BACKUP_DIR/project-level/"
fi

# Settings
if [ -f "$CLAUDE_DIR/settings.json" ]; then
    cp "$CLAUDE_DIR/settings.json" "$BACKUP_DIR/user-level/"
fi

# Rules (coding standards)
if [ -d "$CLAUDE_DIR/rules" ]; then
    cp -r "$CLAUDE_DIR/rules" "$BACKUP_DIR/user-level/rules"
fi

# User-level commands
if [ -d "$CLAUDE_DIR/commands" ]; then
    cp -r "$CLAUDE_DIR/commands" "$BACKUP_DIR/user-level/commands"
fi

# User-level agents
if [ -d "$CLAUDE_DIR/agents" ]; then
    cp -r "$CLAUDE_DIR/agents" "$BACKUP_DIR/user-level/agents"
fi

# ─── 2. Project-Level Files ──────────────────────────────
echo "→ Backing up project-level files..."

# Writ commands
if [ -d "$PROJECT_DIR/.claude/commands" ]; then
    cp -r "$PROJECT_DIR/.claude/commands" "$BACKUP_DIR/project-level/commands"
fi

# Local settings
if [ -f "$PROJECT_DIR/.claude/settings.local.json" ]; then
    cp "$PROJECT_DIR/.claude/settings.local.json" "$BACKUP_DIR/project-level/"
fi

# Launch config
if [ -f "$PROJECT_DIR/.claude/launch.json" ]; then
    cp "$PROJECT_DIR/.claude/launch.json" "$BACKUP_DIR/project-level/"
fi

# MCP config (but strip any actual secrets — they should be env vars)
if [ -f "$PROJECT_DIR/.mcp.json" ]; then
    cp "$PROJECT_DIR/.mcp.json" "$BACKUP_DIR/project-level/"
fi

# CLAUDE.md
if [ -f "$PROJECT_DIR/CLAUDE.md" ]; then
    cp "$PROJECT_DIR/CLAUDE.md" "$BACKUP_DIR/project-level/"
fi

# ─── 3. Memory Files ─────────────────────────────────────
echo "→ Backing up memory files..."

# Find all project memory directories
find "$CLAUDE_DIR/projects" -path "*/memory/*" -name "*.md" -print0 2>/dev/null | while IFS= read -r -d '' memfile; do
    # Preserve relative path structure
    relpath="${memfile#"$CLAUDE_DIR/projects/"}"
    targetdir="$BACKUP_DIR/memory/$(dirname -- "$relpath")"
    mkdir -p "$targetdir"
    cp "$memfile" "$targetdir/$(basename -- "$memfile")"
done

# ─── 4. Plugin List ──────────────────────────────────────
echo "→ Capturing plugin list..."

# Extract enabled plugins from settings.json
if [ -f "$CLAUDE_DIR/settings.json" ]; then
    # Simple extraction — just copy the settings which contains plugin config
    cp "$CLAUDE_DIR/settings.json" "$BACKUP_DIR/plugins/settings-with-plugins.json"
fi

# List installed plugin directories
if [ -d "$CLAUDE_DIR/plugins" ]; then
    ls -la "$CLAUDE_DIR/plugins/" > "$BACKUP_DIR/plugins/installed-plugins.txt" 2>/dev/null || true
fi

# ─── 5. Scheduled Tasks ──────────────────────────────────
echo "→ Backing up scheduled task definitions..."

if [ -d "$CLAUDE_DIR/scheduled-tasks" ]; then
    cp -r "$CLAUDE_DIR/scheduled-tasks" "$BACKUP_DIR/user-level/scheduled-tasks"
fi

# ─── 6. Local plugins ────────────────────────────────────
echo "→ Backing up local plugin manifests..."

if [ -d "$HOME/claude-plugins" ]; then
    # Only copy manifests, not node_modules
    find "$HOME/claude-plugins" \( -name "manifest.json" -o -name "package.json" -o -name "*.md" \) -print0 2>/dev/null | while IFS= read -r -d '' f; do
        relpath="${f#"$HOME/claude-plugins/"}"
        targetdir="$BACKUP_DIR/plugins/local/$(dirname -- "$relpath")"
        mkdir -p "$targetdir"
        cp "$f" "$targetdir/$(basename -- "$f")"
    done
fi

# ─── 7. Create manifest ──────────────────────────────────
echo "→ Generating manifest..."

cat > "$BACKUP_DIR/MANIFEST.md" << EOF
# God System Backup Manifest
**Date:** ${DATE}
**Machine:** $(hostname)
**User:** $(whoami)
**Claude Code Version:** $(claude --version 2>/dev/null || echo "unknown")

## Contents
- user-level/GOD.md — Soul file
- user-level/settings.json — Claude Code settings + plugins
- user-level/rules/ — Coding standards (common + language-specific)
- user-level/commands/ — User-level commands
- user-level/agents/ — Agent definitions
- user-level/scheduled-tasks/ — Scheduled task definitions
- project-level/commands/ — 9 Writ commands
- project-level/.mcp.json — MCP server configuration
- project-level/CLAUDE.md — Project instructions
- memory/ — All cross-session memory files
- plugins/ — Plugin list and local plugin manifests

## Restore
\`\`\`bash
tar xzf ${BACKUP_NAME}.tar.gz
cd ${BACKUP_NAME}
# Follow instructions in bootstrap/README.md
\`\`\`
EOF

# ─── 8. Create tarball ───────────────────────────────────
echo "→ Creating archive..."

OUTPUT_PATH="${PROJECT_DIR}/${BACKUP_NAME}.tar.gz"
cd /tmp
tar czf "$OUTPUT_PATH" "$BACKUP_NAME"

# Clean up
rm -rf "$BACKUP_DIR"

# ─── Done ─────────────────────────────────────────────────
SIZE=$(du -h "$OUTPUT_PATH" | cut -f1)
echo ""
echo "═══ Backup Complete ═══"
echo "File: ${OUTPUT_PATH}"
echo "Size: ${SIZE}"
echo ""
echo "Store this somewhere safe (iCloud, Google Drive, USB)."
echo "To restore: ./bootstrap/restore.sh ${BACKUP_NAME}.tar.gz"
