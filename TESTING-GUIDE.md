# Testing Guide: When and How to Test

> **Last Updated:** 2026-02-11
> **Research:** Reddit (188 upvotes, 106 comments), X (102 likes), Web (10+ guides)

---

## The Testing Paradigm Shift (2026)

**Old wisdom (2024):**
> "Never use TDD when building an MVP. It will really slow you down." - r/FlutterDev (39 upvotes, 19 comments)

**New reality (Feb 2026):**
> "TDD used to feel slow because you wrote both sides. Now the model handles the boilerplate, and tests become the spec. Feels less like overhead and more like steering." - @_introvertaf

> "When code generation is cheap, verification becomes the bottleneck. TDD stops being overhead and starts being guardrails for stochastic output." - @talantfund (4 likes)

**Translation:** With AI writing code, tests are no longer overhead - they're the ONLY way to verify correctness.

---

## Decision Tree: When to Test

### 🚀 MVP / Prototype (Speed Priority)

**Test this:** NO
**Why:** You're validating ideas, not shipping to users
**Exception:** If you have existing tests from a similar project, let Claude adapt them (< 5% overhead)

**Technical debt:**
- **Low risk** if you rewrite from scratch after validation
- **High risk** if MVP becomes production (it always does)

**Mitigation:**
```markdown
# Add to CLAUDE.md for MVP projects:
## Testing: MVP Mode
- NO unit tests unless explicitly requested
- Focus: ship fast, validate idea
- When pivoting to production: full test suite before adding features
```

---

### 🏗️ Production / Shipped Apps (Quality Priority)

**Test this:** YES - Full TDD
**Why:** AI-generated code contains subtle bugs that look correct
**Overhead:** ~5-15% time investment, but prevents catastrophic bugs

**The TDD Workflow with Claude Code:**

From r/ClaudeCode (188 upvotes, staff engineer with 14 years experience):

#### Step 1: Write Tests FIRST

```bash
# Tell Claude explicitly:
"Write a FAILING test for [feature]. Do NOT write implementation yet."
```

**Why explicit?** Claude naturally writes implementation first. You MUST force TDD.

#### Step 2: See It Fail

Claude runs the test → RED ❌

#### Step 3: Implement

Claude writes minimal code to pass the test

#### Step 4: Auto-Test Hook Runs

Hook automatically runs tests → GREEN ✅

#### Step 5: Refactor

Claude improves code, tests keep passing

