---
feature: 0005-merge-conflict-workflow/0002-conflict-detection
phase: review
status: final
created: 2026-10-07
updated: 2026-10-07
parent: 0005-merge-conflict-workflow
---

# Review — Pre-flight conflict detection and classification

## Verdict

**approve** — every acceptance criterion is met on the delivered surfaces, the
prior `request-changes` findings (M1–M4) are independently confirmed fixed, and
the remaining items are documentation-coherence and precision nits that do not
block the ship.

## How this review was produced

Base is `HEAD` = `origin/main`; the work is uncommitted working-tree edits plus
this item's untracked artifacts. No branch switch was needed.

| Command | Result |
| ------- | ------ |
| `git merge-base HEAD origin/main` | `5fe9bdc0fb447df547ee59180f1d179e0a3bf4f3` |
| `git rev-parse HEAD` | `5fe9bdc0fb447df547ee59180f1d179e0a3bf4f3` (base == HEAD) |
| `git status --porcelain` | 6 modified `.opencode` surfaces + 6 untracked files under the item dir |
| `git diff --stat` | 6 files, +247/−33 |
| `git diff -- .opencode/...` | reviewed per surface (skill, shipper, ship, status agent/command, pr-workflow) |

The delivered diff is confined to the six design-named surfaces; `docs/`,
`AGENTS.md`, `README.md`, `opencode.json`, `template/`, and `tests/` are
untouched (`git diff --stat -- tests docs README.md AGENTS.md opencode.json
template` is empty).

The current `review.md` was a stale prior pass (`request-changes`); `verify.md`
records that its M1–M4 were subsequently fixed. I re-derived the review from the
current tree rather than trusting that note, and independently confirmed each fix
(see "Prior review findings").

## Findings

### Blockers

None.

### Major

None.

### Minor

- **[M1] The authoritative status surface under-documents the new finding
  vocabulary** — `docs/workflow.md:118-123`, `.opencode/agent/status.md:143-147`,
  `.opencode/command/status.md:31-37`
  `docs/workflow.md` → "### Status reporting" enumerates exactly four integrity
  findings (`DANGLING-DEP`, `MISSING-CHILD`, `UNLISTED-CHILD`, `CYCLIC-DEP`),
  while `/status` now also emits `DUPLICATE-PREFIX`, `DUPLICATE-CHILD`, and
  `DRIFT-FACT`. The spec design deliberately left `docs/workflow.md` unchanged to
  avoid colliding with siblings `0003`/`0004`, and AC14 does not require editing
  it, so this is not a spec violation — but it leaves the declared source of truth
  out of sync with the agent that implements it, which is exactly the
  duplicated-fact drift this initiative exists to catch. Recommendation: in a
  follow-up (or the parent roadmap's accepted-drift record), add the three codes
  to the `## Status reporting` list or add an explicit pointer to the
  `merge-conflict` skill as the canonical vocabulary. Do not fix it here if that
  would collide with sibling branches.

- **[M2] The pre-flight never defines `<remote>`** —
  `.opencode/skill/merge-conflict/SKILL.md:37`
  Step 1 fetches with `git fetch <remote> <default-branch>` but nothing in the
  skill resolves `<remote>`; the rest of the procedure (and the shipper's
  allowlist) assumes `origin`. On a clone whose default remote is not `origin`,
  an agent following the skill literally has no instruction for what to
  substitute, and may fetch the wrong ref or fail. Recommendation: name the
  resolution once (e.g. "the remote of `origin/HEAD`, normally `origin`") so the
  command is executable as written.

- **[M3] "write nothing" is literally false for the fetch/probe steps** —
  `.opencode/skill/merge-conflict/SKILL.md:28-29`, `:37-38`, `:53-54`
  The concurrency sentence says two pre-flights "take no lock and write
  nothing", but `git fetch` writes `FETCH_HEAD` and remote-tracking refs, and
  `git merge-tree --write-tree` may leave an unreachable object. The paragraph
  above correctly qualifies fetch as updating "remote-tracking refs only", so the
  two statements disagree. The spec's read-only definition is narrower (no
  commit, no branch change, no working-tree change), which the delivery does
  satisfy, so this is a wording defect rather than a behavior one.
  Recommendation: tighten the concurrency clause to "write nothing under the
  working tree or `work/` tree" (or "no branch and no working-tree write") so it
  is not contradicted two lines later.

