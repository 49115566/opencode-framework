---
feature: 0012-roadmap-deprecation/0003-parent-migration
phase: design
status: final
created: 2026-10-13
updated: 2026-10-13
conflicts-with: "—"
parent: 0012-roadmap-deprecation
---

# Design — Existing-parent migration: grandfather the seven live nodes and migrate the test fixtures

## Summary

Grandfather the seven live decomposing parents read-only (no file changes), and
migrate the five committed decomposing-node fixtures from the legacy
`roadmap.md` / `phase: roadmap` spelling to the modern `manifest.md` /
`phase: manifest` spelling, keeping exactly one fixture
(`tests/fixtures/cyclic-roadmap/roadmap.md`) as the retained deprecated-alias
fixture. Reconcile the three fixture-bearing guards (`80-cycle-fixture.sh`,
`85-conflict-guards.sh`, `87-backtrack-guards.sh`) to resolve a decomposing
node's manifest by either spelling, update `tests/mutation.sh`'s fixture paths,
and modernize the descriptive prose in `tests/README.md` and the guard headers,
leaving every stable `ACn` token, agreement-area label, directory name, `Children`
table, and spent number untouched.

## Approach

The change set is confined to fixtures, three guard scripts, the mutation tooling,
and test prose; it adds no guard, area, code, grammar, or dependency.

### 1. Grandfather the seven live parents (no edits)

`work/0003-framework-quality-hardening` … `0007-phase-backtracking`,
`work/0010-recursive-plan-cycle`, and `work/0011-recursive-bootstrap` keep their
committed `roadmap.md`, `phase: roadmap`, `Children` tables, spent local numbers,
`0010`'s withdrawal records, and every child's phase artifacts and `ship.md`. The
recognized deprecated alias (`docs/workflow.md:53-57,1225-1237,1297-1304`;
`docs/artifact-conventions.md:137-141`) already keeps them valid; this item writes
nothing under any of them. The decision is recorded in this item's committed
artifacts (the `spec.md` notes and this design), satisfying AC2 without a new
registry or state file.

### 2. Migrate five fixtures, retain one legacy alias

Six committed decomposing-node fixtures carry `roadmap.md` / `phase: roadmap`.
Five migrate; the sixth is retained as the single deprecated-alias fixture:

| Fixture | Action |
| ------- | ------ |
| `tests/fixtures/declared-conflicts/items/9001-roadmap-a/roadmap.md` | migrate → `manifest.md` |
| `tests/fixtures/declared-conflicts/items/9002-roadmap-b/roadmap.md` | migrate → `manifest.md` |
| `tests/fixtures/declared-conflicts/items/9003-roadmap-old/roadmap.md` | migrate → `manifest.md` (keeps the five-column header) |
| `tests/fixtures/backtracking/items/9120-revised-roadmap/roadmap.md` | migrate → `manifest.md` |
| `tests/fixtures/backtracking/items/9121-readiness/roadmap.md` | migrate → `manifest.md` |
| `tests/fixtures/cyclic-roadmap/roadmap.md` | **retain** `roadmap.md` / `phase: roadmap` (legacy alias) |

