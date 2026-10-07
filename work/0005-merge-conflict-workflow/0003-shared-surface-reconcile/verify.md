---
feature: 0005-merge-conflict-workflow/0003-shared-surface-reconcile
phase: test
status: final
created: 2026-10-07
updated: 2026-10-07
parent: 0005-merge-conflict-workflow
notes: "Prompt/config/doc only; no runtime code and no new committed check (committed merge-integrity guards are sibling 0005-merge-integrity-guards). AC1-AC14 and the spec edge cases are encoded as content assertions plus three live behavioral probes (merge-forward conflict resolution, abort-to-clean-tree, up-to-date no-op) and an effective-permission resolver in work/0005-merge-conflict-workflow/0003-shared-surface-reconcile/verify-tests.sh; AC13/AC14 are integration-verified by the canonical bash tests/run.sh plus inventory/unchanged-lifecycle invariants. Re-verification after review.md's request-changes: the builder added the missing shipper grants (git mv*, bash tests/run.sh*, and both item-check path forms); the tester added the effective-permission-resolution section that would have caught B1/M1, so the reconcile commands now resolve to allow under last-match-wins. No defects found in this child. Sibling 0001 and 0002 historical item suites still fail a few snapshot assertions as expected drift from this child's design-mandated edits; the canonical committed suite stays green."
---

# Verification — Reconcile workflow for shared framework surfaces

## Summary

All fourteen acceptance criteria of
`work/0005-merge-conflict-workflow/0003-shared-surface-reconcile` are satisfied
against the current working tree. The deliverable is prompt/config/document
content plus agent permission frontmatter, so the automatable evidence is the
read-only item suite
`work/0005-merge-conflict-workflow/0003-shared-surface-reconcile/verify-tests.sh`,
which encodes AC1–AC12 and every spec edge case as content assertions, adds three
live behavioral probes of the documented git forms, and resolves the shipper's
**effective** permission for each reconcile-critical command and path.

- The item suite passes **185/185** (0 failed). It grew from 154 to 185 because
  this re-verification pass added an effective-permission resolver covering
  AC2/AC3/AC6.
- The canonical suite `bash tests/run.sh` passes **285 passed, 0 failed, 0
  skipped**, including `tests/checks/30-permissions.sh` (shipper
  `edit=tests+work bash=git-gh`) and `tests/checks/40-inventory.sh` (12 commands /
  14 agents / 11 skills).
- The production change set is exactly the six design-named surfaces; no command,
  agent, or skill file was added; `docs/workflow.md` is byte-identical;
  `docs/artifact-conventions.md` changes only by the additive `## Reconcile`
  record inside the `ship.md` template.
- No production file was modified by this verification pass. The only test file
  changed is `verify-tests.sh`.

**Review follow-up.** A prior `review.md` returned **request-changes** on two
findings: [B1] the class (c) mechanism `git mv` was named in the skill but not
permitted by the shipper's allowlist, and [M1] AC6 re-verification instructed the
shipper to run `bash tests/run.sh` and the item checks, which its allowlist
denied. Both are now resolved in the implementation — the shipper grants
`"git mv*": allow`, `"bash tests/run.sh*": allow`,
`"bash work/*/verify-tests.sh*": allow`, and
`"bash work/*/*/verify-tests.sh*": allow` — and this pass adds the
effective-permission tests (see AC2/AC3/AC6 below) that would have caught the
original gap, where literal pattern presence alone did not. The guardrails are
unchanged: rebase resolves to deny, `gh pr merge` resolves to deny, and push
(including force-push) resolves to `ask`.

**Cross-phase note:** the historical item suites of siblings `0001-conflict-model`
and `0002-conflict-detection` still fail a few snapshot assertions. These
constrain surfaces this child's design deliberately edits; the failures are
expected drift recorded under residual risk, not defects in this child and not
failures of the canonical committed suite. Those artifacts are owned by the test
phase of their own items and were not edited here.

## Commands run

