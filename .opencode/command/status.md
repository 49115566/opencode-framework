---
description: "Report the phase of every work item by inspecting the work/ directory. Usage: /status"
agent: status
---

Produce a **status report**. This is read-only: do not edit any file.

Follow your Status agent instructions exactly. In particular:

- List `work/` and read each item's artifacts — frontmatter, `tasks.md` check
  boxes, `review.md` verdict, and any `ship.md` or detected PR.
- Derive each item's phase using the "Derived state" table in
  `docs/workflow.md`; base it on artifacts and contents, not timestamps.
- Report the status table with `checked/total` task progress and the exact next
  command per item, then note any stale or inconsistent items.
- If a specific item is named in the argument, show its full artifact inventory.

If `work/` is empty, say so and recommend `/spec <feature>`. Do not start or run
any phase. End with the handoff block.
