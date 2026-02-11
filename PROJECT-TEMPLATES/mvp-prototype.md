# MVP / Prototype Template

> **Stack:** Any
> **Use Case:** Fast iteration, idea validation, throwaway prototypes

---

## CLAUDE.md Quick Config

```markdown
# Project: [PROTOTYPE_NAME]
# Stack: [Whatever gets it done fastest]
# Type: **MVP / PROTOTYPE** (not for production)

## MVP Rules
1. **Speed > Quality** - Ship fast, validate idea
2. **No tests** unless explicitly requested
3. **No code review** (this is throwaway code)
4. **Hardcode** when it saves time (mark with TODO for later)
5. **Document assumptions** in comments

## Exit Strategy
When this MVP succeeds:
- [ ] Rewrite with production setup (TESTING-GUIDE.md)
- [ ] Add tests before adding features
- [ ] Refactor hardcoded values
- [ ] Set up proper deployment

## Current Hypothesis
[What are you validating?]
Example: "Users will pay for feature X"

## Success Criteria
[When do you move to production?]
Example: "10 paying users OR 100 signups"
```

---

## MCPs Needed

**Minimal.** Just Context7 + GitHub.

---

## Hooks Configuration

```json
{
  "hooks": [
    {
      "name": "force-skill-loader",
      "event": "PrePrompt",
      "command": "echo 'Loading CLAUDE.md...' && cat .claude/CLAUDE.md 2>/dev/null"
    }
  ]
}
```

**NO auto-test hook.** Speed is priority.

---

## When to Upgrade to Production

Signs your MVP needs production setup:

- ✅ Users are actually using it (not just testing)
- ✅ You're adding features (not just validating)
- ✅ Bugs are causing real problems
- ✅ You're thinking "I should rewrite this"

**Action:** Use ASSESSMENT-PROMPT.md to upgrade setup.
