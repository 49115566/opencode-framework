---
feature: 0007-phase-backtracking/0003-findings-challenge-loop
phase: spec
status: final
created: 2026-10-08
updated: 2026-10-08
notes: "Nested roadmap child; directory was empty (only .gitkeep) and its scope is the parent roadmap's 'Contestable findings and adjudication loop' child, so the roadmap supplies the requirements. Readiness: the sole dependency, 0001-backtracking-model, is shipped (its ship.md is present), so under the readiness algorithm the child is ready and no override is needed. User resolved the five adjudication forks: (1) the producing phase re-evaluates a challenge first and the user breaks a tie; (2) an unresolved challenge blocks the item and escalates, deriving a 'challenged' state; (3) contestable findings are review.md findings and /test defects, including a test defect that is really a spec or design fault; (4) no new command — raise the challenge through existing phase surfaces and record it in a committed, append-only per-item challenge/response record distinct from backtracks.md; (5) a sustained challenge overturns/adjusts the finding and the verdict is recomputed while a rejected challenge leaves the finding and verdict unchanged and normal routing resumes."
parent: 0007-phase-backtracking
---

# Contestable findings and adjudication loop

## Problem

A later phase can already send an upstream artifact back for revision
(`docs/workflow.md` → "Phase reversal (backtracking)"), but nobody can dispute
the *finding* that triggered it. `/review` classifies findings Blocker / Major /
Minor / Nit and sets `request-changes` if any Blocker or Major survives scrutiny
(`.opencode/agent/reviewer.md:72-76`), and its only handoff is `/build` to address
the blockers (`.opencode/agent/reviewer.md:104-110`); the builder may not edit
`review.md` (`.opencode/agent/builder.md:120-121`). So when the author believes a
finding is wrong, its severity is inflated, or the acceptance-criterion
interpretation is mistaken, there is no recorded way to say so — the author can
only silently comply, silently override, or halt. A `/test` defect is worse: the
tester treats every production-code fault as a builder defect and hands it to
`/build` (`.opencode/agent/tester.md:77-78,134-140`), even when the real fault is
in the spec or the design, so the item is pushed at the wrong artifact. The one
escape hatch — labeling a concern a question rather than a defect
(`.opencode/agent/reviewer.md:92-93`) and declining a Nit
(`.opencode/skill/code-review/SKILL.md:24-28`) — is unrecorded and cannot contest
a Blocker. Two audiences pay for this: **framework maintainers**, who hit the
dead end while running the lifecycle, and **adopters**, who inherit the same
one-way verdict. `0001-backtracking-model` and `0002-reverse-phase-routing`
deliberately deferred contesting a finding to this item
(`work/0007-phase-backtracking/0001-backtracking-model/spec.md:62-64`,
`work/0007-phase-backtracking/0002-reverse-phase-routing/design.md:307-308`), so
the gap is now the only missing reverse interaction.

## Goals

- Give an author a **recorded** way to challenge a finding, its severity, or an
  acceptance-criterion interpretation, with evidence and rationale, without
  editing the artifact owned by the phase that produced the finding.
- Define an adjudication in which the producing phase re-evaluates the challenge
  first and, when it remains unresolved, the user decides — and record who
  decided and why.
- Define how a **sustained** challenge changes the finding, the verdict, and the
  next command, and how a **rejected** challenge leaves them unchanged.
- Cover a `/test` defect that is really a spec or design fault, routing it
  upstream through the sanctioned backtrack model rather than only to `/build`;
  wire the `/test`→`/build`, `/test`→`/plan`, and `/test`→`/spec` edges that
  `0002` deferred here.
- Represent a challenge as committed, append-only per-item state and a blocked
  ("challenged") condition consistent with `0001`'s marker model, without a new
  `phase` value, state file, command, agent, or skill.
- Reuse the existing severity scale, finding format, and verdict vocabulary; do
  not fork a second one.
- Keep the committed suite green and every documented inventory unchanged.

## Non-goals

- Redefining the review verdict vocabulary (`approve`/`request-changes`), the
  Blocker/Major/Minor/Nit severity scale, the review finding format, the
  `0001` backtrack model, the `backtracks.md` record, the `stale:`/`reopened:`
  markers, or the `0002` re-entry mechanics. This item extends them.
- Revising a parent `roadmap.md` from a child phase — owned by
  `0004-roadmap-revision`.
- Post-ship PR denial, recall, and reopen — owned by `0005-post-ship-pr-denial`.
- The full `/status` phase vocabulary and derived-state reporting implementation
  — owned by `0006-status-and-derived-state`; this item fixes the state shape
  `0006` consumes.
