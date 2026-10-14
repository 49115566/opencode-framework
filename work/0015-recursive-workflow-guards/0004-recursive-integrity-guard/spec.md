---
feature: 0015-recursive-workflow-guards/0004-recursive-integrity-guard
phase: spec
status: final
created: 2026-10-14
updated: 2026-10-14
parent: 0015-recursive-workflow-guards
notes: "Nested child of 0015-recursive-workflow-guards (the Roadmap 5 guards node); the directory held only .gitkeep and its scope is the parent manifest's 0004 row (work/0015-recursive-workflow-guards/manifest.md:126). Readiness: the row declares Depends on: — (no dependencies), so the child is ready under the readiness algorithm and no override is needed. No backtracks.md exists in this item and no open finding targets /spec, so this is ordinary forward progression. User resolved the four guard forks on 2026-10-14: (1) the renumber half exercises a committed completed whole-subtree renumber fixture and asserts no stale reference remains, rather than re-pinning prose; (2) overlapping invariants are handled by referencing the owning sibling areas by name (0001 for the duplicate findings, the cycle area for CYCLIC-DEP, the packaging area for the duplicated-count fact) and directly pinning only the unowned tree-structural invariants; (3) the area's stable suite token is pre-assigned by local-id order as AC30; (4) this item stages its own new fixture root in the mutation self-check's copy list so the opt-in whole-suite runs stay green, while the tests/README.md row and the mutation jobs remain 0005's registration. The authority docs and prompts are the pinned target, not the guarded artifact; a contradiction a guard exposes is routed upstream via the backtrack model, not fixed here."
---

# Committed recursive merge-integrity and renumber guards

## Problem

The recursive **merge-integrity guard** and the recursive **renumbering
procedure** are shipped as documented prompt behavior — `docs/workflow.md` →
"Merge conflicts" and its "Merge-integrity guard" invariant set, together with
the operational mirror in `.opencode/skill/merge-conflict/SKILL.md` and
`docs/artifact-conventions.md` → "Renumbering after a parallel merge" — but no
committed fixture pins their **recursive** shape. The invariant set must be
evaluated at **every node of the tree, independently**, and the renumber must
move a **whole subtree** and rewrite every reference on the changed path; today
nothing in the committed suite would fail if the evaluation silently flattened
back to two levels or the renumber's reference sweep were truncated to the moved
directory and its own `feature:` line.

The existing guards are two-level: the cycle fixture and its agreement are depth
2, the declared-conflict fixture is depth 2, and `tests/checks/88-renumber-sweep.sh`
pins only the **prose** rewrite lists (it asserts the authority and skill
enumerate the reference set — not that a renumber actually leaves no stale
reference). Consequently a regression that evaluates the invariant set only at
the top level, that misses a colliding grandchild, that fails to flag a
missing/unlisted child on a nested node, that treats a node holding both a modern
manifest and the deprecated alias as clean, or that performs a renumber leaving an
intermediate manifest's `Canonical reference` or a descendant's `parent:` stale
would pass the committed suite green.

Two audiences pay for this. **Framework maintainers** rely on `bash tests/run.sh`
as the regression backstop; they cannot change the merge-integrity or renumber
contract and trust a committed test catches a regression at every depth.
**Adopters** inherit the recursive model and the same committed suite and need its
guarantees held at every node without per-item setup.

## Goals

- Add a committed, fixture-based agreement area that pins the **merge-integrity
  invariant set** as evaluated **independently at every node** of the recursive
  tree — the top level against top-level items and each decomposing node against
  its own immediate children — with a committed fixture root whose tree is at
  least three levels deep and includes a colliding grandchild, a decomposing node
  with a missing and an unlisted child, and a node carrying both manifest
  spellings.
- Pin the guard's **report-only contract**: findings are non-fatal, never
  truncated, and never auto-repaired; a deliberate withdrawal recorded under a
  node's open issues is report-only for `UNLISTED-CHILD`; an empty or clean tree
  reports no findings and does not error.
