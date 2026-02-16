#!/bin/bash
# =============================================================================
# Claude Code Global Setup
# Run this ONCE on a new machine. Sets up everything globally.
# =============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"

# Auto mode: set CLAUDE_WORKFLOW_AUTO=1 to skip interactive prompts
AUTO="${CLAUDE_WORKFLOW_AUTO:-0}"

echo ""
echo "=================================================="
echo "  Claude Code Global Setup"
echo "  This installs everything you need, once."
echo "  Platform: macOS only"
echo "=================================================="
echo ""

# -----------------------------------------------------------------------------
# Pre-flight: close running Claude Code instances
# -----------------------------------------------------------------------------
CLAUDE_PIDS=$(pgrep -x "claude" 2>/dev/null || true)
if [ -n "$CLAUDE_PIDS" ]; then
  CLAUDE_COUNT=$(echo "$CLAUDE_PIDS" | wc -l | tr -d ' ')
  echo "  Found $CLAUDE_COUNT running Claude Code process(es)."
  echo "  This script installs global MCPs and plugins, which can conflict"
  echo "  with running sessions."
  echo ""
  if [ "$AUTO" = "1" ]; then
    KILL_CLAUDE="y"
  else
    read -p "  Kill all Claude Code instances and continue? [y/n]: " KILL_CLAUDE
  fi
  if [ "$KILL_CLAUDE" = "y" ]; then
    pkill -x "claude" 2>/dev/null || true
    sleep 1
    echo "  [OK] Claude Code instances terminated."
  else
    echo "  Please close them manually and run this script again."
    exit 1
  fi
  echo ""
fi

# -----------------------------------------------------------------------------
# Helper functions
# -----------------------------------------------------------------------------
check_installed() {
  command -v "$1" &> /dev/null
}

ok()   { echo "  [OK] $1"; }
skip() { echo "  [SKIP] $1 (already installed)"; }
fail() { echo "  [FAIL] $1"; }
step() { echo ""; echo "--- $1 ---"; }

# -----------------------------------------------------------------------------
# Step 1: Prerequisites
# -----------------------------------------------------------------------------
step "Step 1/6: Prerequisites"

# Platform check
if [[ "$OSTYPE" != "darwin"* ]]; then
  echo "  ERROR: This script only supports macOS."
  echo "  For Linux, install the dependencies manually."
  exit 1
fi

# Homebrew (macOS)
if [[ "$OSTYPE" == "darwin"* ]]; then
  if check_installed brew; then
    skip "Homebrew"
  else
    echo "  Installing Homebrew..."
    BREW_INSTALLER="/tmp/homebrew-install.sh"
    curl -fsSL --connect-timeout 10 -o "$BREW_INSTALLER" https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh || { fail "Failed to download Homebrew installer"; exit 1; }
    /bin/bash "$BREW_INSTALLER"
    rm -f "$BREW_INSTALLER"
    command -v brew &> /dev/null || { fail "Homebrew not found after install"; exit 1; }
    ok "Homebrew installed"
  fi
fi

# Node.js (>= 18 required for Claude Code npm install)
if check_installed node; then
  NODE_VERSION=$(node --version | tr -d 'v')
  NODE_MAJOR=$(echo "$NODE_VERSION" | cut -d. -f1)
  if [ "$NODE_MAJOR" -lt 18 ]; then
    echo "  Node.js $NODE_VERSION is too old (need >= 18). Upgrading..."
    brew install node
    ok "Node.js upgraded"
  else
    skip "Node.js (v$NODE_VERSION)"
  fi
else
  echo "  Installing Node.js..."
  brew install node
  ok "Node.js installed"
fi

# Python 3 (>= 3.7 required for pyright)
if check_installed python3; then
  skip "Python 3 ($(python3 --version 2>&1))"
else
  echo "  Installing Python 3..."
  brew install python3
  ok "Python 3 installed"
fi

# Git
if check_installed git; then
  skip "Git ($(git --version))"
else
  echo "  Installing Git..."
  brew install git
  ok "Git installed"
fi

# -----------------------------------------------------------------------------
# Step 2: tmux (for parallel worktrees)
# -----------------------------------------------------------------------------
step "Step 2/6: tmux (parallel agents)"

if check_installed tmux; then
  skip "tmux ($(tmux -V))"
else
  echo "  Installing tmux..."
  brew install tmux
  ok "tmux installed"
fi

echo ""
echo "  tmux lets you run multiple Claude agents side by side."
echo "  Quick reference:"
echo "    tmux                    Start tmux"
echo "    Ctrl+B then \"           Split horizontal"
echo "    Ctrl+B then %           Split vertical"
echo "    Ctrl+B then arrow keys  Navigate panes"
echo "    Ctrl+B then d           Detach (keeps running)"
echo "    tmux attach             Reattach"

# -----------------------------------------------------------------------------
# Step 3: Claude Code
# -----------------------------------------------------------------------------
step "Step 3/6: Claude Code"

if check_installed claude; then
  skip "Claude Code (already installed)"
