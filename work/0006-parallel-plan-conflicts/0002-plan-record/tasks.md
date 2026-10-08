---
feature: 0006-parallel-plan-conflicts/0002-plan-record
phase: tasks
status: final
created: 2026-10-08
updated: 2026-10-08
parent: 0006-parallel-plan-conflicts
notes: "Docs- and prompt-only item; no test files change (0004-conflict-guards owns the committed guards). Every task's Verify runs `bash tests/run.sh` where a surface is regression-sensitive."
---

# Tasks — Pre-development plan publication and declared conflict record

Ordered, dependency-aware. One task ≈ one focused commit. The declaration home
is `design.md` frontmatter `conflicts-with`; publication is `/ship plan
<item-ref>`, run by the shipper.

- [x] **T1** — Add the item-level declaration home and union rule to the workflow
      authority. In `docs/workflow.md` → `### Declared conflicts
      (conflicts-with)` (`:110-166`), after the storage-independent-grammar
      sentence, state that a child or standalone item's own declaration is stored
      in its `design.md` frontmatter `conflicts-with` value; that absence or `—`
      means no declared conflicts; that a roadmap child's declared set is the
      union of that value and its parent `Children` row's cell, with a
      disagreement reported by the later check and never silently resolved; and
      that a malformed/unresolved value is reported by the later check, never
      dropped or auto-repaired. Restate that the declaration is advisory and adds
      no readiness edge. Do not restate the grammar. [AC4, AC5, AC6, AC7, AC8,
      AC12]
      Verify: `rg -n 'design.md|frontmatter|union|advisory|unresolved' docs/workflow.md`
      shows the additions inside the Declared conflicts subsection; a read-through
      confirms the home, absence/`—`, union + mismatch, unresolved, and advisory
      statements and no second grammar; `bash tests/run.sh` exits 0.

- [x] **T2** — Document the `conflicts-with` frontmatter field in
      `docs/artifact-conventions.md`. Add a bullet to the Frontmatter rules
      (`:28-39`) describing the optional `design.md` `conflicts-with` value: it
      holds one `ConflictTargetList`, absent or `—` means no declared conflicts,
      it is advisory and does not affect phase derivation or readiness, and it
      points to `docs/workflow.md` → "Declared conflicts (`conflicts-with`)" for
      the grammar. Add the optional field to the `design.md` template frontmatter
      (`:193-200`). [AC4, AC5, AC6, AC13] [depends: T1]
      Verify: `rg -n 'conflicts-with' docs/artifact-conventions.md` shows the
      Frontmatter rule and the `design.md` template line; a read-through confirms
      it references the authority and states absence/`—` and the advisory rule;
      `bash tests/run.sh` exits 0 (no inventory or lifecycle agreement is
      affected).

- [x] **T3** — Author the declaration at `/plan` in
      `.opencode/agent/architect.md`. Add to the process and quality bar: choose
      the `design.md` frontmatter `conflicts-with` value using the grammar in
      `docs/workflow.md` → "Declared conflicts (`conflicts-with`)" (default `—`
      when the plan declares none); ensure no self-reference and no duplicate
      target; and end the handoff by naming the plan-publication step. [AC4, AC5,
      AC12, AC13] [depends: T1]
      Verify: `rg -n 'conflicts-with|/ship plan|Declared conflicts'
      .opencode/agent/architect.md` shows the process/quality-bar entries; a
      read-through confirms they reference the authority and add no grammar of
      their own.

- [x] **T4** — Update `.opencode/command/plan.md` so the `/plan` phase describes
      the declaration and hands off to plan publication. State that
      `conflicts-with` is authored on `design.md` as part of the plan, and change
      the closing handoff's `Next:` to `/ship plan <item-ref>` (development
      begins only after the plan merges). [AC4, AC11, AC13] [depends: T3]
      Verify: `rg -n 'conflicts-with|/ship plan' .opencode/command/plan.md` shows
      both; a read-through confirms the handoff and that the text references
      `docs/workflow.md` rather than restating the grammar.

- [x] **T5** — Add the plan-publication flow to the workflow authority. Insert a
      new `## Plan publication` section in `docs/workflow.md` after the `## Phases`
      block (Phase 6 ends at `:295`) and before `## Derived state` (`:297`),
      stating: the plan is the item's `spec.md` + `design.md` + `tasks.md`; it is
      published by the shipper via `/ship plan <item-ref>` on a dedicated
      `plan/<ref>` branch and PR; the PR requires at least one human approval
      before merge; the plan must be merged to the default branch before `/build`
      (with the gate algorithm from the design as the observable form); a revised
      plan is republished through the same flow; a historical item with no plan PR
      is not blocked and needs no migration; and the declarations remain advisory.
      Update Phase 2 `/plan` `Next` (`:226`) and Phase 3 `/build` `Entry`
      (`:231`) to point at the step and the gate. Do not change the phase list,
      the derived-state table, or any phase heading. [AC1, AC2, AC3, AC6, AC8,
      AC9, AC11, AC13] [depends: T1]
      Verify: `rg -n 'Plan publication|plan/<ref>|/ship plan|human approval|gate'
      docs/workflow.md` shows the section and the two phase pointers; a read-through
      confirms the flow, revision, historical, and advisory rules and that no new
      phase or derived-state row was added; `bash tests/run.sh` exits 0.

