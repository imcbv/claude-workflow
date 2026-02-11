# Git Workflow: Parallel Agents with Worktrees

> **Last Updated:** 2026-02-11
> **Research:** Reddit (212 upvotes, r/ClaudeAI), X (21 likes, @mikeyobrienv), 10+ terminal tools

---

## The #1 Productivity Unlock

> "Work in parallel with 3-5 git worktrees at once, each running its own Claude session. It's the single biggest productivity unlock." - [Builder.io](https://www.builder.io/blog/claude-code) (Claude Code team's top tip)

**What this means:**
- Terminal 1: Feature A (new-auth branch)
- Terminal 2: Bug fix (hotfix-payment branch)
- Terminal 3: Refactor (improve-api branch)
- All working simultaneously, no conflicts

**Source:** r/ClaudeAI (212 upvotes, 54 comments) - "Stop running multiple Claude Code agents in the same repo"

---

## What Are Git Worktrees?

**Normal git workflow:**
```bash
git checkout feature-branch  # Switches entire repo
# Can't work on main while on feature-branch
```

**Worktree workflow:**
```bash
git worktree add ../my-repo-feature feature-branch
# Now you have TWO directories:
# ~/my-repo/ (main branch)
# ~/my-repo-feature/ (feature-branch)
# Can work on BOTH simultaneously
```

**Why this matters for Claude Code:**
- Run Claude Code in each worktree = parallel agents
- No file conflicts
- No stashing/switching branches
- Each agent has isolated workspace

---

## Setup: Terminal-Based Worktrees (You Code from Terminal)

### Step 1: Install tmux (Terminal Multiplexer)

```bash
# macOS
brew install tmux

# Linux
sudo apt install tmux  # Debian/Ubuntu
sudo yum install tmux  # RedHat/CentOS
```

**What tmux does:** Lets you split your terminal into multiple panes, each running a different worktree.

### Step 2: Create Your First Worktree

```bash
# In your main repo
cd ~/projects/my-app

# Create a worktree for a feature
git worktree add ../my-app-feature feature/new-auth

# Create a worktree for a hotfix
git worktree add ../my-app-hotfix hotfix/payment-bug

# List all worktrees
git worktree list
```

**Output:**
```
/Users/you/projects/my-app         abc123 [main]
/Users/you/projects/my-app-feature def456 [feature/new-auth]
/Users/you/projects/my-app-hotfix  ghi789 [hotfix/payment-bug]
```

### Step 3: Launch Claude Code in Each Worktree

#### Option A: tmux Workflow (Recommended)

```bash
# Start tmux
tmux

# Split terminal into 3 panes
Ctrl+B then "    # Split horizontally
Ctrl+B then %    # Split vertically
# Navigate between panes: Ctrl+B then arrow keys

# In pane 1:
cd ~/projects/my-app
claude

# In pane 2:
cd ~/projects/my-app-feature
claude

# In pane 3:
cd ~/projects/my-app-hotfix
claude
```

**tmux cheat sheet:**
- `Ctrl+B then "` → Split horizontal
- `Ctrl+B then %` → Split vertical
- `Ctrl+B then arrow key` → Navigate panes
- `Ctrl+B then d` → Detach (keeps running in background)
- `tmux attach` → Reattach to session

**Source:** @kellypeilinchan (4 likes) - "After finally running Git worktrees properly, my setup just clicked. tmux, one window, three panes: AI agent, pnpm dev running, terminal for dirty work. Now I've got 6 worktrees + 6 AI agents."

#### Option B: Multiple Terminal Tabs

```bash
# Tab 1
cd ~/projects/my-app
claude

# Tab 2
cd ~/projects/my-app-feature
claude

# Tab 3
cd ~/projects/my-app-hotfix
claude
```

Simpler but less efficient than tmux.

#### Option C: Ralph Orchestrator (Advanced)

```bash
# Install Ralph (multi-agent orchestrator)
npm install -g ralph-orchestrator

# Run parallel agents via worktrees
# Terminal 1
ralph run -p "Add authentication"

# Terminal 2
ralph run -p "Fix payment bug"
```

**Features:**
- Multi-loop concurrency via git worktrees
- Zero conflicts
- Orchestrates multiple Claude Code instances

**Source:** @mikeyobrienv (21 likes, 4 reposts) - "Ralph Orchestrator v2.2.3 just dropped. New: Multi-loop concurrency via git worktrees."

---

## The Complete Workflow

### Daily Routine with 3 Parallel Agents

**Morning:**
```bash
# Start tmux session
tmux new -s dev

# Pane 1: Main branch (production hotfixes)
cd ~/projects/my-app
claude

# Pane 2: Feature branch (new feature)
git worktree add ../my-app-feature feature/new-dashboard
cd ../my-app-feature
claude

# Pane 3: Refactor branch (tech debt)
git worktree add ../my-app-refactor refactor/api-cleanup
cd ../my-app-refactor
claude
```

**During the day:**
- Tell Pane 1 Claude: "Fix the Stripe payment bug"
- Tell Pane 2 Claude: "Build the user dashboard"
- Tell Pane 3 Claude: "Refactor the API to use async/await"

All three work simultaneously, no conflicts.

**End of day:**
```bash
# Detach tmux (keeps running)
Ctrl+B then d

# Next day: reattach
tmux attach -t dev
```

**Source:** @dgalarza (4 likes, 3 reposts) - "Everyone's posting about running multiple coding agents. Here's how to actually do it: Git worktrees. Run Claude Code agents in parallel across different branches. Production hotfix in one terminal, feature work in another."

---

## Commit Strategy

### Per-Task-Step Commits

**Pattern:** Claude commits as it goes, NOT one giant commit at the end.

```markdown
# Add to CLAUDE.md:
## Commit Strategy
- Commit after EVERY completed task step
- Commit messages format: "Add [feature]: [what it does]"
- This allows easy revert if something breaks
- Run tests BEFORE committing (hook does this automatically)
```

**Why this works:**
- Easy to revert a single bad commit
- Git history tells the story of the feature
- Code review is easier (small, focused commits)

**Example commit history:**
```
feat: Add user authentication schema
feat: Add login endpoint
feat: Add JWT token generation
test: Add auth endpoint tests
fix: Handle expired token edge case
```

VS bad:
```
feat: Add authentication (500 lines changed across 20 files)
```

**Source:** [Builder.io](https://www.builder.io/blog/claude-code) - "One important instruction is to have Claude write commits as it goes for each task step."

### Commit Template

Add to `.gitmessage`:

```
# <type>: <subject> (max 50 chars)
# |<----  Using a Maximum Of 50 Characters  ---->|

# Explain why this change is being made (wrap at 72 chars)
# |<----   Try To Limit Each Line to a Maximum Of 72 Characters   ---->|

# Provide links to related issues, PRs, or documentation
# Example: Fixes #123, Related to #456

# Type: feat, fix, docs, style, refactor, test, chore

# Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>
```

Tell Claude in CLAUDE.md:
```markdown
## Commits
Use the template in .gitmessage
Always include: Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>
```

---

## Plan Mode → /clear → Implement Pattern

**The workflow:**

```bash
# 1. Start in plan mode
/plan "Build user dashboard with charts"

# Claude explores codebase, designs approach, writes plan

# 2. Review plan, approve

# 3. Clear context (plan mode bloats context)
/clear

# 4. Implement from plan
"Implement the plan we just created"

# Claude implements, commits per step, tests auto-run
```

**Why /clear?**
- Plan mode loads tons of files for exploration
- Implementation doesn't need all that context
- Saves tokens, speeds up responses

**Source:** @mojibaked - "After planning out a feature in Claude's plan mode, the CLI provides an option to clear context and implement the plan, which is the recommended approach to achieve better results."

---

## Cleaning Up Worktrees

```bash
# When feature is merged, remove worktree
git worktree remove ../my-app-feature

# Delete the merged branch
git branch -d feature/new-auth

# List remaining worktrees
git worktree list
```

**Prune orphaned worktrees:**
```bash
git worktree prune
```

---

## Advanced: Persisting Sessions

**Problem:** If you close the terminal, Claude Code sessions die.

**Solution:** Use a persistent terminal

### Option 1: tmux (Already Covered)

```bash
# Start session
tmux new -s claude-dev

# Detach: Ctrl+B then d
# Reattach anytime: tmux attach -t claude-dev
```

### Option 2: CCC (Claude Code Client)

Tool that prevents Claude Code sessions from dying when you close the terminal.

**Source:** r/ClaudeCode - "I built a OS terminal that won't kill your Claude Code sessions when you close or update"

---

## Team Workflow (For Your Non-Technical Team Members)

**Your setup:**
- You: Terminal + worktrees + parallel agents
- Non-technical: Lovable (vibe-code) connected to GitHub

**How it works together:**

1. **Non-technical creates PR via Lovable:**
   - They describe feature in Lovable
   - Lovable generates code, opens PR on GitHub

2. **You review in a worktree:**
   ```bash
   # Create worktree from their PR branch
   git worktree add ../review-pr-123 pr/lovable-feature
   cd ../review-pr-123
   claude

   # "Review this PR and suggest improvements"
   ```

3. **CodeRabbit reviews automatically:**
   - Catches bugs, style issues
   - Comments on GitHub PR

4. **You merge or request changes:**
   ```bash
   # If good:
   gh pr merge 123 --squash

   # If needs work:
   gh pr comment 123 --body "Please fix the auth logic"
   ```

**Source:** Your context - "solo or small teams, some non-technical using Lovable connected to GitHub"

---

## Common Issues

### Issue: "Worktree X already exists"

```bash
# Force remove
git worktree remove --force ../my-app-feature

# Then recreate
git worktree add ../my-app-feature feature/new-auth
```

### Issue: "Claude Code agents conflict on git operations"

**Solution:** Each agent works in its own worktree, so no conflicts. But if they try to push to the same branch:

```markdown
# Add to CLAUDE.md:
## Git Rules
- Only push when I explicitly say "push"
- Never force push to main/master
- Commit locally, I'll handle pushing
```

### Issue: "Too many worktrees, lost track"

```bash
# List all worktrees
git worktree list

# Prune dead ones
git worktree prune

# Remove specific ones
git worktree remove ../path/to/worktree
```

---

## Resources

### Official Git Docs
- [Git worktrees documentation](https://git-scm.com/docs/git-worktree)

### Community Examples
- [r/ClaudeAI: Stop running multiple agents in same repo](https://www.reddit.com/r/ClaudeAI/comments/1qzduim/stop_running_multiple_claude_code_agents_in_the/) (212 upvotes)
- [r/ClaudeCode: Subtask - spawns subagents in worktrees](https://www.reddit.com/r/ClaudeCode/comments/1qhzagf/subtask_claude_code_creates_tasks_and_spawns/) (263 upvotes)
- @kellypeilinchan (4 likes): tmux + worktrees workflow
- @dgalarza (4 likes, 3 reposts): Parallel agents tutorial
- @mikeyobrienv (21 likes, 4 reposts): Ralph Orchestrator

### Tools
- [tmux](https://github.com/tmux/tmux) - Terminal multiplexer
- [Ralph Orchestrator](https://github.com/mikeyobrienv/ralph-orchestrator) - Multi-agent orchestration
- [CCC](https://www.threads.com/@naa_rang) - Mobile IDE with worktree support

---

## Quick Reference

```bash
# CREATE WORKTREE
git worktree add <path> <branch>

# LIST WORKTREES
git worktree list

# REMOVE WORKTREE
git worktree remove <path>

# PRUNE ORPHANED
git worktree prune

# TMUX BASICS
tmux new -s <name>          # Start session
Ctrl+B then "               # Split horizontal
Ctrl+B then %               # Split vertical
Ctrl+B then arrow           # Navigate
Ctrl+B then d               # Detach
tmux attach -t <name>       # Reattach
```

---

## Next: Set Up Code Review

See `CODE-REVIEW.md` for CodeRabbit and Greptile integration.
