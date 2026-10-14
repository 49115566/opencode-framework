---
feature: 0015-recursive-workflow-guards/0001-recursive-structure-guard
phase: tasks
status: final
created: 2026-10-14
updated: 2026-10-14
parent: 0015-recursive-workflow-guards
---

# Tasks — Recursive model, reference, and allocation guard

Ordered, dependency-aware. One task ≈ one focused commit. Every task leaves
`bash tests/run.sh` green. The stable suite token is `AC27`; the check file is
`tests/checks/81-recursive-structure-guard.sh` and the fixture root is
`tests/fixtures/recursive-structure/` (see `design.md`).

- [x] **T1** — Author the committed fixture root
      `tests/fixtures/recursive-structure/items/` exactly as tabulated in
      `design.md`: the hybrid `9001-tree/` (`manifest.md`, `spec.md`, `tasks.md`),
      its decomposing `0001-branch/` → `0001-leaf/` chain down to the depth-4
      `0001-deep/` marker-only leaf, the depth-4 `0009-dup-x/`/`0009-dup-y/`
      duplicate pair, the `0002-leaf/` marker-only leaf, the second top-level
      `9002-tree/` with its own `0001-branch/0001-leaf/`, and the top-level
      duplicate pair `9010-dup-a/`/`9010-dup-b/`. Every child of a manifest node
      carries `.gitkeep`; each `manifest.md` uses the canonical six-column
      `Children` header with `—` dependencies, `phase: manifest`, and resolving
      canonical references; `9001-tree/tasks.md` lists entries `T1`/`T2` with no
      matching directory; no fixture text contains `work/`, `..`, or an absolute
      path. [AC1, AC2, AC3, AC4, AC6, AC7, AC8, AC10]
      Verify: `bash -c 'set -eu; R=tests/fixtures/recursive-structure/items; for f in 9001-tree/manifest.md 9001-tree/spec.md 9001-tree/tasks.md 9001-tree/0001-branch/.gitkeep 9001-tree/0001-branch/manifest.md 9001-tree/0001-branch/0001-leaf/0001-deep/.gitkeep 9001-tree/0001-branch/0001-leaf/0009-dup-x/.gitkeep 9001-tree/0001-branch/0001-leaf/0009-dup-y/.gitkeep 9001-tree/0002-leaf/.gitkeep 9002-tree/0001-branch/0001-leaf/.gitkeep 9010-dup-a/spec.md 9010-dup-b/spec.md; do test -f "$R/$f"; done; ! grep -rq "work/" "$R"; echo ok'`.
- [x] **T2** — Author `tests/checks/81-recursive-structure-guard.sh` with the
      header, `AC27` labels, path constants, the `rs_is_item_dir`/`rs_manifest`/
      `rs_children`/`rs_max_depth` helpers, and the fixture-shape sub-areas
      `fixture-depth` (fail — not skip — when the root is absent; fail when the
      deepest branch is < 4 levels), `hybrid-node` (a node with both a manifest
      and an own phase artifact), `reservation-marker` (every child dir at every
      level has `.gitkeep`; at least one marker-only leaf exists),
      `allocation-scoping` (two distinct parents each begin their local numbering
      at `0001`; a grandchild is allocated under its immediate parent), and
      `reference-depth` (the depth-4 reference resolves; pin the regex literal
      `^[0-9]{4}-[a-z0-9-]+(/[0-9]{4}-[a-z0-9-]+)*$` on
      `docs/artifact-conventions.md`). Sourced by `run.sh`, so it must not call
      `exit`. [AC1, AC2, AC3, AC4, AC5] [depends: T1]
      Verify: `FRAMEWORK_TEST_AREAS=81-recursive-structure-guard bash tests/run.sh` exits 0.
- [x] **T3** — Add the duplicate-derivation sub-areas to
      `81-recursive-structure-guard.sh`: `rs_dup_findings` (full-canonical-path
      identity; `DUPLICATE-PREFIX` for the top-level `9010` pair and
      `DUPLICATE-CHILD` for the depth-4 `0009` pair with shared parent and shared
      local prefix) compared to the committed expected block, and
      `duplicate-position` (negative assertions: equal local-id text under
      different parents is not a duplicate; no top-level collision labeled
      `DUPLICATE-CHILD` and no deeper collision labeled `DUPLICATE-PREFIX`).
      [AC6, AC7, AC8] [depends: T2]
      Verify: `FRAMEWORK_TEST_AREAS=81-recursive-structure-guard bash tests/run.sh` exits 0 and prints the `duplicate-derivation` and `duplicate-position` ok lines.
- [x] **T4** — Add the `contract-pins` sub-area to
      `81-recursive-structure-guard.sh`: pin `applies uniformly at every node`,
      `no maximum recursion depth`, and `nesting continues to arbitrary depth`
      on `docs/workflow.md`; `are **not** nodes` on `docs/workflow.md`; the
      per-level-reservation and immediate-parent allocation-scoping phrases on
      `docs/artifact-conventions.md`; and, for both the merge-integrity guard and
      the declared-conflict check, `prompt behavior only` plus
      `no committed checker, script, helper, or executable tool` (using `flat`
      for the declared-conflict sentence, which wraps). [AC9, AC10, AC11, AC12] [depends: T3]
      Verify: `FRAMEWORK_TEST_AREAS=81-recursive-structure-guard bash tests/run.sh` exits 0 and prints the `contract-pins` ok lines.
- [x] **T5** — Add the `read-only-contract` sub-area to
      `81-recursive-structure-guard.sh`: fail when the fixture root references a
      live `work/` path or contains a `..`/absolute path token; assert the guard
      adds no committed production checker (it is invoked by no framework
      command). [AC13] [depends: T4]
      Verify: `FRAMEWORK_TEST_AREAS=81-recursive-structure-guard bash tests/run.sh` exits 0; run it twice capturing output under `scratch/` and `diff` the two
      outputs → identical (idempotent, writes no file).
- [x] **T6** — Append exactly one line to `stage_copy()` in `tests/mutation.sh`
      copying `tests/fixtures/recursive-structure` into the staged copy, so the
      mutation self-check's clean whole-suite runs see the fixture root
      (append-only; no mutation job is added — `0005` owns those). [AC15] [depends: T5]
      Verify: `bash tests/mutation.sh` exits 0 (its two clean whole-suite runs
      pass with the new area present).
- [x] **T7** — Confirm the committed suite and scope: fix any regression surfaced
      by T2–T6. [AC14, AC16] [depends: T6]
      Verify: `bash tests/run.sh` exits 0 with every existing area green and the
      new area labelling its assertions `AC27`; `git diff --name-only` (excluding
      `work/`) names only paths under `tests/`.
