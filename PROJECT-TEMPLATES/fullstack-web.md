# Full-Stack Web App Template

> **Stack:** React / Next.js + Node / Django / FastAPI + PostgreSQL / MongoDB + Vercel / Render
> **Use Case:** Complete web applications with frontend, backend, and database

---

## When to Use This Template

- Building a full web application
- Need both frontend and backend
- Database-backed (PostgreSQL, MongoDB, or Supabase)
- Deploying to Vercel, Render, or similar

**Examples from your projects:**
- SaaS apps with dashboards
- E-commerce platforms
- Social platforms
- Admin panels with APIs

---

## CLAUDE.md Configuration

Copy this to `.claude/CLAUDE.md`:

```markdown
# Project: [PROJECT_NAME]
# Stack: [Next.js | React] + [FastAPI | Django | Node] + [PostgreSQL | MongoDB | Supabase]
# Type: [MVP | Production]
# Deployment: [Vercel | Render | Other]

## Core Rules

1. **Testing:** [See TESTING-GUIDE.md - Production: Full TDD | MVP: Minimal]
2. **Commits:** Write commits as you go for each task step
3. **Errors:** Do not handle errors gracefully. Fail hard and fast with tests.
4. **Scope:** No over-engineering. Implement exactly what's requested.
5. **Code Review:** After every correction, update this CLAUDE.md

## Frontend Standards

### React / Next.js
- **Components:** Functional components with hooks (no class components)
- **TypeScript:** Strict mode enabled
- **Styling:** [Tailwind | CSS Modules | Styled Components - specify your preference]
- **State:** [React Query for server state | Context for global state]
- **Forms:** React Hook Form + Zod validation
- **File Structure:**
  ```
  /app
    /components
      /[feature]      # Feature-based, not type-based
        Component.tsx
        Component.test.tsx
    /api
      /[version]      # /api/v1/users, /api/v2/users
        /[resource]
          route.ts
  ```

### API Routes (Next.js App Router)
- Route handlers in /app/api/[version]/[resource]/route.ts
- Validate inputs with Zod
- Return consistent error format:
  ```typescript
  {
    error: {
      code: "VALIDATION_ERROR",
      message: "User-friendly message",
      details: {...}  // Optional, for debugging
    }
  }
  ```

## Backend Standards

### FastAPI
- **Type Hints:** All function parameters and returns
- **Validation:** Pydantic models for request/response
- **Async:** Prefer async def for I/O operations
- **File Structure:**
  ```
  /app
    /api
      /v1
        /users
          router.py
          schemas.py
          models.py
          services.py
    /core
      config.py
      database.py
    /tests
  ```

### Django
- **Type Hints:** Use django-stubs for type checking
- **Views:** Class-based views for CRUD, function-based for custom
- **Serializers:** DRF serializers with explicit fields
- **File Structure:**
  ```
  /apps
    /users
      models.py
      views.py
      serializers.py
      urls.py
      tests.py
  ```

### Node / Express
- **TypeScript:** Required
- **Async:** async/await (no callbacks)
- **Middleware:** Express middleware for auth, logging, errors
- **File Structure:**
  ```
  /src
    /routes
      /v1
        users.ts
    /controllers
      users.controller.ts
    /services
      users.service.ts
    /models
      user.model.ts
  ```

## Database Standards

### PostgreSQL / Supabase
- **Migrations:** Always create migration files (Prisma, Alembic, or Django migrations)
- **Indexes:** Add indexes for foreign keys and frequently queried fields
- **Naming:** snake_case for tables and columns
- **N+1 Prevention:** Use joins or select_related/prefetch_related
- **Transactions:** Wrap multiple writes in transactions

### MongoDB
- **Schemas:** Define Mongoose schemas with validation
- **Indexes:** Add indexes for lookup fields
- **Pagination:** Use cursor-based pagination for large datasets
- **Aggregations:** Prefer aggregation pipeline over multiple queries

## Authentication

- **JWT:** Store in httpOnly cookies (not localStorage)
- **Refresh Tokens:** Separate refresh token rotation
- **Password:** bcrypt with salt rounds >= 10
- **Session:** Use database-backed sessions for sensitive apps

## Error Handling

- **API Errors:** Return consistent format (see above)
- **Frontend:** React Error Boundaries for component crashes
- **Backend:** Global exception handler middleware
- **Logging:** Log errors with context (user ID, request ID, stack trace)

## Performance

- **Frontend:**
  - Code splitting with dynamic imports
  - Image optimization (next/image or equivalent)
  - Lazy load below-the-fold content
  - Debounce search inputs

- **Backend:**
  - Cache frequently accessed data (Redis)
  - Database connection pooling
  - Avoid N+1 queries
  - Paginate large result sets

## Security Checklist

- [ ] Validate all user inputs (Zod on frontend, Pydantic/validators on backend)
- [ ] Parameterized queries (prevent SQL injection)
- [ ] CORS configured (not allow *)
- [ ] Rate limiting on API endpoints
- [ ] HTTPS only in production
- [ ] Secrets in environment variables (not hardcoded)
- [ ] CSP headers configured

## Current Focus

[Update this as you work - helps Claude maintain context]

Example:
- Building user dashboard (components/dashboard/)
- Implementing Stripe subscription flow
- Fixing performance issue in /api/v1/posts endpoint

## Known Issues / Bugs to Avoid

[Claude updates this when you say "Update CLAUDE.md so you don't make that mistake again"]
```

