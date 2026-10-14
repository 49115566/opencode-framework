---
feature: 9201-root-a/0001-nested/0002-grand
phase: design
status: final
created: 2026-10-14
updated: 2026-10-14
conflicts-with: "docs/workflow.md"
---

# Design — Fixture drift/union child

A committed test fixture. Its own `conflicts-with` value is `docs/workflow.md`
while its parent row declares `docs/customization.md`; both are present and
unequal, so the declared set is their union and the guard reports a declaration
discrepancy.
