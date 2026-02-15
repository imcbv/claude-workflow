# Architecture: Plugins vs MCPs vs Skills (Global vs Local)

> **Last Updated:** 2026-02-15
> **This is the most important file to understand before setting up anything.**

---

## 🧠 The Big Picture

Claude Code has **four extension types** that work TOGETHER:

```
┌──────────────────────────────────────────────────────────────┐
│                        PLUGIN                                │
│  (Bundle that packages everything below into one install)    │
│                                                              │
│   ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐   │
│   │  SKILL   │  │   MCP    │  │   HOOK   │  │ COMMAND  │   │
│   │          │  │          │  │          │  │          │   │
│   │ Internal │  │ External │  │ Auto     │  │ /slash   │   │
│   │ playbook │  │ connect  │  │ actions  │  │ commands │   │
│   └──────────┘  └──────────┘  └──────────┘  └──────────┘   │
└──────────────────────────────────────────────────────────────┘
```

### What Each Thing Does

| Type | What It Is | Example | Analogy |
|------|-----------|---------|---------|
| **Skill** | Markdown instructions Claude follows | "When building React components, use feature folders" | A **playbook/manual** |
| **MCP** | Connection to external tool/API | Sentry reads errors, Stripe creates payments | A **phone line** to outside |
| **Hook** | Automatic action on events | "Run tests after every code edit" | An **autopilot rule** |
| **Plugin** | Bundle of skills + MCPs + hooks + commands | "frontend-design" includes design skills + visual testing | A **complete toolkit** |

