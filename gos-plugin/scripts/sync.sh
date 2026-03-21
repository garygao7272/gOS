#!/bin/bash
# gOS Plugin Sync Script
# Bidirectional sync between live ~/.claude/ config and gos-plugin/

set -euo pipefail

PLUGIN_DIR="$(cd "$(dirname "$0")/.." && pwd)"
CLAUDE_DIR="$HOME/.claude"

COMMANDS=(gos think design simulate build review ship evolve aside checkpoint claw)
AGENTS=(planner architect tdd-guide code-reviewer security-reviewer build-error-resolver e2e-runner doc-updater refactor-cleaner python-reviewer harness-optimizer loop-operator)
SKILLS=(intake design-sync stitch-design arx-ui-stack strategic-compact verification-loop tdd-workflow coding-standards backend-patterns frontend-patterns frontend-slides python-patterns python-testing)

usage() {
  echo "Usage: $0 <export|install|link>"
  echo ""
  echo "  export  - Copy from live ~/.claude/ into plugin directory"
  echo "  install - Register plugin as local marketplace + create symlinks"
  echo "  link    - Create symlinks from ~/.claude/commands/ to plugin (flat commands in Code)"
  exit 1
}

cmd_export() {
  echo "=== Exporting from live config to plugin ==="

  # Commands
  echo "Copying commands..."
  for cmd in "${COMMANDS[@]}"; do
    src="$CLAUDE_DIR/commands/${cmd}.md"
    if [ -f "$src" ]; then
      # Resolve symlink if needed
      real_src="$(readlink -f "$src" 2>/dev/null || echo "$src")"
      cp "$real_src" "$PLUGIN_DIR/commands/${cmd}.md"
    fi
  done

  # Agents
  echo "Copying agents..."
  for agent in "${AGENTS[@]}"; do
    src="$CLAUDE_DIR/agents/${agent}.md"
    if [ -f "$src" ]; then
      cp "$src" "$PLUGIN_DIR/agents/${agent}.md"
    fi
  done

  # Skills
  echo "Copying skills..."
  for skill in "${SKILLS[@]}"; do
    src="$CLAUDE_DIR/skills/${skill}"
    if [ -d "$src" ]; then
      rm -rf "$PLUGIN_DIR/skills/${skill}"
      cp -r "$src" "$PLUGIN_DIR/skills/${skill}"
    fi
  done

  echo "=== Export complete ==="
  echo "Commands: $(ls "$PLUGIN_DIR/commands/"*.md 2>/dev/null | wc -l | tr -d ' ')"
  echo "Agents:   $(ls "$PLUGIN_DIR/agents/"*.md 2>/dev/null | wc -l | tr -d ' ')"
  echo "Skills:   $(ls -d "$PLUGIN_DIR/skills/"*/ 2>/dev/null | wc -l | tr -d ' ')"
}

cmd_install() {
  echo "=== Installing gOS plugin ==="

  # Register as local marketplace in settings.json
  if [ -f "$CLAUDE_DIR/settings.json" ]; then
    # Check if gos-plugin marketplace already registered
    if ! grep -q "gos-plugin" "$CLAUDE_DIR/settings.json"; then
      echo "Registering gos-plugin as local marketplace..."
      echo "Add the following to ~/.claude/settings.json under 'extraKnownMarketplaces':"
      echo ""
      echo '    "gos-plugin": {'
      echo '      "source": {'
      echo '        "source": "directory",'
      echo "        \"path\": \"$PLUGIN_DIR\""
      echo '      }'
      echo '    }'
      echo ""
      echo "And add to 'enabledPlugins':"
      echo '    "gos@gos-plugin": true'
    else
      echo "gos-plugin marketplace already registered."
    fi
  fi

  # Create symlinks for flat commands in Code mode
  cmd_link

  echo "=== Install complete ==="
}

cmd_link() {
  echo "=== Creating symlinks for flat Code-mode commands ==="

  mkdir -p "$CLAUDE_DIR/commands"

  for cmd in "${COMMANDS[@]}"; do
    src="$PLUGIN_DIR/commands/${cmd}.md"
    dst="$CLAUDE_DIR/commands/${cmd}.md"

    if [ -f "$src" ]; then
      # Remove existing file/symlink
      if [ -e "$dst" ] || [ -L "$dst" ]; then
        rm "$dst"
      fi
      ln -s "$src" "$dst"
      echo "  Linked: /${cmd} -> plugin"
    fi
  done

  echo "=== Symlinks created ==="
}

case "${1:-}" in
  export)  cmd_export ;;
  install) cmd_install ;;
  link)    cmd_link ;;
  *)       usage ;;
esac
