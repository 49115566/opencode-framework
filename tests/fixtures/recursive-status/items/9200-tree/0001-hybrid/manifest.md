---
feature: 9200-tree/0001-hybrid
phase: manifest
status: final
created: 2026-10-14
updated: 2026-10-14
parent: 9200-tree
---

# Manifest — Fixture hybrid node

## Initiative

A hybrid fixture node: it both decomposes into children and carries its own phase
artifacts (`spec.md`, `design.md`), so its derived phase is its own (`design`)
rather than the container phase `manifest`. It is the depth-2 parent of the
depth-3 subtree, which includes a `.gitkeep`-only leaf, an approved leaf, and a
deliberate two-node dependency cycle. It is read-only fixture data and allocates
no real sequence number.

## Assumptions

- Fixture data only; readiness and phase are derived live and are never stored.

## Children

| Local id | Title | Scope | Depends on | conflicts-with | Canonical reference |
| -------- | ----- | ----- | ---------- | -------------- | ------------------- |
| 0001-empty-leaf | Empty leaf | A `.gitkeep`-only child that derives `not started`. | — | — | 9200-tree/0001-hybrid/0001-empty-leaf |
| 0002-approved-leaf | Approved leaf | A full child whose own review is `approve`. | — | — | 9200-tree/0001-hybrid/0002-approved-leaf |
| 0003-cyclic-a | Cycle member A | A `.gitkeep`-only member of a deliberate dependency cycle. | 0004-cyclic-b | — | 9200-tree/0001-hybrid/0003-cyclic-a |
| 0004-cyclic-b | Cycle member B | A `.gitkeep`-only member of a deliberate dependency cycle. | 0003-cyclic-a | — | 9200-tree/0001-hybrid/0004-cyclic-b |

## Sequencing

1. 0001-empty-leaf
2. 0002-approved-leaf
3. 0003-cyclic-a
4. 0004-cyclic-b

## Open issues

- **Deliberate cycle — `0003-cyclic-a` ↔ `0004-cyclic-b`.** The two rows depend
  on each other, so the readiness analyzer's cycle reduction leaves both members
  in the cycle and never reports either `ready`; cycle *detection* remains owned
  by `tests/checks/80-cycle-fixture.sh`. Per `docs/artifact-conventions.md`, a
  genuinely cyclic initiative records the cycle here and leaves the stored graph
  acyclic; the fixture exists only to prove the readiness consequence at depth, so
  it records the cycle instead.
