---
feature: 0015-recursive-workflow-guards/0001-recursive-structure-guard
phase: review
status: final
created: 2026-10-14
updated: 2026-10-14
parent: 0015-recursive-workflow-guards
---

# Review — Recursive model, reference, and allocation guard

## Verdict

**approve** — the change adds a self-contained, fixture-based agreement area that
satisfies every acceptance criterion I can substantiate, edits no production
surface, and presents no defect I can defend; the only claims not independently
re-executed here are the suite/mutation run results, which this review
environment cannot run (see "Not reviewed").

No finding of any severity survives, so the verdict is `approve`.

## Diff basis and method

Exact commands:

- `git merge-base HEAD origin/main` → `a006142` = `HEAD`. The item's plan commit
  is already contained in `origin/main`, so the implementation under review is
  the uncommitted working tree, and the base is `HEAD`.
- `git status --porcelain=v1 --untracked-files=all`
- `git diff` / `git diff --stat`
- Read every untracked file in full (the new check file and all 17 fixture
  files) and the touched `tests/mutation.sh` hunk.

Surfaces under review:

- Modified: `tests/mutation.sh` (one appended line), and the item's own
  `tasks.md` (check boxes only).
- New: `tests/checks/81-recursive-structure-guard.sh`;
  `tests/fixtures/recursive-structure/**` (17 committed files);
  `work/<item-ref>/verify.md` (tester artifact).
- No file under `docs/**`, `.opencode/**`, `README.md`, `AGENTS.md`, or
  `template/**` is touched (AC16).

`work/<item-ref>/challenges.md` is absent, so there was no open challenge to
adjudicate before forward work; no prior `review.md` exists.

## Findings

### Blockers

- None.

### Major

- None.

### Minor

- None.

### Nits

- None.

## Acceptance criteria walk

| AC | Result | Evidence |
| -- | ------ | -------- |
| AC1 fixture depth | met | `tests/checks/81-recursive-structure-guard.sh:176-186` reports `bad` (never `skip`) when `$RS_ITEMS` is absent; `rs_max_depth` (`:76-91`) fails below 4. Deepest committed branch is `9001-tree/0001-branch/0001-leaf/0001-deep` (4 levels; confirmed on disk). |
| AC2 hybrid node | met | `:188-212` finds a node holding both a manifest and an own phase artifact. `tests/fixtures/recursive-structure/items/9001-tree/` holds `manifest.md` + `spec.md` + `tasks.md`. |
| AC3 per-level reservation marker | met | `:214-253` checks every child of every manifest node carries `.gitkeep` and that a marker-only leaf exists. On disk all 8 child `.gitkeep`s exist; `0001-deep`, `0009-dup-x`, `0009-dup-y`, `0002-leaf`, and `9002-tree/0001-branch/0001-leaf` are marker-only. |
| AC4 per-level allocation scoping | met | `:255-303`: ≥2 parents begin at `0001` (fixture yields 5: `9001-tree`, `9001-tree/0001-branch`, `9001-tree/0001-branch/0001-leaf`, `9002-tree`, `9002-tree/0001-branch`); the grandchild `9001-tree/0001-branch/0001-leaf` is listed under its immediate parent and its `parent:` frontmatter is `9001-tree/0001-branch`. |
| AC5 reference nests to depth | met | `:305-322`: `9001-tree/0001-branch/0001-leaf/0001-deep` resolves and matches the grammar; the literal grammar is pinned with `need "$CONV"` against `docs/artifact-conventions.md:87`. |
| AC6 top-level duplicate derived | met | `:330-352`: `rs_dup_findings` (`:133-158`) emits exactly `DUPLICATE-PREFIX\|9010-dup-a\|9010-dup-b` and the derived set is compared to the committed expected block (`:334-338`). Traced the two top-level loops and the prefix comparison. |
| AC7 same-parent depth ≥3 duplicate derived | met | `:354-359`: the expected block's `DUPLICATE-CHILD` line carries both full refs, the shared parent `.../0001-leaf`, and the shared local prefix `0009`; the depth gate (`:151`, `gsub("/","/",a) >= 2`) matches the design's "depth ≥ 3 segments". |
| AC8 position never mislabeled | met | `:361-377`: expected-block equality plus six negative clamps; the two finding kinds are emitted by separate loops (`:138-155`), and the cross-parent equal-text pairs (`0001-branch`, `0001-leaf`) are proven absent. `rs_dup_findings` keys identity on the full parent path (`par[i] == par[j]`). |
| AC9 model uniform at every node | met | `:390-395` pin `applies uniformly at every node`, `no maximum recursion depth`, `nesting continues to arbitrary depth`; all three verified present in `docs/workflow.md` (lines 61, 62, 157). |
| AC10 task entries are not nodes | met | `:400-416`: pins `are **not** nodes` (`docs/workflow.md:105`) and scans the fixture — `9001-tree/tasks.md` lists `T1`/`T2`, no `T*` directory exists. |
| AC11 reservation/allocation prose pinned | met | `:420-428`: flatten-matched `each child directory is reserved with a `.gitkeep` at that level` (`docs/artifact-conventions.md:196-197`) and `scoped to its **immediate** parent` (`:685-686`), plus `need` on `greatest 4-digit prefix ever committed under that parent and add one` (`:684`) and `never reused within that parent` (`:688`). I confirmed each phrase flattens to the asserted substring. |
| AC12 no committed executable checker | met | `:430-454` extracts the `### Merge-integrity guard` and `## Declared-conflict check` sections and pins `prompt behavior only` + `no committed checker, script, helper, or executable tool` in each (both confirmed present; the latter wraps and is flatten-matched). `:478-501` pins that the guard itself lives under `tests/checks/` and no production surface (`.opencode`, `docs`, `README.md`, `AGENTS.md`) names its stem. |
| AC13 read-only and self-contained | met | `:456-476` fails when the fixture references `work/` or an absolute/escaping token; confirmed the fixture contains neither (`grep` over `tests/fixtures/recursive-structure` finds no `work/`, no `..`, no `/(home|tmp|Users|etc|var|root|opt|mnt)/`). The guard reads only `$RS_ROOT`, `$CONV`, `$WF`, and the production-surface trees; it writes nothing and takes no lock. |
| AC14 suite stays green | met (static) | The area is sourced by `tests/run.sh` with no `run.sh` edit, labels all 37 assertions `AC27`, and is registered nowhere it needn't be. I confirmed no existing area enumerates `tests/checks/*.sh` or validates a registration table, and that `80-cycle-fixture.sh:66-71` (which scans all of `tests/fixtures` for `roadmap.md`) is unaffected because the new fixture uses `manifest.md`. Not independently re-executed (see "Not reviewed"). |
| AC15 mutation clean runs stay green | met (static) | `tests/mutation.sh:122` stages `tests/fixtures/recursive-structure` into the clean copy, so the two whole-suite clean runs and every worker copy see the fixture root. Append-only, single line, as designed. Not independently re-executed. |
| AC16 no production surface touched | met | `git status`/`git diff --name-only -- ':!work/'` name only `tests/mutation.sh` (modified) plus new files under `tests/checks/` and `tests/fixtures/recursive-structure/`; no `docs/**`, `.opencode/**`, `README.md`, `AGENTS.md`, or `template/**`. |

