---
feature: 0015-recursive-workflow-guards/0003-recursive-conflicts-guard
phase: design
status: final
created: 2026-10-14
updated: 2026-10-14
parent: 0015-recursive-workflow-guards
conflicts-with: "—"
---

# Design — Recursive declared-conflicts guard

## Summary

Extend the shipped depth-2 declaration-model agreement area
(`tests/checks/85-conflict-guards.sh`, suite token `AC23`) **in place**: widen its
target resolver from a one-`/`-segment cap to the recursive reference grammar
`NNNN-slug(/MMMM-slug)*`, make its event builder recurse into a child that itself
holds a manifest, and add a new committed fixture root
`tests/fixtures/recursive-conflicts/` whose tree is three levels deep. The
existing `declared-conflicts` fixture and every current `AC23` assertion stay
untouched as the depth-2 control; the recursive behavior is pinned by new
`AC23 recursive-*` sub-area assertions whose expected blocks are enumerated here.
No production, authority, registration, or mutation surface is edited.

## Approach

The change is entirely inside `tests/checks/85-conflict-guards.sh` plus one new
committed fixture root. It has three parts.

**1. Resolver generalization.** `guard_resolve` currently matches a reference with
`^[0-9]{4}-[a-z0-9-]+(/[0-9]{4}-[a-z0-9-]+)?$` — at most one nested segment. Widen
the trailing group to `*` so a canonical reference of arbitrary depth is
classified as an item reference and resolved against `$GUARD_ITEMS/$1`; every
other token keeps the reference-vs-path discriminator (`/` -bearing references are
root-relative; a bare `MMMM-slug` resolves sibling-row-first, then root). This is a
behavior-preserving widening for every existing fixture token, so the shipped
`AC23 cell-resolution` block is unchanged (AC10).

**2. Recursive event build.** `guard_build_events` currently walks only
top-level-node → immediate child. Replace the two hardcoded loops with a
recursive walk:

```
guard_walk_node(node_ref, node_dir, node_rows):
  for each child dir <local-id>/ under node_dir:
    guard_emit_entity("node_ref/local-id", child_dir, node_ref, local-id, node_rows)
    if child_dir holds a manifest (manifest.md or legacy roadmap.md):
      guard_walk_node("node_ref/local-id", child_dir, rows_of(that manifest))
```

Top level: a directory holding a manifest starts a `guard_walk_node` (it is a
container, never emitted as an entity itself); a directory with `spec.md` and no
manifest is emitted as a standalone entity. This makes a decomposing **child** both
an entity (from its parent's row) and the source of further entities (its own
rows), keyed by full canonical reference at arbitrary depth (AC3). The builder is
parameterized by its items root so the same code builds both fixtures' streams.
A new generic analyzer `fixture_entities` emits the `E` events (`ref|shipped`)
so the compared set can be asserted directly.

**3. Fixture + assertions.** Author `tests/fixtures/recursive-conflicts/items/`
with a depth-≥3 tree and a decomposing child, then add `AC23 recursive-*`
assertions that run the existing generic analyzers over the recursive event
stream. The fixture and the exact expected blocks are specified below so no
design decision is left to the builder.

### Why in place

The spec fixes the shape: extend the existing agreement area and its analyzer so
there is one declaration-model area and no duplicated resolver
(`spec.md:40-46`). The `declared-conflicts` fixture is retained verbatim as the
depth-2 control, so the recursive assertions cannot be satisfied by weakening the
existing ones.

## Alternatives considered

- **A recursive sibling area (`86-recursive-conflicts.sh`) with its own copy of
  the resolver/analyzers.** Pros: no risk of disturbing the shipped `AC23` blocks;
  clean per-area mutation isolation. Cons: duplicates the resolver, the
  reference-vs-path discriminator, the sibling-first precedence, and all four
  analyzers, so the two copies can drift; the spec explicitly rejects this
  ("one declaration-model area and no duplicated resolver", `spec.md:40-43`).
  Rejected.
