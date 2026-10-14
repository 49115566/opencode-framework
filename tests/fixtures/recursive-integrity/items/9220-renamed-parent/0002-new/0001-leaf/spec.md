---
feature: 9220-renamed-parent/0002-new/0001-leaf
phase: spec
status: final
created: 2026-10-14
updated: 2026-10-14
parent: 9220-renamed-parent/0002-new
---

# Fixture spec — 9220-renamed-parent/0002-new/0001-leaf

A committed test fixture, not a real work item. Its `feature:` and `parent:`
values both carry the new path produced by a completed whole-subtree renumber,
so the renumber guard (`tests/checks/91-integrity-guard.sh`, AC30) can assert
every descendant artifact's reference was rewritten.

## Problem

Fixture only.

## Goals

- Carry the new canonical reference after the renumber.

## Non-goals

- None.

## User stories

- **As a** fixture, **I want** the new reference, **so that** the renumber guard
  can assert it.

## Acceptance criteria

1. **AC1** — Given the fixture, when it is scanned, then only the new reference
   is present.
