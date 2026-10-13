---
feature: 0012-roadmap-deprecation/0001-deprecation-contract
phase: tasks
status: final
created: 2026-10-13
updated: 2026-10-13
parent: 0012-roadmap-deprecation
---

# Tasks — Deprecation contract: the generic manifest replaces the special `roadmap` concept

Ordered, dependency-aware. One task ≈ one focused commit. Only
`docs/workflow.md` and `docs/artifact-conventions.md` are edited by T1–T7; no
command, agent, skill, inventory, fixture, or existing `work/*/roadmap.md` is
touched (that boundary is `0002`/`0003`'s). Preserve verbatim every literal the
suite pins: keep `spec | design | build | test | review` contiguous in the `stale`
note, keep the `backtracks.md`/`challenges.md` record-shape blocks and the
readiness algorithm text unchanged, and keep the derived-state routing literals
and the six-column `Children` header unchanged.

- [x] **T1** — In `docs/artifact-conventions.md`, fix the manifest identity: change
      the frontmatter `phase` value list (`:20`) to
      `spec | design | manifest | tasks | test | visual | review | ship`; retitle the
      template heading (`:124`) to `` ### `manifest.md` (manifest) — the manifest of
      a decomposing node ``; rewrite its description (`:134-137`) to state the
      concrete spelling `manifest.md` with `phase: manifest` at every depth, with
      `roadmap.md`/`phase: roadmap` as the recognized deprecated alias; and update
      the template body `phase: roadmap` → `phase: manifest` and the H1
      `# Roadmap — <initiative title>` → `# Manifest — <initiative title>`
      (`:142`, `:148`). [AC2, AC3, AC7]
      Verify: `grep -n 'manifest.md\|phase: manifest\|# Manifest' docs/artifact-conventions.md` shows the new spelling; `grep -n 'phase: roadmap' docs/artifact-conventions.md` and `grep -n '# Roadmap' docs/artifact-conventions.md` show only explicit deprecated-alias notes (or nothing).
- [x] **T2** — In `docs/artifact-conventions.md`, retire the concept vocabulary and
      rename the token: update the `stale` frontmatter note (`:51-57`) so the token
      list keeps `spec | design | build | test | review` contiguous and names
      `manifest` (not `roadmap`) for the phase→parent-`manifest.md` backtrack, noting
      legacy `stale: roadmap` is accepted and maps to `spec`; rewrite the
      `## Work item references` "roadmap" paragraph (`:101-109`) to the generic
      decomposing-node/manifest terms with no "roadmap metadata"; modernize the
      illustrative path at `:97` to a non-`roadmap` example; change the
      `conflicts-with` "successor roadmap" wording (`:204`); update the two
      "Revising a roadmap" references (`:211`, `:216`) to `### Revising a
      decomposition`; and change "roadmap parent"/"roadmap `Children`" in
      `### Renumbering after a parallel merge` (`:692`, `:702`) to the generic
      terms. Any remaining `roadmap` mention is inside a deprecated/backward-
      compatibility note or is an existing identifier. [AC8, AC9, AC11] [depends: T1]
      Verify: `grep -n -i roadmap docs/artifact-conventions.md` — every hit is a legacy note or identifier; `grep -n 'Revising a roadmap\|successor roadmap\|roadmap metadata' docs/artifact-conventions.md` returns nothing.
- [x] **T3** — In `docs/workflow.md`, point every manifest-identity surface at the
      new spelling and alias: `### Where decomposition is authored and recorded`
      (`:75-80`) authors `work/<item-ref>/manifest.md` with `phase: manifest`; update
      the backward-compat paragraph (`:131`) to name legacy `roadmap.md` parents;
      update the `## The work item directory` diagram (`:144-145`) to `manifest.md`;
      update the `### 2. Design` entry/exit/artifact prose (`:464`, `:476`, `:493`,
      `:498-499`); and update `## Plan publication` (`:601`, `:612`) to `manifest.md`.
      New manifests are always `manifest.md`/`phase: manifest`. [AC2, AC3, AC4] [depends: T1]
      Verify: `grep -n 'manifest.md\|phase: manifest' docs/workflow.md` shows the new spelling at these surfaces; `grep -n 'work/<item-ref>/roadmap.md' docs/workflow.md` returns nothing.
- [x] **T4** — In `docs/workflow.md`, retire the section vocabulary: retitle
      `## Roadmaps` (`:174`) to `## Decomposing nodes and the manifest` and rewrite
      its intro (`:176-192`) to describe the generic manifest (spelling, deprecated
      alias, `/roadmap` alias clause retained as a BC note); retitle
      `### Revising a roadmap` (`:345`) to `### Revising a decomposition`; fix the
      intro reference to "Roadmaps" (`:32-33`); rewrite the `### Terms` deprecated-
      alias paragraph (`:53-55`) as the legacy-spelling BC note; and update every
      cross-reference to the renamed headings (`:96`, `:480`, `:883`). [AC1, AC9] [depends: T3]
      Verify: `grep -n '## Roadmaps\|Revising a roadmap\|"Roadmaps"' docs/workflow.md` returns nothing; `grep -n '## Decomposing nodes and the manifest\|### Revising a decomposition' docs/workflow.md` shows the new headings.
- [x] **T5** — In `docs/workflow.md`, fix derived state and alias precedence:
      rename the container phase `roadmap` → `manifest` in the `## Derived state`
      prose (`:1216-1219`), the table row (`:1230` → `` a manifest present
      (`manifest.md`, or legacy `roadmap.md`) and no own phase artifacts ... |
      manifest ``), the `stale` token note (`:1246` → `manifest`, maps to `spec`,
      legacy `stale: roadmap` accepted), and the decomposing-node paragraph
      (`:1288-1292`); and state the precedence/reporting rule — `manifest.md`
      authoritative over a redundant `roadmap.md`, mismatched spelling/`phase`
      reported — adding it to the `/status` integrity-findings list (`:331-334`)
      and the `### Merge-integrity guard` invariant set (`:1454-1455`) by reusing
      the shipped `(d)` class and `DRIFT-FACT` code, never auto-repaired. Own phase
      artifacts still take precedence over the manifest at every depth. [AC5, AC6, AC7, AC8, AC10] [depends: T4]
      Verify: `grep -n 'derives the container phase' docs/workflow.md` reads `manifest`; `grep -n 'DRIFT-FACT' docs/workflow.md` shows the reused code; `grep -n 'roadmap.md' docs/workflow.md` hits are legacy notes only.
- [x] **T6** — In `docs/workflow.md`, retire the remaining concept nouns: the
      conflict-check compared set (`:745`, `:748-751`, `:764`, `:796`) "Roadmap
      parent/child"/"roadmaps" → generic; the backtracking reverse-edge rule, table
      row, and exceptions (`:871-872`, `:883`, `:892-894`) → `parent `manifest.md``,
      label `manifest`, `### Revising a decomposition`; `### Taking an edge`
      (`:934`, `:972`) "parent-`roadmap`" → "parent-`manifest`"; `## Multiple work
      items` (`:1371-1372`) and `## Merge conflicts` taxonomy / lifecycle placement
      / invariant table (`:1392`, `:1405`, `:1454-1455`) "roadmap parent"/"roadmap
      `Depends on`" → generic; and the `## Routing heuristics` `/roadmap` bullet
      concept nouns (`:1338-1340`) "parent roadmap item"/"intra-roadmap" → generic,
      leaving the `/roadmap` command alias clause for `0002`. Do not edit the
      `/roadmap` command/agent files or the alias clause itself. [AC8, AC9, AC12] [depends: T5]
      Verify: `grep -n 'parent-`roadmap`\|Roadmap parent\|Roadmap child\|intra-roadmap\|roadmap parent' docs/workflow.md` returns nothing (except the retained `/roadmap` alias clause); `git diff --name-only` still lists only the two documents.
- [x] **T7** — Sweep both documents for the final vocabulary: confirm every
      remaining `roadmap` occurrence is either the deprecated literal spellings
      (`roadmap.md`, `phase: roadmap`, `stale: roadmap`) inside an explicit
      deprecated/backward-compatibility note, the deprecated `/roadmap` command
      alias, or an existing/illustrative identifier; no document surface defines a
      standalone "roadmap" concept. Fix any concept-vocabulary straggler. [AC1, AC9] [depends: T6]
      Verify: `grep -n -i roadmap docs/workflow.md docs/artifact-conventions.md` — classify every hit; no concept-noun use remains outside a BC note.
- [x] **T8** — Verify the whole change: run the suite, confirm scope, and confirm the
      pinned contract strings survived. [AC10, AC11, AC12, AC13] [depends: T1, T2, T3, T4, T5, T6, T7]
      Verify: `bash tests/run.sh` → PASS (especially the `AC24 contract-pins` and
      `AC22 signature agreement` areas); the implementation diff (excluding this
      item's own `work/` artifacts) lists only `docs/workflow.md` and
      `docs/artifact-conventions.md`; confirm the six-column `Children` header,
      the `conflicts-with` grammar, and the finding code set are unchanged.
