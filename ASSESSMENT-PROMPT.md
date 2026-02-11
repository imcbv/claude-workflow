# Existing Project Assessment Prompt

> **Purpose:** Feed this to Claude Code when working on an existing project to assess and update its setup
> **Usage:** `cat CORE-SETUP.md ASSESSMENT-PROMPT.md | claude` from your project directory

---

## Assessment Instructions for Claude

You are assessing an existing project to align it with modern Claude Code best practices (as of 2026-02-11).

### Step 1: Analyze Current Setup

Please analyze this project and report:

1. **Project Type:**
   - [ ] MVP / Prototype (fast iteration, light testing)
   - [ ] Production (full testing, code review)
   - [ ] Legacy / Refactor (safety-first, heavy testing)

2. **Tech Stack:**
   - Frontend: [React | Next.js | React Native | Other: ___]
   - Backend: [Node | Django | FastAPI | Other: ___]
   - Database: [PostgreSQL | MongoDB | Supabase | Other: ___]
   - Payment: [Stripe | Other: ___]
   - Deployment: [Vercel | Render | Fly.io | AWS | Other: ___]
   - Other: [Redis | Other: ___]

3. **Current Setup (Check what exists):**
   - [ ] `.claude/CLAUDE.md` file
   - [ ] `.claude/settings.json` with hooks
   - [ ] Test framework installed (pytest | vitest | jest | other)
   - [ ] Tests written (count: ___ files)
   - [ ] Code review tool (CodeRabbit | Greptile | None)
   - [ ] Git worktrees in use
   - [ ] MCPs configured (list: ___)

4. **Code Quality:**
   - [ ] Tests passing: ___ / ___ (or N/A if no tests)
   - [ ] Test coverage: ___% (or N/A)
   - [ ] Recent commits have tests
   - [ ] Commits are small and focused
   - [ ] CLAUDE.md has project-specific rules

### Step 2: Identify Gaps

Compare current setup against the recommended setup in CORE-SETUP.md. List missing components:

**Missing Critical Components:**
- [ ] CLAUDE.md configuration
- [ ] Hooks for automated testing
- [ ] Test framework
- [ ] Code review integration
- [ ] Recommended MCPs for this stack
- [ ] Other: ___

**Missing Optional Components:**
- [ ] Git worktrees setup
- [ ] Testing agent
- [ ] Stack-specific skills
- [ ] Other: ___

### Step 3: Recommend Changes

Based on the project type and gaps, recommend:

1. **Immediate Actions (Do Now):**
   ```
   Example:
   - Create .claude/CLAUDE.md with project rules
   - Add hooks for auto-testing (this is production code)
   - Install pytest and write tests for payment logic (critical path)
   ```

2. **Short-Term Actions (This Week):**
   ```
   Example:
   - Set up Greptile for code review (unlimited repos)
   - Configure Stripe MCP (you use payments)
   - Create worktrees for parallel work on features X and Y
   ```

3. **Long-Term Actions (This Month):**
   ```
   Example:
   - Increase test coverage from 30% to 80% on critical paths
   - Refactor to use consistent commit patterns
   - Document architecture in CLAUDE.md
   ```

4. **Optional / Nice-to-Have:**
   ```
   Example:
   - Set up /insights to generate custom skills
   - Try parallel worktrees workflow
   - Add pre-commit hooks for formatting
   ```

### Step 4: Generate Setup Files

Create the missing files needed for this project:

**If CLAUDE.md is missing:**
```markdown
Create .claude/CLAUDE.md with:
- Project name and stack
- Testing strategy (based on project type)
- Commit rules
- Code review standards
- Current focus areas
```

**If settings.json is missing:**
```json
Create .claude/settings.json with:
- Appropriate hooks for project type
- Skill loading hook (fix current bug)
- Testing hooks (if production project)
```

**If .gitmessage is missing:**
```
Create .gitmessage template with:
- Conventional commits format
- Co-authored-by Claude line
```

### Step 5: Prioritize by Project Type

**If MVP/Prototype:**
- Focus: Speed > Safety
- Skip: Heavy testing, code review
- Add: CLAUDE.md (minimal), basic hooks
- Estimated time: 15-30 minutes

**If Production:**
- Focus: Safety > Speed
- Add: Everything (tests, hooks, code review, MCPs)
- Estimated time: 2-4 hours initial setup

**If Legacy/Refactor:**
- Focus: Safety > Speed
- Add: Tests FIRST (as safety net), then refactor tools
- Estimated time: 4-8 hours initial setup

### Step 6: Action Plan

Generate a step-by-step action plan I can execute:

