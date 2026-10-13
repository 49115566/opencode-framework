---
feature: 0011-recursive-bootstrap/0002-recursive-schema
phase: spec
status: final
created: 2026-10-12
updated: 2026-10-12
notes: "Nested roadmap child of 0011-recursive-bootstrap; the directory held only .gitkeep and the parent roadmap supplies the requirements (work/0011-recursive-bootstrap/roadmap.md:104). Dependency 0001-recursive-model is satisfied (its ship.md is present with no reopened: marker, so the child is ready); no override is needed. User resolved the four schema forks: (1) the manifest is a generic concept and roadmap.md remains its recognized shipped concrete spelling at every node — no new file name, no new phase value, no artifact-presence row; the rename/retirement stays in Roadmap 2; (2) frontmatter parent: names the immediate parent's canonical reference (one segment at depth 2, the parent's full multi-segment reference at depth >= 3), with the full ancestor chain derivable from the directory path; (3) the conflicts-with grammar is preserved unchanged and every-level conflict targets are deferred to Roadmap 3; (4) the deliverable is docs/artifact-conventions.md plus the minimal docs/workflow.md schema restatements, leaving readiness/derived-state/status to 0004 and the writer to 0003."
parent: 0011-recursive-bootstrap
---

# Recursive work-item schema, references, and sequence allocation

## Problem

`0001-recursive-model` fixed the recursive model — a node may decompose into
children to unbounded depth and the six-phase cycle applies uniformly at every
node — but the **schema that represents it** does not exist yet. The committed
artifact conventions still cap nesting at two levels: the canonical reference
grammar is `NNNN-slug` or `NNNN-slug/MMMM-slug`, explicitly a maximum
(`docs/artifact-conventions.md:68-98`); sequence allocation defines exactly one
per-parent level (`docs/artifact-conventions.md:630-647`); the frontmatter
`parent:` field names only a top-level `<NNNN-slug>` (`docs/artifact-conventions.md:24,35-36`);
and the child-enumeration artifact exists only as a **top-level** roadmap parent
(`docs/workflow.md:151-158`). The cost is concrete: a node at depth three or
deeper has **no valid canonical reference the grammar accepts**, no defined
local-number allocation rule, no schema-sanctioned parent pointer, and no
defined spelling for its child enumeration. The model says such a node is legal;
the schema cannot name it. Two audiences pay: **framework maintainers**, who
cannot represent a genuinely nested decomposition, and **adopters**, who would
inherit conventions that contradict the documented model. The schema must
generalize the existing references, allocation, frontmatter, and manifest from a
two-level maximum to arbitrary nesting **without** forking the shipped grammar
or requiring any existing `work/` content to migrate.

## Goals

- Generalize the canonical reference to a **recursive path** of arbitrary depth,
  keeping the one-segment form unchanged and the two-segment form a special case
  rather than a maximum.
- Apply **per-level sequence allocation** (top-level and per-parent) at **every**
  depth, scoping each level's local `MMMM` to its immediate parent.
- Define the frontmatter `parent:` **chain**: the immediate parent's canonical
  reference, with the full ancestor chain derivable from the directory path.
- Define the **manifest** as the generic child-enumeration source for any
  decomposing node, keeping `roadmap.md` as its recognized shipped concrete
  spelling at every depth — no new file name, no new `phase` value, no new
  artifact-presence row.
- Reserve each child directory with `.gitkeep` at every level.
- **Preserve** the six-column positional `Children` table and the shipped
  `conflicts-with` grammar unchanged.
- Keep the committed suite green and every documented inventory count unchanged.
- Preserve backward compatibility: a one-segment standalone item and every
  existing two-level roadmap parent/child remain valid with **no forced
  migration**, and no second reference grammar or state model is introduced.

## Non-goals

- The concrete recursive writer — its command/agent wiring and handoff — owned by
  `0003-recursive-writer`.
- Readiness, derived state, the phase/progress derivation of a node from its
  children, and the `/status` tree report — owned by `0004-recursive-readiness`.
- Generalizing `conflicts-with` targets to arbitrary depth ("`conflicts-with` at
  every level") — a successor roadmap (Roadmap 3,
  `work/0011-recursive-bootstrap/roadmap.md:137-139`).
