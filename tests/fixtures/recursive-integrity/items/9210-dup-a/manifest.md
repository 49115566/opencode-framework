---
feature: 9210-dup-a
phase: manifest
status: final
created: 2026-10-14
updated: 2026-10-14
---

# Manifest — Fixture top-level duplicate prefix A

## Initiative

A committed test fixture, not a real work item. Together with `9210-dup-b` it
forms a top-level `NNNN` prefix collision (`DUPLICATE-PREFIX`) at the root of the
recursive tree. It lives under `tests/`, never under the item tree, and is
read-only.

## Assumptions

- Fixture data only; the shared `9210` prefix is deliberate.

## Children

| Local id | Title | Scope | Depends on | conflicts-with | Canonical reference |
| -------- | ----- | ----- | ---------- | -------------- | ------------------- |
| 0001-x | A leaf | Fixture scope for the duplicate-prefix pair. | — | — | 9210-dup-a/0001-x |

## Sequencing

1. 0001-x

## Open issues

- Deliberate top-level duplicate prefix with `9210-dup-b`.