| Command | Result | Notes |
| ------- | ------ | ----- |
| `bash tests/run.sh` | PASS | `TOTAL: 285 passed, 0 failed, 0 skipped`; exit 0; no `FAIL` line |
| `bash work/0005-merge-conflict-workflow/0003-shared-surface-reconcile/verify-tests.sh` | PASS | `TOTAL: 185 passed, 0 failed`; exit 0 |
| `bash -n work/0005-merge-conflict-workflow/0003-shared-surface-reconcile/verify-tests.sh` | PASS | syntax OK |
| `git diff --quiet -- docs/workflow.md` | PASS | byte-identical (AC14) |
| `git diff -- docs/artifact-conventions.md` | PASS | only the additive `## Reconcile` record inside the `ship.md` template (AC10/AC14) |
| `git status --porcelain` | PASS | exactly six modified surfaces plus the untracked item dir (AC14) |
| `bash tests/run.sh \| grep 'AC8 shipper:'` | PASS | `AC8 shipper: mode=primary edit=tests+work bash=git-gh` (AC3/AC13) |
| `bash work/0005-merge-conflict-workflow/0001-conflict-model/verify-tests.sh` | FAIL (expected drift) | `TOTAL: 134 passed, 3 failed`; sibling snapshot, see residual risk |
| `bash work/0005-merge-conflict-workflow/0002-conflict-detection/verify-tests.sh` | FAIL (expected drift) | `TOTAL: 157 passed, 4 failed`; sibling snapshot, see residual risk |

## Acceptance coverage