- [x] **T6** — Add the plan-publication mode to the shipper. In
      `.opencode/agent/shipper.md` and `.opencode/command/ship.md`, document
      `/ship plan <item-ref>`: preconditions (`spec.md` and `design.md` exist; no
      `review.md` required; no secrets); create/switch to `plan/<ref>`;
      commit the plan artifacts as one conventional commit; push (ask) and open a
      PR with the plan template; require human approval and let a human merge;
      never write `ship.md`, never run pre-flight/reconcile, never merge; a
      revision adds commits to the same branch/PR (never force-push); an
      up-to-date already-merged plan is a no-op; when `gh` is unavailable, make
      the local commits and report the push/PR commands. Update the `/ship`
      argument grammar block to include the `plan` mode, keeping the canonical
      base signature and the exact fix-landing usage substring intact. [AC1, AC3,
      AC9, AC11] [depends: T5]
      Verify: `rg -n 'plan|plan/' .opencode/agent/shipper.md .opencode/command/ship.md`
      shows the mode and the branch convention; a read-through confirms shipper-only
      git writes, no `ship.md`, no merge/approve, and the revision/no-op rules;
      `bash tests/run.sh` exits 0 (the `/ship` signature assertions still pass).

- [x] **T7** — Add the plan PR description template to
      `.opencode/skill/pr-workflow/SKILL.md`. Add a `## Plan PR description
      template` with `Summary` (naming the item-ref), `Declared conflicts` (the
      item's `design.md` `conflicts-with` value, or `—`), `Plan artifacts`
      (`spec.md`, `design.md`, `tasks.md` by repository path), and `Testing`
      (the configured test command, or "plan-only; no code changed"). State that
      it omits the ship-time `## Conflict detection` and `## Reconcile` sections.
      [AC1, AC3, AC5, AC13] [depends: T5]
      Verify: `rg -n 'Plan PR|Declared conflicts|Plan artifacts'
      .opencode/skill/pr-workflow/SKILL.md` shows the template; a read-through
      confirms it references the authority for the declaration rather than
      restating the grammar.

- [x] **T8** — Document the plan-publication branch prefix in
      `.opencode/skill/conventional-commits/SKILL.md`. Under branch naming, state
      that pre-development plan publication uses a dedicated `plan/<ref>` branch,
      where `<ref>` is the canonical reference with `/` replaced by `-`, distinct
      from the item's final `<type>/<ref>` ship branch; never reuse the plan
      branch for the ship. [AC1, AC13] [depends: T5]
      Verify: `rg -n 'plan/' .opencode/skill/conventional-commits/SKILL.md`
      shows the branch-prefix rule with a nested-child example; a read-through
      confirms it matches the shipper prompt and `## Plan publication`.

- [x] **T9** — Add the `/build` plan-publication gate to the builder prompt and
      command. In `.opencode/agent/builder.md` (process/preconditions) and
      `.opencode/command/build.md`, state: before selecting a task, verify the
      plan is on the default branch (published); if it is absent and a
      `plan/<ref>` branch exists (local or `git ls-remote` on origin), **refuse**
      and report the plan PR that must be merged; if neither exists, proceed and
      note that no plan publication was found (historical/pre-flow item);
      unreachable `origin` degrades to the best-effort result and never hard-fails.
      Reference `docs/workflow.md` → `## Plan publication` for the algorithm
      rather than restating it. [AC2, AC9, AC10] [depends: T5]
      Verify: `rg -n 'plan/|plan publication|merged|default branch'
      .opencode/agent/builder.md .opencode/command/build.md` shows the gate; a
      read-through confirms refuse-on-unmerged, proceed-when-absent, and the
      authority reference; manual dry-run: with a `plan/<ref>` branch present and
      no default-branch plan, `/build` reports/refuses.

- [x] **T10** — Cross-surface consistency and regression. Read the plan and the
      declaration across every touched surface — `docs/workflow.md`,
      `docs/artifact-conventions.md`, `.opencode/agent/{architect,shipper,builder}.md`,
      `.opencode/command/{plan,ship,build}.md`,
      `.opencode/skill/pr-workflow/SKILL.md`,
      `.opencode/skill/conventional-commits/SKILL.md` — and confirm one home, one
      `0001` grammar reference, one advisory statement, and no restated grammar.
      Confirm no surface claims a new artifact, phase value, command, or
      derived-state row. [AC10, AC13] [depends: T1, T2, T3, T4, T5, T6, T7, T8, T9]
      Verify: `bash tests/run.sh` prints `TOTAL: ... 0 failed`; a cross-surface
      `rg -n 'conflicts-with|/ship plan|plan/<ref>|Plan publication'` plus a
      read-through shows agreement and no second taxonomy.
