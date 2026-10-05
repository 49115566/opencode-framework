---
feature: 0002-agentic-roadmaps
phase: tasks
status: final
created: 2026-10-04
updated: 2026-10-04
notes: "Prompt/config work item: no runtime code and no test runner. T9 and T10 are verification tasks; nothing is committed. T1–T10 complete."
---

# Tasks — Agentic multi-feature roadmaps

Ordered, dependency-aware. One task ≈ one focused commit. There is no test
runner in this repo, so `Verify:` steps are read-only shell assertions plus
explicit manual agent invocations. The artifact shapes and the readiness
algorithm are fixed in `design.md`; no task may re-decide them.

- [x] **T1** — Define the work-item reference grammar and the roadmap artifact
      conventions in `docs/artifact-conventions.md`: add `roadmap` to the
      `phase` enum; add the optional `parent: <NNNN-slug>` frontmatter field and
      state that `feature` is the canonical reference (`NNNN-slug`, or
      `NNNN-slug/MMMM-slug` for a nested child); add a "Work item references"
      section with the grammar, the two-segment resolution rule, and the nested
      layout `work/<NNNN-slug>/<MMMM-slug>/`; add the `roadmap.md` template
      (Initiative, Assumptions, Children table with Local id / Title / Scope /
      Depends on / Canonical reference, Sequencing, Open issues) from `design.md`
      §2 and §"Interfaces and data model". [AC2] [AC3] [AC8] [AC11]
      Verify: `rg -n "phase: roadmap|parent:|canonical reference|Depends on|work/<NNNN-slug>/<MMMM-slug>" docs/artifact-conventions.md`
      matches each; `rg -n "roadmap" docs/artifact-conventions.md` shows the
      template; a manual read confirms the grammar regex
      `^[0-9]{4}-[a-z0-9-]+(/[0-9]{4}-[a-z0-9-]+)?$` is stated.

- [x] **T2** — Document the roadmap lifecycle semantics in the always-loaded
      docs. In `docs/workflow.md`: add a "Roadmaps" section covering the parent
      item vs. nested children, the Children-table dependency rules (existing
      local ids, no self, acyclic; cycles go to Open issues), the readiness
      algorithm (`ready` iff every dependency is satisfied; satisfied iff the
      depended child has `review.md` verdict `approve` or `ship.md`; no-dep child
      is ready; a child in a cycle is never ready), the `ready`/`blocked` status
      reporting and the roadmap/child separation, the `DANGLING-DEP` /
      `MISSING-CHILD` / `UNLISTED-CHILD` / `CYCLIC-DEP` findings, the
      blocked-start override protocol, the nested layout, and a `/roadmap`
      routing-heuristic bullet; extend the "The work item directory" layout with
      nested children; add roadmap rows to the "Derived state" table. In
      `AGENTS.md`: add `roadmap` to the supporting-agents list, `/roadmap` to the
      supporting-commands list, and a nested-work-item note to the artifact
      contract. Change no existing phase's inputs, outputs, or exit criteria.
      [AC4] [AC5] [AC6] [AC7] [AC9] [AC10] [AC11] [AC15]
      Verify: `rg -n "Roadmaps|ready|blocked|DANGLING-DEP|CYCLIC-DEP|/roadmap" docs/workflow.md`
      matches; `rg -n 'roadmap|/roadmap' AGENTS.md` matches;
      `git diff docs/workflow.md` shows the lifecycle phase table unchanged.

- [x] **T3** — Add the roadmap authoring agent. Create
      `.opencode/agent/roadmap.md` with the frontmatter and process from
      `design.md` §"Interfaces and data model" and §4: primary mode, `edit`
      limited to `work/**` + `**/work/**`, read-only bash allowlist,
      `question` allowed. The body restates the initiative; handles an empty
      initiative (ask, create nothing), a single-feature initiative (recommend
      `/spec`), and a non-decomposable initiative (record an Open issue); scans
      `work/*/roadmap.md` and `work/*/spec.md` for a likely duplicate; allocates
      the next top-level `NNNN`; writes `roadmap.md` with the T1/T2 shapes; and
      creates `work/<NNNN-slug>/<MMMM-slug>/.gitkeep` for every child. It writes
      no child specs and performs no child phase work. [AC1] [AC2] [AC3] [AC4]
      [AC12] [AC14] [depends: T1, T2]
      Verify: `opencode debug agent roadmap` resolves with `edit` granting both
      `work/**` and `**/work/**` and no write-capable bash pattern; a manual
      read confirms the agent's process covers AC1, AC3, AC12, and AC14;
      `rg -n "gitkeep|cycle|duplicate|single feature|assumption" .opencode/agent/roadmap.md`
      matches.