- **Merge the depth-≥3 cases into the existing `declared-conflicts` root.**
  Pros: no second root. Cons: AC10 requires the existing fixture's blocks to stay
  unchanged, and merging new entities into that root changes its event stream and
  its expected blocks; the spec also fixes the new root as additive
  (`spec.md:44-46`). Rejected.
- **Widen only `guard_resolve` and assert a hand-written resolution table without
  a fixture tree.** Pros: smallest change. Cons: cannot pin recursion into a
  decomposing child (AC3), the union/drift at depth (AC4/AC5), or the pair
  predicate across levels (AC6); the compared set is built by the event builder,
  not the resolver alone. Rejected.

## Interfaces and data model

All symbols are test-local inside `tests/checks/85-conflict-guards.sh`; nothing is
exported and no production interface changes.

### New/changed constants and helpers

```sh
RC_ROOT="tests/fixtures/recursive-conflicts"      # new committed fixture root
RC_ITEMS="$RC_ROOT/items"                          # fixture-local shadow root
GUARD_ITEMS="$GUARD_ROOT/items"                    # existing, becomes the active root

# Build the event stream for one items root (save/restore the active root).
guard_collect() { local saved="$GUARD_ITEMS"; GUARD_ITEMS="$1"; guard_build_events; GUARD_ITEMS="$saved"; }

# Recursive child walk (replaces the two hardcoded top-level loops).
guard_walk_node() { ... }                          # node-ref, node-dir, node-rows

# New generic analyzer over GUARD_EVENTS:
fixture_entities() { ... }                         # prints "<ref>|<shipped 0|1>", sorted
```

`guard_resolve`'s item-reference test becomes
`^[0-9]{4}-[a-z0-9-]+(/[0-9]{4}-[a-z0-9-]+)*$` (was `(...)?$`). The event-stream
grammar (`E|`, `T|`, `D|`) and the four existing analyzers are unchanged and
depth-agnostic; only the walk that produces the stream changes. The resolver in
`guard_resolve`, the sibling-first check, and the drift comparison already take
the immediate parent's rows as an argument, so recursion needs no new resolution
logic.

Driver: capture the main fixture's `ACT_RESOLUTION`/`ACT_UNRESOLVED`/`ACT_DRIFT`/
`ACT_CONFLICTS` exactly as today, then `guard_collect "$RC_ITEMS"` and capture the
recursive blocks into `RC_ENTITIES`, `RC_RESOLUTION`, `RC_UNRESOLVED`, `RC_DRIFT`,
`RC_CONFLICTS`.

### Fixture: `tests/fixtures/recursive-conflicts/items/`

Ids stay in the high, non-colliding fixture space (`00xx`/`92xx`) and allocate no
real `work/` number. Each directory holds only committed fixture data. Prose must
avoid the literal substring `work/` (the read-only-contract assertion greps for
it).

Top level:

| Directory | Kind | Purpose |
| --------- | ---- | ------- |
| `9201-root-a/` | decomposing node (`manifest.md`, 6-col) | the depth-≥3 tree |
| `9202-root-b/` | decomposing node (`manifest.md`, 6-col) | cross-parent equal-token control |
| `0002-grand/` | standalone item (`spec.md` only) | sibling-first decoy (must NOT win) |
| `0009-solo/` | standalone item (`spec.md` only) | bare-token root fallback |
| `9203-shared/` | `.gitkeep` only (no `spec.md`) | shared item target that is not an entity |
| `9210-surface-shared/` | standalone (`spec.md` + `design.md`) | shared **surface** target partner |
| `9211-names-shared/` | standalone (`spec.md` + `design.md`) | shared **item** target partner |

`9201-root-a/manifest.md` (6-column `Children`):

