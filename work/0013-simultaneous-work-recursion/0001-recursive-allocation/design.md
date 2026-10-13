---
feature: 0013-simultaneous-work-recursion/0001-recursive-allocation
phase: design
status: final
created: 2026-10-13
updated: 2026-10-13
parent: 0013-simultaneous-work-recursion
conflicts-with: "docs/workflow.md, docs/artifact-conventions.md"
---

# Design — Per-level sequence allocation and recursive duplicate detection

## Summary

Replace the two-level duplicate-sequence sentence in `docs/workflow.md` →
"Multiple work items" with one recursive **duplicate-detection rule**: duplicate
`4`-digit prefixes are checked independently at every node of the tree, the two
shipped codes are mapped to their tree positions (`DUPLICATE-PREFIX` = two
top-level `NNNN`, `DUPLICATE-CHILD` = two same-parent `MMMM` at any depth), and a
depth-≥ 3 collision names both offenders by full canonical reference plus the
shared parent and shared local prefix. Add a one-sentence cross-reference from
`docs/artifact-conventions.md` → "Sequence allocation" so no second duplicate
rule exists. Allocation, the `## Merge conflicts` section, the renumber
procedure, the `status` agent, the `merge-conflict` skill, and every fixture are
untouched.

## Approach

This is a documentation-only change to two authority documents, matching the
spec's deliverable surfaces (`spec.md` "Dependencies and constraints" →
"Deliverable surfaces"). It states a rule that already exists in fragments across
surfaces; it introduces no new mechanism, artifact, or vocabulary.

### 1. `docs/workflow.md` → "Multiple work items" (the single authority)

Replace the paragraph at lines 1379–1388 with the recursive rule below. The
existing renumber pointer ("Renumbering after a parallel merge") and the
"only one class of conflict → `## Merge conflicts`" pointer are preserved. The
new prose to author is:

> Because two branches can each allocate the same next number, a merge can leave
> two items sharing a canonical reference without a filesystem conflict. Duplicate
> `4`-digit prefixes are checked at **every node** of the recursive tree, not only
> the top level plus one child layer; each decomposing node at any depth is checked
> against **its own immediate children**, independently, and the top level is
> checked against the top-level items. No node's check depends on another's, and
> identity is the full canonical path, not the trailing segment — two nodes whose
> local id text matches but whose parents differ are not a duplicate.
>
> The two shipped codes name the two tree positions; a collision is reported under
> exactly one of them:
>
> - `DUPLICATE-PREFIX` — two **top-level** `NNNN` prefixes are equal.
> - `DUPLICATE-CHILD` — two **same-parent** `MMMM` prefixes are equal, at any depth.
>
> A top-level collision is never reported as `DUPLICATE-CHILD`, and a deeper
> collision is never reported as `DUPLICATE-PREFIX`. A `DUPLICATE-CHILD` finding
> names both offenders by their **full canonical reference**; when the collision
> is at depth ≥ 3 — for example two grandchildren, `<parent>/<MMMM-slug>-a` and
> `<parent>/<MMMM-slug>-b` — it also names the **shared parent and shared local
> prefix** in the detail, so the finding is unambiguous at any depth. Findings use
> the class `(c)` label and the finding grammar of `## Merge conflicts`; this rule
> introduces no new code, class, or vocabulary.
>
> On a collision, follow "Renumbering after a parallel merge" in
> `docs/artifact-conventions.md`: renumber the unshipped item to the next number
> from the allocation contract and update every reference in the same change
> before it ships. A number is never reused. Duplicate sequence numbers are only
> one class of conflict; for every other class — shared-surface textual conflicts,
> `work/` artifact conflicts, and derived-agreement drift — see
> `## Merge conflicts`.

