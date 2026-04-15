#!/usr/bin/env bash
# gOS Bootstrap & Installer
#
# Usage:
#   ./install.sh                         Health check only (default)
#   ./install.sh --install               Install tools (no project wiring)
#   ./install.sh --global                Install gOS globally to ~/.claude/
#   ./install.sh --bootstrap <dir>       Wire gOS into a project (lean — project-specific only)
#   ./install.sh --bootstrap             Interactive (asks for project dir)
#
# Architecture:
#   --global   → shared files to ~/.claude/ (CLAUDE.md, commands, agents, skills, rules, hooks, settings)
#   --bootstrap → project-specific files only (CLAUDE.md template, .mcp.json, directory structure)
#   Global install is a prerequisite for bootstrap. Run --global once per machine.
#
# Run from inside the gOS repo clone.

set -euo pipefail

# ── Config ──────────────────────────────────────────────────────
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
GOS_DIR="$SCRIPT_DIR"
WORKING_DIR="$(dirname "$GOS_DIR")"
TOOLKIT="$WORKING_DIR/toolkit"
CLAUDE_HOME="${HOME}/.claude"

# ── Colors ──────────────────────────────────────────────────────
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
CYAN='\033[0;36m'; BOLD='\033[1m'; DIM='\033[2m'; NC='\033[0m'
PASS="${GREEN}✓${NC}"; FAIL="${RED}✗${NC}"; WARN="${YELLOW}!${NC}"; INFO="${CYAN}→${NC}"

ERRORS=0; WARNINGS=0; INSTALLED=0

# ── Helpers ─────────────────────────────────────────────────────
check_cmd() {
    local name="$1" cmd="$2" flag="${3:---version}"
    if "$cmd" "$flag" &>/dev/null; then
        local ver; ver=$("$cmd" "$flag" 2>&1 | head -1)
        echo -e "  ${PASS} ${name}: ${ver}"; return 0
    else
        echo -e "  ${FAIL} ${name}: not found"; ((ERRORS++)); return 1
    fi
}

install_cmd() {
    local name="$1" install_fn="$2"
    echo -e "  ${INFO} Installing ${name}..."
    eval "$install_fn"
    ((INSTALLED++))
}

copy_if_newer() {
    local src="$1" dst="$2"
    if [[ ! -f "$dst" ]] || [[ "$src" -nt "$dst" ]]; then
        cp "$src" "$dst"
        return 0
    fi
    return 1
}

# ── Parse Args ──────────────────────────────────────────────────
MODE="check"
TARGET_DIR=""

case "${1:-}" in
    --global)    MODE="global" ;;
    --bootstrap) MODE="bootstrap"; TARGET_DIR="${2:-}" ;;
    --install)   MODE="install" ;;
    --check|-c)  MODE="check" ;;
    "")          MODE="check" ;;
    *)           echo "Unknown: $1. Usage: ./install.sh [--check|--install|--global|--bootstrap <dir>]"; exit 1 ;;
esac

# ── Header ──────────────────────────────────────────────────────
echo ""
echo -e "${CYAN}${BOLD}gOS Installer${NC} — $(uname -s) $(uname -m)"
echo -e "${DIM}Mode: ${MODE}  |  gOS: ${GOS_DIR}  |  Toolkit: ${TOOLKIT}${NC}"
echo "────────────────────────────────────────────────"

[[ "$(uname -s)" == "Darwin" ]] && export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"

# ════════════════════════════════════════════════════════════════
# PHASE 1: Core Runtime
# ════════════════════════════════════════════════════════════════
echo -e "\n${CYAN}1. Core Runtime${NC}"

check_cmd "Python3" "python3" || true
check_cmd "Git" "git" || true

if command -v node &>/dev/null; then check_cmd "Node.js" "node" || true
elif [[ "$MODE" != "check" ]]; then install_cmd "Node.js" "brew install node"
else echo -e "  ${FAIL} Node.js: not found"; ((ERRORS++)); fi

command -v npx &>/dev/null && check_cmd "npx" "npx" || true
if command -v gh &>/dev/null; then check_cmd "gh CLI" "gh" || true
elif [[ "$MODE" != "check" ]]; then install_cmd "gh CLI" "brew install gh"
else echo -e "  ${FAIL} gh CLI: not found"; ((ERRORS++)); fi

# ════════════════════════════════════════════════════════════════
# PHASE 2: CLI Tools
# ════════════════════════════════════════════════════════════════
echo -e "\n${CYAN}2. CLI Tools${NC}"

