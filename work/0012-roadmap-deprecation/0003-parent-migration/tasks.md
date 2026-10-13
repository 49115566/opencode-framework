---
feature: 0012-roadmap-deprecation/0003-parent-migration
phase: tasks
status: final
created: 2026-10-13
updated: 2026-10-13
parent: 0012-roadmap-deprecation
---

# Tasks — Existing-parent migration: grandfather the seven live nodes and migrate the test fixtures

Ordered, dependency-aware. One task ≈ one focused commit. After T1 the suite is
temporarily red until the guard tasks land; each task's own `Verify:` states the
check that must pass for that task.

- [x] **T1** — Migrate the five decomposing-node fixtures to the modern spelling.
      `git mv` `tests/fixtures/declared-conflicts/items/9001-roadmap-a/roadmap.md`,
      `tests/fixtures/declared-conflicts/items/9002-roadmap-b/roadmap.md`,
      `tests/fixtures/declared-conflicts/items/9003-roadmap-old/roadmap.md`,
      `tests/fixtures/backtracking/items/9120-revised-roadmap/roadmap.md`, and
      `tests/fixtures/backtracking/items/9121-readiness/roadmap.md` to
      `manifest.md`; set frontmatter `phase: manifest`; change the H1 to
      `# Manifest — <title>`; reword artifact-naming nouns in the `## Initiative`
      body from "roadmap" to "manifest". Preserve byte-for-byte the fixture-local
      `feature:` value, directory names, `Children` table (including
      `9003-roadmap-old`'s five-column header), `Canonical reference` cells,
      `## Sequencing`, and any withdrawal/revision records. Retain
      `tests/fixtures/cyclic-roadmap/roadmap.md` as the single legacy-alias
      fixture and add one backward-compatibility sentence naming it so. [AC3] [AC4]
      Verify: `grep -rl 'phase: roadmap' tests/fixtures` lists only
      `tests/fixtures/cyclic-roadmap/roadmap.md`; `ls tests/fixtures/declared-conflicts/items/9001-roadmap-a tests/fixtures/backtracking/items/9120-revised-roadmap`
      shows `manifest.md` and no `roadmap.md`; `grep -rl 'phase: manifest' tests/fixtures` lists the five migrated files.

- [x] **T2** — Reconcile `tests/checks/85-conflict-guards.sh` to the migrated
      fixtures and to both manifest spellings. Add a local resolver
      (`<dir>/manifest.md` when present, else `<dir>/roadmap.md`, else empty) and
      use it for the parent detection in `guard_build_events` (the parent
      `-f` test and the `guard_children_rows` call) and the standalone-item skip.
      Repoint the fixture-existence, `column-layout`, and `positional-parse`
      assertions at `9001-roadmap-a/manifest.md` and
      `9003-roadmap-old/manifest.md`, and add `need` assertions that each carries
      `phase: manifest` and `# Manifest —`. Do not change the expected
      resolution/conflict/drift blocks or the `AC23` sub-area labels; modernize
      only the descriptive comment wording ("roadmap Children table" → "manifest
      Children table"). [AC3] [AC5] [AC7] [depends: T1]
      Verify: `FRAMEWORK_TEST_AREAS=85-conflict-guards bash tests/run.sh` prints
      `TOTAL:` with `0 failed`; `grep -n 'roadmap.md' tests/checks/85-conflict-guards.sh`
      returns nothing.

- [x] **T3** — Reconcile `tests/checks/87-backtrack-guards.sh` to the migrated
      backtracking manifests and to both spellings. Add the same local resolver
      and use it in `bt_record_refs`, `bt_challenge_refs`, and `fixture_derived`
      to skip a decomposing-node fixture by either spelling, and to resolve the
      paths in the fixture-existence list, `fixture_revision`, `BT_RM`,
      `fixture_readiness`, `fixture_readiness_blocked`, and the
      no-stored-readiness header check (`9120-revised-roadmap/manifest.md`,
      `9121-readiness/manifest.md`). Add `need` assertions for `phase: manifest`
      and `# Manifest —` on both migrated manifests. Rename the internal helpers
      `bt_roadmap_rows`/`bt_roadmap_header`/`bt_roadmap_seq` to
      `bt_manifest_*` and the internal `missing-roadmap|` fault token to
      `missing-manifest|`, and modernize descriptive comments ("parent-roadmap
      revision", "roadmap cycle rule", "non-roadmap fixture item", "Revising a
      roadmap"). Keep the `AC24` token and the `roadmap-revision`
      agreement-area label verbatim, along with the expected blocks. [AC3] [AC5] [AC7] [depends: T1]
      Verify: `FRAMEWORK_TEST_AREAS=87-backtrack-guards bash tests/run.sh` prints
      `TOTAL:` with `0 failed`; `grep -n 'roadmap.md' tests/checks/87-backtrack-guards.sh`
      returns nothing; `grep -c 'AC24 roadmap-revision' tests/checks/87-backtrack-guards.sh`
      is unchanged (the stable label is preserved).

- [x] **T4** — Reconcile `tests/checks/80-cycle-fixture.sh` to recognize the
      retained legacy alias. Resolve the cycle fixture through the same
      manifest-then-alias lookup (prefer
      `tests/fixtures/cyclic-roadmap/manifest.md`, fall back to `roadmap.md`) and
      add an explicit assertion that the resolution lands on the retained legacy
      `roadmap.md` alias and that it is recognized as the decomposing manifest,
      alongside the existing `phase: roadmap` and `# Roadmap —` checks. Keep the
      existing `Children`/cycle parse and the `CYCLIC-DEP` rule assertions
      unchanged, keep the missing-fixture failure message containing the literal
      `AC13 committed cycle fixture missing`, and modernize the banner/comment
      prose from "roadmap cycle rule" to "decomposing-node cycle rule" while
      keeping the `AC13` token. [AC4] [AC5] [AC7] [depends: T1]
      Verify: `FRAMEWORK_TEST_AREAS=80-cycle-fixture bash tests/run.sh` prints
      `TOTAL:` with `0 failed`; `grep -n 'roadmap cycle rule' tests/checks/80-cycle-fixture.sh`
      returns nothing; `grep -n 'AC13 committed cycle fixture missing' tests/checks/80-cycle-fixture.sh`
      still matches.

- [x] **T5** — Update `tests/mutation.sh` fixture paths. Repoint `job_15` and
      `job_16` at `tests/fixtures/declared-conflicts/items/9001-roadmap-a/manifest.md`
      (both the mutation target and the `job_finish` restore path) and `job_24`
      at `tests/fixtures/backtracking/items/9120-revised-roadmap/manifest.md`;
      leave `job_8` on the retained `tests/fixtures/cyclic-roadmap/roadmap.md`.
      Change no other path, counter, or job. [AC6] [depends: T1]
      Verify: `bash tests/mutation.sh --selftest` prints `SELFTEST: <n> passed, 0 failed`;
      `bash tests/mutation.sh` prints `MUTATION TOTAL: <n> checked passed, 0 failed`;
      `grep -n 'roadmap-a/roadmap.md\|9120-revised-roadmap/roadmap.md' tests/mutation.sh`
      returns nothing.

- [x] **T6** — Modernize `tests/README.md` terminology. Change the
      `80-cycle-fixture.sh` Checks-table cell from "roadmap cycle rule and
      committed fixture" to a manifest/decomposing-node wording. Keep every
      stable `ACn` token, agreement-area label (including `AC24 roadmap-revision`),
      area file name, and the copy-set sentences pinned by `90-packaging.sh` and
      `95-split-guard.sh` unchanged. [AC7]
      Verify: `grep -n 'roadmap' tests/README.md` shows only the stable
      `AC24 roadmap-revision` label (and any retained-legacy note);
      `FRAMEWORK_TEST_AREAS=90-packaging,95-split-guard bash tests/run.sh` prints
      `TOTAL:` with `0 failed`.

- [x] **T7** — Full verification and scope checks. Run the whole suite and the
      mutation pass; confirm the seven grandfathered parents and every
      out-of-scope surface are untouched; confirm no new agreement area, guard,
      command, or artifact kind was introduced and that this item's committed
      artifacts record the grandfather decision. [AC1] [AC2] [AC8] [AC9] [AC10] [AC11] [depends: T2,T3,T4,T5,T6]
      Verify:
      `bash tests/run.sh` prints `TOTAL:` with `0 failed`;
      `bash tests/mutation.sh` prints `MUTATION TOTAL: <n> checked passed, 0 failed`;
      `git diff --name-only` lists only the five migrated `manifest.md` files,
      `tests/fixtures/cyclic-roadmap/roadmap.md`,
      `tests/checks/80-cycle-fixture.sh`, `tests/checks/85-conflict-guards.sh`,
      `tests/checks/87-backtrack-guards.sh`, `tests/README.md`,
      `tests/mutation.sh`, and `work/0012-roadmap-deprecation/0003-parent-migration/{design.md,tasks.md}`;
      `git status --short work/0003-framework-quality-hardening work/0004-adoption-template-split work/0005-merge-conflict-workflow work/0006-parallel-plan-conflicts work/0007-phase-backtracking work/0010-recursive-plan-cycle work/0011-recursive-bootstrap`
      is empty.