- Pin the **recursive renumber** by exercising a committed fixture that
  represents a **completed whole-subtree renumber** and asserting that **no
  reference to the old canonical reference remains** across the full rewrite set
  (directory name, every descendant `feature:` value, every `parent:` value on
  the changed path, the owning manifest's `Local id` and `Canonical reference`
  cells, every intermediate manifest's `Canonical reference` cell, every
  `Depends on` cell, every `conflicts-with` target, and the recorded ship/handoff
  path).
- Reference the invariants already owned by neighbouring agreement areas by name
  and add no duplicate assertion of their literals; keep every existing area
  green.
- Expose stable named sub-areas and label every assertion with the area's stable
  suite token, and add the new fixture root to the opt-in mutation self-check's
  staged copy list so its whole-suite runs stay green; the suite-documentation
  row and the mutation jobs remain the registration child's responsibility.
- Keep the change framework-internal, fixture-based, read-only, provider-neutral,
  and runnable on a fresh clone with no live `work/**` present, with no committed
  production checker and no new runtime dependency, service, network access, or
  `gh` call.

## Non-goals

- Changing the contracts this item guards. The merge-integrity invariant set, the
  finding grammar and codes, the report-only policy, and the recursive renumber
  procedure are fixed by the shipped authority and its operational mirror; this
  item freezes them with tests and re-decides none of them.
- Re-pinning what the existing areas already own — the top-level and same-parent
  **duplicate findings** (owned by `0001-recursive-structure-guard`), the
  **cycle diagnostic** (owned by `tests/checks/80-cycle-fixture.sh`), the
  **duplicated-inventory/count fact** (owned by `tests/checks/90-packaging.sh`),
  the declared-conflict grammar and check (`tests/checks/85-conflict-guards.sh`),
  the backtrack/reopen guards (`tests/checks/87-backtrack-guards.sh`), and the
  renumber prose lists (`tests/checks/88-renumber-sweep.sh`). The new area
  references those areas by name and adds no duplicate literal.
- Authoring the registration: the `tests/README.md` Checks row and its mapping
  paragraph, and the per-rule mutation jobs, are the registration child's
  (`0005-guard-registration-sweep`) responsibility, not this item's.
- Editing any live surface — `docs/*.md`, `AGENTS.md`, `template/AGENTS.md`,
  `README.md`, or `.opencode/**`. The authority is the pinned target, not the
  guarded artifact; if a guard exposes a contradiction in a settled surface, the
  finding is recorded and routed upstream through the backtrack model rather than
  fixed here.
- Adding a committed executable checker, script, helper, or production tool for
  the merge-integrity guard or the renumber. Both remain prompt behavior with no
  committed checker; the guard is fixture-scoped test code only.
- Executing a live `/status` render, a real `/ship` reconcile or post-merge
  integrity pass, or an actual `git mv` against live `work/**`. Those remain
  documented manual residuals, consistent with the cycle, conflict, and backtrack
  guard areas.
- Any visual, UI, frontend, or browser work; the deliverable has no user-facing
  surface.
- Redefining any finding code, class, severity, or verdict vocabulary; the
  existing grammar is reused unchanged.

## Users and stories

- **As a** framework maintainer, **I want** the merge-integrity invariant set
  pinned by committed fixture-based tests evaluated at every node, **so that** a
  regression that flattens the evaluation to two levels fails in CI instead of
  shipping silently.
- **As a** framework maintainer, **I want** the recursive renumber pinned by a
  fixture that proves a completed whole-subtree move leaves no stale reference,
  **so that** a truncated reference sweep is caught rather than discovered when a
  stale declaration later reports a dangling or drift fault.
- **As an** adopter, **I want** my inherited suite to guard the same recursive
  integrity and renumber contract, **so that** a framework upgrade cannot regress
  it unnoticed.
- **As a** maintainer of the mutation self-check, **I want** each new sub-area
  proven caught and named, **so that** a vacuous or unfalsifiable guard cannot
  pass as coverage.
- **As a** maintainer on a fresh clone, **I want** the guards to read only
  committed fixtures and live surfaces and never live `work/**`, **so that** the
  suite runs with no per-item artifacts present.
- **As a** maintainer, **I want** the new guards to extend rather than duplicate
  the existing agreement areas, **so that** a single contract has a single owning
  guard and the suite stays comprehensible.

