#!/bin/bash
# ═══════════════════════════════════════════════════════════
# God System — New Project Bootstrap
# Creates a new project directory with the full Writ system.
# Usage: ./new-project.sh <project-name> [project-dir]
# ═══════════════════════════════════════════════════════════

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
TEMPLATES="$SCRIPT_DIR/templates"
PROJECT_NAME="${1:-}"

if [ -z "$PROJECT_NAME" ]; then
    echo "Usage: ./new-project.sh <project-name> [parent-dir]"
    echo ""
    echo "Examples:"
    echo "  ./new-project.sh my-saas-app"
    echo "  ./new-project.sh trading-bot ~/Projects"
    echo ""
    echo "This creates a project directory with the God/Writ system pre-configured."
    exit 1
fi

PARENT_DIR="${2:-$(pwd)}"
PROJECT_DIR="$PARENT_DIR/$PROJECT_NAME"

if [ -d "$PROJECT_DIR" ]; then
    echo "ERROR: Directory already exists: $PROJECT_DIR"
    echo "Use restore.sh for existing projects."
    exit 1
fi

echo "═══ God System — New Project ═══"
echo "Project: $PROJECT_NAME"
echo "Location: $PROJECT_DIR"
echo ""

# ─── 1. Create directory structure ────────────────────────
echo "→ Creating project structure..."

mkdir -p "$PROJECT_DIR"/{.claude/commands,specs,sessions,outputs,tools,apps}

# ─── 2. Install GOD.md ───────────────────────────────────
echo "→ Installing GOD.md (soul file)..."

if [ -f "$TEMPLATES/GOD.md" ]; then
    cp "$TEMPLATES/GOD.md" "$PROJECT_DIR/.claude/GOD.md"
else
    echo "  WARNING: No GOD.md template found at $TEMPLATES/GOD.md"
fi

# ─── 3. Install Writ commands ────────────────────────────
echo "→ Installing Writ commands..."

if [ -d "$TEMPLATES/commands" ]; then
    cp "$TEMPLATES/commands/"*.md "$PROJECT_DIR/.claude/commands/"
    echo "  Installed $(ls "$PROJECT_DIR/.claude/commands/"*.md | wc -l | tr -d ' ') commands."
else
    echo "  WARNING: No command templates found at $TEMPLATES/commands/"
fi

# ─── 3b. Install Skills ────────────────────────────────
echo "→ Installing skills..."

if [ -d "$TEMPLATES/skills" ]; then
    for skilldir in "$TEMPLATES/skills/"*/; do
        [ -d "$skilldir" ] || continue
        skillname=$(basename -- "$skilldir")
        mkdir -p "$PROJECT_DIR/.claude/skills/$skillname"
        cp "$skilldir"*.md "$PROJECT_DIR/.claude/skills/$skillname/" 2>/dev/null || true
    done
    echo "  Installed $(ls -d "$PROJECT_DIR/.claude/skills/"*/ 2>/dev/null | wc -l | tr -d ' ') skills."
else
    echo "  No skill templates found at $TEMPLATES/skills/"
fi

# ─── 4. Create CLAUDE.md from template ───────────────────
echo "→ Creating CLAUDE.md..."

if [ -f "$TEMPLATES/CLAUDE.template.md" ]; then
    # Replace placeholder with actual project name
    sed "s/{{PROJECT_NAME}}/$PROJECT_NAME/g" "$TEMPLATES/CLAUDE.template.md" > "$PROJECT_DIR/CLAUDE.md"
else
    cat > "$PROJECT_DIR/CLAUDE.md" << EOF
# ${PROJECT_NAME} — Project Instructions

## What Is ${PROJECT_NAME}

<!-- Describe your project here -->

## Project Structure

