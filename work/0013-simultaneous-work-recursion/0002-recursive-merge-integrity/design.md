---
feature: 0013-simultaneous-work-recursion/0002-recursive-merge-integrity
phase: design
status: final
created: 2026-10-13
updated: 2026-10-13
parent: 0013-simultaneous-work-recursion
conflicts-with: "docs/workflow.md, docs/artifact-conventions.md, .opencode/skill/merge-conflict/SKILL.md"
---

# Design — Merge integrity and renumbering for recursive trees

## Summary

Generalize the merge-time contract from its two-level cap to arbitrary depth,
editing only the three surfaces the spec fixes: the class `(c)` row and the
**merge-integrity guard** in `docs/workflow.md`, the post-merge pass in its
"Lifecycle placement", the normative **renumber procedure** in
`docs/artifact-conventions.md` ("Renumbering after a parallel merge"), and the
guard/enforcement passages of `.opencode/skill/merge-conflict/SKILL.md`. The
duplicate-detection rule itself is **not** restated: `0001-recursive-allocation`
already fixed it once in `docs/workflow.md` → "Multiple work items", and every
edit here references that authority. The change adds no new code, class,
grammar, fixture, or state model.

## Approach

This is a documentation-and-prompt change to three framework surfaces, matching
the spec's deliverable surfaces (`spec.md` → "Dependencies and constraints" →
"Deliverable surfaces"). Every edit is a **strict depth generalization** of
shipped text: "top level plus one child layer" becomes "every node at every
depth", and the one flat renumber step becomes a whole-subtree reference sweep.
Nothing is removed or reworded beyond that axis, so backward compatibility is
automatic (AC15) and the shipped vocabulary is byte-preserved (AC11).

Scope boundary taken deliberately: `docs/workflow.md` → "Multiple work items"
(already generalized by `0001`) and "Sequence allocation" are read-only
references here, and the guard's position-generic graph-fault rows
(`DANGLING-DEP`, `CYCLIC-DEP`, `MISSING-CHILD`, `UNLISTED-CHILD`, `DRIFT-FACT`)
keep their existing wording (AC4, AC10). The skill's legacy `roadmap.md`
vocabulary is retained as the recognized deprecated alias; the edits generalize
its depth, not its noun, and the broad `roadmap`→`manifest` vocabulary sweep
remains Roadmap 4 (AC13).

### 1. `docs/workflow.md` → "Conflict taxonomy" — class `(c)` row (AC1)

Replace the class `(c)` row (`docs/workflow.md:1424`) so its conflict
description and its affected-surface cell admit a same-parent `MMMM` collision at
any node, not only "per-parent" one layer down:

> | (c) duplicate sequence number | Both branches allocate the same top-level `NNNN`, or the same local `MMMM` under the **same parent at any node** of the tree. | Top-level `work/<NNNN-slug>`; and, for any decomposing node at any depth, its immediate children `work/<node-ref>/<MMMM-slug>` |

This mirrors the two tree positions fixed in "Multiple work items" (AC1, AC10);
the other three taxonomy rows are untouched.

### 2. `docs/workflow.md` → "Lifecycle placement" — post-merge pass (AC2)

In the post-merge integrity pass sentence (`docs/workflow.md:1433-1439`),
replace "re-scan top-level and per-parent `work/` directories for duplicate
4-digit prefixes, re-check every `Depends on` against its `Children` table" with
a node-scoped scan at every depth:

> … The post-merge integrity pass is a documented, shipper-owned checklist run on
> the merged tree: re-scan **every node** of the recursive tree for duplicate
> 4-digit prefixes — the top level against the top-level items, and each
> decomposing node at any depth against its own immediate children,
> independently — re-check every `Depends on` against **its own node's**
> `Children` table for dangling, missing, unlisted, or cyclic references, and
> re-run the repository's own configured test command — the Project profile
> `Test:` value — to surface derived-agreement drift.

The following no-op sentence is unchanged.

### 3. `docs/workflow.md` → "Merge-integrity guard" — scope, duplicate rows, enforcement points (AC3, AC4, AC5, AC12)

