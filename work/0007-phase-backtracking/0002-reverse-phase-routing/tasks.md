---
feature: 0007-phase-backtracking/0002-reverse-phase-routing
phase: tasks
status: final
created: 2026-10-08
updated: 2026-10-08
parent: 0007-phase-backtracking
---

# Tasks — Reverse phase routing and upstream re-entry

Ordered, dependency-aware. One task ≈ one focused commit. This item edits
existing documentation and prompt files only; it adds no command, agent, skill,
fixture, or runtime dependency, and no new committed check (guards are
`0007-backtracking-guards`).

- [x] **T1** — In `docs/workflow.md` → `## Phase reversal (backtracking)`, add the operational `### Taking an edge` and `### Re-entry` subsections: the five-step edge procedure (sanctioned-edge check; append the `Finding <n>` entry to `backtracks.md`; mark every existing artifact strictly downstream of the target phase and not owned by the target `stale: <target-label>`; never edit the target artifact; hand off), the concrete per-edge marker table (`/build`→`/plan` marks `verify.md`/`review.md` `stale: design`; `/plan`→`/spec` marks `design.md`/`tasks.md`/`verify.md`/`review.md` `stale: spec`), and the conditional re-entry rule (open finding targeting the running phase → revise, append `## Resolution <n>`, clear owned markers, resume forward; no open finding → ordinary forward, record nothing). Adjust the invalidation subsection's opening clause (`:617`) to "when the reverse edge is taken". In `## Plan publication`, add the denied/changes-requested plan-PR bullet: re-run `/plan <item-ref>` and republish via `/ship plan <item-ref>` on the existing `plan/<ref>` branch (a new PR if pruned; never force-push), explicitly not a backtrack. Add no `### <digit>. ` heading and change none of the seven `tests/checks/20-lifecycle.sh:60-78` route literals. [AC3, AC4, AC5, AC6, AC7, AC10]
      Verify: `grep -n 'Taking an edge\|### Re-entry\|reverse edge is taken\|Denied or changes-requested' docs/workflow.md` finds the additions; `grep -n '\`review.md\` verdict \`request-changes\`' docs/workflow.md` still matches; `bash tests/run.sh` exits 0 with `20-lifecycle.sh` green.

- [x] **T2** — In `docs/workflow.md`, extend the phase `Next:` handoffs so the routing is stated in the workflow authority: Requirements (`:220`), Design (`:237-238`), and Build (`:254-255`) name the reverse-edge routing (`/plan`→`/spec` and `/build`→`/plan`) and the plan-PR republish route, keeping the existing forward `Next` values. [AC1, AC2, AC8] [depends: T1]
      Verify: read the three `- **Next**:` lines; `grep -n 'Next' docs/workflow.md` shows `/plan <item-ref>` and `/spec <item-ref>` in the phase handoffs; `bash tests/run.sh` exits 0.

- [x] **T3** — In `.opencode/agent/builder.md`, replace the operating-principle line 38 ("stop and route back") with the concrete `/build`→`/plan` route, add a `process` step that takes the edge when the design is wrong (record the finding, mark `verify.md`/`review.md` `stale: design`, never edit `design.md`/`tasks.md`/`spec.md`, leave the task unchecked), and add the conditional handoff `Next: /plan <item-ref>`. [AC1, AC3, AC8] [depends: T1]
      Verify: `grep -n 'backtracks.md\|stale: design\|Next: \`/plan' .opencode/agent/builder.md` finds them; the never-edit-`design.md` rule is retained; `bash tests/run.sh` exits 0.

- [x] **T4** — In `.opencode/agent/architect.md` and `.opencode/command/plan.md`, wire the architect's two roles: the `/plan`→`/spec` detecting route (record the finding, mark `design.md`/`tasks.md` and any later artifacts `stale: spec`, never edit `spec.md`, hand off `Next: /spec <item-ref>`), the `/plan` re-entry (read an open finding targeting `/plan`, revise `design.md`/`tasks.md`, append a resolution, resume forward; otherwise ordinary), and the denied/changes-requested plan-PR republish route. Replace the `rules` "route back" line (`architect.md:106`). [AC2, AC3, AC5, AC7, AC8] [depends: T1]
      Verify: `grep -n 'backtracks.md\|Next: \`/spec\|re-entr\|plan/<ref>' .opencode/agent/architect.md .opencode/command/plan.md` finds the routing; read both files to confirm the no-self-edit rule and that `Usage:`/frontmatter signatures are unchanged; `bash tests/run.sh` exits 0.

