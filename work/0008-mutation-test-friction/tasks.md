---
feature: 0008-mutation-test-friction
phase: tasks
status: final
created: 2026-10-09
updated: 2026-10-09
---

# Tasks — Reduce mutation-test harness friction

Ordered, dependency-aware. One task ≈ one focused commit. After every task,
`bash tests/run.sh` must stay green. Design authority: `design.md`.

**Precondition (sequencing).** This item builds only after
`0007-phase-backtracking/0007-backtracking-guards` ships: `tests/checks/87-backtrack-guards.sh`,
its `tests/fixtures/backtracking/**` tree, and its eight `AC24` mutation blocks
must be present. T4 converts every mutation block present at build time, including
those eight. If the area, fixtures, or blocks are absent, stop and report the
item blocked rather than inventing them.

**Baseline (AC10).** Before T4 edits `tests/mutation.sh`, run the pre-change pass
once and record its wall time and its whole-suite run count; T8 compares against
it. On the post-0007 inventory (27 mutations) this is the recorded 7–11 minute
baseline.

- [ ] **T1** — Add opt-in subset selection to the canonical command: implement
      `area_name_of` and `resolve_area_selector` in `tests/lib.sh` (exact area-name
      match first, else unique name-prefix; return `3` unknown, `4` ambiguous
      printing candidates), and in `tests/run.sh` parse `FRAMEWORK_TEST_AREAS`
      (comma/whitespace separated), turn an unset value into the unchanged full
      run, turn a set-but-empty value into a `setup error:` naming the empty
      selection and exit `2`, resolve/dedupe selectors preserving filename order,
      print a `setup error:` naming any unknown or ambiguous selector and exit `2`
      before sourcing anything, and otherwise source only the selected checks in
      the one shared process. [AC1, AC2, AC3]
      Verify: `bash tests/run.sh` → exit 0 and the same `TOTAL` as before;
      `FRAMEWORK_TEST_AREAS=10-readiness bash tests/run.sh` → exit 0 and its
      `TOTAL` excludes every other area; `FRAMEWORK_TEST_AREAS=10,10-readiness
      bash tests/run.sh` → `10-readiness` counted once;
      `FRAMEWORK_TEST_AREAS=nope bash tests/run.sh` → exit 2 naming `nope`;
      `FRAMEWORK_TEST_AREAS=8 bash tests/run.sh` → exit 2 naming `8` and the
      ambiguous candidates; `FRAMEWORK_TEST_AREAS= bash tests/run.sh` → exit 2.

- [ ] **T2** — Prove and repair per-area isolation: run every area alone and
      confirm each sources the shared `lib.sh` state it needs and keeps its
      skip/execute behavior; if a hidden cross-area dependency is found (a helper
      or variable defined by another check), fix it minimally without changing any
      assertion or coverage. [AC4] [depends: T1]
      Verify: for every `tests/checks/*.sh`, `FRAMEWORK_TEST_AREAS=<stem>
      bash tests/run.sh` → exit 0 with that area's `ok`/`skip` lines and no
      `FAIL`; `bash tests/run.sh` (full) → exit 0.

- [ ] **T3** — Make the optional-tool probes lazy: in `tests/lib.sh` replace the
      eager `have_*` setup with idempotent `probe_py`/`probe_opencode`/
      `probe_npm`/`probe_net` functions that honor `FRAMEWORK_TEST_NO_PY`/
      `_OPENCODE`/`_NPM` and cache into `have_py`/`have_opencode`/`have_npm`/
      `have_net`; add `probe_needed_by` scanning check files for the `have_*` names
      they reference; in `tests/run.sh` call `probe_needed_by` on the selected
      checks only, so unselected areas' probes never run. Do not edit any
      `tests/checks/*.sh`. [spec Goal: probes only when an executed area needs
      them; AC1, AC12] [depends: T1]
      Verify: `bash tests/run.sh` → exit 0 with the same skip lines and `TOTAL` as
      before; `FRAMEWORK_TEST_AREAS=10-readiness bash -x tests/run.sh` trace
      contains no `probe_npm`, `probe_net`, or `probe_opencode` call, while a full
      `bash -x tests/run.sh` trace does; `FRAMEWORK_TEST_NO_PY=1
      FRAMEWORK_TEST_NO_OPENCODE=1 FRAMEWORK_TEST_NO_NPM=1 bash tests/run.sh` →
      exit 0 with visible `skip` lines.

