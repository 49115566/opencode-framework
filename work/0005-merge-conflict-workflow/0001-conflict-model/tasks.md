---
feature: 0005-merge-conflict-workflow/0001-conflict-model
phase: tasks
status: final
created: 2026-10-07
updated: 2026-10-07
notes: "Docs + one skill; no command, agent, artifact format, or lifecycle change. T8 is the item-level acceptance gate (suite + inventory invariants), not a code commit. T1 complete: taxonomy + relationship to renumbering added to docs/workflow.md; backward pointer added to docs/artifact-conventions.md. T2 complete: Lifecycle placement + Ownership added; cross-references added in Multiple work items and Ship. T3 complete: Resolution principles + Verification added. T4 complete: .opencode/skill/merge-conflict/SKILL.md created. T5 complete: README Skills row + Layout count raised to 11. T4 and T5 landed together because T4's suite-green Verify depends on T5's inventory update (the added skill otherwise fails AC9). T6 complete: `## Reference` bullets added to `AGENTS.md` and `template/AGENTS.md`. T7 complete: `docs/customization.md` always-loaded cost table refreshed for all three listed files (AGENTS 1.9k/7.6 KB, workflow 5.4k/21.6 KB, artifact-conventions 3.3k/13.0 KB; total 10.6k/42.2 KB); AGENTS.md and artifact-conventions.md are included because both changed in this item and the table's own instruction refreshes whenever a listed file changes. T8 complete: acceptance gate passed — `bash tests/run.sh` 210 passed / 0 failed (AC9 inventory shows 11 knowledge skills incl. merge-conflict), `.opencode/command/` 12 and `.opencode/agent/` 14 files, workflow phase list/derived-state table/artifact templates unchanged (diff touches only the new `## Merge conflicts` section and the `### 6. Ship` process line), and `git status --porcelain` touches only the allowed surfaces."
parent: 0005-merge-conflict-workflow
---

# Tasks — Merge-conflict model and resolution contract

Ordered, dependency-aware. One task ≈ one focused commit. The contract tasks
(T1-T3) edit the same new `docs/workflow.md` section and are sequential.

- [x] **T1** — Add the `## Merge conflicts` section to `docs/workflow.md` with
      `### Conflict taxonomy` naming the four classes exactly — (a) shared-surface
      textual conflict, (b) `work/` artifact conflict, (c) duplicate sequence
      number, (d) derived-agreement drift — each row naming at least one affected
      surface (shared-surface: `README.md`, `AGENTS.md`, `docs/*.md`,
      `.opencode/{agent,command,skill}/**`, `template/**`, `tests/checks/**`;
      artifact: roadmap `Children`/`Depends on` tables, artifact frontmatter,
      nested-child intersections; duplicate: top-level `work/<NNNN-slug>` and
      per-parent `work/<NNNN-slug>/<MMMM-slug>`; drift: README Layout counts and
      Skills table), and `### Relationship to renumbering` deferring duplicate
      sequence numbers to the existing "Renumbering after a parallel merge" rule.
      Add a one-sentence pointer to `## Merge conflicts` inside
      `docs/artifact-conventions.md` → `### Renumbering after a parallel merge`.
      [AC1] [AC8]
      Verify: `grep -nE '^## Merge conflicts|^### Conflict taxonomy|^### Relationship to renumbering' docs/workflow.md`; grep each class name and each named surface; `grep -n 'Renumbering after a parallel merge' docs/workflow.md docs/artifact-conventions.md` resolves both directions; `bash tests/run.sh` exits 0.
- [x] **T2** — Add `### Lifecycle placement` and `### Ownership` to the
      `## Merge conflicts` section: pre-ship reconcile before the shipper performs
      its ship operations; a post-merge integrity pass after a merge to the default
      branch; the `shipper` is the single owner; reconciliation is a step inside
      `/ship`, not a new command or agent. Add the cross-reference sentence in
      `## Multiple work items` (pointing to `## Merge conflicts` for the
      non-renumbering classes) and a leading reconcile sentence in the
      `### 6. Ship` process. [AC2] [AC3] [depends: T1]
      Verify: `grep -nE '^### Lifecycle placement|^### Ownership' docs/workflow.md`; grep the pre-ship, post-merge, single owner, step inside `/ship`, and no-new-command/agent literals; `grep -n 'Merge conflicts' docs/workflow.md` shows the `## Multiple work items` and `### 6. Ship` cross-references; `bash tests/run.sh` exits 0.
