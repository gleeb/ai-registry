# Python + uv

Use `uv` as the single tool for Python version management, virtual environments, dependency management, and script execution. Replaces pyenv, pip, poetry, pipx, and virtualenv.

## Install uv

```bash
# macOS / Linux
curl -LsSf https://astral.sh/uv/install.sh | sh

# Windows
powershell -ExecutionPolicy ByPass -c "irm https://astral.sh/uv/install.ps1 | iex"

# Homebrew
brew install uv
```

## Scaffold

### Application (CLI, web server, script)

```bash
uv init <project-name>
cd <project-name>
```

Creates: `pyproject.toml`, `main.py`, `.python-version`, `.gitignore`, `README.md`.

### Library (pip-installable package)

```bash
uv init --lib <project-name>
cd <project-name>
```

Creates same files plus `src/<project_name>/` package layout with `__init__.py` and `py.typed`.

### Minimal (pyproject.toml only)

```bash
uv init --bare <project-name>
```

## Post-Scaffold Checklist

1. **Pin Python version** — edit `.python-version` or use `uv python pin 3.12`.
2. **Add dependencies**:

```bash
uv add fastapi uvicorn          # Runtime dependencies
uv add --dev pytest ruff mypy   # Dev dependencies
```

3. **Lock** — `uv.lock` is auto-generated on first `uv add` or `uv run`. Commit it.
4. **Configure `pyproject.toml`**:

```toml
[project]
name = "my-project"
version = "0.1.0"
requires-python = ">=3.12"
dependencies = ["fastapi", "uvicorn"]

[dependency-groups]
dev = ["pytest", "ruff", "mypy"]

[tool.ruff]
line-length = 100
target-version = "py312"

[tool.ruff.lint]
select = ["E", "F", "I", "UP", "B", "SIM"]

[tool.mypy]
strict = true
python_version = "3.12"
```

5. **Run commands** — always use `uv run` (auto-creates/activates venv):

```bash
uv run python main.py
uv run pytest
uv run ruff check .
uv run mypy .
```

## Recommended Folder Structure

### Application

```
my-project/
├── pyproject.toml
├── uv.lock
├── .python-version
├── .gitignore
├── README.md
├── src/
│   └── my_project/
│       ├── __init__.py
│       ├── main.py
│       ├── config.py
│       ├── api/
│       │   ├── __init__.py
│       │   └── routes.py
│       ├── models/
│       ├── services/
│       └── utils/
└── tests/
    ├── __init__.py
    ├── conftest.py
    └── test_main.py
```

### FastAPI Specifically

```bash
uv init my-api
cd my-api
uv add fastapi uvicorn[standard]
uv add --dev pytest httpx ruff mypy
```

Entry point: `uv run uvicorn src.my_api.main:app --reload`

## Key Tools (2026)

| Purpose | Recommended | Notes |
|---------|-------------|-------|
| Linting | Ruff | Replaces flake8, isort, pyupgrade — 10-100x faster |
| Type checking | mypy (strict) | Or pyright for VS Code integration |
| Testing | pytest | With pytest-asyncio for async code |
| Web framework | FastAPI | Or Django for full batteries |
| HTTP client | httpx | Async-capable, modern API |
| Env vars | python-dotenv or pydantic-settings | pydantic-settings for typed config |

## uv Workspaces (Monorepo)

For Python monorepos with multiple packages, see [monorepo.md](monorepo.md) (Python workspace section).

```toml
# Root pyproject.toml
[tool.uv.workspace]
members = ["packages/*"]
```

Each member has its own `pyproject.toml` and can depend on siblings via:

```toml
[tool.uv.sources]
shared-lib = { workspace = true }
```

---

## Scaffolding Verification Checklist

Run through every item before marking the scaffold complete.

### Project Structure

- [ ] `pyproject.toml` with `[project]`, `requires-python = ">=3.12"`, `[dependency-groups]` dev section
- [ ] `.python-version` pinned to `3.12` or `3.13`
- [ ] `src/<project_name>/` package layout (NOT flat `<project_name>/` at root)
- [ ] `src/<project_name>/__init__.py` exists
- [ ] `tests/__init__.py` and `tests/conftest.py` exist
- [ ] `tests/test_setup.py` with at least one passing smoke test
- [ ] `uv.lock` committed to version control

### Tool Configuration (all in `pyproject.toml`)

- [ ] Ruff lint rules: `select = ["E", "F", "I", "UP", "B", "SIM"]` minimum
- [ ] Ruff: `line-length = 100`, `target-version = "py312"`
- [ ] mypy: `[tool.mypy]` section with `strict = true`, `python_version = "3.12"`
- [ ] mypy overrides for untyped third-party libs: `[[tool.mypy.overrides]] module = "untyped_lib.*" ignore_missing_imports = true`
- [ ] pytest: `[tool.pytest.ini_options]` with `testpaths = ["tests"]`
- [ ] Coverage config: `[tool.coverage.report]` with `omit = ["*/tests/*", "*/conftest.py", "*/__init__.py"]`

### For FastAPI Projects (additional)

