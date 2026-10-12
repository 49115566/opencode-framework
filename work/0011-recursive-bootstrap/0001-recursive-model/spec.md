---
feature: 0011-recursive-bootstrap/0001-recursive-model
phase: spec
status: final
created: 2026-10-12
updated: 2026-10-12
notes: "Nested roadmap child; the directory held only .gitkeep and its scope is the parent roadmap's keystone child (work/0011-recursive-bootstrap/roadmap.md:103), so the roadmap supplies the requirements. Depends on: —, so the child is ready and no override is needed. User resolved the five model forks: (1) recursion depth is unbounded; (2) the recursive decomposition writer is `/plan` (architect), with `/roadmap` retained as a thin deprecated alias until a successor roadmap retires it; (3) fine-grained `tasks.md` entries stay tasks, not child nodes; (4) a node may be a hybrid carrying its own phase artifacts and children; (5) the model vocabulary is work item / node / leaf / decomposition / plan, with `roadmap` a deprecated alias."
parent: 0011-recursive-bootstrap
---

# Recursive lifecycle model

## Problem

The framework's lifecycle is single-level with a bolt-on two-level exception. A
work item is one feature with one `spec.md`/`design.md`/`tasks.md`, and a
multi-feature request must first be planned through a separate **roadmap**
facility that adds a parent `roadmap.md` plus nested children
(`docs/workflow.md:62-75`); nesting is capped at `NNNN-slug/MMMM-slug`
(`docs/artifact-conventions.md:68-98`). The cap creates a structural dead end: a
node is either a roadmap parent (no lifecycle of its own, `docs/workflow.md:64-70`)
or a feature leaf (no children), so **"a child that is itself an initiative" has
no representation at all**. The cost is concrete and already paid: when this
initiative was first planned, its eight children were realistically
sub-initiatives rather than single features and the whole plan had to be withdrawn
and re-homed (`work/0010-recursive-plan-cycle/roadmap.md:152-208`,
`work/0011-recursive-bootstrap/roadmap.md:20-31`). The very facility needed to
plan a recursive model cannot be expressed with the tooling that exists. Two
audiences pay for the gap: **framework maintainers**, who must over-scope or
improvise when a unit of work is larger than a feature, and **adopters**, who
inherit a lifecycle that is uniform for one level and special-cased for the next.
What is missing is a single recursive **model** — stated once as the authority —
that the schema, writer, and status phases can then implement.

## Goals

- Define the recursive lifecycle model as the single authority: the standard
  six-phase cycle applies **uniformly at every node**, with no special roadmap
  concept at the model level.
- Remove the two-level cap in the model: recursion depth is **unbounded**; any
  node may decompose into children.
- Fix the model vocabulary — **work item**, **node**, **leaf**, **decomposition**,
  **plan** — and demote `roadmap` to a deprecated alias for a decomposing node.
- Allow **hybrid** decomposition: a plan may contain a mix of tasks, features,
  initiatives, and larger items, and a node may carry its own phase artifacts and
  a child set at the same time.
- Fix **where decomposition is authored and recorded**: in the planning (design)
  step, with `/roadmap` a deprecated alias for that step; leave the concrete
  writer's wiring to a sibling.
- State that fine-grained `tasks.md` entries remain tasks and are **not** nodes.
- State how a node's own phase artifacts relate to its children.
- Compose cleanly with the shipped backtracking/re-entry rules (reuse the model,
  introduce no second state model).
- Preserve backward compatibility: a one-segment standalone item behaves exactly
  as before, and existing committed `work/` content needs no migration.
- Keep the committed suite green and the documented inventories unchanged.

## Non-goals

- The concrete recursive writer — its command/agent wiring, its handoff, and its
  implementation — owned by `0003-recursive-writer`.
- The reference grammar, per-level sequence allocation, the frontmatter `parent`
  chain, the child-enumeration artifact ("manifest") representation, and
  `.gitkeep` reservation at each level — owned by `0002-recursive-schema`.
- Readiness, derived state, the phase/progress derivation of a node from its
  children, and the `/status` tree report — owned by `0004-recursive-readiness`.
- Deprecating or removing `/roadmap` and `roadmap.md` and migrating existing
  roadmap parents (including `0010` and `0011`) — a successor roadmap (Roadmap 2
  in `work/0011-recursive-bootstrap/roadmap.md:133-136`).
- Simultaneous-work guarantees under recursion: per-level duplicate detection,
  `conflicts-with` at every level, merge integrity and renumbering for recursive
  trees — a successor roadmap.
- The agent/command/inventory surface sweep — a successor roadmap.
- Committed fixtures, agreement areas, and mutation coverage pinning the model —
  a successor roadmap.
- A new runtime dependency, service, network access, or toolchain.
- A second state model, reference grammar, conflict taxonomy, or finding/
  severity vocabulary; the model reuses the shipped ones.
