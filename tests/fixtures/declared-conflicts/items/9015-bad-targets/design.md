---
feature: 9015-bad-targets
phase: design
status: final
created: 2026-10-08
updated: 2026-10-08
conflicts-with: "docs/*.md, ../escape, /abs.md, 9999-nope"
---

# Design — Fixture malformed and non-existent targets

A committed test fixture. Each target is unresolved: `docs/*.md` carries a glob
metacharacter, `../escape` traverses, `/abs.md` is absolute, and `9999-nope`
resolves to no fixture item and no repository path.
