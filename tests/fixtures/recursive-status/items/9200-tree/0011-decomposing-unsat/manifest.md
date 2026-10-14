---
feature: 9200-tree/0011-decomposing-unsat
phase: manifest
status: final
created: 2026-10-14
updated: 2026-10-14
parent: 9200-tree
---

# Manifest — Fixture unsatisfied decomposing container

## Initiative

A pure container fixture node: it holds no phase artifacts of its own, so it
derives the container phase `manifest`, and carries no `ship.md` or `approve`
verdict, so it does not satisfy a dependent. It decomposes into a single shipped
child that is never consulted for the dependent's readiness. Read-only fixture
data; allocates no real sequence number.

## Assumptions

- Fixture data only; readiness and phase are derived live and are never stored.

## Children

| Local id | Title | Scope | Depends on | conflicts-with | Canonical reference |
| -------- | ----- | ----- | ---------- | -------------- | ------------------- |
| 0001-shipped-child | Shipped child | A full child with a non-recalled `ship.md`. | — | — | 9200-tree/0011-decomposing-unsat/0001-shipped-child |

## Sequencing

1. 0001-shipped-child

## Open issues

- None.
