# Workflow Update Process (Every 30 Days)

> **Purpose:** Keep this workflow aligned with latest best practices from the community
> **Next Update Due:** 2026-03-13
> **Method:** `/last30days` skill + research synthesis

---

## Why Update Every 30 Days?

**The pace of change (Evidence from this research):**
- Feb 5: /insights feature released (auto-generates skills)
- Feb 4: Opus 4.6 shipped (regression: asks before commits)
- Feb 3: Worktrees + tmux workflow went viral (212 upvotes)
- Jan 26: TDD paradigm shift ("tests = guardrails for AI output")

**30 days = enough time for new patterns to emerge, not so long you fall behind.**

---

## The Update Workflow

### Step 1: Run /last30days Research (60-90 minutes)

Open Claude Code and run targeted research:

```bash
# Terminal 1: General setup
/last30days recommended claude code setup indie hacker 2026

# Terminal 2: Testing updates
/last30days claude code testing TDD best practices

# Terminal 3: Code review tools
/last30days coderabbit greptile AI code review

# Terminal 4: Frontend/backend specific
/last30days claude code [your main stack] best practices
# Example: "claude code next.js fastapi best practices"

# Terminal 5: Git workflow
/last30days git worktrees parallel agents claude code
```

**Expected output:** Research summaries from Reddit, X, and Web across last 30 days

**Save outputs:**
```bash
# Create dated research folder
mkdir -p ~/Documents/Code/claude-workflow/research/2026-03-13

# Copy/paste research outputs into markdown files
```

### Step 2: Synthesize Findings (30-45 minutes)

Read through all research outputs and identify:

**1. New Tools / Features**
- Example: "/insights skill" (discovered Feb 2026)
- Example: "New plugin for X with Y community adoption"

**2. Changed Recommendations**
- Example: "Opus 4.6 regression - revert to 4.5 for now"
- Example: "TDD overhead reduced from 30% to 5% with AI"

**3. Deprecated Practices**
- Example: "CLAUDE.md being ignored (bug) - use hooks instead"
- Example: "Sequential workflow replaced by parallel worktrees"

**4. New Pain Points**
- Example from research: "Skills not loading reliably"
- Example: "Opus 4.6 asks permission for everything"

**5. Top Voices to Follow**
- Example: @cptn3mox (insights feature), @kellypeilinchan (worktrees)
- Example: r/ClaudeCode threads with 100+ upvotes

### Step 3: Update Documentation (45-60 minutes)

For each finding, update relevant files:

#### If New Tool/Feature:

**Add to CORE-SETUP.md:**
```markdown
## [New Section or Update Existing]

### New: [Feature Name]

**What it does:** [Brief description]
**Why it matters:** [Use case]
**How to use:** [Commands/setup]
**Source:** [Link + engagement metrics]
**Added:** 2026-03-13
```

#### If Changed Recommendation:

**Update existing section:**
```markdown
### [Section Name]

~~Old recommendation (deprecated 2026-03-13):~~
~~[Old advice]~~

**Current recommendation (as of 2026-03-13):**
[New advice]

**Why the change:** [Reason from research]
**Source:** [Link]
```

#### If Bug/Workaround:

**Add to CORE-SETUP.md > Current Issues:**
```markdown
## Current Bug Alert (Updated 2026-03-13)

**[Bug Name]:**
- **What:** [Description]
- **Since:** [Date discovered]
- **Impact:** [Who it affects]
- **Workaround:** [Temporary fix]
- **Status:** [Still broken | Fixed in version X]
- **Source:** [Reddit thread / X post with engagement]
```

#### Update All "Last Updated" Dates:

```bash
# In each .md file, update:
> **Last Updated:** 2026-03-13
> **Next Review:** 2026-04-13
```

### Step 4: Update Project Templates (If Needed)

If new stack-specific best practices emerge:

```bash
# Update relevant template in PROJECT-TEMPLATES/
# Example: New Next.js 16 patterns
vim PROJECT-TEMPLATES/fullstack-web.md
```

### Step 5: Update MCP Modules (If New MCPs Released)

```bash
# Check for new official MCPs:
# - Stripe updates
# - New deployment platforms (e.g., Railway MCP)
# - New database integrations

# Add to MCP-MODULES/ if relevant
```

### Step 6: Test Changes (30 minutes)

Apply updates to a test project:

```bash
# Pick one of your projects to test on
cd ~/projects/test-project

# Apply updated setup
cat ~/Documents/Code/claude-workflow/CORE-SETUP.md | claude

# "Update this project with the latest 2026-03-13 recommendations"

# Verify:
# - Hooks still work
# - CLAUDE.md is read
# - Tests run automatically
# - New features work as described
```

### Step 7: Commit and Tag (5 minutes)

