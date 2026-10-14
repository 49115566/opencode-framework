---
feature: 0015-recursive-workflow-guards/0001-recursive-structure-guard
phase: spec
status: final
created: 2026-10-14
updated: 2026-10-14
notes: ""
parent: 0015-recursive-workflow-guards
---

# Recursive model, reference, and allocation guard

## Problem

The recursive lifecycle model is documented and has been swept across every
agent, command, and skill prompt (Roadmap 4, `0014-agent-command-inventory-sweep`,
shipped), but it is pinned by almost no committed fixture. The committed
recursive fixtures are all two levels deep — the cycle fixture and the
`declared-conflicts`/`backtracking` manifest fixtures each exercise only a
parent→child shape. No committed fixture reaches depth ≥ 3, carries a **hybrid**
node (one that both decomposes and holds its own phase artifacts), or nests a
test reference beyond the two-level special case.

The consequence is that a regression which flattens the model back to two levels
would pass the committed suite: mis-allocating a grandchild's local `MMMM`
number from the top-level sequence, treating a fine-grained `tasks.md` entry as a
node, truncating the canonical-reference grammar to one nested segment, or
failing to derive a same-parent duplicate at depth. Framework maintainers who
change the recursive model cannot trust CI to catch such a regression, and
adopters inherit the recursive model with that gap.

The authority this guard pins is already shipped and is not to be edited:
`docs/workflow.md` → "The recursive lifecycle model", "Where decomposition is
authored and recorded", "Multiple work items", and "Merge-integrity guard"; and
`docs/artifact-conventions.md` → "Work item references", "Sequence allocation",
and "`manifest.md` — the manifest of a decomposing node". It is the single source
of truth for the model, the reference grammar, and per-level allocation; this
work item redefines none of it and edits no production surface.

## Goals

- A committed, fixture-based guard exists that fails whenever the recursive
  model, the canonical-reference grammar, or per-level sequence allocation
  regresses at depth ≥ 3.
- The guard's committed fixture tree reaches at least four item levels
  (`<NNNN>/<MMMM>/<MMMM>/<MMMM>/`), includes a node that both decomposes and
  carries its own phase artifacts, includes a directory holding only a per-level
  reservation marker and no phase artifacts, and includes duplicate-prefix
  samples at the top level and at depth ≥ 3.
- The guard derives the `DUPLICATE-PREFIX` and `DUPLICATE-CHILD` findings for its
  allocation samples and compares them to an expected block, so a mis-scoped
  allocation fails the guard rather than passing unnoticed.
- The guard pins the authority prose that the cycle applies uniformly at every
  node, that decomposition imposes no maximum depth, that fine-grained task
  entries are not nodes, that each child directory is reserved at every level,
  and that allocation is scoped to the immediate parent and never reused.
- The guard pins the cross-cutting "prompt behavior only — no committed
  executable checker" contract for both the merge-integrity guard and the
  declared-conflict check, so no guard drifts into shipping a production checker.
- The committed suite stays green, and the mutation self-check's clean
  whole-suite runs stay green.
- The guard reads only committed fixture surfaces and the live authority
  documents; it never reads live `work/**`.

## Non-goals

- Recursive readiness, derived state, and `/status` rendering — owned by
  `0002-recursive-readiness-status-guard`.
- Recursive declared-conflict detection and the `conflicts-with` grammar — owned
  by `0003-recursive-conflicts-guard`.
- The full merge-integrity invariant set (dangling, cyclic, missing, unlisted,
  drift) and the recursive renumber procedure — owned by
  `0004-recursive-integrity-guard`.
- Registering the new agreement area in the documented Checks table, assigning
  its stable token, and adding the mutation jobs — owned by
  `0005-guard-registration-sweep`.
- Any new committed executable checker or production tool; the guard is
  fixture-scoped test behavior invoked by no framework command.
- Editing any production surface: `docs/**`, `.opencode/**`, `README.md`,
  `AGENTS.md`, `template/**`.
- Re-asserting the literals owned by the existing areas (readiness, lifecycle,
  command signatures) or duplicating the cycle, conflict, and backtrack guards'
  authority.
- Migrating, rewriting, or re-opening any shipped work item or its artifacts.

## Users and stories

- **As a** framework maintainer changing the recursive model, **I want** a
  committed guard that fails when the model is flattened to two levels or a
  grandchild's allocation is mis-scoped, **so that** I can change the model and
  trust CI to catch the regression at every depth.
- **As a** framework maintainer, **I want** the guard to derive duplicate
  findings from a committed fixture rather than assert only prose, **so that** an
  allocation regression fails the suite rather than passing unnoticed.
