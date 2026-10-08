---
feature: 0006-parallel-plan-conflicts/0002-plan-record
phase: spec
status: final
created: 2026-10-08
updated: 2026-10-08
parent: 0006-parallel-plan-conflicts
notes: "User decisions 2026-10-08: (1) no new plan artifact — the item's plan is its existing spec/design artifacts; (2) the declared target list is authored by the architect at /plan as part of the plan artifacts; (3) the plan is published via a dedicated plan branch + PR and merged before /build begins, so plans are public on GitHub for manual cross-reference; (4) the item-level declaration and the parent roadmap Children conflicts-with cell coexist (union; a mismatch is reported by 0003); (5) absence = no declared conflicts, no migration. This refines the roadmap's 'committed plan record' shape from a possible new phase artifact to the item's already-committed plan."
---

# Pre-development plan publication and declared conflict record

## Problem

Framework maintainers — and adopters who inherit the workflow — can plan two work
items (roadmap children or standalone items) that are fully independent by
`Depends on` yet compete for the same repository surfaces. Today an item's
intended surfaces live only in prose (a design's affected-area list), and for
roadmap children in the parent's `conflicts-with` cell added by
`0001-conflict-declaration-model`; nothing publishes an item's plan for others to
see before development, and nothing gives a per-item committed declaration a
later check can read. The overlap stays invisible until both branches collide and
must be reconciled by hand at merge time — the shipped contract only governs
merge time (`docs/workflow.md:395-495`). `0001` fixed the vocabulary for
declaring a planning-time conflict but deliberately left where an item's own
declaration is stored to this work item (`0001/design.md:50-51`). Maintainers
also have no shared, public place to cross-reference plans before code exists.

## Goals

- Publish a work item's plan — its existing requirements and design artifacts —
  to the shared default branch through a dedicated plan branch and pull request,
  merged before development begins, so the plan is public on GitHub for manual
  cross-reference.
- Record the item's declared conflict target list, in the shipped `0001` grammar,
  as part of that committed plan, so the plan carries a per-item declaration a
  later check can compare.
- Keep declarations advisory: they add no readiness edge, reorder no child, and
  gate nothing by themselves; the plan-publication merge is a separate process
  step that precedes development.
- Let a roadmap child's own declaration coexist with its parent `Children` row's
  `conflicts-with` cell; both feed comparison, and a disagreement is reported
  rather than silently resolved.
- Reuse the shipped `0001` conflict grammar, classes, and finding vocabulary
  unchanged; introduce no second taxonomy, registry, or artifact.
- Leave historical and already-shipped work items valid without migration.

## Non-goals

- Detecting, comparing, or reporting declared conflicts between plans — owned by
  `0003-conflict-check`.
- Committed fixtures, agreement areas, and mutation coverage — owned by
  `0004-conflict-guards`.
- A new artifact, a new frontmatter `phase` value, a registry file, or any
  central plan document. The plan record is the item's existing plan artifacts.
- Any change to the `0001` declaration grammar or to the merge-time reconcile
  contract of `0005-merge-conflict-workflow`.
- Using declarations to change readiness, reorder children, schedule work, or
  block a plan on a detected conflict.
- Migrating historical or already-shipped work items.
- A hosted service, bot, or GitHub integration beyond the existing
  branch/commit/push/pull-request flow.
- The human review policy (who approves a plan pull request and whether approval
  is required) and the exact command or agent that drives publication — these are
  agreements left to design.

## Users and stories

- **As a** framework maintainer starting a work item, **I want** its plan merged
  to the default branch before I begin development, **so that** other maintainers
  can see what surfaces I intend to touch before any code exists.
- **As a** maintainer running parallel roadmap children or parallel work items,
  **I want** each merged plan to carry its declared conflict targets in the shared
  vocabulary, **so that** I can cross-reference overlaps on GitHub and let a later
  check report them during planning instead of at merge time.
- **As an** adopter, **I want** the plan-publication flow to reuse the conflict
  vocabulary my documentation already uses, **so that** I maintain no second
  taxonomy.

## Acceptance criteria

1. **AC1** — Given a work item has completed `/plan` and its plan artifacts
   exist, when the plan is published, then the plan is committed on a dedicated
   plan branch and a pull request is opened for it.
2. **AC2** — Given a work item has an open plan pull request, when development
   (`/build`) is started, then the plan pull request has first been merged to the
   default branch; development does not begin while the plan is unmerged.
3. **AC3** — Given a plan pull request is merged, when another maintainer views
   the repository on GitHub, then the item's plan artifacts are present on the
   default branch and readable without the item's local branch, so plans are
   public for manual cross-reference.
4. **AC4** — Given a work item's plan, when it is committed, then the item's
   declared conflict target list is part of the committed plan artifacts and is
   authored at `/plan`.
5. **AC5** — Given the item's declared target list, when it is expressed, then
   each target is exactly one of the shipped `0001` target kinds (an
   intra-roadmap sibling local id, a canonical work-item reference, or a
   repository-relative surface path), multiple targets are comma-separated, and
   no declared conflicts are `—`; the list references the `0001` authority and
   defines no second grammar.
6. **AC6** — Given a work item whose plan declares no targets, when the plan is
   committed, then absence or `—` means no declared conflicts, no extra container
   or artifact is required, and no historical item needs migration.
7. **AC7** — Given a roadmap child whose own plan declares targets and whose
   parent `Children` row also declares `conflicts-with`, when the declared sets
   are read, then both are read as the child's declared set (the union) and a
   disagreement between them is reported, never silently resolved.
8. **AC8** — Given an item's declared target list, when readiness is derived or
   children are sequenced, then the declarations add no readiness edge, reorder
   no child, and change no child's readiness.
9. **AC9** — Given the plan-publication flow, when a plan branch, commit, push,
   pull request, or merge is created, then only the shipper performs the git
   write, and only on explicit invocation; no other agent commits, pushes, or
   merges.
10. **AC10** — Given a work item created before this change, when it is read,
    then it remains valid with no plan pull request and no declared targets, and
    derived state and the committed suite are unaffected.
11. **AC11** — Given a plan is revised at `/plan` after its pull request
    merged, when the revision changes the intended surfaces or declared targets,
    then the revised plan is published through the same plan-branch and
    pull-request flow before development continues.
12. **AC12** — Given a declared target that is malformed or resolves to no
    sibling row, work item, or path, when the plan is read, then it is an
    unresolved declaration that a later check reports, never silently dropped or
    auto-repaired.
13. **AC13** — Given the lifecycle authority, the frontmatter/derived-state
    contract, and the owning prompts, when the flow is added, then they describe
    the plan-publication step and the declaration's home consistently, state the
    declaration's advisory nature, and reference the single `0001` grammar rather
    than restating or forking it.

## Edge cases

- **Empty declaration** — a plan records `—` (or no declared target list) for no
  conflicts; an empty or whitespace-only value is malformed, not equivalent to
  `—`, mirroring `0001`.
- **Absent declaration** — a historical plan has no declared targets; absence is
  read as no declared conflicts.
- **Plan not yet ready** — an item that has not completed `/plan` has no plan
  branch and cannot be published.
- **Plan pull request already merged** — re-invoking publication on an
  up-to-date, already-merged plan is a no-op and does not error.
- **Unmerged plan blocks development** — an attempt to begin `/build` while the
  plan pull request is open is refused or reported, per AC2.
- **Revised plan after merge** — a later `/plan` revision changes the intended
  surfaces; the change must be published, not left only in the item's working
  copy.
- **Roadmap parent** — a parent has `roadmap.md` and no requirements/design
  artifacts; its declaration remains the `Children` table's `conflicts-with`
  cells, and it does not author a separate item declaration.
- **Both sides declare** — two in-flight plans each name the other; the pair is
  one declared conflict.
- **One side declares** — only one plan names the other; the pair is still a
  declared conflict.
- **Self-reference** — an item declares its own canonical reference.
- **Duplicate target** — the same target appears twice in one list.
- **Concurrent publication** — two maintainers publish plans at once; each plan
  branch and pull request is independent and no plan is overwritten.
- **Cross-roadmap overlap** — a target names a top-level item or a nested child
  in another roadmap's tree.

## Open questions

- [ ] **Plan pull request approval policy.** Must a plan pull request receive
  human review/approval before it is merged, or may it be merged on open? The
  requirement to merge before development holds either way; the approval rule is
  a process fork. — owner: user, needed by: design.
- [ ] **Publication invocation surface.** Whether publication is a new command, a
  mode of `/ship`, or a step inside `/plan` (with the shipper still performing the
  git writes) is left to design; if a new command is added, the README inventory
  and its committed guard must be updated in the same change. — owner: architect,
  needed by: design.

## Dependencies and constraints

- **Consumes `0001-conflict-declaration-model` unchanged.** The declaration
  grammar, target kinds, empty-value convention, resolution rules, and finding
  vocabulary are the single authority in `docs/workflow.md` → `### Declared
  conflicts (conflicts-with)` (`docs/workflow.md:110-166`); this item reuses them
  and defines no second taxonomy.
- **No new artifact or phase.** The plan is the item's existing artifacts; the
  frontmatter phase list (`docs/artifact-conventions.md:19`) and the derived-state
  table (`docs/workflow.md:297-319`) are unchanged. This refines the roadmap's
  "committed plan record" shape from a possible new phase artifact to the item's
  already-committed plan, per the user decision.
- **Committed state travels to GitHub.** `work/` artifacts are committed working
  state that travel with the branch (`docs/workflow.md:379-382`); the plan branch
  and its merged pull request are what make them public before development.
- **Merge-time contract untouched.** `0005-merge-conflict-workflow` and
  `docs/workflow.md` → `## Merge conflicts` (`:395-495`) act on branches after
  they exist; this item is planning-time and complements, never replaces, them.
- **Shipper owns git writes.** Only the shipper performs
  branch/commit/push/pull-request operations, and only on explicit invocation
  (`AGENTS.md` guardrails); this holds for plan publication exactly as for ship.
- **Suite and migration.** The committed suite is read-only and never reads live
  `work/**` (`tests/README.md:29`), so publishing a plan and the absence of
  declarations cannot break it; historical items need no migration.
- **Roadmap model.** Extends the shipped `0002-agentic-roadmaps` model; readiness
  stays purely `Depends on`-based and is unaffected by declarations or by the
  plan-publication step.
- **Framework-internal change only.** Docs, prompts, and tests; no runtime
  dependency, service, network access, or new toolchain beyond the existing
  git/pull-request flow.
- **Roadmap-assumption refinement (explicit).** The roadmap assumed declarations
  never gate readiness and do not gate `/build` by themselves
  (`roadmap.md:42-45`). The user's decision adds a separate plan-publication merge
  that precedes development; this is a process step, not a readiness edge, and the
  *declared conflicts* remain advisory for readiness and conflict-driven gating.
