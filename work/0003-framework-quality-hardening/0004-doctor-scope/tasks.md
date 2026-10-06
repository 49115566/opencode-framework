---
feature: 0003-framework-quality-hardening/0004-doctor-scope
phase: tasks
status: final
created: 2026-10-05
updated: 2026-10-05
parent: 0003-framework-quality-hardening
notes: "Ordered; T2-T4 serialize edits to the doctor files and README. T5 is the end-to-end verification task."
---

# Tasks — Doctor audience and diagnostic accuracy

Ordered, dependency-aware. One task ≈ one focused commit. Design decisions are
fixed in `design.md`; no task requires a new design decision.

- [x] **T1** — Exclude the doctor agent and command from the adoption quickstart
      and document the maintainer-only scope. In `README.md`, add
      `rm -f .opencode/agent/doctor.md .opencode/command/doctor.md` immediately
      after the directory copy in the quickstart block (`:40-47`), and add the
      note that follows it: `/doctor` and the `doctor` agent are
      framework-maintainer-only because the diagnostic needs the framework
      README inventory that the quickstart never copies; an already-adopted repo
      should remove or ignore the two files; an out-of-band copy that retains
      them will make `/doctor` misreport outside the framework repo. [AC2, AC3]
      Verify: the quickstart block contains the `rm -f` step; run the block
      verbatim into `scratch/qs` and assert
      `test ! -e .opencode/agent/doctor.md && test ! -e .opencode/command/doctor.md`;
      `rg -n "framework-maintainer only" README.md` shows the note.

- [x] **T2** — Label `/doctor` and the `doctor` agent as framework-maintainer-only
      on every live surface. Append the scope marker to the `/doctor` Commands
      row description (`README.md:159`), the `doctor` Agents row's "Can run bash"
      cell (`README.md:179`), the `/doctor` and `doctor` entries in `AGENTS.md`
      supporting lists (`:50`, `:54`), the `/doctor` bullet in
      `docs/workflow.md` (`:274-276`), and the `description:` frontmatter of
      `.opencode/agent/doctor.md:2` and `.opencode/command/doctor.md:2`. Do not
      alter the `doctor` / `/doctor` name cells. [AC1, AC3] [depends: T1]
      Verify: `rg -n "framework-maintainer only" README.md AGENTS.md
      docs/workflow.md .opencode/agent/doctor.md .opencode/command/doctor.md`
      returns a match in each file; the README `doctor` and `/doctor` name cells
      are unchanged (grep the rows).

- [x] **T3** — Replace the diagnostic's brittle and factually wrong sample
      findings with symbolic examples in `.opencode/agent/doctor.md`
      `<finding_format>` (`:137-155`). Replace the `COUNT-MISMATCH` example
      (`:148`) so it carries no integers and no `README.md:182`; replace the
      `TEMP-PATH-OUTSIDE-WORKSPACE` example (`:152`) so it carries no
      `SKILL.md:46` and no false claim (the cited line actually writes to the
      in-repo `scratch/`). Leave the examples at `:147` and `:149-151` and the
      accurate check-step count (`agent:169`, `command:13`) unchanged. [AC4]
      [depends: T2]
      Verify: `rg -n "README\.md:[0-9]+|SKILL\.md:[0-9]+|[0-9]+ (files|role
      prompts)" .opencode/agent/doctor.md` returns no matches; every example
      names its location by document plus table/row/comment.

- [x] **T4** — Rewrite `.opencode/agent/doctor.md` `<completeness_rule>`
      (`:157-164`) per `design.md`: declare the required documentation surfaces
      and confirm their existence first; emit a single `SURFACE-MISSING` finding
      and skip dependent comparisons when one is absent, never a per-item
      cascade; derive lifecycle classification from `docs/workflow.md` phase
      tables instead of the inline `(ask, doctor, scout, scribe, status,
      bootstrap)` enumeration; and state that a command-less agent is not a
      finding. Add the matching surface-existence guard and a `SURFACE-MISSING`
      example to `.opencode/command/doctor.md` (`:13-26`). [AC5, AC6]
      [depends: T3]
      Verify: `rg -n "non-lifecycle agents|\(ask, doctor" .opencode/agent/doctor.md`
      returns no matches; `rg -n "SURFACE-MISSING" .opencode/agent/doctor.md
      .opencode/command/doctor.md` matches both files.

- [x] **T5** — Verify end to end that the diagnostic is clean and nothing else
      regressed. Run the framework `/doctor`, confirm the clean result and
      counts; confirm `opencode.json` still omits `README.md` from
      `instructions`; confirm no `permission:` block changed; confirm the
      `docs/workflow.md` phase behavior is untouched. [AC7, AC8, AC9, AC10,
      AC11] [depends: T1, T2, T3, T4]
      Verify: `opencode run --agent doctor "Run the framework consistency
      diagnostic."` prints `No findings — repository is consistent.` with counts
      agents 14, commands 12, skills 10; `rg -n '"README.md"' opencode.json`
      returns no match; `git diff --stat` lists only `README.md`, `AGENTS.md`,
      `docs/workflow.md`, `.opencode/agent/doctor.md`, and
      `.opencode/command/doctor.md`.
