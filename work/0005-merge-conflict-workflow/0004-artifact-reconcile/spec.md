---
feature: 0005-merge-conflict-workflow/0004-artifact-reconcile
phase: spec
status: final
created: 2026-10-07
updated: 2026-10-07
notes: "Nested roadmap child; dependencies 0001-conflict-model and 0002-conflict-detection are satisfied (both have ship.md present), so it is ready. User resolved three forks: (1) delivery form is a documented, agent-executable procedure in the merge-conflict skill and the shipper//ship wiring, not an executable script; (2) structural work/ graph faults auto-repair, intent-dependent faults escalate per 0001; (3) the normative 'Renumbering after a parallel merge' text stays unchanged and the automation is operational only, so no second renumbering rule is defined."
parent: 0005-merge-conflict-workflow
---

# Reconcile workflow for `work/` artifacts and sequence numbers

## Problem

The merge-conflict contract classifies `work/` artifact conflicts (class b) and
duplicate sequence numbers (class c) (`docs/workflow.md:344-351`), and sibling
`0003-shared-surface-reconcile` made the shared-surface reconcile executable. But
the `work/`-specific repair remains an unexecutable hand procedure: merging
roadmap `Children` tables and their `Depends on` cells, repairing dangling,
missing, unlisted, or cyclic references, and performing the "Renumbering after a
parallel merge" rule (`docs/artifact-conventions.md:445-472`). The
`merge-conflict` skill currently defers class (c) to that rule and states in
parentheses that "automated renumbering and graph repair remain sibling `0004`"
(`.opencode/skill/merge-conflict/SKILL.md:179-188`); nothing tells the shipper
*how* to detect the collision, *which* item to renumber, or what to do when the
rule cannot be applied mechanically. The only concrete automation is a
single-scenario fixture inside a shipped child's read-only verification script
(`work/0003-framework-quality-hardening/0001-state-model/verify-tests.sh`), not a
reusable procedure.

**Framework maintainers** shipping roadmap-child branches, and **adopters**
running parallel work items, both inherit this gap: when two branches allocate
the same number or edit the same roadmap table, the shipper can detect the
collision (sibling `0002`) but has no defined order of operations to repair it,
no rule for choosing an item when the contract's tie-break is not mechanically
decidable, and no defined escalation when a graph fault needs a judgment about
intent. The result is a hand merge with no reviewable record beyond a free-text
note, exactly the manual gap this initiative exists to close.

## Goals

- A `work/`-artifact reconcile that the shipper can execute during `/ship`:
  artifact frontmatter, roadmap `Children` rows, and `Depends on` cells are merged
  preserving both branches' records, dropping neither side.
- The existing "Renumbering after a parallel merge" rule is made operational:
  detect equal top-level `NNNN` and per-parent `MMMM` prefixes (including a
  collision that exists only between the two branches), choose one item by the
  contract's rule, move it, and update every reference in one change without
  reusing a spent number.
- After a merge, the roadmap dependency graph is re-checked to be acyclic and
  every `Depends on` local id resolves to an existing row and child directory;
  structural faults are repaired mechanically and intent-dependent faults
  escalate.
- The reconcile is bounded: it preserves both branches' records, never silently
  resolves an intent conflict, and never forks the normative renumbering rule.
- The committed suite stays green and no new command, agent, skill, artifact
  format, lifecycle phase, or committed check is introduced.

## Non-goals

- **Read-only pre-flight detection and classification** — shipped as sibling
  `0002-conflict-detection`; this child consumes its findings.
- **Shared-surface textual reconcile mechanics** — shipped as sibling
  `0003-shared-surface-reconcile`; this child owns only the `work/`-specific
  repairs.
- **Committed merge-integrity guards and mutation coverage** — sibling
  `0005-merge-integrity-guards`; this child adds no committed check.
- **An executable reconcile script or any runtime code** — resolved as out of
  scope by the user; the deliverable is a documented, agent-executable procedure.
- **Changing the normative "Renumbering after a parallel merge" text in
  `docs/artifact-conventions.md`** — it stays the single normative definition; the
  new automation is operational and adds no second rule.
- **A new command, agent, skill, phase, or artifact format.** Reconciliation
  remains a step inside `/ship` owned by the shipper.
- **Rebase, force-push, or automatic resolution of a semantic conflict** — all
  remain excluded by the `0001` principles.
