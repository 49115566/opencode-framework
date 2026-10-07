---
feature: 0006-parallel-plan-conflicts
phase: spec
status: final
created: 2026-10-07
updated: 2026-10-07
notes: "Standalone item (next free top-level NNNN is 0006). User decisions 2026-10-07: one standalone spec rather than a roadmap; a new per-ready-item surface declaration committed before development and compared across all ready in-flight items; a conflict counts as a declared Conflicts-with edge, an overlapping concrete path/surface, or a shared-surface collision; the check runs as a step before /build; report-only/non-fatal; prompt/config/doc only; extends the shipped 0005 merge-conflict taxonomy and finding vocabulary rather than defining a second one."
---

# Parallel-development plan conflicts and a `Conflicts with` roadmap column

## Problem

Parallel development is normal in this framework: several work items run on
separate branches, and a roadmap's children are deliberately independent enough
to be developed concurrently. But the plan carries only an *ordering* relation.
The roadmap `Children` table's `Depends on` column says when a child cannot start
until another is satisfied, and nothing records that two children are independent
yet touch the same files, so developing them at the same time is exactly what
will collide. Collisions surface only reactively, at merge/`/ship` time, under the
shipped `0005-merge-conflict-workflow` contract — after both branches already
contain conflicting work. There is no way, before a developer writes a line, to
commit a plan that says "I will touch these surfaces" and compare it against the
other in-flight plans to learn that someone else is about to touch the same ones.

**Framework maintainers** and **adopters** running parallel work items discover
surface collisions late and redo work; **roadmap authors** cannot express a
coordination constraint that is not a dependency; and **reviewers** have no
record that parallel-development risk was assessed before the build began.

## Goals

- The roadmap `Children` table carries a `Conflicts with` column that declares,
  per child, which sibling children touch overlapping surfaces and must not be
  developed concurrently — a coordination relation distinct from `Depends on`.
- Each ready (non-blocked) in-flight work item commits a machine-readable
  declaration of the paths/surfaces it will touch before development begins.
- A pre-development consistency check, run as a step before `/build` starts
  implementation, compares the item's committed declaration against the committed
  declarations of every other ready in-flight item and reports conflicts.
- A conflict is detected when any of the following holds: one item declares a
  `Conflicts with` relation naming the other; their declared surfaces name the
  same concrete path or an ancestor/descendant directory overlap; or their
  declared surfaces collide on the same shared framework surface.
- Findings use the shipped `0005` merge-conflict taxonomy, finding grammar, and
  class labels, extended with pre-development codes only where the concept is
  genuinely new.
- The check is report-only: non-fatal, modifies no file, auto-repairs nothing, and
  never blocks the build.
- Delivered as prompt, configuration, and documentation only — no executable
  tooling, and no new command, agent, or lifecycle phase.
- The behavior reaches adopters through the surfaces they already receive, and no
  regression: the committed suite stays green, including the pinned Children
  header/fixture and the inventory agreements.

## Non-goals

- **Resolving or serializing parallel work.** The check detects and reports; it
  never assigns an order, moves a branch, merges, or blocks a build.
- **Merge-time reconcile and conflict resolution** — the shipped
  `0005-merge-conflict-workflow` contract. This item is the pre-development
  counterpart and changes none of that policy.
- **Readiness or sequencing.** `Conflicts with` never affects readiness;
  readiness stays derived from `Depends on` alone.
- **A new command, agent, or lifecycle phase.** The check is a step inside
  existing `/build` behavior. (Whether it lives in a new skill or an existing one
  is a design decision; adding a skill is allowed only with the inventory updates
  it requires.)
- **Any executable checker, script, helper, or runtime code**, and **any new
  committed test agreement area** proving the check. The capability is
  prompt/config/doc only; existing pinned assertions are updated only as required
  to stay green.
- **Detecting collisions against shipped or blocked items, or against other
  branches or repositories.** The comparison universe is the ready in-flight
  items in this repository's committed `work/` tree.
