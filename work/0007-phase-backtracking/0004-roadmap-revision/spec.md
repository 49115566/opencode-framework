---
feature: 0007-phase-backtracking/0004-roadmap-revision
phase: spec
status: final
created: 2026-10-08
updated: 2026-10-08
notes: "Nested roadmap child; directory held only .gitkeep and its scope is the parent roadmap's 0004 row, so the roadmap supplies the requirements. Depends on: 0001-backtracking-model, satisfied by its committed ship.md, so the child is ready and no override is needed. User resolved the five policy forks: (1) invocation is a revision mode of the existing roadmap command, not a new command; (2) provenance is the triggering child's committed backtrack record plus the updated parent roadmap, preserving prior content in git history; (3) a withdrawn child mirrors the shipped 0003/0009 handling; (4) every existing child whose row is re-scoped or re-sequenced is invalidated (marked stale), not just the triggering child; (5) a revision is written autonomously like the roadmap command today, without a pre-write approval gate."
parent: 0007-phase-backtracking
---

# Parent-roadmap revision from child phases

## Problem

A child phase can discover that its **parent `roadmap.md` is wrong** — a child is
mis-scoped, a needed feature is missing, a withdrawn feature should be removed,
or two children are sequenced so a dependency points forward — but there is no
sanctioned way to correct the parent. The roadmap command only ever authors a
**new** parent: `work/0003-framework-quality-hardening/0009-surface-consistency/spec.md:8`
records the limitation verbatim ("`/roadmap` only creates a new parent (it cannot
amend the existing one)"). So the maintainer either starts a duplicate roadmap or
hand-edits the parent, bypassing the roadmap agent's ownership and validation
rules (`.opencode/agent/roadmap.md:131-140`). The `0001-backtracking-model`
initiative sanctions a per-item phase→parent-`roadmap.md` reverse edge and
reserves the `roadmap` stale token for it, but explicitly assigns the route to
this item (`docs/workflow.md` → "Phase reversal (backtracking)"), so today that
edge has no implementation and a child phase can only halt and report.

The people who pay for the gap are **framework maintainers** running the
lifecycle, who cannot repair a plan they own without either duplicating it or
breaking the artifact contract, and **adopters**, who inherit the same one-way
plan and the same dead end. The fix must revise the existing parent in place,
preserve every existing child directory, number, and its history, and keep the
plan internally consistent — acyclic, no dangling or accidental unlisted
children, and sequenced so every dependency precedes its dependents.

## Goals

- Give a child phase a sanctioned way to feed a correction back into its parent
  roadmap, revising the existing parent in place rather than creating a new work
  item.
- Support the four revision operations — re-scope, add, withdraw, and re-sequence
  children — while preserving existing child directories, local numbers, and
  history.
- Create and number child directories for newly enumerated features, allocating
  the next local number from the parent's committed history and never reusing a
  spent number.
- Keep the revised plan internally consistent: every dependency precedes its
  dependents, every `Depends on` resolves to a sibling row and directory, the
  stored graph is acyclic, and no active child is missing or unlisted.
- Record a withdrawn child without reusing its number, mirroring the shipped
  `0003`/`0009` withdrawal handling.
- Record the revision's provenance in committed state — the triggering child's
  backtrack record plus the updated parent — so a reader can audit what changed
  and why, and the pre-revision roadmap remains recoverable from git history.
- Invalidate, non-destructively, every existing unshipped child whose row is
  re-scoped or re-sequenced, so no downstream work proceeds against a changed
  plan.
- Update the roadmap agent, the roadmap command, the roadmap template, and the
  roadmap/readiness authority surfaces, reusing the `0001` model's record,
  markers, and vocabulary, and keeping the committed suite green.

## Non-goals

- The intra-item reverse routes (`/build`→`/plan`, `/plan`→`/spec`, `/test`→…,
  `/review`→`/build`) and their wiring — owned by `0002-reverse-phase-routing`.
- Contesting or adjudicating a finding — owned by `0003-findings-challenge-loop`.
- Post-ship PR denial, recall, and reopen, including revoking the shipped signal
  — owned by `0005-post-ship-pr-denial`.
- The full `/status` and derived-state reporting vocabulary — owned by
  `0006-status-and-derived-state`.
- Committed fixtures, agreement areas, and mutation coverage for the revision —
  owned by `0007-backtracking-guards`.
- Automatic re-planning or re-scheduling of children not driven by a stated
  revision (for example re-balancing load); the parent roadmap already records
  this as out of scope.
