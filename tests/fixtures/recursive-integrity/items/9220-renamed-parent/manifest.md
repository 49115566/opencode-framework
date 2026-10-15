---
feature: 9220-renamed-parent
phase: manifest
status: final
created: 2026-10-14
updated: 2026-10-14
---

# Manifest — Fixture completed whole-subtree renumber

## Initiative

A committed test fixture, not a real work item. It represents a **completed**
whole-subtree renumber: the child formerly numbered `0001-*` now exists as the
new local id `0002-new`, and its old local id and old canonical reference appear
nowhere in the fixture. Its `Children` table already carries the rewritten `Local
id` and `Canonical reference` cells, and the sibling `0003-follower`'s `Depends
on` cell already names the new local id, so the renumber guard
(`tests/checks/91-integrity-guard.sh`, AC30) can assert the rewrite is complete
by a recursive literal scan. It lives under `tests/`, never under the item tree,
and is read-only.

## Assumptions

- Fixture data only; the renumber is complete and deliberate, never re-applied.

## Children

| Local id | Title | Scope | Depends on | conflicts-with | Canonical reference |
| -------- | ----- | ----- | ---------- | -------------- | ------------------- |
| 0002-new | Renamed node | The renumbered node, formerly the old local id, now an intermediate decomposing manifest on the changed path. | — | — | 9220-renamed-parent/0002-new |
| 0003-follower | Follower node | A sibling whose `Depends on`, declared conflict, and ship path name the new local id. | 0002-new | — | 9220-renamed-parent/0003-follower |

## Sequencing

1. 0002-new
2. 0003-follower

## Open issues

- None. The fixture is a completed renumber: no stale reference to the old local
  id or old canonical reference remains.
