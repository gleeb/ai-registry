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
