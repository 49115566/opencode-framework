---
feature: 0015-recursive-workflow-guards/0003-recursive-conflicts-guard
phase: test
status: final
created: 2026-10-14
updated: 2026-10-14
parent: 0015-recursive-workflow-guards
---

# Verification — Recursive declared-conflicts guard

## Commands run

| Command | Result | Notes |
| ------- | ------ | ----- |
| `bash tests/run.sh` | PASS | `TOTAL: 551 passed, 0 failed, 0 skipped` (full suite; includes the 1 assertion added by this pass). |
| `FRAMEWORK_TEST_AREAS=85-conflict-guards bash tests/run.sh` | PASS | `TOTAL: 97 passed, 0 failed, 0 skipped`; all 11 `AC23 recursive-*` labels `ok`. |
| `bash tests/run.sh /tmp/opencode/mut` (fresh clone with **no** `work/**`) | PASS | `TOTAL: 551 passed, 0 failed, 0 skipped` — proves the area reads no live `work/` path. |
| `grep -rn 'work/' tests/fixtures/recursive-conflicts/` | no match | The recursive fixture references no live `work/` path. |
| `git diff tests/checks/85-conflict-guards.sh` removals audit | PASS | The only removed lines are the header comment, the old `?`-capped regex, and the replaced non-recursive inner loop. No depth-2 `EXP_*` block or depth-2 assertion was removed or altered. |
| 11 targeted mutations on a scratch copy (AC12) | PASS | Each recursive label is independently trippable; see "Mutation spot-check (AC12)". |

Baseline was established before editing (full suite `550 passed, 0 failed, 0 skipped`).
The implementation diff under test: `tests/checks/85-conflict-guards.sh` (resolver,
recursive walk, analyzers, new assertions) plus the new committed fixture root
`tests/fixtures/recursive-conflicts/`. `tasks.md` T1–T9 are all `[x]`.

## Acceptance coverage

The guard *is* the test (design → "Test strategy"). Each criterion is pinned by a
committed assertion in `tests/checks/85-conflict-guards.sh`, run by
`bash tests/run.sh`.

| Criterion | Test(s) | Result |
| --------- | ------- | ------ |
| AC1 recursive reference grammar + ref-vs-path | `AC23 recursive-reference: the depth-3 reference block matches the expected resolution`; `... a three-segment reference resolves as an item`; `... a non-reference token resolves as a surface path` | PASS |
| AC2 sibling-first, then root fallback, below the root | `AC23 recursive-sibling-precedence: the below-root resolution block matches the expected resolution`; `... a bare MMMM-slug resolves to its sibling row first below the root`; `... the sibling row wins over the same-named top-level decoy`; `... a bare token matching no sibling row falls to the root fallback` | PASS |
| AC3 recursion into a decomposing child | `AC23 recursive-traversal: compared-set entity stream matches the expected block`; `... the decomposing child is an entity from its parent row`; `... the decomposing child's own row is an entity at depth 3` | PASS |
| AC4 own ∪ parent-cell union | `AC23 recursive-union: the own ∪ parent-cell union matches the expected resolution`; `... the union includes the child's own declaration`; `... the union includes the parent cell's declaration`; `... a one-sided parent cell declares its target` | PASS |
| AC5 drift discrepancy; one-sided is not drift | `AC23 recursive-drift: the drift set matches the expected block`; `... a both-present-unequal declaration at depth is reported`; `... a one-sided record is not reported as a discrepancy`; **added:** `... a both-present-equal declaration is a no-drift union` | PASS |
| AC6 pair predicate across levels | `AC23 recursive-pair: cross-level declared conflict pairs match the expected block`; `... a cross-level shared surface target is a class (a) conflict`; `... a cross-level shared item target is a class (b) conflict`; `... one-sided naming of an otherwise silent counterpart is a conflict`; `... equal text resolving to different items is not a shared target` | PASS |
| AC7 shipped resolves but is excluded | `AC23 recursive-shipped: a shipped target still resolves for the declaring entity`; `... a shipped entity is excluded as a conflict counterpart`; `... the shipped entity carries the shipped signal` | PASS |
| AC8 malformed/unresolved reporting | `AC23 recursive-unresolved: the malformed/unresolved block matches the expected block` + 7 per-token `... reported, not dropped` assertions (blank, `../escape`, `/abs.md`, `docs/*.md`, `9999-nope`, `docs/no-such-file.md`, self-reference) | PASS |
| AC9 legacy 5-column header at depth | `AC23 recursive-column-layout: the depth-2 legacy manifest has the 5-column Children header`; `... depth-2 header places Depends on at pipe-field 5 and conflicts-with field 6`; `... a 5-column legacy child is an entity from its parent row`; `... a 5-column legacy row declares nothing` | PASS |
| AC10 depth-2 control unchanged | Existing `AC23 column-layout` / `positional-parse` / `cell-resolution` / `pair-predicate` / `reporting-vocabulary` blocks present, unedited (removals audit above), and green in the full run | PASS |
| AC11 fixture existence + read-only, fresh clone | `AC23 recursive-fixture-existence` (7 files); `AC23 recursive-read-only-contract`; fresh-clone run with no `work/**` | PASS |
| AC12 one targeted change trips the matching label | Mutation spot-check below (11 labels) | PASS (scratch); permanent jobs owned by `0005` |

