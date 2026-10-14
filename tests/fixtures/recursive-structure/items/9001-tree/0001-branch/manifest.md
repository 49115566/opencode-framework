---
feature: 9001-tree/0001-branch
phase: manifest
status: final
created: 2026-10-14
updated: 2026-10-14
parent: 9001-tree
---

# Manifest — Fixture decomposing branch

## Initiative

A fixture child that itself decomposes, pinning that any node may decompose to
arbitrary depth. Fixture data only.

## Assumptions

- Fixture data only.

## Children

| Local id | Title | Scope | Depends on | conflicts-with | Canonical reference |
| -------- | ----- | ----- | ---------- | -------------- | ------------------- |
| 0001-leaf | Decomposing leaf | Fixture scope for a grandchild that itself decomposes. | — | — | 9001-tree/0001-branch/0001-leaf |

## Sequencing

1. 0001-leaf

## Open issues

- None.
