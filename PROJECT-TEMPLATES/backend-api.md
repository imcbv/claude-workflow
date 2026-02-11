# Backend API Template

> **Stack:** FastAPI / Django / Node + PostgreSQL / MongoDB + Redis
> **Use Case:** Pure backend APIs, microservices, data pipelines

---

## CLAUDE.md Quick Config

```markdown
# Project: [API_NAME]
# Stack: [FastAPI | Django | Node] + [PostgreSQL | MongoDB] + Redis
# Type: [Production | MVP]

## API Standards
- **Versioning:** /api/v1/, /api/v2/
- **Auth:** JWT in Authorization header
- **Response Format:**
  ```json
  {
    "data": {...},
    "meta": { "page": 1, "total": 100 }
  }
  ```
- **Errors:**
  ```json
  {
    "error": {
      "code": "ERROR_CODE",
      "message": "User message",
      "details": {}
    }
  }
  ```

## Performance Requirements
- [ ] All endpoints < 200ms response time
- [ ] Database queries use indexes
- [ ] Redis caching for frequently accessed data
- [ ] Pagination for list endpoints (limit: 100 max)

## Testing
- **Coverage:** 80%+ on critical paths (auth, payments, data processing)
- **Approach:** TDD for business logic

## Deployment: [Render | Fly.io | AWS Beanstalk]
```

---

## MCPs Needed

- Context7, GitHub, File System (core)
- PostgreSQL MCP or MongoDB MCP
- Redis MCP (if using)
- Render/Fly.io/AWS MCP (for deployment)

---

## Testing: pytest or vitest

```bash
# FastAPI/Django
pip install pytest pytest-asyncio httpx
pytest

# Node
npm install -D vitest supertest
npx vitest
```
