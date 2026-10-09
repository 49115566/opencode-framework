---
feature: 0007-phase-backtracking
phase: roadmap
status: final
created: 2026-10-08
updated: 2026-10-08
---

# Roadmap — Phase backtracking, findings challenges, and post-ship reopen

## Initiative

This initiative makes the lifecycle able to move **backward** when a later phase
discovers that an earlier phase was wrong. Today the six phases are forward-only:
`AGENTS.md` and `docs/workflow.md` tell a downstream phase to "stop and report" or
"route back" when it finds an upstream flaw (`.opencode/agent/builder.md:38`,
`.opencode/agent/architect.md:62-63,106-107`, `docs/workflow.md:773`), but no
mechanism exists to actually revise the upstream artifact, because every artifact
is owned by its phase and no phase may rewrite another's
(`.opencode/agent/builder.md:109-110`, `.opencode/agent/architect.md:100`). The
only reverse edge is the reviewer's `request-changes` verdict routing to
`/build` (`.opencode/agent/reviewer.md:109`, `docs/workflow.md:285,572`), and
even that is a silent rework with no way to contest a finding. So a build that
finds a design flaw, a design that finds a spec flaw, or a spec that finds the
parent roadmap wrong can only stop; a finding can be obeyed or ignored but never
challenged; and a PR denied after `ship.md` already exists has no recall path —
`ship.md` presence is the sole shipped signal and readiness treats the item as
satisfied (`docs/workflow.md:85-104`).

The initiative serves two audiences: **framework maintainers**, who hit these
dead ends while running the lifecycle and currently work around them by hand; and
**adopters**, who inherit the same one-way contract. The outcome is a lifecycle
with defined, reviewable, and regression-guarded reverse transitions at every
level — `/build`→`/plan`, `/plan`→`/spec`, `/spec`→`/roadmap`, disputed findings,
and denial of a PR after ship — without breaking the invariant that the owning
phase is the only writer of its own artifact.

## Assumptions

- **Framework-internal, prompt/config/doc/test only.** No installed runtime
  dependency, service, or new toolchain is introduced. Surfaces in scope:
  `docs/workflow.md`, `docs/artifact-conventions.md`, `AGENTS.md`, `README.md`,
  `.opencode/{agent,command,skill}/**`, and `tests/`.
- **Preserve the ownership invariant; do not break it.** A backtrack re-enters the
  upstream phase, whose owning agent revises its own artifact, so "only the owning
  phase writes its artifact" still holds. The model decides how a downstream
  finding is recorded and handed up without the finder editing the upstream file.
- **Extend, do not fork.** The existing review `request-changes`→`/build` rework
  row (`docs/workflow.md:572`), the frontmatter `notes` convention
  (`docs/artifact-conventions.md:15-79`), the derived-state table
  (`docs/workflow.md:548-587`), the readiness algorithm (`docs/workflow.md:85-135`),
  and the `0006` declared-conflict finding grammar are the seed this initiative
  extends; it defines no second state or finding vocabulary.
- **Preserve history; never silently rewrite.** A revision records what changed and
  why (supersede/stale markers or frontmatter `notes`). The post-ship case is
  hard because `ship.md` presence is the sole shipped signal; a recall must stop
  the item satisfying dependents without deleting the historical record.
- **The committed suite stays green.** `bash tests/run.sh` must pass at every step.
  The suite is read-only and **never reads live `work/**`**
  (`tests/README.md:29`), so every new guard must be fixture-based.
- **The user owns the policy forks.** Whether backtracking is a new command
  (`/revise`, `/reopen`) or a step inside existing commands; whether stale
  downstream artifacts are auto-invalidated or only marked; who adjudicates a
  challenged finding and whether an unresolved challenge blocks or escalates; and
  how a recalled item's shipped signal is revoked are user decisions owned by the
  relevant children. The roadmap does not decide them.