| Local id | Title | Scope | Depends on | conflicts-with | Canonical reference |
| -------- | ----- | ----- | ---------- | -------------- | ------------------- |
| 0001-nested | Nested decomposing child | fixture | — | — | 9201-root-a/0001-nested |
| 0002-sibling | Silent sibling | fixture | — | — | 9201-root-a/0002-sibling |
| 0003-legacy | Legacy 5-column decomposing child | fixture | — | — | 9201-root-a/0003-legacy |

`9201-root-a/0001-nested/` is the **decomposing child** (depth 2). Its
`manifest.md` (6-column `Children`):

| Local id | Title | Scope | Depends on | conflicts-with | Canonical reference |
| -------- | ----- | ----- | ---------- | -------------- | ------------------- |
| 0001-leaf | Silent leaf | fixture | — | — | 9201-root-a/0001-nested/0001-leaf |
| 0002-grand | Drift/union child | fixture | — | docs/customization.md | 9201-root-a/0001-nested/0002-grand |
| 0003-shipped | Shipped child | fixture | — | docs/workflow.md | 9201-root-a/0001-nested/0003-shipped |
| 0004-refs | Recursive-reference child | fixture | — | — | 9201-root-a/0001-nested/0004-refs |
| 0005-precedence | Sibling-first child | fixture | — | — | 9201-root-a/0001-nested/0005-precedence |
| 0006-bad | Malformed-target child | fixture | — | — | 9201-root-a/0001-nested/0006-bad |

`9201-root-a/0003-legacy/manifest.md` carries the **legacy 5-column** header (no
`conflicts-with` column) with one row `0001-old` (canonical
`9201-root-a/0003-legacy/0001-old`) — the depth-≥2 legacy case (AC9).

`9202-root-b/manifest.md` (6-column `Children`):

| Local id | Title | Scope | Depends on | conflicts-with | Canonical reference |
| -------- | ----- | ----- | ---------- | -------------- | ------------------- |
| 0002-grand | Silent grand | fixture | — | — | 9202-root-b/0002-grand |
| 0001-namer | Namer of a silent grand | fixture | — | 0002-grand | 9202-root-b/0001-namer |

Leaf files:

| Path | Content |
| ---- | ------- |
| `9201-root-a/0002-sibling/.gitkeep` | empty (silent depth-2 entity) |
| `9201-root-a/0001-nested/0001-leaf/.gitkeep` | empty (silent depth-3 entity) |
| `9201-root-a/0001-nested/0002-grand/design.md` | `conflicts-with: "docs/workflow.md"` |
| `9201-root-a/0001-nested/0003-shipped/ship.md` | shipped signal (no `design.md`) |
| `9201-root-a/0001-nested/0004-refs/design.md` | `conflicts-with: "9201-root-a/0001-nested/0001-leaf, tests/fixtures, 9201-root-a/0001-nested/0003-shipped"` |
| `9201-root-a/0001-nested/0005-precedence/design.md` | `conflicts-with: "0002-grand, 0009-solo, 9203-shared"` |
| `9201-root-a/0001-nested/0006-bad/design.md` | `conflicts-with: "../escape, /abs.md, docs/*.md, 9999-nope, docs/no-such-file.md, 9201-root-a/0001-nested/0006-bad, "` (trailing empty token) |
| `9201-root-a/0003-legacy/0001-old/.gitkeep` | empty |
| `9202-root-b/0001-namer/.gitkeep` | empty (declares `0002-grand` via its row cell) |
| `9202-root-b/0002-grand/.gitkeep` | empty |
| `9210-surface-shared/design.md` | `conflicts-with: "docs/workflow.md"` |
| `9211-names-shared/design.md` | `conflicts-with: "9203-shared"` |

`0002-grand/`, `0009-solo/`, `9210-surface-shared/`, `9211-names-shared/` each
carry `spec.md`; `9210`/`9211` also carry the `design.md` above. `9203-shared/`
carries only `.gitkeep`, so it resolves as an item target but is not itself an
entity.

### Expected recursive event blocks

