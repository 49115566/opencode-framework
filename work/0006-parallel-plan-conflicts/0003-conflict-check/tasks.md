---
feature: 0006-parallel-plan-conflicts/0003-conflict-check
phase: tasks
status: final
created: 2026-10-08
updated: 2026-10-08
parent: 0006-parallel-plan-conflicts
---

# Tasks — Pre-development parallel-plan conflict check

Ordered, dependency-aware. One task ≈ one focused commit. After each task,
`bash tests/run.sh` must stay green.

- [ ] **T1** — Add the single authoritative `## Declared-conflict check` section
      to `docs/workflow.md` (between `## Plan publication` and `## Derived
      state`) and a `/conflicts [item-ref]` bullet to `## Routing heuristics`.
      State: the compared set (unshipped plans with a non-empty declaration;
      roadmap parents are containers, children carry own-`design.md` ∪ parent
      cell, standalone items carry own field; `ship.md` excludes but a shipped
      item still resolves as a target); the reference to the reused grammar and
      resolution algorithm (do not restate it); the pair predicate and
      `same_target` identity by resolution; the findings table
      (`TEXTUAL-CONFLICT` `(a)`/`(b)`, `DANGLING-DEP` `(b)`, `DRIFT-FACT` `(d)`)
      using the shipped finding grammar; the unresolved-declaration and
      parent/item-discrepancy rules; and the advisory/offline/local/read-only
      contract plus enforcement points (`/conflicts`, `/status`, `/build` gate)
      and the distinction from the merge-time branch contract. [AC1, AC3, AC4,
      AC5, AC6, AC7, AC8, AC9, AC12, AC13, AC14, AC16]
      Verify: `bash tests/run.sh` → exit 0; read `docs/workflow.md` →
      `## Declared-conflict check` and confirm every listed element is present
      and the `### Declared conflicts` grammar/`### Merge-integrity guard`
      sections are unchanged.

- [ ] **T2** — Record the planning-time finding meanings in
      `.opencode/skill/merge-conflict/SKILL.md`: `TEXTUAL-CONFLICT` also covers a
      *declared* conflict (`(a)`/`(b)`), `DANGLING-DEP` also covers a malformed
      or unresolvable `conflicts-with` target, and `DRIFT-FACT` also covers a
      parent/item declaration disagreement. Scope the "`TEXTUAL-CONFLICT` is
      pre-flight-only / no dry-run merge" note to the *detected* dry-run case and
      reference `docs/workflow.md` → `## Declared-conflict check`. Do not change
      the finding grammar or add a code. [AC6, AC13, AC16] [depends: T1]
      Verify: read the skill's finding-grammar/vocabulary section; the three
      planning-time meanings and the scoped note are present and no new code is
      introduced; `bash tests/run.sh` → exit 0.

- [ ] **T3** — Make the `status` agent the reporting owner:
      `.opencode/agent/status.md` and `.opencode/command/status.md` describe and
      report the declared-conflict check (global mode, item-ref focused mode, and
      the `/status` integrity window), referencing `docs/workflow.md` →
      `## Declared-conflict check`. Preserve the existing readiness/cycle/finding
      literals (`Dependencies and readiness`, `CYCLIC-DEP`, `informational and
      never fatal`, `members of a cycle are never reported`) and add no readiness
      algorithm marker. [AC1, AC2, AC7, AC8, AC10, AC12, AC14] [depends: T1]
      Verify: `bash tests/run.sh` → exit 0 (`10-readiness` and
      `80-cycle-fixture` green); read both files and confirm the check is
      described and the authority is referenced, not restated.

- [ ] **T4** — Surface the advisory check at the `/build` plan gate:
      `.opencode/agent/builder.md` and `.opencode/command/build.md` run a
      read-only focused check for the item after a PROCEED outcome and print the
      findings before selecting a task, without changing the gate outcome or
      blocking the build; reference `docs/workflow.md` → `## Declared-conflict
      check`. [AC9, AC11, AC12, AC16] [depends: T1]
      Verify: `bash tests/run.sh` → exit 0; read the gate step in both files and
      confirm findings are printed post-PROCEED and the outcome is unchanged.

- [ ] **T5** — Add the `/conflicts` command and register it in every command
      inventory in one change: create `.opencode/command/conflicts.md`
      (`agent: status`; `description:` carries `Usage: /conflicts [item-ref]`);
      add the command to the `README.md` `Commands` table and change `Layout`
      `# 12 slash commands` → `# 13 slash commands`; add `/conflicts [item-ref]`
      to the `Supporting commands:` list of `AGENTS.md` and
      `template/AGENTS.md`; add the route to
      `.opencode/skill/workflow-lifecycle/SKILL.md`; and update
      `tests/checks/96-signature-sweep.sh` (`canonical_signature` case,
      `ALL_COMMANDS`, and the `AGENTS`/`README`/`SKILL` required sets). Do not
      edit `tests/checks/40-inventory.sh` (generic) or any `0004`-owned fixture.
      [AC1, AC2, AC15, AC16] [depends: T1, T3]
      Verify: `test -f .opencode/command/conflicts.md` and
      `bash tests/run.sh` → exit 0 (`40-inventory` and `96-signature-sweep`
      green); `rg -n '/conflicts' README.md AGENTS.md template/AGENTS.md
      .opencode/skill/workflow-lifecycle/SKILL.md tests/checks/96-signature-sweep.sh`.

- [ ] **T6** — Cross-surface consistency pass: confirm the command surface, the
      `workflow-lifecycle` routing, the `status` agent/command, and the builder
      prompt each describe the check's surface, its advisory nature, and its
      reuse of the shipped vocabulary consistently, with the algorithm stated
      only in `docs/workflow.md` → `## Declared-conflict check` and referenced
      elsewhere rather than restated; fix any drift. [AC16]
      [depends: T1, T2, T3, T4, T5]
      Verify: `rg -n 'Declared-conflict check' docs .opencode README.md AGENTS.md
      template/AGENTS.md` shows reference-form mentions and no second algorithm
      statement; `bash tests/run.sh` → exit 0.
