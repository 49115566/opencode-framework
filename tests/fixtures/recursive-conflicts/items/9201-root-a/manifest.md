---
feature: 9201-root-a
phase: manifest
status: final
created: 2026-10-14
updated: 2026-10-14
---

# Manifest — Recursive declared-conflict fixture root A

## Initiative

A committed test fixture, not a real work item. Its tree is three levels deep
(`9201-root-a/0001-nested/...`) so the declared-conflict guard in
`tests/checks/85-conflict-guards.sh` (`AC23 recursive-*`) can pin the recursive
`conflicts-with` target grammar and reference-vs-path discriminator, the
sibling-first-then-root resolution precedence below the root, the own ∪
parent-cell union and its drift at depth, the pair predicate across levels, and
malformed/unresolved reporting. It lives under `tests/`, is read-only, and
allocates no real sequence number.

## Assumptions

- The fixture is read-only committed test data; it is never shipped and never
  executed by `/status`.

## Children

| Local id | Title | Scope | Depends on | conflicts-with | Canonical reference |
| -------- | ----- | ----- | ---------- | -------------- | ------------------- |
| 0001-nested | Nested decomposing child | fixture | — | — | 9201-root-a/0001-nested |
| 0002-sibling | Silent sibling | fixture | — | — | 9201-root-a/0002-sibling |
| 0003-legacy | Legacy 5-column decomposing child | fixture | — | — | 9201-root-a/0003-legacy |

## Sequencing

1. 0001-nested
2. 0002-sibling
3. 0003-legacy

## Open issues

- None. The fixture is deliberate, acyclic test data.
