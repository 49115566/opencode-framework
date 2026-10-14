---
feature: 0015-recursive-workflow-guards/0004-recursive-integrity-guard
phase: design
status: final
created: 2026-10-14
updated: 2026-10-14
parent: 0015-recursive-workflow-guards
conflicts-with: "tests/README.md, tests/mutation.sh"
---

# Design — Committed recursive merge-integrity and renumber guards

## Summary

Add one new fixture-based agreement area, `tests/checks/91-integrity-guard.sh`
(suite token `AC30`), plus its committed fixture root
`tests/fixtures/recursive-integrity/`. The area reimplements, read-only, the
merge-integrity invariant evaluation as a genuine recursive scan over the fixture
tree — the top level against top-level items and every decomposing node against
its own immediate children — and asserts its findings against a reviewed expected
block, so a regression that flattens the evaluation to two levels fails. A second
half exercises a committed fixture representing a completed whole-subtree
renumber and asserts no reference to the old canonical reference remains across
the full rewrite set. The area references the sibling agreement areas that own
overlapping literals (structure, cycle, packaging, renumber-sweep) by name and
re-asserts none of them. One line is added to `tests/mutation.sh`'s staged-copy
list so the opt-in whole-suite runs stay green, and
`tests/checks/80-cycle-fixture.sh`'s AC13 whole-set `roadmap.md` assertion is
narrowed to exclude the one documented deliberate drift alias so the committed
migration guard stays green with the dual-spelling fixture present. The area is
renamed off the collided `89-` numeric stem to the free `91-` stem so no two
merged areas share a selector prefix; the `AC30` token and sub-area labels are
unchanged (see "Renaming the area off the collided `89-` stem").

## Approach

### New agreement area

- **File.** `tests/checks/91-integrity-guard.sh`, sourced by the existing
  `tests/run.sh` glob (no `run.sh` edit), never calling `exit`, Bash 3.2
  compatible (no associative arrays, no `mapfile`, no empty-array expansion under
  `set -u`). It mirrors the structure of `tests/checks/85-conflict-guards.sh`
  and `tests/checks/87-backtrack-guards.sh`: a header naming the areas it defers
  to, `fig_*` helper functions, an events/findings analyzer emitting normalized
  sorted lines, and an expected block compared with `=`.
- **Token and sub-areas.** Every assertion is labelled `AC30 <sub-area>`. The
  named sub-areas are `per-node-eval`, `structural-graph`, `spelling-drift`,
  `report-only`, `renumber-sweep`, and the un-mutated structural labels
  `fixture-existence`, `read-only-contract`, `mutation-staging`, `no-duplication`.
  This is the token/sub-area surface the registration child (`0005`) targets.
- **Fixture root.** `tests/fixtures/recursive-integrity/items/`, using the
  manifest's high non-colliding `92xx` space, root-local ids only.

### Fixture tree (integrity half)

```
tests/fixtures/recursive-integrity/items/
  9201-clean/                     manifest.md, 0001-leaf/.gitkeep      clean, no finding
  9202-graph-faults/              manifest.md
    0001-present/.gitkeep          row present, dir present
    0003-dangling/.gitkeep         row Depends on 0099-ghost          -> DANGLING-DEP
    0004-withdrawn/.gitkeep        no row, recorded withdrawal        -> report-only
    0005-unlisted/.gitkeep         no row, no withdrawal record       -> UNLISTED-CHILD
    (row 0002-missing has no dir)                                     -> MISSING-CHILD
  9203-spelling-both/             manifest.md + roadmap.md           -> DRIFT-FACT
  9204-phase-mismatch/            manifest.md with phase: roadmap    -> DRIFT-FACT
  9210-dup-a/                      manifest.md, 0001-x/.gitkeep       -\ DUPLICATE-PREFIX
  9210-dup-b/                      manifest.md, 0001-y/.gitkeep       -/ (top level)
  9211-deep/                       manifest.md, 0001-mid/
    0001-mid/manifest.md           0001-alpha/.gitkeep, 0001-beta/.gitkeep
                                                                      -> DUPLICATE-CHILD (depth 3)
  9220-renamed-parent/            (renumber half — below)
```

`9202-graph-faults/manifest.md` carries the retained withdrawn-child record under
`## Open issues` in the `manifest.md` template shape, naming
`work/<parent>/0004-withdrawn/`; the record is the recognition signal that makes
its `UNLISTED-CHILD` observation report-only (by reference — see
`docs/workflow.md` → "Status reporting" and "Revising a decomposition").

### Fixture tree (renumber half)