- **[M4] The sibling `0001-conflict-model` item suite is now red** —
  `work/0005-merge-conflict-workflow/0001-conflict-model/verify-tests.sh:183`,
  `:238-243`
  This child renames the skill's fused `**Detect.**` step to `**Reconcile.**` and
  edits `.opencode/agent/shipper.md` / `status.md`, so `0001`'s historical
  snapshot asserts literals and a clean command/agent change-set that this change
  invalidates. `verify.md:97-113` records this honestly as expected drift, and
  the canonical suite (`bash tests/run.sh`) never reads `work/**`, so it is not a
  CI failure — but a committed item suite under `work/` is supposed to be
  evidence, and leaving it red is a real (if minor) hygiene cost.
  Recommendation: refresh `0001`'s stale literals (`**Detect.**` →
  `**Reconcile.**`) and replace its obsolete clean-tree negative control in a
  small follow-up owned by that item, or record the accepted drift in the parent
  roadmap. Do not weaken or delete the assertions.

### Nits

- **[N1] Design table is stale relative to the code** — `design.md:59`
  The permission table marks `git symbolic-ref` "already allowed"; it was not,
  and the delivered change had to add `"git symbolic-ref*": allow`
  (`shipper.md:20`). The design artifact is another phase's file, so leave it;
  this is recorded only so the next reader of `design.md` is not misled.

- **[N2] "repeat it verbatim" is not literally true for `DRIFT-FACT`** —
  `.opencode/agent/status.md:132-133`, `:147`
  The status agent says the vocabulary is canonical in the skill and to "repeat
  it verbatim", but its `DRIFT-FACT` definition drops the skill's "or the other
  branch" clause (correctly, to stay local-only per M3 of the prior review).
  Align the claim (e.g. "except where local-only detection requires") or the
  wording, so the verbatim instruction and the text agree.

