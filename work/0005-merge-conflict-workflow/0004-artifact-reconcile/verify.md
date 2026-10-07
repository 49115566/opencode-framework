---
feature: 0005-merge-conflict-workflow/0004-artifact-reconcile
phase: test
status: final
created: 2026-10-07
updated: 2026-10-07
parent: 0005-merge-conflict-workflow
notes: "No committed check added (sibling 0005 owns merge-integrity guards). Evidence is the item-level read-only work/0005-merge-conflict-workflow/0004-artifact-reconcile/verify-tests.sh (177 assertions: content over the skill/shipper//ship/PR/artifact-conventions surfaces plus seven live probes in scratch git repos) plus the canonical bash tests/run.sh. docs/workflow.md and docs/artifact-conventions.md are byte-identical to HEAD; the shipper permission frontmatter is unchanged. Re-verified the revision that addresses the prior review's [M1] (clean-merge routing keyed on a touched work/ path), [m1] (per-parent MMMM allocation), and [m2] (clean-merge escalation does not attempt a nonexistent abort). Added Probe7 for the per-parent MMMM collision / child-renumber reference sweep gap."
---

# Verification — Reconcile workflow for `work/` artifacts and sequence numbers

## Commands run

| Command | Result | Notes |
| ------- | ------ | ----- |
| `bash tests/run.sh` | PASS | `TOTAL: 285 passed, 0 failed, 0 skipped`, exit 0; run at baseline and again after adding this item's tests. Read-only, never reads `work/**`. |
| `bash work/0005-merge-conflict-workflow/0004-artifact-reconcile/verify-tests.sh` | PASS | `TOTAL: 177 passed, 0 failed`, exit 0. Content assertions AC1–AC14 + edge cases + seven live git probes. (169 before this pass added Probe7.) |
| `git diff --quiet -- docs/workflow.md` | PASS | byte-identical to HEAD (AC14). |
| `git diff --quiet -- docs/artifact-conventions.md` | PASS | byte-identical to HEAD (AC12; the normative "Renumbering after a parallel merge" text is unchanged). |
| `ls .opencode/command/*.md \| wc -l`; `ls .opencode/agent/*.md \| wc -l`; `ls -d .opencode/skill/*/ \| wc -l` | PASS | 12 / 14 / 11 — unchanged inventory (AC13, AC14). |
| `git status --porcelain` | PASS | only `.opencode/agent/shipper.md`, `.opencode/command/ship.md`, `.opencode/skill/merge-conflict/SKILL.md`, and this item's directory (AC14). |

The deliverable is prompt/config/document content, so the automatic level is
content assertions over the delivered surfaces plus live probes that execute the
documented git forms in disposable scratch repos. The probes are deterministic
(fixed commit dates, unique `mktemp` directories) and clean up after themselves;
no test sleeps or depends on ordering.

### Tests added this pass

- **Probe 7** in `verify-tests.sh` closes the per-parent/child gap: a
  cross-branch `MMMM` collision (`0002-b` on the item branch vs `0002-c` on the
  default branch), the per-parent allocation from the parent's own history
  (`0004` → `0005`), then the child `git mv` and reference sweep — updating the
  moved child's `feature` frontmatter, the roadmap `Children` row's `Local id`
  and `Canonical reference` cells, and a dependent child's `Depends on` cell —
  asserting no old child reference remains, no duplicate parent prefix remains,
  and the graph re-check is clean. (AC4 per-parent, AC5 per-parent allocation,
  AC6 child-reference sweep, AC3 re-check.)

## Acceptance coverage