- [x] **T4** — Add the `/roadmap` command. Create
      `.opencode/command/roadmap.md` with `agent: roadmap` and the usage line,
      mirroring the shape of `.opencode/command/spec.md`: state that the run is
      autonomous and produces only the roadmap artifact and child directory
      skeletons, instruct the agent to ask for an initiative when the argument
      is empty, to recommend `/spec` for a single feature, and to end with the
      handoff block. [AC1] [depends: T3]
      Verify: `rg -n "agent: roadmap|/roadmap" .opencode/command/roadmap.md`
      matches; after restarting opencode, `/roadmap` appears in the command list
      and invoking it with a multi-feature initiative produces a roadmap item.

- [x] **T5** — Teach the per-feature phase agents to resolve nested references
      and enforce the blocked-start gate. Add the same one-line resolution rule
      (a two-segment `NNNN-slug/MMMM-slug` reference resolves to
      `work/<NNNN-slug>/<MMMM-slug>/`; a one-segment reference is unchanged) to
      `.opencode/agent/product.md`, `architect.md`, `builder.md`, `tester.md`,
      `reviewer.md`, `shipper.md`, and `visual.md`. In `product.md` only, add the
      AC9 gate: for a nested child, resolve the parent `roadmap.md`, run the
      readiness algorithm from `docs/workflow.md`, and if the child is blocked,
      report the blocking children and stop before writing `spec.md`; proceed
      only on explicit user override and record the override plus blockers in the
      new spec's frontmatter `notes`. Change no phase semantics for standalone
      items. [AC8] [AC9] [AC11] [depends: T1, T2]
      Verify: `rg -n "MMMM-slug" .opencode/agent/product.md .opencode/agent/architect.md .opencode/agent/builder.md .opencode/agent/tester.md .opencode/agent/reviewer.md .opencode/agent/shipper.md .opencode/agent/visual.md`
      matches in all seven; `rg -n "blocked|override|readiness" .opencode/agent/product.md`
      matches; `git diff` shows no change to any agent's permission block.

- [x] **T6** — Teach the per-feature phase commands to accept a canonical
      reference. Update `.opencode/command/spec.md`, `plan.md`, `build.md`,
      `test.md`, `review.md`, `ship.md`, and `visual.md` so every hardcoded
      `work/<slug>/...` path is expressed as `work/<item-ref>/...` with a note
      that `item-ref` is `NNNN-slug` or `NNNN-slug/MMMM-slug`. Do not change the
      commands' phase behavior for standalone items. [AC8] [depends: T1]
      Verify: `rg -n "NNNN-slug/MMMM-slug" .opencode/command/spec.md .opencode/command/plan.md .opencode/command/build.md .opencode/command/test.md .opencode/command/review.md .opencode/command/ship.md .opencode/command/visual.md`
      matches in all seven; `git diff` shows no change to any `agent:` field.

- [x] **T7** — Extend the status agent and command for roadmaps and readiness.
      In `.opencode/agent/status.md`: detect a roadmap parent by `roadmap.md`;
      report the roadmap separately from its children; compute each child's phase
      and readiness with the T2 algorithm; print `<ready>/<total> ready` for the
      roadmap plus a distribution tally of children across phases; name blockers
      per blocked child; add `roadmap` to the phase vocabulary; emit
      `DANGLING-DEP` / `MISSING-CHILD` / `UNLISTED-CHILD` / `CYCLIC-DEP` findings
      without failing; keep `edit: deny` and modify nothing.
      Update the output-format block and process accordingly, and add matching
      bullets to `.opencode/command/status.md`. [AC5] [AC6] [AC7] [AC10] [AC15]
      [depends: T1, T2]
      Verify: `rg -n "roadmap|ready|blocked|DANGLING-DEP|CYCLIC-DEP|roadmap.md" .opencode/agent/status.md .opencode/command/status.md`
      matches; `rg -n "edit: deny" .opencode/agent/status.md` still matches;
      manual: `/status <parent>` prints the roadmap row and child readiness.