- Renaming, retiring, or migrating `roadmap.md` and `/roadmap`, and deciding the
  treatment of existing roadmap parents (including `0010` and `0011`) — a
  successor roadmap (Roadmap 2,
  `work/0011-recursive-bootstrap/roadmap.md:133-136`).
- Simultaneous-work guarantees under recursion: per-level duplicate detection
  across a merge, merge-integrity and renumbering for recursive trees, and
  parallel plan publication — a successor roadmap.
- The agent/command/inventory surface sweep — a successor roadmap.
- Committed fixtures, agreement areas, or mutation coverage pinning the
  recursive schema — a successor roadmap; the committed suite stays green as a
  constraint, not a deliverable.
- A new runtime dependency, service, network access, or toolchain.
- A second state model, reference grammar, conflict taxonomy, or finding/
  severity vocabulary; the schema reuses the shipped ones.
- Any change to the shipped decisions or artifacts of `0002-agentic-roadmaps`,
  `0003/0002-readiness-ship-state`, `0005-merge-conflict-workflow`,
  `0006-parallel-plan-conflicts`, or `0007-phase-backtracking`.
- Automatic orchestration, scheduling, delivery dates, or parallel-agent
  execution.

## Users and stories

- **As a** framework maintainer, **I want** a canonical reference that names a
  node at any depth, **so that** a genuinely nested decomposition can be
  addressed by every command and artifact exactly as a shallow one is.
- **As a** plan author, **I want** each level to allocate its own local child
  numbers and reserve its child directories, **so that** a decomposition at any
  depth stays collision-free and independently workable.
- **As a** framework maintainer, **I want** a single generic child-enumeration
  artifact (the manifest) with one spelling at every node, **so that** I do not
  learn a special top-level-only roadmap concept.
- **As an** adopter, **I want** my existing one-segment items and two-level
  roadmap parents to keep working and the `Children`/`conflicts-with` grammar to
  be unchanged, **so that** adopting the recursive schema requires no migration
  and no re-learning of the conflict grammar.

## Acceptance criteria

1. **AC1** — Given the artifact conventions, when the canonical-reference
   grammar is read, then a reference is a recursive path of one or more
   dash-slug segments (`NNNN-slug` at the top level, then `/<MMMM-slug>` at each
   further level, arbitrarily deep), the one-segment standalone form is
   unchanged, and the two-segment form is stated as a special case rather than a
   maximum depth.

2. **AC2** — Given a canonical reference of any depth, when it is resolved, then
   it maps to the directory `work/<item-ref>/` by following its nested segments,
   and a nested child's artifacts set `feature:` to the full canonical
   reference and `parent:` to its immediate parent (per AC4).

3. **AC3** — Given a node at any depth, when local child numbers are allocated,
   then each level uses a 4-digit local `MMMM` scoped to its **immediate** parent
   (the greatest 4-digit prefix ever committed under that parent plus one, never
   reused within it), applying the same allocation contract at every level
   independent of the top-level sequence and of other nodes.

4. **AC4** — Given a nested child's artifact, when its frontmatter `parent:` is
   read, then it names the **immediate** parent's canonical reference — one
   segment at depth two (`NNNN-slug`) and the parent's full multi-segment
   reference at depth three or deeper — the full ancestor chain is derivable from
   the directory path, and a standalone item omits `parent:` as before.

5. **AC5** — Given a node that decomposes into children, when its child
   enumeration is read, then it is recorded in that node's **manifest**, and the
   manifest's shipped concrete spelling is `roadmap.md` with `phase: roadmap` at
   **every** depth; the manifest is stated as the generic enumeration source for
   any decomposing node, and no new file name, `phase` value, or
   artifact-presence row is introduced.

6. **AC6** — Given a manifest, when its `Children` table is read, then the
   six-column positional header is preserved unchanged — `Depends on` at
   pipe-field 5 and `conflicts-with` at pipe-field 6 — each row's
   `Canonical reference` resolves to that child's directory, and a `Depends on`
   cell names only sibling local ids in the same table with the stored graph
   acyclic.

7. **AC7** — Given a `conflicts-with` cell, when its target grammar is read, then
   it is preserved unchanged from the shipped grammar (the two-level
   `SiblingOrItemRef` and exact surface-path forms, the reference-vs-path
   discriminator, and the sibling-first precedence), and generalizing targets to
   arbitrary depth is explicitly deferred to the successor roadmap that owns
   "`conflicts-with` at every level".