mkdir -p "$TOOLKIT" 2>/dev/null || true

if [[ -x "$TOOLKIT/officecli" ]]; then
    check_cmd "OfficeCLI" "$TOOLKIT/officecli"
elif [[ "$MODE" != "check" ]]; then
    ARCH=$(uname -m)
    [[ "$ARCH" == "arm64" ]] && ASSET="officecli-mac-arm64" || ASSET="officecli-mac-x64"
    install_cmd "OfficeCLI" "curl -sL -o '$TOOLKIT/officecli' 'https://github.com/iOfficeAI/OfficeCLI/releases/latest/download/$ASSET' && chmod +x '$TOOLKIT/officecli'"
else
    echo -e "  ${FAIL} OfficeCLI: not found"; ((ERRORS++))
fi

if command -v soffice &>/dev/null; then check_cmd "LibreOffice" "soffice"
elif [[ "$MODE" != "check" ]]; then install_cmd "LibreOffice" "brew install --cask libreoffice"
else echo -e "  ${WARN} LibreOffice: not found (optional)"; ((WARNINGS++)); fi

# Dux — simulation engine
if [[ -d "$WORKING_DIR/Dux" ]]; then
    echo -e "  ${PASS} Dux"
elif [[ "$MODE" != "check" ]] && command -v gh &>/dev/null; then
    echo -e "  ${INFO} Cloning Dux (simulation engine)..."
    gh repo clone garygao7272/Dux "$WORKING_DIR/Dux" -- --quiet 2>/dev/null && echo -e "  ${PASS} Dux (cloned)" && ((INSTALLED++)) || { echo -e "  ${WARN} Dux: clone failed (check repo access)"; ((WARNINGS++)); }
else
    echo -e "  ${WARN} Dux: not found — clone with: gh repo clone garygao7272/Dux \"$WORKING_DIR/Dux\""; ((WARNINGS++))
fi

# MiroFish — backtesting engine
if [[ -d "$WORKING_DIR/MiroFish" ]]; then
    echo -e "  ${PASS} MiroFish"
elif [[ "$MODE" != "check" ]] && command -v gh &>/dev/null; then
    echo -e "  ${INFO} Cloning MiroFish (backtesting engine)..."
    gh repo clone garygao7272/MiroFish "$WORKING_DIR/MiroFish" -- --quiet 2>/dev/null && echo -e "  ${PASS} MiroFish (cloned)" && ((INSTALLED++)) || { echo -e "  ${WARN} MiroFish: clone failed (check repo access)"; ((WARNINGS++)); }
else
    echo -e "  ${WARN} MiroFish: not found — clone with: gh repo clone garygao7272/MiroFish \"$WORKING_DIR/MiroFish\""; ((WARNINGS++))
fi

# ════════════════════════════════════════════════════════════════
# PHASE 3: Toolkit MCP Servers
# ════════════════════════════════════════════════════════════════
echo -e "\n${CYAN}3. Toolkit MCP Servers${NC}"

for mcp_dir in hyperliquid-mcp spec-rag-mcp sources-mcp; do
    if [[ -d "$TOOLKIT/$mcp_dir" ]]; then
        echo -e "  ${PASS} $mcp_dir"
    elif [[ -d "$GOS_DIR/toolkit/$mcp_dir" && "$MODE" != "check" ]]; then
        cp -R "$GOS_DIR/toolkit/$mcp_dir" "$TOOLKIT/"
        echo -e "  ${INFO} Installed $mcp_dir"; ((INSTALLED++))
    else
        echo -e "  ${FAIL} $mcp_dir: missing"; ((ERRORS++))
    fi
done

[[ -f "$TOOLKIT/stitch-proxy.mjs" ]] && echo -e "  ${PASS} stitch-proxy" || {
    [[ -f "$GOS_DIR/toolkit/stitch-proxy.mjs" && "$MODE" != "check" ]] && cp "$GOS_DIR/toolkit/stitch-proxy.mjs" "$TOOLKIT/" && echo -e "  ${INFO} Installed stitch-proxy" || echo -e "  ${WARN} stitch-proxy: missing"; ((WARNINGS++))
}

[[ -d "$TOOLKIT/hyperliquid-mcp/node_modules" ]] && echo -e "  ${PASS} hyperliquid deps" || {
    [[ -f "$TOOLKIT/hyperliquid-mcp/package.json" && "$MODE" != "check" ]] && install_cmd "hyperliquid deps" "(cd '$TOOLKIT/hyperliquid-mcp' && npm install --quiet 2>/dev/null)" || { echo -e "  ${WARN} hyperliquid deps: missing"; ((WARNINGS++)); }
}

