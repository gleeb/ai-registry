---
name: scaffold-project
description: >
  Bootstrap new software projects from scratch with modern tooling, documentation, and best practices.
  Use when a user asks to: (1) start a new project, (2) scaffold or initialize a codebase,
  (3) set up a React, Next.js, React Native, or Python project, (4) create a monorepo,
  (5) bootstrap a frontend, backend, mobile app, or fullstack application,
  (6) set up project documentation structure, or
  (7) any variation of "create a new app/project/repo."
---

# Scaffold Project

Set up new projects with current (2026) tooling, folder structure, and best practices.

## Workflow

### 1. Determine Project Type

Ask the user or infer from context:

| Signal | Project Type | Reference |
|--------|-------------|-----------|
| SPA, dashboard, internal tool, no SEO | **React + Vite** | [react-vite.md](references/react-vite.md) |
| React + Vite with offline/installable | **React + Vite + PWA** | [react-vite.md](references/react-vite.md) + [pwa.md](references/pwa.md) |
| Public-facing web, SSR, SEO, API routes | **Next.js** | [nextjs.md](references/nextjs.md) |
| Mobile app (iOS/Android), cross-platform | **React Native (Expo)** | [react-native.md](references/react-native.md) |
| API, CLI, data pipeline, ML, scripting | **Python + uv** | [references/python-uv.md](references/python-uv.md) |
| Multiple apps sharing code | **Monorepo** | [monorepo.md](references/monorepo.md) |

If the project combines multiple types (e.g., Next.js frontend + Python API), read [monorepo.md](references/monorepo.md) for the hybrid monorepo pattern.

### 2. Read the Gotchas First

Before writing any code, read the **Known Gotchas** section of the appropriate reference file. These are real failures observed in prior scaffolding runs — they save remediation cycles:

- React + Vite: Vitest CSS import behavior, coverage contamination, path alias mismatch
- PWA: dev-dist coverage contamination, Chrome icon requirements, MSW conflict
- Next.js: "use client" overuse, fetch caching defaults, layout state persistence
- React Native: cloud-sync directory issue, asset path mismatch, Reanimated plugin order
- Python: flat vs src layout, mypy strict mode with untyped libs, async blocking
- Monorepo: missing `outputs` in turbo.json, TURBO_TOKEN vs Vercel PAT confusion

### 3. Scaffold

Read the appropriate reference file for exact commands and flags. General flow:

1. Run the scaffold command for the chosen technology.
2. Apply the post-scaffold checklist from the reference **including all gotcha mitigations**.
3. Set up shared tooling (TypeScript, linting, styling) — see [web-tooling.md](references/web-tooling.md) for JS/TS projects.
4. Create the recommended folder structure.
5. Initialize git (if not already), create `.gitignore`, make first commit.

### 4. Monorepo Considerations

Default to monorepo structure when any of these are true:
- The user mentions both frontend and backend.
- Multiple apps will share code (types, utils, UI components).
- The project includes a mobile app alongside a web app.

Monorepo stack:
- **JS/TS**: Turborepo + pnpm workspaces. See [monorepo.md](references/monorepo.md).
- **Python**: uv workspaces. See [python-uv.md](references/python-uv.md) and [monorepo.md](references/monorepo.md).
- **Hybrid (JS + Python)**: pnpm workspaces for JS side, uv workspace for Python side, unified with a Makefile. See [monorepo.md](references/monorepo.md).

### 5. Set Up Test Infrastructure

Every project gets a working test setup from day one. Configure per project type:

| Project Type | Test Runner | Setup |
|-------------|-------------|-------|
| React + Vite | Vitest | `pnpm add -D vitest @testing-library/react @testing-library/user-event @testing-library/jest-dom jsdom`, create `vitest.config.ts` with `environment: "jsdom"`, `globals: true`, `setupFiles` |
| Next.js | Vitest | Same as React + Vite |
| React Native (Expo) | Jest (Expo preset) | `pnpm add -D jest jest-expo @testing-library/react-native`, configure in `package.json` |
| Python | pytest | `uv add --dev pytest pytest-cov`, create `tests/` with `conftest.py`, configure `[tool.pytest.ini_options]` |

For all project types:
1. Configure the test runner with the project's path aliases and TypeScript settings.
2. Create a test helper/setup file (`src/test-setup.ts` for JS/TS, `tests/conftest.py` for Python).
3. Create one smoke test that proves the runner works (basic import assertion or render test).
4. Configure coverage **scoped to source files only** — see the stack's Scaffolding Verification Checklist for correct include/exclude patterns.
5. Run the test suite and confirm it passes before proceeding.

### 6. Scaffold Project Documentation

Every project gets a `docs/` directory. Read [project-docs.md](references/project-docs.md) for templates and structure.

1. Create the `docs/` tree matching the project type (frontend-only, backend-only, fullstack, monorepo).
2. Write `docs/index.md` — project overview, component descriptions, links to domain docs.
3. Write domain index files (`docs/frontend/index.md`, `docs/backend/index.md`, etc.) with the tech stack and structure chosen during scaffolding.
4. Create topic file stubs (`technology.md`, `project-structure.md`, `setup-and-deployment.md`, `api.md`, etc.) — fill in everything known from the scaffold.
5. Add a **Testing Conventions** section to the relevant domain doc documenting:
   - Test framework and runner
   - Test file naming convention
   - How to run tests and coverage
   - Known gotchas for this stack's test setup
6. Create `docs/staging/README.md` with the staging workflow conventions.
7. Create `docs/specs/` and `docs/archive/` with `.gitkeep`.

Fill in as much as you can from what was decided during scaffolding — don't leave placeholders for things already known.

### 7. Scaffolding Verification Checklist

After scaffolding, run the full **Scaffolding Verification Checklist** from the stack's reference file. This is mandatory — do not mark the scaffold complete until every item passes.

```bash
# JS/TS projects — run in this order
pnpm install          # No errors
pnpm build            # Exits 0
pnpm lint             # Exits 0
pnpm typecheck        # Exits 0
pnpm test             # Exits 0, ≥1 test passes

# Python projects
uv sync               # Resolves all deps
uv run ruff check .   # Exits 0
uv run mypy src/      # Exits 0
uv run pytest         # Exits 0, ≥1 test passes

# Monorepo
turbo build           # All packages build
turbo lint            # Exits 0
turbo test            # Exits 0

# All project types — documentation structure
test -f docs/index.md            # Root index exists
test -f docs/staging/README.md   # Staging workflow exists
```

If any step fails, fix it before proceeding to feature work. A scaffold that doesn't pass its verification gate is not done.

## Defaults & Opinions

When the user doesn't specify, use these defaults:

| Decision | Default |
|----------|---------|
| Language | TypeScript (strict) for JS ecosystem, Python 3.12+ for Python |
| Package manager | pnpm (JS/TS), uv (Python) |
| Linting | Biome for JS/TS, Ruff for Python |
| Styling | Tailwind CSS v4 |
| Monorepo tool | Turborepo + pnpm workspaces |
| React framework | Next.js (if SSR/SEO matters), Vite (otherwise) |
| Mobile | Expo (managed workflow) |
| Testing | Vitest (JS/TS), pytest (Python) |
| Coverage scope | Source files only (`src/**`) — never global without exclusions |
| Documentation | Always scaffold `docs/` — see [project-docs.md](references/project-docs.md) |
| PWA additions | See [pwa.md](references/pwa.md) for install checklist + gotchas |
