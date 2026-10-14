---
feature: 0015-recursive-workflow-guards/0002-recursive-readiness-status-guard
phase: design
status: final
created: 2026-10-14
updated: 2026-10-14
conflicts-with: "—"
parent: 0015-recursive-workflow-guards
---

# Design — Recursive readiness and `/status` guard

## Summary

Add one committed agreement area, `tests/checks/89-recursive-status-guards.sh`
(suite token `AC27`), and a new committed fixture root
`tests/fixtures/recursive-status/` whose tree is three or more levels deep and
contains a hybrid node, a `.gitkeep`-only leaf, a deliberate dependency cycle,
every dependency-satisfaction case, and the derived-state overlay cases. The area
derives readiness, each node's phase, and each decomposing node's summary line
from the fixture with pure Bash/awk — the same fixture-scoped shape as
`80-cycle-fixture.sh`/`85-conflict-guards.sh`/`87-backtrack-guards.sh` — compares
the result to reviewed literal expected blocks, and pins the `/status` render
contract against the prompt authority. It edits no production surface and
registers itself nowhere (`0005` owns registration).

## Approach

The framework's recursive readiness, derived-state, and `/status` contracts are
documented and swept but pinned by no fixture deeper than two levels
(`tests/checks/87-backtrack-guards.sh:94` deliberately skips decomposing nodes;
the cycle fixture is depth 2). This item adds the missing **committed,
fixture-based** guard by extending the established guard pattern from flat/depth-2
to recursive depth:

1. **A new fixture root**, `tests/fixtures/recursive-status/items/`, a fixture-local
   tree that shadows the live `work/` root (exactly as
   `tests/fixtures/{declared-conflicts,backtracking}/items/` do). It contains one
   top-level decomposing node `9200-tree`, a same-local-id decoy `9201-decoy`, and
   a depth-3/4 subtree. Fixture entity ids stay in the non-allocating `92xx` band
   (the sibling roots use `90xx`/`91xx`); fixture roots are read-only test data and
   allocate no real `work/` number.
2. **One agreement area**, `tests/checks/89-recursive-status-guards.sh`, sourced by
   `tests/run.sh` like every other check. It resolves each manifest through the
   shared manifest-then-legacy-alias lookup, parses the `Children` table by header
   name, walks the fixture tree recursively, and emits three analyzers — readiness,
   derived phase, and per-container summary — each compared to a reviewed
   `cat <<'EOF'` expected block. Structural assertions (fixture-existence that
   fails rather than skips, the read-only contract) and the `/status` render pins
   sit alongside them.
3. **No new harness, token scheme, or policy**: the area is one `tests/checks/*.sh`
   file labelled `AC27` with sub-area labels (which `tests/mutation.sh` names when a
   mutation trips), it prints only `ok`/`FAIL`/`skip`, never calls `exit`, stays
   Bash 3.2 compatible, and reads only committed fixtures and live surfaces.

The recursive composition is computed, not restated: the guard implements the
readiness and derived-state rules for its own fixture and references the
neighbouring areas (`10-readiness`, `20-lifecycle`, `80-cycle-fixture`,
`87-backtrack-guards`) by name, re-asserting none of their authority literals
(AC15). The flat overlay vocabulary is the authority's shared vocabulary and is
referenced by name, not re-pinned.

### Fixture tree and computed values (the data model)

`tests/fixtures/recursive-status/items/`. "full" below means `spec.md`, `design.md`,
`tasks.md` (all boxes checked), `verify.md`, `review.md`; `review.md` carries the
named verdict and `ship.md` the named state.

