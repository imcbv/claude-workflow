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
- ✅ Work the same across ALL projects
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

**Common Problem: Multi-Account Supabase**

If you install Supabase MCP globally but use different accounts for different projects,
the global config will always point to the same account.

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

## 🔌 Complete Plugin Guide

### How Plugins Trigger (Do I Need to Remember?)

| Trigger Type | How It Works | Example Plugins |
|-------------|-------------|-----------------|
| **AUTOMATIC** | Hook fires on events. Zero effort. | security-guidance, skill-loader |
| **SKILLS (auto)** | Claude sees skills and uses them when relevant. | frontend-design, code-review |
| **SLASH COMMANDS** | You invoke manually (or Claude suggests). | /commit, /feature-dev, /revise-claude-md |
| **LSP (background)** | Language server runs silently. | typescript-lsp, pyright-lsp |

**For slash commands**, add these rules to CLAUDE.md so Claude follows them automatically:
```markdown
## Workflow Rules
- Before committing: use /commit (commit-commands plugin)
- Before PRs: run /pr-review-toolkit:review-pr all
- End of session: run /revise-claude-md
- New features: use /feature-dev for non-trivial features
```

---

### GLOBAL Plugins (Install Once, All Projects)

```bash
# === AUTOMATIC (zero effort) ===

# 1. Security Guidance - Scans code as Claude writes it
/plugin install security-guidance
# Catches: XSS, command injection, eval(), pickle, hardcoded secrets
# PreToolUse hook → fires before every Write/Edit → non-blocking warnings
# Covers: React, Django, FastAPI, Node, GitHub Actions

# 2. TypeScript LSP - Real-time type checking
/plugin install typescript-lsp
# Claude sees type errors instantly after every edit
# 900x faster code navigation than grep
# Requires: npm install -g typescript-language-server typescript

# 3. Pyright LSP - Python type checking
/plugin install pyright-lsp
# Catches type bugs in Django/FastAPI that Claude would miss
# Requires: pip install pyright

# === SKILLS (auto-invoked when relevant) ===

# 4. Frontend Design - Professional UI generation
/plugin install frontend-design
# Auto-activated when Claude works on UI code
# Bold design choices, proper typography, spacing, colors, animations

# 5. Code Review - 5 parallel review agents
/plugin install code-review
# Auto-used during review tasks. CLAUDE.md compliance, bug detection,
# historical context, PR history, code comments quality
# Complements CodeRabbit/Greptile (local review vs GitHub review)

# === SLASH COMMANDS (Claude suggests when appropriate) ===

# 6. Commit Commands - Git workflow
/plugin install commit-commands
# /commit - Conventional Commit from staged diff
# /commit-push-pr - Branch + commit + push + PR in one shot
# /clean_gone - Remove stale local branches

# 7. Feature Dev - Structured 7-phase feature development
/plugin install feature-dev
# /feature-dev - 3 subagents: code-explorer, code-architect, code-reviewer
# Discovery → Exploration → Questions → Design → Implement → Review → Summary
# Overkill for small fixes, perfect for new features

# 8. PR Review Toolkit - 6 specialized review agents
/plugin install pr-review-toolkit
# /pr-review-toolkit:review-pr all
# Agents: comment-analyzer, test-coverage, silent-failure-hunter,
#         type-design, code-reviewer, code-simplifier
# You're your own reviewer - this gives you six.

# 9. Claude MD Management - Keep CLAUDE.md current
/plugin install claude-md-management
# /revise-claude-md - Captures session learnings, proposes CLAUDE.md updates
# Run at end of productive sessions

# 10. CodeRabbit (if you use CodeRabbit)
/plugin install coderabbit
# /coderabbit:review - Bundles MCP + skill + hook

# 11. Playwright - Browser testing
/plugin install playwright
# Claude opens a browser and tests your UI
# Clicks buttons, fills forms, catches visual bugs
```