The rule deliberately references the class label and grammar of
`## Merge conflicts` rather than restating the `(a)`–`(d)` taxonomy, so the
shipped finding vocabulary stays single-sourced (AC5). The `DUPLICATE-PREFIX` /
`DUPLICATE-CHILD` wording deliberately mirrors the canonical table in
`.opencode/skill/merge-conflict/SKILL.md:118-119` ("two different top-level
`work/` references share an `NNNN`" / "two different per-parent child references
share an `MMMM`") and the `status` agent's bullets
(`.opencode/agent/status.md:225-228`), which already generalize to any depth via
"per-parent".

### 2. `docs/artifact-conventions.md` → "Sequence allocation" (cross-reference only)

After the per-level `MMMM` paragraph (ending line 687) and before
`### Renumbering after a parallel merge`, insert one sentence that points at the
rule without restating its mapping (AC6):

> Duplicate `4`-digit prefixes — at the top level and at every node of the tree —
> are detected by the recursive rule stated once in `docs/workflow.md` →
> "Multiple work items"; this section defines no duplicate-detection rule of its
> own.

The allocation contract itself (lines 670–687) is unchanged (AC7).

## Alternatives considered

- **Put the rule in `## Merge conflicts`, beside the taxonomy and guard.**
  Rejected: the spec assigns the rule to "Multiple work items" (AC6), and the
  `## Merge conflicts` section — taxonomy, guard invariant rows, enforcement
  points — is explicitly `0002-recursive-merge-integrity`'s to generalize (AC8,
  `spec.md` "Non-goals"). Editing there would both contradict the named authority
  and collide with a sibling.
- **Put the rule in `docs/artifact-conventions.md` "Sequence allocation" and
  point at it from "Multiple work items".** Rejected: "Sequence allocation" is the
  allocation/renumber contract; the spec fixes "Multiple work items" as the single
  rule authority (AC6), and the shipped `## Merge conflicts` and renumber text
  already route duplicate handling through "Multiple work items"
  (`docs/workflow.md:1383`, `docs/artifact-conventions.md:718-720`).
- **Add a new dedicated section for recursive duplicate detection.** Rejected:
  it creates a second authority and a competing rule, violating AC6's
  single-authority requirement, and adds a surface the spec's scope excludes
  (AC8).
- **Move/duplicate the code mapping into the `status` agent and `merge-conflict`
  skill too.** Rejected: those are Roadmap 4 surfaces (and `0002`'s guard
  surfaces) per the spec's "Non-goals"; AC8 confines the change set to the two
  authority documents.

## Interfaces and data model

No code interfaces, schema, or data structures change. The "interface" of this
change is the documented contract and its finding shape.

- **Rule location (single authority)** — `docs/workflow.md` → "Multiple work
  items". Every other surface references it.
- **Tree positions** — top level: node = a top-level item, check = all top-level
  `work/*` directory names. Any decomposing node at any depth: node = the parent,
  check = its own immediate children's `MMMM` prefixes. Checks are independent.
- **Code mapping** — `DUPLICATE-PREFIX` (class `(c)`): two equal top-level
  `NNNN`. `DUPLICATE-CHILD` (class `(c)`): two equal same-parent `MMMM` at any
  depth. Mutually exclusive by tree position.
- **Depth ≥ 3 naming** — a `DUPLICATE-CHILD` finding names both offenders by full
  canonical reference; at depth ≥ 3 it also names the shared parent and shared
  local prefix in the detail. Concretely:

  ```
  - [DUPLICATE-CHILD] (c) <parent>/0002-api, <parent>/0002-web — two child references under <parent> share `0002`.
  ```

  where `<parent>` is a canonical reference of depth ≥ 2 (so the offenders are
  depth ≥ 3). This reuses the grammar
  `- [<CODE>] (<class>) <offender canonical reference(s)> — <specific detail>`
  (`.opencode/skill/merge-conflict/SKILL.md:94-100`), not a new one.
- **Backward compatibility** — the rule is a strict generalization of the shipped
  two-level sentence; a standalone `NNNN-slug`, a two-level parent/child, and
  every committed `work/` item remain valid with no migration and no change to
  allocation, `Depends on`, readiness, or renumbering behavior.

