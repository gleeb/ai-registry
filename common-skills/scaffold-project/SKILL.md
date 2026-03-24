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
| Public-facing web, SSR, SEO, API routes | **Next.js** | [nextjs.md](references/nextjs.md) |
| Mobile app (iOS/Android), cross-platform | **React Native (Expo)** | [react-native.md](references/react-native.md) |
| API, CLI, data pipeline, ML, scripting | **Python + uv** | [references/python-uv.md](references/python-uv.md) |
| Multiple apps sharing code | **Monorepo** | [monorepo.md](references/monorepo.md) |

If the project combines multiple types (e.g., Next.js frontend + Python API), read [monorepo.md](references/monorepo.md) for the hybrid monorepo pattern.

### 2. Scaffold

Read the appropriate reference file for exact commands and flags. General flow:

1. Run the scaffold command for the chosen technology.
2. Apply the post-scaffold checklist from the reference.
3. Set up shared tooling (TypeScript, linting, styling) — see [web-tooling.md](references/web-tooling.md) for JS/TS projects.
4. Create the recommended folder structure.
5. Initialize git (if not already), create `.gitignore`, make first commit.

### 3. Monorepo Considerations

Default to monorepo structure when any of these are true:
- The user mentions both frontend and backend.
- Multiple apps will share code (types, utils, UI components).
- The project includes a mobile app alongside a web app.

Monorepo stack:
- **JS/TS**: Turborepo + pnpm workspaces. See [monorepo.md](references/monorepo.md).
- **Python**: uv workspaces. See [python-uv.md](references/python-uv.md) and [monorepo.md](references/monorepo.md).
- **Hybrid (JS + Python)**: pnpm workspaces for JS side, uv workspace for Python side, unified with a Makefile. See [monorepo.md](references/monorepo.md).

### 4. Set Up Test Infrastructure

Every project gets a working test setup from day one. Configure per project type:

| Project Type | Test Runner | Setup |
|-------------|-------------|-------|
| React + Vite | Vitest | `pnpm add -D vitest @testing-library/react @testing-library/jest-dom`, add `test` script to `package.json`, create `vitest.config.ts` |
| Next.js | Vitest | `pnpm add -D vitest @testing-library/react @testing-library/jest-dom`, add `test` script, create `vitest.config.ts` |
| React Native (Expo) | Jest (Expo preset) | `pnpm add -D jest @testing-library/react-native`, configure in `package.json` or `jest.config.js` |
| Python | pytest | `uv add --dev pytest`, create `tests/` directory with `conftest.py` |

For all project types:
1. Configure the test runner with the project's path aliases and TypeScript settings.
2. Create a test helper/setup file (e.g., `src/test-setup.ts` for JS/TS, `tests/conftest.py` for Python).
3. Create one example test that actually runs and passes — proves the test runner works:
   - JS/TS: `src/__tests__/setup.test.ts` or `src/example.test.ts` with a basic assertion.
   - Python: `tests/test_setup.py` with a basic assertion.
4. Run the test suite and confirm it passes before proceeding.

### 5. Scaffold Project Documentation

Every project gets a `docs/` directory. Read [project-docs.md](references/project-docs.md) for templates and structure.

1. Create the `docs/` tree matching the project type (frontend-only, backend-only, fullstack, monorepo).
2. Write `docs/index.md` — project overview, component descriptions, links to domain docs.
3. Write domain index files (`docs/frontend/index.md`, `docs/backend/index.md`, etc.) with the tech stack and structure chosen during scaffolding.
4. Create topic file stubs (`technology.md`, `project-structure.md`, `setup-and-deployment.md`, `api.md`, etc.) — fill in everything known from the scaffold.
5. Add a **Testing Conventions** section to the relevant domain doc (e.g., `docs/frontend/technology.md` or `docs/backend/technology.md`) documenting:
   - Test framework and runner (e.g., "Vitest", "pytest")
   - Test file naming convention (e.g., `*.test.ts` colocated, `tests/test_*.py`)
   - Test file location convention (e.g., colocated next to source, `tests/` directory)
   - How to run tests (e.g., `pnpm test`, `uv run pytest`)
   - Test helper/setup file location
6. Create `docs/staging/README.md` with the staging workflow conventions.
7. Create `docs/specs/` and `docs/archive/` with `.gitkeep`.

Fill in as much as you can from what was decided during scaffolding — don't leave placeholders for things already known (tech stack, folder structure, setup commands, testing conventions).

### 6. Post-Setup Verification

After scaffolding, verify the setup works:

```bash
# JS/TS projects
pnpm install && pnpm dev    # Dev server starts without errors
pnpm build                  # Build completes
pnpm lint                   # No lint errors
pnpm test                   # Test suite runs with at least 1 passing test

# Python projects
uv run python -c "print('ok')"  # venv + deps resolve
uv run pytest                    # Test suite runs with at least 1 passing test

# Monorepo
turbo dev                   # All apps start
turbo build                 # All apps build
turbo test                  # All test suites run

# All project types — documentation structure
test -f docs/index.md       # Root index exists
test -f docs/staging/README.md  # Staging workflow exists
```

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
| Documentation | Always scaffold `docs/` — see [project-docs.md](references/project-docs.md) |