- Committed fixtures, agreement areas, and mutation coverage for the challenge
  loop — owned by `0007-backtracking-guards`.
- A new command, agent, or skill, and any change to the documented command,
  agent, or skill inventories — including a `/challenge`, `/revise`, or
  `/reopen` command.
- Redefining the shipped `0006-parallel-plan-conflicts` declared-conflict finding
  grammar, or any branch-level merge reconcile (`0005-merge-conflict-workflow`).
- Automatic adjudication, automatic overturning of a finding, or automatic
  re-planning/re-sequencing of roadmap children.
- Any change to the ownership invariant, the `Depends on`/readiness contract, or
  the shipped signal (`ship.md` presence).

## Users and stories

- **As a** builder whose review finding I believe is wrong or mis-severitied,
  **I want** to record a challenge with evidence, **so that** I can dispute it
  instead of silently complying, silently overriding, or halting.
- **As a** reviewer, **I want** to re-evaluate a challenge against the spec and
  the diff, **so that** a mistaken finding is corrected and a valid one stands
  on the record.
- **As a** tester who finds a defect that is really a spec or design fault,
  **I want** to route it to the phase that owns the wrong artifact, **so that**
  the upstream premise is fixed instead of being pushed at `/build`.
- **As a** maintainer, **I want** an unresolved challenge to block the item and
  escalate to the user, **so that** a disputed item cannot advance or ship on a
  contested finding.
- **As a** user, **I want** to break a tie the agents cannot resolve, **so that**
  the decision is recorded and the item can move again.
- **As an** adopter, **I want** the challenge loop to reuse the existing
  artifacts and vocabulary and add no command, **so that** my prompts and
  inventories do not churn.

## Acceptance criteria

1. **AC1** — Given a finding in `review.md` or a defect reported in `verify.md`,
   when the author raises a challenge, then a committed, append-only per-item
   challenge entry is recorded naming the challenged finding, the challenge type
   (the finding itself, its severity, or an acceptance-criterion interpretation),
   the evidence, and the rationale; the challenger never edits the artifact owned
   by the phase that produced the finding; and the entry is not a phase artifact
   (it adds no `phase` value and by itself does not determine the item's derived
   phase).

2. **AC2** — Given a `review.md` finding or a defect reported in `verify.md`,
   when a challenge is considered, then both kinds are challengeable, including a
   claimed defect that is really a spec or design fault; a challenge to a
   non-review finding is not silently dropped.

3. **AC3** — Given a filed challenge, when it is adjudicated, then the phase that
   produced the challenged finding re-evaluates it first; if the challenge cannot
   be resolved there, the producing phase escalates it to the user, whose decision
   is recorded; the challenger is never the adjudicator of its own challenge, and
   no adjudication proceeds without an entry recording the decision, its basis,
   and who made it.

4. **AC4** — Given an open (undecided) challenge, when the item's phase is derived
   or the next forward phase is invoked, then the item derives a challenged
   (blocked) condition, does not advance to the next forward phase — including
   `/ship` — and the challenge escalates to the user; no new `phase` value is
   introduced by this condition.

5. **AC5** — Given an adjudication that sustains a challenge, when it completes,
   then the challenged finding is overturned or its severity is adjusted, the
   review verdict is recomputed (`approve` if and only if no Blocker or Major
   remains), the outcome and its evidence are recorded, and the next command
   follows the recomputed verdict.

6. **AC6** — Given an adjudication that rejects a challenge, when it completes,
   then the challenged finding and the verdict are unchanged, the rejection and its
   rationale are recorded, and normal routing resumes — the existing
   `review.md` verdict `request-changes` → `/build` route for a blocking finding.

7. **AC7** — Given a `/test` finding that is really a spec or design fault rather
   than an implementation defect, when the tester acts on it, then it is routed to
   the phase that owns the wrong artifact (`/plan` or `/spec`) through the
   sanctioned backtrack model — recorded finding, downstream `stale:` markers, and
   the target-phase handoff — rather than only to `/build`; this wires the
   `/test`→`/plan` and `/test`→`/spec` reverse edges.

8. **AC8** — Given a `/test` finding that is an implementation defect, when the
   tester acts on it, then it routes to `/build` as today, consistently with the
   backtrack model's `/test`→`/build` edge; the tester's existing rule that it owns
   tests and hands production-code defects back to the builder is preserved.