\`\`\`
${PROJECT_NAME}/
├── CLAUDE.md          ← YOU ARE HERE
├── .claude/
│   ├── GOD.md         ← God's soul file
│   └── commands/      ← The Writ (9 commands)
├── specs/             ← Product specs
├── apps/              ← Buildable projects
├── tools/             ← Custom MCP servers
├── sessions/          ← Session tracking
└── outputs/           ← Generated outputs
\`\`\`

## The Writ

God's command set. See \`.claude/GOD.md\` for the full definition.

| Command | Purpose |
|---------|---------|
| \`/god\` | Start session, get briefing, route to mode |
| \`/think\` | Product thinking: discover, design, research, decide, spec |
| \`/build\` | Implementation: prototype, feature, component, test, deploy |
| \`/judge\` | Review: user personas, specialist personas, full-council |
| \`/schedule\` | Automation: recurring agents on cron |
| \`/coordinate\` | Parallel sessions: claim, handoff, merge |
| \`/evolve\` | Self-improvement: audit, upgrade, learn, reflect |
| \`/prototype\` | Quick prototype shortcut |
| \`/verify-app\` | Verify it works |

## Version Control

- Never delete files — archive or let git track
- Commit after every meaningful change
- Use Edit tool over Write tool (smaller diffs)
EOF
fi

# ─── 5. Create MCP config ────────────────────────────────
echo "→ Creating MCP config..."

if [ -f "$TEMPLATES/.mcp.template.json" ]; then
    cp "$TEMPLATES/.mcp.template.json" "$PROJECT_DIR/.mcp.json"
else
    cat > "$PROJECT_DIR/.mcp.json" << 'EOF'
{
  "mcpServers": {
    "playwright": {
      "command": "npx",
      "args": [
        "@playwright/mcp@latest",
        "--browser", "chrome",
        "--headless"
      ]
    }
  }
}
EOF
fi

# ─── 6. Create .gitignore ────────────────────────────────
echo "→ Creating .gitignore..."

if [ -f "$TEMPLATES/.gitignore.template" ]; then
    cp "$TEMPLATES/.gitignore.template" "$PROJECT_DIR/.gitignore"
else
    cat > "$PROJECT_DIR/.gitignore" << 'EOF'
# Dependencies
node_modules/
*.pyc
__pycache__/

# Virtual environments
tools/*-env/

# Build outputs
.vercel/
.next/
dist/
build/

# Vector DB (regenerable)
.lancedb/

# Session working memory (ephemeral)
sessions/scratchpad.md

# OS files
.DS_Store
Thumbs.db

# Environment (secrets)
.env
.env.local
*.env

# Editor
.vscode/
.idea/

# Lock files (from MCP tools)
*.lock.tmp
EOF
fi

# ─── 7. Create specs index ───────────────────────────────
echo "→ Creating specs index..."

cat > "$PROJECT_DIR/specs/INDEX.md" << EOF
# ${PROJECT_NAME} — Specs Index

> Quick lookup for all product specs. Start here when you need context.

## Spec Files

<!-- Add spec files as you create them -->

| ID | Name | Altitude | Status |
|----|------|----------|--------|
| — | (no specs yet) | — | — |

## How to Add Specs

Use the naming convention: \`${PROJECT_NAME}_{Group}-{Artifact}_{Slug}.md\`

| Group | Altitude | What Goes Here |
|-------|----------|----------------|
| 1 | 30,000 ft | Foundation — vision, strategy, business model |
| 2 | 20,000 ft | Market intel — research, competitors |
| 3 | 10,000 ft | Product — roadmap, PRD, journeys |
| 4 | 5,000 ft | Design — design system, screen specs |
| 5 | 1,000 ft | Engineering — architecture, data model |
| 6 | Ground | Execution — MVP blueprint |
| 7 | Ground | Operations — metrics |
| 9 | Lateral | Governance — decisions, hypotheses |
EOF

# ─── 8. Create session management ────────────────────────
echo "→ Setting up sessions..."

cat > "$PROJECT_DIR/sessions/active.md" << 'EOF'
# Active Sessions

| ID | Mode | Worktree | Files Owned | Started | Notes |
|----|------|----------|-------------|---------|-------|
EOF

# ─── 9. Create local settings ────────────────────────────
echo "→ Creating local settings..."

cat > "$PROJECT_DIR/.claude/settings.local.json" << 'EOF'
{
  "permissions": {
    "allow": [
      "Bash(npm run *)",
      "Bash(npx *)",
      "Bash(git *)",
      "Bash(ls *)",
      "Bash(mkdir *)",
      "Bash(cat *)"
    ]
  }
}
EOF

# ─── 10. Initialize git ──────────────────────────────────
echo "→ Initializing git..."

cd "$PROJECT_DIR"
git init --quiet
git add -A
git commit -m "feat: bootstrap project with God/Writ system" --quiet

# ─── Done ─────────────────────────────────────────────────
echo ""
echo "═══ Project Created ═══"
echo ""
echo "  $PROJECT_DIR/"
echo "  ├── .claude/GOD.md        ← Soul file"
echo "  ├── .claude/commands/     ← 10 Writ commands"
echo "  ├── .claude/skills/       ← Design & build skills"
echo "  ├── CLAUDE.md             ← Edit with project details"
echo "  ├── .mcp.json             ← Add MCP servers you need"
echo "  ├── specs/                ← Product specs"
echo "  ├── apps/                 ← Your code"
echo "  └── sessions/             ← Session tracking"
echo ""
echo "Next steps:"
echo "  1. cd $PROJECT_DIR"
echo "  2. Edit CLAUDE.md with your project details"
echo "  3. Edit .mcp.json to add MCP servers you need"
echo "  4. claude"
echo "  5. /god"