### Edge cases

| Edge case | Coverage | Result |
| --------- | -------- | ------ |
| Empty compared set at depth | `AC23 pair-predicate: an empty compared set with no declarations yields no findings` (depth-2 synthetic stream; the `fixture_conflicts` analyzer is depth-agnostic, so nesting adds no distinct behavior) | PASS |
| All-shipped compared set | `AC23 pair-predicate: an all-shipped compared set yields no findings` (same analyzer) | PASS |
| `.gitkeep`-only nested child remains a counterpart | Entity set + pairs: `0001-leaf` and `9203-shared` are named targets with no declaration of their own (`recursive-traversal` / `recursive-pair`) | PASS |
| Equal text, different targets | `AC23 recursive-pair: equal text resolving to different items is not a shared target` (`0002-grand` in `9201-root-a/0001-nested` vs `9202-root-b/0001-namer`) | PASS |
| Both-present-and-equal | **Added test:** `AC23 recursive-drift: a both-present-equal declaration is a no-drift union` (mutation-sensitive; fails when the equal case emits drift) | PASS |
| Reference-vs-path ambiguity | `AC23 recursive-reference` item vs surface classification | PASS |
| Legacy header at depth | `AC23 recursive-column-layout` (`9201-root-a/0003-legacy`) | PASS |
| Depth boundary (`.gitkeep` leaf) | `9201-root-a/0001-nested/0001-leaf` is an entity with no declaration (`recursive-traversal`) | PASS |
| No live `work/**` | `AC23 recursive-read-only-contract` + `grep` + fresh-clone run | PASS |

## Mutation spot-check (AC12)

Independent targeted mutations on a scratch copy (no `work/`), each run with
`FRAMEWORK_TEST_AREAS=85-conflict-guards bash tests/run.sh <copy>`. Every label's
own mutation produced a `FAIL` line naming that label (`exit=1`).

| Label | Targeted change | FAILed own label |
| ----- | --------------- | ---------------- |
| `recursive-reference` | reverted the resolver regex to the one-`/`-segment `?` form | yes |
| `recursive-sibling-precedence` | resolved root-first instead of sibling-row-first | yes |
| `recursive-traversal` | removed the recursion into a decomposing child | yes |
| `recursive-union` | dropped the parent-cell candidate contribution | yes |
| `recursive-drift` | disabled the drift condition | yes |
| `recursive-pair` | removed the one-sided item-naming clause | yes |
| `recursive-shipped` | included shipped entities as counterparts | yes |
| `recursive-unresolved` | disabled structural malformation detection | yes |
| `recursive-fixture-existence` | moved the fixture root aside | yes |
| `recursive-read-only-contract` | injected a `work/` literal into a fixture file | yes |
| `recursive-column-layout` | changed the depth-2 header to the 5-column form | yes |

The mutations also tripped the depth-2 control labels when they shared logic
(e.g. the resolver), which is expected: the depth-2 control and the recursive
area share one resolver and one analyzer set, exactly as the spec requires.

## Changes made by this pass

- `tests/checks/85-conflict-guards.sh` — added one focused, read-only assertion
  (`AC23 recursive-drift: a both-present-equal declaration is a no-drift union`).
  It drives `guard_emit_entity` with a synthetic parent-cell value against the
  committed `0004-refs` `design.md` and asserts the equal set emits no `D` event
  while an unequal set still does. No fixture file, expected block, analyzer, or
  production surface was modified. Verified mutation-sensitive: forcing the
  emitter to always report drift makes the assertion `FAIL`.

## Gaps and residual risk

- **Live model runs are not executable in CI.** The actual `/conflicts`,
  `/status`, and `/build`-gate prompts are not run by the suite; this residual is
  unchanged from the shipped depth-2 area. Manual step: in an interactive session
  run `/conflicts 0015-recursive-workflow-guards/0003-recursive-conflicts-guard`
  and `/status 0015-recursive-workflow-guards/0003-recursive-conflicts-guard` and
  confirm the findings/readiness rendered for the fixture-shaped declarations.
- **Permanent mutation jobs and `tests/README.md` registration are deferred.**
  `tests/mutation.sh` does not yet stage `tests/fixtures/recursive-conflicts/` and
  has no jobs for the new labels; AC12 is proven here only by a scratch
  targeted-mutation spot check. This is the recorded sibling dependency owned by
  `0005-guard-registration-sweep` (`spec.md` non-goals), not a regression in
  `bash tests/run.sh`.
- **Harness observation (pre-existing, out of scope).** `tests/run.sh` sources each
  check with `.` and does not inspect the source's return status, so a syntax
  error inside a check file makes that entire area's assertions silently not run
  while the suite still exits 0 (reproduced: an unmatched `if` at the top of
  `85-conflict-guards.sh` yielded `exit=0`, `0 failed`, and 454 instead of 551
  total assertions). This affects every area and predates this item; it is a
  follow-up suggestion for the harness, not a defect of this work item.
- **No flakiness observed.** The fixture is pure committed data; assertions are
  deterministic and order-independent, and the fixture ids stay in the
  non-colliding `92xx` fixture space, allocating no real `work/` number.

## Verdict

Every acceptance criterion and every spec edge case is covered by a passing,
mutation-sensitive committed assertion. No implementation defect found; no
backtrack required.
