# Claude Code Workflow for Indie Hackers
> **Last Updated:** 2026-02-11
> **Next Review:** 2026-03-13 (30 days)
> **Research Method:** `/last30days` skill across Reddit, X, Web

A comprehensive, modular Claude Code setup for solo builders managing 20+ projects across multiple tech stacks.

---

## 📋 Quick Start

**For NEW projects:**
```bash
# Feed this entire repo to Claude Code when starting a new project
cat CORE-SETUP.md PROJECT-TEMPLATES/<your-stack>.md | claude
```

**For EXISTING projects:**
```bash
# Claude will assess your setup and suggest changes
cat CORE-SETUP.md ASSESSMENT-PROMPT.md | claude
```

---

## 📂 Repository Structure

```
claude-workflow/
├── README.md                    # This file
├── CORE-SETUP.md                # Universal setup (all projects)
├── TESTING-GUIDE.md             # TDD workflows & when to use
├── GIT-WORKFLOW.md              # Worktrees, parallel agents, commits
├── CODE-REVIEW.md               # CodeRabbit & Greptile setup
├── ASSESSMENT-PROMPT.md         # Feed to Claude for existing projects
├── UPDATE-WORKFLOW.md           # How to update this repo every 30 days
├── PROJECT-TEMPLATES/
│   ├── fullstack-web.md         # React/Next.js + Node/Django + DB
│   ├── backend-api.md           # FastAPI/Node/Django + DB
│   ├── mobile.md                # React Native / Capacitor
│   └── mvp-prototype.md         # Fast iteration, lighter setup
├── MCP-MODULES/
│   ├── databases.md             # PostgreSQL, MongoDB, Supabase
│   ├── payments.md              # Stripe MCP
│   ├── deployment.md            # Vercel, Render, Fly.io, AWS
│   └── redis.md                 # Redis MCP
└── HOOKS/
    ├── auto-test.json           # Automatically run tests
    ├── auto-format.json         # Format code on save
    └── skill-loader.json        # Force skill loading
```

---

## 🎯 Philosophy

1. **Modular** - Mix and match components per project
2. **Automated** - Don't remind Claude, hooks do it
3. **Consistent** - Same patterns across all 20+ projects
4. **Updated** - Review every 30 days with `/last30days`
5. **Evidence-based** - All recommendations from recent research (Reddit, X, Web)

---

## 🚀 What's Inside

### Core Setup (Always)
- Context7 MCP (up-to-date library docs)
- GitHub MCP (repo management)
- File System MCP (refactoring control)
- `/insights` skill (auto-generates custom skills)
- CLAUDE.md template
- Hooks for automatic testing, skill loading

### Testing (Project-Dependent)
- **MVPs/Prototypes:** Minimal testing, focus on speed
- **Production apps:** Full TDD with hooks
- **Technical debt calculator** (when to skip tests)

### Git Workflow
- Parallel worktrees from terminal (3-5 agents)
- tmux integration
- Commit-per-task-step pattern
- Plan mode → /clear → implement

### Code Review
- **CodeRabbit** (Claude Code plugin, fast feedback)
- **Greptile** (catches 3x more bugs, full codebase context, GitLab support)

### MCP Modules (Add as Needed)
- Stripe (payments)
- PostgreSQL / MongoDB / Supabase (databases)
- Vercel / Render / Fly.io / AWS Beanstalk (deployment)
- Redis (caching)

---

## 📅 Maintenance Schedule

**Every 30 days:**
1. Run `/last30days recommended claude code setup indie hacker 2026`
2. Review suggested changes
3. Update relevant docs
4. Commit with date: `git commit -m "Update: 2026-03-13 workflow review"`

See `UPDATE-WORKFLOW.md` for detailed instructions.

---

## 🤝 Community

This setup is public and battle-tested across 20+ production projects. PRs welcome!

**Research sources:**
- Reddit: r/ClaudeCode, r/ClaudeAI (750+ upvotes analyzed)
- X: 75+ posts from top voices (@cptn3mox, @dani_avila7, @kellypeilinchan)
- Web: 30+ guides from Builder.io, QuantumByte, Apidog, Greptile, CodeRabbit

---

**Created:** 2026-02-11
**License:** MIT
**Author:** Indie hacker managing 20+ projects (React, Next.js, Django, Node, Deno, FastAPI, React Native, Capacitor, Supabase, MongoDB, PostgreSQL, Stripe, Vercel, Render, Fly.io, AWS, Redis)
