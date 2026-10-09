---
feature: 0007-phase-backtracking/0005-post-ship-pr-denial
phase: spec
status: final
created: 2026-10-08
updated: 2026-10-08
notes: "Nested roadmap child; the directory held only .gitkeep and its scope is the parent roadmap's 0005 row, so the roadmap supplies the requirements. Readiness: both dependencies (0001-backtracking-model, 0002-reverse-phase-routing) have committed ship.md, so the child is ready and no override is needed. No open finding in backtracks.md, so this is ordinary progression. User resolved the four policy forks: (1) revoke the shipped signal by populating the forward-declared `reopened:` marker on the existing ship.md (no new artifact or field); (2) readiness consults the recall, so a recalled item no longer satisfies its dependents; (3) the item re-enters the phase the denial implicates (code/tests -> /build, design -> /plan, requirements -> /spec), recorded at recall; (4) the route reuses the existing /ship command (no new command), consistent with 0002's decision."
parent: 0007-phase-backtracking
---

# Post-ship PR denial, recall, and reopen

## Problem

The lifecycle stops at "reviewable pull request": `/ship` writes
`work/<item-ref>/ship.md`, and `ship.md` presence is the **sole shipped signal**
consumed by readiness (`docs/workflow.md` → "Dependencies and readiness"). Once it
exists, the item is treated as shipped — it is excluded from the
`0001-backtracking-model` backtrack (a shipped item has no reverse path), the
derived-state table reports it shipped, and every dependent sees it as
satisfied (`docs/workflow.md` → "Derived state";
`work/0007-phase-backtracking/0001-backtracking-model/design.md`). But a pull
request is a **human** decision that can go the other way: it may be denied,
closed, or sent back for changes **after** `ship.md` was written. There is no
sanctioned recall path for that case. The maintainer can only open a duplicate
work item, hand-edit `work/` state and readiness inputs, or force-push and rewrite
pushed history — the last of which the shipper's guardrails forbid
(`.opencode/agent/shipper.md:274-275`).

