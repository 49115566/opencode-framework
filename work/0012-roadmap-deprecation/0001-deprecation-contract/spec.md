---
feature: 0012-roadmap-deprecation/0001-deprecation-contract
phase: spec
status: final
created: 2026-10-13
updated: 2026-10-13
notes: "Nested roadmap child of 0012-roadmap-deprecation; the parent roadmap supplies the requirements (work/0012-roadmap-deprecation/roadmap.md:72,109-113). Dependency is `—`, so the child is ready and no override is needed. User resolved the three policy forks this child owns: (1) the manifest's concrete spelling becomes `manifest.md` with `phase: manifest`, and the legacy `roadmap.md`/`phase: roadmap` remains a recognized deprecated alias until 0003 migrates existing parents; (2) the `phase` value is renamed to `manifest`; (3) the `roadmap` vocabulary is retired fully — the section is retitled, and the parent-manifest backtrack label and the `stale: roadmap` token become `manifest`. Deliverable is docs/workflow.md plus docs/artifact-conventions.md only; the /roadmap command and agent retirement is 0002 and existing-parent migration is 0003."
parent: 0012-roadmap-deprecation
---

# Deprecation contract: the generic manifest replaces the special `roadmap` concept

## Problem

The recursive model shipped by `0011-recursive-bootstrap` made a node's
child-enumeration artifact the generic **manifest**, applicable at any depth
(`docs/workflow.md:28-98`). But the special **roadmap** concept survived it in
five concrete places: the `/roadmap` command, the `roadmap` agent, the
`roadmap.md` file spelling, the `phase: roadmap` frontmatter value, and the
"roadmap" vocabulary used throughout the authority documents — the
`## Roadmaps` section (`docs/workflow.md:174`), the writer's manifest definition
(`docs/workflow.md:75-81`), the derived-state row (`docs/workflow.md:1211`), and
the manifest template heading
(`docs/artifact-conventions.md:124`). `0011` deliberately left the rename and
retirement to this roadmap (`work/0011-recursive-bootstrap/0002-recursive-schema/spec.md:7,209-222`).

Two audiences pay for the residue. **Framework maintainers** keep two names for
one concept — a generic "decomposing node" and a special "roadmap" — so every
future surface must decide which spelling to use, and the derived-state,
backtrack-token, and guard surfaces fork on the distinction. **Adopters** must
learn a dedicated "roadmap" facility that the recursive model has subsumed, and
the docs present a special-case concept as if it were still primary. The
deprecation contract must fix the manifest's single spelling, its `phase` value,
and the derived-state and vocabulary consequences **before** the command surface
(`0002`) or the existing-parent migration (`0003`) can be specified, because both
consume this decision.

## Goals

- State the **manifest** as the sole child-enumeration artifact of any
  decomposing node, at every depth, with one concrete spelling.
- Fix that concrete spelling as **`manifest.md`** carrying **`phase: manifest`**
  at every depth.
- Define **`roadmap.md` / `phase: roadmap`** as a **recognized deprecated alias**
  so the seven existing decomposing parents remain valid decomposing nodes with
  no forced migration, while new manifests use the modern spelling only.
- Fix the **derived-state and artifact-presence** consequences: a manifest-only
  node derives the renamed container phase `manifest`, and own phase artifacts
  still take precedence over the manifest.
- Retire the **`roadmap` vocabulary** in the two authority documents: retitle
  the `## Roadmaps` section to the generic term, and rename the parent-manifest
  backtrack label and the `stale: roadmap` token to `manifest`.
- Keep the committed suite (`bash tests/run.sh`) green and introduce no new
  file name beyond the manifest spelling, no new command, agent, or skill, and
  no new dependency.

## Non-goals

- Retiring the **`/roadmap` command and the `roadmap` agent** and reconciling
  the documented command/agent/inventory surfaces (`README.md`, `AGENTS.md`,
  `template/AGENTS.md`, `tests/checks/40-inventory.sh`,
  `tests/checks/96-signature-sweep.sh`, the `workflow-lifecycle` skill, and the
  `docs/workflow.md` alias prose) — owned by `0002-command-retirement`.
- **Migrating the seven existing decomposing nodes** (`0003`–`0007`, `0010`,
  `0011`) or reconciling the fixtures and guards that load `roadmap.md`
  (`80-cycle-fixture`, `85-conflict-guards`, `87-backtrack-guards`) and
  `tests/README.md` — owned by `0003-parent-migration`.
- The broad **agent, command, and inventory surface sweep** of every remaining
  prompt to the recursive model (Roadmap 4) and the committed recursive-workflow
  guards (Roadmap 5).
- Changing the six-column `Children` table, the `conflicts-with` grammar, the
  `Depends on`/readiness contract, or any second state model, reference grammar,
  conflict taxonomy, or finding/severity vocabulary.
- Any change to the shipped decisions or artifacts of earlier shipped work, or
  any rewrite of a shipped item's files or `ship.md` signal.
- A new runtime dependency, service, network access, or toolchain.

## Users and stories

