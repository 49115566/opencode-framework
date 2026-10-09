---
feature: 0007-phase-backtracking/0001-backtracking-model
phase: tasks
status: final
created: 2026-10-08
updated: 2026-10-08
parent: 0007-phase-backtracking
---

# Tasks — Phase-backtracking and revision model

Ordered, dependency-aware. One task ≈ one focused commit. This item edits three
documentation surfaces only (`docs/workflow.md`, `docs/artifact-conventions.md`,
`AGENTS.md`); it adds no command, agent, skill, fixture, or runtime dependency.

- [x] **T1** — In `docs/workflow.md`, insert a new `## Phase reversal (backtracking)` section immediately before `## Derived state`: the definition of a backtrack and its distinction from forward progression and from plan-publication revision; the general later→earlier rule; the sanctioned-edge table (`/build`→`/plan`, `/plan`→`/spec`, `/test`→`/build`, `/test`→`/plan`, `/test`→`/spec`, `/review`→`/build`, any child phase→parent `roadmap.md`); the full exception list (no self-target, shipped excluded, strictly earlier target, `roadmap` only for a nested child's parent, a recorded finding precedes the edge, the detector never edits the target artifact); the ownership rule; the non-destructive `stale:` marking and forward re-run; and the shipped-exclusion/reopen handoff. State it once as the single authority; add no command signature or table row outside this section. [AC1, AC2, AC3, AC5, AC10]
      Verify: read the new section; `grep -n 'Phase reversal (backtracking)' docs/workflow.md` returns the heading; confirm all seven edges and every exception appear in the section.

- [x] **T2** — In `docs/artifact-conventions.md`, document the per-item record and the markers: add optional `stale: <phase>` and `reopened: <phase>` fields to the Frontmatter block (kept distinct from `status`); add a `backtracks.md` record template under Templates with the minimal distinct frontmatter (`feature`, `record: backtracks`, `created`, `updated` — no `phase`) and the append-only `Finding <n>` / `Resolution <n>` entry shapes and effective-status rule; and state that the record is not a phase artifact. [AC4, AC5, AC7] [depends: T1]
      Verify: read the Frontmatter block and the new template; `grep -n 'backtracks.md' docs/artifact-conventions.md` returns the record section; confirm no `phase:` appears in the record frontmatter.

- [x] **T3** — In `docs/workflow.md` → `## Derived state`, add the two precedence rows (earliest `stale:` marker → `<phase> (backtracked)`; `ship.md` present with a `reopened:` marker → `<phase> (reopened)`) above the artifact-presence rows, add the precedence note (stale is never a satisfied prerequisite, `roadmap` maps to `spec`), and present the existing `review.md` verdict `request-changes` → `build (rework)` row as the pre-existing instance of the model without altering that row or defining a second mechanism. [AC6, AC7, AC8] [depends: T1]
      Verify: `grep -n 'review.md` verdict `request-changes`' docs/workflow.md` still matches the unchanged row; read the added rows and precedence note.

- [x] **T4** — In `docs/workflow.md` → `## Failure and rollback`, reword the "route back" clause to reference `## Phase reversal (backtracking)` as the sanctioned route, leaving the three rules in force (report failures, never rewrite another phase's artifact to hide a failure, destructive git recovery requires confirmation). [AC9] [depends: T1]
      Verify: read the section; confirm the report-failures and destructive-recovery clauses are unchanged apart from the reworded route-back clause.

- [x] **T5** — In `AGENTS.md` → `## Working agreements`, add one prose bullet cross-referencing the model (`docs/workflow.md` → "Phase reversal (backtracking)") and the never-edit-another-phase's-artifact rule. Add no lifecycle-table row and no token to the `Supporting commands:` line. [AC10, AC11] [depends: T1]
      Verify: read the bullet; `grep -n 'Phase reversal (backtracking)' AGENTS.md` matches; `git diff AGENTS.md` shows no change to a table row or the supporting-commands list.

- [x] **T6** — Verify the whole change: run the suite, confirm no surface states a conflicting reverse-transition rule, confirm inventories are unchanged, and confirm the diff is limited to the three documentation surfaces. [AC11, AC12] [depends: T1, T2, T3, T4, T5]
      Verify: `bash tests/run.sh` → exit 0 with `TOTAL: … 0 failed` (in particular `20-lifecycle.sh`, `40-inventory.sh`, `96-signature-sweep.sh` green); `git diff --stat` lists only `docs/workflow.md`, `docs/artifact-conventions.md`, and `AGENTS.md`; `grep -rn` the three surfaces for any rival reverse-transition rule finds none.