Entity set (`fixture_entities`, sorted):

```
0002-grand|0
0009-solo|0
9201-root-a/0001-nested|0
9201-root-a/0001-nested/0001-leaf|0
9201-root-a/0001-nested/0002-grand|0
9201-root-a/0001-nested/0003-shipped|1
9201-root-a/0001-nested/0004-refs|0
9201-root-a/0001-nested/0005-precedence|0
9201-root-a/0001-nested/0006-bad|0
9201-root-a/0002-sibling|0
9201-root-a/0003-legacy|0
9201-root-a/0003-legacy/0001-old|0
9202-root-b/0001-namer|0
9202-root-b/0002-grand|0
9210-surface-shared|0
9211-names-shared|0
```

Resolution (`fixture_resolution`) grouped by owner for the per-rule blocks:

```
# 9201-root-a/0001-nested/0004-refs  (AC1, AC7)
9201-root-a/0001-nested/0004-refs|9201-root-a/0001-nested/0001-leaf|resolved|item|9201-root-a/0001-nested/0001-leaf
9201-root-a/0001-nested/0004-refs|9201-root-a/0001-nested/0003-shipped|resolved|item|9201-root-a/0001-nested/0003-shipped
9201-root-a/0001-nested/0004-refs|tests/fixtures|resolved|surface|tests/fixtures

# 9201-root-a/0001-nested/0005-precedence  (AC2)
9201-root-a/0001-nested/0005-precedence|0002-grand|resolved|item|9201-root-a/0001-nested/0002-grand
9201-root-a/0001-nested/0005-precedence|0009-solo|resolved|item|0009-solo
9201-root-a/0001-nested/0005-precedence|9203-shared|resolved|item|9203-shared

# 9201-root-a/0001-nested/0002-grand  (AC4)
9201-root-a/0001-nested/0002-grand|docs/customization.md|resolved|surface|docs/customization.md
9201-root-a/0001-nested/0002-grand|docs/workflow.md|resolved|surface|docs/workflow.md
```

Drift (`fixture_drift`, AC5): `9201-root-a/0001-nested/0002-grand`.

Unresolved (`fixture_unresolved`, AC8):

```
9201-root-a/0001-nested/0006-bad|
9201-root-a/0001-nested/0006-bad|../escape
9201-root-a/0001-nested/0006-bad|/abs.md
9201-root-a/0001-nested/0006-bad|9201-root-a/0001-nested/0006-bad
9201-root-a/0001-nested/0006-bad|9999-nope
9201-root-a/0001-nested/0006-bad|docs/*.md
9201-root-a/0001-nested/0006-bad|docs/no-such-file.md
```

Conflict pairs (`fixture_conflicts`, AC6/AC7):

```
0009-solo|9201-root-a/0001-nested/0005-precedence|(b)
9201-root-a/0001-nested/0001-leaf|9201-root-a/0001-nested/0004-refs|(b)
9201-root-a/0001-nested/0002-grand|9201-root-a/0001-nested/0005-precedence|(b)
9201-root-a/0001-nested/0002-grand|9210-surface-shared|(a)
9201-root-a/0001-nested/0005-precedence|9211-names-shared|(b)
9202-root-b/0001-namer|9202-root-b/0002-grand|(b)
```

Notes tying the blocks to the criteria:

- `9201-root-a/0001-nested/0004-refs`'s three-segment target proves the widened
  grammar (the old `(...)?$` regex would fall through to the surface check and
  report it unresolved); `tests/fixtures` proves the ref-vs-path discriminator
  still classifies a non-reference as a surface path (AC1).
- `0005-precedence`'s `0002-grand` resolves to the sibling
  `9201-root-a/0001-nested/0002-grand`, **not** the top-level `0002-grand`
  directory; `0009-solo` and `9203-shared` fall to the root fallback (AC2).
