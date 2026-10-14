---
feature: 9201-root-a/0001-nested
phase: manifest
status: final
created: 2026-10-14
updated: 2026-10-14
---

# Manifest — Recursive fixture nested decomposing child

## Initiative

A committed test fixture, not a real work item. This depth-2 directory itself
holds a manifest, so it is both an entity (from `9201-root-a`'s row) and the
source of further entities keyed by their full canonical reference. Its rows
exercise sibling-first resolution below the root, the recursive reference
grammar, the own ∪ parent-cell union and its drift, shipped-counterpart
exclusion, and malformed/unresolved reporting.

## Assumptions

- The fixture is read-only committed test data; it is never shipped and never
  executed by `/status`.

## Children

| Local id | Title | Scope | Depends on | conflicts-with | Canonical reference |
| -------- | ----- | ----- | ---------- | -------------- | ------------------- |
| 0001-leaf | Silent leaf | fixture | — | — | 9201-root-a/0001-nested/0001-leaf |
| 0002-grand | Drift/union child | fixture | — | docs/customization.md | 9201-root-a/0001-nested/0002-grand |
| 0003-shipped | Shipped child | fixture | — | docs/workflow.md | 9201-root-a/0001-nested/0003-shipped |
| 0004-refs | Recursive-reference child | fixture | — | — | 9201-root-a/0001-nested/0004-refs |
| 0005-precedence | Sibling-first child | fixture | — | — | 9201-root-a/0001-nested/0005-precedence |
| 0006-bad | Malformed-target child | fixture | — | — | 9201-root-a/0001-nested/0006-bad |

## Sequencing

1. 0001-leaf
2. 0002-grand
3. 0003-shipped
4. 0004-refs
5. 0005-precedence
6. 0006-bad

## Open issues

- None. The fixture is deliberate, acyclic test data.
