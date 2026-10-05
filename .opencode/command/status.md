---
description: "Report the phase of every work item by inspecting the work/ directory, including roadmap parents and their children. Usage: /status [item-ref]"
agent: status
---

Produce a **status report**. This is read-only: do not edit any file.

Follow your Status agent instructions exactly. In particular:

- List `work/` and read each item's artifacts — frontmatter, `tasks.md` check
  boxes, `review.md` verdict, and any `ship.md`.
- Detect a **roadmap parent** by the presence of `roadmap.md`; treat everything
  else as a single-feature item. Decide this before deriving any phase.
- Derive each item's phase using the "Derived state" table in
  `docs/workflow.md`; base it on artifacts and contents, not timestamps. A
  `.gitkeep`-only child directory is `not started`.
- For each roadmap parent, parse the **Children** table and compute each child's
  readiness with the authoritative readiness definition in `docs/workflow.md` →
  "Dependencies and readiness". Do not restate its branch sequence here. In
  short: a `review.md` verdict of `approve` satisfies a dependency even when
  unshipped, and presence of the dependency's `ship.md` satisfies it too; a child
  with no dependencies is `ready`; a child in a cycle is never `ready`. Name the
  specific blocking children for each blocked child.
- Report the roadmap row separately from its children, showing
  `<ready>/<total> ready` plus a distribution tally of its children across phases
  (`<phase> <n>, ...`); list child rows beneath it. A standalone row keeps
  `checked/total tasks`.
- Emit `DANGLING-DEP` / `MISSING-CHILD` / `UNLISTED-CHILD` / `CYCLIC-DEP`
  findings for broken or cyclic references. Report them without failing and
  without modifying anything.
- Report the status table with `checked/total` task progress and the exact next
  command per item, then note any integrity findings and stale or inconsistent
  items.
- If a specific item is named in the argument, show its full artifact inventory.

If `work/` is empty, say so and recommend `/spec <feature>`. Do not start or run
any phase. End with the handoff block.
