---
feature: 0013-simultaneous-work-recursion/0001-recursive-allocation
phase: spec
status: final
created: 2026-10-13
updated: 2026-10-13
notes: "Nested manifest child of 0013-simultaneous-work-recursion; the parent manifest supplies the requirements (work/0013-simultaneous-work-recursion/manifest.md:87). Dependency is `—`, so the child is ready and no override is needed; the directory held only .gitkeep and there is no open finding, so this is ordinary forward progression. User resolved the four scoping forks this child owns: (1) duplicate detection is per-node independent, keeping both shipped codes — `DUPLICATE-PREFIX` stays the top-level `NNNN` collision and `DUPLICATE-CHILD` covers a same-parent `MMMM` collision at any depth, with offenders named by full canonical reference; (2) 0001 defines the recursive duplicate-detection rule in docs/workflow.md 'Multiple work items' only, leaving the whole '## Merge conflicts' section (taxonomy, merge-integrity guard invariant rows, enforcement points) and 'Renumbering after a parallel merge' to 0002-recursive-merge-integrity; (3) the change set is the two authority documents only — the status agent, the merge-conflict skill, and 'Lifecycle placement' are left to 0002 and Roadmap 4; (4) per-level allocation is already recursive (0011/0002), so the deliverable is duplicate detection, with 'Sequence allocation' touched only to cross-reference the rule."
parent: 0013-simultaneous-work-recursion
---

# Per-level sequence allocation and recursive duplicate detection

## Problem

The recursive model permits a node to decompose into children at any depth and,
since `0011-recursive-bootstrap`, allocates each level's local `MMMM` per its
immediate parent (`docs/artifact-conventions.md:668-687`). But the **simultaneous
work** contract that detects two branches allocating the same number is still
stated for a two-level tree. The authoritative sentence in `docs/workflow.md`
"Multiple work items" says to "scan the top-level `work/` directories — and each
decomposing parent's child directories — for duplicate 4-digit prefixes"
(`docs/workflow.md:1379-1388`); the merge-conflict skill restates it as
"per-parent roadmap child numbers" within "each roadmap parent"
(`.opencode/skill/merge-conflict/SKILL.md:69-75`); and the status agent's
duplicate step already scans "any two child directories ... at any depth"
(`.opencode/agent/status.md:142-147`) while its finding bullets describe
`DUPLICATE-PREFIX`/`DUPLICATE-CHILD` generically (`:225-228`). The result is a
split contract: the surfaces disagree about whether the rule reaches depth three
or deeper, and **no surface states how a collision at depth ≥ 3 is named or
attributed**.

Two audiences pay. **Framework maintainers** who run independent items in
parallel at a nested level have no authoritative rule telling them whether two
colliding grandchildren are a duplicate, which shipped code names it, or how the
offenders are cited — so a merge is adjudicated by whichever surface a reviewer
happens to read. **Adopters** inherit a workflow whose model promises arbitrary
nesting while its simultaneous-work contract describes only the top level plus
one child layer. The duplicate-detection rule must be stated once for a tree of
arbitrary depth, fixing the code mapping, the per-node scan model, and the
depth-≥ 3 naming — **before** `0002-recursive-merge-integrity` can generalize the
guard that consumes it.

## Goals

- Generalize the **duplicate-detection rule** in `docs/workflow.md` "Multiple
  work items" so it applies at every node of a recursive tree, not only the top
  level plus one child layer.
- Fix the **per-node scan model**: each decomposing node at any depth is checked
  against its own immediate children, independently; the top level is checked
  against the top-level items.
- Fix the **code mapping** at every depth: `DUPLICATE-PREFIX` names a collision
  of two top-level `NNNN` prefixes, and `DUPLICATE-CHILD` names a collision of
  two same-parent `MMMM` prefixes at any depth.
- Define how a **depth ≥ 3 collision is derived and named**: when two
  grandchildren collide, both offenders are named by their full canonical
  reference and the shared level (their parent and shared local prefix) is named
  in the detail.
- State the rule **once** in the "Multiple work items" authority and
  cross-reference it from `docs/artifact-conventions.md` "Sequence allocation",
  so no surface defines a competing duplicate rule.
- Reuse the **shipped finding vocabulary** (`DUPLICATE-PREFIX`/`DUPLICATE-CHILD`,
  class `(c)`, the finding-line grammar) and introduce no new code, class, or
  grammar.
- Keep the committed suite green and every documented inventory count unchanged,
  and edit only the two authority documents.
