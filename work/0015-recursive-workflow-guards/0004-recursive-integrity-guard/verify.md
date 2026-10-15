---
feature: 0015-recursive-workflow-guards/0004-recursive-integrity-guard
phase: test
status: final
created: 2026-10-14
updated: 2026-10-14
parent: 0015-recursive-workflow-guards
notes: "Fresh verification pass after the /plan revision (backtracks.md Resolution 2) renamed the area to tests/checks/91-integrity-guard.sh and re-opened T4-T7/T9. No challenges.md exists for this item, so no adjudication was pending. The prior verify.md was stale (stale: design); this pass re-runs everything against the renamed area and independently reproduces the sensitivity battery. No production code was modified and no test was weakened, skipped, or deleted."
---

# Verification — Committed recursive merge-integrity and renumber guards

## Commands run

All commands run from the repository root. Scratch copies live under the
git-ignored `scratch/` and were removed afterwards. The working tree is the
uncommitted implementation on the plan branch; `HEAD` is the plan commit and is
an ancestor of `origin/main`.

| Command | Result | Notes |
| ------- | ------ | ----- |
| `bash tests/run.sh` | PASS | 576 passed, 0 failed, 0 skipped (exit 0) |
| `FRAMEWORK_TEST_AREAS=91-integrity-guard bash tests/run.sh` | PASS | 73 passed, 0 failed, 0 skipped (exit 0) |
| `FRAMEWORK_TEST_AREAS=80-cycle-fixture bash tests/run.sh` | PASS | 18 passed, 0 failed, 0 skipped (exit 0) |
| `bash tests/mutation.sh` | PASS | 30 mutations caught and named, 0 failed; clean-copy run 574 pass / 0 fail / 2 skip; exit 0 |
| full suite against a no-`work/` copy (`bash <copy>/tests/run.sh <copy>`) | PASS | 576 passed, 0 failed, 0 skipped — fresh-clone safety |
| merged-state sim (`git archive origin/main` + this item's files → suite) | PASS | 727 passed, 0 failed, 0 skipped (exit 0) |
| merged-state selectors `89`, `91`, `81` | PASS | each resolves uniquely (66 / 73 / 37 assertions, exit 0); no `89-` collision |
| `grep -rF '89-integrity-guard' tests/` | PASS | no output (exit 1) — rename sweep complete |
| `git diff --name-only` / `git status --porcelain` | PASS | only `tests/**` plus this work item (scope, AC12) |
| independent mutation battery (below) | PASS | 18/18 planted regressions failed the area and named the expected `AC30 <sub-area>` |

The `91-` area emits 73 assertions across all nine declared sub-areas
(`per-node-eval`, `structural-graph`, `spelling-drift`, `report-only`,
`renumber-sweep`, `fixture-existence`, `read-only-contract`, `mutation-staging`,
`no-duplication`); every emitted line carries the `AC30` token.

## Acceptance coverage

| Criterion | Test(s) | Result |
| --------- | ------- | ------ |
| AC1 — fixture-based, fresh-clone safe, fails not skips on a missing fixture | `AC30 fixture-existence` (tree + 14 required files); `AC30 read-only-contract` (no live `work/` path, no executable file, no committed checker, no `.opencode` reference); full suite against a no-`work/` copy. Sensitivity: removing a required fixture → `FAIL AC30 fixture-existence` (exit 1, not skip) | PASS |
| AC2 — independent per-node evaluation; depth-3 fault caught and attributed | `AC30 per-node-eval` expected block; `AC30 per-node-eval: the depth-three collision is attributed to 9211-deep/0001-mid`. Sensitivity: removing the intermediate manifest breaks recursion → block diverges; adding a third same-prefix top-level node diverges the block | PASS |
| AC3 — structural graph faults + deliberate withdrawal report-only | `AC30 structural-graph` expected block (`DANGLING-DEP`, `MISSING-CHILD`, `UNLISTED-CHILD`); `AC30 structural-graph: the recorded deliberate withdrawal yields no UNLISTED-CHILD fault`. Sensitivity: deleting the unlisted dir, or adding an unrecorded stray child dir, diverges the block | PASS |
| AC4 — manifest-spelling drift; modern spelling authoritative; no drop/merge/repair | `AC30 spelling-drift` expected block (`9203-spelling-both`, `9204-phase-mismatch`); `AC30 spelling-drift: the modern manifest is authoritative over the deprecated alias`; `AC30 spelling-drift: both spellings are retained, never dropped or auto-repaired`; `FRAMEWORK_TEST_AREAS=80-cycle-fixture` green. Sensitivity: dropping the alias or fixing the phase mismatch diverges the block; flipping the resolver to prefer the alias fails the authority assertion | PASS |
| AC5 — report-only, non-fatal, never-truncated, no-file-modified contract; clean tree empty | `AC30 report-only`: authority pins (`**non-fatal**`, `**never silently dropped**`, `**never truncated**`, `**not auto-repaired**`, `**modifies no file**`, `report **no findings**`, `**does not error**`), skill pins (`**report-only**`, `the list is never truncated`, `**modifies no file**`, `it never auto-repairs a violation`), and the clean `9201-clean` node yields empty findings. Sensitivity: removing an authority/skill literal fails the pin | PASS |
| AC6 — sibling-owned invariants referenced, not re-pinned | `AC30 no-duplication`: header references to `10-readiness`, `20-lifecycle`, `80-cycle-fixture`, `85-conflict-guards`, `87-backtrack-guards`, `88-renumber-sweep`, `90-packaging`, `96-signature-sweep`, `0001-recursive-structure-guard`; 9 forbidden-literal scans. Sensitivity: removing a header reference or appending an owned literal fails the assertion | PASS |
| AC7 — completed whole-subtree renumber leaves no stale reference | `AC30 renumber-sweep` presence assertions in all nine rewrite positions (directory, `feature:`, `parent:`, owning manifest `Local id`/`Canonical reference`, intermediate manifest `Canonical reference`, `Depends on`, `conflicts-with`, ship/handoff branch) plus the recursive old-reference absence scans. Sensitivity: reintroducing the old canonical ref into any fixture file fails the scan | PASS |
| AC8 — renumber assertion is sensitive | scratch-only: reintroducing `9220-renamed-parent/0001-old` into one fixture file made the area exit 1 naming `AC30 renumber-sweep`. No committed test pins this in this item — the registered mutation job is `0005`'s (design test-strategy row; spec AC10). See residual risk | MANUAL (scratch-verified) |
| AC9 — recursive renumber contract pins (intermediate manifest + reference-not-restate) | `AC30 renumber-sweep: authority names the intermediate manifest on the changed path`; `AC30 renumber-sweep: skill names the intermediate manifest on the changed path`; the `88-renumber-sweep` closing literal is *not* restated (`no-duplication` forbids it). Sensitivity: breaking the intermediate-manifest phrase on either surface fails the pin | PASS |
| AC10 — stable token, named sub-areas, mutation staging | every emitted assertion is `AC30 <sub-area>`; all nine declared sub-areas appear; `AC30 mutation-staging: tests/mutation.sh stages tests/fixtures/recursive-integrity`. Sensitivity: de-staging the line fails the assertion | PASS |
| AC11 — no duplication; existing areas stay green | `bash tests/run.sh` green (576 pass); `AC30 no-duplication`; `FRAMEWORK_TEST_AREAS=80-cycle-fixture` green (18 pass); merged-state simulation green (727 pass); a third stray `roadmap.md` still fails the relaxed `AC13` guard. Sensitivity: header/forbidden-literal mutations caught | PASS |
| AC12 — scope and purity | manual: `git status --porcelain` shows only `tests/checks/80-cycle-fixture.sh`, `tests/mutation.sh`, `tests/checks/91-integrity-guard.sh`, `tests/fixtures/recursive-integrity/**` (all `tests/**`) plus `work/.../tasks.md` and the item's `backtracks.md`/`verify.md`/`review.md`. No live doc, prompt, command, agent, skill, `phase` value, state file, or production checker added; no new dependency, network, or `gh` call; the check has no shell `exit`, no file-writing redirection, no `curl`/`wget`/`gh`/`git`, and no `mapfile`/associative arrays | MANUAL (inspection) |

### Independent mutation battery (staged under `scratch/`, each on a fresh copy)

| # | Planted regression | Area | Expected / observed |
| - | ------------------ | ---- | ------------------- |
| M1 | remove `9211-deep/0001-mid/manifest.md` (breaks recursion) | 91 | `AC30 per-node-eval` FAIL, exit 1 |
| M2 | delete `9202-graph-faults/0005-unlisted` | 91 | `AC30 structural-graph` FAIL |
| M3 | add an unrecorded stray child dir `9202-graph-faults/0006-stray` | 91 | `AC30 structural-graph` FAIL |
| M4 | remove `9203-spelling-both/roadmap.md` | 91 | `AC30 spelling-drift` FAIL |
| M5 | fix `9204-phase-mismatch` (`phase: roadmap` → `manifest`) | 91 | `AC30 spelling-drift` FAIL |
| M6 | flip the area's resolver to prefer the alias | 91 | `AC30 spelling-drift` (authority) FAIL |
| M7 | remove a required fixture (`0003-follower/ship.md`) | 91 | `AC30 fixture-existence` FAIL (not skip) |
| M8 | reintroduce old canonical ref `9220-renamed-parent/0001-old` | 91 | `AC30 renumber-sweep` FAIL |
| M9 | add a third same-prefix top-level node `9210-dup-c` | 91 | `AC30 per-node-eval` FAIL |
| M10 | remove the `88-renumber-sweep` header reference | 91 | `AC30 no-duplication` FAIL |
| M11 | remove the `0001-recursive-structure-guard` header reference | 91 | `AC30 no-duplication` FAIL |
| M12 | append the `88`-owned closing literal | 91 | `AC30 no-duplication` FAIL |
| M13 | de-stage `recursive-integrity` from `tests/mutation.sh` | 91 | `AC30 mutation-staging` FAIL |
| M14 | add a live `work/` path to a fixture file | 91 | `AC30 read-only-contract` FAIL |
| M15 | `chmod +x` the check file | 91 | `AC30 read-only-contract` FAIL |
| M16 | break the authority's intermediate-manifest phrase | 91 | `AC30 renumber-sweep` FAIL |
| M17 | break the skill's intermediate-manifest phrase | 91 | `AC30 renumber-sweep` FAIL |
| M18 | add a third stray `roadmap.md` under `tests/fixtures/` | 80 | `AC13 unexpected roadmap.md fixture set` FAIL |

Every mutation failed the suite (exit 1) and named the expected sub-area/token,
so the assertions are sensitive rather than vacuous.

## Gaps and residual risk

- **AC8 committed sensitivity is deferred to `0005`.** The design's test-strategy
  row routes the registered renumber mutation job to
  `0005-guard-registration-sweep`, and this item's non-goals defer the mutation
  jobs. The assertion's sensitivity was confirmed in a scratch copy only (M8);
  no committed test in this item's own area fails on a reintroduced old reference
  when run as the default suite. This is a documented residual, not a defect.
- **Bash 3.2 compatibility is static.** The host shell is GNU bash 5.2; the area
  contains no associative arrays, `mapfile`/`readarray`, or empty-array expansion
  under `set -u`, matching the harness constraint, but was not executed under a
  true 3.2.
- **`read-only`/`no-network` are structural, not sandbox-intercepted.** They are
  asserted by inspection (no file writes, no `curl`/`wget`/`gh`/`git`, no shell
  `exit`, no exec bit, no writing redirection) and by a fresh-clone run; no
  syscall sandbox was used.
- **Graph faults and drift are planted only on top-level nodes.** The recursive
  per-node evaluation is proven by the depth-three `DUPLICATE-CHILD` (AC2) and by
  the intermediate manifest on the renumber path (AC7/AC9), but no *nested* node
  carries a `MISSING-CHILD`/`UNLISTED-CHILD`/`DANGLING-DEP`/`DRIFT-FACT` fault, so
  an evaluation that flattened only those arms to the top level would not be
  caught by the committed fixture. AC2's stated observable (the deepest-level
  fault caught and named) and AC3's stated sample (a decomposing node, not
  necessarily nested) are both met; this is noted as a follow-up suggestion, not
  a defect against the acceptance criteria.
