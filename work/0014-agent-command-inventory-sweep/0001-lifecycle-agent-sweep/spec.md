---
feature: 0014-agent-command-inventory-sweep/0001-lifecycle-agent-sweep
phase: spec
status: final
created: 2026-10-13
updated: 2026-10-13
parent: 0014-agent-command-inventory-sweep
---

# Lifecycle-agent recursive sweep

## Problem

The repository's six lifecycle/phase agent prompts — `product`, `architect`,
`builder`, `tester`, `reviewer`, and `shipper` — still teach the retired
two-level roadmap model, even though the shipped authority
(`docs/workflow.md` → "The recursive lifecycle model"; `docs/artifact-conventions.md`
→ "Work item references") has made the generic **manifest** the sole
child-enumeration artifact at arbitrary depth. The `product` prompt instructs the
agent to resolve a "parent roadmap", to take a `/roadmap revise` route that no
longer exists, and to target a `roadmap` phase that is now `manifest`
(`product.md:56,77-78,87,116-124`); the `shipper` prompt speaks of a "roadmap
graph" and "roadmap `Children`" (`shipper.md:132,202,376`); and all six prompts
repeat an item-ref boilerplate that says "for a roadmap child" (`product.md:56`,
`architect.md:87`, `builder.md:70`, `tester.md:98`, `reviewer.md:63`,
`shipper.md:94`). Framework maintainers cannot trust any single prompt to teach
the model the authority documents, and adopters who inherit the prompts verbatim
are told about a retired route, artifact, and phase. The pain is concrete: an
agent following today's `product.md` would look for a `work/<parent-ref>/roadmap.md`
that is no longer the enumeration source.

## Goals

- Each of the six lifecycle agent prompts teaches the shipped recursive model and
  no longer instructs retired roadmap behavior.
- The item-ref form is stated once and identically across the six prompts, ready
  for `0003-command-sweep` to mirror verbatim.
- The sweep is prose-only: agent responsibilities, frontmatter, permission blocks,
  handoff blocks, and phase behavior are unchanged.
- The committed suite stays green and the documented inventories are unchanged.

## Non-goals

- The supporting agents (`0002-supporting-agent-sweep`), the commands
  (`0003-command-sweep`), the skills (`0004-skill-sweep`), and the
  inventory/doctor reconciliation (`0005-inventory-and-doctor-sweep`).
- Adding any new committed fixture, guard, or executable checker — that boundary
  is Roadmap 5.
- Editing the authority documents `docs/workflow.md` and
  `docs/artifact-conventions.md`; they are read-only references for this sweep.
- Renaming, adding, enabling, or disabling any agent, or changing any agent's
  `description`, `mode`, or `permission` block.
- Removing the sanctioned, clearly-labelled legacy `roadmap.md` alias mention
  (the user decision recorded under Open questions keeps it).

## Users and stories

- **As a** framework maintainer, **I want** each lifecycle agent prompt to teach
  the same recursive model as `docs/workflow.md`, **so that** `/spec`, `/plan`,
  `/build`, `/test`, `/review`, and `/ship` behave consistently and I can trust
  any prompt on its own.
- **As an** adopter, **I want** the inherited lifecycle prompts to reference the
  parent **manifest** rather than a retired `roadmap.md`, **so that** the prompts
  work on my nested work items out of the box.
- **As the** author of `0003-command-sweep`, **I want** a single canonical item-ref
  boilerplate, **so that** each command can mirror its paired agent's wording
  verbatim.

## Acceptance criteria

1. **AC1** — Given the swept `product` agent prompt, when its parent-node revision
   guidance is read, then it names the parent's **manifest**
   (`work/<parent-ref>/manifest.md`), the target phase `manifest`, and the
   sanctioned `/plan <parent-ref>` revise route, cites `docs/workflow.md` →
   "Revising a decomposition", and contains no `parent roadmap`, no `/roadmap
   revise`, no `roadmap` target phase, and no live `work/<parent-ref>/roadmap.md`
   path.

2. **AC2** — Given the swept `product` agent prompt, when its nested-child process
   step is read, then resolving a nested child resolves the parent's
   `work/<NNNN-slug>/manifest.md` rather than `roadmap.md`, and the step's
   readiness check and explicit-override behavior are preserved.

3. **AC3** — Given the swept `shipper` agent prompt, when its merge/reconcile and
   renumber guidance is read, then "roadmap graph" is stated as the manifest's
   dependency graph and "roadmap `Children`" as the manifest's `Children` table,
   with the renumber and integrity semantics unchanged.