```bash
cd ~/Documents/Code/claude-workflow

git add .
git commit -m "Update: 2026-03-13 workflow review

Key changes:
- Added: [new feature/tool]
- Updated: [changed recommendation]
- Fixed: [workaround for bug]
- Sources: [key Reddit threads, X posts]

Research from /last30days across Reddit, X, Web:
- [metric] Reddit threads
- [metric] X posts
- [metric] upvotes/likes analyzed

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"

# Tag the version
git tag -a v2026-03-13 -m "Monthly workflow update"

git push origin main --tags
```

### Step 8: Share (Optional, 10 minutes)

If you made significant discoveries:

1. **Post to r/ClaudeCode:**
   ```markdown
   Title: "Workflow Update (Mar 2026): New /insights feature, worktrees setup, TDD changes"

   I maintain a public workflow repo for indie hackers managing multiple projects.
   Here's what changed this month based on /last30days research:

   - [Key finding 1]
   - [Key finding 2]
   - [Key finding 3]

   Full repo: [link]
   ```

2. **Tweet (X):**
   ```
   Monthly #ClaudeCode workflow update 🚀

   Top 3 changes:
   • [Finding 1]
   • [Finding 2]
   • [Finding 3]

   Research from [N] Reddit threads + [N] X posts

   Full breakdown: [repo link]
   ```

---

## Automation Setup (Recommended)

### Calendar Reminder

```bash
# macOS Calendar
open -a Calendar
# Create recurring event: "Claude Workflow Update" every 30 days

# OR use a cron-like service
# launchd on macOS, systemd on Linux
```

### Automated Reminder Script

Create `~/Documents/Code/claude-workflow/scripts/remind.sh`:

```bash
#!/bin/bash

LAST_UPDATE=$(git log -1 --format=%cd --date=short)
NEXT_UPDATE=$(date -j -v+30d -f "%Y-%m-%d" "$LAST_UPDATE" "+%Y-%m-%d")
TODAY=$(date "+%Y-%m-%d")

if [[ "$TODAY" == "$NEXT_UPDATE" ]]; then
  osascript -e 'display notification "Time to update your Claude workflow!" with title "Workflow Update Due"'

  echo "📅 Claude Workflow Update Due!"
  echo ""
  echo "Run these commands:"
  echo "  cd ~/Documents/Code/claude-workflow"
  echo "  cat UPDATE-WORKFLOW.md"
  echo "  /last30days recommended claude code setup indie hacker"
  echo ""
  echo "Last update: $LAST_UPDATE"
fi
```

Run daily:

```bash
# Add to crontab
crontab -e

# Add line:
0 9 * * * ~/Documents/Code/claude-workflow/scripts/remind.sh
```

---

## Research Archive Structure

Keep historical research for reference:

```
claude-workflow/
└── research/
    ├── 2026-02-11/
    │   ├── setup-general.md
    │   ├── testing-workflow.md
    │   ├── code-review-tools.md
    │   └── git-worktrees.md
    ├── 2026-03-13/
    │   ├── setup-general.md
    │   ├── new-mcp-servers.md
    │   └── frontend-patterns.md
    └── README.md  # Index of all research cycles
```

---

## What to Look For in Research

### Green Flags (Update Recommended)

✅ **High engagement** (100+ upvotes, 10+ likes)
✅ **Multiple sources agree** (Reddit + X + Web all say same thing)
✅ **From core team** (@bcherny, @anthropic handles)
✅ **Solves a pain point** you currently experience
✅ **Battle-tested** (worked in production for others)

### Red Flags (Skip or Wait)

❌ **One-off suggestion** (1 person said it, no validation)
❌ **Contradicts other sources** (Reddit says yes, X says no)
❌ **Unproven** (released yesterday, no user reports)
❌ **Clickbait** ("This ONE TRICK changed everything!")
❌ **Vendor marketing** (disguised as advice)

### Example Decision:

**Finding:** "Use ZeroRules + SkillFence for Claude Code"
- **Engagement:** 61 upvotes (r/ClaudeAI)
- **Sources:** 1 Reddit thread
- **Age:** Released this week
- **Verdict:** ⚠️ Wait 30 days - promising but unproven

**Finding:** "Git worktrees for parallel agents"
- **Engagement:** 212 upvotes (r/ClaudeAI), 21 likes (X), multiple guides
- **Sources:** Reddit, X, Builder.io official guide
- **Age:** Discussed for months, recently surged
- **Verdict:** ✅ Add immediately - proven pattern

---

## Dealing with Breaking Changes

### If Core Setup Changes Dramatically

Example: "Claude Code deprecates CLAUDE.md, replaces with .claude.yaml"

