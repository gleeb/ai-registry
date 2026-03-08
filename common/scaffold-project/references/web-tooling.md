# Web Tooling (Shared Across JS/TS Projects)

Common tooling decisions for any JavaScript/TypeScript project. Apply these after scaffolding.

## Package Manager: pnpm

pnpm is the recommended package manager for all JS/TS projects (2026).

```bash
# Install pnpm (if not present)
corepack enable && corepack prepare pnpm@latest --activate

# Or standalone
npm install -g pnpm
```

Why pnpm:
- Content-addressable storage (saves disk, prevents phantom dependencies)
- Native workspace support for monorepos
- Faster installs than npm/yarn
- Strict by default — catches missing dependency declarations

## TypeScript

Always use TypeScript with strict mode. Base config for reuse:

```jsonc
// tsconfig.base.json (shared in monorepo) or tsconfig.json (single project)
{
  "compilerOptions": {
    "strict": true,
    "target": "ES2022",
    "module": "ESNext",
    "moduleResolution": "bundler",
    "esModuleInterop": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true,
    "resolveJsonModule": true,
    "isolatedModules": true,
    "noUncheckedIndexedAccess": true,
    "noUnusedLocals": true,
    "noUnusedParameters": true
  }
}
```

## Linting & Formatting: Biome (Recommended) or ESLint + Prettier

### Option A: Biome (faster, simpler — recommended for new projects)

```bash
pnpm add -Dw @biomejs/biome
pnpm biome init
```

```jsonc
// biome.json
{
  "$schema": "https://biomejs.dev/schemas/2.0/schema.json",
  "linter": {
    "enabled": true,
    "rules": { "recommended": true }
  },
  "formatter": {
    "enabled": true,
    "indentStyle": "space",
    "indentWidth": 2,
    "lineWidth": 100
  },
  "javascript": {
    "formatter": { "semicolons": "always", "quoteStyle": "double" }
  }
}
```

Commands:

```bash
pnpm biome check .           # Lint + format check
pnpm biome check --write .   # Lint + format fix
```

### Option B: ESLint + Prettier (when Biome doesn't cover your needs)

Use when you need framework-specific plugins (e.g., eslint-plugin-react-compiler) or security rules not yet in Biome.

```bash
pnpm add -Dw eslint prettier eslint-config-prettier
```

## Styling: Tailwind CSS v4

Tailwind v4 is CSS-first (no `tailwind.config.js` by default).

```bash
pnpm add tailwindcss @tailwindcss/vite    # For Vite projects
# or
pnpm add tailwindcss                       # Next.js includes Vite plugin
```

```css
/* globals.css */
@import "tailwindcss";
```

Customization is done in CSS with `@theme`:

```css
@theme {
  --color-primary: #3b82f6;
  --font-display: "Inter", sans-serif;
}
```

## Git Hooks: Husky + lint-staged (Optional)

Enforce linting on commit:

```bash
pnpm add -Dw husky lint-staged
pnpm husky init
```

```json
// package.json
{
  "lint-staged": {
    "*.{ts,tsx,js,jsx,json,css,md}": "biome check --write"
  }
}
```

## Testing

| Layer | Tool | Notes |
|-------|------|-------|
| Unit / Integration | Vitest | Native Vite integration, fast, compatible with Jest API |
| E2E (web) | Playwright | Cross-browser, best DX |
| E2E (mobile) | Detox or Maestro | Maestro for simpler flows |
| Visual | Chromatic / Percy | Storybook-based visual regression |

Setup Vitest:

```bash
pnpm add -Dw vitest @testing-library/react @testing-library/jest-dom jsdom
```

```ts
// vitest.config.ts (or inside vite.config.ts)
import { defineConfig } from "vitest/config";
export default defineConfig({
  test: { environment: "jsdom", globals: true },
});
```

## Environment Variables

- `.env` — default values (committed, no secrets)
- `.env.local` — local overrides (gitignored)
- `.env.production` — production values (gitignored or in CI)
- Validate with `@t3-oss/env-nextjs` (Next.js) or `zod` schema at app startup.

## CI Essentials

Minimum CI pipeline for any JS/TS project:

```yaml
# .github/workflows/ci.yml (simplified)
steps:
  - uses: actions/checkout@v4
  - uses: pnpm/action-setup@v4
  - uses: actions/setup-node@v4
    with: { node-version: 22, cache: pnpm }
  - run: pnpm install --frozen-lockfile
  - run: pnpm biome check .
  - run: pnpm tsc --noEmit
  - run: pnpm test
```
