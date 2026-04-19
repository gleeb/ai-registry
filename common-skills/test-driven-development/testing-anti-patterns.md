# Testing Anti-Patterns

**Load this reference when:** writing or changing tests, choosing what to assert on, adding mocks, or tempted to add test-only methods to production code.

## Overview

Tests must verify real behavior, not mock behavior, and not source artifacts. Mocks are a means to isolate, not the thing being tested.

**Core principle:** Test what the code does, not what the code is, and not what the mocks do.

**Following strict TDD prevents these anti-patterns.**

## The Iron Laws

```
1. NEVER test source artifacts instead of behavior
2. NEVER test mock behavior
3. NEVER add test-only methods to production classes
4. NEVER mock without understanding dependencies
```

## Anti-Pattern 0: Testing Source Artifacts Instead of Behavior

**The violation:**
```typescript
// ❌ BAD: asserting file contents
import { readFileSync } from 'node:fs';
const css = readFileSync('src/styles/globals.css', 'utf8');
expect(css).toContain(':root {');
expect(css).toContain('.app-shell {');

// ❌ BAD: asserting an exported constant
import { APP_VERSION } from '../constants';
expect(APP_VERSION).toBe('1.0.0');

// ❌ BAD: asserting a config key exists
import viteConfig from '../vite.config';
expect(JSON.stringify(viteConfig)).toContain('"pwa"');
```

**Why this is wrong:**
- You are testing that you wrote what you just wrote. It adds zero safety net.
- Static file content, exported constants, and config keys are easy to assert but impossible to break accidentally — and if they change intentionally, the test is now an obstacle.
- Created the multi-iteration yak-shave seen in the CSS import transcript: the agent committed to making a non-behavioral test pass across 4 different approaches.
- The rendered page or the module that consumes the constant already validates the meaningful behavior.

**your human partner's correction:** "Are we testing that a file contains specific text, or that the code produces correct output?"

**Good tests assert:**
- Rendered output contains expected elements (component test)
- Function returns expected values for given inputs (unit test)
- API responds with correct status and body (integration test)
- Browser shows expected content and interactions (E2E test)

**Suspect tests assert:**
- A CSS file contains specific selectors → test the rendered page instead
- A config file contains specific keys → test that the config produces correct behavior
- An exported constant equals a specific string → test the code that uses the constant
- A file exists at a specific path → the build/import will fail if it doesn't

**Exceptions — testing file contents IS appropriate when:**
- The file IS the product (JSON schemas, OpenAPI specs, migration files, codegen output)
- The content has direct security implications (CSP headers, CORS policy, secret-pattern absence)
- A codegen tool produces the file and correctness of the generated text is the acceptance criterion

### Gate Function

```
BEFORE asserting on file contents, exported constants, or config keys:
  Ask: "Is this asserting observable runtime behavior, or is it asserting source artifacts?"

  IF source artifact:
    Ask: "Does this file/constant/key fall under the listed exceptions
          (product output, security content, generated code)?"

    IF NOT exception:
      STOP — delete the assertion.
      Write a behavior test instead: test the rendered output, return value, or
      API response that depends on the thing you were about to assert on.

    IF exception:
      Proceed, but read @test-patterns.md for the correct pattern
      (e.g., readFileSync via import.meta.url — NOT Vite ?raw/?inline).
```

## Anti-Pattern 1: Testing Mock Behavior

**The violation:**
```typescript
// ❌ BAD: Testing that the mock exists
test('renders sidebar', () => {
  render(<Page />);
  expect(screen.getByTestId('sidebar-mock')).toBeInTheDocument();
});
```

**Why this is wrong:**
- You're verifying the mock works, not that the component works
- Test passes when mock is present, fails when it's not
- Tells you nothing about real behavior

**your human partner's correction:** "Are we testing the behavior of a mock?"

**The fix:**
```typescript
// ✅ GOOD: Test real component or don't mock it
test('renders sidebar', () => {
  render(<Page />);  // Don't mock sidebar
  expect(screen.getByRole('navigation')).toBeInTheDocument();
});

// OR if sidebar must be mocked for isolation:
// Don't assert on the mock - test Page's behavior with sidebar present
```

### Gate Function