**Sources:**
- [r/ClaudeCode TDD thread](https://www.reddit.com/r/ClaudeCode/comments/1qd64xx/tdd_workflows_with_claude_code_whats_actually/) (188 upvotes, 106 comments)
- [Skywork.ai guide](https://skywork.ai/blog/how-to-generate-documentation-unit-tests-claude-code-plugin/)
- [ngconf Medium article](https://medium.com/ngconf/create-reliable-unit-tests-with-claude-code-9147d050d557)

---

### 🛠️ Refactoring / Legacy Code (Safety Priority)

**Test this:** YES - Tests as safety net
**Why:** "You can't refactor without tests" - every experienced dev

**Strategy:**
1. Let Claude generate tests for existing code FIRST
2. Verify tests pass with current code
3. Refactor with confidence
4. Tests catch regressions

**Source:** [AI Agents subreddit](https://www.reddit.com/r/AI_Agents/comments/1qon7mi/how_to_refactor_50k_lines_of_legacy_code_without/) - "How to refactor 50k lines without breaking prod"

---

## Setting Up Testing (Step-by-Step)

### If You've NEVER Used Tests Before

**What tests do:** Verify your code does what you think it does

**Example:**
```python
# Your code (app.py)
def add(a, b):
    return a + b

# Test (test_app.py)
def test_add():
    assert add(2, 3) == 5  # ✅ PASS
    assert add(-1, 1) == 0  # ✅ PASS
    assert add(0, 0) == 0  # ✅ PASS
```

If someone breaks `add()` later, tests fail immediately.

### Step 1: Choose Your Framework

**Python:**
- pytest (most popular)
- `pip install pytest`
- Run: `pytest`

**JavaScript/TypeScript:**
- Vitest (modern, fast)
- `npm install -D vitest`
- Run: `npx vitest`

**React:**
- React Testing Library + Vitest
- `npm install -D @testing-library/react vitest`

**FastAPI:**
- pytest + httpx
- `pip install pytest httpx`

**Django:**
- Built-in: `python manage.py test`

**React Native:**
- Jest (built-in)
- `npm test`

### Step 2: Create a Testing Agent

Create `~/.claude/agents/testing-agent/AGENT.md`:

```markdown
---
name: Testing Agent
description: Writes and runs comprehensive unit tests
---

# Testing Agent

You are a testing specialist. Your job:

1. **Write tests FIRST** before implementation (TDD)
2. **Cover edge cases:** empty arrays, null values, boundary conditions
3. **Use the project's test framework** (check package.json or requirements.txt)
4. **Run tests after writing them** to verify they work
5. **Aim for 80%+ coverage** on critical paths

## Test Structure

- **Unit tests:** Individual functions
- **Integration tests:** Multiple components working together
- **Edge cases:** What breaks this code?

## After Every Test File

1. Run the test suite
2. Report: ✅ passing, ❌ failing, and coverage %
3. If failing, fix immediately

## Project-Specific Notes

[Claude Code auto-detects test framework from package.json/requirements.txt]
```

**How this works:**
- Claude Code detects when you're about to write tests
- Auto-loads this agent with all testing rules
- You never have to remind Claude about testing again

**Source:** [Skywork.ai](https://skywork.ai/blog/how-to-use-skills-in-claude-code-install-path-project-scoping-testing/) - "Claude Code detects testing context and auto-loads the agent"

### Step 3: Add Hooks (Automated Testing)

Add to `.claude/settings.json`:

```json
{
  "hooks": [
    {
      "name": "auto-test-on-code-change",
      "event": "PostToolUse",
      "filter": "Edit|Write",
      "prompt": "Verify all unit tests still pass. Run the test suite and report results."
    },
    {
      "name": "auto-test-on-test-file",
      "event": "PostToolUse",
      "filter": "Write",
      "command": "if [[ $CLAUDE_TOOL_FILE =~ test.*\\.(py|js|ts|jsx|tsx)$ ]]; then pytest $CLAUDE_TOOL_FILE 2>/dev/null || npm test 2>/dev/null; fi"
    }
  ]
}
```

**What this does:**
- After Claude writes/edits ANY code → prompt to run tests
- After Claude writes a TEST file → immediately run that test
- You see TDD cycle happen in real-time

**Sources:**
- [Claude Code hooks docs](https://code.claude.com/docs/en/hooks-guide)
- [Letanure blog](https://www.letanure.dev/blog/2025-08-06--claude-code-part-8-hooks-automated-quality-checks)
- [Medium guide](https://medium.com/@joe.njenga/use-claude-code-hooks-newest-feature-to-fully-automate-your-workflow-341b9400cfbe)

### Step 4: Update CLAUDE.md

Add to your project's `.claude/CLAUDE.md`:

```markdown
## Testing Requirements

**Framework:** [pytest | vitest | jest | built-in]
**Coverage Target:** 80%+ on critical paths
**Approach:** Test-Driven Development (TDD)

### TDD Process
1. I describe a feature
2. You write a FAILING test
3. You implement minimal code to pass
4. Hooks auto-run tests
5. You refactor if needed

### What to Test
- ✅ Critical business logic
- ✅ External API calls
- ✅ Database operations
- ✅ Payment flows (Stripe)
- ✅ Authentication
- ❌ Simple getters/setters
- ❌ Framework code (React hooks, Django ORM)

### Edge Cases to Cover
- Empty/null inputs
- Boundary conditions (0, -1, MAX_INT)
- Network failures (for API calls)
- Race conditions (for async code)
```

**Why this works:** CodeRabbit reads CLAUDE.md, so it knows your testing standards during code review.

---

## Testing Different Tech Stacks

### React / Next.js

```bash
npm install -D vitest @testing-library/react @testing-library/jest-dom
```

**Test structure:**
```javascript
// components/Button.test.tsx
import { render, screen } from '@testing-library/react'
import { Button } from './Button'

test('renders button with text', () => {
  render(<Button>Click me</Button>)
  expect(screen.getByText('Click me')).toBeInTheDocument()
})
```

**Run:** `npx vitest`

### FastAPI / Python

```bash
pip install pytest httpx
```

**Test structure:**
```python
# test_main.py
from fastapi.testclient import TestClient
from main import app

client = TestClient(app)

def test_read_root():
    response = client.get("/")
    assert response.status_code == 200
    assert response.json() == {"message": "Hello World"}
```

**Run:** `pytest`

### Django

**Test structure:**
```python
# myapp/tests.py
from django.test import TestCase
from .models import User

class UserModelTest(TestCase):
    def test_create_user(self):
        user = User.objects.create(username="test")
        self.assertEqual(user.username, "test")
```

**Run:** `python manage.py test`

### React Native

```bash
# Built-in with React Native
npm test
```

**Test structure:**
```javascript
// __tests__/App.test.js
import { render } from '@testing-library/react-native'
import App from '../App'

test('renders correctly', () => {
  const { getByText } = render(<App />)
  expect(getByText('Welcome')).toBeTruthy()
})
```

---

## Common Questions

### Q: "What if I don't know what to test?"

**A:** Let Claude identify edge cases.

```
"Analyze this function and identify all edge cases I should test.
Then write tests for each edge case."
```

Claude will find: null inputs, empty arrays, boundary conditions, error states.

**Source:** [Medium guide](https://medium.com/ngconf/create-reliable-unit-tests-with-claude-code-9147d050d557) - "Ask Claude to identify edge cases you missed"

### Q: "What's the actual time overhead?"

**A:** Research shows:
- **Writing tests manually:** 30-50% overhead (old)
- **AI writes tests:** 5-15% overhead (2026)
- **AI writes code + tests together:** Almost zero overhead (TDD with hooks)

**Source:** X posts from @RyanCarniato thread (Feb 2026)

### Q: "Can I skip tests for throwaway prototypes?"

**A:** YES. But add to CLAUDE.md:

```markdown
## Testing: PROTOTYPE MODE
- This is a throwaway prototype to validate [specific idea]
- NO tests required
- If this works, we'll rebuild with tests before production
```

This tells Claude AND future code reviewers your intent.

---

## Measuring Success

### Coverage Reports

**Python (pytest):**
```bash
pip install pytest-cov
pytest --cov=. --cov-report=html
open htmlcov/index.html
```

**JavaScript (vitest):**
```bash
npx vitest --coverage
```

### What Coverage Should You Aim For?

**General rules:**
- **80%+** on critical paths (payments, auth, data processing)
- **50-60%** on UI components (harder to test, less critical)
- **Don't chase 100%** - diminishing returns

**Source:** r/ClaudeAI thread "Built 7 production apps in 3 months" - "I made 90%+ coverage a hard requirement. This is not always the flex you think it is."

---

## Technical Debt Calculator

**If you skip testing, here's the debt:**

| Project Type | Skip Testing? | Technical Debt | Repay Cost |
|-------------|---------------|----------------|------------|
| MVP (will rewrite) | ✅ YES | Low | Zero (you rewrite) |
| MVP (might ship) | ⚠️ RISKY | High | 3-5x feature time |
| Production | ❌ NO | Catastrophic | 10x+ feature time |
| Refactor | ❌ NO | Catastrophic | Can't refactor safely |

**Repay cost:** Time to add tests AFTER the code is written and bugs are in production.

---

## Resources

### Official Docs
- [Claude Code common workflows](https://code.claude.com/docs/en/common-workflows)
- [Claude Code testing guide](https://www.claudecode101.com/en/tutorial/workflows/test-driven)

### Community Guides
- [Skywork.ai testing guide](https://skywork.ai/blog/how-to-generate-documentation-unit-tests-claude-code-plugin/)
- [Medium: 9 ways Claude Code helps with testing](https://medium.com/@joe.njenga/9-ways-claude-code-helps-me-with-testing-and-debugging-like-a-pro-tester-69c8776282ab)
- [Shipyard: E2E testing with Claude Code](https://shipyard.build/blog/e2e-testing-claude-code/)

### Reddit Discussions
- [TDD workflows (188 upvotes)](https://www.reddit.com/r/ClaudeCode/comments/1qd64xx/tdd_workflows_with_claude_code_whats_actually/)
- [Are you really doing TDD? (46 upvotes, 142 comments)](https://www.reddit.com/r/ClaudeCode/comments/1q9vkvh/those_doing_tdd_are_you_really/)
- [Writing tests thread (r/ClaudeAI)](https://www.reddit.com/r/ClaudeAI/comments/1qszisg/writing_tests/)

---

## Next: Set Up Your Git Workflow

See `GIT-WORKFLOW.md` for parallel worktrees and running multiple Claude Code agents simultaneously.
