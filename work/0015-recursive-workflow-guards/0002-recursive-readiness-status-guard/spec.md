---
feature: 0015-recursive-workflow-guards/0002-recursive-readiness-status-guard
phase: spec
status: final
created: 2026-10-14
updated: 2026-10-14
parent: 0015-recursive-workflow-guards
---

# Recursive readiness and `/status` guard

## Problem

The recursive lifecycle model derives each node's **readiness** and **phase**
live from committed files, and `/status` renders the whole decomposition tree
indented to arbitrary depth with per-node readiness and per-container summary
lines. That contract is documented and swept, but it is pinned by **no committed
fixture deeper than two levels**. The existing readiness and lifecycle guards
assert contract text only and cover flat items; the cycle guard's fixture is
depth 2; and the backtracking guard deliberately skips decomposing nodes
(`tests/checks/87-backtrack-guards.sh:94`). As a result, a regression that
flattened readiness/derived-state/status back to two levels, mis-derived a nested
or hybrid node's phase, dropped the indentation or the `<ready>/<total> ready`
and phase-tally lines, or mishandled a recalled dependency would still pass
`bash tests/run.sh`.

Framework maintainers cannot safely change the recursive readiness/status
contract, and adopters inherit an unguarded workflow guarantee. This item adds
the committed, fixture-based guard that pins recursive readiness, derived-state
precedence, and `/status` rendering at every depth.

## Goals

- A committed, fixture-based **agreement area** pins recursive readiness,
  derived-state precedence, and `/status` render shape and fails when any of them
  regresses.
- A committed **fixture root** exercises a tree at depth ≥ 3 that includes a
  hybrid node (a node that both decomposes and carries its own phase artifacts),
  a `.gitkeep`-only child, and both satisfied and unsatisfied sibling
  dependencies at more than one level.
- The guard derives each fixture node's readiness and phase and compares the
  result, and each decomposing node's summary line, to a reviewed expected block;
  flattening the tree or mis-deriving a node fails the area.
- The `/status` render requirements (arbitrary-depth indentation, per-node
  `ready`/`blocked: <local ids>`, and per-container `<ready>/<total> ready` plus a
  `<phase> <n>, ...` phase tally) are pinned against the prompt authority so
  removing one fails the area.
- `bash tests/run.sh` stays green, the guard reads only committed fixtures and
  live surfaces (never live `work/**`), and it modifies no file.

## Non-goals

- **No production surface changes.** `docs/**`, `.opencode/**`, `README.md`, and
  `AGENTS.md` are the *pinned* authority, not the guarded artifact; this item
  edits none of them.
- **No committed executable checker.** The guard is fixture-scoped test code, not
  a production tool: it adds no command, script, or helper invoked by any
  framework phase, mirroring the "prompt behavior only" contract of
  `docs/workflow.md` → "Merge-integrity guard" and "Declared-conflict check".
- **No re-pinning of flat overlay semantics.** The flat (top-level,
  non-decomposing) `stale:`/`reopened:`/open-challenge vocabulary and readiness
  single-source phrases remain owned by
  `tests/checks/87-backtrack-guards.sh` and `tests/checks/10-readiness.sh`; this
  item pins only their **recursive composition**.
- **No ownership of the recursive structure/reference/allocation contract**
  (`0001`), declared conflicts (`0003`), or merge-integrity/renumber (`0004`).
- **Registration is not this item's.** The `tests/README.md` Checks-table row and
  mapping paragraph, the mutation jobs, and the `tests/mutation.sh` staged-copy
  entry are owned by `0005-guard-registration-sweep`; this item authors the guard
  and fixture only.
- **No live `/status` run.** Driving a real `/status` is not executable in CI; the
  LLM-run residual stays a documented manual check.
- **No new harness or policy.** No second harness, token scheme, mutation policy,
  runtime dependency, service, network access, or toolchain is introduced.

## Users and stories

- **As a** framework maintainer, **I want** a committed guard that fails when
  recursive readiness, derived state, or the `/status` render regresses at any
  depth, **so that** I can change the recursive model and trust the suite to
  catch a flattening or mis-derivation regression.
