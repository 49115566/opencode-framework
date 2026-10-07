---
feature: 0005-merge-conflict-workflow/0004-artifact-reconcile
phase: review
status: final
created: 2026-10-07
updated: 2026-10-07
parent: 0005-merge-conflict-workflow
notes: "Supersedes the stale review.md that predated the 12:52 production revision. The prior request-changes [M1] (clean-merge routing skipped the work/ reconcile) is fixed at SKILL.md:170-182; [m1] (per-parent MMMM allocation) is fixed at SKILL.md:355-359; [m2] (shipper abort rule on the clean-merge path) is fixed at shipper.md:239-242. Remaining findings are Minor/Nit; verdict approve."
---

# Review — Reconcile workflow for `work/` artifacts and sequence numbers

## Verdict

**approve** — the prior request-changes' [M1] routing defect is genuinely fixed
(entering the `work/` reconcile is now keyed on the merge touching a `work/`
path, not only on a pre-flight finding), all fourteen acceptance criteria are
met, and the only surviving findings are wording/clarity minors that do not
break an acceptance criterion or the safety contract.

## Base and diff

- Base ref: `git merge-base HEAD origin/main` →
  `46a036800287c244e1cb42fe144f45d4e9e2772c`, equal to `git rev-parse HEAD
  origin/main main`. The item is uncommitted working-tree changes on `main`; the
  effective base is `HEAD` (`46a0368`).
- Commands used (read-only): `git status`, `git status --porcelain`,
  `git merge-base HEAD origin/main`, `git rev-parse HEAD origin/main main`,
  `git log --oneline`, `git diff HEAD`, `git diff HEAD --stat`,
  `git diff HEAD --numstat`,
  `git diff --stat -- docs/workflow.md docs/artifact-conventions.md README.md
  AGENTS.md template/AGENTS.md opencode.json tests`,
  `git diff --quiet -- docs/workflow.md docs/artifact-conventions.md README.md
  AGENTS.md template/AGENTS.md opencode.json tests`,
  `ls .opencode/command/*.md`, `ls .opencode/agent/*.md`,
  `ls -d .opencode/skill/*/`, `ls -l` on the item and sibling directories. The
  untracked item files were read with the file tools.
- Diff: exactly three tracked surfaces, +220/−40 (`git diff HEAD --numstat`):
  `.opencode/agent/shipper.md` (+41/−14), `.opencode/command/ship.md` (+16/−5),
  `.opencode/skill/merge-conflict/SKILL.md` (+163/−21). The item directory is
  untracked and accounted for separately. `git status --porcelain` shows no
  untracked file outside `work/`.