- **Shipped work is context, not scope.** `0001`–`0006` and their children are
  treated as approved/shipped. In particular this initiative is **phase-level** and
  distinct from the branch-level merge reconcile of `0005-merge-conflict-workflow`
  and the planning-time declared-conflict check of `0006-parallel-plan-conflicts`;
  it extends their vocabulary but does not re-open them.
- **The `conflicts-with` column is current.** This roadmap is authored after
  `0006-parallel-plan-conflicts` introduced the `Children` `conflicts-with` column;
  its table therefore uses the current six-column template
  (`docs/artifact-conventions.md:80-136`).
- Child numbers are local to this parent and independent of the top-level sequence
  and of other roadmaps.

## Children

| Local id | Title | Scope | Depends on | conflicts-with | Canonical reference |
| -------- | ----- | ----- | ---------- | -------------- | ------------------- |
| 0001-backtracking-model | Phase-backtracking and revision model | Define what a phase reversal (a "backtrack") is and the sanctioned way to perform one when a downstream phase finds an upstream artifact wrong. Fix the reverse-edge model — `/build`→`/plan` (design flaw), `/plan`→`/spec` (spec flaw), `/test`→`/build`/`/plan`/`/spec`, `/review`→`/build`, and a per-item phase→parent `roadmap.md` (the last owned by `0004-roadmap-revision`) — and decide ownership so a backtrack re-enters the upstream **owning** phase, which revises its own artifact, preserving "only the owning phase writes its artifact" (`.opencode/agent/builder.md:109-110`). Define how a finding and its resolution are recorded as committed `work/` state, how downstream artifacts are marked stale/superseded rather than silently rewritten (reconcile with the frontmatter `notes` convention, `docs/artifact-conventions.md:15-79`), and how the model composes with the shipped review `request-changes`→`/build` rework row (`docs/workflow.md:572`) and "Failure and rollback" (`docs/workflow.md:755-780`). Extend the derived-state table with the rework/backtracked/reopened states (`docs/workflow.md:548-587`), deciding whether they are new `phase` values or frontmatter markers. Author the contract in `docs/workflow.md` and `docs/artifact-conventions.md`; cross-reference it from `AGENTS.md`. Keystone — every other child consumes it. Evidence: `.opencode/agent/builder.md:38,109-110`, `.opencode/agent/architect.md:62-63,100,106-107`, `.opencode/agent/reviewer.md:75-76,109`, `.opencode/agent/product.md:103-104`, `docs/workflow.md:285,572,773`, `.opencode/skill/workflow-lifecycle/SKILL.md:57-69`. | — | — | 0007-phase-backtracking/0001-backtracking-model |
| 0002-reverse-phase-routing | Reverse phase routing and upstream re-entry | Give the reverse edges an actual entry point and wire them into the owning prompts and commands. Define and implement how a downstream phase invokes an upstream revision — e.g. a `/revise <item-ref> <target-phase>` (or an equivalent documented route; the surface is a user fork) that records the finding, marks downstream artifacts stale per `0001`, and hands control to the upstream owning phase. Wire `/build`→`/plan` (builder sends a wrong design back, `builder.md:38`) and `/plan`→`/spec` (architect sends an ambiguous or wrong spec back, `architect.md:62-63,106-107`). Cover the plan-publication round trip: a denied or changes-requested `plan/<ref>` PR routes back to `/plan` and republishes, extending the shipper plan-mode revision step (`shipper.md:263-268`, `.opencode/command/ship.md:112-115`). Update the agent prompts, the `/build` and `/plan` commands, the phase `Next:` handoffs, `AGENTS.md`'s lifecycle table, and the `workflow-lifecycle` routing block (`:31-39`). Excludes parent-`roadmap.md` revision (`0004`) and post-ship reopen (`0005`). Evidence: `.opencode/agent/builder.md:38,117-123`, `.opencode/agent/architect.md:62-63,106-107,115-121`, `.opencode/command/build.md`, `.opencode/command/plan.md`, `.opencode/agent/shipper.md:263-268`. | 0001-backtracking-model | docs/workflow.md, .opencode/agent/builder.md, .opencode/agent/architect.md, 0003-findings-challenge-loop | 0007-phase-backtracking/0002-reverse-phase-routing |
| 0003-findings-challenge-loop | Contestable findings and adjudication loop | Add a way to **challenge a finding** rather than silently comply with or silently override it. Today a `review.md` verdict routes to `/build` and the builder must address blockers (`reviewer.md:109`, `docs/workflow.md:285`), with no recorded mechanism for the author to dispute a finding, a severity, or an acceptance-criterion interpretation, or for the reviewer to reconsider. Define a structured, committed challenge/response record (evidence plus rationale), who adjudicates (`/review` re-evaluation, or user escalation when unresolved), and how a sustained versus rejected challenge changes the verdict, the findings, and the next command. Cover a `/test` defect that is really a spec or design fault being contested rather than only handed to `/build`, and reconcile with the existing severity vocabulary and finding format in `docs/artifact-conventions.md:340-390` and the `code-review` skill — do not fork either. Evidence: `.opencode/agent/reviewer.md:75-76,109`, `.opencode/agent/builder.md:38,106-114`, `.opencode/agent/tester.md:99-104`, `docs/artifact-conventions.md:340-390`, `.opencode/skill/code-review/SKILL.md`. | 0001-backtracking-model | docs/workflow.md, .opencode/agent/builder.md, .opencode/agent/reviewer.md, 0002-reverse-phase-routing | 0007-phase-backtracking/0003-findings-challenge-loop |
| 0004-roadmap-revision | Parent-roadmap revision from child phases | Let a child phase feed a correction back into the parent `roadmap.md` ("specs find issues with roadmaps"). Add a revision mode to `/roadmap` (or a documented route) that revises an existing parent rather than always creating a new one: re-scope, add, withdraw, and re-sequence children; create child directories for newly enumerated features; preserve existing child directories, numbers, and history; recompute sequencing so every dependency precedes its dependents; and keep the stored graph acyclic and free of dangling or unlisted children. Decide how a withdrawn child is recorded without reusing its number (mirror the `0003`/`0009` withdrawal handling, `work/0003-framework-quality-hardening/roadmap.md:87-95`) and how revision provenance is recorded. Update the roadmap agent (`roadmap.md:61-107`), the `/roadmap` command, the `roadmap.md` template, and the readiness/integrity surfaces (`docs/workflow.md` → "Roadmaps"). Must keep `tests/checks/80-cycle-fixture.sh:27-98` and the positional `Children`-table contract green, coordinating with the shipped `0006`/`0004-conflict-guards`. Independent of `0002` (which covers intra-item routes) but triggered from the product and architect prompts. Evidence: `.opencode/agent/roadmap.md:61-107`, `.opencode/command/roadmap.md`, `docs/artifact-conventions.md:80-136`, `docs/workflow.md:57-135`, `tests/checks/80-cycle-fixture.sh:27-98`. | 0001-backtracking-model | docs/workflow.md, .opencode/agent/roadmap.md, .opencode/command/roadmap.md | 0007-phase-backtracking/0004-roadmap-revision |
| 0005-post-ship-pr-denial | Post-ship PR denial, recall, and reopen | Handle a PR that is denied, closed, or sent back for changes **after** `ship.md` was written — the "all the way down to denial of pull requests post-ship" case. Define the post-ship states (open PR denied/closed/changes-requested; PR never opened; branch abandoned) and a reopen/recall route that records the denial, revises the item, and returns it to the correct phase via `0002`'s re-entry path. Reconcile with the shipped signal: `ship.md` presence is currently the sole shipped signal and readiness treats it as satisfied (`docs/workflow.md:85-104`), so a recalled item must stop satisfying dependents without silently deleting the historical `ship.md` — decide with the user whether the record is marked revoked/superseded (a new field or superseding artifact) and readiness consults it, or another mechanism is used. Wire the shipper and `/ship` surfaces (`shipper.md:208-217,300-311`, `.opencode/command/ship.md`) and never force-push or rewrite pushed history. Evidence: `.opencode/agent/shipper.md:208-217,300-311`, `docs/workflow.md:85-135,548-587`, `.opencode/agent/status.md:125-134`. | 0001-backtracking-model, 0002-reverse-phase-routing | docs/workflow.md, .opencode/agent/shipper.md, .opencode/agent/status.md, .opencode/command/ship.md | 0007-phase-backtracking/0005-post-ship-pr-denial |
| 0006-status-and-derived-state | Status, derived state, and readiness for backtracked items | Extend `/status` and the derived-state contract to report the new states. Add phase values or markers for backtracked, rework, challenged, and recalled/reopened items and stale downstream artifacts; report which upstream artifact is being revised and which downstream artifacts are invalidated; and ensure a recalled/reopened item no longer satisfies a dependency while an approved or `ship.md`-present item still does. Update the "Derived state" table and readiness algorithm (`docs/workflow.md:548-587,85-135`), the `status` agent's phase vocabulary and findings (`status.md:125-134,229-231`), and the `workflow-lifecycle` skill. Reuse the existing finding grammar; add no second vocabulary. Consumes the state shapes fixed by `0001`, `0002`, and `0005`. Evidence: `.opencode/agent/status.md:75-123,125-134,229-231`, `docs/workflow.md:548-587`, `docs/artifact-conventions.md:15-40`. | 0001-backtracking-model, 0002-reverse-phase-routing, 0005-post-ship-pr-denial | docs/workflow.md, .opencode/agent/status.md | 0007-phase-backtracking/0006-status-and-derived-state |
| 0007-backtracking-guards | Committed backtracking and reopen guards | Extend the committed suite (`tests/`) to pin the backtracking/reopen contract as fixture-based agreement areas: reverse-edge routing and the recorded finding, stale-downstream marking, the challenge/response record and its adjudication, parent-roadmap revision integrity (Children table after a revision), the post-ship recall signal and readiness no longer satisfied, and the new derived states. Update `tests/README.md` to document the new areas and extend `tests/mutation.sh` so each guard is proven caught and named. Keep the existing readiness/cycle/inventory/conflict/signature areas (`tests/checks/10-readiness.sh`, `40-inventory.sh`, `80-cycle-fixture.sh`, `85-conflict-guards.sh`, `96-signature-sweep.sh`) green rather than duplicating their agreements, and remain fixture-based because the suite never reads live `work/**` (`tests/README.md:29`). Sequenced last so it freezes settled surfaces. Evidence: `tests/run.sh`, `tests/checks/10-readiness.sh`, `tests/checks/40-inventory.sh`, `tests/checks/80-cycle-fixture.sh`, `tests/checks/85-conflict-guards.sh`, `tests/README.md:29,64-116`, `tests/mutation.sh`. | 0001-backtracking-model, 0002-reverse-phase-routing, 0003-findings-challenge-loop, 0004-roadmap-revision, 0005-post-ship-pr-denial, 0006-status-and-derived-state | tests/checks, tests/fixtures, tests/README.md, tests/mutation.sh | 0007-phase-backtracking/0007-backtracking-guards |