After the two enforcement-point bullets and the sentence "The guard observes the
same invariant set at both points, and neither defines a separate guard."
(`docs/workflow.md:1480`), insert the guard-wide scope sentence (AC3) and the
single-source pointer (AC4):

> The invariant set is evaluated at **every node** of the recursive tree: the top
> level against the top-level items, and each decomposing node at any depth
> against its own immediate children, independently — no node's check depends on
> another's. Both enforcement points below observe the full invariant set at
> every node. The duplicate-sequence rows agree with the rule stated once in
> `docs/workflow.md` → "Multiple work items" and restate no competing duplicate
> rule.

Make the two duplicate rows (AC4) explicit and mutually exclusive while leaving
the position-generic graph-fault rows unchanged:

> | no two top-level `work/` items share a 4-digit `NNNN` prefix | `DUPLICATE-PREFIX` | `(c)` |
> | no two same-parent children of one decomposing node share a 4-digit `MMMM`, at any depth | `DUPLICATE-CHILD` | `(c)` |

Annotate the two enforcement-point bullets with "at every node" (AC5): the
`/status` bullet reports the invariants "at every node, offline and read-only on
demand", and the `/ship` post-merge bullet runs "at every node". The existing
report-only, non-fatal, no-lock, empty-tree no-op contract
(`docs/workflow.md:1493-1500`) is preserved verbatim (AC12).

### 4. `docs/workflow.md` → "Relationship to renumbering" (AC8, AC10)

Strengthen the deferral sentence (`docs/workflow.md:1508-1512`) to state the
renumber steps apply at any depth while keeping the single-authority claim:

> Duplicate sequence numbers — class (c) — are handled **at any depth** by
> "Renumbering after a parallel merge" in `docs/artifact-conventions.md`. Those
> steps apply identically to a collision at any node of the tree; this section
> defers to and extends that rule and never defines a second renumbering rule.

### 5. `docs/artifact-conventions.md` → "Renumbering after a parallel merge" (AC6, AC7, AC8)

**Step 1 "Detect"** (`docs/artifact-conventions.md:701-704`) — make detection
recursive and canonical-reference-identified, referencing the single rule:

> 1. **Detect.** Any two top-level `work/` directories whose 4-digit `NNNN`
>    prefix is equal are a `DUPLICATE-PREFIX` collision; and, for **every
>    decomposing node at any depth**, any two of its immediate children whose
>    local 4-digit `MMMM` prefix is equal are a `DUPLICATE-CHILD` collision. This
>    is the recursive rule stated once in `docs/workflow.md` → "Multiple work
>    items"; each offender is identified by its **full canonical reference**, and
>    a collision at depth ≥ 3 also names the **shared parent and shared local
>    prefix**.

**Step 4 "Update every reference in the same change"**
(`docs/artifact-conventions.md:711-714`) — replace the one-level list with the
whole-subtree sweep AC7 requires:

> 4. **Update every affected reference in the same change.** When the chosen node
>    is itself a decomposing node, its **whole subtree** moves with it — rewrite:
>    - the directory name;
>    - the node's own `feature:` frontmatter value, and **every descendant
>      artifact's** `feature:` value (the full canonical reference);
>    - the owning manifest's `Children` row `Local id` and `Canonical reference`
>      cells for the renumbered node, and **every intermediate manifest's**
>      `Children` `Canonical reference` cell on the changed path;
>    - **every descendant's** `parent:` value on the changed path;
>    - `ship.md` and PR/handoff paths; and
>    - any prose that names the old reference.

