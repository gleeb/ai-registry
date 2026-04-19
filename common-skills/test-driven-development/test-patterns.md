# Known Test Patterns

**Load this reference when:** writing tests that touch CSS files, server-rendered components, browser globals, or bundler/Vite configs.

These are real patterns from working implementations. Each section leads with the working approach and explicitly names the trap to avoid.

---

## Pattern 1: Testing CSS file contents (when actually needed)

**When to use:** Only when the CSS file IS the product (e.g., a design token output, a generated theme file, or a security-scoped stylesheet). See Anti-Pattern 0 exceptions in `@testing-anti-patterns.md`.

**The trap:** Vite's `?raw` and `?inline` import suffixes return empty strings in Vitest. Do NOT use them.

```typescript
// ❌ BAD — returns '' in Vitest
import cssContent from './globals.css?raw';
expect(cssContent).toContain(':root {'); // always fails

// ✅ GOOD — use Node's readFileSync with import.meta.url resolution
import { readFileSync } from 'node:fs';
const css = readFileSync(new URL('./globals.css', import.meta.url), 'utf8');
expect(css).toContain(':root {');
```

**Why:** Vite processes `?raw` imports at bundle time; Vitest's module resolution bypasses that transform and returns an empty string. `readFileSync` with `import.meta.url` reads the source file directly from the filesystem, which is always available during test runs.

---

## Pattern 2: Testing React components without a DOM

**When to use:** Verifying that a component renders the correct HTML structure (element presence, text, ARIA roles) without mounting a real browser DOM. Faster and more portable than jsdom.

**The trap:** `@testing-library/react` and `jsdom`/`happy-dom` are not needed for simple structure assertions. Importing them increases setup complexity and adds side-effects that can bleed between test files.

```tsx
// ✅ GOOD — renderToStaticMarkup from react-dom/server, no DOM needed
import { renderToStaticMarkup } from 'react-dom/server';
import { MyComponent } from '../MyComponent';

it('renders the expected heading', () => {
  const html = renderToStaticMarkup(<MyComponent title="Hello" />);
  expect(html).toContain('<h1>Hello</h1>');
});
```

**Why:** `renderToStaticMarkup` runs synchronously in Node, produces a plain HTML string, and requires no DOM environment. Use `@testing-library/react` when you need user-interaction simulation (click, type) or accessibility queries — not for static structure assertions.

---

## Pattern 3: Mocking browser globals (window, document, navigator)

**When to use:** Testing code that branches on browser global availability (SSR-safe guards, feature detection, PWA checks).

**The traps:**
- `delete globalThis.window` is non-configurable in some environments and throws.
- `vi.stubGlobal` does not reset the prototype chain cleanly for nested properties.
- Not resetting in `afterEach` leaks the mock into subsequent tests.

```typescript
// ✅ GOOD — Object.defineProperty with configurable: true + afterEach reset

describe('navigator.onLine guard', () => {
  afterEach(() => {
    // Restore original descriptor — prevents leak between tests
    Object.defineProperty(globalThis, 'navigator', {
      configurable: true,
      value: undefined,
    });
  });

  it('handles missing navigator', () => {
    Object.defineProperty(globalThis, 'navigator', {
      configurable: true,
      value: undefined,
    });
    expect(isOnline()).toBe(false);
  });

  it('reports online when navigator.onLine is true', () => {
    Object.defineProperty(globalThis, 'navigator', {
      configurable: true,
      value: { onLine: true },
    });
    expect(isOnline()).toBe(true);
  });
});
```

**Why:** `Object.defineProperty` with `configurable: true` lets you redefine the property in `afterEach`, keeping tests isolated. Setting `value: undefined` in `afterEach` resets to a predictable baseline without needing to know the original descriptor.

---

## Pattern 4: Testing Vite config behavior

**When to use:** Verifying that a Vite config exports the correct plugin list, resolve aliases, build options, or PWA manifest fields.

**The trap:** Do not import and stringify the config object as text to check for key presence. Import and assert the exported structure directly.

```typescript
// ❌ BAD — fragile, breaks on whitespace/key-order changes
import { readFileSync } from 'node:fs';
const src = readFileSync('vite.config.ts', 'utf8');
expect(src).toContain('"pwa"');

// ✅ GOOD — import the config and assert the exported value
import viteConfig from '../vite.config';
import { defineConfig } from 'vite';

it('includes the PWA plugin', () => {
  // plugins is an array; find by name
  const plugins = (viteConfig as ReturnType<typeof defineConfig>).plugins ?? [];
  const pluginNames = (plugins as Array<{ name?: string }>)
    .flat()
    .map((p) => p?.name);
  expect(pluginNames).toContain('vite-plugin-pwa');
});

it('exports the correct PWA manifest icons', () => {
  // If the config exports named constants, import them directly
  import { pwaManifestIcons } from '../vite.config';
  expect(pwaManifestIcons).toEqual(
    expect.arrayContaining([
      expect.objectContaining({ sizes: '192x192' }),
      expect.objectContaining({ sizes: '512x512' }),
    ])
  );
});
```

**Why:** Importing the config module lets TypeScript type-check the assertion and keeps the test decoupled from formatting. If the config uses conditional logic, the imported value reflects the actual runtime result rather than raw source text.

---

## Pattern 5: Guarding browser-only APIs under jsdom (matchMedia / ResizeObserver / IntersectionObserver)

