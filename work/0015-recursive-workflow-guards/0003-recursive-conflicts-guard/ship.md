---
feature: 0015-recursive-workflow-guards/0003-recursive-conflicts-guard
phase: ship
status: final
created: 2026-10-14
updated: 2026-10-14
parent: 0015-recursive-workflow-guards
---

# Ship record — Recursive declared-conflicts guard

- Branch: `test/0015-recursive-workflow-guards+0003-recursive-conflicts-guard`
- PR: https://github.com/49115566/opencode-framework/pull/93
- Commits:
  - `05189ca` test(conflict-guards): pin the recursive declared-conflicts check
  - `1758e12` docs(work): record build, verification, and review for 0015-recursive-workflow-guards/0003-recursive-conflicts-guard

## Reconcile

- Result: reconciled (fast-forward, no conflicts) — the item branch was a strict ancestor of
  `origin/main` (merge base `8d1a35e` == HEAD); `git merge --no-edit origin/main`
  fast-forwarded to `43382b1`, adding only the sibling plan artifacts under
  `work/0015-recursive-workflow-guards/{0001,0002,0004}/`. The merge touched
  `work/` paths, so the `work/` artifact reconcile re-ran: no duplicate
  top-level `NNNN`, no duplicate per-parent `MMMM` at any decomposing node, and
  every manifest `Depends on` resolves within its own `Children` table with an
  acyclic stored graph.
- Resolved paths:
  - none — the merge was a fast-forward with no conflict markers, preserving both
    branches' records in the merged tree.
- Re-verification: `bash tests/run.sh` → `551 passed, 0 failed, 0 skipped`;
  `FRAMEWORK_TEST_AREAS=85-conflict-guards bash tests/run.sh` → `97 passed,
  0 failed, 0 skipped` (all 11 `AC23 recursive-*` labels `ok`).
- Pre-flight: no conflicts detected. `git merge-tree --write-tree HEAD
  origin/main` reported no conflicted paths (classes (a)/(b)); no duplicate
  top-level or per-parent sequence prefixes (class (c)); no manifest graph fault
  (class (b)); duplicated inventory/count facts agree (class (d)) — confirmed by
  the green full suite.
