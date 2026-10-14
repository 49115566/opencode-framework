---
feature: 0015-recursive-workflow-guards/0001-recursive-structure-guard
phase: ship
status: final
created: 2026-10-14
updated: 2026-10-14
parent: 0015-recursive-workflow-guards
---

# Ship record — Recursive model, reference, and allocation guard

- Branch: `test/0015-recursive-workflow-guards+0001-recursive-structure-guard`
- PR: https://github.com/49115566/opencode-framework/pull/95
- Commits:
  - `d287abd` test(recursive-structure-guard): pin recursive model, reference, and allocation
  - `4968d9e` docs(work): record build, verification, and review for 0015-recursive-workflow-guards/0001-recursive-structure-guard

## Reconcile

- Result: reconciled (fast-forward, no conflicts) — the item branch was a strict
  ancestor of `origin/main` (merge base `a006142` == HEAD); `git merge --no-edit
  origin/main` fast-forwarded to `ddda28c`, adding the sibling plan/ship
  artifacts under `work/0015-recursive-workflow-guards/{0002,0003,0004}/` and
  the sibling `0003` guard's `tests/**` changes. The merge touched `work/`
  paths, so the `work/` artifact reconcile re-ran: no duplicate top-level
  `NNNN`, no duplicate per-parent `MMMM` at any decomposing node, and every
  manifest `Depends on` resolves within its own `Children` table with an
  acyclic stored graph.
- Resolved paths:
  - none — the merge was a fast-forward with no conflict markers, preserving
    both branches' records in the merged tree.
- Re-verification: `bash tests/run.sh` → `588 passed, 0 failed, 0 skipped`;
  the item's area `AC27 recursive structure, reference, and allocation guard`
  → all 37 assertions `ok`.
- Pre-flight: no conflicts detected. `git merge-tree --write-tree --name-only
  HEAD origin/main` reported no conflicted paths (classes (a)/(b)); no duplicate
  top-level or per-parent sequence prefixes (class (c)); no manifest graph fault
  (class (b)); duplicated inventory/count facts agree (class (d)) — confirmed by
  the green full suite.
