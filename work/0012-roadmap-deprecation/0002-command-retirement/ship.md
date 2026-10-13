---
feature: 0012-roadmap-deprecation/0002-command-retirement
phase: ship
status: final
created: 2026-10-13
updated: 2026-10-13
parent: 0012-roadmap-deprecation
---

# Ship record — Retire the `/roadmap` command and agent; `/plan` becomes the sole recursive writer

- Branch: `docs/0012-roadmap-deprecation-0002-command-retirement`
- PR: https://github.com/49115566/opencode-framework/pull/66
- Commits:
  - `3e96d8b` docs: retire the /roadmap command and agent
  - `efef44e` docs: reconcile /plan signatures and inventories
  - `085e8fb` docs(work): record tasks, verification, and review for 0012-roadmap-deprecation/0002-command-retirement

## Conflict detection

- No conflicts detected. Merge base `d681251` (the plan-branch tip, already an
  ancestor of `origin/main` via PR #64); the ship branch is based on the current
  `origin/main` tip `1bd3679`. Pre-flight item-branch changed paths: none (the
  work was uncommitted); `origin/main` added
  `work/0012-roadmap-deprecation/0003-parent-migration/{spec,design,tasks}.md`;
  `git merge-tree --write-tree --name-only HEAD origin/main` reported no
  conflicted paths. Integrity: unique top-level/per-parent `work/` sequence
  prefixes, acyclic `0012` roadmap graph, README Layout counts agree with disk.

## Reconcile

- Result: no-op (already up to date)
- Resolved paths: none (no merge commit created)
- Re-verification: `bash tests/run.sh` → 482 passed, 0 failed, 0 skipped; the
  item's acceptance coverage in `verify.md` remains PASS (AC1–AC14)
