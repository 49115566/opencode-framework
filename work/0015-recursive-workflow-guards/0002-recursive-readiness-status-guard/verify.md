---
feature: 0015-recursive-workflow-guards/0002-recursive-readiness-status-guard
phase: test
status: final
created: 2026-10-14
updated: 2026-10-14
parent: 0015-recursive-workflow-guards
---

# Verification — Recursive readiness and `/status` guard

## Summary

This item *is* a committed agreement area: `tests/checks/89-recursive-status-guards.sh`
(suite token `AC27`, 686 lines) over a new fixture root
`tests/fixtures/recursive-status/items/` (6 manifests, 70 files, depth 3). All
eight tasks (`T1`–`T8`) are checked. The area is sourced by `tests/run.sh` and
contributes 66 assertions to a full-suite total of **569 passed, 0 failed, 0
skipped**.

Verification re-derived every expected block by hand from
`docs/workflow.md` → "Dependencies and readiness" and "Derived state", then
confirmed the guard is mutation-sensitive by editing a scratch copy of the
fixture and the pinned authority and observing the intended `FAIL`. No
implementation or spec/design defect was found; two speculative points are
recorded as residual risk and one coverage gap versus a spec edge-case bullet
(not an acceptance criterion) is noted.

## Commands run

| Command | Result | Notes |
| ------- | ------ | ----- |
| `bash tests/run.sh` | PASS | `TOTAL: 569 passed, 0 failed, 0 skipped`; exit 0 |
| `FRAMEWORK_TEST_AREAS=89-recursive-status-guards bash tests/run.sh` | PASS | `TOTAL: 66 passed, 0 failed, 0 skipped`; exit 0 |
| `bash tests/mutation.sh --selftest` | PASS | `SELFTEST: 6 passed, 0 failed`; exit 0 |
| `git status --porcelain` | PASS | only `tests/checks/89-recursive-status-guards.sh`, `tests/fixtures/recursive-status/`, and the checked-off `tasks.md`; no production surface |
| `grep -rn 'work/' tests/fixtures/recursive-status/` | none | fixture references no live `work/` path |
| mutation probes (below, on a scratch copy) | PASS | every probe produced the intended `FAIL`, no `skip` |

### Mutation probes (scratch copy at `/tmp/opencode/rs-mut`, `FRAMEWORK_TEST_AREAS=89-recursive-status-guards bash tests/run.sh "$M"`)

| Mutation | Observed result |
| -------- | --------------- |
| delete `9200-tree/0001-hybrid/0001-empty-leaf/` (flatten a level) | 4 FAIL: `fixture-existence`, `nested-readiness` (depth), `derived-phase` (block + `.gitkeep` line); no skip |
| remove `stale: design` from `0013-stale-hybrid/spec.md` (mis-derive) | 3 FAIL: `derived-phase`, `overlay-precedence`, `decomposing-summary` |
| flip `0004-rejected/review.md` to `approve` (readiness) | 4 FAIL: `recursive-readiness`, `dependency-satisfaction`, `derived-phase`, `decomposing-summary` |
| break the cycle (`0004-cyclic-b` `Depends on`) | 5 FAIL incl. `cycle-readiness` "a cycle member was reported ready" |
| remove `0006-precedence/ship.md` (precedence) | 4 FAIL: readiness/dependency/derived/summary |
| delete the whole fixture root | 32 FAIL incl. `fixture-existence`; **0 skipped** |
| add `work/0001-something` reference to a fixture | 1 FAIL: `read-only-contract` |
| add a nested `work/` directory to the fixture | 1 FAIL: `read-only-contract` |
| add `/home/someone/secret` to a fixture | 1 FAIL: `read-only-contract` |
| strip `<ready>/<total> ready` from the 3 pinned surfaces | 3 FAIL: `status-render` |
| strip `<phase> <n>, ...` from `docs/workflow.md` | 1 FAIL: `status-render` |

## Acceptance coverage

