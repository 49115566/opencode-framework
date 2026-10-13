---
feature: 0013-simultaneous-work-recursion/0002-recursive-merge-integrity
phase: spec
status: final
created: 2026-10-13
updated: 2026-10-13
notes: "Nested manifest child of 0013-simultaneous-work-recursion; the parent manifest supplies the requirements (work/0013-simultaneous-work-recursion/manifest.md:88). Dependency 0001-recursive-allocation is satisfied — its ship.md is present with no `reopened:` marker — so the child is ready and no override is needed; the directory held only .gitkeep and there is no open finding, so this is ordinary forward progression. User resolved the four scoping forks this child owns: (1) change set is docs/workflow.md + docs/artifact-conventions.md + .opencode/skill/merge-conflict/SKILL.md, leaving the agent/command restatements and the status agent to Roadmap 4; (2) renumbering a decomposing node rewrites its whole subtree's references in the same change; (3) the cross-branch prefix comparison descends every node at every depth; (4) the guard/taxonomy generalization adds a guard-wide 'evaluated at every node' scope sentence and makes class (c) and the two duplicate rows explicit, leaving the position-generic graph-fault rows as-is. 0001 already generalized the duplicate-detection rule in docs/workflow.md 'Multiple work items', so 0002 references it and does not restate it."
parent: 0013-simultaneous-work-recursion
---

# Merge integrity and renumbering for recursive trees

## Problem

The recursive model lets a node decompose into children at **any** depth, and
`0013-simultaneous-work-recursion/0001-recursive-allocation` (shipped) generalized
the duplicate-detection *rule* — `DUPLICATE-PREFIX` for a top-level `NNNN`
collision, `DUPLICATE-CHILD` for a same-parent `MMMM` collision at any depth,
offenders named by full canonical reference
(`docs/workflow.md:1379-1401`). But the surfaces that **consume** that rule at
merge time are still capped at two levels, so a deep collision is stated in one
place and contradicted in another:

- The class `(c)` taxonomy's affected-surface cell names only
  `Top-level work/<NNNN-slug>, per-parent work/<NNNN-slug>/<MMMM-slug>`
  (`docs/workflow.md:1424`) — no grandchild path.
- The post-merge integrity pass is described as re-scanning "top-level and
  per-parent `work/` directories" (`docs/workflow.md:1434-1435`), and the
  merge-integrity guard's duplicate row says "no two children of one decomposing
  parent" (`docs/workflow.md:1484-1485`) without a tree-wide scope sentence.
- The normative renumber procedure's Detect step and its update step are phrased
  for one level — "a nested child's `parent:` value; the manifest `Children`
  table `Canonical reference` cells" (`docs/artifact-conventions.md:701-714`) —
  and never say what happens when the colliding node is itself a decomposing node
  whose descendants' full canonical references all move.
