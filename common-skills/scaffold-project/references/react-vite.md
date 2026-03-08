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