# ════════════════════════════════════════════════════════════════
# PHASE 4: Python Environments
# ════════════════════════════════════════════════════════════════
echo -e "\n${CYAN}4. Python Environments${NC}"

for venv_name in spec-rag-env sources-env notte-env; do
    mcp_name="${venv_name%-env}-mcp"
    if [[ -d "$TOOLKIT/$venv_name" && -x "$TOOLKIT/$venv_name/bin/python" ]]; then
        echo -e "  ${PASS} $venv_name"
    elif [[ "$MODE" != "check" ]]; then
        python3 -m venv "$TOOLKIT/$venv_name"
        req_found=""
        for req_path in "$TOOLKIT/$mcp_name/requirements.txt" "$GOS_DIR/toolkit/$mcp_name/requirements.txt"; do
            if [[ -f "$req_path" ]]; then
                "$TOOLKIT/$venv_name/bin/pip" install -q -r "$req_path"
                req_found="$req_path"
                break
            fi
        done
        if [[ -z "$req_found" ]]; then
            echo -e "  ${FAIL} $venv_name: requirements.txt missing (checked $TOOLKIT/$mcp_name and $GOS_DIR/toolkit/$mcp_name)"; ((ERRORS++))
        else
            echo -e "  ${PASS} $venv_name (created)"; ((INSTALLED++))
        fi
    else
        echo -e "  ${FAIL} $venv_name: missing"; ((ERRORS++))
    fi
done

# ════════════════════════════════════════════════════════════════
# PHASE 5: Global Install (--global mode)
# ════════════════════════════════════════════════════════════════
if [[ "$MODE" == "global" ]]; then
    echo -e "\n${CYAN}${BOLD}5. Global Install → ~/.claude/${NC}"

    mkdir -p "$CLAUDE_HOME/commands" "$CLAUDE_HOME/agents" "$CLAUDE_HOME/rules" "$CLAUDE_HOME/hooks"

    # CLAUDE.md — the co-creation pact
    echo -e "  ${CYAN}CLAUDE.md${NC}"
    if [[ -f "$GOS_DIR/templates/global-CLAUDE.md" ]]; then
        cp "$GOS_DIR/templates/global-CLAUDE.md" "$CLAUDE_HOME/CLAUDE.md"
        echo -e "    ${PASS} CLAUDE.md (co-creation pact)"
    else
        echo -e "    ${FAIL} templates/global-CLAUDE.md not found"; ((ERRORS++))
    fi

    # invariants.md — falsifiable global rules (INV-G01..G16)
    echo -e "  ${CYAN}invariants.md${NC}"
    if [[ -f "$GOS_DIR/invariants.md" ]]; then
        cp "$GOS_DIR/invariants.md" "$CLAUDE_HOME/invariants.md"
        echo -e "    ${PASS} invariants.md (global invariants)"
    else
        echo -e "    ${FAIL} invariants.md not found in gOS repo"; ((ERRORS++))
    fi

    # Commands
    echo -e "  ${CYAN}Commands${NC}"
    for f in "$GOS_DIR"/commands/*.md; do
        [[ -f "$f" ]] || continue
        cp "$f" "$CLAUDE_HOME/commands/"
        echo -e "    ${PASS} $(basename "$f")"
    done

    # Agents
    echo -e "  ${CYAN}Agents${NC}"
    for f in "$GOS_DIR"/agents/*.md; do
        [[ -f "$f" ]] || continue
        cp "$f" "$CLAUDE_HOME/agents/"
        echo -e "    ${PASS} $(basename "$f")"
    done

    # Skills
    echo -e "  ${CYAN}Skills${NC}"
    for skill_dir in "$GOS_DIR"/skills/*/; do
        [[ -d "$skill_dir" ]] || continue
        name=$(basename "$skill_dir")
        mkdir -p "$CLAUDE_HOME/skills/$name"
        cp "$skill_dir"* "$CLAUDE_HOME/skills/$name/" 2>/dev/null
        echo -e "    ${PASS} $name"
    done

    # Rules
    echo -e "  ${CYAN}Rules${NC}"
    for rule_dir in "$GOS_DIR"/rules/*/; do
        [[ -d "$rule_dir" ]] || continue
        name=$(basename "$rule_dir")
        mkdir -p "$CLAUDE_HOME/rules/$name"
        cp -R "$rule_dir"* "$CLAUDE_HOME/rules/$name/" 2>/dev/null
        echo -e "    ${PASS} rules/$name/"
    done
    for f in "$GOS_DIR"/rules/*.md; do
        [[ -f "$f" ]] || continue
        cp "$f" "$CLAUDE_HOME/rules/"
        echo -e "    ${PASS} rules/$(basename "$f")"
    done

    # Hooks
    echo -e "  ${CYAN}Hooks${NC}"
    mkdir -p "$CLAUDE_HOME/hooks"
    for f in "$GOS_DIR"/.claude/hooks/*; do
        [[ -f "$f" ]] || continue
        cp "$f" "$CLAUDE_HOME/hooks/"
        chmod +x "$CLAUDE_HOME/hooks/$(basename "$f")" 2>/dev/null
        echo -e "    ${PASS} $(basename "$f")"
    done

    # Claws — persistent scheduled agents (source-monitor, spec-drift, market-regime)
    echo -e "  ${CYAN}Claws${NC}"
    if [[ -d "$GOS_DIR/claws" ]]; then
        mkdir -p "$CLAUDE_HOME/claws"
        for claw_dir in "$GOS_DIR"/claws/*/; do
            [[ -d "$claw_dir" ]] || continue
            name=$(basename "$claw_dir")
            mkdir -p "$CLAUDE_HOME/claws/$name"
            cp -R "$claw_dir"* "$CLAUDE_HOME/claws/$name/" 2>/dev/null
            echo -e "    ${PASS} claws/$name"
        done
    else
        echo -e "    ${WARN} claws/ dir not found in gOS repo"; ((WARNINGS++))
    fi

    # Settings — MERGE hooks into existing settings.json (don't overwrite plugins/env)
    echo -e "  ${CYAN}Settings${NC}"
    if [[ -f "$GOS_DIR/settings/settings.json" ]]; then
        if [[ -f "$CLAUDE_HOME/settings.json" ]]; then
            cp "$CLAUDE_HOME/settings.json" "$CLAUDE_HOME/settings.json.bak"
            # Merge: take hooks from gOS template, keep everything else from existing
            python3 -c "