- Branch-level merge reconcile and any conflict resolution between branches —
  owned by the shipped `0005-merge-conflict-workflow`.
- A new top-level work item, a new command, agent, or skill, a new `phase` value,
  a new state file, or any change to the `Depends on`/readiness semantics.
- Editing a **shipped** child's artifacts: the `0001` model excludes an item
  whose `ship.md` is present from a backtrack, and this item does not change that.
- Reworking the six-column `Children` layout, the declared-conflict grammar, or
  the finding/severity vocabulary; the revision reuses them.
- Rewriting or pruning historical records; a revision preserves prior content in
  committed git history rather than deleting it.

## Users and stories

- **As a** product agent whose spec revealed the parent roadmap is mis-scoped,
  **I want** a sanctioned route to send that correction back to the roadmap
  owner, **so that** the plan is fixed rather than my halting, starting a
  duplicate roadmap, or hand-editing the parent.
- **As an** architect whose design cannot fit the roadmap's child boundaries,
  **I want** to route the finding to the parent roadmap, **so that** the plan is
  revised and my item can proceed against a correct one.
- **As a** framework maintainer, **I want** a revision to preserve existing child
  directories and numbers and to record its provenance, **so that** I can trust
  the committed plan and later audit why it changed.
- **As a** framework maintainer, **I want** children whose rows were re-scoped or
  re-sequenced marked stale, **so that** no downstream work silently continues
  against a changed plan.
- **As an** adopter, **I want** the revision to reuse the roadmap, backtrack, and
  finding vocabulary the framework already ships, **so that** I do not maintain a
  second one.

## Acceptance criteria

1. **AC1** — Given an existing parent roadmap, when a revision is invoked, then
   the parent's `roadmap.md` is updated in place — its canonical reference,
   `feature` value, and child local numbering are unchanged — and no new
   top-level work item is created.

2. **AC2** — Given a revision that re-scopes an existing child, when it is
   applied, then that child's row (title and scope) is updated in place, its local
   id and directory are preserved, and the child is invalidated per AC5.

3. **AC3** — Given a revision that enumerates a new feature, when it is applied,
   then a new child row is added with the next local number allocated from that
   parent's committed history (a spent number is never reused), a matching empty
   child directory is created, and the row's canonical reference resolves to that
   directory.

4. **AC4** — Given a revision that withdraws a child, when it is applied, then
   the row is removed from the `Children` table and the `## Sequencing` list, the
   child's directory and spent local number are preserved, and the withdrawal and
   its rationale are recorded under the roadmap's `## Open issues`; the number is
   never reused. This mirrors the shipped `0009-surface-consistency` handling
   (`work/0003-framework-quality-hardening/roadmap.md:87-95`).

5. **AC5** — Given a revision that re-scopes an existing child's row or
   re-sequences it, when the revision is applied, then every affected existing
   unshipped child's artifacts are marked stale in committed state per the `0001`
   model (with the parent-`roadmap` target), so the child derives its target
   phase and must re-run forward; unaffected children are untouched; no artifact
   is deleted or silently rewritten; and the prior content remains recoverable
   from committed git history.

6. **AC6** — Given a revised roadmap, when the `## Sequencing` list is read, then
   it lists every child after all of its dependencies, so every `Depends on`
   reference precedes its dependents.

7. **AC7** — Given a revised roadmap, when the `Children` table and the child
   directories are validated, then every `Depends on` value names another row in
   the same table, no child depends on itself, the stored graph is acyclic, every
   row's canonical reference resolves to an existing child directory, and every
   child directory in the active set appears as a row; if the intended
   dependencies contain a cycle, the revision stores no cyclic edge and records
   the cycle under `## Open issues`.

8. **AC8** — Given a child withdrawn under AC4 whose directory is retained, when
   roadmap integrity is derived, then the retained directory is recognized as a
   deliberate withdrawal and reported report-only (never auto-repaired) rather
   than treated as an accidental graph fault.

9. **AC9** — Given a revised roadmap, when the `Children` table is read
   positionally, then it still has the six columns with `Depends on` at
   pipe-field 5 and `conflicts-with` at pipe-field 6, and every `conflicts-with`
   cell is `—` or a well-formed conflict-target list; the committed cycle and
   declared-conflict guards stay green.

10. **AC10** — Given a revision triggered by a child phase's finding, when the
    revision completes, then the triggering child records the finding and its
    resolution in its committed backtrack record (per the `0001` model), the
    parent roadmap's `updated` date changes and the revision is noted, and the
    pre-revision roadmap content remains recoverable from committed git history.

