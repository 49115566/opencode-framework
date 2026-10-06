---
feature: 0003-framework-quality-hardening/0005-fix-landing
phase: spec
status: final
created: 2026-10-05
updated: 2026-10-05
parent: 0003-framework-quality-hardening
notes: "Ready: dependency 0001-state-model is satisfied because its ship.md is present (shipped). User decisions recorded: (1) shipper-on-request landing with no new work item, artifact, or sequence number; (2) no independent review for a fix; (3) reuse /ship, no new command or agent; (4) a landed fix creates no shipped-state record (the shipped signal stays scoped to lifecycle work items)."
---

# Fix-track landing path

## Problem

`/fix` is documented as a first-class lightweight track — "reproduce, fix, test,
report" — but it has no sanctioned way to land. The builder is told to add a
regression test and run the project's checks, and then stops: `.opencode/command/fix.md:24`
says "Never commit", and `.opencode/agent/builder.md:38,77` says the builder never
commits because "the shipper does, on request". Yet the shipper's preconditions
(`.opencode/agent/shipper.md:69-77`, `.opencode/command/ship.md:8-12`) require an
approved work item with a `review.md`, which a fix does not have. The result is a
dead-end: a verified fix cannot reach a branch, commit, or pull request through any
sanctioned path.

This affects adopters and maintainers who use `/fix` for small defects, and it
undermines the framework's own contract: `README.md:23` promises "Only the shipper
commits, and only when you run `/ship`", but `/fix` has no route into `/ship`. The
only workaround is for the user to commit by hand, bypassing the shipper's secret
scan, conventional-commit discipline, and PR evidence. `/fix` therefore either
dead-ends or silently violates the guardrail it is supposed to respect.

## Goals

- A verified `/fix` has a documented, sanctioned landing path that ends in a
  reviewable pull request (or local commits when `gh` is unavailable), without the
  user hand-committing.
- The landing path uses only the shipper for git writes, so the "only the shipper
  commits" trust boundary holds on the fix track too.
- The fix track stays lightweight: no spec, no design, no independent review, and
  no work-item artifact or sequence number.
- Every surface that describes the fix track agrees on one landing path, and no
  surface still presents a fix as un-landable.
- A landed fix carries a durable, human-readable record of its reproduction, root
  cause, change, and check evidence in the pull request.

## Non-goals

- Introducing a new artifact type, phase, or directory under `work/` for a fix
  (no fix record and no shipped-state record).
- Consuming a work-item sequence number for a fix.
- Changing the full lifecycle, its artifacts, or its requirement that a work item
  receive an independent review before shipping.
- Granting git-write capability to the builder or any other non-shipper agent.
- Allowing the shipper to commit, push, or open a PR without the user's explicit
  request.
- Landing a fix whose verification failed or whose reproduction could not be
  established.
- Auto-promoting a fix into the full lifecycle, or changing when a fix should be
  routed to `/spec`.
- Changing readiness or shipped-state semantics, or the fate of the shipped-state
  record for work items.
- Broad permission hardening or modifying the read-only agent allowlists.

## Users and stories

- **As an** adopter or maintainer, **I want** to run `/fix` on a small defect and
  then land it without hand-committing, **so that** a fix follows the same commit
  and secret-scan discipline as every other change.
- **As a** framework maintainer, **I want** only the shipper to perform git writes
  on every track, **so that** the trust boundary is not quietly weakened for
  lightweight fixes.
- **As a** fix author, **I want** the landing path stated at the point `/fix` ends,
  **so that** I know the exact next action instead of discovering a dead-end.
- **As a** reviewer, **I want** a fix PR to state its reproduction, root cause,
  change, and check evidence, **so that** I can assess it without a specification.

## Acceptance criteria

1. **AC1 — A verified fix has a documented landing path.** Given a `/fix` run has
   completed reproduction, fix, regression test, and checks, when its closing
   handoff is read, then it names the sanctioned way to land the fix (the user
   explicitly requests shipping and the shipper performs it) as the next action.

2. **AC2 — Landing requires an explicit user request.** Given a verified fix in the
   working tree, when the user has not explicitly requested shipping, then no
   commit, push, or pull request is created for it.

3. **AC3 — A verified fix can land.** Given a fix whose regression test failed
   before and passes after the change and whose test, lint, and typecheck pass for
   the touched scope, when the user explicitly requests shipping, then the shipper
   creates a branch, stages and commits the change and its regression test in
   conventional commits, and opens a pull request (or makes local commits and
   reports the exact push and PR commands when `gh` is unavailable).

4. **AC4 — No review artifact is required for a fix.** Given a fix with no
   independent review record, when the user explicitly requests shipping, then the
   shipper lands it without stopping for a missing review, as a documented
   exception to its approved-work-item precondition.

5. **AC5 — Only the shipper performs git writes.** Given the fix landing path, when
   any surface describes who commits, then the builder and every other non-shipper
   agent still never commit or push, and the shipper is the only agent that does.

6. **AC6 — The fix consumes no work item.** Given a `/fix` run and its landing,
   when the artifact tree is inspected, then no new work-item directory, sequence
   number, or fix artifact has been created.

7. **AC7 — Evidence travels with the fix PR.** Given a fix is shipped while `gh` is
   available, when the pull request is opened, then its description records the
   reproduction, the root cause, the change, and the check results, and no secret
   was staged.

