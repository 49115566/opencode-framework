---
feature: 0005-merge-conflict-workflow/0003-shared-surface-reconcile
phase: spec
status: final
created: 2026-10-07
updated: 2026-10-07
notes: "Nested roadmap child; dependencies 0001-conflict-model and 0002-conflict-detection are satisfied (both have ship.md present), so it is ready. User resolved four forks: (1) the shipper gains a scoped edit allow for class (a) shared surfaces and resolves markers itself; (2) this child completes any merge it encounters, resolving class (a) and class (b)/(c) conflicts per the 0001 principles, with 0004 automating work/ renumbering and graph repair; (3) the reconcile record extends ship.md and the PR description; (4) a semantic conflict aborts the merge to restore a clean tree and escalates."
parent: 0005-merge-conflict-workflow
---

# Reconcile workflow for shared framework surfaces

## Problem

`0001-conflict-model` fixed the merge-conflict contract and `0002-conflict-detection`
added a read-only pre-flight, but the reconcile those pieces describe still cannot
be executed by the agent that owns it. The `merge-conflict` skill's first procedure
step instructs the shipper to "Merge the default branch forward into the item
branch" (`.opencode/skill/merge-conflict/SKILL.md:145-151`), yet the shipper's bash
allowlist grants no merge operation and its edit scope is `work/**` only
(`.opencode/agent/shipper.md:4-32`). So when a branch actually falls behind the
default branch and a shared framework file conflicts, the agent can detect the
collision but cannot act on it: it cannot merge the default branch forward and
cannot edit a conflicted `README.md`, `docs/*.md`, or `.opencode/**` file to
resolve the markers. The result is exactly the situation commit `22d0b69`
illustrates — a hand-resolved `README.md` conflict on a roadmap-child branch with
no executable procedure, no scoped write authority, and no committed record of what
was resolved. **Framework maintainers** shipping roadmap-child branches, and
**adopters** running parallel work items, both inherit this gap: the contract says
what should happen, the tooling cannot perform it, and no artifact shows it was
done and re-verified.

## Goals

- An agent-executable reconcile: fetch the latest default branch, merge it forward
  into the item branch, resolve shared-surface conflict markers by preserving both
  branches' intent, and complete the merge — including `work/` artifact and
  duplicate-sequence conflicts encountered in the same merge — without rebasing or
  force-pushing.
- The shipper holds the scoped permissions the reconcile needs, both to perform the
  git operations and to edit the shared framework files it must resolve, without
  weakening the never-merge-a-PR and never-force-push guardrails.
- A defined escalation path: a conflict requiring a judgement about competing
  intents is never silently resolved; the merge is aborted to a clean tree and the
  decision is escalated to the user.
- Re-verification is mandatory and observable: the committed suite and the affected
  item's checks run after any resolution and must be green before the merge is
  committed, recorded, or shipped.
- The reconcile result is durable: the reconciled paths and the re-verification
  evidence are recorded in the shipped record and the pull-request description, so
  a reviewer can confirm both.
- The existing committed suite stays green and no new command, agent, lifecycle
  phase, or readiness rule is introduced.

## Non-goals

- **Read-only pre-flight conflict detection and classification** — shipped as
  sibling `0002-conflict-detection`; this child consumes its findings and does not
  re-specify detection.
- **Automated `work/` renumbering and roadmap-graph-repair tooling.** This child
  completes a merge that contains those conflicts by applying the existing
  "Renumbering after a parallel merge" rule and the 0001 principles by hand;
  sibling `0004-artifact-reconcile` owns any automation or checked procedure.
- **Committed merge-integrity guards and mutation coverage** — sibling
  `0005-merge-integrity-guards`.
- **A new command or agent.** Reconciliation remains a step inside `/ship` owned by
  the shipper; no `/reconcile` command and no `reconciler` agent is added.
- **Rebase, interactive rebase, amend-of-pushed, or force-push support.** All are
  excluded; the merge-forward rule is unchanged.
