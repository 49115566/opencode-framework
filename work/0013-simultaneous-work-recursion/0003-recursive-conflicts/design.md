---
feature: 0013-simultaneous-work-recursion/0003-recursive-conflicts
phase: design
status: final
created: 2026-10-13
updated: 2026-10-13
parent: 0013-simultaneous-work-recursion
conflicts-with: "—"
---

# Design — Recursive `conflicts-with` at every level

## Summary

Generalize the declared-conflict model from its two-segment cap to arbitrary
depth, editing only the two authority surfaces: the target grammar and
discriminator in `docs/workflow.md` → "Declared conflicts (`conflicts-with`)",
the compared set / resolution / pair predicate in `docs/workflow.md` →
"Declared-conflict check", and the manifest `conflicts-with` bullet in
`docs/artifact-conventions.md`. The change is a strict superset: the grammar's
`( /[0-9]{4}-[a-z0-9-]+ )?` becomes `( /[0-9]{4}-[a-z0-9-]+ )*`, the
discriminator's `?` becomes `*`, and the compared set is defined by a recursive
walk that treats every node's `Children` rows as entities at any depth. No
committed checker, fixture, code, or new vocabulary is added.

## Approach

The declared-conflict facility is **prompt behavior documented in two authority
documents** — there is no executable implementation. So the change is entirely
editorial, but it must be *exact*, because two forces pin it: (1) the recursive
model's own consistency across the two authority sections, and (2) the committed
guard `tests/checks/85-conflict-guards.sh`, which reads the live authority's
"Declared-conflict check" section and asserts its vocabulary.

### A. `docs/workflow.md` → "Declared conflicts (`conflicts-with`)"

1. **Grammar.** `SiblingOrItemRef ::= [0-9]{4}-[a-z0-9-]+( /[0-9]{4}-[a-z0-9-]+ )?`
   becomes `... ( /[0-9]{4}-[a-z0-9-]+ )*` (source `docs/workflow.md:286`).
2. **Reference-vs-path discriminator.** The regex
   `^[0-9]{4}-[a-z0-9-]+(/[0-9]{4}-[a-z0-9-]+)?$` becomes
   `^[0-9]{4}-[a-z0-9-]+(/[0-9]{4}-[a-z0-9-]+)*$` (`docs/workflow.md:302-307`).
3. **Target kinds.** The canonical work-item reference becomes
   `NNNN-slug(/MMMM-slug)*` (top-level `NNNN-slug`, nested to any depth), still
   resolving to `work/<ref>/`; a reference may name an ancestor, a descendant, or
   an item in a different subtree — cross-level naming is permitted
   (AC6, AC7).
4. **Precedence generalized to the immediate parent.** A **bare** single-segment
   token (no `/`) resolves against the **declaring entity's immediate parent's**
   `Children` table first, then `work/<token>/` at the repository root; a token
   containing `/` is always root-relative and never sibling-first (AC5, AC6).
   For a top-level standalone entity (no parent) only the root fallback applies.
5. **Well-formedness generalized.** A reference may not name the declaring
   entity's own local id *or* its own full canonical reference (both are
   unresolved self-references) (AC12).

### B. `docs/workflow.md` → "Declared-conflict check"

6. **The compared set recurses.** Re-express "Decomposing parent / Decomposing
   child / Standalone item" as a recursive walk (AC3, AC4):
   - a **decomposing node** is never an entity itself as a container; its
     `Children` rows are entities keyed by their **full canonical reference**,
     and when a row's child directory itself holds a manifest
     (`manifest.md`, or the legacy `roadmap.md` alias) that child is **also**
     a decomposition whose rows are recursed — at arbitrary depth;
   - a leaf child (even `.gitkeep`-only) is an entity via its immediate parent's
     row;
   - a standalone top-level item with a `spec.md` and no manifest is an entity
     via the standalone rule.
   The `own ∪ cell` union and the both-present-unequal `DRIFT-FACT` rule apply
   per entity at any depth (AC8, AC9); a `ship.md`-present entity is excluded as
   a counterpart but still resolves as a target (AC11).