- **`DANGLING-DEP` predicate covers the "no row" half only.** The authority
  (`.opencode/skill/merge-conflict/SKILL.md:121`) defines `DANGLING-DEP` as "a
  local id with no child directory **or** no table row"; the area's predicate
  tests only the row half. AC3 words its sample as a `Depends on` that "names no
  row and no directory" (`0099-ghost`), which is exercised. The "row present,
  directory absent" arm is unexercised — recorded as a residual, matching the
  review's non-blocking question.
- **Reverse phase-mismatch arm unexercised.** `9204-phase-mismatch` exercises
  `manifest.md` + `phase: roadmap`; the reverse (`roadmap.md` +
  `phase: manifest`) is coded in the guard (`91-integrity-guard.sh:197`) but not
  fixture-exercised. AC4 requires only that "the manifest spelling disagrees with
  its declared `phase` value" be detected, which is covered.
- **Withdrawal record shape diverges from the template.** The fixture records the
  withdrawal as `9202-graph-faults/0004-withdrawn/` rather than the template's
  `work/<parent>/<MMMM-slug>/`, because the area's `read-only-contract` forbids
  the literal `work/` in the fixture root. Recognition is a substring match and
  works on the real `work/<parent>/<child>/` shape; AC3 does not mandate the
  prefix. Recorded as a residual (also the review's second non-blocking
  question).
