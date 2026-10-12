---
feature: 0007-phase-backtracking/0007-backtracking-guards
phase: review
status: final
created: 2026-10-09
updated: 2026-10-09
parent: 0007-phase-backtracking
---

# Review — Committed backtracking and reopen guards

## Verdict

**approve** — all fourteen acceptance criteria are met, the change is
`tests/**`-only and additive, and the committed suite plus the opt-in mutation
self-check are independently green; no Blocker or Major finding survives, and the
remaining Minor/Nit findings are documentation-only and affect no acceptance
criterion.

## Base and commands

The item is a nested roadmap child. `HEAD` (`1fc97e9`, the plan-record commit)
equals `git merge-base HEAD origin/main`; the plan is already merged on
`origin/main` (`230714d`). All build work is uncommitted in the working tree, so
the reviewed range is the working tree against `HEAD`.

```
git merge-base HEAD origin/main        # 1fc97e9…
git rev-parse HEAD origin/main         # HEAD=1fc97e9…, origin/main=230714d…
git status --porcelain                 # 3 modified, 4 untracked trees/files
git diff HEAD --stat                   # tests/README.md, tests/mutation.sh, tasks.md
git diff HEAD -- tests/README.md tests/mutation.sh
```

Untracked artifacts (`tests/checks/87-backtrack-guards.sh`,
`tests/fixtures/backtracking/**`, the item's `backtracks.md` and `verify.md`)
were read directly. I also re-ran the suite via a delegated read-only shell after
the primary sandbox denied direct `bash`:

```
bash tests/run.sh        -> TOTAL: 448 passed, 0 failed, 0 skipped  (exit 0)
bash tests/mutation.sh   -> MUTATION TOTAL: 57 checked passed, 0 failed (exit 0)
bash tests/run.sh | grep -c AC24 -> 104
```

## Acceptance criteria

| AC | Status | Evidence |
| -- | ------ | -------- |
| AC1 reverse-edge recording | **met** | `87-backtrack-guards.sh:92-127` (`fixture_backtrack_findings`) parses detecting/target/affected/status from every `backtracks.md`; expected block at `:236-245` covers `/build`→`/plan`, `/plan`→`/spec`, `/test`→`/plan`, `/test`→`/spec`; `:255-262` asserts the five live intra-item edge rows in `docs/workflow.md`. A dropped field diverges the block and names `AC24 reverse-edge` (mutation 1). |
| AC2 record effective status | **met** | `:130-154` keys `resolved` on a matching `## Resolution <n>` header; expected block `:267-276` has `9107-resolved` resolved and `9108-malformed` open/unmatched, with `wellformed=0` for the resolution-before-finding case; malformed set `:285-296` is `{9108-malformed}`. Mutation 2 renames the header and is caught. |
| AC3 per-edge stale-downstream | **met** | `:163-174` (`fixture_stale_map`) + expected block `:301-332`: `9101`/`9103` downstream `stale: design`, `9102`/`9104` `stale: spec`, `9105`/`9106` `NONE`; `:342-347` assert target artifacts unmarked; `:350-354` assert the rework edges force no marker. Mutation 3 is caught. |
| AC4 challenge/response & adjudication | **met** | `:395-457` cover the four entry kinds, `type`/`decision`/adjudicator token sets, effective status, and `9111-challenge-malformed`; expected blocks `:465-539`; `:542-543` assert a `Reversal` leaves the challenge `resolved`. Mutation 4 drops the `Reversal` and is caught. |
| AC5 parent-roadmap revision integrity | **met** | `fixture_revision` (`:601-713`) checks positional header (`:608`), dep-names-a-row/no-self (`:616-629`), Kahn acyclicity (`:633-665`), canonical-ref resolution (`:667-673`), active-child listing vs withdrawal record (`:677-691`), preserved-but-unlisted withdrawal (`:686-691`), sequencing order (`:693-712`); revision-note/withdrawal pins at `:725-736`. Mutation 5 is caught. |
| AC6 recalled-item readiness revocation | **met** | `fixture_readiness`/`fixture_readiness_blocked` (`:755-796`); expected `0001-recalled|0`, `0002-approved|1`, `0003-shipped|1`, blocked `0004-dependent|0001-recalled` (`:798-825`); no stored readiness column (`:828-832`). Mutation 6 is caught. |
| AC7 derived states | **met** | `bt_derive`/`fixture_derived` (`:845-878`) apply the precedence; expected block `:881-899` yields `design/spec (backtracked)`, `design (reopened)`, `challenged (blocked)`, and `shipped`; `:908-927` assert a shipped item is never challenged and a stale marker outranks an open challenge. |
| AC8 absent records are no-ops | **met** | `9107`/`9108`/`9114` derive `build` and `9116-empty` derives `not started`; `:929-938` assert none invents a backtracked/challenged/reopened state. |
| AC9 documented-contract pins | **met** | `:950-986` pin the record/field/marker/token/label strings on `docs/artifact-conventions.md` (21 pins) and `docs/workflow.md` (9 pins), each labelled with the named authority; no readiness algorithm or command signature is restated. Mutation 8 is caught. |
| AC10 fixture-based, fresh-clone safe | **met** | `fixture-existence` fails via `bad` (never `skip`) at `:184-209`; `read-only-contract` asserts no live `work/`, no nested `work/`, and no absolute/escaping path (`:211-231`). The mutation copy carries no `work/` and exits 0. |
| AC11 mutation coverage | **met** | Eight mutations in `tests/mutation.sh:348-410`, one per declared sub-area; independent `bash tests/mutation.sh` run: `MUTATION TOTAL: 57 checked passed, 0 failed`. |
| AC12 no duplication, existing areas green | **met** | `no-duplication` (`:988-1033`) references `10`/`20`/`80`/`85`/`96` by name and negates their exact literals (assembled at runtime so the check cannot match itself); full suite green with all existing areas passing. |
| AC13 documentation | **met** | `tests/README.md:80` Checks row; `:139-180` `AC24` mapping paragraph naming the sub-areas, fixture root, never-reads-`work/**` contract, mutation coverage, and the LLM-run residual. |
| AC14 scope and purity | **met** | `git status` shows only `tests/**` plus the item's own `tasks.md`/`backtracks.md`/`verify.md`; no production surface, command, agent, skill, `phase`, state file, or checker is added; no network/provider call. |

Edge cases from the spec are exercised as the tester recorded: missing fixture
(independent probe), self-containment (no absolute/escaping path), malformed/out-
of-order records (`9108`, `9111`), withdrawal vs unlisted child, cyclic/dangling
deps (probed), `.gitkeep`-only `9116-empty`, backtrack-plus-challenge precedence
(`9115-stale-challenge`), and shipped-with-open-challenge (`9112`).

## Findings

### Blockers

- None.

### Major

- None.

### Minor

- **[m1] `read-only-contract` does not assert what design §4 says it asserts** —
  `docs`-facing prose vs code. `design.md:195-197` says `read-only-contract` asserts
  "that the check adds no committed executable production checker"; the
  implemented assertion at `tests/checks/87-backtrack-guards.sh:211-231` only
  verifies the fixture tree's no-live-`work/`, no-nested-`work/`, and
  no-absolute/escaping-path properties. AC10 does not require a
  no-production-checker assertion (that is a non-goal verified by AC14's scope
  check), and the file header/comment states the property, so nothing fails.
  Recommend either adding a one-line assertion the check file is test-scoped
  (e.g. that it is not referenceable as a production surface) or correcting the
  design prose on the next `/plan` revision. Non-blocking.

### Nits

- **[n1] Pin count overstated.** `verify.md:58` says `AC24 contract-pins` covers
  "31 pins"; the sub-area defines 30 (21 on `docs/artifact-conventions.md` +
  9 on `docs/workflow.md`, `tests/checks/87-backtrack-guards.sh:950-986`).
- **[n2] `check_mutation` substring matching is coarse.** `tests/mutation.sh:103`
  greps the log for the expected substring, so an unrelated failure combined with
  a passing target `ok` line could in principle be read as "caught". This is
  pre-existing harness behavior (all `AC6`–`AC23` cases share it) and the tester
  independently confirmed a `FAIL AC24 <sub-area>` line for each of the eight
  mutants; recorded only for transparency.

## Not reviewed

- Actual Bash 3.2 execution: no 3.2 interpreter is available; compatibility is
  reviewed by inspection (no associative arrays, no `mapfile`, no empty-array
  expansion under `set -u`) and matches the `85`/`80` precedent.
- Live LLM-run behavior (a real `/status` render, a real backtrack, a real
  `/ship recall`) — deliberately a documented manual residual, not executable in
  CI.
- The `work/0007-phase-backtracking/roadmap.md` parent and the six sibling
  contracts (`0001`–`0006`) are consumed unchanged and were not re-reviewed.
- `visual.md`: not applicable; the item has no user-facing surface.

## Handoff notes

No open `challenges.md` exists and no open `backtracks.md` finding targets
`/review` (Findings 1 and 2 target `/plan` and both carry matching Resolutions),
so no challenge adjudication was required. The two build-time design defects
(`challenge-loop` and `record-status` mutation anchors) are corrected in
`design.md` §5 and the shipped `tests/mutation.sh` matches the corrected anchors,
so the backtracks are closed for this phase.
