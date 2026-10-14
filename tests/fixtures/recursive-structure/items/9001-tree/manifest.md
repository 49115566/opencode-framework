---
feature: 9001-tree
phase: manifest
status: final
created: 2026-10-14
updated: 2026-10-14
---

# Manifest — Fixture hybrid tree

## Initiative

A committed test fixture, not a real item. It is the top-level **hybrid** node of
the recursive-structure guard (`tests/checks/81-recursive-structure-guard.sh`,
`AC27`): it both decomposes into children and carries its own `spec.md`/`tasks.md`.
Its tree reaches four item levels.

## Assumptions

- Fixture data only; never shipped and never executed by `/status`.

## Children

| Local id | Title | Scope | Depends on | conflicts-with | Canonical reference |
| -------- | ----- | ----- | ---------- | -------------- | ------------------- |
| 0001-branch | Decomposing branch | Fixture scope for a child that itself decomposes. | — | — | 9001-tree/0001-branch |
| 0002-leaf | Marker-only leaf | Fixture scope for a marker-only leaf child. | — | — | 9001-tree/0002-leaf |

## Sequencing

1. 0001-branch
2. 0002-leaf

## Open issues

- None. The fixture is deliberate, acyclic test data.
