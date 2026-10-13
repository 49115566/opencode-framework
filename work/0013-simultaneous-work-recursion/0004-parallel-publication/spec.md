---
feature: 0013-simultaneous-work-recursion/0004-parallel-publication
phase: spec
status: final
created: 2026-10-13
updated: 2026-10-13
parent: 0013-simultaneous-work-recursion
notes: "User decisions 2026-10-13: (1) collision-free reversible encoding used by BOTH the plan branch and the final ship branch (one shared flattened form, defined once); (2) keep the /build plan gate's builder/build mirrors in sync in this change (required consistency, not the Roadmap 4 sweep); (3) no migration — already-merged plans are read from the default branch, and a pre-existing unmerged branch under the old flattened name is not recognized. Child Depends on is — and it is ready."
---

# Parallel plan publication under recursion

## Problem

Framework maintainers — and the adopters who inherit this workflow — can no
longer publish and gate plans safely when independent work items run at the same
time at **any depth** of the recursive plan tree. Two concrete faults break that.

First, a work item's plan and ship branch names are produced by flattening its
canonical reference with `/` → `-`. Because `-` is a legal character **inside**
a reference segment and is also the flattening separator, the mapping is not
injective: the nested child `NNNN-slug/MMMM-slug` and a distinct top-level item
literally named `NNNN-slug-MMMM-slug` both flatten to `NNNN-slug-MMMM-slug`. Two
independent work items therefore share one branch name. One publication can
overwrite the other's branch, and the build gate can resolve to the wrong
reference's plan — silently, with no error.

Second, plan publication is still scoped to single-feature nodes. The shipper's
plan-mode precondition requires the item's requirements and design artifacts,
and the build gate recognizes a published plan by the presence of the item's
design artifact. A **decomposing node** is a pure container: it has a manifest
and no requirements/design/tasks of its own. Such a node cannot satisfy either
precondition, so its plan can neither be published nor gate its own build,
even though a decomposing node is a first-class work item under the recursive
model.

The cost: parallel work is safe only at the top level and only for
single-feature items; below that, a collision can corrupt a plan branch, and a
decomposing node is stranded outside the publication flow.

## Goals

- Two distinct canonical references at **any depth** always map to two distinct
  plan branch names and two distinct ship branch names.
- A decomposing node with only a manifest can publish its plan and have its build
  gated on that plan, exactly as a single-feature item can.
- Publishing one node's plan is independent of another node publishing
  concurrently; no publication overwrites, blocks, or orders another.
- There is a single canonical flattened-branch rule, defined once and referenced
  by every surface that names a branch.
- Historical items and already-merged plans stay valid with no migration.
- The repository's configured test command stays green.
- A node's declared-conflict findings remain advisory during publication and the
  build gate: they change no outcome and add no readiness edge.

## Non-goals

- Per-level sequence allocation and duplicate detection — owned by
  `0001-recursive-allocation`.
- Merge integrity and renumbering for recursive trees — owned by
  `0002-recursive-merge-integrity`.
- The `conflicts-with` target grammar at every level — owned by
  `0003-recursive-conflicts`.
- The broad agent, command, and inventory surface sweep — Roadmap 4.
- New committed fixture areas, agreement areas, or mutation coverage — Roadmap 5.
- A new command, agent, `phase` value, artifact, registry, or state file.
- Changing what a plan *is* (its content), the derived-state table, or the
  merge-time conflict contract.
- A hosted service, bot, or any GitHub integration beyond the existing
  branch/commit/push/pull-request flow.
- Migrating historical, shipped, or already-published plans.
- Deciding the human review/approval policy for a plan pull request.

## Users and stories

- **As a** framework maintainer planning parallel work at any depth, **I want**
  distinct references to produce distinct branch names, **so that** one node's
  plan branch can never be confused with or overwritten by another's.
- **As a** maintainer of a decomposing node, **I want** to publish the node's
  manifest-only plan and have the build gate recognize it as published, **so
  that** a multi-feature initiative is public and gated like any other item.
- **As a** maintainer publishing two plans at once, **I want** each node to
  publish to its own branch independently, **so that** I need no lock, ordering,
  or coordination between concurrent publications.
- **As an** adopter, **I want** one flattened-branch rule that covers every work
  item at every depth, **so that** I maintain no second branch-naming convention.

## Acceptance criteria

1. **AC1** — Given two distinct canonical references at any depth, when each is
   mapped to its plan branch name and to its ship branch name, then the two plan
   names differ and the two ship names differ.
2. **AC2** — Given a canonical reference, when its branch name is derived, then
   the mapping is deterministic and reversible (a flattened branch name
   identifies exactly one reference), and the **same** rule produces both the
   plan branch name and the final ship branch name.
3. **AC3** — Given a nested child and a distinct top-level item whose old
   `/`→`-` joined forms were textually identical, when their branch names are
   derived, then the two names are distinct, so the old collision cannot occur.
4. **AC4** — Given a decomposing node that has completed `/plan` and holds only a
   manifest (no requirements, design, or tasks of its own), when its plan is
   published, then publication proceeds: the precondition admits a manifest-only
   plan.
5. **AC5** — Given a decomposing node's plan is published, when the committed
   plan state is examined, then it contains the node's manifest, the node's own
   phase artifacts when it has them, and its immediate child directory
   reservations, and it contains **no** child's own in-flight phase artifacts.