- **Structurally de-duplicating the shared framework surfaces** so parallel items
  stop colliding — a deliberate, recorded omission.
- **Reopening the state model, readiness model, permission-class model, or the
  shipped work** of `0003-framework-quality-hardening`,
  `0004-adoption-template-split`, or `0005-merge-conflict-workflow`.

## Users and stories

- **As a** roadmap author, **I want** to mark two children as conflicting in the
  plan, **so that** the constraint that they must not be developed in parallel is
  recorded even though neither depends on the other.
- **As a** builder about to start an item, **I want** a pre-development check that
  compares my committed surface declaration against other in-flight items',
  **so that** I learn before writing code that another ready item will touch the
  same surfaces.
- **As a** framework maintainer running parallel work items, **I want**
  pre-development findings classified with the same vocabulary as merge-time
  findings, **so that** one mental model covers the whole conflict lifecycle.
- **As an** adopter, **I want** this behavior to arrive through the surfaces I
  already receive, **so that** I get it without installing tooling.
- **As a** reviewer, **I want** the pre-development assessment recorded in the
  build handoff, **so that** I can see what was checked before development.

## Acceptance criteria

1. **AC1** — Given a roadmap document, when its `Children` table is inspected,
   then it carries a `Conflicts with` column alongside `Depends on`, and each cell
   names sibling local ids (comma-separated) or `—` for none; the relation is
   intra-roadmap only, exactly like `Depends on`.

2. **AC2** — Given a `Conflicts with` cell, when a named local id does not resolve
   to another row in the same `Children` table, or names the declaring row itself,
   then a non-fatal finding is reported that names the roadmap, the offending row,
   and the invalid reference, and the roadmap is neither rejected nor aborted.

3. **AC3** — Given a roadmap child that declares a `Conflicts with` entry and
   whose `Depends on` entries are all satisfied, when its readiness is derived,
   then it is `ready`; a `Conflicts with` entry never changes a child's readiness
   or its place in the dependency graph.

4. **AC4** — Given a roadmap parent whose `Conflicts with` cells are read by
   `/status`, when `/status` reports, then invalid declarations are reported as
   findings in the existing grammar and non-fatal contract, alongside the existing
   findings; `/status` remains offline, read-only, and modifies no file.

5. **AC5** — Given a ready in-flight work item about to enter development, when
   its plan is committed before development begins, then the committed plan
   contains a machine-readable declaration of the paths/surfaces the item will
   touch, discoverable by the item's canonical reference without reading
   implementation code.

6. **AC6** — Given a ready in-flight item with a committed surface declaration,
   when `/build` starts development on that item, then before any implementation
   the check compares the item's declaration against the declarations of every
   other ready in-flight item and reports the result.

7. **AC7** — Given two ready in-flight items where one declares a `Conflicts with`
   relation naming the other, when the check runs, then it reports a conflict
   naming both items and the declared relation.

8. **AC8** — Given two ready in-flight items whose surface declarations name the
   same concrete path, or where one declared path is an ancestor directory of the
   other, when the check runs, then it reports a conflict naming both items and
   the overlapping surface(s).

9. **AC9** — Given two ready in-flight items whose surface declarations both
   include the same shared framework surface, when the check runs, then it reports
   a conflict naming both items and the shared surface.

10. **AC10** — Given the check reports any conflict, when the finding is produced,
    then it carries a finding code, a class label from the `0005` taxonomy, the
    offending item canonical references, and the specific overlap or declared-edge
    detail, in the existing finding grammar; no detected conflict is silently
    dropped or truncated.

11. **AC11** — Given the check reports one or more conflicts, when `/build`
    continues, then the build is not blocked, the check modifies no file, nothing
    is auto-repaired, and the check is read-only.

12. **AC12** — Given there is no other ready in-flight item, or no other item
    carries a surface declaration, or the current item declares no surfaces, when
    the check runs, then it reports no conflicts and does not error.

