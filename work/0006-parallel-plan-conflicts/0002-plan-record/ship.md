---
feature: 0006-parallel-plan-conflicts/0002-plan-record
phase: ship
status: final
created: 2026-10-08
updated: 2026-10-08
parent: 0006-parallel-plan-conflicts
---

# Ship record — Pre-development plan publication and declared conflict record

- Branch: `feat/0006-parallel-plan-conflicts-0002-plan-record`
- PR: https://github.com/49115566/opencode-framework/pull/26
- Commits:
  - `65dca3c` docs(work): add 0006-parallel-plan-conflicts/0002-plan-record artifacts
  - `ce55cf5` docs(workflow): publish the plan before development and add the declaration home
  - `da14b39` docs(agent): author the declaration and publish the plan in architect, shipper, builder
  - `11a3f52` docs(command): add plan publication to plan, ship, and build
  - `73731c1` docs(skill): document the plan PR template and plan branch prefix

## Reconcile

- Result: no-op (already up to date)
- Resolved paths: none — at pre-flight `HEAD == origin/main == a489e2d` and the
  merge base equalled `origin/main`, so the `git merge-tree --write-tree
  --name-only HEAD origin/main` dry-run produced no conflicted paths and the
  `git merge --no-edit origin/main` merge was `Already up to date.`; no merge
  commit was created, no `work/` path needed resolution, and no renumber was
  required.
- Conflict detection: `no conflicts detected`. No duplicate top-level `NNNN` or
  per-parent `MMMM` prefix; the `0006`, `0005`, and `0004` roadmap `Depends on`
  graphs resolve to existing child directories and are acyclic; README
  inventory/count facts agree with disk (14 role prompts / 12 slash commands /
  11 knowledge skills; `tests/run.sh` AC9/AC20). Report-only guard note:
  `0003-framework-quality-hardening/0009-surface-consistency` is a deliberately
  withdrawn child documented in that roadmap's `## Open issues` (removed from the
  `Children` table; the number stays spent); it exists identically on
  `origin/main`, is not introduced by this branch, is not a merge collision, and
  the integrity guard is non-fatal and report-only.
- Re-verification: `bash tests/run.sh` → 285 passed, 0 failed, 0 skipped. The
  item suite `bash
  work/0006-parallel-plan-conflicts/0002-plan-record/verify-tests.sh` reported
  158 passed, 0 failed before commit; its `STRUCT` modified-surface assertion
  (`git diff --name-only HEAD`) is a pre-commit scope check and is expected to
  report a false failure once the change is committed — documented in
  `review.md` → Test quality and `verify.md`.
