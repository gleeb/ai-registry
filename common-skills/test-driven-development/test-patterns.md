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