- Any change to the shipped decisions or artifacts of `0002-agentic-roadmaps`,
  `0003-framework-quality-hardening`, `0005-merge-conflict-workflow`,
  `0006-parallel-plan-conflicts`, or `0007-phase-backtracking`.
- Automatic orchestration, scheduling, delivery dates, or parallel-agent
  execution.

## Users and stories

- **As a** framework maintainer planning a large initiative, **I want** to
  recursively decompose it until every leaf is independently specifiable,
  buildable, and reviewable, **so that** I no longer over-scope children or
  invent sub-initiatives the two-level model cannot represent.
- **As a** framework maintainer, **I want** the standard six-phase cycle to apply
  uniformly at every node, **so that** I learn and maintain one model instead of a
  special roadmap concept.
- **As a** plan author, **I want** a single planning step where decomposition is
  authored and recorded, **so that** I know where a node's children come from.
- **As a** framework maintainer, **I want** a node to be able to carry its own
  phase artifacts and children at the same time, **so that** a hybrid
  feature/initiative is representable.
- **As an** adopter, **I want** a one-segment standalone item to behave exactly
  as before and the model to reuse the shipped backtracking vocabulary, **so
  that** existing work and tooling keep working and I do not learn a second model.

## Acceptance criteria

1. **AC1** — Given the workflow authority, when a reader looks up the lifecycle,
   then it states that the standard six-phase cycle applies uniformly at every
   node of a recursive plan, and it defines the model's core terms as: a **node**
   is any work item in the tree, a **leaf** is a node with no children, and a
   **decomposition** is a node's enumerated child set.

2. **AC2** — Given the workflow authority, when recursion depth is read, then the
   model imposes no maximum depth: any node may decompose into children, and both
   a one-segment standalone item and a nested child are valid instances of the
   same model.

3. **AC3** — Given the workflow authority, when where decomposition is authored
   and recorded is read, then it states that a node's child set is authored and
   recorded in the planning (design) step, that `/roadmap` is a deprecated alias
   for that step, and that a decomposing node's child set is committed plan state;
   the concrete writer's command/agent wiring is left to `0003-recursive-writer`.

4. **AC4** — Given a node, when its granularity is read, then a plan may decompose
   into a hybrid of tasks, features, initiatives, and larger items; fine-grained
   `tasks.md` entries remain a leaf's internal work list and are not themselves
   nodes unless a planner explicitly decomposes an item into children.

5. **AC5** — Given a node that has children, when its own lifecycle is read, then
   the model permits a hybrid: a node may carry its own phase artifacts and a
   child set at the same time, the standard cycle applies to the node's own
   artifacts independently of its children, and no node is required to be a pure
   container.

6. **AC6** — Given the model's vocabulary, when the terms are read, then they are
   stated once as the single authority — work item, node, leaf, decomposition,
   plan — and `roadmap` is defined only as a deprecated alias for a decomposing
   node; no surface states a competing definition.

7. **AC7** — Given the shipped backtracking and re-entry model, when the
   recursive model composes with it, then the reverse edges, `stale:` marking,
   re-entry, recall, and the ownership invariant apply per node on the same
   unshipped work item; the recursive model introduces no second state model, no
   new `phase` value, and no new reversal mechanism for a decomposition.

8. **AC8** — Given the shipped `Depends on`/readiness and declared-conflict
   vocabulary, when the recursive model refers to them, then it reuses them
   without change (readiness and reporting rules remain owned by
   `0004-recursive-readiness`; the reference grammar by `0002-recursive-schema`);
   the model adds no new dependency edge, conflict class, or state vocabulary.

9. **AC9** — Given a one-segment standalone work item, when the model is applied,
   then it behaves exactly as before with no forced migration, and existing
   committed `work/` content — including today's roadmap parents and their nested
   children — remains valid under the model.

10. **AC10** — Given the repository surfaces, when the model is authored, then the
    workflow authority states the recursive model once as its single authority and
    `AGENTS.md` cross-references it; no other surface states a conflicting
    recursive rule.

11. **AC11** — Given the repository after the change, when the project's
    configured test command runs, then it passes; no new command, agent, or skill
    is introduced, no documented inventory count changes, and the six core phase
    commands, the `phase` value set, and the `Depends on`/readiness and
    declared-conflict contracts are unchanged.

## Edge cases

- **A leaf is a valid terminal.** A node with no children (today's standalone
  item or nested feature) is a leaf; nothing requires decomposition.