| Node (canonical ref under `items/`) | Own artifacts / markers | Derived phase |
| ----------------------------------- | ----------------------- | ------------- |
| `9200-tree` | `manifest.md` only (pure container) | `manifest` |
| `9200-tree/0001-hybrid` | `manifest.md` + `spec.md` + `design.md` (hybrid) | `design` |
| `9200-tree/0001-hybrid/0001-empty-leaf` | `.gitkeep` | `not started` |
| `9200-tree/0001-hybrid/0002-approved-leaf` | full + `review.md` `approve` | `ship` |
| `9200-tree/0001-hybrid/0003-cyclic-a` | `.gitkeep` | `not started` |
| `9200-tree/0001-hybrid/0004-cyclic-b` | `.gitkeep` | `not started` |
| `9200-tree/0002-shipped` | full + `ship.md` | `shipped` |
| `9200-tree/0003-approved` | full + `review.md` `approve` | `ship` |
| `9200-tree/0004-rejected` | full + `review.md` `request-changes` | `build (rework)` |
| `9200-tree/0005-noreview` | spec, design, tasks✓, verify | `review` |
| `9200-tree/0006-precedence` | full + `review.md` `request-changes` + `ship.md` | `shipped` |
| `9200-tree/0007-recalled` | full + `review.md` `approve` + `ship.md` `reopened: build` | `build (reopened)` |
| `9200-tree/0008-dependent` | `spec.md` | `spec` |
| `9200-tree/0009-decomposing-approved` | `manifest.md` + full + `review.md` `approve` (hybrid) | `ship` |
| `9200-tree/0009-decomposing-approved/0001-leaf` | `.gitkeep` | `not started` |
| `9200-tree/0010-depends-decomposing` | `spec.md` | `spec` |
| `9200-tree/0011-decomposing-unsat` | `manifest.md` only (pure container) | `manifest` |
| `9200-tree/0011-decomposing-unsat/0001-shipped-child` | full + `ship.md` | `shipped` |
| `9200-tree/0012-depends-unsat-dec` | `spec.md` | `spec` |
| `9200-tree/0013-stale-hybrid` | `manifest.md` + `spec.md` (`stale: design`) | `design (backtracked)` |
| `9200-tree/0014-challenged-node` | `spec.md` + `design.md` + open `challenges.md` | `challenged (blocked)` |
| `9200-tree/0015-stale-and-challenged` | `spec.md` (`stale: spec`) + open `challenges.md` | `spec (backtracked)` |
| `9201-decoy` | `manifest.md` only (pure container) | `manifest` |
| `9201-decoy/0002-shipped` | `ship.md` `reopened: build` | `build (reopened)` |

`9200-tree`'s manifest `Children` rows: `0001-hybrid`; `0002-shipped`;
`0003-approved`; `0004-rejected`; `0005-noreview`; `0006-precedence`;
`0007-recalled`; `0008-dependent` (`Depends on: 0002-shipped, 0003-approved,
0004-rejected, 0005-noreview, 0006-precedence, 0007-recalled`);
`0009-decomposing-approved`; `0010-depends-decomposing` (`Depends on:
0009-decomposing-approved`); `0011-decomposing-unsat`; `0012-depends-unsat-dec`
(`Depends on: 0011-decomposing-unsat`); `0013-stale-hybrid`;
`0014-challenged-node`; `0015-stale-and-challenged`. `0001-hybrid`'s manifest
`Children`: `0001-empty-leaf`; `0002-approved-leaf`; `0003-cyclic-a` (`Depends on:
0004-cyclic-b`); `0004-cyclic-b` (`Depends on: 0003-cyclic-a`) — a deliberate
cycle recorded under that manifest's `## Open issues` (the `cyclic-roadmap`
fixture precedent), with cycle *detection* left to `80-cycle-fixture`.

Readiness (`<ref>|<ready|blocked: ids>`): every row is `ready` except
`9200-tree/0008-dependent` → `blocked: 0004-rejected, 0005-noreview, 0007-recalled`;
`9200-tree/0012-depends-unsat-dec` → `blocked: 0011-decomposing-unsat`;
`9200-tree/0001-hybrid/0003-cyclic-a` → `blocked: 0004-cyclic-b`;
`9200-tree/0001-hybrid/0004-cyclic-b` → `blocked: 0003-cyclic-a`. The satisfied
sibling `9200-tree/0002-shipped` versus the recalled `9201-decoy/0002-shipped`
proves sibling-only resolution: a cross-root resolver would also block
`9200-tree/0008-dependent` on `0002-shipped`.

