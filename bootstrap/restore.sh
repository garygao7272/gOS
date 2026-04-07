#!/bin/bash
# ═══════════════════════════════════════════════════════════
# God System Restore
# Restores the full God/Writ system on a fresh machine.
# Usage: ./restore.sh [backup.tar.gz]
#   If no backup provided, uses templates from bootstrap/templates/
# ═══════════════════════════════════════════════════════════

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
CLAUDE_DIR="$HOME/.claude"
TEMPLATES="$SCRIPT_DIR/templates"

echo "═══ God System Restore ═══"
echo ""

# ─── 0. Prerequisites ────────────────────────────────────
echo "→ Checking prerequisites..."

# Check for Claude Code
if ! command -v claude &> /dev/null; then
    echo "  Claude Code not found. Installing..."
    if command -v npm &> /dev/null; then
        npm install -g @anthropic-ai/claude-code
    else
        echo "  ERROR: npm not found. Install Node.js first:"
        echo "    brew install node"
        exit 1
    fi
fi

# Check for Python 3
if ! command -v python3 &> /dev/null; then
    echo "  Python 3 not found. Install it:"
    echo "    brew install python3"
    exit 1
fi

# Check for Node.js
if ! command -v node &> /dev/null; then
    echo "  Node.js not found. Install it:"
    echo "    brew install node"
    exit 1
fi

echo "  All prerequisites met."

# ─── 1. Restore from backup or templates ─────────────────
BACKUP_PATH="${1:-}"

if [ -n "$BACKUP_PATH" ] && [ -f "$BACKUP_PATH" ]; then
    echo ""
    echo "→ Restoring from backup: $BACKUP_PATH"
    RESTORE_DIR="/tmp/god-restore-$$"
    mkdir -p "$RESTORE_DIR"
    tar xzf "$BACKUP_PATH" -C "$RESTORE_DIR"
    # Find the extracted directory
    BACKUP_DIR=$(find "$RESTORE_DIR" -maxdepth 1 -type d -name "god-backup-*" | head -1)

    if [ -z "$BACKUP_DIR" ]; then
        echo "  ERROR: Invalid backup archive format."
        rm -rf "$RESTORE_DIR"
        exit 1
    fi

    FROM_BACKUP=true
else
    echo ""
    echo "→ No backup provided. Using templates from bootstrap/templates/"
    FROM_BACKUP=false
fi

# ─── 2. Create directory structure ────────────────────────
echo ""
echo "→ Creating directory structure..."

mkdir -p "$CLAUDE_DIR"
mkdir -p "$PROJECT_DIR/.claude/commands"
mkdir -p "$PROJECT_DIR/specs"
mkdir -p "$PROJECT_DIR/sessions"
mkdir -p "$PROJECT_DIR/outputs"
mkdir -p "$PROJECT_DIR/tools"

# ─── 3. Install GOD.md (Soul File) ───────────────────────
echo "→ Installing GOD.md..."

if [ "$FROM_BACKUP" = true ] && [ -f "$BACKUP_DIR/project-level/GOD.md" ]; then
    cp "$BACKUP_DIR/project-level/GOD.md" "$PROJECT_DIR/.claude/GOD.md"
elif [ -f "$TEMPLATES/GOD.md" ]; then
    cp "$TEMPLATES/GOD.md" "$PROJECT_DIR/.claude/GOD.md"
else
    echo "  WARNING: No GOD.md found. Create one manually."
fi

# ─── 4. Install Writ Commands ────────────────────────────
echo "→ Installing Writ commands..."

if [ "$FROM_BACKUP" = true ] && [ -d "$BACKUP_DIR/project-level/commands" ]; then
    cp "$BACKUP_DIR/project-level/commands/"*.md "$PROJECT_DIR/.claude/commands/"
elif [ -d "$TEMPLATES/commands" ]; then
    cp "$TEMPLATES/commands/"*.md "$PROJECT_DIR/.claude/commands/"
fi

echo "  Installed $(ls "$PROJECT_DIR/.claude/commands/"*.md 2>/dev/null | wc -l | tr -d ' ') commands."

# ─── 5. Install Rules (common + all language dirs) ───────
echo "→ Installing coding rules..."

if [ "$FROM_BACKUP" = true ] && [ -d "$BACKUP_DIR/user-level/rules" ]; then
    cp -r "$BACKUP_DIR/user-level/rules" "$CLAUDE_DIR/rules"