- **As a** framework maintainer, **I want** one generic child-enumeration
  artifact with a single spelling at every depth, **so that** the recursive model
  has no special-case concept to keep coherent across docs, agents, and guards.
- **As an** adopter, **I want** my existing `roadmap.md` parents to keep working
  while new plans use the generic spelling, **so that** retiring the concept
  requires no migration and no relearning.
- **As a** plan author, **I want** the manifest's file name and `phase` value to
  match the "manifest" vocabulary already used in the authority documents, **so
  that** the artifact kind is unambiguous at any depth.

## Acceptance criteria

1. **AC1 — Sole child-enumeration artifact.** Given a node that decomposes into
   children at any depth, when its child enumeration is recorded, then it is
   recorded in that node's **manifest**, and the documents define no other
   child-enumeration artifact and no separate top-level-only "roadmap" concept.

2. **AC2 — Concrete spelling and `phase` value.** Given the artifact
   conventions, when the manifest's concrete spelling is read, then the manifest
   is **`manifest.md`** carrying **`phase: manifest`** at every depth, and the
   manifest template is titled and described by that spelling.

3. **AC3 — Legacy alias is recognized.** Given a legacy decomposing node whose
   manifest is still a `roadmap.md` carrying `phase: roadmap`, when the node is
   classified or its children are read, then it is accepted as a manifest — the
   legacy spelling is a recognized deprecated alias — so the node remains a
   valid decomposing node without migration, and the documents name the old
   spelling only as deprecated.

4. **AC4 — New manifests use the modern spelling.** Given a newly authored
   decomposing node, when its manifest is written, then it is `manifest.md` with
   `phase: manifest`; the deprecated spelling is never used for a new manifest.

5. **AC5 — Precedence when both spellings are present.** Given one node
   directory that contains both `manifest.md` and `roadmap.md`, when the node is
   classified, then `manifest.md` is authoritative and the node is derived from
   it, while the redundant legacy file is reported as an integrity inconsistency
   and is never silently merged, dropped, or auto-repaired.

6. **AC6 — Derived container phase.** Given the derived-state authority, when a
   node carries a manifest (either spelling) and no own phase artifacts, then it
   derives the container phase **`manifest`** (the renamed container phase), and
   a node's own phase artifacts still take precedence over the manifest at every
   depth.

7. **AC7 — `phase` value set recognizes the rename.** Given the frontmatter
   documentation, when the `phase` value set is read, then it lists `manifest`
   in place of `roadmap`, and a legacy `roadmap.md`'s `phase: roadmap` is
   recognized as the deprecated equivalent of `phase: manifest` for derivation.

8. **AC8 — Parent-manifest label and `stale:` token renamed.** Given the
   backtracking and derived-state vocabulary, when the parent-manifest
   reverse-edge target label and its `stale:` token are read, then they use
   `manifest` (the `roadmap` label and the `stale: roadmap` token are retired),
   and the `stale: manifest` token maps to `spec` when a child's phase is
   derived.

9. **AC9 — Vocabulary retires to the generic term.** Given the two authority
   documents, when the "roadmap" vocabulary is read, then the `## Roadmaps`
   section is retitled to the generic decomposing-node/manifest term, the
   "roadmap" term appears only in a historical/backward-compatibility note, and
   no document surface defines a standalone "roadmap" concept.

10. **AC10 — Extend, do not fork.** Given the change set, when it is inspected,
    then it introduces no second state model, reference grammar, conflict
    taxonomy, finding/severity vocabulary, or new dependency edge, and the
    six-column `Children` table and the shipped `conflicts-with` grammar are
    unchanged.

11. **AC11 — Backward compatibility.** Given the repository after the change,
    when a one-segment standalone item, an existing legacy decomposing parent,
    and any item whose `ship.md` is present are read, then all remain valid with
    no forced migration, no artifact rewrite, and no spent-number or `ship.md`
    change.

12. **AC12 — Scope.** Given the change set, when its scope is inspected, then
    `docs/workflow.md` and `docs/artifact-conventions.md` carry the contract, and
    the `/roadmap` command and `roadmap` agent retirement and the existing-parent
    migration and fixtures are untouched.

13. **AC13 — Suite stays green.** Given the repository after the change, when
    the configured test command (`bash tests/run.sh`) runs, then it passes; no
    new command, agent, or skill is introduced, and no documented inventory
    count changes.

## Edge cases

- **Legacy-only parent.** A node holding `roadmap.md` with `phase: roadmap` and
  no `manifest.md` is a valid decomposing node that derives the `manifest`
  container phase (AC3, AC6); nothing about it is rewritten.
- **Both spellings present.** `manifest.md` is authoritative; the redundant
  `roadmap.md` is an integrity inconsistency, reported and never auto-repaired
  (AC5).
- **Mismatched spelling and value.** A `manifest.md` carrying `phase: roadmap`,
  or a `roadmap.md` carrying `phase: manifest`, travels against the expected
  pairing; it is reported as an inconsistency rather than silently normalized,
  and no content is rewritten.
- **Modern-only node.** A node holding `manifest.md` with `phase: manifest` is
  the primary shape at every depth.
