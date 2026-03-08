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