- The `merge-conflict` skill restates the two-level scan ("Within each roadmap
  parent …", `.opencode/skill/merge-conflict/SKILL.md:73-75`), the cross-branch
  comparison ("and per-parent …", `:86-92`), the post-merge pass
  ("top-level and per-parent `work/` directories", `:284`), and the renumber steps
  (`:359-407`) — all two-level.

Two audiences pay. **Framework maintainers** running independent items in
parallel at a nested level get a split contract: the rule says "every node," the
guard, taxonomy, renumber procedure, and skill say "top level plus one child
layer," and a colliding grandchild has no stated handling or naming in the merge
path. **Adopters** inherit a workflow whose model promises arbitrary nesting while
its simultaneous-work merge contract reaches only two levels, so a real merge is
adjudicated by whichever surface a maintainer happens to read. The merge-integrity
and renumbering contract must be stated for a tree of arbitrary depth — reusing
the duplicate rule `0001` already fixed — **before** merge safety can be trusted
at every level.

## Goals

- Generalize the **class `(c)` duplicate-sequence taxonomy** so its affected
  surface reaches a same-parent `MMMM` collision at any node of the tree, not only
  the top level plus one child layer.
- State that the **merge-integrity guard's invariant set is evaluated at every
  node** of the recursive tree — the top level and each decomposing node's own
  immediate children, independently — and make the `DUPLICATE-PREFIX` /
  `DUPLICATE-CHILD` rows explicitly recursive and consistent with the rule
  `0001` stated once in "Multiple work items".
- Generalize both **enforcement points** — the `/status` read-only window and the
  `/ship` post-merge integrity pass — so the full invariant set holds at every
  node, remaining offline, local, read-only, non-fatal, and report-only.
- Generalize the normative **renumber procedure** so its detect/choose/renumber/
  update/record steps apply to a colliding node at any depth, and when the chosen
  node is itself a decomposing node, the **whole subtree's** references are
  rewritten in the same change so no stale canonical reference remains.
- Generalize the **`merge-conflict` skill's** guard and enforcement passages — the
  pre-flight duplicate scan, the cross-branch prefix comparison, the post-merge
  integrity pass, and the `work/` artifact reconcile's renumber steps — to the same
  arbitrary-depth contract.
- Keep each rule **stated once** in its authority (the duplicate rule in
  `docs/workflow.md` "Multiple work items", the invariant set in
  `docs/workflow.md` "Merge-integrity guard", the renumber steps in
  `docs/artifact-conventions.md` "Renumbering after a parallel merge") and
  cross-reference the rest, so no second rule is defined.
- Reuse the **shipped vocabulary** (the seven codes, the `(a)`–`(d)` classes, the
  finding-line grammar) and introduce no new code, class, grammar, or severity
  vocabulary.
- Keep the committed suite green with every documented inventory count unchanged,
  and edit only the three named surfaces.
- Preserve backward compatibility: existing one-segment and two-level items and
  every committed `work/` item remain valid with no migration, rename, or
  spent-number change.

## Non-goals

- **The duplicate-detection rule itself** — stated once by
  `0001-recursive-allocation` in `docs/workflow.md` "Multiple work items"
  (`:1379-1401`). This item references it and does not restate, weaken, or fork it.
- **Per-level sequence allocation** — `docs/artifact-conventions.md` "Sequence
  allocation" is already recursive and stays as shipped.
- **Declared conflicts (`conflicts-with`) at every level** and the read-only
  declared-conflict check — owned by `0003-recursive-conflicts`.
- **Parallel plan publication and the `/build` plan gate** — owned by
  `0004-parallel-publication`.
- **The broad agent/command/skill surface sweep** — the two-level summaries in
  `.opencode/agent/shipper.md:200,365-370`, `.opencode/command/ship.md:41`, and
  `.opencode/command/status.md:60`, plus the `status` agent's legacy `roadmap.md`
  vocabulary (`.opencode/agent/status.md`) — deferred to Roadmap 4. The `status`
  agent already scans duplicates "within each decomposing node at any depth"
  (`.opencode/agent/status.md:142-147`), so it needs no change here.
- **Committed fixtures, agreement areas, or mutation coverage** pinning the
  recursive merge-integrity contract — a successor roadmap (Roadmap 5); the
  committed suite stays green as a constraint, not a deliverable.
- **A new artifact, state model, dependency edge, finding code, class, or
  severity vocabulary**, or any change to `Depends on`/readiness.
- **The merge-time *meanings* of the shipped codes** and the shipped finding
  grammar; and the plan-publication revision flow and backtracking model, which
  are untouched.
- **Any change to a shipped item's files or `ship.md` signal**, including the
  shipped `0001` child and earlier `0005`/`0006` merge-conflict work.

## Users and stories

- **As a** framework maintainer running independent items in parallel in a deep
  recursive tree, **I want** the merge-integrity guard, the class `(c)`
  taxonomy, and the renumber procedure to apply at every node, **so that** a
  colliding grandchild introduced by a parallel merge is detected, named, and
  resolved the same way a top-level collision is.
- **As a** maintainer resolving a collision on a decomposing node, **I want** the
  renumber step to rewrite the whole subtree's references together, **so that**
  after the move no artifact, manifest cell, or prose still points at the old
  canonical reference.
- **As a** maintainer reading the `merge-conflict` skill, **I want** its scan,
  cross-branch comparison, post-merge pass, and renumber steps to state the same
  arbitrary-depth contract as the authority, **so that** the operational view does
  not contradict the source of truth.
- **As an** adopter, **I want** my existing one- and two-level items and the
  shipped codes and grammar to stay valid, **so that** the generalization requires
  no migration and no relearning of the finding vocabulary.

## Acceptance criteria

1. **AC1 — Class `(c)` affected surface reaches arbitrary depth.** Given
   `docs/workflow.md` "Conflict taxonomy", when the class `(c)` row is read, then
   both its conflict description and its affected-surface cell admit a same-parent
   `MMMM` collision at any node of the tree — including a grandchild-or-deeper
   path — and are not capped at two segments or at "top-level, per-parent",
   consistent with the rule in "Multiple work items".

2. **AC2 — Post-merge pass at every node.** Given `docs/workflow.md` "Lifecycle
   placement", when the post-merge integrity pass is described, then it re-scans
   **every** node's own immediate children for duplicate 4-digit prefixes at every
   depth (not only "top-level and per-parent"), re-checks every `Depends on`
   against its own node's `Children` table for dangling, missing, unlisted, or
   cyclic references, and re-runs the repository's configured test command.

3. **AC3 — Guard scope: invariant set evaluated at every node.** Given
   `docs/workflow.md` "Merge-integrity guard", when its scope is read, then it
   states that the invariant set is evaluated at **every node** of the recursive
   tree — the top level against the top-level items and each decomposing node at
   any depth against its own immediate children, independently — with no node's
   check depending on another's.

4. **AC4 — Guard duplicate rows explicit and single-sourced.** Given the
   merge-integrity guard's invariant table, when its `DUPLICATE-PREFIX` and
   `DUPLICATE-CHILD` rows are read, then `DUPLICATE-PREFIX` names two top-level
   `NNNN` prefixes and `DUPLICATE-CHILD` names two same-parent `MMMM` prefixes at
   any depth; the rows agree with the rule stated once in "Multiple work items"
   and neither restates nor contradicts a competing duplicate rule. The
   position-generic graph-fault rows (`DANGLING-DEP`, `CYCLIC-DEP`,
   `MISSING-CHILD`, `UNLISTED-CHILD`, `DRIFT-FACT`) may keep their existing
   wording.

5. **AC5 — Both enforcement points hold at every node.** Given the two
   prompt-only enforcement points, when each is read, then the `/status` read-only
   window and the `/ship` post-merge integrity pass both evaluate the full
   invariant set at every node, and neither defines a separate guard. Their
   definitions remain canonical in this section; the agent and command
   implementation surfaces that summarize them are out of scope (AC13).

6. **AC6 — Renumber detect at any depth.** Given `docs/artifact-conventions.md`
   "Renumbering after a parallel merge", when its Detect step is read, then it
   detects a collision between two top-level `NNNN` references and between any two
   same-parent `MMMM` references at any node of the tree, using the rule stated
   once in `docs/workflow.md` "Multiple work items", and requires each offender to
   be identified by canonical reference (with the depth-≥ 3 shared-parent/
   shared-prefix naming `0001` fixed).

7. **AC7 — Renumber rewrites the whole affected subtree.** Given a collision
   whose chosen node is itself a decomposing node with descendants, when the
   procedure's update step is read, then it requires every affected reference to
   be rewritten **in the same change**: the directory name; the node's `feature:`
   frontmatter value; the owning manifest's `Children` row `Local id` and
   `Canonical reference` cells; every descendant artifact's `feature:` value (the
   full canonical reference); every descendant's `parent:` value on the changed
   path; every intermediate manifest's `Children` `Canonical reference` cell;
   `ship.md` and PR/handoff paths; and any prose naming the old reference.