## Acceptance criteria

1. **AC1 — Fixture-based and fresh-clone safe.** Given the committed suite is run
   against a tree containing no live `work/**`, when the new merge-integrity area
   executes, then it passes using only committed fixtures and live surfaces,
   performs no write and no network or provider call, and fails rather than skips
   when a required fixture is missing.

2. **AC2 — Independent per-node evaluation.** Given a committed integrity fixture
   whose tree is at least three levels deep, when the suite runs, then the area
   evaluates the invariant set **independently at every node** — the top level
   against the top-level items and each decomposing node against its own immediate
   children — and a fault planted at the deepest level is caught and named as
   belonging to that node, so a two-level-only evaluation fails.

3. **AC3 — Structural graph faults at depth.** Given committed fixture data for a
   decomposing node carrying a `Children` row whose child directory is absent, a
   child directory absent from the table, and a `Depends on` local id that names
   no row and no directory, when the suite runs, then the area asserts each fault
   is detected and named (`MISSING-CHILD`, `UNLISTED-CHILD`, `DANGLING-DEP`), and
   asserts that an unlisted child directory recorded under the node's open issues
   as a **deliberate withdrawal** is reported report-only and is never counted as
   an accidental graph fault.

4. **AC4 — Manifest-spelling drift.** Given committed fixture data in which one
   node holds both a modern manifest and the deprecated alias spelling, or whose
   manifest spelling disagrees with its declared `phase` value, when the suite
   runs, then the area asserts the inconsistency is detected and named
   (`DRIFT-FACT`), that the modern manifest is treated as authoritative, and that
   the inconsistency is reported without merging, normalizing, dropping, or
   auto-repairing either file.

5. **AC5 — Report-only, non-fatal contract.** Given any fixture state, when the
   area runs, then it asserts the guard's report-only contract: every finding is
   reported and non-fatal, the finding list is never truncated, no file is
   modified by the guard, and an empty or already-clean tree reports no findings
   and does not error.

6. **AC6 — Sibling-owned invariants referenced, not re-pinned.** Given the
   invariants already owned by neighbouring areas (the top-level and same-parent
   duplicate findings, the cycle diagnostic, and the duplicated-inventory/count
   fact), when the area runs, then it references those areas by name for the
   derivation rules and asserts only the merge-integrity evaluation that covers
   them at every node, adding no duplicate assertion of the owning areas'
   literals.

