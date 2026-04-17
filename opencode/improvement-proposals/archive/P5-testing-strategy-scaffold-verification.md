# P5: Testing Strategy & Scaffold Verification

**Status:** Largely resolved — scaffold tier complete; feature-tier behavior-first principle, escalation protocol, and test patterns addressed. Remaining open: Feature vs Integration tier definitions (LOW).
**Relates to:** [P1 (Ceremony Scaling)](./P1-ceremony-scaling-and-scaffolding.md), [P3 (Verification Pipeline)](./P3-verification-pipeline.md)
**Scope:** `opencode/.opencode/agents/sdlc-engineering-implementer.md` (test writing section), `opencode/.opencode/agents/sdlc-engineering-qa.md` (test adequacy checks), `common-skills/test-driven-development/`, scaffolding skill test guidance
**Transcript evidence:** `ses_278b8ce55ffeKxlkK4NQaSyTHd` — CSS test yak-shave (~20 min, 4+ iterations), coverage config churn, test files that assert static file contents rather than runtime behavior

---

## 0. Current Status (2026-04-16)

### What P1 and P3 already resolved

**Scaffold testing tier (section 2.1 "Scaffold" row, section 2.3, section 2.4).**
Completely solved by P1's architecture. The scaffold lifecycle now runs through `@sdlc-engineering-scaffolder` → `@sdlc-engineering-implementer` (dispatched without TDD skill) → `@sdlc-engineering-scaffold-reviewer` (binary PASS/FAIL, no adversarial stance, no coverage thresholds). The general QA agent is never dispatched for scaffold tasks, so `TASK_TYPE: scaffold` is moot. Coverage is scoped correctly from day one (checklist items mandate `dev-dist/`, `dist/`, `node_modules/` exclusions and forbid global thresholds during scaffold).

**CSS content testing gotcha (section 1.1).**
Solved by P1's Known Gotchas in `react-vite.md` and `pwa.md`: "Vitest + CSS imports return empty strings … Do NOT test CSS file contents via `?raw` or `?inline` imports." The scaffolder dispatches this as `KNOWN GOTCHAS TO PREVENT`, which prevents the 4-iteration yak-shave from recurring at scaffold time.

**Coverage config churn (section 1.2).**
Solved by P1. The scaffold checklist requires correct `coverage.include` / `coverage.exclude` at scaffold time, and P3's `vitest.config.ts`-enforced thresholds (via `coverage.thresholds`) are not set during scaffold per the checklist.

### Resolved by this iteration (2026-04-17)

1. **Behavior-first testing principle (section 2.2).** Added as Anti-Pattern 0 in `common-skills/test-driven-development/testing-anti-patterns.md`. Includes good/suspect/exception classification, a gate function, and a cross-link from the Quick Reference table. SKILL.md trigger updated to mention "when choosing what to assert on". Code-reviewer updated with a one-line pointer to Anti-Pattern 0 that flags source-artifact tests as Important.

2. **Test failure escalation protocol (section 3.2).** Inlined into `sdlc-engineering-implementer.md` Test Writing section. Rule: stop after 2 failures on the same assertion, apply Anti-Pattern 0 gate, check `test-patterns.md`, try fundamentally different approaches, HALT after 3. Must be inline (not a lazy-loaded skill) because the rule fires during in-flight iteration.

3. **Known test patterns skill (section 3.3).** Created as `common-skills/test-driven-development/test-patterns.md` — four patterns: CSS via `readFileSync`/`import.meta.url`, `renderToStaticMarkup`, browser globals with `Object.defineProperty`, Vite config import-and-assert. Loader pointer added to TDD SKILL.md. Follows the existing sibling-reference pattern established by `testing-anti-patterns.md`.

### What remains open

4. **Feature and Integration tier definitions (section 2.1 remaining rows).** Only the Scaffold tier is operational. The QA agent still applies uniform coverage/test rigor to both Feature (Phase 2) and Integration (Phase 3) tasks. This is a lower-priority gap because the defaults work acceptably for typical feature work, but it becomes a problem for thin-glue tasks (renames, imports-only changes) where coverage threshold enforcement adds noise.

### Priority (updated)

- **Feature/Integration tier definitions (LOW).** Defer until we have evidence this is a real bottleneck for non-scaffold tasks.

---

## 1. Problem Statement

The testing strategy during the scaffold execution had two distinct problems:

### 1.1 Wrong test target: testing file contents instead of behavior