## Affected areas

- `docs/workflow.md` — the "Multiple work items" paragraph (currently lines
  1379–1388); all other sections, including `## Merge conflicts` and
  `### Lifecycle placement`, untouched.
- `docs/artifact-conventions.md` — one inserted cross-reference sentence in
  "Sequence allocation" (after line 687); the allocation/renumber text untouched.
- **Not touched** (AC8): `## Merge conflicts` (taxonomy, merge-integrity guard
  invariant rows, enforcement points), "Renumbering after a parallel merge",
  `.opencode/agent/status.md`, `.opencode/skill/merge-conflict/SKILL.md`,
  `test/**`, `README.md`, any `conflicts-with` grammar or check, plan
  publication, and every fixture.

## Risks and mitigations

- **Wording drift re-creates a competing duplicate rule.** — likelihood: medium /
  impact: medium / mitigation: state the rule once in "Multiple work items"; in
  "Sequence allocation" add only a pointer sentence; reference `## Merge
  conflicts` for the class label and grammar rather than restating the `(a)`–`(d)`
  taxonomy.
- **Accidental edit to a sibling-owned section.** — likelihood: low / impact:
  high / mitigation: edit only the two named paragraphs; verify with
  `git diff` that no change falls inside `## Merge conflicts` or
  `### Lifecycle placement`.
- **Inventory/count drift breaks the committed suite.** — likelihood: low /
  impact: high / mitigation: no agent/command/skill surface and no README count is
  changed; run `bash tests/run.sh` and confirm `tests/checks/40-inventory.sh`
  stays green (AC9).
- **Ambiguity about what "depth" the rule reaches.** — likelihood: low / impact:
  medium / mitigation: state the rule as "every node of the recursive tree …
  checked against its own immediate children" and give the explicit grandchild
  example, so depth ≥ 3 is covered without a special case (AC1, AC4).
- **A surface still implies a two-level boundary and contradicts the new rule.**
  — likelihood: medium / impact: low / mitigation: this is a known, bounded
  residual: the `merge-conflict` skill's "per-parent roadmap child numbers"
  (`.opencode/skill/merge-conflict/SKILL.md:73-75`) and the `status` agent's
  restatements are deferred to Roadmap 4 / `0002` by the spec's "Non-goals" and
  are report-only, not contradictory in effect. Recorded, not fixed here.

## Test strategy

This is a prose change to two documents; the committed suite is read-only and
never reads live `work/**` (`tests/README.md:30-31`), so verification is a mix of
targeted content checks and the repository's own test command.

| Criterion | Verification level | How |
| --------- | ------------------ | --- |
| AC1 rule reaches arbitrary depth | static content | grep `docs/workflow.md` for the "every node" / "own immediate children" wording |
| AC2 per-node scan model | static content | grep `docs/workflow.md` for "its own immediate children" and "top level is checked against the top-level items" |
| AC3 code mapping | static content | grep for `DUPLICATE-PREFIX` / `DUPLICATE-CHILD` and the top-level / same-parent mapping |
| AC4 depth ≥ 3 naming | static content | grep for "full canonical reference" and "shared parent and shared local prefix" |
| AC5 shipped vocabulary reused | static content | confirm the rule references `## Merge conflicts` for class/grammar and adds no new code/class |
| AC6 single authority | static content | confirm the rule is in "Multiple work items" and "Sequence allocation" only cross-references it |
| AC7 allocation unchanged | static content | `git diff docs/artifact-conventions.md` shows only the inserted pointer sentence |
| AC8 scope and boundary | static content | `git diff --name-only` lists only the two docs (plus this item's `work/` artifacts) |
| AC9 suite green, inventory unchanged | integration | `bash tests/run.sh` → exit 0 |
| AC10 backward compatibility | static content | diff shows no change to allocation, `## Merge conflicts`, or renumber text |