11. **AC11** — Given the product or architect phase discovers that the parent
    roadmap is wrong, when it acts, then its prompt names the sanctioned revision
    route and records the finding; it does not edit the parent roadmap itself,
    and only the roadmap owner writes the parent.

12. **AC12** — Given a revision, when it runs, then it writes without a pre-write
    approval gate, as the roadmap command does today; the user reviews the
    committed revision after the fact.

13. **AC13** — Given the documented invocation surface is a revision form of the
    existing roadmap command, when the command usage string and every surface
    that states command signatures are read, then they state one consistent
    signature for it, no new command is added, and the committed command-signature
    agreement stays green.

14. **AC14** — Given the repository after the change, when the project's
    configured test command runs, then it passes; the six `phase` values, the
    derived-state contract, and the `Depends on`/readiness semantics are
    unchanged; and no documented inventory count changes.

15. **AC15** — Given the roadmap/readiness authority, when it is read after the
    change, then it describes the revision route and the integrity invariants a
    revision must preserve, referencing the `0001` model rather than restating a
    second reverse-transition, state, or finding vocabulary.

## Edge cases

- **Revision before any child has artifacts.** When every child holds only a
  `.gitkeep`, invalidating a re-scoped child marks nothing; it simply derives
  `not started`, and the revision does not error.
- **Withdrawing a child another child depends on.** This would leave a dangling
  dependency; the revision must not silently pick a resolution. It either also
  withdraws or re-points the dependents, or refuses and reports the ambiguous
  intent rather than storing a fault.
- **Adding a child whose dependencies would create a cycle.** The revision stores
  no cyclic edge; it records the cycle under `## Open issues` and leaves the
  stored graph acyclic.
- **Re-sequencing an already acyclic graph.** Re-ordering only; it never
  introduces a cycle or a duplicate local number.
- **Re-scoping a shipped child (Assumption).** The `0001` model excludes a
  shipped item from a backtrack, so the revision must not rewrite a shipped
  child's artifacts; it surfaces the conflict for the user rather than silently
  invalidating the shipped child. See Open questions.
- **Duplicate local number attempted.** A revision that would reuse a spent local
  number is refused; the number stays spent.
- **Empty revision.** A revision request that changes nothing is a no-op and
  modifies no file.
- **Withdrawn directory surfaces as unlisted.** Retaining a withdrawn child's
  directory (AC4) intentionally surfaces as a report-only listed-child finding
  (`UNLISTED-CHILD`, as `work/0003-framework-quality-hardening/0009-surface-consistency`
  does today); AC8 requires it to be treated as a deliberate withdrawal, not a
  fault to auto-repair.
- **Revision invoked on a non-parent reference.** A reference that is not a
  roadmap parent is refused; the revision mode revises a parent, it does not
  create one.
- **Concurrent revisions to the same parent on two branches.** The revision takes
  no lock and writes only its own committed state; the resulting `work/` artifact
  conflict is a class (b) merge conflict handled by the shipped merge-conflict
  contract, which preserves both branches' rows rather than dropping one.
- **A dependency target withdrawn in the same revision.** The graph is validated
  after all four operations are applied, so a re-point or removal is judged on
  the final state, never the intermediate one.

## Open questions

- [x] **Invocation surface** — resolved (user): a revision **mode of the existing
  roadmap command** (for example a revise form taking a parent reference); no new
  command. The canonical command signature and every surface stating it, plus the
  committed signature agreement, change together (AC13).
- [x] **Provenance home** — resolved (user): the triggering child records the
  finding and resolution in its committed backtrack record (per `0001`), and the
  parent roadmap is updated in place; prior content stays in git history (AC10).
- [x] **Withdrawal record** — resolved (user): mirror the shipped `0003`/`0009`
  handling — drop the row from `Children` and `Sequencing`, keep the directory
  and spent number, record under `## Open issues` (AC4, AC8).
- [x] **Invalidation scope** — resolved (user): every existing child whose row is
  re-scoped or re-sequenced is invalidated (marked stale), not only the child
  that raised the finding (AC5).
- [x] **Approval gate** — resolved (user): autonomous, like the roadmap command
  today; no pre-write approval gate (AC12).
- [ ] **Assumption — shipped child in a re-scope.** Because `0001` excludes a
  shipped item from a backtrack, a revision that re-scopes or re-sequences a
  shipped child will not rewrite that child's artifacts; it must surface the
  conflict for the user. Confirm this conservative behavior, or define how a
  revision invalidates a shipped child (which would touch the shipped signal and
  is otherwise `0005`/`0006` territory). — owner: user, needed by: design.