- **[N3] Pre-flight is stated as a precondition but implemented as step 1** —
  `.opencode/agent/shipper.md:88-92`, `:116-124`
  The work-item `<preconditions>` bullet describes an action ("the read-only
  pre-flight ... runs") as a condition that must hold, while `<process>` step 1
  performs it. A precondition should be a state, not an action. Recommendation:
  keep the requirement in `<process>` and reduce the precondition bullet to
  "pre-flight completed and its result recorded", or leave as-is; harmless but
  imprecise.

## Prior review findings re-checked

Independently verified in the current tree:

| Finding | Status | Evidence |
| ------- | ------ | -------- |
| M1 — `git symbolic-ref` denied | **Fixed** | `shipper.md:20` adds `"git symbolic-ref*": allow`; the pattern does not match the git-write regex in `tests/checks/30-permissions.sh:87`, so the shipper stays `git-gh`. |
| M2 — `merge-tree` exit/output shape undocumented | **Fixed** | `SKILL.md:49-52` states exit `1` means conflicts, not failure, and to skip the leading tree-OID line. |
| M3 — `/status` `DRIFT-FACT` claimed a cross-branch read | **Fixed** | `status.md:147` now says "disagrees with disk"; `grep -c 'or the other branch' .opencode/agent/status.md` is 0. |
| M4 — shared `<handoff>` gained a work-item-only line | **Fixed** | `shipper.md:191-192` scopes `Detected:` to work-item mode; fix-landing omits it. |

The added `git symbolic-ref*` pattern is a justified deviation from the design's
three-pattern list: AC7 requires the pre-flight's default-branch read to be
permitted, and `gh` may be unavailable.

## Acceptance criteria

| Criterion | Status | Evidence |
| --------- | ------ | -------- |
| AC1 — read-only pre-flight determines merge base, reports changed paths, mutates nothing | **Met** | `SKILL.md:22-45`: `**read-only pre-flight**`, `merge base`, `git merge-base HEAD origin/<default>`, `git fetch <remote> <default-branch>`, both `git diff --name-only` forms, `mutates neither the branch nor the working tree`, `no merge applied`/`no rebase`/`no force-push`/`no commit`/`no branch change`. |
| AC2 — non-applying dry-run over changed paths, classifies each conflict (a)/(b) | **Met** | `SKILL.md:47-62`: `git merge-tree --write-tree --name-only HEAD origin/<default>`, three-arg fallback, `does not apply to the working tree`, class `(a)` surface list and class `(b)` = `work/` path, cites the `0001` taxonomy. `verify-tests.sh:107-143` also runs a live scratch-repo probe. |
| AC3 — integrity checks: duplicate prefixes/children, graph faults, drift | **Met** | `SKILL.md:64-92`: duplicate top-level `NNNN`, duplicate per-parent `MMMM`, `dangling`/`missing`/`unlisted`/`cyclic`, README Layout/Skills vs on-disk, cross-branch `git ls-tree --name-only origin/<default>:work`. |
| AC4 — every finding carries class + offender + detail, none dropped | **Met** | `SKILL.md:94-125` grammar and table; `No finding is silently dropped`, `never truncated`, all eight codes and four class labels. |
| AC5 — shipper + `/ship` run pre-flight before any ship operation | **Met** | `shipper.md:88-92,116-124`; `command/ship.md:25-31`. |
| AC6 — intent-judgment conflict stops and escalates; detection never resolves | **Met** | `SKILL.md:138-141,194-198`; `shipper.md:120-122`; `command/ship.md:28-29`. |
| AC7 — minimal read-only git permissions; rebase/force-push forbidden | **Met** | `shipper.md:20-24` grants `git symbolic-ref*`, `git fetch*`, `git merge-tree*`, `git ls-tree*`; `"git push*": ask` retained (`:31`); no `git rebase*`. Coarse class unchanged. |
| AC8 — `/status` reports duplicate/pre-fix findings alongside the four existing | **Met** | `status.md:88-97,122-150`; `command/status.md:31-37`; findings remain non-fatal and modify no file. |
| AC9 — `/status` detection is local-only (no fetch, no remote, no dry-run merge) | **Met** | `status.md:206-210`; `command/status.md:35-37`; `verify-tests.sh:241-244` asserts no `git fetch` / `git merge-tree` on either surface. |
| AC10 — findings name the offender reference and class | **Met** | `SKILL.md:99-103`; `status.md:143-147`, examples at `:181-183` name concrete canonical refs with `(c)`/`(d)`. |
| AC11 — up-to-date branch is a no-op, no error | **Met** | `SKILL.md:129-130`; `shipper.md:122-123`. |
| AC12 — result recorded in ship handoff and PR description | **Met** | `shipper.md:185,191-192`; `pr-workflow/SKILL.md:43-47` `## Conflict detection` + `No conflicts detected`; `command/ship.md:29-31`. |
| AC13 — `bash tests/run.sh` passes, including permission agreement | **Met (per tester evidence; not independently executed)** | `verify.md:45,73` records 285 passed / 0 failed and `30-permissions.sh` green (shipper `git-gh`, status `read-only`). Static review of `30-permissions.sh:87` (the new patterns do not match the git-write regex) and `40-inventory.sh` (counts unchanged) agrees. The review sandbox denies `bash`, so I could not re-run it — see "Not reviewed". |
| AC14 — no lifecycle/artifact/command/agent change; no new command/agent | **Met** | Diff touches only the six design-named surfaces; `ls` gives 12 commands / 14 agents / 11 skills; `docs/`, `AGENTS.md`, `README.md`, `opencode.json`, `template/`, `tests/` unmodified. |

Spec edge cases (default branch undeterminable, fetch skipped with reason, empty
`work/`, shipped/unshipped duplicates, overlapping classes, equal changes are not
drift, clean dry-run caveat, concurrent runs, no truncation) are each addressed on
the delivered surfaces and recorded PASS in `verify.md:78-88`. The new item suite
is content-assertion based, as the design's test strategy requires for a
prompt/config-only deliverable, and its negative controls are appropriate
(no `git fetch`/`git merge-tree` on `/status`, no `git rebase` on the shipper, no
new untracked surface, `.opencode` change-set equality literal).

## Not reviewed

- **Independent execution of `bash tests/run.sh` and the item suite.** The review
  sandbox permits only `git` read commands, `ls`, and `cat`; `bash` is denied, so
  AC13 is assessed from `verify.md` plus static review of the committed checks
  rather than a re-run. A reviewer with shell access should re-run `bash
  tests/run.sh` and `bash
  work/0005-merge-conflict-workflow/0002-conflict-detection/verify-tests.sh`.
- **Runtime behavior of the delivered procedure** (a live `/status` run, an
  end-to-end `/ship` pre-flight). These need an agent runtime and live branch
  state; committed fixture/mutation coverage is explicitly deferred to sibling
  `0005-merge-integrity-guards`. The one executable primitive (`git merge-tree
  --write-tree --name-only`) is probed by `verify-tests.sh:107-143`.
- **UI/visual.** Not applicable; this child has no user-facing surface.
