---
feature: 0006-parallel-plan-conflicts/0001-conflict-declaration-model
phase: tasks
status: final
created: 2026-10-08
updated: 2026-10-08
parent: 0006-parallel-plan-conflicts
notes: "T5 read-only consistency pass: one authoritative grammar in docs/workflow.md → \"Declared conflicts\"; artifact template note, agent prompt, and command all reference it and none restate a conflicting grammar. Positional consumer tests/checks/80-cycle-fixture.sh reads Depends on at field 5; fixture still five-column, so no consumer moved. No consistency correction required."
---

# Tasks — Declared planning-time conflict model and `conflicts-with` column

Ordered, dependency-aware. One task ≈ one focused commit. This item changes
documents and prompts only; test guards are child `0004-conflict-guards` and
reporting is child `0003-conflict-check`.

- [x] **T1** — Add the authoritative declared-conflict model to
      `docs/workflow.md`. Insert a new `### Declared conflicts (conflicts-with)`
      subsection inside `## Roadmaps`, after `### Dependencies and readiness`
      (currently ends at `:108`) and before `### Status reporting` (`:110`). State:
      the planning-time conflict definition as a declared, committed claim
      distinct from `## Merge conflicts` and from `Depends on`; the
      `ConflictTargetList` grammar (three target kinds — sibling local id,
      canonical work-item reference, exact repository-relative surface path — with
      comma separation, `—` empty value, absent-column-means-none, empty cell
      malformed); the reference-vs-path discriminator and sibling-first resolution
      precedence; no self-reference and no duplicate target; the advisory rule
      that it adds no readiness edge and does not affect readiness; one-sided
      declaration semantics; that unresolved declarations are reported later and
      never dropped; and that declared conflicts reuse the shipped `(a)`–`(d)`
      classes and finding-line grammar with no new class, code, or policy. Do not
      edit `## Merge conflicts` or the readiness algorithm. [AC1, AC3, AC4, AC5,
      AC6, AC7, AC8, AC10, AC11, AC12]
      Verify: `rg -n '^### Declared conflicts|ConflictTargetList|conflicts-with|no new class' docs/workflow.md` shows the subsection; reading it confirms all three target kinds, the absence/empty rules, the advisory rule, the one-sided rule, the unresolved rule, and the `(a)`–`(d)` reference; `bash tests/run.sh` exits 0.

- [x] **T2** — Add the `conflicts-with` column to the roadmap **template** and its
      notes in `docs/artifact-conventions.md`. Change the header at `:110` to
      `| Local id | Title | Scope | Depends on | conflicts-with | Canonical reference |`,
      add a `conflicts-with` value (`—`) to both example rows (`:112-113`), and add
      a column note after `:133` that states the column declares the targets the
      row expects to collide with, that `—` means none, and that the grammar is
      defined in `docs/workflow.md` → "Declared conflicts" (reference the
      authority rather than restate it). Do not decide where an item-level
      declaration is stored. [AC2, AC3, AC12] [depends: T1]
      Verify: `rg -n 'conflicts-with' docs/artifact-conventions.md` shows the header, the example rows, and the note; reading the note confirms it explains the column meaning and the empty value and points to the workflow authority; `bash tests/run.sh` exits 0 (the fixture is unchanged and still parses).

- [x] **T3** — Describe the `conflicts-with` column in the roadmap **agent**
      prompt `.opencode/agent/roadmap.md`: in the process step that records
      `Depends on` (`:77-82`), add that each row may optionally declare its
      `conflicts-with` targets using the grammar in `docs/workflow.md` →
      "Declared conflicts", using `—` when none, and that the declaration is
      advisory and never changes `Depends on` or readiness; add a matching
      quality-bar check (`:104-120`) that every `conflicts-with` cell is `—` or
      well-formed and names no self or duplicate target. Keep the wording
      consistent with the authority; state no conflicting grammar. [AC9, AC12]
      [depends: T1]
      Verify: `rg -n 'conflicts-with' .opencode/agent/roadmap.md` shows the process step and the quality-bar check; reading them confirms they reference `docs/workflow.md` and match the authority grammar.

- [x] **T4** — Describe the `conflicts-with` column in the roadmap **command**
      `.opencode/command/roadmap.md` (`:10-23`): add a bullet that a roadmap row
      may declare the targets it expects to collide with in a `conflicts-with`
      cell per `docs/workflow.md` → "Declared conflicts" (`—` when none, advisory,
      no readiness effect). Keep the wording consistent with the authority;
      state no conflicting grammar. [AC9, AC12] [depends: T1]
      Verify: `rg -n 'conflicts-with' .opencode/command/roadmap.md` shows the bullet; reading it confirms it references `docs/workflow.md` and matches the authority grammar.

- [x] **T5** — Cross-surface consistency and regression gate. Read the three
      vocabulary surfaces together (`docs/workflow.md` → "Declared conflicts",
      `docs/artifact-conventions.md` template + note,
      `.opencode/agent/roadmap.md` + `.opencode/command/roadmap.md`) and confirm
      one authoritative grammar with the others referencing it and no surface
      stating a conflicting column grammar. Confirm the positional analysis:
      `tests/checks/80-cycle-fixture.sh`'s `Depends on` field index is unchanged
      and no positional consumer needed to move. No file edit is expected beyond
      any consistency correction this read surfaces (record it in the task note if
      it does). [AC6, AC10, AC12] [depends: T2, T3, T4]
      Verify: `rg -n 'conflicts-with' docs/workflow.md docs/artifact-conventions.md .opencode/agent/roadmap.md .opencode/command/roadmap.md` and a read-through show agreement; `bash tests/run.sh` exits 0.
