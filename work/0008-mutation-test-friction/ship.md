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
- Commits: `de7f1f9` feat(tests): add area subset selection and lazy optional-tool probes; `073438d` perf(tests): area-scope and parallelize the mutation self-check; `e9c7f36` docs(tests): document area selection and the mutation policy; `dad31af` docs(work): record tasks, verification, and review for 0008-mutation-test-friction; `0f4ad5c` Merge origin/main into feat/0008-mutation-test-friction (reconcile)

## Reconcile

- Result: reconciled
- Resolved paths:
  - `tests/mutation.sh` — class (a) shared-surface textual conflict. Kept the
    item's area-scoped job runner and ported main's two new AC25 mutation blocks
    into it as `job_28`/`job_29` (area `25-review-severity-bar`), bumping
    `JOB_COUNT` 27 → 29. Both branches' intent is preserved: main's new AC25
    coverage and the item's restructured runner.
  - `tests/README.md` — auto-merged; main's `25-review-severity-bar.sh` Checks
    row and AC25 note are kept alongside the item's section, lazy-probe, and
    mutation-policy additions.
- Re-verification: `bash tests/run.sh` → 489 passed, 0 failed, 0 skipped
  (exit 0). The item's mutation checks (`bash tests/mutation.sh`, `--selftest`)
  are not runnable in this sandbox (not in the bash allow-list); the ported
  `job_28`/`job_29` reproduce main's AC25 mutation blocks verbatim and the
  `25-review-severity-bar` area passes green in the canonical suite.
