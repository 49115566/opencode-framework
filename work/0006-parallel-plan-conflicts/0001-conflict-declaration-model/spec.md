---
feature: 0006-parallel-plan-conflicts/0001-conflict-declaration-model
phase: spec
status: final
created: 2026-10-07
updated: 2026-10-07
notes: ""
parent: 0006-parallel-plan-conflicts
---

# Declared planning-time conflict model and `conflicts-with` column

## Problem

Framework maintainers running parallel roadmap children or parallel work items —
and adopters who inherit the same setup — can plan two items that are fully
independent by their `Depends on` graph yet still compete for the same repository
surfaces. Nothing in a committed plan records which surfaces an item expects to
touch, so the overlap stays invisible until both branches collide and must be
reconciled by hand. The shipped merge-conflict contract is merge-time only
(`docs/workflow.md:337-438`) and readiness is purely `Depends on`-based
(`docs/workflow.md:77-135`), so there is no planning-time notion of "these two
plans will fight." This work item fixes the definition and vocabulary of a
declared planning-time conflict and adds the first place to record one: a
`conflicts-with` column on the roadmap `Children` table. It is the keystone the
rest of the initiative consumes.

## Goals

- Define what a *planning-time conflict* is as committed, reviewable plan state,
  distinct from the merge-time reconcile contract and from `Depends on`.
- Let a roadmap child row declare, in the `Children` table, the targets it
  expects to collide with.
- Define one declaration grammar usable both by a roadmap row and by a child or
  standalone work item's own intended conflict set.
- Reuse the shipped conflict classes and finding grammar unchanged; introduce no
  second taxonomy or vocabulary.
- Keep declarations advisory: they never create a readiness edge, reorder
  children, or gate development.
- Make every declared target well-formed enough that a later read-only check can
  resolve it or report it as unresolved.

## Non-goals

- Deciding where an item's own declaration is stored, or its container/field —
  owned by `0002-plan-record`.
- Detecting, comparing, or reporting declared conflicts between plans — owned by
  `0003-conflict-check`.
- Committed test fixtures, agreement areas, and mutation coverage — owned by
  `0004-conflict-guards`.
- Any change to the shipped merge-time reconcile contract of
  `0005-merge-conflict-workflow`, or a forked conflict taxonomy.
- Tagging a declaration with a conflict class; the class is assigned when a
  conflict is detected, not when it is declared.
- Blocking `/build`, gating a plan, reordering children, or scheduling work from
  declared conflicts.
- Structural de-duplication of shared framework surfaces.
- A new registry file, or a new artifact `phase` value, for declarations.

## Users and stories

- **As a** framework maintainer planning a roadmap, **I want** each child row to
  record the sibling rows, top-level items, or surfaces it expects to collide
  with, **so that** I can see and coordinate overlaps while planning instead of
  resolving them by hand at merge time.
- **As a** maintainer authoring a standalone or nested child work item, **I want**
  to declare the surfaces it expects to touch in the same vocabulary as a
  roadmap row, **so that** a pre-development check can compare my plan against
  the plans already committed.
- **As an** adopter running parallel work, **I want** the declaration model to
  reuse the conflict vocabulary my tooling and docs already use, **so that** I do
  not have to learn or maintain a second taxonomy.

## Acceptance criteria

1. **AC1** — Given the authority documentation for roadmaps, when a reader looks
   up a planning-time conflict, then it is defined as a declared, committed claim
   about the targets a plan expects to collide with, explicitly distinct from the
   merge-time contract and from `Depends on`, and it references the shipped
   conflict classes rather than restating a new taxonomy.
2. **AC2** — Given the roadmap `Children` table template, when a roadmap is
   authored, then the table includes a `conflicts-with` column and the template's
   column notes explain what the column means and what an empty value is.
3. **AC3** — Given a `conflicts-with` cell, when a target is declared, then each
   target is exactly one of: an intra-roadmap sibling local id, another top-level
   work item's canonical reference, or a repository-relative surface path;
   multiple targets are comma-separated; and a row with no declared conflicts uses
   `—`.
4. **AC4** — Given a child or standalone work item, when it declares its own
   intended conflict set, then the declaration uses the same three target kinds
   and the same comma-separation and empty-value conventions as a `conflicts-with`
   cell, and the model is defined independently of where that declaration is
   stored.
5. **AC5** — Given two plans where at least one side names the other, when the
   declared set is evaluated, then the pair is a declared conflict even if the
   other side is silent; a declaration does not require a reciprocal declaration.
6. **AC6** — Given a `conflicts-with` cell, when readiness is derived, then the
   cell adds, removes, or reorders no `Depends on` edge and does not change any
   child's readiness; only `Depends on` gates readiness.
7. **AC7** — Given a declared conflict that is later reported, when a class or a
   finding line is produced, then it uses the shipped `(a)`–`(d)` class labels and
   the existing finding-line grammar verbatim, and no new class, finding code, or
   policy is defined for declarations.
