---
feature: 0005-merge-conflict-workflow/0004-artifact-reconcile
phase: tasks
status: final
created: 2026-10-07
updated: 2026-10-07
notes: "T5 done 2026-10-07: acceptance gate green (bash tests/run.sh 285 passed, 0 failed, 0 skipped; docs/workflow.md and docs/artifact-conventions.md byte-identical; counts 12 commands / 14 agents / 11 skills; git status only the three .opencode surfaces and this item's directory). T4 done 2026-10-07. Prompt/config/doc only. T1 adds the `work/` content-merge + graph re-check half of the merge-conflict skill subsection and replaces the sibling 0004 deferral; T2 adds the sequence-collision detect/choose/renumber/reference-sweep half; T3 wires the shipper (no permission change); T4 wires /ship; T5 is the item-level acceptance gate. AC map: AC1 T1,T3; AC2 T1; AC3 T1; AC4 T2; AC5 T2; AC6 T2,T3; AC7 T2,T3; AC8 T2,T3; AC9 T1; AC10 T1,T3,T4; AC11 T2,T3,T4; AC12 T2,T5; AC13 T5; AC14 T3,T5. No task touches docs/workflow.md, docs/artifact-conventions.md, pr-workflow, README.md, AGENTS.md, tests/**, the shipper permission frontmatter, an inventory count, or a command signature."
parent: 0005-merge-conflict-workflow
---

# Tasks — Reconcile workflow for `work/` artifacts and sequence numbers

Ordered, dependency-aware. One task ≈ one focused commit. Every task edits prose or
agent-instruction content only: no task adds a command, agent, skill, artifact
format, committed check, or executable script, changes a permission, a command
signature, a phase heading, an inventory count, or `docs/workflow.md` /
`docs/artifact-conventions.md`.

- [x] **T1** — In `.opencode/skill/merge-conflict/SKILL.md`, add the
      ``### `work/` artifact reconcile`` subsection (after the `## Procedure` step-1
      sequence) and rewire the generic steps to reference it. Write its placement
      and content-merge + graph half: it runs `after the conflict set is listed`
      and `before the re-verification`; it consumes the pre-flight findings
      (`DUPLICATE-PREFIX`, `DUPLICATE-CHILD`, `DANGLING-DEP`, `MISSING-CHILD`,
      `UNLISTED-CHILD`, `CYCLIC-DEP`) and, because the pre-flight ran before the merge,
      `re-scan the merged tree`. Merge colliding `work/` artifact content
      preserving both branches' records and `drop neither side`: union roadmap
      `Children` rows and `Depends on` cells, never silently discard a branch's
      dependency, de-duplicate an identical row, and route a differing scalar
      frontmatter field or a differing duplicate row to the `judgment about intent`
      escalation. Re-check every roadmap graph: each `Depends on` local id
      `resolves to an existing row and child directory` and the stored graph is
      `acyclic`; auto-repair a `structural fault` (a value left stale by this
      reconcile's renumber sweep, an identical duplicate row, a duplicated
      dependency) and escalate a `judgment about intent` (ambiguous dangling
      target, `cycle`, `deliberately removed child`, `unlisted child` needing
      title/scope). Replace the sibling `0004` deferral. Wire the generic resolve
      sub-step 6 to invoke this subsection and step 8/step 5 to re-verify and record
      (renumber as a `Resolved paths` entry `<old> → <new>` in the existing
      `## Reconcile` record; phrase it `Renumbering after a parallel merge` /
      `never defines a second renumbering rule`). Keep the pre-flight and the
      generic resolve/re-verify/record/post-merge/escalate steps in substance.
      [AC1] [AC2] [AC3] [AC9] [AC10]
      Verify: `grep -nF 'artifact reconcile' .opencode/skill/merge-conflict/SKILL.md`; then `grep -nE 'preserve both branches|drop neither side|artifact frontmatter|Children|Depends on|never silently discard|resolves to an existing row and child directory|acyclic|structural fault|judgment about intent|bash tests/run.sh|## Reconcile|<old> → <new>|Renumbering after a parallel merge' .opencode/skill/merge-conflict/SKILL.md` shows every literal; `grep -nF 'remain sibling' .opencode/skill/merge-conflict/SKILL.md` returns nothing; `bash tests/run.sh` exits 0.

