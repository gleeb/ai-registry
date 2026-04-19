# Vite React Preamble and Direct TSX Mounting

**Load this reference when:** attempting browser-side verification of a React component by importing the TSX module directly from a Vite dev server in Playwright / an ad-hoc page, and seeing one of: `@vitejs/plugin-react can't detect preamble`, an empty mount, `Invalid hook call`, or a refresh-runtime error.

## The failure mode

`@vitejs/plugin-react` injects a small "preamble" script at the top of the HTML entry document. That preamble registers React Refresh's runtime globals before any TSX module is evaluated. The plugin's transform for TSX modules assumes this preamble has already run: the generated module code references `__vite_plugin_react_preamble_installed__` (or equivalent), and throws if that hook isn't present.

When you open a bare URL like `http://localhost:5173/src/components/Settings.tsx` (or let Playwright `page.goto('/__vite_inject__/Settings.tsx')`), you bypass the dev server's real HTML entrypoint. The preamble never runs. The TSX module throws on evaluation and nothing mounts.

This is not a bug you can work around from the outside. The plugin author's intent is that all dev-mode TSX goes through the HTML entry.

## Symptom signature

Any of these in the browser console during an ad-hoc mount:

- `@vitejs/plugin-react can't detect preamble. Something is wrong.`
- `Uncaught Error: Invalid hook call. ...`
- `Failed to fetch dynamically imported module: http://localhost:<port>/src/.../Component.tsx`
- The mount point is empty and there are no React errors — just silence.

If you see any of these while trying to mount a TSX module directly, this is the cause.

## Mitigations, in priority order

### 1. Wire the component through the real app entrypoint (preferred)

Add a route or a dev-only debug page inside the actual app bundle. Then `page.goto('/debug/settings')` in Playwright. The preamble runs as part of the normal `index.html` load, the refresh runtime is installed, and the component mounts like any other route.

This is the correct long-term fix. The temporary mount cost is minutes; the "why doesn't this work" debugging cost of the alternatives is hours.

### 2. Component tests plus the verify gate (practical fallback)

When you only need to assert component behavior (not browser-rendered pixels), skip browser smoke entirely:

- Write component tests with `@testing-library/react` + Vitest (or `renderToStaticMarkup` for pure structure).
- Rely on the full verify pipeline (typecheck + unit + component + integration) as your evidence of behavioral correctness.
- Explicitly note in the task's verification record: "browser smoke skipped; component covered by component tests + verify gate."

### 3. Skip with a staging note (last resort)

If the component is trivial (no interaction, already covered by tests), and you'd only be verifying it appears on screen:

- Skip browser verification for this task.
- Record a gotcha entry noting the preamble blocker and a link to this reference.
- Do not invent a workaround. Workarounds to this specific problem either don't work or leak test-only code into production.

## Anti-patterns

- **Manually injecting a `<script>` tag with the preamble string.** The preamble format is not stable across `@vitejs/plugin-react` versions. You will succeed once, then break on the next plugin upgrade. Do not do this.
- **Dynamically `import()`-ing the TSX from a blank page.** Same root cause. The TSX transform still assumes the preamble ran.
- **Switching to `@vitejs/plugin-react-swc` in the hope that it "just works".** The SWC plugin has the same preamble requirement; you'll get a different error message for the same cause.
- **Using `page.setContent()` with inline TSX + a script tag importing `/@react-refresh`.** This produces a working-looking shell that still won't mount components with hooks. Even when it appears to work, it hides subtle runtime mismatches that bite later.

## Gate function

```
BEFORE attempting to mount a TSX module directly in a browser for verification:
  Ask: "Am I going through index.html / the app's normal entrypoint?"

  IF no:
    STOP. The preamble is not injected on this path.
    Pick mitigation #1 (wire through a real route) if verification must be browser-based.
    Otherwise pick mitigation #2 (component tests + verify gate).

  IF yes:
    Proceed. The preamble runs; TSX modules evaluate normally.
```

## Red flags

- Playwright setup code that does `page.goto('/src/...')` or `page.goto('/@fs/...')`.
- Test scaffolding that hand-injects `/@react-refresh` or a preamble `<script>`.
- A PR adding a "debug TSX mount" helper that is not part of the production route table.
- Multiple iterations of the same gotcha across different tasks in the same story — indicates the team is fighting the preamble rather than routing around it.

## Related

- [vite-dev-server-port.md](./vite-dev-server-port.md) — another class of ad-hoc-browser-smoke failure (stale port); the symptoms overlap and you may hit both at once.
- [react-hook-purity.md](./react-hook-purity.md) — a real `Invalid hook call` can also come from duplicate React copies; rule out the preamble first, then look at hook-purity and multiple-React-roots.
