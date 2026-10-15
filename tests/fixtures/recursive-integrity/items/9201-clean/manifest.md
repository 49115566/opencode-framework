---
feature: 9201-clean
phase: manifest
status: final
created: 2026-10-14
updated: 2026-10-14
---

# Manifest — Fixture clean node

## Initiative

A committed test fixture, not a real work item. Its `Children` table is integral:
every row resolves to its child directory, so the recursive merge-integrity
evaluation guarded by `tests/checks/91-integrity-guard.sh` (`AC30`) reports no
finding for it. It lives under `tests/`, never under the item tree, and is
read-only.

## Assumptions

- Fixture data only; never shipped and never executed by `/status`.

## Children

| Local id | Title | Scope | Depends on | conflicts-with | Canonical reference |
| -------- | ----- | ----- | ---------- | -------------- | ------------------- |
| 0001-leaf | Clean leaf | Fixture scope for an integral node. | — | — | 9201-clean/0001-leaf |

## Sequencing

1. 0001-leaf

## Open issues

- None. The fixture is deliberately integral so the guard reports no finding.