For each migrated fixture: rename the file with `git mv`, set frontmatter
`phase: manifest`, change the H1 to `# Manifest — <title>`, and reword
artifact-naming nouns in the `## Initiative` body from "roadmap" to "manifest".
Everything fixture-local is preserved byte-for-byte: the frontmatter `feature:`
value, the fixture directory names (`9001-roadmap-a`, `9120-revised-roadmap`, …),
the `Children` table (including `9003-roadmap-old`'s legacy five-column header),
the `Canonical reference` cells, `## Sequencing`, and any withdrawal/revision
records. The retained cyclic fixture keeps `phase: roadmap`, its `# Roadmap —`
heading, and its `Children` table; it gains one backward-compatibility sentence
in `## Initiative` naming it the retained legacy-alias fixture.

The cyclic fixture is the retained alias because it is a self-contained
decomposing fixture whose whole purpose is the manifest-parsing/`CYCLIC-DEP`
diagnostic, and because its guard (`80-cycle-fixture.sh`) already reads it by
name and already asserts `phase: roadmap` — so it is also the mutation-self-check
target that keeps alias coverage mutation-sensitive (`job_8`, no new job needed).

### 3. Reconcile the three guards to both spellings

Every guard that discovers decomposing-node fixtures gains a tiny local resolver —
the manifest is `<dir>/manifest.md` when present, else `<dir>/roadmap.md` — and
uses it instead of a hardcoded `roadmap.md`:

- `85-conflict-guards.sh` — the resolver drives the parent detection in
  `guard_build_events` (the `$pd/roadmap.md` test and `guard_children_rows` call)
  and the standalone-item skip (`$sd/roadmap.md`). The fixture-existence,
  `column-layout`, and `positional-parse` assertions repoint to the migrated
  `manifest.md` paths. New `need` assertions pin `phase: manifest` and the
  `# Manifest —` heading on `9001-roadmap-a/manifest.md` and
  `9003-roadmap-old/manifest.md` (AC3). The expected resolution/conflict/drift
  blocks are unchanged, since they key on directory-based entity refs, not the
  file name.
- `87-backtrack-guards.sh` — the resolver drives the decomposing-node skip in
  `bt_record_refs`, `bt_challenge_refs`, and `fixture_derived`, and the paths in
  the fixture-existence list, `fixture_revision`, `BT_RM`, `fixture_readiness`,
  `fixture_readiness_blocked`, and the no-stored-readiness header check. New
  `need` assertions pin `phase: manifest` and `# Manifest —` on
  `9120-revised-roadmap/manifest.md` and `9121-readiness/manifest.md`.
- `80-cycle-fixture.sh` — resolves the cycle fixture through the same
  manifest-then-alias lookup, asserts the resolution lands on the retained
  `roadmap.md` alias, and asserts its `phase: roadmap` and `# Roadmap —` legacy
  heading (AC4). The existing `Children`/cycle parse and the `CYCLIC-DEP` rule
  assertions are unchanged. The missing-fixture failure keeps the literal
  `AC13 committed cycle fixture missing` so `tests/mutation.sh`'s `job_8`
  still catches and names the area.

### 4. Mutation tooling and prose

`tests/mutation.sh` repoints only the three jobs that name migrated fixtures:
`job_15` and `job_16` → `9001-roadmap-a/manifest.md` (mutation target and restore
path), `job_24` → `9120-revised-roadmap/manifest.md`. `job_8` stays on the
retained legacy `cyclic-roadmap/roadmap.md`, so the legacy alias remains
mutation-covered. Descriptive prose is modernized in `tests/README.md` (the
`80-cycle-fixture.sh` Checks-table cell), the guard banner/comments, and the
`87` helper names (`bt_roadmap_*` → `bt_manifest_*`, `missing-roadmap|` →
`missing-manifest|`). Every stable `ACn` token, agreement-area label (including
`AC24 roadmap-revision`), area file name, and copy-set sentence pinned by
`90-packaging.sh`/`95-split-guard.sh` is left verbatim.

## Alternatives considered

- **Retain a declared-conflicts fixture (e.g. `9002-roadmap-b`) as the legacy
  alias instead of the cyclic fixture.** Pros: the legacy file would sit inside
  the same `85` discovery loop as migrated `manifest.md` fixtures, proving
  within-one-analyzer equivalence. Cons: the legacy alias would fall outside the
  mutation path (no `mutation.sh` job targets `9002`), so alias coverage would be
  observation-only; `80` would still have to migrate, adding churn for no
  coverage gain; and `0001`'s design cites the cyclic fixture as the pinned
  legacy sample (`0001-deprecation-contract/design.md:91`). Rejected.
- **Migrate all six fixtures and rely on `docs/` alias prose for coverage.**
  Pros: one spelling everywhere, least guard branching. Cons: violates AC4 —
  alias recognition must stay observably covered by a committed fixture — and the
  case's stated edge case (alias coverage silently disappearing). Rejected.
- **Retain the cyclic alias but leave `85`/`87` hardcoded to `manifest.md`.**
  Pros: smallest guard diff. Cons: violates AC5's "(and the retained legacy
  `roadmap.md` fixture, where present)" and the edge case that a guard detecting
  only `manifest.md` silently drops alias coverage; also leaves the guards
  unable to skip a future legacy decomposing fixture. Rejected.
