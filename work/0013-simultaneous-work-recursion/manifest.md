---
feature: 0013-simultaneous-work-recursion
phase: manifest
status: final
created: 2026-10-13
updated: 2026-10-13
---

# Manifest — Simultaneous work under recursion

## Initiative

This is **Roadmap 3** of the bootstrapped multi-roadmap plan that
`work/0011-recursive-bootstrap/roadmap.md` launched (its "Multi-roadmap sequence",
`work/0011-recursive-bootstrap/roadmap.md:125-149`). Roadmap 1
(`0011-recursive-bootstrap`) shipped the minimum slice that made the lifecycle
recursive — model, schema, writer, and readiness/derived state — and Roadmap 2
(`0012-roadmap-deprecation`) retired the special `roadmap` concept, made the
generic **manifest** the sole child-enumeration artifact, and made the planning
step (`/plan`, `architect`) the sole recursive writer. What remains of the
original initiative is the **simultaneous-work** half: a recursive tree must
tolerate independent work items running in parallel at **any** depth.

This roadmap delivers that: per-level sequence allocation and duplicate detection
at every depth; `conflicts-with` declared targets at every level (the one
generalization the manifest template explicitly deferred); merge-integrity and
renumbering for recursive trees; and parallel plan publication without
collision. Each is a genuine single feature, so this node is a **pure container**
with no lifecycle artifacts of its own.

It serves **framework maintainers**, who must be able to run independent items in
parallel at any depth and trust that numbering, declared conflicts, merge
integrity, and plan publication stay coherent; and **adopters**, who inherit a
recursive workflow that must remain safe under simultaneous work rather than only
at the top level.

Deliberately **out of scope**: the broad agent/command/inventory **surface sweep**
(Roadmap 4) and the **committed recursive-workflow guards** (Roadmap 5). This
roadmap fixes the contract and the surfaces it touches, keeping the existing
committed fixtures green rather than adding a new fixture area.

## Assumptions

- **Framework-internal, prompt/config/doc/test only.** No installed runtime
  dependency, service, network access, or new toolchain is introduced. Surfaces in
  scope: `docs/workflow.md`, `docs/artifact-conventions.md`, `.opencode/agent/`,
  `.opencode/command/`, `.opencode/skill/merge-conflict/SKILL.md`, and `tests/`.
- **Roadmap 3 of the sequence.** Roadmaps 1 (`0011-recursive-bootstrap`) and 2
  (`0012-roadmap-deprecation`) have shipped all of their children; this roadmap is
  the next stage specified at `work/0011-recursive-bootstrap/roadmap.md:137-139`.
  Roadmaps 4–5 (surface sweep, committed guards) remain separate, later
  invocations.
- **Extend, do not fork.** The recursive reference grammar, per-level sequence
  allocation, the manifest, readiness, and derived state shipped by `0011` are the
  seed this roadmap generalizes. It defines no second state model, reference
  grammar, conflict taxonomy, or finding vocabulary.
