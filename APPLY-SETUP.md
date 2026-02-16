# Apply Setup to Any Project

> **Purpose:** Automated workflow to apply Claude Code setup to new or existing projects
> **Time:** 5-10 minutes
> **Works for:** Any project (analyzes automatically)

---

## 🚀 Quick Start (Recommended)

### For New Project

```bash
cd ~/projects/my-new-app

# Copy this entire command and paste into terminal:
cat << 'EOF' | claude
I'm setting up Claude Code workflow for this project.

Please analyze this repository and recommend the complete setup:

1. **Detect the stack:**
   - Check package.json, requirements.txt, go.mod, etc.
   - Identify: Frontend framework, backend framework, database, other tools

2. **Recommend MCPs to install:**
   - Based on detected stack (PostgreSQL MCP, MongoDB MCP, etc.)
   - Based on detected deployment (Vercel MCP, Render MCP, etc.)
   - Include Sentry MCP for error tracking

3. **Recommend Sentry projects:**
   - How many projects needed? (monorepo detection)
   - Naming convention for each
   - Which DSN environment variables to set

4. **Project questionnaire (answer these):**
   - Is this a **production app** or **MVP/prototype**?
     → If production: install superpowers plugin (TDD enforcement)
   - Will you use **Figma designs** for this project?
     → If yes: install figma plugin
   - Does this project need **web scraping/research**?
     → If yes: install firecrawl plugin
   - Do you **collaborate with others via Slack** on this project?
     → If yes: install slack plugin
   - Does this project use **GitLab** (not GitHub)?
     → If yes: install gitlab plugin locally
   - Does this project use **Firebase**?
     → If yes: install firebase plugin locally
   - Does this project use **vector search / Pinecone**?
     → If yes: install pinecone plugin locally
   - Does this project use **PostHog** for analytics?
     → If yes: install posthog plugin locally
   - Is this a **PHP/Laravel** project?
     → If yes: install laravel-boost + php-lsp locally

5. **Run claude-code-setup plugin** (second opinion):
   - Compare its recommendations with your own analysis
   - Adopt any suggestions that improve the setup
   - This plugin is read-only and safe to run

6. **Generate CLAUDE.md:**
   - Based on detected stack
   - Include project-specific rules
   - Add Sentry configuration
   - Add workflow rules for slash commands:
     ```
     ## Workflow Rules
     - Before committing: use /commit (commit-commands plugin)
     - Before PRs: run /pr-review-toolkit:review-pr all
     - End of session: run /revise-claude-md
     - New features: use /feature-dev for non-trivial features
     ```

7. **Generate .claude/settings.json:**
   - Appropriate hooks for this project type
   - Auto-test hook if production app
   - Skill loader hook
   - Auto-format hook

8. **Provide setup checklist:**
   - Step-by-step commands to run
   - What to install where (global plugins already installed, only per-project items needed)
   - How to test each component

Please be specific and thorough. I want to copy-paste the commands.

Reference setup files:
$(cat ~/Documents/Code/claude-workflow/CORE-SETUP.md)
$(cat ~/Documents/Code/claude-workflow/PROJECT-TEMPLATES/*.md | head -200)
$(cat ~/Documents/Code/claude-workflow/MCP-MODULES/*.md | head -200)
EOF
```

**What happens:**
1. ✅ Claude analyzes your repo (package.json, file structure, etc.)
2. ✅ Detects stack (Next.js + FastAPI + PostgreSQL + Stripe, etc.)
3. ✅ Recommends MCPs to install
4. ✅ Recommends how many Sentry projects (detects monorepo)
5. ✅ Generates CLAUDE.md and settings.json
6. ✅ Gives you copy-paste commands

---

## 📋 Detailed Walkthrough

### Step 1: Stack Detection

**Claude automatically checks:**