```
9220-renamed-parent/
  manifest.md                     Children row: Local id 0002-new,
                                  Canonical reference 9220-renamed-parent/0002-new;
                                  a sibling row 0003-follower with Depends on: 0002-new
  0002-new/                       intermediate manifest on the changed path
    manifest.md                   Children row 0001-leaf -> Canonical reference
                                  .../0002-new/0001-leaf
    0001-leaf/spec.md             feature: 9220-renamed-parent/0002-new/0001-leaf
                                  parent: 9220-renamed-parent/0002-new
  0003-follower/design.md         conflicts-with: 0002-new
  0003-follower/ship.md           recorded ship/handoff path naming the new ref
```

The fixture represents a **completed** renumber: the new directory
`9220-renamed-parent/0002-new/` is present, and the old local id `0001-old` and
old canonical reference `9220-renamed-parent/0001-old` appear **nowhere** in the
fixture. The area hard-codes the old/new constants and asserts absence across the
whole fixture root by a recursive literal scan, then asserts the new reference is
present in each enumerated rewrite position (directory, `feature:`, `parent:`,
owning manifest `Local id`/`Canonical reference`, intermediate manifest
`Canonical reference`, `Depends on`, `conflicts-with`, ship path) so the absence
assertion is not vacuous on an empty tree.

### Analyzer and expected block

The area computes findings into three category blocks, each compared to its own
expected block so one mutation names one sub-area:

- `fixture_duplicates` → `DUPLICATE-PREFIX` / `DUPLICATE-CHILD` → `per-node-eval`.
- `fixture_graph` → `MISSING-CHILD` / `UNLISTED-CHILD` / `DANGLING-DEP` →
  `structural-graph`.
- `fixture_drift` → `DRIFT-FACT` → `spelling-drift`.

Each finding normalizes to `CODE|offender[,offender]` (offenders are canonical
refs relative to `items/`, sorted), and the block is `LC_ALL=C sort`ed. The
recursive scan (`fig_scan_node <ref> <dir> <parent-ref> <local-id> <rows>`)
resolves a manifest manifest-then-legacy-alias, parses the six-column `Children`
table by header name, compares rows against child directories (missing/unlisted),
resolves `Depends on` against rows and directories (dangling), groups child
directories by 4-digit prefix within the node (duplicate-child), detects a node
holding both manifest spellings or a spelling/phase mismatch (drift), and recurses
into every child whose directory holds a manifest. Top-level duplicate prefixes
are grouped once over `items/*/`. The depth-3 collision at
`9211-deep/0001-mid/0001-alpha` vs `.../0001-beta` is emitted by the recursion, so
a two-level-only evaluation misses it and fails `per-node-eval`.

### Report-only, contract pins, and structural assertions

- `report-only` asserts the guard's non-fatal/never-truncated/no-file-modified
  contract on the authority and the operational mirror (`docs/workflow.md` →
  "Merge-integrity guard"; `tests/checks/…` restates none), asserts
  `9202-graph-faults/0004-withdrawn` produces no `UNLISTED-CHILD` fault, and
  asserts the clean `9201-clean` node yields empty findings without error.
- `per-node-eval` also pins the recursive authority phrases (`docs/workflow.md` →
  "Merge-integrity guard": the invariant set is evaluated at every node, no
  node's check depends on another's; `.opencode/skill/merge-conflict/SKILL.md`:
  every node at every depth). These literals are owned by no sibling area.
- `renumber-sweep` asserts old-reference absence and new-reference presence, and
  (AC9) that the authority and the skill name the **intermediate manifest** on the
  changed path — the recursive specific the renumber-sweep area does not own —
  referencing `tests/checks/88-renumber-sweep.sh` by name and restating none of
  its literals.
- `fixture-existence` fails (never skips) when a required fixture file is absent.
- `read-only-contract` asserts the fixture tree references no live `work/` path
  and the area adds no committed executable checker or command.
- `mutation-staging` asserts `tests/mutation.sh`'s staged-copy list names
  `tests/fixtures/recursive-integrity`.
- `no-duplication` asserts the area header references the owning areas by name
  (`10-readiness`, `20-lifecycle`, `80-cycle-fixture`, `85-conflict-guards`,
  `87-backtrack-guards`, `88-renumber-sweep`, `90-packaging`, `96-signature-sweep`,
  and the structure guard `0001-recursive-structure-guard`) and does not re-assert
  their owned literals.

### Mutation staging

`tests/mutation.sh`'s `stage_copy()` gains one line copying the new fixture root
into the scratch copy. Without it the opt-in whole-suite runs (steps 1–2) would
fail once the check exists. The `tests/README.md` Checks row and the per-rule
mutation jobs remain `0005-guard-registration-sweep`'s responsibility.