The implementer created `src/styles/globals.test.ts` that imported the CSS file and asserted it contained specific selectors (`:root {`, `.app-shell {`, `.surface-list {`). This test:
- Tests that a file you just wrote contains the strings you just wrote. It adds zero safety net.
- Created a 4-iteration debugging cycle when Vitest's CSS transform returned empty strings for `?raw` and `?inline` imports.
- Was ultimately rewritten 3 times before landing on `readFileSync` — a workaround for a non-problem.
- The browser smoke test already validates that styles are applied (rendered page shows styled components).

### 1.2 Coverage thresholds applied uniformly

The QA agent enforced coverage thresholds on a scaffolding task with the same strictness as a feature task. When `dev-dist/` generated files (3400+ lines of workbox code) dragged global coverage to 2.52%, this triggered remediation to fix coverage configuration — a structural issue that should have been prevented by the scaffold template.

### 1.3 The broader concern

"Don't test static file contents" is a rule that's easy to state for scaffolding but could be harmful if applied broadly. As the project grows, there ARE cases where testing file contents or configurations is valuable:
- Schema validation files (JSON schemas, OpenAPI specs)
- Configuration correctness (security headers, CSP policies)
- Generated code output (codegen tools, migration files)

The challenge is defining a testing strategy that **scales from scaffolding to mature feature work** without either under-testing (missing real bugs) or over-testing (testing that you wrote what you wrote).

---

## 2. Proposed Solution: Phase-Aware Testing Tiers

### 2.1 Testing tier definitions

Define testing intensity tiers that map to execution phases and task types:

| Tier | When | What to test | Coverage target | What NOT to test |
|------|------|--------------|-----------------|------------------|
| **Scaffold** | Phase 0b, Task 0 | Build passes, dev server starts, structural assertions (route count, component renders), smoke test | Source files individually at reasonable levels; no global threshold | Static file contents, CSS selector existence, copy/paste constants |
| **Feature** | Phase 2, Tasks 1+ | Unit tests per AC, integration tests for boundaries, negative/error paths, coverage thresholds from testing strategy | Per testing-strategy.md thresholds (e.g., 75% line, 75% branch on new code) | Exhaustive permutation testing, UI pixel tests (unless design story) |
| **Integration** | Phase 3 | Cross-task interaction tests, E2E critical paths, regression checks | Cumulative story coverage meets thresholds | Re-running all per-task tests (already passed) |

### 2.2 Behavior-first testing principle

Add a guiding principle to the test-driven-development skill and implementer agent:

