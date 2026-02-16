# Claude Code Setup Tool

Set up the perfect Claude Code configuration for any project. One-time global install, then per-project setup in minutes.

## How It Works

**4 commands. That's it.**

### 1. First Time? Global Setup

Run this once on your machine. Installs everything: Claude Code, tmux (parallel agents), LSP servers, 12 global plugins.

```bash
git clone https://github.com/imcbv/claude-workflow.git ~/Documents/Code/claude-workflow
cd ~/Documents/Code/claude-workflow
./scripts/setup-global.sh
```

**What it installs:**
- tmux (run multiple Claude agents side by side)
- TypeScript + Python language servers (real-time type checking)
- 12 plugins: security scanning, code review, commit automation, UI design, PR review, and more

Takes ~15 minutes. Never needs to run again.

### 2. New Project

Run this when starting a new project. Asks a few questions, then Claude generates all config files.

```bash
cd ~/projects/my-new-app
~/Documents/Code/claude-workflow/scripts/setup-new.sh
```

**What it does:**
- Asks: production or MVP? What stack? What services?
- Generates `.claude/CLAUDE.md` (project rules)
- Generates `.claude/settings.json` (auto-test, auto-format hooks)
- Lists which MCPs and plugins to install locally
- Takes ~5 minutes

### 3. Existing Project

Run this in a project that already has code. Claude analyzes the codebase and sets up what's missing.

```bash
cd ~/projects/my-existing-app
~/Documents/Code/claude-workflow/scripts/setup-existing.sh
```

**What it does:**
- Scans your code (package.json, requirements.txt, file structure, .env files)
- Detects stack, database, deployment, payments, monorepo structure
- Shows what it found, asks you to confirm
- Generates config files for what's missing
- Takes ~5 minutes

### 4. Monthly Update

Run this every 30 days (or whenever). Checks if your setup needs updating.

```bash
~/Documents/Code/claude-workflow/scripts/update.sh
```

**What it does:**
- Researches latest Claude Code best practices
- Checks for new plugins, deprecated tools, breaking changes
- Compares with your current setup
- Suggests specific updates (or tells you you're good)

---

## What You Get After Setup

Once set up, this is what happens automatically when you use Claude Code:

| What | How It Works | You Do... |
|------|-------------|-----------|
| Security scanning | Plugin scans every code edit for XSS, injection, etc. | Nothing. Automatic. |
| Type checking | LSP catches type errors in real-time | Nothing. Automatic. |
| UI quality | Design skills activate when Claude does UI work | Nothing. Automatic. |
| Committing | Claude uses `/commit` or `/commit-push-pr` | Just say "commit this" |
| New features | Claude uses 7-phase structured workflow | Just say "build X feature" |
| Code review | 6 agents review before PR | Just say "review this" |
| Session memory | CLAUDE.md updated with learnings | Happens at session end |
| Tests | Auto-run after every code edit (production projects) | Nothing. Automatic. |

---

## Parallel Agents (Worktrees)

Work on multiple features at the same time with separate Claude agents:

```bash
cd ~/projects/my-app

# Create separate workspaces
git worktree add ../my-app-feature feature/auth
git worktree add ../my-app-bugfix fix/payments

# Open tmux, split into panes, run Claude in each
tmux
# Pane 1: cd ~/projects/my-app && claude
# Pane 2: cd ~/projects/my-app-feature && claude
# Pane 3: cd ~/projects/my-app-bugfix && claude

# 3 agents, 3 branches, no conflicts.
# /clean_gone cleans up when done.
```

See [GIT-WORKFLOW.md](GIT-WORKFLOW.md) for the full guide with tmux cheatsheet.

---

## Detailed Documentation

The scripts handle everything, but if you want to understand the details:

| Doc | What's In It |
|-----|-------------|
| [ARCHITECTURE.md](ARCHITECTURE.md) | Plugins vs MCPs vs Skills, what's global vs local, complete plugin list |
| [CORE-SETUP.md](CORE-SETUP.md) | Essential MCPs, CLAUDE.md template, hooks |
| [TESTING-GUIDE.md](TESTING-GUIDE.md) | When to test, TDD workflow, framework setup |
| [GIT-WORKFLOW.md](GIT-WORKFLOW.md) | Worktrees, tmux, parallel agents, commit patterns |
| [CODE-REVIEW.md](CODE-REVIEW.md) | CodeRabbit + Greptile setup |
| [APPLY-SETUP.md](APPLY-SETUP.md) | Detailed project setup workflow (used by scripts) |
| [ARCHITECTURE.md](ARCHITECTURE.md) | Plugin analysis: what to install, what to skip, why |
| [UPDATE-WORKFLOW.md](UPDATE-WORKFLOW.md) | Monthly update process, research methodology |

### Reference Files

| Dir | Contents |
|-----|---------|
| [PROJECT-TEMPLATES/](PROJECT-TEMPLATES/) | Stack-specific configs (fullstack, backend, mobile, MVP) |
| [MCP-MODULES/](MCP-MODULES/) | Setup guides for databases, payments, deployment, error tracking |
| [HOOKS/](HOOKS/) | Hook templates (auto-test, auto-format, skill-loader) |

---

## Philosophy

1. **Automated** - Hooks and plugins do the work, not reminders
2. **Modular** - Global base + per-project additions
3. **Simple** - 4 commands cover everything
4. **Updated** - Monthly review keeps it current
5. **Evidence-based** - All recommendations from community research

---

**License:** MIT