- **Deep nesting.** The manifest spelling, `phase` value, alias recognition, and
  precedence rules are identical at every depth; depth changes no rule.
- **Hybrid node.** A node may carry its own phase artifacts and a manifest; the
  contract fixes the manifest's spelling and the derived container phase, not how
  the node's own progress derives (own artifacts still win).
- **Shipped parent.** An item whose `ship.md` is present is out of scope for any
  rewrite or re-scoping; its manifest and signal are preserved as committed.
- **Standalone item.** A one-segment item with no manifest is unaffected and
  keeps its existing derivation.
- **`.gitkeep`-only child.** A reserved, not-started child remains valid and is
  not a manifest.
- **Concurrency.** Not applicable: this contract changes committed documents
  only and introduces no runtime state or shared resource.

## Open questions

- [x] **Manifest spelling** — resolved (user): `manifest.md` is the concrete
  spelling; the legacy `roadmap.md` remains a recognized deprecated alias until
  `0003` migrates existing parents.
- [x] **`phase` value** — resolved (user): rename to `manifest`.
- [x] **Vocabulary retirement depth** — resolved (user): retire the `roadmap`
  term fully, retitle the section, and rename the label and token.
- [ ] **Deferred — production surfaces that name the retired spelling/token.**
  Which child or successor reconciles the surfaces that functionally name the
  old spelling or token: the `architect` writer, the `status` agent/command
  decomposing-node detection, the `product` agent's parent-manifest resolution,
  and the `stale: roadmap` mentions in agent prose and the fixtures/guards that
  load `roadmap.md`. Owner: `0002-command-retirement` (writer and command/agent
  surfaces), `0003-parent-migration` (fixtures/guards and existing parents), and
  Roadmap 4 (the broad agent sweep). — needed by: their `/spec`.
- [ ] **Deferred — existing-parent migration timing.** Whether and when the
  seven existing decomposing nodes migrate from `roadmap.md` to `manifest.md`.
  Owner: `0003-parent-migration`. — needed by: `0003` `/spec`.

## Dependencies and constraints

- **Ready.** The parent roadmap lists this child as `Depends on: —`
  (`work/0012-roadmap-deprecation/roadmap.md:72`); it is the keystone the other
  two children consume (`work/0012-roadmap-deprecation/roadmap.md:82-87`), so no
  override is needed.
- **Consumes the recursive model and schema.** The generic manifest concept, the
  recursive reference grammar, per-level allocation, and the `.gitkeep`
  reservation are fixed by `0011-recursive-bootstrap`
  (`work/0011-recursive-bootstrap/0001-recursive-model/spec.md`,
  `work/0011-recursive-bootstrap/0002-recursive-schema/spec.md`). This item
  retires the special-case name and value; it defines no second contract.
- **Deliverable surfaces.** Per the child scope, the contract is authored in
  `docs/workflow.md` ("The recursive lifecycle model" including "Where
  decomposition is authored and recorded", "Roadmaps", "Derived state") and
  `docs/artifact-conventions.md` (the manifest template and "Work item
  references"). Because the deliverable is the framework's own documents, the
  acceptance criteria name the surfaces that must carry the contract; they
  specify required content, not implementation choices.
- **Downstream consumers (explicit boundary).** Renaming the spelling and value
  and retiring the token touches surfaces outside this child: the `/roadmap`
  command and `roadmap` agent and the documented inventories (`0002`), the
  fixtures/guards and the seven existing parents (`0003`), and the agent prose
  that names the concept (Roadmap 4, the surface sweep). They are named so the
  seam is visible; this child writes only the two documents and does not edit
  them.
- **Legacy alias keeps the suite green.** Because the legacy `roadmap.md` /
  `phase: roadmap` remains recognized (AC3), the committed fixtures that carry
  the old spelling (for example `tests/fixtures/cyclic-roadmap/roadmap.md`,
  pinned by `tests/checks/80-cycle-fixture.sh:30`) stay valid and the suite stays
  green without a fixture change; `0003` owns any migration.
- **No inventory change.** This child adds or removes no agent, command, or
  skill, so the `README.md` Layout counts and the `40-inventory.sh` and
  `96-signature-sweep.sh` agreements are untouched by it.
- **Sibling boundaries.** `0002-command-retirement` owns the command/agent
  removal and inventory reconciliation; `0003-parent-migration` owns the
  existing parents and fixtures; the broad agent sweep is Roadmap 4 and the
  committed recursive guards are Roadmap 5. This child fixes only the contract
  they consume.
- **Backward compatibility.** A one-segment standalone item and every existing
  committed `work/` item remain valid; no migration, rename, spent-number change,
  or `ship.md` change occurs.
- **Framework-internal change only.** Documents and prompts; no runtime
  dependency, service, or new toolchain.
- **Assumption — the contract is one feature.** Fixing the spelling, the
  `phase` value, the alias recognition, the derived-state row, the vocabulary,
  and the tokens is one coherent contract change, specified and reviewable on
  its own; if it proves too large at `/plan`, the roadmap's sanctioned remedy is
  `/roadmap revise 0012-roadmap-deprecation` to add siblings at the same level,
  not to nest.
