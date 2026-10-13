---
feature: 0011-recursive-bootstrap/0003-recursive-writer
phase: spec
status: final
created: 2026-10-12
updated: 2026-10-12
notes: "Nested roadmap child; the directory held only .gitkeep and the parent roadmap supplies the requirements (work/0011-recursive-bootstrap/roadmap.md:105), so no standalone reference allocation is made. Dependencies 0001-recursive-model and 0002-recursive-schema are both satisfied (each ship.md present with no reopened: marker, no open finding in backtracks.md), so the child is ready and no override is needed. User resolved the four writer forks explicitly deferred from 0001 (docs/workflow.md:72-74): (1) the writer authors AND revises a decomposition at any depth; (2) the writer surface is the planning step — `/plan` (architect) authors, with `/roadmap` retained as a thin deprecated alias (a new top-level node via `/roadmap <initiative>`, revision via `/roadmap revise <item-ref>`), adding no new command; (3) a decomposing node always gets the manifest and MAY also carry its own design.md/tasks.md (hybrid) — never forced on a pure container; (4) the handoff publishes the node's plan state via `/ship plan <item-ref>` and then routes to `/spec <child-ref>` for each ready child."
parent: 0011-recursive-bootstrap
---

# Recursive decomposition writer

## Problem

`0001-recursive-model` fixed the model — a node at any depth may decompose into
children, and the six-phase cycle applies uniformly at every node — and
`0002-recursive-schema` fixed how a decomposition is represented: a recursive
canonical reference, per-level `MMMM` allocation, and the manifest
(`roadmap.md`, `phase: roadmap`) as the child-enumeration source **at every
depth** (`docs/artifact-conventions.md:124-137`, `:73-100`). Both explicitly
deferred the concrete writer: "The concrete writer's command/agent wiring and
handoff are owned by `0003-recursive-writer`" (`docs/workflow.md:72-74`).

The writer that exists cannot do this. Today the child-enumeration capability
lives only in the `/roadmap` create/revise command and the `roadmap` agent
(`.opencode/command/roadmap.md:18-55`, `.opencode/agent/roadmap.md:28-42`), and both
modes act **only on a top-level parent**: create mode allocates one top-level
`NNNN` and writes `work/<NNNN-slug>/roadmap.md`, and revise mode refuses any
`<item-ref>` that is not a roadmap parent
(`.opencode/agent/roadmap.md:67-69,126-128`). So a node that sits at depth two or
deeper — for example a `.gitkeep`-reserved child of this very roadmap that proves
to be an initiative — is legal under the model and representable under the schema
but **cannot authorize its own decomposition**: no writer accepts it. The
documented authoring step has no implementation at depth. `0001` also declared
`/roadmap` a **deprecated alias** for the planning step (`docs/workflow.md:68-70`)
and left the wiring to this item, so the alias and the authoring step do not yet
agree.

Two audiences pay. **Framework maintainers** can plan a recursive tree in theory
but cannot materialize a decomposition below the top level, so the recursion is
documented yet unreachable; and **adopters** inherit a model whose only writer is
a top-level-only command. The deliverable is not a new concept — the model and
schema are already shipped — but the **writer and its handoff** that make
decomposition work at any depth, per the child's scope
(`work/0011-recursive-bootstrap/roadmap.md:105`).

## Goals

- Give the planning step a **recursive writer**: `/plan <item-ref>` authors a
  node's decomposition (its manifest plus child directory reservations) for a
  node at **any depth**, not only a top-level node.
- Preserve the writer's established **output contract**: the manifest
  (`roadmap.md`, `phase: roadmap`), each child directory reserved with
  `.gitkeep`, per-level `MMMM` allocation scoped to the immediate parent, and the
  six-column `Children` table.
- Keep the writer **autonomous** (no pre-write approval gate) and make it write
  **no child phase artifact** — children stay independently owned.
- Allow **hybrid** nodes: the writer always authors the manifest and may also
  author the node's own `design.md`/`tasks.md` when the node has its own
  deliverable.
- Generalize **revision** of a decomposition to any depth — re-scope, add,
  withdraw, and re-sequence, with `stale: roadmap` invalidation — so an existing
  decomposition can be corrected wherever the node lives.