```
BEFORE asserting on any mock element:
  Ask: "Am I testing real component behavior or just mock existence?"

  IF testing mock existence:
    STOP - Delete the assertion or unmock the component

  Test real behavior instead
```

## Anti-Pattern 2: Test-Only Methods in Production

**The violation:**
```typescript
// ❌ BAD: destroy() only used in tests
class Session {
  async destroy() {  // Looks like production API!
    await this._workspaceManager?.destroyWorkspace(this.id);
    // ... cleanup
  }
}

// In tests
afterEach(() => session.destroy());
```

**Why this is wrong:**
- Production class polluted with test-only code
- Dangerous if accidentally called in production
- Violates YAGNI and separation of concerns
- Confuses object lifecycle with entity lifecycle

**The fix:**
```typescript
// ✅ GOOD: Test utilities handle test cleanup
// Session has no destroy() - it's stateless in production

// In test-utils/
export async function cleanupSession(session: Session) {
  const workspace = session.getWorkspaceInfo();
  if (workspace) {
    await workspaceManager.destroyWorkspace(workspace.id);
  }
}

// In tests
afterEach(() => cleanupSession(session));
```

### Gate Function

```
BEFORE adding any method to production class:
  Ask: "Is this only used by tests?"

  IF yes:
    STOP - Don't add it
    Put it in test utilities instead

  Ask: "Does this class own this resource's lifecycle?"

  IF no:
    STOP - Wrong class for this method
```

## Anti-Pattern 3: Mocking Without Understanding

**The violation:**
```typescript
// ❌ BAD: Mock breaks test logic
test('detects duplicate server', () => {
  // Mock prevents config write that test depends on!
  vi.mock('ToolCatalog', () => ({
    discoverAndCacheTools: vi.fn().mockResolvedValue(undefined)
  }));

  await addServer(config);
  await addServer(config);  // Should throw - but won't!
});
```

**Why this is wrong:**
- Mocked method had side effect test depended on (writing config)
- Over-mocking to "be safe" breaks actual behavior
- Test passes for wrong reason or fails mysteriously

**The fix:**
```typescript
// ✅ GOOD: Mock at correct level
test('detects duplicate server', () => {
  // Mock the slow part, preserve behavior test needs
  vi.mock('MCPServerManager'); // Just mock slow server startup

  await addServer(config);  // Config written
  await addServer(config);  // Duplicate detected ✓
});
```

### Gate Function

```
BEFORE mocking any method:
  STOP - Don't mock yet

  1. Ask: "What side effects does the real method have?"
  2. Ask: "Does this test depend on any of those side effects?"
  3. Ask: "Do I fully understand what this test needs?"

  IF depends on side effects:
    Mock at lower level (the actual slow/external operation)
    OR use test doubles that preserve necessary behavior
    NOT the high-level method the test depends on

  IF unsure what test depends on:
    Run test with real implementation FIRST
    Observe what actually needs to happen
    THEN add minimal mocking at the right level

  Red flags:
    - "I'll mock this to be safe"
    - "This might be slow, better mock it"
    - Mocking without understanding the dependency chain
```

## Anti-Pattern 4: Incomplete Mocks

**The violation:**
```typescript
// ❌ BAD: Partial mock - only fields you think you need
const mockResponse = {
  status: 'success',
  data: { userId: '123', name: 'Alice' }
  // Missing: metadata that downstream code uses
};

// Later: breaks when code accesses response.metadata.requestId
```

**Why this is wrong:**
- **Partial mocks hide structural assumptions** - You only mocked fields you know about
- **Downstream code may depend on fields you didn't include** - Silent failures
- **Tests pass but integration fails** - Mock incomplete, real API complete
- **False confidence** - Test proves nothing about real behavior

**The Iron Rule:** Mock the COMPLETE data structure as it exists in reality, not just fields your immediate test uses.

**The fix:**
```typescript
// ✅ GOOD: Mirror real API completeness
const mockResponse = {
  status: 'success',
  data: { userId: '123', name: 'Alice' },
  metadata: { requestId: 'req-789', timestamp: 1234567890 }
  // All fields real API returns
};
```

### Gate Function

