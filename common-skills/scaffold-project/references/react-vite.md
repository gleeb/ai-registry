# React + Vite (SPA / Client-Side App)

Use for dashboards, internal tools, SPAs, and client-heavy applications where SSR/SEO is not critical.

## Scaffold

```bash
pnpm create vite@latest <app-name> --template react-ts
cd <app-name>
pnpm install
```

If inside a monorepo, create under `apps/` and skip `pnpm install` (root handles it).

## Post-Scaffold Checklist

1. **TypeScript strict mode** — set `"strict": true` in `tsconfig.json` (template default).
2. **Path aliases** — add to `tsconfig.json` and `vite.config.ts`:

```jsonc
// tsconfig.json
{ "compilerOptions": { "baseUrl": ".", "paths": { "@/*": ["./src/*"] } } }
```

```ts
// vite.config.ts
import { defineConfig } from "vite";
import react from "@vitejs/plugin-react";
import { resolve } from "path";

export default defineConfig({
  plugins: [react()],
  resolve: { alias: { "@": resolve(__dirname, "src") } },
});
```

3. **Linting & formatting** — see [web-tooling.md](web-tooling.md).
4. **Environment variables** — use `.env` files; prefix with `VITE_` for client exposure.

## Recommended Folder Structure

```
src/
├── assets/          # Static assets (images, fonts)
├── components/      # Shared/reusable components
│   └── ui/          # Primitive UI components
├── features/        # Feature-based modules
│   └── auth/
│       ├── components/
│       ├── hooks/
│       └── utils/
├── hooks/           # Global custom hooks
├── lib/             # Third-party wrappers & configs
├── pages/           # Route-level components (if using router)
├── stores/          # State management (Zustand, Jotai, etc.)
├── types/           # Shared TypeScript types
├── utils/           # Pure utility functions
├── App.tsx
└── main.tsx
```

## Key Libraries (2026)

| Purpose | Recommended | Notes |
|---------|-------------|-------|
| Routing | React Router v7 or TanStack Router | TanStack Router for type-safe routing |
| State | Zustand or Jotai | Zustand for global, Jotai for atomic |
| Data fetching | TanStack Query | Server state caching & sync |
| Forms | React Hook Form + Zod | Zod for schema validation |
| Styling | Tailwind CSS v4 | Utility-first, see [web-tooling.md](web-tooling.md) |
| Testing | Vitest + Testing Library | Vitest integrates natively with Vite |

---

## Scaffolding Verification Checklist

Run through every item before marking the scaffold complete. This is the contract the scaffold-reviewer checks against.

### Project Structure

- [ ] `package.json` with scripts: `dev`, `build`, `preview`, `lint`, `typecheck`, `test`
- [ ] `tsconfig.json` with `"strict": true`, `"moduleResolution": "bundler"`, `"jsx": "react-jsx"`
- [ ] `vite.config.ts` with React plugin and path aliases (`@/*` → `./src/*`)
- [ ] `index.html` with `<div id="root">` and `<script type="module" src="/src/main.tsx">`
- [ ] `src/main.tsx` entry point with `createRoot`
- [ ] `src/App.tsx` (or `src/app/app.tsx`) shell component
- [ ] `src/styles/globals.css` base styles
- [ ] Path aliases consistent between `tsconfig.json` and `vite.config.ts`

### Testing Infrastructure

- [ ] `vitest.config.ts` (or inline in `vite.config.ts`) with:
  - `environment: "jsdom"`
  - `globals: true`
  - `setupFiles: ["./src/test-setup.ts"]`
  - `coverage.provider: "v8"`
  - `coverage.include: ["src/**/*.{ts,tsx}"]`
  - `coverage.exclude: ["src/**/*.{test,spec}.{ts,tsx}", "src/**/*.d.ts", "src/test-setup.ts", "dist/**", "node_modules/**"]`
- [ ] `src/test-setup.ts` importing `@testing-library/jest-dom`
- [ ] `@testing-library/react`, `@testing-library/user-event`, `@testing-library/jest-dom` installed as dev deps
- [ ] At least one smoke test exists and passes (`pnpm test` exits 0)
- [ ] Coverage thresholds NOT enforced during scaffold (add thresholds only after feature implementation begins)

### Linting & Formatting

- [ ] Biome or ESLint + TypeScript configured — see [web-tooling.md](web-tooling.md)
- [ ] Linter ignores `dist/` and `node_modules/`
- [ ] `pnpm lint` exits 0 on clean scaffold

### Verification Gate (all must pass before scaffold is done)

```bash
pnpm install          # No errors
pnpm dev              # Dev server starts, no console errors
pnpm build            # Exits 0, outputs to dist/
pnpm lint             # Exits 0
pnpm typecheck        # Exits 0 (tsc --noEmit)
pnpm test             # Exits 0, ≥1 test passes
```

### Documentation Structure

- [ ] `docs/index.md` with project overview
- [ ] `docs/frontend/index.md`, `docs/frontend/technology.md`, `docs/frontend/project-structure.md`, `docs/frontend/setup-and-deployment.md`
- [ ] `docs/staging/README.md`
- [ ] `docs/specs/.gitkeep` and `docs/archive/.gitkeep`

---

## Known Gotchas


### Vitest + CSS imports return empty strings

`?raw` and `?inline` query suffixes return empty strings in the Vitest test environment. Vitest's CSS plugin processes the file before the `?raw` suffix takes effect, so the import resolves to an empty module. Do NOT test CSS file contents via `import styles from './foo.css?raw'` — you will always get `""`. Use `fs.readFileSync` for static content assertions, or test rendered behavior via Testing Library instead (preferred).

### Coverage contamination from generated files

If using `vite-plugin-pwa`, the `dev-dist/` folder is generated during development and contains workbox service worker files (~3400 lines) at 0% coverage. If not excluded, these drag total coverage below thresholds even when all source files are at 100%. Exclude `dev-dist/**` from coverage, linting, and TypeScript compilation from the very first scaffold commit. See [pwa.md](pwa.md) for the full PWA gotcha list.

### `globals: true` is required in Vitest config

Without `globals: true`, `describe`, `it`, `expect`, and `beforeEach` must be imported in every test file. Set it in `vitest.config.ts` at scaffold time — retrofitting it later requires removing import statements from every test file.

### Use `@testing-library/user-event` not `fireEvent`

`fireEvent` dispatches synthetic DOM events that bypass browser behavior (no focus, no hover, no sequential event ordering). `userEvent` simulates complete browser event sequences (`mousedown → focus → mouseup → click`). Use `userEvent` for all user interaction tests. Import: `import userEvent from '@testing-library/user-event'`.

### Path alias mismatch causes runtime failures

`tsconfig.json` and `vite.config.ts` must declare identical path aliases. TypeScript uses `tsconfig.json` for type-checking; Vite uses its own config for bundling. A mismatch compiles cleanly but fails at runtime with `Module not found` errors. After adding aliases, verify both files are in sync and run `pnpm build` (not just `pnpm dev`) to confirm.

### TypeScript strict options that break clean scaffolds

`noUncheckedIndexedAccess` and `noUnusedLocals`/`noUnusedParameters` will cause errors in freshly scaffolded boilerplate (array index access returns `T | undefined`, unused template variables error). Either handle these during scaffold or enable only after the scaffold passes `tsc --noEmit` cleanly.

### Coverage thresholds during scaffold phase

Do not set global coverage thresholds (e.g., `lines: 80`) during the scaffold phase. Scaffold smoke tests cover infrastructure only, not business logic — enforcing thresholds will always fail until feature implementation begins. Add thresholds as a separate task after the first feature story completes.
