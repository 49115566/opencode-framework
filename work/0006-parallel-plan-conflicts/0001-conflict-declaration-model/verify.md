---
feature: 0006-parallel-plan-conflicts/0001-conflict-declaration-model
phase: test
status: final
created: 2026-10-08
updated: 2026-10-08
parent: 0006-parallel-plan-conflicts
notes: "Docs + prompts only; no runtime code, no UI. AC1-AC12 and every spec edge case are encoded as content assertions in the item suite work/0006-parallel-plan-conflicts/0001-conflict-declaration-model/verify-tests.sh (79 passed, 0 failed); the canonical suite bash tests/run.sh is the regression gate (285 passed, 0 failed, 0 skipped). No committed tests/check area or mutation case is added, deliberately: the spec non-goals and the design defer fixture-based committed guards to sibling 0004-conflict-guards. No defects found. No test weakened, skipped, or deleted."
---

# Verification — Declared planning-time conflict model and `conflicts-with` column

## Summary

All twelve acceptance criteria of
`work/0006-parallel-plan-conflicts/0001-conflict-declaration-model` are satisfied
against the current working tree, and every spec edge case is covered. The
deliverable is documentation and prompts, so the automatable evidence is a new
read-only item suite,
`work/0006-parallel-plan-conflicts/0001-conflict-declaration-model/verify-tests.sh`,
which encodes AC1–AC12 and the edge cases as content assertions over the four
changed surfaces, plus structural/regression invariants for AC6/AC10 and the
canonical committed suite as the regression gate.

- Item suite: **79 passed, 0 failed** (exit `0`).
- Canonical suite `bash tests/run.sh`: **285 passed, 0 failed, 0 skipped** (exit
  `0`).
- `docs/workflow.md` diff is **additions-only** (`58 inserted, 0 deleted`), so
  `## Merge conflicts` and `### Dependencies and readiness` are untouched (AC6,
  AC7, AC10).
- `tests/` is unchanged, so no committed guard was preempted from sibling
  `0004-conflict-guards`.
- No production file was modified by this verification pass; the only file added
  is the item suite. No defects found.

The item suite follows the established doc-only verification pattern from
`work/0005-merge-conflict-workflow/0001-conflict-model/verify-tests.sh`: an
item-level suite under `work/`, not a `tests/checks/**` agreement area, because
the spec's non-goals and the design's test strategy assign the committed,
fixture-based guards to sibling `0004-conflict-guards`.

## Commands run

| Command | Result | Notes |
| ------- | ------ | ----- |
| `bash tests/run.sh` | PASS | `TOTAL: 285 passed, 0 failed, 0 skipped`, exit `0` — regression gate (incl. `80-cycle-fixture.sh`, `40-inventory.sh`) |
| `bash work/0006-parallel-plan-conflicts/0001-conflict-declaration-model/verify-tests.sh` | PASS | `TOTAL: 79 passed, 0 failed`, exit `0` — AC1–AC12 + edge cases |
| `bash -n work/0006-parallel-plan-conflicts/0001-conflict-declaration-model/verify-tests.sh` | PASS | syntax OK |
| `git status --porcelain -- tests/` | PASS | empty — no committed tests/ file changed by this item |
| `git diff --numstat HEAD -- docs/workflow.md` | PASS | `58  0` — additions-only; readiness and merge-time sections untouched |
| `git status --porcelain -- docs/workflow.md docs/artifact-conventions.md .opencode/agent/roadmap.md .opencode/command/roadmap.md` | PASS | exactly the four design-named surfaces modified |

## Acceptance coverage

The "Test(s)" column names the assertion group in
`verify-tests.sh`; each named assertion is a literal content check over the live
surface. `need`/`needflat`/`absent` are exact-literal checks (`needflat` collapses
line wrapping first).

