---
feature: 0012-roadmap-deprecation/0003-parent-migration
phase: spec
status: final
created: 2026-10-13
updated: 2026-10-13
notes: "Nested roadmap child of 0012-roadmap-deprecation; the parent roadmap supplies the requirements (work/0012-roadmap-deprecation/roadmap.md:74,114-117). The parent node carries the legacy `roadmap.md` alias and resolves as this node's manifest. Dependency `0001-deprecation-contract` is shipped (its `ship.md` present with no `reopened:` marker), so the child is ready and no override is needed. No `backtracks.md` exists, so this is ordinary forward progression, not re-entry. User resolved the three policy forks this child owns: (1) the seven existing live parents are grandfathered read-only and never migrated; (2) the committed test fixtures are migrated to `manifest.md` / `phase: manifest`, with alias coverage retained by a dedicated legacy fixture; (3) only descriptive guard/README prose is modernized, keeping stable AC tokens. Deliverable is the fixtures, the cycle/conflict/backtrack guard scripts, tests/README.md, and the mutation tooling; the docs contract is 0001 and the command/agent retirement is 0002."
parent: 0012-roadmap-deprecation
---

# Existing-parent migration: grandfather the seven live decomposing nodes and migrate the test fixtures

## Problem

The recursive model's child-enumeration artifact has one modern spelling —
`manifest.md` with `phase: manifest` — with `roadmap.md` / `phase: roadmap`
recognized as a deprecated alias (shipped by `0001-deprecation-contract`;
`docs/workflow.md:53-57,1225-1237,1297-1304`,
`docs/artifact-conventions.md:138-141`). But the repository's committed state is
split: seven live decomposing parents (`0003`–`0007`, `0010`, `0011`) still carry
the legacy spelling, and the committed test fixtures that exercise the
decomposing-node rules still carry the legacy spelling too. `0001` deliberately
left both surfaces to this child (`work/0012-roadmap-deprecation/roadmap.md:74,88-117`;
`0001-deprecation-contract/spec.md:64-67`).

Two costs follow. **Framework maintainers** reading the suite see the retired
"roadmap" concept presented as current, and there is no recorded decision about
what happens to the seven existing parents, so every future reader must re-derive
it. The committed fixtures exercise only the legacy spelling, so the modern
`manifest.md` shape is not covered by any guard. The migration must apply the
`0001` contract — preserve committed history, never reuse a spent number, never
rewrite shipped work — while making the suite coherent with the modern concept.

## Goals

- Record the decision that the seven existing live decomposing parents
  (`0003`–`0007`, `0010`, `0011`) are **grandfathered read-only**: their
  committed `roadmap.md` artifacts, `phase: roadmap` values, `Children` tables,
  spent numbers, withdrawal records, and shipped children are preserved
  unchanged, and the recognized deprecated alias keeps them valid with no forced
  migration.
- Migrate the committed decomposing-node **test fixtures** to the modern spelling
  (`manifest.md` with `phase: manifest`) so the suite exercises the modern shape.
- Retain explicit **coverage of the deprecated alias**: at least one committed
  fixture continues to exercise `roadmap.md` / `phase: roadmap` and is recognized
  as an equivalent manifest, so alias recognition is not lost by the migration.
- Reconcile the **guards, mutation tooling, and `tests/README.md` prose** that
  name the fixture manifest files or the retired "roadmap" concept, so the suite
  is coherent and stays green.
- Keep `bash tests/run.sh` green, read-only, fresh-clone clean, and free of any
  live `work/**` dependency.

## Non-goals

- **Migrating or rewriting any of the seven existing live parents.** Their
  `work/<ref>/roadmap.md`, `Children` tables, artifacts, spent numbers, and
  withdrawal records are grandfathered read-only.
- Migrating the current parent `0012-roadmap-deprecation` itself (it stays a
  legacy `roadmap.md` node) or any other standalone item.
- Retiring the **`/roadmap` command and the `roadmap` agent**, and reconciling
  the root inventories (`README.md`, `AGENTS.md`, `template/AGENTS.md`,
  `tests/checks/40-inventory.sh`, `tests/checks/96-signature-sweep.sh`, the
  `workflow-lifecycle` skill) — owned by `0002-command-retirement`.
- Changing the **docs contract** (`docs/workflow.md`,
  `docs/artifact-conventions.md`), the alias semantics, the derived-state model,
  the six-column `Children` table, the `conflicts-with` grammar, readiness, or any
  finding/severity vocabulary — fixed by `0001`.
- Renaming stable AC tokens or their agreement-area labels (for example the
  `AC24 roadmap-revision` token).
- Adding a new agreement area, guard, committed checker, or dependency, or
  changing what the existing guards prove beyond spelling/path/terminology
  reconciliation.

