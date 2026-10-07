---
feature: 0005-merge-conflict-workflow
phase: roadmap
status: final
created: 2026-10-07
updated: 2026-10-07
---

# Roadmap — Merge-conflict workflow

## Initiative

The framework's roadmap feature gives work items explicit dependency ordering, and
`/status` reports each child as `ready` or `blocked`, but nothing defines what to
do when a branch falls behind the default branch and the merge conflicts — or when
two roadmap children, or two standalone items, touch the same shared surfaces.
Today that work is done by hand whenever it happens: commit `22d0b69` is a
concrete instance in which `main` was merged into the roadmap child branch
`feat/0003-framework-quality-hardening-0005-fix-landing` and a `README.md`
conflict was resolved manually with no procedure, ownership, or verification
step. The existing contract covers one narrow slice only — the "Renumbering after
a parallel merge" rule for duplicate `work/` sequence numbers
(`docs/artifact-conventions.md:438-465`) — and the shipper's own rules forbid the
git operations (`fetch`, `merge`) a reconcile needs
(`.opencode/agent/shipper.md:9-28,148-158`; `.opencode/command/ship.md:64`).

This initiative serves two audiences: **framework maintainers**, who currently
resolve roadmap-child merges by hand and need a defined, reviewable, and
regression-guarded way to do it; and **adopters** running parallel work items,
who receive the same framework and today inherit an undocumented gap. The outcome
is a workflow that says when reconciliation happens, who owns it, how each class
of conflict is resolved, how the result is verified against the committed suite,
and how the framework's own integrity invariants are guarded afterward.

## Assumptions

- **The commit is evidence, not a spec.** Commit `22d0b69` illustrates the class
  of problem (a hand-resolved `README.md` conflict on a roadmap child branch); it
  does not define required behavior. Each child re-verifies the current state of
  the surfaces it touches before acting.
- **Framework-internal and prompt/config/doc/test only.** No installed runtime
  dependency, service, or new toolchain is introduced. The surfaces in scope are
  `.opencode/agent/*.md`, `.opencode/command/*.md`, `.opencode/skill/**`,
  `docs/*.md`, `AGENTS.md`, `README.md`, `template/**`, and `tests/`.
- **Build on the existing renumbering contract, do not fork it.** The
  "Renumbering after a parallel merge" section and the `work/` sequence-allocation
  rules are the seed for the artifact-conflict child; the roadmap extends and
  automates them rather than defining a second contract.
- **The committed suite stays green.** `bash tests/run.sh` (`tests/README.md:18-30`)
  must pass at every step. The suite is read-only and **never reads `work/**`**
  (`tests/README.md:29`), so any new merge-integrity guard must be fixture-based or
  operate on a copy, not on live `work/` content.
- **Adding a skill changes a documented count.** If the model child introduces a
  `merge-conflict` skill or a new command, the README inventory and
  `tests/checks/40-inventory.sh` must be updated in the same change; the roadmap
  does not pre-decide whether a new skill or command is added.
- **The user owns the policy forks.** Merge-forward versus rebase, whether
  semantic conflicts may be auto-resolved or must be escalated for approval, and
  whether reconcile is a new command or a step inside `/ship` are user decisions.
  The owning children present options with trade-offs and recommend; they do not
  decide unilaterally.
- **Shipped siblings are context, not scope.** The children of
  `0003-framework-quality-hardening` and `0004-adoption-template-split` are
  treated as approved/shipped; this roadmap does not redo their work, and in
  particular does not re-open the state model, readiness model, or surface sweep.
- Child numbers are local to this parent and independent of the top-level sequence
  and of other roadmaps.

## Children

