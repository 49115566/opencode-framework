---
feature: 0011-recursive-bootstrap/0003-recursive-writer
phase: tasks
status: final
created: 2026-10-12
updated: 2026-10-12
parent: 0011-recursive-bootstrap
---

# Tasks — Recursive decomposition writer

Ordered, dependency-aware. One task ≈ one focused commit. This item is
documentation/prompt-only; no test file is added (committed guards are deferred
to a successor roadmap per the spec's non-goals). `Verify:` commands use the
project's configured test command, `bash tests/run.sh`, optionally area-scoped via
`FRAMEWORK_TEST_AREAS`. Do not touch any literal in the design's "Must-not-touch"
list, do not change the exact `Usage:` strings, and do not edit `AGENTS.md`,
`template/AGENTS.md`, `README.md`, `docs/artifact-conventions.md`, or any test
file.

- [x] **T1** — In `docs/workflow.md`, replace the `0003`-deferral in
      `### Where decomposition is authored and recorded` (lines 66-74) with the
      concrete writer contract, stated once: the planning step (`/plan`,
      `architect`) authors/revises a decomposition at any depth; `/roadmap` is
      the thin deprecated alias (`/roadmap <initiative>` creates a brand-new
      top-level node; `/roadmap revise <item-ref>` revises at any depth); the
      writer authors the manifest `work/<item-ref>/roadmap.md` (`feature:` = the
      full canonical reference, `phase: roadmap`) and reserves each child
      `work/<item-ref>/<MMMM-slug>/.gitkeep`; it writes **no child phase
      artifact**; it is **autonomous**; a single feature still gets
      `design.md`/`tasks.md` and no manifest; a decomposing node always gets the
      manifest and MAY also get its own `design.md`/`tasks.md` (hybrid), never
      forced on a pure container; the handoff publishes then routes to ready
      children. Reference `docs/artifact-conventions.md` for the manifest shape
      and allocation, and `### Revising a roadmap` / `## Plan publication` for
      revision and publication — do not restate them. [AC1] [AC2] [AC3] [AC4]
      [AC5] [AC7] [AC9] [AC11] [AC13]
      Verify: `grep -n 'Where decomposition is authored' docs/workflow.md` shows
      the section names the planning step as writer, the alias, the manifest
      path, no-child-artifact, autonomy, and hybrid; grep shows the old sentence
      `concrete writer's command/agent wiring` is gone; the six-column header and
      conflict grammar are not restated;
      `FRAMEWORK_TEST_AREAS='10-readiness,80-cycle-fixture,85-conflict-guards,87-backtrack-guards,96-signature-sweep' bash tests/run.sh`
      exits 0.

- [x] **T2** — In `docs/workflow.md`, extend `### 2. Design — /plan <item-ref>`
      (lines 411-431) for the two planning paths. Purpose covers both deciding a
      design and authoring a decomposition; Entry keeps the single-feature
      `spec.md` requirement **and** admits the decomposition path without the
      node's own `spec.md`; Process describes author/revise of the manifest and
      child reservations with no child phase artifact; Exit/Artifact name
      `design.md`/`tasks.md` and/or the manifest `roadmap.md` (+ own artifacts
      when hybrid); Next keeps `/ship plan <item-ref>` and the reverse edge, and
      adds `/spec <child-ref>` for each ready child for a decomposing node. Do
      not add a `### <n>. ` heading. [AC1] [AC5] [AC8] [AC13] [depends: T1]
      Verify: the section shows both paths, the no-`spec.md` decomposition entry,
      and the publish-then-route-to-children handoff; the `### 2. Design — \`/plan <item-ref>\``
      heading is unchanged; `FRAMEWORK_TEST_AREAS='20-lifecycle,96-signature-sweep' bash tests/run.sh`
      exits 0.

- [x] **T3** — In `docs/workflow.md`, generalize `### Revising a roadmap`
      (lines 303-388) from "the parent" to a decomposing node at **any depth**:
      `<item-ref>` must resolve to a node that has a manifest
      (`work/<item-ref>/roadmap.md`); a reference with no manifest is refused.
      Reconcile the sole-writer sentence (line 309) so the planning step
      (`/plan`, `architect`) — or its deprecated `/roadmap` alias — is the sole
      writer of a `roadmap.md`, while a child phase that finds the decomposition
      wrong records a finding and never edits the manifest. **Preserve
      unchanged** the four operations, the final-state validation predicate, the
      `stale: roadmap` marking, the shipped-child refusal, and the no-op rule.
      [AC6] [AC9] [AC11] [depends: T1]
      Verify: grep shows the any-depth generalization and the reconciled
      sole-writer sentence; the four operations and `stale: roadmap` are intact;
      `FRAMEWORK_TEST_AREAS='87-backtrack-guards' bash tests/run.sh` exits 0.

- [x] **T4** — In `docs/workflow.md`, broaden `## Plan publication` (lines
      520-566). Restate the plan definition so a decomposing node's plan is its
      manifest (`roadmap.md`) plus its own `spec.md`/`design.md`/`tasks.md` when
      present plus its child directory reservations. State the precondition as a
      disjunction: the item has completed `/plan` — either `spec.md` and
      `design.md` exist (single-feature) **or** `roadmap.md` exists (decomposing
      node, own artifacts included when present) — keeping the no-`review.md`
      exception and the no-secrets rule. Clarify that plan mode commits the
      node's own plan state (manifest + own artifacts + child reservations) and
      not a child's own in-flight artifacts. Do not weaken the ordinary
      single-feature `spec.md`+`design.md` requirement and do not edit the
      `/build` plan gate algorithm. [AC8] [AC13] [depends: T2]
      Verify: the precondition names both the single-feature and the manifest
      plan; the `spec.md`+`design.md` requirement for a single-feature item is
      retained; the `/build` plan gate block is byte-unchanged;
      `FRAMEWORK_TEST_AREAS='20-lifecycle' bash tests/run.sh` exits 0.

- [x] **T5** — In `docs/workflow.md`, make the minimal consistency touch to the
      `## Roadmaps` opening (line 165) and the routing-heuristic `/roadmap`
      bullet (lines 1239-1244): name the planning step (`/plan`) as the author
      and `/roadmap` as the deprecated alias for it, with no competing writer
      grammar. Leave the `## Roadmaps` operational text and the pinned literals
      untouched. [AC9] [AC11] [AC12] [depends: T1]
      Verify: grep shows the planning step named as author and `/roadmap` as the
      deprecated alias in both spots; the `## Roadmaps` operational literals and
      the six-column header are unchanged;
      `FRAMEWORK_TEST_AREAS='10-readiness,80-cycle-fixture,96-signature-sweep' bash tests/run.sh`
      exits 0.

- [x] **T6** — Update the planning-step surfaces: `.opencode/agent/architect.md`
      and `.opencode/command/plan.md`. In the agent, broaden the mission to
      `design.md`/`tasks.md` and/or the manifest; add the two-path process
      (single-feature design vs. decomposition); state the decomposition rules
      (any depth, manifest + child `.gitkeep` reservations, no child phase
      artifact, autonomous, hybrid) and require the produced manifest to satisfy
      the manifest quality bar — six-column `Children`, every `Depends on`
      naming another row with no self-dependency and an acyclic stored graph,
      every `Canonical reference` resolving to its child directory, and every
      `conflicts-with` cell `—` or well-formed — **by reference** to
      `docs/artifact-conventions.md` (restate none of it); note in inputs that
      the decomposition path needs no node `spec.md`; and add the decomposition
      variant to the handoff block (publish via `/ship plan <item-ref>`, then
      `/spec <child-ref>` for each ready child). In the command, describe the
      decomposition path and handoff. Both defer the normative contract to
      `docs/workflow.md`; **keep** the exact `Usage: /plan <item-ref>` string.
      [AC1] [AC2] [AC3] [AC4] [AC5] [AC7] [AC8] [AC13] [depends: T1, T2, T3, T4]
      Verify: the agent shows the two paths, the decomposition writer behavior,
      no-child-artifact, autonomy, the by-reference manifest quality bar, and the
      decomposition handoff; the command keeps `Usage: /plan <item-ref>`; no
      competing writer grammar is stated;
      `FRAMEWORK_TEST_AREAS='10-readiness,20-lifecycle,30-permissions,96-signature-sweep' bash tests/run.sh`
      exits 0.

- [x] **T7** — Demote the alias surfaces to a thin deprecated alias:
      `.opencode/agent/roadmap.md` and `.opencode/command/roadmap.md`. State that
      `/roadmap` is the deprecated alias for the planning step; create mode
      creates a brand-new top-level decomposing node (next top-level `NNNN`) and
      writes only the manifest and child `.gitkeep` reservations; revise mode
      revises an existing decomposition at any depth; reconcile the agent's
      sole-writer self-claim; keep it writing no child phase artifact and
      deferring the grammar to `docs/workflow.md`. **Keep** the exact
      `Usage: /roadmap <initiative> | /roadmap revise <item-ref>` string and do
      not retire or remove the command or agent. [AC2] [AC3] [AC6] [AC9] [AC11]
      [depends: T1, T3]
      Verify: grep shows the deprecation wording, create-top-level, revise-any-
      depth, and the reconciled sole-writer claim; the usage string is unchanged;
      `FRAMEWORK_TEST_AREAS='30-permissions,40-inventory,96-signature-sweep' bash tests/run.sh`
      exits 0.

- [x] **T8** — Final verification of the whole item. Run the full committed
      suite; confirm no new agent/command/skill file exists, no documented
      inventory count changed, the six core commands and command→agent pairs are
      unchanged, and the change set is exactly the five files; confirm no
      surface states a competing writer grammar and the existing `/plan <item-ref>`,
      `/roadmap <initiative>`, and `/roadmap revise <item-ref>` invocations still
      work. [AC10] [AC12] [depends: T1, T2, T3, T4, T5, T6, T7]
      Verify: `bash tests/run.sh` exits 0 with `TOTAL: <p> passed, 0 failed`;
      `40-inventory.sh` reports the documented counts equal to disk;
      `git diff --name-only` lists exactly `docs/workflow.md`,
      `.opencode/agent/architect.md`, `.opencode/command/plan.md`,
      `.opencode/agent/roadmap.md`, and `.opencode/command/roadmap.md`;
      `ls .opencode/agent .opencode/command .opencode/skill` shows no added file.
