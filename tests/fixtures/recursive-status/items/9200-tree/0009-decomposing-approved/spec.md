---
feature: 9200-tree/0009-decomposing-approved
phase: spec
status: final
created: 2026-10-14
updated: 2026-10-14
parent: 9200-tree
---

# Fixture spec — 0009-decomposing-approved

A hybrid node that decomposes into a `.gitkeep`-only child and carries its own
full phase artifact set. It is the dependency target of `0010-depends-decomposing`
and is satisfied by its own `approve` verdict, so the dependent is `ready` even
though the target's child is `not started`.
