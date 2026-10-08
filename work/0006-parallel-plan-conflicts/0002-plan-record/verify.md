---
feature: 0006-parallel-plan-conflicts/0002-plan-record
phase: test
status: final
created: 2026-10-08
updated: 2026-10-08
parent: 0006-parallel-plan-conflicts
notes: "Docs + prompts only; no runtime code, no UI. AC1-AC13 and every spec edge case are encoded as content assertions in work/0006-parallel-plan-conflicts/0002-plan-record/verify-tests.sh (158 passed, 0 failed this pass; 8 assertions added for the plan PR declaration and the publication flow's human-approval / no-shipped-state safeguards). The canonical suite bash tests/run.sh is the regression gate (285 passed, 0 failed, 0 skipped). Non-vacuity proven by 31 mutations run this pass in a throwaway copy (/tmp/opencode/mut), all caught and named; the unmutated control passed (158/0). The reviewer's Major (M1, the gate never fetches the plan branch) is fixed in the current tree: step 0 fetches the plan branch best-effort and an unresolvable advertised ref refuses. Live git/GitHub behavior (branch/PR creation, merge, gate refusal) remains documented and manual; only the shipper performs those writes on explicit invocation. Committed fixture-based guards remain deferred to sibling 0004-conflict-guards. No test weakened, skipped, or deleted."
---

# Verification — Pre-development plan publication and declared conflict record

## Summary

All thirteen acceptance criteria of
`work/0006-parallel-plan-conflicts/0002-plan-record` are satisfied against the
current working tree, and every spec edge case is covered. The deliverable is
documentation and prompts only (ten surfaces changed), so the automatable
evidence is a read-only item suite,
`work/0006-parallel-plan-conflicts/0002-plan-record/verify-tests.sh`, which
encodes AC1–AC13 and the edge cases as content assertions, plus the canonical
committed suite as the regression gate.

- Item suite: **158 passed, 0 failed** (exit `0`); 8 assertions added this pass.
- Canonical suite `bash tests/run.sh`: **285 passed, 0 failed, 0 skipped** (exit
  `0`).
- Sibling item suite `…/0001-conflict-declaration-model/verify-tests.sh`:
  **79 passed, 0 failed** (the shipped declaration grammar this item consumes is
  intact).
- The change touches exactly the ten design-named surfaces; `tests/` is
  unchanged and no production surface was modified by this verification pass.
- Non-vacuity: 31 independent mutations in a throwaway copy each produced a
  named failure; the unmutated control passed (see "Mutation evidence").

### Change since the prior verify/review passes

The working tree changed after `review.md` was written. This pass confirms the
reviewer's findings against the updated tree:

- **Reviewer M1 (Major: the gate resolves `plan_ref` to `origin/plan/<ref>` but
  never fetches that ref) — addressed.** Step 0 now sets
  `remote_plan = git ls-remote --heads origin plan/<ref> returns a ref` and, when
  the remote advertises one, runs `git fetch origin plan/<ref>` best-effort
  (`docs/workflow.md:363-370`). A ref the remote advertises but that still does
  not resolve locally sets `unresolved_plan = true` (`docs/workflow.md:385`),
  step 1 proceeds only when `not unmerged_plan and not unresolved_plan`
  (`:387-388`), and step 2 refuses when `plan_ref is not none or unresolved_plan`
  (`:390`). This closes both failure modes the reviewer named: the stale
  remote-tracking ref is refreshed (no under-block of a later revision), and an
  unresolvable advertised ref refuses rather than erroring or reading as a match
  (no over-block / undefined outcome). `.opencode/agent/builder.md:57-69` and
  `.opencode/command/build.md:16-24` mirror the fetch scope and the unresolvable
  refusal. The suite asserts all of it (AC2 group, 36 assertions).

- **Coverage additions this pass (8 assertions).** Mutation testing found three
  surfaces whose removal the prior 150-assertion suite did not catch: the plan PR
  template's declaration section, the human-approval precondition on the three
  plan-publication surfaces, and the "plan mode writes no shipped state"
  safeguard on the same three. Assertions were added for each
  (`verify-tests.sh` AC3 and AC13 groups); every one is now proven caught by a
  dedicated mutation.

