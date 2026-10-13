---
feature: 0013-simultaneous-work-recursion/0003-recursive-conflicts
phase: spec
status: final
created: 2026-10-13
updated: 2026-10-13
parent: 0013-simultaneous-work-recursion
---

# Recursive `conflicts-with` at every level

## Problem

Framework maintainers — and adopters inheriting the workflow — must be able to
run independent work items in parallel at **any** depth of a recursive plan tree,
and to trust that declared conflicts between those items are reported before
development. Today the declared-conflict facility is capped at two levels, so a
tree three or more levels deep cannot be fully reasoned about.

Two concrete limits:

- The target grammar admits at most one `/`:
  `SiblingOrItemRef ::= [0-9]{4}-[a-z0-9-]+( /[0-9]{4}-[a-z0-9-]+ )?`
  (`docs/workflow.md:286`), and the reference-vs-path discriminator repeats the
  same two-segment cap (`docs/workflow.md` → "Declared conflicts
  (`conflicts-with`)" → "Reference-vs-path discriminator"). A plan cannot
  declare a conflict against a grandchild-or-deeper item.
- The read-only declared-conflict check enumerates only top-level decomposing
  parents, their immediate children, and standalone top-level items
  (`docs/workflow.md` → "Declared-conflict check" → "The compared set"). A
  decomposing child's own children are **not** entities, so deeper collisions go
  unreported.

The cost is silent overlap: two independent items at depth ≥ 3 may edit the same
surface, and the advisory check reports nothing because it never sees them. The
manifest template explicitly deferred this generalization
(`docs/artifact-conventions.md:207-210`), and the parent roadmap assigns it to
this child (`work/0013-simultaneous-work-recursion/manifest.md:89`).

## Goals

- The declared-conflict target grammar accepts a reference of **arbitrary depth**.
- The reference-vs-path discriminator recognizes an arbitrary-depth reference.
- The declared-conflict check treats **every node of the tree** as potentially
  involved: a decomposing child's own children are entities, each with a declared
  set, and any two unshipped entities at any depth may be reported as a conflict.
- A bare single-segment token resolves against the declaring entity's
  **immediate parent's** `Children` table first, then repository-root
  `work/<token>/`; a multi-segment reference resolves from the repository root.
- Naming across levels (ancestor, descendant, or a different subtree) is
  permitted, as the shipped model already permits for two-segment references.
- The `own ∪ parent-cell` union and the `DRIFT-FACT` discrepancy rule hold at
  arbitrary depth.
- No new conflict class, finding code, reference grammar, state model, or
  vocabulary is introduced; existing declarations and the committed suite stay
  valid with no migration.

## Non-goals

- **Committed recursive fixtures/guards.** Fixture-based guards pinning the
  recursive model are Roadmap 5. This child keeps the existing committed suite
  green and adds no new fixture area.
- **Per-level sequence allocation and duplicate detection** — owned by
  `0001-recursive-allocation`.
- **Merge-integrity invariants and renumbering** — owned by
  `0002-recursive-merge-integrity`.
- **Parallel plan publication** — owned by `0004-parallel-publication`.
- **Restricting naming to siblings and surfaces.** The user chose to keep open
  root-relative naming; a sibling-only restriction is explicitly not adopted.
- **Merge-time conflict detection/resolution.** This remains a planning-time
  declaration check; the merge-time contract in `docs/workflow.md` →
  "Merge conflicts" is untouched.
- **Any readiness or phase-gating effect.** Declarations stay advisory: no
  readiness edge is added, no child is reordered, no phase is blocked.
- **New finding classes or codes** — the shipped `(a)`–`(d)` classes and
  `TEXTUAL-CONFLICT`/`DANGLING-DEP`/`DRIFT-FACT` codes are reused unchanged.

## Users and stories

- **As a** framework maintainer running several independent items in parallel in
  a deep recursive tree, **I want** to declare a conflict against an item at any
  depth, **so that** overlapping plans are surfaced before development starts.
- **As a** maintainer relying on the read-only report, **I want** the check to
  treat every nested node as an entity and to report conflicts between any two
  unshipped items at any depth, **so that** deeper collisions are not silently
  missed.
- **As an** adopter inheriting the recursive workflow, **I want** my existing
  single- and two-segment declarations to keep working unchanged, **so that** the
  generalization requires no migration.

## Acceptance criteria

1. **AC1 — Arbitrary-depth references are well-formed.** Given the
   declared-conflict grammar, when a target reference has three or more
   `/<MMMM-slug>` segments (`NNNN-slug/MMMM-slug/MMMM-slug/...`), then it is a
   well-formed reference target and resolves to `work/<ref>/`.
2. **AC2 — The discriminator recognizes arbitrary depth.** Given a token
   matching `^[0-9]{4}-[a-z0-9-]+(/[0-9]{4}-[a-z0-9-]+)*$`, when it is
   classified, then it is a reference (not a surface path), including at depth
   three and deeper.
3. **AC3 — The compared set recurses.** Given a decomposing child that itself
   holds a manifest (`manifest.md`, or the legacy `roadmap.md` alias), when the
   check derives compared entities, then each row of that child's `Children`
   table is an entity keyed by its full canonical reference — in addition to the
   child itself being an entity via its immediate parent's row.
4. **AC4 — Entity kinds at depth.** Given a deeper tree, when the check
   enumerates entities, then a leaf child is an entity via its immediate parent's
   `Children` row (even when its directory holds only `.gitkeep`), a nested
   decomposing node is both an entity via its parent row and a decomposition
   whose rows are recursed, and a standalone top-level item with a `spec.md` and
   no manifest is an entity via the standalone rule.
5. **AC5 — Bare-token precedence generalizes to the immediate parent.** Given a
   bare single-segment token declared by an entity, when it is resolved, then the
   check matches it against the declaring entity's immediate parent's `Children`
   table first, and only if no sibling row matches does it fall back to
   `work/<token>/` at the repository root.
6. **AC6 — Multi-segment references are root-relative.** Given a multi-segment
   reference target at any depth, when it is resolved, then it resolves from the
   repository root to `work/<ref>/`, independent of the declaring node.
7. **AC7 — Cross-level naming is permitted.** Given a reference target naming an
   ancestor, a descendant, or an item in a different subtree, when it resolves to
   an existing `work/<ref>/`, then it is a valid declared target; no sibling-only
   restriction is applied. Equal trimmed tokens that resolve to *different* items
   are not the same target.
8. **AC8 — The `own ∪ cell` union holds at depth.** Given a child at any depth
   whose own `design.md` carries a `conflicts-with` value and whose immediate
   parent's `Children` row carries a `conflicts-with` cell, when its declared set
   is derived, then the set is the union of the two.
9. **AC9 — `DRIFT-FACT` holds at depth.** Given a child whose own declaration and
   parent cell are both present (neither `—`) and whose token sets are unequal
   (a subset relationship still counts), when the check runs, then it reports
   `DRIFT-FACT` (class `(d)`) naming the child. A one-sided record (one side
   absent or `—`) is the union and is not drift; agreement produces no finding.
10. **AC10 — The pair predicate holds between any two unshipped entities.** Given
    two unshipped entities anywhere in the tree, when some target of one and some
    target of the other are the same target, or one names the other, then exactly
    one finding is produced: class `(a)` for a shared surface target outside
    `work/`, class `(b)` for a shared `work/` path or a one-sided naming. A
    named item that declares nothing of its own is still a counterpart.
11. **AC11 — Shipped handling is unchanged.** Given an entity whose `ship.md` is
    present, when the check runs, then it still resolves as a target but is
    excluded as a counterpart (produces no conflict and no unresolved finding).
12. **AC12 — Malformed and unresolved declarations at depth are reported.**
    Given a target that is malformed (empty/whitespace-only, a glob
    metacharacter, `..`, an absolute path, a self-reference, or a repeated target
    within one list), or that resolves to no sibling row, no `work/<ref>/`, and
    no existing repository path, when the check runs at any depth, then it is
    reported as unresolved (`DANGLING-DEP`) and is never dropped or
    auto-repaired.
13. **AC13 — No new vocabulary.** Given the shipped finding-line grammar, the
    `TEXTUAL-CONFLICT`/`DANGLING-DEP`/`DRIFT-FACT` codes, and the `(a)`–`(d)`
    classes, when the generalization lands, then no new code, class, or grammar is
    introduced (no `(e)`; no `DECLARED-`, `PLAN-`, or `CONFLICT-` code prefix).
14. **AC14 — Advisory, read-only, and effort-free on readiness.** Given the
    generalization, when the check runs, then it remains offline, local,
    read-only, takes no lock, modifies no file, performs no merge or dry-run
    merge, adds no readiness edge, reorders no child, and blocks no phase.
15. **AC15 — Backward compatibility and a green suite.** Given an existing
    single- or two-segment declaration, when the generalized grammar and check
    run, then it resolves exactly as before; and `bash tests/run.sh` passes with
    `tests/checks/85-conflict-guards.sh` and its `tests/fixtures/declared-conflicts/`
    fixture unchanged.
16. **AC16 — Empty compared set is a no-op.** Given no unshipped item with a
    declaration — or a tree whose items are all shipped — when the check runs,
    then it reports no findings and does not error.
17. **AC17 — The authority states the recursive contract.** Given the two
    authority documents, when the generalization lands, then `docs/workflow.md`
    → "Declared conflicts (`conflicts-with`)" states the arbitrary-depth grammar
    and discriminator, and "Declared-conflict check" states the recursive
    compared set, the immediate-parent-then-root precedence, the `own ∪ cell`
    union, and the `DRIFT-FACT` rule at depth; and `docs/artifact-conventions.md`
    → the manifest `conflicts-with` bullet no longer defers the generalization to
    a successor and references the recursive grammar.

## Edge cases

- **Depth boundary.** Depth exactly three and arbitrarily deeper must both work;
  there is no depth cap.
- **Same bare token, different parents.** The same `MMMM-slug` text declared
  inside two different parents resolves to two different items and is **not** a
  shared target.
- **Sibling vs root-name collision.** A bare token matching both a sibling row
  and a top-level `work/<token>/` resolves to the sibling (immediate parent's
  table wins).
- **Multi-segment first segment equal to a sibling id.** A token containing `/`
  is always root-relative, never sibling-first.
- **Self-reference.** A nested child naming its own local id or its own full
  canonical reference is unresolved.
- **One-sided declaration.** A parent cell present but no own declaration (or the
  reverse) is the union, not drift.
- **Pure container vs hybrid.** A nested decomposing child with a manifest and no
  `design.md` has an empty own set and a declared set equal to its parent cell; a
  hybrid node may carry both its own declaration and children.
- **`.gitkeep`-only child.** A child directory holding only `.gitkeep` is still an
  entity via its parent row.
- **Legacy alias at depth.** A nested `roadmap.md` carrying `phase: roadmap` is
  treated the same as a `manifest.md` for the recursion.
- **Shipped vs recalled.** A `ship.md`-present entity is excluded as a
  counterpart; the declared-conflict check does not introduce new handling for a
  recalled marker beyond the shipped exclusion.
- **Empty comparison.** No declarations at all, or all items shipped, yields no
  findings and no error.

## Open questions

- [x] **Cross-level naming policy — resolved 2026-10-13 by user.** References
  resolve from the repository root to any existing `work/<ref>/` at any depth
  (ancestor, descendant, or different subtree); sibling-first applies only to a
  bare single-segment token. Preserves the shipped fixtures. Owner: user.
- [x] **Bare-token precedence — resolved 2026-10-13 by user.** Immediate-parent
  `Children` table first, then repository-root `work/<token>/`; multi-segment
  references are root-relative. Owner: user.
- [x] **Verification approach — resolved 2026-10-13 by user.** Docs-only: update
  the two authority documents and keep `tests/checks/85-conflict-guards.sh`
  byte-unchanged and green; recursion is verified by authority inspection/manual
  review. Committed recursive guards are deferred to Roadmap 5. Owner: user.
- [ ] **Exact committed recursive fixture coverage** (depth-3 conflict case) —
  deferred to Roadmap 5. Owner: user, needed by: none for this item.

## Dependencies and constraints

- **Extend, do not fork.** This child extends the shipped declaration model from
  `0006-parallel-plan-conflicts`, the recursive reference grammar and readiness
  from `0011-recursive-bootstrap`, and the manifest-as-sole-enumeration-source
  from `0012-roadmap-deprecation`. It defines no second state model, reference
  grammar, conflict taxonomy, or finding vocabulary.
- **Surfaces.** `docs/workflow.md` ("Declared conflicts (`conflicts-with`)",
  "Declared-conflict check") and `docs/artifact-conventions.md` (the manifest
  `conflicts-with` bullet). No source code, no new fixture area.
- **Committed suite stays green.** `bash tests/run.sh` must pass at every step;
  `tests/checks/85-conflict-guards.sh` is left byte-unchanged (its resolution
  regex stays two-segment, which continues to satisfy every existing fixture).
- **Verification is authority inspection.** The declared-conflict check is
  prompt behavior with no committed checker; with this child's docs-only scope,
  AC1–AC17 are verified by reading the named authority sections and by the
  existing suite staying green. The residual — a live `/conflicts`, `/status`, or
  `/build`-gate run emitting the recursive findings — remains a documented manual
  check, as it already is for the two-level model.
- **Conflict-free by construction.** This item declares no `conflicts-with`
  targets of its own; the manifest records that sibling pairs sharing
  `docs/workflow.md`/`docs/artifact-conventions.md` are an intentional advisory
  overlap.
