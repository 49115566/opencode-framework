---
feature: 9200-tree/0010-depends-decomposing
phase: spec
status: final
created: 2026-10-14
updated: 2026-10-14
parent: 9200-tree
---

# Fixture spec — 0010-depends-decomposing

A row depending on the decomposing node `0009-decomposing-approved`. The target
is satisfied by its own `approve` verdict, so this row is `ready`; the target's
own child is never consulted.
