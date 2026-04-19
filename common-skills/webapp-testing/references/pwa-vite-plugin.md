# vite-plugin-pwa: Custom Worker Registration in Prod and Dev

**Load this reference when:** wiring `vite-plugin-pwa` with a custom service worker (`strategies: 'injectManifest'`) and seeing any of: service worker never registers in the browser, `ServiceWorker script evaluation failed` in dev, prod smoke flakes on offline/installability, or custom navigation routes never match.

## The three decisions that matter

Every `vite-plugin-pwa` setup with a custom `injectManifest` worker stands or falls on three knobs. Most incidents are a mismatch on one of them.

1. **`injectRegister`** — how the registration call gets into the browser.
2. **Production worker `type`** — `classic` vs `module`.
3. **`devOptions.navigateFallback`** — required when the custom worker registers navigation routes in dev.

## Decision 1: `injectRegister`

The plugin supports several values; the practical choice is between two.

| `injectRegister`     | What it does                                                      | When to use                                                    |
|----------------------|-------------------------------------------------------------------|----------------------------------------------------------------|
| `'auto'`             | Tries to use the virtual register module; **no-ops if your app does not import it**. | Only when your app explicitly does `import { registerSW } from 'virtual:pwa-register'`. |
| `'script-defer'`     | Injects a `<script defer>` that registers the SW directly into the HTML entry. | Default for plugin-only setups — no app code change needed, registration is guaranteed. |
| `'script'`           | Same as above but non-deferred. Rarely needed.                    | Avoid unless you have a specific ordering requirement.         |
| `null`               | Disables injection; you must register the SW yourself.            | Only if you already have a hand-written `navigator.serviceWorker.register(...)` call and want full control. |

**Default recommendation for a custom worker without explicit registration code:** `injectRegister: 'script-defer'`.

The trap is that `auto` looks safe but silently does nothing when your app doesn't import the virtual module. You get a built worker sitting on disk and a browser that never registers it.

```typescript
// vite.config.ts
import { VitePWA } from 'vite-plugin-pwa';

export default defineConfig({
  plugins: [
    VitePWA({
      strategies: 'injectManifest',
      srcDir: 'src/sw',
      filename: 'sw.ts',
      injectRegister: 'script-defer',
      // ... rest of config
    }),
  ],
});
```

## Decision 2: Production worker `type`

When `vite-plugin-pwa` registers the worker for you, the production registration is `type: 'classic'`. If you hand-wrote a registration call anywhere — a legacy bootstrap file, a mid-refactor helper — and it drifted to `type: 'module'`, production behavior diverges from dev because the worker is re-fetched and re-evaluated with different module semantics.

| Environment | Expected `type` |
|-------------|-----------------|
| Production  | `'classic'`      |
| Dev (plugin-managed) | `'module'` — the plugin emits ESM for dev-mode iteration |

The dev path is the plugin's concern. For production, either:

- **Let the plugin register the worker** (recommended). Remove any hand-written `navigator.serviceWorker.register(...)` call.
- **Or, if you must register manually**, register with `{ type: 'classic' }` in production builds and `{ type: 'module' }` in dev — matching what the plugin does internally. This is fragile; prefer the plugin path.

The mismatch symptom: dev works, prod build registers but the worker never takes control of navigations, offline tests fail.

## Decision 3: `devOptions.navigateFallback`

A custom `injectManifest` worker in dev mode with `devOptions: { enabled: true }` will throw `ServiceWorker script evaluation failed` for `dev-sw.js?dev-sw` if the worker handles navigation requests and no fallback is configured.

The dev worker needs an explicit navigation fallback so it can route SPA navigations the same way the production worker will once it precaches `index.html`.

```typescript
VitePWA({
  strategies: 'injectManifest',
  srcDir: 'src/sw',
  filename: 'sw.ts',
  injectRegister: 'script-defer',
  devOptions: {
    enabled: true,
    type: 'module',
    navigateFallback: 'index.html',
  },
  // ...
});
```

Skip this only if:

- Your custom worker does not register any navigation routes (`registerRoute({ request: { mode: 'navigate' } })` / `NavigationRoute` via Workbox).
- Or you disable `devOptions.enabled` and only test the worker in `vite preview`.

## Verification checklist

Before claiming PWA behavior works, verify against the **production bundle** served by `vite preview`, not the dev server:

```bash
npm run build
npm run preview -- --port 4180 --strictPort
# Then run Playwright smoke against http://localhost:4180
```

**Why preview, not dev:**

- Dev mode uses the plugin's dev-sw shim, which behaves differently from the real worker on the lifecycle edges (install, activate, skipWaiting, offline navigation).
- Precaching against the real build is what your users will experience. Dev precaching is a simulation and can mask bugs.
- Tests that pass against dev and fail against preview are common; tests that pass against preview and fail against dev rarely matter.

Smoke checks that should pass against the preview bundle:

- SW registers (`navigator.serviceWorker.getRegistration()` resolves to an active registration).
- App manifest is served (`GET /manifest.webmanifest` returns 200 with correct JSON).
- Reload works offline after first load (caches are populated, `context.setOffline(true)` + reload still renders the app shell).
- Installability check via CDP (see related notes).

## Anti-patterns

- **`injectRegister: 'auto'` without importing the virtual module.** No-op; looks correct; doesn't register.
- **Mixing plugin-managed registration with hand-written `navigator.serviceWorker.register(...)`.** Two competing registrations race; behavior depends on load order and is not reproducible.
- **Omitting `devOptions.navigateFallback` when the custom worker registers navigation routes.** Dev server crashes on SW evaluation; you debug for an hour before finding this line.
- **Validating PWA behavior against the dev server.** Dev-mode SW semantics differ from prod. Always build + preview for PWA smoke.
- **Committing `dist/` or the generated `sw.js` to debug a registration issue.** The artifact is produced from config + source; fix the config.

## Gate function

```
BEFORE claiming a custom injectManifest worker is wired correctly:
  1. Is injectRegister set? (NOT the default — an explicit value matching your registration strategy)
  2. Is dev-mode navigateFallback set if the worker has navigation routes?
  3. Is there ANY hand-written navigator.serviceWorker.register in the codebase? If yes — remove it.
  4. Run `npm run build && npm run preview`; hit the preview URL; confirm registration in the browser.

  IF any step fails: stop before writing PWA smoke tests. The tests will give misleading signal.
```

## Red flags

- The word "auto" in `injectRegister` alongside a custom worker.
- A manual `navigator.serviceWorker.register(...)` call in `main.ts` or `bootstrap.ts`.
- PWA smoke tests that only ever run against `npm run dev`.
- A `devOptions.navigateFallback` line that's been commented out "temporarily".
- `type: 'module'` hard-coded in a production registration path.

## Related

- [vite-dev-server-port.md](./vite-dev-server-port.md) — stale-port browser sessions can mask SW registration bugs; rule out port collisions before debugging SW issues.
- [vite-react-preamble.md](./vite-react-preamble.md) — direct-TSX-mount preamble errors are sometimes reported alongside SW errors; the two are independent and should be diagnosed separately.
- `common-skills/playwright-best-practices/browser-apis/service-workers.md` — the Playwright-side patterns for asserting SW behavior against the preview bundle, including `clear registrations before reload` and the CDP manifest-enum gotcha.
