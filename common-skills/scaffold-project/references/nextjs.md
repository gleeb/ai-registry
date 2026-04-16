# Next.js (Fullstack / SSR / SSG)

Use for public-facing SaaS, e-commerce, content-heavy sites, or any app needing SSR, SEO, or API routes.

## Scaffold

```bash
pnpm create next-app@latest <app-name> \
  --ts --tailwind --eslint --app --src-dir --turbopack \
  --import-alias "@/*" --use-pnpm
```

Flags explained:
- `--ts` — TypeScript
- `--tailwind` — Tailwind CSS preconfigured
- `--eslint` — ESLint with Next.js rules
- `--app` — App Router (default, recommended over Pages Router)
- `--src-dir` — code inside `src/` to separate from config files
- `--turbopack` — Turbopack dev server (faster HMR)
- `--import-alias "@/*"` — clean import paths

For an **API-only** project (no frontend):

```bash
pnpm create next-app@latest <api-name> --api --ts --use-pnpm
```

## Post-Scaffold Checklist

1. **Verify `tsconfig.json`** — strict mode and path aliases are set by the scaffolder.
2. **Add Biome** (optional) — replace ESLint + Prettier with Biome for faster linting. See [web-tooling.md](web-tooling.md).
3. **Environment variables** — use `.env.local` for secrets (never committed). Public vars must be prefixed `NEXT_PUBLIC_`.
4. **Add `next.config.ts`** adjustments if needed (image domains, redirects, headers).

## Recommended Folder Structure (App Router)

```
src/
├── app/
│   ├── layout.tsx        # Root layout
│   ├── page.tsx          # Home page
│   ├── globals.css
│   ├── (auth)/           # Route group (no URL segment)
│   │   ├── login/page.tsx
│   │   └── signup/page.tsx
│   ├── dashboard/
│   │   ├── layout.tsx    # Nested layout
│   │   └── page.tsx
│   └── api/
│       └── health/route.ts
├── components/
│   ├── ui/               # Primitive components
│   └── layouts/          # Layout components
├── lib/                  # Server utilities, DB clients, auth
├── hooks/                # Client-side hooks
├── types/                # Shared types
└── utils/                # Pure functions
```

### Key Conventions

- **Server Components by default** — files in `app/` are Server Components unless they use `"use client"`.
- **Route groups** — `(groupName)/` creates logical groups without affecting the URL.
- **Loading & error states** — add `loading.tsx` and `error.tsx` alongside `page.tsx` for built-in Suspense/error boundaries.
- **API routes** — use `route.ts` with exported `GET`, `POST`, etc. functions.

## Key Libraries (2026)

| Purpose | Recommended | Notes |
|---------|-------------|-------|
| ORM | Prisma or Drizzle | Drizzle for type-safe, lightweight; Prisma for rich ecosystem |
| Auth | NextAuth.js v5 (Auth.js) | Or Clerk/Supabase Auth for managed auth |
| Validation | Zod | Server Actions + Zod for form validation |
| Data fetching | Server Components + TanStack Query | SC for server data, TQ for client mutations |
| Styling | Tailwind CSS v4 | Included by scaffolder |
| Testing | Vitest + Playwright | Unit + E2E |

---

## Scaffolding Verification Checklist

Run through every item before marking the scaffold complete.

### Project Structure

- [ ] `src/app/layout.tsx` with root `<html lang>` and `<body>` elements
- [ ] `src/app/page.tsx` home page component (Server Component by default)
- [ ] `src/app/globals.css` with Tailwind import (`@import "tailwindcss"`)
- [ ] `next.config.ts` (TypeScript, not `.js`) exists
- [ ] `tsconfig.json` with `"strict": true` and `"paths": { "@/*": ["./src/*"] }`
- [ ] `.env.local` added to `.gitignore` (never committed)
- [ ] `.env.example` created documenting all required env vars with placeholder values

### Configuration

- [ ] Caching strategy documented per data source (not relying on `fetch()` default `force-cache` silently)
- [ ] `images.remotePatterns` configured in `next.config.ts` if external images will be used
- [ ] `NEXT_PUBLIC_` prefix conventions documented in `docs/frontend/technology.md`
- [ ] TypeScript strict mode: `"strict": true` in `tsconfig.json`
- [ ] Turbopack enabled (`next dev --turbopack` or confirmed default in Next.js 16+)

### Testing Infrastructure