## Sequencing

1. 0001-backtracking-model
2. 0002-reverse-phase-routing
3. 0003-findings-challenge-loop
4. 0004-roadmap-revision
5. 0005-post-ship-pr-denial
6. 0006-status-and-derived-state
7. 0007-backtracking-guards

`0001-backtracking-model` is the keystone: the reverse-edge model, the ownership
rule, the committed finding record, the stale/downstream marking, and the new
derived states must be fixed before any route, command, or report can be
specified. Once `0001` lands, `0002-reverse-phase-routing` (intra-item re-entry),
`0003-findings-challenge-loop` (disputing a finding), and `0004-roadmap-revision`
(parent-roadmap revision) have no unmet prerequisites and may proceed in
parallel; they are ordered `0002`, `0003`, `0004` here only to keep a stable
reading order, since `0002` and `0003` share `.opencode/agent/builder.md` and
`docs/workflow.md`. `0005-post-ship-pr-denial` follows `0002` because its reopen
path routes back into the lifecycle `0002` defines. `0006-status-and-derived-state`
follows `0002` and `0005` because it must report the states those introduce.
`0007-backtracking-guards` is deliberately last so it can pin the settled
reverse-edge routing, challenge record, roadmap-revision integrity, recall
signal, and derived states with committed, fixture-based regression coverage.