8. **AC8 — Renumber at any depth, one rule.** Given a collision at depth three or
   deeper, when the procedure runs, then the same detect/choose/renumber/update/
   record steps apply as at the top level; the steps are stated once in
   "Renumbering after a parallel merge" and referenced by `docs/workflow.md`
   "Relationship to renumbering"; no second renumbering rule is defined.

9. **AC9 — The `merge-conflict` skill's guard/enforcement passages generalize.**
   Given `.opencode/skill/merge-conflict/SKILL.md`, when its recursive-relevant
   passages are read, then the pre-flight duplicate scan scans every node at every
   depth; the cross-branch prefix comparison descends every node at every depth
   (comparing each node's children against the corresponding `origin/<default>`
   path); the post-merge integrity pass re-scans every node; and the `work/`
   artifact reconcile's detect/choose/move/update steps apply the AC7 whole-subtree
   sweep. The skill continues to name `docs/workflow.md` as the source of truth and
   defines no second rule.

10. **AC10 — Single authority, no competing rule.** Given the three surfaces, when
    the duplicate-detection rule, the guard's invariant set, and the renumber
    steps are read, then each is stated once in its authority — the duplicate rule
    in `docs/workflow.md` "Multiple work items", the invariant set in
    `docs/workflow.md` "Merge-integrity guard", the renumber steps in
    `docs/artifact-conventions.md` "Renumbering after a parallel merge" — and the
    other surfaces cross-reference that authority rather than restating or
    contradicting it.

