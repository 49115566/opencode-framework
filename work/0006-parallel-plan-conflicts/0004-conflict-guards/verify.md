---
feature: 0006-parallel-plan-conflicts/0004-conflict-guards
phase: test
status: final
created: 2026-10-08
updated: 2026-10-08
parent: 0006-parallel-plan-conflicts
notes: "All 13 acceptance criteria and every listed edge case verified. Canonical suite: 334 passed, 0 failed, 0 skipped (exit 0); mutation self-check: 39 checked passed, 0 failed (exit 0), including all five AC23 guards. Independently probed six additional adversarial fixture mutations and all five self-check mutations; each is caught with a genuine FAIL line naming the intended AC23 sub-area. This pass added two test-only assertions for the spec's empty-compared-set edge case (tests/checks/85-conflict-guards.sh:540-564) and strengthened the five AC23 mutation expectations to require a FAIL line (tests/mutation.sh), so a passing ok line can no longer satisfy the 'caught and named' check. No production surface touched."
---

# Verification — Committed guards for the declared-conflict model and check

## Summary

This item is test-only: it adds `tests/checks/85-conflict-guards.sh` (suite token
`AC23`), the `tests/fixtures/declared-conflicts/` fixture tree, a 6-column rollout
of the cyclic fixture + `80-cycle-fixture.sh`, five `tests/mutation.sh` cases, and
`tests/README.md` documentation. No production surface (`docs/**`,
`.opencode/**`, root docs/config) is touched — confirmed below.

I verified the guards independently rather than trusting the self-check: beyond
running the suite and mutation harness, I applied six extra adversarial mutations
to the fixture (removed `ship.md`; equalized the drift sets; non-existent
directory surface; em-dash → empty; glob-only malformed; legacy header upgraded)
and re-applied the five self-check mutations, confirming each produces a genuine
`FAIL  AC23 <sub-area>` line. Two gaps were closed with test-only changes (see
"Tests added in this pass").

Result: **PASS** — canonical suite `334 passed, 0 failed, 0 skipped`; mutation
self-check `39 checked passed, 0 failed`; fresh-clone-without-`work/` run
`334 passed`. No defects found.

## Commands run

| Command | Result | Notes |
| ------- | ------ | ----- |
| `bash tests/run.sh` | PASS (exit 0) | `TOTAL: 334 passed, 0 failed, 0 skipped`; 43 `AC23` ok lines |
| `bash tests/mutation.sh` | PASS (exit 0) | `MUTATION TOTAL: 39 checked passed, 0 failed`; five `AC23` mutations reported caught and named |
| `bash tests/run.sh <copy-without-work>` | PASS (exit 0) | Independent `tar` copy with `work/` excluded: `334 passed`; proves AC9/AC13 fresh-clone independence |
| `bash -n tests/checks/85-conflict-guards.sh` | PASS | shell syntax OK (also `tests/mutation.sh`) |
| `git status --porcelain -- docs .opencode README.md AGENTS.md template opencode.json` | PASS (empty) | no production surface touched |
| `grep -c 'work/' tests/checks/85-conflict-guards.sh` | control | only comments, the fixture read-only-contract grep, and the `work/` class-(b) identity test; the guard reads no live `work/**` |
| adversarial fixture probes (6) | PASS | each mutation yields a `FAIL AC23 cell-resolution`/`column-layout`/`pair-predicate` line (details below) |

## Acceptance coverage

The deliverable is itself verification code, so the "test" that covers each
criterion is the guard assertion group or the harness, run by the canonical
suite. All cells are deterministic content/fixture assertions; the one live-model
run is called out as manual.

