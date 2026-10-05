---
feature: 0003-framework-quality-hardening/0002-readiness-ship-state
phase: spec
status: final
created: 2026-10-05
updated: 2026-10-05
parent: 0003-framework-quality-hardening
notes: "Ready: dependency 0001-state-model is satisfied by its review verdict approve (unshipped), so no override was needed. User decisions recorded: (1) keep the ship record artifact as the sole machine-readable shipped signal and grant the shipper write access to work artifacts, removing the unexecutable detected-PR branch; (2) one authoritative readiness definition with every other surface deferring to it; (3) this item adds the readiness-agreement assertion now, in the framework's existing verification suite, with sibling 0006 to relocate and harden it later."
---

# Readiness semantics and shipped-state detection

## Problem

The framework tells maintainers and adopters how dependency readiness and
"shipped" state are determined, but its statements are not mutually consistent
and not fully executable, so two people — or two surfaces — can reach opposite
conclusions about the same repository.

Re-verified against the current files:

- **The readiness rules are duplicated and one copy contradicts itself.** The
  algorithm in `docs/workflow.md:89-101` and the copy in
  `.opencode/agent/status.md:104-116` both say an approve verdict satisfies a
  dependency *even if unshipped*. The prose directly below the copy in the status
  agent says the opposite (`status.md:119-122`). `docs/workflow.md:103-106` is at
  best ambiguous: it groups "an approved-but-unshipped boundary" with the
  unsatisfied cases. Two reads of the framework give two answers.
- **The shipped signal is unreadable.** The readiness algorithm counts "a PR is
  detected for the child" as shipped (`docs/workflow.md:94`,
  `.opencode/agent/status.md:109`), but the status agent's read-only bash
  allowlist (`status.md:6-16`) has no `gh` and cannot query a pull request, so
  that branch can never execute. This is open prior finding m1
  (`work/0002-agentic-roadmaps/review.md:58-69`).
- **The shipped signal is unwritable.** The artifact meant to record shipped
  state is prescribed but the shipper is forbidden to write any file
  (`.opencode/agent/shipper.md:5` is `edit: deny`) while being told to write it
  (`shipper.md:89`, `.opencode/command/ship.md:24`). The documented permissions
  agree with the prohibition (`README.md:173`, "Can edit: none").

**Who is affected:** framework maintainers, who cannot trust a status report to
match the documented rules, and adopters, who copy both the rules and the
permission model into arbitrary repositories. **The cost:** an approved-but-
unshipped dependency can be reported blocked or ready depending on which surface
is read, a hand-shipped dependency is never counted, and a ship record can never
be written in the normal path.

## Goals

- One authoritative readiness definition; every other surface that needs it
  defers to that source, and no surface contradicts it.
- Approved-but-unshipped is stated unambiguously and consistently as satisfying a
  dependency.
- A single machine-readable shipped signal that the shipper can write and the
  status agent can read using only the permissions it already has.
- Every documented permission and behavior surface stays consistent with the
  chosen shipped signal.
- A regression assertion keeps the definition and its descriptions from
  diverging again.

## Non-goals

- Changing the resolved semantics that a dependency is satisfied by an approve
  verdict even before it ships. That was settled by shipped work
  `0002-agentic-roadmaps` and is not reopened here.
- Moving the framework's verification suite to a committed location or adding CI
  (sibling `0006-committed-tests-ci`).
- Broad read-only permission hardening or removing write-capable bash tokens
  (sibling `0003-readonly-permissions`).
- Giving `/fix` a landing path (sibling `0005-fix-landing`).
- Changing default-agent or model configuration (sibling `0007-config-hardening`).
- Revisiting whether `work/` artifacts are committed (sibling `0001-state-model`;
  settled as committed).
- Introducing a state file, registry, ledger, or any stored readiness value.

## Users and stories

- **As a framework maintainer**, I want readiness and shipped state defined once,
  so that no second copy can drift and misreport an item.
- **As a framework maintainer**, I want the shipper to be able to record shipped
  state and the status agent to be able to read it, so that a shipped dependency
  is actually reported satisfied.
- **As an adopter**, I want the documented agent permissions and state derivation
  to match what opencode enforces, so that I can trust the framework's reports in
  my own repository.
- **As a roadmap owner**, I want an approved-but-unshipped dependency to count as
  satisfied clearly and consistently, so that I can sequence children without
  waiting for a merged pull request.

## Acceptance criteria