- Keep `/roadmap` as a **thin deprecated alias**: a new top-level node via
  `/roadmap <initiative>`, revision via `/roadmap revise <item-ref>` — no new
  command, so no inventory change, and no retirement (that is a successor
  roadmap's concern).
- Define the writer's **handoff**: publish the node's plan state, then route to
  `/spec` for each ready child.
- Keep the committed suite green, preserve backward compatibility, and state the
  writer contract once without forking the shipped model, schema, or conflict
  grammar.

## Non-goals

- Readiness, derived state, the phase/progress derivation of a parent from its
  children, and the `/status` tree report — owned by
  `0004-recursive-readiness`.
- Retiring or removing `/roadmap` or `roadmap.md`, and migrating existing
  roadmap parents (including `0010` and `0011` themselves) — a successor roadmap
  (Roadmap 2, `work/0011-recursive-bootstrap/roadmap.md:133-136`).
- `conflicts-with` targets at arbitrary depth, per-level duplicate detection
  across a merge, merge-integrity and renumbering for recursive trees, and
  parallel plan publication — a successor roadmap (Roadmap 3).
- The agent/command/inventory surface sweep and reconciling every surface to the
  recursive model — a successor roadmap (Roadmap 4).
- Committed fixtures, agreement areas, or mutation coverage pinning the writer —
  a successor roadmap (Roadmap 5); the committed suite stays green as a
  constraint, not a deliverable.
- A new command, agent, skill, `phase` value, artifact file name, or
  artifact-presence row.
- A new runtime dependency, service, network access, or toolchain.
- A second state model, reference grammar, conflict taxonomy, or writer/handoff
  vocabulary; the writer reuses the shipped ones.
- Automatic orchestration, scheduling, delivery dates, or parallel-agent
  execution.

## Users and stories

- **As a** framework maintainer, **I want** to decompose a node that lies deep in
  a plan tree, **so that** a nested unit of work that is itself an initiative can
  be broken into independently specifiable, buildable, and reviewable children.
- **As a** plan author, **I want** the planning step itself to author the child
  enumeration, **so that** I do not have to invoke a separate top-level-only
  command to record a decomposition.
- **As a** plan author, **I want** to revise a decomposition at any depth, **so
  that** re-scoping, adding, withdrawing, and re-sequencing children work wherever
  the node lives.
- **As a** plan author, **I want** the writer to reserve child directories and
  write no child phase artifact, **so that** each child's phases stay owned and
  started independently.
- **As an** adopter, **I want** existing `/roadmap` invocations, one-segment
  standalone items, and two-level roadmap parents to keep working unchanged, **so
  that** adopting the recursive writer requires no migration and no re-learning.

## Acceptance criteria

1. **AC1** — Given the planning step (`/plan`, `architect`), when a node at any
   depth is decomposed, then the writer authors that node's manifest at
   `work/<item-ref>/roadmap.md`, with `feature:` set to the node's full canonical
   reference and `phase: roadmap`, and a node at depth two or deeper is authored
   exactly as a top-level node is (not only a top-level node).

2. **AC2** — Given a decomposing node, when the writer records its child set,
   then each enumerated child gets a directory `work/<item-ref>/<MMMM-slug>/`
   reserved with a `.gitkeep`, the child's `MMMM` is allocated per the immediate
   parent (the greatest 4-digit prefix ever committed under `work/<item-ref>/`
   plus one, never reused within that parent), and each child's canonical
   reference is the node's canonical reference with the child segment appended.

3. **AC3** — Given the writer authoring a decomposition, when the manifest is
   inspected, then it carries the six-column `Children` header (`Depends on` at
   pipe-field 5 and `conflicts-with` at pipe-field 6), every `Depends on` value
   names another row's local id in the same table with no self-dependency and an
   acyclic stored graph (an intended cycle is recorded under `## Open issues`,
   never stored), every `Canonical reference` resolves to that child's directory,
   and every `conflicts-with` cell is `—` or a well-formed target list.

4. **AC4** — Given the writer authoring a decomposition, when the produced files
   are inspected, then **no child phase artifact is written**: each new child
   directory contains only `.gitkeep`, and the writer writes no child `spec.md`,
   `design.md`, `tasks.md`, `verify.md`, or `review.md`.

5. **AC5** — Given the writer authoring a decomposition for a node, when that
   node's own artifacts are inspected, then the writer always produces the
   manifest and MAY additionally produce the node's own `design.md`/`tasks.md`
   when the node has a deliverable of its own (hybrid); it never forces
   `design.md`/`tasks.md` onto a pure container; and for a node that is a genuine
   single feature, planning still produces `design.md`/`tasks.md` and no
   manifest.

6. **AC6** — Given the writer invoked to revise an existing decomposition at any
   depth, when the revision runs, then the four operations (re-scope, add,
   withdraw, re-sequence) are applied in one pass and validated on the final
   state with no fault stored; each affected existing unshipped child's present
   phase artifacts are marked `stale: roadmap` and no content is deleted or
   rewritten; a shipped child (`ship.md` present) is not re-scoped or
   re-sequenced — the conflict is refused and surfaced; and a request that
   changes nothing modifies no file.

7. **AC7** — Given the writer is invoked, when it produces or revises a
   decomposition, then it acts **autonomously**: it writes the manifest and child
   directory reservations without a pre-write approval gate, and the user reviews
   the committed artifact afterward.

8. **AC8** — Given the writer has authored or revised a decomposition, when it
   ends, then its handoff recommends publishing the node's plan state and then
   routes to `/spec <child-ref>` for each ready child. The node's plan state
   includes its manifest and its own `spec.md`/`design.md`/`tasks.md` when
   present, so a decomposing node's child set — including a pure container's
   manifest-only plan — is publishable as committed plan state that a fresh clone
   derives, and the handoff names each ready child.

9. **AC9** — Given `/roadmap`, when it is invoked, then it remains a **thin
   deprecated alias** for the planning step: `/roadmap <initiative>` creates a
   brand-new top-level decomposing node (allocating the next top-level `NNNN`),
   `/roadmap revise <item-ref>` revises an existing node at any depth, the
   command is documented as a deprecated alias for the planning step, and it is
   not retired or removed (retirement is a successor roadmap's decision).

10. **AC10** — Given the repository after the change, when the project's
    configured test command runs, then it passes; no new command, agent, or skill
    is added; no documented inventory count changes; and the six core phase
    commands, the `phase` value set, and the `Children`/`conflicts-with` and
    readiness contracts are unchanged (`tests/checks/40-inventory.sh`,
    `96-signature-sweep.sh`, `20-lifecycle.sh`, `80-cycle-fixture.sh`, and
    `85-conflict-guards.sh` stay green).

11. **AC11** — Given the recursive writer contract, when it is stated, then it is
    stated once in the workflow authority — the model's writer wiring
    (`docs/workflow.md:66-74`), "Revising a roadmap" (`:303-388`), and "Plan
    publication" (`:520`) — and the surfaces that must carry it (the planning
    step's agent and command, the roadmap agent and command, and the workflow
    authority) state one consistent writer contract with no competing writer
    grammar. The existing ownership claim that the roadmap agent is the sole
    writer of a `roadmap.md` (`docs/workflow.md:309`) is reconciled so it no
    longer contradicts the planning step being the authoring authority.

12. **AC12** — Given the repository after the change, when a one-segment
    standalone item or an existing two-level roadmap parent/child is read, then
    it remains valid with no forced migration; existing `/roadmap <initiative>`
    and `/roadmap revise <item-ref>` invocations keep working; no existing
    reference changes meaning; and no shipped decision or artifact of `0001` or
    `0002` is re-opened.

13. **AC13** — Given a node that has no `spec.md` of its own — a `.gitkeep`
    reserved child or a pure container — when the writer authors its
    decomposition, then it produces the manifest and child reservations without
    requiring the node's own `spec.md`, and it writes no `spec.md` for the node
    (a spec belongs to the requirements phase, not the writer). A node that is a
    genuine single feature is still reachable through the ordinary `/plan` path
    that requires its `spec.md`.

## Edge cases

- **Pure container.** A node with only a manifest (no `spec.md`/`design.md`/`tasks.md`
  of its own) is valid and is exactly what the writer produces for a decomposing
  initiative; it can itself be decomposed without its own spec (AC13).
- **Hybrid node.** A node may carry its own in-progress `design.md`/`tasks.md`
  and a manifest at the same time; the writer produces both without requiring
  either on a pure container (AC5).
- **Single feature, not an initiative.** A node that is genuinely one feature is
  planned as today — `design.md`/`tasks.md`, no manifest; the writer must not
  force a decomposition.
- **`.gitkeep`-only reserved child.** A child directory holding only `.gitkeep`
  can itself be decomposed later, producing grandchildren; the writer sets no
  special behavior at any depth.
- **Deep chain.** A chain of single-child decompositions is permitted; the writer
  behaves identically at every depth.
- **Repeated local id text at different levels.** The same `MMMM-slug` under two
  different parents names two distinct nodes; identity is the full canonical
  path.
- **Existing two-level roadmap.** A committed two-level parent/child is
  untouched; `/roadmap <initiative>` still creates a top-level node and
  `/roadmap revise <item-ref>` still revises it.
- **Shipped node.** The writer does not re-scope or re-sequence a node whose
  `ship.md` is present; it refuses and surfaces the conflict.
- **No-op revision.** A revise request that changes no cell and re-sequences
  nothing modifies no file.
- **Intended dependency cycle.** If the intended graph would be cyclic, the
  writer stores no cyclic edge and records the cycle under `## Open issues`.
- **Withdrawal that would dangle a dependency.** The writer applies the re-point
  or withdrawal that removes the dangling edge in the same revision, or refuses
  and reports the ambiguous intent — it never stores a dangling dependency.
- **Malformed `conflicts-with` cell.** An empty or whitespace-only cell is
  malformed and reported, not treated as `—`; a target that names the declaring
  row or repeats a target is malformed.
- **Malformed reference.** A trailing slash, an empty segment, or a non-conforming
  segment is not a valid reference and is not treated as one.
- **Parallel nodes.** The writer touches only its own node's committed state and
  changes no other item's readiness or artifacts.

## Open questions

- [x] **Writer scope — author vs. author + revise.** Resolved (user): the writer
  authors **and** revises a decomposition at any depth (AC1, AC6).
- [x] **Writer surface / entry point.** Resolved (user): `/plan` (`architect`)
  authors at any depth; `/roadmap` is a thin deprecated alias (new top-level via
  `/roadmap <initiative>`, revision via `/roadmap revise <item-ref>`); no new
  command (AC9, AC10).
- [x] **Decomposing-node artifacts.** Resolved (user): always the manifest, plus
  optional own `design.md`/`tasks.md` (hybrid) — never forced on a pure container
  (AC5).
- [x] **Writer handoff.** Resolved (user): publish the node's plan state via
  `/ship plan <item-ref>`, then `/spec <child-ref>` for each ready child (AC8).
- [ ] **Deferred — retirement and migration of `/roadmap`/`roadmap.md`.** Whether
  `/roadmap` and `roadmap.md` are renamed or retired and how existing roadmap
  parents migrate are Roadmap 2 decisions. — owner: Roadmap 2 (roadmap
  deprecation and migration), needed by: Roadmap 2 `/spec`.
- [ ] **Deferred — recursive readiness, derived state, and `/status`.** How a
  parent's progress derives from its children and how the tree is reported are
  `0004-recursive-readiness`. — owner: `0004-recursive-readiness`, needed by:
  `0004` design.
- [ ] **Deferred — `conflicts-with` at every level and recursive duplicate
  detection / renumbering.** — owner: Roadmap 3 (simultaneous work under
  recursion), needed by: Roadmap 3 `/spec`.
- [ ] **Assumption — the decomposition path is reachable without the node's own
  `spec.md`.** Because a pure-container node or a `.gitkeep`-reserved child has no
  `spec.md`, the writer must be reachable without one (AC13), and the node's plan
  to publish may be manifest-only (AC8). This requires `/plan`'s spec entry
  criterion and Plan publication's `spec.md`+`design.md` precondition to
  accommodate the decomposition path without weakening them for an ordinary
  single-feature item; the exact wiring is the design's. — owner:
  `0003-recursive-writer` design (architect), needed by: design.

## Dependencies and constraints

- **Ready.** The parent roadmap lists this child as `Depends on:
  0001-recursive-model, 0002-recursive-schema`
  (`work/0011-recursive-bootstrap/roadmap.md:105`); both siblings are shipped
  (their `ship.md` are present with no `reopened:` marker), so the dependency is
  satisfied and no override is needed.
- **Consumes the model (`0001`).** The writer wiring was explicitly deferred here
  (`docs/workflow.md:72-74`): the standard cycle applies uniformly at every node,
  recursion depth is unbounded, a node may be a hybrid, `tasks.md` entries are not
  nodes, and `roadmap` is a deprecated alias
  (`work/0011-recursive-bootstrap/0001-recursive-model/spec.md`, AC1–AC9).
- **Consumes the schema (`0002`).** The recursive canonical reference, per-level
  `MMMM` allocation, the frontmatter `parent:` chain, the manifest's shipped
  spelling (`roadmap.md`/`phase: roadmap`) at every depth, the six-column
  `Children` table, the `.gitkeep` reservation at each level, and the preserved
  `conflicts-with` grammar (`work/0011-recursive-bootstrap/0002-recursive-schema/spec.md`,
  AC1–AC9; `docs/artifact-conventions.md:73-137`).
- **Deliverable surfaces.** Per the child scope the writer is the planning step's
  command/agent plus the workflow authority: `.opencode/agent/architect.md` and
  `.opencode/command/plan.md` (make `/plan` the authoring step), the roadmap
  agent/command (demote to a thin deprecated alias), and `docs/workflow.md` →
  the model's writer-wiring statement, "Revising a roadmap", and "Plan
  publication" (`work/0011-recursive-bootstrap/roadmap.md:105`). The acceptance
  criteria state required behavior; the concrete wiring is the design's.
- **Pure-container reachability.** A decomposing node may have no
  `spec.md`/`design.md` of its own (0001 AC5; `docs/workflow.md:76-85`), so the
  writer path must be reachable without the node's own spec (AC13), and its
  publishable plan may be manifest-only (AC8). `/plan`'s entry criterion
  (`docs/workflow.md:411-432`) and Plan publication's `spec.md`+`design.md`
  precondition (`:520-566`) are therefore reconciled by the design for the
  decomposition path, without weakening them for an ordinary single-feature item.
- **Extend, do not fork.** The writer generalizes the shipped create/revise
  behavior (`.opencode/agent/roadmap.md:76-172`), the four revise operations and
  the `stale: roadmap` marking (`docs/workflow.md:303-388`), the manifest and
  `Children` grammar (`docs/artifact-conventions.md:124-216`), per-level
  allocation (`docs/artifact-conventions.md:662-682`), and the recursive
  reference grammar (`docs/artifact-conventions.md:73-100`). It defines no second
  grammar, state model, or conflict taxonomy.
- **Single-source guards must stay green.** `tests/checks/40-inventory.sh` pins
  the README layout counts and agent/command/skill tables;
  `tests/checks/96-signature-sweep.sh` pins the command signatures (the
  canonical `/roadmap <initiative> | /roadmap revise <item-ref>` registry entry
  and every command's usage string); `tests/checks/20-lifecycle.sh` pins the six
  core commands, the command→agent pairs, and the derived-state routing literals;
  `tests/checks/80-cycle-fixture.sh` pins the six-column positional `Children`
  header and the `CYCLIC-DEP` rule; `tests/checks/85-conflict-guards.sh` pins the
  declaration model and grammar; `tests/checks/95-split-guard.sh` requires
  `AGENTS.md` and `template/AGENTS.md` to be byte-identical outside
  `## Project profile`. This item must restate none of their pinned literals and
  must keep them green.
- **Suite never reads live `work/**`.** The committed suite is read-only and
  fresh-clone-clean (`tests/README.md`); any guard is fixture-based, and the
  committed guards are deferred to a successor roadmap, so this item adds no test
  file.
- **Sibling boundaries.** Readiness/derived-state/`/status` is `0004`; roadmap
  deprecation and migration is Roadmap 2; simultaneous-work guarantees and
  every-level conflicts are Roadmap 3; the surface sweep is Roadmap 4; committed
  guards are Roadmap 5. This item fixes only the writer and its handoff.
- **Declared-conflict hygiene.** The item's own declared conflict set (authored
  in `design.md` frontmatter at the next phase) should equal the parent `Children`
  row's cell — `docs/workflow.md, .opencode/agent/roadmap.md,
  .opencode/command/roadmap.md` (`work/0011-recursive-bootstrap/roadmap.md:105`)
  — so the read-only check does not report declaration drift.
- **Backward compatibility.** A one-segment standalone item and every existing
  committed `work/` item remain valid; no migration, rename, or spent-number
  change occurs (`work/0011-recursive-bootstrap/roadmap.md:83-85`).
- **Assumption — the bootstrap child is a single feature.** Authoring and
  revising a decomposition at any depth is one coherent writer change,
  specifiable and reviewable on its own. If it proves too large at `/spec`, the
  roadmap's sanctioned remedy is `/roadmap revise 0011-recursive-bootstrap` to
  add siblings at the **same** level, never to nest.
- **Framework-internal change only.** Docs and prompts; no runtime dependency,
  service, or new toolchain.