- **Automatic resolution of semantic conflicts.** A conflict that requires a
  judgement between competing intents is escalated, never auto-resolved.
- **Structurally de-duplicating the shared surfaces** so parallel branches stop
  colliding — a deliberate roadmap omission.
- **Reopening the state model, readiness model, permission-class model, or shipped
  sibling work** (`0003-framework-quality-hardening`,
  `0004-adoption-template-split`).

## Users and stories

- **As the** shipper agent, **I want** an executable merge-forward reconcile with
  the git and edit permissions it needs, **so that** I can actually resolve
  conflicts during `/ship` instead of detecting them and stopping.
- **As a** framework maintainer whose branch has fallen behind, **I want** the
  reconcile to run the same reviewable way every time and record what it resolved,
  **so that** I can trust and audit the merge rather than reconstruct it by hand.
- **As a** reviewer, **I want** the reconciled paths and the re-verification
  evidence committed in the shipped record and the PR, **so that** I can confirm
  the merge was resolved preserving both branches and re-verified before I approve.
- **As the** shipper agent, **I want** an unambiguous stop-and-abort path for a
  semantic conflict, **so that** I never silently choose between competing intents.
- **As an** adopter running parallel work items, **I want** reconciliation to work
  out of the box on the framework's own shared surfaces, **so that** I do not have
  to invent the procedure when my branches collide.

## Acceptance criteria

1. **AC1** — Given the `merge-conflict` skill and the shipper's process, when the
   reconcile step is read, then it specifies an ordered, agent-executable procedure
   that determines the default branch and the merge base, fetches the latest default
   branch, merges the default branch forward into the item branch, and explicitly
   never rebases and never force-pushes.

2. **AC2** — Given the shipper agent's declared bash capability, when its allowlist
   is read, then it permits the git operations the reconcile needs — fetching the
   default branch, merging it forward, inspecting conflict status and diff, and
   aborting a merge — while rebase remains impermissible, force-push remains a
   confirmation-required action, and merging a pull request remains forbidden.

3. **AC3** — Given the shipper agent's declared file-edit capability, when it is
   read, then it permits editing the class (a) shared framework surfaces the
   reconcile must resolve — the root `README.md` and `AGENTS.md`, `docs/*.md`, the
   `.opencode/{agent,command,skill}/**` surfaces, `template/**`, and
   `tests/checks/**` — in addition to `work/**`; and the README's Agents row for the
   shipper plus the committed permission-agreement check both remain consistent
   with that declaration.

4. **AC4** — Given both branches edited the same shared framework file, when the
   reconcile reaches a conflict marker in that file, then the procedure resolves
   the marker by preserving both branches' changes — dropping neither side — and
   the resolved file contains no conflict markers.

5. **AC5** — Given a conflict whose resolution is mechanical or structural and does
   not require choosing between competing intents, when the reconcile runs, then
   the shipper may auto-resolve it without stopping, subject to AC6's
   re-verification.

6. **AC6** — Given any resolution, when it completes, then the committed suite
   (`bash tests/run.sh`) and the affected item's checks are re-run, and both must be
   green before the resolved merge is committed, recorded, or shipped.

7. **AC7** — Given a conflict that requires a judgement about competing intents,
   when the reconcile reaches it, then the shipper does not resolve it; it aborts
   the merge to restore a clean working tree, reports the specific blocked path(s)
   and the decision the user must make, and the ship stays blocked until the user
   responds.

8. **AC8** — Given a merge that also produces `work/` artifact conflicts or
   duplicate sequence-number conflicts, when the shipper reconciles, then it still
   completes the merge: `work/` records from both branches are preserved rather than
   dropped, and duplicate sequence numbers are handled by the existing
   "Renumbering after a parallel merge" rule; automated renumbering and
   graph-repair remain sibling `0004`.

9. **AC9** — Given the reconcile completes, when the shipped record and pull
   request are written, then the reconcile is recorded — the resolved paths and the
   re-verification evidence — in both `ship.md` and the pull-request description, so
   a reviewer can confirm what was resolved and that it was re-verified.

