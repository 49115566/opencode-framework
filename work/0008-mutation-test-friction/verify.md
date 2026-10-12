---
feature: 0008-mutation-test-friction
phase: test
status: final
created: 2026-10-12
updated: 2026-10-12
---

# Verification — Reduce mutation-test harness friction

## Summary

All thirteen acceptance criteria and every spec edge case pass on this item's
tree. The prior `verify.md` (untracked, `status: blocked`) reported defect **D1**
— two concurrent `tests/mutation.sh` passes collided on a fixed
`scratch/framework-mutation` root. The current implementation derives a
per-invocation (`$$`-suffixed) scratch root and pins it with `--selftest`
assertion 6; this phase re-ran the D1 reproduction directly and **both
overlapping passes now exit `0` with 27/27 caught and no residue**. D1 is closed.
No open defects, no `challenges.md`, no `backtracks.md`. No test was weakened,
skipped, or deleted.

The canonical full run is byte-identical to the pre-change harness, the mutation
pass runs a constant **2** whole-suite executions (down from ~54), and wall time
falls from a reproduced baseline of **445 s** to **29 s**.

**Environmental interference (not an item defect).** Mid-session an unrelated
untracked clone `recursive-specification/` appeared at the repository root
(created 14:48, separate `.git`, remote
`git@github.com:49115566/opencode-framework.git`). The pre-existing check
`90-packaging.sh` `AC20` enumerates *every* non-hidden root entry and requires the
`README.md` `## Layout` block to document it, so that foreign directory now trips
one assertion (`AC20 root entry(ies) undocumented in README Layout:
recursive-specification`) when the suite is run **in place**. It is not caused by
this item: `tests/checks/90-packaging.sh` and the `README.md` Layout block are
outside the item's change surface (`tests/run.sh`, `tests/lib.sh`,
`tests/mutation.sh`, `tests/README.md` only), and the suite is green on the item's
tree — both before the directory appeared (448/0/0 in place) and on a staged clean
copy that excludes the foreign directory (`bash tests/run.sh <clean-copy>` →
`TOTAL: 448 passed, 0 failed, 0 skipped`, exit 0). The directory was left
untouched (not this phase's artifact, and deleting it would be a destructive
action on unknown concurrent work); it is flagged for the user.

## Commands run