## Users and stories

- **As a** framework maintainer, **I want** the seven existing decomposing
  parents left exactly as committed, **so that** retiring the roadmap concept
  never rewrites shipped history, reuses a spent number, or disturbs a shipped
  child's signal.
- **As a** framework maintainer, **I want** the committed fixtures to exercise
  the modern `manifest.md` shape while at least one fixture still exercises the
  deprecated alias, **so that** both the modern and legacy shapes stay covered.
- **As a** framework maintainer, **I want** the guards, mutation tooling, and
  test README to name the current manifest terminology, **so that** the suite does
  not present a retired concept as current.

## Acceptance criteria

1. **AC1 — Grandfather read-only.** Given the seven existing live decomposing
   parents (`0003`–`0007`, `0010`, `0011`), when the change set is inspected,
   then none of their committed files is modified: each keeps its `roadmap.md`,
   its `phase: roadmap` value, its `Children` table, its spent local numbers,
   `0010`'s recorded withdrawals, and every child's phase artifacts and `ship.md`
   exactly as committed.

2. **AC2 — Decision recorded.** Given the seven grandfathered parents, when this
   item's committed artifacts are read, then the decision to grandfather them
   read-only under the recognized deprecated alias — and that no forced migration
   occurs — is recorded in committed state.

3. **AC3 — Fixtures use the modern spelling.** Given the committed
   decomposing-node fixtures under `tests/fixtures/` that currently carry
   `roadmap.md`, when their manifest files are read after the change, then each
   migrated fixture uses `manifest.md` with `phase: manifest` and the manifest
   heading, and no migrated fixture remains named `roadmap.md`.

4. **AC4 — Deprecated-alias coverage retained.** Given the fixture set after the
   migration, when the guard for the legacy alias runs, then at least one
   committed fixture still carries `roadmap.md` with `phase: roadmap` and is
   recognized as an equivalent decomposing-node manifest, so alias recognition is
   observably covered rather than silently dropped.

5. **AC5 — Guards reconciled to the fixtures.** Given the guard areas that name
   fixture manifest files or detect decomposing-node fixtures (the cycle,
   declared-conflict, and backtrack areas), when the suite runs, then each reads
   the migrated `manifest.md` paths (and the retained legacy `roadmap.md` fixture,
   where present), no guard references a migrated fixture's old path, and the
   existing agreements (cycle detection, six-column layout, declared conflicts,
   revision integrity, readiness revocation) still hold.

6. **AC6 — Mutation tooling reconciled.** Given the opt-in mutation self-check,
   when its fixture mutations run, then each targeted mutation resolves to a
   migrated manifest path (or the retained legacy fixture), the pass still catches
   and names its area, and each mutated file is restored byte-for-byte.

7. **AC7 — Test prose terminology reconciled.** Given `tests/README.md` and the
   guard scripts' descriptive prose, when the retired "roadmap" concept term is
   read, then it appears only for the retained legacy alias/fixture, in a stable
   AC token or agreement-area label, or in a historical/backward-compatibility
   note; the generic manifest/decomposing-node terms are used everywhere else,
   and stable AC tokens and agreement-area labels are unchanged.

8. **AC8 — Read-only and no live-work dependency.** Given the fixture tree and
   guards after the change, when inspected, then the fixtures reference no live
   `work/` path, the fixture tree contains no nested `work/` directory, and the
   suite continues to read no live `work/**`.

9. **AC9 — Suite stays green.** Given the repository after the change, when the
   configured test command (`bash tests/run.sh`) runs, then it passes with no
   regression to the existing agreement areas.

10. **AC10 — Scope.** Given the change set, when inspected, then it modifies only
    the fixture files, the guard scripts, `tests/README.md`, the mutation tooling,
    and this item's own artifacts; it modifies none of the seven grandfathered
    parents, and it leaves `docs/workflow.md`, `docs/artifact-conventions.md`, the
    `/roadmap` command, and the `roadmap` agent untouched. No spent number is
    reused and no new sequence number is allocated.

11. **AC11 — Extend, do not fork.** Given the change set, when inspected, then it
    introduces no new agreement area, guard, finding code, state model, reference
    grammar, or conflict class, and the six-column `Children` table and the
    `conflicts-with` grammar are unchanged.

## Edge cases

- **Legacy-alias fixture keeps a distinct spelling.** A fixture whose file is
  still `roadmap.md` sits alongside migrated `manifest.md` fixtures; the guard must
  treat the legacy one as an equivalent manifest. If a guard detects only
  `manifest.md`, alias coverage silently disappears — exactly what AC4 prevents.
- **Absent-column legacy.** The fixture carrying the legacy five-column
  `Children` header (no `conflicts-with` column) must keep proving that an absent
  column means "no declarations" (`—` for every row), now inside a
  `manifest.md`-spelled file.