### PER-PROJECT Plugins (Install Locally When Needed)

These get installed **only on projects that need them**. The project questionnaire
(see APPLY-SETUP.md) determines which ones to install.

```bash
# TDD Enforcement (production projects only)
/plugin install superpowers
# 20+ skills enforcing TDD, YAGNI, planning, subagent-driven dev
# ⚠️ Opinionated: deletes code written before tests
# ⚠️ DO NOT install on MVPs/prototypes - it fights rapid iteration
# WHEN TO USE: Production apps where test coverage matters
# Install per-project, not globally

# Greptile (if using for code review)
/plugin install greptile
```

### QUESTIONNAIRE Plugins (Ask Before Installing)

These plugins are useful but only for specific tools/services. The project
assessment (APPLY-SETUP.md) asks about these:

| Question | If Yes → Install |
|----------|-----------------|
| "Will you use Figma designs?" | `figma` plugin (design-to-code) |
| "Need web scraping/research?" | `firecrawl` plugin (web crawling) |
| "Collaborate via Slack?" | `slack` plugin (trigger Claude from Slack) |
| "Does this project use GitLab?" | `gitlab` plugin (locally) |
| "Does this project use Firebase?" | `firebase` plugin (locally) |
| "Does this project use Pinecone?" | `pinecone` plugin (locally) |
| "Is this a PHP/Laravel project?" | `laravel-boost` + `php-lsp` (locally) |
| "Do you use PostHog analytics?" | `posthog` plugin (locally) |
| "Do you use Notion for specs?" | `Notion` plugin (locally) |
| "Does this project use Docker?" | Docker detection + container workflow |

### SKIP These Plugins

| Plugin | Why Skip |
|--------|---------|
| context7 plugin | You already have Context7 as MCP. Plugin just wraps same MCP. |
| github plugin | `gh` CLI works fine. Plugin adds MCP wrapper with no real gain. |
| explanatory-output-style | Adds token cost every session explaining things you know. |
| learning-output-style | Asks YOU to write code. Designed to slow you down. |
| agent-sdk-dev | Only for building Claude Agent SDK apps. |
| plugin-dev | Only for building Claude Code plugins. |
| playground | Niche visual config tool. Marginal utility. |
| hookify | Claude already writes hooks for you when asked. Buggy. |
| code-simplifier | Token cost (pay twice). Bug modifies string literals. |
| serena | Overlaps with typescript-lsp + pyright-lsp. Connection issues. |
| atlassian | Solo dev, not using Jira/Confluence. |
| linear | Solo dev, not using Linear. |
| asana | Solo dev, not using Asana. |
| circleback | Meeting notes. Solo dev. |
| huggingface-skills | ML/LLM training. Not your use case. |
| sonatype-guide | Low adoption. npm audit/Dependabot sufficient. |
| All irrelevant LSPs | gopls, csharp, rust-analyzer, jdtls, clangd, kotlin, lua, swift |

---

### Plugin vs MCP: When Both Exist

**Example: CodeRabbit**

| Approach | What You Get |
|----------|-------------|
| **Just CodeRabbit MCP** | Claude can talk to CodeRabbit API |
| **Just CodeRabbit Plugin** | MCP + skill + /coderabbit:review command + hook |

**Rule:** If a **plugin** exists, use the plugin (it includes the MCP + more).

**Exception: Context7 and GitHub** - You already have working MCPs for these.
The plugins would just wrap the same MCPs. No reason to switch.

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
# Phase 1: Immediate (zero-config, auto-trigger)
/plugin install security-guidance
/plugin install typescript-lsp    # requires: npm i -g typescript-language-server typescript
/plugin install pyright-lsp       # requires: pip install pyright

# Phase 2: Skills + Commands
/plugin install frontend-design
/plugin install code-review
/plugin install commit-commands
/plugin install feature-dev
/plugin install pr-review-toolkit
/plugin install claude-md-management
/plugin install playwright
/plugin install coderabbit         # if using CodeRabbit
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