- [x] **T2** — In `.opencode/skill/merge-conflict/SKILL.md`, add the
      sequence-prefix half of the same subsection: detect equal top-level 4-digit
      `NNNN` prefixes and equal per-parent `MMMM` prefixes across the merged tree,
      including a collision between the item branch and the default branch via
      `git ls-tree --name-only origin/<default>:work` (and per-parent), reporting
      each with its `canonical reference(s)` and `never truncated`; choose the item
      to renumber by the existing rule — `not yet approved or shipped` (shipped =
      `ship.md` presence, approved = `review.md` verdict `approve`), then
      `added later by commit time` via `git log --diff-filter=A`, then `slug order`; allocate
      the `next number` from the allocation contract and `never reuse` a spent
      number. Move it with `git mv work/<old> work/<new>` and rewrite every
      reference `in the same change` — `feature` frontmatter, a nested child's
      `parent`, the `Children` `Local id` and `Canonical reference` cells, every
      `Depends on` cell naming the old local id, `ship.md` and PR/handoff paths,
      and any `prose` — asserting `no reference to the old canonical reference remains`.
      Escalate rather than guess when the choice is undecidable
      (`both are already shipped`, state `cannot be determined`, history
      `unavailable` / `shallow clone`, `two different new numbers`): `git merge --abort`,
      report the blocked reference(s) and the decision, and stay
      `blocked until the user responds`. State the no-op: no collision and no graph fault →
      `no conflicts`, `no renumber`, `no move`, `does not error`. Add the record
      instruction: the renumber is written as a `Resolved paths` entry in the
      `## Reconcile` record of `ship.md` and the `pull-request`. [AC4] [AC5] [AC6]
      [AC7] [AC8] [AC11] [AC12] [depends: T1]
      Verify: `grep -nE 'NNNN|MMMM|git ls-tree --name-only origin/<default>:work|not yet approved or shipped|git log --diff-filter=A|slug order|git mv work/<old> work/<new>|Local id|Canonical reference|no reference to the old canonical reference remains|in the same change|never reuse|both are already shipped|shallow clone|two different new numbers|no renumber|no move|does not error|never defines a second renumbering rule' .opencode/skill/merge-conflict/SKILL.md` shows every literal; `bash tests/run.sh` exits 0.

- [x] **T3** — Wire the `work/` reconcile into `.opencode/agent/shipper.md` **without
      changing its permission frontmatter**. In `<preconditions>` (work-item mode)
      extend the reconcile clause so a `work/` sequence collision or roadmap graph
      fault is resolved or escalated, not shipped unresolved. In `<process>` step 2
      expand the class (c) sentence to run the `work/` artifact reconcile per the
      `merge-conflict` skill: merge `work/` content preserving both records,
      re-check the roadmap graph, detect top-level/per-parent/cross-branch
      collisions, choose and `git mv` per the existing rule, rewrite every reference
      in one change, and escalate an undecidable renumber or intent fault by
      aborting. In `<rules>` add the reference-sweep authority, `never reuse` a
      spent number, and never resolve a cycle or undecidable renumber. Extend the
      `<handoff>` `Reconciled:` line to report any renumbered reference (work-item
      mode only). Change no frontmatter permission pattern and no guardrail.
      [AC1] [AC6] [AC7] [AC8] [AC10] [AC11] [AC14] [depends: T1, T2]
      Verify: `grep -nE 'never reuse|renumber|abort|Reconciled:' .opencode/agent/shipper.md` shows the new body literals; `git diff -- .opencode/agent/shipper.md | grep -E '^[+-]' | grep -vE '^(\+\+\+|---)' | grep -E '"\*"|"git |"work/\*\*"|"bash '` returns nothing (no permission frontmatter line added or removed); `bash tests/run.sh` exits 0 with `30-permissions.sh` reporting the shipper `edit=tests+work bash=git-gh`.

- [x] **T4** — Expand the work-item reconcile bullet in `.opencode/command/ship.md`
      with the `work/`-specific mechanics: merge `work/` artifact content preserving
      both sides, re-check the roadmap graph, apply the existing "Renumbering after
      a parallel merge" rule to a top-level/per-parent `NNNN`/`MMMM` collision,
      update every reference in one change, escalate an undecidable renumber or
      intent fault, and record the result in the `## Reconcile` section of `ship.md`
      and the PR. Change no signature, usage string, phase heading, or the closing
      never-merge / never-force-push guardrail. [AC10] [AC11] [depends: T3]
      Verify: `grep -nE 'every reference in one change|undecidable|top-level/per-parent|## Reconcile' .opencode/command/ship.md` shows the new bullet literals; `grep -n 'Usage: /ship \[item-ref\]' .opencode/command/ship.md` is unchanged; `bash tests/run.sh` exits 0 (`96-signature-sweep.sh` green).

- [x] **T5** — Run the item-level acceptance gate: `bash tests/run.sh` must exit 0
      with no `FAIL` lines, including `tests/checks/30-permissions.sh` (shipper
      `edit=tests+work bash=git-gh`) and `tests/checks/40-inventory.sh`; the
      inventory is unchanged at 12 commands / 14 agents / 11 skills with no new
      file; `docs/workflow.md` is byte-identical; the
      `### Renumbering after a parallel merge` section of
      `docs/artifact-conventions.md` is byte-identical; every artifact template
      heading is retained; the six lifecycle phases are retained and no seventh
      exists; no executable file is added outside `work/`; and `git status --porcelain`
      touches only
      `.opencode/skill/merge-conflict/SKILL.md`, `.opencode/agent/shipper.md`,
      `.opencode/command/ship.md`, and
      `work/0005-merge-conflict-workflow/0004-artifact-reconcile/`. [AC12] [AC13]
      [AC14] [depends: T1, T2, T3, T4]
      Verify: `bash tests/run.sh`; `git diff --quiet -- docs/workflow.md` and `git diff --quiet -- docs/artifact-conventions.md` (both byte-identical, so the renumbering section is unchanged); `ls .opencode/command/*.md | wc -l` is 12, `ls .opencode/agent/*.md | wc -l` is 14, `ls -d .opencode/skill/*/ | wc -l` is 11; `git status --porcelain` matches the allowed surface list.
