# Database MCPs

## PostgreSQL MCP

**When:** Using PostgreSQL or Supabase

**Setup:**
```bash
# Check if installed in Claude Code settings
# If not, add from MCP registry
```

**Use cases:**
- Query database from Claude Code
- Generate migrations
- Debug slow queries
- Set up indexes

---

## MongoDB MCP

**When:** Using MongoDB

**Setup:**
```bash
# Check MCP registry for MongoDB server
```

**Use cases:**
- Query collections
- Design schemas
- Create indexes
- Aggregation pipelines

---

## Supabase MCP

**When:** Using Supabase (built on PostgreSQL)

**Features:**
- Database queries (via PostgreSQL MCP)
- Auth management
- Storage buckets
- Edge functions

**Built-in tools available** (check your tool list for mcp__supabase__)

**Use cases:**
- Create tables and RLS policies
- Generate TypeScript types
- Deploy edge functions
- Query logs
