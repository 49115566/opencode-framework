---
feature: 0004-adoption-template-split/0004-doctor-template-alignment
phase: tasks
status: final
created: 2026-10-07
updated: 2026-10-07
parent: 0004-adoption-template-split
notes: "Ordered. T1-T3 extend the single doctor agent prompt; T4 mirrors it in the command; T5 is the independent README labeling and may run in parallel; T6 is the end-to-end regression. No task edits tests/** (child 0003 owns committed guards). Each task's verify is runnable or an observable check."
---

# Tasks — Doctor alignment with the adoption template split

Ordered, dependency-aware. One task ≈ one focused commit.

- [x] **T1** — In `.opencode/agent/doctor.md` `<inputs>`, name the adopter-facing
  `template/AGENTS.md` as a documentation surface beside root `AGENTS.md` and
  `README.md`, and add the expected-pristine scope clause (unfilled Project
  profile expected; `template/opencode.json` and `template/.gitignore` are not
  compared). In checks 1 and 2, require each on-disk agent/command to appear in
  the matching README table and by name in the lifecycle table or supporting
  lists of **both** `AGENTS.md` files, with the phantom direction applying to a
  named surface with no on-disk file. [AC1] [AC4] [AC6]
      Verify: `grep -n 'template/AGENTS.md' .opencode/agent/doctor.md` shows the
      name in `<inputs>` and in checks 1-2; opening the file shows the
      expected-placeholder/pristine-config clause; `bash tests/run.sh` exits 0.

- [x] **T2** — In `.opencode/agent/doctor.md`, add `template/` to the temp-path
  scan: the `<inputs>` scan-location list and check 8's scanned paths
  (`TEMP-PATH-OUTSIDE-WORKSPACE`). [AC2] [depends: T1]
      Verify: `grep -n 'template/' .opencode/agent/doctor.md` shows `template/`
      in both the `<inputs>` scan item and check 8. Manual: in a scratch clone,
      append an absolute `/tmp/...` path to `template/AGENTS.md`, run `/doctor`,
      and confirm one `TEMP-PATH-OUTSIDE-WORKSPACE` finding naming the file and
      line; discard the clone.

- [x] **T3** — In `.opencode/agent/doctor.md` `<completeness_rule>`, add
  `template/AGENTS.md` as a third required surface: absent/unreadable emits
  exactly one `[SURFACE-MISSING]` finding and skips only the template-dependent
  comparisons (README, root-`AGENTS.md`, counts, permissions, ignore rules,
  skills, and temp paths still run), and the template's placeholder profile is
  stated expected. Add a matching `template/AGENTS.md` `SURFACE-MISSING` example
  to `<finding_format>`. [AC3] [AC6] [depends: T2]
      Verify: `grep -n 'template/AGENTS.md' .opencode/agent/doctor.md` shows it
      in the required-surface list and the finding example. Manual: in a scratch
      clone, rename `template/AGENTS.md`, run `/doctor`, and confirm exactly one
      `SURFACE-MISSING` finding and no per-inventory-item cascade; discard the
      clone.

- [x] **T4** — Mirror T1-T3 in `.opencode/command/doctor.md`: name
  `template/AGENTS.md` in the required-surface guard, state that agent/command
  inventory is cross-checked against both `AGENTS.md` files, and state that the
  temp-path scan covers `template/`. Keep the phrase "the nine checks", the full
  code list, the maintainer-only audience, and the read-only rules unchanged.
  [AC10] [depends: T3]
      Verify: `grep -n 'template/AGENTS.md' .opencode/command/doctor.md` shows
      the surface; the guard and check list name the same surfaces and codes as
      the agent; `bash tests/run.sh` exits 0.

- [x] **T5** — Add a maintainer-only note below the README Agents table (after
  the `doctor` row, before the `> †` permission-caveat blockquote) naming the
  `doctor` agent and `/doctor` command as framework-maintainer only and noting
  the quickstart removes both. Leave the table's `Can edit` and `Can run bash`
  cells byte-identical. [AC7] [AC8]
      Verify: `grep -n 'framework-maintainer only' README.md` shows the note
      below the Agents table; `git diff README.md` shows no change to the
      `doctor` row cells; a sweep (`grep -n 'maintainer-only\|maintainer only'
      README.md AGENTS.md docs/workflow.md .opencode/agent/doctor.md
      .opencode/command/doctor.md`) shows every `/doctor` / `doctor` surface
      carries the marker; `bash tests/run.sh` exits 0.

- [x] **T6** — End-to-end regression: run the committed suite and a real
  diagnostic on the framework repository. [AC5] [AC9] [AC11] [depends: T1, T2, T3, T4, T5]
      Verify: `bash tests/run.sh` exits 0 with no failed assertion;
      `opencode run --agent doctor "Run the framework consistency diagnostic."`
      prints `No findings — repository is consistent.` and counts 14 agents /
      12 commands / 10 skills with no `COUNT-MISMATCH`; `git status --porcelain`
      is empty both before and after the diagnostic run.