9. **AC9** — Given any challenge or upstream `/test` route, when it is taken, then
   the challenger/detector records state but never edits the artifact owned by the
   producing phase; the producing phase's owner revises its own artifact and
   appends the outcome; and the "only the owning phase writes its artifact"
   invariant is unchanged.

10. **AC10** — Given a challenge record, when entries are added over time, then
    the record is append-only: an adjudication, withdrawal, or reversal is
    appended and never rewrites or removes a prior entry, no entry is silently
    dropped, and a malformed record (for example an adjudication recorded before
    its challenge) is reported rather than reordered.

11. **AC11** — Given the challenge record and its outcomes, when they are
    inspected, then they reuse the existing severity scale
    (`Blocker`/`Major`/`Minor`/`Nit`) and finding format, and the review verdict
    vocabulary remains exactly `approve`/`request-changes`; no second severity
    scale, finding grammar, verdict, or state file is introduced.

12. **AC12** — Given the repository surfaces a maintainer or adopter reads, when
    the loop lands, then the workflow authority states the challenge/adjudication
    contract once as its single authority, the artifact conventions document the
    challenge record and the challenged condition, and the affected agent prompts
    (`/review`, `/build`, `/test`) and the code-review skill reference the contract;
    no surface states a conflicting challenge rule or still presents a disputed
    finding as obey-or-ignore with no recorded route.

13. **AC13** — Given an item with an open or adjudicated challenge, when its phase
    is derived, then the challenged condition is represented in committed state
    consistent with the `0001` marker model (an optional marker plus a derived
    label; no new `phase` value) and evaluated with defined precedence so a
    challenged item is never read as ready to advance or ship; the full `/status`
    reporting vocabulary and any dependency-readiness reporting remain `0006`'s.

14. **AC14** — Given the repository after the change, when the project's
    configured test command (`bash tests/run.sh`) runs, then it passes; the six
    core phase commands and their command→agent pairings are unchanged; no
    command, agent, or skill is added or removed; and no documented inventory
    count or command signature changes.

## Edge cases

- **No findings.** An item with no `review.md` finding and no `verify.md` defect
  has nothing to challenge; no challenge record is created and nothing blocks.
- **Open challenge never adjudicated.** The challenge stays open, the item derives
  the challenged condition, and it does not advance or ship; nothing resolves on
  its own and the escalation to the user persists.
- **Withdrawn challenge.** The author may withdraw a challenge; the withdrawal is
  appended, the item is unblocked, and the prior entry is preserved.
- **Adjudication by the wrong party.** The challenger adjudicating its own
  challenge is refused; the producing phase (or the user on escalation) decides.
- **Sustained challenge that reveals a wrong acceptance criterion.** If the
  challenge shows the AC text itself is wrong rather than the finding being
  mistaken, the correction is routed upstream through the backtrack model
  (revising `spec.md`/`design.md` by their owners) rather than being written into
  `review.md`.
- **Challenge to a non-blocking finding.** A challenge to a Minor or Nit is
  supported; while it is open it still holds the item and escalates, and a
  sustained outcome adjusts or removes it and re-evaluates the verdict.
- **Challenge after the item shipped.** An item whose `ship.md` is present is out
  of scope; its reversal is the post-ship reopen path (`0005`), not a challenge.
- **Multiple open challenges.** More than one challenge may be open at once; the
  item stays challenged until every open challenge is adjudicated or withdrawn,
  and record order is preserved.
- **`/test` fault cannot be classified.** When it is unclear whether a defect is
  an implementation or an upstream spec/design fault, the item is not pushed at
  the wrong phase: the classification is recorded and, if unresolved, escalated
  rather than guessed.
- **Out-of-order record entries.** An adjudication recorded before its challenge
  is malformed and reported, not silently reordered, mirroring `backtracks.md`.
- **Two items in parallel.** A challenge touches only its own item's committed
  state and changes no other item's readiness.
- **Shipped or missing upstream artifacts.** A `/test`→`/plan` or `/test`→`/spec`
  route taken before the downstream artifacts exist marks nothing stale; the item
  simply derives the target phase, per the `0001` model.
- **No unrecorded route.** A challenge or a `/test` upstream route taken without a
  recorded entry is not a sanctioned action (see the Open questions assumption).

## Open questions

- [x] **Adjudicator** — resolved (user): the producing phase re-evaluates first;
  the user breaks ties when it remains unresolved, and the decision is recorded.
- [x] **Unresolved challenge** — resolved (user): an open challenge blocks the item
  and escalates to the user, deriving a challenged condition.