Summary lines (`<node-ref>|<ready>/<total> ready · phases: <phase> <n>, ...`, the
phase token being `rs_derive`'s label): `9200-tree` → `13/15 ready · phases: …`
over its fifteen immediate children; `9200-tree/0001-hybrid` → `2/4 ready ·
phases: not started 3, ship 1`; `9201-decoy` → `1/1 ready · phases: build
(reopened) 1`.

### Guard interfaces (helper functions)

Defined in `89-recursive-status-guards.sh`, Bash 3.2-compatible, mirroring the
`bt_*`/`guard_*` helpers of the sibling areas:

- `rs_manifest(dir)` → the node's `manifest.md`, else the legacy `roadmap.md`
  alias, else nothing (shared manifest-then-alias lookup).
- `rs_fm_value(file, field)` → a frontmatter field's trimmed value (the
  `bt_fm_value` shape), used for `stale` and `reopened`.
- `rs_children_rows(manifest)` → normalized `localid|depends-on|conflicts-with|ref`
  rows parsed by header name.
- `rs_header(manifest)` → the `|`-joined `Children` header names (the
  no-stored-readiness assertion compares it to the canonical six columns).
- `rs_has_open_challenge(ref)` → a `Challenge n` with no matching `Response
  n`/`Withdrawal n` in the fixture's `challenges.md`.
- `rs_satisfied(childdir)` → `1` when `ship.md` is present with no `reopened:`
  marker, or (absent `ship.md`) `review.md` names `approve`; else `0`.
- `rs_cycle_members(manifest)` → local ids left after Kahn's reduction (the
  `80-cycle-fixture`/`87-backtrack-guards` proof shape).
- `rs_ready_blocked(node_dir)` → `<node-ref>/<localid>|<ready|blocked: ids>` per
  row; a cycle member is never `ready`.
- `rs_derive(dir, ref)` → the derived label, applying the authority's precedence:
  earliest `stale:` → `<token> (backtracked)`; `ship.md` `reopened:` →
  `<phase> (reopened)`; unshipped open challenge → `challenged (blocked)`;
  manifest with no own phase artifacts → `manifest`; otherwise the
  artifact-presence/verdict rows; a `.gitkeep`-only node → `not started`.
- `rs_summary(node_dir)` → `<node-ref>|<n>/<total> ready · phases: …`.

