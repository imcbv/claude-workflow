# Usage Reference: What's Automatic vs What You Invoke

> After running `setup-global.sh`, this is how everything works.

---

## The Three Categories

Everything installed falls into one of three buckets:

| Category | What It Means | You Do... |
|----------|--------------|-----------|
| **Automatic** | Runs silently in the background on every edit/prompt | Nothing. Forget it exists. |
| **You type a command** | Slash commands you invoke when you want them | Type `/command` in Claude Code |
| **Claude uses when relevant** | Claude decides to use these tools based on context | Nothing. Claude figures it out. |

---

## Automatic (Install and Forget)

These activate on every file edit or every prompt. You never think about them.

| Tool | What It Does | How It Works |
|------|-------------|-------------|
| **security-guidance** | Scans every code edit for XSS, injection, secrets, pickle attacks | PreToolUse hook — fires before every Write/Edit |
| **typescript-lsp** | Real-time TypeScript type checking | Background LSP — catches type errors as Claude writes code |
| **pyright-lsp** | Real-time Python type checking | Background LSP — same as above but for Python |
| **frontend-design** | Professional UI: typography, spacing, colors, animations | Skill — Claude reads it and follows it when doing UI work |
| **playwright** | Web testing best practices | Skill — Claude uses it when writing browser tests |
| **auto-test hook** | Runs your test suite after every code edit | PostToolUse hook (project-level, set up by project scripts) |
| **auto-format hook** | Runs prettier/black after every code edit | PostToolUse hook (project-level, set up by project scripts) |
| **skill-loader hook** | Loads CLAUDE.md and skills before every prompt | PrePrompt hook (workaround for CLAUDE.md loading bug) |

**What "automatic" means in practice:**
You say "add a login form" → Claude writes the code → security-guidance checks it for XSS → typescript-lsp checks for type errors → auto-format cleans up formatting → auto-test runs tests → frontend-design ensures good UI patterns. All invisible to you.

---

## You Type a Command (Slash Commands)

These do nothing until you explicitly invoke them. They're powerful workflows behind a single command.

| Command | What It Does | When To Use It |
|---------|-------------|---------------|
| `/commit` | Creates a conventional commit from your staged changes | After you're happy with the code. Say "commit this" or type `/commit` |
| `/commit-push-pr` | Commits + pushes + opens a pull request in one step | When you want to ship a feature to a PR |
| `/clean_gone` | Removes local branches that no longer exist on remote | After merging PRs, to clean up stale branches |
| `/feature-dev` | 7-phase structured feature development with 3 sub-agents | Starting a non-trivial new feature. Say "build auth system" |
| `/pr-review-toolkit:review-pr all` | 6 specialized review agents analyze your code | Before merging a PR. Say "review this PR" |
| `/revise-claude-md` | Captures session learnings and updates CLAUDE.md | End of a work session. Say "update claude md" |
| `/coderabbit:review` | CodeRabbit AI code review | Additional code review perspective |
| `/last30days [topic]` | Researches any topic from Reddit + X + Web (last 30 days) | Monthly updates, researching tools, staying current |
| `/insights` | Auto-generates custom skills based on your working style | Periodically, to let Claude learn your patterns |

**Pro tip:** You don't need to memorize these. Just describe what you want in plain English and Claude will suggest the right command. "Review my code" → Claude suggests `/pr-review-toolkit`. "Commit this" → Claude uses `/commit`.

**Making slash commands semi-automatic:** Add rules to your project's `.claude/CLAUDE.md`:
```markdown
## Workflow Rules
- Before committing: use /commit (commit-commands plugin)
- Before PRs: run /pr-review-toolkit:review-pr all
- End of session: run /revise-claude-md
- New features: use /feature-dev for non-trivial features
```
Now Claude will proactively suggest (or run) these at the right moments.

---

## Claude Uses When Relevant (MCPs)

MCPs (Model Context Protocol) are connections to external services. Once installed, Claude sees them as available tools and uses them when your question matches.

### Global MCPs (installed once, work everywhere)

