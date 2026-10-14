---
feature: 9201-root-a/0001-nested/0004-refs
phase: design
status: final
created: 2026-10-14
updated: 2026-10-14
conflicts-with: "9201-root-a/0001-nested/0001-leaf, tests/fixtures, 9201-root-a/0001-nested/0003-shipped"
---

# Design — Fixture recursive-reference child

A committed test fixture. Its targets pin the recursive reference grammar: a
three-segment canonical reference resolves to the fixture item at that path, a
non-reference token (`tests/fixtures`) resolves as a surface path, and a shipped
item's reference still resolves even though it is excluded as a counterpart.
