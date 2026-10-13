---
feature: 0013-simultaneous-work-recursion/0003-recursive-conflicts
phase: tasks
status: final
created: 2026-10-13
updated: 2026-10-13
parent: 0013-simultaneous-work-recursion
---

# Tasks — Recursive `conflicts-with` at every level

Ordered, dependency-aware. One task ≈ one focused commit. Docs-only; all edits
are to the two authority surfaces named in the spec. `tests/checks/85-conflict-guards.sh`
and `tests/fixtures/declared-conflicts/` are never touched.

- [ ] **T1** — Generalize the target grammar, discriminator, and target-resolution
      rules in `docs/workflow.md` → "Declared conflicts (`conflicts-with`)":
      change `SiblingOrItemRef`'s trailing `( /[0-9]{4}-[a-z0-9-]+ )?` to
      `( /[0-9]{4}-[a-z0-9-]+ )*`; change the reference-vs-path discriminator
      regex `([0-9]{4}-[a-z0-9-]+)?$` to `([0-9]{4}-[a-z0-9-]+)*$`; generalize
      the canonical work-item reference to arbitrary depth; state that a
      multi-segment reference is always root-relative, that a bare single-segment
      token resolves against the declaring entity's **immediate parent's**
      `Children` table first and then `work/<token>/` at the repository root
      (root-only when there is no parent), that cross-level naming (ancestor,
      descendant, different subtree) is permitted, and that a reference may not
      name the declaring entity's own local id or its own full canonical
      reference. [AC1] [AC2] [AC5] [AC6] [AC7] [AC12]
      Verify: `grep -F '( /[0-9]{4}-[a-z0-9-]+ )*' docs/workflow.md` and
      `grep -F '(/[0-9]{4}-[a-z0-9-]+)*$' docs/workflow.md` each match; grep the
      section for the immediate-parent-then-root precedence, cross-level naming,
      and self-reference statements. Confirm the old `)?`/`)?$` forms are gone.

- [ ] **T2** — Recursify "The compared set" in `docs/workflow.md` →
      "Declared-conflict check": re-express the enumerations as a recursive walk
      in which every decomposing node's `Children` rows are entities keyed by
      full canonical reference, a row whose child directory holds a manifest
      (`manifest.md`, or the legacy `roadmap.md` alias) is itself recursed, a
      leaf `.gitkeep`-only child is an entity via its parent row, and a
      standalone top-level item with a `spec.md` and no manifest is an entity;
      carry the `own ∪ cell` union and the both-present-unequal `DRIFT-FACT`
      rule to every depth, and keep the `ship.md`-present exclusion (resolves as
      a target, excluded as a counterpart). [AC3] [AC4] [AC8] [AC9] [AC11]
      [depends: T1]
      Verify: grep the section for the recursive-walk language, the
      `own ∪ cell` union and `DRIFT-FACT`-at-depth statements, and the
      shipped-exclusion sentence; read the section and confirm a nested
      decomposing child is both an entity and recursed.

- [ ] **T3** — Generalize the resolution paragraph, the pair predicate, and the
      contract in `docs/workflow.md` → "Declared-conflict check" while
      preserving the vocabulary: update "sibling-first precedence for a bare
      `MMMM-slug`" to immediate-parent-then-root and the
      `work/<NNNN-slug>[/<MMMM-slug>]/` reference to arbitrary depth; state the
      pair predicate between "any two unshipped entities at any depth" with
      per-resolved-reference identity (the same bare token under two parents is
      not shared); keep the finding-line grammar, the
      `TEXTUAL-CONFLICT`/`DANGLING-DEP`/`DRIFT-FACT` codes, the `(a)`–`(d)`
      classes, the advisory/offline/read-only/no-readiness-effect contract, and
      the empty-compared-set no-op unchanged. [AC10] [AC12] [AC13] [AC14] [AC16]
      [depends: T1]
      Verify: grep the section for "any two unshipped entities at any depth",
      the immediate-parent-then-root precedence, the empty-set no-op, and the
      advisory/read-only contract; assert
      `awk '/^## Declared-conflict check/{f=1} f&&/^## /&&!/^## Declared-conflict check/{exit} f' docs/workflow.md`
      contains `TEXTUAL-CONFLICT`, `DANGLING-DEP`, `DRIFT-FACT`, `(a)`, `(b)`,
      `(d)`, and the exact finding-line grammar, and contains none of `(e)`,
      `DECLARED-`, `PLAN-`, `CONFLICT-`.

- [ ] **T4** — Remove the deferral in `docs/artifact-conventions.md` → the
      manifest `conflicts-with` bullet: delete the sentence stating the grammar
      is "preserved unchanged" and the generalization "is deferred to the
      successor decomposing node that owns '`conflicts-with` at every level'",
      replacing it with a statement that references may nest to arbitrary depth
      and pointing at the recursive grammar in `docs/workflow.md` → "Declared
      conflicts (`conflicts-with`)" (reference the authority; do not restate the
      grammar). [AC17]
      Verify: `grep -F 'deferred to the successor' docs/artifact-conventions.md`
      returns nothing; grep the bullet for the arbitrary-depth statement and the
      authority reference.

- [ ] **T5** — Verify the whole change: run the committed suite and confirm the
      guard surfaces are untouched and the two authority sections are mutually
      consistent. [AC15] [AC17] [depends: T1] [depends: T2] [depends: T3]
      [depends: T4]
      Verify: `bash tests/run.sh` exits `0` with no `FAIL` lines;
      `git diff --quiet tests/checks/85-conflict-guards.sh tests/fixtures/declared-conflicts/`
      is clean (fixture and guard byte-unchanged); re-read both generalized
      sections and confirm the grammar, discriminator, and compared set agree on
      arbitrary depth.
