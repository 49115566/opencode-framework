---
feature: 9003-roadmap-old
phase: roadmap
status: final
created: 2026-10-08
updated: 2026-10-08
---

# Roadmap — Legacy fixture roadmap without a conflicts-with column

## Initiative

A committed test fixture, not a real work item. It carries the legacy five-column
`Children` header (no `conflicts-with` column), so the guard can prove that an
absent column is treated as no declarations (`—` for every row) rather than as
malformed.

## Assumptions

- The fixture is read-only test data; it is never shipped and never executed by
  `/status`.

## Children

| Local id | Title | Scope | Depends on | Canonical reference |
| -------- | ----- | ----- | ---------- | ------------------- |
| 0001-old | Legacy child | fixture | — | 9003-roadmap-old/0001-old |

## Sequencing

1. 0001-old

## Open issues

- None. The fixture is deliberate, acyclic test data.
