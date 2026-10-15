---
feature: 0015-recursive-workflow-guards/0004-recursive-integrity-guard
phase: review
status: final
created: 2026-10-14
updated: 2026-10-14
parent: 0015-recursive-workflow-guards
---

# Review — Committed recursive merge-integrity and renumber guards

## Verdict

**approve** — the change is correct, well-scoped, and every acceptance criterion
is met; the prior review's only finding (the `89-` area-prefix collision) is
resolved by the plan revision's rename to the free `91-` stem, and no finding of
any severity survives this pass.

## Challenges adjudicated

None. `work/0015-recursive-workflow-guards/0004-recursive-integrity-guard/challenges.md`
does not exist, so there is no open challenge against any `review.md` finding to
adjudicate. This is the forward re-review after the `/plan` revision recorded as
`backtracks.md` Resolution 2; the on-disk `review.md` was `stale: design` and is
superseded by this fresh pass, which clears that marker.

## Base ref and diff

The implementation is **uncommitted** on the plan branch; `HEAD` is the plan
commit and equals the merge base with `origin/main`, so `origin/main...HEAD`
carries no code change. The reviewable change is the working tree versus `HEAD`
plus the untracked files.

| Command | Result |
| ------- | ------ |
| `git rev-parse HEAD` | `39738ecc7b15501753585007c5e5f0df4e25c514` |
| `git merge-base HEAD origin/main` | `39738ec` (== `HEAD`) |
| `git log --oneline HEAD..origin/main` | 22 commits — siblings `0001`/`0002`/`0003` and their plan/publication merges |
| `git diff HEAD --stat` | `tests/checks/80-cycle-fixture.sh` (+15/-6), `tests/mutation.sh` (+1), `work/.../tasks.md` (+5/-5) |
| `git status --porcelain` | the 3 modified files above, plus untracked `tests/checks/91-integrity-guard.sh`, `tests/fixtures/recursive-integrity/`, `work/.../backtracks.md`, `work/.../verify.md`, `work/.../review.md` |
| `git show origin/main:tests/checks` | siblings present incl. `81-recursive-structure-guard.sh`, `89-recursive-status-guards.sh`; no `91-` area |

I read the full new check (`tests/checks/91-integrity-guard.sh`, 805 lines), all
25 committed fixture files, the two changed test files, the sibling guards on
`origin/main`, and the four authority surfaces the area pins (`docs/workflow.md`
→ `### Merge-integrity guard`, `.opencode/skill/merge-conflict/SKILL.md`,
`docs/artifact-conventions.md` → `### Renumbering after a parallel merge`,
`tests/checks/88-renumber-sweep.sh`). The sandbox denies executing the suite, so
the suite result is the tester's evidence plus my static trace (see "Not
reviewed").

## Findings

### Blockers

- None.

### Major

- None.

### Minor

- None.

### Nits

- None.

## Questions (non-blocking; recorded, not classified)

- **`DANGLING-DEP` predicate breadth.** The authority defines `DANGLING-DEP` as a
  `Depends on` naming a local id with no child directory **or** no table row
  (`docs/workflow.md` → "Merge-integrity guard" invariant table;
  `.opencode/skill/merge-conflict/SKILL.md:121`). The area's predicate
  (`tests/checks/91-integrity-guard.sh:237-250`) tests only the **row** half
  (`fig_has_line "$rowids" "$d"`), so a `Depends on` naming an existing row whose
  directory is absent is not reported; `design.md` describes the analyzer as
  resolving against "rows **and** directories". `spec.md` AC3 words its sample as
  a local id that "names no row and no directory" (`0099-ghost`), which is
  exercised, so the criterion is met. Is the narrower predicate the intended pin,
  or should the area also cover the "row present, directory absent" arm? Recorded
  as a question, not a defect, because the spec's chosen sample does not require
  the broader arm.
- **Withdrawal-record fidelity.** The fixture records the deliberate withdrawal as
  `9202-graph-faults/0004-withdrawn/`
  (`tests/fixtures/recursive-integrity/items/9202-graph-faults/manifest.md:39-42`)
  rather than the `manifest.md` template's `work/<parent>/<MMMM-slug>/` shape,
  because the area's `read-only-contract` forbids the literal `work/` in the
  fixture root. Recognition is a substring match
  (`tests/checks/91-integrity-guard.sh:233`) and still works on the faithful
  `work/<parent>/<child>/` shape. Is the divergence acceptable, or should the
  fixture carry the faithful path with a read-only exemption? AC3's report-only
  requirement holds either way.

## Acceptance criteria coverage