import json, sys
with open('$CLAUDE_HOME/settings.json') as f:
    live = json.load(f)
with open('$GOS_DIR/settings/settings.json') as f:
    template = json.load(f)
# Merge hooks from template into live
live['hooks'] = template.get('hooks', {})
# Ensure PATH includes ~/.local/bin for uvx
env = live.setdefault('env', {})
if 'PATH' not in env or '.local/bin' not in env.get('PATH', ''):
    import os
    env['PATH'] = os.path.expanduser('~/.local/bin') + ':/opt/homebrew/bin:/opt/homebrew/sbin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin'
with open('$CLAUDE_HOME/settings.json', 'w') as f:
    json.dump(live, f, indent=4)
" 2>/dev/null && echo -e "    ${PASS} settings.json (hooks merged)" || {
                echo -e "    ${WARN} Python merge failed — falling back to overwrite"
                cp "$GOS_DIR/settings/settings.json" "$CLAUDE_HOME/settings.json"
                echo -e "    ${PASS} settings.json (overwritten)"
            }
        else
            cp "$GOS_DIR/settings/settings.json" "$CLAUDE_HOME/settings.json"
            echo -e "    ${PASS} settings.json (new install)"
        fi
    fi

    # Workspace CLAUDE.md (if workspace dir exists and no CLAUDE.md there)
    if [[ -d "$WORKING_DIR" && ! -f "$WORKING_DIR/CLAUDE.md" ]]; then
        if [[ -f "$GOS_DIR/templates/workspace-CLAUDE.md" ]]; then
            cp "$GOS_DIR/templates/workspace-CLAUDE.md" "$WORKING_DIR/CLAUDE.md"
            echo -e "    ${PASS} Workspace CLAUDE.md → $(basename "$WORKING_DIR")/"
        fi
    elif [[ -f "$WORKING_DIR/CLAUDE.md" ]]; then
        echo -e "    ${WARN} Workspace CLAUDE.md exists — skipped"
    fi

    # Verification
    echo -e "\n  ${CYAN}${BOLD}Verification${NC}"
    G_CMD=$(find "$CLAUDE_HOME/commands" -name '*.md' 2>/dev/null | wc -l | tr -d ' ')
    G_AGT=$(find "$CLAUDE_HOME/agents" -name '*.md' 2>/dev/null | wc -l | tr -d ' ')
    G_SKL=$(find "$CLAUDE_HOME/skills" -maxdepth 2 -name 'SKILL.md' 2>/dev/null | wc -l | tr -d ' ')
    G_HOK=$(find "$CLAUDE_HOME/hooks" -name '*.sh' 2>/dev/null | wc -l | tr -d ' ')
    G_CLW=$(find "$CLAUDE_HOME/claws" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | wc -l | tr -d ' ')

    for f in "CLAUDE.md" "invariants.md" "settings.json" "commands/gos.md" "agents/README.md"; do
        [[ -f "$CLAUDE_HOME/$f" ]] && echo -e "    ${PASS} $f" || { echo -e "    ${FAIL} $f"; ((ERRORS++)); }
    done
    # Verify hooks are executable (any hook missing +x breaks runtime silently)
    UNEXEC=$(find "$CLAUDE_HOME/hooks" -name '*.sh' ! -perm -u+x 2>/dev/null | wc -l | tr -d ' ')
    [[ "$UNEXEC" == "0" ]] && echo -e "    ${PASS} all hooks executable" || { echo -e "    ${WARN} $UNEXEC hook(s) missing +x"; ((WARNINGS++)); }
    echo -e "\n  ${BOLD}Global:${NC} ${G_CMD} commands, ${G_AGT} agents, ${G_SKL} skills, ${G_HOK} hooks, ${G_CLW} claws"
