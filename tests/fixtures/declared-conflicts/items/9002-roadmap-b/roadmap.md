---
feature: 9002-roadmap-b
phase: roadmap
status: final
created: 2026-10-08
updated: 2026-10-08
---

# Roadmap — Declared-conflict fixture roadmap B

## Initiative

A committed test fixture, not a real work item. It exercises the cross-roadmap
same-token control: both roadmaps declare the bare token `0001-shared`, which
resolves sibling-first to a different item in each parent, so the equal token is
not a shared target. It also proves one-sided naming of a silent sibling.

## Assumptions

- The fixture is read-only test data; it is never shipped and never executed by
  `/status`.

## Children

| Local id | Title | Scope | Depends on | conflicts-with | Canonical reference |
| -------- | ----- | ----- | ---------- | -------------- | ------------------- |
| 0001-shared | Silent sibling | fixture | — | — | 9002-roadmap-b/0001-shared |
| 0002-sibling | Namer of the silent sibling | fixture | — | 0001-shared | 9002-roadmap-b/0002-sibling |

## Sequencing

1. 0001-shared
2. 0002-sibling

## Open issues

- None. The fixture is deliberate, acyclic test data.
