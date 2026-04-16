# Monorepo Setup

Most real projects are monorepos containing frontend, backend, and shared packages. This guide covers the two main ecosystems: JavaScript/TypeScript (Turborepo + pnpm) and Python (uv workspaces).

## JavaScript/TypeScript Monorepo

### Stack: Turborepo + pnpm Workspaces

Turborepo handles task orchestration (build order, caching). pnpm handles dependency resolution and workspace linking.

### Scaffold

```bash
pnpm dlx create-turbo@latest <repo-name> --package-manager pnpm
cd <repo-name>
```

This generates a working monorepo with example apps and packages.

### Alternatively — Manual Setup

If adding Turborepo to an existing repo or need full control:

1. **Initialize pnpm workspace**:

```yaml
# pnpm-workspace.yaml
packages:
  - "apps/*"
  - "packages/*"
```

2. **Add Turborepo**:

```bash
pnpm add -Dw turbo
```

3. **Configure `turbo.json`**:

```json
{
  "$schema": "https://turbo.build/schema.json",
  "tasks": {
    "build": {
      "dependsOn": ["^build"],
      "outputs": [".next/**", "dist/**"]
    },
    "dev": {
      "cache": false,
      "persistent": true
    },
    "lint": {},
    "test": {}
  }
}
```

### Recommended Structure

```
my-monorepo/
├── apps/
│   ├── web/                # Next.js frontend
│   │   └── package.json
│   ├── mobile/             # React Native / Expo
│   │   └── package.json
│   └── api/                # Node.js backend (Express/Fastify/Hono)
│       └── package.json
├── packages/
│   ├── ui/                 # Shared component library
│   │   └── package.json
│   ├── config-ts/          # Shared tsconfig bases
│   │   └── tsconfig.base.json
│   ├── config-biome/       # Shared Biome config
│   │   └── biome.json
│   └── shared/             # Shared types, utils, constants
│       └── package.json
├── turbo.json
├── pnpm-workspace.yaml
├── package.json            # Root — dev deps only (turbo, etc.)
├── biome.json              # Root Biome config (extends packages/config-biome)
└── tsconfig.json           # Root TS config (extends packages/config-ts)
```

### Cross-Package Dependencies

Reference local packages in any app's `package.json`:

```json
{
  "dependencies": {
    "@repo/ui": "workspace:*",
    "@repo/shared": "workspace:*"
  }
}
```

Use a consistent scope prefix (e.g., `@repo/` or `@myorg/`) for all internal packages.

### Common Commands

```bash
turbo build              # Build all packages in dependency order
turbo dev                # Start all dev servers in parallel
turbo lint               # Lint all packages
turbo build --filter=web # Build only the 'web' app and its deps
```

### Adding a New App

1. Create `apps/<app-name>/` with its own `package.json`.
2. Add dependencies including any `@repo/*` packages.
3. Add `build`, `dev`, `lint` scripts to its `package.json`.
4. Run `pnpm install` from root.
5. Turborepo auto-discovers it — no config changes needed.

### Adding a New Package

1. Create `packages/<pkg-name>/` with `package.json` (`"name": "@repo/<pkg-name>"`).
2. Add `"main"` and `"types"` entry points.
3. Any app/package that needs it adds `"@repo/<pkg-name>": "workspace:*"` to dependencies.
4. Run `pnpm install` from root.

---

## Python Monorepo (uv Workspaces)

### Scaffold

```bash
uv init my-monorepo
cd my-monorepo
mkdir -p packages
```

### Configure Workspace

```toml
# Root pyproject.toml
[project]
name = "my-monorepo"
version = "0.1.0"
requires-python = ">=3.12"
dependencies = []

[tool.uv.workspace]
members = ["packages/*", "apps/*"]
```

### Add Members

```bash
uv init --lib packages/shared-models
uv init apps/api
cd apps/api && uv add shared-models
```

In `apps/api/pyproject.toml`:

