#!/bin/bash
set -euo pipefail

# ============================================================
# gOS Sync — Export live ~/.claude config to this gOS repo
# Run on your PRIMARY machine to capture current state.
# ============================================================

GOS_DIR="$(cd "$(dirname "$0")" && pwd)"
CLAUDE_DIR="$HOME/.claude"

echo "📤 Syncing live config → gOS repo"
echo "  From: $CLAUDE_DIR"
echo "  To:   $GOS_DIR"
echo ""

# Commands (resolve symlinks)
echo "📋 Commands..."
for cmd in gos think design simulate build review ship evolve aside claw checkpoint; do
  if [ -L "$CLAUDE_DIR/commands/$cmd.md" ]; then
    cp -L "$CLAUDE_DIR/commands/$cmd.md" "$GOS_DIR/commands/$cmd.md"
  elif [ -f "$CLAUDE_DIR/commands/$cmd.md" ]; then
    cp "$CLAUDE_DIR/commands/$cmd.md" "$GOS_DIR/commands/$cmd.md"
  fi
done

# Skills
echo "🧠 Skills..."
for d in intake arx-ui-stack design-sync stitch-design strategic-compact verification-loop tdd-workflow coding-standards backend-patterns frontend-patterns frontend-slides python-patterns python-testing; do
  if [ -d "$CLAUDE_DIR/skills/$d" ]; then
    rm -rf "$GOS_DIR/skills/$d"
    cp -r "$CLAUDE_DIR/skills/$d" "$GOS_DIR/skills/$d"
  fi
done

# Agents
echo "🤖 Agents..."
cp "$CLAUDE_DIR/agents/"*.md "$GOS_DIR/agents/" 2>/dev/null || true

# Rules
echo "📏 Rules..."
rm -rf "$GOS_DIR/rules"
cp -r "$CLAUDE_DIR/rules" "$GOS_DIR/rules"

# Config
echo "⚙️  Config..."
cp "$CLAUDE_DIR/config/intake-sources.md" "$GOS_DIR/config/" 2>/dev/null || true

# Settings (sanitize paths)
echo "🔑 Settings..."
cp "$CLAUDE_DIR/settings.json" "$GOS_DIR/settings/settings.json"
cp "$CLAUDE_DIR/settings.local.json" "$GOS_DIR/settings/settings.local.json"

# Sanitize hardcoded home paths
WHOAMI=$(whoami)
sed -i '' "s|/Users/$WHOAMI/claude-plugins|/Users/REPLACE_WITH_YOUR_USERNAME/claude-plugins|g" "$GOS_DIR/settings/settings.json"

echo ""
echo "✅ Sync complete. Review changes:"
echo "   cd $GOS_DIR && git diff --stat"
echo ""
echo "To push: git add -A && git commit -m 'sync gOS' && git push"
