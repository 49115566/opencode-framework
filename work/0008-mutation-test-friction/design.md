---
feature: 0008-mutation-test-friction
phase: design
status: final
created: 2026-10-09
updated: 2026-10-09
conflicts-with: "tests/mutation.sh, tests/run.sh, tests/lib.sh, tests/README.md"
---

# Design — Reduce mutation-test harness friction

## Summary

Give `tests/run.sh` an opt-in subset selector (`FRAMEWORK_TEST_AREAS`), make the
optional-tool capability probes lazy so a run only probes tools an executed area
references, and restructure `tests/mutation.sh` into a job runner that runs each
mutation against only its catching agreement area, verifies restoration by byte
comparison instead of a suite run, and executes jobs across isolated per-worker
scratch copies. The mutation pass's whole-suite executions drop from roughly two
per mutation to a small constant, while every mutation is still caught and named
and the canonical full run is byte-for-byte unchanged when no selection is given.

## Approach

### 1. Subset selection in the canonical command (AC1–AC4)

- **Surface.** A single environment variable, `FRAMEWORK_TEST_AREAS`, consistent
  with the existing `FRAMEWORK_TEST_NO_PY/_OPENCODE/_NPM` override namespace. A
  selector is a comma- or whitespace-separated list. Unset means "full run" and
  changes nothing (AC2). Set-but-empty or whitespace-only is an explicit empty
  selection and is a setup error (AC3).
- **Area identity.** An agreement area is one `tests/checks/*.sh` file (the
  `tests/README.md` Checks-table unit). Its selector is the file's basename
  without `.sh` (for example `10-readiness`, `85-conflict-guards`). The set is
  discovered from the `checks/*.sh` glob, so 0007's new `87-backtrack-guards.sh`
  and any future area are selectable with no registry to maintain.
- **Matching.** Each trimmed selector resolves against the area-name set:
  1. an exact area-name match wins;
  2. otherwise a unique name-prefix match wins (`85` → `85-conflict-guards`, `4` →
     `40-inventory`);
  3. a prefix matching two or more areas is **ambiguous**; a selector matching
     none is **unknown**. Both cases print `setup error: ...` naming the offending
     selector and exit `2`, as does an explicit empty selection. There is no
     silent fallback to a full run and no success report (AC3).
- **Execution.** Resolution deduplicates (`10,10-readiness` runs `10-readiness`
  once) and preserves the existing filename source order, so selected areas run
  deterministically and in the same order as a full run (AC edge: several areas,
  duplicates, all areas). `run.sh` filters the `checks` list, sources only the
  selected files in the one shared process, and prints the same
  `TOTAL: <p> passed, <f> failed, <s> skipped` line, whose counts now cover only
  the executed areas; exit `0`/`1`/`2` semantics are unchanged (AC1).

### 2. Area isolation (AC4)

Selection only changes *which* check files are sourced; it does not reorder or
partition the process. Recon shows each check defines its own helper functions
and locals and depends only on the `lib.sh` counters, reporters, path constants,
and probe variables, so an area's behavior is unchanged when its siblings are
absent. The design keeps the one-process model deliberately: a full run sources
the same files in the same order (AC2), and per-area selection is a filter of
that same list. T2 runs every area alone and repairs any hidden coupling found;
coverage and assertions are never weakened.

### 3. Lazy optional-tool probes (spec Goal; AC1, AC12)

`tests/lib.sh` keeps the `have_py`/`have_opencode`/`have_npm`/`have_net`
variables and the `FRAMEWORK_TEST_NO_*` overrides, but moves detection into
idempotent functions `probe_py`, `probe_opencode`, `probe_npm`, `probe_net` that
populate them on first call and cache (including the npm-registry network probe,
which runs inside `probe_net`). After `run.sh` has resolved the selected check
files, it calls `probe_needed_by "${selected_checks[@]}"`; that function scans
each selected check for the `have_*` names it references and calls only the
matching probes. A subset that does not execute `60-default-agent`/`70-pin` never
probes the opencode CLI or the npm registry; a full run probes exactly what it
uses. No check file changes and no assertion is touched.