## Open issues

- **Single-feature check.** The initiative is genuinely multi-feature — a
  documented reverse-transition model, intra-item routing, a findings-challenge
  loop, parent-roadmap revision, a post-ship recall path, derived-state/status
  reporting, and committed guards — so a roadmap is the right vehicle rather than a
  standalone `/spec`.
- **No duplicate roadmap.** Recon of `work/` found four existing roadmaps
  (`0003-framework-quality-hardening`, `0004-adoption-template-split`,
  `0005-merge-conflict-workflow`, `0006-parallel-plan-conflicts`) and two flat
  items (`0001-framework-consistency-hardening`, `0002-agentic-roadmaps`); none
  covers phase reversal, finding challenges, or post-ship reopen. `0005` is
  branch-level merge reconcile, `0006` is planning-time declared conflicts, and
  `0003/0005-fix-landing` is only the `/fix` landing path. No collision was found.
- **Possible overlap with shipped readiness/ship-state work.** Child
  `0005-post-ship-pr-denial` touches `ship.md` and the readiness algorithm that
  `0003/0002-readiness-ship-state` settled, and `0006-status-and-derived-state`
  extends the derived state that the same item defined. They must extend and
  reference those decisions, not re-open or fork them, and keep
  `tests/checks/10-readiness.sh` green.
