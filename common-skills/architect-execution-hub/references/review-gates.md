# Review Gates

Pre-review quality gates that must pass before dispatching to code reviewer.

## Test Existence Gate

Before dispatching to code reviewer, the architect verifies that the implementer created test files for new/modified source modules:

**Detection patterns** (check via bash — adapt globs to project conventions):
- `**/__tests__/**/*.{test,spec}.{ts,tsx,js,jsx}`
- `**/*.{test,spec}.{ts,tsx,js,jsx}`
- `**/test_*.py`, `**/*_test.py`, `**/tests/**/*.py`

**Module-to-test mapping**: Every new or significantly modified source file under `src/` (or project source root) must have a corresponding test file. The mapping uses naming conventions: `Foo.ts` → `Foo.test.ts` or `__tests__/Foo.test.ts`.

**Exemptions** (no test file required):
- Documentation-only changes (`*.md`, `docs/**`)
- Configuration files (`*.config.*`, `*.json`, `*.yaml`, `*.yml` at project root)
- Type declaration files (`*.d.ts`)
- Test utility files (`test-utils.*`, `__mocks__/**`, `*.fixture.*`)
- Generated code (if project has a generation convention)

**On failure**: Re-dispatch implementer with test-only focus (counts as an iteration). Do NOT send to reviewer without tests.

## Coverage Gate

After the Test Existence Gate passes and before dispatching to the code reviewer, run a coverage check on the implementer's work:

1. **Run coverage**: Execute the project's test suite with coverage reporting:
   - Default: `npx jest --coverage --coverageReporters=json-summary`
   - Stack-specific alternatives: `pytest --cov --cov-report=json`, `go test -cover`, etc.
2. **Parse results**: Read the coverage summary (e.g., `coverage/coverage-summary.json`) for line, branch, and function percentages.
3. **Apply thresholds**: Compare new/modified file coverage against thresholds from `plan/cross-cutting/testing-strategy.md`. If no testing strategy exists, use defaults: 80% lines, 70% branches for new/modified files.
4. **On failure**: Re-dispatch to implementer with coverage report and specific uncovered lines/branches. Include the coverage summary in the re-dispatch message. This counts as an iteration.
5. **On success**: Include the coverage summary in the reviewer dispatch for reference.

**Note**: The Coverage Gate runs the test suite to collect metrics — this is separate from the QA agent's independent execution later in the pipeline.
