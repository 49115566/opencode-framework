---
feature: 0007-phase-backtracking/0006-status-and-derived-state
phase: spec
status: final
created: 2026-10-09
updated: 2026-10-09
notes: "Nested roadmap child; the directory held only .gitkeep and its scope is the parent roadmap's 0006 row, so the roadmap supplies the requirements. Readiness: the declared dependencies 0001-backtracking-model, 0002-reverse-phase-routing, 0003-findings-challenge-loop, and 0005-post-ship-pr-denial all carry a committed ship.md, so the child is ready and no override is needed. The prior /spec run recorded a roadmap finding (Finding 1) because the parent row omitted 0003; /roadmap revise 0007-phase-backtracking re-sequenced the row on 2026-10-09 to add 0003 to Depends on, the finding was resolved in this item's backtracks.md, and this re-run reconciles the spec with the revised roadmap and clears the stale: roadmap marker. No open finding targets /spec, so this remains ordinary forward progression. User resolved the four reporting forks: (1) render the state as a parenthesized Phase-column label mirroring the derived-state table (P (backtracked), P (reopened), challenged (blocked)), with a Notes line naming the revised artifact and invalidated downstream artifacts; (2) resolve 0003's residual by making the challenged overlay unshipped-only, so a ship.md-present item reports shipped and its open challenge is surfaced as out-of-scope; (3) update the status agent, the /status command, docs/workflow.md, and the workflow-lifecycle skill; (4) the roadmap dependency finding is resolved through the revision route."
parent: 0007-phase-backtracking
stale: ""
---

# Status, derived state, and readiness for backtracked items

## Problem

The reverse-transition state shapes already exist. `0001-backtracking-model`
fixed the `stale:` marker and the `backtracks.md` record, `0002-reverse-phase-routing`
wired re-entry, `0003-findings-challenge-loop` fixed the `challenges.md` record and
the `challenged` blocked condition, and `0005-post-ship-pr-denial` fixed the
`reopened:` marker and the recalled-item readiness revocation. `docs/workflow.md`
→ "Derived state" now carries the rows `P (backtracked)`, `P (reopened)`, and
`challenged (blocked)`, and "Dependencies and readiness" revokes satisfaction for
a recalled item (`docs/workflow.md:1027-1082`, `docs/workflow.md:77-114`).

What is missing is the **report**. The read-only window a maintainer actually uses
— `/status` — was deliberately left to this item: `0003` shipped with
`.opencode/agent/status.md` untouched and its verification recorded that "the full
`/status` vocabulary and derived-state table implementation are `0006`'s"
(`work/0007-phase-backtracking/0003-findings-challenge-loop/verify.md:64-65`).
The status agent's phase vocabulary still ends at
`not started, spec, design, build, test, review, rework, ship, shipped, roadmap`
(`.opencode/agent/status.md:237-238`); it neither names the backtracked, reopened,
or challenged states nor reports which upstream artifact is being revised or which
downstream artifacts a backtrack invalidated. So an item the lifecycle has sent
backward or recalled can read as if it were still moving forward, and a maintainer
cannot see from `/status` what happened, what was invalidated, or why a dependent
is blocked. Two audiences pay for this: **framework maintainers** running the
lifecycle and **adopters** who inherit the same status contract.

A separate residual compounds it. Because the `challenged` overlay is evaluated
before the `ship.md` row, a shipped item with an open `challenges.md` entry would
derive `challenged` rather than `shipped`, contradicting the documented rule that a
shipped item is out of scope for a challenge and that post-ship reversal is recall's
domain (`work/0007-phase-backtracking/0003-findings-challenge-loop/verify.md:97-111`).
`/status` is the surface that would show the wrong state, and the derived-state
authority is the place to fix the precedence.

The result is that the backward lifecycle is auditable in the committed artifacts
but invisible in the report a maintainer reads to decide the next command.

## Goals

- Make `/status` derive and report the backtracked, reopened, challenged, and
  reworked conditions and the stale downstream artifacts they leave, using the
  exact labels the derived-state authority already defines.
- Make `/status` name, for a backtracked item, the target phase being revised and
  the affected upstream artifact, and list the downstream artifacts the backtrack
  invalidated.
- Make `/status` report a recalled/reopened item as not satisfying its dependents
  while a non-recalled `ship.md` presence and an `approve` verdict still satisfy
  exactly as before.
- Make `/status` report an open challenge as the blocked `challenged` condition
  with the open challenge named, and never report such an item as ready to advance
  or ship.
- Resolve the challenge-versus-shipped precedence so a `ship.md`-present item is
  never reported `challenged`.