| Criterion | Test(s) | Result |
| --------- | ------- | ------ |
| AC1 — ordered, agent-executable `work/` reconcile merges frontmatter/`Children`/`Depends on`, preserving both records | `verify-tests.sh` AC1 (subsection heading, run-after/before placement, `preserve both branches' records`, `drop neither side`, `artifact frontmatter`, `Roadmap Children rows`, `Depends on cells`, resolve sub-step wiring, clean-merge routing keyed on a touched `work/` path, shipper preconditions, sibling-0004 deferral removed) | PASS |
| AC2 — merged `Children` table contains both branches' rows; each `Depends on` preserved/reconciled | AC2 content (`union of both branches' rows`, `de-duplicated to one`, `never silently discard a branch's dependency`, union of dependencies, collapse, divergent same-row escalation) + Probe2 (union keeps `0002-b` and `0003-c` rows and the shared `0001-a` dependency) + Probe1 (post-merge no duplicate prefix) | PASS |
| AC3 — graph re-check: every `Depends on` resolves to a row and child dir, graph acyclic; structural auto-repair, intent escalates | AC3 content (`resolves to an existing row and child directory`, `acyclic`, `structural fault`, `unambiguous structural repair`, `DANGLING-DEP`/`CYCLIC-DEP`/`MISSING-CHILD`/`UNLISTED-CHILD`, `deliberately removed child`) + Probe2 (clean union passes) + Probe3 (stale dep detected; sweep repair resolves; ambiguous dep stays unresolved; cycle detected) + Probe7 (graph clean after a child renumber sweep) | PASS |
| AC4 — detects equal top-level `NNNN` and per-parent `MMMM`, including a cross-branch-only collision, reporting canonical reference(s) | AC4 content (`NNNN`, `MMMM`, `git ls-tree --name-only origin/<default>:work`, per-parent `git ls-tree ...:work/<parent>`, `canonical reference(s)`, `never truncated`, `top-level`) + Probe1 (cross-branch top-level collision before merge; duplicate `0005` after merge) + Probe7 (cross-branch per-parent `0002` collision) | PASS |
| AC5 — choose by the existing rule (not approved/shipped → added later by commit time → slug order); allocate next number, never reuse | AC5 content (choice literals, `git log --diff-filter=A`, `slug order`, `next number`, `never reuse`, top-level and per-parent allocation) + Probe1 (commit-time picks beta; allocates `0006`) + Probe5 (deleted `0006` is spent → next `0007`) + Probe7 (per-parent allocation from parent history → `0005`; no duplicate prefix remains) | PASS |
| AC6 — move with `git mv` and update every reference in the same change; no old reference remains | AC6 content on skill and shipper (`git mv work/<old> work/<new>`, `in the same change`, `feature` frontmatter, nested `parent`, `Local id`, `Canonical reference`, every `Depends on`, `PR/handoff`, `prose`, `no reference to the old canonical reference remains`) + Probe1 (top-level `git mv` + sweep; `feature:` updated; no `0005-beta` remains) + Probe7 (child renumber: `feature`, `Children` `Local id`/`Canonical reference`, dependent `Depends on`; no `0002-c` remains) | PASS |
| AC7 — undecidable renumber escalates rather than guessing | AC7 content (`both are already shipped`, `cannot be determined`, `shallow clone`, `unavailable`, `two different new numbers`, `do not reassign a number arbitrarily`; shipper `undecidable renumber`) | PASS (content; see residual risk) |
| AC8 — intent fault/cycle/dangling/removed-child does not resolve silently; abort to a clean tree, report blocked reference(s) + decision, stay blocked | AC8 content (`git merge --abort`, `blocked reference(s)`, `decision the user must make`, `blocked until the user responds`, clean-merge path has no in-progress merge; shipper abort/escalate nuance) + Probe4 (abort restores a clean tree with no `MERGE_HEAD`) + Probe3 (ambiguous dangling dep not repaired) | PASS |
| AC9 — re-run `bash tests/run.sh` + affected item's checks; green before commit/record/ship; failing check is the blocker | AC9 content on skill and shipper (`bash tests/run.sh`, item checks, `green`, `before the merge is recorded or shipped`, `a failing check is the blocker`, auto-committed merge not rewritten) + integration: `bash tests/run.sh` → PASS | PASS |
| AC10 — record resolved `work/` paths and renumber(s) in `ship.md` `## Reconcile` and the PR | AC10 content (skill: `` `## Reconcile` ``, `Resolved paths`, `<old> → <new>`, `pull-request`; `docs/artifact-conventions.md` `## Reconcile`/`Resolved paths`; `pr-workflow` `## Reconcile`/`Resolved paths`; shipper handoff `<old> → <new>`) | PASS |
| AC11 — up-to-date branch and no collision is a no-op: no renumber/move, no error, no merge commit | AC11 content (`no conflicts`, `no renumber`, `no move`, `does not error`, `no merge commit`; shipper + `/ship` wiring) + Probe6 (up-to-date merge-forward creates no commit, rc 0; empty `work/` tree reports no collision) | PASS |
| AC12 — normative "Renumbering after a parallel merge" unchanged; no second rule | AC12 content (`Renumbering after a parallel merge`, `never defines a second renumbering rule`, section heading) + `git diff --quiet -- docs/artifact-conventions.md` → unchanged | PASS |
| AC13 — `bash tests/run.sh` passes incl. inventory, lifecycle, permission, signature agreements; no new command/agent/skill/committed check | `bash tests/run.sh` → `285 passed, 0 failed`; asserts `30-permissions.sh` shipper `edit=tests+work bash=git-gh`, `40-inventory.sh` counts, and `96-signature-sweep.sh` `/ship` signature | PASS |
| AC14 — no new lifecycle/artifact-format/inventory surface beyond the additive reconcile record; no new executable | AC14 content: counts 12 commands / 14 agents / 11 skills; `docs/workflow.md` byte-identical; all seven artifact templates retained; six phases retained, no seventh; shipper permission frontmatter byte-identical to HEAD; no new command/agent/skill file; no new file outside `work/`; production change set is exactly the three design-named surfaces | PASS |