4. **AC4** — Given the six lifecycle agent prompts, when the item-ref boilerplate
   sentence is extracted from each prompt's inputs, then the six sentences are
   byte-identical, each states the item-ref as a canonical reference (`NNNN-slug`
   for a standalone item or a nested `NNNN-slug/MMMM-slug` at any depth) resolving
   to `work/<item-ref>/`, and none contains the wording "roadmap child".

5. **AC5** — Given the swept `tester` and `reviewer` agent prompts, when their
   inputs that read `work/<item-ref>/` are read, then each addresses a decomposing
   node's `manifest.md`, its nested children, and the canonical reference, so a
   nested child or a hybrid node is handled rather than only a leaf.

6. **AC6** — Given the six swept prompts, when every occurrence of the token
   `roadmap` is inspected, then each occurrence is a clearly-labelled deprecated
   alias mention permitted by the parent's sanctioned-legacy-alias rule; no
   occurrence presents `roadmap` as a current phase, artifact path, or route.

7. **AC7** — Given each of the six swept prompts, when its frontmatter and handoff
   block are compared with the pre-sweep file, then the `description`, `mode`, and
   `permission` values are byte-identical and the `<handoff>` block's commands and
   structure are preserved, so the change is prose-only and no agent's phase
   behavior changes.

8. **AC8** — Given the swept tree, when `bash tests/run.sh` is run, then it exits
   `0`, and the documented inventory remains 13 agents / 12 commands / 11 skills.

9. **AC9** — Given the swept prompts, when any recursive-model statement is
   inspected, then it references the authority sections by name and introduces no
   new `phase` value, finding code, or reference grammar.

## Edge cases

- `product.md` carries the stale item-ref wording in two places — its inputs list
  and its process step "Allocate the canonical reference"; both must be swept, not
  just the first.
- `architect.md` retains exactly one sanctioned, clearly-labelled legacy
  `roadmap.md` alias mention; it is the intentional exception to AC6 and must stay
  labelled "legacy".
- A nested child that is itself a decomposing node (a hybrid) must be readable by
  `tester` and `reviewer`, which otherwise see only a leaf's spec/design/tasks.
- The canonical boilerplate sentence must be stable because `0003-command-sweep`
  mirrors it; a later change to it re-opens `0003`.
- `shipper.md` already names `manifest.md` in its plan-publication and recall
  modes; the sweep must not regress that wording.
- The sweep touches a file set disjoint from `0002` and `0004` (the lifecycle
  agents only), so no concurrent same-file edit is expected; `0003` consumes both
  agent sweeps.

## Open questions

- [x] **Legacy-alias mentions** — resolved: keep the clearly-labelled deprecated
  `roadmap.md` alias mention where it exists (`architect.md`); sweep only
  bare/current usages. owner: user; needed by: spec.
- [x] **Boilerplate identity** — resolved: use one identical canonical sentence
  across the six prompts' inputs, so `0003` can mirror it verbatim. owner: user;
  needed by: spec.
- [ ] **Exact canonical sentence text** — deferred to design; the spec fixes only
  the required content and the cross-file identity. owner: architect
  (`/plan`); needed by: design.

## Dependencies and constraints

- The recursive authority is already shipped and is read-only here:
  `docs/workflow.md` → "The recursive lifecycle model", "Where decomposition is
  authored and recorded", "Revising a decomposition", "Dependencies and
  readiness", "Derived state"; and `docs/artifact-conventions.md` → "Work item
  references", "`manifest.md` — the manifest of a decomposing node", "Sequence
  allocation".
- The parent node `work/0014-agent-command-inventory-sweep/manifest.md` fixes the
  shared sweep vocabulary (retired→recursive term mapping) this spec consumes; the
  sanctioned legacy-alias rule is at `docs/artifact-conventions.md:124-137`.
- The six prompts are shared verbatim with adopters (single source
  `.opencode/agent/`), so this change ships to adopters.
- The committed suite (`bash tests/run.sh`) is read-only and never reads live
  `work/**`; there is no committed fixture for a recursive agent sweep, so
  verification of AC1–AC7, AC9 is by inspection of the swept prompts and AC8 by
  the suite.
- This child is ready under the parent's `Children` table (`Depends on: —`); it
  has no unmet prerequisite.