- **Fixture-local references.** Fixture `feature` values and `Children`
  `Canonical reference` cells use a fixture-local prefix (for example the cyclic
  fixture's `fixture-cyclic-roadmap/...`), not live `work/` paths; they remain
  valid and must not be rewritten into `work/` references (AC8).
- **Heading spelling.** A migrated fixture's heading is the manifest heading, not
  the old `# Roadmap — …` heading (AC3).
- **Mutation restore.** Removing or renaming a fixture file must keep the
  mutation pass's byte-for-byte restore valid (AC6).
- **Unaffected child state.** `.gitkeep`-only children and any shipped/recalled
  child markers inside fixtures are unaffected by the parent's spelling change.
- **No-op fixture.** A fixture with no content beyond its `Children` table still
  migrates.
- **Empty / absent.** A fixture tree with no remaining legacy fixture would fail
  AC4; a migration that leaves no `manifest.md` fixture would fail AC3.
- **Concurrency.** Not applicable: this item changes committed fixtures and prose
  only and introduces no runtime state or shared resource.

## Open questions

- [x] **Treatment of the seven existing live parents** — resolved (user):
  grandfather read-only; no migration and no rewrite.
- [x] **Treatment of the committed test fixtures** — resolved (user): migrate to
  `manifest.md` / `phase: manifest`, with a retained legacy-alias fixture.
- [x] **Terminology sweep depth** — resolved (user): reconcile descriptive prose
  only; keep stable AC tokens and agreement-area labels.
- [ ] **Deferred — future migration of the grandfathered parents and of the
  current legacy `0012` node.** Whether any `roadmap.md` node ever migrates is a
  later, separately-scoped decision; the deprecated alias is permanent under
  `0001`, so nothing here forces it. Owner: framework maintainers. — needed by: a
  future roadmap, not by this item.

## Dependencies and constraints

- **Ready.** The parent roadmap lists this child as `Depends on:
  0001-deprecation-contract` (`work/0012-roadmap-deprecation/roadmap.md:74`).
  `0001` is shipped — its `ship.md` is present with no `reopened:` marker — so the
  dependency is satisfied and no override is needed.
- **Consumes the shipped alias contract.** `roadmap.md` / `phase: roadmap` is a
  recognized deprecated alias with no forced migration
  (`docs/workflow.md:53-57,1225-1237,1297-1304`;
  `docs/artifact-conventions.md:138-141`). This item applies that contract to the
  existing parents and the fixtures; it defines no second contract.
- **The parent node is itself a legacy node.** `0012-roadmap-deprecation` carries
  `roadmap.md` and resolves as this node's manifest; it is excluded from the
  migration set because it is the in-flight node.
- **State of the seven parents.** All seven are pure containers (no parent-level
  `spec.md`/`design.md`/`tasks.md`/`ship.md`) and all use `roadmap.md` /
  `phase: roadmap`; none carries a `manifest.md`.
- **Fixture and guard couplings to reconcile.** The cycle fixture
  (`tests/checks/80-cycle-fixture.sh:25,30`), the declared-conflict guards
  (`tests/checks/85-conflict-guards.sh:280-281,293,363-365,382-385,394`), the
  backtrack guards (`tests/checks/87-backtrack-guards.sh:81,202-203,602,756,776`),
  the mutation cases (`tests/mutation.sh:119,388-389,461-475,561-564`), and
  `tests/README.md:114`.
- **Sibling boundaries.** `0002-command-retirement` owns the `/roadmap` command
  and `roadmap` agent removal and the root-inventory reconciliation (root
  `README.md`, `AGENTS.md`, `template/AGENTS.md`, `tests/checks/40-inventory.sh`,
  `tests/checks/96-signature-sweep.sh`, the `workflow-lifecycle` skill); `0001`
  owns the docs contract. This item owns the fixtures, the three guard scripts,
  `tests/README.md`, and the mutation tooling.
- **Suite contract.** The suite is read-only, fixture-based, and never reads live
  `work/**` (`tests/README.md:30-31`); the migration preserves that. The mutation
  self-check is opt-in and not run in CI (`tests/README.md:295-302`).
- **Shipped work is context.** The seven parents' shipped children, `ship.md`
  signals, spent numbers, and `0010`'s recorded withdrawals are preserved; no
  shipped artifact is rewritten.
- **Framework-internal change only.** Fixtures, guard scripts, and test prose; no
  runtime dependency, service, or new toolchain.
- **Assumption — one coherent feature.** The grandfather decision and the fixture
  migration are one reviewable change; if the work proves too large at `/plan`,
  the roadmap's sanctioned remedy is `/roadmap revise 0012-roadmap-deprecation` to
  add siblings at the same level, not to nest.