```bash
# Frontend detection
- package.json → Next.js, React, Vue, Svelte?
- Has /app directory → Next.js App Router
- Has /pages directory → Next.js Pages Router
- Has vite.config.ts → Vite
- Has capacitor.config.ts → Capacitor (mobile)

# Backend detection
- requirements.txt → Python
  - Has fastapi in requirements → FastAPI
  - Has django in requirements → Django
- package.json → Node
  - Has express → Express
  - Has @nestjs → NestJS
- go.mod → Go
- Cargo.toml → Rust

# Database detection
- Has prisma/ → PostgreSQL (check schema.prisma)
- Has alembic/ → PostgreSQL (check alembic.ini)
- Has migrations/ → Django (check settings.py for DB)
- package.json has mongoose → MongoDB
- .env has DATABASE_URL=postgres:// → PostgreSQL
- .env has MONGODB_URI → MongoDB
- .env has SUPABASE_URL → Supabase

# Payment detection
- .env has STRIPE_SECRET_KEY → Stripe
- package.json has stripe → Stripe

# Deployment detection
- vercel.json → Vercel
- render.yaml → Render
- fly.toml → Fly.io
- railway.toml or Procfile → Railway
- .elasticbeanstalk/ → AWS Beanstalk

# Docker detection
- Has Dockerfile → Docker containerized app
- Has docker-compose.yml or compose.yml → Multi-container setup
- Has .dockerignore → Docker project

# Queue system detection
- package.json has bullmq → BullMQ (Redis-backed job queue)
- requirements.txt has celery → Celery task queue
- .env has REDIS_URL → Redis (may be queue backend)

# Runtime detection
- Has deno.json or deno.jsonc → Deno runtime

# CMS detection
- Has strapi in package.json → Strapi CMS

# Mobile framework detection
- Has expo in package.json → Expo (React Native)

# Monorepo detection
- Has apps/, packages/, services/ → Monorepo
- Multiple package.json files → Monorepo
- lerna.json or nx.json → Monorepo
```

**Example output:**
```
✅ Stack detected:
- Frontend: Next.js 14 (App Router) with TypeScript
- Backend: FastAPI with Python 3.11
- Database: PostgreSQL (via Prisma)
- Payments: Stripe
- Deployment: Vercel (frontend) + Render (backend)
- Type: Monorepo (frontend/ and backend/ directories)
```

---

### Step 2: MCP Recommendations

**Claude recommends based on detected stack:**

```
📦 Recommended MCPs to install:

**Essential (already installed):**
✅ Context7 - Library documentation
✅ GitHub - Repository management

**Install these for your stack:**
🔧 PostgreSQL MCP - Query database, generate migrations
   Install: [Check Claude Code settings or MCP registry]

🔧 Stripe MCP - Test payments, query customers
   Install: claude mcp add --transport http stripe https://stripe-mcp-server-url

🔧 Sentry MCP - Error tracking and debugging
   Install: claude mcp add --transport http sentry https://mcp.sentry.dev/mcp

🔧 Vercel MCP - Deploy, view logs, manage env vars
   Install: [Check if already available in tools]

🔧 Render MCP - Deploy backend, manage services
   Install: [Check if already available in tools]

**Optional:**
⚪ Sequential Thinking MCP - Complex problem solving
```

---

### Step 3: Sentry Project Recommendations

**Claude analyzes your repo structure:**

**Example 1: Monorepo (Frontend + Backend)**
```
📊 Sentry Projects Needed: 2

1. my-app-frontend-prod
   - Tracks: Next.js client errors, API route errors
   - DSN env var: NEXT_PUBLIC_SENTRY_DSN
   - Location: frontend/.env.production

2. my-app-backend-prod
   - Tracks: FastAPI errors, database errors
   - DSN env var: SENTRY_DSN
   - Location: backend/.env

**Setup steps:**
1. Go to sentry.io
2. Create project: my-app-frontend-prod (JavaScript)
3. Copy DSN → frontend/.env.production
4. Create project: my-app-backend-prod (Python)
5. Copy DSN → backend/.env

See: MCP-MODULES/error-tracking.md for detailed setup
```

**Example 2: Single App**
```
📊 Sentry Projects Needed: 1

1. my-app-prod
   - Tracks: All application errors
   - DSN env var: NEXT_PUBLIC_SENTRY_DSN (if Next.js) or SENTRY_DSN (if backend)
   - Location: .env.production

**Setup steps:**
1. Go to sentry.io
2. Create project: my-app-prod (Next.js)
3. Copy DSN → .env.production
```

**Example 3: Microservices**
```
📊 Sentry Projects Needed: 3

Detected services:
- services/auth-service/
- services/payment-service/
- services/notification-service/

Recommended:
1. my-app-auth-prod
2. my-app-payment-prod
3. my-app-notification-prod

Each gets its own DSN in its own .env file.
```