- [ ] Vitest configured with `@vitejs/plugin-react` (or SWC variant)
- [ ] `environment: "jsdom"` and `globals: true` in `vitest.config.ts`
- [ ] Test setup file imports `@testing-library/jest-dom`
- [ ] Coverage excludes: `.next/**`, `node_modules/**`, `next.config.*`, `**/*.d.ts`
- [ ] At least one smoke test passes (`pnpm test` exits 0)

### Verification Scripts

- [ ] `scripts/verify.sh` created — silent on success, prints only the failing gate
- [ ] `package.json` `scripts` includes `"verify:full"` and `"verify:quick"`

The script is the same as [react-vite.md](react-vite.md) with one Next.js difference: `pnpm exec vitest run --coverage` runs Vitest (not `next test`). Build uses `pnpm build` which runs `next build` and catches both TypeScript and lint errors.

```bash
# package.json scripts additions
"verify:full": "bash scripts/verify.sh full",
"verify:quick": "bash scripts/verify.sh quick"
```

Use the `scripts/verify.sh` template from [react-vite.md](react-vite.md) — it is identical for Next.js projects.

### Verification Gate (all must pass before scaffold is done)

```bash
pnpm install          # No errors (always run first)
pnpm dev              # Dev server starts, no console errors (manual check — not in verify script)
npm run verify:full   # Silent: lint + typecheck + test (with coverage) + next build
                      # Exits 0 and prints "=== ALL GATES PASSED ===" on success
                      # Prints the failing gate's output and exits non-zero on failure
```

### Documentation Structure

- [ ] `docs/index.md` with project overview
- [ ] `docs/frontend/index.md`, `docs/frontend/technology.md`, `docs/frontend/project-structure.md`, `docs/frontend/setup-and-deployment.md`
- [ ] `docs/staging/README.md`
- [ ] `docs/specs/.gitkeep` and `docs/archive/.gitkeep`

---

## Known Gotchas


### "use client" overuse disables Server Components

Wrapping entire pages or layouts in `"use client"` disables Server Components, SSR data fetching, automatic caching, and streaming. The App Router's performance benefits disappear. Rule: mark the smallest component that needs browser APIs or React state as client. Default is Server Component. Add `"use client"` only when using `useState`, `useEffect`, browser event listeners, or browser-only APIs.

### `fetch()` is cached by default — stale data in production

In Next.js Server Components, `fetch()` uses `force-cache` by default. Subsequent requests return cached data from Next.js's built-in cache even if the origin has updated. This causes unexpected stale data in production that works fine in development (where caching is often bypassed). Explicitly set caching behavior at scaffold time per data source:
- `fetch(url, { cache: 'no-store' })` — dynamic, always fresh
- `fetch(url, { next: { revalidate: 60 } })` — ISR, revalidate every N seconds
- `fetch(url)` (default `force-cache`) — only for truly static data

Document the caching strategy in `docs/frontend/technology.md`.

### Layouts do not remount between navigations

`layout.tsx` files are rendered once and persist across route changes within their segment. State defined in a layout does NOT reset when the user navigates to a different page within the same layout. Never put per-page ephemeral state (form state, modal open/close, page-specific data) in a layout component. Move state to the page component or use `usePathname()` + `useEffect()` to reset layout state on route change.

### Build-time vs request-time environment variables

`NEXT_PUBLIC_*` variables are inlined at build time into the client bundle. Server-only variables (without `NEXT_PUBLIC_`) are available only at request time in Server Components. Variables accessed outside a request context (in `generateStaticParams`, static export) must exist in the build environment, not just runtime. Undocumented env var timing leads to `undefined` values in production builds. Document each variable's timing in `.env.example`.

### Turbopack dev vs webpack build

`next dev --turbopack` (default in Next.js 16+) uses Turbopack for fast HMR. `next build` still uses webpack. Configuration that works in Turbopack dev may not work during webpack builds (webpack-specific plugins, loaders, or module aliases). Always run `pnpm build` during scaffold verification — not just `pnpm dev`.

### .next/ coverage contamination

The `.next/` directory contains build output including TypeScript-compiled JavaScript files. If not excluded from Vitest/Jest coverage config, these files appear in coverage reports and distort source coverage numbers. Always add `.next/**` to `coverage.exclude` in `vitest.config.ts` from the start.

### `optimizePackageImports` for large UI libraries

If the project uses large icon libraries (Lucide, Heroicons) or component libraries (Radix, shadcn), add them to `optimizePackageImports` in `next.config.ts` to prevent importing the entire library on every page:

```ts
// next.config.ts
experimental: {
  optimizePackageImports: ['lucide-react', '@radix-ui/react-icons'],
}
```

Without this, development HMR becomes slow and bundle size grows unnecessarily. Configure at scaffold time for any library already planned for use.
