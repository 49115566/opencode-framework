---
feature: 0013-simultaneous-work-recursion/0001-recursive-allocation
phase: tasks
status: final
created: 2026-10-13
updated: 2026-10-13
parent: 0013-simultaneous-work-recursion
---

# Tasks — Per-level sequence allocation and recursive duplicate detection

Ordered, dependency-aware. One task ≈ one focused commit. The exact prose to
author is fixed in `design.md` → "Interfaces and data model"; no task may
re-open those decisions.

- [ ] **T1** — Rewrite the duplicate-detection paragraph in
      `docs/workflow.md` → "Multiple work items" (currently lines 1379–1388) to
      the recursive rule specified in `design.md`: checked at every node against
      its own immediate children, the `DUPLICATE-PREFIX` / `DUPLICATE-CHILD` code
      mapping, the depth-≥ 3 full-canonical-reference plus shared-parent/prefix
      naming, and the `## Merge conflicts` reference for class/grammar. Preserve
      the existing renumber pointer and the "only one class of conflict" pointer.
      [AC1, AC2, AC3, AC4, AC5, AC6, AC10]
      Verify: `grep -nE 'DUPLICATE-PREFIX|DUPLICATE-CHILD|own immediate children|full canonical reference|shared parent and shared local prefix' docs/workflow.md` shows all terms inside `## Multiple work items`; `grep -n 'scan the top-level' docs/workflow.md` returns nothing (old two-level wording gone).
- [ ] **T2** — Insert the single cross-reference sentence into
      `docs/artifact-conventions.md` → "Sequence allocation", immediately after
      the per-level `MMMM` paragraph (after line 687) and before
      `### Renumbering after a parallel merge`, exactly as fixed in `design.md`.
      Do not alter the allocation contract text. [AC6, AC7] [depends: T1]
      Verify: `grep -n 'detected by the recursive rule stated once' docs/artifact-conventions.md` matches once; `git diff docs/artifact-conventions.md` shows only the added pointer sentence (no change to the allocation or renumber paragraphs).
- [ ] **T3** — Verify the scope boundary and backward compatibility: confirm the
      change set is exactly the two authority documents, that nothing inside
      `## Merge conflicts` / `### Lifecycle placement` / "Renumbering after a
      parallel merge" changed, and that the code mapping and grammar reuse no new
      vocabulary. [AC8, AC10] [depends: T1, T2]
      Verify: `git diff --name-only` lists only `docs/workflow.md` and `docs/artifact-conventions.md` (plus this item's `work/` artifacts); `git diff docs/workflow.md docs/artifact-conventions.md` contains no hunk under a `## Merge conflicts`, `### Lifecycle placement`, or `### Renumbering after a parallel merge` heading.
- [ ] **T4** — Run the repository's configured test command and confirm the
      committed suite is green with no documented inventory count changed. [AC9]
      [depends: T1, T2]
      Verify: `bash tests/run.sh` exits 0; its `tests/checks/40-inventory.sh`
      (AC9) lines are all `ok`.