11. **AC11 — Shipped vocabulary reused.** Given the findings the generalized
    guard and procedure produce, when their form is read, then they use the
    shipped `DUPLICATE-PREFIX`, `DUPLICATE-CHILD`, `DANGLING-DEP`, `CYCLIC-DEP`,
    `MISSING-CHILD`, `UNLISTED-CHILD`, and `DRIFT-FACT` codes, the class `(a)`–`(d)`
    labels, and the shipped finding-line grammar; no new code, class, grammar, or
    severity vocabulary is introduced.

12. **AC12 — Report-only, non-fatal, offline/local, no-op on empty.** Given the
    guard and the procedure, when they run, then they modify no file, never
    auto-repair a violation, never silently drop or truncate a finding, and take no
    lock; the `/status` window performs no fetch, remote read, or dry-run merge; and
    an empty `work/` tree or an already-up-to-date branch with no collision reports
    no findings and does not error.

13. **AC13 — Scope: three surfaces only.** Given the change set, when it is
    inspected, then it edits only `docs/workflow.md`, `docs/artifact-conventions.md`,
    and `.opencode/skill/merge-conflict/SKILL.md`; it does not touch
    `.opencode/agent/status.md`, `.opencode/agent/shipper.md`,
    `.opencode/command/status.md`, `.opencode/command/ship.md`, the manifest
    template's `conflicts-with` bullet, the declared-conflict check, plan
    publication, or any fixture; and it introduces no new command, agent, skill, or
    fixture area.

14. **AC14 — Suite green and inventory unchanged.** Given the repository after the
    change, when the configured test command (`bash tests/run.sh`) runs, then it
    passes and no documented inventory count changes (`tests/checks/40-inventory.sh`
    stays green); the suite remains read-only and never reads live `work/**`, and no
    shipped item's files or `ship.md` signal are modified.

15. **AC15 — Backward compatibility.** Given the repository after the change, when
    a one-segment standalone item, an existing two-level decomposing parent/child,
    or any committed `work/` item is read, then it remains valid with no forced
    migration, no rename, no spent-number change, and no change to `Depends on`,
    readiness, or the merge-time meanings of the shipped codes and grammar.

## Edge cases

- **Collision at depth three and deeper.** The rule is identical at every depth;
  no depth has special behavior, and the whole-subtree sweep (AC7) applies when the
  chosen node has descendants (AC6, AC7).
