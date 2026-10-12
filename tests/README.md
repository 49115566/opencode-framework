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
adding a file; `run.sh` needs no edit. Set `FRAMEWORK_TEST_AREAS` to run only a
subset of the areas (see "Area selection").

The suite is read-only, provider-neutral, and never reads `work/**`, so it runs
on a fresh clone with no per-item artifacts present.

## Area selection

`tests/run.sh` can run a subset of the agreement areas. Set
`FRAMEWORK_TEST_AREAS` to a comma- or whitespace-separated list of selectors:

```sh
FRAMEWORK_TEST_AREAS=10-readiness bash tests/run.sh
FRAMEWORK_TEST_AREAS='10-readiness,85-conflict-guards' bash tests/run.sh
```

A selector is an **area name** — a `tests/checks/*.sh` stem such as
`10-readiness` or `85-conflict-guards`, the file's basename without `.sh`. Each
trimmed selector resolves against the present `tests/checks/*.sh` areas:

1. an exact area-name match wins;
2. otherwise a unique name-prefix match wins (`85` → `85-conflict-guards`);
3. a prefix matching two or more areas is **ambiguous**, and one matching none
   is **unknown**.

Only the selected areas are sourced, in the same filename order as a full run,
and a selector that resolves to an area already selected is not counted twice
(`10,10-readiness` runs `10-readiness` once). The printed `TOTAL` then counts
only the executed areas' assertions, and the exit contract below is unchanged.

Selection errors are setup errors: an unknown selector, an ambiguous prefix, or
an explicitly empty (or whitespace-only) value prints `setup error:` naming the
offending selector (or the empty selection) and exits `2` before any check is
sourced. There is no silent fallback to a full run. An **unset**
`FRAMEWORK_TEST_AREAS` is the unchanged full run.

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

Optional-tool probes come from `tests/lib.sh`. They are **lazy**: `run.sh` calls
`probe_needed_by` on the selected checks, which scans each check for the
`have_*` names it references and calls only the matching probes, so a run never
probes a tool that no executed area uses. Each probe is idempotent, honors its
force-absent override, and caches into its `have_*` variable.

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
| `25-review-severity-bar.sh` | review severity-bar agreement (suite token `AC25`) |
| `30-permissions.sh` | documented-vs-declared permission agreement |
| `40-inventory.sh` | documented inventory counts vs disk |
| `50-instructions.sh` | always-loaded instruction set agreement |
| `60-default-agent.sh` | default-agent agreement |
| `70-pin.sh` | external pin agreement |
| `80-cycle-fixture.sh` | roadmap cycle rule and committed fixture |
| `85-conflict-guards.sh` | declared-conflict declaration model and check guards (suite token `AC23`) |
| `87-backtrack-guards.sh` | backtracking and reopen guards (suite token `AC24`) |
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

