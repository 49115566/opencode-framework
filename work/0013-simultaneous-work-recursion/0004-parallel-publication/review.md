---
feature: 0013-simultaneous-work-recursion/0004-parallel-publication
phase: review
status: final
created: 2026-10-13
updated: 2026-10-13
parent: 0013-simultaneous-work-recursion
---

# Review — Parallel plan publication under recursion

## Verdict

**approve** — every acceptance criterion is implemented and met by the diff; no
finding of any severity survives.

## Scope and base ref

- Repository is on `plan/0013-simultaneous-work-recursion-0004-parallel-publication`
  at `HEAD = 4e23708` (the plan commit); `git merge-base HEAD origin/main` is
  `4e23708`, and `origin/main` already contains it, so the build is the
  **uncommitted working-tree change on top of `HEAD`**.
- Commands used:
  - `git merge-base HEAD origin/main` → `4e23708`
  - `git status` → 8 modified live surfaces + `tasks.md`; `verify.md` untracked
  - `git diff` (full working-tree diff reviewed)
  - `git diff --stat` → 9 files, +159/−81
  - `git log --oneline -15`, `git show --stat 4e23708`
  - `git diff HEAD -- docs/workflow.md` (to separate build edits from pre-existing
    plan-publication prose)
  - `grep`/`glob` over `docs/`, `.opencode/`, `CONTRIBUTING.md`, `tests/` for
    cross-surface consistency and live-surface old-form literals.
- No `challenges.md` exists under the item, so there was no open challenge to
  adjudicate.

## Findings

None. No Blocker, Major, Minor, or Nit survived scrutiny.

## Acceptance criteria

| Criterion | Result | Evidence |
| --------- | ------ | -------- |
| AC1 distinct refs → distinct branch names at any depth | met | `flatten` is injective; `00`-segment alphabet excludes `+` (`.opencode/skill/conventional-commits/SKILL.md:52-65`); depth-3 example `SKILL.md:81,83-86`; `CONTRIBUTING.md:76-79`. |
| AC2 deterministic + reversible; same rule for plan and ship | met | `SKILL.md:57-65` (`ref.split("/").join("+")` / `flat.split("+")` round-trip); both branch kinds share the token `SKILL.md:67-75`. |
| AC3 classic `/`→`-` collision now distinct | met | `SKILL.md:88-94` superseded-form note; `+` example `docs/workflow.md:624-628`. |
| AC4 manifest-only plan is publishable | met | `.opencode/agent/shipper.md:157-165` (`or manifest.md exists`); `.opencode/command/ship.md:92-96`; `docs/workflow.md:616-619`. |
| AC5 decomposing-node plan = manifest + own artifacts + immediate child `.gitkeep`, no child in-flight artifact | met | `shipper.md:282-287`; `ship.md:104-109`; `docs/workflow.md:632-636`; `.opencode/skill/pr-workflow/SKILL.md:127-137`. |
| AC6 nested child publishes only its own plan (no parent/sibling) | met | staging scoped to `work/<item-ref>/` and "each child publishes its own plan" (`shipper.md:282-287`; `docs/workflow.md:634-636`). |
| AC7 gate proceeds for a manifest-only published plan | met | `docs/workflow.md:705-710` (`published = … design.md or … manifest.md`); `.opencode/agent/builder.md:90-95`; `.opencode/command/build.md:28-32`. |
| AC8 gate refuses a differing/unresolved plan branch; offline degrades | met | `docs/workflow.md:703-704,711-715,742-746` — content-aware refuse, unresolved-ref refuse, best-effort offline unchanged. |
| AC9 gate uses the collision-free flattened name | met | `docs/workflow.md:675-676` (`ref = flatten(item_ref)`); `builder.md:90-92`; `build.md:28-29`. |
| AC10 concurrent publications are independent, no lock/ordering | met | `docs/workflow.md:624-631`; `shipper.md:275-281`; `ship.md:97-103`. |
| AC11 no migration; old-format unmerged branch unrecognized | met | `docs/workflow.md:660-665,734-737`; `SKILL.md:92-94`. |
| AC12 one rule, defined once, referenced (incl. gate mirrors) | met | single home `SKILL.md:50-94`; formula literal appears nowhere else in live surfaces (grep); references at `docs/workflow.md:624-627,675-676`, `shipper.md:222,275-277`, `ship.md:54-56,97-99`, `builder.md:90-92`, `build.md:28-29`, `CONTRIBUTING.md:70-74`. Old-form literals remain only in the skill's superseded note. |
| AC13 shipper-only git writes, explicit invocation; plan mode writes no `ship.md`/pre-flight/reconcile/ship branch | met | `docs/workflow.md:643-645`; `shipper.md:160-161,297-301`; `ship.md:115-119,126-127`. |
| AC14 conflicts stay advisory; no new readiness edge/`phase`/state file | met | `docs/workflow.md:748-752`; `build.md:39-44`; diff adds no `phase:` token and touches no `artifact-conventions.md`/state file. |
| AC15 configured suite green; suite reads no live `work/**` | met (reported) | `verify.md` records `bash tests/run.sh` → 495/0/0, exit 0; suite is contractually read-only (`tests/run.sh:20`, `tests/README.md:30`, per-check headers). Not independently re-run in this pass (read-only review; bash execution is not permitted). Nothing in `tests/**` pins the changed text, so the suite is not regressed by the edit. |

