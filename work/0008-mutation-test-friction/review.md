---
feature: 0008-mutation-test-friction
phase: review
status: final
created: 2026-10-12
updated: 2026-10-12
---

# Review — Reduce mutation-test harness friction

## Verdict

**approve** — all thirteen acceptance criteria are met by the diff, no Blocker or
Major survives scrutiny, and the two remaining Minor items are maintainability
caveats rather than defects; the item is ready to ship once a foreign untracked
directory in the working tree is dealt with (see "Not reviewed").

## Review basis

- Base ref: `git merge-base HEAD origin/main` = `5b07658a304e8ca0f95ab20d4403d2bffa925a7b`.
  `git rev-parse HEAD origin/main` = the same `5b07658`, so the diff is the
  **uncommitted working tree**.
- Commands used: `git merge-base HEAD origin/main`, `git rev-parse HEAD
  origin/main`, `git status`, `git diff --stat`, `git diff -- <file>`,
  `git show HEAD:tests/mutation.sh`, `git diff --name-only`.
- Reviewed diff: `tests/run.sh`, `tests/lib.sh`, `tests/mutation.sh`,
  `tests/README.md` (plus `work/0008-mutation-test-friction/tasks.md` box ticks,
  and the untracked `verify.md`). `git diff --name-only` confirms the source
  change surface is exactly those four `tests/**` files.
- No `challenges.md` and no `backtracks.md` exist for this item, so there was no
  open challenge to adjudicate.

## Acceptance criteria walkthrough

| AC | Status | Evidence |
| -- | ------ | -------- |
| AC1 — Subset execution | met | `run.sh:51-128` parses `FRAMEWORK_TEST_AREAS`, resolves/dedupes selectors, sources only selected checks in filename order in the one shared process; `run.sh:130` prints the same `TOTAL` over only the executed areas; `run.sh:131` keeps the `0`/`1` exit. `verify.md:53-59` records subset/multi/duplicate/order/all-areas runs. |
| AC2 — Full run unchanged | met | Unset path `run.sh:112-114` sets `chosen=("${checks[@]}")` (identical list/order); `probe_needed_by` (`run.sh:119-121`) reproduces the eager probes for the areas that use them. `verify.md:52` records a byte-identical full-run diff vs the HEAD harness. |
| AC3 — Selection errors | met | `run.sh:83-100`: ambiguous (`4`) and unknown (`3`) print `setup error: …` naming the offender and `exit 2` before sourcing; `saw_token=0` covers set-but-empty/whitespace-only. `verify.md:60-63` records all cases plus `10-readiness,nope`. `--selftest` assertions 2-4 pin them (`mutation.sh:628-654`). |
| AC4 — Area isolation | met | Selection filters the source list only (`run.sh:101-111`); no partition/reorder. `verify.md:59` records all 13 `tests/checks/*.sh` alone → exit 0, including `87-backtrack-guards` (a sibling-naming area) at 103/0/0. |
| AC5 — Area-scoped mutation | met | `run_area` (`mutation.sh:142-146`) invokes `run.sh` with `FRAMEWORK_TEST_AREAS=$J_AREA` and the force-absent overrides; each `job_<n>` sets exactly one `J_AREA` and `job_finish` (`mutation.sh:219-233`) asserts non-zero exit plus the named token. I re-derived all 27 jobs against the check sources and confirmed every `J_EXPECTED` token is emitted by its mapped area (e.g. `AC10 docs/customization.md is missing` from `50-instructions.sh:104` via `$surf=$CUST`; `AC7 skill routes no spec` from `20-lifecycle.sh:63` via the `no spec -> /spec` route case). |
| AC6 — Cheap restore verification | met | `restore_one`/`restore_verify` (`mutation.sh:148-180`) copy each mutated file back from `$REPO_ROOT` and compare byte-for-byte with `cmp -s` (or `git diff --no-index --quiet`), reporting the unrestored surface; no suite run per mutation. `--selftest` assertion 1 (`mutation.sh:615-626`) corrupts a restore and asserts the report names `example.txt`. |
| AC7 — End-to-end clean runs retained | met | `run_whole_plain`/`run_whole_absent` (`mutation.sh:128-137`) run the whole suite against `$COPY` (staged by `stage_copy`, `mutation.sh:106-122`, with no `work/`) and with `FRAMEWORK_TEST_NO_*`; `FRAMEWORK_TEST_AREAS` is explicitly `unset` in the subshell so an ambient value cannot subset them. `verify.md:89`. |
| AC8 — Mutation sensitivity preserved | met | `JOB_COUNT=27` matches all 27 converted blocks (jobs 1-19 = AC6-AC13/AC18-AC23; jobs 20-27 = the eight AC24 blocks). `verify.md:90` records `MUTATION TOTAL: 27 checked passed, 0 failed`, exit 0, all named. |
| AC9 — Parallel execution with isolation | met | `resolve_workers` (`mutation.sh:186-209`) resolves the count and caps it; `worker_run` (`mutation.sh:736-747`) stages a per-worker copy under `$SCRATCH/w<N>/live` and deals jobs round-robin; results are one file per job (`mutation.sh:742-745`) aggregated in job order after `wait` (`mutation.sh:756-775`). `verify.md:91` records identical named sets for default/`JOBS=1`/`JOBS=4`, a failing-token run at 26/27, and scratch removal. |
| AC10 — Bounded whole-suite executions | met | The only whole-suite runs are the two setup runs; jobs use the subset path, so `whole_runs` is a constant `2` (`mutation.sh:777-780`). `verify.md:92,142-144` records 2 vs ~54 and 29 s vs a reproduced 445 s baseline. |
| AC11 — Mutation policy documented | met | `tests/README.md:217-281` adds Area selection, lazy probes, the parallel execution model, and a Mutation policy (opt-in/not-CI, scheduled/milestone audit, area-scoped norm, one mutation per distinct rule, cap 3) while keeping the Checks table, exit contract, and skip policy. |
| AC12 — Existing contract preserved | met (item tree) | Exit contract and `TOTAL` format unchanged (`run.sh:130-131`); checks never read live `work/**`; `stage_copy` runs with no `work/`. See "Not reviewed" for the in-place environmental caveat. |
| AC13 — Scope | met | `git diff --name-only` is exactly `tests/README.md`, `tests/lib.sh`, `tests/mutation.sh`, `tests/run.sh` (+ `work/…/tasks.md`); no `.github/**`, `docs/**`, `.opencode/**`, root docs/config. No runtime dependency added: `cmp` has a `git diff` fallback (`mutation.sh:148-154`), and CPU detection falls back to `1` (`mutation.sh:202-204`). |

