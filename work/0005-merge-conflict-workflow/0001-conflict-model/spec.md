---
feature: 0005-merge-conflict-workflow/0001-conflict-model
phase: spec
status: final
created: 2026-10-07
updated: 2026-10-07
notes: "Nested roadmap child; no dependencies (Depends on: —), so it is ready. User resolved the three roadmap policy forks: merge-forward / never rebase; auto-resolve mechanical conflicts and escalate semantic ones; reconcile is a step inside /ship owned by the shipper (no new command or agent)."
parent: 0005-merge-conflict-workflow
---

# Merge-conflict model and resolution contract

## Problem

The framework's roadmap feature sequences work items and `/status` reports each
child `ready` or `blocked`, but nothing defines what to do when an item branch
falls behind the default branch and the merge conflicts. The only related rule is
"Renumbering after a parallel merge" (`docs/artifact-conventions.md:438-465`),
which covers a single class — duplicate `work/` sequence numbers. The shipper,
the only git-writing agent, has neither a reconcile procedure nor the git
permissions (`fetch`, `merge`) a reconcile needs (`.opencode/agent/shipper.md:9-28,148-158`),
and its guardrails already forbid the force-push a rebase would require. In
practice the work is done by hand with no defined owner, procedure, or
verification: commit `22d0b69` merged `main` into the roadmap-child branch
`feat/0003-framework-quality-hardening-0005-fix-landing` and a `README.md`
conflict was resolved manually. Two audiences carry the cost — **framework
maintainers**, who resolve roadmap-child merges by hand and cannot point to a
reviewable contract, and **adopters** running parallel work items, who inherit
the same undocumented gap.

## Goals

- A single documented merge-conflict contract that classifies every conflict
  class this workflow can encounter and states the sanctioned handling for each.
- An unambiguous lifecycle placement: reconciliation runs before a ship, and an
  integrity pass runs after a merge to the default branch.
- A single named owner, the `shipper`, with reconciliation executed as a step
  inside `/ship` rather than a new command or agent.
- Fixed, observable resolution principles: merge the default branch forward;
  never rebase a pushed branch and never force-push; preserve both branches'
  intent; never silently accept a semantic conflict and escalate intent
  ambiguity to the user; re-run the suite after resolving.
- The contract extends, and does not fork, the existing "Renumbering after a
  parallel merge" rule.
- A `merge-conflict` skill encoding the agent procedure, discoverable from
  `AGENTS.md` and `README.md`, with the documented inventory kept consistent and
  the committed suite green.

## Non-goals

- **Pre-flight conflict detection and classification tooling** — the read-only
  compare against the default branch and its `/ship` / `/status` surfacing are
  sibling `0002-conflict-detection`.
- **Shared-surface reconcile mechanics** — the executable fetch/merge/resolve
  procedure and the shipper's git allowlist changes are sibling
  `0003-shared-surface-reconcile`.
- **`work/` artifact reconcile and renumbering automation** — merging roadmap
  `Children` tables, repairing dangling/duplicate/cyclic references, and
  automating the renumbering rule are sibling `0004-artifact-reconcile`.
- **Committed merge-integrity guards and mutation coverage** — sibling
  `0005-merge-integrity-guards`.
- **A new command or agent.** Reconciliation is a step inside `/ship` owned by
  the shipper; no `/reconcile` command and no `reconciler` agent is added.
- **Rebase or force-push support, and automatic resolution of semantic
  conflicts** — both are explicitly excluded by the chosen principles.
- **Structurally de-duplicating the shared surfaces** so parallel children stop
  colliding — the roadmap records this as a deliberate omission.
- **Reopening the state model, readiness model, or shipped sibling work**
  (`0003-framework-quality-hardening`, `0004-adoption-template-split`).

## Users and stories

- **As a** framework maintainer whose roadmap-child branch has fallen behind the
  default branch, **I want** a defined reconcile procedure and owner, **so that**
  I resolve conflicts the same reviewable way every time instead of by hand.
- **As the** shipper agent, **I want** an explicit, step-by-step reconcile
  procedure grounded in the merge-forward principle, **so that** I can reconcile
  without violating my never-force-push guardrails.
- **As an** adopter running parallel work items, **I want** the framework to
  describe what to do when items collide, **so that** I do not have to invent a
  policy.
- **As a** reviewer, **I want** the reconcile contract and its re-verification
  requirement documented, **so that** I can confirm the merge was resolved and
  re-verified before approving.

## Acceptance criteria

1. **AC1** — Given the workflow contract, when its merge-conflict section is
   read, then it defines a taxonomy naming each of these conflict classes:
   (a) textual conflicts in shared framework surfaces, (b) `work/` artifact
   conflicts, (c) duplicate sequence numbers, and (d) derived-agreement drift in
   duplicated inventory/count facts; and each class names at least one affected
   surface.

2. **AC2** — Given the workflow contract, when its lifecycle-placement statement
   is read, then it states that reconciliation runs as a pre-ship step, before
   the shipper performs its ship operations, and that a post-merge integrity pass
   runs after a merge to the default branch, each tied to its lifecycle point.

3. **AC3** — Given the workflow contract, when its ownership statement is read,
   then it names the `shipper` as the single owner of reconciliation and states
   that reconciliation is a step inside `/ship`, not a new slash command or
   agent.

4. **AC4** — Given the workflow contract, when its resolution principles are
   read, then it requires merging the default branch forward into the item branch
   and explicitly forbids rebasing a pushed branch and force-pushing.