```
BEFORE creating mock responses:
  Check: "What fields does the real API response contain?"

  Actions:
    1. Examine actual API response from docs/examples
    2. Include ALL fields system might consume downstream
    3. Verify mock matches real response schema completely

  Critical:
    If you're creating a mock, you must understand the ENTIRE structure
    Partial mocks fail silently when code depends on omitted fields

  If uncertain: Include all documented fields
```

## Anti-Pattern 5: Integration Tests as Afterthought

**The violation:**
```
✅ Implementation complete
❌ No tests written
"Ready for testing"
```

**Why this is wrong:**
- Testing is part of implementation, not optional follow-up
- TDD would have caught this
- Can't claim complete without tests

**The fix:**
```
TDD cycle:
1. Write failing test
2. Implement to pass
3. Refactor
4. THEN claim complete
```

## Anti-Pattern 6: Relying on jsdom for CSS/Computed-Style Contracts

**The violation:**
```typescript
// ❌ BAD: asserting on computed style under jsdom
import { render } from '@testing-library/react';
import { AppShell } from '../AppShell';

it('uses the correct theme tokens', () => {
  const { container } = render(<AppShell />);
  const styles = window.getComputedStyle(container.firstElementChild!);
  expect(styles.getPropertyValue('--color-bg')).toBe('#0f172a'); // unreliable
  expect(styles.minHeight).toBe('44px'); // often reports '0px' or empty
});
```

**Why this is wrong:**
- jsdom's CSSOM does not fully apply imported global stylesheets. `getComputedStyle` for custom properties and for rules originating from a linked stylesheet can return empty, stale, or zero values.
- The test passes or fails based on the jsdom version, not on the actual CSS contract.
- You end up writing "make this specific jsdom quirk look correct" code in your stylesheet, which then breaks when the real browser renders it.

**The fix:**

Separate the two things this test is trying to do:

```typescript
// ✅ GOOD: assert the CSS contract by reading the source stylesheet directly
import { readFileSync } from 'node:fs';

const css = readFileSync(new URL('../src/styles/globals.css', import.meta.url), 'utf8');
expect(css).toMatch(/--color-bg:\s*#0f172a/);
expect(css).toMatch(/min-height:\s*44px/);
```

```typescript
// ✅ GOOD: assert the rendered-behavior contract in a real browser (Playwright)
test('tap target is ≥44px', async ({ page }) => {
  await page.goto('/');
  const box = await page.locator('[data-testid="primary-action"]').boundingBox();
  expect(box!.height).toBeGreaterThanOrEqual(44);
});
```

The first test verifies that the stylesheet has the token. The second verifies the user-observable behavior. Neither of them asks jsdom to do something jsdom cannot reliably do.

### Gate Function

```
BEFORE asserting on window.getComputedStyle(...) under jsdom:
  Ask: "Is this value supplied by a linked stylesheet or by a CSS custom property?"

  IF yes:
    STOP. jsdom's CSSOM does not guarantee this value.
    Split the assertion:
      - Assert the CSS source via readFileSync (for the contract), OR
      - Assert the behavior via Playwright in a real browser (for the UX).

  IF no (inline style attribute you set in the test):
    getComputedStyle is fine for inline styles you control.
```

## Anti-Pattern 7: Vitest Accidentally Excluding Your Test File Because It Looks Like a Config

**The violation:**
```typescript
// vitest.config.ts — file is test-of-vite-config
export default defineConfig({
  test: {
    include: ['src/**/*.test.ts', 'tests/**/*.test.ts'],
    // default excludes apply — includes **/*.config.*
  },
});

// src/vite.config.test.ts — named so it sits next to vite.config.ts
describe('vite.config', () => { /* ... */ });
// vitest run finds NO test files
```

**Why this is wrong:**
- Vitest's default `configDefaults.exclude` contains `**/*.config.*` to keep tool configs out of the suite. A test named `vite.config.test.ts` matches that glob and is silently excluded.
- You change the `include` pattern, you change the test filename, you add individual file paths — nothing fixes it until you realize the exclude list is the problem.
- The failure mode is "zero tests run, command exits 0" — passes CI, proves nothing.

**The fix:**

Filter `configDefaults.exclude` to drop only the specific glob, keeping the rest:

