---
feature: 0005-merge-conflict-workflow/0003-shared-surface-reconcile
phase: ship
status: final
created: 2026-10-07
updated: 2026-10-07
parent: 0005-merge-conflict-workflow
---

# Ship record — Reconcile workflow for shared framework surfaces

- Branch: `feat/0005-merge-conflict-workflow-0003-shared-surface-reconcile`
- PR: https://github.com/49115566/opencode-framework/pull/21
- Commits:
  - `369755e` docs(skill): make the merge-conflict reconcile step executable
  - `2c234ba` docs(ship): grant the shipper reconcile authority and wire the process
  - `606ecd2` docs(ship): record the reconcile in ship.md and the PR template
  - `943a9f7` docs(ship): add the reconcile step to the /ship command
  - `1b98d6a` test(work): add the shared-surface reconcile verification suite
  - `43a681f` docs(work): add 0005-merge-conflict-workflow/0003-shared-surface-reconcile artifacts

## Reconcile

- Result: no-op (already up to date)
- Resolved paths: none
- Re-verification: `bash tests/run.sh` → 285 passed, 0 failed, 0 skipped (from
  `verify.md`); `bash work/0005-merge-conflict-workflow/0003-shared-surface-reconcile/verify-tests.sh`
  → 185 passed, 0 failed (from `verify.md`). The suites were not re-run in the
  ship session because its sandbox permits only git/gh read commands.
