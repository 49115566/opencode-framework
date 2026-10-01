---
name: python
description: "Python conventions and tooling. Use when writing, testing, or reviewing Python: uv/poetry/pip, pytest, ruff, mypy/pyright, pyproject.toml, virtualenvs, type hints."
---

# Python conventions

The repository's configuration is authoritative. Read `pyproject.toml`
(`[tool.ruff]`, `[tool.mypy]`, `[tool.pytest.ini_options]`) and any
`requirements*.txt` before writing. Below are defaults when the repo is silent.

## Match the existing style

- Follow neighboring modules for imports, layout, and naming.
- Use the configured formatter (ruff format, black) rather than hand-formatting.
- Reuse existing helpers and models; search before adding new ones.
- Respect the project's package layout (`src/` layout vs flat).

## Python

- Add type hints to new public functions; keep them honest.
- Prefer standard-library tools and already-installed packages.
- Use `pathlib` over `os.path` for new filesystem code.
- Raise specific exceptions; do not use bare `except:` or swallow errors silently.
- Use context managers for resources (files, connections, locks).
- Avoid mutable default arguments; use `None` + assignment.
- Prefer f-strings; keep logging structured and free of secrets.

## Verification

- Run tests with the project's runner (`uv run pytest`, `pytest`, or a script).
- Run `ruff check` and `ruff format --check` (or the configured linter/formatter).
- Run the configured type checker (`mypy` or `pyright`).

## Common pitfalls

- Editing generated or vendored files.
- Adding a dependency that is already available transitively and pinned.
- Assuming a virtualenv is active — prefer `uv run` or the project's documented
  invocation.
- Catching broad exceptions to make a test pass.
