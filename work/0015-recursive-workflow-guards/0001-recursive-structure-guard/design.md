---
feature: 0015-recursive-workflow-guards/0001-recursive-structure-guard
phase: design
status: final
created: 2026-10-14
updated: 2026-10-14
conflicts-with: "tests/README.md, tests/mutation.sh"
parent: 0015-recursive-workflow-guards
---

# Design — Recursive model, reference, and allocation guard

## Summary

Add one committed, fixture-based agreement area,
`tests/checks/81-recursive-structure-guard.sh` (stable suite token `AC27`), backed
by a new committed fixture root `tests/fixtures/recursive-structure/` whose tree
reaches four item levels. The guard walks the fixture, derives the
`DUPLICATE-PREFIX`/`DUPLICATE-CHILD` findings for its allocation samples, compares
that derived set to an expected block, and pins the shipped recursive-model,
reference, and per-level-allocation prose in `docs/workflow.md` and
`docs/artifact-conventions.md`. It adds no production checker, edits no production
surface, and stages its fixture root into `tests/mutation.sh`'s clean copy.

## Approach

The guard follows the conventions of the existing committed fixture guards
(`tests/checks/80-cycle-fixture.sh`, `tests/checks/85-conflict-guards.sh`): one
`tests/checks/*.sh` file sourced by `tests/run.sh` (so it must not call `exit`),
reading only its own fixture root and the live authority docs, printing
`ok`/`FAIL` lines labelled `<token> <sub-area>`, never reading live `work/**`, and
bash-3.2 compatible (no associative arrays, no `mapfile`; pure `awk`/string
helpers). It reuses the harness from `tests/lib.sh` (`ok`/`bad`/`need`/`needE`/
`flat`) and defines no second harness.

The guard has three parts.

1. **Fixture shape.** A committed tree under
   `tests/fixtures/recursive-structure/items/` (the fixture-local "work root",
   mirroring the `items/` convention of `tests/fixtures/declared-conflicts/`) that
   satisfies AC1–AC4, AC6, AC7, AC8, and AC10. The guard asserts the fixture root
   exists (failing, never skipping, when absent), computes the tree's maximum item
   depth and fails when it is below four, finds a hybrid node, checks the
   per-level reservation marker, and checks per-immediate-parent allocation
   scoping.

2. **Derived duplicate findings.** The guard walks the fixture tree and derives
   allocation findings with a small, self-contained algorithm mirroring the
   authority's recursive duplicate rule (`docs/workflow.md` → "Multiple work
   items"), then compares the derived set to a committed expected block — the same
   "derive-over-fixture, compare-to-expected-block" shape `85-conflict-guards.sh`
   uses for its resolution and pair-predicate blocks. AC6/AC7 require the
   derivation; AC8 requires the negative position/identity assertions.

3. **Pinned authority prose.** Literal-presence assertions (`need`) against
   `docs/workflow.md` and `docs/artifact-conventions.md` for the model-uniformity,
   no-maximum-depth, task-entries-are-not-nodes, per-level-reservation,
   immediate-parent-allocation-scoping, and "prompt behavior only — no committed
   executable checker" statements (AC9–AC12).

The guard is fixture-scoped test behavior, invoked by no framework command; it is
not a production checker (AC12).

### Fixture tree

Root `tests/fixtures/recursive-structure/`; the fixture work root is its `items/`
subdirectory. Every directory name matches `[0-9]{4}-[a-z0-9-]+`; every child of a
manifest-holding node carries a `.gitkeep`. Ids stay in the high, non-colliding
test range and allocate no real `work/` number.