- **Reopening the state model, readiness model, permission-class model, or the
  shipped sibling work** (`0003-framework-quality-hardening`,
  `0004-adoption-template-split`).
- **Structurally de-duplicating the shared surfaces** so parallel branches stop
  colliding — a deliberate roadmap omission.

## Users and stories

- **As the** shipper agent, **I want** an ordered, executable procedure for
  `work/`-artifact conflicts and sequence renumbering, **so that** I can complete
  a merge that collides on `work/` artifacts instead of detecting it and
  stopping.
- **As a** framework maintainer whose branch collided on a roadmap `Children`
  table or a duplicate sequence number, **I want** the reconcile to choose and
  renumber deterministically per the existing contract, **so that** the result is
  reviewable and no number is ever reused.
- **As a** reviewer, **I want** the repaired references, the chosen renumbers, and
  the re-verification evidence recorded, **so that** I can confirm both branches'
  records survived and the graph is consistent before I approve.
- **As the** shipper agent, **I want** an unambiguous escalation for a graph fault
  or a renumber choice that needs a judgment about intent, **so that** I never
  silently drop a record, reassign a number, or break a dependency.
- **As an** adopter running parallel work items, **I want** the framework to
  define the `work/` reconcile the same reviewable way for me, **so that** I do
  not have to invent the procedure when my items collide.

## Acceptance criteria

1. **AC1** — Given the `merge-conflict` skill and the shipper's `/ship` reconcile
   step, when the `work/` reconcile is read, then it specifies an ordered,
   agent-executable procedure that merges colliding `work/` artifact content —
   artifact frontmatter, roadmap `Children` rows, and `Depends on` cells —
   preserving both branches' records and dropping neither side.

2. **AC2** — Given both branches edited a roadmap parent's `Children` table, when
   the reconcile completes, then the merged table contains both branches' rows,
   and each surviving row's `Depends on` cell is preserved or reconciled without
   silently discarding a branch's dependency.

3. **AC3** — Given the merged tree after a `work/` reconcile, when the roadmap
   dependency graph is re-checked, then every `Depends on` local id resolves to an
   existing row and child directory and the stored graph is acyclic; a fault the
   procedure can repair mechanically (a structural fault) is repaired, and a fault
   requiring a judgment about intent is not silently resolved and escalates per
   AC8.

4. **AC4** — Given the `work/` reconcile, when sequence-prefix collisions are
   inspected, then it detects equal top-level 4-digit `NNNN` prefixes and equal
   per-parent 4-digit `MMMM` prefixes, including a collision that exists only
   between the item branch and the default branch, and reports each with its
   canonical reference(s).

5. **AC5** — Given a detected sequence-prefix collision, when the reconcile
   selects one item to renumber, then it applies the existing "Renumbering after a
   parallel merge" rule — the item not yet approved or shipped, then the directory
   added later by commit time, then slug order — and allocates the next number
   from the existing sequence-allocation contract, never reusing a spent number.

6. **AC6** — Given a chosen renumber, when the item is moved, then every
   reference is updated in the same change — the directory name, the artifact
   `feature` frontmatter, a nested child's `parent` value, the roadmap `Children`
   table's `Local id` and `Canonical reference` cells for the renumbered row, every
   `Depends on` cell that names the old local id, the shipped record, the
   pull-request and handoff paths, and any prose naming the old reference — and no
   reference to the old canonical reference remains.

7. **AC7** — Given a sequence-prefix collision for which the contract's choice is
   not mechanically decidable — for example the items cannot be distinguished by
   approval, shipped state, commit time, or slug order, or both are already
   shipped — when the reconcile reaches it, then it does not guess: it escalates
   per AC8 rather than reassigning a number arbitrarily.

8. **AC8** — Given a `work/` conflict or graph fault whose resolution requires a
   judgment about competing intents — a dangling dependency whose correct target
   is ambiguous, a cycle, a deliberately removed child, or an undecidable renumber
   choice — when the reconcile reaches it, then it does not resolve it silently:
   it aborts the merge to restore a clean working tree, reports the specific
   blocked reference(s) and the decision the user must make, and the ship stays
   blocked until the user responds.

9. **AC9** — Given any `work/`-reconcile resolution, when it completes, then the
   committed suite (`bash tests/run.sh`) and the affected item's checks are
   re-run and must be green before the resolved merge is committed, recorded, or
   shipped; a resolution whose re-verification fails is not accepted and the
   failing check is reported as the blocker.

