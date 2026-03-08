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