1. **AC1** — Given the framework's readiness rule set, when a maintainer inspects
   every surface that describes how dependency readiness is computed (the
   workflow documentation, the status agent, the `/status` command, and the
   product agent's blocked-start gate), then exactly one surface states the
   algorithm and every other surface describes it by reference rather than
   restating the branch sequence.

2. **AC2** — Given a dependency child whose review verdict is `approve` and that
   has no shipped-state artifact, when readiness is evaluated, then the
   dependency is satisfied and the depending child is ready, and no surface
   states or implies that this dependency is unsatisfied.

3. **AC3** — Given any surface that describes readiness, when its prose is
   compared with the authoritative algorithm, then it agrees branch-for-branch;
   in particular, the workflow text that groups an approved-but-unshipped
   dependency with the unsatisfied cases is corrected.

4. **AC4** — Given a work item, when its shipped state is derived, then presence
   of that item's shipped-state artifact is the sole condition; no readiness rule,
   derived-state row, or prose credits a detected pull request as an alternate
   shipped signal.

5. **AC5** — Given the shipper runs the Ship phase, when it records shipped state,
   then the shipper holds permission to create or update the artifact under the
   item's work directory, and that grant appears in the documented
   agent-permission surfaces.

6. **AC6** — Given the status agent's read-only permission set, when it derives
   shipped state and readiness, then every step it is instructed to perform is
   executable with the permissions it already holds, with no dependency on `gh`
   or network access.

7. **AC7** — Given the agent-permission documentation and the framework's
   read-only permission-drift check, when they are compared after the change,
   then the shipper's documented capability and its resolved grant agree and the
   automatic permission check produces no finding attributable to this change.

8. **AC8** — Given a standalone approved item with no shipped-state artifact,
   when its phase is derived, then it is the ship phase; given that artifact, then
   it is shipped; and no state file is introduced.

9. **AC9** — Given the framework's existing verification suite, when it runs,
   then it asserts that the authoritative readiness definition is stated exactly
   once and that no surface contradicts the approved-but-unshipped semantics, and
   it fails when a second definition or a contradicting statement is introduced.

10. **AC10** — Given the framework's existing verification suite after the
    change, when it runs, then it passes; any existing assertion that encoded the
    removed detected-PR branch, or that forbade any change to agent permission
    blocks, is updated to the settled behavior rather than left failing.

## Edge cases

- Dependency with an `approve` verdict and no shipped-state artifact → satisfied
  **(AC2)**.
- Dependency with a shipped-state artifact but a `request-changes` verdict →
  shipped-state presence takes precedence and the item reads shipped; the
  authoritative definition states this ordering explicitly.
- Dependency that is actually merged or shipped but has no shipped-state artifact
  (for example, merged by hand) → not satisfied under the single-signal model.
  No surface may claim otherwise; this is the accepted cost of one file-based
  signal.
- Shipped-state artifact present but recording no pull-request URL (for example,
  `gh` was unavailable and only local commits exist) → presence is sufficient;
  the definition keys on presence, not on URL contents.
- Item with no dependencies → ready (unchanged).
- Item in a dependency cycle → never ready (unchanged).
- Multiple dependencies with only some satisfied → the report names exactly the
  unsatisfied ones (unchanged).
- Empty or dangling dependency reference → reported as an integrity finding, not
  a crash (unchanged).
- Read-only derivation with no network → succeeds, because no step requires `gh`.
- `/status` run on a tree mid-`/ship`, before the shipped-state artifact is
  written → reports the pre-ship phase, not an error.
- Standalone item (no parent, no roadmap) → phase derivation and readiness rules
  behave exactly as before.

## Open questions

- [ ] Should sibling `0006-committed-tests-ci` relocate the readiness-agreement
      assertion to a committed test location, and under what name? —
      owner: user/architect, needed by: `0006`'s plan. **Deferred**: this item
      adds the assertion in the existing suite now so the fix is guarded
      immediately.
- **Assumption** (resolved in this spec) — the single shipped-state signal is the
  existing ship record artifact, and the rule keys on its presence rather than
  parsing its contents. Owner: product.
- **Assumption** (resolved in this spec) — the "detected PR" branch is removed
  rather than re-implemented, because the status agent is intentionally read-only
  and network-free. Owner: product.

## Dependencies and constraints

- **Depends on `0003-framework-quality-hardening/0001-state-model`** — satisfied
  by its review verdict `approve` (unshipped). It made `work/` artifacts
  committed working state, so a shipped-state artifact is committable. No further
  dependency work is required.
- **Supersedes prior finding m1** (`work/0002-agentic-roadmaps/review.md:58-69`):
  removing the detected-PR branch resolves it; the roadmap child scope is
  satisfied without forking a second readiness definition.
- **Coordinate with sibling `0006-committed-tests-ci`** on where the agreement
  assertion ultimately lives; this item owns adding it now.
- **No conflict with sibling `0003-readonly-permissions`**: this item adds no
  `gh` permission to a read-only agent and removes a branch, so it moves in the
  same direction.
- The approved-but-unshipped semantics is **fixed by shipped work**
  `0002-agentic-roadmaps` (its acceptance criterion and verification treat
  approve-unshipped as ready); this item does not reopen it.
- The framework consistency diagnostic's permission inventory — the README agent
  table compared against resolved permission blocks — constrains any permission
  wording changed here.
- The existing verification suite is a constraint: it currently asserts the
  detected-PR branch (`work/0002-agentic-roadmaps/verify-tests.sh:219-222`) and a
  "no agent permission block changed vs HEAD" regression (`:233-240`); both are
  updated to the settled behavior under **AC10**.
