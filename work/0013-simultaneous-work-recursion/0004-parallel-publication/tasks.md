---
feature: 0013-simultaneous-work-recursion/0004-parallel-publication
phase: tasks
status: final
created: 2026-10-13
updated: 2026-10-13
parent: 0013-simultaneous-work-recursion
---

# Tasks — Parallel plan publication under recursion

Ordered, dependency-aware. One task ≈ one focused commit.

- [x] **T1** — Define the collision-free reversible branch rule once in
      `.opencode/skill/conventional-commits/SKILL.md` → "Branch naming":
      `flatten(ref)` joins the reference's `/`-separated segments with `+` (a
      character outside the segment alphabet `[0-9]{4}-[a-z0-9-]+`), so the
      mapping is injective and reversible; both the ship branch
      (`<type>/<flatten(ref)>`) and the plan branch (`plan/<flatten(ref)>`) use the
      **same** flattened token; give the depth-2 and depth-3 examples and note the
      superseded `/` → `-` joined form. [AC1, AC2, AC3, AC10, AC12]
      Verify: read the "Branch naming" section; `rg -n 'flatten|\+0002|\+0003|superseded' .opencode/skill/conventional-commits/SKILL.md` shows the single definition; manually confirm `0013-simultaneous-work-recursion/0004-parallel-publication` → `0013-simultaneous-work-recursion+0004-parallel-publication` differs from a top-level `0013-simultaneous-work-recursion-0004-parallel-publication`.

- [x] **T2** — In `docs/workflow.md` → "Plan publication", replace the **Branch**
      bullet's `/` → `-` restatement with a reference to the single rule
      (`.opencode/skill/conventional-commits/SKILL.md` → "Branch naming") and
      update the example to the `+` form; add the no-migration clause: an
      already-merged plan stays valid, and a pre-existing unmerged branch under the
      superseded `/` → `-` name is **not** recognized by the gate. [AC2, AC9, AC11,
      AC12] [depends: T1]
      Verify: read the bullet; `rg -n 'plan/<ref>|flatten|conventional-commits|not recognized|no migration' docs/workflow.md` shows the reference, the `+` example, and the no-migration clause.

- [x] **T3** — In `docs/workflow.md` → "The `/build` plan gate", change the
      `plan_gate(item_ref)` algorithm to derive `ref = flatten(item_ref)` per the
      single rule (referencing the skill), and broaden step 1's published
      condition to `<default_ref> has work/<item_ref>/design.md or
      work/<item_ref>/manifest.md`; add a bullet that an old-format unmerged
      branch is not recognized and falls to case 3. Keep the content-aware
      refuse/unresolved/offline behavior unchanged. [AC7, AC8, AC9, AC11]
      [depends: T1]
      Verify: read the algorithm; `rg -n 'flatten|manifest.md|unmerged_plan|unresolved_plan|design.md' docs/workflow.md` shows the updated derivation and published condition.

- [x] **T4** — Sync the gate mirrors `.opencode/agent/builder.md` and
      `.opencode/command/build.md`: include a decomposing node's `manifest.md`
      among the artifacts `/build` reads; state that a manifest-only plan counts
      as published and that the `plan/<ref>` branch uses the collision-free
      flattening rule (reference `conventional-commits`), never the ambiguous old
      form. [AC7, AC9, AC12] [depends: T1, T3]
      Verify: read both files; `rg -n 'manifest.md|flatten|conventional-commits|plan/<ref>' .opencode/agent/builder.md .opencode/command/build.md`; `FRAMEWORK_TEST_AREAS='96-signature-sweep,40-inventory' bash tests/run.sh` exits 0.

- [x] **T5** — Update `.opencode/agent/shipper.md` plan-publication mode: (a) the
      mode's inputs read `spec.md`/`design.md`/`tasks.md` **or** the node's
      `manifest.md`; (b) the precondition admits a manifest-only plan
      (`spec.md`+`design.md` exist, **or** `manifest.md` exists); (c) the branch
      step references the `conventional-commits` rule instead of restating
      `/` → `-`; (d) the staging scope is the node's own plan state — manifest, own
      phase artifacts when present, and immediate child `.gitkeep` reservations,
      never a child's in-flight phase artifacts; (e) no `ship.md`, no pre-flight or
      reconcile, no final ship branch. Also fix the work-item-mode branch step to
      reference the rule. [AC4, AC5, AC6, AC12, AC13] [depends: T1]
      Verify: read the plan-mode section; `rg -n 'manifest|flatten|conventional-commits|gitkeep|ship.md' .opencode/agent/shipper.md` shows the manifest precondition/scope and no `/` → `-` restatement remains.

- [x] **T6** — Update `.opencode/command/ship.md` to mirror T5: plan-publication
      mode lists the manifest among the plan artifacts / precondition, references
      the branch rule, and states the manifest-plus-.gitkeep staging scope; fix the
      work-item-mode branch line to reference the rule. [AC4, AC5, AC6, AC12,
      AC13] [depends: T5]
      Verify: read the plan-mode section; `rg -n 'manifest|flatten|conventional-commits|gitkeep' .opencode/command/ship.md`; confirm no `/` → `-` restatement remains.

- [x] **T7** — Update `.opencode/skill/pr-workflow/SKILL.md` plan PR template's
      `## Plan artifacts` list to cover a decomposing node (link the node's
      `manifest.md` and its own artifacts when present) as well as a
      single-feature plan. [AC5] [depends: T5]
      Verify: read the plan template; `rg -n 'manifest|Plan artifacts' .opencode/skill/pr-workflow/SKILL.md` shows the manifest option.

- [x] **T8** — Update `CONTRIBUTING.md` → "Branch conventions" so the nested-child
      example uses the collision-free flattened form (referencing the rule) and add
      a depth-3 example; remove the `/` replaced by `-` sentence. [AC1, AC2, AC12]
      [depends: T1]
      Verify: read the section; `rg -n '0002-agentic-roadmaps|\+0002|Branch conventions' CONTRIBUTING.md` shows the `+` form and no `/` → `-` restatement.

- [x] **T9** — Cross-surface consistency pass and suite run: confirm only the
      single definition's "superseded" note mentions the old literals; confirm no
      new readiness edge, `phase` value, or state file was introduced; confirm the
      declared-conflict/advisory language is unchanged; confirm plan mode still
      writes no `ship.md`, runs no reconcile, and creates no ship branch.
      [AC12, AC13, AC14, AC15] [depends: T1, T2, T3, T4, T5, T6, T7, T8]
      Verify: `rg -n 'with "/" -> "-"|replaced by `-`|NNNN-slug-MMMM-slug' docs .opencode CONTRIBUTING.md AGENTS.md README.md tests` returns only the rule's superseded note (no live-surface fork); `bash tests/run.sh` exits 0.
