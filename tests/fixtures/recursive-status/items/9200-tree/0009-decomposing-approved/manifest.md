---
feature: 9200-tree/0009-decomposing-approved
phase: manifest
status: final
created: 2026-10-14
updated: 2026-10-14
parent: 9200-tree
---

# Manifest — Fixture approved decomposing hybrid

## Initiative

A hybrid fixture node: it both decomposes into a `.gitkeep`-only child and
carries its own full phase artifact set whose review verdict is `approve`. Its
derived phase is its own (`ship`), so it proves a decomposing target is satisfied
by its own signal only — readiness never consults its descendant. Read-only
fixture data; allocates no real sequence number.

## Assumptions

- Fixture data only; readiness and phase are derived live and are never stored.

## Children

| Local id | Title | Scope | Depends on | conflicts-with | Canonical reference |
| -------- | ----- | ----- | ---------- | -------------- | ------------------- |
| 0001-leaf | Leaf | A `.gitkeep`-only child that derives `not started`. | — | — | 9200-tree/0009-decomposing-approved/0001-leaf |

## Sequencing

1. 0001-leaf

## Open issues

- None.