| Path (under `items/`) | Holds | Serves |
| --------------------- | ----- | ------ |
| `9001-tree/` | `manifest.md`, `spec.md`, `tasks.md` | top-level **hybrid** decomposing node (AC2); fine-grained task list (AC10) |
| `9001-tree/0001-branch/` | `.gitkeep`, `manifest.md` | child that itself decomposes (AC1, AC4) |
| `9001-tree/0001-branch/0001-leaf/` | `.gitkeep`, `manifest.md` | grandchild that decomposes (depth 3; AC4) |
| `9001-tree/0001-branch/0001-leaf/0001-deep/` | `.gitkeep` only | depth-4 marker-only leaf (AC1, AC3, AC5) |
| `9001-tree/0001-branch/0001-leaf/0009-dup-x/` | `.gitkeep` only | depth-4 same-parent duplicate sample (AC7) |
| `9001-tree/0001-branch/0001-leaf/0009-dup-y/` | `.gitkeep` only | depth-4 same-parent duplicate sample (AC7) |
| `9001-tree/0002-leaf/` | `.gitkeep` only | second child of `9001-tree`; marker-only leaf (AC3) |
| `9002-tree/` | `manifest.md` | second top-level decomposing node (AC4) |
| `9002-tree/0001-branch/` | `.gitkeep`, `manifest.md` | its own local numbering starts at `0001` (AC4) |
| `9002-tree/0001-branch/0001-leaf/` | `.gitkeep` only | grandchild; local-id text `0001-leaf` matches `9001-tree`'s under a different parent (AC8) |
| `9010-dup-a/` | `spec.md` | top-level duplicate sample (AC6) |
| `9010-dup-b/` | `spec.md` | top-level duplicate sample, shared `NNNN` prefix `9010` (AC6) |

Each manifest uses the canonical six-column `Children` header
(`| Local id | Title | Scope | Depends on | conflicts-with | Canonical reference |`),
declares `phase: manifest`, has acyclic sibling-only dependencies (`—` throughout;
its own deliverable), and lists its children with resolving canonical references.
The fixture text contains no `work/` token and no `..` or absolute path
(AC13). `9001-tree/tasks.md` lists entries `T1`/`T2` and no directory named for a
task entry exists (AC10).

The two depth-4 `0009-dup-*` children sit under the shared parent
`9001-tree/0001-branch/0001-leaf`; the two top-level nodes `9010-dup-a`/`9010-dup-b`
share the `NNNN` prefix `9010`.

### Duplicate derivation

Two pure helpers produce the finding set, keyed on the **full canonical path** so
equal local-id text under different parents is never a collision (AC8):

- `rs_is_item_dir <name>` → true when the name matches `^[0-9]{4}-`.
- `rs_children <node-dir>` → the immediate child directories matching
  `rs_is_item_dir` (empty for a node with no manifest).

Emitting, after `LC_ALL=C sort`:

- **`DUPLICATE-PREFIX`** — for every pair of top-level items whose four-digit
  prefix is equal, one line `DUPLICATE-PREFIX|<ref-a>|<ref-b>` (AC6).
- **`DUPLICATE-CHILD`** — for every pair of same-parent children whose local
  four-digit prefix is equal, one line
  `DUPLICATE-CHILD|<ref-a>|<ref-b>|<shared-parent>|<shared-local-prefix>`, where
  `<shared-parent>` is the pair's immediate parent reference and
  `<shared-local-prefix>` the colliding four-digit local prefix; both are appended
  only when the children's references are at depth ≥ 3 segments (AC7).

The expected block (sorted) is exactly:

```
DUPLICATE-CHILD|9001-tree/0001-branch/0001-leaf/0009-dup-x|9001-tree/0001-branch/0001-leaf/0009-dup-y|9001-tree/0001-branch/0001-leaf|0009
DUPLICATE-PREFIX|9010-dup-a|9010-dup-b
```

AC8 is asserted both structurally (the two finding kinds are produced by separate
code paths, so neither can be emitted at the other's position) and negatively:
the derived `DUPLICATE-CHILD` set names no pair built from `9001-tree/0001-branch`
vs `9002-tree/0001-branch`, or `9001-tree/.../0001-leaf` vs `9002-tree/.../0001-leaf`
(equal text, different parents); the derived `DUPLICATE-PREFIX` set names no pair
other than `9010-dup-a`/`9010-dup-b`.

### Pinned authority prose

Literal-presence assertions (`need`, or `flat`-flattened `grep -qF` for phrases
that wrap across lines) against the shipped authority, so a dropped or weakened
statement is caught and named:

| AC | Surface | Statement pinned (substring) |
| -- | ------- | ---------------------------- |
| AC9 | `docs/workflow.md` | `applies uniformly at every node`; `no maximum recursion depth`; `nesting continues to arbitrary depth` |
| AC10 | `docs/workflow.md` | `are **not** nodes` (fine-grained `tasks.md` entries); plus the fixture-level "no task entry creates a directory" assertion |
| AC11 | `docs/artifact-conventions.md` | `each child directory is reserved with a `.gitkeep` at that level`; `greatest 4-digit prefix ever committed under that parent and add one`; `scoped to its **immediate** parent`; `never reused within that parent` |
| AC12 | `docs/workflow.md` | `prompt behavior only` in both the `### Merge-integrity guard` and the declared-conflict-check sections, and the phrase `no committed checker, script, helper, or executable tool` for both — flattened with `flat` for the declared-conflict section, whose sentence wraps across lines |

## Alternatives considered

- **A. New fixture root + new check file (chosen).** Extends the proven
  fixture-based guard pattern, keeps the structure/reference/allocation contract a
  single, disjoint agreement area, and lets the spec's AC1–AC8 (a real depth-4
  tree and a derived duplicate block) be met with committed, reviewable fixture
  state. Cost: one new check file and one new fixture root.
