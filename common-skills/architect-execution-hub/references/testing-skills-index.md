# Testing Skills Index

Single source of truth for which testing skills to load for which activity, when, and by whom.

## Skill Inventory

| Skill | Path | Source | Purpose |
|-------|------|--------|---------|
| test-driven-development | `skills/test-driven-development/` | obra/superpowers | TDD red-green-refactor methodology |
| webapp-testing | `skills/webapp-testing/` | anthropics/skills | Native browser-based E2E testing with Playwright |
| playwright-best-practices | `skills/playwright-best-practices/` | currents-dev | 50+ Playwright patterns: E2E, component, API, visual, a11y |
| nodejs-backend-patterns | `skills/nodejs-backend-patterns/` | wshobson/agents | Backend integration test patterns, middleware, DB testing |
| e2e-testing-patterns | `skills/e2e-testing-patterns/` | wshobson/agents | E2E testing strategy, test pyramid ratios, CI/CD patterns |
| systematic-debugging | `skills/systematic-debugging/` | obra/superpowers | Root-cause tracing, test polluter detection, defense-in-depth |

## When to Load Each Skill

### Planning Phase

| Activity | Skill | Agent | When |
|----------|-------|-------|------|
| Test pyramid design | e2e-testing-patterns | planning-testing-strategy | Phase 2 of testing strategy workflow |
| Coverage threshold definition | (built-in — TEST-PLAN.md section 14) | planning-testing-strategy | Phase 5 of testing strategy workflow |

### Execution Phase — Implementer

| Activity | Skill | When |
|----------|-------|------|
| Writing tests (TDD cycle) | test-driven-development | `phase: test_writing` — before writing any test |
| Integration/API test patterns | nodejs-backend-patterns | `phase: test_writing` — when task involves API endpoints or data flows |
| E2E test scenarios | playwright-best-practices | `phase: test_writing` — when task has UI-facing ACs requiring E2E tests |

### Execution Phase — QA Verifier

| Activity | Skill | When |
|----------|-------|------|
| E2E test adequacy evaluation | webapp-testing | `phase: test_adequacy_check` — when evaluating browser-facing test coverage |
| Playwright pattern validation | playwright-best-practices | `phase: test_adequacy_check` — when reviewing E2E test quality |
| Beyond-suite edge case design | nodejs-backend-patterns | `phase: fresh_execution` — when designing beyond-suite verification |

### Execution Phase — Code Reviewer

| Activity | Skill | When |
|----------|-------|------|
| Test quality assessment | test-driven-development | `phase: code_quality_assessment` — verify TDD patterns in test code |
| Integration test review | nodejs-backend-patterns | `phase: code_quality_assessment` — verify API/DB test patterns |

### Execution Phase — Architect Hub

| Activity | Skill | When |
|----------|-------|------|
| Persistent test failure diagnosis | systematic-debugging | When review/QA iterations hit 3+ for the same defect |
| Test polluter detection | systematic-debugging | When previously passing tests fail after new code |

## Loading Protocol

Skills are loaded on-demand, not at initialization. Each agent loads skills only when the specific activity occurs:

1. Check if the skill path exists: `skills/<skill-name>/SKILL.md`
2. Read `SKILL.md` for methodology and workflow instructions
3. Follow the skill's patterns for the current activity
4. Do not load skills that don't apply to the current task type

## Substitution Notes

The original plan specified `backend-testing` and `testing-strategies` from `supercent-io/skills-template` (private repo). These were substituted:
- `backend-testing` → `nodejs-backend-patterns` (wshobson/agents) — covers the same API/DB integration test patterns
- `testing-strategies` → `e2e-testing-patterns` (wshobson/agents) — covers test pyramid ratios and CI/CD patterns