- [x] **Contestable findings** — resolved (user): `review.md` findings and
  `/test` defects, including a defect that is really a spec/design fault.
- [x] **Entry point and record** — resolved (user): no new command; a committed,
  append-only per-item challenge/response record distinct from `backtracks.md`.
- [x] **Outcome mapping** — resolved (user): sustained overturns/adjusts and the
  verdict is recomputed; rejected leaves the finding and verdict unchanged and
  normal routing resumes.
- [ ] **Deferred — exact record shape and marker token.** The challenge record's
  file/section name, the challenge-type vocabulary, and the challenged
  marker/label token are design choices; the observable behavior above is fixed.
  — owner: architect, needed by: design.
- [ ] **Deferred — exact surfaces and wording.** Which prompt/skill passages carry
  the contract, how the raising and adjudication steps are phrased, and how the
  challenged condition composes with the derived-state precedence are design
  choices. — owner: architect, needed by: design.
- [ ] **Assumption — no unrecorded route.** Every challenge and every `/test`
  upstream route carries a recorded entry before it is taken, mirroring `0001`'s
  no-silent-reversal precondition; no lightweight challenge is defined. Confirm,
  or allow one. — owner: user, needed by: design.
- [ ] **Assumption — escalation mechanism.** Escalation uses the existing
  user-interaction (question) surface at the phase that produced the finding, and
  the producing phase records the user's decision; no new escalation channel is
  introduced. Confirm. — owner: user, needed by: design.

## Dependencies and constraints

- **Ready.** The parent roadmap lists `Depends on: 0001-backtracking-model`; that
  child is shipped (its `ship.md` is present), so the sole dependency is satisfied
  under the readiness algorithm (`docs/workflow.md` → "Dependencies and
  readiness") and no override is needed.
- **Extend, do not fork.** The loop builds on `0001`'s `## Phase reversal
  (backtracking)` model, the `backtracks.md` record, the `stale:`/`reopened:`
  markers, and `0002`'s re-entry and "Taking an edge" procedure. It reuses the
  review severity scale and finding format (`docs/artifact-conventions.md` →
  `review.md`; `.opencode/skill/code-review/SKILL.md`), the verdict vocabulary,
  and the shipped finding grammar; it introduces no second state or finding
  vocabulary.
- **Preserve the ownership invariant.** The challenger/detector records state and
  never edits the producing phase's artifact; the producing phase's owner revises
  its own artifact and appends the outcome.
- **`/test` edges are this item's.** `0002` explicitly left the `/test` reverse
  edges unwired (`work/0007-phase-backtracking/0002-reverse-phase-routing/design.md:307-308`,
  `.../0002-reverse-phase-routing/spec.md:57-58`); this item wires
  `/test`→`/build`, `/test`→`/plan`, and `/test`→`/spec`.
- **State shape feeds `0006`.** The challenged condition and its precedence must
  be fixed here so `0006-status-and-derived-state` can report it; the full
  `/status` vocabulary and derived-state table implementation are `0006`'s.
- **Committed suite constraints.** `tests/checks/20-lifecycle.sh` byte-pins the
  seven routing literals, including `review.md` verdict `request-changes` and
  `review.md` verdict `approve`, no `ship.md`, and pins the six phase commands and
  their command→agent pairs; `tests/checks/40-inventory.sh` pins the README Layout
  counts and inventory tables; `tests/checks/96-signature-sweep.sh` pins command
  signatures and the workflow numbered headings; `tests/checks/85-conflict-guards.sh`
  pins the merge finding grammar. The suite is read-only and never reads live
  `work/**` (`tests/README.md:29`). This item must keep those green; committed
  fixtures and mutation coverage are `0007-backtracking-guards`.
- **Sibling boundaries.** Parent-roadmap revision is `0004`; post-ship reopen is
  `0005`; status/derived-state reporting is `0006`; committed guards are `0007`.
  This item fixes the challenge loop and the `/test` routes; it implements none of
  their scopes.
- **Framework-internal change only.** Docs, prompts, and tests; no runtime
  dependency, service, new toolchain, or new command/agent/skill.
- **Assumption — naming surfaces for testability.** Because the deliverable is the
  framework's own prompts and documents, the acceptance criteria name the surfaces
  that must carry the contract (`docs/workflow.md`, `docs/artifact-conventions.md`,
  the `/review`, `/build`, and `/test` prompts, and the `code-review` skill); they
  specify required content and behavior, not implementation choices such as the
  exact record shape or marker token.
