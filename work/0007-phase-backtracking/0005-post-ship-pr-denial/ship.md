---
feature: 0007-phase-backtracking/0005-post-ship-pr-denial
phase: ship
status: final
created: 2026-10-09
updated: 2026-10-09
parent: 0007-phase-backtracking
---

# Ship record — Post-ship PR denial, recall, and reopen

- Branch: `feat/0007-phase-backtracking-0005-post-ship-pr-denial`
- PR: https://github.com/49115566/opencode-framework/pull/41
- Commits:
  - `4fdcdc9` docs(workflow): define the post-ship recall and reopen route
  - `8a408bf` docs(agent): add post-ship recall and re-ship to the shipper
  - `a9bc904` docs(agent): honor recalled readiness and wire /build re-entry
  - `31f7c8b` docs(skill): route post-ship denials to /ship recall
  - `35a6ac8` test(checks): pin the /ship recall usage signature
  - `cd6c7ea` docs(work): record 0005 tasks, verification, and review
  - `8150764` Merge remote-tracking branch 'origin/main' into feat/0007-phase-backtracking-0005-post-ship-pr-denial

## Reconcile

- Result: reconciled
- Pre-flight (read-only, against `origin/main` `72bc5a9`, merge base `f74fbdf`):
  - `[TEXTUAL-CONFLICT] (a) .opencode/agent/builder.md` — both branches add to the operating principles and the process step list.
  - No class (b) `work/` conflict; our `0005` child is disjoint from the merged `0003` child.
  - No class (c) duplicate sequence number; top-level and per-parent `work/` prefixes are unique and match the default branch.
  - No class (d) drift; the roadmap `Depends on` graph resolves and is acyclic.
- Resolved paths:
  - `.opencode/agent/builder.md` — union preserving both branches' intent: kept the `0005` re-entry operating-principle bullet and the new process step 2, and the merged `0003` challenge operating-principle bullet and challenge process step, renumbering the subsequent process steps.
- Re-verification: `bash tests/run.sh` → `345 passed, 0 failed, 0 skipped` (exit 0); item checks (AC1–AC14 surface inspection) → green.
