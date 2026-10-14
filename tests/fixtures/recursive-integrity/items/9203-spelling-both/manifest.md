---
feature: 9203-spelling-both
phase: manifest
status: final
created: 2026-10-14
updated: 2026-10-14
---

# Manifest — Fixture dual manifest spelling

## Initiative

A committed test fixture, not a real work item. It holds both a modern
`manifest.md` and the deprecated `roadmap.md` alias so the merge-integrity
evaluation reports a `DRIFT-FACT` and treats this file as authoritative without
merging, normalizing, or deleting the other. It lives under `tests/`, never
under the item tree, and is read-only.

## Assumptions

- Fixture data only; the redundant `roadmap.md` is deliberate drift, never
  auto-repaired.

## Children

| Local id | Title | Scope | Depends on | conflicts-with | Canonical reference |
| -------- | ----- | ----- | ---------- | -------------- | ------------------- |
| 0001-leaf | Drift leaf | Row and directory present on the dual-spelling node. | — | — | 9203-spelling-both/0001-leaf |

## Sequencing

1. 0001-leaf

## Open issues

- Deliberate dual spelling: `manifest.md` and `roadmap.md` both present.