### 4. Area-scoped, cheap, parallel mutation runner (AC5–AC10)

`tests/mutation.sh` is restructured from a linear list of
`apply → full-suite run → restore → full-suite clean run` blocks into a job
runner:

- **Job model.** Each mutation is a job: an `id`, the single **area** that
  detects and names it, the expected named substring, a human description, a
  mutation function that edits the worker's copy, and the file(s) to restore.
  Function-per-job dispatch is used rather than a static data table because
  several jobs compute their mutation values and expected substrings at runtime
  (for example the inventory-count and version mutations).
- **Area-scoped detection (AC5).** A job runs `FRAMEWORK_TEST_AREAS=<area>
  FRAMEWORK_TEST_NO_* =1 bash tests/run.sh <worker-copy>`, asserts a non-zero
  exit, and asserts the log names the expected area substring. Only the catching
  area executes for that mutation; unaffected areas never run.
- **Cheap restore (AC6).** After the mutation is caught, each mutated file is
  copied back from the real repository and verified with `cmp -s` against the
  original (falling back to `git diff --no-index --quiet` if `cmp` is absent); a
  mismatch is a reported failure that names the unrestored surface. No suite run
  is performed per mutation.
- **Bounded whole-suite runs (AC7, AC10).** The only whole-suite executions are
  the two constant setup runs that precede the jobs — a plain run against a copy
  with no `work/`, and a forced-absent run — plus the visible-skip assertion that
  reuses the absent log. These are run with `FRAMEWORK_TEST_AREAS` explicitly
  unset so an ambient value cannot make them subsets.
- **Inventory (AC8).** Every mutation block present at build time is converted,
  including the eight `AC24` blocks added by
  `0007-phase-backtracking/0007-backtracking-guards`. The current inventory is 19
  blocks growing to 27; each maps to exactly one area, tabulated in "Interfaces
  and data model".
- **Parallelism with isolation (AC9).** Worker count is `FRAMEWORK_MUTATION_JOBS`
  when set to a positive integer, else detected best-effort (`getconf
  _NPROCESSORS_ONLN`, then `nproc`), else `1`; it is capped at the job count.
  Jobs are dealt round-robin to that many background worker subshells, each with
  its own staged copy under `scratch/framework-mutation/w<N>/live` and its own
  log/result file, so no worker can observe another's mutation. Workers append
  one result line per job; after `wait`, the main process prints results in job
  order, aggregates the counts (so the set of named mutations and the aggregate
  exit equal a serial run), and exits non-zero if any job failed. One worker's
  failure never aborts another's. The whole scratch subtree is removed on exit,
  including on failure, via the existing trap. On a one-CPU machine this degrades
  to a serial run.
- **Restore self-test.** `bash tests/mutation.sh --selftest` proves the
  corrupted-restore path: it performs a deliberate bad restore and asserts the
  runner reports a failure naming the surface, and it exercises the selector
  error cases against `run.sh` (unknown, ambiguous, empty) plus one successful
  subset. This keeps the harness behavior committed-testable without adding an
  agreement area.
- **Timing (AC10).** The runner prints elapsed seconds (bash `SECONDS`), so the
  tester records a measured wall-clock comparison against the baseline captured
  before the restructure.

### 5. Documentation (AC11)

`tests/README.md` gains: the subset-selection surface, matching rule, and error
behavior; a note that optional-tool probes are lazy and the probe table's
"probed when used" behavior; the mutation runner's area-scoped/parallel/cheap-
restore execution model; and a **mutation policy** stating the pass is opt-in and
not run in CI, that the full pass is a scheduled/milestone audit with area-scoped
mutations as the development norm, and that a new area should add one mutation
per distinct rule with a normative cap (three mutations per area unless the area
covers more distinct rules). Existing mutation, check, and skip documentation is
kept.

## Alternatives considered