8. **AC8 — No surface still dead-ends the fix track.** Given every documentation,
   command, and agent surface that describes the fix track, when searched for an
   unconditional prohibition on committing a fix with no stated landing path, then
   none remains; each states or consistently refers to the shipper-on-request
   landing path.

9. **AC9 — Guardrails and shipper preconditions agree.** Given the always-loaded
   workflow contract's git-write guardrail and the shipper's stated preconditions,
   when compared, then both state that the shipper may land a verified fix on the
   user's explicit request while all other agents never perform git writes.

10. **AC10 — Failed verification blocks landing.** Given a fix whose verification
    fails, or a defect that could not be reproduced, when the run ends, then the
    landing path is not presented as successfully completed, and no commit or pull
    request is created.

11. **AC11 — The track stays lightweight.** Given a fix is landed, when the
    artifacts and process used are reviewed, then no spec, design, task list,
    verification artifact, or independent review was required, and the fix
    remained a small, focused change.

12. **AC12 — The documentation surfaces agree.** Given the workflow routing
    documentation, the `/fix` command text, the builder's lightweight-fix
    instructions, the shipper's instructions, and the lifecycle skill, when
    compared, then they describe one landing path and no longer contradict each
    other.

## Edge cases

- **`gh` unavailable or unauthenticated.** The shipper makes the local commits and
  reports the exact commands the user must run to push and open the PR; no partial
  or uncommitted fix is left behind.
- **A secret in the fix diff.** The shipper stops and reports; nothing is committed
  or pushed.
- **Unrelated pre-existing working-tree changes.** The shipper stages only the
  fix's files and refuses to sweep unrelated edits into the fix; ambiguity is
  surfaced to the user.
- **The current branch is the default branch.** The shipper creates a fix branch
  rather than committing to the default branch.
- **A fix that grows into new behavior.** The builder routes to `/spec`; the fix
  landing path does not apply.
- **The defect cannot be reproduced.** The builder stops and asks for precise
  steps (existing behavior); no landing is offered.
- **An untestable defect with no regression test.** The run cannot meet the
  verification bar, so landing is blocked unless the user explicitly accepts the
  gap; the acceptance must be recorded in the PR.
- **Several independent fixes pending at once.** The user's explicit request and
  the shipper's staging determine which fix lands; each is committed as its own
  logical unit.
- **Concurrent lifecycle work items.** Because a fix consumes no sequence number,
  it cannot collide with or renumber a work item, even when both are in flight.
- **`/ship` invoked with neither a fix nor a work item.** Existing behavior is
  unchanged — the shipper asks which work item to ship.

## Open questions

- [ ] The exact user-facing spelling of the explicit ship request for a fix (for
      example, `/ship` with a fix-oriented argument versus `/ship` with no item
      reference while a verified fix is pending) — owner: architect, needed by:
      `/plan`. Working assumption: reuse `/ship`; the design selects the spelling
      without adding a command or changing documented inventories.
- [ ] How the shipper distinguishes a fix's files from an unrelated in-progress
      work item's files when both share a working tree, and what it asks the user
      — owner: architect, needed by: `/plan`. Working assumption: the shipper
      stages only the files the fix changed and asks when the boundary is unclear.

## Dependencies and constraints

- **Readiness:** this child depends on `0003-framework-quality-hardening/0001-state-model`,
  satisfied because its `ship.md` is present (shipped). The chosen committed model
  means the fix's source change and regression test ride the same branch and PR;
  no fix artifact is required for that to work.
- **Sibling `0002-readiness-ship-state`:** the shipped signal is the presence of
  the shipped-state record for a work item. A fix creates no work item and
  therefore no shipped-state record; readiness and shipped-state semantics are
  unchanged and remain scoped to lifecycle work items. This item must not
  contradict that definition.
- **Sibling `0003-readonly-permissions`:** this item must not add git-write
  capability to a read-only agent; it relies on the shipper's existing git/gh
  allowlist.
- **Static verification suite constraint:** the framework's existing verification
  scripts assert documented inventories (agent, command, and skill counts and that
  every command appears in the README) and include a regression assertion that
  agent permission blocks are unchanged. The chosen landing path must not add a
  command or agent, and must not alter permission blocks; prose changes to the
  builder and shipper are expected and must keep those assertions green. Sibling
  `0006-committed-tests-ci` relocates this suite.
- **Existing guardrail wording:** the always-loaded workflow contract already
  permits git writes when the user invokes `/ship` or explicitly asks, and names
  the shipper as the only agent that performs them; this item makes the fix track
  consistent with that rule rather than introducing a new permission.
- **Grounding surfaces to reconcile (evidence, not prescription):**
  `.opencode/command/fix.md:24`, `.opencode/agent/builder.md:26,38,77`,
  `.opencode/agent/shipper.md:38-43,69-77`, `.opencode/command/ship.md:8-12`,
  `AGENTS.md:107`, `docs/workflow.md:263-266`, `README.md:23,156`,
  `.opencode/skill/workflow-lifecycle/SKILL.md:62`.
- **No runtime change:** prompt, command, and documentation only; no dependency is
  introduced and no source behavior beyond the landing path changes.
- **Immutability:** previously authored artifacts under `work/` are not edited to
  reflect this change.
- **Assumptions:** the cited dead-end was re-verified against the current files
  during recon; the four landing decisions above are the user's (2026-10-05).
