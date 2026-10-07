---
feature: 0005-merge-conflict-workflow/0003-shared-surface-reconcile
phase: review
status: final
created: 2026-10-07
updated: 2026-10-07
parent: 0005-merge-conflict-workflow
---

# Review — Reconcile workflow for shared framework surfaces

## Verdict

**approve** — the reconcile is now executable end to end: the ordered
merge-forward procedure, the shipper's scoped git/edit grants (including the
`git mv` and `bash tests/run.sh` / item-check grants that the previous pass
blocked on), the `/ship` wiring, and the `## Reconcile` record are all present
and mutually consistent; the only surviving findings are documentation-coherence
minors and nits.

## Base and diff

- Base ref: `git merge-base HEAD origin/main` → `da3f64e971270404269446e8fcd808fcc6947971`,
  equal to both `git rev-parse HEAD` and `git rev-parse origin/main`. The item is
  being reviewed as uncommitted working-tree changes on `main`, so the effective
  base is `HEAD` (`da3f64e`).
- Commands used: `git status`, `git status --porcelain`,
  `git merge-base HEAD origin/main`, `git rev-parse HEAD origin/main`,
  `git diff`, `git diff --stat`, `git status --porcelain -- <surface>`.
  Untracked item files (`spec.md`, `design.md`, `tasks.md`, `verify.md`,
  `verify-tests.sh`) were read directly with the file tools.
- Diff: 6 tracked surfaces, +151/−24 —
  `.opencode/agent/shipper.md` (+70), `.opencode/command/ship.md` (+8),
  `.opencode/skill/merge-conflict/SKILL.md` (+81),
  `.opencode/skill/pr-workflow/SKILL.md` (+7), `README.md` (+2/−1),
  `docs/artifact-conventions.md` (+7). The item directory is untracked and
  accounted for separately. No tracked file outside the six surfaces changed;
  `docs/workflow.md` is unchanged.

## Acceptance criteria