**Conditional plugins (based on project questionnaire):**
```bash
# Only install if project needs TDD enforcement:
/plugin install superpowers

# Only install if project-specific service:
/plugin install figma         # If using Figma designs
/plugin install firecrawl     # If need web scraping
/plugin install firebase      # If project uses Firebase
/plugin install gitlab        # If project uses GitLab
/plugin install pinecone      # If project uses vector DB
/plugin install slack         # If collaborating via Slack
```

**Also run claude-code-setup for recommendations:**
```bash
# This plugin analyzes your project and suggests MCPs, skills, hooks
# Run it ONCE per project as a second opinion alongside APPLY-SETUP.md
# It's read-only (never modifies files)
/plugin install claude-code-setup   # install globally once
# Then in your project, Claude auto-suggests based on detected stack
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
┌──────────────────────────┬────────┬─────────┬──────────────────────────────┐
│ Component                │ Scope  │ Install │ Trigger / Reason             │
├──────────────────────────┼────────┼─────────┼──────────────────────────────┤
│ GLOBAL MCPs (install once, forget)                                        │
├──────────────────────────┼────────┼─────────┼──────────────────────────────┤
│ Context7 MCP             │ user   │ once    │ No account needed            │
│ GitHub MCP (gh CLI)      │ user   │ once    │ One GitHub account           │
│ Sentry MCP               │ user   │ once    │ One Sentry, all projects     │
├──────────────────────────┼────────┼─────────┼──────────────────────────────┤
│ GLOBAL PLUGINS (install once, forget)                                     │
├──────────────────────────┼────────┼─────────┼──────────────────────────────┤
│ security-guidance        │ plugin │ once    │ AUTOMATIC (PreToolUse hook)  │
│ typescript-lsp           │ plugin │ once    │ AUTOMATIC (background LSP)   │
│ pyright-lsp              │ plugin │ once    │ AUTOMATIC (background LSP)   │
│ frontend-design          │ plugin │ once    │ SKILLS (auto when UI work)   │
│ code-review              │ plugin │ once    │ SKILLS (auto during review)  │
│ commit-commands          │ plugin │ once    │ COMMANDS: /commit, /commit-  │
│                          │        │         │  push-pr, /clean_gone        │
│ feature-dev              │ plugin │ once    │ COMMAND: /feature-dev        │
│ pr-review-toolkit        │ plugin │ once    │ COMMAND: /pr-review-toolkit  │
│ claude-md-management     │ plugin │ once    │ COMMAND: /revise-claude-md   │
│ playwright               │ plugin │ once    │ SKILLS (auto for web tests)  │
│ coderabbit               │ plugin │ once    │ COMMAND: /coderabbit:review  │
│ Skills in ~/             │ global │ once    │ Your personal skills         │
│ skill-loader hook        │ global │ once    │ AUTOMATIC (PrePrompt hook)   │
├──────────────────────────┼────────┼─────────┼──────────────────────────────┤
│ PER-PROJECT MCPs (install per project)                                    │
├──────────────────────────┼────────┼─────────┼──────────────────────────────┤
│ Supabase MCP             │ local  │ each    │ Different accounts!          │
│ Stripe MCP               │ local  │ each    │ Different keys!              │
│ PostgreSQL MCP           │ local  │ each    │ Different databases!         │
│ MongoDB MCP              │ local  │ each    │ Different databases!         │
│ Vercel MCP               │ local  │ each    │ Different projects!          │
│ Render MCP               │ local  │ each    │ Different services!          │
│ Fly.io MCP               │ local  │ each    │ Different apps!              │
│ Redis MCP                │ local  │ each    │ Different instances!         │
├──────────────────────────┼────────┼─────────┼──────────────────────────────┤
│ PER-PROJECT PLUGINS (questionnaire decides)                               │
├──────────────────────────┼────────┼─────────┼──────────────────────────────┤
│ superpowers              │ local  │ maybe   │ TDD enforcement (prod only)  │
│ figma                    │ local  │ maybe   │ If using Figma designs       │
│ firecrawl                │ local  │ maybe   │ If need web scraping         │
│ slack                    │ local  │ maybe   │ If collaborating via Slack   │
│ gitlab                   │ local  │ maybe   │ If project uses GitLab       │
│ firebase                 │ local  │ maybe   │ If project uses Firebase     │
│ pinecone                 │ local  │ maybe   │ If project uses vector DB    │
│ posthog                  │ local  │ maybe   │ If using PostHog analytics   │
│ laravel-boost + php-lsp  │ local  │ maybe   │ If PHP/Laravel project       │
├──────────────────────────┼────────┼─────────┼──────────────────────────────┤
│ PER-PROJECT CONFIG                                                        │
├──────────────────────────┼────────┼─────────┼──────────────────────────────┤
│ CLAUDE.md                │ local  │ each    │ Project-specific rules       │
│ settings.json hooks      │ local  │ each    │ Stack-specific automation    │
│ Test framework           │ local  │ each    │ Stack-specific               │
└──────────────────────────┴────────┴─────────┴──────────────────────────────┘
```