- **Chosen:** migrate five, retain the cyclic alias, and give all three guards a
  manifest-then-alias resolver — modern shape covered, alias coverage retained
  and mutation-sensitive, and no hardcoded single spelling.

## Interfaces and data model

No runtime interface or schema changes; the touched "interfaces" are files and
shell helpers inside the committed suite.

- **Migrated fixture file** — `manifest.md` with frontmatter `phase: manifest`
  and H1 `# Manifest — <title>`; the fixture-local `feature:`, directory name,
  `Children` table, and `Canonical reference` cells are unchanged.
- **Retained legacy fixture** — `tests/fixtures/cyclic-roadmap/roadmap.md` with
  `phase: roadmap` and `# Roadmap —`, plus one backward-compatibility note.
- **Guard resolver (local to each script, not shared)** —
  `resolve_manifest <dir>`: prints `<dir>/manifest.md` when it exists, else
  `<dir>/roadmap.md` when it exists, else empty. Used for parent detection,
  decomposing-node skip, and fixture path resolution.
- **`tests/mutation.sh` job paths** — `job_15`/`job_16` target
  `tests/fixtures/declared-conflicts/items/9001-roadmap-a/manifest.md`; `job_24`
  targets `tests/fixtures/backtracking/items/9120-revised-roadmap/manifest.md`;
  `job_8` targets the retained `tests/fixtures/cyclic-roadmap/roadmap.md`.
- **Backward compatibility** — the deprecated alias remains recognized by the
  suite; `90-packaging.sh`, `95-split-guard.sh`, `40-inventory.sh`, and
  `96-signature-sweep.sh` are untouched; the seven live parents and every shipped
  artifact are untouched; no sequence number is allocated or reused.

## Affected areas

- `tests/fixtures/declared-conflicts/items/9001-roadmap-a/roadmap.md` →
  `manifest.md`; `…/9002-roadmap-b/roadmap.md` → `manifest.md`;
  `…/9003-roadmap-old/roadmap.md` → `manifest.md`.
- `tests/fixtures/backtracking/items/9120-revised-roadmap/roadmap.md` →
  `manifest.md`; `…/9121-readiness/roadmap.md` → `manifest.md`.
- `tests/fixtures/cyclic-roadmap/roadmap.md` — retained; one legacy note added.
- `tests/checks/80-cycle-fixture.sh` — alias resolver + alias assertion + prose.
- `tests/checks/85-conflict-guards.sh` — resolver; existence/column/positional
  paths; `phase: manifest` assertions; prose.
- `tests/checks/87-backtrack-guards.sh` — resolver; skip checks; revision,
  readiness, header, and existence paths; `phase: manifest` assertions; helper
  names and prose.
- `tests/mutation.sh` — `job_15`, `job_16`, `job_24` paths.
- `tests/README.md` — the `80-cycle-fixture.sh` Checks-table cell.
- `work/0012-roadmap-deprecation/0003-parent-migration/` — `design.md`,
  `tasks.md`.

## Risks and mitigations

- **A guard's expected block shifts after a fixture rename.** The `85`/`87`
  expected blocks key on directory-based entity refs and artifact names, not the
  manifest file name; a rename that also changed a directory or a `Canonical
  reference` would surface as an area failure. — Likelihood low / impact high.
  Mitigation: rename only the file, never a directory or `Canonical reference`
  cell; run each affected area after its edit.