| Criterion | Test(s) | Result |
| --------- | ------- | ------ |
| AC1 — ordered, agent-executable merge-forward procedure; never rebase/force-push | `verify-tests.sh` AC1: skill carries `determine the default branch and the merge base`, `git fetch <remote> <default>`, `git merge-base HEAD origin/<default>`, `git merge --no-edit origin/<default>`, `merge the default branch forward`, `never rebase`, `never force-push`; sequence order asserted (`Determine…then fetch` < `Merge the default branch forward` < `Stop and escalate a semantic conflict`); shipper process carries the same commands and constraints | PASS |
| AC2 — shipper bash allowlist grants fetch/merge/inspect/abort; rebase impermissible, force-push ask, PR-merge forbidden | `verify-tests.sh` AC2: pattern presence (`"git merge*"`, `"git fetch*"`, `"git status*"`, `"git diff*"`, `"git merge-base*"`, `"git rev-parse*"`, `"git symbolic-ref*"`, `"git mv*"`, `"git push*": ask`; no `git rebase`/`git pull`, no `gh pr merge`), **plus effective resolution** under last-match-wins: symbolic-ref/merge-base/fetch/rev-parse/merge/status/diff/mv/abort → `allow`, push and force-push → `ask`, rebase and `gh pr merge` → `deny` | PASS |
| AC3 — shipper may edit class (a) shared surfaces plus `work/**`; README row and permission check agree | `verify-tests.sh` AC3: all 18 edit patterns present in both path forms (`README.md`/`**/README.md`, `AGENTS.md`/`**/AGENTS.md`, `docs/*.md`/`**/docs/*.md`, `.opencode/{agent,command,skill}/**` + nested forms, `template/**`/`**/template/**`, `tests/checks/**`/`**/tests/checks/**`, `work/**`/`**/work/**`), `"*": deny` retained; **effective edit resolution**: README, docs, `.opencode` agent/skill, template, `tests/checks`, and relative+absolute `work/` → `allow`, `src/main.ts` → `deny`; README shipper row names `tests/checks` and a shared surface and keeps `git/gh`; canonical `30-permissions.sh` reports `AC8 shipper: mode=primary edit=tests+work bash=git-gh` | PASS |
| AC4 — resolve a shared-surface conflict preserving both branches, no markers remain | `verify-tests.sh` AC4: skill has `preserve **both** branches'`, `drop neither side`, class (a)/(b); **live probe** creates a two-sided `README.md` conflict, confirms `git diff --name-only --diff-filter=U` lists it, resolves preserving both lines, asserts no `<<<<<<<`/`=======`/`>>>>>>>`, and commits the resolved merge | PASS |
| AC5 — mechanical/structural conflicts auto-resolve, subject to re-verification | `verify-tests.sh` AC5: `Auto-resolve only \`mechanical or structural\``, `does not require choosing between competing intents`, `subject to sub-step 8` | PASS |
| AC6 — re-run the committed suite + item checks; green before commit/record/ship | `verify-tests.sh` AC6: skill and shipper both carry `bash tests/run.sh`, the affected item's checks, and the green-before-committed/recorded/shipped gate; **effective resolution** confirms `bash tests/run.sh`, `bash work/<item>/verify-tests.sh`, and `bash work/<parent>/<child>/verify-tests.sh` all resolve to `allow` | PASS |
| AC7 — semantic conflict aborts to a clean tree and escalates; ship stays blocked | `verify-tests.sh` AC7: skill has `semantic conflict`, `do not resolve it`, `git merge --abort`, `clean working tree`, `blocked path(s)`, `blocked until the user responds`, `if the abort cannot complete`; shipper has `git merge --abort` and the blocked-until-user line; **live probe** confirms `git merge --abort` clears `MERGE_HEAD` and leaves `git status --porcelain` empty | PASS |
| AC8 — `work/` conflicts preserve both records; class (c) defers to the renumbering rule | `verify-tests.sh` AC8: `class (b) \`work/\` records from both`, `rather than dropping one`, `Renumbering after a parallel merge`, `git mv`, `sibling \`0004\``, roadmap `Children` / `Depends on` classification, `never defines a second rule`; **effective resolution** confirms `git mv` → `allow` | PASS |
| AC9 — reconcile recorded in `ship.md` and the PR description (resolved paths + re-verification) | `verify-tests.sh` AC9: `docs/artifact-conventions.md` and `pr-workflow` both carry `## Reconcile`, `Resolved paths`, and `Re-verification: \`bash tests/run.sh\``; skill records into the `## Reconcile` section of `ship.md` and the pull-request; negative control asserts the fix PR template gained no `## Reconcile` | PASS |
| AC10 — the `ship.md` template documents the reconcile record | `verify-tests.sh` AC10: the `### \`ship.md\`` template body (extracted through its closing fence) contains `## Reconcile`, the `Result: <reconciled \| no-op (already up to date) \| blocked: <reason>>` vocabulary, and the `Re-verification:` line | PASS |
| AC11 — reconcile after pre-flight, before other operations; guardrails never-merge/never-force-push retained | `verify-tests.sh` AC11: shipper and `/ship` carry `Reconcile first`, `after the read-only pre-flight`, `before the other ship operations`; ordering asserted in both surfaces (shipper 136 < 145 < 159; `/ship` 25 < 32 < 40); `Never merge a PR`, `Never force-push`, the `/ship` closing guardrail, and the `Reconciled:` handoff line retained | PASS |
| AC12 — already-up-to-date branch is a no-op that creates no merge commit | `verify-tests.sh` AC12: skill has `already-up-to-date branch is a no-op`, `no conflicts`, `no merge commit`, `does not error`; shipper has `no conflicts`/`no merge commit`; **live probe** confirms the default branch is an ancestor and `git merge --no-edit` leaves HEAD unchanged and exits 0 | PASS |
| AC13 — `bash tests/run.sh` passes, including permission + inventory agreements | Independently re-run here: `TOTAL: 285 passed, 0 failed, 0 skipped`, exit 0, no `FAIL`; the item suite extracts `AC8 shipper: mode=primary edit=tests+work bash=git-gh` and confirms `40-inventory.sh` asserted the README Layout counts | PASS |
| AC14 — no lifecycle/artifact-format/readiness/command/agent addition beyond the `ship.md` reconcile record | `verify-tests.sh` AC14: counts 12 commands / 14 agents / 11 skills; no untracked command/agent/skill file; `docs/workflow.md` byte-identical; every artifact template heading retained; six phases retained and no seventh; production change set equals exactly the six design-named surfaces; no new file outside `work/` | PASS |

### Edge cases

