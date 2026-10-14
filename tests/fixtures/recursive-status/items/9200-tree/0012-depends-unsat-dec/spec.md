---
feature: 9200-tree/0012-depends-unsat-dec
phase: spec
status: final
created: 2026-10-14
updated: 2026-10-14
parent: 9200-tree
---

# Fixture spec — 0012-depends-unsat-dec

A row depending on the unsatisfied decomposing container `0011-decomposing-unsat`.
The target carries no `ship.md` and no `approve` verdict, so this row is `blocked`
naming `0011-decomposing-unsat`; the target's shipped child is never consulted.