---

### Step 4: Generated Files

**Claude creates these files for you:**

#### .claude/CLAUDE.md

```markdown
# Project: [Auto-detected name from package.json or repo]
# Stack: Next.js 14 + FastAPI + PostgreSQL + Stripe
# Type: Production (monorepo)
# Deployment: Vercel (frontend) + Render (backend)

## Core Rules

1. **Testing:** Full TDD for production (tests BEFORE implementation)
2. **Commits:** Write commits as you go for each task step
3. **Errors:** Do not handle errors gracefully. Fail hard and fast with tests.
4. **Scope:** No over-engineering. Implement exactly what's requested.
5. **Code Review:** After every correction, update this CLAUDE.md

## Tech Stack Specifics

### Frontend (Next.js)
- Components: Functional with hooks, TypeScript strict mode
- State: React Query for server state
- Forms: React Hook Form + Zod validation
- Styling: [Detected: Tailwind | styled-components | CSS Modules]
- File structure: app/components/[feature]/Component.tsx

### Backend (FastAPI)
- Type hints: All parameters and returns
- Validation: Pydantic models
- Async: Prefer async def for I/O
- File structure: app/api/v1/[resource]/router.py

### Database (PostgreSQL via Prisma)
- Migrations: Always generate with npx prisma migrate dev
- Indexes: Add for foreign keys and frequently queried fields
- Queries: Use Prisma's include/select to avoid N+1

### Payments (Stripe)
- Never log full card details
- Always validate webhook signatures
- Use test mode in development
- Store minimal PII

## Error Tracking

**Sentry Projects:**
- Frontend: my-app-frontend-prod (Next.js)
  - DSN: NEXT_PUBLIC_SENTRY_DSN
  - Location: frontend/.env.production

- Backend: my-app-backend-prod (FastAPI)
  - DSN: SENTRY_DSN
  - Location: backend/.env

**When debugging:**
1. Identify which part is failing (frontend or backend)
2. Ask Claude to check THAT Sentry project
3. Example: "Check backend Sentry for payment errors"

## MCPs Configured
- Context7 ✓
- GitHub ✓
- PostgreSQL ✓
- Stripe ✓
- Sentry ✓
- Vercel ✓
- Render ✓

## Current Focus

[Update this as you work]

## Known Issues / Bugs to Avoid

[Claude updates this section automatically]
```

#### .claude/settings.json

```json
{
  "hooks": [
    {
      "name": "force-skill-loader",
      "event": "PrePrompt",
      "command": "echo 'Loading skills and CLAUDE.md...' && cat ~/.claude/skills/*/SKILL.md .claude/CLAUDE.md 2>/dev/null | head -100"
    },
    {
      "name": "auto-test",
      "event": "PostToolUse",
      "filter": "Edit|Write",
      "prompt": "After modifying code, verify all unit tests still pass. Run the test suite and report results."
    },
    {
      "name": "auto-format",
      "event": "PostToolUse",
      "filter": "Edit|Write",
      "command": "cd frontend && prettier --write '**/*.{js,jsx,ts,tsx,css,json}' 2>/dev/null; cd ../backend && black . 2>/dev/null; true"
    }
  ]
}
```

---

### Step 5: Setup Checklist

**Claude generates a personalized checklist:**

