---
feature: 0015-recursive-workflow-guards/0002-recursive-readiness-status-guard
phase: tasks
status: final
created: 2026-10-14
updated: 2026-10-14
parent: 0015-recursive-workflow-guards
---

# Tasks — Recursive readiness and `/status` guard

Ordered, dependency-aware. One task ≈ one focused commit. "full" means
`spec.md`, `design.md`, `tasks.md` (all boxes checked), `verify.md`, `review.md`.

- [x] **T1** — Create the fixture root `tests/fixtures/recursive-status/items/` and
      author the top-level decomposing node `9200-tree/manifest.md` (pure
      container, six-column `Children` table, `—` `conflicts-with` for every row)
      with its dependency-signal children at depth 2: `0002-shipped` (full +
      `ship.md`), `0003-approved` (full + `review.md` `approve`), `0004-rejected`
      (full + `review.md` `request-changes`), `0005-noreview` (spec, design,
      tasks✓, verify), `0006-precedence` (full + `request-changes` + `ship.md`),
      `0007-recalled` (full + `approve` + `ship.md` `reopened: build`), and
      `0008-dependent` (`spec.md`, `Depends on: 0002-shipped, 0003-approved,
      0004-rejected, 0005-noreview, 0006-precedence, 0007-recalled`). Add the
      same-local-id decoy root `9201-decoy/manifest.md` with child `0002-shipped`
      carrying only `ship.md` `reopened: build`. [AC2] [AC3] [AC4] [AC5] [AC6]
      Verify: `test -f tests/fixtures/recursive-status/items/9200-tree/manifest.md`
      and `test -f tests/fixtures/recursive-status/items/9200-tree/0007-recalled/ship.md`
      and `grep -q 'reopened: build' tests/fixtures/recursive-status/items/9200-tree/0007-recalled/ship.md`
      and `test -f tests/fixtures/recursive-status/items/9201-decoy/0002-shipped/ship.md`.
- [x] **T2** — Author the hybrid subtree `9200-tree/0001-hybrid/`: its
      `manifest.md` (hybrid) plus its own `spec.md` and `design.md`, and its
      depth-3 children `0001-empty-leaf/` (`.gitkeep`), `0002-approved-leaf/`
      (full + `review.md` `approve`), `0003-cyclic-a/` (`.gitkeep`, `Depends on:
      0004-cyclic-b`) and `0004-cyclic-b/` (`.gitkeep`, `Depends on:
      0003-cyclic-a`); record the deliberate cycle under the hybrid manifest's
      `## Open issues` (the `cyclic-roadmap` fixture precedent), leaving cycle
      *detection* to `80-cycle-fixture`. [AC1] [AC2] [AC7] [AC9] [AC10]
      Verify: `test -f tests/fixtures/recursive-status/items/9200-tree/0001-hybrid/manifest.md`
      and `test -f tests/fixtures/recursive-status/items/9200-tree/0001-hybrid/spec.md`
      and `test -f tests/fixtures/recursive-status/items/9200-tree/0001-hybrid/0001-empty-leaf/.gitkeep`
      and `test -f tests/fixtures/recursive-status/items/9200-tree/0001-hybrid/0003-cyclic-a/.gitkeep`.
- [x] **T3** — Author the decomposing-target nodes and the overlay nodes under
      `9200-tree/`: `0009-decomposing-approved/` (hybrid: `manifest.md` + full +
      `review.md` `approve`) with `.gitkeep` child `0001-leaf/`;
      `0010-depends-decomposing/` (`spec.md`, `Depends on:
      0009-decomposing-approved`); `0011-decomposing-unsat/` (pure container
      `manifest.md` only) with child `0001-shipped-child/` (full + `ship.md`);
      `0012-depends-unsat-dec/` (`spec.md`, `Depends on: 0011-decomposing-unsat`);
      `0013-stale-hybrid/` (`manifest.md` + `spec.md` `stale: design`);
      `0014-challenged-node/` (`spec.md` + `design.md` + `challenges.md` open
      `Challenge 1`); `0015-stale-and-challenged/` (`spec.md` `stale: spec` +
      `challenges.md` open `Challenge 1`). [AC4] [AC6] [AC9] [AC10] [AC11]
      Verify: `test -f tests/fixtures/recursive-status/items/9200-tree/0009-decomposing-approved/review.md`
      and `test -f tests/fixtures/recursive-status/items/9200-tree/0011-decomposing-unsat/manifest.md`
      and `test -f tests/fixtures/recursive-status/items/9200-tree/0013-stale-hybrid/spec.md`
      and `test -f tests/fixtures/recursive-status/items/9200-tree/0014-challenged-node/challenges.md`
      and `test -f tests/fixtures/recursive-status/items/9200-tree/0015-stale-and-challenged/challenges.md`.