- State the reporting consistently on the status agent, the `/status` command, the
  workflow authority, and the `workflow-lifecycle` skill, without forking the
  derived-state table or the readiness authority.
- Keep the change additive and framework-internal: no new `phase` value, command,
  agent, skill, state file, or finding vocabulary, and the committed suite stays
  green.

## Non-goals

- Re-deciding the reverse-edge model (`0001`), the re-entry routing and recording
  (`0002`), the finding-challenge/adjudication contract (`0003`), or the
  post-ship recall and shipped-signal revocation (`0005`). This item reports the
  state shapes those children fixed; the one precedence clarification in AC7 is
  the only change to an existing rule.
- Changing the readiness semantics for a non-recalled item; `0005` fixed the
  recalled-item exclusion and this item only reports it.
- Committed fixtures, agreement areas, and mutation coverage for the new
  reporting — owned by `0007-backtracking-guards`.
- A new `phase` value, a new command, agent, or skill (including a dedicated
  `/status backtracks` mode), a new state file, or a new finding code or severity /
  verdict vocabulary.
- Redefining the `0006-parallel-plan-conflicts` declared-conflict finding grammar
  or any branch-level merge reconcile.
- Rewriting or relaunching the flagged plan-publication flow, the fix track, or
  any phase other than the read-only report.
- Editing `README.md`, `AGENTS.md`, or `template/AGENTS.md`: the reporting lives
  on the four surfaces named in AC9, and the always-loaded contract already points
  at the backtracking model.
- Any visual or UI work; the deliverable has no user-facing surface.

## Users and stories

- **As a** framework maintainer, **I want** `/status` to show that an item was sent
  back and which artifact is being revised and what got invalidated, **so that** I
  know what to fix and which phases must re-run instead of misreading the item as
  current.
- **As a** maintainer of a dependent roadmap child, **I want** `/status` to show a
  recalled/reopened dependency as not satisfying my child, **so that** I do not
  proceed against a rejected plan.
- **As a** maintainer, **I want** `/status` to show an open challenge as a blocked
  state with the challenge named, **so that** I understand why the item is not
  advancing and can route to adjudication.
- **As a** maintainer reading a report, **I want** the backtracked, reopened,
  challenged, and rework labels to reuse the derived-state vocabulary, **so that**
  the report and the authority never disagree.
- **As a** reviewer or maintainer, **I want** a shipped item with an open challenge
  to be reported `shipped` rather than `challenged`, **so that** post-ship reversal
  is handled by recall rather than a phantom blocked state.
- **As an** adopter, **I want** the status reporting to reuse the existing labels
  and add no command or state file, **so that** my inherited prompts and
  inventories do not churn.

## Acceptance criteria

1. **AC1** — Given an item whose artifacts carry a `stale:` marker naming phase
   `P`, when `/status` derives and reports its phase, then it reports the
   parenthesized label `P (backtracked)` in the Phase column, matching the label in
   `docs/workflow.md` → "Derived state", and never reports the pre-backtrack phase
   as the item's current phase.

2. **AC2** — Given a backtracked item with an open finding in its `backtracks.md`
   (no matching resolution), when `/status` reports it, then the report names the
   target phase being revised and the affected upstream artifact from the finding,
   and lists the downstream artifacts the backtrack invalidated (the artifacts
   carrying the `stale:` marker); an item with no existing downstream artifacts
   reports that nothing was invalidated.

3. **AC3** — Given a `ship.md` carrying a `reopened:` marker naming phase `P`, when
   `/status` derives it, then it reports `P (reopened)` rather than `shipped` and
   names the recall as the reason.

4. **AC4** — Given a recalled/reopened item, when `/status` evaluates a dependent
   whose dependency it is, then it reports that dependent as `blocked` and names the
   recalled item as the unsatisfied dependency; a non-recalled `ship.md` presence
   and a `review.md` verdict of `approve` still report the dependency satisfied
   exactly as before, and no stored readiness value is introduced.

5. **AC5** — Given an unshipped item with an open challenge in `challenges.md` (a
   `Challenge <n>` with no matching `Response n` or `Withdrawal n`, and no
   `ship.md`), when `/status` derives it, then it reports the blocked `challenged`
   condition and names the open challenge(s), and the item is not reported as ready
   to advance or ship.

6. **AC6** — Given an item with the existing `review.md` verdict
   `request-changes` and no `ship.md`, when `/status` derives it, then it reports
   `build (rework)` exactly as today; `rework` remains a distinct label from
   `backtracked`, and no second rework state is introduced.

