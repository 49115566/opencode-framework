---
feature: 0007-phase-backtracking/0002-reverse-phase-routing
phase: spec
status: final
created: 2026-10-08
updated: 2026-10-08
notes: "Nested roadmap child; directory was empty (only .gitkeep) and its scope is the parent roadmap's 'Reverse phase routing and upstream re-entry' child, so the roadmap supplies the requirements. Readiness: 0001-backtracking-model is shipped (its ship.md is present), so the sole dependency is satisfied and no override is needed. User resolved the three routing forks: (1) no new command — the reverse edges use the existing phase commands as the entry point, with the detecting agent recording the finding and its handoff routing the user to the target phase; (2) 0002 wires only /build->/plan and /plan->/spec plus the plan-publication round trip, leaving /test->... to 0003 and parent-roadmap/post-ship to 0004/0005; (3) the adopter-pristine template/AGENTS.md is kept in sync with root AGENTS.md."
parent: 0007-phase-backtracking
---

# Reverse phase routing and upstream re-entry

## Problem

`0001-backtracking-model` defines a *backtrack* — a sanctioned reverse transition
on an unshipped work item — together with the recorded finding, the non-destructive
`stale:` marking, and the derived-state precedence (`docs/workflow.md` →
"Phase reversal (backtracking)"). What it deliberately does not do is give the
reverse edges an operational entry point: the agent prompts still end the thought
at "stop and route back" with no route (`builder.md:38`,
`architect.md:62-63,106-107`), the phase `Next:` handoffs and the
`workflow-lifecycle` routing block only ever move forward, and nothing tells a
maintainer what to actually type when a build finds a design flaw or a plan finds
a spec flaw. The plan-publication flow has the same gap from the other direction:
a `plan/<ref>` pull request that is denied, closed, or sent back for changes has
no documented route back into `/plan`, even though the shipper's plan-mode
revision step (`.opencode/agent/shipper.md:263-268`,
`.opencode/command/ship.md:112-115`) already knows how to add a commit to an
existing plan branch. Two audiences pay for this gap: **framework maintainers**
running the lifecycle, who read that a route exists but cannot find it, and
**adopters**, whose own agent prompts and `AGENTS.md` inherit the same
forward-only handoffs. The result is that the model `0001` fixed remains
theoretical at exactly the moment it is needed.

## Goals

- Give the `/build`→`/plan` reverse edge an operational entry point: a builder
  that finds the design wrong can record the finding, invalidate what must be
  redone, and hand control to `/plan` without editing the architect's artifact.
- Give the `/plan`→`/spec` reverse edge the same entry point for an ambiguous or
  wrong spec.
- Make re-entry itself deterministic: a target phase invoked on an item with an
  open finding against it revises its own artifact, records the resolution, and
  resumes the forward lifecycle from that phase.
- Wire the plan-publication round trip so a denied or changes-requested
  `plan/<ref>` pull request routes back to `/plan` and republishes through the
  existing plan-revision path, without force-pushing.
- State the routing consistently on every surface a maintainer or adopter reads:
  the agent prompts, the `/build` and `/plan` commands, the phase `Next:`
  handoffs, the always-loaded contract, the lifecycle routing block, and the
  adopter-pristine template.
- Keep the change additive and framework-internal: no new command, agent, skill,
  state file, or runtime dependency, and the committed suite stays green.

## Non-goals

- `/test`→`/build`, `/test`→`/plan`, and `/test`→`/spec` reverse edges, and
  contesting or adjudicating a finding — owned by `0003-findings-challenge-loop`.
- Revising a parent `roadmap.md` from a child phase — owned by
  `0004-roadmap-revision`.
- Post-ship PR denial, recall, and reopen, including `reopened:` production and
  shipped-signal revocation — owned by `0005-post-ship-pr-denial`.
- Reporting the new states in `/status` and the rest of the derived-state/status
  vocabulary implementation — owned by `0006-status-and-derived-state`.
- Committed fixtures, agreement areas, and mutation coverage for the routing —
  owned by `0007-backtracking-guards`.
- Redefining the `0001` model, the six `phase` values, the `backtracks.md`
  record, the `stale:` marker, the review verdict vocabulary, or the
  `Depends on`/readiness contract; this item only wires the routes the model
  fixed.
- A new command, agent, or skill, and any change to the documented command,
  agent, or skill inventories — including a `/revise` or `/reopen` command.
- Automatic re-planning or re-sequencing of roadmap children, and any
  branch-level merge reconcile.

## Users and stories

- **As a** builder whose task cannot be implemented because the design is wrong,
  **I want** to record the finding and send the item back to `/plan`, **so that**
  the design is fixed by its owner instead of my improvising a redesign or
  halting.
- **As an** architect whose design rests on an ambiguous or wrong spec, **I want**
  to record the finding and send the item back to `/spec`, **so that** the
  requirement is corrected before I design around a broken premise.
