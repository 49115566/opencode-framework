---
feature: 9203-spelling-both
phase: roadmap
status: final
created: 2026-10-14
updated: 2026-10-14
---

# Roadmap — Fixture legacy alias kept alongside the modern manifest

## Initiative

A committed test fixture, not a real work item. This deprecated-alias spelling is
deliberately retained beside the node's `manifest.md` so the merge-integrity
evaluation reports a `DRIFT-FACT`; the modern spelling stays authoritative and
this file is never merged, normalized, or deleted. It lives under `tests/`, never
under the item tree, and is read-only.

## Assumptions

- Fixture data only; the redundancy is deliberate drift.

## Children

| Local id | Title | Scope | Depends on | conflicts-with | Canonical reference |
| -------- | ----- | ----- | ---------- | -------------- | ------------------- |
| 0001-leaf | Drift leaf | Row and directory present on the dual-spelling node. | — | — | 9203-spelling-both/0001-leaf |

## Sequencing

1. 0001-leaf

## Open issues

- None beyond the deliberate dual spelling recorded on the modern manifest.