8. **AC8** — Given a decomposing node, when its children are created, then each
   child directory is reserved with a `.gitkeep` at that level
   (`work/<parent-ref>/<MMMM-slug>/.gitkeep`), and this reservation applies at
   every depth, not only the top level.

9. **AC9** — Given the repository after the change, when a one-segment standalone
   item or an existing two-level roadmap parent/child is read, then it remains
   valid under the recursive schema with no forced migration; the schema
   generalizes the existing conventions rather than forking them and introduces
   no second reference grammar, no second state model, no new dependency edge,
   and no new conflict class.

10. **AC10** — Given the repository after the change, when the project's
    configured test command runs, then it passes; no new command, agent, or
    skill is introduced, no documented inventory count changes, and the six core
    phase commands, the `phase` value set, and the `Children`/`conflicts-with`
    and readiness contracts are unchanged (`tests/checks/80-cycle-fixture.sh` and
    `tests/checks/85-conflict-guards.sh` stay green).

11. **AC11** — Given the change set, when its scope is inspected, then the
    recursive schema is stated in `docs/artifact-conventions.md` and the minimal
    `docs/workflow.md` restatements of the reference grammar and work-item layout
    are made consistent with it; the concrete writer, readiness/derived-state/
    `/status`, and roadmap deprecation/migration surfaces are untouched and no
    surface states a competing reference grammar or manifest definition.

## Edge cases

- **Deep chain.** A node at depth three or deeper is a valid instance: its
  canonical reference is a longer recursive path and its local `MMMM` is scoped
  to its immediate parent; the schema sets no special behavior at any depth.
- **One-segment standalone item.** `NNNN-slug` remains valid and is a special
  case of the recursive path, not a separate grammar; it omits `parent:` and has
  no `MMMM` segment.
- **Existing two-level roadmap parent/child.** Today's `0011` parents and their
  nested children remain valid exactly as committed; no rename and no migration.
- **Hybrid node.** A node may carry its own phase artifacts and a manifest at the
  same time; the schema fixes how its children are named, not how its progress
  derives (the latter is `0004`).
- **`.gitkeep`-only child.** A child directory holding only `.gitkeep` is a
  reserved, not-started child and is representable at any depth.
- **Repeated local id text at different levels.** The same `MMMM-slug` text under
  two different parents names two distinct nodes, because identity is the full
  canonical path, not the trailing segment.
- **Bare local id resolution.** A bare `MMMM-slug` in a node's own `Children`
  table keeps its sibling-first precedence and is therefore deterministic even
  when a deeper node elsewhere shares the text.
- **Malformed recursive reference.** A trailing slash, an empty segment, or a
  non-conforming segment is not a valid reference and is not treated as one.
- **`conflicts-with` target deeper than two segments.** The shipped grammar is
  preserved (AC7), so such a target is out of scope for this item and is covered
  by the successor roadmap; it is a documented seam, not silently accepted.
- **Per-parent number exhaustion or collision.** Allocation follows the
  existing "greatest ever committed plus one, never reused" contract at each
  level; cross-branch duplicate detection for recursive trees is a successor
  roadmap's concern.
- **Shipped node.** An item whose `ship.md` is present is out of scope for
  re-scoping or re-sequencing, as under the shipped backtracking model.

## Open questions

- [x] **Manifest representation** — resolved (user): the manifest is a generic
  concept and `roadmap.md` remains its recognized shipped concrete spelling at
  every node; no new file/phase value; the rename/retirement is Roadmap 2.
- [x] **`parent` chain shape** — resolved (user): the immediate parent's
  canonical reference; the full chain is derived from the directory path.
- [x] **`conflicts-with` at depth** — resolved (user): preserve the grammar
  unchanged; every-level conflict targets are deferred to Roadmap 3.
- [x] **Affected authority surfaces** — resolved (user):
  `docs/artifact-conventions.md` plus the minimal `docs/workflow.md` schema
  restatements; writer and readiness surfaces untouched.
- [ ] **Deferred — concrete manifest file name and retirement.** Whether the
  enumeration artifact is ever renamed to a non-`roadmap.md` spelling and how
  existing roadmap parents are migrated are Roadmap 2 decisions. — owner: Roadmap 2
  (roadmap deprecation and migration), needed by: Roadmap 2 `/spec`.