| Criterion | Test(s) | Result |
| --------- | ------- | ------ |
| AC1 — cyclic fixture uses the 6-column layout, cycle still proven, `Depends on` still at the same field | `tests/checks/80-cycle-fixture.sh:31` (6-column header literal) + `:43-97` (Kahn parse `id = a[2]; dep = a[5]`) asserts `AC13 fixture dependency graph is genuinely cyclic (members: 0001-alpha 0002-beta)`; `tests/fixtures/cyclic-roadmap/roadmap.md` rows carry `—` | PASS |
| AC2 — every `conflicts-with` cell is `—` or a well-formed list; malformed/unresolved fails and names the area | `85:464-502` (`AC23 cell-resolution` exact expected resolution + unresolved blocks; `guard_malformed`/`guard_resolve` cover blank, glob, `..`, absolute, self, duplicate, non-existent). Adversarial probes: glob-only, empty value, non-existent dir all produce `FAIL AC23 cell-resolution` | PASS |
| AC3 — two unshipped plans sharing a target is a genuine conflict; fails if no longer encoded | `85:505-538` expected pair `9001-roadmap-a/0001-shared\|9010-surface-shared\|(a)`; mutation "pair predicate" changes the target to `README.md` and is caught with `FAIL AC23 pair-predicate` | PASS |
| AC4 — one plan naming a silent unshipped plan is a conflict | `85:521-525` pairs `9011-names-silent\|9012-silent` and `9002-roadmap-b/0001-shared\|0002-sibling` (both named items have no declaration) | PASS |
| AC5 — sibling, canonical item, file/dir surface resolve; `—` declares nothing; malformed/self/dup/empty/non-existent unresolved | `85:412-462` expected blocks cover all cases; `:487-502` sibling-first vs the top-level decoy and `—`/absent negatives; `:473-478` unresolved block. Adversarial probes for dir/nonexistent, empty, glob | PASS |
| AC6 — child declared set is own ∪ parent cell; both-present unequal is drift, one-sided is not | `85:225-234` (union + drift) and `:480-497` (drift block = `{9001-roadmap-a/0003-drift}`, union includes both surfaces). Equalizing the drift sets removes drift and fails `FAIL AC23 cell-resolution` | PASS |
| AC7 — shipped item excluded as counterpart, still resolves as target | `85:418` (`9013-names-shipped` → shipped resolves), `:529-533` (shipped absent from conflicts). Removing `ship.md` makes the shipped child a counterpart and fails `FAIL AC23 pair-predicate` | PASS |
| AC8 — shipped finding grammar, codes, `(a)`–`(d)` classes for the four situations; no new class/code/policy | `85:567-622`: authority (`TEXTUAL-CONFLICT`, `DANGLING-DEP`, `DRIFT-FACT`, `(a)`, `(b)`, `(d)`, grammar), skill grammar + planning-time block, four operative prompts reference the authority, negative controls for `(e)`/`DECLARED-`/`PLAN-`/`CONFLICT-`. Mutation "reporting vocabulary" drops the class from the skill grammar and is caught | PASS |
| AC9 — reads only committed fixtures + live surfaces, never live `work/**`; no committed executable checker | `85:354-377` fixture-existence + read-only-contract (`grep -rq 'work/'` over the fixture); guard source reads no live `work/**`; fresh-clone-without-`work/` run passes. No production executable added (`git status` empty over production surfaces) | PASS (content); checker-absence is by diff/inspection with no dedicated assertion — see residual risk |
| AC10 — existing readiness/cycle/inventory agreements stay green; no duplicate assertion | `bash tests/run.sh` 334/0 (`10-readiness`, `80-cycle-fixture`, `40-inventory` green); `85` contains no readiness/cycle/inventory assertion (`grep -niE 'ready\|cyclic\|inventory'` → only a comment) | PASS |
| AC11 — each new guard mutated and caught/named; escaped mutation fails | `bash tests/mutation.sh` 39/0; five `AC23` mutations each name their sub-area. Strengthened to require `FAIL  AC23 <sub-area>` so a passing `ok` label cannot satisfy the check | PASS |
| AC12 — suite documents the new area and token; existing area list/tokens accurate | `tests/README.md:79` Checks-table row and `:112-137` `AC23` mapping paragraph + manual-residual sentence; diff adds only the new row/paragraph | PASS (inspection; documentation-only, no automated assertion — consistent with the existing suite) |
| AC13 — fresh clone with no `work/` exits 0 with all new assertions satisfied | independent `tar` copy excluding `work/`: `bash tests/run.sh <copy>` → `334 passed, 0 failed`; mutation harness's clean-copy runs likewise | PASS |

