---
feature: 0015-recursive-workflow-guards/0003-recursive-conflicts-guard
phase: tasks
status: final
created: 2026-10-14
updated: 2026-10-14
parent: 0015-recursive-workflow-guards
---

# Tasks — Recursive declared-conflicts guard

Ordered, dependency-aware. One task ≈ one focused commit. Every task edits only
`tests/checks/85-conflict-guards.sh` or adds files under
`tests/fixtures/recursive-conflicts/` (and the node's own `tasks.md` boxes). Do
not touch `tests/README.md`, `tests/mutation.sh`, `tests/fixtures/declared-conflicts/`,
or any production/authority surface — those are out of scope (`spec.md:50-68`).

- [x] **T1** — Widen `guard_resolve` in `tests/checks/85-conflict-guards.sh` to the
      recursive reference grammar `^[0-9]{4}-[a-z0-9-]+(/[0-9]{4}-[a-z0-9-]+)*$`
      (the trailing group is `?` today), keeping the root-relative reference
      branch, the sibling-row-first bare-token branch, and the surface fallback
      unchanged; update the file's header comment to name the recursive sub-areas.
      [AC1] [AC2]
      Verify: `FRAMEWORK_TEST_AREAS=85-conflict-guards bash tests/run.sh` exits 0 —
      the shipped `AC23 column-layout`/`positional-parse`/`cell-resolution`/
      `pair-predicate` blocks are unchanged.

- [x] **T2** — Make the event build recursive and parameterized: add
      `guard_walk_node(node_ref, node_dir, node_rows)` replacing the two hardcoded
      top-level loops in `guard_build_events`, recursing into a child directory
      that holds `manifest.md` or `roadmap.md`; add
      `guard_collect(items_root)` (save/restore `GUARD_ITEMS` around
      `guard_build_events`); add the generic `fixture_entities` analyzer emitting
      `<ref>|<shipped 0|1>` sorted. [AC3] [depends: T1]
      Verify: `FRAMEWORK_TEST_AREAS=85-conflict-guards bash tests/run.sh` exits 0;
      the `declared-conflicts` fixture (no decomposing child) produces an unchanged
      event stream, so all shipped `AC23` blocks still match.

- [x] **T3** — Author the committed fixture root `tests/fixtures/recursive-conflicts/`
      exactly as specified in `design.md` → "Fixture": the seven top-level entries,
      the 6-column `9201-root-a` and `9201-root-a/0001-nested` manifests, the
      5-column legacy `9201-root-a/0003-legacy` manifest, the 6-column
      `9202-root-b` manifest, the `spec.md` files, the `design.md` declarations,
      the shipped `ship.md`, and every `.gitkeep`. `9203-shared/` holds only
      `.gitkeep`. Fixture prose must not contain the literal substring `work/`.
      [AC1] [AC2] [AC3] [AC4] [AC5] [AC6] [AC7] [AC8] [AC9] [AC11] [depends: T2]
      Verify: every path in the design's fixture tables exists (inspect with the
      Glob/Read tools); `grep -r 'work/' tests/fixtures/recursive-conflicts`
      returns no match.

- [x] **T4** — Add the structural recursive assertions: `AC23 recursive-fixture-existence`
      (the root and its key files exist; a missing fixture `bad`s, never skips),
      `AC23 recursive-read-only-contract` (no live `work/` path under `$RC_ROOT`),
      and `AC23 recursive-column-layout` (the 6-column header on `9201-root-a` and
      `0001-nested`, the 5-column legacy header on `9201-root-a/0003-legacy`,
      positional parse `Depends on|conflicts-with`, and `0001-old` declaring
      nothing while remaining an entity). [AC9] [AC11] [depends: T2] [depends: T3]
      Verify: `FRAMEWORK_TEST_AREAS=85-conflict-guards bash tests/run.sh` exits 0;
      temporarily renaming `tests/fixtures/recursive-conflicts` makes the area exit
      non-zero naming `recursive-fixture-existence` (restore immediately).

- [x] **T5** — Add `AC23 recursive-traversal`, `AC23 recursive-reference`, and
      `AC23 recursive-sibling-precedence`, using the expected blocks in
      `design.md` → "Expected recursive event blocks" and the analyzers
      `fixture_entities` / `fixture_resolution` (filtered by owner ref).
      [AC1] [AC2] [AC3] [depends: T4]
      Verify: `FRAMEWORK_TEST_AREAS=85-conflict-guards bash tests/run.sh` exits 0
      with all three labels `ok`.

- [x] **T6** — Add `AC23 recursive-union` (the expected two-line resolution subset
      for `9201-root-a/0001-nested/0002-grand`) and `AC23 recursive-drift` (the
      expected `fixture_drift` block). [AC4] [AC5] [depends: T4]
      Verify: `FRAMEWORK_TEST_AREAS=85-conflict-guards bash tests/run.sh` exits 0
      with both labels `ok`.

- [x] **T7** — Add `AC23 recursive-pair` (the expected six-line `fixture_conflicts`
      block) with the absence assertions that no pair names
      `9201-root-a/0001-nested/0003-shipped` and that
      `9201-root-a/0001-nested/0005-precedence` is not paired with
      `9202-root-b/0001-namer`; add `AC23 recursive-shipped` (the shipped target
      still resolves for `0004-refs`, and the shipped ref is absent from the pair
      block). [AC6] [AC7] [depends: T4]
      Verify: `FRAMEWORK_TEST_AREAS=85-conflict-guards bash tests/run.sh` exits 0;
      temporarily copying the `9201-root-a/0001-nested/0003-shipped` row and
      adding an unshipped copy makes the pair block diverge and fail (restore
      immediately).

- [x] **T8** — Add `AC23 recursive-unresolved` with the expected
      `fixture_unresolved` block for `0006-bad`, asserting every malformed and
      unresolved token is reported and none is dropped. [AC8] [depends: T4]
      Verify: `FRAMEWORK_TEST_AREAS=85-conflict-guards bash tests/run.sh` exits 0;
      adding one extra well-formed-and-resolving token to
      `9201-root-a/0001-nested/0006-bad/design.md` makes the block diverge and fail
      (restore immediately).

- [x] **T9** — Run the full suite and the mutation-sensitivity spot check.
      [AC10] [AC12] [depends: T5] [depends: T6] [depends: T7] [depends: T8]
      Verify: `bash tests/run.sh` exits 0 with every area green (AC10). On a
      scratch copy of the repo, for each of the eight labels
      `recursive-reference`, `recursive-sibling-precedence`,
      `recursive-traversal`, `recursive-union`, `recursive-drift`,
      `recursive-pair`, `recursive-shipped`, `recursive-unresolved`, apply one
      targeted change (to the guard's resolver/walk or to the corresponding fixture
      declaration) and confirm `FRAMEWORK_TEST_AREAS=85-conflict-guards bash
      tests/run.sh <copy>` exits non-zero and prints a `FAIL` line naming that
      label. Permanent mutation jobs are registered by
      `0005-guard-registration-sweep`.
