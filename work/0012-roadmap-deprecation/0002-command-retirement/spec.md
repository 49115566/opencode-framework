---
feature: 0012-roadmap-deprecation/0002-command-retirement
phase: spec
status: final
created: 2026-10-13
updated: 2026-10-13
notes: "Nested roadmap child of 0012-roadmap-deprecation; the parent roadmap supplies the requirements (work/0012-roadmap-deprecation/roadmap.md:73,105-108). Dependency `0001-deprecation-contract` is satisfied — its ship.md is present with no reopened: marker — so the child is ready and no override is needed. User resolved the three policy forks this child owns: (1) the /roadmap command and the roadmap agent are deleted outright (no thin redirect retained) and the create mode moves to /plan; (2) /plan exposes the create mode through the dual-form canonical signature `/plan <item-ref or initiative>`, mirroring /spec; (3) the read-side agent/command prose (status, product, reviewer, visual, builder, tester, shipper, scribe) stays out of scope — the broad agent sweep is Roadmap 4 and the roadmap.md fixtures/guards and existing parents are 0003-parent-migration. Deliverable surfaces: the retired command/agent files, /plan + architect (write side), README.md, AGENTS.md, template/AGENTS.md, the workflow-lifecycle skill, docs/workflow.md's /roadmap command-alias prose and phase-2 signature, and tests/checks/96-signature-sweep.sh (with 40-inventory.sh and 95-split-guard.sh staying green). The legacy roadmap.md / phase: roadmap artifact alias fixed by 0001 is consumed, not changed."
parent: 0012-roadmap-deprecation
---

# Retire the `/roadmap` command and agent; `/plan` becomes the sole recursive writer

## Problem

The recursive model shipped by `0011-recursive-bootstrap` made a node's
child-enumeration artifact the generic **manifest**, authored by the planning
step (`/plan`, `architect`) at any depth
(`docs/workflow.md` → "The recursive lifecycle model"). `0001-deprecation-contract`
then fixed the modern spelling and vocabulary: `manifest.md` carrying
`phase: manifest`, with legacy `roadmap.md` / `phase: roadmap` retained only as a
recognized deprecated **file/phase** alias, and the `roadmap` term retired from
the authority documents (AC1–AC9 of
`work/0012-roadmap-deprecation/0001-deprecation-contract/spec.md`).

But the special **`/roadmap` command** and its **`roadmap` agent** still ship,
and they are now the *only* surface that can create a brand-new top-level
decomposing node. They keep the retired concept alive in four concrete ways: they
are still enumerated in the always-loaded command/agent inventories
(`AGENTS.md:44-51`, `template/AGENTS.md:48-55`), the README Layout counts and
Commands/Agents tables (`README.md:203,215,273-275`), the command-signature
registry (`tests/checks/96-signature-sweep.sh:47,226,228,230,270`), and the
`workflow-lifecycle` skill's routing block
(`.opencode/skill/workflow-lifecycle/SKILL.md:31`); they still write the retired
`roadmap.md` / `phase: roadmap` spelling (`.opencode/command/roadmap.md:30`);
and `docs/workflow.md` still documents the command as a live deprecated alias
(`docs/workflow.md` → "Where decomposition is authored and recorded",
"Revising a decomposition").

Two audiences pay for the residue. **Framework maintainers** must keep a
deprecated command/agent pair coherent with a contract that has already moved to
the manifest, and must reconcile two parallel writer surfaces — `/roadmap` and
`/plan` — that contradict each other on the artifact they produce. **Adopters**
must learn a dedicated "roadmap" facility that the recursive model has subsumed.
Finally, the create path a new top-level node needs lives only in the retiring
alias, so once it is gone the planning step has no way to create a node; the
create mode must move to `/plan`.

## Goals

- **Retire the command and agent.** Remove `.opencode/command/roadmap.md` and
  `.opencode/agent/roadmap.md`, so the shipped command and agent sets contain no
  `roadmap` entry.
- **Move the create mode to `/plan`.** Make the planning step (`/plan`,
  `architect`) the sole recursive writer, including the brand-new top-level
  create mode the alias owned, exposed through a single dual-form signature
  `/plan <item-ref or initiative>`.
- **Write the modern spelling.** The planning step's author and revise paths
  produce and revise a **`manifest.md`** carrying `phase: manifest`, and mark
  affected unshipped children `stale: manifest`, not `stale: roadmap`.
- **Reconcile every named surface.** Bring the documented command/agent
  inventories, the command-signature registry, the always-loaded contracts, the
  workflow-lifecycle skill, and `docs/workflow.md`'s command-alias prose into
  agreement with the retired command and the moved create mode.
- **Keep the suite green.** `bash tests/run.sh` passes, and the committed
  inventory, signature, lifecycle, permission, and split guards stay green.

