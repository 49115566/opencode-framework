---
feature: 9201-root-a/0001-nested/0006-bad
phase: design
status: final
created: 2026-10-14
updated: 2026-10-14
conflicts-with: "../escape, /abs.md, docs/*.md, 9999-nope, docs/no-such-file.md, 9201-root-a/0001-nested/0006-bad, "
---

# Design — Fixture malformed and unresolved targets

A committed test fixture. Every target is unresolved and reported: `../escape`
traverses, `/abs.md` is absolute, `docs/*.md` is a glob, `9999-nope` resolves to
no sibling row and no item, `docs/no-such-file.md` resolves to no repository
path, the self-reference is malformed, and the trailing empty token is blank.
