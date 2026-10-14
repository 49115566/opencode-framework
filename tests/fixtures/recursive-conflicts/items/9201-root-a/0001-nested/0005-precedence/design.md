---
feature: 9201-root-a/0001-nested/0005-precedence
phase: design
status: final
created: 2026-10-14
updated: 2026-10-14
conflicts-with: "0002-grand, 0009-solo, 9203-shared"
---

# Design — Fixture sibling-first child

A committed test fixture. `0002-grand` names a sibling row of its immediate
parent and so resolves to that sibling, not the same-named top-level item;
`0009-solo` and `9203-shared` match no sibling row and fall to the root fallback.