```toml
[tool.uv.sources]
shared-models = { workspace = true }
```

### Structure

```
my-monorepo/
├── apps/
│   ├── api/
│   │   ├── pyproject.toml
│   │   └── src/api/
│   └── worker/
│       ├── pyproject.toml
│       └── src/worker/
├── packages/
│   └── shared-models/
│       ├── pyproject.toml
│       └── src/shared_models/
├── pyproject.toml          # Root workspace config
├── uv.lock                 # Single lockfile for entire workspace
└── .python-version
```

---

## JavaScript/TypeScript Monorepo Scaffolding Verification Checklist

Run through every item before marking the scaffold complete.

### Root Configuration

- [ ] `pnpm-workspace.yaml` declares `apps/*` and `packages/*`
- [ ] `turbo.json` with `tasks` covering `build`, `dev`, `lint`, `test`, `typecheck`
- [ ] Every task in `turbo.json` has `outputs` configured — even if `[]` for tasks with no file output
- [ ] `next.js` tasks in `turbo.json` include `"!.next/cache/**"` in outputs to prevent artifact bloat
- [ ] Root `package.json` has `devDependencies` ONLY (turbo, biome/ESLint, lint-staged, etc.) — no production deps
- [ ] `tsconfig.json` at root extending `packages/config-ts/tsconfig.base.json`
- [ ] Consistent package scope prefix chosen and used: `@repo/` or `@<org>/`

### Per-App Verification (repeat for each app in `apps/`)

- [ ] Own `package.json` with `build`, `dev`, `lint`, `test`, `typecheck` scripts
- [ ] Internal packages referenced via `"@repo/package-name": "workspace:*"` (NOT version numbers or paths)
- [ ] Own `tsconfig.json` extending root base config

### Shared Packages

- [ ] `packages/config-ts/` with `tsconfig.base.json`
- [ ] `packages/config-biome/` (or `packages/config-eslint/`) with shared linting config
- [ ] Separate `packages/types/` or `packages/shared/` for cross-package type sharing (prevents circular deps)

### Remote Cache Documentation

- [ ] `TURBO_TOKEN` documented in `.env.example` (note: must be Turborepo-specific token, NOT Vercel PAT)
- [ ] `TURBO_TEAM` documented in `.env.example` (Vercel team slug)
- [ ] CI config includes `TURBO_TOKEN` and `TURBO_TEAM` setup instructions

### Verification Scripts

- [ ] `scripts/verify.sh` created at monorepo root (see template below) — silent on success, prints only the failing gate
- [ ] Root `package.json` `scripts` includes `"verify:full"` and `"verify:quick"`

```bash
# Root package.json scripts additions
"verify:full": "bash scripts/verify.sh full",
"verify:quick": "bash scripts/verify.sh quick"
```

```bash
#!/usr/bin/env bash
# scripts/verify.sh — silent verification for JS/TS monorepo (Turborepo + pnpm)
set -euo pipefail

TIER="${1:-full}"

run_gate() {
  local name="$1"; shift
  local output
  if output=$("$@" 2>&1); then
    return 0
  else
    echo "=== ${name} FAILED ==="
    echo "$output"
    exit 1
  fi
}

run_gate "LINT"       pnpm turbo lint
run_gate "TYPECHECK"  pnpm turbo typecheck
run_gate "TEST"       pnpm turbo test

if [ "$TIER" = "full" ]; then
  run_gate "BUILD" pnpm turbo build
fi

echo "=== ALL GATES PASSED ==="
```

Make it executable: `chmod +x scripts/verify.sh`

Note: Turbo suppresses individual task output on cache hit. The gate-level capture still works — if any task fails, Turbo exits non-zero and the failure output is printed.

### Verification Gate (all must pass before scaffold is done)

```bash
pnpm install          # No errors from root (run first)
npm run verify:full   # Silent: turbo lint + typecheck + test + build across all packages
                      # Exits 0 and prints "=== ALL GATES PASSED ===" on success
                      # Prints the failing task output and exits non-zero on failure
```

