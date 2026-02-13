# Error Tracking: Sentry MCP Setup

> **Last Updated:** 2026-02-11
> **MCP Status:** ✅ Official, Production-Ready (50M+ requests/month)
> **Setup Time:** 15-20 minutes (first time), 5 minutes (subsequent projects)

---

## 🎯 What This Does

**Connects Claude Code to Sentry** so Claude can:
- Read production errors and debug them
- Analyze stack traces and suggest fixes
- Monitor performance issues
- Track errors across releases
- Auto-fix bugs from Sentry issues

**Real user quote:**
> "Started using Sentry MCP with Claude - it reads issues, understands error context, and resolves them." - @kevinlegui_

---

## 📋 Table of Contents

1. [Sentry Account Setup](#sentry-account-setup) (Skip if you already have Sentry)
2. [Project Configuration](#project-configuration)
3. [Monorepo Setup](#monorepo-setup) (Multiple projects in one repo)
4. [MCP Installation](#mcp-installation)
5. [SDK Integration](#sdk-integration) (Per project type)
6. [Claude Code Integration](#claude-code-integration)
7. [Testing](#testing)
8. [Troubleshooting](#troubleshooting)

---

## 1. Sentry Account Setup

### If You DON'T Have Sentry Yet

**Step 1: Create Account**
1. Go to [sentry.io](https://sentry.io/)
2. Sign up (free tier: 5K events/month, good for 1-2 projects)
3. Verify email

**Step 2: Create Organization**
```
Organization Name: [Your name or company]
Example: "MyStartup" or "JohnDoe"
```

**Pricing:**
- **Developer (Free):** 5K errors/month, 1 project
- **Team ($26/month):** 50K errors/month, unlimited projects
- **Business ($80/month):** 100K errors/month, performance monitoring

**Recommendation for indie hackers with 20+ projects:**
- Start with **Team plan** ($26/month)
- Unlimited projects (perfect for your setup)
- Can track errors across all your apps

### If You ALREADY Have Sentry

✅ Skip to [Project Configuration](#project-configuration)

---

## 2. Project Configuration

### Single Project (One App)

**Create Sentry Project:**
1. Go to Sentry dashboard
2. Click **"Create Project"**
3. Select platform:
   - **JavaScript** → For Next.js, React, Node
   - **Python** → For Django, FastAPI
   - **React Native** → For mobile apps
   - **Go** → For Go backends
4. Name: `my-app-production`
5. Copy the **DSN** (looks like: `https://xxx@o123.ingest.sentry.io/456`)

**Environment tags:**
```
Project: my-app-production    → DSN_PROD
Project: my-app-staging       → DSN_STAGING
Project: my-app-development   → DSN_DEV
```

**Best practice:** One Sentry project per environment.

---

## 3. Monorepo Setup

### Scenario A: Frontend + Backend in Same Repo

**Example structure:**
```
my-saas-app/
├── frontend/          # Next.js
├── backend/           # FastAPI
└── .git/
```

**Sentry projects needed:**
```
1. my-saas-frontend-prod     → DSN_FRONTEND_PROD
2. my-saas-backend-prod      → DSN_BACKEND_PROD
3. my-saas-frontend-staging  → DSN_FRONTEND_STAGING (optional)
4. my-saas-backend-staging   → DSN_BACKEND_STAGING (optional)
```

**Create each in Sentry:**
1. Click **"Create Project"** (4 times)
2. **Frontend projects:**
   - Platform: JavaScript
   - Name: `my-saas-frontend-prod`
   - Copy DSN → Save as `SENTRY_DSN_FRONTEND_PROD`
3. **Backend projects:**
   - Platform: Python (or Node)
   - Name: `my-saas-backend-prod`
   - Copy DSN → Save as `SENTRY_DSN_BACKEND_PROD`

### Scenario B: iOS + Android in Same Repo

**Example structure:**
```
my-mobile-app/
├── ios/               # React Native iOS
├── android/           # React Native Android
└── .git/
```

**Sentry projects needed:**
```
1. my-mobile-ios-prod        → DSN_IOS_PROD
2. my-mobile-android-prod    → DSN_ANDROID_PROD
```

**Why separate?**
- Different error patterns (iOS crashes vs Android)
- Different release cycles
- Platform-specific debugging

### Scenario C: Microservices in Same Repo

**Example structure:**
```
my-platform/
├── services/
│   ├── auth-service/
│   ├── payment-service/
│   └── notification-service/
└── .git/
```

**Sentry projects:**
```
1. my-platform-auth-prod
2. my-platform-payment-prod
3. my-platform-notification-prod
```

**Rule of thumb:**
- **Separate Sentry project** if they deploy independently
- **Same Sentry project** if they deploy together

---

## 4. MCP Installation

### Step 1: Add Sentry MCP to Claude Code

```bash
# One command - connects to Sentry's hosted MCP server
claude mcp add --transport http sentry https://mcp.sentry.dev/mcp
```

**What this does:**
- Adds remote MCP server (nothing to install locally)
- Uses OAuth (no manual API keys)
- Gives Claude access to ALL your Sentry projects

### Step 2: Authenticate

```bash
# Start Claude Code
claude

# Run authentication
/mcp

# Follow prompts:
# 1. Opens browser to Sentry OAuth page
# 2. Click "Authorize"
# 3. Returns to Claude Code
# 4. Shows: "✅ Sentry MCP connected"
```

**Verify it works:**
```bash
# Inside Claude Code
"List my Sentry projects"

# Expected output:
# - my-app-production
# - my-app-staging
# - etc.
```

**One-time setup:** Once authenticated, works across all your projects!

---

## 5. SDK Integration

### For Each Project/Service, Install Sentry SDK

Choose your platform:

---

### Next.js (Frontend)

```bash
cd frontend/  # or wherever your Next.js app is

# Install
npm install @sentry/nextjs

# Initialize (interactive wizard)
npx @sentry/wizard@latest -i nextjs
```

**Wizard will create:**
- `sentry.client.config.ts` - Frontend error tracking
- `sentry.server.config.ts` - API routes error tracking
- `sentry.edge.config.ts` - Edge runtime error tracking
- `next.config.js` - Sentry integration
- `.env.sentry-build-plugin` - Upload source maps

**Set environment variables:**
```bash
# .env.local
NEXT_PUBLIC_SENTRY_DSN=https://xxx@o123.ingest.sentry.io/456
SENTRY_ENVIRONMENT=production  # or development, staging
```

**For monorepo:**
```bash
# frontend/.env.production
NEXT_PUBLIC_SENTRY_DSN=https://frontend-prod-dsn...
SENTRY_ENVIRONMENT=production

# frontend/.env.development
NEXT_PUBLIC_SENTRY_DSN=https://frontend-dev-dsn...
SENTRY_ENVIRONMENT=development
```

---

### FastAPI (Backend)

```bash
cd backend/

# Install
pip install sentry-sdk[fastapi]
```

**Add to your FastAPI app:**

```python
# main.py
import sentry_sdk
from fastapi import FastAPI

# Initialize Sentry
sentry_sdk.init(
    dsn="https://xxx@o123.ingest.sentry.io/456",
    environment="production",  # or development, staging
    traces_sample_rate=1.0,  # 100% of transactions for performance monitoring
    profiles_sample_rate=1.0,  # 100% of transactions for profiling
)

app = FastAPI()

# Your routes...
```

**Use environment variables:**
```python
# main.py
import os
import sentry_sdk

sentry_sdk.init(
    dsn=os.environ.get("SENTRY_DSN"),
    environment=os.environ.get("SENTRY_ENVIRONMENT", "development"),
    traces_sample_rate=1.0 if os.environ.get("SENTRY_ENVIRONMENT") == "production" else 0.1,
)
```

```bash
# .env.production
SENTRY_DSN=https://backend-prod-dsn...
SENTRY_ENVIRONMENT=production

# .env.development
SENTRY_DSN=https://backend-dev-dsn...
SENTRY_ENVIRONMENT=development
```

---

### Django (Backend)

```bash
pip install sentry-sdk[django]
```

```python
# settings.py
import sentry_sdk
from sentry_sdk.integrations.django import DjangoIntegration

sentry_sdk.init(
    dsn=os.environ.get("SENTRY_DSN"),
    environment=os.environ.get("SENTRY_ENVIRONMENT", "development"),
    integrations=[DjangoIntegration()],
    traces_sample_rate=1.0,
)
```

---

### Node/Express (Backend)

```bash
npm install @sentry/node @sentry/profiling-node
```

```javascript
// index.js
const Sentry = require("@sentry/node");

Sentry.init({
  dsn: process.env.SENTRY_DSN,
  environment: process.env.SENTRY_ENVIRONMENT || "development",
  tracesSampleRate: 1.0,
});

// Must be first middleware
app.use(Sentry.Handlers.requestHandler());
app.use(Sentry.Handlers.tracingHandler());

// Your routes...

// Error handler (must be last)
app.use(Sentry.Handlers.errorHandler());
```

---

### React Native (Mobile)

```bash
npm install @sentry/react-native
```

```javascript
// App.tsx
import * as Sentry from "@sentry/react-native";

Sentry.init({
  dsn: "https://xxx@o123.ingest.sentry.io/456",
  environment: __DEV__ ? "development" : "production",
});

// Wrap your root component
export default Sentry.wrap(App);
```

**For iOS + Android monorepo:**
```javascript
// App.tsx
import { Platform } from "react-native";

Sentry.init({
  dsn: Platform.OS === "ios"
    ? process.env.SENTRY_DSN_IOS
    : process.env.SENTRY_DSN_ANDROID,
  environment: __DEV__ ? "development" : "production",
});
```

---

## 6. Claude Code Integration

### Update Your Project's CLAUDE.md

**For single project:**

```markdown
# .claude/CLAUDE.md

## Error Tracking

**Sentry:**
- Project: my-app-production
- DSN: [Set in environment variables]
- Environment: production

**When debugging production errors:**
1. Ask Claude to check Sentry for recent errors
2. Claude reads full context (stack trace, breadcrumbs)
3. Claude suggests or implements fix
4. Deploy fix
5. Verify in Sentry that error is resolved

**Error priority:**
- 🔥 CRITICAL (payments, auth, data loss): Fix immediately
- ⚠️ HIGH (broken features, bad UX): Fix within 24h
- 📝 MEDIUM (minor bugs, edge cases): Fix this week
- ℹ️ LOW (cosmetic issues): Backlog
```

**For monorepo (frontend + backend):**

```markdown
# .claude/CLAUDE.md

## Error Tracking

**Sentry Projects:**
- Frontend: my-saas-frontend-prod (Next.js)
  - DSN: [NEXT_PUBLIC_SENTRY_DSN_FRONTEND]
  - Tracks: Client errors, API route errors

- Backend: my-saas-backend-prod (FastAPI)
  - DSN: [SENTRY_DSN_BACKEND]
  - Tracks: API errors, database errors, background tasks

**When debugging:**
1. Identify which part is failing (frontend or backend)
2. Ask Claude to check THAT Sentry project
3. Example: "Check frontend Sentry for errors in the last hour"
4. Example: "Check backend Sentry for payment API errors"

**Cross-project debugging:**
- If frontend shows network error → Check backend Sentry
- If backend shows 500 error → Check frontend Sentry for client context
```

### Add Sentry to Your Workflow Commands

Create `~/.claude/skills/sentry-debug/SKILL.md`:

```markdown
---
name: Sentry Debugger
description: Debug production errors using Sentry
keywords: sentry, error, bug, production, crash, issue
---

# Sentry Debugger

When user mentions Sentry error or production bug:

## For Single Project

1. Ask: "Which Sentry project?" (if multiple)
2. Fetch recent errors: "Show me errors from [project] in the last [timeframe]"
3. For specific issue: "Analyze Sentry issue #[ID]"
4. Read full context:
   - Stack trace
   - Breadcrumbs (user actions before error)
   - Tags (browser, OS, release)
   - Frequency and affected users
5. Identify root cause
6. Create worktree if needed: `git worktree add ../hotfix-[issue] hotfix/sentry-[issue]`
7. Implement fix
8. Test locally
9. Commit: "fix: Resolve Sentry issue #[ID] - [brief description]"
10. After deploy: "Verify Sentry issue #[ID] is resolved"

## For Monorepo

1. Ask: "Which project? (frontend/backend/ios/android)"
2. Determine Sentry project name from CLAUDE.md
3. Fetch errors from THAT project
4. If cross-project issue:
   - Check frontend Sentry first (user-facing)
   - Then check backend Sentry (API/data layer)
   - Identify which layer is root cause
5. Fix in appropriate part of monorepo
```

---

## 7. Testing

### Test 1: Trigger Test Error

**Frontend (Next.js):**
```javascript
// pages/test-sentry.tsx
export default function TestSentry() {
  return (
    <button onClick={() => {
      throw new Error("Test Sentry error from frontend!");
    }}>
      Trigger Error
    </button>
  );
}
```

**Backend (FastAPI):**
```python
# main.py
@app.get("/test-sentry")
def test_sentry():
    raise Exception("Test Sentry error from backend!")
```

**Visit the endpoint:**
- Frontend: http://localhost:3000/test-sentry (click button)
- Backend: http://localhost:8000/test-sentry

**Check Sentry:**
1. Go to sentry.io
2. Select your project
3. You should see the error appear within 10 seconds

### Test 2: Claude Code Integration

```bash
claude

# Test commands:
"Show me the latest error from Sentry"
"List all errors from the last hour"
"Analyze Sentry issue #123"
"Find all errors related to payments"
```

**Expected:**
- Claude fetches real data from Sentry
- Shows error details
- Can analyze and suggest fixes

---

## 8. Troubleshooting

### Issue: "Sentry MCP not connected"

```bash
# Re-authenticate
/mcp

# Or check MCP status
claude mcp list
```

### Issue: "No errors showing in Sentry"

**Check 1: DSN correct?**
```bash
# In your app, add debug log
console.log("Sentry DSN:", process.env.NEXT_PUBLIC_SENTRY_DSN)
# Should NOT be undefined
```

**Check 2: Sentry initialized?**
```javascript
// Add after Sentry.init()
console.log("Sentry initialized");
```

**Check 3: In production mode?**
```bash
# Sentry often disabled in development
# Set explicitly:
SENTRY_ENVIRONMENT=development
```

### Issue: "Claude can't read specific error"

```bash
# Be specific about project name
"Show me errors from my-saas-frontend-prod"  # ✅ Good

# Not:
"Show me frontend errors"  # ❌ Too vague
```

### Issue: "Too many errors in Sentry (quota exceeded)"

**Solution 1: Filter noisy errors**
```javascript
// Sentry config
Sentry.init({
  dsn: "...",
  beforeSend(event) {
    // Ignore known non-issues
    if (event.exception?.values?.[0]?.value?.includes("ResizeObserver")) {
      return null;  // Don't send to Sentry
    }
    return event;
  },
});
```

**Solution 2: Sample errors**
```javascript
Sentry.init({
  dsn: "...",
  sampleRate: 0.5,  // Send 50% of errors (reduces quota usage)
});
```

**Solution 3: Upgrade plan**
- Free: 5K errors/month
- Team: 50K errors/month ($26)
- Business: 100K errors/month ($80)

---

## 📋 Quick Reference

### Setup Checklist (New Project)

**Sentry Account:**
- [ ] Create Sentry project for each service/environment
- [ ] Copy DSN for each project

**Code Integration:**
- [ ] Install Sentry SDK
- [ ] Initialize with DSN
- [ ] Set environment variables
- [ ] Test error capture (trigger test error)
- [ ] Verify error appears in Sentry

**Claude Code:**
- [ ] Add Sentry MCP (one-time): `claude mcp add --transport http sentry https://mcp.sentry.dev/mcp`
- [ ] Authenticate: `/mcp`
- [ ] Update CLAUDE.md with Sentry project names
- [ ] Test: "Show me errors from [project]"

**For Monorepo:**
- [ ] Create separate Sentry project per service
- [ ] Document in CLAUDE.md which project is which
- [ ] Set different DSNs per service
- [ ] Test each service separately

### Common Commands

```bash
# Inside Claude Code

# List projects
"List my Sentry projects"

# Recent errors
"Show errors from [project] in the last hour"
"Show critical errors from [project] today"

# Specific issue
"Analyze Sentry issue #12345"
"Show me the stack trace for issue #12345"

# Search
"Find errors in payment.ts"
"Find errors affecting user@example.com"
"Show errors from release v2.1.0"

# Performance
"Show slowest endpoints in [project]"
"Analyze performance issues in [project]"

# Cross-project (monorepo)
"Compare error rates between frontend and backend"
"Show all errors related to authentication across all projects"
```

---

## 🎯 Best Practices

### 1. Name Projects Clearly

**Good:**
- `my-saas-frontend-prod`
- `my-saas-backend-prod`
- `my-saas-frontend-staging`

**Bad:**
- `project-1`
- `test`
- `new-project`

### 2. Use Environments

```javascript
Sentry.init({
  dsn: "...",
  environment: process.env.NODE_ENV,  // 'development' | 'staging' | 'production'
});
```

**Filter by environment in Sentry dashboard.**

### 3. Add Context

```javascript
// Helpful for debugging
Sentry.setUser({ id: user.id, email: user.email });
Sentry.setTag("page", "checkout");
Sentry.setContext("order", { orderId: 123, total: 99.99 });
```

**Claude can see this context when debugging!**

### 4. Release Tracking

```javascript
Sentry.init({
  dsn: "...",
  release: "my-app@1.2.3",  // From package.json or git tag
});
```

**Enables:** "Show errors introduced in v1.2.3"

### 5. Source Maps (Frontend)

**Upload source maps so Sentry shows original code (not minified):**

```bash
# Automatically done by @sentry/nextjs wizard
# Or manually:
npx @sentry/cli releases files my-app@1.2.3 upload-sourcemaps ./build
```

---

## 🚀 Advanced: Hooks

### Hook: Check Sentry After Deploy

```json
{
  "hooks": [
    {
      "name": "post-deploy-sentry-check",
      "event": "PostDeploy",
      "prompt": "After deployment, check Sentry for new errors in the last 10 minutes. Report any critical issues immediately."
    }
  ]
}
```

### Hook: Weekly Error Summary

```bash
# crontab
0 9 * * 1 echo "Summarize errors from all Sentry projects in the last 7 days" | claude
```

---

## 📚 Resources

- [Sentry MCP docs](https://docs.sentry.io/product/sentry-mcp/)
- [Sentry Next.js guide](https://docs.sentry.io/platforms/javascript/guides/nextjs/)
- [Sentry FastAPI guide](https://docs.sentry.io/platforms/python/guides/fastapi/)
- [Sentry React Native guide](https://docs.sentry.io/platforms/react-native/)
- [Anthropic MCP webinar](https://www.anthropic.com/webinars/building-with-mcp-and-claude-code-sentrys-0-to-1-story)

---

## ❓ FAQ

**Q: Do I need separate Sentry projects for dev/staging/prod?**

A: **Option 1 (Recommended):** One project, use `environment` tags to filter.

**Option 2:** Separate projects if you want hard separation (e.g., dev errors don't count toward prod quota).

For indie hackers: Option 1 is simpler.

---

**Q: Can Claude auto-fix Sentry errors?**

A: Yes! Example:
```
"Read Sentry issue #123, create a worktree, fix the bug, and commit"
```

Claude will:
1. Fetch issue from Sentry
2. Analyze stack trace
3. Create `git worktree add ../fix-123 hotfix/sentry-123`
4. Fix the code
5. Run tests
6. Commit: "fix: Resolve Sentry #123 - [description]"

---

**Q: What if I have 20+ projects?**

A: **Team plan ($26/month)** = unlimited projects.

In CLAUDE.md, list all projects:
```markdown
## Sentry Projects

**Production:**
- app1-frontend-prod
- app1-backend-prod
- app2-frontend-prod
- app2-backend-prod
...

**Staging:**
- app1-frontend-staging
- app1-backend-staging
...
```

Claude can search across all of them: "Find authentication errors across all projects"

---

**Q: Is Sentry MCP safe/secure?**

A: **Yes.**
- OAuth authentication (not API keys)
- Read-only access (Claude can't delete errors or modify settings)
- Hosted by Sentry (official, not third-party)
- 50M+ requests/month in production use

---

**Next:** Add to CORE-SETUP.md and update project templates.
