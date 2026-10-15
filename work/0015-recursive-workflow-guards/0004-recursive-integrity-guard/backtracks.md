---
feature: 0015-recursive-workflow-guards/0004-recursive-integrity-guard
record: backtracks
created: 2026-10-14
updated: 2026-10-14
---

## Finding 1 — 2026-10-14

- detecting phase: `/build`
- target phase: `/plan`
- affected: `design.md`, `tasks.md`
- evidence: `design.md:59` mandates a fixture node `9203-spelling-both/` holding
  **both** `manifest.md` and the deprecated `roadmap.md` alias, and `tasks.md:17`
  (`T1`) instructs authoring it, with `T1`'s `Verify:` (`tasks.md:18`) requiring
  `bash tests/run.sh` to exit 0. But the committed area
  `tests/checks/80-cycle-fixture.sh:66-71` (`AC13`, the `0012-roadmap-deprecation`
  migration guard) asserts that `find tests/fixtures -name roadmap.md` returns
  exactly one path — `tests/fixtures/cyclic-roadmap/roadmap.md` — and fails
  otherwise. After authoring the `T1` fixture, `bash tests/run.sh` prints
  `FAIL  AC13 unexpected roadmap.md fixture set (AC3):
  tests/fixtures/cyclic-roadmap/roadmap.md
  tests/fixtures/recursive-integrity/items/9203-spelling-both/roadmap.md`
  (`TOTAL: 502 passed, 1 failed`) and exits 1. Verified the assertion is unchanged
  on `origin/main`, and it is the only whole-fixture-set `roadmap.md` assertion in
  the suite. This contradicts `spec.md` AC11 ("every existing agreement area still
  passes") and the design's own "Backward compatibility … `bash tests/run.sh` …
  stay green". The builder cannot resolve it in scope: `spec.md`'s non-goals
  forbid re-pinning what the existing areas own (the cycle area), and the design's
  "Affected areas" lists only `tests/checks/89-integrity-guard.sh`,
  `tests/fixtures/recursive-integrity/**`, and `tests/mutation.sh`. The design's
  §"Affected areas"/backward-compatibility claim is therefore inconsistent with
  its §"Fixture tree (integrity half)".
- status: open

Recorded by the `/build` phase while selecting `T1`; the `design.md`, `tasks.md`,
and `spec.md` artifacts owned by other phases were not edited, and `T1` remains
unchecked. Nothing downstream was stale-marked on this item: `verify.md` and
`review.md` do not exist, and `design.md`/`tasks.md` are the found-against target
artifacts (revised, not marked). The sanctioned route is
`/plan 0015-recursive-workflow-guards/0004-recursive-integrity-guard` to
reconcile the dual-spelling fixture with the committed `AC13` whole-set assertion
— for example by scoping an update to `tests/checks/80-cycle-fixture.sh` to this
item (or to a sibling guard), by moving the deliberate drift alias out of the
`tests/fixtures/**` `find` root, or by having the plan state which phase owns the
assertion's relaxation — so that `bash tests/run.sh` exits 0 with the fixture
present. The `9204-phase-mismatch` node already exercises AC4's "manifest
spelling disagrees with its declared `phase` value" arm; the open question the
plan must settle is how (or whether) to keep the "both manifest spellings" arm
without breaking the committed migration guard.

## Resolution 1 — 2026-10-14

- resolves: Finding 1
- revision: The plan now owns the reconciliation instead of leaving the
  dual-spelling fixture and the committed AC13 guard in conflict. `design.md`
  gains a "Reconciling the deliberate dual-spelling fixture with the committed
  AC13 guard" subsection that narrows `tests/checks/80-cycle-fixture.sh`'s AC13
  whole-set `roadmap.md` assertion to exclude the one documented deliberate path
  `tests/fixtures/recursive-integrity/items/9203-spelling-both/roadmap.md`
  (`find … -name roadmap.md | grep -vxF <path>`), keeping the remainder's
  exact-equality against the retained cyclic alias so any *third* alias still
  fails; the cycle diagnostic and `job_8` are untouched. The edit is a focused
  single-item change, not a shared append-only registry, so `design.md`'s
  `conflicts-with` stays the parent cell's two registries (`tests/README.md`,
  `tests/mutation.sh`) and no `DRIFT-FACT` is created. "Affected areas",
  "Backward compatibility" (no longer "purely additive"), the "AC13 migration
  guard weakened" risk, and the AC4/AC11 test-strategy rows were updated.
  `tasks.md` inserts a new first task `T1` (narrow the AC13 assertion, verified
  green independently and sensitive to a scratch third alias) and renumbers the
  fixture/check/staging tasks to `T2`–`T9`, with the integrity-fixture task now
  depending on `T1` and its `Verify:` requiring `bash tests/run.sh` to exit 0 with
  the dual-spelling fixture present.   `spec.md` was not edited; no artifact was
  marked `stale:` (none was downstream of `/plan`).