| Edge case | Test(s) | Result |
| --------- | ------- | ------ |
| Nothing to reconcile (already up to date) | AC12 content + live no-op probe | PASS |
| Default branch undeterminable | EDGE: `default branch cannot be determined` + `do not mutate the branch` | PASS |
| Fetch unavailable or denied | EDGE: `unavailable or denied` + `report the comparison as \`skipped\`` (inherited from the pre-flight section) | PASS |
| Behind but conflict-free | EDGE: `clean merge is not evidence of correctness` still requires re-verification | PASS |
| Delete/modify conflict | Covered by the generic `judgment between competing intents` semantic clause and `drop neither side`; the terms "delete/modify" are not literally named. See residual risk. | PASS (by general rule) |
| Markers remain after resolution | EDGE: `unresolved` + `must not be committed` | PASS |
| Semantic conflict escalated mid-merge; abort cannot complete | AC7 content + live abort probe; EDGE `restore a clean working tree`, `rather than committing a partial merge` | PASS |
| Re-verification fails after a mechanical resolution | EDGE: `re-verification fails is not accepted` | PASS |
| Duplicate sequence number in a mixed merge | AC8: defers to `Renumbering after a parallel merge`; `git mv` effectively permitted; step 7 escalates when it cannot be resolved mechanically | PASS |
| Roadmap `Children` / `Depends on` conflict | AC8: `roadmap \`Children\` / \`Depends on\`` classification; step 7 aborts an unresolvable graph | PASS |
| Binary file conflict | Covered by the generic semantic clause (taking one side requires a judgment); the term "binary" is not literally named. See residual risk. | PASS (by general rule) |
| Already mid-merge at start | EDGE: `Do not start a second merge` + `MERGE_HEAD` | PASS |
| Large conflict set | EDGE: `never truncated` | PASS |
| Concurrent ships on the same branch | Out of scope per spec; the pre-flight/skill take no lock and write nothing. Not tested. | N/A (spec non-goal) |

## Gaps and residual risk

- **Content criteria are literal-presence checks plus a modeled permission
  resolver, not semantic proofs.** The deliverable is prose plus prompt
  configuration; there is no runtime harness for document content. AC1–AC12 and
  the edge cases are verified by asserting the required literals from the finished
  surfaces (the design's stated test strategy), three live probes of the documented
  git behavior, and a resolver that models opencode's documented last-match-wins
  permission evaluation. The resolver widens `*`/`**` to `.*`, which is permissive;
  every asserted target lies inside a named surface, so a modeled match also holds
  under the real matcher. The resolver still models the matcher rather than invoking
  `opencode debug agent shipper`; running that command in an environment where
  opencode is installed would close this residual. A reviewer should still read the
  surfaces for coherence.
- **`delete/modify` and `binary` conflicts are handled by the general rule, not
  named explicitly.** The design's Approach prose said the skill would name them,
  but its own Required-literals table (the concrete contract the builder
  implemented) did not, and the spec's ACs do not require the labels. Both are
  instances of "requires a judgment between competing intents", which the skill
  routes to `git merge --abort` and escalation. Low risk; a future sibling that
  wants explicit labels should add them there, not layer a second rule here.
- **`git merge*` is broader than the one command.** Prefix matching also permits
  `git merge --continue` and a bare `git merge <x>`. Rebase resolves to deny and
  push (including force-push) stays `ask`, so the never-rebase/never-force-push
  guardrails hold. Accepted by the design; impact low.
- **Precondition ordering.** The shipper's `<preconditions>` now requires "The
  branch has been reconciled…", while the reconcile is process step 2 and
  preconditions are verified in step 3. The condition is therefore established by
  the process before it is checked, which is consistent, but the precondition block
  reads as a gate ahead of step 1. Recorded in `review.md` as [m4]; documentation
  coherence only, no AC impact.
- **Skill duplication of resolve/re-verify/escalate rules.** The rewritten
  `## Procedure` step 1 embeds a nine-sub-step sequence while outer steps 2–7
  restate resolve, re-verify, and escalate, and some cross-references ("step 4",
  "step 7") read as outer steps. `review.md` [m2]; no AC impact, but the two copies
  can drift.
- **README shipper row presents the surfaces as root-only.** The declared edit
  grant includes the nested `**/…` forms, but the Agents-table cell names the
  surfaces without the nested equivalents. It satisfies the coarse agreement
  (`edit=tests+work`) and `review.md` [m3] is a documentation-accuracy nit.
- **Sibling historical item suites drift.** `0001-conflict-model` reports
  `134 passed, 3 failed` (its snapshot expects the fused `**Detect.**` step and
  `**Record**` label this child/0002 rewrote, and no shipper agent-surface change).
  `0002-conflict-detection` reports `157 passed, 4 failed` (its snapshot expects
  `edit=work` for the shipper, the old `Detected:` scoping sentence, and the
  pre-0003 `.opencode` change set). These are historical read-only snapshots of
  their own item state, not the committed suite; the canonical `bash tests/run.sh`
  is green and its `30-permissions.sh` affirms the new `edit=tests+work`
  agreement.
- **No UI surface.** This is prompt/config/document work; no `/visual` pass
  applies.