7. **Resolution paragraph.** Update "sibling-first precedence for a bare
   `MMMM-slug`" to the immediate-parent-then-root precedence, and
   `work/<NNNN-slug>[/<MMMM-slug>]/` to the arbitrary-depth reference (AC5, AC12).
8. **Pair predicate.** "any two unshipped items" becomes "any two unshipped
   entities at any depth"; target identity is per resolved canonical reference or
   trimmed surface path, so the same bare token under two different parents is
   not a shared target (AC7, AC10).
9. **Vocabulary and contract preserved verbatim.** The finding-line grammar, the
   `TEXTUAL-CONFLICT`/`DANGLING-DEP`/`DRIFT-FACT` codes, and the `(a)`–`(d)`
   classes are unchanged; the advisory/offline/read-only/no-readiness-effect
   contract and the empty-compared-set no-op are unchanged (AC13, AC14, AC16).

### C. `docs/artifact-conventions.md` → manifest `conflicts-with` bullet

10. Remove the deferral sentence (`docs/artifact-conventions.md:207-210`) and
    state that the shipped grammar is now recursive — references nest to
    arbitrary depth — referencing the authority rather than restating the grammar
    (AC17).

## Alternatives considered

- **Chosen — generalize both authority sections by reference, docs-only, no new
  fixtures.** Smallest change that satisfies every AC; extends the existing
  grammar in place; the sole executable guard (`85-conflict-guards.sh`) reads a
  section that stays byte-consistent and green. Cost: recursion is verified by
  authority inspection and the suite staying green, with the live LLM-run
  residual documented — the same residual the two-level model already carries.
- **Add a committed depth-3 recursive fixture/checker to `tests/`.** Pros:
  executable coverage of the recursion. **Rejected:** the user resolved the
  verification approach as docs-only and deferred the committed recursive fixture
  (depth-3 case) to Roadmap 5 (spec "Open questions"); it is a non-goal, would
  widen scope beyond the spec, and would collide with AC15's requirement that
  `85-conflict-guards.sh` stay byte-unchanged.