- **B. Extend `tests/checks/80-cycle-fixture.sh` and its fixture.** Rejected:
  `80` is the `AC13` cycle-rule area whose fixture is deliberately the retained
  legacy `roadmap.md` alias sample; folding the structure contract into it would
  couple the cycle mutation job to unrelated rules, blur the one-area-per-concern
  boundary, and re-assert literals owned elsewhere — an explicit spec non-goal.
- **C. Pin only prose, no fixture tree and no derivation.** Rejected: AC1–AC8
  require a committed tree reaching depth ≥ 3 (four levels) and a **derived**
  duplicate finding set compared to an expected block; prose assertions cannot
  satisfy the derivation criteria, and a regression that mis-scoped a grandchild's
  `MMMM` would still pass.
- **D. Generate the fixture tree at guard-run time.** Rejected: the fixture is
  committed plan/test state a reviewer inspects; a runtime-generated tree would
  not pin the actual layout and would not survive a fresh clone as reviewable
  state.

## Interfaces and data model

**Check file** `tests/checks/81-recursive-structure-guard.sh`:

- Header comment naming `AC27` and the sub-areas, matching the existing guards.
- `echo "== AC27 recursive structure, reference, and allocation guard =="`.
- Path constants: `RS_ROOT="tests/fixtures/recursive-structure"`,
  `RS_ITEMS="$RS_ROOT/items"`.
- Helpers (bash 3.2 safe): `rs_is_item_dir`, `rs_manifest` (manifest-then-legacy
  resolver, mirroring `80`/`85`), `rs_children`, `rs_max_depth`,
  `rs_dup_findings`, and a `rs_block_contains`/`rs_block_absent` pair for
  expected-block member assertions.
- Sub-area labels used in every `ok`/`bad`: `fixture-depth`, `hybrid-node`,
  `reservation-marker`, `allocation-scoping`, `reference-depth`,
  `duplicate-derivation`, `duplicate-position`, `contract-pins`,
  `read-only-contract`.

**Fixture root** `tests/fixtures/recursive-structure/` as tabulated above. No
production surface is created or edited; the only non-fixture, non-check file
touched is `tests/mutation.sh` (one appended line).

**Registration handoff.** This area claims suite token `AC27`. `0005` owns adding
the `tests/README.md` Checks-table row and paragraph and the mutation jobs; the
design records the token so the guard's labels and `0005`'s table agree.

## Affected areas

- **New:** `tests/checks/81-recursive-structure-guard.sh`.
- **New:** `tests/fixtures/recursive-structure/**` (manifests, `.gitkeep`s,
  `spec.md`, `tasks.md`).
- **Edited (append-only):** `tests/mutation.sh` — one line in `stage_copy()`
  (`cp -R "$REPO_ROOT/tests/fixtures/recursive-structure"
  "$copy/tests/fixtures/recursive-structure"`), so the mutation clean whole-suite
  runs see the fixture root (AC15).
- **Read, never edited:** `docs/workflow.md`, `docs/artifact-conventions.md`,
  `tests/lib.sh`, `tests/run.sh`.
- **Not touched:** `docs/**`, `.opencode/**`, `README.md`, `AGENTS.md`,
  `template/**` (AC16); `tests/README.md` and the mutation job list (owned by
  `0005`); and the other guards' check files and fixture roots.

