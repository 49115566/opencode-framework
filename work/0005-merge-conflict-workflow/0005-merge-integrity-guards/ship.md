---
feature: 0005-merge-conflict-workflow/0005-merge-integrity-guards
phase: ship
status: final
created: 2026-10-07
updated: 2026-10-07
parent: 0005-merge-conflict-workflow
---

# Ship record — Merge-integrity guard as a portable behavior contract

- Branch: `feat/0005-merge-conflict-workflow-0005-merge-integrity-guards`
- PR: https://github.com/49115566/opencode-framework/pull/23
- Commits:
  - `631fa36` docs(workflow): state the merge-integrity guard contract
  - `5b1e812` docs(skill): point the merge-conflict skill at the guard contract
  - `992917b` docs(agent): make status the guard's read-only window
  - `44f12a5` docs(agent): make the shipper post-merge pass report-only
  - `1dc1fdc` docs(work): generalize the reconcile re-verification template
  - `756cf38` docs(work): add 0005-merge-conflict-workflow/0005-merge-integrity-guards artifacts

## Reconcile

- Result: no-op (already up to date)
- Resolved paths: none
- Re-verification: `bash tests/run.sh` (the repository's own configured test command — the Project profile `Test:` value) → 285 passed, 0 failed, 0 skipped, exit 0; item checks (read-only surface inspection per `verify.md`) → PASS
