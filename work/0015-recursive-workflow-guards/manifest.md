---
feature: 0015-recursive-workflow-guards
phase: manifest
status: final
created: 2026-10-14
updated: 2026-10-14
---

# Manifest — Committed recursive-workflow guards

## Initiative

This is **Roadmap 5** — the final roadmap of the bootstrapped multi-roadmap plan
that `work/0011-recursive-bootstrap/roadmap.md` launched (its "Multi-roadmap
sequence", `work/0011-recursive-bootstrap/roadmap.md:125-149`; Roadmap 5 named at
`:143-144` and re-derived at
`work/0013-simultaneous-work-recursion/manifest.md:121-123` and
`work/0014-agent-command-inventory-sweep/manifest.md:167-169`). Roadmap 1
(`0011-recursive-bootstrap`) shipped the minimal recursive facility — model,
schema, writer, and readiness/derived state; Roadmap 2 (`0012-roadmap-deprecation`)
retired the special `roadmap` concept and made the generic **manifest** the sole
child-enumeration artifact; Roadmap 3 (`0013-simultaneous-work-recursion`)
generalized allocation, duplicate detection, declared conflicts, merge integrity,
and plan publication to arbitrary depth; and Roadmap 4
(`0014-agent-command-inventory-sweep`) swept every agent, command, and skill
prompt onto the recursive model and reconciled the documented inventories.

What remains is the **committed guard**: the recursive model is documented and
swept, but it is **pinned by almost no committed fixture**. The existing guards
are two-level — `tests/fixtures/cyclic-roadmap/roadmap.md` and the
`tests/fixtures/{declared-conflicts,backtracking}/` manifests are all depth 2 and
no fixture exercises depth ≥ 3, a hybrid node, or an arbitrary-depth reference —
so a regression that flattened the model back to two levels, mis-allocated a
grandchild's `MMMM`, mis-derived a nested node's readiness/phase, or truncated the
`conflicts-with` resolver would pass the suite. Roadmap 5 adds the **fixture-based
committed guards** that pin the recursive model, references, allocation,
readiness, status, and conflicts, so the recursive contract cannot silently
regress.

It serves **framework maintainers**, who must be able to change the recursive
model and trust a committed test catches a regression at every depth; and
**adopters**, who inherit the recursive model and need its guarantees held by the
same committed suite.

The recursive authority is already shipped and is the single source of truth:
`docs/workflow.md` → "The recursive lifecycle model", "Where decomposition is
authored and recorded", "Revising a decomposition", "Dependencies and readiness",
"Derived state", "Multiple work items", "Declared conflicts (`conflicts-with`)",
"Declared-conflict check", and "Merge conflicts"; together with
`docs/artifact-conventions.md` → "Work item references", "Sequence allocation",
and "`manifest.md` — the manifest of a decomposing node". This roadmap pins that
authority; it redefines none of it and edits no production surface. Whole
families of guards are genuine single features, so this node is a **pure
container** with no lifecycle artifacts of its own.

Deliberately **out of scope**: the authority docs and every swept prompt (Roadmaps
1–4 shipped them and they are the *pinned* source, not the guarded artifact); any
change to `.opencode/`, `README.md`, `AGENTS.md`, or `docs/`; the historical
per-item `work/<ref>/verify-tests.sh` scripts (they are not part of
`tests/run.sh`); and the committed recursive guards' *production* surfaces — the
guards remain prompt/fixture behavior only, adding no committed executable
checker.

## Assumptions

- **Framework-internal and test-only.** No installed runtime dependency, service,
  network access, or new toolchain is introduced. Surfaces in scope:
  `tests/checks/`, `tests/fixtures/`, `tests/README.md`, and `tests/mutation.sh`.
  No production surface (`.opencode/**`, `docs/**`, `README.md`, `AGENTS.md`) is
  edited: the authority is the pinned target, not the guarded artifact.
- **Roadmap 5 of the sequence.** Roadmaps 1–4 (`0011`–`0014`) have shipped all of
  their children; this roadmap is the final stage specified at
  `work/0011-recursive-bootstrap/roadmap.md:143-144`. It re-homes the scope of the
  withdrawn child `0010-recursive-plan-cycle/0008-recursive-guards`
  ("fixture-based committed guards pinning the recursive workflow",
  `work/0010-recursive-plan-cycle/roadmap.md:204-209`).
