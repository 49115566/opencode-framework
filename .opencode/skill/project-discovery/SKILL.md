---
name: project-discovery
description: Use when you need a project's exact install, test, lint, typecheck, format, or build commands, or when the language, package manager, or test runner is unknown. Triggers on "what command", "how do I run the tests", package.json, pyproject.toml, Cargo.toml, go.mod, Makefile, lockfiles, CI workflow files.
---

# Project discovery

Never guess a project's commands. Read its configuration and report the real
ones. Guessed commands produce false "PASS" claims and wasted cycles.

## What to inspect, in order

1. **Task runner first.** A `Makefile`, `justfile`, `Taskfile.yml`, or
   `package.json` `scripts` block usually names the canonical commands. Prefer
   these over invoking tools directly.
2. **Language manifest.**
   - `package.json` → Node/TypeScript scripts and dependencies.
   - `pyproject.toml` / `requirements.txt` / `setup.cfg` → Python.
   - `Cargo.toml` → Rust. `go.mod` → Go.
3. **Lockfiles** reveal the package manager: `pnpm-lock.yaml`, `yarn.lock`,
   `package-lock.json`, `bun.lockb`, `uv.lock`, `poetry.lock`, `Pipfile.lock`.
4. **Config files** reveal the tools and their scope: `tsconfig.json`,
   `vitest.config.*`, `jest.config.*`, `eslint.config.*`, `.eslintrc*`,
   `biome.json`, `.prettierrc*`, `pytest.ini`, `[tool.ruff]`, `mypy.ini`,
   `ruff.toml`.
5. **CI** (`.github/workflows/*.yml`) is the ground truth for how the project is
   actually built and tested in automation. Match it.
6. **README / CONTRIBUTING** often document the intended commands.

## Mapping heuristics

| Need        | Node/TS                              | Python                        |
| ----------- | ------------------------------------ | ----------------------------- |
| Install     | `pnpm install` / `npm ci`            | `uv sync` / `poetry install`  |
| Test        | `pnpm test` / `vitest run` / `jest`  | `pytest` / `uv run pytest`    |
| Lint        | `pnpm lint` / `eslint .` / `biome ci`| `ruff check .`                |
| Format      | `prettier --check .` / `biome format`| `ruff format --check .`       |
| Typecheck   | `tsc --noEmit`                       | `mypy .` / `pyright`          |
| Build       | `pnpm build`                         | `python -m build`             |

Validate every mapping against the manifest. Do not output a command unless you
saw it, or it is the unambiguous default for a tool you confirmed is configured.

## Output

Report a compact table:

```
| Purpose   | Command               | Source               |
| --------- | --------------------- | -------------------- |
| install   | pnpm install          | pnpm-lock.yaml       |
| test      | pnpm test             | package.json scripts |
| lint      | pnpm lint             | package.json scripts |
| typecheck | pnpm typecheck        | tsconfig.json        |
| build     | pnpm build            | package.json scripts |
```

Include the source file for each command so the caller can verify. If a purpose
has no command, write `none` and say what that implies (e.g. no linter
configured — do not invent one).