- **As an** adopter inheriting the recursive model, **I want** its guarantees
  held by a committed, read-only suite, **so that** the model I depend on cannot
  silently regress.

## Acceptance criteria

1. **AC1 — Fixture depth.** Given the committed test suite, when the guard runs,
   then a committed fixture tree exists whose directory nesting reaches at least
   four item levels (`<NNNN>/<MMMM>/<MMMM>/<MMMM>/`); the guard fails (does not
   skip) when the fixture root is absent or when its deepest branch is shallower
   than four levels.

2. **AC2 — Hybrid node.** Given the fixture tree, when the guard inspects it,
   then at least one node both decomposes into children and carries at least one
   of its own phase artifacts; the guard fails if no such node exists, pinning
   that a node may carry its own artifacts and a child set at the same time.

3. **AC3 — Per-level reservation marker.** Given the fixture tree, when the
   guard inspects it, then every child directory, at every level, contains a
   per-level reservation marker, and at least one leaf child contains only that
   marker and no phase artifacts; the guard fails if a reserved child directory
   lacks the marker or if no marker-only leaf exists.

4. **AC4 — Per-level allocation scoping.** Given the fixture tree, when the guard
   inspects the child allocations, then the tree demonstrates two distinct
   parents each independently beginning their local numbering at its own first
   number, including a grandchild allocated under its immediate parent; the guard
   fails if any local number is derived from the top-level sequence or from a
   non-immediate ancestor.

5. **AC5 — Canonical reference nests to depth.** Given a fixture node at depth
   four, when the guard resolves its canonical reference, then the
   three-or-more-segment reference resolves to that node's directory; and the
   guard pins the documented grammar
   `^[0-9]{4}-[a-z0-9-]+(/[0-9]{4}-[a-z0-9-]+)*$` as the arbitrary-depth nesting
   form.

6. **AC6 — Top-level duplicate derived.** Given two top-level fixture items
   sharing a four-digit prefix, when the guard derives duplicate findings, then
   it reports exactly one `DUPLICATE-PREFIX` finding naming both offenders, and
   the derived finding set matches an expected block.

7. **AC7 — Same-parent duplicate at depth ≥ 3 derived.** Given two same-parent
   children at depth ≥ 3 sharing a local four-digit prefix, when the guard
   derives duplicate findings, then it reports exactly one `DUPLICATE-CHILD`
   finding that names both full canonical references plus the shared parent and
   the shared local prefix.

8. **AC8 — Duplicate position never mislabeled.** Given the fixture's duplicate
   samples, when the guard derives findings, then no top-level collision is
   reported as `DUPLICATE-CHILD` and no deeper collision is reported as
   `DUPLICATE-PREFIX`, and two nodes whose local-id text matches but whose
   parents differ are not reported as a duplicate.

9. **AC9 — Model uniform at every node.** Given the guard runs, when it checks
   the pinned authority, then it fails if the statement that the cycle applies
   uniformly at every node, that decomposition imposes no maximum depth, and that
   nesting continues to arbitrary depth is dropped or weakened from the
   authority.

10. **AC10 — Task entries are not nodes.** Given the fixture's fine-grained task
    list, when the guard inspects it, then no task entry has a corresponding item
    directory and no item directory is created by a task entry; and the guard
    pins the authority statement that fine-grained task entries are not nodes.

11. **AC11 — Reservation and allocation prose pinned.** Given the guard runs,
    when it checks the pinned authority, then it fails if the per-level
    child-reservation statement or the immediate-parent allocation-scoping
    statement (greatest four-digit prefix ever committed under that parent, plus
    one, never reused) is dropped or weakened.

12. **AC12 — No committed executable checker.** Given the guard and the
    authority, when the guard runs, then it pins the "prompt behavior only — no
    committed executable checker" statement for both the merge-integrity guard
    and the declared-conflict check, and it asserts that the guard itself is
    fixture-scoped test behavior (invoked by no framework command) rather than a
    production checker.

13. **AC13 — Read-only and self-contained.** Given the guard runs, when it reads
    the fixture, then it reads only committed fixture surfaces and never a live
    `work/**` path, fails when the fixture references a live work path, and
    contains no absolute or escaping path; repeated or concurrent runs produce
    identical findings and modify no file.

14. **AC14 — Suite stays green.** Given the guard and its fixture are committed,
    when the committed suite runs against a fresh clone with no `work/**`, then it
    exits 0 with every existing area still passing and the new area labelling its
    assertions with a stable token.

