---
feature: 0006-parallel-plan-conflicts/0004-conflict-guards
phase: ship
status: final
created: 2026-10-08
updated: 2026-10-08
parent: 0006-parallel-plan-conflicts
---

# Ship record — Committed guards for the declared-conflict model and check

- Branch: `feat/0006-parallel-plan-conflicts-0004-conflict-guards`
- PR: https://github.com/49115566/opencode-framework/pull/30
- Commits:
  - `d4cf1f1` test(fixtures): roll cyclic fixture onto the 6-column layout
  - `477e51b` test(fixtures): add the declared-conflicts fixture tree
  - `ff473f1` test(checks): add the AC23 declared-conflict guard area
  - `0d5328e` test(checks): cover the AC23 guards in the mutation self-check
  - `4d8d22e` docs(tests): document the AC23 conflict-guard area
  - `906a65c` test(work): record 0004 verification and review artifacts

## Reconcile

- Detection (read-only pre-flight): no conflicts detected. The item branch and
  `origin/main` had identical trees; `git merge-tree --write-tree` reported no
  conflicted paths; no duplicate top-level or per-parent sequence prefix, every
  roadmap `Depends on` resolved and acyclic, and the README inventory counts
  agreed with disk (14 agents / 13 commands / 11 skills). One pre-existing,
  documented observation: `work/0003-framework-quality-hardening/0009-surface-consistency`
  is a withdrawn child absent from its parent `Children` table (`UNLISTED-CHILD`,
  class `(b)`); it is present on `main` before this ship and is outside this item's
  changed set (report-only, not resolved here).
- Result: no-op (already up to date)
- Resolved paths:
  - none
- Re-verification: `bash tests/run.sh` → `TOTAL: 334 passed, 0 failed, 0 skipped`
  (exit 0, run after the commits); mutation self-check per `verify.md` →
  `39 checked passed, 0 failed` (not re-run in this session: the sandbox bash
  policy does not permit the opt-in `tests/mutation.sh`).
