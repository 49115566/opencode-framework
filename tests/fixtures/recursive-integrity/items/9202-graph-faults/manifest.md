---
feature: 9202-graph-faults
phase: manifest
status: final
created: 2026-10-14
updated: 2026-10-14
---

# Manifest — Fixture structural graph faults

## Initiative

A committed test fixture, not a real work item. Its `Children` table and child
directories deliberately exercise three structural graph faults — a row whose
child directory is absent (`MISSING-CHILD`), a child directory absent from the
table (`UNLISTED-CHILD`), and a `Depends on` local id that names no row and no
directory (`DANGLING-DEP`) — plus a deliberate withdrawal that is report-only.
It lives under `tests/`, never under the item tree, and is read-only.

## Assumptions

- Fixture data only; never shipped and never executed by `/status`.

## Children

| Local id | Title | Scope | Depends on | conflicts-with | Canonical reference |
| -------- | ----- | ----- | ---------- | -------------- | ------------------- |
| 0001-present | Present child | Row and directory both present. | — | — | 9202-graph-faults/0001-present |
| 0002-missing | Missing child | Row whose child directory is absent. | — | — | 9202-graph-faults/0002-missing |
| 0003-dangling | Dangling child | Depends on a local id with no row and no directory. | 0099-ghost | — | 9202-graph-faults/0003-dangling |

## Sequencing

1. 0001-present
2. 0003-dangling

## Open issues

- **Withdrawn child — `0004-withdrawn`.** Withdrawn by user decision on 2026-10-14
  and removed from the Children table and Sequencing above. Its directory
  `9202-graph-faults/0004-withdrawn/` and spent local number are preserved; the
  number is never reused. Rationale: fixture withdrawal. Former scope: fixture.