| Local id | Title | Scope | Depends on | Canonical reference |
| -------- | ----- | ----- | ---------- | ------------------- |
| 0001-conflict-model | Merge-conflict model and resolution contract | Define what a merge conflict is in this workflow and the sanctioned way to handle each class. Fix a taxonomy: textual conflicts in shared framework surfaces (`README.md`, `AGENTS.md`, `docs/*.md`, `.opencode/{agent,command,skill}/**`, `template/**`, `tests/checks/**`); `work/` artifact conflicts (roadmap `Children`/`Depends on` tables, frontmatter, nested-child intersections); duplicate top-level and per-parent sequence numbers; and derived-agreement drift in duplicated inventories. Decide when reconciliation happens in the lifecycle (a pre-ship reconcile step, plus a post-merge integrity pass) and which single agent owns it; state resolution principles (merge-forward and never rebase a pushed branch, never force-push, re-run `bash tests/run.sh`, never silently accept a semantic conflict, escalate ambiguity to the user); and define how the contract composes with the existing "Renumbering after a parallel merge". Author the contract in `docs/workflow.md` and encode the agent procedure as a new `merge-conflict` skill; reference it from `AGENTS.md`/`README.md`. Keystone — the other children consume it. Evidence: `docs/workflow.md:310-335`, `docs/artifact-conventions.md:438-465`, `.opencode/agent/shipper.md:105-127,148-158`, `.opencode/command/ship.md:64`, commit `22d0b69`. | — | 0005-merge-conflict-workflow/0001-conflict-model |
| 0002-conflict-detection | Pre-flight conflict detection and classification | Add a read-only detection capability that, before a ship and on demand, compares a branch to the default branch and reports conflicts classified per `0001`: textual conflicts (merge-base plus a dry-run merge / `git merge-tree` over the changed paths) and framework integrity collisions (duplicate top-level `work/` prefixes, duplicate roadmap child numbers, roadmap `Depends on` dangling or cyclic references, children absent from a `Children` table, and drift in duplicated inventory/count facts). Surface results in `/ship`'s preconditions and in `/status`; grant the minimal read-only git permissions required (`git fetch`, `git merge-tree`, conflict inspection). Evidence: `.opencode/agent/shipper.md:76-103,148-158`, `docs/workflow.md:310-335`, `docs/artifact-conventions.md:438-465`, `tests/checks/40-inventory.sh`. | 0001-conflict-model | 0005-merge-conflict-workflow/0002-conflict-detection |
| 0003-shared-surface-reconcile | Reconcile workflow for shared framework surfaces | Implement the agent-executable reconcile for textual conflicts in shared framework files (`README.md`, `AGENTS.md`, `docs/*.md`, `.opencode/{agent,command,skill}/**`, `template/**`, `tests/checks/**`): fetch the default branch, merge it forward into the item branch (never rebase a pushed branch, never force-push), resolve conflict markers preserving both branches' intent, then re-run `bash tests/run.sh` and the item's checks and confirm green. Record the reconcile, the resolved paths, and the re-verification in `ship.md`/the PR description. Update the `shipper` process and its bash allowlist (`git fetch`, `git merge`, conflict inspection) and the `/ship` command; define the escalation path when a semantic conflict cannot be resolved mechanically. Must not regress the "never merge a PR / never force-push" guardrails. Evidence: `.opencode/agent/shipper.md:105-127,148-158`, `.opencode/command/ship.md:17-38,64`, `docs/workflow.md:310-335`, commit `22d0b69` (the `README.md` conflict). | 0001-conflict-model, 0002-conflict-detection | 0005-merge-conflict-workflow/0003-shared-surface-reconcile |
| 0004-artifact-reconcile | Reconcile workflow for work/ artifacts and sequence numbers | Implement the `work/`-specific reconcile: merge `work/<item-ref>/**` artifacts forward without dropping either branch's records; merge roadmap `Children` tables and their `Depends on` cells; repair dangling, duplicate, or cyclic references. Automate the existing manual "Renumbering after a parallel merge" contract — detect equal 4-digit prefixes at the top level and within each roadmap parent, choose the unshipped/later item, `git mv` it, and update its `feature`/`parent` frontmatter, the `Children` canonical-reference cells, and PR/handoff paths in one change — as a checked script or documented procedure. Build on the contract; do not fork a second renumbering definition. Evidence: `docs/artifact-conventions.md:438-465`, `docs/workflow.md:318-335`, `work/0003-framework-quality-hardening/0001-state-model/verify.md:76-78`. | 0001-conflict-model, 0002-conflict-detection | 0005-merge-conflict-workflow/0004-artifact-reconcile |
| 0005-merge-integrity-guards | Committed merge-integrity guards | Extend the committed suite (`tests/checks/`, fixture-based because the suite never reads `work/**` — `tests/README.md:29`) with agreement areas asserting merge integrity after a reconcile: no duplicate top-level or per-parent sequence prefixes, every roadmap `Depends on` resolves to an existing row and the stored graph is acyclic, no unlisted or dangling children, and the duplicated inventory/count facts stay consistent. Update `tests/README.md` to document the new area and extend `tests/mutation.sh` so each guard is proven to be caught and named. Must keep the existing areas (`tests/checks/40-inventory.sh`, `tests/checks/80-cycle-fixture.sh`) green rather than duplicating their agreements. Evidence: `tests/run.sh`, `tests/checks/40-inventory.sh`, `tests/checks/80-cycle-fixture.sh`, `tests/mutation.sh`, `tests/README.md:64-116`. | 0001-conflict-model, 0002-conflict-detection | 0005-merge-conflict-workflow/0005-merge-integrity-guards |

