---
feature: fixture-cyclic-roadmap
phase: roadmap
status: final
created: 2026-10-06
updated: 2026-10-06
---

# Roadmap — Cyclic dependency fixture

## Initiative

A committed test fixture, not a real work item. Its `Children` table deliberately
encodes a dependency cycle so `tests/checks/80-cycle-fixture.sh` (AC13) can prove
the documented `CYCLIC-DEP` contract against a known-cyclic graph on a fresh
clone. It lives under `tests/`, never under `work/`, so it never pollutes the
artifact tree and no sequence number is allocated.

## Assumptions

- The fixture is read-only test data; it is never shipped and never executed by
  `/status`.

## Children

| Local id | Title | Scope | Depends on | Canonical reference |
| -------- | ----- | ----- | ---------- | ------------------- |
| 0001-alpha | Alpha | First fixture child | 0002-beta | fixture-cyclic-roadmap/0001-alpha |
| 0002-beta | Beta | Second fixture child | 0001-alpha | fixture-cyclic-roadmap/0002-beta |

## Sequencing

1. 0001-alpha
2. 0002-beta

## Open issues

- **Deliberate cycle.** `0001-alpha` depends on `0002-beta` and `0002-beta`
  depends on `0001-alpha`. Per `docs/artifact-conventions.md`, a genuinely cyclic
  initiative records the cycle here and leaves the stored graph acyclic; this
  fixture exists only to prove the `CYCLIC-DEP` diagnostic, so it records the
  cycle instead.