| Criterion | Test(s) | Result |
| --------- | ------- | ------ |
| AC1 — planning-time conflict is a declared, committed claim, distinct from merge-time and `Depends on`, referencing the shipped classes | `verify-tests.sh` AC1 (5 assertions): `### Declared conflicts` subsection; "declared, committed claim"; "distinct from the merge-time `## Merge conflicts` contract"; "distinct from `Depends on`, which is a readiness edge"; "shipped `(a)`–`(d)` class labels" | PASS |
| AC2 — template includes `conflicts-with` and its note explains meaning and empty value | `verify-tests.sh` AC2 (6): exact 6-column header; both example rows carry `—`; note "declares the targets the row expects to collide with"; "Use `—`"; note points to `docs/workflow.md` → "Declared conflicts" | PASS |
| AC3 — three target kinds; comma-separated; `—` when none | `verify-tests.sh` AC3 (8): the `ConflictTargetList`/`ConflictTarget` productions; sibling local id; canonical work-item reference (top-level and nested); repository-relative surface path; "Targets are comma-separated"; "`—` … declares no conflicts"; "a comma always separates targets" | PASS |
| AC4 — child/standalone uses the same grammar and conventions, defined independently of storage | `verify-tests.sh` AC4 (3): "The same grammar defines the intended conflict set of a child or standalone work item"; "independent of where such an item's declaration is stored"; negative control — no new declaration `phase` value | PASS |
| AC5 — one-sided declaration is a conflict; no reciprocity | `verify-tests.sh` AC5 (2): "at least one side names the other"; "does not require a reciprocal declaration" | PASS |
| AC6 — advisory; no `Depends on` edge or readiness change | `verify-tests.sh` AC6 (9): advisory rule on all four surfaces; readiness section still carries `satisfied(dep_local_id)`/`ready(child)`/`blocked_by(child)`; readiness section contains no `conflicts-with` input | PASS |
| AC7 — reuse shipped `(a)`–`(d)` and finding-line grammar; no new class/code/policy | `verify-tests.sh` AC7 (6): shipped-class + grammar reference; explicit "no new class, finding code, or policy"; unresolved reported, never dropped; negative controls — no `(e)` and no new planning-conflict finding code in the new subsection | PASS |
| AC8 — sibling target is a different row; no duplicate target | `verify-tests.sh` AC8 (5): no self-reference (authority + agent quality bar); no repeated target; reference-vs-path discriminator resolves a sibling id | PASS |
| AC9 — roadmap agent prompt and command describe the column consistently, no conflicting grammar | `verify-tests.sh` AC9 (10): agent prompt and command each name the cell, reference the authority grammar, state the advisory rule; agent quality bar; negative controls — neither restates `ConflictTargetList ::=` | PASS |
| AC10 — `Depends on` parsing and readiness unchanged; positional consumer intact | `verify-tests.sh` AC10 (6) + suite: parser still `dep = a[5]`; committed fixture/header assertion unchanged; `tests/` diff empty; suite green. Inserting `conflicts-with` after `Depends on` leaves pipe-field 5 as `Depends on` in both the 5-column fixture and the 6-column template | PASS |
| AC11 — malformed/unresolved target is an unresolved declaration reported later, never dropped | `verify-tests.sh` AC11 (3): "unresolved declaration" definition; "reported by a later read-only check"; "never silently dropped or auto-repaired" | PASS |
| AC12 — one authoritative grammar; others reference it; no conflicting grammar | `verify-tests.sh` AC12 (7): `ConflictTargetList ::=` appears in exactly one non-`work/` surface (`docs/workflow.md`); template, agent, and command each reference it; negative controls — none of the three restates the production | PASS |

Coverage: **12/12 acceptance criteria covered and passing.**

### Edge cases

