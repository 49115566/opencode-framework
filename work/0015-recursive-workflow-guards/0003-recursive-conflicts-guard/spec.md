---
feature: 0015-recursive-workflow-guards/0003-recursive-conflicts-guard
phase: spec
status: final
created: 2026-10-14
updated: 2026-10-14
notes: "Shape decided with the user: extend the existing depth-2 declaration-model guard in place; the new fixture root is additive. Registration in tests/README.md and tests/mutation.sh is deferred to 0005-guard-registration-sweep."
parent: 0015-recursive-workflow-guards
---

# Recursive declared-conflicts guard

## Problem

The declared-conflict check is documented as recursive — it compares unshipped
declarations at any depth and resolves targets to arbitrary nesting
(`docs/workflow.md` → "Declared-conflict check") — but the committed guard that
pins it only exercises two levels. The guard's token resolver caps a reference at
one optional `/` segment, and its event builder walks only parent→immediate-child,
never recursing into a child that itself decomposes. As a result a regression that
flattens the check back to two levels — capping the recursive reference grammar,
skipping a decomposing child's own `Children` rows, or losing sibling-first
resolution precedence below the root — passes `bash tests/run.sh` unnoticed.

Framework maintainers therefore cannot trust the recursive declared-conflict
guarantee at depth three or deeper when they change the model or its resolver, and
adopters inherit an unguarded contract. The gap is real and was named by the
initiative: the existing guards are two-level and no fixture exercises depth ≥3 or
the recursion into a decomposing child
(`work/0015-recursive-workflow-guards/manifest.md:29-38,125`).

## Goals

- A committed, fixture-based guard that pins the declared-conflict check's
  **recursive** behavior at depth ≥3: the recursive target grammar and
  reference-vs-path discriminator, sibling-first-then-root resolution at every
  level, the own ∪ parent-cell union and its `DRIFT-FACT` discrepancy at depth, the
  pair predicate across levels, shipped-counterpart exclusion, and
  malformed/unresolved reporting.
- The guard is authored by **extending the existing declaration-model agreement
  area in place** (the depth-2 guard and its analyzer), so there is one
  declaration-model area and no duplicated resolver; the existing two-level
  fixture and its assertions remain as controls and stay green.
- A new committed fixture root whose tree is at least three levels deep and
  includes a decomposing **child** whose own `Children` rows enter the compared
  set.
- The guard is read-only and fixture-scoped, runs on a fresh clone with no
  `work/**`, and adds no production checker.

## Non-goals

- Editing any production or authority surface — `docs/workflow.md`,
  `docs/artifact-conventions.md`, `.opencode/**`, `README.md`, `AGENTS.md`. The
  authority is the pinned target, not the guarded artifact.
- Registering the new rules in `tests/README.md`'s Checks table/mapping paragraph
  or adding their mutation jobs and staged-copy entry to `tests/mutation.sh`.
  That reconciliation is owned by `0005-guard-registration-sweep`; this item only
  authors guard behavior and fixtures.
- Pinning the cross-cutting "prompt behavior only — no committed executable
  checker" contract. Its home is owned by `0001-recursive-structure-guard` /
  `0005`.
- The other recursive guards: structure/reference/allocation (`0001`),
  readiness/derived-state/status (`0002`), merge-integrity/renumber (`0004`).
- Any new finding code, class label, or conflict-check policy. The shipped
  `(a)`–`(d)` classes, `TEXTUAL-CONFLICT` / `DANGLING-DEP` / `DRIFT-FACT` codes,
  and finding-line grammar are reused unchanged.
- Executing a live `/conflicts`, `/status`, or `/build`-gate model run. That
  residual is not executable in CI and remains a documented manual check.

## Users and stories

- **As a** framework maintainer, **I want** the declared-conflict check's
  recursive behavior pinned by a committed fixture at depth ≥3, **so that** a
  change that silently flattens it back to two levels fails the committed suite
  and names the rule that regressed.
- **As an** adopter, **I want** the recursive declared-conflict guarantee to be
  held by the same committed suite I inherit, **so that** I can rely on arbitrary-
  depth declaration checking without reading the resolver.
- **As a** maintainer of the declaration model, **I want** the recursive rules
  pinned by one agreement area with one fixture per concern, **so that** a broken
  rule is caught by a bounded, single-purpose test rather than a broad one.

## Acceptance criteria

1. **AC1** — Given a fixture entity whose declared target is a canonical
   work-item reference containing two or more nested `NNNN-slug`/`MMMM-slug`
   segments, when the declaration-check guard resolves it, then it is classified
   as an item reference (never as a surface path) and resolves to the fixture item
   at that canonical path; and given a token that does not satisfy the recursive
   reference grammar, then it is classified as a surface path and resolves only if
   the corresponding repository path exists.

2. **AC2** — Given an entity at depth ≥3 (an entity whose immediate parent is
   itself a nested child, not the root) that declares a bare `MMMM-slug` matching
   a different row of its immediate parent's `Children` table, when resolved, then
   it resolves to that immediate parent's sibling row; and given a bare
   `MMMM-slug` that matches no sibling row but matches a top-level fixture item,
   then it resolves to that top-level item.

3. **AC3** — Given a nested child directory that itself holds a manifest, when the
   compared set is built, then that child's own `Children` rows each appear as an
   entity keyed by their full canonical reference at arbitrary depth, while the
   decomposing child itself also remains an entity from its parent's row.

4. **AC4** — Given a nested entity for which both its own declaration and its
   immediate parent row's `conflicts-with` cell are present (neither `—`), when
   its declared target set is computed, then the set is the union of the two; when
   exactly one side is present, the set is that side's targets alone.

