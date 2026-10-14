---
feature: 9200-tree/0001-hybrid
phase: spec
status: final
created: 2026-10-14
updated: 2026-10-14
parent: 9200-tree
---

# Fixture spec — 0001-hybrid

A hybrid node that both decomposes and carries its own phase artifacts. It has a
`spec.md` and a `design.md` but no `tasks.md`, so its own derived phase is
`design` and its own artifacts take precedence over the container `manifest`.