7. **AC7 — Completed whole-subtree renumber leaves no stale reference.** Given a
   committed fixture representing a completed whole-subtree renumber of a node and
   its descendants (at least three levels deep, with an intermediate manifest on
   the changed path), when the suite runs, then the area asserts that no reference
   to the old canonical reference remains across the full rewrite set: the
   directory name; every descendant artifact's `feature:` value; every `parent:`
   value on the changed path; the owning manifest's `Local id` and `Canonical
   reference` cells; every intermediate manifest's `Canonical reference` cell;
   every `Depends on` cell naming the old local id; every `conflicts-with` target
   naming the old local id or old canonical reference; and the recorded
   ship/handoff path.

8. **AC8 — Renumber assertion is sensitive.** Given the renumbered fixture with
   any single old reference reintroduced, when the area runs, then it fails and
   names the renumber sub-area, so the completeness assertion is proven sensitive
   rather than vacuous.

9. **AC9 — Recursive renumber contract pins.** Given the recursive specifics of
   the renumber procedure that cannot be computed from the fixture alone (the
   intermediate manifests on the changed path and the closing "no reference to the
   old canonical reference remains" assertion), when the suite runs, then the area
   asserts those are present on the authority and its operational mirror,
   referencing the existing renumber-sweep agreement by name and restating none of
   its literals.

10. **AC10 — Stable token, sub-areas, and mutation staging.** Given the new area
    runs, when it emits its results, then every assertion is labelled with the
    area's stable suite token and one of its named sub-areas, and the new fixture
    root is present in the opt-in mutation self-check's staged copy list so its
    whole-suite runs stay green; the suite-documentation row and the mutation jobs
    remain the registration child's responsibility.

11. **AC11 — No duplication and existing areas stay green.** Given the change
    lands, when the committed suite runs, then every existing agreement area still
    passes and the new area states no duplicate of the literals owned by the
    readiness, lifecycle, cycle, conflict, backtrack, renumber-sweep, packaging,
    or command-signature areas, referencing them by name instead.

12. **AC12 — Scope and purity.** Given the item is complete, when the change is
    inspected, then only the committed test suite and the new area's own test
    documentation are touched; no live doc, prompt, command, agent, skill,
    `phase` value, state file, or production checker is added or changed, and no
    runtime dependency, network access, or `gh` call is introduced.

## Edge cases

- **No live `work/**`.** The suite runs against a fresh clone with no per-item
  artifacts; every new assertion reads only committed fixtures and live surfaces
  and never live `work/**`.
- **Missing fixture.** A required fixture that is absent fails and names its
  sub-area; it is never skipped, because a silently dropped guard is a defect.
- **Depth-three collision.** A colliding grandchild (depth ≥ 3) is detected at its
  own node, named by both full canonical references, and — for the finding's
  derivation — defers to the structure area that owns the duplicate-finding rule.
- **Deliberate withdrawal versus an accidental unlisted child.** A retained
  withdrawn child directory named under a node's open issues is report-only; an
  unlisted child with no withdrawal record is a fault the guard names.
- **Node holding both manifest spellings.** A node carrying both a modern
  manifest and the deprecated alias, or whose spelling and `phase` value disagree,
  is reported as drift with the modern manifest authoritative; neither file is
  deleted, normalized, or merged.
- **Cycle not re-fabricated.** The cycle diagnostic stays owned by the cycle
  fixture area; the new fixture carries no second cyclic graph, and the guard
  references the cycle area by name.
- **Renumber with an intermediate manifest.** A renumber of a node that is itself
  a child (depth ≥ 3) must rewrite the intermediate manifest's `Canonical
  reference` cell; the guard asserts the intermediate path is not left stale.
- **Renumber no-op.** A renumber that changes nothing is a no-op that modifies no
  file; the guard does not invent a fault for an empty change.
- **Report-only.** The guard modifies no file and never auto-repairs a violation;
  repeated runs on unchanged fixtures yield identical findings.
- **Repeat and parallel runs.** The guards are read-only and idempotent; two
  concurrent runs take no lock and write nothing.
- **Optional tools absent.** The new guards require only bash and git; if they
  ever need an optional tool it is skipped visibly, never failed.
- **Bash 3.2 compatibility.** The guards avoid associative arrays, `mapfile`, and
  empty-array expansion under `set -u`, matching the harness constraint.
- **LLM-run residual.** Behavior that requires running a phase (a live `/status`
  render, a real `/ship` reconcile or post-merge integrity pass, an actual
  `git mv`) is documented as a manual residual and is not faked by a static
  assertion.

## Open questions

- [x] **Renumber verification depth** — resolved (user): the renumber half
  exercises a committed completed whole-subtree renumber fixture and asserts no
  stale reference remains, rather than re-pinning the authority's prose lists.
- [x] **Overlapping-invariant ownership** — resolved (user): reference the owning
  sibling areas by name (the structure area for the duplicate findings, the cycle
  area for `CYCLIC-DEP`, the packaging area for the duplicated-count fact) and
  directly pin only the unowned tree-structural invariants and the
  manifest-spelling drift.
- [x] **Stable suite token** — resolved (user): pre-assigned by local-id order as
  `AC30`; the registration child records the mapping in the suite documentation.
- [x] **Mutation staging** — resolved (user): this item stages its own new fixture
  root in the mutation self-check's copy list so the opt-in whole-suite runs stay
  green; the suite-documentation row and the mutation jobs belong to the
  registration child.
- [x] **Readiness** — resolved: the parent manifest row declares `Depends on: —`,
  so the child is ready and no override is needed; there is no `backtracks.md` in
  this item and no open finding targets `/spec`.
- [ ] **Deferred — exact fixture layout, sub-area names, and check filename.** The
  fixture directory shape, the named sub-area labels, and the check filename are
  design choices; the observable content above is fixed. — owner: architect,
  needed by: design.
- [ ] **Assumption — settled surfaces are final.** The merge-integrity invariant
  set, the report-only policy, and the renumber procedure are final, and this item
  changes none of them; if a guard exposes a contradiction in a live surface, it
  is recorded and routed upstream via the backtrack model rather than fixed here.
  Confirm. — owner: user, needed by: design.
- [ ] **Assumption — test-only, offline, no provider.** This item touches only the
  committed test suite and its documentation, adds no committed production
  checker, and introduces no runtime dependency, network access, or `gh` call.
  Confirm. — owner: user, needed by: design.

## Dependencies and constraints

- **Ready.** The parent manifest row declares `Depends on: —`
  (`work/0015-recursive-workflow-guards/manifest.md:126`), so this child has no
  dependencies and is ready under the readiness algorithm; no override is needed.
- **Consumes the shipped authority unchanged.** The merge-integrity invariant set,
  its finding codes and classes, its report-only and never-auto-repaired policy,
  and its enforcement points are fixed by `docs/workflow.md` → "Merge conflicts"
  and "Merge-integrity guard", with the operational mirror in
  `.opencode/skill/merge-conflict/SKILL.md`. The recursive renumber procedure is
  fixed by `docs/artifact-conventions.md` → "Renumbering after a parallel merge"
  and the skill's class (c) renumber step. This item pins them and forks nothing.
- **Sibling areas that must stay green and must not be duplicated.** The
  readiness area (`10-readiness`), the lifecycle/derived-state area
  (`20-lifecycle`), the cycle fixture area (`80-cycle-fixture`), the
  declared-conflict guards (`85-conflict-guards`), the backtrack guards
  (`87-backtrack-guards`), the renumber-sweep area (`88-renumber-sweep`), the
  packaging area (`90-packaging`), and the command-signature sweep
  (`96-signature-sweep`). The new area references these by area name and
  re-asserts none of their literals.
- **Sibling guards 0001–0003.** The structure guard owns the recursive model,
  reference grammar, per-level allocation, and the duplicate-finding derivation;
  the readiness/status guard owns readiness and derived state; the conflicts guard
  owns the declared-conflict check. This item owns the merge-integrity invariant
  evaluation and the recursive renumber, and deliberately excludes those.
- **Not yet pinned here — deferred to registration.** The `tests/README.md`
  Checks table row and mapping paragraph, and the mutation jobs, belong to
  `0005-guard-registration-sweep`, which depends on this item. This item must
  nonetheless expose stable named sub-areas and label assertions with its stable
  token so the registration mutations can target it, and must stage its own new
  fixture root in the mutation self-check's copy list so the opt-in whole-suite
  runs stay green once its check exists.
- **Fixture-based and read-only.** The suite never reads live `work/**` and runs
  on a fresh clone (`tests/README.md`); the new area must preserve that, using
  committed fixtures and the harness reporters and deferring optional tools to a
  visible skip. Any item-reference in a fixture resolves within the fixture, not
  against live items.
- **Harness constraints.** A check file is sourced by the suite entry point and
  must not call `exit`; assertions are labelled with a stable token; the suite is
  Bash 3.2 compatible. The mutation self-check is opt-in maintainer tooling and is
  not part of the default suite run.
- **Declared conflicts.** The parent manifest row declares the two append-only
  test surfaces `tests/README.md` and `tests/mutation.sh` in `conflicts-with`
  (`work/0015-recursive-workflow-guards/manifest.md:126`); this item's own
  declaration belongs in its `design.md` frontmatter. Each guard appends its own
  row/jobs, so the read-only check will report advisory `TEXTUAL-CONFLICT` pairs
  among the four guards, which is intentional and blocks no phase.
- **Framework-internal change only.** Tests and test documentation only; no
  runtime dependency, service, new toolchain, command, agent, skill, or state
  file.
- **Assumption — naming surfaces for testability.** Because the deliverable is the
  framework's own committed suite, the acceptance criteria describe required
  observable guard behavior and scope; the exact fixture layout, sub-area names,
  and check filename are design choices deferred to the architect.
