---
feature: 9200-tree/0009-decomposing-approved
phase: design
status: final
created: 2026-10-14
updated: 2026-10-14
parent: 9200-tree
---

# Fixture design — 0009-decomposing-approved

The hybrid node's own design. Because it carries its own phase artifacts, its
derived phase is its own (`ship`) rather than the container phase `manifest`, even
though it also decomposes into a child.
