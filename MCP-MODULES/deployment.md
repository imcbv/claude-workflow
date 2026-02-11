# Deployment MCPs

## Vercel MCP

**When:** Deploying Next.js or frontend apps to Vercel

**Features:**
- Deploy from Claude Code
- Check deployment status
- View logs
- Manage environment variables

**Built-in:** Check your tool list for `mcp__vercel__*` tools

**Setup:**
```bash
# Already available if Vercel MCP is installed
# Authenticate via Vercel dashboard token
```

**Use cases:**
```bash
# Inside Claude Code
"Deploy this to Vercel production"
"Check the latest deployment logs"
"Add STRIPE_SECRET_KEY environment variable to production"
```

**Source:** [Vercel MCP announcement](https://vercel.com/blog/introducing-vercel-mcp-connect-vercel-to-your-ai-tools)

---

## Render MCP

**When:** Deploying backends, databases, or full-stack apps to Render

**Features:**
- Create web services, cron jobs, static sites
- Manage databases (PostgreSQL)
- View logs and metrics
- Update environment variables

**Built-in:** Check your tool list for `mcp__render__*` tools (you have this!)

**Use cases:**
```bash
# Inside Claude Code
"Deploy this FastAPI app to Render"
"Create a PostgreSQL database on Render"
"Check logs for my API service"
"Add environment variable DATABASE_URL"
```

**For your projects:**
- One big AWS Beanstalk project → Consider migrating to Render (easier MCP integration)
- Other projects → Render is great for APIs, cron jobs, databases

---

## Fly.io MCP

**When:** Deploying to Fly.io (you use this)

**Features:**
- Deploy apps
- View status and logs
- Manage machines

**Built-in:** Check your tool list for `mcp__flymcp__*` tools (you have this!)

**Use cases:**
```bash
# Inside Claude Code
"Deploy this to Fly.io"
"Check Fly.io app status"
"Get logs for my Fly.io machine"
```

---

## AWS Beanstalk

**MCP Status:** No official MCP found

**Recommendation:**
- Use AWS CLI via Bash tool for now
- Or consider migrating to Render (better Claude Code integration)

**If staying with Beanstalk:**
```bash
# From Claude Code, use Bash tool
eb deploy
eb logs
eb setenv KEY=value
```

---

## Redis

**MCP Status:** No dedicated Redis MCP found in research

**Recommendation:**
- Use Redis clients in your code
- Claude Code can help write Redis queries

**Example in FastAPI:**
```python
import redis
r = redis.Redis(host='localhost', port=6379)
r.set('key', 'value')
```

---

## Comparison: Which Deployment Platform?

| Platform | MCP Support | Best For | Your Use |
|----------|------------|----------|----------|
| **Vercel** | ✅ Official | Next.js, frontends | Some projects |
| **Render** | ✅ Official | APIs, databases, full-stack | Some projects |
| **Fly.io** | ✅ Available | Low-latency apps, global | Some projects |
| **AWS Beanstalk** | ❌ None | Enterprise, one big project | One project |

**Recommendation:** Use Render MCP and Fly.io MCP for new projects. They have excellent Claude Code integration.

---

## Deployment Checklist (All Platforms)

Add to CLAUDE.md:

```markdown
## Deployment Checklist

Before deploying:
- [ ] All tests passing
- [ ] Environment variables set (no hardcoded secrets)
- [ ] Database migrations run
- [ ] HTTPS enabled
- [ ] Logs configured
- [ ] Error tracking set up (Sentry, etc.)

After deploying:
- [ ] Smoke test critical paths (auth, payments, key features)
- [ ] Check logs for errors
- [ ] Monitor performance (response times)
```
