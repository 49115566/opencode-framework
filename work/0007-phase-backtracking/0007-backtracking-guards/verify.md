---
feature: 0007-phase-backtracking/0007-backtracking-guards
phase: test
status: final
created: 2026-10-09
updated: 2026-10-09
parent: 0007-phase-backtracking
stale: ""
---

# Verification — Committed backtracking and reopen guards

## Summary

The work item adds one fixture-based agreement area,
`tests/checks/87-backtrack-guards.sh` (suite token `AC24`), a fixture-local item
tree under `tests/fixtures/backtracking/items/`, eight new `tests/mutation.sh`
mutations, and the `AC24` documentation paragraph. Every acceptance criterion
passes on the committed suite and the opt-in mutation self-check. No production
surface (`docs/**`, `.opencode/**`, `README.md`, `AGENTS.md`, `template/**`,
`opencode.json`, the parent `roadmap.md`) is touched.

No `challenges.md` exists for this item and no open `backtracks.md` finding
targets `/test` (both recorded findings target `/plan` and carry matching
resolutions), so no challenge adjudication was required and this run is ordinary
forward progression.

Two spec-listed edge cases were not exercised by the reviewed fixture set
(stale-versus-challenge precedence; the `.gitkeep`-only `not started` item) and
the fixture self-containment edge case asserted only the no-live-`work/` half.
The tester added focused fixtures and assertions for all three (test files only;
no production change). They are called out in the matrix and in "Tests added".

## Commands run

| Command | Result | Notes |
| ------- | ------ | ----- |
| `bash tests/run.sh` | PASS | `TOTAL: 448 passed, 0 failed, 0 skipped`; exit 0 |
| `bash tests/mutation.sh` | PASS | `MUTATION TOTAL: 57 checked passed, 0 failed`; exit 0; every `AC24` mutation caught and named |
| `git status --porcelain -- docs .opencode README.md AGENTS.md template opencode.json work/0007-phase-backtracking/roadmap.md` | PASS | empty — no production surface changed |
| `grep -rn 'work/' tests/fixtures/backtracking` | PASS | no match — fixture tree references no live `work/` |

AC24-only run (`bash tests/run.sh | grep -c 'AC24'`): 104 labelled assertions,
all `ok`.

## Acceptance coverage

| Criterion | Test(s) | Result |
| --------- | ------- | ------ |
| AC1 reverse-edge recording | `tests/checks/87-backtrack-guards.sh` → `AC24 reverse-edge` (expected block + five live edges); mutation 1 (`AC24 reverse-edge`) | PASS |
| AC2 record effective status | `AC24 record-status` (expected open/resolved block + `9108-malformed` wellformed 0); mutation 2 | PASS |
| AC3 per-edge stale-downstream | `AC24 stale-downstream` (per-artifact expected block + target-own-artifact-unmarked + rework-no-marker); mutation 3 | PASS |
| AC4 challenge/response record & adjudication | `AC24 challenge-loop` (four entry kinds, `type`/`decision`/adjudicator token sets, effective status, Reversal-no-reopen, `9111` malformed); mutation 4 | PASS |
| AC5 parent-roadmap revision integrity | `AC24 roadmap-revision` (positional columns, dep-names-a-row, no-self, acyclic, refs-resolve, active-child listing, sequencing order, withdrawal preserved-but-unlisted, revision-note fields); mutation 5 | PASS (plus 6 independent integrity probes, below) |
| AC6 recalled-item readiness revocation | `AC24 readiness-revocation` (recalled 0 / approved 1 / shipped 1; dependent blocked by `0001-recalled`; no stored readiness column); mutation 6 | PASS |
| AC7 derived states | `AC24 derived-state` (backtracked, reopened, challenged, shipped-never-challenged) | PASS |
| AC8 absent records are no-ops | `AC24 derived-state` (`9114-forward`→`build`, `9116-empty`→`not started`, invent-no-state) | PASS |
| AC9 documented-contract pins | `AC24 contract-pins` (31 pins on `docs/artifact-conventions.md` + `docs/workflow.md`); mutation 8 | PASS |
| AC10 fixture-based, fresh-clone safe | `AC24 read-only-contract` (no live `work/`, no nested `work/`, no absolute/escaping path), `AC24 fixture-existence` (fails, never skips); `bash tests/mutation.sh` clean copy with no `work/`; independent missing-fixture probe | PASS |
| AC11 mutation coverage | `bash tests/mutation.sh` → 57/57, all eight `AC24` mutant sub-areas caught and named; independent sub-area precision probe | PASS |
| AC12 no duplication, existing areas green | `AC24 no-duplication` (references `10`/`20`/`80`/`85`/`96` by name; negates their literals); full suite green | PASS |
| AC13 documentation | `tests/README.md:80` Checks row, `tests/README.md:139` `AC24` mapping paragraph naming sub-areas, fixture root, never-reads-`work/**` contract, mutation coverage, and the manual LLM-run residual | PASS |
| AC14 scope and purity | `git status` shows only `tests/**` plus the item's own `tasks.md`/`backtracks.md`; no command/agent/skill/phase/state-file/checker; guards call no network/provider | PASS |

### Edge cases

