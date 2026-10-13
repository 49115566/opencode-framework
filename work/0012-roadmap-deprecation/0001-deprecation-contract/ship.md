---
feature: 0012-roadmap-deprecation/0001-deprecation-contract
phase: ship
status: final
created: 2026-10-13
updated: 2026-10-13
parent: 0012-roadmap-deprecation
---

# Ship record — Deprecation contract: the generic manifest replaces the special `roadmap` concept

- Branch: `docs/0012-roadmap-deprecation-0001-deprecation-contract`
- PR: https://github.com/49115566/opencode-framework/pull/63
- Commits:
  - `272662d` docs(workflow): retire the roadmap concept for the generic manifest
  - `5225d16` docs(work): record tasks, verification, and review for 0012-roadmap-deprecation/0001-deprecation-contract

## Conflict detection

- No conflicts detected.

## Reconcile

- Result: no-op (already up to date)
- Resolved paths: none (no merge commit created)
- Re-verification: `bash tests/run.sh` → 489 passed, 0 failed, 0 skipped; `git merge-tree --write-tree HEAD origin/main` → no conflicted paths
