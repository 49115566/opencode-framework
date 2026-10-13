---
feature: 0011-recursive-bootstrap/0004-recursive-readiness
phase: spec
status: final
created: 2026-10-12
updated: 2026-10-12
notes: "Nested roadmap child of 0011-recursive-bootstrap; the directory held no .gitkeep yet and the parent roadmap supplies the requirements (work/0011-recursive-bootstrap/roadmap.md:106). Both dependencies are satisfied — 0001-recursive-model and 0002-recursive-schema each have a ship.md with no reopened: marker — so the child is ready; no override is needed. User resolved the five readiness/derived-state forks: (1) `Depends on` stays sibling-only at every level — no ancestor/descendant/cousin or cross-tree edges; (2) a node's phase derives from its own phase artifacts first, falling back to the container phase `roadmap` only when it has a manifest and no own artifacts; (3) a decomposing dependency target is satisfied by its own ship/approve signal only, with no recursive propagation; (4) /status renders an indented recursive tree to arbitrary depth with ready/blocked at every level; (5) the change set is docs/workflow.md plus .opencode/agent/status.md, with the minimal .opencode/command/status.md and workflow-lifecycle skill restatements needed to avoid a contradiction — the broad surface sweep stays in Roadmap 4."
parent: 0011-recursive-bootstrap
---

# Readiness, derived state, and status across recursion

## Problem

