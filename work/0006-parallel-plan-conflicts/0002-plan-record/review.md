---
feature: 0006-parallel-plan-conflicts/0002-plan-record
phase: review
status: final
created: 2026-10-08
updated: 2026-10-08
parent: 0006-parallel-plan-conflicts
---

# Review — Pre-development plan publication and declared conflict record

## Verdict

**approve** — the previous pass's lone Major (the `/build` gate resolving
`origin/plan/<ref>` without ever fetching it) is genuinely fixed by the step-0
best-effort fetch plus the `unmerged_plan` / `unresolved_plan` content checks, and
the declaration home, grammar reuse, publication flow, and cross-surface
consistency satisfy AC1–AC13; what remains is documentation drift and usability
gaps (Minor/Nit), none of which breaks an acceptance criterion.

## Scope and commands

This item has no commit of its own. Its work is uncommitted on top of the shipped
`0001` tip, which is also its base. `git merge-base HEAD origin/main` is `HEAD`
(`d01f356`); `origin/main` (`a489e2d`) is the merge of `0001` and adds no content
over `HEAD` (`git diff HEAD origin/main --stat` is empty), so the 0002 diff is the
working tree against `HEAD`, equivalent to a range against `origin/main`.

Commands run (read-only; the reviewer's bash allowlist permits only git/ls/cat,
not program execution):

- `git status --short` → 10 modified tracked files, 6 untracked under
  `work/0006-parallel-plan-conflicts/0002-plan-record/`; no untracked outside it.
- `git rev-parse HEAD origin/main` → `d01f356…`, `a489e2d…`.
- `git merge-base HEAD origin/main` → `d01f3564fe1928d1af068db5d0830e507146e394`.
- `git log --oneline -8` / `git log --oneline HEAD..origin/main` → only `a489e2d`
  (the `0001` merge); `HEAD` is the `0001` ship record.
- `git diff HEAD --stat` / `git diff HEAD --numstat` / `git diff HEAD` (full diff
  read) → 10 files, +333/−22.
- `git diff HEAD origin/main --stat` → empty (trees identical).

I read the item's `spec.md`, `design.md`, `tasks.md`, `verify.md`,
`verify-tests.sh`, all ten changed surfaces, the committed checks that could be
affected (`10-readiness.sh`, `20-lifecycle.sh`, `30-permissions.sh`,
`40-inventory.sh`, `50-instructions.sh`, `60-default-agent.sh`, `70-pin.sh`,
`80-cycle-fixture.sh`, `95-split-guard.sh`, `96-signature-sweep.sh`), and
`tests/run.sh`. The ten tracked files match the design's "Affected areas"
exactly — no scope creep; `tests/**` is untouched. I recomputed the
single-source claims with `grep` (`ConflictTargetList ::=` occurs once outside
`work/`, at `docs/workflow.md:142`).

I could not execute `bash tests/run.sh` or the item suite: the read-only bash
allowlist permits only `git`/`ls`/`cat`, not program execution. I hand-traced the
checks instead (see "Test quality") and treat `verify.md`'s reported results
(`285/0` canonical, `158/0` item) as **unverified in this pass**.

## Acceptance criteria

| AC | Status | Evidence |
| -- | ------ | -------- |
| AC1 — dedicated `plan/<ref>` branch + PR | met | `docs/workflow.md:321-336`; `.opencode/agent/shipper.md:239-270`; `.opencode/command/ship.md:11-13,88-120`; `.opencode/skill/conventional-commits/SKILL.md:67-76`. Live git/PR is manual by design. |
| AC2 — development does not begin while the plan PR is unmerged | met | Gate at `docs/workflow.md:351-422` (step 0 fetch `:362-370`, content-aware `plan_ref`/`unmerged_plan`/`unresolved_plan` `:377-395`); mirrored `.opencode/agent/builder.md:57-71`, `.opencode/command/build.md:16-24`. Online enforcement is correct; offline degradation is documented (`:421-422`). Live refusal is manual by design. |
| AC3 — merged plan public on the default branch | met | `docs/workflow.md:314-336`; `.opencode/skill/pr-workflow/SKILL.md:108-138` links spec/design/tasks by repository path. Live merge is manual. Branch base under-specified (m3). |
| AC4 — declared list is part of the plan, authored at `/plan` | met | `docs/artifact-conventions.md:39-43,205`; `docs/workflow.md:128-137`; `.opencode/agent/architect.md:70-80`; `.opencode/command/plan.md:20-23`. |
| AC5 — shipped `0001` grammar reused, not forked | met | Grammar single-sourced at `docs/workflow.md:142` (only non-`work/` occurrence); six owning surfaces reference the authority and none restates `ConflictTargetList ::=`. |
| AC6 — absence/`—` = none, no container, no migration | met | `docs/workflow.md:128-137`; `docs/artifact-conventions.md:39-43`; architect/plan default `—`. |
| AC7 — child value ∪ parent `Children` cell, mismatch reported | met | `docs/workflow.md:132-135`; parent `Children` header unchanged. |
| AC8 — advisory; readiness/derived state unchanged | met | `docs/workflow.md:136-137,424-428`; readiness algorithm and derived-state table untouched (no `plan` row, no new `phase`). |
| AC9 — shipper-only git writes, on explicit invocation | met | `docs/workflow.md:321-322`; `.opencode/agent/shipper.md:148-158,239`; architect/plan carry no commit/push/PR instruction. Enforcement is prompt-level. |
| AC10 — historical/pre-flow items proceed; suite unaffected | met | `docs/workflow.md:394-396,411-413`; builder/command proceed-with-note; no committed `tests/` file changed. |
| AC11 — a revised plan is republished before development continues | met | `docs/workflow.md:344-347`; shipper revision step (`:263-266`); the content-aware gate refuses an unmerged revision (`:406-410`). An uncommitted revision is invisible to the git-only gate (m4, documented residual). |
| AC12 — malformed/unresolved is reported, never auto-repaired | met | `docs/workflow.md:135-136,170-173`. |
| AC13 — authority, frontmatter, prompts consistent; one grammar | met | Declaration home/union/advisory and the single grammar are consistent across the named surfaces; the mental-model diagram now shows `/ship plan → merge → /build` (`docs/workflow.md:18`). Unnamed routing/guardrail surfaces remain (m1, not an AC13 failure). |

