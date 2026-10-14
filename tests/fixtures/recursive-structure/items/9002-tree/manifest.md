---
feature: 9002-tree
phase: manifest
status: final
created: 2026-10-14
updated: 2026-10-14
---

# Manifest — Fixture second node

## Initiative

A second top-level fixture decomposing node whose local numbering independently
begins at `0001`, pinning per-immediate-parent allocation scoping.

## Assumptions

- Fixture data only.

## Children

| Local id | Title | Scope | Depends on | conflicts-with | Canonical reference |
| -------- | ----- | ----- | ---------- | -------------- | ------------------- |
| 0001-branch | Decomposing branch | Fixture scope for a child that itself decomposes. | — | — | 9002-tree/0001-branch |

## Sequencing

1. 0001-branch

## Open issues

- None.