- Preserve backward compatibility: existing two-level statements and every
  committed `work/` item remain valid with no migration, no allocation change,
  and no renumbering-behavior change.

## Non-goals

- The **merge-integrity guard** — its invariant rows, its class `(c)` taxonomy
  wording, its two enforcement points (`/status` and the `/ship` post-merge
  integrity pass), and its "Lifecycle placement" and "Relationship to
  renumbering" text — owned by `0002-recursive-merge-integrity`.
- The **renumber procedure** ("Renumbering after a parallel merge", the
  detect/choose/renumber/update/record steps and their recursive generalization)
  — owned by `0002-recursive-merge-integrity`.
- `conflicts-with` declared targets at every level and the declared-conflict
  check — owned by `0003-recursive-conflicts`.
- Parallel plan publication and the `/build` plan gate — owned by
  `0004-parallel-publication`.
- The **agent/command/skill surface sweep** — including the `status` agent's
  duplicate step and finding bullets, the `merge-conflict` skill's restatement,
  and the `merge-conflict` skill's remaining "roadmap parent" vocabulary —
  deferred to Roadmap 4, except where `0002` owns a guard/enforcement surface.
- Committed fixtures, agreement areas, or mutation coverage pinning the
  recursive duplicate rule — a successor roadmap (Roadmap 5); the committed
  suite stays green as a constraint, not a deliverable.
- Changing the **allocation contract** itself: per-level `MMMM` allocation
  already nests to arbitrary depth and stays as shipped.
- A new runtime dependency, service, network access, or toolchain.
- A second state model, reference grammar, conflict taxonomy, finding code,
  class, or finding/severity vocabulary; a new dependency edge; or a change to
  `Depends on`/readiness.
- Any change to the shipped decisions or artifacts of earlier shipped work,
  including any rewrite of a shipped item's files or `ship.md` signal.

## Users and stories

- **As a** framework maintainer running independent items in parallel at a
  nested level, **I want** one authoritative rule that says what a duplicate
  sequence number is at any depth and which code names it, **so that** a
  collision introduced by a parallel merge is adjudicated the same way at depth
  three as at the top level.
- **As a** reviewer reading a status or integrity report, **I want** a
  depth-≥ 3 collision named by the full canonical references of both offenders
  and their shared parent/prefix, **so that** I can locate the colliding
  directories without inferring which `MMMM` is meant.
- **As an** adopter, **I want** the existing two-level duplicate wording and my
  committed `work/` tree to stay valid and the shipped codes and grammar to be
  reused, **so that** adopting the recursive rule requires no migration and no
  relearning of the finding vocabulary.

## Acceptance criteria

1. **AC1 — Rule reaches arbitrary depth.** Given `docs/workflow.md` "Multiple
   work items", when its duplicate-sequence rule is read, then it states that
   duplicate `4`-digit prefixes are checked at **every** node of a recursive
   tree — not only the top level plus one child layer — and a node at depth ≥ 3
   is covered exactly as a shallower one.

2. **AC2 — Per-node scan model.** Given the rule, when the scan is described,
   then each decomposing node at any depth is checked against **its own
   immediate children** independently, and the top level is checked against the
   top-level items; no node's check depends on another's, and the rule names the
   tree position (top level vs. same-parent siblings) that each check covers.

3. **AC3 — Code mapping at every depth.** Given the two shipped codes, when
   their meaning is read, then `DUPLICATE-PREFIX` names a collision of two
   **top-level** `NNNN` prefixes and `DUPLICATE-CHILD` names a collision of two
   **same-parent** `MMMM` prefixes at any depth; a top-level collision is never
   reported as `DUPLICATE-CHILD` and a deeper collision is never reported as
   `DUPLICATE-PREFIX`.

4. **AC4 — Depth ≥ 3 derived and named.** Given two sibling directories whose
   local `MMMM` prefixes are equal under a parent at depth ≥ 3 (for example two
   grandchildren, `.../MMMM-parent/<same-MMMM>-a` and
   `.../MMMM-parent/<same-MMMM>-b`), when the collision is named, then the rule
   requires both offenders to be identified by their **full canonical
   reference** and the **shared parent and shared local prefix** to be named,
   so the finding is unambiguous at any depth.

5. **AC5 — Shipped vocabulary reused.** Given the finding the rule produces,
   when its form is read, then it uses the shipped `DUPLICATE-PREFIX` /
   `DUPLICATE-CHILD` codes, class `(c)`, and the shipped finding-line grammar
   (offenders named by canonical reference), and the rule introduces **no** new
   code, class, grammar, or severity vocabulary.

