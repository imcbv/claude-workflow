#!/bin/bash
# =============================================================================
# Existing Project Setup
# Run this in an existing project. Claude analyzes the code and sets up config.
# =============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"

# Sanitize user input: strip characters that could cause issues in prompts
sanitize() { printf '%s' "$1" | tr -d '`$(){}\\'; }

echo ""
echo "=================================================="
echo "  Claude Code - Existing Project Setup"
echo "  Platform: macOS only"
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

# Check for existing Claude config
if [ -f ".claude/CLAUDE.md" ]; then
  echo "  NOTE: .claude/CLAUDE.md already exists."
  read -p "  Overwrite it? [y/n]: " OVERWRITE
  if [ "$OVERWRITE" != "y" ]; then
    echo "  Will merge with existing config instead."
  fi
  echo ""
fi

# -----------------------------------------------------------------------------
# Minimal questionnaire (only things Claude can't detect)
# -----------------------------------------------------------------------------
echo "--- Quick Questions (Claude detects the rest) ---"
echo ""

echo "  1. What type of project is this?"
echo "     a) Production app (needs tests, code review, TDD)"
echo "     b) MVP / prototype (speed over quality)"
echo "     c) Internal tool (moderate quality)"
echo ""
read -p "     Choice [a/b/c]: " PROJECT_TYPE
echo ""

echo "  2. Which of these apply? (comma-separated, or 'none')"
echo "     figma      - You use Figma designs for this project"
echo "     firecrawl  - Need web scraping/research"
echo "     slack      - Collaborate with team via Slack"
echo "     pinecone   - Vector search / RAG features"
echo "     posthog    - PostHog analytics"
echo "     notion     - Pull specs from Notion"
echo "     docker     - Project uses Docker/containers"
echo ""
read -p "     Optional tools: " OPTIONAL_TOOLS
echo ""

# Sanitize user inputs
OPTIONAL_TOOLS=$(sanitize "$OPTIONAL_TOOLS")

# Map project type
case "$PROJECT_TYPE" in
  a|A) TYPE_DESC="Production app (full TDD, code review, strict quality)" ;;
  b|B) TYPE_DESC="MVP/prototype (speed over quality, minimal testing)" ;;
  c|C) TYPE_DESC="Internal tool (moderate quality, basic testing)" ;;
  *)   TYPE_DESC="Production app" ;;
esac

# Check for existing config
HAS_EXISTING="no"
if [ -f ".claude/CLAUDE.md" ] && [ "$OVERWRITE" != "y" ]; then
  HAS_EXISTING="yes"
fi

# -----------------------------------------------------------------------------
# Build the prompt
# -----------------------------------------------------------------------------
echo ""
echo "--- Analyzing project with Claude Code ---"
echo ""

PROMPT="You are setting up Claude Code for an EXISTING project. The code already exists.
Your job is to EXECUTE the setup — install MCPs, install plugins, create config files.
Only leave things for the user that genuinely require human action (account creation, API keys).

PROJECT DETAILS:
- Name: $PROJECT_NAME
- Path: $PROJECT_DIR
- Type: $TYPE_DESC
- Optional Tools: $OPTIONAL_TOOLS
- Has existing .claude/CLAUDE.md: $HAS_EXISTING

YOUR TASKS:

PHASE 1 - Analyze the codebase:
1. Scan the project:
   - Read package.json, requirements.txt, go.mod, Cargo.toml, etc.
   - Detect: frontend framework, backend framework, database, deployment, payments
   - Check for monorepo structure (apps/, packages/, services/)
   - Check .env files for service integrations (Supabase, Stripe, etc.)
   - Check for existing test setup (jest, vitest, pytest, etc.)
   - Check vercel.json, render.yaml, fly.toml, railway.toml, .elasticbeanstalk/
   - Check Dockerfile, docker-compose.yml, .dockerignore
   - Check for queue systems (bullmq in package.json, celery in requirements.txt)
   - Check deno.json, deno.jsonc (Deno projects)

2. SHOW me what you detected:
   - Full stack analysis
   - Services detected
   - Existing test setup
   - Existing Claude Code config (if any)

PHASE 2 - Your recommendations:
3. Read the setup guides:
   - $REPO_DIR/APPLY-SETUP.md
   - $REPO_DIR/ARCHITECTURE.md
4. Based on detected stack + user answers, create YOUR recommendations for:
   - Which local MCPs to install
   - Which local plugins to install
   - What hooks to enable
   - CLAUDE.md content

PHASE 3 - Plugin second opinion:
5. Run the claude-code-setup plugin to get ITS recommendations for this project.
   It will independently scan the codebase and suggest MCPs, skills, hooks, subagents.

PHASE 4 - Compare and merge:
6. Compare YOUR recommendations (Phase 2) with the PLUGIN's recommendations (Phase 3).
   Show me both side by side. For any differences:
   - Explain what each side recommends and why
   - Pick the better recommendation (or merge both)
   - If the plugin suggests something you missed, include it
   - If you recommend something the plugin didn't catch, include it

PHASE 5 - Execute setup:
7. Based on the merged recommendations, GENERATE these files:
   a. .claude/CLAUDE.md - Project-specific rules based on detected stack
   b. .claude/settings.json - Hooks appropriate for this stack
   (If existing config: merge, don't overwrite custom rules)

8. INSTALL local MCPs by running \`claude mcp add\` commands via the Bash tool.
   - Use LOCAL scope (the default — do NOT use --scope user)
   - Each project gets its own MCP instances — never install project-specific MCPs globally
   - Before configuring any MCP, use Context7 and/or web search to verify the CURRENT
     recommended setup. For example, Supabase now recommends publishable keys
     (sb_publishable_...) over legacy anon JWT keys for new apps. Always use what the
     official docs currently recommend — never hardcode legacy patterns.
   - For MCPs that need API keys or credentials found in .env, use those values
   - For MCPs that need API keys NOT found in .env, skip and add to TODO (Phase 6)

9. INSTALL local plugins by running the appropriate install commands.
   - If production: install superpowers plugin
   - If optional tools selected: install those plugins
   - Only install per-project plugins — global plugins are already installed

PHASE 6 - Generate MANUAL TODO:
10. After completing all automated setup, output a MANUAL TODO checklist of steps
    only the user can do. For each item, explain WHY they need to do it and WHAT
    to come back with. Examples:
    - 'Create Supabase account at supabase.com' (if no SUPABASE_URL in .env)
    - 'Get Stripe API keys from dashboard.stripe.com/apikeys' (if Stripe detected but no key in .env)
    - 'Open Claude Code and run /mcp to complete Sentry OAuth'
    - 'Create Sentry project at sentry.io for [app-name]'
    If the user already has accounts/keys (detected in .env), skip those TODOs.
    If there are NO manual steps needed, say 'All set! No manual steps required.'

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

echo "  Launching Claude Code to analyze your project..."
echo "  Claude will detect your stack and generate all config files."
echo ""

# Launch Claude with the prompt
echo "$PROMPT" | claude