6. **AC6** — Given a nested child has completed `/plan`, when the child's plan is
   published, then only that child's own plan state is committed, and no parent
   or sibling artifact is added or modified.
7. **AC7** — Given a manifest-only node's plan has been merged to the default
   branch, when `/build` runs the plan gate for that node, then the gate
   proceeds (the plan is published), rather than refusing for a missing
   design artifact.
8. **AC8** — Given a node's plan branch carries plan state that differs from the
   default branch — a first publication, a later revision, or a manifest-only
   plan — when `/build` runs the gate for that node, then the gate refuses and
   names the plan branch or pull request that must be merged first.
9. **AC9** — Given the gate resolves a plan branch for a node at any depth, when
   it derives that branch name, then it uses the collision-free flattened name
   and never the ambiguous old form.
10. **AC10** — Given two nodes publish concurrently, when each commits and
    pushes, then each commits to its own distinct branch and neither branch must
    be created from, merged with, or blocked behind the other.
11. **AC11** — Given a historical item or an already-merged plan, when it is
    read, then it remains valid with no migration, and derived state and the
    committed suite are unaffected.
12. **AC12** — Given the collision-free branch rule is stated, when the authority
    and the owning prompts are read, then they describe the same rule, define it
    once, and reference it rather than restating or forking it — including the
    build gate's mirrors.
13. **AC13** — Given plan publication runs, when any branch, commit, push, or
    pull request is created, then only the shipper performs the git write and
    only on explicit invocation; plan mode writes no shipped-state record, runs
    no ship pre-flight or reconcile, and creates no final ship branch.
14. **AC14** — Given the plan gate runs and prints the item's declared-conflict
    findings after a PROCEED, then those findings remain advisory and change no
    gate outcome, and the change introduces no new readiness edge, `phase` value,
    or state file.
15. **AC15** — Given the change is complete, when the repository's configured
    test command runs, then it passes and the suite reads no live `work/**`.

## Edge cases

- **Pure container** — a decomposing node with only a manifest publishes a
  manifest-only plan (AC4) and its build is gated on it (AC7).
- **Hybrid node** — a decomposing node that also has its own requirements/design
  publishes both its manifest and its own artifacts (AC5).
- **Depth ≥ 3** — a grandchild reference still yields a collision-free branch
  name (AC1, AC2).
- **The classic collision** — a top-level item whose slug embeds an
  `MMMM-slug`-shaped tail versus the nested child of the item with that prefix
  (AC3).
- **Sibling children** — two children of one decomposing node must not share a
  branch name.
- **Concurrent publication** — a parent's manifest-only publication and a
  child's publication proceed at the same time without interfering (AC6, AC10).
- **Already-merged plan** — re-invoking publication on an up-to-date, merged
  plan is a no-op and does not error.
- **Unmerged old-format branch** — a pre-existing, unmerged plan branch under the
  old flattened name is **not** recognized by the new gate; this is documented
  and needs no migration (AC11).
- **Plan branch advertised but unresolvable locally** — the gate refuses rather
  than reading it as matching or differing (existing behavior preserved).
- **Unreachable origin** — the gate degrades to its best-effort result and never
  hard-fails (existing behavior preserved).
- **No plan at all** — a node with neither a manifest nor requirements/design has
  no plan and cannot be published.
- **Secrets** — a plan diff containing credentials, tokens, or `.env` content is
  never committed.

## Open questions

- [ ] **Exact collision-free encoding.** The reversible mapping must use a
  separator (or escaping) that cannot appear inside a canonical reference
  segment, so decoding is unambiguous. The specific form is a design decision,
  not a requirement. — owner: architect, needed by: design.

## Dependencies and constraints

- **Extends, does not fork.** This item extends the plan-publication decision of
  `work/0006-parallel-plan-conflicts/0002-plan-record` and the recursive model of
  `0011-recursive-bootstrap`. It corrects the `/`→`-` flattening those settled,
  which the parent manifest sanctions as "verify and, where needed, replace"; it
  defines no second flattening convention.
- **Independent of its siblings.** This child's `Depends on` is `—`; it shares
  no prerequisite with `0001`/`0002`/`0003`, though `0002`, `0003`, and this item
  all edit the workflow authority, so their changes must compose.
- **Authority surfaces.** The operative statement is
  `docs/workflow.md` → "Plan publication" and "The `/build` plan gate". The
  owned prompts are `.opencode/agent/shipper.md` and `.opencode/command/ship.md`;
  the branch rule is defined once in
  `.opencode/skill/conventional-commits/SKILL.md`; and the gate's mirrors
  `.opencode/agent/builder.md` and `.opencode/command/build.md` are kept in sync
  (user decision 2).
- **No new artifact or phase.** The frontmatter phase vocabulary and the
  derived-state table are unchanged; a plan remains the item's existing
  committed artifacts, and a decomposing node's plan is its manifest plus its own
  artifacts plus child reservations.
- **Shipper owns git writes.** Publication and any renumber are performed only by
  the shipper on explicit invocation, exactly as before.
- **Read-only suite.** The committed suite never reads live `work/**`, so this
  change is validated against the live prompt/doc surfaces and the existing
  fixtures; new fixture areas are Roadmap 5.
- **Framework-internal only.** Docs, prompts, and the branch-name rule; no
  runtime dependency, service, network access, or new toolchain.