- **The suite contract is the seed.** A guard is **one agreement area = one
  `tests/checks/*.sh` file** labelled with a stable `ACn` token; it is
  **fixture-based** and reads only committed surfaces, **never live `work/**`**
  (`tests/run.sh:20`, `tests/README.md:30-31`); it resolves a manifest
  manifest-then-legacy-alias (`tests/checks/80-cycle-fixture.sh:28-34`); and it
  carries **one bounded mutation per distinct rule** (norm ≤ 3 per area,
  `tests/README.md:314-323`). This roadmap extends those conventions; it defines
  no second harness, token scheme, or mutation policy.
- **Guards pin prose and shape, never execution.** The read-only check, readiness
  derivation, a `/status` render, a real backtrack, and a `/ship recall` are prompt
  behavior and are not executable in CI; as with the existing guards, the
  LLM-run residual is documented in the area's `verify.md` and `tests/README.md`,
  and the committed guard pins the *fixture and contract text* instead.
- **Prompt behavior only — no committed executable checker.** The guards add no
  committed checker, script, helper, or executable tool for the recursive model,
  references, allocation, readiness, status, or conflicts; they pin the shipped
  contract text that says so (`docs/workflow.md` "Merge-integrity guard",
  "Declared-conflict check").
- **New fixture roots are additive and non-allocating.** Fixture entity ids stay
  in the high, non-colliding `90xx`/`91xx`/`92xx` space and allocate no real
  `work/` number, matching the existing `tests/fixtures/{declared-conflicts,backtracking}/`
  convention.
- **The committed suite stays green.** `bash tests/run.sh` must pass at every step,
  and the mutation self-check (`bash tests/mutation.sh`) must catch and name each
  new rule. The new fixture roots are added to `tests/mutation.sh`'s staged copy
  list; no live `work/**` is ever read.
- **Shipped work is context.** Every shipped item (including every `0010`–`0014`
  child) is out of scope for rewriting; the guards extend their decisions and
  re-open none.
- **No new counted surfaces.** The README/customization inventories (13 agents /
  12 commands / 11 skills) count no test file, so `40-inventory.sh` stays green
  and no inventory is edited.
- **Child numbers are local** to this parent and independent of the top-level
  sequence and of every other node.
- **The user owns the policy forks.** Whether the readiness and status guards are
  one area or two; whether the merge-integrity/renumber guard is in scope (the
  charter names "allocation" and "conflicts", not "integrity"); where the
  cross-cutting "no committed checker" contract assertion lives; and whether the
  depth-2 `85-conflict-guards.sh` resolver is generalized in place or a recursive
  sibling area is added, are user decisions owned by the relevant children, not
  decided here.

## Children

