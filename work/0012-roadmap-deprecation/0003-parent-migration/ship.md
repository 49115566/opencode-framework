---
feature: 0012-roadmap-deprecation/0003-parent-migration
phase: ship
status: final
created: 2026-10-13
updated: 2026-10-13
parent: 0012-roadmap-deprecation
---

# Ship record — Existing-parent migration: grandfather the seven live nodes and migrate the test fixtures

- Branch: `docs/0012-roadmap-deprecation-0003-parent-migration`
- PR: https://github.com/49115566/opencode-framework/pull/67
- Commits:
  - `576f457` test: migrate decomposing-node fixtures to the manifest spelling
  - `b9c44cc` test: reconcile cycle, conflict, and backtrack guards to both spellings
  - `a46b5bc` test: repoint mutation jobs at the migrated manifest fixtures
  - `8125bda` docs: modernize manifest terminology in the test README
  - `3c35eca` docs(work): record build, verification, and review for 0012-roadmap-deprecation/0003-parent-migration
  - `64b1bca` Merge remote-tracking branch 'origin/main' into docs/0012-roadmap-deprecation-0003-parent-migration

## Reconcile

- Result: reconciled
- Resolved paths:
  - none — `git merge --no-edit origin/main` merged cleanly: the changed-path
    sets are disjoint. The merge added item `0002-command-retirement` artifacts
    under `work/0012-roadmap-deprecation/0002-command-retirement/` plus its
    `.opencode/`, docs, and inventory changes; none overlaps a path this item
    changed (this item touches only `tests/` and its own `work/` artifacts).
  - Re-scanned the merged `work/` tree: no duplicate top-level `NNNN`
    (`0001`–`0012`) and no duplicate per-parent `MMMM`
    (`0012` → `0001`–`0003`); no cross-branch prefix collision; no
    roadmap/manifest graph fault introduced.
- Re-verification: `bash tests/run.sh`
  → `TOTAL: 495 passed, 0 failed, 0 skipped` (post-merge); item checks
  (`80-cycle-fixture`/`85-conflict-guards`/`87-backtrack-guards` areas and
  `bash tests/mutation.sh` `29 checked passed, 0 failed`) green per `verify.md`.
