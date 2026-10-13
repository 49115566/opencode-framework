---
feature: 0011-recursive-bootstrap/0003-recursive-writer
phase: design
status: final
created: 2026-10-12
updated: 2026-10-12
conflicts-with: "docs/workflow.md, .opencode/agent/roadmap.md, .opencode/command/roadmap.md"
parent: 0011-recursive-bootstrap
---

# Design — Recursive decomposition writer

## Summary

Make the **planning step** (`/plan`, `architect`) the recursive writer: for a
node that decomposes, it authors or revises the node's manifest
(`work/<item-ref>/roadmap.md`) and reserves each child directory with a
`.gitkeep`, at **any** depth, autonomously and without writing a child phase
artifact — while keeping `design.md`/`tasks.md` authoring for a genuine single
feature. `/roadmap` is demoted to a **thin deprecated alias** (a brand-new
top-level node via `/roadmap <initiative>`, revision via
`/roadmap revise <item-ref>`), and the writer contract is stated once in
`docs/workflow.md`, which the agent and command surfaces reference rather than
restate.

## Approach

The deliverable is framework prompt/doc config, so the "interface" is a document
contract. The design folds the shipped `roadmap` agent's create/revise behavior
(`.opencode/agent/roadmap.md:76-172`, unchanged by `0001`/`0002`) into the
planning step and re-points the `/roadmap` surface at it as a deprecated alias.
Five files change; no command, agent, skill, `phase` value, artifact name,
artifact-presence row, or inventory count is added.

**1. `docs/workflow.md` is the single authority for the writer contract.** Four
places carry it, plus one consistency touch:

- `### Where decomposition is authored and recorded` (lines 66-74) — replace the
  `0003`-deferral sentence (`:72-74`, "The concrete writer's command/agent wiring
  and handoff are owned by `0003-recursive-writer`") with the concrete wiring:
  the planning step (`/plan`, `architect`) authors/revises a decomposition at any
  depth; `/roadmap` is the thin deprecated alias; the writer is autonomous,
  writes no child phase artifact, always authors the manifest for a decomposing
  node and MAY additionally author the node's own `design.md`/`tasks.md` (hybrid);
  a genuine single feature still gets `design.md`/`tasks.md` and no manifest; the
  handoff publishes the node's plan state then routes to each ready child. The
  manifest's shape and the revision algorithm are **referenced**
  (`docs/artifact-conventions.md`, `### Revising a roadmap`), never restated.
- `### 2. Design — /plan <item-ref>` (lines 411-431) — extend Purpose, Entry,
  Process, Exit, Artifact, and Next to describe the two planning paths
  (single-feature design vs. decomposition) and the decomposition handoff.
- `### Revising a roadmap` (lines 303-388) — generalize from "the parent" to a
  decomposing node at any depth, and reconcile the sole-writer claim: the
  planning step (or its `/roadmap` alias) is the sole writer of a `roadmap.md`.
  The four operations, the final-state validation predicate, the `stale: roadmap`
  marking, the shipped-child refusal, and the no-op rule are preserved
  unchanged.
- `## Plan publication` (lines 520-566) — broaden the plan definition and the
  `spec.md`+`design.md` precondition so a decomposing node's plan (manifest +
  own `spec.md`/`design.md`/`tasks.md` when present + child directory
  reservations) is publishable, including a pure container's manifest-only plan,
  **without** weakening the ordinary single-feature precondition.
- `## Roadmaps` opening (line 165) and the routing-heuristic `/roadmap` bullet
  (lines 1239-1244) — a minimal consistency touch so they name the planning step
  as the author and `/roadmap` as the deprecated alias, with no competing writer
  grammar.

**2. The two planning paths.** `/plan <item-ref>` selects a path from the node's
committed state and the architect's recon (the shipped roadmap agent's "decide
whether it decomposes" judgment, folded in):

- *Single-feature path* (unchanged): the node's `spec.md` exists and is
  unambiguous → author `design.md`/`tasks.md`, no manifest.