## Sequencing

1. 0001-conflict-model
2. 0002-conflict-detection
3. 0003-shared-surface-reconcile
4. 0004-artifact-reconcile
5. 0005-merge-integrity-guards

`0001-conflict-model` is the keystone: every other child consumes the taxonomy,
lifecycle placement, and resolution principles it fixes, so nothing else can be
specified until it lands. `0002-conflict-detection` then makes the taxonomy
observable and executable. `0003-shared-surface-reconcile` and
`0004-artifact-reconcile` both build on `0001` + `0002` and may proceed in
parallel once `0002` lands; they are placed `0003` before `0004` and should be
landed in that order because they extend the same `merge-conflict` skill and the
same `shipper`/`ship` surfaces, so parallel edits invite exactly the conflict this
initiative targets. `0005-merge-integrity-guards` also consumes `0001` + `0002`
and is sequenced last so it can cover the reconcile workflow and the merged tree
as `0003`/`0004` land.

## Open issues

- **No duplicate roadmap.** Recon of `work/` found two existing roadmaps
  (`0003-framework-quality-hardening`, `0004-adoption-template-split`) and two
  flat items (`0001`, `0002`); none covers merge-conflict handling. The only
  overlap is the documented "Renumbering after a parallel merge" contract, which
  child `0004-artifact-reconcile` extends rather than replaces.
- **Possible overlap with shipped surface work.** `0003-framework-quality-hardening`
  and `0004-adoption-template-split/0005-surface-consistency-sweep` edit the same
  `README.md`/`AGENTS.md`/`docs/*.md` shared surfaces this workflow reconciles.
  The child that touches them must keep the shipped inventory/signature guards
  green rather than forking their agreements.
- **Unresolved user decision — merge strategy.** Whether reconciliation uses a
  merge forward (append and preserve, no force-push) or permits rebasing is a
  genuine policy fork that child `0001-conflict-model` must resolve with the user;
  a rebase policy would collide with the shipper's "never force-push / never amend
  pushed commits" guardrails (`.opencode/agent/shipper.md:149-155`). The roadmap
  does not decide it.
- **Unresolved user decision — resolution authority.** Whether a semantic conflict
  may be auto-resolved by the agent or must be escalated for explicit user
  approval belongs to child `0001-conflict-model`. It materially changes `0003`
  and `0004`.
- **Unresolved user decision — invocation surface.** Whether reconcile is a new
  `/reconcile` command or a step inside `/ship` is a design fork owned by child
  `0001-conflict-model`; it changes the command/inventory surface and therefore
  `tests/checks/40-inventory.sh`.
- **Deliberately out of scope — conflict reduction.** Structurally de-duplicating
  the shared framework surfaces so parallel children stop colliding (for example
  single-sourcing the duplicated inventory/count facts) is a plausible follow-up
  but not part of this initiative, which the user framed as a workflow. Recorded
  here so the omission is explicit rather than silent scope.
- **Suite read-only constraint.** Any `0005-merge-integrity-guards` check must not
  read live `work/**` (`tests/README.md:29`), so its roadmap-integrity assertions
  must run against `tests/fixtures/` or a temporary copy; the child's spec must
  honor this.
- **Cycle check.** The stored `Depends on` graph is acyclic by construction
  (`0001` → `0002` → {`0003`, `0004`, `0005`}); no `CYCLIC-DEP` is expected.
  Recorded because the roadmap agent never stores a cycle.
- **Single-feature check.** The initiative is genuinely multi-feature — it spans a
  documented contract plus a skill, a detection capability, two distinct reconcile
  surfaces, and committed guards — so a roadmap is the right vehicle rather than a
  standalone `/spec`.
