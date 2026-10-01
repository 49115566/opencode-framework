---
name: spec-writing
description: Use when writing or reviewing a feature specification, user stories, goals, non-goals, or acceptance criteria in Given/When/Then form. Triggers during the /spec phase and whenever requirements must be made precise and testable.
---

# Writing specifications

A spec is a contract between the person who wants the change and the person who
builds it. It states *what* and *why*, never *how*. If you find yourself naming a
library, schema, or endpoint, you are writing design, not a spec.

## Structure

Follow `docs/artifact-conventions.md` for the `spec.md` template and frontmatter.

## Problem

One short paragraph: who is affected, what they cannot do today, and the cost of
that. Avoid solution language. If the problem is vague, the spec will be wrong.

## Goals and non-goals

- Goals are outcomes, phrased so that success is observable.
- Non-goals are the tempting adjacent work you are deliberately excluding. The
  best non-goals prevent scope creep from things a reasonable person might assume
  are included.

## User stories

`As a <role>, I want <capability>, so that <benefit>.` One per distinct kind of
user or use case. Roles should be real — a developer, an operator, an end user.

## Acceptance criteria

This is the part that matters. Rules:

- Number them `AC1`, `AC2`, … so design and tests can reference them.
- Write each as **Given** <context>, **when** <action>, **then** <observable
  result>.
- One behavior per criterion. Split compound criteria.
- Make the "then" observable — a return value, a state change, a rendered output,
  an emitted event, an error. "Works correctly" is not observable.
- Cover the happy path, then the errors, then the edges.

### Turning prose into criteria

Weak: "Users can reset their password."
Strong: "**AC1** — Given a registered email, when the user requests a reset, then
a single-use token is emailed and no account state changes until the token is
used." Plus **AC2** for expiry, **AC3** for reuse, **AC4** for unknown email
(must not reveal whether the account exists).

## Edge cases

Enumerate: empty and missing inputs, boundaries (zero, one, max), errors, timeouts,
concurrency, permissions, and the "already happened / out of order" cases.

## Open questions

List unknowns with an owner and the phase by which they must be resolved. An
unresolved question that changes the design makes `status: blocked`.

## Quality bar

- Every acceptance criterion is testable without reading the implementation.
- No implementation detail anywhere in the spec.
- Non-goals are explicit.
- Assumptions are labeled as assumptions, not stated as fact.