else
  echo "  Installing Claude Code..."
  npm install -g @anthropic-ai/claude-code || { fail "npm install failed"; exit 1; }
  command -v claude &> /dev/null || { fail "claude command not found after install — check your PATH"; exit 1; }
  ok "Claude Code installed"
  echo ""
  echo "  IMPORTANT: Run 'claude' once to authenticate before continuing."
  if [ "$AUTO" != "1" ]; then
    echo "  Press Enter after you've authenticated..."
    read -r
  fi
fi

# Check for updates
echo "  Checking for Claude Code updates..."
CURRENT_VERSION=$(claude --version 2>/dev/null || echo "unknown")
echo "  Current version: $CURRENT_VERSION"
npm outdated -g @anthropic-ai/claude-code 2>/dev/null && echo "  Update available! Run: npm update -g @anthropic-ai/claude-code" || ok "Claude Code is up to date"

# -----------------------------------------------------------------------------
# Step 4: LSP Dependencies
# -----------------------------------------------------------------------------
step "Step 4/6: LSP dependencies"

# TypeScript LSP
if check_installed typescript-language-server; then
  skip "typescript-language-server"
else
  echo "  Installing TypeScript Language Server..."
  npm install -g typescript-language-server typescript
  ok "TypeScript LSP installed"
fi

# Pyright
if python3 -m pyright --version &> /dev/null 2>&1 || check_installed pyright; then
  skip "pyright"
else
  echo "  Installing Pyright..."
  pip3 install pyright
  ok "Pyright installed"
fi

# -----------------------------------------------------------------------------
# Step 5: Global Plugins
# -----------------------------------------------------------------------------
step "Step 5/6: Global Plugins (12 plugins)"

echo ""
echo "  Installing plugins... (this opens Claude Code briefly for each one)"
echo "  Some may already be installed - that's fine."
echo ""

PLUGINS=(
  "security-guidance"
  "typescript-lsp"
  "pyright-lsp"
  "frontend-design"
  "code-review"
  "commit-commands"
  "feature-dev"
  "pr-review-toolkit"
  "claude-md-management"
  "playwright"
  "claude-code-setup"
  "coderabbit"
)

FAILED_PLUGINS=()
for plugin in "${PLUGINS[@]}"; do
  echo "  Installing $plugin..."
  if claude /plugin install "$plugin" 2>/dev/null; then
    ok "$plugin"
  else
    fail "$plugin"
    FAILED_PLUGINS+=("$plugin")
  fi
done

echo ""
SUCCEEDED=$(( ${#PLUGINS[@]} - ${#FAILED_PLUGINS[@]} ))
ok "$SUCCEEDED/${#PLUGINS[@]} plugins installed"

if [ ${#FAILED_PLUGINS[@]} -gt 0 ]; then
  echo ""
  echo "  WARNING: ${#FAILED_PLUGINS[@]} plugin(s) failed to install:"
  for p in "${FAILED_PLUGINS[@]}"; do
    echo "    - $p  (retry: /plugin install $p)"
  done
fi

# -----------------------------------------------------------------------------
# Step 6: Global MCPs
# -----------------------------------------------------------------------------
step "Step 6/6: Global MCPs"

echo ""
echo "  Installing global MCPs (Context7 + Sentry)..."
echo ""

# Context7 MCP
echo "  Installing Context7 MCP..."
if claude mcp list 2>/dev/null | grep -q "context7"; then
  skip "Context7 MCP"
else
  claude mcp add --scope user context7 -- npx -y @anthropic-ai/context7-mcp || { fail "Context7 MCP install failed"; exit 1; }
  claude mcp list 2>/dev/null | grep -q "context7" || { fail "Context7 MCP not found after install"; exit 1; }
  ok "Context7 MCP installed"
fi

# Sentry MCP
echo "  Installing Sentry MCP..."
if claude mcp list 2>/dev/null | grep -q "sentry"; then
  skip "Sentry MCP"
else
  claude mcp add --scope user --transport http sentry https://mcp.sentry.dev/mcp || { fail "Sentry MCP install failed"; exit 1; }
  claude mcp list 2>/dev/null | grep -q "sentry" || { fail "Sentry MCP not found after install"; exit 1; }
  ok "Sentry MCP installed"
fi

# -----------------------------------------------------------------------------
# Done
# -----------------------------------------------------------------------------
echo ""
echo "=================================================="
echo "  Global Setup Complete!"
echo "=================================================="
echo ""
echo "  What was installed:"
echo "    - tmux (parallel agents)"
echo "    - TypeScript Language Server + Pyright (LSP)"
echo "    - 12 Claude Code plugins (global)"
echo "    - Context7 MCP (library documentation)"
echo "    - Sentry MCP (error tracking)"
echo ""
echo "  Manual steps (do these yourself):"
echo "    - [ ] Open Claude Code and run /mcp to authenticate Sentry (one-time OAuth)"
echo ""
echo "  Next steps:"
echo "    1. Verify plugins: open Claude Code, run /plugin list"
echo "    2. Verify MCPs: open Claude Code, run 'claude mcp list'"
echo "    3. Set up a project:"
echo ""
echo "       New project:      $REPO_DIR/scripts/setup-new.sh"
echo "       Existing project: $REPO_DIR/scripts/setup-existing.sh"
echo ""
echo "  To undo this setup: see $REPO_DIR/README.md#uninstall"
echo ""