- [ ] **T4** — Restructure `tests/mutation.sh` into the area-scoped job runner:
      after recording the baseline, replace the linear per-mutation
      `run → restore → clean-suite` blocks with jobs that each run only their
      catching area (via `FRAMEWORK_TEST_AREAS`), assert the mutation is caught
      and named, then restore each mutated file from the repository and verify it
      with `cmp -s` (falling back to `git diff --no-index --quiet`), reporting a
      failure that names an unrestored surface; convert every mutation block
      present at build time, including `0007`'s eight `AC24` blocks, each mapped to
      its single area per design's job→area table; keep exactly the two
      whole-suite setup runs (plain no-`work/` copy and all-optional-tools-absent)
      with `FRAMEWORK_TEST_AREAS` explicitly unset and the visible-skip assertion,
      and remove the per-mutation clean-suite runs. [AC5, AC6, AC7, AC10]
      [depends: T1]
      Verify: `bash tests/mutation.sh` → exit 0 with every mutation reported
      "caught and named" and `MUTATION TOTAL: <n> checked passed, 0 failed` where
      `<n>` equals the full block count (27 post-0007); the captured run log
      contains exactly two whole-suite `TOTAL:` lines; temporarily making one
      expected substring wrong → exit 1.

- [ ] **T5** — Add the runner self-test: `bash tests/mutation.sh --selftest`
      exercises a deliberately corrupted restore (asserting the report names the
      unrestored surface) and the selector error cases against `run.sh`
      (unknown, ambiguous, explicitly empty, plus one successful subset), exiting
      `0` only when every assertion holds. [AC1, AC3, AC6] [depends: T4]
      Verify: `bash tests/mutation.sh --selftest` → exit 0 and prints a passing
      corrupted-restore assertion plus the three selection-error assertions;
      breaking the self-test expectation → exit 1.

- [ ] **T6** — Parallelize the job runner: resolve the worker count from
      `FRAMEWORK_MUTATION_JOBS` (positive integer) else best-effort `getconf
      _NPROCESSORS_ONLN`/`nproc` else `1`, capped at the job count; deal jobs
      round-robin to background worker subshells each with an isolated staged copy
      under `scratch/framework-mutation/w<N>/live` and its own result/log file;
      after `wait`, print per-job results in job order and aggregate so the named
      set and aggregate exit equal a serial run; keep cleanup of the whole scratch
      subtree in the exit trap. [AC9] [depends: T4]
      Verify: `bash tests/mutation.sh` (default), `FRAMEWORK_MUTATION_JOBS=1
      bash tests/mutation.sh`, and `FRAMEWORK_MUTATION_JOBS=4 bash tests/mutation.sh`
      all → exit 0 with an identical set of named mutations; after each,
      `test -e scratch/framework-mutation` is false.

- [ ] **T7** — Document the harness changes in `tests/README.md`: add the
      `FRAMEWORK_TEST_AREAS` subset surface, matching rule, and error behavior;
      note that optional-tool probes are now probed on use and update the probe
      table text accordingly; describe the mutation runner's area-scoped,
      parallel, cheap-restore execution model; and add a **Mutation policy**
      section stating the pass is opt-in and not run in CI, that a full pass is a
      scheduled/milestone audit with area-scoped mutations as the development
      norm, and that a new area adds one mutation per distinct rule with a
      normative cap of three unless it covers more distinct rules. Keep the
      existing mutation, check, and skip documentation in place. [AC11]
      [depends: T1, T3, T4, T6]
      Verify: `bash tests/run.sh` → exit 0; `grep -nE
      'FRAMEWORK_TEST_AREAS|opt-in|scheduled|distinct rule|probed' tests/README.md`
      shows the selection, policy, and probe statements; the pre-existing Checks
      table and exit-contract sections are still present.

- [ ] **T8** — Final verification and measurement: confirm the full mutation pass
      exits `0` with zero failed mutations, whole-suite runs are the constant two
      (AC10), the canonical full suite exits `0` and reads no `work/**`
      (AC12), and only `tests/**` changed (AC13); record in the subsequent
      `verify.md` the post-change wall time against the T4 baseline.
      [AC8, AC10, AC12, AC13] [depends: T4, T5, T6, T7]
      Verify: `time bash tests/mutation.sh` → exit 0 and a wall time materially
      below the recorded baseline; the run log's whole-suite `TOTAL:` count is
      `2`; `bash tests/run.sh` → exit 0; `git status --porcelain -- docs .opencode
      .github README.md AGENTS.md template opencode.json` is empty and
      `git diff --name-only` lists only paths under `tests/`.