- The set above contains `9201-root-a/0001-nested` (from `9201-root-a`'s row)
  **and** its own rows, each keyed by full canonical reference (AC3).
- `0002-grand`'s block contains both its own target (`docs/workflow.md`) and its
  parent cell's (`docs/customization.md`) — the union (AC4) — while its drift is
  reported because both are present and unequal (AC5); `0003-shipped`'s one-sided
  cell is not drift.
- `0002-grand | 9210-surface-shared` is the cross-level shared **surface** class
  `(a)`; `0005-precedence | 9211-names-shared` is the cross-level shared
  **item** class `(b)`; `0001-leaf | 0004-refs`, `0002-grand | 0005-precedence`,
  `0009-solo | 0005-precedence`, and `9202-root-b/0001-namer |
  9202-root-b/0002-grand` are one-sided naming of otherwise silent counterparts,
  each reported once (AC6).
- `0004-refs` names `9201-root-a/0001-nested/0003-shipped`, which still resolves
  (in the resolution block) but appears in **no** conflict pair because a shipped
  entity is excluded as a counterpart (AC7).
- `0006-bad`'s tokens are each reported unresolved and never dropped or repaired:
  `..` traversal, absolute path, and glob are malformed; `9999-nope` and
  `docs/no-such-file.md` resolve to nothing; the self reference and the trailing
  empty token are malformed (AC8).
- `9201-root-a/0003-legacy/0001-old`'s five-column row declares nothing (no
  resolution/unresolved lines) yet is an entity (AC9).

The cross-parent control: `0005-precedence`'s bare `0002-grand` and
`9202-root-b/0001-namer`'s bare `0002-grand` resolve to **different** canonical
items, so there is deliberately no pair between them (equal text, different
targets). The guard asserts that absence.

### New `AC23` sub-area labels

Each recursive rule gets a distinct label so a single targeted mutation trips a
`FAIL` naming that rule (AC12):

| Label | Pins | Criteria |
| ----- | ---- | -------- |
| `AC23 recursive-fixture-existence` | the committed fixture root and key files exist | AC11 |
| `AC23 recursive-read-only-contract` | `$RC_ROOT` references no live `work/` path | AC11 |
| `AC23 recursive-column-layout` | 6-col header on `9201-root-a`/`0001-nested`; 5-col legacy header at depth 2; positional parse; `0001-old` declares nothing but is an entity | AC9 |
| `AC23 recursive-traversal` | the entity set (decomposing child + its rows) | AC3 |
| `AC23 recursive-reference` | the recursive reference grammar and ref-vs-path discriminator | AC1 |
| `AC23 recursive-sibling-precedence` | sibling-first, then root fallback, below the root | AC2 |
| `AC23 recursive-union` | own ∪ parent-cell union at depth | AC4 |
| `AC23 recursive-drift` | both-present-unequal discrepancy | AC5 |
| `AC23 recursive-pair` | pair predicate across levels | AC6 |
| `AC23 recursive-shipped` | shipped target resolves but is excluded as a counterpart | AC7 |
| `AC23 recursive-unresolved` | malformed/unresolved reporting | AC8 |

Each assertion uses the existing `ok`/`bad` reporters and the existing
`guard_contains`/`guard_absent`/diff helpers; no new reporter or token scheme.

## Affected areas

- `tests/checks/85-conflict-guards.sh` — widened `guard_resolve` regex; recursive
  `guard_walk_node` + parameterized `guard_collect`; new `fixture_entities`;
  new `AC23 recursive-*` assertion blocks; header comment updated. Existing
  constants, analyzers, and `AC23` blocks are otherwise untouched.
- `tests/fixtures/recursive-conflicts/` — new committed fixture tree (all files
  listed above), including the `items/` shadow root.
- **Not touched** (out of scope, per `spec.md:50-68`): `docs/workflow.md`,
  `docs/artifact-conventions.md`, `.opencode/**`, `README.md`, `AGENTS.md`,
  `tests/README.md`, `tests/mutation.sh`, and `tests/fixtures/declared-conflicts/`.