## Non-goals

- **The deprecation contract of `0001`.** The modern spelling (`manifest.md`),
  the modern `phase` value (`manifest`), and the legacy `roadmap.md` /
  `phase: roadmap` **file/phase** alias are consumed as fixed. In particular the
  legacy artifact alias stays documented as deprecated; only the **`/roadmap`
  command alias** is retired.
- **The read-side agent and command prose.** The `status` agent/command
  decomposing-node detection and `manifest` container-phase derivation, the
  `product` agent's parent-manifest resolution, and the generic "roadmap child"
  phrasing in `reviewer`, `visual`, `builder`, `tester`, `shipper`, `scribe`, and
  the remaining commands are the broad agent/command/inventory surface sweep —
  Roadmap 4 (`work/0012-roadmap-deprecation/roadmap.md:118-122`).
- **Migrating the seven existing decomposing nodes** (`0003`–`0007`, `0010`,
  `0011`) and reconciling the fixtures and guards that load `roadmap.md`
  (`80-cycle-fixture`, `85-conflict-guards`, `87-backtrack-guards`) and
  `tests/README.md` — owned by `0003-parent-migration`
  (`work/0012-roadmap-deprecation/roadmap.md:74`).
- **Historical records** that name the retired command: `CHANGELOG.md`,
  `CONTRIBUTING.md`, and committed `work/` artifacts.
- Changing the six-column `Children` table, the `conflicts-with` grammar, the
  `Depends on`/readiness contract, the derived-state model, or any second state
  model, reference grammar, conflict taxonomy, or finding/severity vocabulary.
- Adding or removing any other command, agent, or skill, or introducing any new
  runtime dependency, service, network access, or toolchain.
- Rewriting any shipped item's artifacts or its `ship.md` signal.

## Users and stories

- **As a** framework maintainer, **I want** a single planning entry point with no
  deprecated command/agent pair and no writer that emits a retired spelling, **so
  that** there is one writer contract and one artifact kind to keep coherent
  across docs, prompts, inventories, and guards.
- **As an** adopter, **I want** to plan and create work items through `/plan`
  without learning a separate "roadmap" command, **so that** the recursive model
  presents one facility that matches the authority documents.
- **As a** plan author, **I want** `/plan <initiative>` to create a brand-new
  top-level decomposing node exactly as the retired alias did, **so that** moving
  off the alias does not remove my ability to start a new initiative.

## Acceptance criteria

1. **AC1 — Command removed.** Given the framework's command set, when
   `.opencode/command/` is enumerated, then no `roadmap` command exists, and no
   command file's `agent:` field names the retired `roadmap` agent.

2. **AC2 — Agent removed.** Given the framework's agent set, when
   `.opencode/agent/` is enumerated, then no `roadmap` agent exists, and the
   documented agent inventory matches the on-disk set.

3. **AC3 — Create mode moved to `/plan`.** Given the planning command invoked
   with an argument that does not resolve to an existing `work/<item-ref>/`, when
   the planner runs, then it treats the argument as an initiative: it reconnoitres
   `work/` so it neither collides with nor duplicates an item, allocates the next
   top-level `NNNN` and a kebab-case slug, authors
   `work/<NNNN-slug>/manifest.md` carrying `phase: manifest`, reserves each
   enumerated child as `work/<NNNN-slug>/<MMMM-slug>/.gitkeep`, and writes no
   child phase artifact — the create mode the retired alias owned. Given an
   argument that resolves to an existing work item, the planner takes the
   existing-item path (single-feature design, or author/revise of that node's
   decomposition).

4. **AC4 — Canonical `/plan` signature.** Given the command-signature surfaces,
   when the planning command's signature is read, then it is
   **`/plan <item-ref or initiative>`**, and that canonical form agrees across
   the README Commands table, the `AGENTS.md` lifecycle table, `template/AGENTS.md`,
   the `docs/workflow.md` Design-phase heading, the `workflow-lifecycle` skill's
   routing block, the `/plan` command's own usage string, and the
   `96-signature-sweep.sh` registry.

5. **AC5 — Sole recursive writer.** Given the writer authority and the shipped
   command set, when the planning step is described, then `/plan` (architect) is
   the sole recursive writer, no documented surface presents `/roadmap` as an
   available command or alias, and no documented surface names the retired
   `roadmap` agent.

6. **AC6 — Writer emits the modern spelling.** Given the planning step's author
   and revise paths, when a manifest is produced or revised, then it is
   `manifest.md` carrying `phase: manifest`; affected unshipped children are
   marked `stale: manifest` (not `stale: roadmap`); and the writer surfaces name
   the renamed authority ("Revising a decomposition"), not the retired "Revising
   a roadmap".