| Local id | Title | Scope | Depends on | conflicts-with | Canonical reference |
| -------- | ----- | ----- | ---------- | -------------- | ------------------- |
| 0001-recursive-structure-guard | Recursive model, reference, and allocation guard | Author a committed, fixture-based guard pinning the recursive **model** and the **reference/allocation** contract that carries it, with a new committed fixture root (for example `tests/fixtures/recursive-structure/`) whose tree is at least **three levels deep** (`<NNNN>/<MMMM>/<MMMM>/`) and includes a node that both decomposes and carries its own phase artifacts (a **hybrid** node), a `.gitkeep`-only leaf, and duplicate `NNNN`/`MMMM` samples. Pin: the standard cycle applies uniformly at every node and any node may decompose to **arbitrary depth with no maximum**; fine-grained `tasks.md` entries are **not** nodes; the canonical reference grammar `^[0-9]{4}-[a-z0-9-]+(/[0-9]{4}-[a-z0-9-]+)*$` nests to arbitrary depth; each child directory is reserved with a `.gitkeep` at every level; per-level `MMMM` allocation is scoped to the **immediate** parent (greatest 4-digit prefix ever committed under that parent, plus one, never reused); and the duplicate findings `DUPLICATE-PREFIX` (top level) and `DUPLICATE-CHILD` (same-parent at any depth, naming the shared parent and local prefix at depth ≥ 3) are derived at every node. Optionally pin the cross-cutting "prompt behavior only — no committed executable checker" contract so no guard drifts into shipping a production checker. Evidence: `docs/workflow.md` "The recursive lifecycle model", "Where decomposition is authored and recorded", "Multiple work items", "Merge conflicts"/"Merge-integrity guard"; `docs/artifact-conventions.md` "Work item references", "Sequence allocation", "`manifest.md`"; `tests/checks/80-cycle-fixture.sh`; `tests/README.md`; `tests/mutation.sh`. Excludes readiness/status (`0002`), conflicts (`0003`), integrity/renumber (`0004`), and registration (`0005`). | — | tests/README.md, tests/mutation.sh | 0015-recursive-workflow-guards/0001-recursive-structure-guard |
| 0002-recursive-readiness-status-guard | Recursive readiness and status guard | Author a committed, fixture-based guard pinning recursive **readiness**, **derived state**, and **/status** rendering, with a new committed fixture root (for example `tests/fixtures/recursive-status/`) containing a decomposing node whose children have satisfied/unsatisfied dependencies at **more than one level**, a hybrid node, and a `.gitkeep`-only child. Pin: readiness is derived **live** from committed files at every level with no stored value; a dependency is satisfied by `ship.md` presence or an `approve` verdict even if unshipped, a **recalled** `ship.md` is unsatisfied, and a child in a cycle is never `ready`; dependencies are **sibling-only**; `/status` renders the tree **indented to arbitrary depth** with each node's `ready`/`blocked: <local ids>`, and each decomposing node's `<ready>/<total> ready` plus its phase distribution tally; and the **derived-state precedence** at depth — a node's own phase artifacts derive its phase **before** the container `manifest`, and the earliest `stale:`, the `reopened:`, and the unshipped open-challenge blocked overlay are evaluated first. Evidence: `docs/workflow.md` "Dependencies and readiness", "Derived state", "Status reporting"; `.opencode/agent/status.md`; `tests/checks/{10-readiness,20-lifecycle,80-cycle-fixture}.sh`; `tests/README.md`. Excludes the structure contract (`0001`), conflicts (`0003`), integrity/renumber (`0004`), and registration (`0005`). | — | tests/README.md, tests/mutation.sh | 0015-recursive-workflow-guards/0002-recursive-readiness-status-guard |
| 0003-recursive-conflicts-guard | Recursive declared-conflicts guard | Generalize and pin the declared-conflict **check** to arbitrary depth. Extend the depth-2 resolver and non-recursive event builder in `tests/checks/85-conflict-guards.sh` — whose `SiblingOrItemRef` regex caps at one `/` segment and whose event builder iterates only parent→child — to the recursive grammar `NNNN-slug(/MMMM-slug)*`, and add a committed fixture root (for example `tests/fixtures/recursive-conflicts/`) holding a depth-≥3 tree so the compared set recurses into a decomposing **child**'s own `Children` rows. Pin: the recursive `conflicts-with` target grammar and reference-vs-path discriminator; the sibling-first-then-root resolution precedence at every level; the own ∪ parent-cell union at every depth and the both-present-unequal `DRIFT-FACT` discrepancy; the pair predicate across levels (shared target, one-sided naming of a silent counterpart, and a shipped counterpart still resolving but excluded); and a malformed/unresolved target reported as `DANGLING-DEP`. Evidence: `docs/workflow.md` "Declared conflicts (`conflicts-with`)", "Declared-conflict check"; `docs/artifact-conventions.md` manifest `conflicts-with` bullet; `tests/checks/85-conflict-guards.sh`; `tests/fixtures/declared-conflicts/`; `tests/README.md`. Excludes the structure contract (`0001`), readiness/status (`0002`), integrity/renumber (`0004`), and registration (`0005`). | — | tests/README.md, tests/mutation.sh | 0015-recursive-workflow-guards/0003-recursive-conflicts-guard |
| 0004-recursive-integrity-guard | Recursive merge-integrity and renumber guard | Author a committed, fixture-based guard pinning the **merge-integrity** invariant set and the recursive **renumbering** procedure at every node, with a new committed fixture root (for example `tests/fixtures/recursive-integrity/`) containing a colliding **grandchild** (depth ≥ 3) and a decomposing node with a missing/unlisted child. Pin: every invariant is evaluated at **every node independently** — `DUPLICATE-PREFIX`, `DUPLICATE-CHILD`, `DANGLING-DEP`, `CYCLIC-DEP`, `MISSING-CHILD`, `UNLISTED-CHILD`, and `DRIFT-FACT` — and reported **non-fatally, never auto-repaired**, with a deliberate withdrawal report-only for `UNLISTED-CHILD`; and that the recursive renumber moves a **whole subtree** and rewrites `feature:`, `parent:`, the owning manifest's `Children` canonical references, the intermediate manifests on the changed path, and every `Depends on`/`conflicts-with` reference naming the old id, leaving no stale reference. Evidence: `docs/workflow.md` "Merge conflicts", "Merge-integrity guard", "Multiple work items"; `docs/artifact-conventions.md` "Renumbering after a parallel merge"; `.opencode/skill/merge-conflict/SKILL.md`; `tests/checks/{80-cycle-fixture,88-renumber-sweep}.sh`; `tests/README.md`. Excludes the structure contract (`0001`), readiness/status (`0002`), declared conflicts (`0003`), and registration (`0005`). | — | tests/README.md, tests/mutation.sh | 0015-recursive-workflow-guards/0004-recursive-integrity-guard |
| 0005-guard-registration-sweep | Guard registration, contract pin, and suite reconciliation | Reconcile the committed test documentation and self-check with the four new guards. Add each new agreement area to the `tests/README.md` Checks table and its mapping paragraph with its stable `AC27`+ token, and register each new fixture root with **one mutation per distinct rule** (norm ≤ 3 per area) in `tests/mutation.sh`, including adding the new roots to the staged-copy list. Pin the cross-cutting **"prompt behavior only — no committed executable checker"** contract of `docs/workflow.md` ("Merge-integrity guard", "Declared-conflict check") so no guard drifts into shipping a production checker. Run `bash tests/run.sh` and the mutation self-check and confirm the existing areas stay green. Evidence: `tests/README.md`; `tests/mutation.sh`; `tests/run.sh`; `tests/checks/{80-cycle-fixture,85-conflict-guards,87-backtrack-guards,88-renumber-sweep}.sh`. Excludes authoring the guards themselves (`0001`–`0004`). | 0001-recursive-structure-guard, 0002-recursive-readiness-status-guard, 0003-recursive-conflicts-guard, 0004-recursive-integrity-guard | tests/README.md, tests/mutation.sh | 0015-recursive-workflow-guards/0005-guard-registration-sweep |