Steps 2, 3, and 5, and the closing paragraph (the "one sanctioned mechanical
cross-phase edit" rule), are unchanged. The step numbers and their meaning stay
the same, so the same detect/choose/renumber/update/record steps apply at any
depth (AC8).

### 6. `.opencode/skill/merge-conflict/SKILL.md` — guard and enforcement passages (AC9, AC11)

Edit only the recursive-relevant passages; the skill continues to name
`docs/workflow.md` as the source of truth and defines no second rule (AC10/AC9).

- **Pre-flight "Duplicate per-parent roadmap child numbers"** (`:73-75`) →
  rename to "Duplicate same-parent child numbers at every node" and scan **every
  decomposing node at any depth** (the top level plus each node's own immediate
  children), deferring the rule to `docs/workflow.md` → "Multiple work items".
- **Pre-flight "Roadmap graph faults"** (`:76-81`) → for each decomposing node
  (its `manifest.md`, or the legacy `roadmap.md` alias) at any depth, re-check
  every `Depends on` against **its own** `Children` table.
- **Pre-flight "Cross-branch prefix collision"** (`:86-92`) → descend **every
  node at every depth**, comparing each node's immediate children against the
  corresponding `git ls-tree --name-only origin/<default>:work/<node-ref>/` path;
  `/status` remains offline and performs no such read.
- **Procedure step 6 "Post-merge integrity pass"** (`:282-289`) → re-scan every
  node at every depth (not "top-level and per-parent").
- **`work/` artifact reconcile step 3** (`:359-398`) → in "Detect", scan every
  node at every depth; in "Move", apply the AC7 whole-subtree sweep (the node's
  `feature:`, the owning manifest's `Local id`/`Canonical reference`, every
  descendant's `feature:`/`parent:`, every intermediate manifest cell, `ship.md`
  and PR/handoff paths, and prose), keeping the existing
  `never defines a second renumbering rule` deferral.

**Preserved byte-for-byte** (pinned by `tests/checks/85-conflict-guards.sh:626-637`):
the exact finding-line grammar `- [<CODE>] (<class>) <offender path or
canonical reference(s)> — <specific detail>`, the word `planning-time`, and the
absence of the forbidden prefixes `(e)`, `DECLARED-`, `PLAN-`, `CONFLICT-`.

### Contract invariants preserved (AC10, AC11, AC12, AC15)

- **Single authority (AC10).** The duplicate rule stays solely in "Multiple work
  items"; the invariant set solely in "Merge-integrity guard"; the renumber steps
  solely in "Renumbering after a parallel merge". Every other mention points at
  its authority.
- **Vocabulary (AC11).** The seven codes, the `(a)`–`(d)` classes, and the
  finding-line grammar are reused unchanged; no new code, class, or severity is
  introduced.
- **Report-only contract (AC12).** No file is modified by the guard or procedure;
  no auto-repair; no truncation; no lock; `/status` performs no fetch or remote
  read; empty `work/` / up-to-date branch is a no-op.
- **Backward compatibility (AC15).** Every edit is a strict generalization of the
  shipped two-level text; one-segment items, two-level parents/children, and
  every committed `work/` item stay valid with no migration, rename, or
  spent-number change.

## Alternatives considered

- **Chosen — generalize the three surfaces in place, docs/prompt only, by
  reference, with no new fixtures.** Smallest change that satisfies every AC;
  keeps the single-authority claim intact (AC10); extends shipped vocabulary
  rather than adding one (AC11); the committed suite carries no recursive
  merge-integrity wording to break, so AC14 is met by `bash tests/run.sh` staying
  green. Cost: recursion is verified by authority inspection plus the suite, with
  the live `/status`/`/ship` LLM-run residual documented — the same residual the
  two-level model already carries.
- **Add a committed recursive merge-integrity fixture/checker under `tests/`.**
  Pros: executable coverage of the recursion. **Rejected:** the spec defers
  committed recursive guards to Roadmap 5 (explicit non-goal; `spec.md` "Open
  questions"), AC13 confines the change set to the three named surfaces, and
  AC14 requires the suite to stay read-only and never read live `work/**`.
- **Restate the duplicate rule inside the guard or the renumber section** rather
  than referencing "Multiple work items". Pros: the reader needs one hop fewer.
  **Rejected:** it creates a second authority and a competing rule, violating AC10;
  `0001-recursive-allocation` already fixed that rule in "Multiple work items", and
  the shipped `## Merge conflicts` and renumber text already route duplicate
  handling through it (`docs/workflow.md:1403-1404`,
  `docs/artifact-conventions.md:723-725`).
- **Extend the skill's `roadmap.md` vocabulary wholly to `manifest.md`.** Pros:
  one noun for the enumeration artifact. **Rejected:** the spec scopes this item
  to depth generalization; the broad vocabulary sweep is Roadmap 4's, and the
  status agent's legacy `roadmap` vocabulary is an explicit non-goal. The edits
  honor both filenames via the legacy alias without a wholesale rename.

## Interfaces and data model

No code interfaces, schema, or data structures change. The "interface" is the
documented contract and its scan/sweep shapes.

- **The single duplicate rule** — `docs/workflow.md` → "Multiple work items"
  (unchanged here, already recursive from `0001`). Every other surface references
  it.
- **Node-scoped duplicate scan** — for the top level: node = the repository,
  check = all top-level `work/*` `NNNN` prefixes. For every decomposing node at
  any depth: node = that parent, check = its **own immediate children's** `MMMM`
  prefixes. Checks are independent; a node's check never depends on another's.
- **Code mapping (unchanged, now depth-explicit)** — `DUPLICATE-PREFIX` (class
  `(c)`): two equal top-level `NNNN`. `DUPLICATE-CHILD` (class `(c)`): two equal
  same-parent `MMMM` at any depth. Mutually exclusive by tree position.
- **Depth ≥ 3 naming** — a `DUPLICATE-CHILD` finding names both offenders by full
  canonical reference; at depth ≥ 3 it also names the shared parent and shared
  local prefix, reusing the shipped grammar
  `- [<CODE>] (<class>) <offender canonical reference(s)> — <specific detail>`.
- **Whole-subtree reference sweep** — the set of references a renumber of a
  chosen decomposing node rewrites together (AC7):

  ```
  sweep(node) =
      { node dir name }
    ∪ { node's own feature: }
    ∪ { every descendant artifact's feature: }              # full canonical ref
    ∪ { owning manifest Children: Local id + Canonical reference }
    ∪ { every intermediate manifest Children: Canonical reference }
    ∪ { every descendant's parent: on the changed path }
    ∪ { ship.md and PR/handoff paths }
    ∪ { any prose naming the old canonical reference }
  ```

- **Backward compatibility** — every shape above is a strict superset of the
  shipped two-level text; no allocation, `Depends on`, readiness, or `phase`
  value changes.

## Affected areas

- `docs/workflow.md` → "Conflict taxonomy" (`:1424`) — item 1.
- `docs/workflow.md` → "Lifecycle placement" (`:1433-1439`) — item 2.
- `docs/workflow.md` → "Merge-integrity guard" (`:1469-1506`) — item 3.
- `docs/workflow.md` → "Relationship to renumbering" (`:1508-1512`) — item 4.
- `docs/artifact-conventions.md` → "Renumbering after a parallel merge"
  (`:694-721`) — item 5.
- `.opencode/skill/merge-conflict/SKILL.md` → pre-flight (`:69-92`), procedure
  step 6 (`:282-289`), `work/` artifact reconcile step 3 (`:359-398`) — item 6.
- **Untouched (AC13):** `docs/workflow.md` → "Multiple work items" and
  "Sequence allocation"; the manifest `conflicts-with` bullet; the
  "Declared-conflict check" section; `.opencode/agent/status.md`,
  `.opencode/agent/shipper.md`, `.opencode/command/status.md`,
  `.opencode/command/ship.md`; plan publication; `tests/**`; `README.md`; and any
  fixture.

## Risks and mitigations

- **Wording drift re-creates a competing duplicate rule.** — likelihood: medium /
  impact: high (AC10). Mitigation: state the rule once (in "Multiple work items",
  untouched); every edit references it; the guard scope sentence explicitly calls
  the duplicate rows single-sourced.
- **Accidental edit to the pinned "Declared-conflict check" section or the
  pinned skill literals.** — likelihood: low / impact: high (red suite).
  Mitigation: edit only the named sections/passages; preserve the skill's exact
  finding-line grammar, `planning-time`, and forbidden-prefix absence; T7 and T8
  verify with `git diff` and `bash tests/run.sh`.
- **Depth generalization applied inconsistently** (e.g. the taxonomy row says
  "any depth" but the post-merge pass still says "per-parent"). — likelihood:
  medium / impact: high (AC1–AC9). Mitigation: paired task coverage per surface
  plus T7 cross-checking every surface against the ACs.
- **Skill `roadmap.md` vocabulary left ambiguous after the depth edit.** —
  likelihood: low / impact: low. Mitigation: phrase the skill edits to accept the
  `manifest.md`/legacy `roadmap.md` alias explicitly; the wholesale vocabulary
  sweep stays Roadmap 4 and is recorded as a residual.
- **Residual: no executable recursive merge-integrity check.** The live
  `/status` and `/ship` post-merge runs remain a documented manual check, exactly
  as for the two-level model. — likelihood: certain / impact: low (known residual,
  Roadmap 5).
- **Advisory declared conflict with sibling surfaces.** The parent row and this
  design declare `docs/workflow.md`, `docs/artifact-conventions.md`, and
  `.opencode/skill/merge-conflict/SKILL.md`, shared with siblings `0001`, `0003`,
  and `0004`. — likelihood: high (will be reported) / impact: none (advisory).
  Mitigation: the declaration is intentional and changes no `Depends on` edge or
  readiness; the read-only check reports the `TEXTUAL-CONFLICT` pairs as expected.

## Test strategy

Docs/prompt-only, so verification is (1) the existing committed suite, (2)
authority inspection via grep of the named sections, and (3) the documented
manual LLM-run residual. Each acceptance criterion maps as follows:

| Criterion | Verification level | How |
| --------- | ------------------ | --- |
| AC1 class `(c)` reaches arbitrary depth | static content | grep the `(c)` row for "same parent at any node" / "any decomposing node at any depth" |
| AC2 post-merge pass at every node | static content | grep "Lifecycle placement" for "every node" and "its own node's `Children` table" |
| AC3 guard scope every node | static content | grep "Merge-integrity guard" for "evaluated at **every node**" and "independently" |
| AC4 guard duplicate rows explicit + single-sourced | static content | grep the two rows for top-level `NNNN` / same-parent `MMMM` at any depth and the "Multiple work items" pointer |
| AC5 both enforcement points at every node | static content | grep the enforcement bullets for "at every node" and "neither defines a separate guard" |
| AC6 renumber detect at any depth | static content | grep "Renumbering after a parallel merge" step 1 for "every decomposing node at any depth", full canonical reference, and shared parent/prefix |
| AC7 whole-subtree sweep | static content | grep step 4 for `Local id`, descendant `feature:`, descendant `parent:`, intermediate manifest cell |
| AC8 renumber at any depth, one rule | static content | grep "Relationship to renumbering" for "at any depth" and "never defines a second renumbering rule" |
| AC9 skill passages generalize | static content | grep the skill's scan/cross-branch/post-merge/renumber passages for "every node"/"any depth" |
| AC10 single authority | static content | confirm no restatement of the rule/invariant set/renumber steps; only pointers |
| AC11 shipped vocabulary reused | static content | confirm codes/classes/grammar text unchanged; no new token |
| AC12 report-only/non-fatal/offline/no-op | static content | confirm the guard and skill keep the report-only, no-lock, no-fetch, no-op wording |
| AC13 three surfaces only | static content | `git diff --name-only` lists only the three surfaces (plus this item's `work/` artifacts) |
| AC14 suite green, inventory unchanged | integration | `bash tests/run.sh` exits 0; `tests/checks/40-inventory.sh` lines all `ok` |
| AC15 backward compatibility | static content | diff shows only strict generalizations; no allocation/readiness/`phase` change |

The live `/status` and `/ship` post-merge runs emitting recursive findings remain
a documented manual check, consistent with the existing two-level model and the
deferred committed guards (Roadmap 5).