- **A resolver silently hides an unintentional second manifest.** If a fixture
  ever held both spellings, manifest-first resolution would mask the legacy file.
  — Likelihood low / impact medium. Mitigation: no fixture holds both; the
  resolver and the migration keep exactly one manifest per fixture directory.
- **Mutation restore not byte-for-byte.** A mutation whose restore path still
  names `roadmap.md` would fail the byte-for-byte restore. — Likelihood medium /
  impact medium. Mitigation: update the mutate target and the `job_finish`
  restore path together; verify with `bash tests/mutation.sh`.
- **A terminology edit touches a stable token or label.** `AC24 roadmap-revision`
  and the area names are pinned by `mutation.sh` expectations. — Likelihood
  medium / impact medium. Mitigation: change only descriptive prose and
  identifiers; keep every `ACn` token and agreement-area label verbatim; verify
  with `grep` and the full suite.
- **Scope creep into a sibling's surface.** The temptation is to edit
  `40-inventory.sh`, `96-signature-sweep.sh`, the root inventories, or
  `docs/*.md` (owned by `0002`/`0001`). — Likelihood medium / impact high.
  Mitigation: explicit boundary above; verify the change set with
  `git diff --name-only` (AC10).

## Test strategy

The suite is the verification vehicle; no production checker or new agreement
area is introduced. Each guard area is run scoped after its edit, then the full
suite and the opt-in mutation pass.

| Criterion | Verification |
| --------- | ------------ |
| AC1 | `git diff --name-only` shows no path under the seven grandfathered parents; `bash tests/run.sh` never reads live `work/**`. |
| AC2 | Read this item's committed `spec.md` notes and this `design.md`: the grandfather decision and the no-forced-migration rule are recorded. |
| AC3 | `grep -rl 'phase: roadmap' tests/fixtures` lists only `cyclic-roadmap/roadmap.md`; the five migrated files carry `phase: manifest` and `# Manifest —` (asserted in `85`/`87`). |
| AC4 | `80-cycle-fixture.sh` resolves and asserts the retained `roadmap.md` legacy alias as an equivalent manifest; `mutation.sh` `job_8` still catches its removal. |
| AC5 | `FRAMEWORK_TEST_AREAS=80-cycle-fixture,85-conflict-guards,87-backtrack-guards bash tests/run.sh` passes; `grep` shows no guard referencing a migrated fixture's old `roadmap.md` path. |
| AC6 | `bash tests/mutation.sh` reports `0 failed`, with each job's target resolving to a migrated `manifest.md` (or the retained legacy fixture) and every restore byte-for-byte. |
| AC7 | `grep -rn 'roadmap' tests/README.md tests/checks/80-cycle-fixture.sh tests/checks/85-conflict-guards.sh tests/checks/87-backtrack-guards.sh` shows the term only for the retained legacy fixture/alias, the stable labels (`AC24 roadmap-revision`), or a backward-compatibility note. |
| AC8 | `85`/`87`'s `read-only-contract` assertions pass (the `grep -rq 'work/'` over each fixture root is empty and the backtracking tree has no nested `work/`); the fixture-local `Canonical reference` values are unchanged. |
| AC9 | `bash tests/run.sh` prints `TOTAL:` with `0 failed`. |
| AC10 | `git diff --name-only` lists only the fixture files, the three guard scripts, `tests/README.md`, `tests/mutation.sh`, and this item's artifacts. |
| AC11 | Diff inspection: no new agreement area, guard, finding code, state model, reference grammar, or conflict class; the six-column `Children` header and `conflicts-with` grammar are unchanged. |

## Acceptance criteria coverage map

AC1→T7 · AC2→design,T7 · AC3→T1,T2,T3 · AC4→T1,T4 · AC5→T2,T3,T4 ·
AC6→T5 · AC7→T2,T3,T4,T6 · AC8→T7 · AC9→T7 · AC10→T7 · AC11→T7.
