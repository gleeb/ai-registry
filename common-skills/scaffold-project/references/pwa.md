# Progressive Web App (PWA) Setup

Use when the project requires offline support, installability, or service worker capabilities on top of a React + Vite base. Read [react-vite.md](react-vite.md) first and complete that scaffold, then apply this on top.

## Dependencies

```bash
pnpm add -D vite-plugin-pwa workbox-window
```

## Configuration

```ts
// vite.config.ts
import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';
import { VitePWA } from 'vite-plugin-pwa';

export default defineConfig({
  plugins: [
    react(),
    VitePWA({
      registerType: 'autoUpdate',
      devOptions: { enabled: true },
      workbox: {
        globPatterns: ['**/*.{js,css,html,ico,png,svg,woff2}'],
        globIgnores: ['**/node_modules/**/*', 'dev-dist/**'],
      },
      manifest: {
        name: '<App Name>',
        short_name: '<Short>',
        description: '<Description>',
        theme_color: '#ffffff',
        background_color: '#ffffff',
        display: 'standalone',
        start_url: '/',
        icons: [
          {
            src: 'icons/icon-192x192.png',
            sizes: '192x192',
            type: 'image/png',
          },
          {
            src: 'icons/icon-512x512.png',
            sizes: '512x512',
            type: 'image/png',
          },
          {
            src: 'icons/icon-512x512.png',
            sizes: '512x512',
            type: 'image/png',
            purpose: 'maskable',
          },
        ],
      },
    }),
  ],
});
```

## Public Icon Assets

Place raster PNG icons in `public/icons/`. These are served as static files:

```
public/
└── icons/
    ├── icon-192x192.png    # Required for Android add-to-homescreen
    ├── icon-512x512.png    # Required for splash screen + maskable
    └── favicon.ico         # Browser tab icon
```

Generate from a single 1024x1024 source using a tool like `pwa-asset-generator` or `sharp`.

## Exclude dev-dist/ from Everything

Add to every config from the first commit:

```ts
// vitest.config.ts — coverage exclusions
coverage: {
  include: ['src/**/*.{ts,tsx}'],
  exclude: [
    'src/**/*.{test,spec}.{ts,tsx}',
    'src/**/*.d.ts',
    'src/test-setup.ts',
    'dist/**',
    'dev-dist/**',       // ← Required: workbox generated files
    'node_modules/**',
  ],
}
```

```jsonc
// tsconfig.json — exclude from compilation
{
  "exclude": ["node_modules", "dist", "dev-dist"]
}
```

```jsonc
// biome.json — exclude from linting
{
  "files": {
    "ignore": ["dist", "dev-dist", "node_modules"]
  }
}
```

```
# .gitignore — generated in dev, not committed
dev-dist/
```

---

## PWA Scaffolding Verification Checklist

This checklist extends the base [react-vite.md](react-vite.md) checklist. Both must pass.

### PWA Configuration

- [ ] `vite-plugin-pwa` installed and configured in `vite.config.ts`
- [ ] `devOptions.enabled: true` set for development mode PWA testing
- [ ] `registerType` explicitly set (`"autoUpdate"` or `"prompt"`) and documented
- [ ] Web manifest has: `name`, `short_name`, `description`, `theme_color`, `background_color`, `display: "standalone"`, `start_url`
- [ ] Service worker strategy chosen and documented (`generateSW` vs `injectManifest`)
- [ ] Workbox `globIgnores` excludes `**/node_modules/**/*`

### Icon Assets

- [ ] `public/icons/icon-192x192.png` exists — raster PNG (not SVG)
- [ ] `public/icons/icon-512x512.png` exists — raster PNG (not SVG)
- [ ] 512x512 icon has a maskable variant (either separate file or `purpose: "maskable"` in manifest)
- [ ] Icons referenced in manifest match actual file paths in `public/`

### Exclusions (all four must be configured)

- [ ] `dev-dist/**` excluded from Vitest coverage
- [ ] `dev-dist` excluded from `tsconfig.json` compilation
- [ ] `dev-dist` excluded from Biome/ESLint linting
- [ ] `dev-dist/` added to `.gitignore`

### Verification Gate

```bash
pnpm build            # Exits 0, generates dist/ with sw.js and manifest.webmanifest
pnpm preview          # App loads, no console errors, PWA installable prompt appears (Chrome DevTools → Application → Manifest)
pnpm test             # Exits 0 (all tests pass without dev-dist contaminating coverage)
```

Check in Chrome DevTools → Application → Service Workers: service worker registered and active.
Check Application → Manifest: all icons resolve without 404.

---

## Known Gotchas


### dev-dist/ coverage contamination — most common scaffold failure

`vite-plugin-pwa` with `devOptions.enabled: true` generates workbox service worker files in `dev-dist/` during development. These files are large (~3400 lines of generated code) and have 0% coverage. If not excluded from the Vitest coverage configuration, they pull overall coverage from 100% down to 2-3%, triggering false coverage failures on every test run. Configure exclusions at initial scaffold commit — not after the first QA failure.

### Chrome requires raster PNG icons for installability

Chrome's PWA installability criteria require at minimum a 192x192 and a 512x512 raster PNG icon in the web manifest. SVG icons alone do NOT satisfy the installability requirements and will not trigger the "Add to Home Screen" prompt. Additionally, Android requires a maskable icon (512x512 with safe zone padding) for adaptive icon display. Generate PNGs from your SVG source at scaffold time — not as a follow-up task.

### MSW and vite-plugin-pwa service worker conflict

`vite-plugin-pwa` with `generateSW` strategy registers a service worker at the root scope (`/`). Only one service worker can be active per scope. If you use Mock Service Worker (MSW) for API mocking, the PWA service worker will conflict with or silently remove the MSW service worker registration. Symptoms: MSW intercepts stop working in development after the PWA SW registers.

Solutions (choose one at scaffold time):
1. **Disable PWA in non-production via env var**: `devOptions: { enabled: process.env.NODE_ENV === 'production' }`
2. **Use `injectManifest` strategy** with a custom SW that conditionally enables MSW by checking `import.meta.vitest` or an env flag
3. **Register MSW in a sub-scope** (e.g., `/api/`) to avoid scope overlap


### Development mode vs production behavior

In `generateSW` mode with `devOptions.enabled: true`, the dev service worker only precaches the app entry point, not all static assets. Offline functionality and full Workbox caching behavior only work in `build + preview` mode. Use the dev PWA mode for testing notifications, background sync, and install prompts — not for offline behavior testing.

### Service worker update strategy is a UX decision

- `registerType: "autoUpdate"`: SW updates silently on next page load. Users get new versions automatically. Suitable for web apps where version inconsistency is low risk.
- `registerType: "prompt"`: Surfaces an update prompt to the user. Required for apps where mid-session updates could break state (e.g., data entry forms, in-progress workflows).

Choose at scaffold time based on the app's UX requirements. Changing this later requires coordinating with users who already have the old SW cached.

### Workbox globPatterns must not include dev-dist/

The `workbox.globPatterns` field tells Workbox which files to precache. If `dev-dist/` is not in `globIgnores`, Workbox may attempt to precache workbox's own generated files, creating circular precache dependencies. Always include `'dev-dist/**'` in `globIgnores`.
