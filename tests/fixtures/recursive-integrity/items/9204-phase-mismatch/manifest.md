---
feature: 9204-phase-mismatch
phase: roadmap
status: final
created: 2026-10-14
updated: 2026-10-14
---

# Manifest — Fixture phase/spelling mismatch

## Initiative

A committed test fixture, not a real work item. Its file is named for the modern
`manifest.md` spelling but its declared `phase` value is the deprecated `roadmap`
token, so the merge-integrity evaluation reports the spelling/`phase`
disagreement as `DRIFT-FACT` and never silently normalizes it. It lives under
`tests/`, never under the item tree, and is read-only.

## Assumptions

- Fixture data only; the mismatch is deliberate drift, never auto-repaired.

## Children

| Local id | Title | Scope | Depends on | conflicts-with | Canonical reference |
| -------- | ----- | ----- | ---------- | -------------- | ------------------- |
| 0001-leaf | Mismatch leaf | Row and directory present. | — | — | 9204-phase-mismatch/0001-leaf |

## Sequencing

1. 0001-leaf

## Open issues

- Deliberate mismatch: `manifest.md` spelling with `phase: roadmap`.
