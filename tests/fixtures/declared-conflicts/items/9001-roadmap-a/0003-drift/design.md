---
feature: 9001-roadmap-a/0003-drift
phase: design
status: final
created: 2026-10-08
updated: 2026-10-08
parent: 9001-roadmap-a
conflicts-with: "docs/customization.md"
---

# Design — Fixture drift child

A committed test fixture. Its own `conflicts-with` (`docs/customization.md`)
disagrees with its parent row's cell (`docs/workflow.md`), so the guard detects
and names the parent/own declaration drift.