elif [ -d "$TEMPLATES/rules" ]; then
    for ruledir in "$TEMPLATES/rules/"*/; do
        [ -d "$ruledir" ] || continue
        dirname=$(basename -- "$ruledir")
        mkdir -p "$CLAUDE_DIR/rules/$dirname"
        cp "$ruledir"*.md "$CLAUDE_DIR/rules/$dirname/" 2>/dev/null || true
    done
    RULE_DIRS=$(ls -d "$CLAUDE_DIR/rules/"*/ 2>/dev/null | wc -l | tr -d ' ')
    echo "  Installed $RULE_DIRS rule directories."
fi

# ─── 6. Install Settings ─────────────────────────────────
echo "→ Installing Claude Code settings..."

if [ "$FROM_BACKUP" = true ] && [ -f "$BACKUP_DIR/user-level/settings.json" ]; then
    # Don't overwrite if settings already exist
    if [ -f "$CLAUDE_DIR/settings.json" ]; then
        echo "  Settings already exist. Merging plugin list..."
        # Just inform — manual merge needed
        echo "  Review: $BACKUP_DIR/user-level/settings.json"
    else
        cp "$BACKUP_DIR/user-level/settings.json" "$CLAUDE_DIR/settings.json"
    fi
fi

# ─── 7. Install Agents ───────────────────────────────────
echo "→ Installing agent definitions..."

if [ "$FROM_BACKUP" = true ] && [ -d "$BACKUP_DIR/user-level/agents" ]; then
    mkdir -p "$CLAUDE_DIR/agents"
    cp "$BACKUP_DIR/user-level/agents/"*.md "$CLAUDE_DIR/agents/" 2>/dev/null || true
elif [ -d "$TEMPLATES/agents" ]; then
    mkdir -p "$CLAUDE_DIR/agents"
    cp "$TEMPLATES/agents/"*.md "$CLAUDE_DIR/agents/" 2>/dev/null || true
    echo "  Installed $(ls "$CLAUDE_DIR/agents/"*.md 2>/dev/null | wc -l | tr -d ' ') agents."
fi

# ─── 8. Install MCP Config ───────────────────────────────
echo "→ Installing MCP configuration..."

if [ "$FROM_BACKUP" = true ] && [ -f "$BACKUP_DIR/project-level/.mcp.json" ]; then
    cp "$BACKUP_DIR/project-level/.mcp.json" "$PROJECT_DIR/.mcp.json"
elif [ -f "$TEMPLATES/.mcp.template.json" ]; then
    cp "$TEMPLATES/.mcp.template.json" "$PROJECT_DIR/.mcp.json"
fi

# ─── 9. Install CLAUDE.md ────────────────────────────────
echo "→ Installing project instructions..."

if [ "$FROM_BACKUP" = true ] && [ -f "$BACKUP_DIR/project-level/CLAUDE.md" ]; then
    if [ ! -f "$PROJECT_DIR/CLAUDE.md" ]; then
        cp "$BACKUP_DIR/project-level/CLAUDE.md" "$PROJECT_DIR/CLAUDE.md"
    else
        echo "  CLAUDE.md already exists. Skipping."
    fi
elif [ ! -f "$PROJECT_DIR/CLAUDE.md" ]; then
    if [ -f "$TEMPLATES/CLAUDE.template.md" ]; then
        cp "$TEMPLATES/CLAUDE.template.md" "$PROJECT_DIR/CLAUDE.md"
    fi
fi

# ─── 10. Restore Memory ──────────────────────────────────
echo "→ Restoring memory files..."

if [ "$FROM_BACKUP" = true ] && [ -d "$BACKUP_DIR/memory" ]; then
    # Restore all memory directories
    find "$BACKUP_DIR/memory" -name "*.md" | while read -r memfile; do
        relpath="${memfile#$BACKUP_DIR/memory/}"
        target="$CLAUDE_DIR/projects/$relpath"
        mkdir -p "$(dirname "$target")"
        cp "$memfile" "$target"
    done
    echo "  Memory restored."
fi

# ─── 11. Restore Scheduled Tasks ─────────────────────────
echo "→ Restoring scheduled task definitions..."

if [ "$FROM_BACKUP" = true ] && [ -d "$BACKUP_DIR/user-level/scheduled-tasks" ]; then
    mkdir -p "$CLAUDE_DIR/scheduled-tasks"
    cp -r "$BACKUP_DIR/user-level/scheduled-tasks/"* "$CLAUDE_DIR/scheduled-tasks/" 2>/dev/null || true
fi