- *Decomposition path*: the node decomposes. Deterministic facilitators — an
  existing `work/<item-ref>/roadmap.md` selects **revise**; a node with **no**
  own `spec.md` (a `.gitkeep`-reserved child or a pure container) selects
  **author**, because a genuine single feature is reached through `/spec` →
  `/plan` and therefore always has a `spec.md`. Authoring writes the manifest and
  each `work/<item-ref>/<MMMM-slug>/.gitkeep` and no child phase artifact;
  revision applies the four operations of `### Revising a roadmap`. The
  decomposition path is reachable **without** the node's own `spec.md` and writes
  none.

**3. The handoff.** For a decomposition the architect's handoff names the
manifest and the child directories, and recommends `/ship plan <item-ref>` to
publish the node's plan state, then `/spec <child-ref>` for each ready child.

**4. Surfaces.** `.opencode/agent/architect.md` and `.opencode/command/plan.md`
carry the planning-step behavior; `.opencode/agent/roadmap.md` and
`.opencode/command/roadmap.md` carry the thin deprecated alias. All four defer
the normative rules to the `docs/workflow.md` authority and keep their exact
usage strings.

## Alternatives considered

- **Option A (chosen) — fold the writer into the planning step; demote
  `/roadmap` to a thin alias; single-source the contract in `docs/workflow.md`.**
  Pros: matches the user-resolved model (`0001`'s writer surface decision) and
  AC1/AC5/AC9; the smallest diff that reuses the shipped manifest, four-operation
  revision, and `stale: roadmap` machinery; no new command, agent, skill, or
  inventory change (AC10). Cons: `/plan` now has a two-path entry that a reader
  must follow; mitigated by the deterministic selection rule and the single
  authority.
- **Option B — make `/roadmap` the recursive writer at any depth and leave
  `/plan` unchanged.** Rejected: `0001` resolved (user) that `/plan`
  (`architect`) authors and `/roadmap` is the deprecated alias; AC1 and AC9 fix
  this, so `/roadmap` cannot be the primary writer.
- **Option C — add a sub-mode or flag (`/plan decompose <item-ref>`,
  `--decompose`).** Rejected: `tests/checks/96-signature-sweep.sh:40,270-281`
  pins the exact `/plan <item-ref>` usage string and every command's signature;
  AC10 forbids a new command or signature change; and a sub-mode is a writer
  surface the model does not define.
- **Option D — keep `/roadmap` as a full second writer and have `/plan` delegate
  to it.** Rejected: two surfaces stating the writer grammar is exactly the
  "competing writer grammar" AC11 forbids; the alias must be thin and defer.
- **Option E — a new dedicated writer command/agent.** Rejected: AC10 forbids a
  new command, agent, or skill and any documented inventory count change
  (`tests/checks/40-inventory.sh`).

## Interfaces and data model

### Writer contract (`docs/workflow.md`, `### Where decomposition is authored and recorded`)

Replaces the current deferral sentence (lines 72-74). Required normative
statements, composed by reference:

- The **planning step** (`/plan`, `architect`) is the writer for a decomposition
  at any depth.
- `/roadmap` is the **thin deprecated alias**: `/roadmap <initiative>` creates a
  brand-new top-level decomposing node (the next top-level `NNNN`);
  `/roadmap revise <item-ref>` revises an existing decomposition at any depth.
- For a decomposing node the writer authors the manifest
  `work/<item-ref>/roadmap.md` (`feature:` = the node's full canonical
  reference, `phase: roadmap`) and reserves each child
  `work/<item-ref>/<MMMM-slug>/` with a `.gitkeep`; `MMMM` is allocated per the
  immediate parent per `docs/artifact-conventions.md` → "Sequence allocation",
  and each `Canonical reference` is the node's reference with the child segment
  appended. The manifest, its six-column `Children` table, its `Depends on`
  acyclicity, and its `conflicts-with` grammar are those of
  `docs/artifact-conventions.md` → "`roadmap.md` — the manifest of a decomposing
  node" (referenced, not restated).
- The writer writes **no child phase artifact** — each new child directory holds
  only `.gitkeep`.
- The writer is **autonomous** (no pre-write approval gate); the user reviews
  the committed artifact.
- A genuine single feature still produces `design.md`/`tasks.md` and no manifest;
  a decomposing node always produces the manifest and MAY additionally produce
  its own `design.md`/`tasks.md` (hybrid), never forced on a pure container.
- The handoff publishes the node's plan state via `/ship plan <item-ref>` and
  then routes to `/spec <child-ref>` for each ready child.
- Revision and publication are `### Revising a roadmap` and `## Plan
  publication`; the writer adds no second revision or publication grammar.

### `/plan` two-path entry (`docs/workflow.md`, `### 2. Design`)

- **Entry**: single-feature path — the node's `spec.md` exists and is
  unambiguous (unchanged); decomposition path — the node is one that decomposes
  (an existing manifest, or the planning judgment) and the node's own `spec.md`
  is **not required**. A genuine single feature remains reachable through the
  ordinary path that requires its `spec.md`.
- **Process**: recon; for the decomposition path author/revise the manifest and
  child reservations and write no child phase artifact; for the single-feature
  path write `design.md`/`tasks.md`.
- **Exit/Artifact**: `design.md`/`tasks.md` (single feature) and/or the manifest
  `roadmap.md` plus child reservations (decomposition), with the node's own
  `design.md`/`tasks.md` when hybrid.
- **Next**: `/ship plan <item-ref>`; for a decomposing node the handoff also
  names `/spec <child-ref>` for each ready child. The reverse edges and the
  plan-publication revision flow are unchanged.

### Revision at any depth (`docs/workflow.md`, `### Revising a roadmap`)

- `<item-ref>` must resolve to a node that has a manifest
  (`work/<item-ref>/roadmap.md`); a reference with no manifest is refused. The
  **parent-only** restriction is removed: a decomposition at any depth is
  revised identically.
- The sole-writer sentence (line 309) becomes: the planning step (`/plan`,
  `architect`) — or its deprecated `/roadmap` alias — is the sole writer of a
  `roadmap.md`; no other phase writes one. A child phase that finds the
  decomposition wrong records a finding and recommends the revise route; it
  never edits the manifest.
- The four operations, the final-state validation predicate, `stale: roadmap`
  marking, the shipped-child refusal, and the no-op rule are unchanged.

### Plan publication (`docs/workflow.md`, `## Plan publication`)

- **Plan definition** (lines 522-523): for a single-feature item, its
  requirements and design artifacts (`spec.md`, `design.md`, `tasks.md` when
  present); for a decomposing node, its manifest (`roadmap.md`), its own
  `spec.md`/`design.md`/`tasks.md` when present, and its child directory
  reservations.
- **Preconditions** (lines 532-535): the item has completed `/plan` — either
  `spec.md` and `design.md` exist (a single-feature plan), or `roadmap.md`
  exists (a decomposing node's plan, own artifacts included when present). The
  no-`review.md` exception and the no-secrets rule are unchanged. The ordinary
  single-feature precondition is **not** weakened.
- **Commit and PR** (lines 541-544): plan mode commits the node's own plan state
  under `work/<item-ref>/` — the manifest, its own phase artifacts when present,
  and the child `.gitkeep` reservations — as one conventional commit; it does not
  sweep a child's own in-flight phase artifacts into the parent's publication (a
  child publishes its own plan). The `/build` plan gate is unaffected: a
  manifest-only node has no `tasks.md` (so `/build` never runs on it) and a
  hybrid node has its own `design.md`, which the gate already checks.

### Surfaces (agent and command)

- `.opencode/agent/architect.md` — mission broadened to `design.md`/`tasks.md`
  and/or the manifest; a two-path process; the decomposition rules (any depth,
  no child phase artifact, autonomous, hybrid) with the produced manifest
  satisfying the manifest quality bar by reference; inputs note the no-`spec.md`
  case; the handoff block gains the decomposition variant. Normative rules
  reference `docs/workflow.md`, not restate.
- `.opencode/command/plan.md` — describe the decomposition path and handoff;
  **keep** the exact `Usage: /plan <item-ref>` string pinned by
  `tests/checks/96-signature-sweep.sh`.
- `.opencode/agent/roadmap.md` — demote to the thin deprecated alias surface;
  create a brand-new top-level node; generalize revise to any depth; reconcile
  the sole-writer self-claim; write no child phase artifact.
- `.opencode/command/roadmap.md` — a deprecation note naming the planning step;
  generalized revise; **keep** the exact
  `Usage: /roadmap <initiative> | /roadmap revise <item-ref>` string.

### Declared conflicts

`conflicts-with` is exactly the parent `Children` row's cell
(`work/0011-recursive-bootstrap/roadmap.md:105`) — `docs/workflow.md`,
`.opencode/agent/roadmap.md`, `.opencode/command/roadmap.md` — so the child's
declared set (the union of own and cell) does not trigger a spurious
`DRIFT-FACT`. `.opencode/agent/architect.md` and `.opencode/command/plan.md`
are affected surfaces but are deliberately **not** declared: declaring a set
unequal to the parent cell would itself be reported as declaration drift. The
declaration is advisory and adds no readiness edge.

### Backward compatibility

No command, agent, skill, `phase` value, artifact name, artifact-presence row,
reference, or inventory count changes. `/roadmap <initiative>`,
`/roadmap revise <item-ref>`, and `/plan <item-ref>` keep their exact
signatures and behavior for existing invocations; a one-segment standalone item
and every existing two-level roadmap parent/child remain valid with no migration
(AC12). No shipped decision or artifact of `0001` or `0002` is re-opened.

## Affected areas

- `docs/workflow.md` — `### Where decomposition is authored and recorded`
  (66-74); `### 2. Design — /plan <item-ref>` (411-431); `### Revising a
  roadmap` (303-388); `## Plan publication` (520-566); `## Roadmaps` opening
  (165) and the routing-heuristic `/roadmap` bullet (1239-1244).
- `.opencode/agent/architect.md` — role/mission, inputs, process, rules,
  handoff.
- `.opencode/command/plan.md` — body; usage string preserved.
- `.opencode/agent/roadmap.md` — role/mission, process, rules, handoff; the
  sole-writer self-claim reconciled.
- `.opencode/command/roadmap.md` — body; usage string preserved.

**Must-not-touch (single-source guards).** In `docs/workflow.md`, do not edit or
restate: the readiness algorithm literal `satisfied(dep_local_id):` (exactly
once — `tests/checks/10-readiness.sh`); `A child in a cycle is never \`ready\``,
`integrity findings rather than failing`, `CYCLIC-DEP`, `cycle members are never
reported ready` (`tests/checks/80-cycle-fixture.sh`); the `## Declared-conflict
check` codes/classes/grammar `TEXTUAL-CONFLICT`/`DANGLING-DEP`/`DRIFT-FACT`,
`(a)`/`(b)`/`(d)`, and the finding-line grammar, with no
`(e)`/`DECLARED-`/`PLAN-`/`CONFLICT-` (`tests/checks/85-conflict-guards.sh`);
the reverse-edge table rows and the derived-state labels `` `P` (backtracked) ``,
`` `P` (reopened) ``, `challenged (blocked)`, `build (rework)`, `stale: roadmap`,
`stale: design`, `stale: spec`, and the pinned record/field literals
(`tests/checks/87-backtrack-guards.sh`); the derived-state table row literals and
the artifact names (`tests/checks/20-lifecycle.sh`); and every phase heading /
command signature (`tests/checks/96-signature-sweep.sh`). Do not add a
`### <n>. ` heading, do not change the six-column `Children` header, and do not
touch `AGENTS.md`, `template/AGENTS.md`, `README.md`,
`docs/artifact-conventions.md`, or any test file.

Out of scope (documented follow-ups, not tasks here): recursive
readiness/derived-state/`/status` (`0004-recursive-readiness`); roadmap
deprecation/retirement/migration (Roadmap 2); `conflicts-with` at every level and
recursive duplicate detection (Roadmap 3); the agent/command/README/`workflow-lifecycle`
skill surface sweep and inventory reconciliation (Roadmap 4) — this item updates
only the five surfaces above and leaves `README.md` and the skill to Roadmap 4;
committed fixtures/guards (Roadmap 5).

## Risks and mitigations

- **Breaking a single-source guard by restating pinned vocabulary.** —
  Likelihood: medium / Impact: high / Mitigation: compose by reference only;
  enforce the must-not-touch list; verify `10-readiness.sh`, `20-lifecycle.sh`,
  `80-cycle-fixture.sh`, `85-conflict-guards.sh`, `87-backtrack-guards.sh`, and
  `96-signature-sweep.sh` stay green.
- **Changing a pinned command signature.** — Likelihood: medium / Impact: high /
  Mitigation: preserve the exact `Usage: /plan <item-ref>` and
  `Usage: /roadmap <initiative> | /roadmap revise <item-ref>` strings and the
  command/agent pairing (`architect`, `roadmap`); verify `96-signature-sweep.sh`
  green.
- **A second, competing writer grammar across surfaces.** — Likelihood: medium /
  Impact: high / Mitigation: single-source the contract in `docs/workflow.md`;
  the four agent/command surfaces defer to it by section name and state no
  alternative algorithm; verify no surface contradicts the authority.
- **Weakening plan publication for ordinary single-feature items (AC13).** —
  Likelihood: medium / Impact: medium / Mitigation: state the precondition as a
  disjunction that keeps `spec.md`+`design.md` mandatory for a single-feature
  item; only a decomposing node may publish a manifest-only plan.
- **The two-path `/plan` entry is ambiguous.** — Likelihood: medium / Impact:
  medium / Mitigation: the deterministic facilitator rule (existing manifest →
  revise; no own `spec.md` → author; else single-feature design) plus the
  architect's recon; the single-feature path still requires `spec.md`.
- **A child's in-flight artifacts swept into the parent's plan publication.** —
  Likelihood: low / Impact: medium / Mitigation: plan mode commits the node's own
  plan state (manifest + own artifacts + child reservations) and not a child's
  own phase artifacts.
- **Accidental inventory or contract change (AC10).** — Likelihood: low /
  Impact: high / Mitigation: no new command/agent/skill and no README count-line
  edit; verify `40-inventory.sh` and `96-signature-sweep.sh` green and the full
  suite passing; `git diff --name-only` lists exactly the five files.

## Test strategy

The deliverable is documentation and prompts. The spec explicitly defers
committed fixtures/agreement areas to a successor roadmap, so **no new test file
is added**; verification is the existing committed suite staying green plus
review/grep of the authored text. `Verify:` steps use the project's configured
test command `bash tests/run.sh`, area-scoped via `FRAMEWORK_TEST_AREAS`.

| Criterion | Verification level |
| --------- | ------------------ |
| AC1 | Review + grep: the writer wiring states the manifest at `work/<item-ref>/roadmap.md` with `feature:` = full canonical reference and `phase: roadmap`, at any depth; the architect agent mirrors it. |
| AC2 | Review + grep: child `.gitkeep` reservation, per-immediate-parent `MMMM`, and appended `Canonical reference`; `docs/artifact-conventions.md` → "Sequence allocation" referenced. |
| AC3 | Review + grep: the writer defers to the manifest authority and the architect agent requires the manifest quality bar (six-column `Children`, acyclic `Depends on`, resolving `Canonical reference`, well-formed `conflicts-with`) by reference; `80-cycle-fixture.sh` and `85-conflict-guards.sh` green. |
| AC4 | Review + grep: "writes no child phase artifact; each new child holds only `.gitkeep`" in the authority and the architect agent. |
| AC5 | Review + grep: always-manifest/optional-hybrid/single-feature-no-manifest stated in the authority and the Design-phase section. |
| AC6 | Review + grep: "Revising a roadmap" scoped to any depth, sole-writer reconciled, four operations/validation/`stale: roadmap`/refusal/no-op preserved; `87-backtrack-guards.sh` green. |
| AC7 | Review + grep: autonomous (no pre-write approval gate) in the authority, the architect agent, and the roadmap agent. |
| AC8 | Review + grep: the handoff publishes then routes to ready children; plan publication defines the decomposing node's plan state. |
| AC9 | Review + grep: `/roadmap` deprecated alias with its two modes and unchanged usage string; create top-level, revise any depth; not retired; `96-signature-sweep.sh` green. |
| AC10 | `bash tests/run.sh` exits 0 with `TOTAL: <p> passed, 0 failed`; `40-inventory.sh` counts equal disk; `96-signature-sweep.sh` green; no new command/agent/skill. |
| AC11 | Review + grep: the contract is stated once in `docs/workflow.md`; the four surfaces reference it; the sole-writer sentence is reconciled. |
| AC12 | Review + grep: `docs/workflow.md` revision/authoring wording keeps existing invocations and references unchanged; `git diff --name-only` lists exactly the five files; `87-backtrack-guards.sh` and `10-readiness.sh` green. |
| AC13 | Review + grep: the decomposition path is reachable without the node's own `spec.md` and writes none; the single-feature path still requires `spec.md`; plan publication admits the manifest-only plan. |
