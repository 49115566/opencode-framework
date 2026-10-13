---
feature: 0013-simultaneous-work-recursion/0003-recursive-conflicts
phase: ship
status: final
created: 2026-10-13
updated: 2026-10-13
parent: 0013-simultaneous-work-recursion
---

# Ship record — Recursive `conflicts-with` at every level

- Branch: `docs/0013-simultaneous-work-recursion+0003-recursive-conflicts`
- PR: https://github.com/49115566/opencode-framework/pull/75
- Commits: `0b3c0c9` docs: generalize conflicts-with targets to arbitrary depth;
  `f1eca8c` docs(work): record build, verification, and review for
  0013-simultaneous-work-recursion/0003-recursive-conflicts

## Reconcile

- Result: reconciled — the branch was behind the default branch and was merged
  forward with `git merge --no-edit origin/main`, which auto-merged cleanly.
- Resolved paths:
  - (none) — `docs/workflow.md` and `docs/artifact-conventions.md` auto-merged
    without conflict markers, preserving both branches' edits: this item's
    declared-conflict generalization (`docs/workflow.md` "Declared conflicts
    (`conflicts-with`)" / "Declared-conflict check"; `docs/artifact-conventions.md`
    manifest `conflicts-with` bullet) and the default branch's plan-publication,
    build-plan-gate, multiple-work-items, and allocation edits.
- Pre-flight: default branch `main`; merge base `8518956`; `git merge-tree
  --write-tree --name-only HEAD origin/main` returned a clean merged tree with no
  conflicted paths; framework integrity found no duplicate top-level or per-parent
  4-digit prefixes and no roadmap dependency faults (post-merge re-scan clean).
- Re-verification: `bash tests/run.sh` → `495 passed, 0 failed, 0 skipped`
  (includes the `85-conflict-guards` declared-conflict area).