13. **AC13** — Given the check has run, when the build handoff is written, then it
    records which declarations were assessed and either the conflicts found or an
    explicit "no conflicts", so a reviewer can see what was checked.

14. **AC14** — Given the repository after the change, when the delivered surfaces
    and inventories are inspected, then the capability exists as prompt/config/doc
    content only — no executable checker, script, helper, or runtime code; no new
    command, agent, or lifecycle phase; and no new committed test agreement area.

15. **AC15** — Given the repository after the change, when `bash tests/run.sh`
    runs, then it exits `0`, including the Children-table/format assertion, the
    cycle fixture, the inventory counts and tables, and the readiness/lifecycle
    agreements; every existing pinned surface is updated only as needed to reflect
    the new column.

## Edge cases

- **Empty `work/` or a single in-flight item.** No peer to compare: report no
  conflicts and do not error.
- **Declaration absent.** A ready in-flight item with no committed surface
  declaration: the check reports that it could not compare that item (or skips
  it) and does not error; it must say so rather than assume no surfaces.
- **Self-declaration.** A `Conflicts with` cell naming its own row is an invalid
  reference (AC2), not a valid conflict.
- **One-directional declaration.** Only one of the two items declares the
  `Conflicts with` relation: still a conflict (AC7); declaring both directions is
  not an error.
- **Duplicate id in a cell.** The same local id listed twice is treated once; it is
  not an error.
- **Overlap by directory.** One item declares a directory (`docs/`) and another
  declares a path inside it (`docs/workflow.md`): an overlap (AC8).
- **Shared surface class.** Both declare files under the same shared framework
  surface class (`README.md`, `AGENTS.md`, `docs/*.md`,
  `.opencode/{agent,command,skill}/**`, `template/**`, `tests/checks/**`): a
  conflict (AC9).
- **Blocked or shipped item.** A blocked roadmap child, or any item with
  `ship.md`, is outside the comparison universe — neither a reporter nor a
  reported conflicting item.
- **Conflicting and sequential at once.** Two items may be both `Depends on` and
  `Conflicts with`; the two relations are independent and each is reported by its
  own mechanism.
- **Declaration changes after the check.** The check runs before development; a
  later declaration edit is assessed on the next run, and a stale earlier result
  is never treated as current.
- **Standalone item with no roadmap.** It has no `Conflicts with` cells but still
  participates in surface-overlap comparison.
- **Concurrent check runs.** Two read-only check runs take no lock, write nothing,
  and do not interfere.
- **Large overlap set.** Every conflicting surface is reported; the list is never
  truncated.

## Open questions

- [ ] **Declaration placement and shape** — whether the surface declaration is a
      structured field in the item's existing committed artifacts (its plan,
      spec, or design) or a new declaration section, and its exact grammar. This
      determines how AC5's machine-readability is realized. — owner: architect,
      needed by: design. **Deferred.**
- [ ] **Exact new finding code(s)** — the token(s) for a declared-edge conflict, a
      surface-overlap conflict, and an invalid `Conflicts with` reference,
      extending the `0005` vocabulary. AC10 requires a code; the token is a design
      decision. — owner: architect, needed by: design. **Deferred.**
- [ ] **Column position** — whether `Conflicts with` is appended after
      `Canonical reference` or placed beside `Depends on`. A mid-table insertion
      breaks the exact fixture header assertion
      (`tests/checks/80-cycle-fixture.sh:31`) and the fixture header, requiring
      their update; appending after `Canonical reference` keeps the existing
      fixed-substring assertion and the `Depends on` field index matching. Affects
      AC15. — owner: architect, needed by: design. **Deferred.**
- [ ] **Skill vs. existing prompt** — whether the pre-development check lives in a
      new skill, the `merge-conflict` skill, or the `builder`/`/build` prompt. A
      new skill changes the README Layout count and
      `tests/checks/40-inventory.sh` membership. Affects AC14/AC15. — owner:
      architect, needed by: design. **Deferred.**
