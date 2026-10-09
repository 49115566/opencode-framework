---
feature: 0007-phase-backtracking/0004-roadmap-revision
phase: ship
status: final
created: 2026-10-08
updated: 2026-10-08
parent: 0007-phase-backtracking
---

# Ship record — Parent-roadmap revision from child phases

- Branch: `feat/0007-phase-backtracking-0004-roadmap-revision`
- PR: https://github.com/49115566/opencode-framework/pull/37
- Commits:
  - `040a915` docs(workflow): define the parent-roadmap revision route
  - `1b4596a` docs(artifact): document roadmap withdrawal and revision records
  - `32963bd` docs(agent): add the roadmap revise mode
  - `701c1d2` feat(command): add the revise form to /roadmap
  - `510b68a` docs(agent): route parent-roadmap findings to /roadmap revise
  - `cc87d6c` docs(status): recognize deliberate roadmap withdrawals
  - `4a7c702` docs(signature): extend the canonical /roadmap signature
  - `4458994` test(work): record 0004 verification and review artifacts

## Reconcile

- Result: no-op (already up to date)
- Resolved paths: none — at pre-flight `HEAD == origin/main == 117bbde` and the
  merge base equalled `origin/main`, so the dry-run produced no conflicted paths
  and no merge commit was created; no `work/` path needed resolution and no
  renumber was required.
- Detection (read-only pre-flight): no conflicts detected. `git merge-tree
  --write-tree --name-only HEAD origin/main` reported no conflicted paths. No
  duplicate top-level `NNNN` or per-parent `MMMM` prefix; the
  `0007-phase-backtracking` roadmap's `Depends on` graph resolves to existing
  child directories and is acyclic; the README inventory/count facts agree with
  disk (14 agents / 13 commands / 11 skills).
- Re-verification: `bash tests/run.sh` → `TOTAL: 335 passed, 0 failed, 0 skipped`
  (exit 0, run after the commits); item checks per `verify.md` → all 15 AC PASS.
