---
feature: 9200-tree/0011-decomposing-unsat/0001-shipped-child
phase: spec
status: final
created: 2026-10-14
updated: 2026-10-14
parent: 9200-tree/0011-decomposing-unsat
---

# Fixture spec — 0001-shipped-child

A depth-3 shipped child of an unsatisfied decomposing node. Its own `ship.md`
makes it `ready`; it is never consulted when readiness is derived for the
dependent of its parent.
