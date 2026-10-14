---
feature: 9200-tree/0013-stale-hybrid
phase: spec
status: final
created: 2026-10-14
updated: 2026-10-14
parent: 9200-tree
stale: design
---

# Fixture spec — 0013-stale-hybrid

A hybrid node carrying an earliest `stale: design` marker, so its derived phase
is `design (backtracked)` — the structural marker is evaluated before the
container `manifest` and the forward artifact-presence rows.
