---
feature: 0008-mutation-test-friction
phase: ship
status: final
created: 2026-10-12
updated: 2026-10-12
---

# Ship record — Reduce mutation-test harness friction

- Branch: `feat/0008-mutation-test-friction`
- PR: https://github.com/49115566/opencode-framework/pull/51
- Commits: `de7f1f9` feat(tests): add area subset selection and lazy optional-tool probes; `073438d` perf(tests): area-scope and parallelize the mutation self-check; `e9c7f36` docs(tests): document area selection and the mutation policy; `dad31af` docs(work): record tasks, verification, and review for 0008-mutation-test-friction

## Reconcile

- Result: no-op (already up to date)
- Resolved paths:
  - none
- Re-verification: `bash tests/run.sh` → 448 passed, 0 failed, 0 skipped (exit 0); item checks `bash tests/mutation.sh` and `bash tests/mutation.sh --selftest` → exit 0 (recorded in `verify.md`)