10. **AC10** — Given the artifact conventions, when the `ship.md` template is read,
    then it documents the reconcile record — the location where resolved paths and
    re-verification evidence belong — as part of the shipped artifact's format.

11. **AC11** — Given the `/ship` command and the shipper agent, when work-item mode
    is read, then reconciling first is stated as a step that runs after the
    read-only pre-flight and before the other ship operations, and the guardrails
    never merge a pull request and never force-push remain unchanged.

12. **AC12** — Given an item branch already up to date with the default branch,
    when the reconcile runs, then it is a no-op that reports no conflicts, does not
    error, and creates no merge commit.

13. **AC13** — Given the repository after the change, when `bash tests/run.sh`
    runs, then it passes, including the inventory agreement (no new command, agent,
    or skill is added) and the documented-vs-declared permission agreement for the
    shipper.

14. **AC14** — Given the repository after the change, when the lifecycle phases,
    readiness/state models, and command and agent inventories are inspected, then
    none gains or loses an entry, no new phase, command, or agent exists, and the
    only artifact-format change is the documented reconcile record in `ship.md`
    (AC10).

## Edge cases

- **Nothing to reconcile.** The item branch is already up to date: the reconcile is
  a no-op that reports no conflicts, does not error, and adds no merge commit
  (AC12).
- **Default branch undeterminable.** No remote, `origin/HEAD` unset, or detached
  repo: the reconcile reports that it cannot determine the merge base rather than
  guessing, and does not mutate the branch.
- **Fetch unavailable or denied.** The reconcile reports the comparison as skipped
  with the reason; it never claims a branch is reconciled or up to date on a stale
  or partial comparison.
- **Behind but conflict-free.** A clean merge is not proof of correctness; the merge
  still runs and AC6's re-verification still runs, because derived-agreement drift
  surfaces only there.
- **Delete/modify conflict.** One branch deleted a file the other changed: resolution
  preserves both branches' intent or, if that requires a judgement, escalates
  (AC7) rather than silently keeping one side.
- **Markers remain after resolution.** A resolved file that still contains conflict
  markers is treated as unresolved: the reconcile does not commit it.
- **Semantic conflict escalated mid-merge.** The shipper aborts the merge to a clean
  tree (AC7). If the abort cannot complete, it reports that and stops rather than
  committing a partial merge.
- **Re-verification fails after a mechanical resolution.** The resolution is not
  accepted: the merge is not committed, recorded, or shipped, and the specific
  failing check is reported as the blocker.
- **Duplicate sequence number in a mixed merge.** The collision defers to the
  "Renumbering after a parallel merge" rule; if the collision cannot be resolved by
  that rule or needs a judgement, the merge aborts and escalates (AC7, AC8).
- **Roadmap `Children` / `Depends on` conflict.** Both branches' rows and cells are
  preserved; the resulting graph is re-checked for dangling, duplicate, unlisted,
  or cyclic references, and an unresolvable graph escalates (AC7, AC8).
- **Binary file conflict.** Content merging is not possible and taking one side
  requires a judgement: escalate (AC7).
- **Already mid-merge at start.** If a merge is already in progress, the shipper
  reports it and does not start a second merge.
- **Large conflict set.** Every conflicting path is resolved or reported; the path
  list is never truncated.
- **Concurrent ships on the same branch.** Out of scope; the reconcile does not take
  a lock and assumes one shipper per branch.

## Open questions

- [x] **Resolution authority and write scope** — **resolved (user):** the shipper
      resolves conflict markers itself; it gains a scoped edit allow for the class
      (a) shared surfaces, and the README Agents row and permission-agreement check
      stay consistent.
- [x] **Scope boundary with sibling `0004`** — **resolved (user):** this child
      completes any merge it encounters, resolving class (a) and class (b)/(c)
      conflicts using the 0001 principles; `0004` owns automation of `work/`
      renumbering and graph repair.
