---
feature: 0011-recursive-bootstrap/0002-recursive-schema
phase: ship
status: final
created: 2026-10-12
updated: 2026-10-12
parent: 0011-recursive-bootstrap
---

# Ship record — Recursive work-item schema, references, and sequence allocation

- Branch: `feat/0011-recursive-bootstrap-0002-recursive-schema`
- PR: https://github.com/49115566/opencode-framework/pull/55
- Commits:
  - `7e917ce` docs(artifact-conventions): generalize work-item schema to recursive references
  - `db9d848` docs(work): record tasks, verification, and review for 0011-recursive-bootstrap/0002-recursive-schema

## Reconcile

- Result: reconciled (fast-forward `7cf012d..4a74bb9`). The branch was one merge
  commit behind `origin/main` — the PR #54 merge that published this item's plan.
  `git merge --no-edit origin/main` fast-forwarded with no textual conflict.
- Resolved paths:
  - none — the merge touched no `work/` path, produced no conflict markers, and
    introduced no sequence-prefix collision; no renumber.
- Re-verification: `bash tests/run.sh` → `489 passed, 0 failed, 0 skipped`; the
  item's pinned single-source guards (`10-readiness`, `20-lifecycle`,
  `40-inventory`, `80-cycle-fixture`, `85-conflict-guards`,
  `87-backtrack-guards`, `96-signature-sweep`) → PASS.