- **Selector as a command argument (`tests/run.sh --area X`) instead of an
  environment variable.** Pros: discoverable and visible in shell history. Cons:
  adds argv parsing that must not disturb the existing `[repo-root]` positional
  (used by the mutation runner) or the `0/1/2` contract, and diverges from the
  existing `FRAMEWORK_TEST_*` override convention. **Rejected** for the
  environment variable; the mutation runner and maintainers both already pass
  environment overrides.
- **Run each selected area in its own subprocess and aggregate.** Pros: stronger
  isolation, trivially parallel. Cons: changes the documented one-process model
  and the shared-counter semantics that AC2 pins as unchanged, and adds process
  startup per area. **Rejected** for filtering the source list in the one
  process.
- **Make probes lazy by editing each check that needs a tool to call `probe_*`.**
  Pros: the call site is obvious. Cons: touches `tests/checks/**` (the spec's
  intended change surface is the harness files), widens the merge conflict with
  0007's new area, and couples lazy probing to every future optional-tool check.
  **Rejected** for a `probe_needed_by` scan in `lib.sh`/`run.sh`, which keeps the
  change in the harness and self-maintains.
- **Parallelize with `xargs -P` or GNU `parallel`.** Pros: less hand-rolled
  scheduling. Cons: introduces a tool outside the bash-plus-git minimum and is
  not portable to a minimal macOS/BSD environment. **Rejected** for a bash worker
  pool with a serial fallback.
- **Verify restore by re-running the clean suite (status quo).** Pros: strongest
  end-to-end signal. Cons: this is the cost being removed (two whole-suite runs
  per mutation). **Rejected** for direct byte comparison plus the retained
  constant end-to-end clean runs, which is exactly AC6's contract.
- **Represent jobs as a static delimiter-separated table.** Pros: one place to
  read the inventory. Cons: several mutations compute file names, versions, and
  expected substrings at run time, so the table cannot hold them. **Rejected**
  for function-per-job dispatch with a compact per-job header.

## Interfaces and data model

**Environment variables (new):**

- `FRAMEWORK_TEST_AREAS` — optional selector list for `tests/run.sh`; unset = full
  run, set-but-empty = setup error.
- `FRAMEWORK_MUTATION_JOBS` — optional positive integer worker count for
  `tests/mutation.sh`; invalid values fall back to detection and then to `1`.
- Existing `FRAMEWORK_TEST_NO_PY`/`_OPENCODE`/`_NPM` keep their meaning and still
  force a probe absent.

**`tests/lib.sh` (new helpers):**

- `area_name_of <check-file>` — prints the basename without `.sh`.
- `resolve_area_selector <selector> <newline-separated area names>` — prints the
  resolved area name and returns `0`; returns `3` unknown, `4` ambiguous (also
  printing the candidate names) for `run.sh` to turn into a `setup error`.
- `probe_py` / `probe_opencode` / `probe_npm` / `probe_net` — idempotent;
  honor the force-absent overrides; cache into `have_py`/`have_opencode`/
  `have_npm`/`have_net`.
- `probe_needed_by <check-file>...` — call only the probes referenced by the
  named check files.

**`tests/run.sh`:** parses `FRAMEWORK_TEST_AREAS` after `lib.sh` is sourced,
resolves and filters the `checks` array, calls `probe_needed_by` on the selected
files, sources them in order, prints `TOTAL`, exits `[ "$fail" -eq 0 ]`; every
resolution failure exits `2` before any check is sourced.

**`tests/mutation.sh` (new structure):**

- `stage_worker <w>` — stage a full live-surface copy at
  `$SCRATCH/w<w>/live` (no `work/`), as today's `stage()` does plus 0007's
  fixture root.
- `run_area <worker-copy>` — run only `$J_AREA` with the force-absent overrides.
- `check_caught` — assert non-zero exit and the expected named substring.
- `restore_verify <file>...` — copy each file back from `$REPO_ROOT` and
  `cmp -s`; report a failure naming the first unrestored surface.