- **Pure container.** A node with a child set and no phase artifacts of its own
  (today's roadmap parent) is valid; how its progress derives is owned by
  `0004-recursive-readiness`.
- **Own artifacts, no children.** A node with `spec.md`/`design.md`/`tasks.md` and
  no children is an ordinary work item.
- **Deep chain.** A chain of single-child decompositions is permitted; unbounded
  depth means the model sets no special behavior at any depth.
- **Self-containment.** A node's decomposition may not reach the node itself; the
  decomposition tree is acyclic.
- **Thick hybrid.** A node may carry its own in-progress artifacts while its
  children are at different phases; the model fixes the relationship, not the
  derivation rule.
- **Task mistaken for a node.** A `tasks.md` entry is not a node (AC4); to create
  a child, a planner decomposes an item, not a task.
- **Backtrack on a decomposing node.** A later phase that finds the decomposition
  wrong routes to the planning phase through the shipped reverse-edge model; no
  new mechanism is defined.
- **Shipped node.** An item whose `ship.md` is present is out of scope for
  re-scoping or re-sequencing; children extend its decisions and do not reopen
  them.
- **Historical roadmap parent.** A committed `roadmap.md` remains a valid
  decomposing node; `roadmap` is a deprecated alias, not an invalid artifact.
- **Parallel nodes.** A decomposition touches only its own item's committed state
  and changes no other item's readiness.
- **No convergence requirement.** The model does not force a depth; a plan is
  expected to converge to independently workable leaves by the planner's
  judgment, not by a model rule.

## Open questions

- [x] **Recursion depth** — resolved (user): unbounded. No maximum depth; any node
  may decompose.
- [x] **Writer surface** — resolved (user): `/plan` (`architect`) authors
  decomposition; `/roadmap` is retained as a thin deprecated alias. No new
  command, so no inventory change.
- [x] **Task vs. node granularity** — resolved (user): fine-grained `tasks.md`
  entries stay tasks, not nodes; a node may be a hybrid.
- [x] **Node lifecycle** — resolved (user): hybrid allowed — a node may carry its
  own phase artifacts and children.
- [x] **Vocabulary** — resolved (user): work item / node / leaf / decomposition /
  plan; `roadmap` is a deprecated alias for a decomposing node.
- [ ] **Deferred — concrete representation of the child set.** The manifest
  artifact, the recursive reference grammar, per-level sequence allocation, and
  the `parent` chain are fixed by `0002-recursive-schema`, not here; this item's
  design consumes them. — owner: `0002-recursive-schema`, needed by: `0002` design.
- [ ] **Deferred — progress/derived-state derivation.** How a parent node's phase
  and progress derive from its children (and the reverse), and how `/status`
  reports an arbitrary-depth tree, are fixed by `0004-recursive-readiness`. —
  owner: `0004-recursive-readiness`, needed by: `0004` design.

## Dependencies and constraints

- **Ready.** The parent roadmap lists this child as `Depends on: —`
  (`work/0011-recursive-bootstrap/roadmap.md:103`), so it is ready and no override
  is needed.
- **Keystone.** `0002-recursive-schema`, `0003-recursive-writer`, and
  `0004-recursive-readiness` all consume the model fixed here, so it must be final
  before they plan (`work/0011-recursive-bootstrap/roadmap.md:115-123`).
- **Deliverable surfaces.** Per the child scope, the model contract is authored in
  the workflow authority and cross-referenced from `AGENTS.md`
  (`work/0011-recursive-bootstrap/roadmap.md:103`). Because the deliverable is the
  framework's own documents, the acceptance criteria name the surfaces that must
  carry the model; they specify required content, not implementation choices.
- **Extend, do not fork.** The model generalizes the shipped mental model
  (`docs/workflow.md:8-60`), the roadmap parent/leaf split
  (`docs/workflow.md:62-75`), the reference grammar (`docs/artifact-conventions.md:68-98`),
  the readiness algorithm (`docs/workflow.md:77-115`), the declared-conflict check
  (`docs/workflow.md:553-679`), the backtracking/re-entry model
  (`docs/workflow.md:680-937`), and the derived-state table
  (`docs/workflow.md:1033-1104`). It defines no second state model, reference
  grammar, conflict taxonomy, or finding vocabulary.
- **Committed-suite constraints.** `tests/checks/20-lifecycle.sh` pins the six core
  phase commands, the command→agent pairs, the derived-state routing literals, and
  the core artifact names across `AGENTS.md`, the workflow authority, the README,
  and the `workflow-lifecycle` skill; `tests/checks/40-inventory.sh` pins the README
  layout counts and command/agent inventories; the suite never reads live `work/**`
  (`tests/README.md:30`). This item must keep those green.
- **No migration.** Existing `work/` content, including roadmap parents and nested
  children, stays valid; the chosen writer surface introduces no new command and
  changes no documented count.
- **Sibling boundaries.** The schema/reference/allocation is `0002`; the concrete
  writer is `0003`; readiness/derived-state/status is `0004`; roadmap deprecation
  and migration, simultaneous-work guarantees, the surface sweep, and committed
  guards are successor roadmaps. This item fixes only the model they consume.
- **Assumption — recursion terminates by planning judgment.** The model is
  unbounded, but a plan is expected to reach independently workable leaves; no
  mechanical depth rule enforces convergence.
- **Framework-internal change only.** Docs and prompts; no runtime dependency,
  service, or new toolchain.
