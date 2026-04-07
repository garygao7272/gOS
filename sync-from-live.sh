#!/usr/bin/env bash
# Sync live Arx project → gOS repo (one-way)
# Run from the gOS repo directory after making changes in the live Arx project.
# Usage: ./sync-from-live.sh [arx-path]

set -euo pipefail

GOS_DIR="$(cd "$(dirname "$0")" && pwd)"
ARX_DIR="${1:-$(dirname "$GOS_DIR")/Arx}"

if [[ ! -d "$ARX_DIR/.claude" ]]; then
    echo "Error: $ARX_DIR doesn't look like an Arx project (no .claude/)"; exit 1
fi

echo "Syncing: $ARX_DIR → $GOS_DIR"

for f in "$ARX_DIR"/.claude/commands/*.md; do [[ -f "$f" ]] && cp "$f" "$GOS_DIR/commands/"; done; echo "✓ Commands"
for f in "$ARX_DIR"/.claude/agents/*.md; do [[ -f "$f" ]] && cp "$f" "$GOS_DIR/agents/"; done; echo "✓ Agents"
for d in "$ARX_DIR"/.claude/skills/*/; do [[ -d "$d" ]] && { n=$(basename "$d"); mkdir -p "$GOS_DIR/skills/$n"; cp "$d"* "$GOS_DIR/skills/$n/" 2>/dev/null; }; done; echo "✓ Skills"

cp "$ARX_DIR"/.claude/gOS.md "$GOS_DIR/.claude/" 2>/dev/null; cp "$ARX_DIR"/.claude/self-model.md "$GOS_DIR/.claude/" 2>/dev/null
cp "$ARX_DIR"/.claude/launch.json "$GOS_DIR/.claude/" 2>/dev/null; cp "$ARX_DIR"/.claude/settings.json "$GOS_DIR/settings/settings.json" 2>/dev/null
echo "✓ Core files"

mkdir -p "$GOS_DIR/rules/arx"; cp "$ARX_DIR"/.claude/rules/*.md "$GOS_DIR/rules/arx/" 2>/dev/null; echo "✓ Rules"
for f in "$ARX_DIR"/memory/*.md; do [[ -f "$f" ]] && cp "$f" "$GOS_DIR/memory/"; done; echo "✓ Memory"
cp "$ARX_DIR"/CLAUDE.md "$GOS_DIR/CLAUDE.md" 2>/dev/null; echo "✓ CLAUDE.md"

echo "Done. Review: cd $GOS_DIR && git diff --stat"
