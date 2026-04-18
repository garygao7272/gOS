#!/bin/bash
# sync-gos.sh — propagate gOS source to all live targets
#
# Implements stages 1, 2, 6, 7 of the /ship gos pipeline
# (see outputs/think/decide/ship-gos-pipeline.md for the full 7-stage design).
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
#   bash tools/sync-gos.sh               # full: validate → sync → verify (verbose)
#   bash tools/sync-gos.sh --quiet       # full, summary only
#   bash tools/sync-gos.sh --preflight   # stages 1+2 only (classify + validate) — pre-commit gate
#   bash tools/sync-gos.sh --verify-only # stage 7 only (drift check)
#   bash tools/sync-gos.sh --no-verify   # full sync without post-verification

set -euo pipefail

# ── Args ────────────────────────────────────────────────────────────────
MODE="full"
QUIET=0
VERIFY=1
for a in "$@"; do
  case "$a" in
    --quiet)       QUIET=1 ;;
    --preflight)   MODE="preflight" ;;
    --verify-only) MODE="verify" ;;
    --no-verify)   VERIFY=0 ;;
    *) echo "Unknown arg: $a" >&2; exit 1 ;;
  esac
done

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

# ═══════════════════════════════════════════════════════════════════════
# STAGE 1 — Classify changed files (framework | session | excluded | unknown)
# ═══════════════════════════════════════════════════════════════════════
# Returns 0 if clean (no unknowns). Sets UNKNOWNS, SESSION_FILES counters.
classify_changes() {
  cd "$GOS_DIR"
  UNKNOWNS=()
  SESSION_FILES=()
  FRAMEWORK_FILES=()
  # git status --porcelain: "MM path", " M path", "?? path", etc.
  while IFS= read -r line; do
    [[ -z "$line" ]] && continue
    local path="${line:3}"
    case "$path" in
      commands/*|agents/*|hooks/*|.claude/hooks/*|rules/*|skills/*|tools/*|output-styles/*|evals/*|claws/*|bootstrap/*|docs/*|settings/settings.json|install.sh|CLAUDE.md|README.md|invariants.md|gos-plugin-build/*)
        FRAMEWORK_FILES+=("$path") ;;
      sessions/*|memory/*|.claude/self-model.md)
        SESSION_FILES+=("$path") ;;
      outputs/*|apps/*|specs/*|.claude/scheduled_tasks.lock|*.bak|"* 2"|"* 2.md")
        : # excluded — silently ignore
        ;;
      *)
        UNKNOWNS+=("$path") ;;
    esac
  done < <(git status --porcelain 2>/dev/null)

  log "  framework: ${#FRAMEWORK_FILES[@]} | session: ${#SESSION_FILES[@]} | unknown: ${#UNKNOWNS[@]}"
  if [[ ${#UNKNOWNS[@]} -gt 0 ]]; then
    err "unknown-scope files (add to classify rules or explicit git add):"
    for u in "${UNKNOWNS[@]}"; do echo "  - $u" >&2; done
    return 1
  fi
  return 0
}

# ═══════════════════════════════════════════════════════════════════════
# STAGE 2 — Validate (frontmatter tests + secret scan)
# ═══════════════════════════════════════════════════════════════════════
# Returns 0 on clean, non-zero on any failure.
validate_changes() {
  local failed=0

  # 2a. Frontmatter regression (bats) — only if bats + tests present
  if command -v bats >/dev/null 2>&1 \
     && [[ -f "$GOS_DIR/tests/hooks/command-frontmatter.bats" ]]; then
    log "  frontmatter tests..."
    if ! (cd "$GOS_DIR" && bats tests/hooks/command-frontmatter.bats >/dev/null 2>&1); then
      err "command-frontmatter.bats FAILED — run manually: bats tests/hooks/command-frontmatter.bats"
      failed=1
    else
      log "    ✓ all frontmatter tests pass"
    fi
  else
    log "  (bats or frontmatter tests not found — skipping frontmatter check)"
  fi

  # 2b. Secret scan on staged files only (avoids scanning whole tree)
  log "  secret scan on staged diff..."
  local staged_diff
  staged_diff=$(cd "$GOS_DIR" && git diff --cached 2>/dev/null || true)
  # Common leak patterns: API keys, private keys, env files
  local suspicious=()
  while IFS= read -r hit; do
    [[ -z "$hit" ]] && continue
    suspicious+=("$hit")
  done < <(printf '%s' "$staged_diff" | grep -Ei \
    -e '(api[_-]?key|secret|password|token|bearer)["[:space:]]*[:=]["[:space:]]*[A-Za-z0-9+/=_-]{16,}' \
    -e '-----BEGIN (RSA |OPENSSH |EC |DSA )?PRIVATE KEY-----' \
    -e 'AKIA[0-9A-Z]{16}' \
    -e 'sk-[A-Za-z0-9]{32,}' \
    2>/dev/null || true)
  if [[ ${#suspicious[@]} -gt 0 ]]; then
    err "possible secrets in staged diff (${#suspicious[@]} lines matched) — review manually before committing"
    failed=1
  else
    log "    ✓ no secret patterns detected"
  fi

  return $failed
}

# ═══════════════════════════════════════════════════════════════════════
# STAGE 7 — Verify (drift check — source vs each live target)
# ═══════════════════════════════════════════════════════════════════════
# Returns 0 if no drift, non-zero if any target differs from source.
verify_sync() {
  local drift=0

  # 7a. Repo vs GitHub — distinguish "ahead only" (unpushed commits, not drift)
  # from "behind or diverged" (real drift that needs a pull).
  if git -C "$GOS_DIR" rev-parse --abbrev-ref --symbolic-full-name @{upstream} >/dev/null 2>&1; then
    local ahead behind
    ahead="$(git -C "$GOS_DIR" rev-list --count '@{upstream}..HEAD' 2>/dev/null || echo 0)"
    behind="$(git -C "$GOS_DIR" rev-list --count 'HEAD..@{upstream}' 2>/dev/null || echo 0)"
    if [[ "$behind" -gt 0 ]]; then
      err "  repo: behind upstream by $behind commit(s) — run git pull"
      ((drift++))
    elif [[ "$ahead" -gt 0 ]]; then
      log "  ✓ repo ahead of upstream by $ahead commit(s) (unpushed — not drift)"
    else
      log "  ✓ repo matches upstream"
    fi
  fi

  # 7b. User install matches source (commands only — cheap + sufficient signal)
  local mismatch=0
  for f in "$GOS_DIR"/commands/*.md; do
    [[ -f "$f" ]] || continue
    local name; name="$(basename "$f")"
    if [[ -f "$CLAUDE_HOME/commands/$name" ]]; then
      diff -q "$f" "$CLAUDE_HOME/commands/$name" >/dev/null 2>&1 || ((mismatch++))
    else
      ((mismatch++))
    fi
  done
  if [[ $mismatch -gt 0 ]]; then
    err "  user install: $mismatch commands differ from source"
    ((drift++))
  else
    log "  ✓ user install matches source"
  fi

  # 7c. Plugin cache matches source
  if [[ -n "$PLUGIN_DIR" && -d "$PLUGIN_DIR/commands" ]]; then
    mismatch=0
    for f in "$GOS_DIR"/commands/*.md; do
      [[ -f "$f" ]] || continue
      local name; name="$(basename "$f")"
      if [[ -f "$PLUGIN_DIR/commands/$name" ]]; then
        diff -q "$f" "$PLUGIN_DIR/commands/$name" >/dev/null 2>&1 || ((mismatch++))
      else
        ((mismatch++))
      fi
    done
    if [[ $mismatch -gt 0 ]]; then
      err "  plugin cache: $mismatch commands differ from source"
      ((drift++))
    else
      log "  ✓ plugin cache matches source"
    fi
  fi

  return $drift
}

# ═══════════════════════════════════════════════════════════════════════
# Dispatch — run the requested mode and exit
# ═══════════════════════════════════════════════════════════════════════
if [[ "$MODE" == "preflight" ]]; then
  log "── Preflight: classify + validate ─────────────────────────────────"
  classify_changes || exit 1
  validate_changes || exit 1
  log "✓ preflight clean"
  exit 0
fi

if [[ "$MODE" == "verify" ]]; then
  log "── Verify-only: drift check ───────────────────────────────────────"
  if verify_sync; then
    log "✓ no drift"
    exit 0
  else
    exit 1
  fi
fi

# Default (MODE=full) — continue to existing sync stages below.

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

# ── Stage 7. Post-sync verification (default on; --no-verify to skip) ──
VERIFY_DRIFT=0
if [[ "$VERIFY" == "1" ]]; then
  log ""
  log "── Verification (drift check) ─────────────────────────────────────"
  if verify_sync; then
    log "  → no drift"
  else
    VERIFY_DRIFT=1
    err "post-sync drift detected — re-run bash tools/sync-gos.sh"
  fi
fi

# ── Summary ────────────────────────────────────────────────────────────
echo ""
if [[ "$VERIFY_DRIFT" == "0" ]]; then
  echo "✓ gOS synced — user($USER_FILES) + styles($STYLES) + statusline($STATUSLINE) + plugin($PLUGIN_FILES)"
  exit 0
else
  echo "⚠ gOS synced WITH DRIFT — user($USER_FILES) + styles($STYLES) + statusline($STATUSLINE) + plugin($PLUGIN_FILES)"
  exit 1
fi
