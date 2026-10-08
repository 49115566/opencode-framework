---
feature: 9001-roadmap-a
phase: roadmap
status: final
created: 2026-10-08
updated: 2026-10-08
---

# Roadmap — Declared-conflict fixture roadmap A

## Initiative

A committed test fixture, not a real work item. Its `Children` table exercises
the declared-conflict model guarded by `tests/checks/85-conflict-guards.sh`
(`AC23`): surface sharing, sibling-first resolution, parent/own union drift, a
shipped row, a self-reference, and an unspecced child. It lives under `tests/`,
never under the item tree, and is read-only.

## Assumptions

- The fixture is read-only test data; it is never shipped and never executed by
  `/status`.

## Children

| Local id | Title | Scope | Depends on | conflicts-with | Canonical reference |
| -------- | ----- | ----- | ---------- | -------------- | ------------------- |
| 0001-shared | Shared-surface child | fixture | — | docs/artifact-conventions.md, 0002-sibling | 9001-roadmap-a/0001-shared |
| 0002-sibling | Sibling-naming child | fixture | — | 0001-shared | 9001-roadmap-a/0002-sibling |
| 0003-drift | Drift child | fixture | — | docs/workflow.md | 9001-roadmap-a/0003-drift |
| 0004-shipped | Shipped child | fixture | — | docs/artifact-conventions.md | 9001-roadmap-a/0004-shipped |
| 0005-self | Self-referential child | fixture | — | 0005-self | 9001-roadmap-a/0005-self |
| 0006-unspecced | Unspecced child | fixture | — | tests/fixtures | 9001-roadmap-a/0006-unspecced |

## Sequencing

1. 0001-shared
2. 0002-sibling

## Open issues

- None. The fixture is deliberate, acyclic test data.
