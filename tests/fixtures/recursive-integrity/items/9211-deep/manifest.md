---
feature: 9211-deep
phase: manifest
status: final
created: 2026-10-14
updated: 2026-10-14
---

# Manifest — Fixture depth-three collision root

## Initiative

A committed test fixture, not a real work item. Its child `0001-mid` is itself a
decomposing node whose two children (`0001-alpha`, `0001-beta`) share a local
`0001` prefix, so the collision sits at depth three and is detected only by a
recursive scan that evaluates each node against its own immediate children. It
lives under `tests/`, never under the item tree, and is read-only.

## Assumptions

- Fixture data only; the depth-three collision is deliberate.

## Children

| Local id | Title | Scope | Depends on | conflicts-with | Canonical reference |
| -------- | ----- | ----- | ---------- | -------------- | ------------------- |
| 0001-mid | Intermediate node | A nested decomposing node carrying the colliding grandchildren. | — | — | 9211-deep/0001-mid |

## Sequencing

1. 0001-mid

## Open issues

- Deliberate same-parent collision between the intermediate node's children at
  depth three.