| Edge case | Coverage | Result |
| --------- | -------- | ------ |
| No live `work/**` | `AC24 read-only-contract`; mutation clean copy (no `work/`) exits 0 | PASS |
| Missing fixture | Independent probe: deleting `9101/backtracks.md` yields `FAIL AC24 fixture-existence: … missing`, exit 1 (never `skip`) | PASS |
| Fixture self-containment | `AC24 read-only-contract` asserts no live `work/`, no nested `work/`, and no absolute/escaping path | PASS (assertion added; see Tests added) |
| Malformed / out-of-order records | `9108` resolution-before-finding and `9111` response-before-challenge are the only malformed sets | PASS |
| Deliberate withdrawal vs unlisted child | `fixture_revision` honours the `Withdrawn child —` record; an unlisted dir with no record emits `unlisted-child` (probed) | PASS |
| Cyclic or dangling dependency | Independent probes: true cycle → `acyclic`; dangling → `dep-names-row`; self-dep → `dep-self`; unresolved ref → `refs-resolve` | PASS |
| Empty / `.gitkeep`-only item | New fixture `9116-empty` derives `not started` and invents no state | PASS (test added) |
| Backtrack and challenge both present | New fixture `9115-stale-challenge` derives `design (backtracked)` and is never `challenged`; reordering the guard fails `AC24 derived-state` | PASS (test added) |
| Shipped item with open challenge | `9112-shipped-challenge` stays `shipped`, never `challenged` | PASS |
| Repeat / parallel runs | Suite is read-only and writes nothing; the mutation self-check runs the suite repeatedly on one copy and every clean run passes | PASS (by construction; no separate assertion) |
| Optional tools absent | `FRAMEWORK_TEST_NO_PY/_OPENCODE/_NPM=1` clean runs exit 0 with visible skips | PASS |
| Bash 3.2 compatibility | No associative arrays, no `mapfile`, no empty-array expansion under `set -u`; reviewed by inspection (no Bash 3.2 binary available in this environment) | MANUAL |
| LLM-run residual | Documented in `tests/README.md` — a live `/status` render, a real backtrack, or a `/ship recall` is not executable in CI | MANUAL |

## Independent checks (beyond the committed assertions)

- **Mutation precision.** Staged a clean copy and applied each of the eight AC24
  mutations individually, then confirmed the suite emitted a
  `FAIL  AC24 <sub-area>` line naming the expected sub-area (not merely a passing
  `ok` line containing the substring). All eight named their target sub-area.
  The `stale-downstream` mutation also trips `derived-state` (the changed
  `stale:` token also changes the earliest marker); the design's risk note allows
  a mutation to trip more than one sub-area.
- **Roadmap-integrity depth.** Only the positional header is mutated by the
  committed self-check, so the other integrity rules were probed directly:
  a true two-node cycle → `acyclic|0003-dep 0004-dependent`; a dangling dep →
  `dep-names-row|…`; a self-dep → `dep-self` + `acyclic`; an unresolved canonical
  reference → `refs-resolve|…`; an unlisted child dir → `unlisted-child|…`; a
  sequencing inversion → `sequencing|…`. None is vacuous.
- **Precedence sensitivity.** Reordering the copied guard's `bt_derive` to test
  the challenge condition before the `stale:` loop produced
  `FAIL AC24 derived-state` including "a stale marker outranks an open challenge"
  and "a backtrack-and-challenge item was derived challenged"; the unmodified
  suite stayed at 448 passed. The new precedence assertion is falsifiable.

## Tests added

Only test files were changed (`tests/checks`, `tests/fixtures`):

- `tests/fixtures/backtracking/items/9115-stale-challenge/{spec,design,tasks,verify,backtracks,challenges}.md`
  — an item carrying both a `stale: design` marker and an open `Challenge 1`, to
  exercise the derived-state precedence (edge case "backtrack and challenge both
  present").
- `tests/fixtures/backtracking/items/9116-empty/.gitkeep` — a `.gitkeep`-only
  item to exercise the `not started` derivation (edge case "empty and
  `.gitkeep`-only item").
- `tests/checks/87-backtrack-guards.sh` — the two fixtures' expected lines in the
  `reverse-edge`, `record-status`, `challenge-loop`, and `derived-state` blocks;
  explicit precedence assertions; an absolute/escaping-path self-containment
  assertion; required-existence entries for the new fixtures; and `9116-empty` in
  the invent-no-state loop.

No committed assertion was weakened, skipped, or deleted.

## Gaps and residual risk

- **Bash 3.2 not exercised.** The suite is written to be Bash 3.2 compatible
  (no associative arrays, no `mapfile`, no empty-array expansion under `set -u`),
  but this environment provides only a newer Bash; 3.2 compatibility is verified
  by inspection, not by running a 3.2 interpreter.
- **LLM-run behavior remains a manual residual.** The real `/status` render, a
  real `/build`/`/plan`/`/spec` backtrack, and `/ship recall` are prompt behavior
  and are not executable in CI; only their recorded shapes and derived labels are
  pinned. This is documented in `tests/README.md` and matches the cycle/conflict
  guard precedent.
- **Parser drift risk.** The `AC24` analyzers are fixture-scoped instantiations of
  the `0001`–`0006` authorities; a future authority change must update the fixture
  and guard together. The `AC24 contract-pins` sub-area reduces (but cannot
  eliminate) this risk by pinning the documented shapes.
- **`AC24 no-duplication` scope.** The structural assertion negates a fixed set of
  literals owned by `10-readiness.sh`/`20-lifecycle.sh`/`96-signature-sweep.sh`;
  it cannot prove the absence of every possible restatement, only the named ones.
- `tests/README.md`'s `AC7/AC8` sentence still describes the derived-state
  sub-area accurately after the added fixtures; no README edit was required.

## Verdict

Every acceptance criterion is covered by a passing committed assertion, and the
new area is mutation-sensitive and fixture-scoped as specified. No implementation
defect was found, and no spec/design backtrack is warranted.