- [x] **T5** — In `.opencode/command/build.md`, add the `/build`→`/plan` reverse-edge bullet (record the finding, mark downstream `stale:`, do not edit `design.md`/`tasks.md`/`spec.md`, end with `Next: /plan <item-ref>`). Keep the command's frontmatter `Usage:` line unchanged. [AC1, AC8] [depends: T3]
      Verify: `grep -n 'Phase reversal\|Next: \`/plan' .opencode/command/build.md` finds the bullet; `grep -n 'Usage: /build \[item-ref or task-id\]' .opencode/command/build.md` still matches; `bash tests/run.sh` exits 0.

- [x] **T6** — In `.opencode/agent/product.md` `process`, add the `/spec` re-entry step: when `work/<item-ref>/backtracks.md` has an open finding targeting `/spec`, read it, revise `spec.md`, append a `## Resolution <n>` entry, and resume forward; with no open finding, write the spec as ordinary progression and record nothing. Scope this to the `/plan`→`/spec` target only; add no roadmap-revision routing. [AC5, AC8] [depends: T1]
      Verify: `grep -n 'backtracks.md\|Resolution' .opencode/agent/product.md` finds the re-entry step; read it to confirm it does not touch `work/<NNNN-slug>/roadmap.md` routing; `bash tests/run.sh` exits 0.

- [x] **T7** — In `AGENTS.md` and `template/AGENTS.md`, extend the Working-agreements `Backtracking` bullet (adding it to `template/AGENTS.md`, which lacks 0001's copy) to name the two wired edges, the `backtracks.md` finding record, the `stale:` marking, and re-entry, and reword the Handoff-protocol "stop and report" line (`AGENTS.md:98-99`, `template/AGENTS.md:100-101`) to reference the sanctioned route. Add no lifecycle-table row and no `Supporting commands:` token. Keep the two routing sections in agreement. [AC8, AC12] [depends: T1]
      Verify: `grep -n 'Phase reversal (backtracking)' AGENTS.md template/AGENTS.md` matches both; diff the two Working-agreements and Handoff-protocol sections and confirm they agree apart from the Project-profile placeholders; `bash tests/run.sh` exits 0 (96-signature-sweep green).

- [x] **T8** — In `.opencode/skill/workflow-lifecycle/SKILL.md`, add the reverse-edge/re-entry/plan-republish routes to the `## Which command now?` block using canonical signatures only (`/plan <item-ref>`, `/spec <item-ref>`) with two spaces before any trailing prose, keeping the seven existing route literals byte-identical; reword the `rules` "stop and report" line (`:62`) to reference the sanctioned route. [AC2, AC5, AC7, AC8] [depends: T1]
      Verify: `bash tests/run.sh` exits 0 with `20-lifecycle.sh` and `96-signature-sweep.sh` green; read the block to confirm every routed `→` target is a canonical signature.

- [x] **T9** — Verify the whole change end to end: run the suite, confirm the surfaces, inventories, signatures, and six command→agent pairings are unchanged, confirm no new `phase` value/state file/readiness rule and no unwired reverse edge, and confirm the root vs `template/AGENTS.md` routing agreement. [AC9, AC10, AC11, AC12] [depends: T2, T3, T4, T5, T6, T7, T8]
      Verify: `bash tests/run.sh` → exit 0 with `TOTAL: … 0 failed` (in particular `20-lifecycle.sh`, `40-inventory.sh`, `96-signature-sweep.sh` green); `git diff --stat` lists only `docs/workflow.md`, `AGENTS.md`, `template/AGENTS.md`, `.opencode/agent/builder.md`, `.opencode/agent/architect.md`, `.opencode/agent/product.md`, `.opencode/command/build.md`, `.opencode/command/plan.md`, `.opencode/skill/workflow-lifecycle/SKILL.md`, and `work/…/tasks.md`; `git status --porcelain -- .opencode/agent .opencode/command .opencode/skill README.md tests/` shows no added/removed inventory file; `grep -rn 'stop and report\|route back' .opencode/agent/builder.md .opencode/agent/architect.md .opencode/skill/workflow-lifecycle/SKILL.md` finds no forward-only phrasing; confirm no `/test`→…, parent-`roadmap`, or post-ship route was added.