- **The recursive model is already shipped; only the simultaneous-work half is
  two-level.** `docs/artifact-conventions.md` "Work item references" and
  "Sequence allocation" already nest to arbitrary depth, and `docs/workflow.md`
  "Dependencies and readiness" and "Derived state" are explicitly recursive. The
  remaining flat surfaces are the duplicate scan (`docs/workflow.md` "Multiple work
  items"), the merge-integrity invariant set and renumber procedure, the
  `conflicts-with` grammar's two-segment cap, and the shipper's plan-mode
  precondition.
- **The committed suite stays green.** `bash tests/run.sh` must pass at every
  step. The suite is read-only and **never reads live `work/**`**
  (`tests/README.md:30-31`), so a change here is validated against fixtures and
  live surfaces; committed recursive fixtures are Roadmap 5, not this roadmap.
- **Shipped work is context.** Items whose `ship.md` is present — including every
  `0011` and `0012` child — are out of scope for rewriting; children extend their
  decisions, do not re-open them.
- **Spent numbers are never reused.** `0010-recursive-plan-cycle`'s eight withdrawn
  children and every other spent prefix keep their numbers
  (`work/0010-recursive-plan-cycle/roadmap.md:152-221`).
- **Child numbers are local** to this parent and independent of the top-level
  sequence and of every other node.
- **The user owns the policy forks.** Whether cross-level (as opposed to
  sibling-only) declared conflicts are permitted; whether duplicate detection scans
  the whole tree or each node independently; and the exact recursive
  `conflicts-with` resolution precedence are user decisions owned by the relevant
  children below, not decided here.

## Children

| Local id | Title | Scope | Depends on | conflicts-with | Canonical reference |
| -------- | ----- | ----- | ---------- | -------------- | ------------------- |
| 0001-recursive-allocation | Per-level sequence allocation and duplicate detection | Generalize the allocation contract so a node at **any** depth allocates its children's local `MMMM` per its **immediate** parent, and define duplicate detection (`DUPLICATE-PREFIX`, `DUPLICATE-CHILD`) for a tree of arbitrary depth rather than only the top level plus one child layer — including how a collision introduced by a parallel merge is derived and named for a grandchild (depth ≥ 3). Author `docs/artifact-conventions.md` ("Sequence allocation") and `docs/workflow.md` ("Multiple work items"). Excludes the merge-time guard and the renumber procedure (`0002`) and declared conflicts (`0003`). Evidence: `docs/artifact-conventions.md` "Sequence allocation"; `docs/workflow.md` "Multiple work items"; `tests/checks/40-inventory.sh`. | — | docs/artifact-conventions.md, docs/workflow.md | 0013-simultaneous-work-recursion/0001-recursive-allocation |
| 0002-recursive-merge-integrity | Merge integrity and renumbering for recursive trees | Generalize the merge-conflict taxonomy (class (c) duplicate sequence number), the merge-integrity guard's invariant set (`DUPLICATE-PREFIX`, `DUPLICATE-CHILD`, `DANGLING-DEP`, `CYCLIC-DEP`, `MISSING-CHILD`, `UNLISTED-CHILD`, `DRIFT-FACT`) and its two enforcement points (`/status` and the `/ship` post-merge integrity pass) so they hold at **every** node of a recursive tree. Generalize `docs/artifact-conventions.md` "Renumbering after a parallel merge" so the detect/choose/renumber/update/record steps apply to a colliding grandchild at any depth, updating `feature:`, `parent:`, the owning manifest's `Children` canonical references, and any prose in the same change. Excludes the allocation contract itself (`0001`) and declared conflicts (`0003`). Evidence: `docs/workflow.md` "Merge conflicts" / "Merge-integrity guard"; `docs/artifact-conventions.md` "Renumbering after a parallel merge"; `.opencode/skill/merge-conflict/SKILL.md`. | 0001-recursive-allocation | docs/workflow.md, docs/artifact-conventions.md, .opencode/skill/merge-conflict/SKILL.md | 0013-simultaneous-work-recursion/0002-recursive-merge-integrity |
| 0003-recursive-conflicts | `conflicts-with` at every level | Generalize the declared-conflict target grammar from its current two-segment cap to a recursive path (`ConflictTarget`/`SiblingOrItemRef` gaining `( /[0-9]{4}-[a-z0-9-]+ )*`, and the same extension to the reference-vs-path discriminator), and generalize the read-only declared-conflict check's compared set, sibling-first resolution precedence, the own∪parent-cell union, and the `DRIFT-FACT` discrepancy rule to a tree of arbitrary depth (a decomposing child's own children are themselves entities). This is the one generalization the manifest template explicitly deferred (`docs/artifact-conventions.md`, manifest `conflicts-with` bullet). Author `docs/workflow.md` ("Declared conflicts (`conflicts-with`)", "Declared-conflict check") and the `docs/artifact-conventions.md` manifest `conflicts-with` bullet; keep the fixture-only `tests/checks/85-conflict-guards.sh` green. Excludes allocation (`0001`) and merge-time conflicts (`0002`). Evidence: `docs/workflow.md` "Declared conflicts (`conflicts-with`)", "Declared-conflict check"; `docs/artifact-conventions.md` (manifest `conflicts-with`); `tests/checks/85-conflict-guards.sh`; `tests/fixtures/declared-conflicts/`. | — | docs/workflow.md, docs/artifact-conventions.md | 0013-simultaneous-work-recursion/0003-recursive-conflicts |
| 0004-parallel-publication | Parallel plan publication under recursion | Generalize plan publication and the `/build` plan gate so an arbitrary-depth node publishes its own plan while another node publishes concurrently, without collision: verify and, where needed, replace the `plan/<ref>` branch naming under reference flattening (`/`→`-`) so a nested child and a distinct top-level item cannot share a branch name, and confirm each node's plan state (a decomposing node's manifest plus its own artifacts and child `.gitkeep`; a child's own plan) publishes independently. Reconcile the shipper's plan-mode precondition to admit a manifest-only plan. Author `docs/workflow.md` ("Plan publication", "The `/build` plan gate"); the broad agent/command surface sweep is Roadmap 4. Excludes allocation (`0001`), merge integrity (`0002`), and declared conflicts (`0003`). Evidence: `docs/workflow.md` "Plan publication", "The `/build` plan gate"; `.opencode/agent/shipper.md`; `.opencode/command/ship.md`. | — | docs/workflow.md, .opencode/agent/shipper.md | 0013-simultaneous-work-recursion/0004-parallel-publication |