10. **AC10** — Given the reconcile completes, when the shipped record and pull
    request are written, then the `work/` paths resolved, the renumber(s) chosen,
    and the re-verification evidence are recorded in the `ship.md` `## Reconcile`
    record and the pull-request description, so a reviewer can confirm both
    branches' records survived and which canonical reference was renumbered.

11. **AC11** — Given an item branch already up to date with the default branch and
    no duplicate sequence prefix between the branches, when the `work/` reconcile
    runs, then it reports no conflicts, performs no renumber or move, does not
    error, and creates no merge commit.

12. **AC12** — Given the repository after the change, when the normative
    "Renumbering after a parallel merge" section is read, then it is unchanged and
    remains the single normative definition of renumbering; the new automation
    references and applies it and defines no second renumbering rule.

13. **AC13** — Given the repository after the change, when `bash tests/run.sh`
    runs, then it passes, including the inventory, lifecycle, permission, and
    signature agreements; no new command, agent, skill, or committed check is
    added and no updated line duplicates an existing agreement.

14. **AC14** — Given the repository after the change, when the lifecycle phases,
    artifact formats, readiness/state models, and the command, agent, and skill
    inventories are inspected, then none gains or loses an entry, no new phase or
    command exists, no executable file is added, and the only artifact-record
    change is the additive reconcile record already defined by sibling `0003`
    (AC10).

## Edge cases

- **Empty or placeholder-only `work/` tree.** No directories to reconcile: report
  no findings and complete as a no-op.
- **Same number, different slug.** Both branches add distinct top-level
  directories under the same `NNNN` (or a parent's children under the same
  `MMMM`): a class (c) collision even though the slugs differ; renumber per AC5.
- **Same canonical reference, differing content.** Both branches add the same
  directory name: not just a prefix collision but a content conflict; preserve
  both branches' records per AC1, then re-check the graph (AC3) — a duplicate
  local id is reconciled or escalated, never silently dropped.
- **Dangling `Depends on` after the merge.** A `Depends on` names a local id with
  no table row or child directory. Repair only when the correct target is
  unambiguous; otherwise escalate (AC8).
- **Cycle introduced by the merge.** Two children end up depending on each other:
  a cycle cannot be mechanically broken; escalate (AC8) and do not store a
  circular graph.
- **Unlisted child.** A child directory survives the merge but its `Children` row
  is absent: if restoring the row requires choosing title/scope/intent, escalate
  (AC8).
- **Missing child.** A `Children` row survives but its directory is absent (for
  example the other branch renumbered it): reconcile via the renumber reference
  update (AC6) when the intent is unambiguous; otherwise escalate (AC8).
- **Renumbered child is a dependency.** When a renumbered child's local id
  changes, every `Depends on` cell that names the old local id is updated in the
  same change (AC6); a dependency graph left dangling by the move is re-checked
  (AC3).
- **All candidates shipped.** Both colliding items already have a shipped signal:
  the contract cannot choose; escalate (AC7, AC8).
- **Undecidable order.** Item approval/shipped state cannot be determined, or git
  history is unavailable (for example a shallow clone), so "added later" cannot be
  established: escalate (AC7, AC8) rather than guess.
- **Both branches renumbered the same item differently.** Two different new
  numbers are proposed for one item: a judgment about intent; escalate (AC8).
- **Number already spent.** The chosen next number was previously used and its
  directory deleted: the allocation contract forbids reuse, so allocate the next
  free number rather than the deleted one (AC5).
- **Re-verification fails after a repair.** The repair is not accepted: the merge
  is not committed, recorded, or shipped, and the failing check is reported as the
  blocker (AC9).
- **Large collision set.** Every colliding prefix and every reference is
  reported; the list is never truncated.
- **Concurrent ships on the same branch.** Out of scope; the reconcile takes no
  lock and assumes one shipper per branch.
- **Nothing to reconcile.** Branch up to date and no cross-branch collision: a
  no-op that does not error and creates no merge commit (AC11).

## Open questions

- [x] **Delivery form** — **resolved (user):** a documented, agent-executable
      procedure in the `merge-conflict` skill and the shipper/`/ship` wiring; no
      executable reconcile script.
- [x] **Repair authority** — **resolved (user):** structural `work/` graph and
      sequence faults auto-repair; any fault needing a judgment about intent
      escalates per the `0001` principles (AC3, AC8).
