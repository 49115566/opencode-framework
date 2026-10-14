---
feature: 9211-deep/0001-mid
phase: manifest
status: final
created: 2026-10-14
updated: 2026-10-14
parent: 9211-deep
---

# Manifest — Fixture depth-three collision node

## Initiative

A committed test fixture, not a real work item. Its two immediate children
`0001-alpha` and `0001-beta` share the local `0001` prefix, forming a
`DUPLICATE-CHILD` collision at depth three. It lives under `tests/`, never under
the item tree, and is read-only.

## Assumptions

- Fixture data only; the same-parent collision is deliberate.

## Children

| Local id | Title | Scope | Depends on | conflicts-with | Canonical reference |
| -------- | ----- | ----- | ---------- | -------------- | ------------------- |
| 0001-alpha | Alpha grandchild | First colliding grandchild. | — | — | 9211-deep/0001-mid/0001-alpha |
| 0001-beta | Beta grandchild | Second colliding grandchild. | — | — | 9211-deep/0001-mid/0001-beta |

## Sequencing

1. 0001-alpha
2. 0001-beta

## Open issues

- Deliberate same-parent `0001` collision between the two grandchildren.
