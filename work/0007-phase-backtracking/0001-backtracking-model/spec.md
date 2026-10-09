---
feature: 0007-phase-backtracking/0001-backtracking-model
phase: spec
status: final
created: 2026-10-08
updated: 2026-10-08
notes: "Nested roadmap child; directory was empty (only .gitkeep) and its scope is the parent roadmap's keystone child, so the roadmap supplies the requirements. Depends on: —, so the child is ready and no override is needed. User resolved the five model forks: (1) represent backtracked/rework/reopened conditions as frontmatter markers while reusing the six existing `phase` values; (2) mark downstream artifacts stale non-destructively, resume at the target phase, and re-run forward; (3) record a backtrack's finding and resolution in a dedicated per-item record; (4) define a general later→earlier reverse rule with a sanctioned-edge/exception table; (5) generalize the shipped `/review`→`/build` rework row under the model while keeping the row."
parent: 0007-phase-backtracking
---

# Phase-backtracking and revision model

## Problem

The lifecycle is forward-only. When a later phase discovers that an earlier
phase's artifact is wrong, the agent prompts say to "stop and report" or "route
back" (`.opencode/agent/builder.md:38`, `.opencode/agent/architect.md:62-63,106-107`,
`docs/workflow.md:768-774`), but no sanctioned mechanism exists to actually
revise the upstream artifact: every phase owns its artifact and no phase may
rewrite another's (`.opencode/agent/builder.md:109-110`,
`.opencode/agent/architect.md:100`). The one reverse edge — the reviewer's
`request-changes` verdict routing to `/build` (`docs/workflow.md:572`) — is a
silent rework with no recorded finding, no way to mark what it invalidated, and
no way to contest it. Two audiences pay for this gap: **framework maintainers**
running the lifecycle, who hit dead ends (a build that finds a design flaw, a
design that finds a spec flaw, a spec that finds the parent roadmap wrong) and
work around them by hand; and **adopters**, who inherit the same one-way
contract. The result is that a later phase can neither safely repair an earlier
artifact nor record why it did — it can only halt or improvise.

## Goals

- Define what a *phase reversal* ("backtrack") is as sanctioned, committed
  lifecycle state, distinct from normal forward progression and from the
  plan-publication revision flow.
- Fix the reverse-edge model: a general rule that a later phase may target an
  earlier phase on the same work item, plus the table of sanctioned edges and any
  exceptions.
- Preserve the ownership invariant: a backtrack re-enters the target phase, whose
  owning agent revises its own artifact or output; the detecting phase never edits
  another phase's artifact.
- Define how a backtrack's detected fault and its resolution are recorded as
  committed `work/` state, so a finding is auditable and a reversal is never
  silent.
- Define how already-produced downstream artifacts are marked stale or superseded
  — non-destructively, preserving committed history — and how the item resumes at
  the target phase and re-runs forward.
- Represent the backtracked, rework, and reopened conditions in committed state
  and the derived-state table without introducing new `phase` values and without
  forking the existing vocabulary.
- Generalize, rather than duplicate, the shipped `request-changes`→`/build`
  rework row, and reconcile the model with the existing "Failure and rollback"
  contract.
- Keep the committed suite green and the documented inventories unchanged.

## Non-goals

- The invocation surface — whether a backtrack is a new command (`/revise`,
  `/reopen`, or similar) or a documented step inside existing commands, and the
  wiring of the agent prompts and commands — owned by
  `0002-reverse-phase-routing`.
- Contesting or adjudicating a finding (challenge/response, who decides, whether
  an unresolved challenge blocks or escalates) — owned by
  `0003-findings-challenge-loop`.
- Revising a parent `roadmap.md` from a child phase (re-scoping, re-sequencing,
  withdrawing, or adding children) — owned by `0004-roadmap-revision`.
- Post-ship PR denial, recall, and reopen, including revoking the shipped signal
  while `ship.md` remains — owned by `0005-post-ship-pr-denial`.
- Reporting the new states in `/status` and the full status/derived-state
  vocabulary implementation — owned by `0006-status-and-derived-state`.
- Committed fixtures, agreement areas, and mutation coverage for the model —
  owned by `0007-backtracking-guards`.
- A new `phase` value, a new command, agent, or skill, or any new runtime
  dependency or toolchain.
- Redefining the review verdict vocabulary, the finding severity scale, or the
  shipped `0006` declared-conflict finding grammar; the model reuses them.
- Any change to branch-level merge reconcile (`0005-merge-conflict-workflow`) or
  to the `Depends on`/readiness contract.
- Automatic re-planning or re-sequencing of roadmap children, and any change to
  the shipped artifacts or decisions of `0001`–`0006`.

## Users and stories

- **As a** framework maintainer running the lifecycle, **I want** a sanctioned
  way to send a later phase's finding back to the phase that owns the wrong
  artifact, **so that** the upstream artifact gets fixed instead of my halting or
  improvising around it.
