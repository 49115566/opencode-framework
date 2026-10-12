---
feature: 9121-readiness
phase: roadmap
status: final
created: 2026-10-09
updated: 2026-10-09
---

# Roadmap — Fixture readiness

## Initiative

A fixture roadmap exercising the recalled-item readiness revocation; readiness is
derived live and is not stored in the table.

## Assumptions

- Fixture data only.

## Children

| Local id | Title | Scope | Depends on | conflicts-with | Canonical reference |
| -------- | ----- | ----- | ---------- | -------------- | ------------------- |
| 0001-recalled | Recalled row | Fixture scope for a recalled (reopened) row. | — | — | 9121-readiness/0001-recalled |
| 0002-approved | Approved row | Fixture scope for an approved, unshipped row. | — | — | 9121-readiness/0002-approved |
| 0003-shipped | Shipped row | Fixture scope for a shipped row. | — | — | 9121-readiness/0003-shipped |
| 0004-dependent | Dependent row | Fixture scope for a row depending on the three above. | 0001-recalled, 0002-approved, 0003-shipped | — | 9121-readiness/0004-dependent |

## Sequencing

1. 0001-recalled
2. 0002-approved
3. 0003-shipped
4. 0004-dependent

## Open issues

- None.