`0001-recursive-model` permits a plan to decompose into children to unbounded
depth and `0002-recursive-schema` gives every node at every depth a canonical
reference, a manifest, and per-level numbering — but the two authority surfaces
that say *what state a node is in and whether it can start* still describe a
single-level tree with one two-level exception. Readiness is defined only for a
roadmap parent's immediate children, with `Depends on` cells that name only
siblings in that one `Children` table (`docs/workflow.md` → "Dependencies and
readiness"); the derived-state table resolves a node by artifact presence and
treats any directory containing a manifest as a `roadmap` parent, with no rule
for a node that carries its own artifacts *and* children
(`docs/workflow.md` → "Derived state"); and `/status` and the `status` agent
render one parent and its immediate children, never descending further
(`.opencode/agent/status.md`). The cost is concrete: a node at depth three or
deeper has **no defined readiness computation**, a hybrid node's own phase is
**masked by its manifest**, and a maintainer running `/status` sees the **top of
the tree only**, so a genuinely nested decomposition cannot be tracked at all.
Two audiences pay: **framework maintainers**, who cannot tell whether a deep
node is ready or blocked, and **adopters**, who inherit a model that promises
recursion while the reporting surfaces stop at two levels.

## Goals

- Generalize **readiness** to a recursive tree: every level applies the shipped
  readiness rule independently, with `Depends on` remaining sibling-only (no
  cross-level or cross-tree dependency edges introduced).
- Define how readiness treats a dependency whose target is itself a decomposing
  node, without forking the shipped satisfaction signal.
- Generalize the **derived phase** of a node that has children: its own phase
  artifacts take precedence, and the container phase `roadmap` applies only to a
  node with a manifest and no own phase artifacts.
- Extend the **derived-state table** with that recursive rule while preserving
  the shipped precedence — `stale:`/`reopened:`/open-challenge conditions first,
  then the artifact-presence and verdict rows — and introducing no new `phase`
  value.
- Define a **`/status` report of arbitrary depth**: an indented recursive tree
  with each node's derived phase and its readiness (`ready`/`blocked`) at every
  level, and a `<ready>/<total> ready` rollup plus phase distribution at each
  decomposing node.
- Keep the change coherent across the surfaces that restate readiness or derived
  state, so no live surface contradicts the authority.
- Preserve backward compatibility: a one-segment standalone item and every
  existing two-level roadmap parent/child derive and report exactly as before,
  with no forced migration.
- Keep the committed suite green and every documented inventory count unchanged.

## Non-goals

- **Cross-level or cross-tree dependency edges.** `Depends on` stays sibling-only
  in the same `Children` table (resolved); permitting any other target would add
  a dependency edge kind the model forbids.
- **Recursive readiness propagation.** A decomposing dependency target is
  satisfied by its own shipped/approved signal only; readiness does not recurse
  through its descendants (resolved).
- **A rollup phase for a pure container.** A container's derived phase is the
  shipped `roadmap` label, not a function of its children's phases (resolved).
- The concrete recursive decorative writer — its command/agent wiring and
  handoff — owned by `0003-recursive-writer`.
- The reference grammar, per-level sequence allocation, the frontmatter `parent`
  chain, and the manifest representation — owned by `0002-recursive-schema`.
- Generalizing `conflicts-with` targets to arbitrary depth ("`conflicts-with` at
  every level"), recursive-tree duplicate detection, merge integrity, and
  renumbering — a successor roadmap (Roadmap 3).
- Deprecating or removing `/roadmap` and `roadmap.md` and migrating existing
  roadmap parents (including `0010` and `0011`) — a successor roadmap
  (Roadmap 2).
- The broad agent/command/inventory **surface sweep** — a successor roadmap
  (Roadmap 4); this item touches only the surfaces needed for readiness/derived
  state/status coherence.
- Committed recursive-readiness fixtures, agreement areas, or mutation
  coverage — a successor roadmap (Roadmap 5); the committed suite stays green as
  a constraint, not a deliverable.
- A new runtime dependency, service, network access, or toolchain.
- A second state model, readiness algorithm, derived-state vocabulary,
  dependency edge kind, conflict taxonomy, or finding/severity vocabulary; this
  item reuses the shipped ones.
- Any change to the shipped decisions or artifacts of the framework items this
  initiative extends.
- Automatic orchestration, scheduling, delivery dates, or parallel-agent
  execution.

## Users and stories

- **As a** framework maintainer, **I want** readiness to be computed the same
  way at every level of a recursive plan, **so that** I can tell whether a node
  at any depth is ready to start without inventing a per-level rule.
- **As a** framework maintainer tracking a nested decomposition, **I want**
  `/status` to show the whole tree with each node's phase and readiness, **so
  that** I can see where the work stands without reading directories by hand.
- **As a** plan author, **I want** a hybrid node's own phase to be visible
  rather than hidden behind its manifest, **so that** a node's own progress is
  not conflated with its children's.
- **As an** adopter, **I want** existing one-segment items and two-level roadmap
  parents to derive and report exactly as before and the shipped readiness
  vocabulary to be reused, **so that** adopting recursion requires no migration
  and no second state model.

## Acceptance criteria

1. **AC1** — Given a manifest at any depth, when its `Depends on` cells are
   resolved, then each names only a sibling local id in the same `Children`
   table; an ancestor, descendant, cousin, or cross-tree target is not a valid
   dependency, and no new dependency edge kind is introduced.

2. **AC2** — Given a decomposing node, when each child's readiness is derived,
   then the child is `ready` when every sibling it depends on is satisfied and
   the child is not in a cycle, and `blocked` naming the specific unsatisfied
   sibling(s) otherwise, exactly as the shipped readiness rule; every level of
   the tree applies the same rule independently.

3. **AC3** — Given a `Depends on` target that is itself a decomposing node, when
   its satisfaction is computed, then it is satisfied if and only if its own
   shipped signal holds — its `ship.md` is present with no `reopened:` marker, or
   its `review.md` verdict is `approve` — and its descendants are not consulted
   (no recursive propagation).

4. **AC4** — Given a node that has children, when its phase is derived, then its
   own phase artifacts take precedence: a node carrying its own phase artifacts
   derives its phase from them, and only a node with a manifest and no own phase
   artifacts derives the container phase `roadmap`.

5. **AC5** — Given the derived-state authority, when the recursive rule is read,
   then the shipped precedence is unchanged — structural `stale:` and
   `reopened:` conditions, then the unshipped open-challenge blocked overlay,
   then the phase rows — and the own-artifacts-first/manifest-fallback rule
   composes with it introducing no new `phase` value and no second state model.

6. **AC6** — Given a `work/` tree nested to any depth, when `/status` runs, then
   it renders each decomposing node followed by its descendants indented to
   arbitrary depth, and every node at every level shows its derived phase and its
   readiness as `ready` or `blocked: <local ids>`.

7. **AC7** — Given a decomposing node, when its row is rendered, then it shows
   `<ready>/<total> ready` across its immediate children plus a distribution
   tally of those children across phases (`<phase> <n>, ...`), and each blocked
   child names the specific siblings that block it; readiness is derived live and
   never stored.

8. **AC8** — Given the shipped readiness algorithm and derived-state vocabulary,
   when the recursive generalization is authored, then it reuses them and adds no
   second state model, no new `phase` value, no new dependency edge kind, and no
   new finding or severity vocabulary.

9. **AC9** — Given a one-segment standalone item or an existing two-level roadmap
   parent/child, when the recursive readiness and derived-state rules are
   applied, then it derives and is reported exactly as before with no migration,
   and the shipped derived labels, readiness literals, and pinned contract text
   remain valid.

10. **AC10** — Given the change set, when its scope is inspected, then the
    recursive readiness and derived-state rules are stated once in the workflow
    authority and the status agent defers to that authority; the corresponding
    status command and the lifecycle-skill restatement are the only other
    surfaces updated and no live surface states a competing readiness or
    derived-state rule; the broad agent/command sweep is left to a successor
    roadmap.

11. **AC11** — Given the repository after the change, when the project's
    configured test command runs, then it passes; no new command, agent, or skill
    is introduced; no documented inventory count changes; and the readiness
    algorithm marker and the derived-state routing literals stay single-sourced
    and unchanged.

## Edge cases

- **Pure container.** A node with a manifest and no own phase artifacts derives
  the container phase `roadmap`; its children are reported beneath it with their
  own phases and readiness (AC4, AC6).
- **Hybrid node.** A node carrying its own artifacts and a manifest derives its
  phase from its own artifacts, independently of its children; its child rollup
  is still reported (AC4, AC7).
- **Deep chain.** A chain of single-child decompositions is tracked at every
  level; each level's readiness is computed independently and no depth has
  special behavior.
- **`.gitkeep`-only child.** A reserved child holding only `.gitkeep` derives
  `not started` (unchanged) and is `ready` unless it depends on an unsatisfied
  sibling.
- **No dependencies.** A node whose `Depends on` is empty is `ready`.
- **Cycle within a manifest.** A cyclic sibling graph is reported and its members
  are never `ready` (shipped behavior); since edges are sibling-only, no
  cross-level cycle exists to detect.
- **Recalled dependency.** A sibling whose `ship.md` carries a `reopened:` marker
  does not satisfy a dependent, and the dependent is reported `blocked`, naming
  the recalled sibling, until it re-ships (unchanged).
- **Decomposing dependency, unshipped and unapproved.** A decomposing target
  with neither `ship.md` nor an `approve` verdict is not satisfied even if all of
  its children are complete, because its own signal is the sole satisfaction
  (AC3).
- **Decomposing dependency approved mid-children.** A decomposing target with an
  `approve` verdict and in-progress children is satisfied (own signal only).
- **Cross-level target attempted.** A `Depends on` value naming a non-sibling is
  not a valid edge; it is reported as a dangling/unresolvable reference by the
  shipped integrity window rather than silently accepted (AC1).
- **Empty `work/` tree.** `/status` reports that no items exist and recommends
  `/spec` (unchanged).
- **Standalone leaf.** A one-segment item with no children renders as a single
  row with `checked/total` task progress, exactly as before (AC9).
- **Concurrent/parallel nodes.** Deriving and reporting one node's readiness
  reads only committed files and changes no other node's state; `/status` stays
  read-only and local-only.

## Open questions

- [x] **Cross-level dependencies** — resolved (user): sibling-only at every
  level; no ancestor/descendant/cousin or cross-tree edges.
- [x] **Decomposing-node phase derivation** — resolved (user): own phase
  artifacts first; a manifest with no own artifacts derives `roadmap`.
- [x] **Decomposing dependency target** — resolved (user): satisfied by its own
  ship/approve signal only; no recursive propagation.
- [x] **Status report shape** — resolved (user): an indented recursive tree to
  arbitrary depth with ready/blocked at every level.
- [x] **Affected surfaces** — resolved (user): the workflow authority and the
  status agent, plus the minimal status-command and lifecycle-skill restatements
  needed for coherence.
- [ ] **Deferred — `conflicts-with` targets at arbitrary depth and recursive-tree
  duplicate detection/renumbering.** Roadmap 3's concern. — owner: Roadmap 3
  (simultaneous work under recursion), needed by: Roadmap 3 `/spec`.
- [ ] **Deferred — roadmap deprecation and migration, including the treatment of
  `0010` and `0011`.** Roadmap 2's concern. — owner: Roadmap 2 (roadmap
  deprecation and migration), needed by: Roadmap 2 `/spec`.
- [ ] **Deferred — the broad agent/command/inventory surface sweep.** This item
  updates only the status-relevant surfaces; every other agent, command, and
  skill is Roadmap 4's concern. — owner: Roadmap 4, needed by: Roadmap 4 `/spec`.
- [ ] **Deferred — committed recursive-readiness guards and fixtures.** The
  committed suite stays green as a constraint; pinning the recursive readiness
  and derived-state rules with fixtures is Roadmap 5's concern. — owner:
  Roadmap 5, needed by: Roadmap 5 `/spec`.

## Dependencies and constraints

- **Ready.** The parent roadmap lists this child as `Depends on:
  0001-recursive-model, 0002-recursive-schema`
  (`work/0011-recursive-bootstrap/roadmap.md:106`); both siblings are shipped
  (`.../0001-recursive-model/ship.md` and `.../0002-recursive-schema/ship.md`
  present, no `reopened:` marker), so both dependencies are satisfied and no
  override is needed.
- **Consumes the model and schema.** The recursive vocabulary, unbounded depth,
  hybrid nodes, and "readiness/derived-state/reporting is `0004`'s concern" are
  fixed by `0001-recursive-model`; the recursive reference grammar, per-level
  allocation, frontmatter `parent` chain, and the manifest at every depth are
  fixed by `0002-recursive-schema`. This item turns those into readiness,
  derived state, and a status report.
- **Deliverable surfaces.** Per the child scope, readiness and derived state are
  authored in the workflow authority (`docs/workflow.md` → "Roadmaps" →
  "Dependencies and readiness" and "Derived state") and the `status` agent
  (`.opencode/agent/status.md`) is generalized; the corresponding
  `.opencode/command/status.md` and the `workflow-lifecycle` skill are updated
  only as needed so no surface contradicts the authority
  (`work/0011-recursive-bootstrap/roadmap.md:106`). Because the deliverable is
  the framework's own documents and prompts, the acceptance criteria name the
  required behavior, not implementation choices.
- **Extend, do not fork.** The readiness algorithm
  (`docs/workflow.md` → "Dependencies and readiness"), the derived-state
  precedence and labels (→ "Derived state"), the readiness revocation of a
  recalled `ship.md`, and the `CYCLIC-DEP`/`DANGLING-DEP` reporting vocabulary
  are reused unchanged. This item defines no second state model, no new `phase`
  value, and no new dependency edge kind.
- **Single-source guards must stay green.** `tests/checks/10-readiness.sh`
  requires the algorithm marker `satisfied(dep_local_id):` to appear exactly
  once, in the workflow authority; `tests/checks/20-lifecycle.sh` pins the
  derived-state routing literals and core artifact names;
  `tests/checks/80-cycle-fixture.sh` pins the cycle rule;
  `tests/checks/85-conflict-guards.sh` scopes the conflict vocabulary to the
  declared-conflict authority; `tests/checks/87-backtrack-guards.sh` pins the
  derived labels `P (backtracked)`, `P (reopened)`, `challenged (blocked)`,
  `build (rework)`, and the `stale:`/`reopened:` markers;
  `tests/checks/96-signature-sweep.sh` pins command signatures and phase
  headings. This item restates none of those pinned literals and keeps them
  green.
- **The suite never reads live `work/**`.** The committed suite is read-only and
  fresh-clone-clean (`tests/README.md:30-31`); committed recursive-readiness
  guards are deferred to a successor roadmap, so this item adds no test file.
- **Sibling boundaries.** The concrete recursive writer is
  `0003-recursive-writer`; roadmap deprecation/migration, every-level conflicts
  and recursive-tree duplicate handling, the surface sweep, and committed guards
  are successor roadmaps. This item fixes only readiness, derived state, and the
  status report they feed.
- **Backward compatibility.** A one-segment standalone item and every existing
  committed two-level roadmap parent/child remain valid and derive/report
  unchanged; no migration, rename, or spent-number change occurs
  (`work/0011-recursive-bootstrap/roadmap.md:83-85`).
- **Assumption — the bootstrap child is a single feature.** Sibling-only
  readiness, decomposing-node phase derivation, and an arbitrary-depth status
  report are one coherent change, specifiable and reviewable on its own; if it
  proves too large at `/spec`, the roadmap's sanctioned remedy is
  `/roadmap revise 0011-recursive-bootstrap` to add siblings at the same level,
  not to nest.
- **Framework-internal change only.** Docs and prompts; no runtime dependency,
  service, network access, or new toolchain. No file under another phase is
  edited.