- **As a** builder or architect whose phase discovered an upstream flaw, **I want**
  to record the finding and hand control to the upstream phase without editing
  that phase's artifact, **so that** the ownership rule still holds and the
  reversal is auditable.
- **As a** framework maintainer, **I want** the artifacts invalidated by a
  backtrack marked stale rather than deleted, **so that** committed history is
  preserved and the item resumes and re-runs the affected phases.
- **As a** reviewer or maintainer, **I want** the backtracked/rework/reopened
  conditions derived from committed state without a new state file or new `phase`
  values, **so that** a fresh clone, a teammate, and CI derive the same phase.
- **As an** adopter, **I want** the reverse-transition model to reuse the
  framework's existing artifact, frontmatter, and finding vocabulary, **so that** I
  do not have to learn or maintain a second one.

## Acceptance criteria

1. **AC1** — Given the workflow authority, when a reader looks up a phase
   reversal ("backtrack"), then it is defined as a sanctioned reverse transition
   on the same unshipped work item, triggered by a detected defect in an earlier
   phase's artifact or output, and explicitly distinguished from forward
   progression and from the plan-publication revision flow.

2. **AC2** — Given the workflow authority, when the reverse-edge model is read,
   then it states the general rule that a later phase may target an earlier phase
   on the same item and holds a table listing the sanctioned edges — at minimum
   `/build`→`/plan`, `/plan`→`/spec`, `/test`→`/build`, `/test`→`/plan`,
   `/test`→`/spec`, `/review`→`/build`, and a per-item phase→parent-`roadmap.md`
   edge — together with every exception that restricts the general rule.

3. **AC3** — Given a backtrack, when it is performed, then control returns to the
   target phase and that phase's owning agent revises its own artifact or output;
   the detecting phase records its finding without editing the target phase's
   artifact; and the "only the owning phase writes its artifact" invariant is
   unchanged.

4. **AC4** — Given a detected defect that triggers a backtrack, when the reversal
   is recorded, then a dedicated per-item committed record captures the finding
   (the detecting phase, the target phase, the affected artifact or output,
   observable evidence, and a status of open or resolved) and, when the revision
   completes, the resolution; entries are append-only and no prior entry is
   erased; and the record is not a phase artifact, adds no `phase` value, and does
   not by itself determine the item's derived phase.

5. **AC5** — Given an upstream revision on an item whose downstream artifacts
   already exist, when the revision happens, then each artifact downstream of the
   target phase is marked stale or superseded in committed state; no downstream
   artifact is deleted or silently rewritten; and the original content remains
   recoverable from committed history.

6. **AC6** — Given an item with stale or superseded downstream artifacts, when its
   phase is derived, then the derived phase is the backtrack target phase and the
   item must pass forward through the downstream phases again before it can be
   reviewed or shipped; a stale artifact is never treated as a satisfied
   prerequisite or as a current phase artifact.

7. **AC7** — Given the derived-state table and the frontmatter conventions, when
   the backtracked, rework, and reopened conditions are represented, then the six
   existing `phase` values are unchanged; each condition is expressed as an
   optional frontmatter marker plus a derived status label rather than a new
   `phase` value; and the table states how a backtracked or reopened item and a
   stale or superseded artifact derive, including precedence over the
   artifact-presence rows those conditions invalidate.

8. **AC8** — Given the shipped review `request-changes`→`/build` derived-state
   row, when the model is defined, then that row is retained and presented as one
   instance of the general backtrack model, no second rework mechanism is
   defined, and the existing routing literal and its consumers remain valid.

9. **AC9** — Given the existing "Failure and rollback" contract, when it is read
   after the model lands, then its "route back" instruction references the
   backtrack model as the sanctioned route, and its rules — report failures, never
   rewrite another phase's artifact to hide a failure, and require confirmation
   for destructive git recovery — remain in force unchanged.

10. **AC10** — Given an item whose `ship.md` is present, when a reversal is
    considered, then the backtrack model excludes the item and identifies it as
    the post-ship reopen case handled by a separate path; the model changes
    neither the shipped signal nor the readiness contract.

11. **AC11** — Given the repository surfaces, when the model is authored, then the
    workflow authority states the model once as its single authority, the
    artifact-conventions authority documents the per-item record and the
    frontmatter markers it introduces, and `AGENTS.md` references the model; no
    surface states a conflicting reverse-transition rule.

12. **AC12** — Given the repository after the change, when the project's
    configured test command runs, then it passes; no new command, agent, or skill
    is introduced and no documented inventory count changes; and the six core
    phase commands, the `phase` value set, and the `Depends on`/readiness contract
    are unchanged.

## Edge cases

- **No downstream artifacts yet.** A backtrack taken before any downstream
  artifact exists (for example `/plan`→`/spec` when only the spec exists) marks
  nothing stale; the item simply derives the target phase.
- **Self-target.** A phase targeting itself is not a reversal and is refused.
- **Unrecorded backtrack (Assumption).** A reverse edge taken without a recorded
  finding is not a sanctioned backtrack; see Open questions.
