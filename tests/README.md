# Framework tests

The committed, canonical test suite for the opencode-framework repository itself.

**Maintainer-only.** This directory and `.github/` are framework-maintainer
tooling. The root packaging files `LICENSE`, `CONTRIBUTING.md`, `CHANGELOG.md`,
and `VERSION` are likewise framework-repo/maintainer-only. This directory and
those files are deliberately outside the adopter quickstart copy set. The three
bootstrap-mutable files an adopter receives come from the framework's
adopter-pristine sources — `template/AGENTS.md`, `template/opencode.json`, and
`template/.gitignore` — copied to their destination names; the framework
repository's own root copies of those three are maintainer-bootstrapped and are
never copied. The rest of the set (`.opencode/{agent,command,skill}`, and
`docs/*.md`) has a single source and is shared verbatim between the framework
repository and adopters. Adopters neither receive nor are expected to run or copy
the maintainer tooling or packaging files.

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
| `85-conflict-guards.sh` | declared-conflict declaration model and check guards (suite token `AC23`) |
| `90-packaging.sh` | packaging agreement: manifest ↔ changelog, copy-set, `Layout` (suite tokens `AC18`–`AC20`) |
| `95-split-guard.sh` | adoption split guard: quickstart sources, `docs/customization.md` contract, `template/AGENTS.md` placeholder profile and shared-body parity, copy-set surfaces, `bootstrap` deny rules (suite token `AC21`) |
| `96-signature-sweep.sh` | command signature agreement across the in-scope surfaces plus the `ask` agent description (suite token `AC22`) |

`90-packaging.sh` uses suite tokens `AC18`–`AC20`, which map to the
`0008-adoption-packaging` acceptance criteria: spec AC12 → `AC18` (manifest ↔
changelog agreement), spec AC13 → `AC19` (copy-set agreement), and spec AC14 →
`AC20` (`Layout` ↔ disk agreement).

`95-split-guard.sh` uses the stable suite token `AC21`, which maps to the
`0004-adoption-template-split/0003-split-guard-tests` acceptance criteria:
spec AC2 → `AC21` quickstart source/destination (the `README.md` quickstart
sources `template/AGENTS.md`, `template/opencode.json`, and
`template/.gitignore` to their destination names and never from a root copy),
spec AC3 → `template/AGENTS.md` unfilled placeholder Project profile (and, as a
companion assertion, the template's body is byte-identical to root `AGENTS.md`
outside that profile, so a shared edit cannot reach only one copy), spec AC4
→ the copy-set surfaces name all three pristine sources and never claim an
adopter receives a root copy, spec AC5 → the quickstart source agrees with the
`docs/customization.md` split contract, and spec AC6 → the `bootstrap` agent
denies edits under `template/` while leaving the adopter's own root files
editable.

`96-signature-sweep.sh` uses the stable suite token `AC22`, which maps to the
`0004-adoption-template-split/0005-surface-consistency-sweep` acceptance
criteria: spec AC1 → every command's usage string states the canonical
signature (the `/spec` and `/ship` strings are the two repaired here), spec AC2 → root `AGENTS.md`, spec AC3 →
`template/AGENTS.md`, spec AC4 → `docs/workflow.md`, spec AC5 → `README.md`,
spec AC6 → the `workflow-lifecycle` skill, and spec AC7 → the `ask` agent
description. The check extracts each stated signature from a designated position
on a surface, decodes the markdown-table and mermaid encodings, and compares it
to the canonical registry, failing with both the file and command named on any
divergence.

`85-conflict-guards.sh` uses the stable suite token `AC23`, which maps to the
`0006-parallel-plan-conflicts/0004-conflict-guards` acceptance criteria: spec AC1
→ `AC23 column-layout`/`AC23 positional-parse` (the declaration fixture's
6-column `Children` header keeps `Depends on` at pipe-field 5; the cyclic
fixture's own cycle agreement stays with `80-cycle-fixture.sh`), spec AC2 →
`AC23 cell-resolution` (every `conflicts-with` cell is `—` or a well-formed target
list, and a malformed or unresolved target fails and names the area), spec
AC3/AC4 → `AC23 pair-predicate` (a shared target and the one-sided naming of a
silent counterpart are each a genuine declared conflict), spec AC5 → `AC23
cell-resolution` (sibling-first, canonical item, file and directory surface,
`—`/absent, and each malformed/self/duplicate/empty/non-existent case resolves as
expected), spec AC6 → `AC23 cell-resolution` (a child's declared set is the union
of its own declaration and the parent cell; a both-present unequal pair is named
drift while a one-sided record is not), spec AC7 → `AC23 pair-predicate` (a
shipped item still resolves as a target but is excluded as a counterpart), spec
AC8 → `AC23 reporting-vocabulary` (the authority's codes, classes, and grammar,
the skill grammar, and the operative-prompt references, with no new class or code
introduced), spec AC9/AC13 → the fixture-existence and read-only-contract
assertions (fixture-only reads, no live `work/**`, no committed executable
checker), and spec AC10/AC11/AC12 → the existing agreements staying green, the
`tests/mutation.sh` cases, and this README. A live `/conflicts`, `/status`, or
`/build`-gate model run is not executable in CI; like the cycle diagnostic's
LLM-run residual, it remains a documented manual check.

## Mutation self-check

`tests/mutation.sh` is opt-in maintainer tooling (not part of `run.sh`, not run
in CI). It runs the suite against a copy of the live surfaces with no `work/`,
runs it with every optional tool forced absent, then applies one mutation per
agreement area and asserts each is caught and named.