8. **AC8** — Given a `conflicts-with` cell that names an intra-roadmap sibling,
   when the cell is well-formed, then the named local id is a different row in the
   same `Children` table (no self-reference) and the cell contains no duplicate
   target.
9. **AC9** — Given the roadmap authoring surfaces, when the column is added, then
   the roadmap agent prompt and command describe the `conflicts-with` column and
   its grammar consistently with the authority docs and the artifact template, and
   no surface states a conflicting column grammar.
10. **AC10** — Given the existing `Depends on` semantics and readiness algorithm,
    when the new column is introduced, then `Depends on` parsing and readiness
    behavior are unchanged; any positional consumer that must move for the new
    column is updated so `Depends on` retains its meaning.
11. **AC11** — Given a `conflicts-with` cell whose target is malformed or does not
    resolve to an existing sibling row, top-level work item, or surface, when the
    model is applied, then the target is treated as an unresolved declaration that
    a later check must report, never silently dropped.
12. **AC12** — Given the three vocabulary surfaces (the authority docs, the
    artifact template and its notes, and the roadmap agent prompt), when a reader
    compares them, then the `conflicts-with` grammar has one authoritative
    statement and the others reference it, mirroring how the existing
    `Depends on`/readiness rules are stated once and referenced elsewhere.

## Edge cases

- **Empty declaration** — a cell is `—` for a row that declares no conflicts;
  an empty or whitespace-only cell is malformed, not equivalent to `—`.
- **Absent column** — a committed roadmap authored before this change has no
  `conflicts-with` column at all. Assumption: absence is treated as "no declared
  conflicts" (`—` for every row) so historical roadmaps stay valid; see Open
  questions.
- **Unresolved sibling** — a cell names an intra-roadmap local id with no matching
  row or child directory.
- **Unresolved top-level item** — a cell names a canonical reference that does not
  exist on disk, including one that names a roadmap parent or a nested child
  reference.
- **Unresolved surface** — a cell names a repository-relative path that does not
  exist.
- **Self-reference** — a row's `conflicts-with` names its own local id.
- **Duplicate target** — a cell lists the same target twice.
- **Both sides declare** — two rows each name the other; the pair is still a
  single declared conflict.
- **One side declares** — only one row names the other; the pair is still a
  declared conflict (AC5).
- **Cross-roadmap overlap** — a cell names a top-level item outside the current
  roadmap, or an item in another roadmap's tree.
- **Comma inside a target** — repository paths and references do not contain
  commas, so a comma always separates targets.

## Open questions

- [ ] **Assumption — absence handling.** Treat a missing `conflicts-with` column
  as no declared conflicts so committed historical roadmaps (for example this
  roadmap and `0001`–`0005`) remain valid without migration. Confirm, or require
  the column strictly and have the guard report its absence. — owner: user,
  needed by: design.
- [ ] **Assumption — surface granularity.** A surface target is an exact
  repository-relative file or directory path; broader prefixes or glob patterns
  are not part of the grammar unless confirmed otherwise. — owner: user, needed
  by: design.

## Dependencies and constraints

- **Consumes, does not fork, the shipped `0005` vocabulary.** The canonical class
  labels `(a)`–`(d)` are fixed by
  `work/0005-merge-conflict-workflow/0001-conflict-model/spec.md:88-93`; the
  finding-line grammar and code table live in the `merge-conflict` skill
  (`.opencode/skill/merge-conflict/SKILL.md:94-127`) and are referenced from
  `docs/workflow.md:418-419`. All five `0005` children are shipped. This item
  reuses them unchanged.
- **Extends the shipped roadmap model** (`0002-agentic-roadmaps`). Readiness stays
  `Depends on`-only (`docs/workflow.md:77-135`); this item must not add a
  readiness edge.
- **Positional-parser hazard.** `tests/checks/80-cycle-fixture.sh:31` asserts the
  exact five-column `Children` header, and `:48-50` reads `Depends on` at table
  position 5; the fixture `tests/fixtures/cyclic-roadmap/roadmap.md:26-27` uses
  that header. This item changes the template and docs; child
  `0004-conflict-guards` must update the fixture, check, and mutation coverage so
  `Depends on` keeps its meaning.
- **The committed suite is read-only and never reads live `work/**`**
  (`tests/README.md:29`), so any guard for this model must be fixture-based, and
  live committed roadmaps need no migration to keep the suite green.
- **Recon correction to the roadmap.** `AGENTS.md`, `README.md`, and the
  `workflow-lifecycle` skill name no `Children` columns today, so — per the user
  decision — only surfaces that actually render the table (authority docs, the
  artifact template and notes, the roadmap agent prompt and command, and the test
  fixture/check) are in scope; the other three need no change.
- **Framework-internal change only.** Docs, prompts, and tests; no runtime
  dependency, service, or new toolchain.
- **Keystone.** `0002-plan-record`, `0003-conflict-check`, and `0004-conflict-guards`
  all consume the grammar fixed here, so it must be final before they plan.
