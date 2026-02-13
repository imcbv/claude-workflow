# Core Setup (All Projects)

> **Apply to:** Every project, regardless of stack
> **Last Updated:** 2026-02-11

---

## 1. Essential MCPs (Install Once, Global)

```bash
# Context7 - Up-to-date library documentation
# Already installed ✓

# GitHub - Repository management
# (Check if installed in Claude Code settings)

# File System - Fine-grained permission control for refactoring
# (Check if installed in Claude Code settings)

# Sentry - Error tracking and debugging (NEW - Highly Recommended)
# Install: claude mcp add --transport http sentry https://mcp.sentry.dev/mcp
# Authenticate: /mcp (one-time OAuth)
# See: MCP-MODULES/error-tracking.md

# Sequential Thinking - Helps Claude solve complex problems methodically
# Optional but recommended for complex refactors
```

**Rule:** Max 2-3 MCPs per project. Too many slow down startup.
**Exception:** Sentry MCP is lightweight and highly valuable for production apps.
**Source:** [MCPcat guide](https://mcpcat.io/guides/best-mcp-servers-for-claude-code/)

---

## 2. Skills

### Must Have: /insights

```bash
# Run this to auto-generate skills based on YOUR working style
/insights
```

**When to use:**
- After your first 10-20 sessions with Claude Code
- Every time you significantly change your workflow
- Per @cptn3mox (14 likes): "It built custom skills and hooks for me based on my working style"

**Note:** You're changing your workflow NOW, so run /insights AFTER you implement this new setup.

### Install from Community

```bash
# Official Anthropic skills
/plugin install document-skills@anthropic-agent-skills

# Hackathon-winning setup (10 months of production configs)
# https://github.com/affaan-m/everything-claude-code
# Clone and copy relevant skills to ~/.claude/skills/

# Awesome collection
# https://github.com/travisvn/awesome-claude-skills
```

**Skill Loading Fix:**
Skills need good descriptions with keywords. But there's a current bug (r/ClaudeCode, 15 upvotes): CLAUDE.md being ignored since recent update.

**Workaround:** Use a hook to force skill loading (see HOOKS section below).

---

## 3. CLAUDE.md Template

Create `.claude/CLAUDE.md` in EVERY project:

```markdown
# Project: [PROJECT_NAME]
# Stack: [e.g., Next.js + FastAPI + PostgreSQL + Stripe]
# Type: [MVP | Production | Prototype]

## Core Rules

1. **Testing:** [See TESTING-GUIDE.md - varies by project type]
2. **Commits:** Write commits as you go for each task step. This allows easy revert.
3. **Errors:** Do not handle errors gracefully. Use test-driven development that fails hard and fast.
4. **Scope:** Ask before making changes beyond the immediate task. No over-engineering.
5. **Code Review:** After every correction, update this CLAUDE.md so you don't make that mistake again.

## Tech Stack Specifics

[Copy from PROJECT-TEMPLATES/<your-stack>.md]

## Code Review Standards

- **CodeRabbit:** Reads this file for context. Add your coding standards here.
- **Style:** [Your preferences - e.g., functional React, type hints in Python]
- **Architecture:** [Your patterns - e.g., feature-based folders, API routes in /app/api]

## Current Focus

[Update this section as you work - helps Claude maintain context]

## Known Issues / Bugs to Avoid

[Claude updates this section automatically when you say "Update your CLAUDE.md so you don't make that mistake again"]
```

**Source:** [Builder.io guide](https://www.builder.io/blog/claude-code) - "Claude is eerily good at writing rules for itself"

---

## 4. Hooks (Automation Layer)

**Location:** `.claude/settings.json` in your project

### Hook 1: Force Skill Loading

**Problem:** Skills aren't loading reliably (r/ClaudeCode bug)
**Solution:** Hook that forces Claude to read skills before every call

```json
{
  "hooks": [
    {
      "name": "force-skill-loader",
      "event": "PrePrompt",
      "command": "echo 'Loading skills and CLAUDE.md context...' && cat ~/.claude/skills/*/SKILL.md .claude/CLAUDE.md 2>/dev/null | head -100"
    }
  ]
}
```

### Hook 2: Auto-Run Tests (Conditional)

**Only enable for production projects** (see TESTING-GUIDE.md)

```json
{
  "hooks": [
    {
      "name": "auto-test",
      "event": "PostToolUse",
      "filter": "Edit|Write",
      "prompt": "After modifying code, verify all unit tests still pass. Run the test suite and report results."
    }
  ]
}
```

**How it works:**
- PostToolUse triggers after Claude completes an action
- "Turns a polite suggestion into a guaranteed action" (per [Eesel guide](https://www.eesel.ai/blog/hooks-in-claude-code))
- No more reminding Claude to test

**Source:** [Claude Code hooks docs](https://code.claude.com/docs/en/hooks-guide), [Coding Nexus guide](https://medium.com/coding-nexus/claude-code-hooks-5-automations-that-eliminate-developer-friction-7b6ddeff9dd2)

### Hook 3: Auto-Format

```json
{
  "hooks": [
    {
      "name": "auto-format",
      "event": "PostToolUse",
      "filter": "Edit|Write",
      "command": "prettier --write *.{js,jsx,ts,tsx,css,json} 2>/dev/null || black *.py 2>/dev/null || true"
    }
  ]
}
```

---

## 5. Git Workflow Basics (All Projects)

```bash
# ALWAYS use plan mode for non-trivial features
# Plan → /clear → implement

# Commit per task step
# Claude should commit as it goes, not one giant commit at the end

# See GIT-WORKFLOW.md for parallel worktrees setup
```

---

## 6. Best Practices (Universal)

### The Non-Negotiables

1. **Start in plan mode** for anything beyond a simple bug fix
   - "Pour your energy into the plan so Claude can 1-shot the implementation" ([QuantumByte](https://quantumbyte.ai/articles/claude-code-best-practices))

2. **Use /clear often**
   - Start each new task fresh
   - Prevents context pollution
   - Saves tokens

3. **Force small changes**
   - "Big, multi-file rewrites are where quality collapses" ([QuantumByte](https://quantumbyte.ai/articles/claude-code-best-practices))

4. **Update CLAUDE.md after every correction**
   - "Update your CLAUDE.md so you don't make that mistake again"
   - Claude learns from its mistakes

### Current Bug Alert (Feb 2026)

**Opus 4.6 regression:**
- @dani_avila7 (16 likes): "Opus 4.5: commit, push, release. Opus 4.6: Should I add to staging?"
- CLAUDE.md being ignored since recent update
- Use `/memory` to check what's loaded

**Workaround:** Force skill loading hook (above)

---

## Next Steps

1. ✅ Core setup complete
2. → Choose your project type: See `PROJECT-TEMPLATES/`
3. → Add relevant MCPs: See `MCP-MODULES/`
4. → Set up testing: See `TESTING-GUIDE.md`
5. → Configure git workflow: See `GIT-WORKFLOW.md`
6. → Set up code review: See `CODE-REVIEW.md`