# ─── 12. Set Up Tools ────────────────────────────────────
echo "→ Setting up MCP tools..."

# Hyperliquid MCP
if [ -f "$PROJECT_DIR/tools/hyperliquid-mcp/package.json" ]; then
    echo "  Installing Hyperliquid MCP dependencies..."
    cd "$PROJECT_DIR/tools/hyperliquid-mcp" && npm install --silent 2>/dev/null
    cd "$PROJECT_DIR"
fi

# Spec-RAG (Python venv)
if [ -f "$PROJECT_DIR/tools/spec-rag-mcp/server.py" ] && [ ! -d "$PROJECT_DIR/tools/spec-rag-env" ]; then
    echo "  Creating spec-rag Python environment..."
    python3 -m venv "$PROJECT_DIR/tools/spec-rag-env"
    "$PROJECT_DIR/tools/spec-rag-env/bin/pip" install --quiet lancedb sentence-transformers mcp 2>/dev/null || true
fi

# Notte (Python venv)
if [ ! -d "$PROJECT_DIR/tools/notte-env" ]; then
    echo "  Creating notte Python environment..."
    python3 -m venv "$PROJECT_DIR/tools/notte-env"
    "$PROJECT_DIR/tools/notte-env/bin/pip" install --quiet notte-mcp 2>/dev/null || true
fi

# ─── 12b. Install Hooks ──────────────────────────────────
echo "→ Installing hooks..."

if [ -d "$TEMPLATES/hooks" ]; then
    mkdir -p "$PROJECT_DIR/.claude/hooks"
    for hook in "$TEMPLATES/hooks/"*.sh; do
        [ -f "$hook" ] || continue
        cp "$hook" "$PROJECT_DIR/.claude/hooks/"
        chmod +x "$PROJECT_DIR/.claude/hooks/$(basename -- "$hook")"
    done
    echo "  Installed $(ls "$PROJECT_DIR/.claude/hooks/"*.sh 2>/dev/null | wc -l | tr -d ' ') hooks."
fi

# ─── 12c. Install settings.local.json (hooks config) ────
echo "→ Installing hooks configuration..."

if [ -f "$TEMPLATES/settings.local.json" ]; then
    cp "$TEMPLATES/settings.local.json" "$PROJECT_DIR/.claude/settings.local.json"
    echo "  Hooks configuration installed."
fi

# ─── 12d. Install launch.json ────────────────────────────
echo "→ Installing launch configuration..."

if [ -f "$TEMPLATES/launch.json" ]; then
    cp "$TEMPLATES/launch.json" "$PROJECT_DIR/.claude/launch.json"
fi

# ─── 12e. Install Scheduled Tasks from templates ─────────
echo "→ Installing scheduled tasks..."

if [ -d "$TEMPLATES/scheduled-tasks" ]; then
    for task_dir in "$TEMPLATES/scheduled-tasks/"*/; do
        [ -d "$task_dir" ] || continue
        task_name=$(basename -- "$task_dir")
        mkdir -p "$CLAUDE_DIR/scheduled-tasks/$task_name"
        cp "$task_dir"* "$CLAUDE_DIR/scheduled-tasks/$task_name/" 2>/dev/null || true
    done
    echo "  Installed $(ls -d "$CLAUDE_DIR/scheduled-tasks/"*/ 2>/dev/null | wc -l | tr -d ' ') scheduled tasks."
fi

# ─── 12f. Install Skills ─────────────────────────────────
echo "→ Installing skills..."

if [ -d "$TEMPLATES/skills" ]; then
    for skilldir in "$TEMPLATES/skills/"*/; do
        [ -d "$skilldir" ] || continue
        skillname=$(basename -- "$skilldir")
        mkdir -p "$CLAUDE_DIR/skills/$skillname"
        cp "$skilldir"* "$CLAUDE_DIR/skills/$skillname/" 2>/dev/null || true
    done
    echo "  Installed $(ls -d "$CLAUDE_DIR/skills/"*/ 2>/dev/null | wc -l | tr -d ' ') skills."
fi

# ─── 12g. Install User-Level Commands ────────────────────
echo "→ Installing user-level commands..."

if [ -d "$TEMPLATES/user-commands" ]; then
    mkdir -p "$CLAUDE_DIR/commands"
    cp "$TEMPLATES/user-commands/"*.md "$CLAUDE_DIR/commands/" 2>/dev/null || true
fi

# ─── 12h. Install CI/CD Workflows ────────────────────────
echo "→ Installing CI/CD workflows..."