7. **AC7 — Command-alias prose retired, file/phase alias retained.** Given
   `docs/workflow.md` and the `workflow-lifecycle` skill, when their command prose
   is read, then neither presents `/roadmap` as an available command or alias, and
   the legacy `roadmap.md` / `phase: roadmap` **artifact** alias fixed by `0001`
   remains documented as a recognized deprecated alias.

8. **AC8 — README inventory reconciled.** Given `README.md`, when its Layout
   counts and its Commands and Agents tables are read, then the Layout counts
   equal the on-disk counts after removal (the agent count and the command count
   each one lower than before, e.g. 13 agents and 12 commands), the Commands table
   carries no `/roadmap` row while its `/plan` row states the canonical signature,
   and the Agents table carries no `roadmap` row.

9. **AC9 — Contracts reconciled and byte-parity held.** Given `AGENTS.md` and
   `template/AGENTS.md`, when their lifecycle table, supporting-commands list,
   supporting-agents list, and artifact-contract prose are read, then neither
   names `/roadmap` or the `roadmap` agent, the Design row states the canonical
   `/plan` signature, and the two files remain byte-identical outside the
   `## Project profile` section.

10. **AC10 — Skill surfaces reconciled.** Given the `workflow-lifecycle` skill,
    when its routing block and its derived-state view are read, then the planning
    route offers `/plan <item-ref or initiative>` (not `/roadmap`), and its
    decomposing-node and container-phase references use the manifest vocabulary
    fixed by `0001` (the container phase is `manifest`, the artifact is
    `manifest.md`).

11. **AC11 — Signature guard reconciled.** Given
    `tests/checks/96-signature-sweep.sh`, when its canonical registry, its
    per-surface required sets, and its per-command usage-string loop are read,
    then `/roadmap` is absent from all of them and the `/plan` canonical signature
    is the dual form of AC4.

12. **AC12 — Suite stays green.** Given the repository after the change, when the
    configured test command (`bash tests/run.sh`) runs, then it passes with no
    failures, and no new command, agent, or skill is introduced.

13. **AC13 — No behavior or contract fork.** Given the change set, when it is
    inspected, then it introduces no second state model, reference grammar,
    conflict taxonomy, finding/severity vocabulary, dependency edge, command,
    agent, or skill; the six-column `Children` table and the shipped
    `conflicts-with` grammar are unchanged; no committed `work/` artifact is
    rewritten; no spent sequence number is reused; and no shipped `ship.md` signal
    changes.

14. **AC14 — Scope fence.** Given the change set, when its scope is inspected,
    then it edits only the retired command and agent (removed), the planning
    command and its architect prose, `README.md`, `AGENTS.md`,
    `template/AGENTS.md`, the `workflow-lifecycle` skill, `docs/workflow.md`'s
    command-alias prose and Design-phase signature, and
    `tests/checks/96-signature-sweep.sh`; and it does not edit the read-side
    agent/command prose (`status`, `product`, `reviewer`, `visual`, `builder`,
    `tester`, `shipper`, `scribe`), the `roadmap.md`-loading fixtures and guards,
    `tests/README.md`, `docs/artifact-conventions.md`, `CHANGELOG.md`,
    `CONTRIBUTING.md`, or any committed `work/` artifact.

## Edge cases

- **Empty argument.** `/plan` with no argument asks which item to plan or
  initiative to create, and creates nothing.
- **Item-ref-shaped but non-resolving argument.** A token shaped like
  `NNNN-slug` that resolves to no existing item is not an existing item, so it
  takes the create path (AC3); the planner's `work/` reconnoitre must prevent a
  typo from silently producing a duplicate or colliding node.
- **Single-feature initiative.** A create-path argument that is really one
  feature recommends `/spec <feature>` and creates nothing, matching the retired
  alias's rule.
- **Existing modern manifest.** A node already holding `manifest.md` selects the
  revise path; the four revise operations are unchanged.
- **Existing legacy manifest.** A node holding only `roadmap.md` with
  `phase: roadmap` is a recognized deprecated alias (`0001`), still selects the
  revise path, and is not rewritten by this item.
- **`.gitkeep`-only child / pure container.** A node that decomposes with no own
  `spec.md` selects the author path; each child is reserved with a `.gitkeep` and
  no child phase artifact is written.
- **Hybrid node.** A node with its own deliverable also gets its own
  `design.md`/`tasks.md`; a pure container gets neither.
- **Shipped node.** A node whose `ship.md` is present is out of scope for any
  rewrite or re-scoping; its manifest and shipped signal are preserved.
- **Both spellings present.** When a node holds both `manifest.md` and
  `roadmap.md`, `manifest.md` is authoritative (`0001` AC5) and the writer follows
  it; nothing is silently merged or auto-repaired.