- **Possible overlap with `0006-parallel-plan-conflicts`.** Child
  `0004-roadmap-revision` edits the `Children` table that `0006` extended with the
  `conflicts-with` column; it must keep the six-column positional contract and
  `tests/checks/85-conflict-guards.sh` green rather than forking the column
  layout.
- **Unresolved user decision — invocation surface.** Whether backtracking is a new
  command (`/revise`, `/reopen`, or similar) or a documented step inside existing
  commands is a design fork owned by the relevant children. It changes the command
  inventory and therefore `README.md` and `tests/checks/40-inventory.sh`.
- **Unresolved user decision — stale-artifact handling.** Whether downstream
  artifacts are auto-invalidated or only marked stale, and whether a backtracked
  item re-runs downstream phases or resumes where it left off, materially change
  the model and status reporting. Owned by `0001-backtracking-model` and
  `0006-status-and-derived-state`.
- **Unresolved user decision — challenge adjudication.** Who adjudicates a
  contested finding, and whether an unresolved challenge blocks the item or
  escalates to the user, is owned by `0003-findings-challenge-loop`.
- **Unresolved user decision — shipped-signal revocation.** How a post-ship recall
  revokes the shipped signal without deleting the historical `ship.md` (a new
  frontmatter field, a superseding record, or another mechanism) is owned by
  `0005-post-ship-pr-denial`; it changes the readiness contract and therefore
  `0006-status-and-derived-state`.
- **Deliberately out of scope — automatic re-planning.** Automatic reordering or
  re-scheduling of roadmap children from a revision, and any branch/merge
  reconcile (owned by the shipped `0005-merge-conflict-workflow`), are not part of
  this initiative. Recorded here so the omission is explicit rather than silent.
- **Advisory conflicts are intentional.** Several rows declare `docs/workflow.md`
  (and shared agent/command surfaces) in `conflicts-with`. The read-only
  declared-conflict check will therefore report `TEXTUAL-CONFLICT` pairs among
  this roadmap's own children; this is intentional — they are independent
  siblings that all edit the authority doc — and is advisory only, changing no
  `Depends on` edge and no child's readiness.
- **Cycle check.** The stored `Depends on` graph is acyclic by construction
  (`0001` → {`0002`, `0003`, `0004`}; `0001`→`0002`→`0005`→`0006`;
  `{0001..0006}`→`0007`); no `CYCLIC-DEP` is expected. Recorded because the
  roadmap agent never stores a cycle.