| Command | Result | Notes |
| ------- | ------ | ----- |
| `bash tests/run.sh` | PASS (448 passed, 0 failed, 0 skipped, exit 0) | Full canonical suite; green in place before the foreign `recursive-specification/` directory appeared. |
| `bash tests/run.sh` (in place, after 14:48) | FAIL (447/1/0, exit 1) | Sole failure `AC20 root entry(ies) undocumented in README Layout: recursive-specification` — caused by the unrelated untracked clone (see Summary), not this item. |
| `bash tests/run.sh /tmp/opencode/clean-copy` (item tree, no foreign dir) | PASS (448/0/0, exit 0) | Confirms the item's tree is green; the in-place failure is purely the foreign root entry. |
| `bash /tmp/opencode/head-tests/run.sh "$PWD"` (HEAD `tests/run.sh`+`lib.sh`, current checks) | PASS (448/0/0, exit 0) | Pre-change harness. |
| `diff head-full.log new-full.log` | PASS | **Byte-identical** full-run output. |
| `FRAMEWORK_TEST_AREAS=10-readiness bash tests/run.sh` | PASS (8/0/0, exit 0) | Only `10-readiness` sourced. |
| `FRAMEWORK_TEST_AREAS=10-readiness bash tests/run.sh <mutated-copy>` | EXPECTED FAIL (exit 1, `TOTAL: 7 passed, 1 failed`) | `FAIL AC6 README.md contradicts ...`; 0 `AC7`/`AC8` lines → no unselected area reported. |
| `FRAMEWORK_TEST_AREAS='10-readiness,20-lifecycle' bash tests/run.sh` | PASS (72/0/0, exit 0) | Aggregate. |
| `FRAMEWORK_TEST_AREAS='10,10-readiness'` / `'1,10-readiness'` | PASS (8/0/0 each) | Duplicate/overlapping selector counted once. |
| `FRAMEWORK_TEST_AREAS='20-lifecycle,10-readiness'` (log order) | PASS | `10-readiness` (`AC6`) lines source before `20-lifecycle` (`AC7`): filename order preserved. |
| `FRAMEWORK_TEST_AREAS=<all 13 areas>` | PASS (448/0/0) | Selecting every area == full run. |
| `for f in tests/checks/*.sh; FRAMEWORK_TEST_AREAS=<stem> bash tests/run.sh` | PASS (13/13, exit 0 each, 0 `FAIL`) | Per-area isolation; counts 8/64/15/41/6/6/7/15/43/103/22/28/90. |
| `FRAMEWORK_TEST_AREAS=nope` | EXPECTED FAIL (exit 2, `setup error: unknown area selector 'nope'`) | No check sourced. |
| `FRAMEWORK_TEST_AREAS=8` | EXPECTED FAIL (exit 2, `ambiguous area selector '8' matches: 80-cycle-fixture 85-conflict-guards 87-backtrack-guards`) | Names candidates. |
| `FRAMEWORK_TEST_AREAS=` / `'   '` | EXPECTED FAIL (exit 2, `... names no area (empty selection)`) | No silent full-run fallback. |
| `FRAMEWORK_TEST_AREAS='10-readiness,nope'` | EXPECTED FAIL (exit 2, names `nope`) | Valid+unknown mix still errors. |
| `FRAMEWORK_TEST_AREAS=10-readiness bash -x tests/run.sh \| grep -c probe_(npm\|net\|opencode)` | PASS (0 calls) | Lazy probes: subset probes nothing extra. |
| `bash -x tests/run.sh \| grep -c probe_(npm\|net\|opencode)` | PASS (4 calls) | Full run probes what its areas use. |
| `FRAMEWORK_TEST_NO_PY=1 FRAMEWORK_TEST_NO_OPENCODE=1 FRAMEWORK_TEST_NO_NPM=1 bash tests/run.sh` | PASS (446/0/2, exit 0) | Force-absent overrides preserved; 2 visible skips. |
| `FRAMEWORK_TEST_AREAS=60-default-agent` present vs `NO_OPENCODE=1` | PASS (6/0/0 vs 5/0/1) | Skip parity. |
| `FRAMEWORK_TEST_AREAS=70-pin` present vs `NO_NPM=1` | PASS (7/0/0 vs 6/0/1) | Skip parity. |
| `bash tests/mutation.sh --selftest` | PASS (6 passed, 0 failed, exit 0) | Corrupted restore + 3 selector errors + subset + **D1 pid-root assertion**. |
| `bash tests/mutation.sh` (default, 20 workers) | PASS (exit 0, 27 caught, 0 failed, whole-suite runs 2, **29 s**) | |
| `FRAMEWORK_MUTATION_JOBS=1 bash tests/mutation.sh` | PASS (exit 0, 27 caught, **55 s**) | Serial; identical named set. |
| `FRAMEWORK_MUTATION_JOBS=4 bash tests/mutation.sh` | PASS (exit 0, 27 caught, **40 s**) | Identical named set. |
| `diff` of sorted named-mutation sets (default/1/4) | PASS | 27/27 each, identical. |
| Two overlapping `bash tests/mutation.sh` (D1 repro) | PASS (both exit 0, 27/27 each, 2 whole-suite runs each, no residue) | D1 fixed. |
| `tests/.tmp-bad-mutation.sh` (one wrong expected token; temp, removed) | EXPECTED FAIL (exit 1, `MUTATION TOTAL: 26 checked passed, 1 failed`) | One job's failure does not abort the other 26. |
| `bash scratch/head-mut/mutation.sh` (HEAD pre-change harness) | PASS (exit 0, `MUTATION TOTAL: 57`, **ELAPSED:445 s**) | Independently reproduced baseline. |
| `git status --porcelain` | Only `tests/{README,lib,run,mutation}` + `work/0008-.../tasks.md` (+ this untracked `verify.md`) | Read-only: no repository mutation, no `work/**` written. (`recursive-specification/` is the unrelated foreign clone, see Summary.) |

## Acceptance coverage