if [ -d "$TEMPLATES/workflows" ]; then
    mkdir -p "$PROJECT_DIR/.github/workflows"
    cp "$TEMPLATES/workflows/"*.yml "$PROJECT_DIR/.github/workflows/" 2>/dev/null || true
    echo "  Installed $(ls "$PROJECT_DIR/.github/workflows/"*.yml 2>/dev/null | wc -l | tr -d ' ') workflows."
fi

# ─── 13. Create .gitignore ───────────────────────────────
if [ ! -f "$PROJECT_DIR/.gitignore" ]; then
    echo "→ Creating .gitignore..."
    if [ -f "$TEMPLATES/.gitignore.template" ]; then
        cp "$TEMPLATES/.gitignore.template" "$PROJECT_DIR/.gitignore"
    fi
fi

# ─── 14. Create session files ────────────────────────────
echo "→ Setting up session management..."

if [ ! -f "$PROJECT_DIR/sessions/active.md" ]; then
    cat > "$PROJECT_DIR/sessions/active.md" << 'EOF'
# Active Sessions

| ID | Mode | Worktree | Files Owned | Started | Notes |
|----|------|----------|-------------|---------|-------|
EOF
fi

# ─── 15. Clean up ────────────────────────────────────────
if [ "$FROM_BACKUP" = true ]; then
    rm -rf "$RESTORE_DIR"
fi

# ─── 16. Verification ────────────────────────────────────
echo ""
echo "═══ Verification ═══"

check() {
    if [ -e "$1" ]; then
        echo "  ✓ $2"
    else
        echo "  ✗ $2 — MISSING"
    fi
}

check "$PROJECT_DIR/.claude/GOD.md" "GOD.md (soul file)"
check "$PROJECT_DIR/.claude/commands/god.md" "Writ commands"
check "$PROJECT_DIR/.claude/settings.local.json" "Hooks configuration"
check "$PROJECT_DIR/.claude/hooks/protect-files.sh" "Hook scripts"
check "$PROJECT_DIR/.claude/launch.json" "Launch configuration"
check "$CLAUDE_DIR/settings.json" "Claude Code settings"
check "$CLAUDE_DIR/agents/planner.md" "Agent definitions"
check "$CLAUDE_DIR/rules/common/coding-style.md" "Common rules"
check "$PROJECT_DIR/.mcp.json" "MCP configuration"
check "$PROJECT_DIR/CLAUDE.md" "Project instructions"
check "$PROJECT_DIR/sessions/active.md" "Session management"
check "$PROJECT_DIR/.github/workflows/test.yml" "CI/CD workflows"

# Count components
CMD_COUNT=$(ls "$PROJECT_DIR/.claude/commands/"*.md 2>/dev/null | wc -l | tr -d ' ')
HOOK_COUNT=$(ls "$PROJECT_DIR/.claude/hooks/"*.sh 2>/dev/null | wc -l | tr -d ' ')
AGENT_COUNT=$(ls "$CLAUDE_DIR/agents/"*.md 2>/dev/null | wc -l | tr -d ' ')
RULE_DIRS=$(ls -d "$CLAUDE_DIR/rules/"*/ 2>/dev/null | wc -l | tr -d ' ')
TASK_COUNT=$(ls -d "$CLAUDE_DIR/scheduled-tasks/"*/ 2>/dev/null | wc -l | tr -d ' ')

echo ""
echo "  Component Summary:"
echo "  ├── Commands:        $CMD_COUNT"
echo "  ├── Hooks:           $HOOK_COUNT scripts"
echo "  ├── Agents:          $AGENT_COUNT"
echo "  ├── Rule dirs:       $RULE_DIRS"
echo "  └── Scheduled tasks: $TASK_COUNT"

echo ""
echo "═══ Restore Complete ═══"
echo ""
echo "Next steps:"
echo "  1. Set environment variables: cp bootstrap/env.example ~/.env.local"
echo "  2. Edit ~/.env.local with your actual API keys"
echo "  3. Install plugins: claude plugins install"
echo "  4. Set Agent Teams: export CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1"
echo "  5. Open Claude Code: claude"
echo "  6. Start a session: /god"
echo ""
echo "Required env vars (see env.example):"
echo "  GITHUB_TOKEN, DISCORD_TOKEN, NOTTE_API_KEY"
echo "  TELEGRAM_API_ID, TELEGRAM_API_HASH"
echo "  ANTHROPIC_API_KEY (for CI/CD PR review)"
