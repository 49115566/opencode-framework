---
feature: 9120-revised-roadmap
phase: manifest
status: final
created: 2026-10-09
updated: 2026-10-09
---

# Manifest — Fixture revised roadmap

## Initiative

A fixture manifest after a revision that re-scopes, adds, withdraws, and
re-sequences, exercising the revision-integrity rules.

## Assumptions

- Fixture data only.

## Children

| Local id | Title | Scope | Depends on | conflicts-with | Canonical reference |
| -------- | ----- | ----- | ---------- | -------------- | ------------------- |
| 0001-kept | Kept row | Fixture scope for a re-scoped row. | — | — | 9120-revised-roadmap/0001-kept |
| 0002-added | Added row | Fixture scope for an added row. | 0001-kept | — | 9120-revised-roadmap/0002-added |
| 0003-dep | Dep row | Fixture scope for a dependency row. | — | — | 9120-revised-roadmap/0003-dep |
| 0004-dependent | Dependent row | Fixture scope for a dependent row. | 0003-dep | — | 9120-revised-roadmap/0004-dependent |

## Sequencing

1. 0001-kept
2. 0002-added
3. 0003-dep
4. 0004-dependent

## Open issues

- **Withdrawn child — `0005-withdrawn`.** Withdrawn by user decision on 2026-10-09
  and removed from the Children table and Sequencing above. Its directory
  `9120-revised-roadmap/0005-withdrawn/` and spent local number are preserved; the
  number is never reused. Rationale: fixture withdrawal. Former scope: fixture.
- **Revised 2026-10-09.** Triggered by `9120-revised-roadmap/0004-dependent/`
  (finding in its `backtracks.md`). Operations: re-scope/add/withdraw/re-sequence.
  Invalidated: `9120-revised-roadmap/0002-added`. See git history for the
  pre-revision roadmap.