- [ ] `uvloop` and `httptools` installed (`uv add uvloop httptools`)
- [ ] `pydantic-settings` installed for typed environment configuration
- [ ] `httpx` installed (not `requests`) — async-capable, used as test client for FastAPI
- [ ] `pytest-asyncio` installed and `asyncio_mode = "auto"` in `[tool.pytest.ini_options]`
- [ ] `ORJSONResponse` used as default response class (not default JSONResponse)

### Verification Scripts

- [ ] `scripts/verify.sh` created (see template below) — silent on success, prints only the failing gate
- [ ] `Makefile` at project root with `verify-full` and `verify-quick` targets (Python has no `package.json`)

```makefile
# Makefile
.PHONY: verify-full verify-quick

verify-full:
	bash scripts/verify.sh full

verify-quick:
	bash scripts/verify.sh quick
```

```bash
#!/usr/bin/env bash
# scripts/verify.sh — silent verification for Python (uv + ruff + mypy + pytest)
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

run_gate "LINT"       uv run ruff check .
run_gate "TYPECHECK"  uv run mypy src/

if [ "$TIER" = "full" ]; then
  run_gate "TEST" uv run pytest --cov=src --cov-report=term-missing
else
  run_gate "TEST" uv run pytest
fi

echo "=== ALL GATES PASSED ==="
```

Make it executable: `chmod +x scripts/verify.sh`

Coverage thresholds (if configured in `pyproject.toml` under `[tool.coverage.report] fail_under`) are automatically enforced by `pytest-cov` — no custom threshold parsing needed in the script.

### Verification Gate (all must pass before scaffold is done)

```bash
uv sync                                                      # Resolves and installs all deps (run first)
uv run python -c "import <project_name>; print('ok')"        # Package imports cleanly (manual check)
bash scripts/verify.sh full                                  # Silent: ruff + mypy + pytest (with coverage)
                                                             # Exits 0 and prints "=== ALL GATES PASSED ===" on success
```

### Documentation Structure

- [ ] `docs/backend/index.md`, `docs/backend/technology.md`, `docs/backend/project-structure.md`
- [ ] `docs/backend/api.md` (if FastAPI — stub is fine at scaffold time)
- [ ] `docs/staging/README.md`
- [ ] `docs/specs/.gitkeep` and `docs/archive/.gitkeep`

---

## Known Gotchas


### Flat layout vs src layout — use src layout

`uv init` without flags creates a flat layout (`<project_name>/` at root). The `src/` layout (`src/<project_name>/`) is strongly recommended: it prevents the project root from being accidentally on `sys.path` and makes the package behave identically when installed vs when run from the source directory. Use `uv init --lib` for src layout, or manually create `src/<project_name>/` and update `pyproject.toml` with `[tool.setuptools.packages.find] where = ["src"]`.

### mypy strict mode breaks on untyped third-party libraries

`strict = true` enables `no_implicit_reexport`, `disallow_untyped_defs`, and strict attribute checking. Third-party libraries without bundled type stubs will cause mypy errors (`Cannot find implementation or library stub`). Fix per-library with overrides:

```toml
[[tool.mypy.overrides]]
module = "untyped_lib.*"
ignore_missing_imports = true
```

Add overrides for all untyped dependencies at scaffold time rather than discovering them during feature work.

### Blocking the async event loop in FastAPI

FastAPI routes declared as `async def` must not call synchronous blocking I/O — file reads, database calls via synchronous ORMs (SQLAlchemy sync), or `requests.get()`. A blocking call inside an async route blocks ALL requests to the entire Uvicorn worker process (not just that request). Use async-native libraries (`httpx`, `asyncpg`, `motor`) or wrap blocking calls in `asyncio.to_thread()`.

### uvloop + httptools — performance-critical, install at scaffold time

`uvloop` replaces Python's default asyncio event loop with a C-based implementation (2-4x throughput improvement at high concurrency). `httptools` provides 40% faster HTTP parsing. Uvicorn auto-detects both if installed. These are production performance dependencies — adding them later requires deployment changes. Install at scaffold time:

```bash
uv add uvloop httptools
```


### Coverage must be scoped to src/, not the whole project

Without explicit coverage scoping, `pytest-cov` includes test files, conftest, and `__init__.py` files in coverage reports. These files are trivially at ~100% coverage and inflate the overall percentage misleadingly. Always run with `--cov=src` and configure `omit` in `pyproject.toml`:

```toml
[tool.coverage.report]
omit = ["*/tests/*", "*/conftest.py", "*/__init__.py"]
```


### uv.lock must be committed

`uv.lock` is the lockfile for reproducible installs. If not committed, CI and production environments may install different package versions than development, causing environment-specific failures that are hard to reproduce. Commit `uv.lock` on the first `uv add` or `uv sync`.

### pydantic-settings for typed environment config

Raw `os.environ.get()` calls throughout the codebase are untyped, untestable, and easy to misspell. `pydantic-settings` provides a typed `BaseSettings` class that reads env vars, validates types, and raises clear errors on missing required config:

```python
from pydantic_settings import BaseSettings

class Settings(BaseSettings):
    database_url: str
    debug: bool = False
    api_key: str

settings = Settings()  # Raises on missing required vars at startup
```

Configure at scaffold time.
