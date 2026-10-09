---
feature: 0007-phase-backtracking/0001-backtracking-model
phase: test
status: final
created: 2026-10-08
updated: 2026-10-08
parent: 0007-phase-backtracking
notes: "Documentation-only deliverable. Per spec.md non-goals ('committed fixtures, agreement areas, and mutation coverage for the model — owned by 0007-backtracking-guards') and design.md Test strategy, no new committed check area was added; committed guard coverage is 0007's scope. Verification is the existing suite plus recorded manual inspection of the named surfaces. No UI surface, so no /visual pass."
---

# Verification — Phase-backtracking and revision model

## Scope and approach

This item's deliverable is three documentation surfaces
(`docs/workflow.md`, `docs/artifact-conventions.md`, `AGENTS.md`). Its own
`spec.md` non-goals and `design.md` Test strategy explicitly assign **committed
fixtures, agreement areas, and mutation coverage for the model** to the sibling
`0007-backtracking-guards`; the design's stated verification is "the existing
suite plus observable inspection of the named surfaces". Adding a new
`tests/checks/*` agreement area here would violate that non-goal and overlap
`0007`. No automated test was therefore added, weakened, skipped, or deleted.
Each acceptance criterion is verified below either by the existing suite or by a
recorded inspection command with its observed result.

## Commands run

| Command | Result | Notes |
| ------- | ------ | ----- |
| `bash tests/run.sh` | PASS | `TOTAL: 334 passed, 0 failed, 0 skipped`; exit 0 |
| `git diff --stat` | PASS | only `AGENTS.md`, `docs/artifact-conventions.md`, `docs/workflow.md`, `work/…/tasks.md` changed |
| `git status --porcelain -- .opencode/ template/ README.md tests/` | PASS | clean — no new command/agent/skill, no inventory surface touched |
| `diff <(git show HEAD:docs/workflow.md \| grep 'request-changes') <(grep 'request-changes' docs/workflow.md)` | PASS | `IDENTICAL` — the shipped rework row is byte-for-byte unchanged |
| `diff <(git show HEAD:docs/artifact-conventions.md \| grep 'phase: spec  ') <(grep 'phase: spec  ' docs/artifact-conventions.md)` | PASS | `PHASE ENUM UNCHANGED` |
| `grep -rn -i 'route back\|reverse transition\|reverse edge\|backtrack' .` (excluding `work/`, `scratch/`) | PASS | the model is defined only in `docs/workflow.md`, documented in `docs/artifact-conventions.md`, referenced in `AGENTS.md`; no rival reverse-transition rule |
| `grep -n '^## ' docs/workflow.md` | PASS | `## Phase reversal (backtracking)` at `:557`, immediately before `## Derived state` at `:633` |
| `sed -n '557,632p' docs/workflow.md` + edge grep | PASS | all seven sanctioned edges and the exception list present |

## Acceptance coverage

| Criterion | Test(s) / evidence | Result |
| --------- | ------------------ | ------ |
| AC1 | manual: `docs/workflow.md:557-566` — "A **backtrack** is a sanctioned reverse transition on the same **unshipped** work item, triggered by a detected defect in an earlier phase's artifact or output"; explicitly "not normal forward progression, and not the plan-publication **revision** flow". Both distinctions present. | PASS |
| AC2 | manual: `docs/workflow.md:568-597` — general rule at `:570-571`; edge table `:576-584` contains `/build`→`/plan`, `/plan`→`/spec`, `/test`→`/build`, `/test`→`/plan`, `/test`→`/spec`, `/review`→`/build`, any child phase→parent `roadmap.md`; six exception bullets at `:586-597` (no self-target, shipped excluded, strictly earlier, `roadmap` nested-child-only, recorded finding precedes, detector never edits). | PASS |
| AC3 | manual: `docs/workflow.md:599-605` — control returns to target phase, owning agent revises, detecting phase records but never edits, "only the owning phase writes its artifact" invariant stated unchanged. | PASS |
| AC4 | manual: `docs/workflow.md:607-614`; `docs/artifact-conventions.md:451-500` — `backtracks.md` record template with `feature/record/created/updated` (no `phase`), `Finding <n>` fields (detecting phase, target phase, affected, evidence, status `open`), appended `Resolution <n>`, append-only "no entry is ever edited, reordered, or removed", "not a phase artifact … does not by itself determine the item's derived phase". | PASS |
| AC5 | manual: `docs/workflow.md:616-622` — downstream artifacts marked `stale: <phase>`, "nothing is deleted or silently rewritten, and the pre-revision content stays recoverable from committed git history"; `docs/artifact-conventions.md:46-52` marker rule. | PASS |
| AC6 | manual: `docs/workflow.md:639-641` — row "earliest `stale:` marker … names phase `P` → `P` (backtracked)"; `:654-657` precedence "evaluated **before** the artifact-presence rows", "never read as the item's current phase artifact nor counted as a satisfied downstream prerequisite"; `:622` forward re-run. | PASS |
| AC7 | manual + baseline: phase enumeration byte-identical to `HEAD` (diff above); markers documented at `docs/artifact-conventions.md:25-26,46-59`; derived precedence at `docs/workflow.md:639-664`; `:57-59` states markers are distinct from `status`. No new `phase` value introduced. | PASS |
| AC8 | `tests/checks/20-lifecycle.sh` "review request-changes -> /build" route cases pass (`bash tests/run.sh`); `diff` above shows the `review.md` verdict `request-changes` → `build (rework)` row is `IDENTICAL` to `HEAD`; `docs/workflow.md:661-666` presents it as the pre-existing instance and states no second rework mechanism. | PASS |
| AC9 | manual: `docs/workflow.md:860-867` — "route back" clause now "take the sanctioned reverse transition in `## Phase reversal (backtracking)`: record the finding and hand control to the phase that owns the wrong artifact"; report-failures and destructive-git-confirmation rules unchanged; never-rewrite clause retained. | PASS |
| AC10 | manual: `docs/workflow.md:624-631` — shipped item excluded, "its reversal is the post-ship reopen case, a separate path owned by `0005-post-ship-pr-denial`", "changes neither the shipped signal (`ship.md` presence) nor the `Depends on`/readiness contract". | PASS |
| AC11 | manual: single authority `docs/workflow.md:557-559`; record/markers in `docs/artifact-conventions.md`; reference bullet in `AGENTS.md:125-128`; repo-wide grep found no surface stating a conflicting reverse-transition rule. | PASS |
| AC12 | `bash tests/run.sh` → PASS (334/0/0, exit 0); `git diff --stat` limited to the three docs + `tasks.md`; inventory surfaces (`.opencode/`, `README.md`, `template/`) untouched, so no documented count changes; six phase commands and `Depends on`/readiness untouched. | PASS |