- [x] **T3** — Add `### Resolution principles` and `### Verification` to the
      `## Merge conflicts` section: merge the default branch forward into the item
      branch; never rebase a pushed branch; never force-push; preserve both
      branches' intent; never silently accept a semantic conflict and escalate
      intent ambiguity to the user; auto-resolve a mechanical or structural
      conflict subject to re-verification; re-run `bash tests/run.sh` and the
      affected item's checks after a resolution and require them green before the
      merge is recorded or shipped. [AC4] [AC5] [AC6] [AC7] [depends: T2]
      Verify: `grep -nE '^### Resolution principles|^### Verification' docs/workflow.md`; grep the merge-forward, never-rebase, never-force-push, preserve-intent, escalate, auto-resolve, and `bash tests/run.sh` literals; `bash tests/run.sh` exits 0.
- [x] **T4** — Create `.opencode/skill/merge-conflict/SKILL.md` with frontmatter
      `name: merge-conflict` (matching the folder) and a trigger-rich description
      (`merge conflict`, `reconcile`, `conflict`, `branch behind`, `/ship`); open
      by naming `docs/workflow.md` as the source of truth; encode the shipper
      procedure as ordered steps covering detection/classification, resolution
      (mechanical auto-resolve vs. semantic escalate), re-verification with
      `bash tests/run.sh` and the affected item's checks, recording the resolved
      paths and evidence, the post-merge integrity pass, and an explicit
      stop-and-escalate path consistent with AC1-AC8. [AC9] [depends: T1, T2, T3]
      Verify: `ls .opencode/skill/merge-conflict/SKILL.md`; `grep -nE '^name: merge-conflict'`; `grep -n 'bash tests/run.sh'`; read the file and confirm every ordered step (detect, classify, resolve, re-verify, record, escalate) is present; `bash tests/run.sh` exits 0.
- [x] **T5** — Add a `merge-conflict` row to the `## Skills` table in
      `README.md` and change the `## Layout` line `# 10 knowledge skills` to
      `# 11 knowledge skills`, so the documented count and table match the on-disk
      skill set. [AC10] [AC11] [depends: T4]
      Verify: `grep -n 'merge-conflict' README.md` shows the Skills row; `grep -n '# 11 knowledge skills' README.md`; `bash tests/run.sh` exits 0 with no `FAIL AC9` inventory line.
- [x] **T6** — Add a `## Reference` bullet naming the `merge-conflict` skill and
      the `docs/workflow.md` `## Merge conflicts` section to both `AGENTS.md` and
      `template/AGENTS.md`. [AC10] [depends: T4]
      Verify: `grep -n 'merge-conflict' AGENTS.md template/AGENTS.md`; `bash tests/run.sh` exits 0 (95-split-guard unaffected).
- [x] **T7** — Refresh the `docs/workflow.md` row and the total in
      `docs/customization.md` → `## Always-loaded instructions`, recomputing size
      and tokens at ~4 bytes/token from the edited file, per that table's own
      refresh instruction. [docs-consistency] [depends: T1, T2, T3]
      Verify: compare the documented KB for `docs/workflow.md` with `wc -c docs/workflow.md` (within rounding) and confirm the total row equals the sum of the three rows; `bash tests/run.sh` exits 0.
- [x] **T8** — Run the item-level acceptance gate: `bash tests/run.sh` must exit 0
      with no `FAIL` lines, and `.opencode/command/` must still hold 12 files and
      `.opencode/agent/` 14, with no new command or agent file, and the
      `docs/workflow.md` phase list, derived-state table, and artifact templates
      unchanged. [AC11] [AC12] [depends: T1, T2, T3, T4, T5, T6, T7]
      Verify: `bash tests/run.sh`; `ls .opencode/command/*.md | wc -l` is 12 and `ls .opencode/agent/*.md | wc -l` is 14; `git status --porcelain` touches only `docs/`, `README.md`, `AGENTS.md`, `template/AGENTS.md`, `.opencode/skill/merge-conflict/`, and `work/0005-merge-conflict-workflow/0001-conflict-model/`.