15. **AC15 — Mutation clean runs stay green.** Given the guard's fixture root is
    staged into the mutation self-check's clean copy, when the mutation
    self-check's clean whole-suite runs execute, then they exit 0; the guard's
    own mutation jobs are added later by `0005-guard-registration-sweep`.

16. **AC16 — No production surface touched.** Given the completed work, when the
    diff is inspected, then no file under `docs/**`, `.opencode/**`, `README.md`,
    `AGENTS.md`, or `template/**` is modified.

## Edge cases

- **Missing fixture** — the guard reports a hard failure naming the missing
  fixture root; it never skips over a missing required fixture.
- **Shallow fixture** — a fixture branch that stops before four levels fails AC1
  rather than silently passing.
- **Equal text, different parents** — two nodes whose local-id text matches but
  whose parents differ are not a duplicate; identity is the full canonical path.
- **Shared prefix at depth ≥ 3** — the duplicate finding names both full
  canonical references and the shared parent plus shared local prefix, so a
  collision is unambiguous at depth.
- **Marker-only node** — a child directory holding only the reservation marker is
  not read as carrying phase artifacts and creates no false duplicate.
- **Empty or whitespace-only token** — malformed input must never be treated as
  "no finding" or silently dropped.
- **Staged-copy execution** — the guard runs against the mutation self-check's
  staged copy, which stages no checks directory and no live `work/`; it resolves
  sibling check files relative to its own location and does not depend on live
  work artifacts.
- **Idempotence and concurrency** — repeated or concurrent runs take no lock,
  write nothing, and yield identical findings.
- **Optional-tool absence** — the guard needs only bash and git; it must not fail
  or skip when optional tools are absent.

## Open questions

- [x] Contract-assertion home — **resolved**: pinned inside this structure area
  (user decision).
- [x] Duplicate-finding scope — **resolved**: this guard derives duplicate
  findings for its allocation samples only; the full recursive invariant set and
  the report-only behavior stay with `0004-recursive-integrity-guard` (user
  decision). Recorded as an intentional, bounded overlap on the `DUPLICATE-*`
  codes.
- [x] Mutation staged-copy ownership — **resolved**: this guard adds its own
  fixture root to the mutation self-check's staged-copy list so its clean
  whole-suite runs stay green; `0005-guard-registration-sweep` adds the mutation
  jobs for all four guards (user decision).
- [x] Fixture depth — **resolved**: four item levels plus a depth ≥ 3 duplicate
  sample (user decision).
- [ ] The guard's stable agreement-area token — owner: design /
  `0005-guard-registration-sweep`, needed by: build and registration.
- [ ] The exact new checks-area and fixture-root names and their sequence
  placement — owner: design, needed by: build.

## Dependencies and constraints

- **No `Depends on` edge.** This child declares no sibling dependency and is
  ready. Its only sequencing relationship is that
  `0005-guard-registration-sweep` depends on it.
- **Authority is pinned, not edited.** `docs/workflow.md` and
  `docs/artifact-conventions.md` are the target the guard reads; no child edits
  them. If the guard finds the authority wrong, the sanctioned route is a
  recorded finding and a `/plan <parent-ref>` or reverse-edge handoff, never an
  edit.
- **Shipped work is context.** Every shipped item, including every `0010`–`0014`
  child and the parent manifest, is out of scope for rewriting.
- **No new runtime, toolchain, or network.** The guard is bash-and-git only; no
  install, service, or optional tool is required.
- **Fixture ids are non-allocating.** New fixture entity ids stay in the high,
  non-colliding test-id space and allocate no real `work/` number.
- **Shared test registries.** The parent `Children` row declares
  `conflicts-with: tests/README.md, tests/mutation.sh`; this guard's contribution
  is append-only (its own fixture root in the staged-copy list), and `0005` owns
  the documented Checks table and the mutation jobs.
- **Suite contract.** The committed suite must pass at every step; the mutation
  self-check's clean whole-suite runs must also stay green once this guard's
  fixture root is staged.
- **Sibling boundary.** `0004-recursive-integrity-guard` also names
  `DUPLICATE-PREFIX`/`DUPLICATE-CHILD`; this guard limits itself to
  allocation-scoping derivation and defers the full invariant set and the
  report-only behavior to `0004`, referencing that area rather than restating it.
- **Reference patterns.** The existing fixture-based guards
  (`tests/checks/80-cycle-fixture.sh`, `tests/checks/85-conflict-guards.sh`) and
  the test-suite contract and mutation policy (`tests/README.md`,
  `tests/mutation.sh`) are the conventions this guard extends; it defines no
  second harness, token scheme, or mutation policy.
