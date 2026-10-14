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

Add one new fixture-based agreement area, `tests/checks/89-integrity-guard.sh`
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
list so the opt-in whole-suite runs stay green.

## Approach

### New agreement area

- **File.** `tests/checks/89-integrity-guard.sh`, sourced by the existing
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

## Alternatives considered

- **A prose-only agreement check (pin the recursive authority phrases, no fixture
  or analyzer).** Pros: small, mirrors `88-renumber-sweep.sh`. Cons: cannot satisfy
  AC2/AC3/AC4 — nothing would fail if a *future* evaluation flattened to two
  levels, missed a nested graph fault, or treated a dual-spelling node as clean.
  Rejected: the spec's decided open question requires an exercised fixture, and a
  prose-only check is the exact gap this item closes.
- **Extend `80-cycle-fixture.sh` / `88-renumber-sweep.sh` in place.** Pros: fewer
  files. Cons: breaches single-owner agreement areas and forces re-asserting
  sibling literals, failing AC6/AC11; conflates the cycle diagnostic and the
  renumber prose list with a new recursive-integrity concern. Rejected.
- **Renumber half re-pins the authority's prose lists (like `88`).** Pros: cheap.
  Cons: `88-renumber-sweep.sh` already owns the prose rewrite lists; re-pinning is
  duplication (AC9/AC11) and proves nothing about a *completed* renumber.
  Rejected in favor of the completed-renumber fixture plus a single unowned
  intermediate-manifest pin.

## Interfaces and data model

- **New file** `tests/checks/89-integrity-guard.sh` — sourced, not executed; no
  `exit`; read-only; prints `ok`/`FAIL` lines labelled `AC30 <sub-area>`. Public
  surface for `0005`: the area name `89-integrity-guard` and the sub-area labels.
- **New fixture root** `tests/fixtures/recursive-integrity/` — root-local
  `92xx` entity ids; item references resolve inside `items/`, never against live
  `work/`.
- **Changed file** `tests/mutation.sh` — one additive `cp -R` line in
  `stage_copy()`; no job, no `JOB_COUNT` change.
- **No production interface.** No `phase` value, state file, command, agent,
  skill, or committed production checker is added or changed. The authority docs
  and prompts are the pinned target, not the guarded artifact.

**Backward compatibility.** The change is purely additive: a new auto-sourced
check file, a new fixture root, and one staged-copy line. No existing area,
fixture, selector, or harness behavior changes, so `bash tests/run.sh` and the
existing area selections stay green with no migration.

## Affected areas

- `tests/checks/89-integrity-guard.sh` (new).
- `tests/fixtures/recursive-integrity/**` (new).
- `tests/mutation.sh` (`stage_copy()` — one line).
- Explicitly **not** touched here: `tests/README.md` and the mutation jobs
  (`0005-guard-registration-sweep`); `docs/**`, `AGENTS.md`, `template/**`,
  `README.md`, `.opencode/**` (pinned target).

## Risks and mitigations

- **A self-inflicted `DRIFT-FACT`.** The parent row's `conflicts-with` cell
  declares `tests/README.md, tests/mutation.sh`; if this item's `design.md`
  declaration differed, the read-only check would report drift. — Likelihood
  medium / impact low / mitigation: declare the identical set in this design's
  frontmatter (no self-reference, no duplicate).
- **Filename/prefix collision with a sibling guard authoring a check in
  parallel.** — Likelihood medium / impact low / mitigation: the name
  `89-integrity-guard.sh` is distinct; the two append-only registries are
  declared conflicts and the registration child reconciles; a duplicate `89`
  prefix is only an area-selector ambiguity, not a suite failure.
- **Fixture/analyzer not Bash 3.2 compatible.** — Likelihood low / impact high /
  mitigation: no associative arrays, no `mapfile`, no empty-array expansion under
  `set -u`; mirror the shipped `85`/`87` helpers.
- **The old reference leaks into a fixture file**, making the renumber assertion
  pass trivially wrong. — Likelihood low / impact medium / mitigation: a recursive
  literal scan over the whole fixture root; the constant lives only in the check.
- **Whole-suite runs fail because the fixture is not staged.** — Likelihood
  high if forgotten / impact medium / mitigation: stage the root in
  `tests/mutation.sh` (T7) and assert its presence (T6).
- **The renumber assertion proves nothing if the fixture is empty.** — Likelihood
  low / impact medium / mitigation: assert new-reference presence in each
  enumerated rewrite position alongside old-reference absence.

## Test strategy

| Criterion | Verification level | Where |
| --------- | ------------------ | ----- |
| AC1 | integration — fixture-existence fails on a missing fixture; read-only contract | `AC30 fixture-existence` / `AC30 read-only-contract` in the area; full-suite run |
| AC2 | integration — recursive analyzer over the depth-3 fixture | `AC30 per-node-eval` expected block |
| AC3 | integration — graph-fault fixture | `AC30 structural-graph` expected block |
| AC4 | integration — dual-spelling and phase-mismatch fixtures | `AC30 spelling-drift` expected block |
| AC5 | integration — report-only contract pins + clean node | `AC30 report-only` |
| AC6 | unit — header references + forbidden-literal scan | `AC30 no-duplication` |
| AC7 | integration — completed-renumber fixture | `AC30 renumber-sweep` |
| AC8 | manual-in-scratch + registered mutation (0005) | reintroduce an old ref in a scratch copy; area fails naming `renumber-sweep` |
| AC9 | unit — authority/mirror intermediate-manifest pins | `AC30 renumber-sweep` |
| AC10 | unit — token/sub-area labels + staged-copy assertion | all `AC30` labels; `AC30 mutation-staging` |
| AC11 | integration — full suite + no-duplication | `bash tests/run.sh` green; `AC30 no-duplication` |
| AC12 | manual — scope inspection of the diff | `git diff --name-only` limited to `tests/**` + this item |