`87-backtrack-guards.sh` uses the stable suite token `AC24`, which maps to the
`0007-phase-backtracking/0007-backtracking-guards` acceptance criteria: spec AC1
→ `AC24 reverse-edge` (the append-only `backtracks.md` finding names the detecting
phase, the target phase, the affected artifact, and `status: open`, and the live
reverse-edge table's five sanctioned intra-item edges are asserted), spec AC2 →
`AC24 record-status` (a finding is `open` without a matching `Resolution <n>` and
`resolved` with one, keyed on the resolution header number; a resolution recorded
before its finding is reported malformed and never reordered), spec AC3 → `AC24
stale-downstream` (the design-target edges mark the downstream artifacts `stale:
design`, the spec-target edges `stale: spec`, the rework edge forces no marker,
and the target phase's own artifact is not marked by the detecting phase), spec
AC4 → `AC24 challenge-loop` (the `Challenge`/`Response`/`Withdrawal`/`Reversal`
entry kinds, the `type` and `decision` token sets, the adjudicator values, the
open-until-`Response`/`Withdrawal` status rule, and a `Reversal` superseding
without reopening), spec AC5 → `AC24 roadmap-revision` (the revised `Children`
table's positional columns, no-self and acyclic dependency graph, resolving
canonical references, active-child listing, sequencing order, the
preserved-but-unlisted withdrawn child, and the revision-note fields), spec AC6 →
`AC24 readiness-revocation` (a recalled `ship.md` computes unsatisfied and names
the dependent's blocking dependency, while a non-recalled ship record and an
`approve` verdict still compute satisfied, with no stored readiness value), spec
AC7/AC8 → `AC24 derived-state` (the earliest `stale:` marker, the `reopened:`
marker, the unshipped open-challenge blocked condition, the shipped item never
challenged, and the absent-record item's ordinary forward derivation that invents
no backtracked/challenged/reopened state), spec AC9 → `AC24 contract-pins` (the
documented record/field/marker/token/derived-label strings on
`docs/artifact-conventions.md` and `docs/workflow.md`, referencing the authorities
by name and restating neither the readiness algorithm nor the command
signatures), spec AC10 → the `fixture-existence` and `read-only-contract`
structural assertions (the fixture tree references no live `work/` path, the check
adds no committed production checker, and a missing fixture fails rather than
skips), spec AC11 → the `tests/mutation.sh` cases (one mutation per declared
sub-area, each caught and named), spec AC12 → the `no-duplication` structural
assertion and the existing areas staying green (the check re-asserts none of the
literals owned by `10-readiness.sh`/`20-lifecycle.sh`/`96-signature-sweep.sh` and
references `80-cycle-fixture.sh`/`85-conflict-guards.sh` by name), spec AC13 →
this README, and spec AC14 → the untouched production surfaces. The check reads
only the committed `tests/fixtures/backtracking/` fixture root and never live
`work/**`, making it the fixture-based analogue of the cycle and conflict guards.
A live `/status` render, a real backtrack, or a `/ship recall` is not executable
in CI; like the cycle diagnostic's LLM-run residual, it remains a documented
manual check.

`25-review-severity-bar.sh` uses the stable suite token `AC25`, which maps to the
`0009-minor-nit-resolution` acceptance criteria: spec AC1/AC2/AC8 → `AC25
all-severity-bar` (a surviving finding of any severity — `Blocker`, `Major`,
`Minor`, or `Nit` — yields `request-changes`, and `approve` if and only if no
finding of any severity survives, pinned identically on the reviewer agent, the
`/review` command, the `code-review` skill, `docs/workflow.md`, and the
`workflow-lifecycle` skill), spec AC5/AC6 → the sustained-challenge recompute
phrases (`approve` if and only if no finding of any severity remains; a finding
adjusted to `Minor` or `Nit` still blocks and only an overturn removes it), spec
AC7's question-escape edge case → `AC25 all-severity-bar` (the reviewer's question
records genuine uncertainty and is never a classified `Minor`/`Nit` being
declined, so a classifiable finding must be recorded), spec
AC7/AC10 → `AC25 contract-preserved` (the four severity labels and both verdicts
stay on the two definition surfaces, the `Minor`/`Nit` definitions say the finding
blocks the item and is not declinable, and no surface carries `Blocker or Major`,
`not merge-blocking`, `the author may decline`, or a new disposition token such
as `waived`/`declined`), and spec AC12 → the unchanged inventory and signature
areas (`40-inventory.sh`, `96-signature-sweep.sh`) staying green. It is a
live-surface agreement check (the analogue of `50-instructions.sh` and
`96-signature-sweep.sh`): it reads only committed surfaces and never live
`work/**`, matching the read-only suite contract above. A live re-review or an
actual challenge adjudication is prompt behavior and is not executable in CI;
like the cycle diagnostic's LLM-run residual, it remains a documented manual
check.

## Mutation self-check

`tests/mutation.sh` is opt-in maintainer tooling (not part of `run.sh`, not run
in CI). It stages a copy of the live surfaces with no `work/` under the
git-ignored `scratch/` (the repository itself is never mutated), then:

1. runs the whole suite against the clean copy and asserts exit `0`
   (fresh-clone independence);
2. runs it with every optional tool forced absent
   (`FRAMEWORK_TEST_NO_PY=1 FRAMEWORK_TEST_NO_OPENCODE=1 FRAMEWORK_TEST_NO_NPM=1`)
   and asserts exit `0` with visible `skip` lines;
3. for each mutation job, applies exactly one mutation to a worker's copy, runs
   **only the single agreement area that must catch it** (via
   `FRAMEWORK_TEST_AREAS`), asserts the suite exits non-zero and names the
   expected token, then restores each mutated surface from the repository and
   verifies it byte-for-byte with `cmp -s` (falling back to
   `git diff --no-index --quiet` when `cmp` is absent). No full-suite run is
   needed to prove a restore;
4. prints `MUTATION TOTAL: <p> checked passed, <f> failed`, and exits non-zero if
   any mutation was not caught and named, any restore was not byte-for-byte, or
   any whole-suite run failed. The whole `scratch/` subtree is removed on exit,
   including on failure.

The whole-suite runs in steps 1–2 (plus the visible-skip assertion, which reuses
the forced-absent log) are the pass's only whole-suite executions, so their count
is a small constant independent of the mutation count.

```sh
bash tests/mutation.sh              # run the pass
bash tests/mutation.sh --selftest   # self-test only
```

`--selftest` proves the runner's own assertions without running the mutation
pass: it exercises the corrupted-restore path (asserting the report names the
unrestored surface) and the `run.sh` selector error cases (unknown, ambiguous,
explicitly empty) plus one successful subset.

### Parallelism

Mutation jobs run concurrently across available CPUs. The worker count is
`FRAMEWORK_MUTATION_JOBS` when it is a positive integer, otherwise a best-effort
CPU count (`getconf _NPROCESSORS_ONLN`, then `nproc`), otherwise `1`; it is
capped at the job count. Jobs are dealt round-robin to that many background
worker subshells, each with its own staged copy under
`scratch/framework-mutation.<pid>/w<N>/live` and its own result/log file, so no
worker can observe another's mutation and one worker's failure never aborts
another's. The scratch root is unique per invocation (pid-suffixed), so two
concurrent passes never share a copy, log, result, or cleanup target and cannot
interfere with one another. Results are printed in job order after `wait` and
aggregated, so the set of named mutations and the aggregate exit equal a serial
run. A one-CPU machine degrades to a serial run.

### Mutation policy

- The mutation self-check is **opt-in** and is **not run in CI**
  (`.github/workflows/ci.yml` runs only `bash tests/run.sh`).
- The **full pass is a scheduled/milestone audit**, not a per-task ritual.
  **Area-scoped mutations are the development norm**: while developing a change,
  exercise the mutation check for the area you touched rather than paying for the
  whole pass.
- A new agreement area should add only a **bounded number of mutations — one per
  distinct rule** it enforces. The normative cap is **three mutations per area**;
  an area that genuinely covers more than three distinct rules may exceed the cap
  (one mutation per rule), since the cap is a stated norm rather than a hard wall.
  This keeps the pass's cost bounded as the framework grows.