## Edge-case coverage

| Edge case | Evidence | Result |
| --------- | -------- | ------ |
| No downstream artifacts yet | `docs/workflow.md:616-622` conditions marking on existing downstream artifacts; derived phase is the target (`:639-641`). Behavior follows from the general rule. | PASS (implied) |
| Self-target | `docs/workflow.md:583-584` — "A phase targeting itself is not a reversal and is refused." | PASS |
| Unrecorded backtrack | `docs/workflow.md:594-596` — "A recorded finding precedes the edge … there is no unrecorded reversal." | PASS |
| Target owns no artifact (`/build`) | edge table `docs/workflow.md:580,582` lists the `/build` rework edges; downstream stale applies by the general rule `:616-622`. | PASS (implied) |
| Open backtrack not yet resolved | effective status `docs/artifact-conventions.md:497-499`; derived target row `docs/workflow.md:639-641`. | PASS |
| Revised artifact clears its marker | `docs/artifact-conventions.md:48-52` — "The owning phase clears the marker when it re-runs". | PASS |
| Sequential backtracks | `docs/workflow.md:639-641,654-656` state "earliest `stale:` marker" → derives `P`. Ordering semantics are not spelled out (see residual risk). | PARTIAL |
| Shipped item | `docs/workflow.md:624-631`. | PASS |
| Stale artifact mistaken for current | `docs/workflow.md:621-622,654-657`. | PASS |
| Out-of-order record entries | `docs/artifact-conventions.md:499-500` — "malformed and is reported, not reordered". | PASS |
| Two items in parallel | scope limited to "the same work item" `docs/workflow.md:560,626`; no other item's state or readiness touched. | PASS (implied) |
| Marker versus `status` | `docs/artifact-conventions.md:57-59` — distinct and never overloaded. | PASS |

## Gaps and residual risk

- **No committed automated guard for the new model (deliberate).** The model
  text can drift between this item and `0007-backtracking-guards`, which owns the
  fixture-based agreement areas and mutation coverage. This is the scope boundary
  fixed by `spec.md` non-goals and `design.md` Test strategy, not an oversight;
  `0007` should pin the section literals (edge table, exception list, derived
  precedence rows, `backtracks.md` shape).
- **"earliest `stale:` marker" ordering is undefined.** `docs/workflow.md:640,655`
  says the derived phase is the earliest stale marker's target, but does not
  define "earliest" (lifecycle-phase order vs. record order). For the spec's
  sequential-backtracks case (`/test`→`/plan` then `/plan`→`/spec`, deriving the
  earliest outstanding target `/spec`), the intent should be confirmed when
  `0006-status-and-derived-state` implements derivation and `0007` pins it.
- **Prompt surfaces not yet wired (sibling scope).** `.opencode/agent/builder.md:38`
  ("stop and route back"), `.opencode/agent/architect.md:106` ("route back"), and
  `.opencode/skill/workflow-lifecycle/SKILL.md` ("stop and report") do not yet
  invoke the record or the `stale:` marking; `0002-reverse-phase-routing`/
  `0006-status-and-derived-state` own that wiring. These are consistent with, not
  contradictory to, the model (`docs/workflow.md:557` states the model as the
  single authority), so AC11 is met as written.
- **Spec prose count observation (not a defect).** AC7 says "the six existing
  `phase` values"; the frontmatter enumeration lists eight tokens
  (`spec | design | roadmap | tasks | test | visual | review | ship`). The
  implementation leaves the enumeration byte-identical (verified), introduces no
  new value, and reuses the existing vocabulary, so the testable intent holds; the
  "six" is a spec-count imprecision that does not change the outcome.
- **No UI surface.** This item is documentation-only, so no `/visual` pass was
  run; `visual.md` is intentionally absent.