13/13 criteria are addressed. AC2 and AC11 carry a documented offline residual,
not an acceptance failure.

Prior finding verified fixed this pass: the gate short-circuit (prior M1) is
neutralized by the step-0 plan-branch refresh (`docs/workflow.md:362-370`) and the
`unmerged_plan`/`unresolved_plan` content checks (`:377-395`). A retained merged
branch matches the default branch and proceeds; a later revision differs and
refuses; an advertised-but-unresolvable ref refuses rather than erroring.

## Findings

### Blockers

- None.

### Major

- None.

### Minor

- **[m1] Routing and guardrail surfaces omit plan publication, so they route
  around the gate** — `.opencode/skill/workflow-lifecycle/SKILL.md` ("Which
  command now?" routes `design.md, tasks.md unchecked? → /build`); `AGENTS.md:105`
  (the priority-critical guardrail enumerates only the approved work item and
  `/ship fix`, so `/ship plan` is not sanctioned by the always-loaded contract);
  `template/AGENTS.md`; `README.md`. The design deliberately leaves these
  unchanged to preserve the canonical `/ship [item-ref]` signature, and AC13 does
  not name them, so this is not an AC failure — but a maintainer who lives in the
  skill/README hits the gate refusal without warning, and the critical guardrail
  under-describes a sanctioned git-write path.
  Recommendation: add a plan-publication line to the skill's routing block and the
  guardrail parenthetical ("or a plan on `/ship plan <item-ref>`"); neither
  disturbs the signature sweep.

- **[m2] This item's own `design.md` is stale relative to the implemented
  authority** — `work/0006-parallel-plan-conflicts/0002-plan-record/design.md:93-107,264-267`.
  The design's `plan_gate` still lists the pre-step-0 algorithm and omits
  `unmerged_plan`/`unresolved_plan`, while the authority now opens with a
  best-effort fetch and content checks (`docs/workflow.md:361-395`); the
  retained-branch risk justification (`design.md:266`) relies on a step it does not
  list. No AC names the design's algorithm and `verify.md` residual #5 records it,
  but the plan artifact a maintainer reads is now inaccurate.
  Recommendation: the architect refreshes `design.md` in a `/plan` revision so
  design and authority agree (the reviewer cannot edit another phase's artifact).

- **[m3] Plan-mode branch base is unspecified, so the plan PR can carry unrelated
  commits** — `docs/workflow.md:328-332`; `.opencode/agent/shipper.md:241-246`.
  "Create or switch to the dedicated `plan/<ref>` branch" does not say from what.
  If the current branch already holds commits (e.g., work-in-progress on the
  item), the plan branch inherits them and the plan PR contains code, defeating
  "publish the plan before any code exists" (AC3). Low likelihood with a careful
  shipper, but the contract should pin it.
  Recommendation: state that `plan/<ref>` is created from the (freshly fetched)
  default branch.

- **[m4] An uncommitted `/plan` revision is invisible to the gate** —
  `docs/workflow.md:351-422`; recorded as `verify.md` residual #3. If the architect
  edits `design.md` in the working tree and `/build` runs without republishing, the
  gate sees the old default-branch plan and proceeds, so AC11's "before
  development continues" is unenforced for that path. The design chose a git-only,
  committed-state gate, so this is inherent rather than a coding defect.
  Recommendation: document this explicitly as an architect duty in `/plan` /
  `## Plan publication`, or have the gate also compare the working-tree
  `work/<item-ref>/` against the default branch.

- **[m5] The gate's offline path can still under-block on a stale ref** —
  `docs/workflow.md:362-395`. When `origin` is unreachable, both the `git fetch`
  and `git ls-remote` no-op, and a pre-existing stale `origin/plan/<ref>` (or
  stale `origin/<default>`) is still compared as if current; a `plan/<ref>` that
  matched the default branch at an earlier revision keeps `unmerged_plan=false`
  and can `PROCEED`. The authority already scopes this ("best-effort", "the
  refresh is ignored when `origin` is unreachable"), so this is a limit of the
  chosen offline-first design, not a false claim.
  Recommendation: add one sentence to `## Plan publication` stating that the gate
  observes committed git state it can reach and cannot detect an unmerged plan
  while offline; keep the best-effort fallback.

### Nits

- **[n1] `/ship` description order disagrees with the grammar block** —
  `.opencode/command/ship.md:2` lists `… | /ship fix … | /ship plan …`, while the
  grammar block (`:11`) and `design.md:56` list `plan` before `fix`. The order is
  forced by the signature sweep's exact `fix` substring; cosmetic.

- **[n2] Phase 2's `Next` drops the `/build <task-id>` form** —
  `docs/workflow.md:237-238`. The prior text named `/build <task-id>`; the new
  text names only `/build`. The Build section still documents task selection.

- **[n3] `plan_branch` is assigned but never used** in the gate pseudocode —
  `docs/workflow.md:360`. Remove it or use it in the `ref` computation.

- **[n4] Stale comment** — `work/0006-parallel-plan-conflicts/0002-plan-record/verify-tests.sh:23`
  says "the `Design conflicts` grammar"; it should read "`Declared conflicts`".

- **[n5] The canonical frontmatter example omits `conflicts-with`** —
  `docs/artifact-conventions.md:16-25` lists `notes`/`parent` but not the new
  field, which appears only in the Rules bullet (`:39-43`) and the `design.md`
  template (`:205`). Acceptable since the field is design-only, but a reader of the
  example alone will not see it.

## Test quality

- `verify-tests.sh` (368 lines) is a genuine content test, not a smoke script:
  exact literal, whitespace-collapsed, regex, and negative (`absent`) assertions,
  with `awk` section/subsection scoping so checks bind to the right heading rather
  than matching anywhere. The structural negatives are meaningful: grammar
  production single-sourced (count must equal 1), no `phase: plan`, no `plan`
  derived-state row, untouched readiness algorithm, and a scope check for exactly
  the ten design-named surfaces. The AC2 group (36 assertions) now pins the
  step-0 fetch, the `unmerged_plan`/`unresolved_plan` checks, and the refusal of an
  unresolvable advertised ref — the M1 fix.
- Limitation: every assertion is literal-presence; none exercises the gate's ref
  resolution, so the suite cannot prove the algorithm coherent — only that the
  mandated text is present. A reviewer still reads the pseudocode.
- `verify-tests.sh:348` asserts the modified-surface set via
  `git diff --name-only HEAD`, which holds only while the change is uncommitted;
  this is the established item-suite pattern (sibling `0006/0001`) and is not wired
  into CI, so it is not a defect, but it will report a false STRUCT failure once
  the change is committed.
- Not executed here. I hand-traced the committed checks the edits could break:
  `20-lifecycle.sh` route literals and derived-state table are untouched;
  `96-signature-sweep.sh:275,286` requires `/ship [item-ref]` and the exact
  `/ship [item-ref] | /ship fix [short description]` substring, both preserved by
  the appended plan clause; `extract_wf_headings` matches only `### <digit>. `
  headings, so the new `## Plan publication` / `### The `/build` plan gate`
  headings add no spurious signature; and `10-`/`30-`/`40-`/`50-`/`60-`/`70-`/
  `80-`/`95-` checks read surfaces this diff does not alter. No committed test
  references `conflicts-with` or `/ship plan`, so the suite is unaffected. I rely
  on `verify.md`'s reported `285/0` (canonical) and `158/0` (item) as unverified
  in this read-only pass.

## Not reviewed

- Live git/GitHub behavior (branch/commit/push/PR creation, human approval and
  merge, the gate's actual refusal): prompt-level and manual by design; only the
  shipper performs those writes, on explicit invocation. The tester's manual
  dry-run steps are at `verify.md:182-197`.
- Execution of the canonical suite and the item suite (the read-only bash
  allowlist denies program execution); traced by reading the checks.
- The mutation table in `verify.md:139-174` (self-reported; not reproducible
  here).
- Merge-time contract, readiness/derived-state, and the deferred fixture guards
  owned by sibling `0003-conflict-check` / `0004-conflict-guards`.