```typescript
// ✅ GOOD
import { defineConfig, configDefaults } from 'vitest/config';

export default defineConfig({
  test: {
    include: ['src/**/*.test.ts', 'tests/**/*.test.ts'],
    exclude: configDefaults.exclude.filter((glob) => glob !== '**/*.config.*'),
  },
});
```

Do not replace the entire exclude list — you'll re-admit `node_modules`, `dist`, and other paths the default excludes for good reasons.

## Anti-Pattern 8: Importing Vite Config in a Test Under the Default jsdom Environment

**The violation:**
```typescript
// src/vite.config.test.ts — no environment annotation
import viteConfig from '../vite.config';

it('declares the PWA plugin', () => {
  // throws: "TextEncoder().encode("") instanceof Uint8Array" — esbuild invariant
  const plugins = viteConfig.plugins ?? [];
  // ...
});
```

**Why this is wrong:**
- Vite's config module is evaluated by esbuild, which expects a Node runtime. Under jsdom, `TextEncoder` and related globals are the jsdom shim, not Node's; esbuild's invariant check fires and the whole test file fails to load.
- The error points at esbuild internals, not at your test — finding the root cause takes multiple iterations.
- Switching the whole project to `environment: 'node'` breaks every component test that relies on a DOM.

**The fix:**

Annotate only the config-loading tests with a Node environment:

```typescript
// ✅ GOOD — per-file environment annotation
// @vitest-environment node
import { defineConfig } from 'vite';
import viteConfig from '../vite.config';

describe('vite.config', () => {
  it('declares the PWA plugin', () => {
    const plugins = (viteConfig as ReturnType<typeof defineConfig>).plugins ?? [];
    const names = (plugins as Array<{ name?: string }>).flat().map((p) => p?.name);
    expect(names).toContain('vite-plugin-pwa');
  });
});
```

Other tests in the same suite continue to use the project default (`jsdom` or whatever else). The annotation is per-file; drop it into the one or two files that load Node-only modules.

### When this pattern generalizes

Any module that calls Node-only APIs during import — `node:fs`, `node:path` in a way that touches esbuild/Vite internals, Rollup plugin factories — needs the same treatment. The rule is "if it's meant for the build, test it in Node". Don't try to make jsdom survive Node-only imports.

## When Mocks Become Too Complex

**Warning signs:**
- Mock setup longer than test logic
- Mocking everything to make test pass
- Mocks missing methods real components have
- Test breaks when mock changes

**your human partner's question:** "Do we need to be using a mock here?"

**Consider:** Integration tests with real components often simpler than complex mocks

## TDD Prevents These Anti-Patterns

**Why TDD helps:**
1. **Write test first** → Forces you to think about what you're actually testing
2. **Watch it fail** → Confirms test tests real behavior, not mocks
3. **Minimal implementation** → No test-only methods creep in
4. **Real dependencies** → You see what the test actually needs before mocking

**If you're testing mock behavior, you violated TDD** - you added mocks without watching test fail against real code first.

## Quick Reference

| Anti-Pattern | Fix |
|--------------|-----|
| Assert on file contents / constants / config keys | Test runtime behavior instead; see exceptions + @test-patterns.md |
| Assert on mock elements | Test real component or unmock it |
| Test-only methods in production | Move to test utilities |
| Mock without understanding | Understand dependencies first, mock minimally |
| Incomplete mocks | Mirror real API completely |
| Tests as afterthought | TDD - tests first |
| Over-complex mocks | Consider integration tests |
| `getComputedStyle` assertion under jsdom | Split: source-read for CSS contract, Playwright for UX behavior |
| Config-named test file silently excluded | Filter `configDefaults.exclude`; don't replace it |
| Config import breaks under jsdom | Annotate per-file with `// @vitest-environment node` |

## Red Flags

- Assertion checks for `*-mock` test IDs
- Methods only called in test files
- Mock setup is >50% of test
- Test fails when you remove mock
- Can't explain why mock is needed
- Mocking "just to be safe"

## The Bottom Line

**Mocks are tools to isolate, not things to test.**

If TDD reveals you're testing mock behavior, you've gone wrong.

Fix: Test real behavior or question why you're mocking at all.