- `job_<n> <worker>` — set `J_AREA`/`J_EXPECTED`/`J_DESC`, apply the mutation to
  the worker copy, run/check, restore/verify.
- `selftest` mode and `--selftest` argument.
- Job→area mapping (all blocks present at build time):

  | Mutation token / rule | Area |
  | --------------------- | ---- |
  | AC6 readiness sentence | `10-readiness` |
  | AC7 lifecycle route | `20-lifecycle` |
  | AC8 permission cell | `30-permissions` |
  | AC9 inventory count | `40-inventory` |
  | AC10 instruction path | `50-instructions` |
  | AC11 default agent | `60-default-agent` |
  | AC12 external pin | `70-pin` |
  | AC13 cycle fixture | `80-cycle-fixture` |
  | AC23 conflict guards (5 rules) | `85-conflict-guards` |
  | AC24 backtrack guards (8 sub-areas, from 0007) | `87-backtrack-guards` |
  | AC18/AC19/AC20 packaging | `90-packaging` |
  | AC21 split guard (2 rules) | `95-split-guard` |
  | AC22 signature sweep | `96-signature-sweep` |

**Backward compatibility and migrations:** none. With `FRAMEWORK_TEST_AREAS`
unset, `bash tests/run.sh` behaves as before (same selected files, same order,
same probes for the areas that use them, same `TOTAL`/exit). `tests/mutation.sh`
stays opt-in and outside CI; its exit contract (`0` all caught / `1` an escape or
restore failure / `2` setup error) is unchanged. No new runtime dependency is
introduced: the runner already requires POSIX `awk`/`sed`/`grep`/`cp`, and
`cmp -s` is a POSIX utility (with a git fallback); parallelism uses only bash
background jobs, and CPU detection is best-effort with a `1` fallback.

## Affected areas

- `tests/run.sh` — subset parsing, filtering, probe invocation.
- `tests/lib.sh` — area resolver, lazy probe functions, `probe_needed_by`.
- `tests/mutation.sh` — area-scoped parallel job runner, cheap restore, clean-run
  and self-test handling (converts all blocks including 0007's eight `AC24`
  blocks).
- `tests/README.md` — selection, lazy probes, execution model, mutation policy.

**Deliberately unchanged:** `tests/checks/**` and `tests/fixtures/**` (the
mutation inventory and areas are consumed, not edited, except for a minimal
coupling repair if T2 finds one), `.github/workflows/ci.yml`, `docs/**`,
`.opencode/**`, `README.md`, `AGENTS.md`, `template/**`, and `opencode.json`
(AC13). The suite stays read-only, provider-neutral, fresh-clone runnable, and
never reads live `work/**` (AC12).

## Risks and mitigations

- **Hidden cross-area coupling makes some area fail when selected alone (AC4).**
  Likelihood: medium. Impact: high. Mitigation: T2 runs every area alone and
  repairs any dependency on a sibling's globals; the one-process source order is
  preserved (filtering, not reordering).
- **A mutation is caught by a different area than the one a job selects, so
  area-scoped detection misses it (AC5/AC8).** Likelihood: medium. Impact: high.
  Mitigation: each job is mapped to the area that prints the expected token; the
  converter verifies each job under its single area before deleting the
  full-suite per-mutation path, and the full pass must exit `0`.
- **Parallel workers race on shared scratch or repository files (AC9).**
  Likelihood: medium. Impact: high. Mitigation: each worker owns an isolated
  staged copy and its own result/log file; the repository is read-only to the
  workers; `FRAMEWORK_MUTATION_JOBS=1` is the serial fallback; the exit trap
  removes the whole scratch subtree.
- **Bash 3.2 incompatibility (associative arrays, `mapfile`, empty-array
  expansion under `set -u`).** Likelihood: medium. Impact: medium. Mitigation:
  use indexed arrays/scalars only, keep the existing empty-array guards, and run
  both `bash tests/run.sh` and `bash tests/mutation.sh` under the project bash.
