---
feature: 0013-simultaneous-work-recursion/0004-parallel-publication
phase: test
status: final
created: 2026-10-13
updated: 2026-10-13
parent: 0013-simultaneous-work-recursion
notes: "Doc/prompt-only change. No committed agreement area added: the spec non-goal defers new fixture/agreement areas and mutation coverage to Roadmap 5, and the design's test strategy is cross-surface read-through plus the existing suite. Verification therefore uses an independent, read-only, falsifiable document harness (run inline; scratch/ is gitignored and not writable here) plus the canonical suite."
---

# Verification — Parallel plan publication under recursion

## Summary

This is a documentation/prompt change to eight live surfaces (the
`conventional-commits` skill, `docs/workflow.md`, `shipper.md`/`ship.md`, the
gate mirrors `builder.md`/`build.md`, the `pr-workflow` skill, and
`CONTRIBUTING.md`). All fifteen acceptance criteria and all thirteen spec edge
cases are verified against the **current working tree** by the canonical suite
plus an independent, read-only, falsifiable document harness. **No
acceptance-criterion defect was found.**

No committed agreement area or fixture was added: the spec explicitly defers
"new committed fixture areas, agreement areas, or mutation coverage" to Roadmap 5,
and the design's "Test strategy" is *cross-surface read-through, a manual encoding
check, and the existing suite*. The independent harness was run inline rather
than persisted, matching the precedent for the framework's other doc-only items
(e.g. `0012-roadmap-deprecation/0001-deprecation-contract`, verified by a
scratch/inline harness — `scratch/` is gitignored and is not writable under this
phase's edit policy). A committed live-surface regression guard for this rule is
recorded as a follow-up below.

There is no `work/0013-simultaneous-work-recursion/0004-parallel-publication/challenges.md`,
so there was no open challenge to adjudicate.

## Commands run

| Command | Result | Notes |
| ------- | ------ | ----- |
| `bash tests/run.sh` | **PASS** | `TOTAL: 495 passed, 0 failed, 0 skipped`; exit 0. The canonical, configured suite (AGENTS.md Project profile `Test:`). |
| inline read-only document harness (`bash -s`) | **PASS** | 60/60 assertions; independent, falsifiable greps of the live surfaces, one per AC below. |
| `git check-ref-format --branch <flattened>` | **PASS** | Accepts `plan/0013-simultaneous-work-recursion+0004-parallel-publication`, `feat/…+…`, and `feat/0001-a+0002-b+0003-c`; the old-form name is a *distinct* valid ref (the collision AC3 removes). |
| flatten injectivity/reversibility evaluation | **PASS** | `ref.split("/").join("+")` round-trips and is injective on: the classic-collision pair, two siblings, and a depth-3 reference. |
| `rg -n 'with "/" -> "-"\|replaced by \`-\`\|NNNN-slug-MMMM-slug' docs .opencode CONTRIBUTING.md AGENTS.md README.md tests` | only the skill's superseded note | No live surface forks the old `/`→`-` rule. |
| `git diff --name-only` | 8 expected surfaces + `tasks.md` | Scope is exactly the design "Affected areas"; `docs/artifact-conventions.md` and `AGENTS.md` are untouched. |
| `git diff \| grep -E '^\+.*phase:'` | empty | No new `phase` value or state file introduced. |
| `git status --porcelain \| grep '^??'` | empty | No new tracked artifact; `scratch/` is gitignored. |

## Acceptance coverage

| Criterion | Test(s) / evidence | Result |
| --------- | ------------------ | ------ |
| AC1 distinct refs → distinct branch names at any depth | Harness `AC1 depth-2/depth-3` + CONTRIBUTING `+` examples; flatten eval (classic pair, siblings, depth-3 all distinct). `.opencode/skill/conventional-commits/SKILL.md:77-86`; `CONTRIBUTING.md:77-79`. | PASS |
| AC2 deterministic + reversible; same rule for plan and ship | Harness `AC2` (definition, reserved-separator rationale, round-trip, `a **ship branch** is `<type>/<flatten(ref)>``, `` `plan/<flatten(ref)>` ``); flatten eval round-trip. SKILL.md:52-75. | PASS |
| AC3 classic `/`→`-` collision now distinct | Harness `AC3 classic collision named`; flatten eval of `…/0004-parallel-publication` vs `…-0004-parallel-publication` differ. SKILL.md:88-94. | PASS |
| AC4 manifest-only plan is publishable | Harness AC4 (4 assertions). `docs/workflow.md:616-619`; `.opencode/agent/shipper.md:98-100,162-165`; `.opencode/command/ship.md:92-94`. | PASS |
| AC5 decomposing-node plan = manifest + own artifacts + immediate child `.gitkeep`, no child in-flight artifact | Harness AC5 (7 assertions). `.opencode/agent/shipper.md:282-288`; `docs/workflow.md:632-636`; `.opencode/command/ship.md:104-109`; `.opencode/skill/pr-workflow/SKILL.md:128-134`. | PASS |
| AC6 nested child publishes only its own plan (no parent/sibling) | Harness AC6. `.opencode/agent/shipper.md:286-287` ("each child publishes its own plan"); `docs/workflow.md:634-636`; staging scoped to `work/<item-ref>/`. | PASS |
| AC7 gate proceeds for a manifest-only published plan | Harness AC7. `docs/workflow.md:705-710` (`published = … design.md or … manifest.md`); `.opencode/agent/builder.md:90-98`; `.opencode/command/build.md:28-32`. | PASS |
| AC8 gate refuses a differing/unresolved plan branch; offline degrades | Harness AC8. `docs/workflow.md:703-704,711-715,726-746`. | PASS |
| AC9 gate uses the collision-free flattened name | Harness AC9. `docs/workflow.md:675-676` (`ref = flatten(item_ref)`); `builder.md:90-93`; `build.md:28-30`. | PASS |
| AC10 concurrent publications are independent, no lock/ordering | Harness AC10. `docs/workflow.md:629-631`; `.opencode/agent/shipper.md:279-281`; `.opencode/command/ship.md:101-103`. | PASS |
| AC11 no migration; old-format unmerged branch unrecognized | Harness AC11. `docs/workflow.md:660-665,734-737`; SKILL.md:92-94. | PASS |
| AC12 one rule, defined once, referenced (incl. gate mirrors) | Harness AC12: `ref.split("/").join("+")` single-homed (skill=2 occurrences, 0 elsewhere); six surfaces reference `.opencode/skill/conventional-commits/SKILL.md` → "Branch naming"; old-rule literals only in the skill's superseded note. | PASS |
| AC13 shipper-only git writes, explicit invocation; plan mode writes no `ship.md`/pre-flight/reconcile/ship branch | Harness AC13. `.opencode/agent/shipper.md:160-161,300-301`; `docs/workflow.md:643-645`; `.opencode/command/ship.md:118-119`. | PASS |
| AC14 conflicts stay advisory; no new readiness edge/`phase`/state file | Harness AC14. `docs/workflow.md:748-749`; `.opencode/command/build.md:39-44`; diff adds no `phase:` token and touches no artifact-conventions/state file. | PASS |
| AC15 configured suite green; suite reads no live `work/**` | `bash tests/run.sh` → 495/0/0, exit 0; harness AC15 (`grep -rnE 'work/[0-9]{4}-' tests/checks tests/lib.sh tests/run.sh` → none); suite's own AC23/AC24 read-only-contract assertions pass. | PASS |

### Edge cases (spec)

| Edge case | Coverage | Result |
| --------- | -------- | ------ |
| Pure container | AC4 (precondition) + AC7 (gate) | PASS |
| Hybrid node | AC5: "its own phase artifacts when present" (workflow/shipper/ship) | PASS |
| Depth ≥ 3 | Harness push/pull eval + SKILL.md depth-3 row + CONTRIBUTING depth-3 example | PASS |
| Classic collision | AC3 + flatten eval | PASS |
| Sibling children | flatten eval: two `0004-parallel-publication` siblings map to distinct names | PASS |
| Concurrent publication | AC6 + AC10 | PASS |
| Already-merged plan is a no-op | `docs/workflow.md:658-659` Idempotence bullet unchanged; no-migration clause | PASS |
| Unmerged old-format branch | AC11 (gate case 3) | PASS |
| Plan branch advertised but unresolvable locally | AC8 (`unresolved_plan = true` → refuse) | PASS |
| Unreachable origin | AC8 offline-degrade bullet | PASS |
| No plan at all | Precondition (spec+design **or** manifest) admits no other state; `docs/workflow.md:616-623` | PASS |
| Secrets | `.opencode/agent/shipper.md:166,282`; `docs/workflow.md:623` ("plan diff contains no secrets") | PASS |

## Gaps and residual risk

- **No committed live-surface regression guard for the branch rule.** The spec's
  non-goal defers "new committed fixture areas, agreement areas, or mutation
  coverage" to Roadmap 5, so this item intentionally adds none. Consequence: a
  future edit could re-fork the `/`→`-` rule or drop a manifest-published
  recognition without the canonical suite failing. Follow-up suggestion (Roadmap
  5): add a live-surface agreement area pinning `flatten(ref)`'s single home and
  the gate's `design.md`/`manifest.md` published condition.
- **Prompt-behavior-only criteria.** AC4–AC14 describe shipper/builder behavior
  and the gate algorithm, which are prompt text, not executable code. They are
  verified by read-through against the live prompts/docs (as the design's test
  strategy prescribes); there is no runtime to exercise offline. No automated
  execution of the gate/publication was possible.
- **Hosting provider acceptance of `+` in refs is unverified offline.** Only
  `git check-ref-format` was exercised (accepts it); no `gh`/network probe was
  run. The design records this as low likelihood and a one-line change in the
  rule's single home if a host objects.
- **Historical `work/**/verify-tests.sh` scripts** still assert the superseded
  `NNNN-slug-MMMM-slug` literal (`work/0006-parallel-plan-conflicts/0002-plan-record/verify-tests.sh`,
  `work/0002-agentic-roadmaps/verify-tests.sh`). They are shipped and out of scope
  (non-goal: no historical migration), and the canonical suite never reads live
  `work/**` (confirmed by AC15). Recorded, not edited — matches the design risk.
- **This item's own plan branch** was published under the superseded
  `plan/0013-simultaneous-work-recursion-0004-parallel-publication` name (commit
  `4e23708`). The new gate derives the collision-free name and will not recognize
  it, falling to case 3 (no publication recorded) — the documented AC11
  no-migration behavior, not a defect.

No test was weakened, skipped, or deleted; no production file was modified.