- [ ] **"In-flight" boundary** — the precise phase at which an item enters and
      leaves the comparison universe (for example, enters when its committed plan
      and declaration exist, leaves when `ship.md` is present). AC6/AC12 depend on
      it. — owner: architect, needed by: design. **Deferred.**
- [x] **Vehicle** — resolved (user): one standalone spec, not a roadmap.
- [x] **Plan of record** — resolved (user): a new per-ready-item committed surface
      declaration, compared across all ready in-flight items.
- [x] **Conflict definition** — resolved (user): a declared edge, an overlapping
      concrete path/surface, and a shared-surface collision all count.
- [x] **Trigger** — resolved (user): a step before `/build`.
- [x] **Enforcement** — resolved (user): report-only/advisory, non-fatal.
- [x] **Delivery form** — resolved (user): prompt/config/doc only.
- [x] **Relation to `0005`** — resolved (user): extend the existing taxonomy and
      finding vocabulary; define no second one.

## Dependencies and constraints

- **Complements, does not replace, `0005`.** `0005-merge-conflict-workflow` owns
  the merge-time taxonomy, pre-flight detection, reconcile, and merge-integrity
  guard; this item consumes its classes, finding grammar, and prompt-only
  report-only style and defines no second policy. The `Conflicts with` column and
  the surface declaration are additive to the roadmap format.
- **Roadmap format surfaces to keep consistent.** The `Children` table contract is
  authoritative in `docs/artifact-conventions.md:108-129`, described in
  `docs/workflow.md:77-108`, authored by `.opencode/agent/roadmap.md:77-82,104-120`,
  and consumed by `.opencode/agent/status.md:80-89`; the `/roadmap` command and
  README roadmap description are also affected.
- **Pinned format assertions.** `tests/checks/80-cycle-fixture.sh:31` asserts the
  exact fixture Children header and `tests/fixtures/cyclic-roadmap/roadmap.md:26`
  contains it; `tests/checks/80-cycle-fixture.sh:44-64` parses `Depends on` as the
  fifth table field. The shipped `work/0002-agentic-roadmaps/verify-tests.sh:56-57`
  asserts the presence of each original column by fixed substring, so an appended
  column keeps it passing while a mid-table insertion does not. The format change
  must keep these green (AC15).
- **Suite is maintainer-only and never reads `work/**`**
  (`tests/README.md:3-16,28-30`), so the pre-development check cannot be a
  live-tree committed check; per the user decision it adds no committed agreement
  area. The check operates on committed `work/` artifacts at runtime, not in CI.
- **Inventory agreement.** `tests/checks/40-inventory.sh` enforces the README
  Layout counts and table membership against `.opencode/{agent,command,skill}/`.
  This item adds no command or agent; if the design adds a skill, the README count
  and its table and the check must be updated in the same change.
- **Adopter reach.** `.opencode/**` and `docs/*.md` have a single source and are
  shared verbatim with adopters (`tests/README.md:5-16`), so placing the contract
  on those surfaces delivers it to adopters without migration.
- **Readiness authority.** Readiness and its surfaces are pinned by
  `tests/checks/10-readiness.sh`; `Conflicts with` must not alter them (AC3).
- **Committed plan state.** `work/` artifacts are committed working state
  (`docs/artifact-conventions.md:1-12`), which is what makes "commit the plan,
  then compare" possible without a registry or a state file.
- **Decision (recorded, revisitable).** The `Conflicts with` relation is treated
  as symmetric for detection: declaring one direction is sufficient, and declaring
  both is not an error. If the artifact should instead require both directions to
  match, that would tighten AC7; it is a validation-policy decision the architect
  may revisit.
- **Assumption.** "Surface" means a repository-relative path or directory the item
  will create or modify; a declared directory covers paths beneath it.
- **Assumption.** The comparison universe is the ready in-flight items in the
  local committed `work/` tree; no remote, branch-diff, or cross-repository
  comparison is performed.
- **Assumption.** Because the deliverable is the framework's own prompts, docs,
  and configuration, acceptance criteria name required content and observable
  behavior rather than implementation choices.
