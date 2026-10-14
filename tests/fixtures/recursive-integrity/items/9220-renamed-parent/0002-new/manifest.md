---
feature: 9220-renamed-parent/0002-new
phase: manifest
status: final
created: 2026-10-14
updated: 2026-10-14
parent: 9220-renamed-parent
---

# Manifest — Fixture intermediate manifest on the changed path

## Initiative

A committed test fixture, not a real work item. It is the **intermediate
manifest** on the changed path of a completed whole-subtree renumber: its own
`Children` row's `Canonical reference` cell already carries the new path, so the
renumber guard (`tests/checks/91-integrity-guard.sh`, AC30) can assert the
intermediate manifest is not left stale. It lives under `tests/`, never under the
item tree, and is read-only.

## Assumptions

- Fixture data only; the new reference is deliberate and complete.

## Children

| Local id | Title | Scope | Depends on | conflicts-with | Canonical reference |
| -------- | ----- | ----- | ---------- | -------------- | ------------------- |
| 0001-leaf | Renamed leaf | A descendant artifact whose `feature:` and `parent:` values carry the new path. | — | — | 9220-renamed-parent/0002-new/0001-leaf |

## Sequencing

1. 0001-leaf

## Open issues

- None. The intermediate manifest already names the new canonical reference.
