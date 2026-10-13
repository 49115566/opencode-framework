---
description: "Report the phase of every work item by inspecting the work/ directory, including decomposing nodes and their descendants at any depth. Usage: /status [item-ref]"
agent: status
---

Produce a **status report**. This is read-only: do not edit any file.

Follow your Status agent instructions exactly. In particular:

- List `work/` and read each item's artifacts — frontmatter, `tasks.md` check
  boxes, `review.md` verdict, and any `ship.md`. Read each artifact's `stale:`
  marker and, where present, the item's `backtracks.md` finding/resolution
  entries, its `challenges.md` challenge/response/withdrawal entries, and the
  `ship.md` `reopened:` marker.
- Detect a **decomposing node** by the presence of `roadmap.md` — at any depth,
  a pure container or a hybrid that also carries its own artifacts; treat
  everything else as a single-feature item. Decide this before deriving any
  phase. A decomposing node derives its phase from its own phase artifacts
  first; only a manifest with no own phase artifacts derives the container phase
  `roadmap`.
- Derive each item's phase and derived condition using the "Derived state" table
  in `docs/workflow.md`, applying its precedence: the earliest `stale:` target
  `P` → `P (backtracked)`; a `reopened:` phase `P` on `ship.md` → `P (reopened)`;
  an open challenge (`Challenge <n>` with no matching `Response n`/`Withdrawal n`)
  on an item that has no `ship.md` → `challenged (blocked)`; then the
  artifact-presence and verdict rows. A `ship.md`-present item is never reported
  `challenged` — its open challenge is surfaced as out-of-scope. Map a
  `stale: roadmap` token to `spec`, and report the earliest outstanding backtrack
  target without dropping a later open finding. Report a resolution recorded
  before its finding, or a response recorded before its challenge, as a plain
  integrity observation without reordering it or inventing a finding code. Base
  the derivation on artifacts and contents, not timestamps. A `.gitkeep`-only
  child directory is `not started`.
- For each decomposing node — at any depth — parse its **Children** table and
  compute each immediate child's readiness with the authoritative readiness
  definition in `docs/workflow.md` → "Dependencies and readiness". Do not
  restate its branch sequence here. In short, applied independently at every
  level (a child resolves under its own node's canonical reference): a
  `review.md` verdict of `approve` satisfies a dependency even when unshipped,
  and presence of the dependency's `ship.md` satisfies it too; a **recalled**
  dependency — its `ship.md` carrying a `reopened:` marker — does not satisfy the
  dependency, so its dependents are reported `blocked`, naming the recalled item
  as the unsatisfied dependency, until it re-ships; `Depends on` is sibling-only,
  and a target that is itself a decomposing node is satisfied by its own signal
  only; a child in a cycle is never `ready`; a child with no dependencies is
  `ready`. Name the specific blocking children for each blocked child.
- Report each decomposing node's row separately from its descendants, showing
  `<ready>/<total> ready` plus a distribution tally of its immediate children
  across phases (`<phase> <n>, ...`); render its descendants indented beneath it
  to arbitrary depth, each node showing its derived phase and its readiness
  (`ready`/`blocked: <local ids>`). A standalone row keeps `checked/total tasks`.
- Emit `DANGLING-DEP` / `MISSING-CHILD` / `UNLISTED-CHILD` / `CYCLIC-DEP`
  findings for broken or cyclic references. Report them without failing and
  without modifying anything. An `UNLISTED-CHILD` observation for a child
  directory named as withdrawn under the parent's `## Open issues` is a
  **deliberate withdrawal**: report it report-only and never auto-repair it, not
  a possible rename.
- Also report, as one-line findings with their class labels, `DUPLICATE-PREFIX`
  `(c)` and `DUPLICATE-CHILD` `(c)` for duplicate top-level `NNNN` prefixes and
  duplicate per-parent `MMMM` child numbers, and `DRIFT-FACT` `(d)` for
  disagreement between README.md's Layout counts / Skills table and the on-disk
  `.opencode/{agent,command,skill}/` sets. This detection is local-only: it
  inspects the repository's own tree and facts, fetches nothing, hits no remote,
  runs no dry-run merge, and modifies no file. These findings are the
  merge-integrity guard's offline, read-only window (`docs/workflow.md` →
  `### Merge-integrity guard`); the report is non-fatal and modifies no file.
- Run the read-only **declared-conflict check** (`docs/workflow.md` →
  `## Declared-conflict check`) and report its findings in the same one-line
  format and class vocabulary: `TEXTUAL-CONFLICT` `(a)`/`(b)` for two unshipped
  plans that share a declared target, `DANGLING-DEP` `(b)` for a malformed or
  unresolvable `conflicts-with` target, and `DRIFT-FACT` `(d)` for a parent/item
  declaration disagreement. With no item argument, report every finding across
  the `work/` tree; with an item-ref, report only the findings that involve that
  item and name each counterpart. It is advisory, offline, local-only, and
  read-only: it adds no readiness edge and blocks no phase. Reference the
  authority; do not restate its algorithm.
- Report the status table with `checked/total` task progress and the exact next
  command per item. The Phase column mirrors the "Derived state" table's Phase
  cell — the base phases plus `P (backtracked)`, `P (reopened)`, `build (rework)`,
  and `challenged (blocked)` — and a per-item Notes line carries the detail: for a
  backtracked item the target phase being revised, the affected upstream artifact
  from the open finding, and the downstream artifacts the backtrack invalidated
  (the `stale:`-marked ones), or `none` when none exist; for a reopened item the
  recall and the re-entered phase; for an unshipped challenged item the open
  challenge id(s); and for a shipped item carrying an open challenge, that the
  challenge is out-of-scope. Then note any integrity findings and stale or
  inconsistent items.
- If a specific item is named in the argument, show its full artifact inventory.

If `work/` is empty, say so and recommend `/spec <feature>`. Do not start or run
any phase. End with the handoff block.