Every spec edge case is addressed in `verify.md:99-113`; I spot-checked the
several-areas/duplicate/order, sibling-naming, one-worker-fails, corrupted-restore,
and concurrent-run cases against the code and found them consistent.

## Findings

### Blockers

- None.

### Major

- None.

### Minor

- **[M1] Hardcoded `JOB_COUNT` can silently drop a future mutation** —
  `tests/mutation.sh:74`, `mutation.sh:741,760,767`.
  The runner iterates `1..JOB_COUNT` and dispatches `job_$n`, but the job
  functions are defined by hand. A maintainer who adds `job_28` without bumping
  `JOB_COUNT` gets no error and no result for it: the new mutation is simply never
  executed, and the pass still reports green. (The reverse mistake — `JOB_COUNT`
  too high — fails loudly with `job_28: command not found` → "produced no result".)
  Recommended fix: after the job definitions, assert that `declare -F job_$((JOB_COUNT+1))`
  is false (and optionally that `job_$JOB_COUNT` is defined), so a forgotten bump
  is a setup error rather than a silent coverage loss.

### Nits

- **[N1] `mpass` can exceed the job count on a restore failure** —
  `tests/mutation.sh:767-775`. `job_finish` writes an `ok` line when a mutation is
  caught and, if the restore then fails, an additional `FAIL` line from
  `restore_one`. The aggregation counts both, so `MUTATION TOTAL` can print
  "28 checked" for 27 jobs. Exit status is still correct (`mfail > 0`); only the
  printed count is misleading. Consider one result line per job or a distinct
  restore-failure tally.
- **[N2] `whole_runs` is printed but not asserted** — `tests/mutation.sh:777-780`.
  The AC10 bound is structural, but a future edit that adds a whole-suite call
  would not fail. A `[ "$whole_runs" -eq 2 ]` guard (or a stated `-le` bound)
  would keep the invariant honest. Not required by the spec.
- **[N3] `--selftest` is not hermetic** — `tests/mutation.sh:656-663`. The
  "successful subset" assertion runs `run.sh` against the live `$REPO_ROOT`, so
  `--selftest` fails if `10-readiness` is red for any unrelated reason in the
  maintainer's tree (as appears to be the case with the foreign directory below).
  Running it against a small staged copy would decouple the self-test from the
  working tree.
- **[N4] Dead local `wpids`** — `tests/mutation.sh:751-755`. The PIDs are
  collected but never used (`wait` with no arguments joins all workers). Harmless;
  remove or use it to report failed workers.

## Not reviewed

- **UI / `visual.md`.** Not applicable — this item changes test-harness shell
  scripts and documentation only, with no user-facing surface.
- **`tests/checks/**` and `tests/fixtures/**`.** Deliberately unchanged; the
  mutation inventory is consumed, not edited (verified via `git diff --name-only`).
- **Environmental caveat (not this item's artifact).** An untracked
  `recursive-specification/` clone (separate `.git`) sits at the repository root,
  so an **in-place** `bash tests/run.sh` fails the pre-existing `90-packaging.sh`
  AC20 root-entry agreement (`AC20 root entry(ies) undocumented in README
  Layout`). It is outside the diff and this item's surface; `verify.md:27-42,50`
  records that the item's tree is green on a staged clean copy
  (`TOTAL: 448 passed, 0 failed, 0 skipped`). It is surfaced for the user because
  the shipper's pre-ship/integrity pass runs the configured test command on the
  working tree and will trip on it until the foreign directory is removed (or the
  suite is invoked against a clean copy).
- **Bash 3.2 execution.** No 3.2 binary is available to this review; the changed
  files use only 3.2-safe constructs (indexed arrays, C-style `for`, guarded
  empty-array expansions, no `declare -A`/`mapfile`), which matches the item's
  recorded static scan (`verify.md:113`).