- [x] **T8** — Update the documented inventories and counts, and the lifecycle
      skill quick view. In `README.md`: add a `roadmap` row to the Agents table
      (primary; `work/**` + `**/work/**`; read-only bash allowlist) and a
      `/roadmap` row to the Commands table; update the layout counts to
      `# 14 role prompts` and `# 12 slash commands` (skills stay `# 10`); add a
      short roadmap/nested-item mention. In `.opencode/skill/workflow-lifecycle/SKILL.md`:
      add a roadmap decision-table row and the nested-reference note. Do not
      change `opencode.json` or any skill name. [AC13] [AC11] [depends: T3, T4]
      Verify: `rg -n "14 role prompts|12 slash commands" README.md` matches;
      `rg -n 'roadmap|/roadmap' README.md` matches; a shell loop confirms
      every `.opencode/agent/*.md` basename and every `.opencode/command/*.md`
      basename appears in `README.md` and in `AGENTS.md`; `ls .opencode/agent/*.md`
      counts 14 and `ls .opencode/command/*.md` counts 12.

- [x] **T9** — Verify the framework end to end and confirm `/doctor` is clean.
      Restart opencode. Run `/roadmap` on a multi-feature initiative and confirm
      the artifact and child skeletons; advance a child through the lifecycle by
      canonical reference and confirm artifacts land nested; run `/status` and
      the shell assertions. Confirm `git status --porcelain` shows no tracked
      changes from authoring or status (AC12, AC10) and that no child phase
      artifact exists (AC3). Run `/doctor` and expect
      `No findings — repository is consistent.` [AC1] [AC2] [AC3] [AC8] [AC10]
      [AC11] [AC12] [AC13] [depends: T1, T2, T3, T4, T5, T6, T7, T8]
      Verify: `/doctor` prints the clean line with counts agents 14, commands 12,
      skills 10; `find work/<parent> -mindepth 2 -type f -not -name '.gitkeep'`
      is empty immediately after `/roadmap`; `git status --porcelain` is empty.

- [x] **T10** — Prove the edge cases and readiness boundaries (manual).
      On a scratch roadmap (removed afterward), seed and observe, recording each
      result for `verify.md`: (a) a dependency on an approved-but-unshipped child
      is satisfied and on a `request-changes` child is not; (b) a child with no
      review is blocked and names its blocker; (c) a child with no dependencies
      is ready; (d) remove/rename a child directory and confirm `MISSING-CHILD` /
      `UNLISTED-CHILD`; point a dependency at a missing local id and confirm
      `DANGLING-DEP`; (e) hand-edit a cycle and confirm `CYCLIC-DEP` and that no
      member is reported ready; (f) request `/spec` for a blocked child and
      confirm refusal with named blockers, then confirm explicit override
      proceeds without deleting anything; (g) a single-feature request recommends
      `/spec` and a vague request records assumptions/open issues without
      inventing scope. [AC4] [AC5] [AC6] [AC9] [AC14] [AC15] [depends: T9]
      Verify: each seeded case produces the expected readiness result or named
      finding; the scratch roadmap and probes are removed; `git status --porcelain`
      is empty afterward.

## Acceptance-criteria coverage

| AC | Tasks |
| --- | --- |
| AC1 | T3, T4, T9 |
| AC2 | T1, T3, T9 |
| AC3 | T1, T3, T9 |
| AC4 | T2, T3, T10 |
| AC5 | T2, T7, T10 |
| AC6 | T2, T7, T10 |
| AC7 | T2, T7 |
| AC8 | T1, T5, T6, T9 |
| AC9 | T2, T5, T10 |
| AC10 | T2, T7, T9 |
| AC11 | T1, T2, T5, T8, T9 |
| AC12 | T3, T9 |
| AC13 | T8, T9 |
| AC14 | T3, T10 |
| AC15 | T2, T7, T10 |