- Staleness note: the `review.md` present before this write (mtime 12:49) predated
  the production revision (12:52) and the item's final `verify-tests.sh` /
  `verify.md` (13:25/13:26). Its [M1] quote ("unless the pre-flight reported a
  class (b) finding") does not match the current `SKILL.md`, which adds the
  `touched no \`work/\` path` condition. It is superseded by this review.
- `git diff --quiet` for `docs/workflow.md`, `docs/artifact-conventions.md`,
  `README.md`, `AGENTS.md`, `template/AGENTS.md`, `opencode.json`, and `tests`
  returns no diff — none of those surfaces changed.

## Acceptance criteria

| Criterion | Status | Evidence |
| --------- | ------ | -------- |
| AC1 — ordered, agent-executable `work/` reconcile merges frontmatter / `Children` rows / `Depends on` cells, preserving both records | met | `SKILL.md:277-312` (subsection, placement, `preserve both branches' records`, `drop neither side`, `artifact frontmatter`, roadmap `Children` rows, `Depends on` cells); routed from `SKILL.md:189-199`; clean-merge entry `SKILL.md:174-182`; shipper `shipper.md:114-120,153-176`. |
| AC2 — merged `Children` table keeps both branches' rows; deps preserved without silent discard | met | `SKILL.md:296-312` (union of rows, identical row de-duplicated, union of dependencies, duplicated dependency collapsed, divergent same-row `Depends on` escalates). Probe 2 `verify-tests.sh:493-534`. |
| AC3 — graph re-check: each `Depends on` resolves to a row + child dir, graph acyclic; structural auto-repair, intent escalates | met | `SKILL.md:314-330` (resolves to an existing row and child directory, `acyclic`, `structural fault`, unambiguous repair, intent escalation). Probes 2/3/7 `verify-tests.sh:530-571,727-731`. |
| AC4 — detects equal top-level `NNNN`, per-parent `MMMM`, and a cross-branch-only collision, reporting canonical reference(s) | met | `SKILL.md:332-347` (`NNNN`, `MMMM`, `git ls-tree --name-only origin/<default>:work`, per-parent, `canonical reference(s)`, `never truncated`). Probes 1/7 `verify-tests.sh:420-447,671-685`. |
| AC5 — choose by approved/shipped → added-later-by-commit-time → slug order; allocate next, never reuse | met | `SKILL.md:349-361` (`not yet approved or shipped`, `ship.md`, `review.md` `approve`, `git log --diff-filter=A`, `slug order`, top-level and per-parent allocation, `never reuse`). Probes 1/5/7 `verify-tests.sh:448-464,598-616,687-695`. |
| AC6 — `git mv` + update every reference in the same change; no old reference remains | met | `SKILL.md:363-371` (directory name, `feature`, nested `parent`, `Children` `Local id`/`Canonical reference`, every `Depends on`, `ship.md`/PR/handoff, `prose`, `no reference to the old canonical reference remains`); shipper `shipper.md:233-238`. Probes 1/7. |
| AC7 — undecidable renumber escalates rather than guesses | met | `SKILL.md:373-378` (`both are already shipped`, `cannot be determined`, `unavailable`/`shallow clone`, `two different new numbers`, do not reassign arbitrarily); shipper `shipper.md:168-172`. |
| AC8 — intent fault/cycle/ambiguous dangling does not resolve silently; abort to a clean tree, report blocked reference(s) + decision, stay blocked | met | `SKILL.md:214-223,385-399` (conflicted merge → `git merge --abort`; clean-merge path → hold blocked, do not rewrite the auto-commit); shipper `shipper.md:168-172,239-242`. Probe 4 `verify-tests.sh:573-596`; Probe 3 `:536-558`. |
| AC9 — re-run `bash tests/run.sh` + item checks; green before committed/recorded/shipped; failing check is the blocker | met | `SKILL.md:206-208,248-249` (`bash tests/run.sh`, `the affected item's checks`, `green`, `a failing check is the blocker`, `the resolution is not accepted until it passes`). Wording caveat in [m1]. Suite not independently run — see "Not reviewed". |
| AC10 — record resolved `work/` paths and renumber(s) in `ship.md` `## Reconcile` and the PR | met | `SKILL.md:254-259,385-399`; `/ship` `ship.md:48-50`; PR template `pr-workflow/SKILL.md:49-54`; `docs/artifact-conventions.md:414-419`; shipper handoff `shipper.md:255-258`. |
| AC11 — up-to-date branch + no collision is a no-op: no renumber/move/error, no merge commit | met | `SKILL.md:161-165,380-383`; shipper `shipper.md:175-176`; `/ship` `ship.md:41-44`. Probe 6 `verify-tests.sh:618-643`. |
| AC12 — normative "Renumbering after a parallel merge" unchanged; no second rule | met | `git diff --quiet -- docs/artifact-conventions.md` → no diff; heading still at `artifact-conventions.md:445`; `SKILL.md:332-335` references it and states `never defines a second renumbering rule`. |
| AC13 — `bash tests/run.sh` passes, incl. inventory/lifecycle/permission/signature agreements | met (per `verify.md`; not independently executed) | `verify.md:17-21` records `TOTAL: 285 passed, 0 failed, 0 skipped`; no `tests/**` change; item suite re-derives the same harness strings (`30-permissions.sh:192`, `40-inventory.sh:34`, `96-signature-sweep.sh:276`). |
| AC14 — no new lifecycle/artifact-format/inventory/executable surface beyond the additive reconcile record | met | Counts re-derived: 12 commands / 14 agents / 11 skills; `docs/workflow.md` and `docs/artifact-conventions.md` byte-identical; no untracked file outside `work/`; shipper permission frontmatter unchanged (first diff hunk at `shipper.md:112`); `verify-tests.sh` is non-executable, matching the `0001`–`0003` precedent. |

## Findings

### Blockers

- None.

### Major

- None. The prior review's [M1] is resolved: `SKILL.md:170-182` now enters the
  `work/` reconcile for any clean merge that "touched any `work/` path" or carries
  a pre-flight class (b)/(c) finding, with the `touched no \`work/\` path`
  short-circuit, and sub-step 1.6 routes class (b)/(c) into the subsection
  (`SKILL.md:189-199`). The shipper (`shipper.md:164-167`) and `/ship`
  (`ship.md:41-44`) carry the matching rule. The concrete dangling-after-merge
  case the old [M1] described (default branch renames a child; the item's table
  row keeps the old `Depends on`; distinct hunks merge cleanly) now reaches the
  merged-tree re-scan.

### Minor

- **[m1] The re-verify gate drops the spec/design's explicit "committed" term** —
  `.opencode/skill/merge-conflict/SKILL.md:206-208` and `:248-249`.
  Spec AC9 and design step 8 require the suite and item checks to be green
  "before the resolved merge is **committed**, recorded, or shipped". The
  revision removed "committed" (the pre-revision text had it, per the diff) in
  both places, leaving "before the merge is recorded or shipped". The substantive
  guarantee largely survives because `SKILL.md:208` adds "the resolution is not
  accepted until it passes", but the explicit commit gate the contract names is
  gone, and the item's own AC9 assertion was narrowed to
  `before the merge is recorded or shipped` (`verify-tests.sh:193`), so the suite
  can no longer catch the deviation from the design's stated check. Recommended
  fix: restore an explicit commit gate, qualified for the auto-committed merge
  path — e.g. "green before the resolution is committed, recorded, or shipped;
  for a clean merge whose merge commit already exists, the merge commit itself is
  not rewritten, but the reconcile repairs must not be committed until green".

- **[m2] The Re-verify sub-step conflates the clean-merge escalation nuance with
  the normal reconcile path** — `.opencode/skill/merge-conflict/SKILL.md:209-212`.
  The sentence "When the merge auto-committed cleanly (sub-step 1.4) … do not
  rewrite an already-created merge commit … — hold the ship `blocked` instead"
  sits in the ordinary Re-verify step. But a class (c) duplicate sequence number
  is precisely a clean-merge case (`SKILL.md:177-180`), and the reconcile is
  required to complete it and commit the repairs as follow-up work — not to hold
  the ship. The same nuance is already correctly scoped to *escalation* at
  `SKILL.md:217-221`, `shipper.md:239-242`, and `ship.md:44-47`. A reader that
  takes the Re-verify sentence literally could hold the ship blocked on a
  successful clean-path renumber. Recommended fix: move the sentence into the
  escalation text (sub-step 1.9) or add the condition "only when a resolution
  would require rewriting the merge commit", and state that a clean-path repair
  is committed as a follow-up commit.

### Nits

- **[n1] Placement and labeling drift** — `.opencode/skill/merge-conflict/SKILL.md:277`.
  The subsection sits after the entire `## Procedure` (which ends at `:275`),
  whereas the design places it "within `## Procedure` step 1's resolve sequence"
  (`design.md:44-49`) / "after the `## Procedure` step-1 sequence"
  (`design.md:230-233`). The `## Rules` first bullet still says "the reconcile
  steps below resolve" (`SKILL.md:403-405`) even though the steps now precede
  the rules, and the subsection says it runs "after the conflict set is listed
  (sub-step 1.5)" (`:280`) although sub-step 1.5 is skipped on the clean-merge
  path it also serves. It is harmless because the resolve sub-step references the
  subsection by number, but a single labeling scheme (and correcting "below")
  would read better. Take it or leave it.

- **[n2] Parallel structure in the clean-merge sentence** — `.opencode/skill/merge-conflict/SKILL.md:170-173`.
  "A merge that completes with no conflict markers, touched no \`work/\` path,
  and carries no …" mixes tenses/clauses; "that touched no \`work/\` path" reads
  more cleanly. Cosmetic.

## Not reviewed

- **Independent execution of the suites.** This sandbox permits only read-only
  `git` commands and `ls`; `bash` is denied, so I could not run
  `bash tests/run.sh` or
  `bash work/0005-merge-conflict-workflow/0004-artifact-reconcile/verify-tests.sh`.
  AC13 is assessed from `verify.md` plus static re-derivation (no `tests/**`
  change; counts 12/14/11; the harness strings the item suite greps for exist at
  the cited lines). A reviewer with shell access should run both.
- **Runtime agent behavior.** The deliverable is prompt/config/document content;
  the live probes exercise the documented git forms in scratch repos but do not
  exercise the skill's own routing under the real permission matcher. The
  routing fix is covered only by literal-presence assertions
  (`verify-tests.sh:79-88`), so a regression in routing wording, not behavior,
  is what the item suite can catch.
- **Sibling historical item suites.** `0001`–`0003` `verify-tests.sh` assert
  surfaces this child intentionally edits (e.g. the removed sibling-`0004`
  deferral); `verify.md:115-120` records that expected drift, and the canonical
  gate remains `bash tests/run.sh`.
- **UI/visual.** Not applicable; no `/visual` pass exists for this item
  (prompt/config/document work).
