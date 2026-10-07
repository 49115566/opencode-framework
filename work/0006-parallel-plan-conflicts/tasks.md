---
feature: 0006-parallel-plan-conflicts
phase: tasks
status: final
created: 2026-10-07
updated: 2026-10-07
notes: "Ordered, dependency-aware. T1-T5 are the contract chain (roadmap column → declaration format → vocabulary → workflow authority); T6-T8 wire the operational surfaces; T9 is the item-level acceptance gate. No task adds a script, command, agent, skill, or committed test area. Every task's Verify is read-only."
---

# Tasks — Parallel-development plan conflicts and a `Conflicts with` roadmap column

Ordered, dependency-aware. One task ≈ one focused commit. T1-T5 edit the
contract authority and are sequential where they share a file; T6-T8 consume the
finished contract.

- [x] **T1** — Add the `Conflicts with` column to the roadmap `Children` table
      contract. In `docs/artifact-conventions.md` → `### roadmap.md` change the
      `## Children` header to append `| Conflicts with |` after
      `| Canonical reference |` (append-only, never between `Depends on` and
      `Canonical reference`), add the matching separator segment, put `—` in the
      example rows, and add a `Conflicts with` bullet after the `Depends on`
      bullet: sibling local ids only, comma-separated or `—`, intra-roadmap
      only, a row may not name itself, and it never affects readiness or the
      dependency graph. In `docs/workflow.md` → `## Roadmaps` describe the
      `Conflicts with` column and in `### Dependencies and readiness` add one
      sentence stating a `Conflicts with` entry never changes a child's
      readiness or its place in the dependency graph. [AC1] [AC3]
      Verify: `grep -n '| Local id | Title | Scope | Depends on | Canonical reference | Conflicts with |' docs/artifact-conventions.md`; grep the `Conflicts with` column bullet and the readiness-neutral sentence in `docs/workflow.md`; `bash tests/run.sh` exits 0 with no `FAIL` line (notably AC6 readiness and AC13 fixture stay green).

- [x] **T2** — Update the roadmap authoring surfaces and the committed fixture.
      In `.opencode/agent/roadmap.md`: process step 5 also records each child's
      `Conflicts with` value (sibling local ids or `—`; no self-reference; every
      name must resolve to another row), the quality bar gains a check that each
      `Conflicts with` value resolves and is acyclic-independent, and the rules
      forbid storing a self-conflict. In `.opencode/command/roadmap.md` add the
      `Conflicts with` cell to the Children-table bullet. In
      `tests/fixtures/cyclic-roadmap/roadmap.md` append `| Conflicts with |` to
      the `Children` header, add the separator segment, and set every row's cell
      to `—`. Do not edit `tests/checks/80-cycle-fixture.sh`; the appended column
      keeps its fixed-substring header assertion and its `Depends on` field
      index `a[5]` intact. [AC1] [AC15] [depends: T1]
      Verify: `grep -n 'Conflicts with' .opencode/agent/roadmap.md .opencode/command/roadmap.md tests/fixtures/cyclic-roadmap/roadmap.md`; `awk` field 5 of each fixture data row is still the `Depends on` value; `bash tests/run.sh` exits 0 with no `FAIL AC13` line.

- [x] **T3** — Add the `## Surface declaration` format to `design.md`. In
      `docs/artifact-conventions.md` → `### design.md` insert an optional
      `## Surface declaration` section after `## Approach`, containing a bullet
      list of repository-relative paths (example entries), and add prose
      defining the grammar: one path per bullet, no leading `/` and no `..`,
      optional backticks, a trailing `/` is a directory entry covering every
      path beneath it, and an absent or empty section means the item declares no
      surfaces. [AC5]
      Verify: `grep -nE '^## Surface declaration' docs/artifact-conventions.md` inside the design template; read the section and confirm the directory rule, the no-leading-slash rule, and the absent/empty meaning are stated; `bash tests/run.sh` exits 0.