| Criterion | Status | Evidence |
| --------- | ------ | -------- |
| AC1 — ordered, agent-executable merge-forward procedure; never rebase/force-push | met | `SKILL.md:145-206`: determine default branch + merge base → `git fetch <remote> <default>` → mid-merge guard → up-to-date no-op → `git merge --no-edit origin/<default>` → `git diff --name-only --diff-filter=U` → resolve → marker assert → re-verify → `git merge --abort`; `never rebase`/`never force-push` at `:169-170`. Shipper process mirrors it at `shipper.md:149-161`. |
| AC2 — bash allowlist grants fetch/merge/inspect/abort; rebase impermissible, force-push ask, PR-merge forbidden | met | `shipper.md:25-52`: `"git merge*": allow` (`:39`), fetch/status/diff/merge-base/rev-parse/symbolic-ref allowed, `"git mv*": allow` (`:42`), `"git push*": ask` (`:52`), no `git rebase`, no `gh pr merge`. Effective resolution (last-match-wins after `"*": deny` at `:26`) is asserted by the item suite `verify-tests.sh:574-590`. |
| AC3 — shipper may edit class (a) shared surfaces plus `work/**`; README row and permission check agree | met | `shipper.md:9-24` declares all 18 patterns in both path forms; `README.md:218` names `work/**` + shared surfaces incl. `tests/checks`; `30-permissions.sh:44-57` derives declared `tests+work` and `readme_edit_class:143-149` derives documented `tests+work`; bash cell stays `git/gh`→`git-gh`. |
| AC4 — resolve shared-surface conflict preserving both sides, no markers remain | met | `SKILL.md:179-193`: `preserve **both** branches'`, `drop neither side`, class (a)/(b), marker literals + `unresolved`; live probe `verify-tests.sh:172-216`. |
| AC5 — mechanical/structural auto-resolve subject to re-verification | met | `SKILL.md:184-188` (`Auto-resolve only mechanical or structural`, `does not require choosing between competing intents`, `subject to sub-step 8`). |
| AC6 — re-run committed suite + item checks; green before commit/record/ship | met | Content at `SKILL.md:195-199` and `shipper.md:156-157`; the shipper now grants `"bash tests/run.sh*"`, `"bash work/*/verify-tests.sh*"`, `"bash work/*/*/verify-tests.sh*"` (`shipper.md:49-51`) and the item suite resolves each to `allow` (`verify-tests.sh:583-585`). |
| AC7 — semantic conflict aborts to clean tree and escalates; ship stays blocked | met | `SKILL.md:201-206` (`git merge --abort`, `clean working tree`, `blocked path(s)`, `blocked until the user responds`, abort-failure path); `shipper.md:158-160`; live abort probe `verify-tests.sh:256-290`. |
| AC8 — `work/` conflicts preserve both records; class (c) defers to renumbering rule | met | `SKILL.md:179-188`: class (b) records from both, class (c) → `Renumbering after a parallel merge` with `git mv`, sibling `0004` boundary; `git mv` now permitted (`shipper.md:42`) and effectively resolved to allow (`verify-tests.sh:581`). |
| AC9 — reconcile recorded in `ship.md` and the PR description | met | `docs/artifact-conventions.md:414-419` and `pr-workflow/SKILL.md:49-54` both carry `## Reconcile`, `Resolved paths`, `Re-verification`; fix PR template unchanged (`pr-workflow:78-103`). |
| AC10 — the `ship.md` template documents the reconcile record | met | `docs/artifact-conventions.md:414-419`, inside the `### «ship.md»` fenced template (closing fence at `:420`), with the `Result:` vocabulary and `Re-verification:` line. |
| AC11 — reconcile after pre-flight, before other operations; guardrails retained | met | Shipper ordering pre-flight (`shipper.md:140`) < reconcile (`:149`) < branch creation (`:163`); `/ship` ordering pre-flight (`ship.md:25`) < reconcile (`:32`) < default branch (`:40`); `Never merge a PR` (`shipper.md:216`), `Never force-push` (`:206`), `/ship` closing guardrail (`ship.md:79`), `Reconciled:` handoff (`shipper.md:230-231`). |
| AC12 — already-up-to-date is a no-op, no merge commit | met | `SKILL.md:161-165`; `shipper.md:160-161`; live probe `verify-tests.sh:392-422`. |
| AC13 — `bash tests/run.sh` passes incl. permission + inventory agreements | met (per `verify.md`; not independently executed — see Not reviewed) | `verify.md:63,89` records `285 passed, 0 failed, 0 skipped`; static re-derivation of `30-permissions.sh` (shipper `tests+work`/`git-gh`) and `40-inventory.sh` (12/14/11) agrees. |
| AC14 — no lifecycle/format/inventory change beyond the `ship.md` record | met | Diff limited to the six design-named surfaces; `docs/workflow.md` unmodified; counts 12 commands / 14 agents / 11 skills (verified by `ls`); no new command/agent/skill; every artifact template heading retained. |

## Findings

### Blockers

None.

### Major

None. The two findings from the previous pass are resolved: the class (c)
mechanism `git mv` is now granted (`shipper.md:42`) and `bash tests/run.sh` /
item checks are now granted (`shipper.md:49-51`), and the updated item suite
resolves each command's effective permission rather than only asserting literal
pattern presence (`verify-tests.sh:526-601`).

### Minor

- **[m1] The rewritten skill duplicates the resolve/re-verify/escalate rules and its cross-references are ambiguous** — `.opencode/skill/merge-conflict/SKILL.md:149-206` vs `:208-257`
  The nested nine-sub-step sequence embeds resolve, marker, re-verify, and
  escalate rules that outer steps 3, 4, and 7 restate. Sub-step 8 says "the
  affected item's checks (step 4)" and sub-step 9 says "(step 7)" — references
  that read as the nested sub-steps but intend the outer steps. Two copies of the
  same rules will drift, and a reader following "step 4" can land on the wrong
  one. Recommendation: keep the executable detail in one place and reference the
  other, e.g. "outer step 4" / "outer step 7", or fold the outer restatements
  into the sequence.

