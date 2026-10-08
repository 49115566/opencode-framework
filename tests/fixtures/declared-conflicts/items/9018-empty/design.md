---
feature: 9018-empty
phase: design
status: final
created: 2026-10-08
updated: 2026-10-08
conflicts-with: ""
---

# Design — Fixture present-but-empty declaration

A committed test fixture. A present, empty `conflicts-with` value is malformed
and reported unresolved, unlike an absent field, which declares nothing.
