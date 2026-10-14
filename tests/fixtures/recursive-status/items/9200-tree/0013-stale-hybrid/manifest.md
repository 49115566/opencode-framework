---
feature: 9200-tree/0013-stale-hybrid
phase: manifest
status: final
created: 2026-10-14
updated: 2026-10-14
parent: 9200-tree
---

# Manifest — Fixture stale hybrid

## Initiative

A hybrid fixture node that carries its own `spec.md` (marked `stale: design`) and
a manifest. Its earliest `stale:` marker derives the backtracked phase at the
node, evaluated before the container `manifest` and the artifact-presence rows.
It decomposes into no active child, so its manifest lists none. Read-only fixture
data; allocates no real sequence number.

## Assumptions

- Fixture data only; readiness and phase are derived live and are never stored.

## Children

| Local id | Title | Scope | Depends on | conflicts-with | Canonical reference |
| -------- | ----- | ----- | ---------- | -------------- | ------------------- |

## Sequencing

1. (none)

## Open issues

- No active child: the fixture exists to prove the `stale:` overlay precedence at
  a hybrid node, not to exercise a child set.
