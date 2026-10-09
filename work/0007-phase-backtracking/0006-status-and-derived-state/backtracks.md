---
feature: 0007-phase-backtracking/0006-status-and-derived-state
record: backtracks
created: 2026-10-09
updated: 2026-10-09
---

## Finding 1 — 2026-10-09

- detecting phase: `/spec`
- target phase: `roadmap`
- affected: `work/0007-phase-backtracking/roadmap.md`
- evidence: The 0006 children row (`work/0007-phase-backtracking/roadmap.md:88`)
  states `Depends on: 0001-backtracking-model, 0002-reverse-phase-routing,
  0005-post-ship-pr-denial`, omitting `0003-findings-challenge-loop`, while the
  same row's scope requires reporting the `challenged` state that 0003 defines
  (`docs/workflow.md` → "Findings challenge and adjudication";
  `docs/artifact-conventions.md` → "`challenges.md`"). All four children carry a
  committed `ship.md`, so 0006's readiness is unaffected today, but the stored
  dependency graph understates 0006's dependencies and would let 0006 start
  before 0003 fixed the challenged shape if 0003 were unshipped.
- status: open

Recorded by the `/spec` phase per the product agent's roadmap-reconciliation
rule; the parent `roadmap.md` is owned by the roadmap agent and was not edited.
The sanctioned route is `/roadmap revise 0007-phase-backtracking` adding
`0003-findings-challenge-loop` to the 0006 row's `Depends on` cell.

## Resolution 1 — 2026-10-09

- resolves: Finding 1
- revision: Added `0003-findings-challenge-loop` to the `0006-status-and-derived-state`
  row's `Depends on` cell in `work/0007-phase-backtracking/roadmap.md` (operation:
  re-sequence), so the stored dependency graph now matches the row's scope, which
  consumes the `challenged` shape `0003` defines. The revised graph remains acyclic
  and `## Sequencing` remains a valid topological order (`0003` already precedes
  `0006`), so no reordering was required. The affected child
  `0006-status-and-derived-state` had its present `spec.md` marked `stale: roadmap`;
  no row was added, withdrawn, or re-scoped, and no shipped child was touched.
  Recorded by the roadmap agent; the parent `roadmap.md` revision note is dated
  2026-10-09.