| Criterion | Result | Evidence |
| --------- | ------ | -------- |
| AC1 — fixture-based, fresh-clone safe, fails not skips | **met** | `AC30 fixture-existence` asserts the tree plus 14 required files (`91-integrity-guard.sh:645-675`); `AC30 read-only-contract` asserts no live `work/` path, no executable fixture file or self, no `.opencode/` reference (`:677-710`); no shell `exit`, `curl`, `wget`, `gh`, or writing redirection in the file. |
| AC2 — independent per-node evaluation; depth-3 fault named | **met** | `fig_scan_node` recurses per node (`:177-268`); `EXP_DUP` carries the depth-3 `DUPLICATE-CHILD` and the attribution assertion (`:342-351`). I traced the analyzer over every fixture node and the three expected blocks reproduce exactly. |
| AC3 — `MISSING-CHILD`/`UNLISTED-CHILD`/`DANGLING-DEP` + report-only withdrawal | **met** | `EXP_GRAPH` (`:327-332`) names all three; the `0004-withdrawn` directory is excluded from `UNLISTED-CHILD` by the open-issues record (`:228-235`, `:357-363`). |
| AC4 — dual spelling + phase mismatch `DRIFT-FACT`; modern authoritative; no drop/merge | **met** | `EXP_DRIFT` (`:334-338`); the authoritative-resolver assertion (`:374-379`) and both-files-retained assertion (`:381-388`). |
| AC5 — report-only / non-fatal / never-truncated / no-file-modified; clean tree empty | **met** | `fig_pin` pins the authority literals (`:452-465`) and skill literals (`:480-487`); the clean `9201-clean` node yields an empty block (`:489-503`). |
| AC6 — sibling-owned invariants referenced, not re-pinned | **met** | Header references (`:21-29`); `AC30 no-duplication` header list plus 9 assembled forbidden-literal scans (`:731-805`). I confirmed none of the assembled needles occurs in the file. |
| AC7 — completed whole-subtree renumber leaves no stale reference | **met** | Presence in all 9 rewrite positions (`:521-573`) plus recursive old-ref/old-local absence scans (`:575-593`); the fixture contains no `0001-old` (confirmed by search). |
| AC8 — renumber assertion is sensitive | **met** | Reintroducing an old reference makes `fig_rn_scan_absent` emit `bad "AC30 renumber-sweep: ... leaked into ..."` (`:575-593`), so the area exits non-zero and names the sub-area; proven in scratch (`verify.md` M8). The committed mutation job is `0005`'s by design (`spec.md` AC10). |
| AC9 — recursive renumber contract pins | **met** | The intermediate-manifest phrase is pinned on both surfaces (`:618-643`); the `88`-owned closing literal is not restated, per `AC30 no-duplication`. |
| AC10 — stable token, sub-areas, mutation staging | **met** | Every emitted assertion is `AC30 <sub-area>`; all 9 declared sub-areas appear (73 assertions total, matching `verify.md`); `tests/mutation.sh:122` stages the fixture root and `AC30 mutation-staging` asserts it (`:712-729`). |
| AC11 — no duplication; existing areas stay green | **met** (static + tester evidence) | The only suite edit besides the new area is the design-sanctioned narrowing of `80-cycle-fixture.sh`'s AC13 whole-set `roadmap.md` assertion, excluding exactly the one documented path (`80-cycle-fixture.sh:61-79`); the remainder still equals the retained cyclic alias, and I confirmed it is the only whole-fixture-set `roadmap.md` scan and that no sibling fixture root on `origin/main` adds a `roadmap.md` (so the merged tree has exactly the two expected aliases). Tester reports 576/0/0 and a 727-pass merged simulation; I did not re-run the suite. |
| AC12 — scope and purity | **met** | Diff limited to `tests/**` plus this work item; no live doc, prompt, command, agent, skill, `phase` value, state file, or production checker; no new dependency, network, or `gh`. |

## Not reviewed

- **Independent suite execution.** The sandbox denies running `bash tests/run.sh`
  / `tests/mutation.sh`, so AC11's "existing areas stay green" rests on the
  tester's `verify.md` results and on my static trace (which I walked line by line
  against the fixtures and the four authority surfaces it pins). The 727-pass
  merged-tree simulation in `verify.md` was not reproduced.
- **Pre-ship reconcile.** The branch is behind `origin/main`; the merge-forward —
  including the declared class-(a) `tests/mutation.sh` staged-copy conflict that
  must retain both the sibling's `recursive-structure` line and this item's
  `recursive-integrity` line — and the post-merge integrity pass are the
  shipper's and out of scope here.
- **The `tests/README.md` Checks row and the per-rule mutation jobs** — deferred
  to `0005-guard-registration-sweep` by `spec.md`/`design.md`.
- **Manual/LLM-run residuals** (a live `/status` render, a real `/ship` reconcile,
  an actual `git mv`, the renumber no-op) — documented, not executable in CI.