- [ ] **Deferred — `conflicts-with` targets at arbitrary depth.** The
  generalization of the conflict-target reference form to recursive paths is
  Roadmap 3's concern. — owner: Roadmap 3 (simultaneous work under recursion),
  needed by: Roadmap 3 `/spec`.
- [ ] **Deferred — how a node's phase/progress derives from its children.** The
  schema names the children; the derivation rule and the `/status` tree report
  are `0004-recursive-readiness`. — owner: `0004-recursive-readiness`, needed
  by: `0004` design.

## Dependencies and constraints

- **Ready.** The parent roadmap lists this child as `Depends on:
  0001-recursive-model` (`work/0011-recursive-bootstrap/roadmap.md:104`); that
  sibling is shipped (`work/0011-recursive-bootstrap/0001-recursive-model/ship.md`
  present, no `reopened:` marker), so the dependency is satisfied and no override
  is needed.
- **Consumes the model.** The recursive vocabulary and rules — unbounded depth,
  hybrid nodes, `tasks.md` entries are not nodes — are fixed by `0001`
  (`work/0011-recursive-bootstrap/0001-recursive-model/spec.md`, AC1–AC11); this
  item turns that model into references, allocation, frontmatter, and the
  manifest.
- **Deliverable surfaces.** Per the child scope, the schema is authored in
  `docs/artifact-conventions.md` (its "Work item references", "Sequence
  allocation", and "Templates" sections) and the minimal `docs/workflow.md`
  restatements of the reference grammar and work-item layout are reconciled with
  it (`work/0011-recursive-bootstrap/roadmap.md:104`). Because the deliverable is
  the framework's own documents, the acceptance criteria name the surfaces that
  must carry the schema; they specify required content, not implementation
  choices.
- **Extend, do not fork.** The schema generalizes the shipped reference grammar
  (`docs/artifact-conventions.md:68-98`), the per-scope sequence allocation
  (`docs/artifact-conventions.md:630-647`), the six-column positional `Children`
  table and `conflicts-with` grammar (`docs/workflow.md:229-268`), and the
  manifest's shipped spelling (`docs/workflow.md:151-158`). It defines no second
  reference grammar, state model, conflict taxonomy, or finding vocabulary.
- **Single-source guards must stay green.** `tests/checks/80-cycle-fixture.sh`
  pins the positional `Children` header and the `CYCLIC-DEP` rule;
  `tests/checks/85-conflict-guards.sh` pins the declaration model and grammar;
  `tests/checks/10-readiness.sh`, `tests/checks/20-lifecycle.sh`,
  `tests/checks/40-inventory.sh`, and `tests/checks/96-signature-sweep.sh` pin
  the readiness literal, the phase set and routing, the inventory counts, and the
  command signatures. This item must restate none of their pinned literals and
  must keep them green.
- **Suite never reads live `work/**`.** The committed suite is read-only and
  fresh-clone-clean (`tests/README.md:30-31`); any guard is fixture-based, and
  the committed guards are deferred to a successor roadmap, so this item adds no
  test file.
- **Sibling boundaries.** The concrete writer is `0003-recursive-writer`;
  readiness/derived-state/`/status` is `0004-recursive-readiness`; roadmap
  deprecation and migration is Roadmap 2; simultaneous-work guarantees and
  every-level conflicts are Roadmap 3; the surface sweep is Roadmap 4; committed
  guards are Roadmap 5. This item fixes only the schema they consume.
- **Backward compatibility.** A one-segment standalone item and every existing
  committed `work/` item remain valid; no migration, rename, or spent-number
  change occurs (`work/0011-recursive-bootstrap/roadmap.md:83-85`).
- **Assumption — the bootstrap child is a single feature.** References,
  allocation, the `parent` chain, the manifest, and `.gitkeep` reservation are one
  coherent schema change, specified and reviewable on its own; if it proves too
  large at `/spec`, the roadmap's sanctioned remedy is
  `/roadmap revise 0011-recursive-bootstrap` to add siblings at the same level,
  not to nest.
- **Framework-internal change only.** Docs and prompts; no runtime dependency,
  service, or new toolchain.