| MCP | What It Does | When Claude Uses It |
|-----|-------------|-------------------|
| **Context7** | Looks up current documentation for any library | When Claude needs to check how a library works (e.g., "how does Supabase auth work?") |
| **Sentry** | Queries your error tracking dashboard | When you ask about errors, bugs in production, or error trends |

### Project MCPs (installed per-project by setup scripts)

| MCP | What It Does | When Claude Uses It |
|-----|-------------|-------------------|
| **Supabase** | Queries your database, manages tables, checks RLS policies | When working on database operations in a Supabase project |
| **Stripe** | Manages payments, subscriptions, webhooks | When working on payment code |
| **PostgreSQL** | Direct database queries | When working with a Postgres database |
| **Render/Vercel/Fly.io** | Deployment management | When deploying or checking deployment status |

**What "Claude uses when relevant" means in practice:**
You say "check if users table has RLS enabled" → Claude recognizes this needs Supabase MCP → calls the MCP → gives you the answer. You never said "use Supabase MCP" — Claude figured it out.

---

## "What Tools Should I Use?"

You already have a built-in way to ask this. The **claude-code-setup** plugin includes an "automation recommender" skill.

### How to use it:

Just ask Claude in any project:

```
What Claude Code automations should I use for this project?
```

or more specific:

```
What MCP servers would help with this codebase?
What hooks should I set up?
What skills would be useful here?
```

Claude will:
1. Analyze your project (package.json, file structure, dependencies)
2. Recommend the top 1-2 tools per category (MCPs, hooks, skills, plugins)
3. Explain why each one helps YOUR specific project
4. Offer to set them up

### Quick decision guide:

| You're doing... | Claude might suggest... |
|----------------|----------------------|
| Working with a new library | Context7 MCP (already installed globally) |
| Building a frontend | Playwright MCP for testing, frontend-design skill (already installed) |
| Using Supabase/Stripe | Per-project MCP for that service |
| Writing lots of tests | auto-test hook, gen-test skill |
| Deploying frequently | Render/Vercel/Fly.io MCP |
| Tracking errors | Sentry MCP (already installed globally) |

---

## Complete Installed Toolset

### After `setup-global.sh` (runs once)

| # | Name | Type | Behavior |
|---|------|------|----------|
| 1 | security-guidance | plugin | Automatic |
| 2 | typescript-lsp | plugin | Automatic |
| 3 | pyright-lsp | plugin | Automatic |
| 4 | frontend-design | plugin | Automatic |
| 5 | code-review | plugin | Automatic |
| 6 | commit-commands | plugin | `/commit`, `/commit-push-pr`, `/clean_gone` |
| 7 | feature-dev | plugin | `/feature-dev` |
| 8 | pr-review-toolkit | plugin | `/pr-review-toolkit:review-pr` |
| 9 | claude-md-management | plugin | `/revise-claude-md` |
| 10 | playwright | plugin | Automatic |
| 11 | claude-code-setup | plugin | Ask "what tools should I use?" |
| 12 | coderabbit | plugin | `/coderabbit:review` |
| 13 | /last30days | skill | `/last30days [topic]` |
| 14 | Context7 | MCP | Claude uses automatically |
| 15 | Sentry | MCP | Claude uses automatically (needs OAuth once) |
| -- | tmux | system tool | You use it manually for parallel agents |
| -- | TypeScript LSP | system tool | Automatic (used by typescript-lsp plugin) |
| -- | Pyright | system tool | Automatic (used by pyright-lsp plugin) |

### After project setup scripts (per project)

| Name | Type | Behavior |
|------|------|----------|
| auto-test hook | hook | Automatic |
| auto-format hook | hook | Automatic |
| skill-loader hook | hook | Automatic |
| CLAUDE.md | config | Automatic (Claude reads it every session) |
| Project MCPs | MCP | Claude uses automatically |

---

## Updating

Run `/last30days` monthly to check for new tools and practices:

```
/last30days recommended claude code setup indie hacker 2026
/last30days claude code testing TDD best practices
/last30days claude code plugins MCP new releases
```

Or run the update script:
```bash
~/Documents/Code/claude-workflow/scripts/update.sh
```

See [UPDATE-WORKFLOW.md](UPDATE-WORKFLOW.md) for the full monthly process.
