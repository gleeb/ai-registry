# Scaffolding Dispatch (Task 0)

When the architect detects a greenfield project (no package manager config, no source directories, no docs/ tree):

1. Create **Task 0: Scaffold Project** in the staging document before any implementation units.
2. Dispatch `sdlc-implementer` with:
   - Reference to the `scaffold-project` skill (located in the skills directory).
   - Initiative and user story context so the implementer can determine project type and make technology decisions.
   - Acceptance criteria:
     - Project builds and lints successfully.
     - `docs/` structure exists per the scaffold-project skill's Step 4 ("Scaffold Project Documentation"): `docs/index.md`, domain folders matching project type (e.g., `docs/mobile/` for React Native, `docs/frontend/` for web), `docs/staging/README.md`, `docs/specs/.gitkeep`, `docs/archive/.gitkeep`.
3. Run the standard review + QA cycle on the scaffold output.
4. **GATE**: Verify `docs/index.md` exists before proceeding to Phase 1. If missing, re-dispatch implementer to complete documentation scaffolding.
5. **COVERAGE REPORTER GATE (JS/TS only)**: Verify `vitest.config.ts` includes `json-summary` in `coverage.reporter` and that `scripts/verify.sh` emits `COVERAGE: <path> L=N% B=N% F=N%` lines after the test gate. If missing, re-dispatch scaffolder to add them. This prevents downstream implementers from reading raw coverage artifacts.
6. After scaffold is complete and gate passes, proceed with normal architecture planning (Phase 1) against the scaffolded codebase.
