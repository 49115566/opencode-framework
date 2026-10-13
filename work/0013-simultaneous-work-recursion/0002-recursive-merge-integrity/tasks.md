---
feature: 0013-simultaneous-work-recursion/0002-recursive-merge-integrity
phase: tasks
status: final
created: 2026-10-13
updated: 2026-10-13
parent: 0013-simultaneous-work-recursion
---

# Tasks — Merge integrity and renumbering for recursive trees

Ordered, dependency-aware. One task ≈ one focused commit. The exact prose to
author is fixed in `design.md` → "Approach" and "Interfaces and data model"; no
task may re-open those decisions. Edit only the three surfaces the spec fixes.

- [ ] **T1** — Generalize the class `(c)` duplicate-sequence row in
      `docs/workflow.md` → "Conflict taxonomy" (`:1424`) so its description and
      affected-surface cell admit a same-parent `MMMM` collision at any node,
      exactly as fixed in `design.md` → "Approach" item 1. Do not touch the other
      taxonomy rows. [AC1, AC10, AC11]
      Verify: `grep -nE 'same parent at any node|any decomposing node at any depth' docs/workflow.md` shows the `(c)` row; `git diff docs/workflow.md` shows no hunk under the `(a)`, `(b)`, or `(d)` rows.

- [ ] **T2** — Generalize the post-merge integrity-pass sentence in
      `docs/workflow.md` → "Lifecycle placement" (`:1433-1439`) to re-scan
      every node at every depth and re-check each node's own `Depends on`
      table, exactly as fixed in `design.md` → "Approach" item 2. Leave the
      following no-op sentence unchanged. [AC2]
      Verify: `grep -nE 'every node of the recursive tree|its own node.s' docs/workflow.md` matches inside "Lifecycle placement"; `grep -n 'top-level and per-parent' docs/workflow.md` returns nothing.

- [ ] **T3** — In `docs/workflow.md` → "Merge-integrity guard", insert the
      guard-wide "evaluated at every node" scope sentence and the single-source
      pointer, make the `DUPLICATE-PREFIX`/`DUPLICATE-CHILD` rows depth-explicit,
      and annotate both enforcement-point bullets with "at every node", exactly
      as fixed in `design.md` → "Approach" item 3. Preserve the report-only,
      non-fatal, no-lock, empty-tree no-op contract and the position-generic
      graph-fault rows verbatim. [AC3, AC4, AC5, AC12]
      Verify: `grep -nE 'evaluated at .*every node|same-parent children of one decomposing node|at every node' docs/workflow.md` matches inside the guard; `git diff docs/workflow.md` shows no change to the `DANGLING-DEP`/`CYCLIC-DEP`/`MISSING-CHILD`/`UNLISTED-CHILD`/`DRIFT-FACT` rows.

- [ ] **T4** — Strengthen `docs/workflow.md` → "Relationship to renumbering"
      (`:1508-1512`) to state the renumber steps apply at any depth while keeping
      the single-authority deferral, exactly as fixed in `design.md` → "Approach"
      item 4. [AC8, AC10]
      Verify: `grep -nE 'at any depth|never defines a second renumbering rule' docs/workflow.md` matches inside "Relationship to renumbering".

- [ ] **T5** — Generalize `docs/artifact-conventions.md` → "Renumbering after a
      parallel merge": rewrite step 1 "Detect" (`:701-704`) to scan every
      decomposing node at any depth, name offenders by full canonical reference,
      and reference the rule in "Multiple work items"; replace step 4 "Update
      every reference in the same change" (`:711-714`) with the AC7 whole-subtree
      sweep, exactly as fixed in `design.md` → "Approach" item 5 and the
      `sweep(node)` shape. Steps 2, 3, 5 and the closing paragraph are unchanged.
      [AC6, AC7, AC8]
      Verify: `grep -nE 'every decomposing node at any depth|shared parent and shared local prefix|Local id|every descendant' docs/artifact-conventions.md` matches inside the renumber section; `git diff docs/artifact-conventions.md` shows hunks only in steps 1 and 4.

- [ ] **T6** — Generalize the guard/enforcement passages of
      `.opencode/skill/merge-conflict/SKILL.md`: the pre-flight duplicate scan
      (`:73-75`), the graph-fault scan (`:76-81`), the cross-branch prefix
      collision (`:86-92`), procedure step 6 (`:282-289`), and the `work/`
      artifact reconcile step 3 (`:359-398`), exactly as fixed in
      `design.md` → "Approach" item 6. Keep the skill naming `docs/workflow.md`
      as the source of truth. Preserve byte-for-byte the finding-line grammar,
      the word `planning-time`, and the absence of `(e)`/`DECLARED-`/`PLAN-`/
      `CONFLICT-`. [AC9, AC10, AC11]
      Verify: `grep -cE 'every node|any depth' .opencode/skill/merge-conflict/SKILL.md` is > 0; `grep -qF -- '- [<CODE>] (<class>) <offender path or canonical reference(s)> — <specific detail>' .opencode/skill/merge-conflict/SKILL.md` and `grep -qF -- 'planning-time' …` succeed; `grep -qE '\(e\)|DECLARED-|PLAN-|CONFLICT-' …` fails.

- [ ] **T7** — Verify the scope boundary, single authority, vocabulary reuse, and
      backward compatibility across all edits: confirm the change set is exactly
      the three surfaces, that the duplicate rule / invariant set / renumber
      steps are each stated once and only referenced elsewhere, that no new code,
      class, grammar, or severity token appears, and that the edits are strict
      generalizations. [AC10, AC11, AC12, AC13, AC15] [depends: T1, T2, T3, T4, T5, T6]
      Verify: `git diff --name-only` lists only `docs/workflow.md`,
      `docs/artifact-conventions.md`, and `.opencode/skill/merge-conflict/SKILL.md`
      (plus this item's `work/` artifacts); `git diff` shows no new finding code
      or class label and no change to "Multiple work items", "Sequence
      allocation", the "Declared-conflict check" section, or any `tests/**` file.

- [ ] **T8** — Run the repository's configured test command and confirm the
      committed suite is green with no documented inventory count changed.
      [AC14] [depends: T7]
      Verify: `bash tests/run.sh` exits 0; its `tests/checks/40-inventory.sh`
      lines are all `ok`.