| Criterion | Test(s) | Result |
| --------- | ------- | ------ |
| AC1 — Subset execution | `FRAMEWORK_TEST_AREAS=10-readiness` (8/0/0); mutated-copy subset (exit 1, `7 passed, 1 failed`, `FAIL AC6 …`, no `AC7`/`AC8`); multi/duplicate/order/all-areas runs | PASS |
| AC2 — Full run unchanged | `diff` of current full output vs HEAD harness output → byte-identical; 448/0/0 both; unset var is full run (green on the item's tree; the in-place `AC20` failure is the foreign dir, not this item) | PASS |
| AC3 — Selection errors | `nope`, `8` (names candidates), empty, whitespace-only, `10-readiness,nope` → all exit 2, name the offender, source nothing, no fallback; `--selftest` asserts unknown/ambiguous/empty | PASS |
| AC4 — Area isolation | All 13 `tests/checks/*.sh` selected alone → exit 0, no `FAIL`; `87-backtrack-guards` alone (103/0/0) exercises the sibling-naming edge | PASS |
| AC5 — Area-scoped mutation | 27 jobs each invoke `run_area` with a single `FRAMEWORK_TEST_AREAS=$J_AREA`; replicated job_2 (only `20-lifecycle`, 0 leaked `AC6`/`AC23`/`AC24`) and job_15 (only `85-conflict-guards`, 0 leaked `AC24`/`AC7`) | PASS |
| AC6 — Cheap restore verification | `--selftest` corrupted restore reported naming `example.txt`; every full-pass restore verified by `cmp -s` with no suite run; whole-suite count 2 | PASS |
| AC7 — End-to-end clean runs retained | Setup log: `TOTAL: 448…` + `ok clean copy (no work/) passes`; `TOTAL: 446…` + `ok clean copy passes with optional tools absent` + visible-skips assertion; ambient `FRAMEWORK_TEST_AREAS` cannot subset them (`unset` in subshell) | PASS |
| AC8 — Mutation sensitivity preserved | Full pass exit 0, `MUTATION TOTAL: 27 checked passed, 0 failed`, all 27 named | PASS |
| AC9 — Parallel execution with isolation | Default/`JOBS=1`/`JOBS=4` exit 0 with identical 27-mutation sets; concurrent passes isolated; scratch removed after each incl. the failing run; bad-token run exit 1 with 26/27 passing | PASS |
| AC10 — Bounded whole-suite executions | Setup log `whole-suite runs: 2` regardless of 27 jobs (vs ~54 pre-change); wall time 29 s vs independently measured baseline 445 s (builder `scratch/0008-baseline.log` 438 s) ≈ 15× | PASS |
| AC11 — Mutation policy documented | `tests/README.md`: opt-in/not-CI (l.269–277), scheduled/milestone audit, area-scoped norm, one mutation per distinct rule + normative cap 3; new Area-selection/Parallelism sections added; existing Checks/Exit-contract/Skip-policy sections retained | PASS |
| AC12 — Existing contract preserved | Full suite exit 0 on the item's tree (clean copy 448/0/0); `git status` unchanged by the harness (read-only); subset probes 0 optional tools (provider-neutral); no-`work/` copy passes (fresh-clone); exit 0/1/2 exercised; checks never read live `work/**` | PASS |
| AC13 — Scope | `git diff --name-only` = `tests/README.md`, `tests/lib.sh`, `tests/mutation.sh`, `tests/run.sh` (+ `work/.../tasks.md`); no `.github/**`, `docs/**`, `.opencode/**`, root docs, or config; no new runtime dependency (`cmp` has a `git diff --no-index` fallback; CPU detection falls back to 1) | PASS |

## Edge-case coverage

| Edge case | Evidence | Result |
| --------- | -------- | ------ |
| Several areas at once | `10-readiness,20-lifecycle` → 72/0/0; `20-lifecycle,10-readiness` runs `10-readiness` first (filename order) | PASS |
| Duplicate / overlapping selection | `10,10-readiness`, `1,10-readiness` → 8/0/0 | PASS |
| Area references a sibling area by name | `87-backtrack-guards` alone → 103/0/0 | PASS |
| Concurrent workers and scratch isolation | Per-worker `scratch/framework-mutation.<pid>/w<N>/live`; jobs/`JOBS` runs exit 0; scratch removed incl. on failure | PASS |
| One worker fails, others succeed | Temp wrong-token run → exit 1, 26/27 pass, no abort, scratch removed | PASS |
| Restore wrong or partial | `--selftest` corrupted restore reported naming the surface | PASS |
| Optional tool present vs. forced absent | `60-default-agent`/`70-pin` present pass; forced-absent skip; full forced-absent 446/0/2 | PASS |
| Network unreachable but `npm` present | Not injected (no network-fault hook). `probe_net` only sets `have_net=0` on failure and the dependent area already `skip`s; path unchanged | MANUAL |
| No `work/` directory present | Setup clean copy has no `work/`; passes 448 then 446 | PASS |
| Very small mutation set / all areas selected | All 13 areas = 448/0/0 == full run | PASS |
| Repeated runs (sequential) | Full suite and mutation pass repeated many times; identical results, no residue | PASS |
| Concurrent runs of the pass | Two overlapping passes → both exit 0, 27/27, no collision (D1 fixed) | PASS |
| Bash 3.2 / minimal environment | No bash 3.2 binary available. Static scan of changed files: no `declare -A`, `mapfile`, `readarray`, `&>>`; `local -a` and empty-array expansions are guarded (`[ "${#arr[@]}" -gt 0 ]`, `${arr[@]+"${arr[@]}"}`); uses only bash+git+POSIX (`cmp`/`awk`/`sed`/`grep`/`cp`, `git` fallback) | MANUAL |

## Defects

None open. **D1** (recorded by the prior `verify.md`) is **resolved**: the scratch
root is now `scratch/framework-mutation.$$` and the direct concurrency
reproduction yields two green passes with no residue. `--selftest` assertion 6
pins the per-invocation root as a regression guard.

## Gaps and residual risk

- **Bash 3.2 compatibility is not executable here** (no 3.2 binary). Static scan
  shows only 3.2-safe constructs and guarded empty-array expansions; residual
  risk low but unexercised.
- **Network-fault path** (`npm` present, registry unreachable) was not injected.
  The code path is unchanged in effect (`have_net=0` → dependent area `skip`s)
  and the forced-absent run covers the skip branch.
- **AC5 per-job log capture**: the 27 jobs' logs are removed with the scratch
  subtree, so "unaffected areas not executed" is proven structurally (single
  `FRAMEWORK_TEST_AREAS=$J_AREA` per job) plus two replicated jobs (lifecycle,
  conflict-guards) showing zero cross-area tokens — not by retaining all 27 logs.
- **Committed harness regression tests are opt-in, by design.** The spec's
  non-goals forbid adding an agreement area/check file, so the only committed
  harness test surface is `tests/mutation.sh --selftest` (not run by CI, which
  runs only `bash tests/run.sh`). The new `FRAMEWORK_TEST_AREAS` behavior is
  therefore exercised by `--selftest` (selector errors, successful subset) and by
  this `verify.md`'s recorded integration commands, not by the CI-run canonical
  suite. This is a deliberate consequence of the spec's mutation-out-of-CI policy,
  not an oversight.
- **Timing evidence**: default 29 s (20 workers), `JOBS=1` 55 s, `JOBS=4` 40 s vs
  baseline 445 s (this phase, HEAD harness) and 438 s (builder
  `scratch/0008-baseline.log`); whole-suite executions 2 vs ~54.
- **Unrelated working-tree observation (escalated).** An untracked
  `recursive-specification/` clone (separate `.git`, remote
  `git@github.com:49115566/opencode-framework.git`) appeared at the repository
  root mid-session at 14:48. It breaks the pre-existing `AC20` root-entry
  agreement check when the suite runs in place (it is an undocumented
  non-hidden root entry). It is not this item's artifact and this phase did not
  create or modify it; deleting it would be a destructive action on unknown
  concurrent work, so it was left untouched and is flagged for the user. The
  item's tree is green on a staged clean copy. Follow-up suggestion (outside this
  item's scope): `AC20` could ignore untracked/git-ignored root directories so a
  stray local clone cannot fail the canonical suite.
- No test was weakened, skipped, or deleted. No test file was added or changed by
  this phase.