```markdown
## Setup Checklist for my-app

### Phase 1: MCP Installation (5 min)

- [ ] Install Sentry MCP:
  ```bash
  claude mcp add --transport http sentry https://mcp.sentry.dev/mcp
  claude
  /mcp  # Authenticate with Sentry
  ```

- [ ] Verify MCPs available:
  ```bash
  # Inside Claude Code
  "List available MCPs"
  # Should show: Context7, GitHub, PostgreSQL, Stripe, Sentry, Vercel, Render
  ```

### Phase 2: Sentry Setup (10 min)

- [ ] Create Sentry projects:
  1. Go to https://sentry.io
  2. Create: my-app-frontend-prod (JavaScript/Next.js)
  3. Copy DSN → frontend/.env.production as NEXT_PUBLIC_SENTRY_DSN
  4. Create: my-app-backend-prod (Python/FastAPI)
  5. Copy DSN → backend/.env as SENTRY_DSN

- [ ] Install Sentry SDKs:
  ```bash
  # Frontend
  cd frontend
  npm install @sentry/nextjs
  npx @sentry/wizard@latest -i nextjs

  # Backend
  cd ../backend
  pip install sentry-sdk[fastapi]
  # Add to main.py (see MCP-MODULES/error-tracking.md)
  ```

### Phase 3: Testing Framework (5 min)

- [ ] Install test frameworks:
  ```bash
  # Frontend
  cd frontend
  npm install -D vitest @testing-library/react @testing-library/jest-dom

  # Backend
  cd ../backend
  pip install pytest pytest-asyncio httpx
  ```

### Phase 4: Apply Workflow (2 min)

- [ ] Copy generated files:
  ```bash
  # CLAUDE.md already created above
  # settings.json already created above

  git add .claude/
  git commit -m "chore: Add Claude Code workflow setup"
  ```

### Phase 5: Test Setup (3 min)

- [ ] Test hooks:
  ```bash
  claude
  # "What are the core rules for this project?"
  # Should quote CLAUDE.md
  ```

- [ ] Test Sentry MCP:
  ```bash
  # Inside Claude Code
  "List my Sentry projects"
  # Should show: my-app-frontend-prod, my-app-backend-prod
  ```

- [ ] Trigger test error:
  ```bash
  # Follow instructions in MCP-MODULES/error-tracking.md
  # Verify error appears in Sentry
  # Ask Claude to analyze it
  ```

### Phase 6: Code Review Setup (5 min)

- [ ] Choose and install:
  - [ ] Greptile ($30/month, unlimited repos, GitLab support)
    Go to https://greptile.com
  - [ ] OR CodeRabbit (free tier, Claude Code integration)
    ```bash
    npm install -g @coderabbitai/cli
    coderabbit login
    ```

**Total Time: ~30 minutes**
```

---

## 🤖 Automated Setup (Advanced)

### Create a Setup Script

Save this as `~/Documents/Code/claude-workflow/scripts/setup-project.sh`:

```bash
#!/bin/bash
# Auto-setup Claude Code workflow for any project

cd "$1" || exit 1

echo "🔍 Analyzing project..."

# Feed setup to Claude
cat << 'EOF' | claude
[Same prompt as Quick Start above]
EOF

echo "✅ Analysis complete! Follow the checklist above."
```

**Usage:**
```bash
chmod +x ~/Documents/Code/claude-workflow/scripts/setup-project.sh
~/Documents/Code/claude-workflow/scripts/setup-project.sh ~/projects/my-app
```

---

## 🎯 Examples by Project Type

### Example 1: Next.js + Supabase

**Detected:**
- Frontend: Next.js 14
- Database: Supabase (PostgreSQL)
- Auth: Supabase Auth
- Deployment: Vercel

**Claude recommends:**
```
MCPs: Context7, GitHub, Supabase (built-in), Vercel
Sentry: 1 project (my-app-prod)
Hooks: Auto-test, auto-format, skill-loader
```

### Example 2: Django Monolith

**Detected:**
- Backend: Django
- Database: PostgreSQL
- Deployment: Render

**Claude recommends:**
```
MCPs: Context7, GitHub, PostgreSQL, Render
Sentry: 1 project (my-app-prod)
Hooks: Auto-test (pytest), auto-format (black), skill-loader
```

### Example 3: Microservices

**Detected:**
- services/auth/ (Node + Express)
- services/payment/ (FastAPI)
- services/notification/ (Go)
- Database: PostgreSQL (shared)
- Deployment: Fly.io

**Claude recommends:**
```
MCPs: Context7, GitHub, PostgreSQL, Fly.io
Sentry: 3 projects (auth-prod, payment-prod, notification-prod)
Hooks: Auto-test in each service, auto-format, skill-loader
```

---

## 🔍 Frontend Skills Clarification

**Your question:** "Did you find out anything about frontend skills?"

**Answer:** There are NO separate "frontend skills" to install.

**What I meant earlier:**

### Option 1: Use /insights (Recommended)