### Documentation Structure

- [ ] `docs/index.md` with monorepo structure overview and app/package descriptions
- [ ] Per-app domain docs (`docs/web/`, `docs/api/`, `docs/mobile/`, etc.)
- [ ] `docs/staging/README.md`
- [ ] `docs/specs/.gitkeep` and `docs/archive/.gitkeep`

---

## JavaScript/TypeScript Monorepo Known Gotchas


### Missing `outputs` in turbo.json — #1 cause of cache never hitting

Every task in `turbo.json` MUST declare `outputs`. Without it, Turborepo cannot cache the task results and every run is a cache MISS regardless of whether inputs changed. For build tasks, declare the output directory. For lint/test tasks with no file outputs, use `"outputs": []`.

```json
{
  "tasks": {
    "build": { "dependsOn": ["^build"], "outputs": [".next/**", "!.next/cache/**", "dist/**"] },
    "lint": { "outputs": [] },
    "test": { "outputs": [] },
    "typecheck": { "outputs": [] }
  }
}
```


### TURBO_TOKEN is NOT a Vercel Personal Access Token

`TURBO_TOKEN` for remote caching must be generated via `turbo login` (Turborepo-specific). Using a Vercel Personal Access Token causes silent cache MISS on every CI run — no error message, just endless misses. Also required: `TURBO_TEAM` set to your Vercel team slug. Missing `TURBO_TEAM` causes silent failure even with a valid token.

### Circular package dependencies break build order

If `packages/ui` imports from `packages/shared` AND `packages/shared` imports from `packages/ui`, Turborepo's dependency graph resolution fails. Solution: create a dedicated `packages/types` for cross-package type sharing. Both `ui` and `shared` import from `types`. Types package has zero internal dependencies. Never use bidirectional imports between packages.

### `workspace:*` protocol is mandatory for internal packages

Internal packages MUST be referenced as `"@repo/package-name": "workspace:*"` in `package.json`. Using a version number (e.g., `"@repo/ui": "^1.0.0"`) causes pnpm to look in the npm registry and fail. The `workspace:` protocol tells pnpm to link the local package directory.

### Root package.json pollution hides missing dependency declarations

Installing production dependencies at the root (`pnpm add X` from root) instead of in the specific app (`pnpm add X --filter=web`) makes them available to all packages via hoisting. This masks missing `package.json` declarations — the app works in monorepo but fails when the package is installed standalone or in a different environment. Always use `--filter=<package>` for app-specific dependencies. Root should contain only tooling (turbo, biome, lint-staged, husky).

### pnpm strict hoisting catches phantom dependencies

pnpm's default strict mode prevents importing packages not declared in your own `package.json`. If a package was previously working due to hoisting (importing a dependency of a sibling package), strict mode will break it. This is correct behavior — add the missing dependency to that package's own `package.json`. Do not disable strict mode to silence the error.

---

## Hybrid Monorepo (JS + Python)

For projects with both a JS frontend and Python backend:

```
my-project/
├── apps/
│   ├── web/                # Next.js (managed by pnpm/turbo)
│   └── api/                # Python FastAPI (managed by uv)
│       ├── pyproject.toml
│       └── src/
├── packages/               # Shared JS packages
│   └── ui/
├── turbo.json              # JS task orchestration
├── pnpm-workspace.yaml     # JS workspace (apps/web, packages/*)
├── pyproject.toml           # Python workspace root (apps/api)
├── package.json            # Root JS package
└── Makefile                # Unified commands across both ecosystems
```

A `Makefile` or `justfile` at root can unify commands:

```makefile
dev:
	@make -j2 dev-web dev-api

dev-web:
	cd apps/web && pnpm dev

dev-api:
	cd apps/api && uv run uvicorn src.api.main:app --reload

test:
	turbo test
	cd apps/api && uv run pytest
```
