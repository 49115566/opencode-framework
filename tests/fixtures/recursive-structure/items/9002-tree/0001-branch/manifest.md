---
feature: 9002-tree/0001-branch
phase: manifest
status: final
created: 2026-10-14
updated: 2026-10-14
parent: 9002-tree
---

# Manifest — Fixture second branch

## Initiative

A fixture child that itself decomposes, pinning that its grandchild's local
number is allocated under its immediate parent and that equal local-id text under
a different parent is not a duplicate.

## Assumptions

- Fixture data only.

## Children

| Local id | Title | Scope | Depends on | conflicts-with | Canonical reference |
| -------- | ----- | ----- | ---------- | -------------- | ------------------- |
| 0001-leaf | Marker-only leaf | Fixture scope for a marker-only leaf grandchild. | — | — | 9002-tree/0001-branch/0001-leaf |

## Sequencing

1. 0001-leaf

## Open issues

- None.
