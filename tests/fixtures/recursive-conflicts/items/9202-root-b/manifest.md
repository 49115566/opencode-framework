---
feature: 9202-root-b
phase: manifest
status: final
created: 2026-10-14
updated: 2026-10-14
---

# Manifest — Recursive declared-conflict fixture root B

## Initiative

A committed test fixture, not a real work item. It is the cross-parent control for
the recursive declared-conflict guard: its bare `0002-grand` token and the one in
`9201-root-a/0001-nested` share the same text but resolve to different items, so
they must not be reported as a shared target.

## Assumptions

- The fixture is read-only committed test data; it is never shipped and never
  executed by `/status`.

## Children

| Local id | Title | Scope | Depends on | conflicts-with | Canonical reference |
| -------- | ----- | ----- | ---------- | -------------- | ------------------- |
| 0002-grand | Silent grand | fixture | — | — | 9202-root-b/0002-grand |
| 0001-namer | Namer of a silent grand | fixture | — | 0002-grand | 9202-root-b/0001-namer |

## Sequencing

1. 0002-grand
2. 0001-namer

## Open issues

- None. The fixture is deliberate, acyclic test data.