---

## Required MCPs

Install these MCPs for full-stack web development:

```bash
# Essential
- Context7 (already installed ✓)
- GitHub MCP
- File System MCP

# For your stack (add as needed)
- PostgreSQL MCP (if using PostgreSQL/Supabase)
- MongoDB MCP (if using MongoDB)
- Vercel MCP (if deploying to Vercel)
- Render MCP (if deploying to Render)
```

See `MCP-MODULES/` for detailed setup.

---

## Hooks Configuration

Add to `.claude/settings.json`:

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
      "command": "prettier --write '**/*.{js,jsx,ts,tsx,css,json}' 2>/dev/null || black . 2>/dev/null || true"
    }
  ]
}
```

**For MVP projects:** Remove the "auto-test" hook (slows down iteration).

---

## Testing Setup

### Frontend (Next.js / React)

```bash
# Install testing libraries
npm install -D vitest @testing-library/react @testing-library/jest-dom @vitejs/plugin-react

# Create vitest.config.ts
cat > vitest.config.ts << 'EOF'
import { defineConfig } from 'vitest/config'
import react from '@vitejs/plugin-react'

export default defineConfig({
  plugins: [react()],
  test: {
    environment: 'jsdom',
    setupFiles: ['./vitest.setup.ts'],
  },
})
EOF

# Create setup file
cat > vitest.setup.ts << 'EOF'
import '@testing-library/jest-dom'
EOF

# Add to package.json scripts
# "test": "vitest"
```

### Backend (FastAPI)

```bash
# Install testing libraries
pip install pytest pytest-asyncio httpx

# Create conftest.py
cat > tests/conftest.py << 'EOF'
import pytest
from fastapi.testclient import TestClient
from app.main import app

@pytest.fixture
def client():
    return TestClient(app)
EOF

# Add to pyproject.toml
# [tool.pytest.ini_options]
# testpaths = ["tests"]
```

### Backend (Django)

```bash
# Built-in testing
# Create tests in apps/[app]/tests.py
```

### Backend (Node/Express)

```bash
# Install testing libraries
npm install -D vitest supertest @types/supertest

# Similar setup to frontend vitest
```

---

## Common Patterns

### API Call Pattern (Frontend)

```typescript
// app/lib/api.ts
export async function apiCall<T>(
  endpoint: string,
  options?: RequestInit
): Promise<T> {
  const response = await fetch(`/api/v1${endpoint}`, {
    ...options,
    headers: {
      'Content-Type': 'application/json',
      ...options?.headers,
    },
  })

  if (!response.ok) {
    const error = await response.json()
    throw new Error(error.message)
  }

  return response.json()
}
```

### Database Query Pattern (FastAPI + SQLAlchemy)

```python
# app/services/users.py
from sqlalchemy.orm import Session
from app.models import User

async def get_user(db: Session, user_id: int) -> User | None:
    """Get user by ID. Returns None if not found."""
    return db.query(User).filter(User.id == user_id).first()
```

### Error Handling Pattern (Next.js API Route)

```typescript
// app/api/v1/users/route.ts
import { NextResponse } from 'next/server'
import { z } from 'zod'

const UserSchema = z.object({
  name: z.string().min(1),
  email: z.string().email(),
})

export async function POST(request: Request) {
  try {
    const body = await request.json()
    const validated = UserSchema.parse(body)

    // ... create user

    return NextResponse.json({ user })
  } catch (error) {
    if (error instanceof z.ZodError) {
      return NextResponse.json(
        { error: { code: 'VALIDATION_ERROR', details: error.errors } },
        { status: 400 }
      )
    }

    return NextResponse.json(
      { error: { code: 'INTERNAL_ERROR', message: 'Something went wrong' } },
      { status: 500 }
    )
  }
}
```

---

## Deployment Checklist

### Before Deploying to Production

- [ ] All tests passing
- [ ] Environment variables configured (no hardcoded secrets)
- [ ] Database migrations run
- [ ] HTTPS enabled
- [ ] CORS configured correctly
- [ ] Rate limiting enabled
- [ ] Error logging set up (Sentry, LogRocket, etc.)
- [ ] Performance monitoring (Vercel Analytics, etc.)

### Vercel Deployment

```bash
# Install Vercel CLI
npm install -g vercel

# Deploy
vercel

# Set environment variables
vercel env add POSTGRES_URL
vercel env add NEXT_PUBLIC_API_URL
# etc.
```

### Render Deployment

```bash
# Install Render CLI
npm install -g render

# Or use dashboard at render.com
```

---

## Resources

- [Next.js docs](https://nextjs.org/docs)
- [FastAPI docs](https://fastapi.tiangolo.com/)
- [Django REST Framework](https://www.django-rest-framework.org/)
- [React Testing Library](https://testing-library.com/react)
- [Vitest docs](https://vitest.dev/)