5. **AC5** — Given a nested entity whose own declaration and immediate parent cell
   are both present (neither `—`) and whose target sets are not identical, when
   the guard analyzes it, then it reports a declaration discrepancy naming that
   entity's canonical reference; a one-sided record is not reported as a
   discrepancy.

6. **AC6** — Given two unshipped entities at any depth that share a resolved
   target, or one of which declares a target that resolves to the other's
   canonical reference, when the guard compares the declared sets, then it reports
   exactly one declared conflict for the unordered pair — the shared-target class
   for a shared surface or `work/` target, and the naming class for one-sided
   naming of an otherwise silent counterpart.

7. **AC7** — Given a shipped entity (its `ship.md` present) at any depth and
   another unshipped entity that names it, when the guard compares the declared
   sets, then the named target still resolves, but the shipped entity is excluded
   as a conflict counterpart and produces no conflict from it.

8. **AC8** — Given a nested entity that declares a target which is malformed
   (blank/empty value, a glob metacharacter, a `..` traversal, or an absolute
   path) or which resolves to no sibling row, no `work/<ref>/`, and no existing
   repository path, when the guard analyzes it, then it reports the target as
   unresolved, naming the declaring entity and the target, and neither drops nor
   auto-repairs the declaration.

9. **AC9** — Given a decomposing node at depth ≥2 whose `Children` header carries
   no `conflicts-with` column, when its rows' declared sets are computed, then
   every row is treated as declaring nothing (no target, no finding from its own
   declaration).

10. **AC10** — Given the existing depth-2 declared-conflicts fixture, when the
    generalized guard analyzes it, then the shipped `AC23` expected resolution,
    unresolved, drift, and conflict blocks and the column-layout and
    positional-parse assertions remain unchanged and passing.

11. **AC11** — Given a fresh clone with no `work/**`, when the suite runs, then
    the declaration-check agreement area passes and reads no live `work/` path,
    and the new recursive fixture references no live `work/` path.

12. **AC12** — Given the recursive fixture, when a single targeted change breaks
    any one distinct pinned rule (recursive reference grammar, sibling-first
    precedence below the root, recursion into a decomposing child, the union,
    the drift discrepancy, the pair predicate, the shipped exclusion, or
    malformed/unresolved reporting), then the declaration-check agreement area
    exits non-zero and prints a `FAIL` line naming the rule's sub-area.

## Edge cases

- **Empty compared set at depth** — no unshipped entity at any level declares a
  target: the guard yields no findings and does not error.
- **All-shipped compared set** — every entity is shipped: no findings, no error.
- **`.gitkeep`-only nested child** — an entity with neither `design.md` nor a
  non-`—` parent cell declares nothing, yet remains a counterpart when another
  entity names it.
- **Equal text, different targets** — the same bare `MMMM-slug` used in two
  different decompositions resolves to different items and is not a shared
  target.
- **Both-present-and-equal** — a nested entity whose own declaration equals its
  parent cell declares the union with no drift.
- **Reference-vs-path ambiguity** — a repository path such as `docs/...` must not
  match the recursive reference grammar, and a reference must not resolve as a
  surface path.
- **Legacy header at depth** — a decomposing child (not only a top-level node)
  may carry the five-column header; an absent column is `—` for every row.
- **Depth boundary** — a decomposing child whose own child is a `.gitkeep`-only
  leaf: the leaf is an entity from its parent row and contributes no declaration.
- **No live `work/**`** — the recursive fixture's ids must stay in the high,
  non-colliding fixture space and allocate no real `work/` sequence number.

## Open questions

- [ ] Exact name, depth, and internal layout of the new recursive fixture root,
      and the guard's new sub-area labels, are design choices — owner:
      architect, needed by: `/plan`. Recommended, not required:
      `tests/fixtures/recursive-conflicts/` at depth 3, ids in the `92xx` space.
- [ ] Whether the recursive fixture's depth-≥3 cases are read by a second fixture
      root wired into the existing area or merged into the existing root's
      discovery — owner: architect, needed by: `/plan`. Either is acceptable as
      long as AC10 (existing blocks unchanged) and AC11 (read-only) hold.

## Dependencies and constraints

- **Authority (pinned, not edited):** `docs/workflow.md` → "Declared conflicts
  (`conflicts-with`)" and "Declared-conflict check";
  `docs/artifact-conventions.md` → the `manifest.md` `conflicts-with` bullet.
- **Existing surfaces:** the depth-2 guard `tests/checks/85-conflict-guards.sh`
  and its fixture `tests/fixtures/declared-conflicts/`; the harness
  `tests/run.sh` and `tests/lib.sh` (sourced per area; a check must not `exit`).
- **Registration dependency:** `tests/README.md` Checks table/mapping and
  `tests/mutation.sh` mutation jobs and staged-copy list for the new fixture root
  are owned by `0005-guard-registration-sweep` (sibling, depends on this child).
  This item's manifest row declares both files under `conflicts-with` because
  both are shared append-only surfaces.
- **Suite contract:** the suite is read-only and never reads live `work/**`
  (`tests/run.sh:20`, `tests/README.md:30-31`); `bash tests/run.sh` must stay
  green; a new fixture root must be pure committed fixture data.
- **Assumption:** the new fixture uses the high `90xx`/`91xx`/`92xx` id space and
  allocates no real `work/` number, matching the existing fixture convention.
- **Assumption:** the guard stays portable and pure `awk`/`grep`/Bash 3.2
  compatible with no new runtime dependency.
- **Constraint:** no production surface (`.opencode/**`, `docs/**`, `README.md`,
  `AGENTS.md`) is edited; the guard adds no committed executable checker.
