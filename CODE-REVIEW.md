# Code Review: CodeRabbit + Greptile Setup

> **Last Updated:** 2026-02-11
> **Research:** Reddit (r/coderabbit), X (Greptile vs CodeRabbit comparison)

---

## Why External Code Review?

> "With multiple agents spitting out code at insane rates, it really isn't practical to manually review each line, but the use of AI code reviewers like CodeRabbit and Greptile can definitely help." - @msaaddev

**The reality:** Claude Code can write 1000+ lines/hour. You need automated review.

**Two-tool strategy:**
1. **CodeRabbit:** Fast feedback, integrates with Claude Code, less noise
2. **Greptile:** Catches 3x more bugs, full codebase context, unlimited repos

---

## CodeRabbit Setup

### Step 1: Install GitHub App

1. Go to [coderabbit.ai](https://www.coderabbit.ai/)
2. Install GitHub app on your repos
3. Configure which repos to review

### Step 2: Install Claude Code Plugin

```bash
# Install the CodeRabbit CLI
npm install -g @coderabbitai/cli

# Authenticate
coderabbit login

# Install Claude Code plugin
# Add to your Claude Code plugins directory
```

**Source:** [CodeRabbit Claude Code docs](https://docs.coderabbit.ai/cli/claude-code-integration)

### Step 3: Configure CLAUDE.md

CodeRabbit reads your `CLAUDE.md` for context. Add:

```markdown
# .claude/CLAUDE.md

## Code Review Standards (for CodeRabbit)

### Style Guide
- React: Functional components, hooks, TypeScript strict mode
- Python: Type hints, Black formatting, max line length 88
- API: RESTful patterns, versioning in URL (/api/v1/)

### Architecture Patterns
- Feature-based folders (not type-based)
- Components: /components/[feature]/[Component].tsx
- APIs: /app/api/[version]/[resource]/route.ts

### Security Requirements
- Never commit API keys
- Validate all user inputs
- Use parameterized queries (prevent SQL injection)
- HTTPS only for production

### What to Flag
- 🚨 Security vulnerabilities
- 🚨 Performance issues (N+1 queries, missing indexes)
- ⚠️ Logic errors
- ⚠️ Missing error handling
- 📝 Code style violations (if egregious)

### What to Ignore
- Minor style preferences (spaces vs tabs)
- Subjective refactoring suggestions
- "Consider using X library" (unless security/performance)
```

**Source:** [CodeRabbit docs](https://docs.coderabbit.ai/cli/claude-code-integration) - "CodeRabbit automatically reads your claude.md file"

### Step 4: Use in Claude Code

```bash
# Review all changes
/coderabbit:review

# Review only committed changes
/coderabbit:review --committed

# Review only uncommitted changes
/coderabbit:review --uncommitted

# Compare against specific branch
/coderabbit:review --base=main
```

**What happens:**
1. CodeRabbit analyzes changes
2. Surfaces issues with context
3. Claude Code sees the feedback
4. Claude Code fixes issues automatically
5. Cycle repeats until clean

**Source:** [GitHub: coderabbit-fix-flow-plugin](https://github.com/alchemiststudiosDOTai/coderabbit-fix-flow-plugin) - "Claude Code systematically works through the task list, implementing fixes for each CodeRabbit finding."

### Step 5: Automate with Hooks (Optional)

Add to `.claude/settings.json`:

```json
{
  "hooks": [
    {
      "name": "auto-coderabbit-review",
      "event": "PreGitCommit",
      "command": "coderabbit review --uncommitted --quiet || true"
    }
  ]
}
```

**What this does:**
- Before every git commit, CodeRabbit reviews
- Catches issues BEFORE they enter git history
- `|| true` ensures commit doesn't fail if CodeRabbit finds issues (just warns)

---

## Greptile Setup

### Step 1: Sign Up

1. Go to [greptile.com](https://www.greptile.com/)
2. Choose plan:
   - **Cloud Plan:** $30/month, unlimited repos
   - **Enterprise:** Custom pricing, self-hosted

**For you:** Cloud Plan (unlimited repos, both GitHub AND GitLab)

**Source:** [Greptile pricing](https://www.greptile.com/docs/integrations/github-gitlab-integration) - "Hosted subscription billed per active developer per month, includes unlimited repositories and reviews"

### Step 2: Connect GitHub

1. In Greptile dashboard, click "Connect GitHub"
2. Authorize the Greptile app
3. Select repos (or "All repos")

### Step 3: Connect GitLab (For Your GitLab Repos)

1. In Greptile dashboard, click "Add GitLab"
2. Create a GitLab group access token:
   ```
   GitLab → Group Settings → Access Tokens
   Name: Greptile
   Role: Developer
   Scopes: api, read_repository
   ```
3. Paste token in Greptile
4. Configure webhook:
   ```
   GitLab → Group Settings → Webhooks
   URL: [Greptile provides this]
   Trigger: Merge requests
   ```

**Source:** [Greptile GitLab docs](https://www.greptile.com/docs/integrations/github-gitlab-integration)

### Step 4: Configure Review Settings

In Greptile dashboard:

```yaml
Review Triggers:
  - On PR/MR creation: ✓
  - On PR/MR update: ✓
  - On specific label: "needs-review"

Review Scope:
  - Full codebase context: ✓
  - Diff-only mode: ✗

Focus Areas:
  - Security vulnerabilities: High priority
  - Logic errors: High priority
  - Performance issues: Medium priority
  - Style: Low priority

Auto-approve:
  - If zero issues found: ✗ (still want human review)
```

### Step 5: How Reviews Work

**When you open a PR:**

1. **Greptile analyzes:**
   - Your PR diff
   - ENTIRE codebase for context
   - Related functions, components, dependencies

2. **Greptile comments on GitHub/GitLab:**
   ```
   🐛 Bug detected in payment.ts:42
   The `amount` parameter is not validated. This could allow
   negative payments or amounts > MAX_SAFE_INTEGER.

   Context: This function is called from 3 places:
   - checkout.ts:78
   - subscription.ts:123
   - refund.ts:45

   Suggested fix:
   if (amount <= 0 || amount > MAX_SAFE_INTEGER) {
     throw new Error('Invalid amount');
   }
   ```

3. **You review in a worktree:**
   ```bash
   git worktree add ../review-pr-123 pr/feature-branch
   cd ../review-pr-123
   claude

   # "Fix the issues Greptile found in the payment logic"
   ```

4. **Push fixes, Greptile re-reviews**

---

## CodeRabbit vs Greptile: When to Use Which

### Use CodeRabbit When:

- ✅ You're working solo in a Claude Code session
- ✅ You want immediate feedback (before commit)
- ✅ You prefer less noise, faster iteration
- ✅ GitHub-only workflow

**Workflow:**
```bash
# Inside Claude Code
/coderabbit:review
# "Fix the 3 issues CodeRabbit found"
# Commit
```

### Use Greptile When:

- ✅ Reviewing PRs from team members (including non-technical via Lovable)
- ✅ Need maximum bug detection (82% vs CodeRabbit's 44%)
- ✅ Complex changes affecting multiple parts of codebase
- ✅ GitLab repos (Greptile supports, CodeRabbit doesn't)
- ✅ Unlimited repos (you have 20+)

**Workflow:**
```bash
# After opening PR on GitHub/GitLab
# Greptile auto-reviews, comments on PR
# You read comments, fix in worktree
gh pr view 123  # See Greptile's comments
```

**Source:** [Greptile vs CodeRabbit comparison](https://www.greptile.com/greptile-vs-coderabbit) - "Greptile caught 82% of test issues vs. CodeRabbit's 44%"

---

## The Complete Review Workflow

### For Solo Development (You Working Alone)

```mermaid
1. Write code with Claude Code
2. /coderabbit:review (before commit)
3. Claude fixes issues
4. Commit
5. Push to branch
6. Open PR
7. Greptile reviews (GitHub/GitLab)
8. If issues: fix in worktree
9. Merge
```

### For Team PRs (Non-Technical via Lovable)

```mermaid
1. Team member creates feature in Lovable
2. Lovable opens PR on GitHub
3. Greptile auto-reviews, comments
4. You get notification
5. Review Greptile's comments
6. Create worktree: git worktree add ../review-pr-123 pr/lovable-feature
7. Claude Code fixes issues
8. Push fixes
9. Greptile re-reviews
10. Merge
```

---

## Comparison Table

| Feature | CodeRabbit | Greptile |
|---------|-----------|----------|
| **Bug Detection** | 44% catch rate | 82% catch rate |
| **Context** | PR diff only | Full codebase |
| **Speed** | Very fast | Slower (more thorough) |
| **Noise** | Low (fewer comments) | Higher (more findings) |
| **Claude Code Integration** | ✅ `/coderabbit:review` | ❌ GitHub/GitLab only |
| **GitHub Support** | ✅ | ✅ |
| **GitLab Support** | ❌ | ✅ |
| **Unlimited Repos** | ❌ (per-seat pricing) | ✅ ($30/month) |
| **Self-Hosting** | ❌ | ✅ (Enterprise) |
| **Best For** | Solo dev, fast iteration | Team PRs, max safety |

**Source:** [Greptile comparison](https://www.greptile.com/greptile-vs-coderabbit), [Medium comparison](https://medium.com/@pantoai/coderabbit-vs-greptile-ai-code-review-tools-compared-8b535666f708)

---

## Advanced: Combining Both

**Strategy:** Use BOTH for maximum coverage.

```markdown
# Add to .claude/CLAUDE.md:

## Code Review Process

**Before Commit (Local):**
1. /coderabbit:review (catch obvious issues)
2. Fix issues Claude Code finds
3. Commit with descriptive message

**After Push (Remote):**
1. Open PR on GitHub/GitLab
2. Greptile auto-reviews (full codebase context)
3. If issues: create worktree, fix, push
4. Merge when Greptile approves
```

**Why both:**
- CodeRabbit: Fast feedback loop, prevents bad commits
- Greptile: Catches subtle bugs CodeRabbit misses, full codebase analysis

**Cost:** $30/month for Greptile + CodeRabbit free tier (or $30/seat for pro features)

---

## Common Issues

### Issue: "CodeRabbit writes essays of comments"

**Solution:** Update CLAUDE.md with specific review focus:

```markdown
## Code Review: Focus Only On
- 🚨 Security vulnerabilities
- 🚨 Logic errors that break functionality
- ⚠️ Performance bottlenecks

## Code Review: Ignore
- Style preferences
- Refactoring suggestions (unless performance/security impact)
- "Consider using X pattern" unless critical
```

CodeRabbit reads this and adjusts verbosity.

**Source:** @kiknaio (3 likes) - "CodeRabbit is good, but it writes literal essays on PRs."

### Issue: "Greptile too slow for fast iteration"

**Solution:** Use Greptile only for PR reviews, not during development.

```bash
# During dev: Use CodeRabbit
/coderabbit:review  # Fast

# Before merge: Use Greptile
# (Automatic on PR, no manual trigger needed)
```

### Issue: "Both tools conflict in recommendations"

**Example:**
- CodeRabbit: "Extract this into a helper function"
- Greptile: "This logic is fine, don't over-abstract"

**Solution:** Trust Greptile on architecture (it has full codebase context), trust CodeRabbit on style/quick wins.

---

## Alternative: Run Your Own Reviews

If you don't want external tools, automate reviews with Claude Code:

```markdown
# Create ~/.claude/agents/code-reviewer/AGENT.md:

---
name: Code Reviewer
description: Reviews code for bugs, security, performance
---

# Code Reviewer Agent

Before every commit, review the code for:

1. **Security:** SQL injection, XSS, exposed secrets
2. **Logic Errors:** Off-by-one, null pointer, race conditions
3. **Performance:** N+1 queries, missing indexes, unnecessary loops
4. **Edge Cases:** Empty inputs, null values, boundary conditions

Format:
✅ PASS: No issues found
⚠️ WARNING: [Issue] at [file]:[line]
🚨 CRITICAL: [Security/Logic issue] at [file]:[line]
```

Then use a hook:

```json
{
  "hooks": [
    {
      "name": "pre-commit-review",
      "event": "PreGitCommit",
      "agent": "code-reviewer",
      "prompt": "Review all uncommitted changes for bugs, security, and performance issues."
    }
  ]
}
```

**Tradeoff:** Less sophisticated than Greptile, but free and private.

---

## Resources

### CodeRabbit
- [Official docs](https://docs.coderabbit.ai/)
- [Claude Code integration guide](https://docs.coderabbit.ai/cli/claude-code-integration)
- [GitHub plugin](https://github.com/coderabbitai/claude-plugin)

### Greptile
- [Official site](https://www.greptile.com/)
- [GitHub/GitLab integration docs](https://www.greptile.com/docs/integrations/github-gitlab-integration)
- [vs CodeRabbit comparison](https://www.greptile.com/greptile-vs-coderabbit)

### Community Discussions
- [r/coderabbit: How to use in Claude Code](https://www.reddit.com/r/coderabbit/comments/1qut14s/how_to_use_coderabbit_in_claude_code/) (8 upvotes)
- [r/coderabbit: CodeRabbit workflows](https://www.reddit.com/r/coderabbit/comments/1qxtc6j/what_does_your_coderabbit_workflow_look_like/)
- X poll: @Abhinavstwt (34 likes) - "Which code review bot is best?"

---

## Quick Decision Guide

**Choose your setup:**

| Your Situation | Recommended Setup |
|---------------|-------------------|
| Solo dev, 1-5 GitHub repos | CodeRabbit only |
| Solo dev, 20+ mixed repos (GitHub + GitLab) | Greptile only ($30/month unlimited) |
| Team with non-technical contributors | Greptile (catches more bugs) |
| Maximum safety (payments, health, finance) | Both (CodeRabbit + Greptile) |
| Budget-conscious | DIY with Claude Code reviewer agent |

**Your recommendation:** Greptile ($30/month)
- Unlimited repos (you have 20+)
- GitLab support (some of your repos)
- Catches 3x more bugs
- Full codebase context

Add CodeRabbit if you want Claude Code integration for solo work.

---

## Next: Project Templates

See `PROJECT-TEMPLATES/` for stack-specific configurations.