Adding a check file is adding a file — `tests/run.sh` needs no edit — so the
change is purely additive with no migration: existing areas, their fixtures, the
`FRAMEWORK_TEST_AREAS` selector space (`81` is a unique, unambiguous prefix), and
the shipped `work/` artifacts are all unaffected.

## Risks and mitigations

- **Suite token collision with sibling guards** — likelihood medium / impact low /
  mitigation: this area claims `AC27` (the lowest number after the shipped `AC26`)
  and the design records it for `0005` to reconcile; a sibling claiming the same
  token would be caught by `0005`'s registration pass. Recorded in the item's
  open issue below.
- **Shared append surface `tests/mutation.sh`** — likelihood medium / impact low /
  mitigation: this guard appends exactly one line to `stage_copy()`, the
  declared-conflict check reports the intentional shared target, and the
  `merge-conflict` skill reconciles any textual overlap at `/ship`. The guard
  declares the conflict in `design.md` and the parent cell does too.
- **Wrapped prose literal missed by a single-line `grep`** — likelihood high /
  impact low / mitigation: pin the declared-conflict "no committed checker…"
  phrase with `flat <file> | grep -qF` (the sentence wraps across lines in
  `docs/workflow.md`), as `80-cycle-fixture.sh` does for its wrapped phrase; pin
  `prompt behavior only` per line.
- **Duplicate derivation over-counts** — likelihood low / impact medium /
  mitigation: identity is keyed on the full canonical path, the two equal-text
  cross-parent cases are asserted **absent** from the derived set (AC8), and the
  derived set is compared to a single committed expected block.
- **Fixture accidentally names a live `work/**` path** — likelihood low / impact
  medium / mitigation: the guard greps its own fixture root for `work/` and for
  `..`/absolute tokens and fails if found, mirroring `85-conflict-guards.sh`'s
  read-only-contract assertion (AC13).
- **Bash-version portability** — likelihood low / impact low / mitigation: match
  the existing guards' bash-3.2 constraints (no associative arrays/`mapfile`;
  `awk` and string helpers only).

## Test strategy

The guard is itself the test; the toolchain is `bash tests/run.sh` (`AGENTS.md`
Project profile `Test:`). Each acceptance criterion maps to a verification level:

| Criterion | Verification level |
| --------- | ------------------ |
| AC1 fixture depth | guard sub-area `fixture-depth` (root-present + `rs_max_depth ≥ 4`); mutation job (0005) removes/deepens the fixture |
| AC2 hybrid node | guard sub-area `hybrid-node` (fixture walk finds a manifest + own artifact) |
| AC3 reservation marker | guard sub-area `reservation-marker` |
| AC4 allocation scoping | guard sub-area `allocation-scoping` |
| AC5 reference depth + regex | guard sub-area `reference-depth` (depth-4 dir resolves; regex literal pinned) |
| AC6 top-level duplicate | guard sub-area `duplicate-derivation` (expected-block equality) |
| AC7 same-parent depth ≥ 3 duplicate | guard sub-area `duplicate-derivation` (expected-block member) |
| AC8 never mislabeled | guard sub-area `duplicate-position` (negative member assertions) |
| AC9 model uniform | guard sub-area `contract-pins` (`need` on `docs/workflow.md`) |
| AC10 task entries not nodes | guard sub-area `contract-pins` + fixture assertion |
| AC11 reservation/allocation prose | guard sub-area `contract-pins` (`need` on `docs/artifact-conventions.md`) |
| AC12 no committed checker | guard sub-area `contract-pins` (`need`/`flat` on `docs/workflow.md`) |
| AC13 read-only/self-contained | guard sub-area `read-only-contract` + idempotence: run the area twice, diff the output (T5 Verify) |
| AC14 suite green | `bash tests/run.sh` exit 0; `FRAMEWORK_TEST_AREAS=81-recursive-structure-guard` exit 0 |
| AC15 mutation clean runs | `bash tests/mutation.sh` clean whole-suite steps exit 0 |
| AC16 no production surface | `git diff --name-only -- ':!work/'` names only `tests/**` |

## Open issue carried forward

- **Suite token `AC27` is provisional.** This area claims `AC27`; siblings
  `0002`–`0004` add their own areas and `0005` registers the `AC27+` tokens in
  `tests/README.md`. If a sibling claims the same number, `0005` reconciles the
  assignment during registration; the guard's labels and the README table must
  agree. Recorded for `0005`.