All 13 spec edge cases are addressed by the diff: pure container/hybrid (AC4/AC5),
depth ≥ 3 (`SKILL.md:81`), classic collision (AC3), siblings (injective flatten),
concurrent publication (AC10), already-merged no-op (`docs/workflow.md:658-659`),
old-format unmerged branch (`:734-737`), advertised-but-unresolvable (`:742-744`),
unreachable origin (`:745-746`), no plan at all (`:616-619` precondition admits no
other state), secrets (`shipper.md:166,282`; `docs/workflow.md:623`).

## Correctness, security, tests, scope

- **Correctness.** The gate change is behavior-preserving and additive: `published`
  is a plain widening of the old `design.md`-only check (`docs/workflow.md:705-710`);
  the unmerged/unresolved/offline branches are untouched (`:711-746`). `flatten`
  is a bijection on the canonical grammar; every surface that names a branch now
  uses it. No contradiction found between the authority (`docs/workflow.md`), the
  prompts, and the mirrors.
- **Security / secrets.** No credentials, tokens, or `.env` content introduced. The
  secrets precondition is preserved on the plan path (`docs/workflow.md:623`;
  `shipper.md:166,282`).
- **Tests.** No committed test/fixture added, which is the **specified** behavior:
  the spec defers "new committed fixture areas, agreement areas, or mutation
  coverage" to Roadmap 5, and the design's test strategy is cross-surface
  read-through plus the existing suite. I read the suite; it reads no live
  `work/**` and pins none of the changed strings, so it is a valid regression net
  for this change. Residual risk (no committed live-surface guard for the rule) is
  correctly recorded in `verify.md`.
- **Convention fit.** The diff touches exactly the eight surfaces the design's
  "Affected areas" lists plus `tasks.md` check boxes; `AGENTS.md`,
  `docs/artifact-conventions.md`, the derived-state table, the merge-time contract,
  and `tests/**` are correctly untouched. Frontmatter, cross-references, and the
  conventional-commits / pr-workflow skill shapes are preserved.
- **Backward compatibility.** Merged plans are read from the default branch; an
  old-form unmerged branch is invisible to the gate and falls to case 3, as
  documented. This matches the spec's "no migration" decision (AC11) and the
  framework's own item branch (`plan/0013-…-0004-…`), recorded in `verify.md`.

## Notes

- **AC12 interpretation.** `docs/workflow.md:626-627`, `builder.md:92`, and
  `CONTRIBUTING.md:73-74` carry a one-line gloss of the rule alongside the named
  reference. I considered whether that is a prohibited "restatement" under AC12.
  The authoritative definition (the formula) is single-homed; the gloss is a
  consistent summary that accompanies the reference, which matches the framework's
  established treatment of a summarized-but-single-sourced rule (cf. the readiness
  gloss in `.opencode/agent/status.md` and `tests/checks/10-readiness.sh`). I
  therefore read AC12 as met, not as a defect. Flagged here only for transparency.
- The hosting provider's acceptance of `+` in ref names is unverified offline
  (only `git check-ref-format` is reported); the design records this as low
  likelihood with a one-line remedy in the rule's single home. Not a defect.

## Not reviewed

- No `visual.md` (non-UI documentation/prompt change).
- No independent execution of `bash tests/run.sh` was performed in this read-only
  pass; the suite result is taken from `verify.md` and cross-checked by inspection
  that the suite neither reads live `work/**` nor pins the changed strings.
- Historical `work/**/verify-tests.sh` scripts that still assert the superseded
  `NNNN-slug-MMMM-slug` literal are shipped and explicitly out of scope (spec
  non-goal: no historical migration).