- **Deep nesting.** The create/author/revise rules, the modern spelling, and the
  `stale: manifest` marking are identical at every depth.
- **Muscle-memory invocation.** After removal, invoking `/roadmap` is an unknown
  command; by decision no redirect is retained.
- **Contract parity drift.** Any edit to the `AGENTS.md` shared body must be
  mirrored in `template/AGENTS.md` outside the Project profile, or the split
  guard fails.
- **Concurrency.** Two parallel `/plan` create calls may allocate the same
  top-level `NNNN`; the existing renumbering-after-a-parallel-merge rule applies
  and no new mechanism is introduced.

## Open questions

- [x] **Command/agent fate** — resolved (user): delete `.opencode/command/roadmap.md`
  and `.opencode/agent/roadmap.md` outright; no thin redirect is retained, and the
  create mode moves to `/plan`.
- [x] **`/plan` create-mode grammar** — resolved (user): the canonical signature is
  `/plan <item-ref or initiative>`, a dual form mirroring `/spec`.
- [x] **Read-side surface boundary** — resolved (user): the read-side agent and
  command prose is deferred to Roadmap 4; the `roadmap.md` fixtures/guards and the
  existing parents are `0003`. This child edits only the write side plus the named
  inventory/signature/prose surfaces.
- [ ] **Deferred — disambiguation and error behavior for a non-resolving,
  item-ref-shaped argument.** The exact confirmation/refusal behavior when a
  create-path argument is shaped like an item reference but resolves to nothing.
  Owner: `architect`, needed by: `/plan`.

## Dependencies and constraints

- **Ready.** The parent roadmap lists this child as
  `Depends on: 0001-deprecation-contract`
  (`work/0012-roadmap-deprecation/roadmap.md:73`), which has shipped (its
  `ship.md` is present with no `reopened:` marker), so the dependency is satisfied
  and no override is needed.
- **Consumes the deprecation contract.** The modern spelling (`manifest.md`), the
  modern `phase` value (`manifest`), the recognized legacy `roadmap.md` /
  `phase: roadmap` alias, the renamed container phase, and the `manifest`
  backtrack token are fixed by `0001` and referenced, not restated
  (`work/0012-roadmap-deprecation/0001-deprecation-contract/spec.md`).
- **Deliverable surfaces.** Because the deliverable is the framework's own
  prompts, inventories, and documents, the acceptance criteria name the surfaces
  required to carry the outcome; they specify required content, not implementation
  choices. The concrete surfaces are the retired command/agent files, the planning
  command (`.opencode/command/plan.md`) and its architect prompt
  (`.opencode/agent/architect.md`), `README.md`, `AGENTS.md`,
  `template/AGENTS.md`, `.opencode/skill/workflow-lifecycle/SKILL.md`,
  `docs/workflow.md`, and `tests/checks/96-signature-sweep.sh`.
- **Guards that must stay green.** `tests/checks/40-inventory.sh` (README Layout
  counts and table membership vs disk), `tests/checks/96-signature-sweep.sh`
  (canonical signatures across AGENTS, template AGENTS, workflow, README, skill,
  and usage strings), `tests/checks/95-split-guard.sh` (root `AGENTS.md` /
  `template/AGENTS.md` byte-parity outside the Project profile),
  `tests/checks/20-lifecycle.sh` (core command→agent agreement),
  `tests/checks/30-permissions.sh` (README Agents table vs declared
  permissions). `40-inventory.sh` and `30-permissions.sh` derive from disk, so
  they pass by construction once disk and README agree; `96` carries the literal
  `/roadmap` registry entries that this item edits.
- **Byte-parity twin.** `AGENTS.md` and `template/AGENTS.md` must change
  identically outside the `## Project profile` section
  (`tests/checks/95-split-guard.sh:288-315`).
- **Sibling boundaries.** `0003-parent-migration` owns the existing parents and
  the `roadmap.md` fixtures/guards; Roadmap 4 owns the broad agent/command
  surface sweep (AC14 fences both).
- **Backward compatibility.** A one-segment standalone item, every existing
  legacy decomposing parent, and every item whose `ship.md` is present remain
  valid; no migration, rename, spent-number change, or `ship.md` change occurs.
  Invoking the retired `/roadmap` command is the one intentional breaking removal,
  owned by this item's decision.
- **Framework-internal change only.** Prompts, inventories, and documents; no
  runtime dependency, service, or new toolchain.
- **Assumption — the retirement is one feature.** Removing the command and agent,
  moving the create mode to `/plan`, and reconciling the named inventory,
  signature, and prose surfaces is one coherent, independently reviewable change.
  If it proves too large at `/plan`, the roadmap's sanctioned remedy is
  `/plan revise 0012-roadmap-deprecation` to add siblings at the same level, not
  to nest.
