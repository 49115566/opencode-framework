---
feature: 9200-tree
phase: manifest
status: final
created: 2026-10-14
updated: 2026-10-14
---

# Manifest — Fixture recursive tree

## Initiative

A fixture root for the recursive readiness and `/status` guard
(`tests/checks/89-recursive-status-guards.sh`, suite token `AC27`). It shadows
the live artifact root: its ids stay in the non-allocating `92xx` band and
allocate no real sequence number, and it is read-only test data, never shipped.
Its tree is at least three levels deep and contains a hybrid node (a node that
both decomposes and carries its own phase artifacts), a `.gitkeep`-only leaf, a
deliberate dependency cycle, and satisfied/unsatisfied sibling dependencies at
more than one level.

## Assumptions

- Fixture data only; readiness and phase are derived live and are never stored.

## Children

| Local id | Title | Scope | Depends on | conflicts-with | Canonical reference |
| -------- | ----- | ----- | ---------- | -------------- | ------------------- |
| 0001-hybrid | Hybrid node | A node that both decomposes and carries its own phase artifacts. | — | — | 9200-tree/0001-hybrid |
| 0002-shipped | Shipped row | A full item with a non-recalled `ship.md`. | — | — | 9200-tree/0002-shipped |
| 0003-approved | Approved row | A full item with an `approve` review and no `ship.md`. | — | — | 9200-tree/0003-approved |
| 0004-rejected | Rejected row | A full item with a `request-changes` review and no `ship.md`. | — | — | 9200-tree/0004-rejected |
| 0005-noreview | No-review row | A checked-through item with no `review.md`. | — | — | 9200-tree/0005-noreview |
| 0006-precedence | Precedence row | A full item with a `request-changes` review and a non-recalled `ship.md`. | — | — | 9200-tree/0006-precedence |
| 0007-recalled | Recalled row | A full item whose `ship.md` carries a recall marker. | — | — | 9200-tree/0007-recalled |
| 0008-dependent | Dependent row | A row depending on the six dependency-signal rows above. | 0002-shipped, 0003-approved, 0004-rejected, 0005-noreview, 0006-precedence, 0007-recalled | — | 9200-tree/0008-dependent |
| 0009-decomposing-approved | Approved decomposing row | A hybrid node whose own review is `approve`. | — | — | 9200-tree/0009-decomposing-approved |
| 0010-depends-decomposing | Depends-decomposing row | A row depending on a decomposing node. | 0009-decomposing-approved | — | 9200-tree/0010-depends-decomposing |
| 0011-decomposing-unsat | Unsatisfied decomposing row | A pure container whose own signal is absent. | — | — | 9200-tree/0011-decomposing-unsat |
| 0012-depends-unsat-dec | Depends-unsat-dec row | A row depending on an unsatisfied decomposing node. | 0011-decomposing-unsat | — | 9200-tree/0012-depends-unsat-dec |
| 0013-stale-hybrid | Stale hybrid row | A hybrid node carrying an earliest `stale: design` marker. | — | — | 9200-tree/0013-stale-hybrid |
| 0014-challenged-node | Challenged row | An unshipped node with an open challenge and no `ship.md`. | — | — | 9200-tree/0014-challenged-node |
| 0015-stale-and-challenged | Stale-and-challenged row | A node carrying both an earliest `stale: spec` marker and an open challenge. | — | — | 9200-tree/0015-stale-and-challenged |

## Sequencing

1. 0001-hybrid
2. 0002-shipped
3. 0003-approved
4. 0004-rejected
5. 0005-noreview
6. 0006-precedence
7. 0007-recalled
8. 0008-dependent
9. 0009-decomposing-approved
10. 0010-depends-decomposing
11. 0011-decomposing-unsat
12. 0012-depends-unsat-dec
13. 0013-stale-hybrid
14. 0014-challenged-node
15. 0015-stale-and-challenged

## Open issues

- None.
