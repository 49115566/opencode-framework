---
feature: 0007-phase-backtracking/0004-roadmap-revision
phase: ship
status: final
created: 2026-10-08
updated: 2026-10-08
parent: 0007-phase-backtracking
---

# Ship record — Parent-roadmap revision from child phases

- Branch: `feat/0007-phase-backtracking-0004-roadmap-revision`
- PR: https://github.com/49115566/opencode-framework/pull/37
- Commits:
  - `040a915` docs(workflow): define the parent-roadmap revision route
  - `1b4596a` docs(artifact): document roadmap withdrawal and revision records
  - `32963bd` docs(agent): add the roadmap revise mode
  - `701c1d2` feat(command): add the revise form to /roadmap
  - `510b68a` docs(agent): route parent-roadmap findings to /roadmap revise
  - `cc87d6c` docs(status): recognize deliberate roadmap withdrawals
  - `4a7c702` docs(signature): extend the canonical /roadmap signature
  - `4458994` test(work): record 0004 verification and review artifacts
  - `4868ab8` Merge remote-tracking branch 'origin/main' into feat/0007-phase-backtracking-0004-roadmap-revision

## Reconcile

- Result: reconciled
- Resolved paths:
  - `.opencode/agent/architect.md` — class (a) shared-surface textual conflict.
    `origin/main` (0002-reverse-phase-routing) replaced the generic "If the spec
    is wrong … say so and route back" bullet with the `/plan`→`/spec` reverse-edge
    guidance, while this branch added a separate parent-roadmap bullet after it.
    Both branches' intents were preserved — main's replacement bullet plus the
    item's new parent-roadmap bullet, neither side's record dropped.
- Detection (read-only pre-flight): one class (a) `TEXTUAL-CONFLICT` on
  `.opencode/agent/architect.md`. `git merge-tree --write-tree --name-only HEAD
  origin/main` reported that single conflicted path. No class (b) `work/` fault,
  no class (c) sequence collision, and no class (d) drift: no duplicate top-level
  `NNNN` or per-parent `MMMM` prefix; the `0007-phase-backtracking` roadmap's
  `Depends on` graph resolves to existing child directories and is acyclic; the
  README inventory/count facts agree with disk (14 agents / 13 commands /
  11 skills).
- Merge base advanced from `117bbde` to `772d0ea` (`origin/main` gained the
  0002-reverse-phase-routing merge); the merge commit `4868ab8` is a forward
  merge, not a rebase, and was not force-pushed.
- Re-verification: `bash tests/run.sh` → `TOTAL: 340 passed, 0 failed, 0 skipped`
  (exit 0, run on the resolved merged tree before committing the merge); item
  checks per `verify.md` → all 15 AC PASS.