## Finding 2 — 2026-10-14

- detecting phase: `/build`
- target phase: `/plan`
- affected: `design.md`, `tasks.md`
- evidence: `review.md` [M1] found the new agreement area
  `tests/checks/89-integrity-guard.sh` collides on its numeric prefix with the
  already-merged sibling `tests/checks/89-recursive-status-guards.sh`
  (confirmed present on `origin/main` via `git show origin/main:tests/checks`),
  so once both merge two distinct areas share the `89-` stem.
  `tests/README.md` → "Area selection" (`tests/README.md:43-50`) defines a
  name-prefix selector matching two or more areas as a **setup error**
  ("ambiguous" — one matching none is "unknown"), so `FRAMEWORK_TEST_AREAS=89`
  (and any `89` prefix selector) exits 2; the suite's selector convention is a
  unique stem. `design.md:36` and `design.md:224` fix the filename
  `tests/checks/89-integrity-guard.sh`, and `tasks.md:12-16` states the check
  filename "is fixed by `design.md`; no task below re-decides them", so `/build`
  may not rename it. The design's own risk note (`design.md:275-279`) accepted the
  collision as "only an area-selector ambiguity, not a suite failure"; the review
  found that acceptance wrong and the collision unresolved in the committed
  state, since `0005-guard-registration-sweep`'s scope
  (`work/0015-recursive-workflow-guards/manifest.md:127`) covers only the
  `tests/README.md` Checks row and the mutation jobs, not renaming this area's
  check. The design's chosen check filename and its risk handling are therefore
  wrong and must be revised by their owner — for example to the free prefix
  `tests/checks/91-integrity-guard.sh`, keeping the `AC30` token and sub-area
  labels unchanged — not re-decided by `/build`.
- status: open

Recorded by the `/build` phase while addressing `review.md` [M1]. The
`design.md`, `tasks.md`, and `spec.md` artifacts owned by other phases were not
edited; the completed tasks in `tasks.md` were left checked — the fault is a
design-chosen filename (the area name is `design.md`'s declared public surface
for `0005`), not an unimplemented task, and the `/plan` revision owns the
`tasks.md` update. The review's rename recommendation changes that design-fixed
interface, so the sanctioned route is
`/plan 0015-recursive-workflow-guards/0004-recursive-integrity-guard`. Per the
reverse-edge rule, the downstream artifacts `verify.md` and `review.md` are marked
`stale: design` in their frontmatter; both remain on disk, recoverable, and are
re-run forward after the revision.

## Resolution 2 — 2026-10-14

- resolves: Finding 2
- revision: The plan renames the new area off the collided `89-` numeric stem to
  the free `91-integrity-guard.sh` instead of leaving the collision for `0005`
  (whose scope covers only the `tests/README.md` row and the mutation jobs).
  `design.md` updates the Summary, Approach ("New agreement area"), Interfaces,
  Affected areas, and the test-strategy selector strings to the `91-` name;
  rewrites the former "Filename/prefix collision" risk — whose "only an
  area-selector ambiguity, not a suite failure" acceptance the review correctly
  found wrong — into a resolved-by-rename risk plus a leftover-reference risk;
  adds a "Defer the area rename to `0005`" rejected alternative; and adds a
  "Renaming the area off the collided `89-` stem" subsection that verifies the
  `91-` stem is free against `origin/main:tests/checks` and enumerates the full
  reference sweep — the check file's own name, its `FIG_SELF` resolver, its
  `.opencode/` self-reference scan literal, its header comment, the
  `tests/checks/80-cycle-fixture.sh:66` AC13 cross-reference, and the six
  fixture-prose references under `tests/fixtures/recursive-integrity/` (the
  review named only three of these). The `AC30` token and every sub-area label
  are unchanged, so the `0005` mapping surface is untouched. `tasks.md` updates
  the fixed-filename preamble, folds the rename and the full sweep into `T4`
  (adding `grep -rF '89-integrity-guard' tests/` prints nothing to its
  `Verify:`), updates the `T5`–`T7`/`T9` `Verify:` selectors to
  `91-integrity-guard`, and re-opens `T4`–`T7` and `T9` (their deliverables or
  verification named the old area); `T1`–`T3` and `T8` stay checked — their
  substantive deliverables are unchanged and `T4` sweeps the incidental
  references in their files. `spec.md` was not edited. No artifact was marked
  `stale:` by this revision: `design.md`/`tasks.md` are the found-against target
  (revised, not marked), and `verify.md`/`review.md` already carry the
  reverse-edge `stale: design` marker, which their owning phases clear on re-run.