`0002-reverse-phase-routing` gives the **unshipped** item a re-entry path: a
recorded finding, mechanically applied `stale:` markers, and the target phase's
owning agent revising and resuming forward. It deliberately excludes the post-ship
case, and `0001`'s model likewise excludes any item whose `ship.md` is present,
explicitly assigning the shipped-signal revocation to this item
(`docs/workflow.md` → "Phase reversal (backtracking)" → "Shipped items and
reopen"). So today a denied PR after ship is a dead end: the item reads as
satisfied while its change is not acceptable, and its dependents proceed against a
plan that has been rejected. The people who pay are **framework maintainers**, who
must manually unpick committed state or force-push, and **adopters**, who inherit
the same one-way shipped signal with no recall. The sibling roadmap note records
the dependency explicitly: a recalled item "must stop satisfying dependents
without silently deleting the historical `ship.md`".

## Goals

- Define the post-ship states a work item can be in after `ship.md` exists — an
  open PR denied, closed, or sent back for changes; a PR never opened; and a
  branch abandoned — and distinguish them from the pre-ship and shipped states.
- Provide a recall/reopen route that records the denial, revokes the shipped
  signal non-destructively, and returns the item to the correct phase through
  `0002`'s re-entry path, so a maintainer never has to hand-edit state, duplicate
  the item, or rewrite pushed history.
- Revoke the shipped signal without deleting or rewriting the historical
  `ship.md`, and make readiness and phase derivation honor the revocation so a
  recalled item no longer satisfies its dependents.
- Preserve committed history and pushed history: no historical record is deleted
  or rewritten, and the shipper never force-pushes or rebases a pushed branch.
- Reuse the model and vocabulary that already ship: the `0001` `reopened:` marker,
  the `backtracks.md` record, the `stale:` marker, the `0002` re-entry path, and
  the finding/derived-state vocabulary — no second mechanism, command, state file,
  or `phase` value.
- Reuse an existing command as the invocation surface, keeping the six core phase
  commands and the documented command/agent/skill inventories unchanged.
- Keep the committed suite green.

## Non-goals

- The intra-item reverse edges and their wiring (`/build`→`/plan`,
  `/plan`→`/spec`, the plan-publication round trip) — owned by
  `0002-reverse-phase-routing`.
- Contesting or adjudicating a denied PR's findings — owned by
  `0003-findings-challenge-loop`.
- Revising a parent `roadmap.md` from a child phase — owned by
  `0004-roadmap-revision`.
- The full `/status` and derived-state reporting vocabulary for recalled/reopened
  items — owned by `0006-status-and-derived-state`. This item fixes the state
  shapes those surfaces consume.
- Committed fixtures, agreement areas, and mutation coverage for the recall and
  reopen signal — owned by `0007-backtracking-guards`.
- Branch-level merge reconcile and any conflict resolution between branches —
  owned by the shipped `0005-merge-conflict-workflow`.
- A new command, agent, or skill (including a `/reopen` command), a new `phase`
  value, a new state file, or any change to the six core phase commands and their
  agent pairings.
- Redefining the shipped signal or readiness semantics for an item that is
  **not** recalled: a plain `ship.md` presence and an `approve` verdict still
  satisfy exactly as today.
- Deleting, truncating, or rewriting any historical `work/` record; force-pushing,
  rebasing, or otherwise rewriting pushed history; and deleting or closing the
  denied PR.
- Automatic detection of a PR's state or automatic reopening without an explicit
  maintainer action.
- The finding severity scale, the review verdict vocabulary, and the shipped
  `0006` declared-conflict finding grammar; the recall reuses them.

## Users and stories

- **As a** framework maintainer whose shipped PR was denied, closed, or sent back
  for changes, **I want** a sanctioned way to recall the item and send it back to
  the phase that must change, **so that** I do not have to duplicate the work
  item, hand-edit state, or force-push.
- **As a** maintainer of a dependent roadmap child, **I want** a recalled item to
  stop counting as satisfied, **so that** I do not build on a rejected plan.
- **As a** shipper, **I want** to record the recall and revoke the shipped signal
  without deleting the historical `ship.md`, **so that** the audit trail and
  committed history survive the recall.
- **As a** maintainer, **I want** the recalled item to re-enter the phase the
  denial actually implicates, **so that** only the affected artifacts are redone
  rather than restarting the whole lifecycle.
- **As an** adopter, **I want** the recall to reuse the record, the `reopened:`
  marker, and the derived-state vocabulary the framework already ships, **so that**
  I do not maintain a second mechanism for the same condition.

## Acceptance criteria

1. **AC1** — Given the workflow authority, when the post-ship states are read,
   then they enumerate an open PR denied, closed, or sent back for changes; a PR
   never opened; and a branch abandoned, and they distinguish these from the
   pre-ship states and from a normally shipped item.

2. **AC2** — Given a shipped item (`ship.md` present) whose PR is denied, closed,
   or sent back for changes, when the maintainer invokes the recall, then the
   recall records the triggering condition, the observable evidence, and the
   chosen re-entry phase in the item's committed backtrack record, and appends
   that record entry without deleting or rewriting any prior entry.

3. **AC3** — Given a recall, when the shipped signal is revoked, then the
   historical `ship.md` is retained and gains the `reopened:` marker naming the
   re-entry phase; no historical content is deleted, truncated, or rewritten; and
   the marker is distinct from the frontmatter `status` and does not overload it.

4. **AC4** — Given an item whose `ship.md` carries a `reopened:` marker naming
   phase `P`, when its phase is derived, then it derives `P` (reopened) rather
   than shipped, per the `0001` derived-state precedence; and the marker and the
   downstream `stale:` markers name the same phase `P`.

5. **AC5** — Given a recalled item, when readiness is evaluated for a dependent
   whose dependency it is, then the recalled item does not satisfy the dependency
   and the dependent is reported blocked until the item re-ships; a non-recalled
   `ship.md` presence and an `approve` verdict still satisfy a dependency exactly
   as before, and no second shipped signal or stored readiness value is
   introduced.

6. **AC6** — Given a recalled item with re-entry phase `P`, when the recall is
   recorded, then each existing artifact strictly downstream of `P` is marked
   `stale:` per the `0001`/`0002` model, and the item re-enters `P` through the
   `0002` re-entry path: `P`'s owning agent revises its own artifact, appends a
   resolution entry, and resumes the forward lifecycle from `P` as if the later
   phases had not run. No artifact is deleted or silently rewritten, and the
   pre-revision content remains recoverable from committed git history.

7. **AC7** — Given a denied, closed, or changes-requested PR, when the re-entry
   phase is chosen, then it is a lifecycle phase earlier than ship that the denial
   implicates — implementation or tests → `/build`; design → `/plan`;
   requirements → `/spec` — it is recorded at recall time, and it is deterministic
   rather than re-derived on every read.

8. **AC8** — Given the recall route, when a maintainer reads the command and agent
   surfaces, then the route is a documented step or mode of the existing `/ship`
   command (no new command, agent, or skill is added); the `/ship` usage string and
   every surface that states command signatures, together with the pinned
   command-signature agreement, change consistently; and the six core phase
   commands, their agent pairings, and the documented inventories are otherwise
   unchanged.

9. **AC9** — Given a recalled item that later re-runs and re-ships, when the
   shipper publishes it, then it adds commits to the existing branch/PR or opens a
   new PR when the branch was pruned, mirroring the plan-publication revision
   flow; it never rebases a pushed branch, never force-pushes, and never rewrites
   pushed history; and it does not delete or close the denied PR.

10. **AC10** — Given an item that is shipped and **not** recalled, when its phase
    and readiness inputs are read, then the shipped signal, the readiness
    contract, the six `phase` values, and the derived-state contract for it are
    unchanged; and no second shipped signal, new `phase` value, or state file is
    introduced.

11. **AC11** — Given a shipped item whose PR was never opened or whose branch was
    abandoned (for example `gh` was unavailable and only local commits exist),
    when its phase is derived, then it remains shipped until an explicit recall is
    recorded — the states are defined, but no automatic detection and no automatic
    revocation occurs.

12. **AC12** — Given the repository surfaces a maintainer reads, when the recall
    route lands, then the workflow authority, the artifact-conventions authority,
    the shipper agent and the `/ship` command, the `workflow-lifecycle` routing
    block, the always-loaded `AGENTS.md` and its adopter-pristine
    `template/AGENTS.md` counterpart, and the readiness authority and its
    deferring surfaces all state the route consistently, and no surface still
    presents `ship.md` presence as irrevocable.

13. **AC13** — Given the repository after the change, when the project's
    configured test command runs, then it passes, including the readiness,
    lifecycle, inventory, and command-signature agreements; any agreement that
    literally encoded the pre-recall semantics is updated together with the
    change rather than left failing.

14. **AC14** — Given the item's scope boundaries, when the recall route is
    inspected, then it defines only the post-ship states, the revocation, and the
    re-entry routing; it implements none of the intra-item reverse edges (`0002`),
    the findings challenge loop (`0003`), parent-`roadmap.md` revision (`0004`),
    the full `/status` vocabulary (`0006`), the committed guards (`0007`), or any
    merge reconcile; and it reuses the `0001`/`0002` record, markers, and re-entry
    rather than introducing a second vocabulary.

## Edge cases

- **`ship.md` present but PR "not created" (for example `gh` was unavailable).**
  The item is still shipped under the single-signal model; recall requires an
  explicit maintainer action and must not fire automatically.
- **Recall recorded, then the item re-ships, then is denied again.** A second
  recall appends a new record entry and re-applies (or updates) the `reopened:`
  marker; no prior entry is erased and the marker names the latest re-entry phase.
- **Branch pruned or deleted before re-ship.** Re-shipping creates a new branch
  and PR rather than force-pushing or reusing a deleted branch.
- **No downstream artifacts to mark.** A recall normally has every downstream
  artifact; if one is absent, marking skips it and the item still derives the
  re-entry phase (mirrors `0002`'s "reverse edge before downstream artifacts
  exist").
- **`gh` unavailable.** The recall records the denial and revokes the signal
  through local committed state, and the handoff reports the exact commands the
  user runs to push and open the PR; no step requires the network to record the
  recall.
- **The denied PR is still open.** The recall records the state and re-enters the
  phase; it does not close, delete, or modify the PR.
- **Recall whose target is a phase later than or equal to ship.** Refused: the
  target must be strictly earlier than ship, per the `0001` reverse-edge rule.
- **A dependent of a recalled item.** It is reported blocked (naming the recalled
  item) until the item re-ships; `/status` derives this live, and no stored
  readiness value is written.
- **Re-entry phase with no open finding.** The recall creates the record entry, so
  re-entry finds an open finding targeting `P`; a phase invoked with no such
  finding behaves as ordinary forward progression and fabricates nothing.
- **Recall on an item that never shipped.** An item with no `ship.md` is an
  ordinary backtrack (`0001`/`0002`), not a recall; the route must not offer a
  recall for it.
- **Concurrent recall on two branches.** The recall writes only its own item's
  committed state; a resulting `work/` artifact conflict is a class (b) merge
  conflict handled by the shipped merge-conflict contract.
- **Marker versus lifecycle tokens.** `reopened:` and `stale:` are distinct from
  the frontmatter `status` (`draft`/`final`/`blocked`) and add no `phase` value.

## Open questions

- [x] **Revocation mechanism** — resolved (user): populate the forward-declared
  `reopened:` marker on the existing `ship.md`; no new artifact or field.
- [x] **Readiness treatment** — resolved (user): readiness consults the recall, so
  a recalled item no longer satisfies its dependents; a non-recalled `ship.md` and
  an `approve` verdict satisfy as before.
- [x] **Re-entry phase** — resolved (user): the phase the denial implicates,
  recorded at recall time (`/build`, `/plan`, or `/spec`).
- [x] **Invocation surface** — resolved (user): reuse the existing `/ship`
  command; no new command. Consistent with `0002`'s no-new-command decision.
- [ ] **Deferred — exact recall syntax and record wording.** The precise `/ship`
  recall form, the handoff strings, the `backtracks.md` entry wording, and the
  marker-writing mechanics are design choices; the observable behavior above is
  fixed and reuses the `0001`/`0002` vocabulary. — owner: architect, needed by:
  design.
- [ ] **Assumption — recall is an explicit action.** The framework does not
  auto-detect a PR's state or auto-revoke; the maintainer reports the denial. The
  shipper may read PR state with `gh` when available as evidence, but recording and
  revoking must still work offline. Confirm, or define automatic detection. —
  owner: user, needed by: design.
- [ ] **Assumption — re-ship reuses the ordinary `/ship`.** A recalled item that
  has re-run the lifecycle ships through the existing shipper flow, adding commits
  or a new PR and never force-pushing. Confirm, or define a distinct re-ship
  behavior. — owner: user, needed by: design.

## Dependencies and constraints

- **Ready.** The parent roadmap lists `Depends on: 0001-backtracking-model,
  0002-reverse-phase-routing`; both carry a committed `ship.md`
  (`work/0007-phase-backtracking/0001-backtracking-model/ship.md`,
  `work/0007-phase-backtracking/0002-reverse-phase-routing/ship.md`), so both
  dependencies are satisfied under the readiness algorithm and no override is
  needed.
- **Consumes the `0001` model.** This item populates the forward-declared
  `reopened: <phase>` marker (`.opencode/agent/*`; `0001` design §2), reuses the
  append-only `backtracks.md` record and the `stale:` marker
  (`docs/artifact-conventions.md` → "`backtracks.md`" and the Frontmatter block),
  and relies on the derived-state `reopened:` precedent. It defines no second
  record, marker, or state vocabulary.
- **Consumes `0002`'s re-entry.** After revocation, the item is no longer shipped,
  so `0002`'s re-entry path (detecting phase records the finding; the target's
  owning agent revises, appends a resolution, and resumes forward) applies
  unchanged. The record entry this item appends is what makes the finding open for
  re-entry.
- **Consumed by siblings.** `0006-status-and-derived-state` reports the
  recalled/reopened state and the readiness it implies; `0007-backtracking-guards`
  pins the recall signal and readiness no-longer-satisfied with committed
  fixtures. The state shapes this item fixes are the contract they consume.
- **Readiness-authority coupling.** The readiness algorithm is stated exactly once
  in `docs/workflow.md` (`satisfied(dep_local_id)`) and every other surface defers
  to it; `tests/checks/10-readiness.sh` pins that it appears exactly once, that
  `ship.md` presence is the sole shipped signal, and that presence takes
  precedence. The recalled-item exclusion must be added to that single authority
  and its deferring surfaces consistently, and the readiness agreement must stay
  green — if a pinned literal encodes the pre-recall semantics and must change, it
  changes together with the behavior rather than being left failing. The design
  must reconcile the "sole shipped signal" wording with the revocation without
  forking the mechanism.
- **Derived-state/lifecycle literals.** `tests/checks/20-lifecycle.sh` pins the
  derived-state route literals and the artifact names across the always-loaded
  contract, the workflow authority, the README, and the `workflow-lifecycle` skill;
  the `reopened:` derived row already exists from `0001` and must stay consistent.
- **No-new-command coupling.** `tests/checks/96-signature-sweep.sh` pins the
  `/ship` usage signature across its designated positions, and
  `tests/checks/40-inventory.sh` pins the README Layout counts. Reusing `/ship`
  keeps the command inventory unchanged; a recall form changes only the `/ship`
  signature, so every surface stating it and the sweep's expected literals update
  together (the `0004` roadmap-revision item sets the precedent for adding a mode
  to an existing command).
- **Shipper guardrails.** The shipper is the only git writer and must never
  force-push, rebase a pushed branch, or `reset --hard`
  (`.opencode/agent/shipper.md:274-275`). Re-shipping after recall extends the
  plan-publication revision behavior (add commits; open a new PR when the branch
  was pruned) rather than rewriting history.
- **Ownership invariant.** Only the owning phase writes its own artifact; the
  recall records the finding and revokes the shipped signal, and the re-entry
  target's owning agent revises its own artifact — the `0001` invariant is
  unchanged.
- **Framework-internal change only.** Docs, prompts, and tests; no runtime
  dependency, service, or new toolchain.
- **Assumption — naming surfaces for testability.** Because the deliverable is the
  framework's own prompts and documents, the acceptance criteria name the surfaces
  that must carry the route (the workflow and artifact-conventions authorities,
  the shipper agent and `/ship` command, the `workflow-lifecycle` skill,
  `AGENTS.md` and `template/AGENTS.md`, and the readiness authority). They specify
  required content and behavior, not implementation choices.