- [x] **T4** — Author the guard skeleton `tests/checks/89-recursive-status-guards.sh`:
      the `AC27` header comment naming the sub-areas and the three referenced
      neighbour areas (`10-readiness`, `20-lifecycle`, `80-cycle-fixture`,
      `87-backtrack-guards`), the path constants (`RS_ROOT`, `RS_ITEMS`), the
      shared helpers (`rs_manifest`, `rs_fm_value`, `rs_children_rows`,
      `rs_header`, `rs_has_open_challenge`), and the structural assertions
      `fixture-existence` (present → `ok`; **missing → `bad`, never `skip`**),
      `read-only-contract` (no live `work/` reference, no nested `work/`, no
      absolute/`../` path) and `no-duplication` (references the four areas by
      name; its own source contains none of their owned literals, assembled from
      fragments so it cannot match itself). [AC14] [AC15] [depends: T1]
      Verify: `FRAMEWORK_TEST_AREAS=89-recursive-status-guards bash tests/run.sh`
      exits 0 and prints `ok    AC27 fixture-existence`, `ok    AC27
      read-only-contract`, and `ok    AC27 no-duplication`.
- [x] **T5** — Implement the recursive readiness analyzer: `rs_satisfied`
      (non-recalled `ship.md` presence takes precedence over a
      `request-changes` verdict; else `approve`) and `rs_ready_blocked`
      (sibling-only `Depends on` resolution against the parent's own rows; a
      decomposing target satisfied by its own signal only; `rs_cycle_members`
      via Kahn so a cycle member is never `ready`), plus the reviewed
      `RS_READINESS` expected block covering `9200-tree`'s depth-2 children, the
      hybrid's depth-3 children, and the decoy. [AC2] [AC3] [AC4] [AC5] [AC6]
      [AC7] [depends: T1] [depends: T2] [depends: T3] [depends: T4]
      Verify: the same `FRAMEWORK_TEST_AREAS=89-recursive-status-guards` run
      prints `ok` for `recursive-readiness`, `nested-readiness`,
      `dependency-satisfaction`, `decomposing-target`, and `cycle-readiness`;
      temporarily flipping `0004-rejected/review.md` to `approve` then reverting
      makes `AC27 dependency-satisfaction` `FAIL`.
- [x] **T6** — Implement the recursive derived-phase analyzer `rs_derive`:
      earliest `stale:` → `<token> (backtracked)`; `ship.md` `reopened:` →
      `<phase> (reopened)`; unshipped open challenge → `challenged (blocked)`;
      manifest with no own phase artifacts → `manifest`; otherwise the
      artifact-presence/verdict rows; `.gitkeep`-only → `not started`; plus the
      reviewed `RS_DERIVED` expected block for every fixture node. [AC9] [AC10]
      [AC11] [depends: T2] [depends: T3] [depends: T4]
      Verify: the same run prints `ok` for `derived-phase` and
      `overlay-precedence`; temporarily deleting
      `9200-tree/0001-hybrid/0001-empty-leaf/` then reverting makes `AC27
      derived-phase` `FAIL`.
- [x] **T7** — Implement `rs_summary` (`<node-ref>|<n>/<total> ready · phases:
      <phase> <n>, ...`) with the reviewed `RS_SUMMARY` block for
      `9200-tree`, `9200-tree/0001-hybrid`, and `9201-decoy`; add the
      `determinism` assertion (derive readiness/phase/summary twice and assert
      identical output) and the `no-stored-readiness` assertion (every fixture
      manifest's `Children` header is the canonical six columns); and pin the
      `/status` render contract (`indented to arbitrary depth`,
      `blocked: <local ids>`, `<ready>/<total> ready`, `<phase> <n>, ...`)
      against `docs/workflow.md` → "Status reporting" and
      `.opencode/{agent,command}/status.md` (`status-render`, reading only,
      editing nothing). [AC2] [AC8] [AC12] [AC13] [depends: T5] [depends: T6]
      Verify: the same run prints `ok` for `decomposing-summary`, `determinism`,
      `no-stored-readiness`, and `status-render`; and `bash tests/run.sh` exits
      0 with the unchanged `TOTAL` failure count of 0.
- [x] **T8** — Verify the whole suite is green and the area is
      mutation-sensitive, and confirm scope: `bash tests/run.sh` exits 0;
      `git status --porcelain` lists only `tests/checks/89-recursive-status-guards.sh`
      and `tests/fixtures/recursive-status/` (no production surface touched);
      record in the handoff the area name, token `AC27`, the fixture root, and
      the sub-area labels for `0005-guard-registration-sweep` to register. [AC13]
      [AC14] [AC15] [depends: T5] [depends: T6] [depends: T7]
      Verify: `bash tests/run.sh` exits 0; `git status --porcelain` shows only the
      two new paths; `bash tests/mutation.sh --selftest` exits 0 (if present).