Expected blocks are reviewed literals (`cat <<'EOF'`), compared with the
`bt_show_diff`-style helper so a mutation names the diverging block. Structural
assertions: `AC27 fixture-existence` (present → `ok`, **missing → `bad`, never
`skip`**), `AC27 read-only-contract` (the fixture references no live `work/`
path, contains no nested `work/`, and no absolute or `../` path — the
`87-backtrack-guards.sh:235-255` shape), `AC27 no-duplication` (references
`10-readiness`/`20-lifecycle`/`80-cycle-fixture`/`87-backtrack-guards` by name;
its source contains none of their owned literals, assembled from fragments so the
assertion cannot match itself), and `AC27 no-stored-readiness` (every fixture
manifest's `Children` header is the canonical six columns).

### Rationale for the two spec ambiguities the design resolves

- **`9xxx` band and fixture root name** (spec Open questions, deferred to the
  architect): root `tests/fixtures/recursive-status/`, entity band `92xx`,
  decoy band `9201`. Chosen to read as a distinct, non-`work/`-allocating fixture
  root and to avoid the `90xx`/`91xx` bands already used.
- **The spec's stale-plus-challenge edge case** ("the blocked `challenged
  (blocked)` label wins the phase") contradicts normative AC11, the authority
  (`docs/workflow.md` → "Derived state" evaluates the `stale:`/`reopened:`
  structural rows before the challenged overlay), and the already-shipped
  `87-backtrack-guards` expectation (`9115-stale-challenge|design (backtracked)`
  plus its "a stale marker outranks an open challenge" assertion). The design
  follows AC11 and the authority: `9200-tree/0015-stale-and-challenged` derives
  `spec (backtracked)`. This is a subordinate-bullet inconsistency only; no
  acceptance criterion is undesignable, so no `/plan`→`/spec` reverse edge is
  taken. The pre-existing status-prompt wording is out of scope (non-goal: no
  production surface changes) and is recorded as a follow-up.

## Alternatives considered

- **Extend `tests/checks/87-backtrack-guards.sh` in place to depth ≥ 3**
  (add a deeper fixture to `tests/fixtures/backtracking/` and generalize
  `bt_derive`/`fixture_readiness`). Rejected: 87's scope and expected blocks are
  the flat-item and depth-2 overlay semantics, and the spec's non-goals keep the
  flat overlay vocabulary owned by 87; mutating its fixture would move a shipped
  area's reviewed expected blocks and risk its mutation jobs. A distinct area
  leaves 87 untouched and composes cleanly.
- **Split into two areas — readiness (`AC27`) and `/status` (`AC28`)** — each
  with its own fixture. Rejected: the spec's own assumption pins one area
  (`AC27`), and the parent manifest records that splitting is a parent
  `/plan 0015-recursive-workflow-guards` re-slice, not a spec change
  (`work/0015-recursive-workflow-guards/manifest.md:219-222`).
- **Drive a real `/status` run and diff its output.** Rejected: not executable in
  CI (spec non-goal "No live `/status` run") and it would read live `work/**`,
  breaking the suite's read-only, fresh-clone-clean contract. The guard computes
  the same shape from a committed fixture instead.
- **Ship a production checker (a `tests/`-external script) for the recursive
  contract.** Rejected: the spec's non-goal "No committed executable checker" and
  the authority's "prompt behavior only" contract; the guard is fixture-scoped
  test code and implements no command.

## Interfaces and data model

- **New guard area:** `tests/checks/89-recursive-status-guards.sh`, sourced by
  `tests/run.sh` (no `run.sh` edit — adding a file is adding a check), token
  `AC27`, sub-areas `recursive-readiness`, `nested-readiness`,
  `dependency-satisfaction`, `decomposing-target`, `cycle-readiness`,
  `derived-phase`, `overlay-precedence`, `decomposing-summary`, `status-render`,
  `no-stored-readiness`, `determinism`, and the structural labels
  `fixture-existence`, `read-only-contract`, `no-duplication`.
- **New fixture root:** `tests/fixtures/recursive-status/items/` exactly as
  tabled above. Each fixture entity id is `NNNN-slug` in the `92xx` band;
  identity is the full canonical path under the fixture root.
- **No production interface, schema, dependency, or migration.** No `.opencode/`,
  `docs/`, `README.md`, or `AGENTS.md` change; no new dependency, tool, or
  network access. `tests/README.md` and `tests/mutation.sh` are registered by
  `0005`, not here (this item's `conflicts-with` is `—`; any shared-registry
  declaration travels via the parent `Children` cell, whose effective set is the
  union).
- **Backward compatibility:** additive only. A new `tests/checks/*.sh` file and a
  new fixture root do not alter any existing area, fixture, or production
  surface; `bash tests/run.sh` gains assertions and stays green.

## Affected areas

- `tests/checks/89-recursive-status-guards.sh` — new (the guard).
- `tests/fixtures/recursive-status/items/**` — new (the fixture tree).
- Out of scope (owned downstream): `tests/README.md`, `tests/mutation.sh`
  (`0005-guard-registration-sweep`).

## Risks and mitigations

- **Guard filename collision with a parallel sibling guard (`0001`/`0003`/`0004`).**
  Likelihood medium / impact low. Mitigation: `89-recursive-status-guards.sh` is
  currently unused and descriptive; `run.sh` resolves exact area names first, and
  any residual prefix clash is a registration concern owned by `0005` and the
  parent `/plan` re-sequence.
- **Fixture-id band reuse across sibling roots.** Likelihood low / impact none.
  Mitigation: `92xx` is distinct from `90xx`/`91xx`; identity is the full canonical
  path within a root, so cross-root reuse is definitionally not a duplicate.
- **The spec's stale-plus-challenge edge case conflicts with the authority + 87.**
  Likelihood certain (present in the text) / impact low. Mitigation: follow AC11
  and the authority (`spec (backtracked)`); record the discrepancy here and as a
  follow-up rather than editing the pinned authority.
- **Derived-state order ambiguity (`ship.md`-present vs `spec.md`-missing).**
  Likelihood low / impact low. Mitigation: every fixture node whose phase is
  asserted carries a realistic artifact set, so its label is unambiguous under
  any reading of the decision list; the shipped/approved nodes carry the full
  lifecycle set, not a bare `ship.md`.
- **Summary-line tally format is not fixed by the authority.** Likelihood medium /
  impact low. Mitigation: `rs_summary` uses the authority's `<ready>/<total>
  ready` and `<phase> <n>, ...` tokens with the derived label as the phase token,
  and the reviewed literal expected block is the contract; AC12 pins only the
  contract's presence in the authority, not a specific tally order.
- **Fixture/guard size.** Likelihood medium / impact low. Mitigation: reuse the
  `80`/`85`/`87` analyzer shapes, keep the node set bounded to exactly the states
  the ACs name, and give dependency-only leaves minimal-but-realistic artifacts.
- **Mutation coverage depends on `0005` registration.** Likelihood certain /
  impact medium. Mitigation: the area exposes stable sub-area labels for
  one-mutation-per-rule registration, and the fixture root is added to
  `tests/mutation.sh`'s staged-copy list by `0005`.

## Test strategy

This item *is* a test; its verification is the area's own assertions plus the
mutation self-check (`0005`). Every acceptance criterion maps to a committed,
executable check at the fixture/suite level:

| Criterion | Verification level | Where |
| --------- | ------------------ | ----- |
| AC1 depth ≥ 3, hybrid, `.gitkeep`-only | fixture assertions + `rs_derive`/`rs_ready_blocked` on the tree | `89` (`recursive-readiness`, `derived-phase`) |
| AC2 per-level readiness incl. depth ≥ 3 | analyzer + expected block | `89` (`recursive-readiness`, `nested-readiness`) |
| AC3 four dependency-satisfaction cases | analyzer + expected block | `89` (`dependency-satisfaction`) |
| AC4 recalled dependency blocks dependent | analyzer + expected block | `89` (`dependency-satisfaction`) |
| AC5 `ship.md` presence precedence | analyzer + expected block | `89` (`dependency-satisfaction`) |
| AC6 decomposing target own-signal-only; sibling-only | analyzer + expected block + `9201-decoy` | `89` (`decomposing-target`) |
| AC7 cycle member never ready | analyzer + expected block (cycle fixture) | `89` (`cycle-readiness`) |
| AC8 deterministic; no stored readiness | run-twice diff + header assertion | `89` (`determinism`, `no-stored-readiness`) |
| AC9 hybrid own-phase before container | analyzer + expected block | `89` (`derived-phase`) |
| AC10 nested decomposing own-phase first; `.gitkeep` not-started | analyzer + expected block | `89` (`derived-phase`) |
| AC11 stale/reopened/challenged precedence at a node | analyzer + expected block | `89` (`overlay-precedence`) |
| AC12 `/status` render contract present in the authority | live-surface literal pins | `89` (`status-render`) |
| AC13 literal expected blocks; flatten/mis-derive fails | expected blocks + mutation self-check | `89` (all analyzers); `tests/mutation.sh` (`0005`) |
| AC14 missing fixture fails, not skips; read-only contract | structural assertion + mutation self-check | `89` (`fixture-existence`, `read-only-contract`) |
| AC15 references neighbours by name; no re-assertion; no checker | `no-duplication` assertion + live-surface review | `89` (`no-duplication`) |

AC12's accuracy and AC15's "no production checker" clause are additionally
verified by review of the diff against the two non-goals; the live `/status`
render residual (a real `/status` run emitting the same shape) remains a
documented manual check in `tests/README.md` (`0005`) and `verify.md`.