### Reconciling the deliberate dual-spelling fixture with the committed AC13 guard

`tests/checks/80-cycle-fixture.sh` carries an AC13 **negative** assertion
(`80-cycle-fixture.sh:61-71`) that pins the `0012-roadmap-deprecation` migration:
`find tests/fixtures -name roadmap.md` must resolve to exactly the one retained
legacy alias `tests/fixtures/cyclic-roadmap/roadmap.md`, so a stray un-migrated
`roadmap.md` cannot hide behind the manifest-first resolver. The
`9203-spelling-both` node's deliberate second `roadmap.md` would otherwise break
that exact-equality and fail `bash tests/run.sh`.

This item owns the reconciliation. The assertion is **narrowed, not re-pinned**:
the stray-alias set is computed by excluding the single documented deliberate path
`tests/fixtures/recursive-integrity/items/9203-spelling-both/roadmap.md`
(`find … -name roadmap.md | grep -vxF <that path>`) and the remainder is still
compared for exact equality to the retained cyclic alias. The guard therefore still
fails on any *third* alias, and its intent — no *stray* alias survives migration —
is preserved: a *documented, deliberate* drift fixture is not a stray. The cycle
diagnostic itself (the `Children` parse and the `CYCLIC-DEP` contract assertions,
`80-cycle-fixture.sh:73-166`) is untouched, and the mutation job `job_8` is
unchanged. `89` references `80-cycle-fixture` by name for the migration guard and
re-asserts none of its literals (AC6). This is a scoped, intent-preserving
relaxation of the committed test suite, permitted by AC12 ("only the committed
test suite … are touched"); it edits no live surface.

The `80` edit is a focused single-item change, not one of the shared append-only
registries the four guards contend on, so it is **not** added to this item's
`conflicts-with` declaration. That declaration stays the parent cell's two
registries (`tests/README.md`, `tests/mutation.sh`, `manifest.md:126`), which
avoids a self-inflicted `DRIFT-FACT` and keeps the declared set semantically exact:
the two registries are where sibling plans actually collide.

### Renaming the area off the collided `89-` stem

The merged default branch carries `tests/checks/89-recursive-status-guards.sh`
(the `0002` readiness/status guard). Two distinct agreement areas sharing the
`89-` prefix would make every prefix selector ambiguous — `tests/README.md` →
"Area selection" defines a prefix matching two or more areas as a setup error —
so this area takes the free stem `91-integrity-guard.sh` (verified against
`origin/main:tests/checks`: no `91-` area exists, and the merged sibling guards
occupy `81-`, `85-`, and `89-`). The rename keeps the suite token `AC30` and every
sub-area label unchanged, so it is invisible to `0005-guard-registration-sweep`'s
mapping and to any mutation job. This resolves the collision the review found
rather than deferring it; the earlier "only an area-selector ambiguity, not a
suite failure" acceptance was wrong, because the merged tree would leave the
documented `FRAMEWORK_TEST_AREAS=89` selector a setup error.

The rename sweeps **every** textual reference to the old stem — not only the
three the review named. The complete set, each rewritten `89-integrity-guard` →
`91-integrity-guard`:

- the new check file's own name (`tests/checks/91-integrity-guard.sh`);
- its `FIG_SELF="$FIG_CHECKS_DIR/91-integrity-guard.sh"` resolver;
- its `read-only-contract` self-reference scan
  (`grep -rqF '91-integrity-guard' .opencode/`);
- its header comment naming the area;
- the AC13 cross-reference in `tests/checks/80-cycle-fixture.sh` (the deliberate
  dual-spelling exception's owning area, `80-cycle-fixture.sh:66`); and
- the six fixture-prose references under `tests/fixtures/recursive-integrity/`
  (`items/9201-clean/manifest.md`, `items/9220-renamed-parent/manifest.md`,
  `items/9220-renamed-parent/0002-new/manifest.md`,
  `items/9220-renamed-parent/0002-new/0001-leaf/spec.md`,
  `items/9220-renamed-parent/0003-follower/design.md`, and
  `items/9220-renamed-parent/0003-follower/ship.md`).

`T4` owns the rename and this sweep; its `Verify:` runs the area under the new
selector and asserts `grep -rF '89-integrity-guard' tests/` prints nothing, so a
leftover reference cannot survive green.

## Alternatives considered

- **A prose-only agreement check (pin the recursive authority phrases, no fixture
  or analyzer).** Pros: small, mirrors `88-renumber-sweep.sh`. Cons: cannot satisfy
  AC2/AC3/AC4 — nothing would fail if a *future* evaluation flattened to two
  levels, missed a nested graph fault, or treated a dual-spelling node as clean.
  Rejected: the spec's decided open question requires an exercised fixture, and a
  prose-only check is the exact gap this item closes.
- **Host the new integrity/renumber assertions inside `80-cycle-fixture.sh` /
  `88-renumber-sweep.sh` instead of a new area.** Pros: fewer files. Cons:
  breaches single-owner agreement areas and forces re-asserting sibling literals,
  failing AC6/AC11; conflates the cycle diagnostic and the renumber prose list
  with a new recursive-integrity concern. Rejected. (This is distinct from the
  accepted, narrowly scoped narrowing of `80`'s AC13 whole-set `roadmap.md`
  assertion — that relaxes the migration guard's stray-alias set for the one
  documented deliberate drift fixture, and hosts no new assertion.)
- **Renumber half re-pins the authority's prose lists (like `88`).** Pros: cheap.
  Cons: `88-renumber-sweep.sh` already owns the prose rewrite lists; re-pinning is
  duplication (AC9/AC11) and proves nothing about a *completed* renumber.
  Rejected in favor of the completed-renumber fixture plus a single unowned
  intermediate-manifest pin.
- **Move the deliberate drift alias out of the `tests/fixtures/**` find root (a
  second fixture root, or a root outside `tests/fixtures/`) instead of narrowing
  `80`'s AC13 assertion.** Pros: leaves the committed migration guard
  byte-identical. Cons: breaks the single-`tests/fixtures/` fixture convention and
  splits one fixture root across two locations; leaves the whole-set assertion with
  a blind spot for the relocated root. Rejected in favor of the scoped narrowing,
  which keeps the fixture in the canonical tree and the guard still sensitive to
  any *third* alias.
- **Defer the area rename to `0005-guard-registration-sweep` instead of renaming
  it here.** Pros: leaves this item's stated check filename unchanged and touches
  one fewer path. Cons: `0005`'s scope (`manifest.md:127`) is only the
  `tests/README.md` Checks row/paragraph and the mutation jobs — it does not
  include renaming this area's check — so deferral would leave two distinct areas
  sharing the `89-` stem in the merged tree and the documented
  `FRAMEWORK_TEST_AREAS=89` selector a setup error, i.e. an unresolved collision,
  not a handled one. Rejected: the owning plan renames its own area (see
  "Renaming the area off the collided `89-` stem").

## Interfaces and data model

- **New file** `tests/checks/91-integrity-guard.sh` — sourced, not executed; no
  `exit`; read-only; prints `ok`/`FAIL` lines labelled `AC30 <sub-area>`. Public
  surface for `0005`: the area name `91-integrity-guard` and the sub-area labels.
- **New fixture root** `tests/fixtures/recursive-integrity/` — root-local
  `92xx` entity ids; item references resolve inside `items/`, never against live
  `work/`.
- **Changed files** `tests/mutation.sh` — one additive `cp -R` line in
  `stage_copy()`; no job, no `JOB_COUNT` change — and
  `tests/checks/80-cycle-fixture.sh` — the AC13 whole-set `roadmap.md` assertion
  narrowed to exclude the one documented deliberate drift alias; the cycle
  diagnostic and `job_8` unchanged.
- **No production interface.** No `phase` value, state file, command, agent,
  skill, or committed production checker is added or changed. The authority docs
  and prompts are the pinned target, not the guarded artifact.

**Backward compatibility.** The change is essentially additive — a new
auto-sourced check file, a new fixture root, and one staged-copy line — plus one
scoped, intent-preserving relaxation of `tests/checks/80-cycle-fixture.sh`'s AC13
whole-set `roadmap.md` assertion so the deliberate drift fixture is permitted while
any *stray* alias still fails (see "Reconciling the deliberate dual-spelling
fixture…"). No other area, fixture, selector, or harness behavior changes, so
`bash tests/run.sh` and the existing area selections stay green with no migration.

## Affected areas

- `tests/checks/91-integrity-guard.sh` (new).
- `tests/fixtures/recursive-integrity/**` (new).
- `tests/checks/80-cycle-fixture.sh` — the AC13 whole-set `roadmap.md` assertion
  narrowed to exclude the one documented deliberate drift alias (see "Reconciling
  the deliberate dual-spelling fixture…"); the cycle diagnostic and `job_8`
  untouched.
- `tests/mutation.sh` (`stage_copy()` — one line).
- Explicitly **not** touched here: `tests/README.md` and the mutation jobs
  (`0005-guard-registration-sweep`); `docs/**`, `AGENTS.md`, `template/**`,
  `README.md`, `.opencode/**` (pinned target).

## Risks and mitigations

- **A self-inflicted `DRIFT-FACT`.** The parent row's `conflicts-with` cell
  declares `tests/README.md, tests/mutation.sh`; if this item's `design.md`
  declaration differed, the read-only check would report drift. — Likelihood
  medium / impact low / mitigation: declare the identical set in this design's
  frontmatter (no self-reference, no duplicate); the `80-cycle-fixture.sh` edit is
  deliberately not declared because it is not a shared collision surface (see
  "Reconciling the deliberate dual-spelling fixture…").
- **The AC13 migration guard is weakened by the relaxation.** — Likelihood low /
  impact medium / mitigation: exclude only the one exact documented deliberate
  path; the remainder must still equal the retained cyclic alias, so any third or
  stray alias still fails. T1's `Verify:` reintroduces a scratch third alias under
  `tests/fixtures/` and confirms `80` fails naming `unexpected roadmap.md fixture
  set`.
- **Numeric-prefix collision with the merged sibling area.** — Likelihood low /
  impact medium / mitigation: the area is renamed off the collided `89-` stem to
  the free `91-integrity-guard.sh`, verified free against
  `origin/main:tests/checks` (the sibling guards occupy `81-`, `85-`, and `89-`);
  no two areas then share a numeric stem, so every prefix selector resolves
  uniquely. The `AC30` token and sub-area labels are unchanged, and the two
  append-only registries (`tests/README.md`, `tests/mutation.sh`) stay declared
  conflicts reconciled by `0005`.
- **A leftover `89-integrity-guard` reference survives the rename.** —
  Likelihood low / impact low / mitigation: `T4` sweeps every enumerated site
  (see "Renaming the area off the collided `89-` stem") and its `Verify:` asserts
  `grep -rF '89-integrity-guard' tests/` prints nothing, so a stale reference
  cannot survive green.
- **Fixture/analyzer not Bash 3.2 compatible.** — Likelihood low / impact high /
  mitigation: no associative arrays, no `mapfile`, no empty-array expansion under
  `set -u`; mirror the shipped `85`/`87` helpers.
- **The old reference leaks into a fixture file**, making the renumber assertion
  pass trivially wrong. — Likelihood low / impact medium / mitigation: a recursive
  literal scan over the whole fixture root; the constant lives only in the check.
- **Whole-suite runs fail because the fixture is not staged.** — Likelihood
  high if forgotten / impact medium / mitigation: stage the root in
  `tests/mutation.sh` (T8) and assert its presence (T7).
- **The renumber assertion proves nothing if the fixture is empty.** — Likelihood
  low / impact medium / mitigation: assert new-reference presence in each
  enumerated rewrite position alongside old-reference absence.

## Test strategy

| Criterion | Verification level | Where |
| --------- | ------------------ | ----- |
| AC1 | integration — fixture-existence fails on a missing fixture; read-only contract | `AC30 fixture-existence` / `AC30 read-only-contract` in the area; full-suite run |
| AC2 | integration — recursive analyzer over the depth-3 fixture | `AC30 per-node-eval` expected block |
| AC3 | integration — graph-fault fixture | `AC30 structural-graph` expected block |
| AC4 | integration — dual-spelling and phase-mismatch fixtures; the `80` AC13 whole-set assertion is narrowed so the dual-spelling fixture is permitted | `AC30 spelling-drift` expected block; `FRAMEWORK_TEST_AREAS=80-cycle-fixture bash tests/run.sh` green |
| AC5 | integration — report-only contract pins + clean node | `AC30 report-only` |
| AC6 | unit — header references + forbidden-literal scan | `AC30 no-duplication` |
| AC7 | integration — completed-renumber fixture | `AC30 renumber-sweep` |
| AC8 | manual-in-scratch + registered mutation (0005) | reintroduce an old ref in a scratch copy; area fails naming `renumber-sweep` |
| AC9 | unit — authority/mirror intermediate-manifest pins | `AC30 renumber-sweep` |
| AC10 | unit — token/sub-area labels + staged-copy assertion | all `AC30` labels; `AC30 mutation-staging` |
| AC11 | integration — full suite + no-duplication | `bash tests/run.sh` green; `AC30 no-duplication`; `FRAMEWORK_TEST_AREAS=80-cycle-fixture` still green after the relaxation |
| AC12 | manual — scope inspection of the diff | `git diff --name-only` limited to `tests/**` + this item |