- **As an** adopter, **I want** the recursive readiness and status guarantees
  pinned by the inherited suite, **so that** upgrading the framework cannot
  silently change how my nested work items' readiness and phases are reported.

## Acceptance criteria

1. **AC1** — Given the new recursive-status fixture root, when its tree is
   inspected, then it contains at least one node at depth ≥ 3 (three nested
   reference segments), at least one **hybrid** node that both decomposes into
   children and carries its own phase artifacts, and at least one `.gitkeep`-only
   child.
2. **AC2** — Given a decomposing node in the fixture, when readiness is derived
   for its immediate children, then the area reports each child as `ready` or
   `blocked: <local ids>` naming only the unsatisfied sibling dependencies, and
   does so independently at each level including depth ≥ 3.
3. **AC3** — Given fixture children whose dependency targets respectively carry a
   non-recalled `ship.md`, an `approve` review verdict with no `ship.md`, a
   `request-changes` verdict with no `ship.md`, and no review verdict, when
   readiness is derived, then the first two dependencies are satisfied and the
   latter two are not.
4. **AC4** — Given a fixture child whose `ship.md` carries a `reopened:` marker,
   when a dependent's readiness is derived, then the dependent is `blocked`
   naming that recalled child, and the recalled child does not satisfy the
   dependency.
5. **AC5** — Given a `ship.md`-present dependency whose `review.md` verdict is
   `request-changes`, when readiness is derived, then `ship.md` presence takes
   precedence and the dependency is satisfied.
6. **AC6** — Given a dependency target that is itself a decomposing node, when
   readiness is derived, then the target is satisfied by its own `ship.md`
   presence or `approve` verdict only and its descendants are not consulted; and
   a `Depends on` token is resolved only against a sibling in the same node.
7. **AC7** — Given a fixture child in a dependency cycle, when readiness is
   derived, then no member of the cycle is reported `ready`. (Cycle *detection*
   remains owned by `tests/checks/80-cycle-fixture.sh`; this area pins only the
   readiness consequence at depth.)
8. **AC8** — Given the fixture is derived twice with no change, when the area
   runs, then it produces identical readiness and phase output both times, and no
   fixture manifest carries a stored readiness value.
9. **AC9** — Given a hybrid node (manifest plus its own phase artifacts), when its
   phase is derived, then it derives its **own** phase before the container
   `manifest`; given a pure container (manifest, no own phase artifacts), then it
   derives `manifest`.
10. **AC10** — Given a nested child that itself decomposes, when its phase is
    derived, then it derives its own phase first and, absent own artifacts,
    `manifest`; and a `.gitkeep`-only node derives `not started`.
11. **AC11** — Given a hybrid or nested node carrying an earliest `stale:` marker,
    a `reopened:` marker, or an unshipped open challenge, when its phase is
    derived, then the authority's precedence applies at that node — the earliest
    `stale:` names a backtracked phase, `reopened:` names a reopened phase, and
    the unshipped open-challenge overlay is evaluated before the artifact-presence
    and verdict rows — rendered with the authority's verbatim labels. The flat
    overlay vocabulary and its branches are referenced, not re-asserted.
12. **AC12** — Given the `/status` render contract, when the area runs, then it
    fails if any of the following requirements is absent from the prompt
    authority: the tree is rendered indented to arbitrary depth; each node shows
    its derived phase and its `ready`/`blocked: <local ids>` readiness; each
    decomposing node shows `<ready>/<total> ready` over its immediate children
    plus a `<phase> <n>, ...` distribution tally.
13. **AC13** — Given the fixture, when the area computes each node's derived
    phase/readiness and each decomposing node's summary line, then the result
    equals a reviewed, literal expected block; when the fixture is edited to
    flatten a level or to make a node derive the wrong phase or readiness, then
    the area fails.
14. **AC14** — Given the recursive-status fixture root is missing, when the suite
    runs, then the area **fails** (it does not skip); and the area asserts its
    own read-only contract: it reads only committed fixtures and live surfaces,
    never live `work/**`, and modifies no file.
