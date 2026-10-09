---
feature: 0007-phase-backtracking/0006-status-and-derived-state
phase: ship
status: final
created: 2026-10-09
updated: 2026-10-09
parent: 0007-phase-backtracking
---

# Ship record — Status, derived state, and readiness for backtracked items

- Branch: `feat/0007-phase-backtracking-0006-status-and-derived-state`
- PR: https://github.com/49115566/opencode-framework/pull/43
- Commits:
  - `95ea127` docs(workflow): report derived states and scope challenge to unshipped
  - `ac1214f` docs(status): report backtracked, reopened, and challenged states
  - `c8f7281` docs(status): mirror derived-state reporting in the /status command
  - `d1fda22` docs(skill): add derived states section to workflow-lifecycle
  - `76f9f79` docs(work): record tasks, verification, and review for 0006

## Reconcile

- Result: no-op (already up to date)
- Pre-flight (read-only, against `origin/main` `f834067`, merge base `f834067`;
  `git merge-tree --write-tree --name-only HEAD origin/main` reported no
  conflicted paths): no conflicts detected.
  - No class (a) shared-surface conflict and no class (b) `work/` conflict.
  - No class (c) duplicate sequence number; top-level `work/` prefixes
    (`0001`–`0007`) and the per-parent `0007-phase-backtracking` child prefixes
    (`0001`–`0007`) are unique and match the default branch.
  - No class (d) derived-agreement drift; the roadmap `Depends on` graph resolves
    and is acyclic, and the README Layout counts agree with disk (14 agents,
    13 commands, 11 skills).
- Resolved paths: none (the branch was already up to date; no merge commit)
- Re-verification: `bash tests/run.sh` → `345 passed, 0 failed, 0 skipped`
  (exit 0); item checks (AC1–AC12 surface inspection) → green.