fi

# ════════════════════════════════════════════════════════════════
# PHASE 6: Bootstrap Project (--bootstrap mode — lean)
# ════════════════════════════════════════════════════════════════
if [[ "$MODE" == "bootstrap" ]]; then
    echo -e "\n${CYAN}${BOLD}5. Bootstrap — Wire gOS into Project (lean)${NC}"

    # Check global install exists
    if [[ ! -f "$CLAUDE_HOME/CLAUDE.md" ]]; then
        echo -e "  ${WARN} Global gOS not installed. Running --global first..."
        "$0" --global
        echo -e "\n${CYAN}${BOLD}Continuing bootstrap...${NC}"
    fi

    if [[ -z "$TARGET_DIR" ]]; then
        echo -e "\n  Where is your project?"
        echo -e "  ${DIM}Example: $WORKING_DIR/Arx${NC}"
        echo -en "  ${BOLD}Project dir:${NC} "
        read -r TARGET_DIR
    fi

    TARGET_DIR="${TARGET_DIR/#\~/$HOME}"
    mkdir -p "$TARGET_DIR"
    echo -e "  ${INFO} Target: $TARGET_DIR\n"

    # Project CLAUDE.md (template — user customizes)
    echo -e "  ${CYAN}Project Files${NC}"
    if [[ ! -f "$TARGET_DIR/CLAUDE.md" ]]; then
        cp "$GOS_DIR/project-template/CLAUDE.md" "$TARGET_DIR/CLAUDE.md"
        echo -e "    ${PASS} CLAUDE.md (template — customize this)"
    else
        echo -e "    ${WARN} CLAUDE.md exists — skipped"
    fi

    # Project .claude/ — settings override only (no commands/agents/skills — those are global)
    mkdir -p "$TARGET_DIR/.claude/rules"
    if [[ ! -f "$TARGET_DIR/.claude/settings.json" ]]; then
        cat > "$TARGET_DIR/.claude/settings.json" << 'SETTINGS'
{
  "respectGitignore": true,
  "enableAllProjectMcpServers": true,
  "env": {
    "CLAUDE_AUTOCOMPACT_PCT_OVERRIDE": "80"
  },
  "permissions": {
    "allow": [
      "Edit(*)",
      "Write(*)",
      "Bash",
      "WebFetch(domain:*)",
      "WebSearch",
      "mcp__*"
    ],
    "deny": []
  }
}
SETTINGS
        echo -e "    ${PASS} .claude/settings.json (project overrides)"
    else
        echo -e "    ${WARN} .claude/settings.json exists — skipped"
    fi

    # .mcp.json
    echo -e "  ${CYAN}.mcp.json${NC}"
    if [[ -f "$GOS_DIR/toolkit/mcp-template.json" ]]; then
        sed "s|__TOOLKIT__|$TOOLKIT|g" "$GOS_DIR/toolkit/mcp-template.json" > "$TARGET_DIR/.mcp.json"
        echo -e "    ${PASS} .mcp.json (paths resolved to $TOOLKIT)"
    fi

    # Directory structure
    echo -e "  ${CYAN}Directories${NC}"
    for dir in specs outputs/think/research outputs/think/discover outputs/think/design outputs/think/decide outputs/briefings outputs/gos-jobs apps sessions Archive; do
        mkdir -p "$TARGET_DIR/$dir"
    done
    echo -e "    ${PASS} project directories created"

    # Session state files
    [[ -f "$TARGET_DIR/sessions/scratchpad.md" ]] || echo "# Session State" > "$TARGET_DIR/sessions/scratchpad.md"
    [[ -f "$TARGET_DIR/sessions/evolve_signals.md" ]] || echo "# Evolve Signals" > "$TARGET_DIR/sessions/evolve_signals.md"
    echo -e "    ${PASS} session files"

    # Verification
    echo -e "\n  ${CYAN}${BOLD}Verification${NC}"
    for f in "CLAUDE.md" ".claude/settings.json" ".mcp.json"; do
        [[ -f "$TARGET_DIR/$f" ]] && echo -e "    ${PASS} $f" || { echo -e "    ${FAIL} $f"; ((ERRORS++)); }
    done

    # Check global is in place
    echo -e "\n  ${CYAN}Global (shared via ~/.claude/)${NC}"
    G_CMD=$(find "$CLAUDE_HOME/commands" -name '*.md' 2>/dev/null | wc -l | tr -d ' ')
    G_AGT=$(find "$CLAUDE_HOME/agents" -name '*.md' 2>/dev/null | wc -l | tr -d ' ')
    G_SKL=$(find "$CLAUDE_HOME/skills" -maxdepth 2 -name 'SKILL.md' 2>/dev/null | wc -l | tr -d ' ')
    echo -e "    ${PASS} ${G_CMD} commands, ${G_AGT} agents, ${G_SKL} skills (global)"