**Response:**
1. **Document both approaches** (old and new)
2. **Add migration guide:**
   ```markdown
   ## Migration: CLAUDE.md → .claude.yaml

   **If you're on CLAUDE.md (before 2026-03-13):**
   [migration steps]

   **If you're starting fresh:**
   [use new approach]
   ```

3. **Update ASSESSMENT-PROMPT.md** to detect old setup
4. **Add to changelog:**
   ```markdown
   ### BREAKING CHANGE (2026-03-13)
   CLAUDE.md deprecated in favor of .claude.yaml
   See migration guide in CORE-SETUP.md
   ```

### If Recommended Tool Gets Acquired/Shut Down

Example: "CodeRabbit acquired by Microsoft, shutting down in 90 days"

**Response:**
1. **Immediate update:** Mark as deprecated
2. **Research alternatives:**
   ```bash
   /last30days coderabbit alternatives 2026
   ```
3. **Update CODE-REVIEW.md:**
   ```markdown
   ## CodeRabbit (DEPRECATED as of 2026-03-13)

   ⚠️ CodeRabbit is shutting down on 2026-06-13.

   **Migration options:**
   - Greptile (recommended, similar features + more)
   - [Alternative 2]
   - [Alternative 3]

   See migration guide below.
   ```

---

## Metrics to Track

Optional but helpful to measure improvement:

**Before update:**
- Time to ship feature: ___
- Bug rate: ___ bugs per 100 LOC
- Test coverage: ___%
- Code review time: ___

**After update:**
- Time to ship feature: ___ (Δ ___)
- Bug rate: ___ (Δ ___)
- Test coverage: ___ (Δ ___)
- Code review time: ___ (Δ ___)

**Example:**
```
Feb 2026 update added:
- Parallel worktrees → 40% faster feature delivery
- Auto-test hooks → 60% fewer bugs in production
- Greptile review → Caught 12 critical bugs before merge
```

---

## Quick Update Checklist

Use this for your monthly update:

```markdown
## Update Checklist - [DATE]

### Research (90 min)
- [ ] Run /last30days on general setup
- [ ] Run /last30days on testing
- [ ] Run /last30days on code review
- [ ] Run /last30days on git workflow
- [ ] Run /last30days on [primary stack]
- [ ] Save outputs to research/[DATE]/

### Synthesis (45 min)
- [ ] Identify new tools/features
- [ ] Identify changed recommendations
- [ ] Identify deprecated practices
- [ ] Identify new pain points
- [ ] Note top voices to follow

### Documentation (60 min)
- [ ] Update CORE-SETUP.md
- [ ] Update TESTING-GUIDE.md (if relevant)
- [ ] Update GIT-WORKFLOW.md (if relevant)
- [ ] Update CODE-REVIEW.md (if relevant)
- [ ] Update PROJECT-TEMPLATES/ (if relevant)
- [ ] Update MCP-MODULES/ (if relevant)
- [ ] Update all "Last Updated" dates

### Testing (30 min)
- [ ] Apply to test project
- [ ] Verify hooks work
- [ ] Verify tests run
- [ ] Verify new features work

### Commit & Share (15 min)
- [ ] Git commit with detailed message
- [ ] Tag version (v[DATE])
- [ ] Push to GitHub
- [ ] Share to r/ClaudeCode (optional)
- [ ] Tweet summary (optional)

**Total Time:** ~3.5 hours
**Next Update:** [DATE + 30 days]
```

---

## Emergency Updates (Between Monthly Cycles)

If critical bug or breaking change:

1. **Immediate patch:**
   ```bash
   cd ~/Documents/Code/claude-workflow
   # Update relevant file with warning
   git commit -m "URGENT: [issue] workaround"
   git tag -a emergency-[DATE] -m "Critical update"
   git push
   ```

2. **Notify in README:**
   ```markdown
   ## ⚠️ URGENT UPDATE (2026-02-20)
   [Description of issue]
   [Workaround]
   [Expected fix date]
   ```

3. **Post to r/ClaudeCode:**
   ```
   PSA: [Issue] affecting [who]
   Workaround: [quick fix]
   Details: [link to repo]
   ```

---

## Resources for Research

### Primary Sources
- r/ClaudeCode
- r/ClaudeAI
- X (search: "claude code" filter:follows OR from:anthropicai)
- [code.claude.com/docs](https://code.claude.com/docs)

### Secondary Sources
- Builder.io blog
- QuantumByte blog
- Apidog guides
- Medium (tag: claude-code)

### Tools for Research
- `/last30days` skill (this repo)
- Reddit search: `site:reddit.com/r/ClaudeCode [topic] after:2026-02-11`
- X advanced search: `claude code min_faves:5 since:2026-02-11`

---

**Next update scheduled:** 2026-03-13
**Reminder set:** Calendar + daily cron check
**Archive:** research/2026-02-11/