- **Branch is behind `origin/main`.** HEAD is the plan commit; `origin/main` has
  advanced with the sibling guards. The merged-state simulation
  (`origin/main` + this item's files, with both `tests/mutation.sh` staged-copy
  lines kept) runs green (727 pass, 0 fail), and the `89`/`91`/`81` selectors
  each resolve uniquely once merged. The `tests/mutation.sh` staged-copy additions
  from this item and the sibling `0001` are the declared class-(a) shared-surface
  conflict the shipper reconciles; the correct merged form was simulated.
- **Manual/LLM-run residuals (not faked by static assertions).** A live `/status`
  render, a real `/ship` reconcile/post-merge integrity pass, an actual `git mv`,
  and the renumber no-op case require running a phase and remain documented manual
  residuals, consistent with the cycle/conflict/backtrack guard areas.
- **No test was weakened, skipped, or deleted to obtain a pass.** The only suite
  edit besides the new area is the design-sanctioned narrowing of
  `tests/checks/80-cycle-fixture.sh`'s AC13 whole-set assertion, which still fails
  on any third/stray alias (M18).

## Not covered / out of scope

- The `tests/README.md` Checks row/mapping paragraph and the per-rule mutation
  jobs are `0005-guard-registration-sweep`'s responsibility by design and are not
  asserted here.
- No challenges were pending: `challenges.md` does not exist for this item.
