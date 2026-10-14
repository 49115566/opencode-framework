---
feature: 9220-renamed-parent/0003-follower
phase: design
status: final
created: 2026-10-14
updated: 2026-10-14
parent: 9220-renamed-parent
conflicts-with: "0002-new"
---

# Fixture design — 9220-renamed-parent/0003-follower

A committed test fixture, not a real work item. Its `conflicts-with` declaration
names the new local id `0002-new` (formerly the old local id) as a sibling
target, so the renumber guard (`tests/checks/91-integrity-guard.sh`, AC30) can
assert the declaration reference was rewritten by a completed whole-subtree
renumber.

## Summary

Fixture only: the declared target was updated from the old local id to the new.

## Approach

None; fixture data.

## Alternatives considered

- None.

## Interfaces and data model

None.

## Affected areas

None.

## Risks and mitigations

- None.

## Test strategy

Pin the rewritten `conflicts-with` reference.