6. **AC6 — Single authority, no competing rule.** Given the two authority
   documents, when the duplicate rule is read, then it is stated once in
   `docs/workflow.md` "Multiple work items", `docs/artifact-conventions.md`
   "Sequence allocation" cross-references that rule (rather than restating or
   contradicting it), and neither document defines a second duplicate-detection
   rule.

7. **AC7 — Allocation unchanged.** Given `docs/artifact-conventions.md`
   "Sequence allocation", when its per-level `MMMM` contract is read, then it
   remains the shipped recursive rule (greatest 4-digit prefix ever committed
   under `work/<parent-ref>/` plus one, never reused within that parent), and
   this item changes no allocation behavior.

8. **AC8 — Scope and boundary.** Given the change set, when its scope is
   inspected, then it edits only `docs/workflow.md` and
   `docs/artifact-conventions.md`; the `## Merge conflicts` section (taxonomy,
   merge-integrity guard invariant rows, enforcement points), "Renumbering after
   a parallel merge", the `conflicts-with` grammar/check, plan publication, the
   `status` agent, the `merge-conflict` skill, and every fixture are untouched,
   and no new command, agent, or skill is introduced.

9. **AC9 — Suite stays green and inventory unchanged.** Given the repository
   after the change, when the configured test command (`bash tests/run.sh`)
   runs, then it passes; no documented inventory count changes
   (`tests/checks/40-inventory.sh` stays green), and no shipped item's files or
   `ship.md` signal are modified.

10. **AC10 — Backward compatibility.** Given the repository after the change,
    when a one-segment standalone item or an existing two-level decomposing
    parent/child is read, then it remains valid under the recursive rule with no
    forced migration, no spent-number change, and no change to `Depends on`,
    readiness, or the renumber procedure.

## Edge cases

- **Grandchild collision (depth 3).** Two children of a depth-two parent share
  an `MMMM` prefix; the collision is a `DUPLICATE-CHILD` and both full canonical
  references are named (AC4).
- **Deeper collision (depth ≥ 4).** The rule is identical at every depth; no
  depth has special behavior and no new code is introduced (AC1, AC4).
- **Top-level collision.** Two top-level items share an `NNNN` prefix; it is a
  `DUPLICATE-PREFIX`, never a `DUPLICATE-CHILD` (AC3).
- **Same local id text under different parents.** Two nodes whose trailing
  `MMMM-slug` is identical but whose parents differ are **not** a duplicate,
  because identity is the full canonical path, not the trailing segment.
- **Pure container vs. hybrid node.** A parent that has no phase artifacts of
  its own and one that carries its own artifacts are both checked against their
  immediate children identically.
- **Parent with zero or one child.** No same-parent pair exists, so no collision
  is possible; the check is a no-op and does not error.
- **Already-shipped offender.** Detection is report-only and does not depend on
  shipped state; the rule changes no readiness, blocks no phase, and auto-repairs
  nothing (the guard's non-fatal, report-only contract is `0002`'s).
- **Empty `work/` tree.** With no nodes there are no pairs; the rule yields no
  finding and does not error.
- **Concurrency.** The rule reads only committed `work/` state and is local and
  report-only; it takes no lock and modifies no file.

## Open questions

- [x] **Duplicate-detection scope and code mapping** — resolved (user): per-node
  independent, keeping both shipped codes — `DUPLICATE-PREFIX` = top-level
  `NNNN`, `DUPLICATE-CHILD` = same-parent `MMMM` at any depth, offenders named by
  full canonical reference.
- [x] **0001 / 0002 boundary** — resolved (user): 0001 defines the recursive
  duplicate rule in `docs/workflow.md` "Multiple work items" only; the
  `## Merge conflicts` section (taxonomy, guard invariant rows, enforcement) and
  "Renumbering after a parallel merge" are entirely `0002`'s.
- [x] **Non-documentation surfaces** — resolved (user): the change set is the two
  authority documents only; the `status` agent, the `merge-conflict` skill, and
  "Lifecycle placement" are left to `0002` and Roadmap 4.
- [x] **Allocation scope** — resolved (user): per-level allocation is already
  recursive; the deliverable is duplicate detection, with "Sequence allocation"
  touched only to cross-reference the rule.
- [ ] **Deferred — `conflicts-with` targets at arbitrary depth.** The existing
  cross-level declared-conflict question is `0003-recursive-conflicts`'s concern.
  — owner: `0003-recursive-conflicts`, needed by: `0003` `/spec`.
