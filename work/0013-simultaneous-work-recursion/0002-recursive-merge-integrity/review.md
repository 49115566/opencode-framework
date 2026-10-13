---
feature: 0013-simultaneous-work-recursion/0002-recursive-merge-integrity
phase: review
status: final
created: 2026-10-13
updated: 2026-10-13
parent: 0013-simultaneous-work-recursion
notes: "No challenges.md, so there was no open challenge to adjudicate. The change is uncommitted working-tree state; the reviewed range is `git diff` against HEAD c85453a (also `git merge-base HEAD origin/main`). The configured suite could not be re-executed by this reviewer (the review sandbox denies arbitrary bash execution); AC14 rests on the tester's recorded run plus a static check that no committed check pins the edited wording."
---

# Review — Merge integrity and renumbering for recursive trees

## Verdict

**approve** — a strict, by-reference depth generalization of the merge-integrity
contract across exactly the three surfaces the spec fixes; every acceptance
criterion is met, no defect survived scrutiny, and no finding of any severity is
recorded.

## Base ref and reviewed range

The build is **uncommitted working-tree state** on the local `main`, so the
committed-range diff is empty and the reviewed range is the working-tree diff.

```
$ git rev-parse HEAD
c85453a0979aa3c5402d1db4948668d0dbfa2362
$ git merge-base HEAD origin/main
c85453a0979aa3c5402d1db4948668d0dbfa2362
$ git status
modified:   .opencode/skill/merge-conflict/SKILL.md
modified:   docs/artifact-conventions.md
modified:   docs/workflow.md
modified:   work/0013-simultaneous-work-recursion/0002-recursive-merge-integrity/tasks.md
untracked:  work/0013-simultaneous-work-recursion/0002-recursive-merge-integrity/verify.md
$ git diff --name-only
.opencode/skill/merge-conflict/SKILL.md
docs/artifact-conventions.md
docs/workflow.md
work/0013-simultaneous-work-recursion/0002-recursive-merge-integrity/tasks.md
```

