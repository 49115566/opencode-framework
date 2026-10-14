---
feature: 9210-dup-b
phase: manifest
status: final
created: 2026-10-14
updated: 2026-10-14
---

# Manifest — Fixture top-level duplicate prefix B

## Initiative

A committed test fixture, not a real work item. Together with `9210-dup-a` it
forms a top-level `NNNN` prefix collision (`DUPLICATE-PREFIX`) at the root of the
recursive tree. It lives under `tests/`, never under the item tree, and is
read-only.

## Assumptions

- Fixture data only; the shared `9210` prefix is deliberate.

## Children

| Local id | Title | Scope | Depends on | conflicts-with | Canonical reference |
| -------- | ----- | ----- | ---------- | -------------- | ------------------- |
| 0001-y | B leaf | Fixture scope for the duplicate-prefix pair. | — | — | 9210-dup-b/0001-y |

## Sequencing

1. 0001-y

## Open issues

- Deliberate top-level duplicate prefix with `9210-dup-a`.