- **Restrict declared conflicts to sibling scope plus surfaces at every level**
  (forbid cross-level naming). Pros: simpler resolution, no root-relative
  ambiguity. **Rejected:** the user explicitly rejected it (spec "Open questions"
  → cross-level naming policy; non-goal "Restricting naming to siblings and
  surfaces"), and it would break the shipped two-level fixtures, which already
  permit cross-tree naming.

## Interfaces and data model

The product is a grammar and two algorithms; there is no code. The concrete
shapes are:

```
ConflictTarget     ::= SiblingOrItemRef | SurfacePath
SiblingOrItemRef   ::= [0-9]{4}-[a-z0-9-]+( /[0-9]{4}-[a-z0-9-]+ )*   # ? -> *
SurfacePath        ::= repository-relative file or directory path
```

Discriminator regex (reference when matched, else surface path):

```
^[0-9]{4}-[a-z0-9-]+(/[0-9]{4}-[a-z0-9-]+)*$        # one or more segments
```

Compared-set recursion (entity key = full canonical reference):

```
entities(node_ref, node_dir):
  manifest = node_dir/manifest.md or node_dir/roadmap.md
  for each row in manifest.Children:
    child_ref = node_ref + "/" + row.local_id
    emit entity(child_ref, declared = own(design.md) ∪ row.conflicts-with,
                 shipped = exists(child_dir/ship.md))
    if child_dir holds a manifest: entities(child_ref, child_dir)   # recurse
# top level:
#   decomposing node            -> entities(node_ref, dir)   (container, no own entity)
#   standalone item with spec.md -> emit entity(NNNN-slug, own(design.md), shipped)
```

Token resolution (for entity declaring bare/multi-segment/reference tokens):

```
if token contains "/":            resolve root-relative -> work/<token>/  (reference)
elif declaring parent exists and token names a sibling row in the parent table:
                                  resolve -> <parent>/<token>
elif work/<token>/ exists:        resolve -> <token>
else:                             unresolved
```

Backward compatibility: `?`→`*` is a strict superset — every one- and
two-segment token still matches and resolves identically, so existing
declarations and the `tests/fixtures/declared-conflicts/` fixture need no
migration. `85-conflict-guards.sh`'s own resolution regex remains two-segment
and its expected blocks are unchanged, so AC15 holds. No readiness edge,
dependency edge, `phase` value, state file, or finding vocabulary is introduced.

## Affected areas

- `docs/workflow.md` → "Declared conflicts (`conflicts-with`)" (`docs/workflow.md:250-317`) — items 1–5.
- `docs/workflow.md` → "Declared-conflict check" (`docs/workflow.md:737-863`) — items 6–9.
- `docs/artifact-conventions.md` → manifest `conflicts-with` bullet (`docs/artifact-conventions.md:204-210`) — item 10.
- `tests/checks/85-conflict-guards.sh`, `tests/fixtures/declared-conflicts/`,
  and every other file are **untouched** (AC15). The operative surfaces that
  reference the authority and do not restate its two-segment cap
  (`.opencode/agent/status.md:234-250`, `.opencode/command/status.md:67-76`,
  `.opencode/command/conflicts.md`, `.opencode/command/build.md`) need no edit
  and keep referencing the unchanged `## Declared-conflict check` heading.

## Risks and mitigations

- **Accidental forbidden token in the "Declared-conflict check" section.** The
  guard greps that section for the literal strings `(e)`, `DECLARED-`, `PLAN-`,
  and `CONFLICT-`, and requires `TEXTUAL-CONFLICT`, `DANGLING-DEP`, `DRIFT-FACT`,
  `(a)`, `(b)`, `(d)`, and the exact finding-line grammar.
  Likelihood: medium / Impact: high (red suite). Mitigation: keep all codes,
  classes, and grammar text byte-identical; the task's `Verify:` greps the
  section for the forbidden literals; T5 runs `bash tests/run.sh`.
- **Grammar and check generalized inconsistently** (grammar accepts depth ≥ 3 but
  the compared set still stops at two levels, or vice versa).
  Likelihood: medium / Impact: high (AC3/AC4 unmet). Mitigation: paired task
  coverage — T1 edits the grammar/discriminator, T2/T3 the check — and T5
  cross-checks both sections against AC1–AC10.
- **Precedence ambiguity for a top-level standalone item** (no immediate parent
  table). Likelihood: low / Impact: medium. Mitigation: state explicitly that
  only the root `work/<token>/` fallback applies when there is no parent.
- **Drift with the `merge-conflict` skill's planning-time block**, which
  references `## Declared-conflict check` and the codes but must not restate the
  algorithm. Likelihood: low / Impact: low. Mitigation: keep the skill untouched;
  T5 confirms the section heading and the skill's reference are unchanged.
- **Residual: no executable recursive check.** The live `/conflicts`, `/status`,
  and `/build`-gate runs remain a documented manual check, exactly as for the
  two-level model. Likelihood: certain / Impact: low (known residual, Roadmap 5).

## Test strategy

Docs-only, so verification is (1) the existing committed suite, (2) authority
inspection via grep of the named sections, and (3) the documented manual
LLM-run residual. Mapping:

| Criterion | Verification level |
| --------- | ------------------ |
| AC1, AC2  | grep the grammar line and discriminator regex in `docs/workflow.md` |
| AC3, AC4  | manual/authority inspection of the recursive compared set |
| AC5, AC6, AC7 | grep the precedence and root-relative statements |
| AC8, AC9  | grep the `own ∪ cell` union and `DRIFT-FACT`-at-depth statements |
| AC10, AC11 | grep the "any two unshipped entities at any depth" and shipped-exclusion text |
| AC12, AC13 | grep the unresolved/self-reference text and confirm codes/classes/grammar unchanged |
| AC14, AC16 | grep the advisory/read-only contract and the empty-set no-op |
| AC15      | `bash tests/run.sh` passes; `85-conflict-guards.sh` and its fixture unchanged (`git diff --quiet`) |
| AC17      | grep both authority documents for the recursive grammar and the removed deferral |