- [x] **T4** — Extend the canonical finding vocabulary in
      `.opencode/skill/merge-conflict/SKILL.md` (the table at `:109-127` and the
      surrounding "pre-flight vocabulary" prose) with `DANGLING-CONFLICT` `(b)`
      (a `Conflicts with` local id that resolves to no other row in the same
      Children table, or names its own row), `DECLARED-CONFLICT` `(b)` (two
      ready in-flight items where one plan declares a `Conflicts with` edge
      naming the other), and `SURFACE-OVERLAP` `(a)`/`(b)` (two ready in-flight
      items declare the same concrete path, an ancestor/descendant directory
      overlap, or the same shared framework surface; class `(b)` when both
      entries are under `work/`, otherwise `(a)`). Mark `DECLARED-CONFLICT` and
      `SURFACE-OVERLAP` pre-development-only, like `TEXTUAL-CONFLICT` is
      pre-flight-only, and point at `docs/workflow.md` → `## Parallel-development
      plan conflicts` as the check's authority. Change no existing merge-time
      code or procedure. [AC10]
      Verify: `grep -n 'DANGLING-CONFLICT\|DECLARED-CONFLICT\|SURFACE-OVERLAP' .opencode/skill/merge-conflict/SKILL.md` names all three with class labels; grep the pre-development-only note; `bash tests/run.sh` exits 0 (the skill is not directly asserted, so this is a no-regression check).

- [x] **T5** — Add the normative `## Parallel-development plan conflicts`
      section to `docs/workflow.md`, placed after `## Merge conflicts` and
      before `## Resuming and interruption` (before `:439`). Use `##`/`### `
      non-numbered headings only (never `### N. `). The section must contain:
      the ready in-flight comparison universe (has `design.md`, has no
      `ship.md`, is ready — standalone, or a nested child whose `Depends on` are
      satisfied and which is not in a cycle; shipped and blocked/cyclic items
      excluded); the `/build` trigger as a step before implementation; the three
      detection conditions (a declared `Conflicts with` edge between ready
      in-flight siblings, symmetric and tolerant of one or both directions; the
      same concrete path or an ancestor/descendant directory overlap; the same
      shared framework surface class); the finding grammar
      `- [<CODE>] (<class>) <offender canonical reference(s)> — <detail>` and
      the three codes deferring to the `merge-conflict` skill as canonical
      (`DANGLING-CONFLICT`, `DECLARED-CONFLICT`, `SURFACE-OVERLAP`); the
      report-only contract (non-fatal, read-only, takes no lock, modifies no
      file, auto-repairs nothing, never blocks the build, no finding dropped or
      truncated); the no-declaration/empty-coverage no-error path; and the
      build-handoff recording requirement. [AC5] [AC6] [AC7] [AC8] [AC9] [AC10]
      [AC11] [AC12] [AC13] [depends: T1, T3, T4]
      Verify: `grep -nE '^## Parallel-development plan conflicts|^### Surface declaration|^### Comparison universe|^### Detection|^### Finding vocabulary|^### Report-only contract' docs/workflow.md`; grep `ready in-flight`, `ship.md`, the three detection conditions, `DECLARED-CONFLICT`, `SURFACE-OVERLAP`, `DANGLING-CONFLICT`, `modifies no file`, `never blocks`, and the no-declaration no-error literal; `grep -nE '^### [0-9]+[.] ' docs/workflow.md` shows no new numbered heading; `bash tests/run.sh` exits 0 (20-lifecycle and 96-signature-sweep green).