- **The chosen node itself decomposes.** A grandchild-or-deeper node that is a
  pure container or a hybrid renumbers by the same steps; its descendants' full
  canonical references and intermediate manifest cells all move in the same change.
- **Same local id text under different parents.** Two nodes whose trailing
  `MMMM-slug` is identical but whose parents differ are **not** a duplicate,
  because identity is the full canonical path (AC6).
- **Top-level vs same-parent collision.** A top-level collision is always
  `DUPLICATE-PREFIX`; a same-parent collision at any depth is always
  `DUPLICATE-CHILD`; neither is reported as the other (AC4, AC6).
- **`.gitkeep`-only and pure-container/hybrid nodes.** A child directory holding
  only `.gitkeep` is scanned; a pure container and a hybrid node (with its own
  artifacts) are both checked against their immediate children identically.
- **Parent with zero or one child.** No same-parent pair exists, so no collision
  is possible; the scan is a no-op and does not error.
- **Cross-branch collision with no counterpart.** A prefix present on only one
  branch is not a collision; the deep comparison reports nothing.
- **Legacy alias.** A nested `roadmap.md` carrying `phase: roadmap` is treated the
  same as a `manifest.md` for scanning and renumbering.
- **Already-shipped offender.** Detection is report-only and independent of
  shipped state; the renumber "choose one" step still uses the not-approved/
  not-shipped then later-commit-time rule, and shipped state excludes an item from
  being renumbered.
- **Empty `work/` tree / up-to-date branch.** No pairs and no changed plan
  artifacts yield no findings and no error; the reconcile is a no-op.
- **Concurrency.** The guard is read-only and takes no lock; two concurrent
  pre-flights or status reports do not interfere, and neither writes a file.

## Open questions

- [x] **Change-set surfaces** — resolved (user): edit `docs/workflow.md`,
  `docs/artifact-conventions.md`, and `.opencode/skill/merge-conflict/SKILL.md`;
  leave the agent/command two-level summaries and the status agent to Roadmap 4.
- [x] **Renumbering a decomposing node** — resolved (user): rewrite the whole
  affected subtree's references in the same change (AC7).
- [x] **Cross-branch comparison depth** — resolved (user): descend every node at
  every depth (AC9).
- [x] **Guard/taxonomy scope** — resolved (user): add a guard-wide
  "evaluated at every node" scope sentence and make class `(c)` and the two
  duplicate rows explicit; leave the position-generic graph-fault rows as-is
  (AC1, AC3, AC4).
- [ ] **Deferred — agent/command/skill surface sweep.** The two-level summaries in
  `.opencode/agent/shipper.md`, `.opencode/command/ship.md`,
  `.opencode/command/status.md`, and the `status` agent's legacy `roadmap.md`
  vocabulary are Roadmap 4's concern. — owner: Roadmap 4, needed by: Roadmap 4
  `/spec`.
- [ ] **Deferred — committed recursive merge-integrity fixtures.** Fixture-based
  committed guards pinning the recursive contract are Roadmap 5. — owner: Roadmap
  5, needed by: Roadmap 5 `/spec`.
- [ ] **Deferred — `conflicts-with` targets at arbitrary depth.** Owned by
  `0003-recursive-conflicts`. — owner: `0003-recursive-conflicts`, needed by:
  `0003` `/build`.
- [ ] **Deferred — parallel plan-publication branch naming.** Owned by
  `0004-parallel-publication`. — owner: `0004-parallel-publication`, needed by:
  `0004` `/build`.

## Dependencies and constraints

- **Ready.** The parent manifest lists this child's only dependency as
  `0001-recursive-allocation` (`work/0013-simultaneous-work-recursion/manifest.md:88`),
  whose `ship.md` is present with no `reopened:` marker, so the dependency is
  satisfied and no override is needed. The child directory held only `.gitkeep` and
  there is no open finding, so this is ordinary forward progression.
