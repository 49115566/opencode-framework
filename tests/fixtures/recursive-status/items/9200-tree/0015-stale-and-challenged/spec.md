---
feature: 9200-tree/0015-stale-and-challenged
phase: spec
status: final
created: 2026-10-14
updated: 2026-10-14
parent: 9200-tree
stale: spec
---

# Fixture spec — 0015-stale-and-challenged

A node carrying both an earliest `stale: spec` marker and an open challenge. The
structural marker is a spec-target backtrack that invalidated this artifact, so
its derived phase is `spec (backtracked)` — the `stale:` structural derivation is
evaluated before the challenged overlay.