- [x] **Where the reconcile is recorded** — **resolved (user):** in both `ship.md`
      (extending its documented format) and the pull-request description.
- [x] **Escalation end-state** — **resolved (user):** abort the merge to a clean
      working tree and escalate; the branch stays clean.
- [ ] **Exact permission pattern set and the README Agents-row wording** that keep
      the coarse documented-vs-declared permission class green (adding `tests/checks`
      or `AGENTS.md` patterns changes the shipper's coarse edit class). — owner:
      architect, needed by: design. **Deferred:** the required behavior is fixed by
      AC3; the precise patterns and row wording are design decisions.
- [ ] **Name and shape of the `ship.md` reconcile record section** (AC10) and the
      corresponding pull-request section, and whether either reuses sibling `0002`'s
      detection record. — owner: architect, needed by: design. **Deferred.**
- [ ] **Exact git command forms** for merge-forward, conflict inspection, and abort,
      and their fallbacks on older git. — owner: architect, needed by: design.
      **Deferred.**

## Dependencies and constraints

- **Dependencies satisfied.** The parent `roadmap.md` lists this child as
  `Depends on: 0001-conflict-model, 0002-conflict-detection`; both children's
  `ship.md` files are present, so both dependencies are satisfied and this child is
  ready. This child is the first of the two reconcile siblings sequenced to land
  before `0004-artifact-reconcile` because they extend the same `merge-conflict`
  skill and the same shipper/`/ship` surfaces.
- **Consumes the `0001` contract.** The taxonomy, lifecycle placement, ownership,
  merge-forward principle, auto-resolve-mechanical/escalate-semantic rule, and
  re-verification requirement are authoritative in `docs/workflow.md` →
  `## Merge conflicts` and operational in `.opencode/skill/merge-conflict/SKILL.md`;
  this child makes the resolve step executable and defines no second policy.
- **Consumes the `0002` pre-flight.** The read-only detection and classification
  already exist in the skill and the shipper's preconditions; this child's reconcile
  runs after and consumes that output rather than duplicating it.
- **Shipper is the only git writer and owns reconciliation.** Its guardrails forbid
  rebase, force-push, and merging a pull request
  (`.opencode/agent/shipper.md:166-179`); broadening its allowlist must not weaken
  them.
- **Permission-agreement constraint.** `tests/checks/30-permissions.sh:22-99`
  derives a coarse edit class and bash class from the shipper's frontmatter and
  compares them to the README Agents table. Adding edit patterns for the shared
  surfaces can change the derived class (for example, a `tests/**` pattern makes the
  class `tests+work`), so the declaration and the README row must move together.
- **Inventory constraint.** `tests/checks/40-inventory.sh` enforces the README
  Layout counts and table membership; this child adds no agent, command, or skill,
  so those counts must not change (AC13).
- **Suite constraints.** The committed suite is read-only, provider-neutral, and
  never reads `work/**` (`tests/README.md:29`); this child's verification is by
  literal-presence inspection of the delivered surfaces plus the committed suite,
  following the `0001`/`0002` precedent of an item-level read-only verification
  script. Committed merge-integrity guards are sibling `0005`.
- **Shared-surface distribution.** `.opencode/**` and `docs/*.md` are shared
  verbatim with adopters, and `template/AGENTS.md` is the adopter-pristine source
  (`README.md:8-16`); the reconcile procedure and permissions therefore reach
  adopters on their next copy without a migration.
- **Shipped siblings are context, not scope** (`0003-framework-quality-hardening`,
  `0004-adoption-template-split`); their surfaces are not re-opened.
- **Assumption:** the reconcile creates a merge commit on the item branch only; the
  shipper never writes to the default branch, consistent with the existing
  guardrails.
- **Assumption:** because the deliverable is the framework's own prompts,
  configuration, and documents, the acceptance criteria name the required behavior
  and the surfaces that must carry it so they are testable; they state required
  behavior, not implementation choices.
