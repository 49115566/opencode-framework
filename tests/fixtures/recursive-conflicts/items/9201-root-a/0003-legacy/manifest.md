---
feature: 9201-root-a/0003-legacy
phase: manifest
status: final
created: 2026-10-14
updated: 2026-10-14
---

# Manifest — Recursive fixture legacy (5-column) nested child

## Initiative

A committed test fixture, not a real work item. It is a depth-2 decomposing child
that carries the legacy five-column `Children` header (no `conflicts-with`
column), so the guard can prove an absent column is treated as no declarations at
depth, not only at the top level, while the child itself remains an entity.

## Assumptions

- The fixture is read-only committed test data; it is never shipped and never
  executed by `/status`.

## Children

| Local id | Title | Scope | Depends on | Canonical reference |
| -------- | ----- | ----- | ---------- | ------------------- |
| 0001-old | Legacy leaf | fixture | — | 9201-root-a/0003-legacy/0001-old |

## Sequencing

1. 0001-old

## Open issues

- None. The fixture is deliberate, acyclic test data.