- **[m2] The reconcile precondition is only satisfiable after the reconcile runs** — `.opencode/agent/shipper.md:114-116`, `:149-162`
  `<preconditions>` now requires "The branch has been reconciled with the default
  branch per the `merge-conflict` skill, or an up-to-date no-op was reported",
  and the block opens "Do not proceed unless all hold." But the reconcile is
  process step 2 and the preconditions are verified at process step 3, so the
  condition cannot hold when the precondition block is read. The ordering is
  factually consistent (step 2 establishes it before step 3 checks it) but the
  precondition reads as a gate that precedes its own establishing step.
  Recommendation: phrase it as the outcome of step 2 ("After step 2, the branch
  has been reconciled…"), or move the precondition verification ahead of the
  reconcile.

### Nits

- **[n1] README bash cell deviates from the design/tasks wording** — `README.md:218`
  `design.md:125-127` and task T2 said the shipper's "Can run bash" cell "stays
  `git/gh allowlist`"; it was changed to ``git/gh allowlist + `bash tests/run.sh`
  / item checks``. It still derives `git-gh` and is arguably more accurate now
  that the grant exists, but it is an undocumented deviation from the design
  contract. Take it or leave it; if kept, note it in the design's "Affected
  areas" rather than leaving the two artifacts disagreeing.

- **[n2] "send a class (c) duplicate sequence number to `Renumbering…`"** —
  `.opencode/skill/merge-conflict/SKILL.md:181-183`. "apply" reads better than
  "send … to"; no behavior change.

- **[n3] `delete/modify` and `binary` conflicts are handled by the general rule but not named** — `.opencode/skill/merge-conflict/SKILL.md:184-188`
  The spec edge cases name them; the surfaces route them through "a judgment
  between competing intents". `verify.md:125-131` records this as accepted;
  naming them would make the mapping explicit.

- **[n4] "before the resolved merge is committed" is unreachable on the clean-merge path** — `.opencode/skill/merge-conflict/SKILL.md:167-172`, `:195-199`
  `git merge --no-edit` auto-commits a conflict-free merge, so sub-step 8 runs
  after that commit. AC6 holds where it matters (a conflicted merge is left
  uncommitted), but the wording overstates the guarantee for the clean path;
  "before the merge is recorded or shipped" would be precise.

## Not reviewed

- **Independent execution of the suites.** This review sandbox permits only git
  read commands, `ls`, and `cat`; `bash` is denied, so AC13/AC14 are assessed
  from `verify.md` plus static re-derivation of `tests/checks/30-permissions.sh`
  and `40-inventory.sh`, not a re-run. A reviewer with shell access should run
  `bash tests/run.sh` and
  `bash work/0005-merge-conflict-workflow/0003-shared-surface-reconcile/verify-tests.sh`.
- **Effective permission resolution under the real matcher.** The item suite
  models opencode's last-match-wins evaluation; it does not invoke
  `opencode debug agent shipper`. The model and the real matcher agree for every
  asserted target (and `95-split-guard.sh` confirms `*` spans `/`), but the live
  resolution was not exercised here.
- **Runtime agent behavior.** A live `/ship` reconcile (merge, marker
  resolution, abort, branch state) needs an agent runtime and live branch state;
  the item probes exercise the raw git forms, not the agent's permission gate.
- **Sibling historical item suites.** `0001-conflict-model` and
  `0002-conflict-detection` verify-tests report expected drift against surfaces
  this child deliberately edits (`verify.md:151-159`). Those artifacts are owned
  by their own test phases and were not edited here.
- **Security note, accepted residual.** The grant `bash work/*/verify-tests.sh*`
  lets the shipper execute an item-owned script that travels on the branch under
  review. This is inherent to AC6's "affected item's checks" and matches the
  previous review's own recommendation; it is flagged here so the risk is
  explicit, not as a defect. No secrets are introduced or read; the new grants
  are confined to the class (a) surfaces and `work/**`.
- **UI/visual.** Not applicable; prompt/config/document work, no `/visual` pass.