5. **AC5** — Given the workflow contract, when its resolution principles are
   read, then it requires preserving both branches' intent and states that a
   conflict requiring a judgment about intent is never silently accepted and must
   be escalated to the user for explicit approval.

6. **AC6** — Given the workflow contract, when its resolution-authority
   statement is read, then it permits auto-resolving a conflict whose resolution
   is mechanical or structural and does not require choosing between competing
   intents, subject to the post-resolution re-verification in AC7.

7. **AC7** — Given the workflow contract, when its verification requirement is
   read, then it requires re-running `bash tests/run.sh` and the affected item's
   checks after a resolution and requires them green before the resolved merge is
   recorded or shipped.

8. **AC8** — Given the workflow contract and the existing "Renumbering after a
   parallel merge" section, when both are read, then duplicate sequence numbers
   are handled by that existing rule and the merge-conflict contract defers to
   and extends it rather than defining a second renumbering rule.

9. **AC9** — Given the repository, when the `merge-conflict` skill is loaded,
   then it encodes the shipper's procedure as ordered steps covering detection,
   resolution, re-verification, recording of the resolved paths and evidence, and
   the stop-and-escalate path, consistent with the taxonomy and principles of
   AC1–AC8.

10. **AC10** — Given the repository, when `AGENTS.md` and `README.md` are read,
    then each references the merge-conflict contract or skill (the `AGENTS.md`
    reference list points to it, and the `README.md` Skills table names
    `merge-conflict`).

11. **AC11** — Given the repository after the change, when `bash tests/run.sh`
    runs, then it passes, including the inventory agreement that the README
    Layout skill count and the Skills table both match the on-disk skill set
    containing `merge-conflict`.

12. **AC12** — Given the repository after the change, when the lifecycle phases,
    artifact formats, readiness/state models, and the command and agent
    inventories are inspected, then none of them changed and no new command or
    agent exists.

## Edge cases

- **Overlapping `work/` artifact edits.** Both branches edit a roadmap
  `Children` table (added rows or changed `Depends on` cells). Resolution keeps
  both branches' records, after which the graph is re-checked to be acyclic and
  every `Depends on` local id to resolve to an existing row.
- **Duplicate top-level sequence.** Both branches create `work/<NNNN-slug>` with
  the same `NNNN`. This is a duplicate-sequence conflict and defers to the
  existing renumbering rule (AC8), not a new policy.
- **Duplicate per-parent child sequence.** Both branches add a roadmap child with
  the same local `MMMM` under one parent. Same deferral as above.
- **Textually clean but semantically drifted merge.** A duplicated
  inventory/count fact (for example the README Layout counts) merges without
  conflict markers yet the two sides now disagree. This is derived-agreement
  drift; the post-resolution suite run (AC7) is what surfaces it.
- **Contradictory contract rules.** The two branches state incompatible rules
  (for example different readiness semantics). This requires a judgment about
  intent: escalate, never pick a side silently (AC5).
- **Branch behind but conflict-free.** A clean merge is not evidence of
  correctness; the suite still runs before the merge is recorded (AC7).
- **Nothing to reconcile.** The branch is already up to date: the reconcile step
  and integrity pass are no-ops that do not error.
- **One branch deleted a file the other changed.** Resolution preserves both
  branches' records rather than dropping one side (AC5).
- **Escalation with no user response.** The ship is blocked and reports the
  blocking conflict; the agent must not resolve it silently to proceed (AC5).

## Open questions

- [x] Merge strategy — **resolved (user):** merge the default branch forward into
      the item branch; never rebase a pushed branch and never force-push.
- [x] Resolution authority — **resolved (user):** auto-resolve mechanical or
      structural conflicts; escalate any conflict requiring a judgment about
      intent to the user and never accept it silently.
- [x] Invocation surface and owner — **resolved (user):** reconciliation is a
      step inside `/ship` owned by the shipper; no new command or agent.
- [ ] Is the post-merge integrity pass an agent-executed step or a documented
      manual checklist, and how is it invoked? — owner: architect, needed by:
      design. **Deferred:** the contract must define the pass and its owner; its
      exact invocation is a design decision.

## Dependencies and constraints

- No item dependencies: the parent `roadmap.md` lists this child as
  `Depends on: —`, so it is ready. This child is the keystone all siblings
  consume.
- Must build on and extend `docs/artifact-conventions.md:438-465` and the `work/`
  sequence-allocation contract; it must not define a second renumbering rule
  (AC8).
- The shipper is the only git-writing agent (`.opencode/agent/shipper.md:1-28`);
  its current allowlist omits `fetch` and `merge`, and it forbids force-push
  (`.opencode/agent/shipper.md:148-158`). Granting the git permissions the
  contract needs is sibling `0003-shared-surface-reconcile`; this spec fixes the
  contract the permissions must serve.
- The committed suite is read-only and never reads `work/**`
  (`tests/README.md:29`), so the post-merge integrity pass is an agent or manual
  step, not a suite check; committed guards are sibling `0005-merge-integrity-guards`.
- Adding the `merge-conflict` skill changes a documented count: the README Layout
  states 10 knowledge skills and its Skills table lists them, and
  `tests/checks/40-inventory.sh` enforces both directions. The README and that
  check must agree after this change (AC11).
- Shipped siblings `0003-framework-quality-hardening` and
  `0004-adoption-template-split` are context, not scope; their surfaces are not
  re-opened.
- **Assumption:** because the deliverable is the framework's own documents and a
  skill, the acceptance criteria name those surfaces so they are testable; they
  specify required content, not implementation choices.
- **Assumption:** "merge forward" creates a merge commit on the item branch; the
  agent never writes to the default branch, consistent with the existing
  guardrails.