**Source:** [IntuitionLabs comparison](https://intuitionlabs.ai/articles/claude-skills-vs-mcp)

### Do They Complement or Exclude?

**They COMPLEMENT each other. Never exclude.**

> "Skills act as the AI's internal playbook, while MCP servers are the AI's nervous system connecting it to the outside world." - [IntuitionLabs](https://intuitionlabs.ai/articles/claude-skills-vs-mcp)

**Example:** The CodeRabbit **plugin** bundles:
- A **skill** (instructions on how to review code)
- An **MCP** (connection to CodeRabbit API)
- A **command** (`/coderabbit:review`)
- A **hook** (optional: auto-review before commit)

**You can also use each piece independently:**
- Install JUST the CodeRabbit MCP (without the plugin)
- Install JUST a code review skill (without any MCP)
- The plugin just bundles them conveniently

**Source:** [r/ClaudeCode](https://www.reddit.com/r/ClaudeCode/comments/1qrlgij/everyones_hyped_on_skills_but_claude_code_plugins/) - "Plugins bundle skills + MCP + hooks + agents"

---

## 📦 Installation Scopes (CRITICAL)

### Three Levels

```
┌─────────────────────────────────────────────────────┐
│ USER (Global)                                       │
│ Stored: ~/.claude.json                              │
│ Available: ALL projects on your machine             │
│                                                     │
│ Best for:                                           │
│ - Tools you ALWAYS use (Context7, GitHub)           │
│ - Tools with ONE account (your personal GitHub)     │
│ - Things that don't change per project              │
│                                                     │
│   ┌───────────────────────────────────────────────┐ │
│   │ PROJECT (Shared)                              │ │
│   │ Stored: .mcp.json (in repo, committed)        │ │
│   │ Available: Everyone working on this project   │ │
│   │                                               │ │
│   │ Best for:                                     │ │
│   │ - Team projects where MCPs should be shared   │ │
│   │ - Lovable/non-technical team members          │ │
│   │ - Standard project config                     │ │
│   │                                               │ │
│   │   ┌─────────────────────────────────────────┐ │ │
│   │   │ LOCAL (Private, Per-Project)            │ │ │
│   │   │ Stored: ~/.claude.json (under project)  │ │ │
│   │   │ Available: Only YOU, only THIS project  │ │ │
│   │   │                                         │ │ │
│   │   │ Best for:                               │ │ │
│   │   │ - MCPs with project-specific accounts   │ │ │
│   │   │ - Supabase (different account per proj) │ │ │
│   │   │ - Stripe (different keys per project)   │ │ │
│   │   │ - Sensitive credentials                 │ │ │
│   │   └─────────────────────────────────────────┘ │ │
│   └───────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────┘
```

### Scope Precedence

When same MCP name exists at multiple scopes:

```
LOCAL wins > PROJECT wins > USER (global)
```

**This means:** If you have Supabase MCP globally but also locally, LOCAL config wins for that project.

**Source:** [Claude Code MCP docs](https://code.claude.com/docs/en/mcp)

### How to Install at Each Scope

```bash
# USER (Global) - Available everywhere
claude mcp add --scope user --transport http context7 https://context7-mcp-url

# LOCAL (Default) - Only you, only this project
claude mcp add sentry https://mcp.sentry.dev/mcp
# (--scope local is default, no flag needed)

# PROJECT (Shared) - Everyone on this project
claude mcp add --scope project --transport http sentry https://mcp.sentry.dev/mcp
# Creates .mcp.json file in repo
```

---

## 🎯 Your Setup: What Goes Where

### GLOBAL (Install Once, Forget Forever)

These are tools that:
- ✅ Work the same across ALL your 20+ projects
- ✅ Don't have project-specific accounts/keys
- ✅ You ALWAYS want available

```bash
# Context7 - Library documentation (no account needed)
claude mcp add --scope user --transport http context7 [url]

# GitHub MCP - YOUR personal GitHub account (one account)
claude mcp add --scope user --transport http github [url]

# Sentry MCP - YOUR Sentry account (reads ALL projects)
claude mcp add --scope user --transport http sentry https://mcp.sentry.dev/mcp

# Sequential Thinking - No account needed
claude mcp add --scope user --transport http sequential-thinking [url]
```

**Why Sentry is global:**
- One Sentry account → access to ALL Sentry projects
- MCP uses OAuth → authenticates once
- Claude can read ANY of your Sentry projects from ANY repo

### LOCAL (Per-Project, Different Accounts)

These are tools that:
- ⚠️ Have DIFFERENT accounts per project
- ⚠️ Have project-specific API keys
- ⚠️ Should NOT leak to other projects

```bash
# Supabase - DIFFERENT account per project!
cd ~/projects/app-one
claude mcp add supabase [url]
# Uses app-one's Supabase credentials

cd ~/projects/app-two
claude mcp add supabase [url]
# Uses app-two's Supabase credentials

# Stripe - DIFFERENT keys per project!
cd ~/projects/saas-app
claude mcp add stripe [url]
# Uses saas-app's STRIPE_SECRET_KEY

cd ~/projects/other-app
claude mcp add stripe [url]
# Uses other-app's STRIPE_SECRET_KEY

# PostgreSQL - DIFFERENT databases per project!
cd ~/projects/my-app
claude mcp add postgres [url]
# Connects to my-app's database
```

**Your Supabase Problem:**
> "Imagine I installed Supabase MCP globally but use different accounts for different projects"

**Solution:** Install Supabase MCP at LOCAL scope (default) per project:

```bash
cd ~/projects/project-with-supabase-account-A
claude mcp add supabase [url]  # local scope by default

cd ~/projects/project-with-supabase-account-B
claude mcp add supabase [url]  # local scope, different credentials
```

**Each project uses its own Supabase account.**

### DEPLOYMENT MCPs (Per-Project)

```bash
# Vercel - local if different Vercel projects/teams
cd ~/projects/next-app-on-vercel
claude mcp add vercel [url]

# Render - local if different Render services
cd ~/projects/api-on-render
claude mcp add render [url]

# Fly.io - local if different Fly.io apps
cd ~/projects/app-on-flyio
claude mcp add flyio [url]
```

**OR global if you use one account for everything:**
```bash
# If ALL your Vercel projects are under one account:
claude mcp add --scope user vercel [url]
```

---

## 🔌 Plugins You Should Install

### Official Plugins (from `/plugin` list)

**Install these GLOBALLY** (they work across all projects):

```bash
# 1. Frontend Design - Auto-invoked for frontend work
/plugin install frontend-design@claude-code-plugin

# What it does:
# - Activated automatically when Claude works on UI
# - Provides design guidance: typography, spacing, colors
# - Makes UI look professional (not generic AI-generated)
# - THIS is the "frontend skill" you were asking about!

# 2. Code Review - 5 parallel review agents
/plugin install code-review@claude-code-plugin

# What it does:
# - /code-review command
# - 5 parallel Sonnet agents check:
#   1. CLAUDE.md compliance
#   2. Bug detection
#   3. Historical context
#   4. PR history analysis
#   5. Code comments quality
# - Works alongside CodeRabbit/Greptile (complementary!)

# 3. Webapp Testing - Playwright browser testing
/plugin install webapp-testing@claude-code-plugin

# What it does:
# - Claude can open a browser and TEST your UI
# - Verifies visual output, clicks buttons, fills forms
# - Catches visual bugs, broken flows, responsive issues
# - Auto-invoked when Claude mentions testing a web page

# 4. CodeRabbit (if you use CodeRabbit)
/plugin install coderabbit@claude-code-plugin

# What it does:
# - /coderabbit:review command
# - Bundles: CodeRabbit MCP + skill + hook
# - Don't need separate CodeRabbit MCP if you have this plugin
```

### Plugin vs MCP: When Both Exist

**Example: CodeRabbit**

| Approach | What You Get |
|----------|-------------|
| **Just CodeRabbit MCP** | Claude can talk to CodeRabbit API |
| **Just CodeRabbit Plugin** | MCP + skill + /coderabbit:review command + hook |

**Rule:** If a **plugin** exists, use the plugin (it includes the MCP + more).

**Example: Vercel**

| Approach | What You Get |
|----------|-------------|
| **Just Vercel MCP** | Claude can deploy, check logs, manage env vars |
| **Vercel Plugin (if exists)** | MCP + deployment skills + /deploy command |

**Rule:** Check if a plugin exists FIRST. If yes, use it. If no, use the MCP.

---

## 📋 Complete Recommended Setup

### Step 1: Global Installations (Do Once)

**MCPs (global):**
```bash
# These work the same across ALL projects
claude mcp add --scope user --transport http context7 [url]
claude mcp add --scope user --transport http github [url]
claude mcp add --scope user --transport http sentry https://mcp.sentry.dev/mcp
```

**Plugins (global):**
```bash
# These enhance Claude's capabilities everywhere
/plugin install frontend-design@claude-code-plugin
/plugin install code-review@claude-code-plugin
/plugin install webapp-testing@claude-code-plugin
/plugin install coderabbit@claude-code-plugin  # if using CodeRabbit
```

**Skills (global, in ~/.claude/skills/):**
```bash
# /insights-generated skills go here automatically
# Custom skills you create go here
~/.claude/skills/
  react-component/SKILL.md
  testing-agent/AGENT.md
  sentry-debugger/SKILL.md
```

**Hooks (global, in ~/.claude/settings.json):**
```json
{
  "hooks": [
    {
      "name": "force-skill-loader",
      "event": "PrePrompt",
      "command": "cat ~/.claude/skills/*/SKILL.md .claude/CLAUDE.md 2>/dev/null | head -100"
    }
  ]
}
```

### Step 2: Per-Project Installations (Each Project)

**MCPs with project-specific accounts:**
```bash
cd ~/projects/my-app

# Only add these if the project uses them:
claude mcp add supabase [url]     # Project's Supabase account
claude mcp add stripe [url]       # Project's Stripe keys
claude mcp add postgres [url]     # Project's database
claude mcp add vercel [url]       # Project's Vercel deployment
claude mcp add render [url]       # Project's Render service
claude mcp add flyio [url]        # Project's Fly.io app
```

**Project CLAUDE.md:**
```bash
# Every project gets its own .claude/CLAUDE.md
# Generated by APPLY-SETUP.md workflow
```

**Project hooks (in .claude/settings.json):**
```json
{
  "hooks": [
    {
      "name": "auto-test",
      "event": "PostToolUse",
      "filter": "Edit|Write",
      "prompt": "Run the test suite and report results."
    },
    {
      "name": "auto-format",
      "event": "PostToolUse",
      "filter": "Edit|Write",
      "command": "prettier --write '**/*.{ts,tsx}' 2>/dev/null || true"
    }
  ]
}
```

### Step 3: Summary Table

```
┌─────────────────────┬────────┬─────────┬──────────────────────┐
│ Component           │ Scope  │ Install │ Reason               │
├─────────────────────┼────────┼─────────┼──────────────────────┤
│ GLOBAL (install once, forget)                                 │
├─────────────────────┼────────┼─────────┼──────────────────────┤
│ Context7 MCP        │ user   │ once    │ No account needed    │
│ GitHub MCP          │ user   │ once    │ One GitHub account   │
│ Sentry MCP          │ user   │ once    │ One Sentry, all proj │
│ frontend-design     │ plugin │ once    │ Always useful        │
│ code-review         │ plugin │ once    │ Always useful        │
│ webapp-testing      │ plugin │ once    │ Always useful        │
│ coderabbit          │ plugin │ once    │ Always useful        │
│ Skills in ~/        │ global │ once    │ Your personal skills │
│ skill-loader hook   │ global │ once    │ Fix current bug      │
├─────────────────────┼────────┼─────────┼──────────────────────┤
│ PER-PROJECT (install per project)                             │
├─────────────────────┼────────┼─────────┼──────────────────────┤
│ Supabase MCP        │ local  │ each    │ Different accounts!  │
│ Stripe MCP          │ local  │ each    │ Different keys!      │
│ PostgreSQL MCP      │ local  │ each    │ Different databases! │
│ MongoDB MCP         │ local  │ each    │ Different databases! │
│ Vercel MCP          │ local  │ each    │ Different projects!  │
│ Render MCP          │ local  │ each    │ Different services!  │
│ Fly.io MCP          │ local  │ each    │ Different apps!      │
│ Redis MCP           │ local  │ each    │ Different instances! │
│ CLAUDE.md           │ local  │ each    │ Project-specific     │
│ settings.json hooks │ local  │ each    │ Stack-specific       │
│ Test framework      │ local  │ each    │ Stack-specific       │
└─────────────────────┴────────┴─────────┴──────────────────────┘
```

---

## 🔌 Plugins Deep Dive

### frontend-design (THIS Is What You Were Asking About!)

**What it is:** A plugin that makes Claude generate professional-looking UI

**Auto-invoked:** Yes! When Claude works on frontend code, it automatically activates

**What it does:**
- Bold design choices (not boring defaults)
- Professional typography and spacing
- Proper color palette usage
- Animations and transitions
- Responsive design guidance
- Visual details that make apps feel polished

**Source:** [Medium guide](https://kasata.medium.com/how-to-install-and-use-frontend-design-claude-code-plugin-a-step-by-step-guide-0917d933cc6a)

**Install:**
```bash
/plugin install frontend-design@claude-code-plugin
```

### code-review (Complements CodeRabbit/Greptile)

**What it is:** 5 parallel Sonnet agents that review your code

**Different from CodeRabbit/Greptile:**
- CodeRabbit/Greptile = External tools (review on GitHub/GitLab)
- code-review plugin = Internal Claude Code review (before push)

**They work TOGETHER:**
```
1. You write code
2. code-review plugin checks locally (immediate)
3. You commit and push
4. Greptile reviews on GitHub/GitLab (thorough)
```

**Install:**
```bash
/plugin install code-review@claude-code-plugin
```

### webapp-testing (Playwright)

**What it is:** Claude can open a browser and test your app

**Use cases:**
- "Test the login flow"
- "Check if the checkout page works on mobile"
- "Verify the form validation shows errors correctly"

**Auto-invoked:** When Claude mentions testing a web page

**Install:**
```bash
/plugin install webapp-testing@claude-code-plugin
```

---

## ❓ FAQ

### Q: "Plugin exists AND MCP exists for same tool - which do I use?"

**A: Use the plugin.** It includes the MCP + more.

| Tool | Plugin Exists? | Use |
|------|---------------|-----|
| CodeRabbit | ✅ Yes | Plugin (includes MCP + skill + /command) |
| Sentry | ❌ No (MCP only) | MCP directly |
| Vercel | ✅ Maybe | Check /plugin list, otherwise MCP |
| Stripe | ❌ No (MCP only) | MCP directly |
| Supabase | ❌ No (MCP only) | MCP directly |

### Q: "What if I install globally but need different accounts?"

**A: Local scope OVERRIDES global.**

```bash
# Global: Supabase default account
claude mcp add --scope user supabase [url-with-account-A]

# Project X: Override with different account
cd ~/projects/project-x
claude mcp add supabase [url-with-account-B]
# Local wins! This project uses account B
```

**Better approach:** Don't install account-specific MCPs globally. Only install them locally.

### Q: "Where are plugins stored? Global or local?"

**A: Plugins install globally** (available across all projects).

```bash
# Plugins go to: ~/.claude/plugins/
~/.claude/plugins/
  frontend-design/
  code-review/
  webapp-testing/
  coderabbit/
```

### Q: "Where are skills stored?"

**A: Two locations:**

```bash
# Global skills (available everywhere):
~/.claude/skills/
  my-custom-skill/SKILL.md

# Project skills (only this project):
.claude/skills/
  project-specific-skill/SKILL.md
```

### Q: "Can I see what's installed at each scope?"

```bash
# List all MCPs and their scopes
claude mcp list

# Output shows:
# context7 (user)
# github (user)
# sentry (user)
# supabase (local: ~/projects/my-app)
# stripe (local: ~/projects/my-app)
```

---

## 🔄 Migration: Fix Your Current Setup

### Check Current Installation

```bash
# See what you have now
claude mcp list

# Check global settings
cat ~/.claude.json | python -m json.tool

# Check project settings (in any project)
cd ~/projects/any-project
cat .claude/settings.json 2>/dev/null
cat .mcp.json 2>/dev/null
```

### Recommended Migration

```bash
# 1. Move Context7, GitHub, Sentry to global
claude mcp add --scope user --transport http context7 [url]
claude mcp add --scope user --transport http github [url]
claude mcp add --scope user --transport http sentry https://mcp.sentry.dev/mcp

# 2. Remove Supabase from global (if installed globally)
claude mcp remove --scope user supabase

# 3. Add Supabase locally per project
cd ~/projects/project-a
claude mcp add supabase [url-for-project-a]

cd ~/projects/project-b
claude mcp add supabase [url-for-project-b]

# 4. Install plugins globally
/plugin install frontend-design@claude-code-plugin
/plugin install code-review@claude-code-plugin
/plugin install webapp-testing@claude-code-plugin
```

---

## 📝 Updated Workflow Setup

This file supersedes parts of CORE-SETUP.md regarding installation scope.

### When Setting Up a New Project

```bash
cd ~/projects/new-project

# 1. Global stuff already installed (MCPs + plugins) ✅

# 2. Add project-specific MCPs:
claude mcp add supabase [url]    # if using Supabase
claude mcp add stripe [url]      # if using Stripe
claude mcp add postgres [url]    # if using PostgreSQL
claude mcp add vercel [url]      # if deploying to Vercel
# etc.

# 3. Create project config:
mkdir -p .claude
# Create CLAUDE.md and settings.json (see APPLY-SETUP.md)

# 4. Done! Global plugins + project MCPs + project config = complete setup
```

---

## Resources

- [Claude Code MCP docs](https://code.claude.com/docs/en/mcp)
- [Claude Code plugins docs](https://code.claude.com/docs/en/plugins)
- [IntuitionLabs: Skills vs MCP](https://intuitionlabs.ai/articles/claude-skills-vs-mcp)
- [Medium: Core Concepts](https://medium.com/@diehardankush/become-a-claude-code-hero-core-concepts-of-the-claude-cli-plugins-hooks-skills-mcp-54ae48d7c145)
- [Firecrawl: Top 10 Plugins](https://www.firecrawl.dev/blog/best-claude-code-plugins)
- [alexop.dev: Full Stack Explained](https://alexop.dev/posts/understanding-claude-code-full-stack/)
- [r/ClaudeCode: Plugins take it further](https://www.reddit.com/r/ClaudeCode/comments/1qrlgij/everyones_hyped_on_skills_but_claude_code_plugins/)
- [r/ClaudeCode: Plugin vs Skill difference](https://www.reddit.com/r/ClaudeCode/comments/1qgxpa3/what_is_difference_between_plugins_and_skill/)