## Sequencing

1. 0001-recursive-structure-guard
2. 0002-recursive-readiness-status-guard
3. 0003-recursive-conflicts-guard
4. 0004-recursive-integrity-guard
5. 0005-guard-registration-sweep

`0001-recursive-structure-guard`, `0002-recursive-readiness-status-guard`,
`0003-recursive-conflicts-guard`, and `0004-recursive-integrity-guard` author
disjoint check files and disjoint fixture roots and have no unmet prerequisite;
they may proceed in parallel and are ordered `0001`–`0004` here only to keep a
stable reading order. `0005-guard-registration-sweep` depends on all four because
it reconciles the documented Checks table, the mutation registry, and the
whole-suite run against the settled guard areas. The stored graph is acyclic:
`{0001, 0002, 0003, 0004}` → `0005`.

The four guards share the two append-only test surfaces `tests/README.md` and
`tests/mutation.sh` (each adds its own area row/paragraph and its own mutation
jobs), so the declared-conflict check will report `TEXTUAL-CONFLICT` pairs among
them. This is intentional — independent siblings appending to the same two test
registries — and is advisory only, changing no `Depends on` edge and no child's
readiness. Keeping each guard's registration contribution append-only (its own
table row, its own paragraph, its own mutation jobs) keeps the merges mechanical.

### Multi-roadmap sequence

This is **Roadmap 5**, the final stage. The sequence launched by
`work/0011-recursive-bootstrap/roadmap.md:125-149` is complete:

1. **Roadmap 1 — `0011-recursive-bootstrap` (shipped).** The minimal recursive
   facility: model, schema, writer, readiness/status.
2. **Roadmap 2 — `0012-roadmap-deprecation` (shipped).** Retire `/roadmap` and its
   agent; make the generic manifest the sole enumeration source.
3. **Roadmap 3 — `0013-simultaneous-work-recursion` (shipped).** Allocation,
   duplicate detection, declared conflicts, merge integrity, renumbering, and
   parallel plan publication under recursion.
4. **Roadmap 4 — `0014-agent-command-inventory-sweep` (shipped).** Sweep every
   agent, command, and skill prompt to the recursive model and reconcile the
   documented inventories and counts.
5. **Roadmap 5 — `0015-recursive-workflow-guards` (this).** Fixture-based guards
   pinning the recursive model, references, allocation, readiness, status, and
   conflicts.

Cross-roadmap ordering is **not** encoded as a dependency (dependencies are
sibling-only within a node); it is recorded here as prose. This is the last
roadmap the bootstrap sequence names; a further stage would be a fresh planning
invocation, not an extension of this node.