- **As a** framework maintainer, **I want** the phase `Next:` handoffs and the
  routing guide to name the exact reverse command, **so that** I can take the
  reverse edge without re-deriving it from the model.
- **As a** maintainer of a denied plan pull request, **I want** the item routed
  back to `/plan` and republished on the existing plan branch, **so that** the
  revised plan reaches reviewers without opening a competing branch or
  force-pushing.
- **As an** adopter, **I want** the same routing in my `AGENTS.md` and agent
  prompts, **so that** I inherit the reverse transitions rather than a
  forward-only contract.

## Acceptance criteria

1. **AC1** — Given a builder implementing a task that discovers the design is
   wrong, when it takes the `/build`→`/plan` reverse edge, then the detecting
   `/build` phase records the finding in the item's backtrack record with
   detecting phase `/build`, target phase `/plan`, and the affected design
   artifact(s) named, and its `Next:` handoff directs the user to re-run `/plan`
   for that item.

2. **AC2** — Given an architect planning an item whose spec is ambiguous or
   wrong, when it takes the `/plan`→`/spec` reverse edge, then the detecting
   `/plan` phase records the finding in the item's backtrack record with detecting
   phase `/plan`, target phase `/spec`, and the affected `spec.md` named, and its
   `Next:` handoff directs the user to re-run `/spec` for that item.

3. **AC3** — Given either reverse edge in AC1 or AC2, when it is taken, then the
   detecting phase never edits the target phase's artifact; the finding is
   recorded before the reverse edge is taken; and control returns to the target
   phase, whose owning agent performs the revision.

4. **AC4** — Given an item with an open finding whose target phase is P and
   artifacts downstream of P, when the reverse edge is taken, then those
   downstream artifacts are marked stale per the `0001` model and the item
   derives phase P; the marking is non-destructive and no downstream artifact is
   deleted or rewritten.

5. **AC5** — Given an item with an open backtrack finding targeting phase P, when
   the owning agent for P runs (the user re-runs that phase's command, or the
   agent otherwise re-enters P), then it reads the open finding, revises its own
   artifact, appends a resolution entry, and the item resumes the forward
   lifecycle from P as if the later phases had not yet run.

6. **AC6** — Given an item with no open finding targeting an earlier phase, when
   its phase command runs again, then it behaves as ordinary forward
   progression/revision and records no backtrack; re-entry is not triggered
   without an open finding.

7. **AC7** — Given a `plan/<ref>` pull request that is denied, closed, or sent
   back for changes, when the maintainer responds, then the documented route is
   to re-run `/plan` for the item and republish through the existing
   plan-publication revision path — a commit added to the existing `plan/<ref>`
   branch and PR (or a new PR if the branch was pruned), never a force-push —
   and this round trip is presented as the plan-publication revision flow, not as
   a recorded backtrack.

8. **AC8** — Given the repository surfaces a maintainer reads, when the routing
   lands, then the `/build` and `/plan` agent prompts, the `/build` and `/plan`
   commands, the phase `Next:` handoffs in the workflow authority, the `AGENTS.md`
   lifecycle/routing reference, the `workflow-lifecycle` routing block, and the
   adopter-pristine `template/AGENTS.md` all state the reverse-edge routing, and
   no surface still presents "stop and report"/"route back" as if no sanctioned
   route existed.

9. **AC9** — Given the routing is wired, when the repository surfaces are
   inspected, then the six core phase commands and their command→agent pairings
   are unchanged; no command, agent, or skill is added or removed; and no
   documented inventory count or signature changes.

10. **AC10** — Given the `0001` model and this item's wiring, when both are read,
    then the model remains the single authority for the reverse-edge set,
    ownership, the record, and the stale marker, and this item introduces no
    second reverse-transition mechanism, no new `phase` value, no new state
    file, and no change to the readiness contract.