---

## 🔌 Key Plugins Explained

### security-guidance (AUTOMATIC, zero-config)

**Trigger:** PreToolUse hook fires before every Write/Edit
**What it catches:** XSS (dangerouslySetInnerHTML), command injection (os.system,
child_process.exec), eval(), pickle deserialization, hardcoded secrets,
GitHub Actions injection
**Behavior:** Non-blocking warnings, session-scoped (warns once per pattern)
**Coverage:** React, Django, FastAPI, Node, GitHub Actions

### typescript-lsp + pyright-lsp (AUTOMATIC, background)

**Trigger:** Language server runs silently, checks code after every edit
**What it does:** Real-time type errors → Claude sees and self-corrects immediately.
900x faster code navigation vs grep. ~200-500MB RAM per server.
**Requirements:**
```bash
npm install -g typescript-language-server typescript  # for typescript-lsp
pip install pyright                                   # for pyright-lsp
```

### frontend-design (SKILLS, auto-invoked)

**Trigger:** Auto-activates when Claude works on UI code
**What it does:** Bold design choices, professional typography/spacing/colors,
animations, responsive design. Makes UI look polished, not generic AI-generated.

### commit-commands (COMMANDS)

**Commands:**
- `/commit` - Conventional Commit from staged diff (matches your project's style)
- `/commit-push-pr` - Branch + commit + push + open PR with summary. One shot.
- `/clean_gone` - Remove local branches deleted from remote + their worktrees

### feature-dev (COMMAND, for non-trivial features)

**Command:** `/feature-dev [description]`
**What it does:** 7-phase workflow with 3 subagents:
1. Discovery → 2. Codebase Exploration → 3. Clarifying Questions →
4. Architecture Design → 5. Implementation → 6. Quality Review → 7. Summary
**When to use:** New features. Skip for small bug fixes (overkill).

### pr-review-toolkit (COMMAND, before PRs)

**Command:** `/pr-review-toolkit:review-pr all`
**6 agents:** comment-analyzer, test-coverage, silent-failure-hunter,
type-design-analyzer, code-reviewer, code-simplifier
**Key agent:** silent-failure-hunter catches empty catch blocks, inadequate
logging, inappropriate fallbacks. Critical for solo devs.

### claude-md-management (COMMAND, end of session)

**Command:** `/revise-claude-md`
**What it does:** Captures session learnings (bash commands discovered, code
patterns, environment quirks) and proposes CLAUDE.md updates.
**When to use:** End of productive sessions. Accumulates institutional knowledge.

### superpowers (PER-PROJECT, production only)

**What it does:** 20+ skills enforcing TDD (RED-GREEN-REFACTOR), YAGNI, planning,
subagent-driven development. brainstorm → plan → execute → review pipeline.
**WARNING:** Deletes code written before tests. Fights rapid prototyping.
**Install:** Only on production projects: `/plugin install superpowers`
**Do NOT install on MVPs/prototypes.**

### code-review (SKILLS, auto during review)

**What it is:** 5 parallel Sonnet agents
**Different from CodeRabbit/Greptile:**
- code-review plugin = local review (before push, immediate)
- CodeRabbit/Greptile = external review (on GitHub/GitLab, thorough)

**They work TOGETHER:**
```
1. You write code
2. code-review plugin checks locally (immediate)
3. You commit and push
4. Greptile reviews on GitHub/GitLab (thorough)
```

### claude-code-setup (ONE-TIME per project)

**What it does:** Analyzes your codebase and recommends MCPs, skills, hooks.
Read-only (never modifies files). Use as a second opinion alongside APPLY-SETUP.md.
Run once per project, compare recommendations, take the best of both.

---

## ❓ FAQ

### Q: "Plugin exists AND MCP exists for same tool - which do I use?"

**A: Generally use the plugin.** It includes the MCP + more.

**Exceptions:** If your MCP is already working fine and the plugin just wraps the
same MCP without adding skills/hooks/commands, keep the MCP.

| Tool | Plugin Exists? | Use | Why |
|------|---------------|-----|-----|
| **Context7** | ✅ Yes (community) | **Keep MCP** | Plugin just wraps the same MCP. No extra skills/commands. |
| **GitHub** | ✅ Yes | **Keep `gh` CLI** | `gh` CLI already covers everything. Plugin adds MCP wrapper with no real gain. |
| **CodeRabbit** | ✅ Yes | **Plugin** | Plugin adds skill + /coderabbit:review command + hook on top of MCP. |
| **Sentry** | ✅ Yes | **Plugin or MCP** | Either works. Plugin may add convenience commands. |
| **Vercel** | ✅ Yes | **Plugin** | Check /plugin list for extra features. |
| **Stripe** | ✅ Yes | **Plugin** | Install locally per project (different keys). |
| **Supabase** | ✅ Yes | **Plugin** | Install locally per project (different accounts). |

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

# 4. Install plugins globally (Phase 1: auto-trigger)
/plugin install security-guidance
/plugin install typescript-lsp      # requires: npm i -g typescript-language-server typescript
/plugin install pyright-lsp          # requires: pip install pyright

# 5. Install plugins globally (Phase 2: skills + commands)
/plugin install frontend-design
/plugin install code-review
/plugin install commit-commands
/plugin install feature-dev
/plugin install pr-review-toolkit
/plugin install claude-md-management
/plugin install playwright
/plugin install claude-code-setup    # run once per project for recommendations
/plugin install coderabbit           # if using CodeRabbit
```

---

## 📝 Updated Workflow Setup

This file supersedes parts of CORE-SETUP.md regarding installation scope.

### When Setting Up a New Project

```bash
cd ~/projects/new-project

# 1. Global stuff already installed (MCPs + 12 plugins) ✅

# 2. Run the APPLY-SETUP.md workflow:
#    - Claude auto-detects stack
#    - Answers questionnaire (Figma? Firecrawl? Slack? Firebase? etc.)
#    - Runs claude-code-setup plugin for second opinion
#    - Generates CLAUDE.md + settings.json

# 3. Add project-specific MCPs:
claude mcp add supabase [url]    # if using Supabase
claude mcp add stripe [url]      # if using Stripe
claude mcp add postgres [url]    # if using PostgreSQL
claude mcp add vercel [url]      # if deploying to Vercel
# etc.

# 4. Add conditional plugins (from questionnaire):
/plugin install superpowers       # if production app with TDD
/plugin install figma             # if using Figma designs
/plugin install firecrawl         # if need web scraping
# etc.

# 5. Done! Global plugins + project MCPs + project plugins + config = complete
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