- [ ] **Deferred — exact invocation syntax and marker/record wording.** The
  precise revise-mode syntax, the roadmap revision note's wording, and the
  `stale`/`backtracks.md` values are design choices; the semantics above are
  fixed and reuse the `0001` vocabulary. — owner: architect, needed by: design.

## Dependencies and constraints

- **Ready.** The parent roadmap lists this child as `Depends on:
  0001-backtracking-model`, satisfied by that child's committed `ship.md`
  (`work/0007-phase-backtracking/0001-backtracking-model/ship.md`); no override is
  needed.
- **Keystone consumed.** `0001-backtracking-model` ships the model this item
  implements: the per-item append-only `backtracks.md` record, the `stale`/
  `reopened` frontmatter markers, the `stale: roadmap` token that maps to `spec`
  when derived, and the sanctioned phase→parent-`roadmap.md` edge. This item
  reuses them and defines no second reverse-transition or state vocabulary
  (`docs/workflow.md` → "Phase reversal (backtracking)";
  `docs/artifact-conventions.md` → "`backtracks.md`").
- **Extend, do not fork.** The revision extends the roadmap template and
  `Children` contract (`docs/artifact-conventions.md:80-136`), the
  roadmap/readiness rules (`docs/workflow.md` → "Roadmaps"), the roadmap agent
  (`.opencode/agent/roadmap.md:61-131`), and the `/roadmap` command
  (`.opencode/command/roadmap.md`). It reopens none of the shipped `0001`–`0006`
  decisions.
- **Command-signature coupling.** The `/roadmap` signature is pinned by
  `tests/checks/96-signature-sweep.sh` at `docs/workflow.md`, root `AGENTS.md`,
  `template/AGENTS.md`, `README.md`, and the `workflow-lifecycle` skill, plus each
  command's own usage string (`96-signature-sweep.sh:37-52,226-291`). Adding a
  revision form changes the canonical signature, so all those positions and the
  sweep's expected literals must change together and the suite must stay green
  (AC13, AC14). No new command is added, so the README inventory counts are
  unchanged.
- **Positional `Children` contract.** The six-column header, `Depends on` at
  pipe-field 5, and `conflicts-with` at pipe-field 6 must stay green under
  `tests/checks/85-conflict-guards.sh:35,390-401` and
  `tests/checks/80-cycle-fixture.sh:27-98`; this item coordinates with the
  shipped `0006`/`0004-conflict-guards` rather than forking the layout (AC9).
- **Committed suite constraints.** The suite is read-only and never reads live
  `work/**` (`tests/README.md:29`); the existing agreements
  (`10-readiness.sh`, `20-lifecycle.sh`, `40-inventory.sh`, `80-cycle-fixture.sh`,
  `85-conflict-guards.sh`, `96-signature-sweep.sh`) must remain green. New
  fixture guards and mutation coverage are `0007-backtracking-guards`, not this
  item.
- **Ownership invariant.** Only the roadmap owner writes the parent `roadmap.md`;
  the detecting child phase records the finding and hands control up, per the
  `0001` model.
- **Shipped exclusion.** An item whose `ship.md` is present is out of scope for a
  backtrack; this item does not change the shipped signal or the readiness
  contract (`docs/workflow.md` → "Dependencies and readiness").
- **Precedent for withdrawal.** The shipped `0003`/`0009` withdrawal
  (`work/0003-framework-quality-hardening/roadmap.md:87-95`,
  `work/0003-framework-quality-hardening/0009-surface-consistency/spec.md`) is the
  pattern this item mirrors; it already produces a report-only `UNLISTED-CHILD`
  observation that the merge-conflict skill classifies as a deliberate removal
  (`.opencode/skill/merge-conflict/SKILL.md:353-357`).
- **Sibling boundaries.** Intra-item routing is `0002`; challenge adjudication is
  `0003`; post-ship reopen is `0005`; status/derived-state reporting is `0006`;
  committed guards are `0007`. This item owns only the parent-roadmap revision
  route.
- **Framework-internal change only.** Docs, prompts, and tests; no runtime
  dependency, service, or new toolchain.
- **Assumption — naming surfaces for testability.** Because the deliverable is
  the framework's own documents and prompts, the acceptance criteria name the
  surfaces that must carry the revision route; they specify required content, not
  implementation choices.