- [x] **Documentation locus** — **resolved (user):** the normative renumbering
      text is unchanged; the automation is operational and references it (AC12).
- [ ] **Exact ordered sub-steps and command forms** for detecting the collision,
      selecting, moving, and rewriting references, and their fallbacks on older
      git. — owner: architect, needed by: design. **Deferred.**
- [ ] **Where the `work/` reconcile sits in the procedure** — a distinct
      sub-sequence inside the existing reconcile step or a new step beside it —
      and how it consumes the sibling `0002` pre-flight findings. — owner:
      architect, needed by: design. **Deferred.**
- [ ] **Record shape for a renumber** — whether the existing `## Reconcile`
      record is extended or a nested renumbered-references list is added, without
      changing readiness (which keys on `ship.md` presence). — owner: architect,
      needed by: design. **Deferred.**
- [ ] **Whether any shipper permission changes are needed.** The shipper already
      holds `git mv*` (`.opencode/agent/shipper.md:42`) and edit access to
      `work/**` and the class (a) shared surfaces; design confirms no new grant is
      required and that the never-merge/never-force-push guardrails and the
      documented-vs-declared permission agreement stay green. — owner: architect,
      needed by: design. **Deferred.**

## Dependencies and constraints

- **Dependencies satisfied, item is ready.** The parent `roadmap.md` lists this
  child as `Depends on: 0001-conflict-model, 0002-conflict-detection`; both child
  directories contain `ship.md`, so both dependencies are satisfied and this child
  is ready (`docs/workflow.md:87-108`). It is sequenced after sibling
  `0003-shared-surface-reconcile` because the two extend the same
  `merge-conflict` skill and the same shipper/`/ship` surfaces
  (`work/0005-merge-conflict-workflow/roadmap.md:89-97`).
- **Consumes the `0001` contract.** The taxonomy, lifecycle placement, ownership,
  merge-forward principle, structural-auto/semantic-escalate rule, and
  re-verification requirement are authoritative in `docs/workflow.md` →
  `## Merge conflicts` and operational in the `merge-conflict` skill; this child
  defines no second policy.
- **Consumes the `0002` detection vocabulary.** `DUPLICATE-PREFIX`,
  `DUPLICATE-CHILD`, `DANGLING-DEP`, `MISSING-CHILD`, `UNLISTED-CHILD`, and
  `CYCLIC-DEP` are already defined and reported
  (`.opencode/skill/merge-conflict/SKILL.md:109-121`,
  `.opencode/agent/status.md:135-147`); this child is the procedure that resolves
  them, not a re-specification of detection.
- **Builds on, never forks, the renumbering rule.** `docs/artifact-conventions.md`
  → "Renumbering after a parallel merge" (`:445-472`) is the single normative
  definition; AC6's inclusion of the `Local id` and `Depends on` cells is an
  application of its "update every reference" step, not a new rule.
- **Replaces the sibling deferral.** The skill's resolve substep currently says
  automated renumbering and graph repair remain sibling `0004`
  (`.opencode/skill/merge-conflict/SKILL.md:179-188`); this child replaces that
  deferral with the operational procedure.
- **Suite constraints.** The committed suite is read-only, provider-neutral, and
  never reads `work/**` (`tests/README.md:29-30`), so this child's evidence is an
  item-level read-only verification script plus `bash tests/run.sh` (the
  `0002`/`0003` precedent); committed merge-integrity guards are sibling `0005`.
- **Shipper is the only git writer and owns reconciliation**
  (`.opencode/agent/shipper.md:205-223`); broadening nothing here must leave the
  never-merge-a-PR and never-force-push guardrails intact, and the
  documented-vs-declared permission agreement
  (`tests/checks/30-permissions.sh`) green.
- **Inventory constraint.** No agent, command, or skill is added, so the README
  Layout counts and `tests/checks/40-inventory.sh` must not change (AC13).
- **Shipped siblings are context, not scope** (`0003-framework-quality-hardening`,
  `0004-adoption-template-split`); their surfaces are not re-opened.
- **Assumption:** the reconcile creates a merge commit on the item branch only;
  the shipper never writes to the default branch, consistent with the existing
  guardrails.
- **Assumption:** because the deliverable is the framework's own prompts,
  configuration, and documents, the acceptance criteria name the required behavior
  and the surfaces that must carry it so they are testable; they state required
  behavior, not implementation choices.