- **Target owns no artifact.** Targeting `/build` is a rework of implementation
  and its tasks, not a revision of an upstream artifact; no artifact is revised,
  but downstream verification and review are still stale.
- **Open backtrack not yet resolved.** While the target phase has not revised,
  the record stays `open`, the item derives the target phase, and downstream
  artifacts stay stale.
- **Revised artifact clears its marker.** When the target phase revises its own
  artifact, the artifact is current again; only artifacts downstream of the target
  remain stale until their phases re-run.
- **Sequential backtracks.** A second backtrack taken before the first is resolved
  (for example `/test`→`/plan` then `/plan`→`/spec`) preserves record order, and
  the item derives the earliest outstanding target.
- **Shipped item.** An item with `ship.md` is out of scope (AC10); its reversal is
  the post-ship reopen path, not a backtrack.
- **Stale artifact mistaken for current.** A stale or superseded artifact must
  never satisfy a downstream prerequisite or be read as the item's current phase
  (AC6).
- **Out-of-order record entries.** A resolution recorded before its finding is
  malformed and reported, not silently reordered.
- **Two items in parallel.** A backtrack touches only its own item's committed
  state and changes no other item's readiness.
- **Marker versus `status`.** The new markers are distinct from the existing
  frontmatter `status` (`draft`/`final`/`blocked`) and do not overload it.

## Open questions

- [x] **State representation** — resolved (user): reuse the six `phase` values;
  represent backtracked/rework/reopened as optional frontmatter markers plus a
  derived status label. No new `phase` value.
- [x] **Downstream handling** — resolved (user): mark downstream artifacts
  stale/superseded non-destructively, resume at the target phase, and re-run the
  downstream phases forward.
- [x] **Finding record** — resolved (user): a dedicated per-item committed record
  holds the finding and its resolution.
- [x] **Reverse-edge set** — resolved (user): a general later→earlier rule with a
  sanctioned-edge and exception table, not a closed list.
- [x] **Rework composition** — resolved (user): generalize the shipped
  `request-changes`→`/build` row under the model while keeping the row.
- [ ] **Assumption — no silent backtrack.** Every backtrack must carry a recorded
  finding before the reverse edge is taken; there is no unrecorded reversal.
  Confirm, or allow a lightweight reversal without a record. — owner: user,
  needed by: design.
- [ ] **Deferred — exact vocabulary.** The precise marker tokens, the record's
  file/section shape, and how a revised artifact clears its marker are design
  choices; the semantics above are fixed. — owner: architect, needed by: design.

## Dependencies and constraints

- **Ready.** The parent roadmap lists this child as `Depends on: —`, so it is
  ready and no override is needed.
- **Keystone.** `0002-reverse-phase-routing`, `0003-findings-challenge-loop`,
  `0004-roadmap-revision`, `0005-post-ship-pr-denial`,
  `0006-status-and-derived-state`, and `0007-backtracking-guards` all consume the
  model fixed here, so it must be final before they plan.
- **Extend, do not fork.** The model builds on the frontmatter `notes` convention
  (`docs/artifact-conventions.md:15-79`), the derived-state table
  (`docs/workflow.md:557-579`), the review `request-changes`→`/build` row
  (`docs/workflow.md:572`), and "Failure and rollback" (`docs/workflow.md:768-774`).
  It reuses the shipped `0006` finding grammar and introduces no second state or
  finding vocabulary.
- **Preserve the ownership invariant.** A backtrack re-enters the target phase,
  whose owning agent revises its own artifact (`.opencode/agent/builder.md:109-110`,
  `.opencode/agent/architect.md:100`); the detecting phase never edits another
  phase's artifact.
- **Committed suite constraints.** `tests/checks/20-lifecycle.sh` pins the six
  phase commands, the derived-state route literals (including the
  `request-changes` row), and the artifact names in the workflow authority, README,
  and `workflow-lifecycle` skill; `tests/checks/40-inventory.sh` pins the README
  Layout counts and inventory tables; the suite never reads live `work/**`
  (`tests/README.md:29`). This item must keep those green; committed fixtures and
  mutation coverage are `0007-backtracking-guards`.
- **Recon correction.** `status.md:229-230` already lists `rework` in its phase
  vocabulary for the existing review rework row; the model must stay consistent
  with that label rather than inventing a competing one.
- **Sibling boundaries.** Invocation/wiring is `0002`; challenge adjudication is
  `0003`; parent-roadmap revision is `0004`; post-ship reopen is `0005`; status
  reporting is `0006`; committed guards are `0007`. This item fixes the model they
  consume and implements none of their routes.
- **Framework-internal change only.** Docs, prompts, and tests; no runtime
  dependency, service, or new toolchain.
- **Assumption — naming surfaces for testability.** Because the deliverable is the
  framework's own documents, the acceptance criteria name the surfaces that must
  carry the model (`docs/workflow.md`, `docs/artifact-conventions.md`,
  `AGENTS.md`); they specify required content, not implementation choices.
