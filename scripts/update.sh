#!/bin/bash
# =============================================================================
# Update Configuration
# Run this monthly (or whenever) to check if your setup needs updating.
# Researches latest best practices and suggests changes.
# =============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"

echo ""
echo "=================================================="
echo "  Claude Code - Configuration Update Check"
echo "=================================================="
echo ""

# Get last update date from git
LAST_UPDATE=$(cd "$REPO_DIR" && git log -1 --format=%cd --date=short 2>/dev/null || echo "unknown")
TODAY=$(date "+%Y-%m-%d")

echo "  Last update: $LAST_UPDATE"
echo "  Today:       $TODAY"
echo "  Repo:        $REPO_DIR"
echo ""

# Check what context we're in
if [ "$PWD" != "$REPO_DIR" ] && [ -f ".claude/CLAUDE.md" ]; then
  echo "  NOTE: You're in a project directory ($(basename "$PWD"))."
  echo "  This will also check your project-specific config."
  PROJECT_DIR="$PWD"
  PROJECT_NAME=$(basename "$PWD")
  IN_PROJECT="yes"
else
  IN_PROJECT="no"
fi

echo ""
echo "  What this does:"
echo "    1. Researches latest Claude Code best practices (web search)"
echo "    2. Checks your current plugins and MCPs"
echo "    3. Identifies new tools, deprecated practices, breaking changes"
echo "    4. Suggests specific updates with commands"
echo ""
read -p "  Continue? [y/n]: " CONTINUE
if [ "$CONTINUE" != "y" ]; then
  echo "  Aborted."
  exit 0
fi

# -----------------------------------------------------------------------------
# Build the prompt
# -----------------------------------------------------------------------------

PROJECT_CONTEXT=""
if [ "$IN_PROJECT" = "yes" ]; then
  PROJECT_CONTEXT="
ALSO CHECK THIS PROJECT:
- Project: $PROJECT_NAME
- Path: $PROJECT_DIR
- Has .claude/CLAUDE.md: $([ -f .claude/CLAUDE.md ] && echo 'yes' || echo 'no')
- Has .claude/settings.json: $([ -f .claude/settings.json ] && echo 'yes' || echo 'no')

Check if the project's Claude Code config is up to date with current best practices."
fi

PROMPT="You are running a configuration update check for the claude-workflow setup.

CURRENT SETUP:
- Repo: $REPO_DIR
- Last updated: $LAST_UPDATE
- Today: $TODAY
$PROJECT_CONTEXT

YOUR TASKS:

PHASE 1 - Research:
1. Search the web for latest Claude Code developments:
   - 'Claude Code best practices $TODAY'
   - 'Claude Code plugins new $TODAY'
   - 'Claude Code MCP servers new $TODAY'
   - 'Claude Code breaking changes $TODAY'
   - Check if any installed plugins have updates or are deprecated
   - Use /last30days if available for comprehensive research

PHASE 2 - Read current setup:
2. Read the current configuration:
   - $REPO_DIR/ARCHITECTURE.md (current plugin list and config)
   - $REPO_DIR/CORE-SETUP.md (current core setup)
   - $REPO_DIR/UPDATE-WORKFLOW.md (update process)

PHASE 3 - Plugin assessment (if in a project directory):
3. If we're inside a project, run the claude-code-setup plugin to get fresh
   recommendations for THIS project. Compare with the current .claude/CLAUDE.md
   and .claude/settings.json. Flag any gaps or outdated config.

PHASE 4 - Compare and identify changes:
4. Based on research + plugin assessment, identify:
   a. NEW tools/plugins worth adding (with evidence: install count, community feedback)
   b. DEPRECATED tools to remove
   c. CHANGED best practices
   d. BREAKING CHANGES to address
   e. SECURITY updates needed
   f. Project-specific config that's outdated (if in a project)

5. For each finding, provide:
   - What changed
   - Evidence (source, engagement metrics)
   - Specific action (command to run, file to update)
   - Priority (critical / recommended / optional)

PHASE 5 - Recommendations:
6. If NOTHING significant changed, just say:
   'Your setup is current. No updates needed.'
   And explain why (what you checked, when things last changed).

7. If updates ARE needed, provide:
   - Numbered list of changes, grouped by priority
   - Exact commands to run
   - Files to update (with specific edits)
   - Suggest a commit message for the claude-workflow repo
   - If in a project: also suggest project-specific updates

IMPORTANT:
- Only recommend changes backed by evidence (community adoption, official docs)
- Don't suggest changes just for the sake of changing things
- Prioritize security and breaking changes over nice-to-haves
- Always compare your findings with the claude-code-setup plugin's assessment"

echo ""
echo "  Launching Claude Code to check for updates..."
echo "  This may take a few minutes (web research + analysis)."
echo ""

# Launch Claude with the prompt
echo "$PROMPT" | claude