`HEAD` (`c85453a`, the item's merged plan PR #74) equals `merge-base HEAD
origin/main`, so it is the correct and unambiguous base. Local `main` is five
commits behind `origin/main`, which carries the sibling `0003` changes to
`docs/workflow.md`/`docs/artifact-conventions.md`; a diff against `origin/main`
would wrongly include the *inverse* of `0003` and is not used. The reviewed change
is exactly the three named surfaces plus the builder's `tasks.md` box-ticks;
`verify.md` is the tester's artifact.

## Acceptance criteria walk

| AC | Result | Evidence |
| -- | ------ | -------- |
| AC1 — class `(c)` reaches arbitrary depth | met | `docs/workflow.md:1441` — row now reads "same local `MMMM` under the **same parent at any node**"; surface cell "for any decomposing node at any depth, its immediate children `work/<node-ref>/<MMMM-slug>`". `(a)`/`(b)`/`(d)` rows untouched (`:1439,1440,1442`). |
| AC2 — post-merge pass at every node | met | `docs/workflow.md:1450-1457` — "re-scan **every node of the recursive tree** … each decomposing node at any depth against its own immediate children, independently — re-check every `Depends on` against **its own node's** `Children` table". Old "top-level and per-parent" wording gone. |
| AC3 — guard scope at every node | met | `docs/workflow.md:1500` — "The invariant set is evaluated at **every node** of the recursive tree … no node's check depends on another's." |
| AC4 — duplicate rows explicit + single-sourced | met | `docs/workflow.md:1506-1507` — `DUPLICATE-PREFIX` = two top-level `NNNN`; `DUPLICATE-CHILD` = same-parent `MMMM`, "at any depth"; consistent with `docs/workflow.md:1405-1418`. Single-source pointer at `:1500`. Graph-fault rows unchanged (`:1508-1513`). |
| AC5 — both enforcement points at every node | met | `docs/workflow.md:1492-1496` — `/status` "at every node, offline and read-only"; `/ship` post-merge "runs **at every node**"; "neither defines a separate guard" retained (`:1498`). |
| AC6 — renumber detect at any depth | met | `docs/artifact-conventions.md:701-707` — top-level `NNNN` → `DUPLICATE-PREFIX`, every decomposing node at any depth → `DUPLICATE-CHILD`, full canonical reference, depth-≥ 3 shared parent/prefix naming; references "Multiple work items". |
| AC7 — whole-subtree rewrite | met | `docs/artifact-conventions.md:714-724` — directory name; node's own `feature:`; every descendant artifact's `feature:`; owning manifest's `Children` `Local id`+`Canonical reference`; every intermediate manifest's `Children` `Canonical reference`; every descendant's `parent:`; `ship.md`/PR paths; prose. Mirrors design `sweep(node)`. |
| AC8 — renumber at any depth, one rule | met | `docs/workflow.md:1532-1535` — "handled **at any depth** … steps apply identically to a collision at any node … never defines a second renumbering rule." Steps 2/3/5 and the closing paragraph unchanged. |
| AC9 — skill guard/enforcement passages generalize | met | `SKILL.md:73-79` (pre-flight scan, every node), `:80-86` (graph faults, its own `Children`), `:91-99` (cross-branch descends every node), `:291-297` (post-merge every node), `:373-413` (reconcile detect/move whole-subtree sweep). Skill still names `docs/workflow.md` as source of truth and defines no second rule. |
| AC10 — single authority, no competing rule | met | Rule stated once in "Multiple work items" (`docs/workflow.md:1396-1418`, untouched); invariant set once in "Merge-integrity guard" (`:1500-1513`); renumber steps once in `docs/artifact-conventions.md:694-727`. Every other mention is a pointer. |
| AC11 — shipped vocabulary reused | met | Diff adds no token beyond the shipped `DUPLICATE-PREFIX`/`DUPLICATE-CHILD`; no `(e)`, `DECLARED-`, `PLAN-`, `CONFLICT-`. Finding-line grammar and `planning-time` preserved (`SKILL.md:106,132`). |
| AC12 — report-only, non-fatal, offline, no-op | met | Guard report-only/no-lock/empty-tree no-op contract unchanged (`docs/workflow.md:1515-1528`); skill `/status` offline/no cross-branch read (`SKILL.md:98-99`) and no dry-run merge (`:129-130`). |
| AC13 — three surfaces only | met | `git diff --name-only` shows only the three named surfaces plus this item's `tasks.md`; no `README.md`, `.opencode/agent/**`, `.opencode/command/**`, manifest `conflicts-with` bullet, declared-conflict check, or `tests/**`. |
| AC14 — suite green, inventory unchanged | met (tester evidence + static check) | `verify.md` records `bash tests/run.sh` → 495/0/0 and `40-inventory` → 39/0/0. This reviewer could not re-execute (sandbox denies arbitrary bash); a static sweep of `tests/checks/**` found **no** committed literal pinning any edited wording (`per-parent`, `one decomposing parent`, `top-level and`, `Renumbering after`, `Merge-integrity`, `Relationship to renumbering` all unpinned), so the docs/skill-only edits cannot break a pinned assertion. No inventory surface (README/agents/commands/skills) is touched. |
| AC15 — backward compatibility | met | Every edit is a strict superset of the shipped two-level text; "Multiple work items" and "Sequence allocation" are untouched; no `phase:` token, work-item rename, spent-number change, `Depends on`/readiness change, or `ship.md` change. |

All 15 acceptance criteria are **met**. The spec's edge cases (depth ≥ 3,
chosen node decomposes, same local id under different parents, top-level vs
same-parent, `.gitkeep`/container/hybrid, zero/one child, cross-branch with no
counterpart, legacy `roadmap.md` alias, already-shipped offender, empty `work/`,
concurrency) are all consequences of the generalized per-node scan and the
whole-subtree sweep, and the text admits each.

## Findings

### Blockers

- none

### Major

- none

### Minor

- none

### Nits

- none

## Security, secrets, and error handling

Actively checked: the diff is documentation/prompt prose only — no executable
code, no credential, token, `.env`, URL, or secret added (the changed lines add
only normative text); no new path or command is introduced; and the guard's
report-only/non-fatal/no-auto-repair/no-lock contract (`docs/workflow.md:1515-1528`)
and the skill's escalated-error and no-op paths (`SKILL.md:299-302,422-425`) are
preserved. `git diff` contained no secret-shaped additions.

## Not reviewed / out of scope

- **Skill `per-parent` shorthand (three sites).** `SKILL.md:126` (vocabulary
  table), `:260-261` (classify), and `:394` (renumber "Choose" allocation) retain
  the shipped term "per-parent". These lie **outside** the four passages AC9
  enumerates and are depth-generic ("for each parent"), not a two-level cap; the
  spec defers the broad skill/agent vocabulary sweep to Roadmap 4 (spec
  non-goals; AC9 enumerates only the scan, cross-branch, post-merge, and reconcile
  passages). Recorded by `verify.md` as observations. Deliberately not raised as a
  finding, consistent with the item's declared scope.
- **Merge-time reconcile is the shipper's domain.** `origin/main` already carries
  the sibling `0003` changes to `docs/workflow.md` and
  `docs/artifact-conventions.md`; the shipped branch will need a forward merge per
  `## Merge conflicts`. That is `/ship`'s reconcile step, not a property of this
  diff, so it is not assessed here.
- **No `visual.md`.** This is a docs/prompt change with no user-facing surface;
  the optional visual pass does not apply.
- **Committed recursive merge-integrity fixtures** are an explicit non-goal
  (Roadmap 5), so the absence of a new committed test is sanctioned, not a gap.

## Reviewer limitation

The configured suite (`bash tests/run.sh`) could not be independently re-executed
in the review sandbox (arbitrary bash execution is denied; only read-only git and
file inspection are permitted). AC14 therefore rests on the tester's recorded run
plus the static confirmation above that no committed check pins the edited
wording. No other acceptance criterion depends on execution.
