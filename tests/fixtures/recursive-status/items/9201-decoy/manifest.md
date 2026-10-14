---
feature: 9201-decoy
phase: manifest
status: final
created: 2026-10-14
updated: 2026-10-14
---

# Manifest — Fixture decoy root

## Initiative

A fixture decoy root that reuses the local id `0002-shipped` from `9200-tree`,
to prove sibling-only `Depends on` resolution: a bare local id resolves against
the declaring node's own `Children` table, never another root. It carries no
phase artifacts of its own and allocates no real sequence number.

## Assumptions

- Fixture data only.

## Children

| Local id | Title | Scope | Depends on | conflicts-with | Canonical reference |
| -------- | ----- | ----- | ---------- | -------------- | ------------------- |
| 0002-shipped | Recalled decoy row | A same-local-id decoy whose `ship.md` is recalled. | — | — | 9201-decoy/0002-shipped |

## Sequencing

1. 0002-shipped

## Open issues

- None.