- **Consumes the shipped duplicate rule; does not restate it.** `0001` fixed the
  duplicate-detection rule (code mapping, per-node scan model, depth-≥ 3 naming) in
  `docs/workflow.md` "Multiple work items" and its AC6 requires a single authority
  (`work/0013-simultaneous-work-recursion/0001-recursive-allocation/spec.md`, AC3–
  AC6, AC8). This item's guard, taxonomy, and renumber text reference that rule.
- **Composes with the shipped merge contract.** The merge-conflict taxonomy,
  resolution principles, verification, ownership, and renumber procedure were
  settled by `0005-merge-conflict-workflow`; this item extends their reach to
  arbitrary depth and defines no second taxonomy, resolution, or renumber rule.
- **Deliverable surfaces.** Per the child scope and the user's decision, the
  contract is authored in `docs/workflow.md` ("Conflict taxonomy", "Lifecycle
  placement", "Merge-integrity guard", "Relationship to renumbering"),
  `docs/artifact-conventions.md` ("Renumbering after a parallel merge"), and
  `.opencode/skill/merge-conflict/SKILL.md` (the pre-flight duplicate scan and
  cross-branch comparison, the post-merge pass, and the `work/` artifact reconcile
  renumber steps). Because the deliverable is the framework's own documents, the
  acceptance criteria name the surfaces that must carry the contract; they specify
  required content, not implementation choices.
- **Reuse, do not fork.** The seven codes, the class `(a)`–`(d)` labels, the
  finding-line grammar, the readiness/`Depends on` contract, and the allocation
  contract are reused unchanged. This item defines no second state model, finding
  vocabulary, dependency edge, or reference grammar.
- **Duplicated-inventory `DRIFT-FACT` unchanged.** The guard's inventory/count
  and single-manifest `DRIFT-FACT` invariants are top-level facts and their wording
  is out of scope; only the class `(c)`/duplicate handling is generalized.
- **Single-source guards must stay green.** `tests/checks/40-inventory.sh` pins the
  documented inventory counts and tables; `tests/checks/80-cycle-fixture.sh`,
  `85-conflict-guards.sh`, `87-backtrack-guards.sh`, and `96-signature-sweep.sh`
  pin the cycle rule, the declaration model, the backtrack labels, and the command
  signatures. This item restates none of their pinned literals; no committed check
  pins the merge-integrity or renumber wording, so the edits keep them green.
- **The suite never reads live `work/**`.** The committed suite is read-only and
  fresh-clone-clean (`tests/README.md:30-31`); committed recursive merge-integrity
  guards are deferred to a successor roadmap, so this item adds no test file.
- **Verification is authority inspection plus a green suite.** The guard is prompt
  behavior with no committed checker; with this docs-and-prompt scope, AC1–AC15 are
  verified by reading the named authority sections and the skill passages and by
  `bash tests/run.sh` staying green. The residual — a live `/status` or `/ship`
  post-merge run emitting the recursive findings — remains a documented manual
  check, as it already is for the two-level model.
- **Backward compatibility.** A one-segment standalone item, an existing two-level
  parent/child, and every committed `work/` item remain valid; no migration,
  rename, spent-number change, or `ship.md` change occurs
  (`work/0013-simultaneous-work-recursion/manifest.md:72-74`).
- **Assumption — the contract is one feature.** Generalizing the class `(c)`
  taxonomy, the guard's scope and duplicate rows, both enforcement points, the
  renumber procedure (including the whole-subtree sweep), and the skill's
  guard/enforcement passages is one coherent contract change, specifiable and
  reviewable on its own; if it proves too large at `/plan`, the manifest's
  sanctioned remedy is to revise the decomposition with
  `/plan 0013-simultaneous-work-recursion` and add siblings at the same level, not
  to nest.
- **Framework-internal change only.** Documents and prompts; no runtime
  dependency, service, network access, or new toolchain. No file under another
  phase is edited.
