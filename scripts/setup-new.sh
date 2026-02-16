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
Your job is to EXECUTE the setup — install MCPs, install plugins, create config files.
Only leave things for the user that genuinely require human action (account creation, API keys).

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

PHASE 4 - Execute setup:
6. Based on the merged recommendations, GENERATE these files:
   a. .claude/CLAUDE.md - Project-specific rules, stack config, workflow rules
   b. .claude/settings.json - Hooks (auto-test if production, auto-format, skill-loader)

7. INSTALL local MCPs by running \`claude mcp add\` commands via the Bash tool.
   - Use LOCAL scope (the default — do NOT use --scope user)
   - Each project gets its own MCP instances — never install project-specific MCPs globally
   - Before configuring any MCP, use Context7 and/or web search to verify the CURRENT
     recommended setup. For example, Supabase now recommends publishable keys
     (sb_publishable_...) over legacy anon JWT keys for new apps. Always use what the
     official docs currently recommend — never hardcode legacy patterns.
   - For MCPs that need API keys or credentials found in .env, use those values
   - For MCPs that need API keys NOT found in .env, skip and add to TODO (Phase 5)

8. INSTALL local plugins by running the appropriate install commands.
   - If production: install superpowers plugin
   - If optional tools selected: install those plugins
   - Only install per-project plugins — global plugins are already installed

PHASE 5 - Generate MANUAL TODO:
9. After completing all automated setup, output a MANUAL TODO checklist of steps
   only the user can do. For each item, explain WHY they need to do it and WHAT
   to come back with. Handle the case where the user selected services in the
   questionnaire but may not have accounts yet. Examples:
   - 'You selected Supabase but no SUPABASE_URL was found. Go to supabase.com,
     create a project, then come back and give me the project URL and publishable key.'
   - 'You selected Stripe but no STRIPE_SECRET_KEY was found. Go to
     dashboard.stripe.com/apikeys, get your API keys, then come back and I will
     configure the Stripe MCP.'
   - 'Open Claude Code and run /mcp to complete Sentry OAuth'
   If the user already has accounts/keys (detected in .env), skip those TODOs.
   If there are NO manual steps needed, say 'All set! No manual steps required.'

10. Provide a complete summary of everything that was set up automatically.

IMPORTANT:
- Global plugins are ALREADY installed (security-guidance, typescript-lsp, pyright-lsp,
  frontend-design, code-review, commit-commands, feature-dev, pr-review-toolkit,
  claude-md-management, playwright, claude-code-setup, coderabbit)
- Global MCPs are ALREADY installed (Context7, Sentry)
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
