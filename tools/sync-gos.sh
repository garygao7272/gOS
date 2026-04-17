#!/bin/bash
# sync-gos.sh — propagate gOS source to all live targets
#
# Targets (the three places gOS lives at runtime):
#   1. Repo (git)        — already on disk; this script does NOT push
#   2. User install      — ~/.claude/{commands,agents,skills,rules,hooks,output-styles,statusline.sh}
#   3. Plugin cache      — ~/.claude/plugins/cache/gos-marketplace/gos/<version>/{commands,agents,hooks,rules}
#
# The plugin cache is what powers /-autocomplete in Claude Code ≥ 2.1.84.
# Without syncing the plugin cache, edits to commands/*.md don't appear in
# the autocomplete dropdown until the marketplace re-pulls from GitHub.
#
# Called by `/ship gos` after the git push.
# Idempotent — safe to run repeatedly.
#
# Usage:
#   bash tools/sync-gos.sh           # verbose
#   bash tools/sync-gos.sh --quiet   # only print errors + summary

set -euo pipefail

# ── Args ────────────────────────────────────────────────────────────────
QUIET=0
[[ "${1:-}" == "--quiet" ]] && QUIET=1

log() { [[ "$QUIET" == "0" ]] && echo "$@"; return 0; }
err() { echo "ERROR: $*" >&2; }

# ── Resolve paths ───────────────────────────────────────────────────────
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
GOS_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
CLAUDE_HOME="${HOME}/.claude"

if [[ ! -d "$GOS_DIR/commands" ]]; then
  err "Not a gOS repo: $GOS_DIR (no commands/ dir)"
  exit 1
fi

# ── Find latest plugin cache version (e.g., 4.4.0, 4.5.0, ...) ─────────
PLUGIN_BASE="$CLAUDE_HOME/plugins/cache/gos-marketplace/gos"
PLUGIN_DIR=""
if [[ -d "$PLUGIN_BASE" ]]; then
  PLUGIN_DIR="$(ls -1d "$PLUGIN_BASE"/*/ 2>/dev/null | sort -V | tail -1 || true)"
  PLUGIN_DIR="${PLUGIN_DIR%/}"
fi

# ── Counters ────────────────────────────────────────────────────────────
USER_FILES=0; PLUGIN_FILES=0; STYLES=0; HOOKS=0; STATUSLINE=0

# ── 1. User install (~/.claude/) — delegate to install.sh --global ─────
log "── User install (~/.claude/) ──────────────────────────────────────"
if [[ -x "$GOS_DIR/install.sh" ]]; then
  if [[ "$QUIET" == "1" ]]; then
    bash "$GOS_DIR/install.sh" --global > /dev/null 2>&1 || {
      err "install.sh --global failed"; exit 1;
    }
  else
    bash "$GOS_DIR/install.sh" --global | grep -E '^(  ✓|  !|  ✗|[0-9])' | head -40
  fi
  USER_FILES=$(find "$CLAUDE_HOME/commands" "$CLAUDE_HOME/agents" "$CLAUDE_HOME/hooks" \
                    -type f 2>/dev/null | wc -l | tr -d ' ')
  log "  → $USER_FILES files in commands/ + agents/ + hooks/"
else
  err "install.sh missing or not executable"; exit 1
fi

# ── 2. Output styles (not handled by install.sh) ───────────────────────
log ""
log "── Output styles ──────────────────────────────────────────────────"
if [[ -d "$GOS_DIR/output-styles" ]]; then
  mkdir -p "$CLAUDE_HOME/output-styles"
  for f in "$GOS_DIR"/output-styles/*.md; do
    [[ -f "$f" ]] || continue
    cp "$f" "$CLAUDE_HOME/output-styles/"
    log "  ✓ $(basename "$f")"
    ((STYLES++))
  done
  log "  → $STYLES style(s) synced"
else
  log "  (no output-styles/ dir in repo — skipping)"
fi

# ── 3. Status line (not handled by install.sh) ─────────────────────────
log ""
log "── Status line ────────────────────────────────────────────────────"
if [[ -f "$GOS_DIR/tools/gos-statusline.sh" ]]; then
  cp "$GOS_DIR/tools/gos-statusline.sh" "$CLAUDE_HOME/statusline.sh"
  chmod +x "$CLAUDE_HOME/statusline.sh"
  STATUSLINE=1
  log "  ✓ statusline.sh"
fi

# ── 4. Plugin cache (powers /-autocomplete in CC ≥ 2.1.84) ─────────────
log ""
log "── Plugin cache ───────────────────────────────────────────────────"
if [[ -n "$PLUGIN_DIR" && -d "$PLUGIN_DIR" ]]; then
  log "  target: ${PLUGIN_DIR/$HOME/~}"
  for sub in commands agents rules; do
    if [[ -d "$GOS_DIR/$sub" ]]; then
      mkdir -p "$PLUGIN_DIR/$sub"
      # Use rsync if available for cleaner sync; fall back to cp -R
      if command -v rsync >/dev/null 2>&1; then
        rsync -a --delete --exclude='*.bak' "$GOS_DIR/$sub/" "$PLUGIN_DIR/$sub/" 2>/dev/null || \
          cp -R "$GOS_DIR/$sub"/* "$PLUGIN_DIR/$sub/" 2>/dev/null || true
      else
        cp -R "$GOS_DIR/$sub"/* "$PLUGIN_DIR/$sub/" 2>/dev/null || true
      fi
      n=$(find "$PLUGIN_DIR/$sub" -type f 2>/dev/null | wc -l | tr -d ' ')
      log "  ✓ $sub/ ($n files)"
      PLUGIN_FILES=$((PLUGIN_FILES + n))
    fi
  done
  # Hooks live under .claude/hooks/ in the source repo
  if [[ -d "$GOS_DIR/.claude/hooks" ]]; then
    mkdir -p "$PLUGIN_DIR/hooks"
    for f in "$GOS_DIR"/.claude/hooks/*.sh; do
      [[ -f "$f" ]] || continue
      cp "$f" "$PLUGIN_DIR/hooks/"
      chmod +x "$PLUGIN_DIR/hooks/$(basename "$f")" 2>/dev/null || true
      ((HOOKS++))
    done
    log "  ✓ hooks/ ($HOOKS hooks)"
    PLUGIN_FILES=$((PLUGIN_FILES + HOOKS))
  fi
  log "  → $PLUGIN_FILES files synced to plugin cache"
else
  log "  (no plugin cache found at $PLUGIN_BASE — skipping)"
  log "  install via: claude plugin install gos@gos-marketplace"
fi

# ── Summary ────────────────────────────────────────────────────────────
echo ""
echo "✓ gOS synced — user($USER_FILES) + styles($STYLES) + statusline($STATUSLINE) + plugin($PLUGIN_FILES)"