- `review.md` itself was not rewritten (it is another phase's artifact and its
  verdict is the reviewer's to revise); the reviewer will re-assess the updated
  tree.

## Commands run

| Command | Result | Notes |
| ------- | ------ | ----- |
| `bash tests/run.sh` | PASS | `TOTAL: 285 passed, 0 failed, 0 skipped`, exit `0` — regression gate |
| `bash work/0006-parallel-plan-conflicts/0002-plan-record/verify-tests.sh` | PASS | `TOTAL: 158 passed, 0 failed`, exit `0` — AC1–AC13 + edge cases (was 150; +8 for the plan PR declaration, human approval, and no-shipped-state) |
| `bash work/0006-parallel-plan-conflicts/0001-conflict-declaration-model/verify-tests.sh` | PASS | `TOTAL: 79 passed, 0 failed`, exit `0` — consumed 0001 grammar intact |
| `bash -n work/0006-parallel-plan-conflicts/0002-plan-record/verify-tests.sh` | PASS | syntax OK |
| `git diff --name-only HEAD` | PASS | exactly the ten design-named surfaces (list below) |
| `git status --porcelain -- tests/` | PASS | empty — no committed `tests/` file changed by this item |

Modified surfaces (`git diff --name-only HEAD`, sorted):
`docs/workflow.md`, `docs/artifact-conventions.md`,
`.opencode/agent/{architect,builder,shipper}.md`,
`.opencode/command/{build,plan,ship}.md`,
`.opencode/skill/conventional-commits/SKILL.md`,
`.opencode/skill/pr-workflow/SKILL.md`.

## Acceptance coverage

The "Test(s)" column names the assertion group in `verify-tests.sh`; each named
assertion is a literal content check over a live surface (`need`/`needflat`/
`needE`/`absent`). Criteria whose *behavior* requires real git/GitHub actions are
split: the documented contract is asserted as content, and the live behavior is
listed as manual with steps below the table.

| Criterion | Test(s) | Result |
| --------- | ------- | ------ |
| AC1 — published plan is committed on a dedicated plan branch with a PR | AC1 (9): `## Plan publication`; `/ship plan` mode; dedicated `plan/<ref>` branch on authority + shipper + ship command + conventional-commits; branch example; no new `/publish` command | PASS (content) |
| AC2 — development does not begin while the plan PR is unmerged | AC2 (36): gate subsection + `plan_gate(item_ref)`; step-0 best-effort `git fetch origin <default>` **and `git fetch origin plan/<ref>`**; remote `plan/<ref>` probe; content-aware `plan_ref` resolution; `unmerged_plan = git diff --quiet …`; `unresolved_plan` for an advertised-but-unresolvable ref; `… and not unmerged_plan and not unresolved_plan -> PROCEED`; `if plan_ref is not none or unresolved_plan -> REFUSE`; "Case 2 is content-aware"; an unmerged revision blocks development after a first plan merged; builder/build-command refuse, refresh the plan ref, and refuse an unresolvable ref; offline-first/git-only; builder issues no commit/PR | PASS (content); live refusal manual |
| AC3 — merged plan artifacts are public on the default branch | AC3 (9): published to shared default branch; PR links artifacts by path and prints declared conflicts; plan PR template links spec/design/tasks and carries `## Declared conflicts` + the plan-only Testing case; shipper publishes | PASS (content); live merge manual |
| AC4 — declared list is part of the committed plan and authored at `/plan` | AC4 (6): artifact-conventions frontmatter rule + template field; architect authors it; `/plan` authors it; authority states the home | PASS |
| AC5 — shipped `0001` grammar reused; three kinds; comma-separated; `—`; no second grammar | AC5 (14): production single-sourced in `docs/workflow.md` (count=1); six surfaces reference the authority; none restates `ConflictTargetList ::=` | PASS |
| AC6 — absence/`—` = none; no extra container; no migration | AC6 (5): authority absence/`—` + no container; artifact-conventions rule; no migration; architect/plan default `—` | PASS |
| AC7 — child value ∪ parent `Children` cell; disagreement reported | AC7 (3): union stated; disagreement reported, not silently resolved; parent column untouched | PASS |
| AC8 — advisory; no readiness edge/reorder; derived state unchanged | AC8 (9): advisory on authority + plan-publication; readiness algorithm intact and carries no `conflicts-with` input; derived-state table has no `plan` row; phase vocabulary unchanged; no new artifact/phase/state | PASS |
| AC9 — shipper-only git writes, on explicit invocation | AC9 (10): authority attributes publication to the shipper only; explicit invocation is the consent to write git; shipper does not approve/merge; architect/plan issue no commit/push/PR | PASS (content); enforcement prompt-level |
| AC10 — historical/pre-flow items proceed; derived state and suite unaffected | AC10 (5) + suite: no publication recorded → proceed with note (builder + command); unreachable `origin` never hard-fails; `bash tests/run.sh` green | PASS |
| AC11 — a revised plan is republished before development continues | AC11 (6): authority revision + same branch/PR; shipper revision rule; never force-push; `/plan` handoff; architect handoff; **and the gate refuses an unmerged revision (AC2)** | PASS (content); live republication manual |
| AC12 — malformed/unresolved is reported, never dropped/auto-repaired | AC12 (3): unresolved item value reported; grammar unresolved rule intact | PASS |
| AC13 — authority, frontmatter contract, prompts consistent; single grammar | AC13 (20): shared branch example across four surfaces; each owning surface references the authority; no new `phase: plan`; no new artifact/phase/state; plan template omits merge-time sections; **human-approval precondition on authority + shipper + ship command; plan mode writes no shipped state on authority + shipper + ship command**; no new conflict taxonomy in the new section | PASS |

Coverage: **13/13 acceptance criteria covered.**

### Edge cases

| Edge case | Coverage | Result |
| --------- | -------- | ------ |
| Empty declaration — `—`/absent means none; empty/whitespace-only is malformed | EDGE: `an empty or whitespace-only cell is malformed, not equivalent to `—``; template renders `conflicts-with: "—"` | PASS |
| Absent declaration — historical plan reads as no declared conflicts | EDGE: `Absent or `—` means no declared conflicts`; `the field is optional` | PASS |
| Plan not yet ready — no `/plan` completion, cannot publish | EDGE: gate precondition requires `spec.md` and `design.md` to exist | PASS |
| Plan PR already merged — re-publication is a no-op | EDGE: authority idempotence rule + shipper `Idempotence:` step | PASS |
| Unmerged plan blocks development | AC2: gate refuses and reports | PASS |
| Revised plan after merge | AC11: republished on the same `plan/<ref>` branch/PR; AC2: the gate now refuses the unmerged revision | PASS |
| Roadmap parent — no requirements/design, declaration stays in `Children` | EDGE: field `appears only on `design.md``; authority scopes it to a child or standalone item | PASS |
| Both sides declare / one side declares | Consumed `0001` grammar (unchanged) — symmetry is the `0001` authority; sibling suite 79/0 | PASS (consumed) |
| Self-reference / duplicate target | EDGE: architect quality bar `with no self-reference and no duplicate target`; authority well-formedness rules intact | PASS |
| Concurrent publication — independent branches, no overwrite | EDGE: `Each item gets its own branch, so concurrent publications do not overwrite one another` | PASS |
| Cross-roadmap overlap — top-level item or nested child in another tree | Consumed `0001` reference grammar (unchanged); sibling suite 79/0 | PASS (consumed) |
| Plan diff contains no secrets | EDGE: authority preconditions + shipper precondition/step | PASS |
| Retained merged plan branch is not a block | AC2: step-0 refresh precedes the check; `EDGE retained merged plan branch is not a block` | PASS |
| Advertised-but-unresolvable plan ref (reviewer M1) | AC2: refresh, `unresolved_plan`, step-1 guard, step-2 refusal on authority + builder + command | PASS |

## Mutation evidence

The item suite was run against a throwaway copy under `/tmp/opencode/mut` (never
the working tree), built from `git clone` plus a copy of the ten working-tree
surfaces and the item artifacts, with one mutation applied at a time. All 31
mutations below were executed **in this pass**; each was caught and named, and
the unmutated control passed (`158 / 0`). The mutations marked "new this pass"
target exactly the 8 assertions added this pass.

| # | Mutation | Surface | Item-suite result |
| - | -------- | ------- | ----------------- |
| — | none (control) | — | PASS 158/0 |
| 1 | remove `if remote_plan: git fetch origin plan/<ref>` | `docs/workflow.md` | CAUGHT 157/1 |
| 2 | `unresolved_plan = true` → `false` | `docs/workflow.md` | CAUGHT 157/1 |
| 3 | neuter step-1 `and not unmerged_plan and not unresolved_plan` | `docs/workflow.md` | CAUGHT 157/1 |
| 4 | drop `or unresolved_plan` from step-2 refusal | `docs/workflow.md` | CAUGHT 157/1 |
| 5 | rename `Case 2 is content-aware…` | `docs/workflow.md` | CAUGHT 157/1 |
| 6 | `unmerged_plan = git diff --quiet …` → `false` | `docs/workflow.md` | CAUGHT 157/1 |
| 7 | drop remote-first `plan_ref` resolution | `docs/workflow.md` | CAUGHT 157/1 |
| 8 | remove differing-branch comment | `docs/workflow.md` | CAUGHT 157/1 |
| 9 | break builder plan-ref refresh | `.opencode/agent/builder.md` | CAUGHT 157/1 |
| 10 | break build-command plan-ref refresh | `.opencode/command/build.md` | CAUGHT 157/1 |
| 11 | remove step-0 authority sentence | `docs/workflow.md` | CAUGHT 157/1 |
| 12 | remove plan-publication advisory statement | `docs/workflow.md` | CAUGHT 157/1 |
| 13 | remove shipper explicit-consent rule | `.opencode/agent/shipper.md` | CAUGHT 157/1 |
| 14 | remove union/mismatch rule | `docs/workflow.md` | CAUGHT 157/1 |
| 15 | change architect handoff to `/build` | `.opencode/agent/architect.md` | CAUGHT 157/1 |
| 16 | change "mode of `/ship`" to a new `/publish` command | `docs/workflow.md` | CAUGHT 156/2 |
| 17 | **remove plan PR `## Declared conflicts` section** | `.opencode/skill/pr-workflow/SKILL.md` | CAUGHT 157/1 (new this pass) |
| 18 | **remove approval (authority)** | `docs/workflow.md` | CAUGHT 157/1 (new this pass) |
| 19 | **remove approval (shipper)** | `.opencode/agent/shipper.md` | CAUGHT 157/1 (new this pass) |
| 20 | **remove approval (ship command)** | `.opencode/command/ship.md` | CAUGHT 157/1 (new this pass) |
| 21 | **remove no-shipped-state (authority)** | `docs/workflow.md` | CAUGHT 157/1 (new this pass) |
| 22 | **remove no-shipped-state (shipper)** | `.opencode/agent/shipper.md` | CAUGHT 157/1 (new this pass) |
| 23 | **remove no-shipped-state (ship command)** | `.opencode/command/ship.md` | CAUGHT 157/1 (new this pass) |
| 24 | **remove `plan-only; no code changed`** | `.opencode/skill/pr-workflow/SKILL.md` | CAUGHT 157/1 (new this pass) |
| 25 | remove plan preconditions (spec+design) | `docs/workflow.md` | CAUGHT 157/1 |
| 26 | rename conventional-commits `plan/<ref>` rule | `.opencode/skill/conventional-commits/SKILL.md` | CAUGHT 157/1 |
| 27 | change artifact-conventions field home | `docs/artifact-conventions.md` | CAUGHT 157/1 |
| 28 | remove concurrent-publication rule | `docs/workflow.md` | CAUGHT 157/1 |
| 29 | change "process step, not a phase" | `docs/workflow.md` | CAUGHT 156/2 |
| 30 | drop "prints the item's declared conflicts" | `docs/workflow.md` | CAUGHT 157/1 |
| 31 | remove omit-merge-time-sections rule | `.opencode/skill/pr-workflow/SKILL.md` | CAUGHT 157/1 |

Result: **31/31 applied mutations caught; 0 escaped; control 158/0.**

## Gaps and residual risk

1. **Live git/GitHub behavior is manual (by design).** AC1, AC2, AC3, and AC11
   assert the documented contract; the actual branch/commit/push/PR/merge and the
   gate's refusal are prompt behavior that cannot be exercised offline without
   performing git writes (shipper-only, on explicit invocation). The item suite
   asserts the algorithm's exact text and outcomes. Manual dry-run steps:
   - **AC2 (gate refusal, first publication and revision):** create a throwaway
     branch `plan/<ref>` with one commit that changes `work/<item-ref>/design.md`
     locally, then invoke `/build <item-ref>`; the builder must run the best-effort
     refreshes and refuse, naming the plan branch. Delete the throwaway branch and
     confirm `/build` proceeds with a "no plan publication found" note. To exercise
     the revision path, merge a plan first, then add a differing commit to
     `plan/<ref>` and confirm the gate refuses again. (Deleting a throwaway local
     branch is non-destructive; never push it.)
   - **AC1/AC3/AC11 (publication/merge/revision):** invoke `/ship plan <item-ref>`
     and confirm a `plan/<ref>` branch, one `docs(plan): record plan for
     <item-ref>` commit, and a PR using the plan template; confirm the shipper
     stops before merge; after human approval and merge, confirm the artifacts are
     readable on the default branch.
   These require explicit user invocation and (for merge) a human approver, so
   they are outside a read-only verification pass.
2. **Content criteria are literal-presence checks, not semantic proofs.** The
   deliverable is prose and prompts; a passing literal assertion proves the
   mandated content is present, not that the surrounding prose is coherent. A
   reviewer still reads the contract. Same residual as sibling `0006/0001` and
   `0005/0001`. (Duplicate equivalent phrasing can mask a mutation — an
   artifact-conventions grammar pointer survived removal because an equivalent
   0001 sentence remains; not an AC gap, but a limit of the method.)
3. **The gate observes committed git state only.** Because the algorithm is
   git-derived, an architect revision that exists only in the working tree
   (uncommitted, unpublished) is not visible to the gate and would not block
   `/build` on that same tree. This is inherent to the design's git-only,
   offline-first choice and is not an acceptance criterion; the authority states
   the revision must be published (AC11). Recorded for the reviewer (also reviewer
   m4).
4. **Committed fixture-based guards are deferred to `0004-conflict-guards`
   (deliberate).** The design's test strategy assigns committed `tests/` agreement
   areas and mutation coverage to sibling `0004`; `tests/` is untouched by this
   item. Consequence: a later edit that drops a plan-publication literal would not
   be caught by CI until `0004` lands; the item suite catches it now but is not
   wired into `tests/run.sh`. No action required for this item.
5. **`design.md` predates the step-0 refresh and the content-aware gate
   (architect-owned follow-up, not an AC failure).** The design's `plan_gate`
   listing (`design.md:93-107`) omits the step-0 fetch and the `unmerged_plan` /
   `unresolved_plan` content checks that now head the implemented algorithm in
   `docs/workflow.md:351-396`; its retained-branch risk justification
   (`design.md:264-267`) relies on a step it does not list. The authority is
   `docs/workflow.md`, and no acceptance criterion names the design's algorithm
   text, so nothing fails. Recommendation: the architect refreshes `design.md` in a
   `/plan` revision so design and authority agree. I did not edit `design.md` — it
   is another phase's artifact.
6. **Plan publication is absent from the enumerated/routing surfaces (reviewer
   m1/m2, not an AC failure).** `README.md`, `AGENTS.md`, `template/AGENTS.md`, and
   `.opencode/skill/workflow-lifecycle/SKILL.md` still route `/plan` → `/build` and
   omit `/ship plan` from the git-write guardrail enumeration. AC13 names the
   authority, the frontmatter contract, and the owning prompts, not these
   surfaces; the design deliberately leaves them unchanged to preserve the
   canonical `/ship [item-ref]` signature. Usability follow-up: add a
   plan-publication note to the routing skill and the guardrail parenthetical.
7. **Plan-mode branch base is unspecified (reviewer m3, not an AC failure).** The
   plan branch is created "from" nothing stated; a maintainer who creates it from a
   branch holding unrelated commits would carry them into the plan PR. AC1/AC3 do
   not name the base. Recommendation recorded for the owner: pin the base to the
   freshly fetched default branch.
8. **No UI, so no visual pass.** The change is documentation and prompts beneath a
   CLI lifecycle; there is no user-facing browser surface, so `/visual` does not
   apply.

No acceptance criterion is blocked, no relevant test failed, and no test was
weakened, skipped, or deleted.