## Sequencing

1. 0001-recursive-allocation
2. 0002-recursive-merge-integrity
3. 0003-recursive-conflicts
4. 0004-parallel-publication

`0001-recursive-allocation` is the foundation: the per-level allocation and
duplicate-detection contract must be fixed before the merge-time guard can check a
recursive tree's numbering, so `0002-recursive-merge-integrity` depends on it.
`0003-recursive-conflicts` and `0004-parallel-publication` have no unmet
prerequisite and may proceed in parallel with `0001`/`0002`; they are ordered
`0003`, `0004` here only to keep a stable reading order, since `0002`, `0003`, and
`0004` all edit `docs/workflow.md`.

### Multi-roadmap sequence

This is **Roadmap 3**. The successor roadmaps are authored by separate planning
invocations after the preceding stage ships:

1. **Roadmap 1 — `0011-recursive-bootstrap` (shipped).** The minimal recursive
   facility: model, schema, writer, readiness/status.
2. **Roadmap 2 — `0012-roadmap-deprecation` (shipped).** Retire `/roadmap` and its
   agent; make the generic manifest the sole enumeration source.
3. **Roadmap 3 — `0013-simultaneous-work-recursion` (this).** Allocation,
   duplicate detection, declared conflicts, merge integrity, renumbering, and
   parallel plan publication under recursion.
4. **Roadmap 4 — Agent, command, and inventory surface sweep.** Sweep every agent
   and command to the recursive model and reconcile documented inventories.
5. **Roadmap 5 — Committed recursive-workflow guards.** Fixture-based guards
   pinning the recursive model, references, allocation, readiness, status, and
   conflicts.

Cross-roadmap ordering is **not** encoded as a dependency (dependencies are
sibling-only within a node); it is recorded here as prose and re-derived when each
successor is authored.

## Open issues

- **Single-feature check.** The initiative is genuinely multi-feature — allocation
  and duplicate detection, merge integrity and renumbering, declared conflicts at
  every level, and parallel plan publication — so a decomposing node is the right
  vehicle rather than a standalone `/spec`.
