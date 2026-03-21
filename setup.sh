#!/bin/bash
set -euo pipefail

# ============================================================
# gOS Setup — Gary's Operating System for Claude Code
# Run this on a fresh machine to replicate the full gOS setup.
# ============================================================

echo "🔧 gOS Setup"
echo "============"
echo ""

# --- Step 0: Detect paths ---
GOS_DIR="$(cd "$(dirname "$0")" && pwd)"
CLAUDE_DIR="$HOME/.claude"
COMMANDS_DIR="$CLAUDE_DIR/commands"
SKILLS_DIR="$CLAUDE_DIR/skills"
AGENTS_DIR="$CLAUDE_DIR/agents"
RULES_DIR="$CLAUDE_DIR/rules"
CONFIG_DIR="$CLAUDE_DIR/config"

echo "gOS source:  $GOS_DIR"
echo "Claude dir:  $CLAUDE_DIR"
echo ""

# --- Step 1: Create directory structure ---
echo "📁 Creating directory structure..."
mkdir -p "$COMMANDS_DIR" "$SKILLS_DIR" "$AGENTS_DIR" "$RULES_DIR" "$CONFIG_DIR"
mkdir -p "$CLAUDE_DIR/sessions"
mkdir -p "$CLAUDE_DIR/plans"

# --- Step 2: Copy commands ---
echo "📋 Installing gOS commands..."
for f in "$GOS_DIR/commands/"*.md; do
  [ -f "$f" ] || continue
  name=$(basename "$f")
  cp "$f" "$COMMANDS_DIR/$name"
  echo "  ✓ /$(basename "$name" .md)"
done

# --- Step 3: Copy skills ---
echo "🧠 Installing skills..."
for d in "$GOS_DIR/skills/"*/; do
  [ -d "$d" ] || continue
  name=$(basename "$d")
  mkdir -p "$SKILLS_DIR/$name"
  cp -r "$d"* "$SKILLS_DIR/$name/"
  echo "  ✓ $name"
done

# --- Step 4: Copy agents ---
echo "🤖 Installing agents..."
for f in "$GOS_DIR/agents/"*.md; do
  [ -f "$f" ] || continue
  name=$(basename "$f")
  cp "$f" "$AGENTS_DIR/$name"
  echo "  ✓ $(basename "$name" .md)"
done

# --- Step 5: Copy rules ---
echo "📏 Installing rules..."
if [ -d "$GOS_DIR/rules" ]; then
  cp -r "$GOS_DIR/rules/"* "$RULES_DIR/"
  echo "  ✓ Rules copied"
fi

# --- Step 6: Copy config ---
echo "⚙️  Installing config..."
if [ -d "$GOS_DIR/config" ]; then
  cp -r "$GOS_DIR/config/"* "$CONFIG_DIR/"
  echo "  ✓ Config copied (intake sources, etc.)"
fi

# --- Step 7: Merge settings.json ---
echo "🔑 Installing settings..."
if [ -f "$CLAUDE_DIR/settings.json" ]; then
  echo "  ⚠️  settings.json already exists — backing up to settings.json.bak"
  cp "$CLAUDE_DIR/settings.json" "$CLAUDE_DIR/settings.json.bak"
fi
cp "$GOS_DIR/settings/settings.json" "$CLAUDE_DIR/settings.json"
echo "  ✓ settings.json"

if [ -f "$GOS_DIR/settings/settings.local.json" ]; then
  if [ -f "$CLAUDE_DIR/settings.local.json" ]; then
    cp "$CLAUDE_DIR/settings.local.json" "$CLAUDE_DIR/settings.local.json.bak"
  fi
  cp "$GOS_DIR/settings/settings.local.json" "$CLAUDE_DIR/settings.local.json"
  echo "  ✓ settings.local.json"
fi

# --- Step 8: Copy memory ---
echo "🧠 Installing memory..."
if [ -d "$GOS_DIR/memory" ]; then
  # Memory is project-scoped — needs the project path
  echo "  ℹ️  Memory files are in gOS/memory/. These are project-scoped."
  echo "  ℹ️  They'll be auto-loaded when you cd into a project directory."
  echo "  ℹ️  To install for a specific project, run:"
  echo "      cp -r $GOS_DIR/memory/* ~/.claude/projects/<project-path>/memory/"
fi

echo ""
echo "============================================"
echo "📦 gOS files installed. Now run manual setup:"
echo "============================================"
echo ""
echo "1. INSTALL EXTERNAL DEPENDENCIES:"
echo "   brew install yt-dlp ffmpeg"
echo "   pip3 install --user --break-system-packages youtube-transcript-api openai-whisper"
echo ""
echo "2. AUTHENTICATE FIRECRAWL:"
echo "   npx firecrawl-cli login --browser"
echo ""
echo "3. INSTALL CLAUDE CODE PLUGINS:"
echo "   Open Claude Code and run:"
echo "   /plugins"
echo "   Then enable the plugins listed in SETUP.md"
echo ""
echo "4. AUTHENTICATE GITHUB CLI (if not already):"
echo "   gh auth login"
echo ""
echo "5. (OPTIONAL) COPY PROJECT FILES:"
echo "   Copy your project directories (Arx, Dux, etc.) to your working folder."
echo "   Then create project-level .claude/ directories with CLAUDE.md and commands."
echo ""
echo "Done. Start a new Claude Code session and type /gos to verify."
