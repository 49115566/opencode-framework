---
feature: 0006-parallel-plan-conflicts/0001-conflict-declaration-model
phase: ship
status: final
created: 2026-10-08
updated: 2026-10-08
parent: 0006-parallel-plan-conflicts
---

# Ship record — Declared planning-time conflict model and `conflicts-with` column

- Branch: `feat/0006-parallel-plan-conflicts-0001-conflict-declaration-model`
- PR: https://github.com/49115566/opencode-framework/pull/25
- Commits:
  - `d040656` docs(workflow): define the declared conflicts-with model
  - `650fb9c` docs(artifact): add a conflicts-with column to the roadmap template
  - `33712b7` docs(agent): document conflicts-with in the roadmap prompt
  - `9e24005` docs(command): document conflicts-with in the roadmap command
  - `3ba5177` docs(work): add 0006-parallel-plan-conflicts/0001-conflict-declaration-model artifacts

## Reconcile

- Result: no-op (already up to date)
- Resolved paths: none — at pre-flight `HEAD == origin/main == f16be1c` and the
  merge base equalled `origin/main`, so the dry-run produced no conflicted paths
  and no merge commit was created; no `work/` path needed resolution and no
  renumber was required.
- Conflict detection: `no conflicts detected`. No duplicate top-level `NNNN` or
  per-parent `MMMM` prefix; the `0006-parallel-plan-conflicts` roadmap's
  `Depends on` graph resolves to existing child directories and is acyclic;
  README inventory/count facts agree with disk.
- Re-verification: `bash tests/run.sh` → 285 passed, 0 failed, 0 skipped;
  `bash work/0006-parallel-plan-conflicts/0001-conflict-declaration-model/verify-tests.sh`
  → 79 passed, 0 failed.