## Open issues

- **Single-feature check.** The initiative is genuinely multi-feature — one guard
  family per recursive concern (structure/references/allocation, readiness/status,
  conflicts, integrity/renumber) plus a registration/reconciliation sweep — so a
  decomposing node is the right vehicle rather than a standalone `/spec`. If a
  guard still proves too large at `/spec` (for example the readiness+status
  pairing), the sanctioned remedy is `/plan 0015-recursive-workflow-guards` to
  re-slice at the same level.
- **Re-homes a withdrawn child; no number reuse.** This is the scope of
  `0010-recursive-plan-cycle/0008-recursive-guards`, withdrawn on 2026-10-12 and
  preserved as a `.gitkeep`-only directory
  (`work/0010-recursive-plan-cycle/roadmap.md:204-209`). Its directory and spent
  local number `0008` are **not** reused, and `0010` remains a superseded
  container; this roadmap is a fresh top-level node.
- **No duplicate node.** Recon of `work/` found fourteen existing top-level items
  (`0001`–`0014`) before this node; the sequence's predecessor is
  `0014-agent-command-inventory-sweep`. The nearest shipped guard work is
  `0006/0004-conflict-guards`, `0005/0005-merge-integrity-guards`,
  `0007/0007-backtracking-guards`, and `0013`'s edits to `85`/`87`/`88`, but none
  pins a tree deeper than two levels or a recursive reference/allocation/status
  contract. Recorded so the choice of a new top-level node rather than a nested
  child is explicit.
- **Boundary with Roadmap 4 (surface sweep).** The agent/command/skill/inventory
  sweep is Roadmap 4. This roadmap touches only `tests/**`; it edits no
  `.opencode/**`, `docs/**`, `README.md`, or `AGENTS.md` surface, and it changes
  no swept prompt. The boundary is recorded so scope is not silently widened.
- **The authority docs are the pinned target, not the guarded artifact.** No child
  edits `docs/workflow.md` or `docs/artifact-conventions.md`; the guards read them.
  A guard that finds the authority itself wrong records a finding and recommends
  `/plan <parent-ref>` or the relevant reverse edge rather than editing it.
- **No shared edited surface beyond the two registries; declared conflicts are
  intentional.** Each guard owns a distinct `tests/checks/*.sh` and fixture root;
  the only shared surfaces are `tests/README.md` and `tests/mutation.sh`, which
  every row appends to. Those are declared in the `conflicts-with` column; the
  read-only check will report `TEXTUAL-CONFLICT` pairs among this node's children,
  which is intentional and advisory. Recorded so the non-empty declared-conflict
  set is deliberate rather than an oversight.
- **Cycle check.** The stored `Depends on` graph is acyclic by construction
  (`{0001,0002,0003,0004}`→`0005`); no `CYCLIC-DEP` is expected. Recorded because
  the planning step never stores a cycle.
- **Unresolved user decision — readiness/status granularity.** Whether readiness
  and `/status` are one guard area (`0002`) or two materially changes the child
  count and the fixture split; owned by `0002-recursive-readiness-status-guard`
  and re-sliceable via `/plan 0015-recursive-workflow-guards`.
- **Unresolved user decision — integrity/renumber scope.** The charter names
  "allocation" and "conflicts", not "integrity"; whether the merge-integrity
  invariant set and the recursive renumber belong to this roadmap (as `0004`) or
  fold into `0001`/`0003` is owned by the user. If dropped, the unpinned
  `MISSING-CHILD`/`UNLISTED-CHILD`/recursive-renumber gaps remain open.
- **Unresolved user decision — conflict-guard shape.** Whether the depth-2
  `85-conflict-guards.sh` resolver is generalized **in place** (mutating the
  shipped `AC23` area and its mutation jobs) or a recursive **sibling** area is
  added, and how much of the two-level `AC23` assertions survive, is owned by
  `0003-recursive-conflicts-guard`.
- **Unresolved user decision — contract-assertion home.** Whether the "no committed
  executable checker" contract is pinned in `0001`'s structure area, as its own
  tiny area, or in `0005`, is owned by `0001`/`0005`.
- **One create call, one parent.** This node was authored as a single top-level
  decomposing node (the next top-level `0015`), the final roadmap of the
  bootstrap sequence. Recorded so the staging is explicit rather than silently
  absent.