```markdown
## Action Plan for [PROJECT_NAME]

### Phase 1: Critical Setup (Do Now - 30 min)
1. [ ] Create .claude/CLAUDE.md
   - Copy template from CORE-SETUP.md
   - Fill in: [specific details to add]

2. [ ] Create .claude/settings.json
   - Add hooks: [specific hooks for this project type]

3. [ ] [Other immediate actions]

### Phase 2: Testing Setup (This Week - 2 hours)
1. [ ] Install test framework: [specific command]
2. [ ] Write first tests for: [specific critical paths]
3. [ ] Configure auto-test hook

### Phase 3: Code Review (This Week - 1 hour)
1. [ ] Set up [CodeRabbit | Greptile | Both]
2. [ ] Configure review rules in CLAUDE.md

### Phase 4: Optimization (This Month)
1. [ ] Set up git worktrees for parallel work
2. [ ] Run /insights to generate custom skills
3. [ ] Increase test coverage to 80% on [specific areas]

Total Estimated Time: [X hours]
```

---

## Example Output (What I Expect)

```markdown
# Assessment: my-saas-app

## Current State
- **Type:** Production (live app with paying users)
- **Stack:** Next.js + FastAPI + PostgreSQL + Stripe + Vercel
- **Setup:** Partial (has CLAUDE.md but no hooks, 30% test coverage)

## Gaps Identified
❌ No hooks for automated testing
❌ No code review tool
❌ Missing MCPs: Stripe, PostgreSQL, Vercel
❌ Test coverage too low for production (30% vs recommended 80%)
⚠️ Not using git worktrees (could work faster)

## Recommendations

### IMMEDIATE (Do Now - 30 min)
1. Add hooks to .claude/settings.json:
   - Auto-test hook (this is production)
   - Skill loading hook (fix current bug)

2. Update CLAUDE.md with:
   - "Production code requires tests BEFORE implementation"
   - Stripe payment validation rules

### THIS WEEK (2-3 hours)
1. Install Greptile ($30/month for unlimited repos)
   - You have 20+ repos, this makes sense
   - Catches 3x more bugs than alternatives

2. Add MCPs:
   - Stripe (you use payments heavily)
   - PostgreSQL (your database)
   - Vercel (your deployment platform)

3. Write tests for payment flows (CRITICAL - 0% coverage now)
   - Stripe webhook handling
   - Subscription creation
   - Payment failures

### THIS MONTH (8-10 hours)
1. Increase test coverage from 30% to 80% on:
   - API routes (/app/api/*)
   - Payment logic (lib/stripe.ts)
   - Auth (lib/auth.ts)

2. Set up git worktrees:
   - Main: Production hotfixes
   - Feature: New dashboard
   - Refactor: API cleanup

3. Run /insights after 20+ sessions

## Generated Files

I'll create these files for you now:

[Claude then generates the actual .claude/CLAUDE.md, .claude/settings.json, etc.]
```

---

## After Assessment

Once Claude generates the action plan and files:

1. **Review the plan** - Does it make sense for this project?
2. **Ask questions** - "Why do you recommend Greptile over CodeRabbit?" etc.
3. **Execute phase by phase** - Don't try to do everything at once
4. **Test the setup** - Verify hooks work, tests run, etc.

---

## Usage Examples

### For a New-To-You Project

```bash
cd ~/projects/inherited-app
cat ~/Documents/Code/claude-workflow/CORE-SETUP.md \
    ~/Documents/Code/claude-workflow/ASSESSMENT-PROMPT.md | claude
```

### For a Project You Built 6 Months Ago

```bash
cd ~/projects/old-mvp-now-production
cat ~/Documents/Code/claude-workflow/CORE-SETUP.md \
    ~/Documents/Code/claude-workflow/ASSESSMENT-PROMPT.md | claude

# "This started as MVP but now has paying users. Upgrade to production setup."
```

### For Regular Check-Ins

```bash
# Every 30 days, reassess
cd ~/projects/my-app
cat ~/Documents/Code/claude-workflow/ASSESSMENT-PROMPT.md | claude

# "Check if our setup is still aligned with current best practices"
```

---

## Next Steps After Assessment

1. Execute the action plan Claude generated
2. Commit the new setup files:
   ```bash
   git add .claude/ .gitmessage
   git commit -m "chore: Update Claude Code setup to 2026-02 standards

   - Add CLAUDE.md with project rules
   - Configure hooks for auto-testing
   - Set up testing framework
   - Add code review integration

   Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
   ```

3. Test the setup:
   ```bash
   # Try the auto-test hook
   echo "test" > test.txt
   git add test.txt
   # Hook should run

   # Try Claude Code with new CLAUDE.md
   claude
   # "Read our CLAUDE.md and summarize the key rules"
   ```

4. Document what worked / didn't work
   - Update CLAUDE.md with learnings
   - Contribute back to this repo if you find improvements