## Edge-case coverage

| Edge case | Test | Result |
| --------- | ---- | ------ |
| No declarations | `9019-none` (`—`), `9002-roadmap-b/0001-shared`, `9003-roadmap-old/0001-old`; `85:499-503` negative assertion | PASS |
| Absent column | legacy 5-column `9003-roadmap-old/roadmap.md`; `85:384-385` legacy-header assertion | PASS |
| Bare-reference ambiguity | top-level `0001-shared` decoy + `85:487-490` sibling-first assertion | PASS |
| Cross-roadmap same-token | `85:534-538` `9001-roadmap-a/0002-sibling\|9002-roadmap-b/0002-sibling` negative control | PASS |
| Directory surface target | `9014-dir-surface` → `docs`; adversarial non-existent dir probe caught | PASS |
| Malformed surface target | `9015-bad-targets` → `docs/*.md`, `../escape`, `/abs.md`; glob-only probe caught | PASS |
| Duplicate / empty / self-referential | `9017-duplicate`, `9018-empty`, `9016-self`; triple-duplicate probe caught | PASS |
| Shipped target | `9013-names-shipped` → `9001-roadmap-a/0004-shipped` resolves; excluded as counterpart | PASS |
| Unspecced child (`.gitkeep` only) | `9001-roadmap-a/0006-unspecced` represented by its parent cell `tests/fixtures` | PASS |
| Reciprocal naming | `85:517-519` exactly one `(b)` finding for `9001-roadmap-a/0001-shared` ↔ `0002-sibling` | PASS |
| Mutation staging | `tests/mutation.sh:72` stages `tests/fixtures/declared-conflicts`; five mutations green | PASS |
| Empty compared set | **added this pass**: `85:540-564` asserts the analyzer yields no findings for (a) unshipped items with no declarations and (b) an all-shipped set sharing a surface | PASS |

## Tests added in this pass

Only test files were touched; no production code, config, or another phase's
artifact was modified.

1. `tests/checks/85-conflict-guards.sh:540-564` — two focused assertions for the
   spec's empty-compared-set edge case, exercised directly against
   `fixture_conflicts` with a synthetic event stream (no new fixture required).
   Before this, the all-shipped/empty path was untested.
2. `tests/mutation.sh` — the five `AC23` `check_mutation` expectations now require
   the literal `FAIL  AC23 <sub-area>` in the log. Previously they matched the
   sub-area label that also appears on passing `ok` lines, so the "caught and
   named" claim could pass vacuously. The strengthened assertions still pass and
   now require a real failure line.

## Gaps and residual risk

- **Live model run is not executable in CI (by design).** Like the cycle
  diagnostic's LLM-run residual, whether `/conflicts`, `/status`, or the
  `/build`-gate actually emits these findings against live `work/**` can only be
  confirmed by running the agent. The guard pins the declared-conflict data,
  resolution, pair predicate, and reporting vocabulary, but not the model's
  emission. Documented in `tests/README.md:112-137`. Residual risk: low.
- **Fixture parser is a test-scoped re-instantiation of the authority.** The
  expected blocks encode the reviewed contract; the guard asserts the authority's
  vocabulary but not algorithmic equivalence. A future change to
  `docs/workflow.md` must update the fixture and guard together (design
  risk). The mutation guard covers the five critical axes. Residual risk: medium,
  inherent to a no-committed-checker contract.
- **AC9 "no committed executable checker added" has no dedicated assertion.**
  Verified by the working-tree diff (no production executable) and the
  fixture read-only contract; it is not mechanically falsifiable from inside the
  suite. Residual risk: low.
- **AC12 documentation is verified by inspection**, as the existing suite has no
  agreement asserting that every `tests/checks/*.sh` appears in the README table.
  Residual risk: low.
- No flaky, sleep-based, or order-dependent tests were introduced; the suite is
  read-only and fixes no timing dependency.
