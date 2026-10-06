# Framework tests

The committed, canonical test suite for the opencode-framework repository itself.

**Maintainer-only.** This directory and `.github/` are framework-maintainer
tooling. The root packaging files `LICENSE`, `CONTRIBUTING.md`, `CHANGELOG.md`,
and `VERSION` are likewise framework-repo/maintainer-only. This directory and
those files are deliberately outside the adopter quickstart copy set
(`.opencode/{agent,command,skill}`, `AGENTS.md`, `opencode.json`, `.gitignore`,
and `docs/*.md`), so adopters neither receive nor are expected to run or copy
them.

## Canonical command

```sh
bash tests/run.sh
```

`tests/run.sh [repo-root]` resolves the repository root (an optional first
argument, otherwise the git top level), sources `tests/lib.sh`, then sources
every `tests/checks/*.sh` in filename order **in one process**. Adding a check is
adding a file; `run.sh` needs no edit.

The suite is read-only, provider-neutral, and never reads `work/**`, so it runs
on a fresh clone with no per-item artifacts present.

## Exit contract

| Exit | Meaning |
| ---- | ------- |
| `0`  | every executed assertion passed; skips do not fail the run |
| `1`  | one or more assertions failed |
| `2`  | setup error (not a git repo, cannot cd, cannot locate the checks) |

The printed summary is the human-readable form of the exit status:

```
TOTAL: <p> passed, <f> failed, <s> skipped
```

## Skip policy

A check whose only missing prerequisite is an optional tool reports `skip` and
does not increment `fail`, so a minimal environment (bash + git only) still
exits `0`. A skipped check is always printed; a silently dropped assertion is a
defect.

Optional-tool probes come from `tests/lib.sh`:

| Probe | Detects | Forced absent by |
| ----- | ------- | ---------------- |
| `have_py` | `python3` | `FRAMEWORK_TEST_NO_PY=1` |
| `have_opencode` | the `opencode` CLI | `FRAMEWORK_TEST_NO_OPENCODE=1` |
| `have_npm` | `npm` | `FRAMEWORK_TEST_NO_NPM=1` |
| `have_net` | npm registry reachability (probed only when `npm` is present) | `FRAMEWORK_TEST_NO_NPM=1` |

The overrides exist so skips can be exercised deterministically.

## Checks

Each file under `tests/checks/` is one agreement area and labels its assertions
with a stable `ACn` token.

| File | Area |
| ---- | ---- |
| `10-readiness.sh` | readiness / dependency-satisfaction agreement |
| `20-lifecycle.sh` | lifecycle and derived-state agreement |
| `30-permissions.sh` | documented-vs-declared permission agreement |
| `40-inventory.sh` | documented inventory counts vs disk |
| `50-instructions.sh` | always-loaded instruction set agreement |
| `60-default-agent.sh` | default-agent agreement |
| `70-pin.sh` | external pin agreement |
| `80-cycle-fixture.sh` | roadmap cycle rule and committed fixture |
| `90-packaging.sh` | packaging agreement: manifest ↔ changelog, copy-set, `Layout` (suite tokens `AC18`–`AC20`) |

`90-packaging.sh` uses suite tokens `AC18`–`AC20`, which map to the
`0008-adoption-packaging` acceptance criteria: spec AC12 → `AC18` (manifest ↔
changelog agreement), spec AC13 → `AC19` (copy-set agreement), and spec AC14 →
`AC20` (`Layout` ↔ disk agreement).

## Mutation self-check

`tests/mutation.sh` is opt-in maintainer tooling (not part of `run.sh`, not run
in CI). It runs the suite against a copy of the live surfaces with no `work/`,
runs it with every optional tool forced absent, then applies one mutation per
agreement area and asserts each is caught and named.
