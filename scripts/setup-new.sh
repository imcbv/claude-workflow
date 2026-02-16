#!/bin/bash
# =============================================================================
# New Project Setup
# Run this in the root of a new project to set up Claude Code configuration.
# =============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"

echo ""
echo "=================================================="
echo "  Claude Code - New Project Setup"
echo "=================================================="
echo ""

# Check we're in a project directory
if [ "$PWD" = "$HOME" ]; then
  echo "  ERROR: Don't run this from your home directory."
  echo "  cd into your project first, then run this script."
  exit 1
fi

PROJECT_DIR="$PWD"
PROJECT_NAME=$(basename "$PROJECT_DIR")

echo "  Project: $PROJECT_NAME"
echo "  Path:    $PROJECT_DIR"
echo ""

# -----------------------------------------------------------------------------
# Questionnaire
# -----------------------------------------------------------------------------
echo "--- Quick Questions ---"
echo ""

# Project type
echo "  1. What type of project is this?"
echo "     a) Production app (needs tests, code review, TDD)"
echo "     b) MVP / prototype (speed over quality)"
echo "     c) Internal tool (moderate quality)"
echo ""
read -p "     Choice [a/b/c]: " PROJECT_TYPE
echo ""

# Tech stack
echo "  2. What's the tech stack? (comma-separated)"
echo "     Examples: next.js, react, django, fastapi, node, deno,"
echo "              react-native, expo, capacitor, express, nestjs, strapi"
echo ""
read -p "     Stack: " TECH_STACK
echo ""

# Database
echo "  3. Database? (comma-separated, or 'none')"
echo "     Options: supabase, postgresql, mongodb, firebase, redis, sqlite"
echo ""
read -p "     Database: " DATABASE
echo ""

# Deployment
echo "  4. Deployment platform? (comma-separated, or 'none')"
echo "     Options: vercel, render, fly.io, railway, aws, netlify, docker"
echo ""
read -p "     Deploy to: " DEPLOYMENT
echo ""

# Payments
echo "  5. Payment system? (or 'none')"
echo "     Options: stripe, other, none"
echo ""
read -p "     Payments: " PAYMENTS
echo ""

# Optional tools
echo "  6. Which of these apply? (comma-separated, or 'none')"
echo "     figma      - You'll use Figma designs"
echo "     firecrawl  - Need web scraping/research"
echo "     slack      - Collaborate with team via Slack"
echo "     gitlab     - Project uses GitLab (not GitHub)"
echo "     pinecone   - Vector search / RAG features"
echo "     posthog    - PostHog analytics"
echo "     notion     - Pull specs from Notion"
echo "     docker     - Project uses Docker containers"
echo ""
read -p "     Optional tools: " OPTIONAL_TOOLS
echo ""

# Git repo
if [ -d ".git" ]; then
  echo "  Git repo detected."
else
  read -p "  Initialize git repo? [y/n]: " INIT_GIT
  if [ "$INIT_GIT" = "y" ]; then
    git init
    echo "  Git repo initialized."
  fi
  echo ""
fi

# -----------------------------------------------------------------------------
# Build the prompt
# -----------------------------------------------------------------------------
echo ""
echo "--- Setting up project with Claude Code ---"
echo ""

# Map project type
case "$PROJECT_TYPE" in
  a|A) TYPE_DESC="Production app (full TDD, code review, strict quality)" ;;
  b|B) TYPE_DESC="MVP/prototype (speed over quality, minimal testing)" ;;
  c|C) TYPE_DESC="Internal tool (moderate quality, basic testing)" ;;
  *)   TYPE_DESC="Production app" ;;
esac

PROMPT="You are setting up Claude Code for a new project. Follow the workflow in the setup guide.

PROJECT DETAILS:
- Name: $PROJECT_NAME
- Path: $PROJECT_DIR
- Type: $TYPE_DESC
- Tech Stack: $TECH_STACK
- Database: $DATABASE
- Deployment: $DEPLOYMENT
- Payments: $PAYMENTS
- Optional Tools: $OPTIONAL_TOOLS

YOUR TASKS:

PHASE 1 - Your analysis:
1. Read the setup guide: $REPO_DIR/APPLY-SETUP.md
2. Read the architecture guide: $REPO_DIR/ARCHITECTURE.md
3. Based on the project details above, create your own recommendations for:
   - Which local MCPs to install
   - Which local plugins to install
   - What hooks to enable
   - CLAUDE.md content

PHASE 2 - Plugin second opinion:
4. Run the claude-code-setup plugin to get ITS recommendations for this project.
   It will scan the codebase and suggest MCPs, skills, hooks, and subagents.

PHASE 3 - Compare and merge:
5. Compare YOUR recommendations (Phase 1) with the PLUGIN's recommendations (Phase 2).
   Show me both side by side. For any differences:
   - Explain what each side recommends and why
   - Pick the better recommendation (or merge both)
   - If the plugin suggests something you missed, include it
   - If you recommend something the plugin didn't catch, include it

PHASE 4 - Generate:
6. Based on the merged recommendations, generate:
   a. .claude/CLAUDE.md - Project-specific rules, stack config, workflow rules
   b. .claude/settings.json - Hooks (auto-test if production, auto-format, skill-loader)
7. List which LOCAL MCPs to install (with exact commands)
8. List which LOCAL plugins to install (with exact commands)
   - If production: recommend superpowers plugin
   - If optional tools selected: recommend those plugins
9. Provide a complete summary of everything set up

IMPORTANT:
- Global plugins are ALREADY installed (security-guidance, typescript-lsp, pyright-lsp,
  frontend-design, code-review, commit-commands, feature-dev, pr-review-toolkit,
  claude-md-management, playwright, claude-code-setup, coderabbit)
- Only install LOCAL/per-project items
- Include workflow rules in CLAUDE.md:
  * Before committing: use /commit
  * Before PRs: run /pr-review-toolkit:review-pr all
  * End of session: run /revise-claude-md
  * New features: use /feature-dev for non-trivial features"

echo "  Launching Claude Code with your project configuration..."
echo "  Claude will generate all config files and give you setup commands."
echo ""

# Launch Claude with the prompt
echo "$PROMPT" | claude