15. **AC15** — Given the new agreement area, when its owned literals are compared
    against neighbouring areas, then it references `10-readiness`,
    `20-lifecycle`, `80-cycle-fixture`, and `87-backtrack-guards` by name and
    re-asserts none of the literals those areas own, and it adds no production
    checker.

## Edge cases

- A decomposing node whose immediate child is itself a decomposing node
  (depth ≥ 3), and a node deeper than three levels to prove no maximum depth.
- A `.gitkeep`-only child of a decomposing node derives `not started`, not a
  phase.
- A child with multiple dependencies where only some are satisfied: `blocked`
  names exactly the unsatisfied local ids, comma-separated.
- A dependency target that is both `ship.md`-present and recalled: recalled wins
  (unsatisfied).
- A dependency target that is a decomposing node: only its own signal is
  consulted; its descendants' states are irrelevant.
- An `approve` verdict with no `ship.md` (satisfied, even unshipped) versus a
  `request-changes` verdict with no `ship.md` (not satisfied).
- A hybrid node with its own `spec.md` only, versus one with a partial phase set,
  versus a pure container: own artifacts always precede `manifest`.
- A node carrying both an earliest `stale:` and a live open challenge: the
  blocked `challenged (blocked)` label wins the phase while the backtrack detail
  remains reportable at that node.
- The fixture root absent: the area fails explicitly rather than skipping.
- A malformed expected block or a fixture edit that removes a depth level: the
  area names the mismatch rather than silently passing.

## Open questions

- [ ] Exact fixture root name and the `9xxx` fixture-id band to use, chosen to
  avoid colliding with the sibling guards' new fixture roots (`0001`–`0004` all
  add roots in the high, non-allocating `90xx`/`91xx`/`92xx` space). **Deferred**
  to the architect; owner: architect; needed by: `/plan`. It does not block this
  spec: the requirement is a distinct, non-`work/`-allocating fixture root
  regardless of the name.
- [ ] **Assumption** — the guard is authored as one agreement area carrying the
  next free suite token (`AC27`), per the user's granularity decision; if
  `/plan` re-slices it into two areas, that is a `/plan
  0015-recursive-workflow-guards` revision, not a `/spec` change.

## Dependencies and constraints

- **Pins shipped authority, changes none.** The guard reads
  `docs/workflow.md` → "Dependencies and readiness", "Derived state", "Status
  reporting", "The recursive lifecycle model", "Phase reversal (backtracking)",
  and "Findings challenge and adjudication";
  `docs/artifact-conventions.md` → "Work item references", the `manifest.md`
  template, and the `backtracks.md`/`challenges.md` record shapes; and
  `.opencode/agent/status.md`. A guard that finds the authority itself wrong
  records a finding and recommends the sanctioned reverse route rather than
  editing it.
- **Depends on** the shipped sibling guards for their owned literals:
  `tests/checks/10-readiness.sh` (readiness single-source), `20-lifecycle.sh`
  (flat derived-state), `80-cycle-fixture.sh` (cycle rule), and
  `87-backtrack-guards.sh` (flat reverse/overlay semantics).
- **Carries no manifest dependency.** The parent `Children` row declares
  `Depends on: —`, so this item is `ready` and proceeds without an override.
- **Registration is downstream.** The `tests/README.md` Checks-table row and
  mapping paragraph, and the `tests/mutation.sh` mutation jobs and staged-copy
  entry, are owned by `0005-guard-registration-sweep`; this item's fixture root
  must be registered there or the mutation pass will not exercise it.
- **Suite contract.** The area is sourced by `tests/run.sh` (it must not call
  `exit`, prints `ok`/`FAIL`/`skip` only, and is labelled with a stable token),
  stays Bash 3.2 compatible, reads only committed fixtures and live surfaces, and
  keeps `bash tests/run.sh` green at every step.
- **Fixture ids are non-allocating.** Fixture entity ids stay in the high,
  non-colliding `9xxx` space and allocate no real `work/` number, matching the
  existing fixture roots.
- **Offline and local.** No fetch, remote, dry-run merge, lock, network access,
  or new toolchain is introduced.