```bash
# After 20+ sessions working on frontend code:
/insights

# Claude analyzes your patterns:
# - "User creates React components frequently"
# - "User always uses TypeScript + Tailwind"
# - "User follows feature-based folder structure"

# Generates custom skill:
# ~/.claude/skills/react-component-generator/SKILL.md
```

**This is BETTER than pre-made frontend skills** because it's tailored to YOUR style.

### Option 2: Create Your Own

If you want a frontend skill NOW (before /insights has data):

```bash
mkdir -p ~/.claude/skills/react-component
cat > ~/.claude/skills/react-component/SKILL.md << 'EOF'
---
name: React Component Generator
description: Create React components with TypeScript and tests
keywords: component, react, tsx, create component
---

# React Component Generator

When user asks to create a React component:

1. **Create component file:**
   - Functional component with TypeScript
   - Props interface defined
   - Proper exports

2. **Create test file:**
   - Basic render test
   - Props validation test
   - User interaction tests (if applicable)

3. **Structure:**
   ```
   components/[Feature]/
     ComponentName.tsx
     ComponentName.test.tsx
   ```

4. **Patterns:**
   - Use hooks (no class components)
   - TypeScript strict mode
   - Tailwind for styling (if detected in project)
   - React Hook Form for forms (if detected)

5. **After creating, run tests automatically**
EOF
```

### Option 3: No Frontend Skill (Also Valid)

**You don't NEED a frontend-specific skill.**

Claude already knows:
- React patterns
- Next.js patterns
- TypeScript
- Modern frontend best practices

**The skill just enforces YOUR specific patterns** (like folder structure, naming conventions).

**Recommendation:**
1. **Now:** Don't create frontend skills manually
2. **After 20+ sessions:** Run `/insights`
3. **Result:** Claude generates skills based on YOUR actual patterns

---

## 📝 Summary

### How to Apply Setup (Choose One)

**Option A: Fully Automated (Recommended)**
```bash
cd ~/projects/my-app
# Copy-paste the Quick Start command above
# Claude analyzes and recommends everything
```

**Option B: Manual with Guide**
```bash
cd ~/projects/my-app
cat ~/Documents/Code/claude-workflow/ASSESSMENT-PROMPT.md | claude
# Claude analyzes and you approve step-by-step
```

**Option C: Read and Apply Yourself**
```bash
# Read the guides:
cat ~/Documents/Code/claude-workflow/CORE-SETUP.md
cat ~/Documents/Code/claude-workflow/PROJECT-TEMPLATES/[your-stack].md

# Apply manually
```

### What Claude Auto-Detects

✅ Frontend framework (Next.js, React, Vue, etc.)
✅ Backend framework (FastAPI, Django, Express, etc.)
✅ Database (PostgreSQL, MongoDB, Supabase)
✅ Payments (Stripe detection)
✅ Deployment platform (Vercel, Render, Fly.io, Railway)
✅ Docker (Dockerfile, docker-compose.yml)
✅ Queue systems (BullMQ, Celery)
✅ Runtime (Deno, Node)
✅ Mobile (Expo, Capacitor)
✅ CMS (Strapi)
✅ Monorepo structure
✅ Number of Sentry projects needed

### What Claude Recommends

✅ Which MCPs to install (per-project, local scope)
✅ Which per-project plugins to install (based on questionnaire)
✅ How many Sentry projects
✅ Naming convention for Sentry projects
✅ Which hooks to enable
✅ CLAUDE.md configuration (including workflow rules for slash commands)
✅ settings.json configuration
✅ Step-by-step setup checklist
✅ Cross-check with claude-code-setup plugin recommendations

### What's Already Installed Globally (No Per-Project Action Needed)

✅ Global MCPs: Context7, GitHub (gh CLI), Sentry
✅ Global plugins: security-guidance, typescript-lsp, pyright-lsp,
   frontend-design, code-review, commit-commands, feature-dev,
   pr-review-toolkit, claude-md-management, playwright, claude-code-setup,
   coderabbit
✅ Global hooks: skill-loader (PrePrompt)

### Frontend Skills

❌ No pre-made frontend skills exist
✅ Use `/insights` after 20+ sessions (auto-generates based on YOUR patterns)
✅ frontend-design plugin handles UI quality (auto-invoked)
⚪ Optional: Create custom skill manually (example provided above)

---

**Ready to try?** Just `cd` into any project and run the Quick Start command!