## Correctness, security, tests, conventions, scope

- **Correctness.** I re-derived `rs_alloc_events` → `rs_dup_findings` by hand over
  the committed tree: the only top-level prefix collision is `9010-dup-a`/
  `9010-dup-b`, and the only same-parent collision is `0009-dup-x`/`0009-dup-y`
  under `.../0001-leaf`; the emitted, `LC_ALL=C sort`-ordered set equals the
  committed expected block, and command-substitution trailing-newline stripping
  makes the `[ "$RS_DUP_ALL" = "$RS_EXPECTED_DUP" ]` comparison sound.
- **Shell robustness.** The helpers are bash-3.2-safe (no associative arrays, no
  `mapfile`; read loops fed by process substitution), the file is sourced so it
  calls no `exit`, and all variables referenced under `set -u` are initialized.
  No symbol collision with the other single-process sourced areas (`RS_*`/`rs_*`
  appear only here).
- **Security.** No secrets, no network, no writes, no `eval`; input is committed
  fixture data.
- **Tests.** The guard is itself the test and is reasonably mutation-sensitive
  (37 assertions; the expected-block equality is the load-bearing check, with the
  negative clamps and the prose pins as additional tripwires). I did not find a
  weakened or vacuous assertion that would let a real regression pass.
- **Conventions.** Matches the sibling fixture guards (`80`, `85`, `87`): one
  `tests/checks/*.sh` per area, `ok`/`bad`/`need` harness reuse, manifest-then-
  alias resolution, `AC27`-labelled sub-areas, `LC_ALL=C` ordering.
- **Scope.** Purely additive; the only shared surface touched is the one
  `stage_copy()` line, exactly as designed. No scope creep.

## Not reviewed (nuances, not findings)

- **Execution of the suite/mutation pass.** This sandbox denies `bash`, so I
  could not execute `bash tests/run.sh`, `FRAMEWORK_TEST_AREAS=81-... bash
  tests/run.sh`, or `bash tests/mutation.sh`. AC14/AC15 rest on the recorded
  results in `verify.md` plus my static confirmation that the fixture is present,
  the labels are `AC27`, and the `stage_copy()` line exists. If a maintainer wants
  an independently re-run proof, that is the remaining gap.
- **The guard derives structure from directory names and `parent:` frontmatter,
  not from the fixture manifests' `Children` tables** (`verify.md` records this).
  That is within scope: no acceptance criterion here requires table parsing, and
  `0004-recursive-integrity-guard` owns the invariant set.
- **`AC27` is provisional** (design's carried-forward open issue); registration in
  `tests/README.md` and the committed mutation jobs are owned by
  `0005-guard-registration-sweep`. Not a defect of this item.
- **The read-only scan covers the fixture text, not the guard script**
  (`verify.md` acknowledges it). The script contains no resolved absolute or
  escaping path; the `\.\.`/`/(home|…)/` tokens are its detection regex, not a
  path it uses. I agree this is a documentation nuance, not an unmet criterion.