| Criterion | Test(s) | Result |
| --------- | ------- | ------ |
| AC1 depth ≥ 3, hybrid, `.gitkeep`-only | `89::fixture-existence` (tree + designated files), `89::nested-readiness` (depth-3 dir), `89::derived-phase` (`9200-tree/0001-hybrid\|design`, `.../0001-empty-leaf\|not started`) | PASS |
| AC2 per-level readiness incl. depth ≥ 3 | `89::recursive-readiness` (root's 15 rows), `89::nested-readiness` (hybrid's 4 rows) | PASS |
| AC3 four dependency-satisfaction cases | `89::dependency-satisfaction` (`0008-dependent\|blocked: 0004-rejected, 0005-noreview, 0007-recalled`) | PASS |
| AC4 recalled dependency blocks dependent | `89::dependency-satisfaction`, `89::overlay-precedence` (`0007-recalled` / `9201-decoy/0002-shipped` recalled) | PASS |
| AC5 `ship.md` presence precedence | `89::dependency-satisfaction` (`0006-precedence` omitted from `0008`'s blocked set), `89::derived-phase` (`shipped`) | PASS |
| AC6 decomposing target own-signal-only; sibling-only | `89::decomposing-target` (`0010` ready vs `0012` blocked despite shipped descendant; `9201-decoy` decoy) | PASS |
| AC7 cycle member never ready | `89::cycle-readiness` (both members blocked; no cycle member `ready`) | PASS |
| AC8 deterministic; no stored readiness | `89::determinism` (two snapshots identical), `89::no-stored-readiness` (canonical six-column header on all 6 manifests) | PASS |
| AC9 hybrid own-phase before container | `89::derived-phase` (`0001-hybrid\|design`, `0009-decomposing-approved\|ship`, pure containers `\|manifest`) | PASS |
| AC10 nested decomposing own-phase first; `.gitkeep` `not started` | `89::derived-phase` (`0009` own phase, `0011` `manifest`, `0001-empty-leaf` `not started`) | PASS |
| AC11 stale/reopened/challenged precedence | `89::overlay-precedence` (`design (backtracked)`, `build (reopened)`, `challenged (blocked)`, stale outranks challenge) | PASS |
| AC12 `/status` render contract pinned | `89::status-render` (indentation, `its derived phase and`, `blocked: <local ids>`, `<ready>/<total> ready`, `<phase> <n>, ...` against `docs/workflow.md`, `.opencode/agent/status.md`, `.opencode/command/status.md`) | PASS |
| AC13 literal expected blocks; flatten/mis-derive fails | `89::recursive-readiness`/`nested-readiness`/`derived-phase`/`decomposing-summary` + mutation probes above | PASS |
| AC14 missing fixture fails not skips; read-only | `89::fixture-existence` (`bad`, no `skip`, confirmed by root-deletion probe), `89::read-only-contract` (no `work/`, no nested `work/`, no absolute/`../`) | PASS |
| AC15 references neighbours by name; no re-assertion; no checker | `89::no-duplication` (names `10-readiness`/`20-lifecycle`/`80-cycle-fixture`/`87-backtrack-guards`; 8 owned needles verified absent), `git status` shows no production surface | PASS |

Independent re-derivation of the expected blocks (readiness, derived labels,
summary tallies `13/15`, `2/4`, `1/1`) from the shipped authority matched the
guard's literals exactly, so the literal blocks are not self-fulfilling.

## Gaps and residual risk

- **No depth-4 fixture node (spec Edge cases, not an AC).** The spec's
  "Edge cases" bullet asks for a node "deeper than three levels to prove no
  maximum depth"; the fixture's deepest node is depth 3, which is the AC1
  requirement (`depth ≥ 3`). The recursive walk in `rs_walk_derived`/`fixture_derived`
  has no depth cap, so the guard is not limited to three levels, but no committed
  fixture demonstrates a fourth. Suggest a follow-up fixture node (and matching
  expected-block entry) rather than a spec/design backtrack, since the acceptance
  criterion itself is met.
- **`no-duplication` is a sampled check.** `89::no-duplication` verifies a fixed
  set of eight literals owned by the four neighbouring areas (all eight confirmed
  present in their owners and absent here). It is not an exhaustive scan of every
  literal those areas own, so a future unrelated restatement could slip past. It
  is a reasonable, bounded pin consistent with the design; noted for reviewers.
- **`no-stored-readiness` uses the canonical six-column header as a proxy** for
  "no stored readiness value" (AC8). Independently confirmed: no fixture manifest
  carries a readiness field (only an unrelated prose mention of `ready` in the
  hybrid manifest's `## Open issues`). A readiness value smuggled in via a
  frontmatter field other than the `Children` table would not be caught, but the
  manifest grammar has no such field.
- **Live `/status` render residual is manual** (spec non-goal "No live `/status`
  run"). The guard pins the *contract text* in the prompt authority and computes
  the same shape from the fixture; it does not drive a real `/status`. The
  residual is a documented manual check.
- **Registration is owned downstream.** The `tests/README.md` Checks-table row and
  mapping paragraph, and the `tests/mutation.sh` mutation jobs / staged-copy entry
  for `tests/fixtures/recursive-status/`, are owned by
  `0005-guard-registration-sweep`. This area runs in `tests/run.sh` today (adding
  a file adds the check), but is not yet in the mutation runner's staged-copy set.
- **Sub-area labels exposed for `0005` registration:** `recursive-readiness`,
  `nested-readiness`, `dependency-satisfaction`, `decomposing-target`,
  `cycle-readiness`, `derived-phase`, `overlay-precedence`, `decomposing-summary`,
  `status-render`, `no-stored-readiness`, `determinism`; structural labels
  `fixture-existence`, `read-only-contract`, `no-duplication`.