### Edge-case coverage

| Edge case | Test(s) | Result |
| --------- | ------- | ------ |
| Empty or placeholder-only `work/` tree | Probe6 (empty `work/` reports no prefix collision) + AC11 no-op | PASS |
| Same number, different slug | AC4 `under different slugs` + Probe1 (top-level) + Probe7 (per-parent) | PASS |
| Same canonical reference, differing content | AC2/AC3 `duplicate local id` intent-fault content | PASS (content) |
| Dangling `Depends on` after merge | Probe3 (detected; repaired only when unambiguous) | PASS |
| Cycle introduced by the merge | Probe3 (`CYCLIC-DEP` detected) + AC3 `cannot be mechanically broken` | PASS |
| Unlisted child | AC3 `UNLISTED-CHILD` + `title/scope/intent` escalation content | PASS (content) |
| Missing child | AC3 `MISSING-CHILD` + AC6 renumber reference update | PASS |
| Renumbered child is a dependency | Probe7 (dependent `Depends on` cell updated to the new local id; graph re-check clean) + AC6 `every Depends on` | PASS |
| All candidates shipped / undecidable order / two different new numbers | AC7 content | PASS (content) |
| Number already spent | AC5 `never reallocate a number whose directory was deleted` + Probe5 | PASS |
| Re-verification fails after a repair | AC9 `a failing check is the blocker` | PASS (content) |
| Large collision set | AC4/AC3 `never truncated`, `even for a large set` | PASS (content) |
| Concurrent ships on the same branch | Out of scope (spec: takes no lock, one shipper per branch) | N/A |
| Nothing to reconcile | Probe6 no-op | PASS |

## Gaps and residual risk

- **Agent-instruction behavior is not runtime-executable.** The deliverable is
  prose in the `merge-conflict` skill and the shipper/`/ship` wiring; the tests
  verify the required content is present and that the *documented* git forms
  behave as claimed in disposable repos. They cannot prove that a future agent
  will follow the procedure in every situation. This is inherent to a
  prompt-only deliverable and matches the `0002`/`0003` precedent.

- **AC7 and several edge cases are content-only.** "Undecidable renumber
  escalates", "both already shipped", "shallow clone", and the unlisted-child
  title/scope escalation are covered by literal-presence assertions, not a live
  probe, because constructing a genuine both-shipped collision only reproduces a
  state the instruction already names. Residual risk is low; a reviewer confirms
  the wording.

- **The live probes re-implement the documented steps by hand** (detection,
  `git mv`, reference sweep, graph check). They validate the commands and their
  outcomes, not the skill's autonomous judgment. The probes' graph checker and
  sweep are test scaffolding, not production code, and are not committed outside
  `work/`.

- **Prior review findings re-checked against the current revision.** The
  superseded `review.md` (verdict `request-changes`) predates the current
  working tree (production files and `verify-tests.sh` were last modified after
  it). Its [M1] is addressed by sub-step 1.4 routing any clean merge that touched
  a `work/` path into the reconcile (`SKILL.md:170-182`), and by the matching
  shipper/`/ship` text; [m1] is addressed by the explicit per-parent allocation
  (`SKILL.md:355-359`); [m2] is addressed by the clean-merge qualification in the
  shipper `<rules>` (`shipper.md:230-232,239-242`). Content assertions for all
  three are green. The remaining [n1] is a wording/placement nit (the subsection
  sits after `## Procedure` while sub-step 1.6 references it): it does not affect
  AC1's ordered, agent-executable requirement, since the resolve sub-step names
  the subsection by number.

- **Historical sibling suites are expected to drift.** `0003-shared-surface-reconcile`'s
  `verify-tests.sh` asserts the old `sibling 0004` deferral that this child
  deliberately replaces; its assertion would now fail if re-run. That is intended
  drift recorded by `0002`/`0003`; the canonical gate is `bash tests/run.sh`,
  which stays green. No committed check was weakened, skipped, or deleted to
  obtain a pass.

- **No committed merge-integrity guard was added.** By non-goal, committed guards
  and mutation coverage belong to sibling `0005-merge-integrity-guards`. The
  evidence for this item therefore lives only in its `work/` directory, consistent
  with AC13/AC14.