| Edge case | Coverage | Result |
| --------- | -------- | ------ |
| Empty declaration — `—` means none; empty/whitespace-only is malformed | `verify-tests.sh` EDGE: "an empty or whitespace-only cell is malformed, not equivalent to `—`"; AC3 `—` declaration | PASS |
| Absent column — historical roadmaps stay valid as no declared conflicts | `verify-tests.sh` EDGE: "no `conflicts-with` column"; "absence is treated as no declared conflicts (`—` for every row)" | PASS |
| Unresolved sibling / top-level item / surface | `verify-tests.sh` AC11 + EDGE: "resolves to no sibling row, no `work/<ref>/` directory, and no existing path" | PASS |
| Self-reference | `verify-tests.sh` AC8 + EDGE: no self-reference | PASS |
| Duplicate target | `verify-tests.sh` AC8 + EDGE: no repeated target after trim | PASS |
| Both sides declare / one side declares | `verify-tests.sh` AC5 + EDGE: "at least one side names the other" | PASS |
| Cross-roadmap overlap (top-level item, nested child) | `verify-tests.sh` EDGE: canonical work-item reference covers a top-level `NNNN-slug` (including a roadmap parent) and a nested `NNNN-slug/MMMM-slug` | PASS |
| Comma inside a target | `verify-tests.sh` EDGE: "a comma always separates targets" | PASS |
| Bare-reference ambiguity (sibling id vs top-level item) | `verify-tests.sh` EDGE: sibling-first resolution precedence | PASS |

## Gaps and residual risk

1. **Content criteria are literal-presence checks, not semantic proofs
   (spec-approved).** The deliverable is prose and prompt files with no runtime
   harness. AC1–AC12 and the edge cases are verified by asserting the required
   literals from the finished surfaces (the design's test strategy). A literal
   assertion proves the mandated content is present, not that the surrounding
   prose is coherent; a reviewer still reads the contract. This is the same
   residual the sibling doc-only item `0005/0001` records.
2. **Committed fixture-based guards are deferred to `0004-conflict-guards`
   (deliberate).** The spec non-goals and design assign committed `tests/`
   agreement areas and mutation coverage to sibling `0004`. Adding one here would
   have contradicted the spec and preempted `0004`, so `tests/` is untouched.
   Consequence: a later edit that drops a `conflicts-with` literal would not be
   caught by CI until `0004` lands; the item suite under `work/` catches it now
   but is not wired into `tests/run.sh`.
3. **Fixture/template skew is intentional and recorded.** The roadmap template is
   now 6-column while `tests/fixtures/cyclic-roadmap/roadmap.md` remains 5-column;
   `80-cycle-fixture.sh` asserts the unchanged fixture header. The suite stays
   green because it reads the fixture, not the template. The design explicitly
   records this skew and assigns reconciliation to `0004`. AC10 is satisfied: the
   positional parser reads `Depends on` at field 5 unchanged.
4. **`/status` agent's Children-table field enumeration is now incomplete.**
   `.opencode/agent/status.md:80-82` says each row gives "a local id, title, scope,
   `Depends on` local ids, and a canonical reference" and does not mention
   `conflicts-with`. This surface describes parsing and renders no table, and it
   is not one of the AC-named vocabulary surfaces (AC9 names the roadmap agent
   prompt/command; AC12 names the authority docs, template+notes, and roadmap
   agent prompt), so no acceptance criterion is violated and it is out of the
   design's stated affected areas. It is worth a follow-up when
   `0003-conflict-check` wires the pre-development check into `/status`.
5. **Resolution algorithm is defined in the design, not reproduced in
   `docs/workflow.md`.** The design's normative `resolve(token, row, table)`
   pseudocode (self-reference/duplicate → unresolved, sibling-first precedence) is
   the contract `0003-conflict-check` consumes; the implementation states the
   well-formedness rules and the discriminator in prose. AC8's requirement ("a
   different row in the same table; no duplicate target") is fully stated; the
   finer algorithm is correctly left to the consuming child. This is a scope
   boundary, not a gap.
6. **No UI, so no visual pass.** The change is documentation and prompts beneath a
   CLI lifecycle; there is no user-facing browser surface, so `/visual` does not
   apply.

No acceptance criterion is blocked, no relevant test failed, and no test was
weakened, skipped, or deleted.
