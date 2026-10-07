---
feature: 0006-parallel-plan-conflicts
phase: ship
status: final
created: 2026-10-07
updated: 2026-10-07
notes: "Shipped on branch feat/0006-parallel-plan-conflicts. Pre-flight found no merge conflicts (branch up to date with origin/main); one pre-existing, documented, non-fatal UNLISTED-CHILD integrity finding in 0003-framework-quality-hardening is recorded and not introduced by this item."
---

# Ship record — Parallel-development plan conflicts and a `Conflicts with` roadmap column

- Branch: `feat/0006-parallel-plan-conflicts`
- PR: https://github.com/49115566/opencode-framework/pull/24
- Commits:
  - `3701793` docs(workflow): add the parallel-development plan-conflicts contract
  - `f107265` docs(roadmap): record the Conflicts with column in the roadmap surfaces
  - `08f7dd7` docs(status): report invalid Conflicts with references
  - `e75c772` docs(build): run the pre-development plan-conflict check
  - `9d1424e` docs: surface the plan-conflicts contract to adopters
  - `881a7e6` docs(work): add 0006-parallel-plan-conflicts artifacts

## Conflict detection

Read-only pre-flight against the default branch `main` (`origin/HEAD` and
`gh repo view` agree). Merge base = HEAD = `origin/main` = `f16be1ce`; both side
path-diffs are empty and the `git merge-tree --write-tree` dry-run reported no
conflicted paths. Framework-integrity checks: no duplicate top-level sequence
prefix, no duplicate per-parent child number, no dangling or cyclic roadmap
dependency, no derived-agreement drift, and no cross-branch prefix collision.

- Result: **no conflicts detected**, with one pre-existing, non-fatal integrity
  finding (not introduced by this item; documented as a deliberate withdrawal in
  `0003-framework-quality-hardening`'s `## Open issues`):
  - `[UNLISTED-CHILD] (b) 0003-framework-quality-hardening/0009-surface-consistency — child directory present but absent from the Children table`

## Reconcile

- Result: no-op (already up to date)
- Resolved paths: none — the merge base equals `origin/main`, so no merge commit
  was created and no path needed resolution.
- Re-verification: `bash tests/run.sh` → `285 passed, 0 failed, 0 skipped`
  (exit 0); item suite `bash work/0006-parallel-plan-conflicts/verify-tests.sh`
  → `144 passed, 0 failed` (exit 0).