- **Re-homes a withdrawn child; no number reuse.** This is the scope of
  `0010-recursive-plan-cycle/0006-simultaneous-work`, withdrawn on 2026-10-12 and
  preserved as a `.gitkeep`-only directory
  (`work/0010-recursive-plan-cycle/roadmap.md:190-196`). Its directory and spent
  local number `0006` are **not** reused, and `0010` remains a superseded
  container; this roadmap is a fresh top-level node.
- **No duplicate node.** Recon of `work/` found twelve top-level items
  (`0001`–`0012`); the shipped nodes nearest this scope are
  `0005-merge-conflict-workflow`, `0006-parallel-plan-conflicts`, and
  `0003/0002-readiness-ship-state`, but none generalizes simultaneous work to
  arbitrary depth — they settled the two-level model this roadmap extends.
  Recorded so the choice of a new top-level node rather than a nested child is
  explicit.
- **Boundary with Roadmap 4 (surface sweep).** The broad agent/command/inventory
  sweep is Roadmap 4. This roadmap touches only the surfaces its four features
  require — notably `docs/workflow.md`, `docs/artifact-conventions.md`,
  `.opencode/agent/shipper.md`, and `.opencode/command/ship.md` — and adds no
  general agent sweep of its own. The boundary is recorded so scope is not
  silently widened.
- **Boundary with Roadmap 5 (committed guards).** Fixture-based committed guards
  pinning the recursive workflow are Roadmap 5. This roadmap keeps the existing
  committed fixtures green (`tests/checks/40-inventory.sh`,
  `80-cycle-fixture.sh`, `85-conflict-guards.sh`, `87-backtrack-guards.sh`,
  `96-signature-sweep.sh`) but adds no new fixture area of its own.
- **Shipped-work overlap is extend-only.** `0001`–`0004` extend the roadmap
  schema, allocation, readiness, merge-integrity, declared-conflict, and
  plan-publication surfaces settled by `0002-agentic-roadmaps`,
  `0003/0002-readiness-ship-state`, `0005`, `0006`, and `0007`; they must extend
  and reference those decisions, not fork them.
- **Unresolved user decision — cross-level declared conflicts.** Whether
  `conflicts-with` may name a target outside the sibling scope (an ancestor,
  descendant, or cross-tree item) or stays sibling-scoped plus surfaces at every
  level materially changes the check's compared set; owned by
  `0003-recursive-conflicts`.
- **Unresolved user decision — duplicate-detection scope.** Whether duplicate
  detection scans the whole tree from the root or each node independently (and how
  a `DUPLICATE-PREFIX`/`DUPLICATE-CHILD` is attributed and named at depth) is owned
  by `0001-recursive-allocation`/`0002-recursive-merge-integrity`.
- **Unresolved user decision — branch-naming collision policy.** Whether the
  `plan/<ref>` flattening is replaced (for example, a reversible encoding) or the
  collision is merely detected and refused is owned by `0004-parallel-publication`.
- **Advisory conflicts are intentional.** The rows declare shared authority
  surfaces (`docs/workflow.md`, `docs/artifact-conventions.md`,
  `.opencode/skill/merge-conflict/SKILL.md`, `.opencode/agent/shipper.md`) in
  `conflicts-with`. The read-only declared-conflict check will therefore report
  `TEXTUAL-CONFLICT` pairs among this node's own children; this is intentional —
  independent siblings that edit the same authority docs — and is advisory only,
  changing no `Depends on` edge and no child's readiness.
- **Cycle check.** The stored `Depends on` graph is acyclic by construction
  (`0001`→`0002`; `0003`, `0004` independent); no `CYCLIC-DEP` is expected.
  Recorded because the planning step never stores a cycle.
- **One create call, one parent.** This node was authored as a single top-level
  decomposing node (the next top-level `0013`); Roadmaps 4–5 remain separate later
  invocations. Recorded so the staging is explicit rather than silently absent.
