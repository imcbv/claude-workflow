#!/bin/bash
# =============================================================================
# Claude Code Global Setup
# Run this ONCE on a new machine. Sets up everything globally.
# =============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"

echo ""
echo "=================================================="
echo "  Claude Code Global Setup"
echo "  This installs everything you need, once."
echo "=================================================="
echo ""

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

# Homebrew (macOS)
if [[ "$OSTYPE" == "darwin"* ]]; then
  if check_installed brew; then
    skip "Homebrew"
  else
    echo "  Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    ok "Homebrew installed"
  fi
fi

# Node.js
if check_installed node; then
  skip "Node.js ($(node --version))"
else
  echo "  Installing Node.js..."
  if [[ "$OSTYPE" == "darwin"* ]]; then
    brew install node
  else
    curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
    sudo apt-get install -y nodejs
  fi
  ok "Node.js installed"
fi

# Python 3
if check_installed python3; then
  skip "Python 3 ($(python3 --version 2>&1))"
else
  echo "  Installing Python 3..."
  if [[ "$OSTYPE" == "darwin"* ]]; then
    brew install python3
  else
    sudo apt-get install -y python3 python3-pip
  fi
  ok "Python 3 installed"
fi

# Git
if check_installed git; then
  skip "Git ($(git --version))"
else
  echo "  Installing Git..."
  if [[ "$OSTYPE" == "darwin"* ]]; then
    brew install git
  else
    sudo apt-get install -y git
  fi
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
  if [[ "$OSTYPE" == "darwin"* ]]; then
    brew install tmux
  else
    sudo apt-get install -y tmux
  fi
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
  npm install -g @anthropic-ai/claude-code
  ok "Claude Code installed"
  echo ""
  echo "  IMPORTANT: Run 'claude' once to authenticate before continuing."
  echo "  Press Enter after you've authenticated..."
  read -r
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

for plugin in "${PLUGINS[@]}"; do
  echo "  Installing $plugin..."
  claude /plugin install "$plugin" 2>/dev/null || echo "    (may need manual install: /plugin install $plugin)"
done

echo ""
ok "Plugin installation attempted for all ${#PLUGINS[@]} plugins"
echo ""
echo "  NOTE: If any plugins failed, open Claude Code and run:"
echo "  /plugin install <plugin-name>"
echo ""
echo "  Installed plugins:"
for plugin in "${PLUGINS[@]}"; do
  echo "    - $plugin"
done

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
  claude mcp add --scope user context7 -- npx -y @anthropic-ai/context7-mcp
  ok "Context7 MCP installed"
fi

# Sentry MCP
echo "  Installing Sentry MCP..."
if claude mcp list 2>/dev/null | grep -q "sentry"; then
  skip "Sentry MCP"
else
  claude mcp add --scope user --transport http sentry https://mcp.sentry.dev/mcp
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
echo "  Full documentation: $REPO_DIR/README.md"
echo ""