> **Test observable behavior, not source artifacts.**
>
> A test should assert what the code *does*, not what the code *is*.
>
> **Good tests assert:**
> - Rendered output contains expected elements (component test)
> - Function returns expected values for given inputs (unit test)
> - API responds with correct status and body (integration test)
> - Browser shows expected content and interactions (E2E test)
>
> **Suspect tests assert:**
> - A CSS file contains specific selectors (test the rendered page instead)
> - A config file contains specific keys (test that the config produces correct behavior)
> - An exported constant equals a specific string (test the code that uses the constant)
> - A file exists at a specific path (the build/import will fail if it doesn't)
>
> **Exception:** Testing file contents IS appropriate when:
> - The file IS the product (schema definitions, API specs, migration files)
> - The content has security implications (CSP headers, CORS config, secret patterns)
> - The content is generated by a codegen tool and correctness matters

### 2.3 Scaffold-specific testing guidance

Add to the scaffolding skill (see [P1](./P1-ceremony-scaling-and-scaffolding.md)):

```markdown
## Scaffold Test Requirements

### Required tests
- App renders without errors (renderToStaticMarkup or mount test)
- Route baseline has expected number of entries (structural assertion)
- Build produces output (npm run build exits 0 — handled by verify script)
- Dev server starts (npm run dev exits cleanly — can be manual or script check)

### Required E2E (if browser verification is mandatory)
- Page loads and shows expected heading
- PWA manifest is accessible and contains required icons
- Service worker registers

### NOT required during scaffolding
- Per-file CSS content tests
- Per-constant string value tests
- Exhaustive branch coverage on boilerplate entry points
- Coverage threshold enforcement at the global level

### Coverage during scaffolding
- Individual source files should have reasonable coverage (>50%)
- Global coverage thresholds do NOT apply until the first feature task
- Coverage configuration MUST exclude generated directories from the start (see Known Gotchas)
```

---

## 3. Error Recovery Pattern for Test Failures

### 3.1 The problem with trial-and-error

The CSS test failure loop (lines ~14900-15500 of transcript) shows a pattern:
1. Write test with approach A → fails
2. Research documentation → try approach B → fails
3. Research more → try approach C → fails
4. Finally try approach D → passes

Each iteration is a full patch + run + read-output cycle. The agent didn't step back to question whether the test was necessary — it was committed to making the test work because "every source module must have a test file."

### 3.2 Test failure escalation protocol

Add to the implementer's Test Writing section:

> **When a test approach fails twice for the same assertion:**
>
> 1. STOP iterating on the implementation approach.
> 2. Ask: "Is this test asserting behavior or file contents?" If file contents, consider whether a behavior test would be more appropriate (see behavior-first principle).
> 3. Ask: "Is this test required by an acceptance criterion?" If not, and the behavior is already covered by another test, skip it.
> 4. If the test IS required and IS behavioral: document the blocker in Issues & Resolutions and try a fundamentally different approach (not a variation of the same approach).
> 5. If 3 fundamentally different approaches fail: HALT and escalate to the hub with the blocker detail.
>
> Do NOT iterate more than 3 times on a single test assertion. The cost of iteration exceeds the value of the test.

### 3.3 Known test patterns skill

Extend the test-driven-development skill or create a `common-skills/test-patterns/` skill with known working patterns for common scenarios:

```markdown
## Known Test Patterns

### Testing CSS file contents (when actually needed)
Use `readFileSync` with `import.meta.url` resolution. Do NOT use Vite ?raw or ?inline imports in Vitest.

\`\`\`ts
import { readFileSync } from 'node:fs';
const css = readFileSync(new URL('./globals.css', import.meta.url), 'utf8');
expect(css).toContain(':root {');
\`\`\`

### Testing React components without a DOM
Use `renderToStaticMarkup` from `react-dom/server`. No jsdom or happy-dom needed.

\`\`\`tsx
import { renderToStaticMarkup } from 'react-dom/server';
const html = renderToStaticMarkup(<MyComponent />);
expect(html).toContain('expected text');
\`\`\`

### Mocking browser globals (window, document, navigator)
Use Object.defineProperty with configurable: true. Reset in afterEach.

\`\`\`ts
beforeEach(() => {
  delete (globalThis as { window?: unknown }).window;
});

it('handles missing window', () => {
  // window is undefined
});

it('handles window with capabilities', () => {
  Object.defineProperty(globalThis, 'window', {
    configurable: true,
    value: { matchMedia: vi.fn(() => ({ matches: true })) },
  });
});
\`\`\`

### Testing Vite config behavior
Import the config and assert plugin/option presence. Do NOT test the config file as text.

\`\`\`ts
import { pwaManifestIcons } from '../vite.config';
expect(pwaManifestIcons).toEqual([...]);
\`\`\`
```

---

## 4. Affected Agents and Skills

| File | Change Type | Description |
|------|-------------|-------------|
| `opencode/.opencode/agents/sdlc-engineering-implementer.md` | Modified | Test Writing section: added test failure escalation protocol (2-fail stop rule, Anti-Pattern 0 check, test-patterns.md lookup, 3-approach max before HALT) |
| `opencode/.opencode/agents/sdlc-engineering-code-reviewer.md` | Modified | Test review section: added pointer to Anti-Pattern 0 to flag source-artifact assertions |
| `common-skills/test-driven-development/SKILL.md` | Modified | Updated anti-patterns trigger line; added test-patterns.md loader pointer |
| `common-skills/test-driven-development/testing-anti-patterns.md` | Modified | Added Anti-Pattern 0 (Testing Source Artifacts Instead of Behavior) with gate function; updated Quick Reference table |
| `common-skills/test-driven-development/test-patterns.md` | Created | Four known working patterns: CSS readFileSync, renderToStaticMarkup, browser globals mocking, Vite config import-and-assert |

---

## 5. Open Questions

1. **How strictly to enforce "behavior over file contents"?** The exceptions list (schemas, security configs, generated code) needs to be precise enough that agents don't over-apply the rule. Should this be a hard rule with listed exceptions, or a guideline with agent judgment?
2. **Should the scaffold testing tier apply to ALL Task 0 outputs, or only to Phase 0b (greenfield)?** If a project already exists and Task 0 is "add a new module scaffold," the relaxed testing tier might be inappropriate.
3. **Test pattern maintenance.** The known test patterns skill needs updating as libraries evolve. Who updates it? Proposed: when an implementer discovers a new working pattern during execution, it records it in the staging doc. Post-story, a documentation pass can promote patterns to the skill.
4. **Integration with P4 (documentation lookup).** Some test failures are caused by incorrect API usage that context7 could have prevented. Should the test failure escalation protocol include "check context7 for the library's test integration guidance" as step 2.5?