- [ ] **Deferred — parallel plan-publication branch naming.** Whether the
  `plan/<ref>` flattening is replaced or the collision is detected and refused is
  `0004-parallel-publication`'s concern. — owner: `0004-parallel-publication`,
  needed by: `0004` `/spec`.
- [ ] **Deferred — the broad agent/command/skill surface sweep.** Reconciling the
  `status` agent's and `merge-conflict` skill's restatements (and the skill's
  remaining "roadmap parent" vocabulary) is Roadmap 4's concern, except where
  `0002` owns a guard/enforcement surface. — owner: Roadmap 4, needed by:
  Roadmap 4 `/spec`.

## Dependencies and constraints

- **Ready.** The parent manifest lists this child as `Depends on: —`
  (`work/0013-simultaneous-work-recursion/manifest.md:87`), so it is the
  foundation the merge-integrity child consumes and no override is needed. The
  child directory held only `.gitkeep` and there is no open finding, so this is
  ordinary forward progression.
- **Consumes the shipped schema and allocation.** The recursive reference
  grammar, per-level `MMMM` allocation, and the `.gitkeep` reservation are fixed
  by `0011-recursive-bootstrap`
  (`work/0011-recursive-bootstrap/0002-recursive-schema/spec.md`, AC1–AC3, AC8);
  this item states the duplicate-detection rule those references imply. It
  defines no second reference grammar or allocation rule.
- **Deliverable surfaces.** Per the child scope, the rule is authored in
  `docs/workflow.md` "Multiple work items" and cross-referenced from
  `docs/artifact-conventions.md` "Sequence allocation"
  (`work/0013-simultaneous-work-recursion/manifest.md:87`). Because the
  deliverable is the framework's own documents, the acceptance criteria name the
  surfaces that must carry the rule; they specify required content, not
  implementation choices.
- **Downstream consumers (explicit boundary).** `0002-recursive-merge-integrity`
  generalizes the merge-conflict taxonomy's class `(c)`, the merge-integrity
  guard's invariant rows for `DUPLICATE-PREFIX`/`DUPLICATE-CHILD`, its two
  enforcement points, and the renumber procedure; `0003-recursive-conflicts`
  owns declared conflicts; `0004-parallel-publication` owns the plan gate;
  Roadmap 4 owns the remaining agent/command/skill restatements; Roadmap 5 owns
  committed fixtures. They are named so the seams are visible; this item writes
  only the two documents.
- **Reuse, do not fork.** The `DUPLICATE-PREFIX`/`DUPLICATE-CHILD` codes, the
  class `(c)` label, the finding-line grammar, the class `(a)`–`(d)` taxonomy,
  and the readiness/`Depends on` contract are reused unchanged. This item defines
  no second state model, finding vocabulary, or dependency edge.
- **Single-source guards must stay green.** `tests/checks/40-inventory.sh` pins
  the documented inventory counts and tables; `tests/checks/20-lifecycle.sh`,
  `tests/checks/10-readiness.sh`, `tests/checks/80-cycle-fixture.sh`,
  `tests/checks/85-conflict-guards.sh`, `tests/checks/87-backtrack-guards.sh`,
  and `tests/checks/96-signature-sweep.sh` pin the derived-state routing, the
  readiness marker, the cycle rule, the declaration model, the backtrack
  labels, and the command signatures. This item restates none of their pinned
  literals and keeps them green.
- **The suite never reads live `work/**`.** The committed suite is read-only and
  fresh-clone-clean (`tests/README.md:30-31`); committed recursive-duplicate
  guards are deferred to a successor roadmap, so this item adds no test file.
- **Backward compatibility.** A one-segment standalone item and every existing
  committed `work/` item remain valid; no migration, rename, spent-number change,
  or `ship.md` change occurs
  (`work/0013-simultaneous-work-recursion/manifest.md:72-74`).
- **Assumption — the rule is one feature.** Fixing the per-node scan model, the
  code mapping, the depth-≥ 3 naming, and the single-authority cross-reference is
  one coherent contract change, specifiable and reviewable on its own; if it
  proves too large at `/plan`, the manifest's sanctioned remedy is to revise the
  decomposition with `/plan 0013-simultaneous-work-recursion` and add siblings at
  the same level, not to nest.
- **Framework-internal change only.** Documents and prompts; no runtime
  dependency, service, network access, or new toolchain. No file under another
  phase is edited.
