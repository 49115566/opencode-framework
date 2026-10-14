---
feature: 9001-tree/0001-branch/0001-leaf
phase: manifest
status: final
created: 2026-10-14
updated: 2026-10-14
parent: 9001-tree/0001-branch
---

# Manifest — Fixture depth-3 decomposing leaf

## Initiative

A fixture grandchild that itself decomposes into the depth-4 leaves, pinning
nesting to arbitrary depth and a same-parent duplicate pair at depth ≥ 3.

## Assumptions

- Fixture data only.

## Children

| Local id | Title | Scope | Depends on | conflicts-with | Canonical reference |
| -------- | ----- | ----- | ---------- | -------------- | ------------------- |
| 0001-deep | Depth-4 marker-only leaf | Fixture scope for a marker-only depth-4 leaf. | — | — | 9001-tree/0001-branch/0001-leaf/0001-deep |
| 0009-dup-x | Duplicate x | Fixture scope for a same-parent duplicate sample. | — | — | 9001-tree/0001-branch/0001-leaf/0009-dup-x |
| 0009-dup-y | Duplicate y | Fixture scope for a same-parent duplicate sample. | — | — | 9001-tree/0001-branch/0001-leaf/0009-dup-y |

## Sequencing

1. 0001-deep
2. 0009-dup-x
3. 0009-dup-y

## Open issues

- None. The `0009` pair is a deliberate same-parent duplicate sample.