- [x] **T6** — Add `Conflicts with` validation to `/status`. In
      `.opencode/agent/status.md`: extend process step 4 to validate each
      `Conflicts with` cell against the same `Children` table (each name
      resolves to another row; no self-reference), add `DANGLING-CONFLICT` `(b)`
      to the `<findings>` list with its definition — the finding names the
      roadmap, the offending row, and the invalid reference, and the roadmap is
      neither rejected nor aborted — add an example line to `<output_format>`,
      and add the validation to the `<quality_bar>`. Confirm
      the report stays offline, read-only, and file-modifying-free. In
      `.opencode/command/status.md` add one bullet naming `DANGLING-CONFLICT`
      for invalid `Conflicts with` references. [AC2] [AC4] [depends: T1, T4]
      Verify: `grep -n 'DANGLING-CONFLICT' .opencode/agent/status.md .opencode/command/status.md`; grep the invalid-reference and non-fatal/offline/read-only literals; `bash tests/run.sh` exits 0 (80-cycle-fixture's `CYCLIC-DEP` and non-fatal literals stay present).

- [x] **T7** — Wire the pre-development check into the builder. In
      `.opencode/agent/builder.md`: add a `<process>` step after task selection
      and before implementation that runs the check per `docs/workflow.md` →
      `## Parallel-development plan conflicts` — read the current item's
      `## Surface declaration`, enumerate the ready in-flight universe, report
      declared edges (`DECLARED-CONFLICT`) and surface overlaps
      (`SURFACE-OVERLAP`) or that a peer could not be compared, and continue
      regardless; add a `Plan conflicts:` line to the `<handoff>` block naming
      the declarations assessed and the conflicts found or `no conflicts`; add a
      rule that the check is read-only, modifies no file, and never blocks the
      build. In `.opencode/command/build.md` add one bullet wiring the check in
      before implementation and the handoff mention. [AC6] [AC11] [AC13]
      [depends: T5]
      Verify: `grep -n 'Plan conflicts' .opencode/agent/builder.md`; grep `Parallel-development plan conflicts`, `DECLARED-CONFLICT`, `SURFACE-OVERLAP`, `read-only`, `never blocks` in `builder.md` and `command/build.md`; `bash tests/run.sh` exits 0 (30-permissions unchanged; no signature change).

- [x] **T8** — Update the adopter-facing cross-references and the docs cost
      table. Add a `## Reference` bullet in both `AGENTS.md` and
      `template/AGENTS.md` pointing at `docs/workflow.md` →
      `## Parallel-development plan conflicts`. Name the `Conflicts with` column
      and the pre-build check in the `README.md` `## The lifecycle` roadmap
      paragraph. Refresh the `docs/workflow.md` and `docs/artifact-conventions.md`
      rows and the total in `docs/customization.md` → `## Always-loaded
      instructions`, recomputing at ~4 bytes/token from the edited files, per
      that table's own instruction. [AC14] [depends: T5]
      Verify: `grep -n 'Parallel-development plan conflicts' AGENTS.md template/AGENTS.md`; `grep -n 'Conflicts with' README.md`; compare each documented KB with `wc -c` on the file (within rounding) and confirm the total equals the sum of the three rows; `bash tests/run.sh` exits 0 (95-split-guard and 50-instructions green).

- [x] **T9** — Run the item-level acceptance gate. Confirm `bash tests/run.sh`
      exits 0 with no `FAIL` lines, including AC6 readiness, AC9 inventory
      (README Layout = disk), AC13 cycle fixture, and the signature/lifecycle
      agreements; confirm `.opencode/command/` still holds 12 files,
      `.opencode/agent/` 14, and `.opencode/skill/` 11, with no new command,
      agent, skill, or `tests/checks/*.sh` file and no executable checker,
      script, or helper anywhere in the diff; confirm no `### N. ` heading was
      added to `docs/workflow.md` and the derived-state table is unchanged; and
      confirm `git status --porcelain` touches only `docs/`,
      `.opencode/{agent,command,skill}/`, `README.md`, `AGENTS.md`,
      `template/AGENTS.md`, `tests/fixtures/cyclic-roadmap/roadmap.md`, and
      `work/0006-parallel-plan-conflicts/`. [AC14] [AC15]
      [depends: T1, T2, T3, T4, T5, T6, T7, T8]
      Verify: `bash tests/run.sh`; `ls .opencode/command/*.md | wc -l` = 12, `ls .opencode/agent/*.md | wc -l` = 14, `ls -d .opencode/skill/*/ | wc -l` = 11; `git diff --name-only` matches the allowed scope and adds no `tests/checks/` file or executable.