## Backward compatibility and migrations

None required. The grammar widening is behavior-preserving for every existing
fixture token; the recursive walk adds no entity for a tree with no decomposing
child (the `declared-conflicts` fixture has none), so its `ACT_*` blocks are
byte-identical to today (AC10). The new fixture root is additive and allocates no
`work/` number. `tests/mutation.sh` does not stage the new root yet — its
staged-copy entry and mutation jobs are owned by the sibling
`0005-guard-registration-sweep` (`spec.md:55-58`); until then the opt-in mutation
pass's whole-suite step will not find the new root, which is the recorded sibling
dependency, not a regression in `bash tests/run.sh`.

## Risks and mitigations

- **Recursion perturbs the depth-2 control.** *Likelihood* low / *impact* medium —
  a changed event stream would fail the shipped `AC23` blocks. *Mitigation:* the
  `declared-conflicts` fixture has no decomposing child, so `guard_walk_node`
  emits the identical entity set; T1/T2 verify `FRAMEWORK_TEST_AREAS=85-conflict-guards
  bash tests/run.sh` after each step.
- **Per-rule labels blur, defeating AC12.** *Likelihood* medium / *impact* medium —
  a single umbrella expected block would name the wrong rule. *Mitigation:*
  group each rule into its own labeled assertion and keep the expected subsets in
  this design; `/test` performs the targeted-mutation spot check (T9).
- **A recursive reference token accidentally exists as a filesystem path, flipping
  classification.** *Likelihood* low / *impact* medium. *Mitigation:* ids live in
  the fixture-local `92xx` space with no matching repo-root path; the expected
  block asserts the `item` classification.
- **The read-only-contract grep false-positives on fixture prose.** *Likelihood*
  low / *impact* low. *Mitigation:* fixture prose avoids the literal `work/`; the
  assertion fails loudly if it appears.
- **AC12's end-to-end proof is not in this item's committed mutation jobs.**
  *Likelihood* certain (by spec) / *impact* low. *Mitigation:* dedicated labels
  make each rule independently trippable; T9 runs a scratch-copy targeted-mutation
  spot check; `0005` registers the permanent jobs.

## Test strategy

The guard *is* the test. Each acceptance criterion maps to a committed assertion
in `tests/checks/85-conflict-guards.sh`, run by `bash tests/run.sh`:

| Criterion | Assertion / label | Level |
| --------- | ----------------- | ----- |
| AC1 | `AC23 recursive-reference` — expected resolution subset for `0004-refs` | fixture unit |
| AC2 | `AC23 recursive-sibling-precedence` — expected resolution subset for `0005-precedence` | fixture unit |
| AC3 | `AC23 recursive-traversal` — expected entity set | fixture unit |
| AC4 | `AC23 recursive-union` — expected resolution subset for `0002-grand` | fixture unit |
| AC5 | `AC23 recursive-drift` — expected drift set | fixture unit |
| AC6 | `AC23 recursive-pair` — expected conflict-pair block + absence assertions | fixture unit |
| AC7 | `AC23 recursive-shipped` — shipped resolves + absent from the pair block | fixture unit |
| AC8 | `AC23 recursive-unresolved` — expected unresolved block | fixture unit |
| AC9 | `AC23 recursive-column-layout` — legacy header at depth; `0001-old` declares nothing | fixture unit |
| AC10 | existing `AC23 column-layout`/`positional-parse`/`cell-resolution`/`pair-predicate`/`reporting-vocabulary` unchanged and green | regression |
| AC11 | `AC23 recursive-fixture-existence` + `recursive-read-only-contract` | structural |
| AC12 | each `AC23 recursive-*` label is trippable by one targeted mutation; T9 spot check | mutation (manual here, registered by `0005`) |

The live `/conflicts`, `/status`, and `/build`-gate model runs remain
non-executable in CI and stay a documented manual residual, unchanged from the
shipped area.