fi

# ════════════════════════════════════════════════════════════════
# Summary + Guided Manual Steps
# ════════════════════════════════════════════════════════════════
echo -e "\n${CYAN}${BOLD}═══ Summary ═══${NC}"

if [[ "$MODE" == "global" ]]; then
    echo -e "${GREEN}${BOLD}Global install complete.${NC} gOS is in ~/.claude/"
    echo ""
    echo -e "  Next: ${CYAN}./install.sh --bootstrap <project-dir>${NC} to wire up a project."
    echo -e "  Or:   ${CYAN}cd <project-dir> && claude${NC} — gOS is already available globally."
    echo ""
elif [[ "$MODE" == "bootstrap" ]]; then
    echo -e "${GREEN}${BOLD}Bootstrap complete.${NC} Project: ${TARGET_DIR}"
    echo ""
    echo -e "${CYAN}${BOLD}Next Steps${NC}"
    echo ""
    echo -e "${BOLD}1. Connect Claude Code Plugins${NC}"
    echo "    claude"
    echo "    /mcp                    # Connect: Figma, Vercel, Linear, etc."
    echo ""
    echo -e "${BOLD}2. Set API Keys${NC} (add to ~/.zshrc)"
    echo "    export GITHUB_TOKEN=\"ghp_your_token_here\""
    echo "    # Optional: DISCORD_TOKEN, TELEGRAM_API_ID, NOTTE_API_KEY, etc."
    echo ""
    echo -e "${BOLD}3. Customize Project CLAUDE.md${NC}"
    echo "    Edit ${TARGET_DIR}/CLAUDE.md with project-specific content."
    echo "    Add project-specific .claude/rules/ files as needed."
    echo ""
    echo -e "${BOLD}4. Verify${NC}"
    echo "    cd ${TARGET_DIR} && claude"
    echo "    /gos              # Should show briefing"
    echo "    /gos status       # Should show all green"
    echo ""
elif [[ $ERRORS -eq 0 && $WARNINGS -eq 0 ]]; then
    echo -e "${GREEN}All checks passed. gOS is ready.${NC}"
elif [[ $ERRORS -eq 0 ]]; then
    echo -e "${YELLOW}${WARNINGS} warnings, 0 errors. gOS should work.${NC}"
else
    echo -e "${RED}${ERRORS} errors, ${WARNINGS} warnings.${NC}"
    echo -e "Run ${CYAN}./install.sh --global${NC} to install globally, or ${CYAN}./install.sh --install${NC} for tools only."
fi

echo ""