11. **AC11** — Given the item's scope boundaries, when the wired routes are
    inspected, then parent-`roadmap.md` revision and post-ship reopen are not
    wired by this item, and the `/test` reverse edges are not wired (they remain
    `0003`'s).

12. **AC12** — Given the repository after the change, when the project's
    configured test command runs, then it passes, including the lifecycle,
    inventory, and command-signature agreements, and the root and
    adopter-pristine `AGENTS.md` surfaces remain in agreement.

## Edge cases

- **Reverse edge before downstream artifacts exist.** A `/plan`→`/spec` edge
  taken when only `spec.md` exists marks nothing stale; the item simply derives
  `/spec`.
- **Sequential backtracks.** Two open findings on one item preserve record order
  and derive the earliest outstanding target, per the `0001` model; re-entry at
  that target does not silently discard the later finding.
- **Self-target.** A phase targeting itself is not a reversal and is refused;
  the routing must not offer it.
- **Shipped item.** An item whose `ship.md` is present is out of scope for a
  backtrack; the routing must not present a reverse edge for it (post-ship reopen
  is `0005`).
- **A finding recorded but the target phase never re-entered.** The finding stays
  open, the downstream artifacts stay stale, and the item continues to derive the
  target phase; nothing resumes forward on its own.
- **File a target phase cannot revise.** A `/build` target is a rework of
  implementation and tasks rather than a revision of an upstream artifact; the
  routing must not imply `/build` has an upstream artifact to edit, and the
  `/build`→`/plan` edge (not `/build`→`/build`) is what this item wires.
- **Plan PR denied after its plan already merged.** Re-running `/plan` produces a
  revision republished through the plan-publication revision path; it does not
  reopen a merged item's code phase or create a `ship.md`.
- **Plan branch pruned.** Republishing after a denied plan PR opens a new
  `plan/<ref>` PR rather than force-pushing or reusing a deleted branch.
- **`gh` unavailable.** The documented route degrades to local commits on the
  plan branch plus the exact push/PR commands, mirroring the existing shipper
  behavior.
- **Two items in parallel.** A routing action touches only its own item's
  committed state and changes no other item's readiness.
- **Ordinary forward re-run mistaken for a backtrack.** Re-running a phase with
  no open finding is normal progression and must not fabricate a finding
  (AC6).

## Open questions

- [x] **Invocation surface** — resolved (user): no new command; the reverse edges
  use the existing phase commands as the entry point, with the detecting agent
  recording the finding and its handoff routing to the target phase. Recorded
  because it keeps the six-command inventory and the committed suite's signature
  and inventory agreements unchanged.
- [x] **Reverse-edge coverage** — resolved (user): wire only `/build`→`/plan` and
  `/plan`→`/spec`, plus the plan-publication round trip; `/test`→… is `0003`,
  parent-roadmap is `0004`, post-ship is `0005`.
- [x] **Adopter parity** — resolved (user): mirror the routing reference into
  `template/AGENTS.md` so adopters are not left with a forward-only contract.
- [ ] **Deferred — exact wording and mechanics.** The precise handoff prose, which
  role applies the `stale:` markers when the edge is taken, how re-entry detects
  the open finding, and how the phase commands phrase the route are design
  choices; the observable routing behavior above is fixed. — owner: architect,
  needed by: design.
- [ ] **Assumption — no unrecorded reversal.** Every reverse edge carries a
  recorded finding before it is taken; there is no lightweight reversal. This
  restates the `0001` model's recorded-finding precondition, which this item
  wires rather than changes. — owner: user, needed by: design.

## Dependencies and constraints

- **Ready.** The parent roadmap lists `Depends on: 0001-backtracking-model`, and
  that child is shipped (its `ship.md` is present), so the sole dependency is
  satisfied under the readiness algorithm (`docs/workflow.md` → "Dependencies and
  readiness") and no override is needed.
- **Extend, do not fork.** The routing builds directly on `0001`'s
  `## Phase reversal (backtracking)` section, the `backtracks.md` record, the
  `stale:` marker, and the derived-state precedence. The `0001` model is the
  single authority for the reverse-edge set; this item only wires the
  `/build`→`/plan`, `/plan`→`/spec`, and plan-publication routes.
- **Preserve the ownership invariant.** The detecting phase records the finding
  and never edits the target phase's artifact; the target phase's owning agent
  revises its own artifact.
- **Plan-publication alignment.** The plan round trip extends, and must not
  contradict, `docs/workflow.md` → "Plan publication" and the shipper's
  plan-mode revision step (`.opencode/agent/shipper.md:263-268`,
  `.opencode/command/ship.md:112-115`); it is explicitly not a backtrack.
- **Committed suite constraints.** `tests/checks/20-lifecycle.sh` pins the six
  phase commands, the derived-state route literals (including the
  `request-changes` row), and the artifact names across the always-loaded
  contract, the workflow authority, the README, and the `workflow-lifecycle`
  skill; `tests/checks/40-inventory.sh` pins the README Layout counts and
  inventory tables; `tests/checks/96-signature-sweep.sh` pins every command
  signature on the AGENTS, README, workflow, and skill surfaces. This item must
  keep them green. Committed fixtures and mutation coverage are
  `0007-backtracking-guards`.
- **Adopter-surface agreement.** The root `AGENTS.md` is maintainer-bootstrapped
  and `template/AGENTS.md` is the adopter-pristine source; the routing reference
  must appear in both so the two do not drift.
- **Framework-internal change only.** Docs, prompts, and commands; no runtime
  dependency, service, new toolchain, or new command/agent/skill.
- **Assumption — naming surfaces for testability.** Because the deliverable is
  the framework's own prompts and documents, the acceptance criteria name the
  surfaces that must carry the routing (the `/build` and `/plan` prompts and
  commands, the phase `Next:` handoffs, `AGENTS.md`, the `workflow-lifecycle`
  skill, and `template/AGENTS.md`); they specify required content and behavior,
  not implementation choices.