**When to use:** Testing code that calls browser APIs jsdom does not ship — `window.matchMedia`, `ResizeObserver`, `IntersectionObserver`, `requestIdleCallback` — and you can neither avoid the API nor switch the whole environment to a real browser.

**The trap:** These APIs are `undefined` under jsdom. Calling them throws before your component mounts. Stubbing them via `vi.stubGlobal` can leak between tests; patching `window.matchMedia = () => ...` without `configurable: true` fails when the property is read-only.

```typescript
// ✅ GOOD — test-double at the descriptor level + afterEach restore

type MediaQueryMock = Pick<MediaQueryList, 'matches' | 'media'> & {
  addEventListener: () => void;
  removeEventListener: () => void;
  addListener: () => void;
  removeListener: () => void;
  dispatchEvent: () => boolean;
  onchange: null;
};

function installMatchMediaMock(matches: boolean) {
  const original = Object.getOwnPropertyDescriptor(window, 'matchMedia');

  Object.defineProperty(window, 'matchMedia', {
    configurable: true,
    writable: true,
    value: (query: string): MediaQueryMock => ({
      matches,
      media: query,
      addEventListener: () => {},
      removeEventListener: () => {},
      addListener: () => {},
      removeListener: () => {},
      dispatchEvent: () => false,
      onchange: null,
    }),
  });

  return () => {
    if (original) {
      Object.defineProperty(window, 'matchMedia', original);
    } else {
      // jsdom didn't have it at all — remove so the "undefined" path remains observable
      delete (window as unknown as Record<string, unknown>).matchMedia;
    }
  };
}

describe('ThemeProvider', () => {
  let restoreMatchMedia: () => void;

  afterEach(() => {
    restoreMatchMedia?.();
  });

  it('uses dark scheme when prefers-color-scheme is dark', () => {
    restoreMatchMedia = installMatchMediaMock(true);
    // ... render and assert
  });

  it('falls back to light when matchMedia is missing entirely', () => {
    // Don't install — exercises the guard path
    // ... render and assert the fallback
  });
});
```

**Why the fallback case matters:** Production code often runs in environments that also lack the API (old embedded WebViews, SSR hosts). The guard in your code — `if (typeof window.matchMedia === 'function') { ... } else { /* fallback */ }` — is behavior you must verify, not just implementation detail. Test both branches.

**Do not:** write `window.matchMedia = vi.fn(...)` at module top level. That mutation persists across test files that run in the same jsdom instance and creates order-dependent failures that are painful to diagnose.

---

## Pattern 6: In-memory localStorage double for jsdom

**When to use:** Testing code that reads/writes `window.localStorage` under a jsdom environment where the provided Storage implementation is unreliable (known to happen across Vitest/jsdom versions — `removeItem` or `getItem` can be `undefined` in test contexts that bootstrap providers early).

**The trap:** `window.localStorage = { ... }` sometimes works, sometimes fails with a read-only-property error depending on the jsdom release. `vi.spyOn(window.localStorage, 'getItem')` fails entirely if `localStorage` itself is missing the method shape you expect.

```typescript
// ✅ GOOD — full in-memory Storage double, installed via descriptor, restored per test

function createMemoryStorage(): Storage {
  let store = new Map<string, string>();
  return {
    get length() {
      return store.size;
    },
    clear: () => {
      store = new Map();
    },
    getItem: (key) => (store.has(key) ? store.get(key)! : null),
    key: (index) => Array.from(store.keys())[index] ?? null,
    removeItem: (key) => {
      store.delete(key);
    },
    setItem: (key, value) => {
      store.set(key, String(value));
    },
  };
}

function installLocalStorageDouble() {
  const original = Object.getOwnPropertyDescriptor(window, 'localStorage');
  Object.defineProperty(window, 'localStorage', {
    configurable: true,
    writable: true,
    value: createMemoryStorage(),
  });
  return () => {
    if (original) {
      Object.defineProperty(window, 'localStorage', original);
    } else {
      delete (window as unknown as Record<string, unknown>).localStorage;
    }
  };
}

describe('SettingsProvider persistence', () => {
  let restore: () => void;

  beforeEach(() => {
    restore = installLocalStorageDouble();
  });

  afterEach(() => {
    restore();
  });

  it('persists the chosen theme across reloads', () => {
    // ... set, re-read, assert
  });
});
```

**Why this specific shape:**
- Full `Storage` contract — `getItem`, `setItem`, `removeItem`, `clear`, `key`, `length`. Partial doubles break when code reaches for a method you skipped.
- Descriptor-based install/restore — survives strict-mode readonly properties.
- Per-test install, not module-level — isolation across tests, no state leak.

**Do not:** reach for `JSON.stringify(window.localStorage)` as a "snapshot" in tests. The Storage interface is intentionally opaque; you'll either get `{}` or unpredictable output depending on jsdom version. Assert on what your production code observes (`getItem` return values), not on the Storage container itself.

---

## Related

- `testing-anti-patterns.md` — the "jsdom fidelity gaps" family of anti-patterns covers the general rule these patterns implement.
- `common-skills/webapp-testing/` — when jsdom fidelity is insufficient for the assertion you need (e.g. real CSS computation, true SW registration), move the test to a real browser via Playwright instead of building a more elaborate jsdom shim.