7. **AC7** — Given a `ship.md`-present item with an open `challenges.md` entry,
   when `/status` derives it, then it reports `shipped` — the challenged overlay
   applies to unshipped items only — and surfaces the open challenge as
   out-of-scope for a challenge (post-ship reversal is recall's domain); the
   derived-state authority states this unshipped precondition and its precedence so
   no shipped item is ever reported `challenged`.

8. **AC8** — Given the status phase vocabulary, when `/status` reports any item,
   then the vocabulary includes the derived labels `backtracked`, `reopened`, and
   `challenged` alongside the existing base phases, using the exact tokens the
   derived-state table defines; no new `phase` value, finding code, or state file
   is introduced, and the finding grammar is the existing one.

9. **AC9** — Given the repository surfaces a maintainer reads, when the reporting
   lands, then `.opencode/agent/status.md`, `.opencode/command/status.md`,
   `docs/workflow.md` (the "Derived state" and readiness reporting), and the
   `workflow-lifecycle` skill all state the reporting consistently and none
   contradicts the derived-state table or the readiness authority; the derived-state
   table and the `satisfied(dep_local_id)` algorithm remain the single authorities,
   referenced by name rather than restated.

10. **AC10** — Given the single-source constraints, when the change lands, then the
    readiness algorithm still appears exactly once (in `docs/workflow.md`), the
    status agent and `/status` command still defer to it by name, and the seven
    pinned routing literals and the core derived-state artifact names are
    unchanged.

11. **AC11** — Given the repository after the change, when the project's configured
    test command (`bash tests/run.sh`) runs, then it passes; the six core phase
    commands and their command→agent pairings are unchanged; no command, agent, or
    skill is added or removed; and no documented inventory count or command
    signature changes.

12. **AC12** — Given the item's scope boundaries, when the change is inspected,
    then it reuses the `0001`/`0002`/`0003`/`0005` state shapes and vocabulary,
    adds no fixtures or mutation coverage (`0007`), adds no new command, agent,
    skill, `phase` value, or state file, and does not re-open the model, routing,
    challenge loop, recall, readiness semantics, or the declared-conflict grammar.

## Edge cases

- **Empty `work/`.** `/status` reports that no items exist and recommends
  `/spec <feature>`; no backtracked/challenged reporting is invented.
- **Backtrack with no downstream artifacts yet.** A backtrack taken before any
  downstream artifact exists (for example `/plan`→`/spec` when only `spec.md`
  exists) reports `P (backtracked)` and "nothing invalidated"; it does not claim a
  stale artifact.
- **`stale: roadmap` token.** A phase→parent-`roadmap.md` backtrack's marker maps
  to `spec` when the item's phase is derived; `/status` reports the mapped phase so
  the label and the authority agree.
- **Sequential backtracks.** A second backtrack taken before the first resolves
  preserves record order and derives the earliest outstanding target; `/status`
  names the target phase the item currently derives and does not silently drop the
  later finding.
- **Backtrack and challenge both open.** The `stale:`/`reopened:` structural
  derivation is evaluated first and the `challenged` overlay after it, matching the
  authority's precedence; `/status` reports both conditions rather than only one.
- **Recalled item that also has stale markers.** The item derives the re-entry
  phase throughout and stays blocked for its dependents until it re-ships;
  `/status` reports it consistently with the earliest `stale:` marker.
- **Malformed or out-of-order record.** A resolution recorded before its finding,
  or a response recorded before its challenge, is reported as a finding and not
  reordered, mirroring the existing `backtracks.md`/`challenges.md` rule.
- **Absent records.** An item with no `backtracks.md` and no `challenges.md` is
  neither backtracked nor challenged; historical items need no migration and read
  exactly as today.
- **Shipped with an open challenge.** Reported `shipped` per AC7; the open
  challenge is surfaced as out-of-scope rather than blocking the item.
- **Approved-but-unshipped.** A `review.md` `approve` with no `ship.md` still
  satisfies a dependency and is not challenged; reporting is unchanged from today.
- **`.gitkeep`-only child.** Reported `not started`; not treated as a phase
  artifact or a backtrack target.
- **Two items in parallel.** `/status` reports each item's own state and changes
  no other item's readiness beyond the reported dependency edges.
- **Read-only.** `/status` still modifies no file; reporting a challenged/open
  finding surfaces it and points to the owning phase's escalation, it does not
  adjudicate or escalate on its own.

## Open questions

- [x] **Output shape** — resolved (user): parenthesized state label in the Phase
  column mirroring the derived-state table (`P (backtracked)`, `P (reopened)`,
  `challenged (blocked)`), plus a Notes line naming the revised artifact and the
  invalidated downstream artifacts.
- [x] **Challenge-versus-shipped precedence** — resolved (user): the challenged
  overlay is unshipped-only; a `ship.md`-present item reports `shipped` and its
  open challenge is surfaced as out-of-scope.
- [x] **Surfaces** — resolved (user): `.opencode/agent/status.md`,
  `.opencode/command/status.md`, `docs/workflow.md`, and the `workflow-lifecycle`
  skill.
- [x] **Roadmap dependency omission** — resolved: `Finding 1` was recorded in this
  item's `backtracks.md`, and `/roadmap revise 0007-phase-backtracking` resolved it
  on 2026-10-09 by adding `0003-findings-challenge-loop` to the 0006 row's
  `Depends on` cell; the revised roadmap now lists all four dependencies and the
  item is not blocked.
- [ ] **Deferred — exact Notes wording and rendering.** The precise phrasing of the
  "revising / invalidated" line, whether the report gains a small dedicated
  section, and how the challenged item is labelled next to its underlying phase are
  design choices; the observable content above is fixed. — owner: architect,
  needed by: design.
- [ ] **Assumption — reporting only.** The `0001`/`0002`/`0003`/`0005` state shapes
  (the markers, the records, the derived rows, and the recalled-readiness branch)
  are final and this item changes none of them except the AC7 unshipped
  precondition. Confirm. — owner: user, needed by: design.
- [ ] **Assumption — `/status` reports, it does not act.** A challenged item's
  escalation to the user remains the owning phase's action (per `0003`); `/status`
  reports the open challenge and the blocked condition rather than adjudicating,
  escalating, or writing state. Confirm. — owner: user, needed by: design.

## Dependencies and constraints

- **Ready.** The parent roadmap lists `Depends on: 0001-backtracking-model,
  0002-reverse-phase-routing, 0003-findings-challenge-loop,
  0005-post-ship-pr-denial`; all four carry a committed `ship.md`
  (`work/0007-phase-backtracking/<child>/ship.md`), so every declared dependency is
  satisfied under the readiness algorithm and no override is needed. The
  `0003-findings-challenge-loop` edge was added by the 2026-10-09
  `/roadmap revise 0007-phase-backtracking` re-sequence, which resolved `Finding 1`
  in this item's `backtracks.md` and marked this `spec.md` `stale: roadmap`; this
  re-run clears that marker.
- **Consumes the `0001` model and `0002` routing.** The `stale:`/`reopened:`
  markers, the `backtracks.md` finding/resolution record, the derived-state
  precedence, and the re-entry semantics are the `0001`/`0002` contract; this item
  reads them for reporting and defines no second mechanism.
- **Consumes the `0003` challenge loop.** The `challenges.md` record and the
  `challenged` blocked condition are `0003`'s; the full reporting vocabulary was
  explicitly left to this item (`.../0003-findings-challenge-loop/verify.md:64-65`),
  and AC7 resolves the recorded shipped-item residual
  (`.../0003-findings-challenge-loop/verify.md:97-111`).
- **Consumes the `0005` recall.** The `reopened:` marker and the recalled-item
  readiness exclusion are `0005`'s; this item reports them. `0005` already added
  the readiness clause to the status agent and `/status` command, which this item
  extends with the derived labels and the backtrack/challenge detail.
- **Single-source authorities.** The derived-state table
  (`docs/workflow.md:1027-1082`) and the readiness algorithm
  (`docs/workflow.md:77-114`) stay the single authorities; every other surface
  references them by name.
- **Committed suite constraints.** `tests/checks/10-readiness.sh` requires
  `satisfied(dep_local_id):` exactly once (in `docs/workflow.md`) and the pinned
  phrases `even if unshipped`, `presence is the sole shipped signal`, and
  `ship.md` presence takes precedence`, with the status agent, `/status` command,
  and product prompt deferring by name; `tests/checks/20-lifecycle.sh` pins the
  seven routing literals, the phase set, and the core artifact names;
  `tests/checks/40-inventory.sh` and `tests/checks/96-signature-sweep.sh` pin the
  inventories and signatures. The suite never reads live `work/**`
  (`tests/README.md:29`). This item must keep them green; committed fixtures and
  mutation coverage are `0007-backtracking-guards`.
- **Sibling boundaries.** Parent-roadmap revision integrity and its committed
  guards are `0004`/`0007`; the post-ship recall signal is `0005`; the challenge
  record and adjudication are `0003`. This item implements `0006`'s reporting
  scope only.
- **Framework-internal change only.** Docs and prompts only; no runtime
  dependency, service, new toolchain, command, agent, or skill.
- **Assumption — naming surfaces for testability.** Because the deliverable is the
  framework's own prompts and documents, the acceptance criteria name the surfaces
  that must carry the reporting (the status agent, the `/status` command, the
  workflow authority, and the `workflow-lifecycle` skill); they specify required
  content and behavior, not implementation choices such as exact wording or the
  report layout.