- **CPU detection unavailable or wrong.** Likelihood: medium. Impact: low.
  Mitigation: best-effort detection with a `1` fallback and the
  `FRAMEWORK_MUTATION_JOBS` override; a wrong count never changes results.
- **The `0007` sequencing is not met, so `87-backtrack-guards.sh`, its fixtures,
  or its eight mutation blocks are absent at build time (AC5/AC8).** Likelihood:
  low. Impact: high. Mitigation: the baseline/inventory step and every job-
  conversion task treat the area and fixtures as a precondition and stop blocked
  if they are missing; the declaration makes the overlap with 0007's plan
  explicit.
- **Selection changes the full run (AC2/AC12).** Likelihood: low. Impact: high.
  Mitigation: the selection path is entered only when `FRAMEWORK_TEST_AREAS` is
  set; T1 compares the unset full run's `TOTAL` and exit against the pre-change
  baseline.
- **The probe scan over-probes or misses a probe reference.** Likelihood: low.
  Impact: low. Mitigation: over-probing is harmless and a missed reference can
  only turn a would-be probe into a skip; the check source is the declaration of
  need. Forced-absent runs still exit `0` with visible skips.
- **`cmp` absent on a minimal host.** Likelihood: low. Impact: low. Mitigation:
  fall back to `git diff --no-index --quiet`, which the bash-plus-git minimum
  guarantees.

## Test strategy

Because the spec's non-goals forbid adding or removing agreement areas or check
files, the committed tests for the harness behavior live in the mutated
`tests/mutation.sh` (its job runner and `--selftest`), and the acceptance
evidence is recorded in `verify.md`.

| Criterion | Verification level and method |
| --------- | ----------------------------- |
| AC1 | Integration: `FRAMEWORK_TEST_AREAS=10-readiness bash tests/run.sh` exits `0`; its `TOTAL` equals that area's per-area count and excludes others; duplicate selectors run once. |
| AC2 | Integration: `bash tests/run.sh` with the variable unset exits `0` with the pre-change `TOTAL` and sources every area in order. |
| AC3 | Integration/self-test: unknown (`nope`), ambiguous (`8`), and explicitly empty selections each exit `2`, name the offender, and run no area; `mutation.sh --selftest` asserts the three cases. |
| AC4 | Integration: every `tests/checks/*.sh` area selected alone exits `0` with its own assertions/skips; full run stays green. |
| AC5 | E2E: each mutation job run through only its area is caught and named; unaffected areas are absent from the job log. |
| AC6 | Unit/self-test: `restore_verify` passes on a correct restore and a deliberately corrupted restore is reported naming the surface (`mutation.sh --selftest`). |
| AC7 | E2E: the pass runs the clean copy end-to-end with no `work/` and with every optional tool forced absent, both `0`. |
| AC8 | E2E: `bash tests/mutation.sh` exits `0` with zero failed mutations and every mutation named. |
| AC9 | E2E: the pass exits `0` with the same set of named mutations under `FRAMEWORK_MUTATION_JOBS=1` and a value `>1`; each worker's scratch is isolated and removed. |
| AC10 | E2E/measured: the pass performs a constant two whole-suite runs independent of the mutation count; `verify.md` records the post-change wall time against the pre-change baseline. |
| AC11 | Manual/review: `tests/README.md` states the opt-in/not-CI policy, the scheduled/milestone audit norm, the per-area mutation rule and cap, and does not displace the existing mutation/check/skip documentation. |
| AC12 | Integration: `bash tests/run.sh` exits `0`; the suite remains read-only, provider-neutral, fresh-clone runnable, and reads no `work/**`. |
| AC13 | Inspection: `git diff --name-only` lists only `tests/**`; no CI, doc, agent, command, skill, config, or dependency change. |

A live wall-clock comparison and a manual policy review are the residual
non-CI-checkable evidence, recorded in `verify.md`, mirroring the existing
cycle-diagnostic/manual residuals.
